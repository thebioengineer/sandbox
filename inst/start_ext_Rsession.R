args <- commandArgs(trailingOnly=TRUE)
old <- options(timeout = 60 * 60 * 24 * 30);
on.exit(options(old))

library(sandbox)
sandbox:::evaluateSandbox(args[1],as.numeric(args[2]))