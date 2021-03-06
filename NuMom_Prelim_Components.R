#Install and load packages
packages <- c("tidyverse","tabplot","VIM","rpart","rpart.plot")
for (package in packages) {
  if (!require(package, character.only=T, quietly=T)) {
    install.packages(package,repos='http://lib.stat.cmu.edu/R/CRAN') 
  }
}

for (package in packages) {
  library(package, character.only=T)
}

install.packages("rpart.plot")
install.packages("expss")


library("expss")
library("tidyverse")
library("tabplot")
library("VIM")
library("rpart")
library("rpart.plot")
library("dplyr")

## import data here.

setwd("/Users/abigailcartus/Box/numom2b diet and machine learning")
getwd()
a<- read.csv("numom_small food components.csv", header=TRUE, sep=",")

# need to create a dataset that has only the stuff we want
# Removing studyid, sptb37_alt, income variable, age, and bmi (agecat and bmicat stay)
a <- a[c(-1,-3,-5,-7,-8)]

# general graphical overview of data
tableplot(a)

# visualization of missing
aggr(a)

#Low proportion missing; using only complete cases (?)
a <- a[complete.cases(a), ]

#Converting integer variables to factors
a$sptb37 <- factor(a$sptb37, levels=c(0,1), labels=c("Not preterm", "Preterm"))
a$smokerpre <- factor(a$smokerpre)
a$agecat3 <- factor(a$agecat3)
a$bmicat <- factor(a$bmicat)
a$white <- factor(a$white)
a$college <- factor(a$college)
a$married <- factor(a$married)

# classification and regression tree
# since Abby can't write a workable function, specify which component you want on each run
tree1 <- rpart(sptb37 ~ smokerpre + agecat3 + bmicat + white + college + married + g_nwhldens,  data=a, method="class", control=rpart.control(minsplit=10, minbucket=3, cp=0.001))
#for v_totdens and d_totdens, control parameters for rpart were changes: minsplit = 10, minbucket = 3, cp = 0.001

#Plotting the tree
plot(tree1, branch=0.1, uniform=TRUE, compress=TRUE)  
text(tree1, use.n=TRUE, all=TRUE, cex=0.9)
rpart.plot(tree1, extra=1)

# measuring "impact"

# median of quintiles of each variable
a$rq <- ntile(a$g_nwhldens, 5)  #creating quintile
aggregate(a$g_nwhldens, list(a$rq), median) #getting the median of each quintile (I think!)

#creating different datasets for different contrasts: choose your own adventure
a0 <- a; a0$g_nwhldens <- 2.9 #median of veg quintile 5   
a1 <- a; a1$g_nwhldens <- 2.17 #median of veg quintile 1

# predict from each
y0 <- predict(tree1,newdata = a0)
y1 <- predict(tree1,newdata = a1)

# here's the "impact" of heix_tot on sptb37 expressed on the risk difference scale
mean(y1[,2]) - mean(y0[,2])

# On the Risk Ratio scale
mean(y1[,2]) / mean(y0[,2])

# On the Odds Ratio scale
(mean(y1[,2])/(1 - mean(y1[,2]))) / (mean(y0[,2])/(1 - mean(y0[,2])))

