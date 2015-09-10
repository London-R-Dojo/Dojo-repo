---
title: 'T-distributed stochastic neighbor embedding:
Represent complex data set in 2/3D'
date: "9 September 2015"
output: html_document
---

<h3>Goal of the session: get nice plot!</h3>

The theory:

 ![Details](C:\rtsne.png)
 
 <br>
 
 Libraries needed for the project:
 
```{r, eval = F}
library(data.table)
library(ggplot2)
library(Rtsne)
```

```{r, include = F, message = F, warning = F}
 library(data.table)
 library(ggplot2)
library(Rtsne)
```

The Rtsne function is strict in the sense that it accept only numeric variables, non duplicated row and non missing values.

```{r, cache=TRUE, results='hide'}

# path
path <- "C:/YCR Perso/RTNSE/"

# read the data:
titanic.train <- fread(paste0(path, "DATA/train.csv"))

# get read of qualitative variables:
titanic.train[, flg.M := ifelse(Sex == "male", 1, 0)]

titanic.train[, flg.emb.s := ifelse(Embarked == "S", 1, 0)]
titanic.train[, flg.emb.c := ifelse(Embarked == "C", 1, 0)]
titanic.train[, flg.emb.q := ifelse(Embarked == "Q", 1, 0)]

# get read of duplicate values:
titanic.train2 <- titanic.train[, list(count = .N), by = list(Survived, Pclass, flg.M, flg.emb.s, flg.emb.c, flg.emb.q, Age, SibSp, Parch, Fare, Embarked)]

# get read of missing values:
titanic.train2[, Age := ifelse(is.na(Age), -1, Age)]

```

It is possible to influence the result weighting the variables.
Here, we want a separate representation of survivors.

```{r, cache=TRUE, results='hide'}
# wigthing the survivor variable.
titanic.train2[, Survived := 50 * Survived]
```

With huge table, the function could take a while. 

```{r}
res.rtnse <- Rtsne(titanic.train2[, list(Survived, Pclass, flg.M, flg.emb.s, flg.emb.c, flg.emb.q, Age, SibSp, Parch, Fare, count)], dims = 2)
```

```{r, cache=TRUE, results='hide'}
# we add the coordinates created to the original table and save the result.
titanic.train2[, x.rtnse := res.rtnse$Y[, 1]]
titanic.train2[, y.rtnse := res.rtnse$Y[, 2]]

save(titanic.train2, file = paste0(path, "data/titanic.Rdata"))
```

Now, the table is ready to be plotted.

```{r}
# path
path <- "C:/YCR Perso/RTNSE/"
load(paste0(path, "data/titanic.Rdata"))

## The final plot show separated cluster.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse)) +
  ggtitle("Scatterplot of the result of the rtsne implementation") +
  geom_point(color = "black")

## Survived is well separated. 
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = as.factor(Survived))) +
  ggtitle("Survived") +
  geom_point()

## Age is well separated, as well.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = Age)) +
  ggtitle("Age") +
  geom_point() 

## sex is well separated.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = as.factor(flg.M))) +
  ggtitle("Sex") +
  geom_point()

## Embarked is not really well separated.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = Embarked)) +
  ggtitle("Embarked") +
  geom_point()

## Pclass is mixed feeling separated.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = as.factor(Pclass))) +
  ggtitle("Class") +
  geom_point()

## Number of Siblings/Spouses Aboard is not that badly separated.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = as.factor(SibSp))) +
  ggtitle("Number of Siblings/Spouses Aboard") +
  geom_point()

## Number of Parents/Children Aboard is not that badly separated.
ggplot(data = titanic.train2, aes(x = x.rtnse, y = y.rtnse, color = as.factor(Parch))) +
  ggtitle("Number of Parents/Children Aboard") +
  geom_point()

```

Now, iris dataset: Question: How much meaningfull Cluster could we do?

```{r, cache=TRUE, results='hide'}
# Same thing, but with the iris dataset.
data(iris)

iris.dt <- data.table(iris)

iris.dt2 <- iris.dt[, list(count = .N), by = list(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width, Species)]

res.iris.rtnse <- Rtsne(iris.dt2[, list(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width, count)], dims = 2)

iris.dt2[, x.rtnse := res.iris.rtnse$Y[, 1]]
iris.dt2[, y.rtnse := res.iris.rtnse$Y[, 2]]
```

```{r}
## Let's look at the raw plot:
ggplot(data = iris.dt2, aes(x = x.rtnse, y = y.rtnse)) +
  geom_point(color = "black") 

## Species is well separated, here:
ggplot(data = iris.dt2, aes(x = x.rtnse, y = y.rtnse, color = Species)) +
  geom_point() 

```

The same things happen than with a PCA:

With the label, the species are well separated.

But without, there is difficulties to fix 2 or 3 clusters.

```{r}
# Sepal.length
ggplot(data = iris.dt2, aes(x = x.rtnse, y = y.rtnse, color = Sepal.Length)) +
  geom_point() 

# Sepal.Width
ggplot(data = iris.dt2, aes(x = x.rtnse, y = y.rtnse, color = Sepal.Width)) +
  geom_point() 

# Petal.Length
ggplot(data = iris.dt2, aes(x = x.rtnse, y = y.rtnse, color = Petal.Length)) +
  geom_point() 

# Petal.Width
ggplot(data = iris.dt2, aes(x = x.rtnse, y = y.rtnse, color = Petal.Width)) +
  geom_point() 
```
