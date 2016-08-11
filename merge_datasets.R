#!/usr/bin/env Rscript

library(data.table)
library(argparse)

commandline_parser = ArgumentParser(
        description="merge the datasets into one data.table")
commandline_parser$add_argument('-f', '--file',
            type='character', nargs='?', default='reconstructed.csv',
            help='file with the data.table')
commandline_parser$add_argument('-o', '--output',
            type='character', nargs='?', default='data/pixels.rds',
            help='file with all the pixels')
args = commandline_parser$parse_args()

table = fread(args$f)
print(table)

maketable = function(csv, size, voltage) {
    t = fread(csv)
    t[, voltage := voltage]
    t[, size := size]
    return(t)
}

pixels = table[, maketable(csv, size, voltage), by=reconstructed]
print(pixels)

saveRDS(pixels, args$o)
