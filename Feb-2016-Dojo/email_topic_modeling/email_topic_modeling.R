# Load Packages -------------------------------------
library(stringi)
library(stringr)
library(tm)
library(wordcloud)
library(lda)
library(LDAvis)
library(stm)
library(stmBrowser)
library(stmCorrViz)
library(lubridate)
library(qdap)

options(stringsAsFactors = FALSE)
# Data downloaded from https://www.kaggle.com/kaggle/hillary-clinton-emails/downloads/hillary-clinton-emails-release-2015-09-11-01-39-01.zip
file_path <- "dataset/Emails.csv"

readLines(file_path, 2)

dat <- read.csv(file_path,
                sep = ",",
                encoding = "UTF-8", 
                header = T, 
                stringsAsFactors = F)

class(dat)
names(dat)
dim(dat)

# Check encoding of text 
table(Encoding(dat$ExtractedBodyText)) # lots of unknown encoding

text <- dat$ExtractedBodyText
table(stri_enc_mark(text))

# Enforce UTF-8 (Not working)
# text <- stri_encode(text, "ASCII", "UTF-8")
# There were 50 or more warnings (use warnings() to see the first 50)

# text <- enc2native(text)

# Data pre-processing ----------------------------------------------------------

# Identify emails from Hillary
head(dat[, c("MetadataFrom", "SenderPersonId")], 50) # SenderPersonId == 80

# 157 empty senders
sum(dat$MetadataFrom == "") 

# Have a look at the emails with empty sender
dat$ExtractedBodyText[dat$MetadataFrom == ""] # Lots of empty text as well

# Some emails I can deduce it's from or to Hillary but I'll remove them
# Remove cases with MetadataFrom == ""
dat <- dat[dat$MetadataFrom != "",]
dim(dat)
 
sum(dat$ExtractedBodyText == "") # 1067 emails have no body text

# Look at RawText to see if some more emails can be extracted
head(dat$RawText[dat$ExtractedBodyText == ""])

# Many emails have text between "Subject:" and "UNCLASSIFIED"
emptyBodyText_Idx <- dat$ExtractedBodyText == ""

# replace all line breaks from RawText with a space
dat$RawText <- gsub("\n", " ", dat$RawText )

text_field <- "Subject\\: (.*)UNCLASSIFIED"
# 839 extra texts can be retrived
sum(str_detect(dat$RawText[emptyBodyText_Idx], text_field)) 

# retrive text
retrived_text <- str_extract(dat$RawText[emptyBodyText_Idx], text_field)

# Clean it up
NAidx <- is.na(retrived_text)
retrived_text[NAidx] <- ""
subject <- "Subject\\:(.*)Subject\\:"
retrived_text <- gsub(subject, "", retrived_text)
retrived_text <- gsub("UNCLASSIFIED", "", retrived_text)
head(retrived_text)

# Add retrived text
dat$ExtractedBodyText[emptyBodyText_Idx] <- retrived_text

# Remove these emails without body text
empty_idx <- dat$ExtractedBodyText == ""
sum(empty_idx) # 228
dat <- dat[!empty_idx, ]
dim(dat) # 7560   22

# Clean up date variable
date <- dat$MetadataDateSent
date <- gsub("T(.*)", "", date)
date <- ymd(date)

sum(is.na(date)) # created 3 NAs
na_idx <- which(is.na(date))
dat$MetadataDateSent[na_idx+1] # was empty in MetadataDateSent
dat$ExtractedDateSent[na_idx] # empty in ExtractedDateSent as well

# Check the dates before and after the NAs to see if I can use for inputation
dat$MetadataDateSent[na_idx+1]
dat$MetadataDateSent[na_idx-1]

date[na_idx] <- date[na_idx+1]
sum(is.na(date))

day_month <- day(date)
day_week <- wday(date, label = TRUE, abbr = FALSE)
month <- month(date, label = TRUE, abbr = FALSE)
year <- year(date)
table(year)

# Make new dataframe to store processed data
emails <- data.frame(to = dat$ExtractedTo,
                     from = dat$ExtractedFrom,
                     senderId = dat$SenderPersonId,
                     released = dat$ExtractedReleaseInPartOrFull,
                     emails = dat$ExtractedBodyText,
                     text = dat$ExtractedBodyText,
                     rawtext = dat$RawText,
                     date = date,
                     day_month = day_month,
                     day_week = day_week,
                     month = month,
                     year = year)

