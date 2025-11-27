library(seqinr)
library(ggplot2)
library(ggfortify)
library(tidyverse)

df <- read.table(snakemake@input[[1]], header=TRUE, sep="\t")

file <- basename(snakemake@input[[1]])
tag <- if (grepl("din", file)) "din" else "tri"

df$File <- sapply(df$File, function(x) {
    x <- sub(".*Tcruzi", "", x)      # quita prefijo
    x <- sub("2018$", "", x)         # si termina en 2018, lo borra
    x <- sub("\\.fasta.*$", "", x)   # quita extensión
    return(x)
})

# function to string manipulation on sequence ID
transform_columns <- function(df, cols) {
  # Iterate over the specified columns
  for (col in cols) {
    # Replace '=' with '_'
    df[[col]] <- gsub("=", "_", df[[col]])              
    # Remove everything after ':' or ';'
    df[[col]] <- gsub("[:;].*", "", df[[col]])          
  }
  return(df)  # Return the modified data frame
}

df_transform <- transform_columns(df, "ID")

if (tag == "din") {
  # Convert dinucleotide columns to numeric
  cols_to_convert <- c("aa", "tt", "ac", "gt", "ag", "ct", "ca", "tg", "cc", "gg", "ga", "tc", "at", "cg", "gc", "ta")
  df[cols_to_convert] <- lapply(df[cols_to_convert], as.numeric)
} else if (tag == "tri") {
  # Convert trinucleotide columns to numeric
  cols_to_convert <- c("aaa", "aag", "aat", "aca", "acc", "act", "aga", "agg", "agt", "ata", "atc", "att", "caa", "cag", "cat", "cca", "ccc", "cct", "cga", "cgg", "cgt", "cta", "ctc", "ctt", "gaa", "gag", "gat", "gca", "gcc", "gct", "gga", "ggc", "ggt", "gta", "gtc", "gtt", "taa", "tag", "tat", "tca", "tcc", "tct", "tga", "tgg", "tgt", "tta", "ttc", "ttt")
  df[cols_to_convert] <- lapply(df[cols_to_convert], as.numeric)
}

combine_data_frequencies <- function(data, genome_col = "File", id_col = "ID", tag) {
  if (tag == "din") {
    result_combained_data <- data.frame(
      "Genome" = data[, genome_col],
      "ID" = data[, id_col],
      "aa.tt" = data[,"aa"] + data[,"tt"],
      "ac.gt" = data[,"ac"] + data[,"gt"],
      "ag.ct" = data[,"ag"] + data[,"ct"],
      "ca.tg" = data[,"ca"] + data[,"tg"],
      "cc.gg" = data[,"cc"] + data[,"gg"],
      "ga.tc" = data[,"ga"] + data[,"tc"],
      "at" = data[,"at"],
      "cg" = data[,"cg"],
      "gc" = data[,"gc"],
      "ta" = data[,"ta"]
    )
  } else if (tag == "tri") {
result_combained_data <- data.frame(
  Genome = data[, genome_col],
  ID     = data[, id_col],

  aaa.ttt = data[,"aaa"] + data[,"ttt"],
  aag.ctt = data[,"aag"] + data[,"ctt"],
  aac.gtt = data[,"aac"] + data[,"gtt"],
  aat.att = data[,"aat"] + data[,"att"],

  acc.ggt = data[,"acc"] + data[,"ggt"],
  act.agt = data[,"act"] + data[,"agt"],
  aga.tct = data[,"aga"] + data[,"tct"],
  agg.cct = data[,"agg"] + data[,"cct"],

  ata.tat = data[,"ata"] + data[,"tat"],
  atc.gat = data[,"atc"] + data[,"gat"],

  caa.ttg = data[,"caa"] + data[,"ttg"],
  cag.ctg = data[,"cag"] + data[,"ctg"],
  cat.atg = data[,"cat"] + data[,"atg"],
  cac.gtg = data[,"cac"] + data[,"gtg"],

  cca.tgg = data[,"cca"] + data[,"tgg"],
  ccc.ggg = data[,"ccc"] + data[,"ggg"],
  cga.tcg = data[,"cga"] + data[,"tcg"],
  cta.tag = data[,"cta"] + data[,"tag"],

  gaa.ttc = data[,"gaa"] + data[,"ttc"],
  gag.ctc = data[,"gag"] + data[,"ctc"],
  gca.tgc = data[,"gca"] + data[,"tgc"],
  gta.tac = data[,"gta"] + data[,"tac"],
  gtc.gac = data[,"gtc"] + data[,"gac"],

  tca.tga = data[,"tca"] + data[,"tga"]

  #   result_combained_data <- data.frame(
  # "File" = data[, genome_col],
  # "ID" = data[, id_col],
  # "aaa.ttt" = data[,"aaa"] + data[,"ttt"],
  # "aag.ctt" = data[,"aag"] + data[,"ctt"],
  # "aac.gtt" = data[,"aac"] + data[,"gtt"],
  # "aat.att" = data[,"aat"] + data[,"att"],
  # "acc.ggt" = data[,"acc"] + data[,"ggt"],
  # "act.agt" = data[,"act"] + data[,"agt"],
  # "aga.tct" = data[,"aga"] + data[,"tct"],
  # "agg.cct" = data[,"agg"] + data[,"cct"],
  # "ata.tat" = data[,"ata"] + data[,"tat"],
  # "atc.gat" = data[,"atc"] + data[,"gat"],
  # "caa.ttg" = data[,"caa"] + data[,"ttg"],
  # "cag.ctg" = data[,"cag"] + data[,"ctg"],
  # "cat.atg" = data[,"cat"] + data[,"atg"],
  # "cac.gtg" = data[,"cac"] + data[,"gtg"],
  # "cca.tgg" = data[,"cca"] + data[,"tgg"],
  # "ccc.ggg" = data[,"ccc"] + data[,"ggg"],
  # "cga.tcg" = data[,"cga"] + data[,"tcg"],
  # "cta.tag" = data[,"cta"] + data[,"tag"],
  # "gaa.ttc" = data[,"gaa"] + data[,"ttc"],
  # "gag.ctc" = data[,"gag"] + data[,"ctc"],
  # "gat.atc" = data[,"gat"] + data[,"atc"],
  # "gca.tgc" = data[,"gca"] + data[,"tgc"],
  # "gga.tcc" = data[,"gga"] + data[,"tcc"],
  # "ggg.ccc" = data[,"ggg"] + data[,"ccc"],
  # "gta.tac" = data[,"gta"] + data[,"tac"],
  # "gtc.gac" = data[,"gtc"] + data[,"gac"],
  # "taa.tta" = data[,"taa"] + data[,"tta"],
  # "tag.cta" = data[,"tag"] + data[,"cta"],
  # "tat.ata" = data[,"tat"] + data[,"ata"],
  # "tca.tga" = data[,"tca"] + data[,"tga"],
  # "tga.tca" = data[,"tga"] + data[,"tca"],
  # "tta.aag" = data[,"tta"] + data[,"aag"]
)
  } else {
    stop("Invalid tag specified. Use 'di' for dinucleotides or 'tri' for trinucleotides.")
  }

  return(result_combained_data)
}

