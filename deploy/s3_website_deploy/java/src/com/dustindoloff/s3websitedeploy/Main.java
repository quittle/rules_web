// Copyright (c) 2016-2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.s3websitedeploy;

import com.amazonaws.AmazonClientException;
import com.amazonaws.SdkClientException;
import com.amazonaws.regions.DefaultAwsRegionProviderChain;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.BucketWebsiteConfiguration;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ListObjectsV2Request;
import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import com.amazonaws.regions.Regions;

import java.io.File;
import java.io.IOException;
import java.net.URLConnection;
import java.util.Enumeration;
import java.util.LinkedList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.time.temporal.ChronoUnit;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.FilenameUtils;

/**
 * Contains the main function and argument parsing capabilities
 */
public final class Main {
    public static final int CACHE_DURATION_IMMUTABLE = -1;

    private static final String ARG_WEBSITE_ZIP = "website-zip";
    private static final String ARG_BUCKET = "bucket";
    private static final String ARG_CACHE_DURATION = "cache-duration";
    private static final String ARG_AWS_ACCESS_KEY = "aws-access-key";
    private static final String ARG_AWS_SECRET_KEY = "aws-secret-key";

    private static long ONE_YEAR_SECONDS = ChronoUnit.YEARS.getDuration().getSeconds();

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
                    .argName("Cache Control Duration")
                    .longOpt(ARG_CACHE_DURATION)
                    .desc("Whether or not the site uses immutably named paths")
                    .hasArg()
                    .type(Number.class)
                    .build());
    }

    private static ZipFile getAsValidZip(final File zipFile) {
        try {
            return new ZipFile(zipFile, ZipFile.OPEN_READ);
        } catch (final IOException|SecurityException e) {
            return null;
        }
    }

    private static boolean emptyBucket(final AmazonS3 s3Client, final String bucket) {
        final ListObjectsV2Request request = new ListObjectsV2Request();
        request.setBucketName(bucket);

        System.out.println("Emptying bucket");

        String continuationToken = null;
        ListObjectsV2Result result;
        do {
            request.setContinuationToken(continuationToken);
            result = s3Client.listObjectsV2(bucket);
            for (final S3ObjectSummary summary : result.getObjectSummaries()) {
                final String key = summary.getKey();
                System.out.println("Deleting: " + key);
                s3Client.deleteObject(bucket, key);
            }

            continuationToken = result.getNextContinuationToken();
        } while (result.isTruncated());

        return true;
    }

    private static boolean makeBucketWebsite(final AmazonS3 s3Client, final String bucket) {
        final BucketWebsiteConfiguration configuration =
                new BucketWebsiteConfiguration("index.html");
        try {
            s3Client.setBucketWebsiteConfiguration(bucket, configuration);
            return true;
        } catch (final SdkClientException e) {
            return false;
        }
    }

    private static String getCacheControlValue(final int cacheDuration) {
        List<String> cacheControl = new LinkedList<>();
        cacheControl.add("public");
        if (cacheDuration >= 0) {
            cacheControl.add(String.format("max-age=%d", cacheDuration));
        } else if (cacheDuration == CACHE_DURATION_IMMUTABLE) {
            cacheControl.add(String.format("max-age=%d", ONE_YEAR_SECONDS));
            cacheControl.add("immutable");
        } else {
            throw new IllegalArgumentException(String.format("Cache duration invalid: %d",
                    cacheDuration));
        }
        return String.join(", ", cacheControl);
    }

    private static String getContentType(final String fileName) {
        String mimeType = URLConnection.guessContentTypeFromName(fileName);
        if (mimeType != null) {
            return mimeType;
        }
        final String extension = FilenameUtils.getExtension(fileName);
        switch (extension) {
            case "avi":
                return "video/x-msvideo";
            case "css":
                return "text/css";
            case "eot":
                return "application/vnd.ms-fontobject";
            case "flv":
                return "video/x-flv";
            case "gif":
                return "image/gif";
            case "htc":
                return "text/x-component";
            case "html":
                return "text/html";
            case "jpeg":
            case "jpg":
                return "image/jpeg";
            case "js":
                return "text/javascript";
            case "map":
                return "text/plain";
            case "mp4":
                return "video/mp4";
            case "otf":
                return "font/opentype";
            case "png":
                return "image/png";
            case "sfnt":
                return "application/font-sfnt";
            case "svg":
                return "image/svg+xml";
            case "ttf":
                return "application/x-font-ttf";
            case "txt":
                return "text/plain";
            case "woff":
                return "application/font-woff";
            case "woff2":
                return "application/font-woff2";
            default:
                return null;
        }
    }

    private static PutObjectRequest getPutObjectRequest(final ObjectMetadata metadata,
                                                        final String bucket,
                                                        final int cacheDuration) {
        metadata.setCacheControl(getCacheControlValue(cacheDuration));

        return new PutObjectRequest(bucket, null, (File) null)
                .withMetadata(metadata)
                .withCannedAcl(CannedAccessControlList.PublicRead);
    }

    private static boolean upload(final AmazonS3 s3Client, final String bucket,
                                  final ZipFile zipFile, final int cacheDuration) {

        final ObjectMetadata metadata = new ObjectMetadata();
        final PutObjectRequest request = getPutObjectRequest(metadata, bucket, cacheDuration);

        boolean failed = false;
        final Enumeration<? extends ZipEntry> entries = zipFile.entries();
        while (entries.hasMoreElements()) {
            final ZipEntry entry = entries.nextElement();
            final String key = entry.getName();
            request.setKey(key);
            metadata.setContentType(getContentType(key));
            if (metadata.getContentType() == null) {
                System.out.println("Unrecognized file type: " + key);
                failed = true;
            }
            metadata.setContentLength(entry.getSize());
            try {
                request.setInputStream(zipFile.getInputStream(entry));

                System.out.println(String.format("Uploading %s", key));
                s3Client.putObject(request);
            } catch (final AmazonClientException|IOException e) {
                System.err.println(String.format("Failed to upload %s due to %s",
                        entry.getName(), e.getMessage()));
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
        final int cacheDuration;
        try {
            cacheDuration = ((Number) commandLine.getParsedOptionValue(ARG_CACHE_DURATION)).intValue();
        } catch (final ParseException e) {
            System.out.println("Invalid cache duration");
            System.out.println(e.getMessage());
            System.exit(2);
            return;
        }

        final ZipFile zipFile = getAsValidZip(websiteZip);
        if (zipFile == null) {
            System.out.println("Invalid zip file passed in");
            System.exit(2);
            return;
        }

        System.out.println("Running S3 Website Deploy");

        final AmazonS3 s3Client = AmazonS3ClientBuilder.standard()
                .withRegion(Regions.DEFAULT_REGION)
                .withForceGlobalBucketAccessEnabled(true)
                .build();

        if (!emptyBucket(s3Client, s3Bucket)) {
            System.out.println("Unable to upload to empty bucket.");
            System.exit(4);
            return;
        }

        if (!makeBucketWebsite(s3Client, s3Bucket)) {
            System.out.println("Unable to make bucket a website");
            System.exit(5);
            return;
        }

        if (!upload(s3Client, s3Bucket, zipFile, cacheDuration)) {
            System.out.println("Unable to upload to S3.");
            System.exit(6);
            return;
        }

        System.out.println("Deployment Complete");
    }
}
