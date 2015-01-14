install.packages("rvest")
library(rvest)
set.seed(1000)
startURL<-"http://en.wikipedia.org/wiki/The_Lego_Movie"
i<-10

getExternalLinks<-function(link){
	html <- html(link)
	
	links<-html %>% 
		html_nodes("a[href]") %>%
		html_attr("href")
		
	externalLinks<-grep("^http", links, value=T)
	
	list(
		sample(externalLinks,1),
		length(links)
	)
}

myVector<-c()
doTricks<-function(myURL){
	run<-getExternalLinks(myURL)
	myVector<-1/as.numeric(unlist(run[2]))
	for(i in 1:10){
		print(
			paste(
				run,
				" ",
				"probability of step:",
				i,
				" ",
				myVector,
				" ",
				"number of links:",
				unlist(run[2]),
				sep=""
			)
		)
		run<-getExternalLinks(unlist(run[1]))
		browseURL(unlist(run[1]))
		myVector<-myVector*(1/as.numeric(unlist(run[2])))
	}
}
doTricks("http://en.wikipedia.org/wiki/The_Lego_Movie")