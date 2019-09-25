

# options(show.error.messages=F, error=function(){cat(geterrmessage(),file=stderr());q("no",1,F)})

suppressPackageStartupMessages(library("argparse"))
library("gprofiler2")
library("ggplot2")

options(stringAsfactors = FALSE, useFancyQuotes = FALSE)

set_user_agent(paste0(get_user_agent(), " galaxy"))

parser <- ArgumentParser()

parser$add_argument("--input", type="character", action="append")
parser$add_argument("--label", type="character", action="append")
parser$add_argument("--output", type="character")

parser$add_argument("--multiquery", action='store_true')
parser$add_argument("-p", "--plot", type="character")

args <- parser$parse_args()

fileName = args$input

if (length(fileName) > 1) {
  i <- 1
  j <- 1
  query <- list()
  for (input in fileName) {
    q <- scan(input, character(), quote = "")
    l <- args$label[i]
    while (!is.null(query[[l]])) {
      l <- paste(l, j)
      j <- j + 1
    }
    query[[l]] <- q
    i <- i + 1
  }
} else {
  query <- list()
  query[[args$label]] <- scan(fileName, character(), quote = "")
}

response <- gost(query)

output <- response$result

output$parents <- vapply(output$parents, paste, collapse = ",", character(1L))

output.calnames = colnames(output)

write.table(output, file=args$output, quote=FALSE, sep='\t', row.names = FALSE, col.names = output.calnames)




image.name <- strsplit(args$plot, "\\.")

plot <- gostplot(response, interactive = FALSE)

ggsave(plot, filename = paste0(unlist(image.name)[1], ".png"))

# publish_gostplot(plot, highlight_terms = NULL, filename = paste0(unlist(image.name)[1], ".png"))

file.rename(paste0(unlist(image.name)[1], ".png"), paste0(unlist(image.name)[1], ".dat"))

