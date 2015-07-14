library(stringr)

parseStationFacilities <- function(st.file) {
  st.xml <- xmlParse(st.file)

  st <- data.table(id = xpathSApply(st.xml, "//station/@id") ,
                   type = xpathSApply(st.xml, "//station/@type"),
                   name = xpathSApply(st.xml, "//station/name", xmlValue, trim = TRUE ),
                   zone = xpathSApply(st.xml, "//station/zones", xmlValue, trim = TRUE),
                   coordinates = xpathSApply(st.xml, "//Point/coordinates", xmlValue, trim = TRUE))

  st
}

parseCoordinates <- function(coordinates) {
  coords <- as.data.frame(matrix(as.numeric(unlist(strsplit(stations$coordinates, ","))), ncol = 3, byrow = TRUE))
  colnames(coords) <- c("longitude","latitude", "altitude")
  data.table(coords)
}