dim(emails)
names(emails)

# Classify emails as to and from Hillary
head(emails[,c("from", "senderId")], 50)

emails$from_to <- as.factor(ifelse(emails$senderId == 80, "From Hillary", "To Hillary"))

table(emails$from_to)
# From Hillary   To Hillary 
#        1993         5795 

# Quick look at emails text
head(emails$text, 10)

text <- emails$text

# Clean up a bit more
US_dp_state <- "U\\.S\\. Department of State(.*)STATE\\-"
text <- gsub(US_dp_state, "", text)

# Remove email address
email_address <- "<(.*)>"
text <- gsub(email_address, " ", text)
text <- gsub("(.*)\\.com", " ", text)
text <- gsub("^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$", "", text)
text <- gsub("(.*)@state\\.gov", "", text)

# Remove line break
text <- gsub("\\n", " ", text)

# Remove H
text <- gsub(" H ", " ", text)

# Remove dates
week_days <- "(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)"
months <- "(January|February|March|April|May|June|July|August|September|October|November|December)"

# Remove dates
text <- gsub(week_days, " ", text)
text <- gsub(months, " ", text)

# More tidy up
text <- gsub("[A-P]M", " ", text)
text <- gsub("B\\d", " ", text)
text <- gsub("\"", " ", text)
text <- gsub("[T-t]o\\:|[F-f]rom\\:|H\\:|[F-f]or\\:|[S-s]ent\\:|[R-r][E-e]\\:|FW\\:|Fw\\:|Fwd\\:|mailto\\:|Tel\\:", " ", text)
text <- gsub("Subject\\:", "", text)
text <- gsub("\\/(.*)\\/", "", text)
text <- gsub("^http\\:(.*)", "", text)

head(text, 50)
tail(text, 50)
text[1000:1050]

# Correct some words
# Pis
text <- gsub("Pis", "Pls", text)

# More pre-processing:
text <- gsub("'", "", text)  # remove apostrophes
text <- gsub("•", "", text) # remove •
text <- gsub("[[:punct:]]", "", text)  # remove punctuation 
text <- gsub("[[:cntrl:]]", " ", text)  # replace control characters with space
text <- gsub("^[[:space:]]+", "", text) # remove whitespace at beginning of documents
text <- gsub("[[:space:]]+$", "", text) # remove whitespace at end of documents
text <- gsub("[[:digit:]]", "", text) # remove numbers
text <- tolower(text)  # force to lowercase
text <- gsub("h ", "", text)
text <- gsub("w ", "", text)
text <- gsub("pm ", "", text)
text <- gsub("imagejpg", "", text)

emails$text <- text

# remove empty emails
empty <- emails$text == "" | emails$text == " "
emails <- emails[!empty, ]

dim(emails) # 7393    13

####################
# Word Frequencies --------------------------------------------
####################

txt <- emails$text
txt <- removeWords(txt, words = stopwords("english"))

txt_TO <- txt[emails$from_to == "To Hillary"]
length(txt_TO)

txt_FROM <- txt[emails$from_to == "From Hillary"]
length(txt_FROM)

out.1 <- tau::textcnt(x = txt, 
                      method = "string", 
                      n = 1, 
                      decreasing = TRUE)

out.1_TO <- tau::textcnt(x = txt_TO, 
                      method = "string", 
                      n = 1, 
                      decreasing = TRUE)

out.1_FROM <- tau::textcnt(x = txt_FROM, 
                         method = "string", 
                         n = 1, 
                         decreasing = TRUE)

# Frequencies of bigrams
out.2 <- tau::textcnt(x = txt, 
                    method = "string", 
                    n = 2, 
                    decreasing = TRUE)

out.2_TO <- tau::textcnt(x = txt_TO, 
                      method = "string", 
                      n = 2, 
                      decreasing = TRUE)

out.2_FROM <- tau::textcnt(x = txt_FROM, 
                      method = "string", 
                      n = 2, 
                      decreasing = TRUE)

# Frequencies of trigrams
out.3 <- tau::textcnt(x = txt, 
                    method = "string", 
                    n = 3, 
                    decreasing = TRUE)

out.3_TO <- tau::textcnt(x = txt_TO, 
                      method = "string", 
                      n = 3, 
                      decreasing = TRUE)

out.3_FROM <- tau::textcnt(x = txt_FROM, 
                      method = "string", 
                      n = 3, 
                      decreasing = TRUE)

