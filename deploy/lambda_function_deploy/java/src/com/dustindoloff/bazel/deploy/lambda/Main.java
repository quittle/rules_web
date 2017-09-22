// Copyright (c) 2016-2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.bazel.deploy.lambda;

import com.amazonaws.AmazonClientException;
import com.amazonaws.services.lambda.AWSLambda;
import com.amazonaws.services.lambda.AWSLambdaClientBuilder;
import com.amazonaws.services.lambda.model.CreateFunctionRequest;
import com.amazonaws.services.lambda.model.Environment;
import com.amazonaws.services.lambda.model.FunctionCode;
import com.amazonaws.services.lambda.model.ResourceConflictException;
import com.amazonaws.services.lambda.model.UpdateFunctionCodeRequest;
import com.amazonaws.services.lambda.model.UpdateFunctionConfigurationRequest;
import com.amazonaws.regions.Regions;

import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.File;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.ByteBuffer;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Map;

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
    private static final String ARG_FUNCTION_NAME = "function-name";
    private static final String ARG_FUNCTION_HANDLER = "function-handler";
    private static final String ARG_FUNCTION_ROLE = "function-role";
    private static final String ARG_FUNCTION_RUNTIME = "function-runtime";
    private static final String ARG_FUNCTION_ZIP = "function-zip";
    private static final String ARG_REGION = "region";
    private static final String ARG_MEMORY = "memory";
    private static final String ARG_TIMEOUT = "timeout";
    private static final String ARG_ENVIRONMENT = "environment";

    private static final Gson GSON = new Gson();
    private static final Type STRING_MAP_TYPE = new TypeToken<Map<String, String>>(){}.getType();

    private static Options buildOptions() {
        return new Options()
            .addOption(Option.builder()
                    .argName("Function Name")
                    .longOpt(ARG_FUNCTION_NAME)
                    .desc("The name of the AWS Lambda function")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Function Handler")
                    .longOpt(ARG_FUNCTION_HANDLER)
                    .desc("The AWS Lambda function handler")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Function IAM Role")
                    .longOpt(ARG_FUNCTION_ROLE)
                    .desc("The IAM role the function should run as")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Function Runtime")
                    .longOpt(ARG_FUNCTION_RUNTIME)
                    .desc("The runtime language for the function")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Function Zip")
                    .longOpt(ARG_FUNCTION_ZIP)
                    .desc("The zip or jar file that serves as the function's code")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Region")
                    .longOpt(ARG_REGION)
                    .desc("AWS region the function should live in")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Memory")
                    .longOpt(ARG_MEMORY)
                    .desc("Amount of memory to provide the function when invoking")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Timeout")
                    .longOpt(ARG_TIMEOUT)
                    .desc("Maximum runtime for each function invocation")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Environment Variables")
                    .longOpt(ARG_ENVIRONMENT)
                    .desc("Environment variables to run the function with. Must be a JSON object " +
                            "of strings to strings.")
                    .hasArg()
                    .build());
    }

    private static ByteBuffer fileToByteBuffer(final File file) throws IOException {
        final Path path = file.toPath();
        final byte[] bytes = Files.readAllBytes(path);
        return ByteBuffer.wrap(bytes);
    }

    private static Integer parseInteger(final String integer) {
        if (integer == null) {
            return null;
        }

        return Integer.valueOf(integer);
    }

    private static Map<String, String> parseMap(final String jsonMap) {
        if (jsonMap == null) {
            return null;
        }

        return GSON.fromJson(jsonMap, STRING_MAP_TYPE);
    }

    private static boolean createFunction(final AWSLambda lambdaClient,
                                          final String functionName,
                                          final String functionHandler,
                                          final String functionRole,
                                          final String functionRuntime,
                                          final Integer memory,
                                          final Integer timeout,
                                          final Map<String, String> functionEnvironment,
                                          final File functionZip) {
        final ByteBuffer functionZipBytes;
        try {
            functionZipBytes = fileToByteBuffer(functionZip);
        } catch (final IOException e) {
            System.err.println(e.getMessage());
            return false;
        }

        final Environment environment = functionEnvironment != null ?
                new Environment().withVariables(functionEnvironment) :
                null;

        try {
            lambdaClient.createFunction(new CreateFunctionRequest()
                    .withFunctionName(functionName)
                    .withHandler(functionHandler)
                    .withRole(functionRole)
                    .withRuntime(functionRuntime)
                    .withMemorySize(memory)
                    .withTimeout(timeout)
                    .withEnvironment(environment)
                    .withCode(new FunctionCode()
                            .withZipFile(functionZipBytes)));
        } catch (final ResourceConflictException e) {
            System.out.println("Unable to create function as it already exists. " +
                               "Updating existing function.");
            System.out.print("Updating code... ");
            System.out.flush();
            lambdaClient.updateFunctionCode(new UpdateFunctionCodeRequest()
                    .withFunctionName(functionName)
                    .withZipFile(functionZipBytes));
            System.out.println("Done");
            System.out.print("Updating configuration... ");
            System.out.flush();
            lambdaClient.updateFunctionConfiguration(new UpdateFunctionConfigurationRequest()
                    .withFunctionName(functionName)
                    .withHandler(functionHandler)
                    .withRole(functionRole)
                    .withRuntime(functionRuntime)
                    .withMemorySize(memory)
                    .withTimeout(timeout)
                    .withEnvironment(environment));
            System.out.println("Done");
        } catch (final AmazonClientException e) {
            System.err.println(e.getMessage());
            return false;
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
            new HelpFormatter().printHelp("lambdaDeploy", options);
            System.exit(1);
            return;
        }

        final String functionName = commandLine.getOptionValue(ARG_FUNCTION_NAME);
        final String functionHandler = commandLine.getOptionValue(ARG_FUNCTION_HANDLER);
        final String functionRole = commandLine.getOptionValue(ARG_FUNCTION_ROLE);
        final String functionRuntime = commandLine.getOptionValue(ARG_FUNCTION_RUNTIME);
        final File functionZip = new File(commandLine.getOptionValue(ARG_FUNCTION_ZIP));
        final String regionString = commandLine.getOptionValue(ARG_REGION);
        final String memoryString = commandLine.getOptionValue(ARG_MEMORY);
        final String timeoutString = commandLine.getOptionValue(ARG_TIMEOUT);
        final String environmentString = commandLine.getOptionValue(ARG_ENVIRONMENT);

        final Regions region =
                regionString == null ? Regions.DEFAULT_REGION : Regions.fromName(regionString);
        final Integer memory = parseInteger(memoryString);
        final Integer timeout = parseInteger(timeoutString);
        final Map<String, String> environment = parseMap(environmentString);

        System.out.println("Running Lambda Deploy");

        final AWSLambda lambdaClient = AWSLambdaClientBuilder.standard()
                .withRegion(region)
                .build();

        if (!createFunction(lambdaClient, functionName, functionHandler, functionRole,
                functionRuntime, memory, timeout, environment, functionZip)) {
            System.out.println("Unable to create function");
            System.exit(2);
            return;
        }

        System.out.println("Deployment Complete");
    }

    private Main() {}
}
