// Copyright (c) 2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.bazel.deploy.s3website;

import java.util.Arrays;
import java.util.Collection;

import org.junit.Assert;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

@RunWith(Parameterized.class)
public class MainTest {
    @Parameterized.Parameters
    public static Collection<Object[]> data() {
        return Arrays.asList(new Object[][] {
            { "", "", true },
            { "a", "a", true },
            { "", "*", true },
            { "", "**", true },
            { "ab", "a*", true },
            { "ab", "*b", true },
            { "*", "*", true },
            { "abcdef", "*", true },
            { "aa", "a*a", true },
            { "abcd", "*a*", true },
            { "abcdefa", "a*a", true },
            { "a/b.c", "a/*", true },

            { "", "a", false },
            { "a", "b", false },
            { "a", "*b", false },
            { "aba", "*b", false },
            { "", "**a", false },
        });
    }

    private final String key;
    private final String pattern;
    private final boolean shouldMatch;

    public MainTest(final String key, final String pattern, final boolean shouldMatch) {
        this.key = key;
        this.pattern = pattern;
        this.shouldMatch = shouldMatch;
    }

    @Test
    public void testPatternMatch() {
        Assert.assertEquals(String.format("Matching '%s' against '%s'", key, pattern),
                shouldMatch,
                Main.patternMatches(key, pattern));
    }
}
