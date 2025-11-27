suppressPackageStartupMessages({
library(ggplot2)
library(ggridges)
library(ggbeeswarm)
library(cowplot)
library(dplyr)
})

df <- read.table(snakemake@input[[1]], header=TRUE, sep="\t")

df$genome <- sapply(df$file, function(x) {
    x <- sub(".*Tcruzi", "", x)      # quita prefijo
    x <- sub("2018$", "", x)         # si termina en 2018, lo borra
    x <- sub("\\.fasta.*$", "", x)   # quita extensión
    return(x)
})

### Plot function for GC violin ###
plot_violin_gc <- function(data, plot_title, y_label) {
  data$file <- factor(data$file, levels = sort(unique(data$file)))

  count_data <- data %>%
    group_by(file) %>%
    summarise(count = n(), .groups = "drop")

  ggplot(data, aes(x = file, y = gc, fill = file)) +
    geom_violin(alpha = 0.7, width = 0.5, show.legend = FALSE) +
    geom_boxplot(width = 0.1, fill = "white", alpha = 0.3, show.legend = FALSE) +
    scale_fill_brewer(palette = "Dark2") +
    geom_text(data = count_data,
              aes(x = file, y = max(data$gc, na.rm = TRUE) * 1.05,
                  label = count),
              vjust = 0, color = "black", size = 3.5) +
    labs(title = plot_title, y = y_label) +
    theme_minimal() +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.15)))
}

### Plot function for length ###
plot_violin_length <- function(data, type, plot_title, x_label) {
  data$file <- factor(data$file, levels = sort(unique(data$file)))

  plot_data <- data %>%
    group_by(file) %>%
    mutate(count = n(),
           median_length = median(length)) %>%
    ungroup()

  label_data <- plot_data %>%
    distinct(file, .keep_all = TRUE)

  p <- ggplot(plot_data, aes(length, file, color = file)) +
    geom_quasirandom(groupOnX = FALSE, show.legend = FALSE,
                     size = 1, dodge.width = 0.9, alpha = 0.4) +
    labs(title = plot_title, x = x_label) +
    theme_minimal() +
    scale_color_brewer(palette = "Dark2") +
    geom_text(data = label_data,
              aes(x = Inf, y = file, label = count),
              hjust = -0.2, color = "black", size = 3.5) +
    coord_cartesian(clip = "off")

  if (type == "genome") {
    p <- p + scale_x_log10()
  } else {
    p <- p + scale_x_continuous(expand = expansion(mult = c(0.05, 0.2)))
  }

  return(p)
}

# Generate both plots
p_gc <- plot_violin_gc(df, "Genome GC%", "gc")
p_len <- plot_violin_length(df, "genome", "Genome size", "length")

# Combine
final_plot <- cowplot::plot_grid(p_gc, p_len, ncol = 1, rel_heights = c(1, 1))

# Save
ggsave(filename = snakemake@output[[1]], plot = final_plot, width = 7, height = 10)


# library(ggplot2)

# df <- read.table(snakemake@input[[1]], header=TRUE, sep="\t")

# p <- ggplot(df, aes(x = gc, y = length)) +
#   geom_point() +
#   theme_minimal() +
#   labs(title = "GC% vs length", x = "GC%", y = "Sequence length")

# ggsave(filename = snakemake@output[[1]], plot = p)


# library(ggplot2)

# df <- read.table(snakemake@input[[1]], header=TRUE, sep="\t")

# p <- ggplot(df, aes(x=gc, y=length)) +
#   geom_point() +
#   theme_minimal() +
#   labs(title="GC% vs length", x="GC%", y="Sequence length")

# ggsave(filename=snakemake@output[[1]], plot=p)

