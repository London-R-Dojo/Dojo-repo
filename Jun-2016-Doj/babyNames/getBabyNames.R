library(sweSCB)
library(data.table)
library(devtools)
library(twitteR)
library(httr)
library(tm)
library(stringr)
library(wordcloud)
library(stringi)

main <- function() {
  baby.names <- getSwedishNames()
  total.by.name <- baby.names[, list(total = sum(values, na.rm = TRUE)), by = name][order(total, decreasing = TRUE)]
  bottom.10.names <- tail(total.by.name, 10)

  setupTwitterAuth()
  createWordCloudfor(bottom.10.names[1])
}

getSwedishNames <- function() {
  baby.names <- data.table(get_pxweb_data(url = "http://api.scb.se/OV0104/v1/doris/en/ssd/BE/BE0001/BE0001T05AR", dims = list(Tilltalsnamn = c('*'), ContentsCode = c('BE0001AJ'), Tid = c('*')), clean = TRUE))
  setnames(baby.names, "first name normally used", "name")
}

createWordCloudfor <- function(name) {

  hix <- searchTwitter(name, n=500, since='2007-10-30')
  tweets.text.corpus <- cleanUpTweets(hix)
  printToPng(tweets.text.corpus, name)
}

setupTwitterAuth <- function() {
  stop("You have to fill in the twitter auth below  and delete this line")
	setup_twitter_oauth(consumer_key = "XXX"
											, consumer_secret = "XXX"
											, access_token="XXX"
											, access_secret="XXX")
}

printToPng <- function(tweets.text.corpus, name) {
  pal2 <- brewer.pal(8,"Dark2")
  png(paste0(name, ".png"), width = 1500, height = 1500,  pointsize = 50) 
  wordcloud(tweets.text.corpus,min.freq = 2, random.order = FALSE, max.words = 150, colors = pal2)
  dev.off()
}

cleanUpTweets <- function(hix) {
  tweets.text <- sapply(hix, function(x) x$getText())
  tweets.text <- str_replace_all(tweets.text,"[^[:graph:]]", " ")
  Encoding(tweets.text) <- "UTF-8"

  tweets.text <- tolower(tweets.text)
  tweets.text <- gsub("rt", "", tweets.text)
  # Replace @UserName
  tweets.text <- gsub("@\\w+", "", tweets.text)
  # Remove punctuation
  tweets.text <- gsub("[[:punct:]]", "", tweets.text)
  # Remove links
  tweets.text <- gsub("http\\w+", "", tweets.text)
  # Remove tabs
  tweets.text <- gsub("[ |\t]{2,}", "", tweets.text)
  # Remove blank spaces at the beginning
  tweets.text <- gsub("^ ", "", tweets.text)
  # Remove blank spaces at the end
  tweets.text <- gsub(" $", "", tweets.text)
  tweets.text <- unique(tweets.text)

  #create corpus
  vect.source <- VectorSource(tweets.text)
  vect.source$content <- gsub("ofon", "of on", vect.source$content)
  vect.source$content <- gsub("http", "", vect.source$content)

  tweets.text.corpus <- Corpus(vect.source)

  #clean up by removing stop words
  tweets.text.corpus <- tm_map(tweets.text.corpus, function(x)removeWords(x,c("you", swedishStopwords(), stopwords())))
}

swedishStopwords <- function() {
  swedish.word <- c("och ", "det ", "att ", "i ", "en ", "jag ", "hon ", "som ", "han ", "på ", "den ", "med ", "var ", "sig ", "för ", "så ", "till ", "är ", "men ", "ett ", "om ", "hade ", "de ", "av ", "icke ", "mig ", "du ", "henne ", "då ", "sin ", "nu ", "har ", "inte ", "hans ", "honom ", "skulle ", "hennes ", "där ", "min ", "man ", "ej ", "vid ", "kunde ", "något ", "från ", "ut ", "när ", "efter ", "upp ", "vi ", "dem ", "vara ", "vad ", "över ", "än ", "dig ", "kan ", "sina ", "här ", "ha ", "mot ", "alla ", "under ", "någon ", "eller ", "allt ", "mycket ", "sedan ", "ju ", "denna ", "själv ", "detta ", "åt ", "utan ", "varit ", "hur ", "ingen ", "mitt ", "ni ", "bli ", "blev ", "oss ", "din ", "dessa ", "några ", "deras ", "blir ", "mina ", "samma ", "vilken ", "er ", "sådan ", "vår ", "blivit ", "dess ", "inom ", "mellan ", "sådant ", "varför ", "varje ", "vilka ", "ditt ", "vem ", "vilket ", "sitta ", "sådana ", "vart ", "dina ", "vars ", "vårt ", "våra ", "ert ", "era ", "vilkas ")
}
