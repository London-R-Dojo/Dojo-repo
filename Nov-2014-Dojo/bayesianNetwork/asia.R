library(bnlearn)
data(asia)

colnames(asia) <- c("visit.to.asia",
                    "smoking",
                    "tb",
                    "lung.cancer",
                    "bronchitis",
                    "tb.v.b",
                    "x.ray",
                    "dyspnea")

res = empty.graph(names(asia))

modelstring(res) = paste0("[visit.to.asia][smoking][tb|visit.to.asia]",
                          "[lung.cancer|smoking][bronchitis|smoking]",
                          "[dyspnea|bronchitis:tb.v.b]",
                          "[tb.v.b|tb:lung.cancer][x.ray|tb.v.b]")

plot(res)

str(res)

fit = bn.fit(x=res, data=asia)

cpquery(fit, (visit.to.asia == "yes"),(smoking == "yes" & dyspnea == "yes"))
cpquery(fit, (visit.to.asia == "yes"),(smoking == "yes" & dyspnea == "yes"))

cpquery(fit, (x.ray == "yes" & visit.to.asia == "yes"),(smoking == "yes" & dyspnea == "yes"))

asia.probs<- c(rep(0, 8))
for (i in 1:8){
  eventTTTT = paste("(",names(asia)[i], "=='yes')", sep ="")
    asia.probs[i]<- cpquery(fit, 
#                             (visit.to.asia == "yes"),
                            eval(parse(text = eventTTTT)),
                            eval(parse(text = "(smoking == 'yes' & dyspnea == 'yes')")))
}

names(asia.probs) = names(asia)
asia.probs


