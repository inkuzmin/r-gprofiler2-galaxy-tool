

options(show.error.messages=F, error=function(){cat(geterrmessage(),file=stderr());q("no",1,F)})

library("getopt")
library("gprofiler2")
library("ggplot2")

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

set_user_agent(paste0(get_user_agent()), " galaxy")

args <- commandArgs(trailingOnly = TRUE)

option_specification = matrix(c(
  'input', 'i', 2, 'character',
  'output', 'o', 2, 'character',
  'plot', 'p', 2, 'character'
), byrow=TRUE, ncol=4);

options = getopt(option_specification)

fileName = options$input

query <- scan(fileName, character(), quote = "")

response <- gost(query)

output <- response$result

output$parents <- vapply(output$parents, paste, collapse = ",", character(1L))

output.calnames = colnames(output)

# write.csv(output, options$output)

write.table(output, file=options$output, quote=FALSE, sep='\t', row.names = FALSE, col.names = output.calnames)




image.name <- strsplit(options$plot, "\\.")

plot <- gostplot(response, interactive = FALSE)

ggsave(plot, filename = paste0(unlist(image.name)[1], ".png"))

# publish_gostplot(plot, highlight_terms = NULL, filename = paste0(unlist(image.name)[1], ".png"))

file.rename(paste0(unlist(image.name)[1], ".png"), paste0(unlist(image.name)[1], ".dat"))

