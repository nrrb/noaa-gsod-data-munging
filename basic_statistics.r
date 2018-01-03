#! /usr/bin/env Rscript
d<-scan("stdin", quiet=TRUE)
cat("Min:", min(d), "Max:", max(d), "Median:", median(d), "Mean:", mean(d), sep="\n")
