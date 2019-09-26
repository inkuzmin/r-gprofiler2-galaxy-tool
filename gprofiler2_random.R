# options(show.error.messages=F, error=function(){cat(geterrmessage(),file=stderr());q("no",1,F)})

library("argparse")
library("RCurl")
library("jsonlite")

rcurl_opts =
  RCurl::curlOptions(useragent = "gprofiler2/0.1.6 galaxy", sslversion = 6L)

url = "https://biit.cs.ut.ee/gprofiler/api/gost/random_query/"

parser <- ArgumentParser()
parser$add_argument("--output", type="character")
parser$add_argument("--organism", type="character")
args <- parser$parse_args()

headers <- list( "Accept"       = "application/json"
         	   , "Content-Type" = "application/json"
         	   , "charset"      = "UTF-8"
         	   )

body <- paste0('{"organism":"', args$organism, '"}')

body <- jsonlite::toJSON((
    list(
      organism = args$organism
    )
  ), auto_unbox = TRUE)


oldw <- getOption("warn")
options(warn = -1)
h1 = RCurl::basicTextGatherer(.mapUnicode = FALSE)
h2 = RCurl::getCurlHandle() # Get info about the request

r = RCurl::curlPerform(
    url = url,
    httpheader = headers,
    postfields = body,
    customrequest = 'POST',
    verbose = FALSE,
    ssl.verifypeer = FALSE,
    writefunction = h1$update,
    curl = h2,
    .opts = rcurl_opts
)


options(warn = 0)
rescode = RCurl::getCurlInfo(h2)[["response.code"]]
txt <- h1$value()

if (rescode != 200) {
  stop("Bad request, response code ", rescode)
}

res <- jsonlite::fromJSON(txt)
df = res

write.table(df, file=args$output, quote=FALSE, sep='\t', row.names = FALSE, col.names = FALSE)