par(mfrow=c(2,3), mar=c(2,6,2,2))
# One words barplot
barplot(rev(head(out.1, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of terms\n(Combined)")

barplot(rev(head(out.1_TO, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of terms\n(To Hillary)")

barplot(rev(head(out.1_FROM, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of terms\n(From Hillary)")


# One words wordcloud
wordcloud(names(out.1), freq = out.1, scale = c(5, .05), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))


wordcloud(names(out.1_TO), freq = out.1, scale = c(5, .05), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))

wordcloud(names(out.1_FROM), freq = out.1, scale = c(5, .05), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))


par(mfrow=c(2,3), mar=c(2,8,2,3))
# Bigrams barplot
barplot(rev(head(out.2, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of bi-grams\n(Combined)")

barplot(rev(head(out.2_TO, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of bi-grams\n(To Hillary)")

barplot(rev(head(out.2_FROM, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of bi-grams\n(From Hillary)")

# Bigrams wordcloud
wordcloud(names(out.2), freq = out.2, scale = c(2, .0005), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))

wordcloud(names(out.2_TO), freq = out.2, scale = c(2, .0005), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))

wordcloud(names(out.2_FROM), freq = out.2, scale = c(2, .0005), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))


par(mfrow=c(2,3), mar=c(2,12,2,3))
# Trigrams barplot
barplot(rev(head(out.3, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of tri-grams\n(Combined)")

barplot(rev(head(out.3_TO, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of tri-grams\n(To Hillary)")

barplot(rev(head(out.3_FROM, 20)), col ="orange",
        horiz = TRUE, las=1, main = "Frequency of tri-grams\n(From Hillary)")

par(mar=c(2,2,2,2))
# Trigrams wordcloud
wordcloud(names(out.3), freq = out.3, scale = c(2, .0005), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))

wordcloud(names(out.3_TO), freq = out.3, scale = c(2, .0005), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))

wordcloud(names(out.3_FROM), freq = out.3, scale = c(2, .0005), min.freq = 10,
          max.words = 150, random.order = FALSE, colors = brewer.pal(6,"Dark2"))

#######################
# Topic Modelling -----------------------------
########################

################
# LDA --------------------------------------
################
# example @ http://cpsievert.github.io/LDAvis/reviews/reviews.html

# tokenize on space and output as a list:
doc.list <- strsplit(txt, "[[:space:]]+")

# compute the table of terms:
term.table <- table(unlist(doc.list))
term.table <- sort(term.table, decreasing = TRUE)

# read in some stopwords:
stop_words <- stopwords("SMART")

# remove terms that are stop words or occur fewer than 3 times or are "":
del <- names(term.table) %in% stop_words | term.table < 3 
term.table <- term.table[!del]

# Remove empty string term
head(names(term.table))
empty <- names(term.table) == ""
term.table <- term.table[!empty]

vocab <- names(term.table)

# now put the documents into the format required by the lda package:
get.terms <- function(x) {
        index <- match(x, vocab)
        index <- index[!is.na(index)]
        rbind(as.integer(index - 1), as.integer(rep(1, length(index))))
        }

documents <- lapply(doc.list, get.terms)

# Compute some statistics related to the data set:
D <- length(documents)  # number of documents (7393)
W <- length(vocab)  # number of terms in the vocab (10316)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of tokens per document [7, 1, 15, 4, 118, 15, ...]
N <- sum(doc.length)  # total number of tokens in the data (200037)
term.frequency <- as.integer(term.table)  # frequencies of terms in the corpus [1999, 1040, 985, 839, 756, ...]

# MCMC and model tuning parameters:
K <- 30 # no.topics
G <- 5000
alpha <- 0.02
eta <- 0.02

# Fit the model:
set.seed(357)
t1 <- Sys.time()
fit <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = vocab, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
t2 - t1  # 13.60219 mins
beepr::beep(0)

# Estimate document-topic distributions(D * K matrix θ)
# Set topic-term distributions (K * W matrix ϕ)

theta <- t(apply(fit$document_sums + alpha, 2, function(x) x/sum(x)))
phi <- t(apply(t(fit$topics) + eta, 2, function(x) x/sum(x)))

emails4LDA<- list(phi = phi,
                     theta = theta,
                     doc.length = doc.length,
                     vocab = vocab,
                     term.frequency = term.frequency)

# create the JSON object to feed the visualization:
json <- createJSON(phi = emails4LDA$phi, 
                   theta = emails4LDA$theta, 
                   doc.length = emails4LDA$doc.length, 
                   vocab = emails4LDA$vocab, 
                   term.frequency = emails4LDA$term.frequency)

serVis(json, out.dir = 'LDAvis', open.browser = TRUE)





#########################
# Structural Topic Models ----------------------------------------
#########################

#stemming/stopword removal, etc.
emails$from_to <- factor(emails$from_to)
emails$released <- factor(emails$released)
emails$day_month <- factor(emails$day_month)
emails$year <- factor(emails$year)

stm_data <- emails[,c("released", "senderId", "to", "from",
                      "from_to", "emails","text", "rawtext", "date", 
                      "day_month", "day_week", "month", "year")]



month_names <- tolower(as.character(unique(month)))
week_days_names <- tolower(as.character(unique(day_week)))


# Sentiment analysis ------------------------------------------

# Compute the sentiment score on a [-1,1] range
txt <- tolower(stm_data$text)
t1 <- Sys.time()
sentiments <- polarity(txt,
                       polarity.frame = qdapDictionaries::key.pol,
                       negators = qdapDictionaries::negation.words,
                       amplifiers = qdapDictionaries::amplification.words,
                       deamplifiers = qdapDictionaries::deamplification.words, 
                       amplifier.weight = 0.8,
                       n.before = 4, 
                       n.after = 2,
                       constrain = TRUE)
t2 <- Sys.time()
t2-t1 # 2.249335 mins
beepr::beep(0)


# Add a column called sentiment to the data.frame 
stm_data$sentiment <- sentiments$all$polarity

# General output
sentiments$group

## Structure of the detailed output
str(sentiments$all)

# Distribution of the sentiment - standard a lot of zero's
stm_data[which(is.na(stm_data$sentiment)),] # one email have no text -> leads to NaN sentiment

hist(stm_data$sentiment)

boxplot(stm_data$sentiment, range = F)

summary(stm_data$sentiment)
# Min.  1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
# -0.59100  0.00000  0.00000  0.03177  0.06906  0.83920        1 

# Remove case with sentiment as NA
idx <- which(is.na(stm_data$sentiment))
# 5801

stm_data <- stm_data[-idx,]

pos <- round(sum(stm_data$sentiment > 0, na.rm = TRUE) / length(stm_data$sentiment)*100,2)
# 28.08 % are considered positive

# Negative (%)
neg <- round(sum(stm_data$sentiment < 0, na.rm = TRUE) / length(stm_data$sentiment)*100,2)
# 12.73 % are considered negative

# Neutral (%)
neut <- round(sum(stm_data$sentiment == 0, na.rm = TRUE) / length(stm_data$sentiment)*100,2)
# 59.19 % are considered neutral



stop_words <- c(stop_words, "imagejpg", "Subject:", "AM", "PM", month_names, week_days_names)

processed <- textProcessor(stm_data$text, 
                           metadata=stm_data, 
                           stem = FALSE,
                           striphtml = TRUE,
                           customstopwords = stop_words)


# Choose frequency threshold
plotRemoved(processed$documents, lower.thresh=seq(from = 1, to = 50, by = 1))

#structure and index for usage in the stm model. Verify no-missingness.
out <- prepDocuments(processed$documents, processed$vocab, processed$meta, lower.thresh = 3)
out <- readRDS("out.RDS")
#output will have object meta, documents, and vocab
docs <- out$documents
vocab <- out$vocab
meta  <-out$meta
##############

# released and fromH as a covariate in the topic prevalence
t1 <- Sys.time()
emailsFit <- stm(out$documents,
                 out$vocab,
                 K=40,
                 prevalence = ~ sentiment + from_to + released + day_week + month + year, 
                 max.em.its = 500,
                 data=out$meta,
                 seed=5926696,
                 init.type="Spectral")
t2 <- Sys.time()
t2-t1 # 16.81741 mins (converged on iteration 168)
beepr::beep(0)

saveRDS(emailsFit, "emailsFit.RDS")
saveRDS(out, "out.RDS")
rm(list = ls())

emailsFit <- readRDS("emailsFit.RDS")

# stmBrowser
stmBrowser(mod = emailsFit, 
           data = out$meta, 
           covariates = c("sentiment", "from_to", "released", "day_week", "month", "year"),
           text = "emails",
           id = NULL,
           n = 7000, 
           labeltype ="frex") #prob

