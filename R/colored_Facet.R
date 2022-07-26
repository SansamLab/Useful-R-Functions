#' colored_Facet
#'
#' Given a dataframe, a faceting group, and a function to make an overall plot, this returns a faceted plot with colored banners over each subplot.
#'
#' @param dataframe The dataframe with data to plot
#' @param ggplot_fun A function to make a non-faceted plot from the data in the dataframe
#' @param faceting_group The grouping variable (ie column name) used for making the separate plots
#' @param nrow The number of rows to make for the plots
#' @param strip_colors A vector of colors equal to the number of variables in the faceting_group. Each color should have a name equal to a faceting variable. The order of colors will determine order of plots.
#' @param legend_proportion Proportion of the horizontal plot area taken by the shared legend
#'
#' @return a ggplot in which facet group strips are colored
#' @export


colored_Facet <- function(dataframe=data.frame("y_values"=c(1:1000),
                                               "genotype"=factor(rep(c("WT","Mutant"),500),levels=c("WT","Mutant")),
                                               "timepoint"=rep(c("early","early","late","late"),250)),
                          ggplot_fun = function(df){
                            ggplot2::ggplot(df,ggplot2::aes(color=genotype,y=y_values,fill=timepoint,x=timepoint)) +
                              ggplot2::geom_boxplot() +
                              ggplot2::facet_wrap(~get(faceting_group),drop=T) +
                              ggplot2::guides(color = FALSE) +
                              ggplot2::theme(strip.background = ggplot2::element_rect(fill = strip_color))
                          },
                          faceting_group = "genotype",
                          nrow = 1,
                          strip_colors = c("WT"="blue",
                                           "Mutant"="orange"),
                          legend_proportion = 0.2){

  plot_list <- lapply(1:length(strip_colors),function(i){
    strip_color <- strip_colors[i]
    facet_group <- names(strip_colors[i])
    dataframe_subset <- subset(dataframe,get(faceting_group) %in% facet_group)
    ggplot_fun(dataframe_subset) +
      ggplot2::facet_wrap(~get(faceting_group),drop=T) +
      ggplot2::theme(strip.background = ggplot2::element_rect(fill = strip_color)) +
      ggplot2::theme(legend.position = "none",
                     plot.margin = grid::unit(c(0,0,0,0), "cm"))
  })
  plot_list_yaxis_removed <- lapply(plot_list[2:length(plot_list)],function(plt){plt + ggplot2::theme(axis.text.y=ggplot2::element_blank(),
                                                                                                      axis.title.y=ggplot2::element_blank(),
                                                                                                      axis.ticks.y=ggplot2::element_blank())})
  lgnd <- cowplot::get_legend(ggplot_fun(dataframe))
  combined_plot_1 <- egg::ggarrange(plots=c(plot_list[1],plot_list_yaxis_removed),nrow=1)
  cowplot::plot_grid(combined_plot_1,lgnd,rel_widths = c(1-legend_proportion,legend_proportion))
}
