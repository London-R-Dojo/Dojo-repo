LondonR_Coding_Dojo_031214
==========================

Taken from: https://github.com/agerome-tes/LondonR_Coding_Dojo_031214

Crawling the web and opening the pages in the browser from R
------------------------------------------------------------

This uses Hadley Wickham's rvest package on CRAN to find links on a starting page. We kept only external links with a URL starting with http so https pages could also be visited by our code. We pick on of these links at random and repeat the process 10 times.

For each link selected we do the following:
* open the link in our browser
* calculate the probability to that that specific link was chosen
* print the url, how many links the page had

Next steps would be:
* checking the HTTP status code before trying to grab the HTML code of the page. Only scan for links if the page returned a HTTP 200 code in the first place or pick another link on the page
* store each link in a data frame but only if it has not already been stored
* store the HTTP status code and subset the data frame to get a broken links report
* restrict crawling to certain number of hops/domains

Alban
