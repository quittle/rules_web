// Copyright (c) 2017 Dustin Doloff
// Licensed under Apache License v2.0

package com.dustindoloff.bazel.deploy.lambda;

import com.amazonaws.regions.Regions;
import com.amazonaws.services.lambda.model.Runtime;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;

import org.junit.Assert;
import org.junit.Test;

public class ValidationTest {
    private static boolean hasSimpleConstructor(final Class<?> clazz) {
        try {
            clazz.getConstructor();
            return true;
        } catch (final NoSuchMethodException e) {
            return false;
        }
    }

    @Test
    public void ensureFunctionHandlerExists() {
        final String handler = System.getProperty("handler");
        Assert.assertNotNull("Handler not passed in", handler);

        final String[] handlerParts = handler.split("::");
        Assert.assertTrue("Invalid handler name", 3 > handlerParts.length);
        final String handlerAbsoluteClass = handlerParts[0];
        final String handlerMethod;
        if (handlerParts.length == 2) {
            handlerMethod = handlerParts[1];
        } else {
            handlerMethod = null;
        }

        try {
            final Class<?> handlerClass = Class.forName(handlerAbsoluteClass);
            if (handlerMethod != null) {
                final int handlerClassModifiers = handlerClass.getModifiers();
                final boolean handlerClassHasDefaultConstructor = hasSimpleConstructor(handlerClass);
                Assert.assertTrue(
                        String.format("No valid method found on %s with name %s",
                                handlerAbsoluteClass, handlerMethod),
                        Arrays.stream(handlerClass.getMethods())
                                .filter(method -> method.getName().equals(handlerMethod))
                                .map(Method::getModifiers)
                                .anyMatch(modifiers ->
                                        Modifier.isStatic(modifiers) ||
                                        (
                                            ! Modifier.isAbstract(handlerClassModifiers) &&
                                            handlerClassHasDefaultConstructor
                                        )));
            }
        } catch (final ClassNotFoundException e) {
            Assert.fail(String.format("Handler class not found: %s", handlerAbsoluteClass));
        } catch (final LinkageError e) {
            Assert.fail(String.format("Unable to initialize handler class: %s. Reason: %s",
                    handlerAbsoluteClass, e.getMessage()));
        }
    }

    @Test
    public void ensureFunctionRegionExists() {
        // Region is optional and may be defaulted
        final String region = System.getProperty("region");
        if (region == null) {
            return;
        }

        try {
            Regions.fromName(region);
        } catch (final IllegalArgumentException e) {
            Assert.fail(String.format("Invalid region provided: %s", region));
        }
    }

    @Test
    public void ensureFunctionRuntimeExists() {
        final String runtime = System.getProperty("runtime");
        Assert.assertNotNull("Runtime not passed in", runtime);

        try {
            Runtime.fromValue(runtime);
        } catch (final IllegalArgumentException e) {
            Assert.fail(String.format("Invalid runtime: %s", runtime));
        }
    }
}
