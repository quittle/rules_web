// Copyright (c) 2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.injecthtml;

import br.com.starcode.parccser.ParserException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

import net.htmlparser.jericho.Element;
import net.htmlparser.jericho.OutputDocument;
import net.htmlparser.jericho.Segment;
import net.htmlparser.jericho.Source;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.DefaultParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

import org.apache.commons.io.FileUtils;

import static br.com.starcode.jerichoselector.jerQuery.$;

/**
 * Contains the main function and argument parsing capabilities
 */
public final class Main {
    private static final String ARG_OUTER_HTML = "outer-html";
    private static final String ARG_INNER_HTML = "inner-html";
    private static final String ARG_QUERY_SELECTOR = "query-selector";
    private static final String ARG_INSERTION_MODE = "insertion-mode";
    private static final String ARG_INSERTION_MODE_DEFAULT = InsertionMode.REPLACE_CONTENTS.getName();
    private static final String ARG_OUTPUT = "output";

    private static enum InsertionMode {
        APPEND("append"),
        PREPEND("prepend"),
        REPLACE_CONTENTS("replace_contents"),
        REPLACE_NODE("replace_node");

        private final String name;

        private InsertionMode(final String name) {
            this.name = name;
        }

        public String getName() {
            return name;
        }

        public static InsertionMode from(final String name) {
            for (InsertionMode mode : InsertionMode.values()) {
                if (mode.name.equalsIgnoreCase(name)) {
                    return mode;
                }
            }
            return null;
        }
    }


    private static Options buildOptions() {
        return new Options()
            .addOption(Option.builder()
                    .argName("Outer HTML")
                    .longOpt(ARG_OUTER_HTML)
                    .desc("The outer HTML fragment to inject into")
                    .type(File.class)
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Inner HTML")
                    .longOpt(ARG_INNER_HTML)
                    .desc("The HTML fragment to inject")
                    .type(File.class)
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Query Selector")
                    .longOpt(ARG_QUERY_SELECTOR)
                    .desc("The query selector to find where to inject the inner HTML")
                    .type(String.class)
                    .required()
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Insertion Mode")
                    .longOpt(ARG_INSERTION_MODE)
                    .desc("The mode to use when injecting the inner HTML")
                    .type(String.class)
                    .hasArg()
                    .build())
            .addOption(Option.builder()
                    .argName("Output File")
                    .longOpt(ARG_OUTPUT)
                    .desc("The file to write the injected HTML fragment to")
                    .type(File.class)
                    .required()
                    .hasArg()
                    .build());
    }

    @SuppressWarnings("unchecked")
    private static <T> T getOption(final CommandLine commandLine, final String arg, final T defaultValue) {
        try {
            return (T) commandLine.getParsedOptionValue(arg);
        } catch (final ParseException e) {
            return defaultValue;
        }
    }

    @SuppressWarnings("unchecked")
    private static <T> T getOption(final CommandLine commandLine, final String arg) {
        try {
            return (T) commandLine.getParsedOptionValue(arg);
        } catch (final ParseException e) {
            throw new RuntimeException("Unable to parse arg: " + arg);
        }
    }

    public static void main(final String[] args) throws IOException {
        final Options options = buildOptions();
        final CommandLineParser parser = new DefaultParser();
        final CommandLine commandLine;
        try {
            commandLine = parser.parse(options, args);
        } catch (final ParseException e) {
            System.out.println(e.getMessage());
            new HelpFormatter().printHelp("injectHtml", options);
            System.exit(1);
            return;
        }

        final File outerHtml = getOption(commandLine, ARG_OUTER_HTML);
        final File innerHtml = getOption(commandLine, ARG_INNER_HTML);
        final String querySelector = getOption(commandLine, ARG_QUERY_SELECTOR);
        final InsertionMode insertionMode = InsertionMode.from(getOption(commandLine, ARG_INSERTION_MODE, ARG_INSERTION_MODE_DEFAULT));
        final File output = getOption(commandLine, ARG_OUTPUT);

        final Source outerSource = new Source(outerHtml);
        final Element selectedElement;
        try {
            selectedElement = $(outerSource, querySelector).get(0);
        } catch (final ParserException e) {
            System.out.println("Invalid selector: \"" + querySelector + "\" - " + e.getMessage());
            System.exit(2);
            return;
        }
        final String innerText = FileUtils.readFileToString(innerHtml, StandardCharsets.UTF_8);
        final Segment selectedElementContent = selectedElement.getContent();

        final OutputDocument outputDocument = new OutputDocument(outerSource);
        switch (insertionMode) {
            case APPEND:
                outputDocument.replace(selectedElementContent, selectedElementContent.toString() + innerText);
                break;
            case PREPEND:
                outputDocument.replace(selectedElementContent, innerText + selectedElementContent.toString());
                break;
            case REPLACE_CONTENTS:
                outputDocument.replace(selectedElementContent, innerText);
                break;
            case REPLACE_NODE:
                outputDocument.replace(selectedElement, innerText);
                break;
            default:
                throw new IllegalStateException("Unspported insertion mode: " + insertionMode);
        }
        FileUtils.writeStringToFile(output, outputDocument.toString(), StandardCharsets.UTF_8);
    }
}
