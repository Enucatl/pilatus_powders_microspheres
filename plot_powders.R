#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(argparse)

theme_set(theme_bw(base_size=12) + theme(
    legend.key.size=unit(1, 'lines'),
    text=element_text(face='plain', family='CM Roman'),
    legend.title=element_text(face='plain'),
    axis.line=element_line(color='black'),
    axis.title.y=element_text(vjust=0.1),
    axis.title.x=element_text(vjust=0.1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.key = element_blank(),
    panel.border = element_blank()
))

commandline_parser = ArgumentParser(
        description="merge the datasets into one data.table")
commandline_parser$add_argument('-f', '--file',
            type='character', nargs='?',
            help='file with the data.table')
args = commandline_parser$parse_args()

table = readRDS(args$f)[v > 0.05]

print(table)

statistics = function(A, B, R, name) {
    return(list(
      mean_A=mean(A),
      sd_A=sd(A),
      mean_B=mean(B),
      sd_B=sd(B),
      mean_R=mean(R),
      sd_R=sd(R)
        )
        )
}

table$name = factor(table$name, levels=c("corn flour", "coffee", "rice flour", "sugar", "salt"))
setkey(table, name)
summary = table[, statistics(A, B, R), by=name]

print(summary)

visibility_histogram = ggplot(table, aes(x=v, fill=name)) + geom_density(alpha=0.2)
absorption_histogram = ggplot(table, aes(x=A, fill=name)) + geom_density(alpha=0.2)
dark_field_histogram = ggplot(table, aes(x=B, fill=name)) + geom_density(alpha=0.2)
ratio_histogram = ggplot(table, aes(x=R, fill=name)) +
    geom_density(alpha=0.2) +
    scale_x_continuous(limits = c(0, 10))

summaryplot = ggplot(summary) + 
    geom_point(aes(x=factor(name), y=mean_R, group=name), size=2) +
    geom_errorbar(aes(x=factor(name), ymax=mean_R + sd_R, ymin=mean_R - sd_R)) +
    labs(
         x="",
         y="R"
         )

print(visibility_histogram)
print(absorption_histogram)
print(ratio_histogram)
print(dark_field_histogram)
print(summaryplot)

width = 7
factor = 0.618
height = width * factor
ggsave("plots/powder_visibility.png", visibility_histogram, width=width, height=height, dpi=300)
ggsave("plots/powder_absorption.png", absorption_histogram, width=width, height=height, dpi=300)
ggsave("plots/powder_ratio.png", ratio_histogram, width=width, height=height, dpi=300)
ggsave("plots/powder_darkfield.png", dark_field_histogram, width=width, height=height, dpi=300)
ggsave("plots/powder_summary.png", summaryplot, width=width, height=height, dpi=300)

invisible(readLines(con="stdin", 1))
