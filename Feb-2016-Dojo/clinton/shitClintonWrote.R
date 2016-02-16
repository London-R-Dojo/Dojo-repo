library(data.table)
library(markovchain)
library(stringr)

main <- function() {

  emails <- data.table(read.csv("data/Emails.csv"))

  #   persons <- data.table(read.csv("~/Downloads/output/Persons.csv"))
  #   emails.with.person <- merge(emails, persons[, list(SenderPersonId = Id)], by = "SenderPersonId", all.x = TRUE)

  #   emails.to.hill <- emails[MetadataTo == "H"]
  emails.from.hill <- emails[MetadataFrom == "H"]


  bodies <- emails.from.hill$ExtractedBodyText
  subjects <- emails.from.hill$ExtractedSubject

  start.string <- "<start>"
  end.string <- "<term>"

  all.split.sub <- str_split(bodies, " ")

  all.text <- unlist(sapply(all.split.sub, function(x) c(start.string,x,end.string)))
  count.matrix <- createSequenceMatrix(all.text)

  state.names <- colnames(count.matrix)
  trans.prob <- count.matrix/rowSums(count.matrix)

  getNextWord <- function(this.word, state.names, trans.prob) {
    this.row <- which(rownames(count.matrix) == this.word)
    next.word <- sample(state.names, size = 1, prob = trans.prob[this.row,])
  }

  createSubject <- function() {
    word <- getNextWord(start.string, state.names, trans.prob)
    sentence <- word

    while (word != end.string ){
      word <- getNextWord(word, state.names, trans.prob)
      sentence <- paste(sentence, word)
      } 

    sentence
    }



  createSubject()




}