combained <- combine_data_frequencies(df, tag=tag)

id_vector <- combained$ID

# Transform the ID: remove everything after ";" and replace "=" with "_"
id_vector_cleaned <- gsub(";.*", "", gsub("=", "_", id_vector))
id_vector_cleaned <- gsub("[:;].*", "", id_vector_cleaned) 

# Asignar el vector limpio de vuelta al dataframe
combained_clean <- combained
combained_clean$ID <- id_vector_cleaned

perform_pca <- function(data, file_col = "File", id_col = "ID") {
  # Validate input data
  if (!file_col %in% names(data)) {
    stop(paste("Column", file_col, "not found in data"))
  }
  if (!id_col %in% names(data)) {
    stop(paste("Column", id_col, "not found in data"))
  }
  
  # Exclude 'file_col' and 'id_col' columns from numerical analysis
  pca_data <- data[, !(names(data) %in% c(file_col, id_col))]
  
  # Convert all columns to numeric, handling non-numeric values and NAs
  pca_data <- as.data.frame(lapply(pca_data, function(x) {
    x <- as.numeric(as.character(x))
    ifelse(is.na(x), 0, x)  # Replace NA with 0 (or adjust based on your preference)
  }))
  
  # Ensure no rows were dropped due to conversion issues
  if (nrow(pca_data) != nrow(data)) {
    stop("Mismatch between input data rows and processed PCA data rows")
  }
  
  # Perform the PCA
  pca_result <- prcomp(pca_data, scale. = TRUE)
  
  # Get PCA scores
  pca_scores <- as.data.frame(pca_result$x)
  
  # Add 'file_col' and 'id_col' columns to PCA results
  pca_scores <- cbind(data[, c(file_col, id_col)], pca_scores)
  
  # Plot the PCA using autoplot
  pca_plot <- autoplot(
    pca_result, 
    data = data, 
    colour = file_col, 
    loadings = TRUE, 
    loadings.label = TRUE, 
    loadings.colour = 'grey64', 
    alpha = 0.2, 
    size = 1
  ) +
    theme_minimal()
  
  # Return the results of the PCA and the graph
  return(list(pca_result = pca_result, pca_scores = pca_scores, pca_plot = pca_plot))
}

# Call the updated perform_pca function
perform_result_pca <- perform_pca(
  data = combained_clean, 
  file_col = "Genome", 
  id_col = "ID"
)
# Extract the plot
global_plot <- perform_result_pca$pca_plot

# Save
ggsave(filename = snakemake@output[[1]], plot = global_plot, width = 7, height = 10)

