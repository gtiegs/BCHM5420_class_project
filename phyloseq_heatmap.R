# June 16 2025
# Creation of heatmap depicting log fold change of bacterial phyla 
# before and after treament with cranberrry extract

# Install packages and load libraries
install.packages(c("dplyr", "tidyr", "ggplot2", "RColorBrewer"))
install.packages(c("pheatmap", "ComplexHeatmap"))
install.packages(c("tibble"))
install.packages("BiocManager")
BiocManager::install(c("phyloseq", "tidyverse"))

library(phyloseq)
library(dplyr)
library(tidyr)
library(ggplot2)
library(pheatmap)
library(RColorBrewer)
library(circlize)
library(tibble)

# Load Phyloseq object from ampliseq results
physeq <- readRDS("phyloseq/dada2_phyloseq.RDS")

# Function to calculate log fold change between V1 and V2 for each subject
calculate_log_fold_change_phyloseq <- function(phyloseq_obj) {
  
  # Extract data from phyloseq object
  otu_table <- as.data.frame(otu_table(phyloseq_obj))
  tax_table <- as.data.frame(tax_table(phyloseq_obj))
  sample_data <- as.data.frame(sample_data(phyloseq_obj))
  
  # Agglomerate to phylum level
  ps_phylum <- tax_glom(phyloseq_obj, taxrank = "Phylum")
  
  # Transform to relative abundance
  ps_rel <- transform_sample_counts(ps_phylum, function(x) x / sum(x))
  
  # Extract relative abundance table and taxonomy
  rel_abund <- as.data.frame(otu_table(ps_rel))
  tax_info <- as.data.frame(tax_table(ps_rel))
  sample_info <- as.data.frame(sample_data(ps_rel))
  
  # Add phylum names as rownames
  rownames(rel_abund) <- tax_info$Phylum
  
  # Transpose so samples are rows and phyla are columns
  rel_abund_t <- t(rel_abund)
  rel_abund_df <- as.data.frame(rel_abund_t)
  
  # Add sample metadata
  rel_abund_df$SAMPLE_ID <- rownames(rel_abund_df)
  rel_abund_df <- merge(rel_abund_df, sample_info, by.x = "SAMPLE_ID", by.y = "row.names")
  
  # Reshape data for easier manipulation
  data_long <- rel_abund_df %>%
    pivot_longer(cols = -c(SAMPLE_ID, VISIT, SUBJECT), 
                 names_to = "Phylum", 
                 values_to = "RelativeAbundance")
  
  # Calculate log fold change for each subject and phylum
  lfc_data <- data_long %>%
    filter(!is.na(RelativeAbundance) & RelativeAbundance > 0) %>%
    group_by(SUBJECT, Phylum) %>%
    summarise(
      V1_abundance = RelativeAbundance[VISIT == "V1"],
      V2_abundance = RelativeAbundance[VISIT == "V2"],
      .groups = "drop"
    ) %>%
    filter(!is.na(V1_abundance) & !is.na(V2_abundance) & 
             V1_abundance > 0 & V2_abundance > 0) %>%
    mutate(
      # Add pseudocount to avoid log(0)
      V1_adj = V1_abundance + 1e-6,
      V2_adj = V2_abundance + 1e-6,
      log_fold_change = log2(V2_adj / V1_adj)
    )
  
  return(lfc_data)
}

# Calculate log fold changes
lfc_results <- calculate_log_fold_change_phyloseq(physeq)

# Create matrix for heatmap
heatmap_matrix <- lfc_results %>%
  select(SUBJECT, Phylum, log_fold_change) %>%
  pivot_wider(names_from = Phylum, values_from = log_fold_change) %>%
  column_to_rownames("SUBJECT") %>%
  as.matrix()

# Creat heatmap using ggplot2
create_ggplot_heatmap <- function(lfc_data, title = "Log2 Fold Change by Phylum") {
  
  # Filter out extreme values for better visualization
  lfc_filtered <- lfc_data %>%
    filter(abs(log_fold_change) <= 7)  # Adjust threshold as needed
  
  p <- ggplot(lfc_filtered, aes(x = Phylum, y = SUBJECT, fill = log_fold_change)) +
    geom_tile(color = "white", size = 0.1) +
    scale_fill_gradient2(
      low = "darkorange", 
      mid = "white", 
      high = "darkviolet",
      midpoint = 0,
      name = "Log2 FC",
      limits = c(-3, 3),
      oob = scales::squish
    ) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1),
      axis.text.y = element_text(size = 10),
      plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
      legend.position = "right",
      panel.grid = element_blank()
    ) +
    labs(
      title = title,
      x = "Bacterial Phyla",
      y = "Study Participants",
      caption = "Orange = decreased abundance, Purple = increased abundance (V2 vs V1)"
    ) +
    coord_fixed(ratio = 1)
  
  return(p)
}

print("Creating ggplot heatmap...")
ggplot_heatmap <- create_ggplot_heatmap(lfc_results)
print(ggplot_heatmap)
