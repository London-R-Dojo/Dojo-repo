 
### Load Libraries
library(corrplot)
library(circlize)
 
#load data - Quandl Global net migration stats https://www.quandl.com/c/demography/net-migration-worldbank-by-country
df <- read.csv(file = "Data/WB_migration.csv" )
 
#drop error cols
df <- df[,-19]
df <- df[,-139]
 
#rename cols
colnames <- read.csv(file = "Data/colnames.csv")
names(df) <- colnames[,2]
 
#calc corr matrix (change range to select different countries)
M <- cor(df[,100:178],)
 
#plot corr vis
corrplot(corr = M,method = "ellipse",type = "lower",diag = TRUE,tl.cex = 0.5,
         order = "FPC",
         title = "Global correlation of net migration by country")
 
 
#load 'circle' chart data (square matrix with 2 extra countires, one for imi, one for emi)
circ <- read.csv(file = "Data/WB_circle_migration.csv")
 
#conver to matrix
mat <- as.matrix(circ[1:181,2:180])
rownames(mat) <- as.character(circ[,1])
 
#plot circle diagram
chordDiagram(mat, transparency = 0.2)
