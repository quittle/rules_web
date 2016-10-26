// Copyright (c) 2016 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.s3websitedeploy;

import com.amazonaws.AmazonClientException;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.ListObjectsV2Request;
import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3ObjectSummary;

import java.io.File;
import java.io.IOException;
import java.util.Enumeration;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Contains the main function and argument parsing capabilities
 */
public final class Main {
    private static final String ARG_WEBSITE_ZIP = "website-zip";
    private static final String ARG_BUCKET = "bucket";
    private static final String ARG_AWS_ACCESS_KEY = "aws-access-key";
    private static final String ARG_AWS_SECRET_KEY = "aws-secret-key";

    private static Options buildOptions() {
        return new Options()
            .addOption(Option.builder()
                    .argName("Website Zip Path")
                    .longOpt(ARG_WEBSITE_ZIP)
                    .desc("The zip containing the full site")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("S3 Bucket")
                    .longOpt(ARG_BUCKET)
                    .desc("The S3 bucket to upload to")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("AWS Access Key")
                    .longOpt(ARG_AWS_ACCESS_KEY)
                    .desc("The AWS Access Key ID to use")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("AWS Secret Key")
                    .longOpt(ARG_AWS_SECRET_KEY)
                    .desc("The AWS Secret Key ID to use")
                    .required()
                    .hasArg()
                    .build());
    }

    private static ZipFile getAsValidZip(final File zipFile) {
        try {
            return new ZipFile(zipFile, ZipFile.OPEN_READ);
        } catch (final IOException|SecurityException e) {
            return null;
        }
    }

    private static Region getBucketRegion(final AmazonS3 s3Client, final String bucket) {
        try {
            return Region.getRegion(Regions.fromName(s3Client.getBucketLocation(bucket)));
        } catch (final AmazonClientException|IllegalArgumentException e) {
            return null;
        }
    }

    private static boolean emptyBucket(final AmazonS3 s3Client, final String bucket) {
        final ListObjectsV2Request request = new ListObjectsV2Request();
        request.setBucketName(bucket);

        String continuationToken = null;
        ListObjectsV2Result result;
        do {
            request.setContinuationToken(continuationToken);
            result = s3Client.listObjectsV2(bucket);
            for (final S3ObjectSummary summary : result.getObjectSummaries()) {
                s3Client.deleteObject(bucket, summary.getKey());
            }

            continuationToken = result.getNextContinuationToken();
        } while (result.isTruncated());

        return true;
    }

    private static boolean upload(final AmazonS3 s3Client, final String bucket,
                                  final ZipFile zipFile) {
        boolean failed = false;
        final ObjectMetadata data = new ObjectMetadata();
        final Enumeration<? extends ZipEntry> entries = zipFile.entries();
        while (entries.hasMoreElements()) {
            final ZipEntry entry = entries.nextElement();
            data.setContentLength(entry.getSize());
            try {
                s3Client.putObject(bucket, entry.getName(), zipFile.getInputStream(entry), data);
            } catch (final AmazonClientException|IOException e) {
                failed = true;
            }
        }
        return !failed;
    }

    public static void main(final String[] args) {
        final Options options = buildOptions();
        final CommandLineParser parser = new DefaultParser();
        final CommandLine commandLine;
        try {
            commandLine = parser.parse(options, args);
        } catch (final ParseException e) {
            System.out.println(e.getMessage());
            new HelpFormatter().printHelp("s3WebsiteDeploy", options);
            System.exit(1);
            return;
        }

        final File websiteZip = new File(commandLine.getOptionValue(ARG_WEBSITE_ZIP));
        final String s3Bucket = commandLine.getOptionValue(ARG_BUCKET);
        final String awsAccessKey = commandLine.getOptionValue(ARG_AWS_ACCESS_KEY);
        final String awsSecretKey = commandLine.getOptionValue(ARG_AWS_SECRET_KEY);

        final ZipFile zipFile = getAsValidZip(websiteZip);
        if (zipFile == null) {
            System.out.println("Invalid zip file passed in");
            System.exit(2);
            return;
        }

        System.out.println("Running S3 Website Deploy");

        final AmazonS3 s3Client =
                new AmazonS3Client(new BasicAWSCredentials(awsAccessKey, awsSecretKey));

        final Region bucketRegion = getBucketRegion(s3Client, s3Bucket);

        if (bucketRegion == null) {
            System.out.println("Unable to get the region for the bucket.");
            System.exit(3);
            return;
        }

        s3Client.setRegion(bucketRegion);

        if (!emptyBucket(s3Client, s3Bucket)) {
            System.out.println("Unable to upload to empty bucket.");
            System.exit(4);
            return;
        }

        if (!upload(s3Client, s3Bucket, zipFile)) {
            System.out.println("Unable to upload to S3.");
            System.exit(5);
            return;
        }

        System.out.println("Deployment Complete");
    }
}
