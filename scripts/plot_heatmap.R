#a function to make new adjusted heatmaps
#open raw .csv PlotCaMP_multi file
plot_heatmap <- function(data,
                         heatmap_limits = "auto", 
                         endPulse = 59.5,
                         use_existing = FALSE,
                         ...) {
  library(tidyverse)
  library(magrittr)
  library(scales)
  
  if(missing(data)) {  
    data <- read_csv(file.choose()) %>%
      mutate(animal_num = as.factor(animal_num))
  } else {
    data <- data
  }
  #full_join(data, plot_order) %>%
  #unnest(cols=c()) %>%
  
  if(!is.numeric(heatmap_limits)) { # using auto calc unless a numeric vector input
    breaks <- round(
      data %>% unnest(cols = c()) %$% quantile(delF, c(0.05, 0.5, 0.99)),
      2
    )
    labels <- as.character(breaks)
    limits <- breaks[c(1,3)]
  } else {
    breaks <- heatmap_limits
    labels <- as.character(breaks)
    limits <- breaks[c(1,3)]
  }
  
  labels <- as.character(breaks)
  limits <- breaks[c(1,3)]
  
  plot_order <- data %>% 
    group_by(animal, animal_num) %>%
    summarise(maxD = MF.matR::max_delta(delF, end = endPulse)) %>%
    arrange(maxD)
  
  full_join(data, plot_order, cols = c("animal", "animal_num", "maxD")) %>% 
    group_by(animal_num) %>%
    ggplot(aes(x = time, y = fct_reorder(factor(animal_num), maxD))) +
    geom_tile(aes(fill = signal)) +
    scale_fill_viridis_c(option = "magma",
                         breaks = breaks,
                         labels = labels,
                         limits = limits,
                         oob =squish) +
    theme_classic() +
    theme(axis.text = element_text(size = 16),
          axis.title = element_text(size = 18),
          axis.text.y = element_blank()) +
    labs(y = "Animal number")
}