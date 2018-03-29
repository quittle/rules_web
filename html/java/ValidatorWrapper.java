/**
 * Copyright (c) 2018 Dustin Toff
 * Licensed under Apache License v2.0
 */

import java.util.Arrays;
import java.io.File;

import nu.validator.client.SimpleCommandLineValidator;

public class ValidatorWrapper {
    public static void main(final String[] args) throws Exception {
        final File stampFile = new File(args[0]);

        final String[] validatorArgs = Arrays.copyOfRange(args, 1, args.length);
        SimpleCommandLineValidator.main(validatorArgs);

        stampFile.createNewFile();
    }

    private ValidatorWrapper() {}
}