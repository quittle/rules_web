// Copyright (c) 2016-2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.bazel.deploy.s3website;

import com.amazonaws.AmazonClientException;
import com.amazonaws.SdkClientException;
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

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Type;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.time.temporal.ChronoUnit;

import javax.annotation.Nullable;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.StringUtils;

/**
 * Contains the main function and argument parsing capabilities
 */
@SuppressWarnings("InconsistentOverloads")
public final class Main {
    public static final int CACHE_DURATION_IMMUTABLE = -1;

    private static final String ARG_WEBSITE_ZIP = "website-zip";
    private static final String ARG_BUCKET = "bucket";
    private static final String ARG_CACHE_DURATIONS = "cache-durations";
    private static final String ARG_CONTENT_TYPES = "content-types";
    private static final String ARG_PATH_REDIRECTS = "path-redirects";
    private static final String ARG_AWS_ACCESS_KEY = "aws-access-key";
    private static final String ARG_AWS_SECRET_KEY = "aws-secret-key";

    private static final long ONE_YEAR_SECONDS = ChronoUnit.YEARS.getDuration().getSeconds();
    private static final Type CONTENT_TYPES_FORMAT =
            new TypeToken<HashMap<String, String>>(){}.getType();
    private static final Type CACHE_DURATION_FORMAT =
            new TypeToken<LinkedHashMap<Integer, List<String>>>(){}.getType();
    private static final Type PATH_REDIRECTS_FORMAT =
            new TypeToken<Map<String, String>>(){}.getType();


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
                    .argName("Cache Control Durations")
                    .longOpt(ARG_CACHE_DURATIONS)
                    .desc("Json object representing how long to cache each entry")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Additional Content-Types")
                    .longOpt(ARG_CONTENT_TYPES)
                    .desc("Json object representing a map of file extensions to content type")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Path Redirects")
                    .longOpt(ARG_PATH_REDIRECTS)
                    .desc("Json object representing a map of paths to redirects")
                    .hasArg()
                    .build());
    }

    @Nullable
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

    @Nullable
    private static String getContentType(final String fileName,
                                         final Map<String, String> additionalContentTypes) {
        final String extension = FilenameUtils.getExtension(fileName);

        final String providedContentType = additionalContentTypes.get(extension);
        if (providedContentType != null) {
            return providedContentType;
        }

        String mimeType = URLConnection.guessContentTypeFromName(fileName);
        if (mimeType != null) {
            return mimeType;
        }
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
                                                        final String bucket) {
        return new PutObjectRequest(bucket, null, (File) null)
                .withMetadata(metadata)
                .withCannedAcl(CannedAccessControlList.PublicRead);
    }

    public static boolean patternMatches(final String key, final String pattern) {
        return patternMatches(key, 0, pattern, 0);
    }

    private static boolean patternMatches(final String key, final int keyIndex,
                                          final String pattern, final int patternIndex) {
        // If both are at the end, it is a match
        if (keyIndex == key.length() && patternIndex == pattern.length()) {
            return true;
        }

        // If there's no more pattern, it is not a match
        if (patternIndex >= pattern.length()) {
            return false;
        }

        // If there's no more key, it is only a match on wildcard
        if (keyIndex >= key.length()) {
            for (int i = patternIndex; i < pattern.length(); i++) {
                if (pattern.charAt(i) != '*') {
                    return false;
                }
            }
            return true;
        }

        char c = key.charAt(keyIndex);
        char p = pattern.charAt(patternIndex);
        if (p == '*') {
            return patternMatches(key, keyIndex + 1, pattern, patternIndex) ||
                    patternMatches(key, keyIndex, pattern, patternIndex + 1) ||
                    patternMatches(key, keyIndex + 1, pattern, patternIndex + 1);
        } else if (p == c) {
            return patternMatches(key, keyIndex + 1, pattern, patternIndex + 1);
        } else {
            return false;
        }
    }

    private static String getCacheControlValue(final int cacheDuration) {
        List<String> cacheControl = new ArrayList<>();
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

    private static String getCacheControlValue(final String key,
                                               final LinkedHashMap<Integer, List<String>>
                                                    cacheDurations) {
        final Optional<Integer> cacheDuration = cacheDurations.entrySet().stream()
            .filter(entry ->
                entry.getValue().stream().anyMatch(pattern -> patternMatches(key, pattern))
            )
            .map(entry -> entry.getKey())
            .findFirst();
        if (!cacheDuration.isPresent()) {
            throw new IllegalArgumentException(
                    String.format("'%s' not matched in cache duration patterns", key));
        }

        return getCacheControlValue(cacheDuration.get());
    }

    private static boolean upload(final AmazonS3 s3Client,
                                  final String bucket,
                                  final ZipFile zipFile,
                                  final LinkedHashMap<Integer, List<String>> cacheDurations,
                                  final Map<String, String> additionalContentTypes) {

        final ObjectMetadata metadata = new ObjectMetadata();
        final PutObjectRequest request = getPutObjectRequest(metadata, bucket);

        boolean failed = false;
        final Enumeration<? extends ZipEntry> entries = zipFile.entries();
        while (entries.hasMoreElements()) {
            final ZipEntry entry = entries.nextElement();
            final String key = entry.getName();
            request.setKey(key);
            metadata.setCacheControl(getCacheControlValue(key, cacheDurations));
            metadata.setContentType(getContentType(key, additionalContentTypes));
            if (metadata.getContentType() == null) {
                System.out.println("Unrecognized file type: " + key);
                failed = true;
            }
            metadata.setContentLength(entry.getSize());
            try {
                request.setInputStream(zipFile.getInputStream(entry));

                System.out.println(
                        String.format("Uploading %s: %s", key, metadata.getCacheControl()));
                s3Client.putObject(request);
            } catch (final AmazonClientException|IOException e) {
                System.err.println(String.format("Failed to upload %s due to %s",
                        entry.getName(), e.getMessage()));
                failed = true;
            }
        }
        return !failed;
    }

    private static boolean updateRedirects(final AmazonS3 s3Client,
                                           final String bucket,
                                           final Map<String, String> pathRedirects) {
        for (final Map.Entry<String, String> redirect : pathRedirects.entrySet()) {
            final String key = StringUtils.stripStart(redirect.getKey(), "/");
            final String value = redirect.getValue();
            try {
                System.out.println(String.format("Putting redirect %s -> %s", key, value));
                s3Client.putObject(new PutObjectRequest(bucket, key, value)
                        .withCannedAcl(CannedAccessControlList.PublicRead));
            } catch (final SdkClientException e) {
                System.err.println(String.format("Failed to setup redirect %s -> %s due to %s",
                        key, value, e.getMessage()));
                return false;
            }
        }
        return true;

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

        final Gson gson = new Gson();

        final File websiteZip = new File(commandLine.getOptionValue(ARG_WEBSITE_ZIP));
        final String s3Bucket = commandLine.getOptionValue(ARG_BUCKET);

        final String cacheDurationSerialized = commandLine.getOptionValue(ARG_CACHE_DURATIONS);
        final LinkedHashMap<Integer, List<String>> cacheDurations =
                gson.fromJson(cacheDurationSerialized, CACHE_DURATION_FORMAT);

        final String contentTypesSerialized = commandLine.getOptionValue(ARG_CONTENT_TYPES);
        final Map<String, String> contentTypes =
                gson.fromJson(contentTypesSerialized, CONTENT_TYPES_FORMAT);

        final String pathRedirectsSerialized = commandLine.getOptionValue(ARG_PATH_REDIRECTS);
        final Map<String, String> pathRedirects =
                gson.fromJson(pathRedirectsSerialized, PATH_REDIRECTS_FORMAT);

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
            System.out.println("Unable to make bucket a website.");
            System.exit(5);
            return;
        }

        if (!updateRedirects(s3Client, s3Bucket, pathRedirects)) {
            System.out.println("Unable to setup redirects.");
            System.exit(7);
            return;
        }

        if (!upload(s3Client, s3Bucket, zipFile, cacheDurations, contentTypes)) {
            System.out.println("Unable to upload to S3.");
            System.exit(6);
            return;
        }

        System.out.println("Deployment Complete");
    }

    private Main() {}
}
