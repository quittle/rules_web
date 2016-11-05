// Copyright (c) 2016 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.pngtastic;

import com.googlecode.pngtastic.core.PngImage;
import com.googlecode.pngtastic.core.PngOptimizer;

import java.io.FileNotFoundException;
import java.io.IOException;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

/**
 * Contains the main function and argument parsing capabilities.  This main class is necessary
 * because the original tool si too clunky and simply outputs the input file to the same filename
 * plus a suffix.
 */
public final class Main {
    private static final String ARG_INPUT_PNG = "input";
    private static final String ARG_OUTPUT_PNG = "output";
    private static final String ARG_LOG_LEVEL = "log-level";
    private static final String ARG_ITERATIONS = "iterations";
    private static final String ARG_COMPRESSOR = "compressor";
    private static final String ARG_REMOVE_GAMMA = "remove-gamma";
    private static final String ARG_COMPRESSION_LEVEL = "compression-level";

    /**
     * Parses command-line arguments. Exits with a return code if the args failed to be parsed.
     * @param args The args passed into the main function.
     * @return The parsed arguments.
     */
    private static CommandLine parseArgs(final String[] args) {
        final Options options = new Options()
            .addOption(Option.builder()
                    .argName("Input PNG")
                    .longOpt(ARG_INPUT_PNG)
                    .desc("The input png file")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Output PNG")
                    .longOpt(ARG_OUTPUT_PNG)
                    .desc("The output png file")
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Logging Level")
                    .longOpt(ARG_LOG_LEVEL)
                    .desc("The logging level")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Optimization Passes")
                    .longOpt(ARG_ITERATIONS)
                    .desc("The number of optimization passes to perform")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Alternate Compressor")
                    .longOpt(ARG_COMPRESSOR)
                    .desc("Path to an alternative compressor")
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Remove Gamma")
                    .longOpt(ARG_REMOVE_GAMMA)
                    .desc("Remove gamma correction info")
                    .build())
            .addOption(Option.builder()
                    .argName("Compression Level")
                    .longOpt(ARG_COMPRESSION_LEVEL)
                    .desc("The compresion level (0-9). " +
                          "Default is to brute force all for best result")
                    .build());

        try {
            return new DefaultParser().parse(options, args);
        } catch (final ParseException e) {
            System.out.println(e.getMessage());
            new HelpFormatter().printHelp("pngtastic", options);
            System.exit(1);
            return null;
        }
    }

    /**
     * Parses a {@link String} into an {@link Integer}.
     * @param value The value to convert.
     * @return an integer version of {@code value} or null if {@code value} is null.
     * @throws RuntimeException if {@code value} is not parsable.
     */
    private static Integer toInteger(final String value) throws RuntimeException {
        if (value == null) {
            return null;
        }

        try {
            return Integer.valueOf(value);
        } catch (final NumberFormatException e) {
            throw new RuntimeException(e);
        }
    }

    public static void main(final String[] args) throws FileNotFoundException, IOException {
        final CommandLine commandLine = parseArgs(args);

        final String in = commandLine.getOptionValue(ARG_INPUT_PNG);
        final String out = commandLine.getOptionValue(ARG_OUTPUT_PNG);
        final String logLevel = commandLine.getOptionValue(ARG_LOG_LEVEL);
        final Integer iterations = toInteger(commandLine.getOptionValue(ARG_ITERATIONS));
        final String compressor = commandLine.getOptionValue(ARG_COMPRESSOR);
        final Boolean removeGamma = Boolean.valueOf(commandLine.getOptionValue(ARG_REMOVE_GAMMA));
        final Integer compressionLevel =
                toInteger(commandLine.getOptionValue(ARG_COMPRESSION_LEVEL));

        final PngOptimizer pngOptimizer = new PngOptimizer(logLevel);
        pngOptimizer.setCompressor(compressor, iterations);
        final PngImage pngImage = new PngImage(in, logLevel);
        pngOptimizer.optimize(pngImage, out, removeGamma, compressionLevel);
    }
}
