#########################################################################
# Joshua T. Pierce
# DAT690 Capstone in Data Analytics
#
# This R script is intended to be ran a single time without interaction.
# Utilizing the following dataset should yield identical if you update
#  your working directory accordingly: http://archive.ics.uci.edu/ml/datasets/mammographic+mass
# 
# An example algorithm for deployment is added at the end but is not 
#  intended to be part of the script execution.
#

#########################################################################
#Part I: Packages
#########################################################################

#Install All Packages
#Comment Out if Already Installed (Will Slow Down Runtime)
#install.packages("ridittools", repos = "https://cran.rstudio.com")
#install.packages("Amelia", repos = "https://cran.rstudio.com")
#install.packages("ggvis", repos = "https://cran.rstudio.com")
#install.packages("lattice", repos = "https://cran.rstudio.com")
#install.packages("ggplot2", repos = "https://cran.rstudio.com")
#install.packages("e1071", repos = "https://cran.rstudio.com")
#install.packages("caret", repos = "https://cran.rstudio.com")
#install.packages("FactoMineR", repos = "https://cran.rstudio.com")
#install.packages("ROCR", repos = "https://cran.rstduio.com")
#install.packages("arules", repos = "https://cran.rstudio.com")
#install.packages("mlr", repos = "https://cran.rstudio.com")
#install.packages("Matrix", repos = "https://cran.rstudio.com")
#install.packages("psych", repos = "https://cran.rstudio.com")
#install.packages("dplyr", repos = "https://cran.rstudio.com")
#install.packages("corrplot", repos = "https://cran.rstudio.com")

#Load Packages Into Working Memory
library("ridittools")
library("Amelia")
library("ggvis")
library("lattice")
library("ggplot2")
library("e1071")
library("caret")
library("FactoMineR")
library("ROCR")
library("arules")
library("mlr")
library("Matrix")
library("psych")
library("dplyr")
library("corrplot")

#############################################################################
# Part II: Data Import and Transformation
#############################################################################

#Load Dataset Into Working Memory
mammMasses <- read.csv("c:/users/Joshu/documents/datasets/mammMasses.csv")

#Reorder Columns so "Age"s is First and "Class" is Last
mammMasses <- mammMasses[c(2,1,3,4,5,6)]

#View the Structure of the Dataset
str(mammMasses)

#Create Dot Products
#Create a Copy of mammMasses, "cross"
cross = mammMasses

#Make Each Column Into a Unique Vector
dot1 <- cross[,1]
dot2 <- cross[,2]
dot3 <- cross[,3]
dot4 <- cross[,4]
dot5 <- cross[,5]

#Use tcrossprod to Create Cross Product Variables for All Combinations
dotp1 <- tcrossprod(dot1, dot2)
dotp2 <- tcrossprod(dot1, dot3)
dotp3 <- tcrossprod(dot1, dot4)
dotp4 <- tcrossprod(dot1, dot5)
dotp5 <- tcrossprod(dot2, dot3)
dotp6 <- tcrossprod(dot2, dot4)
dotp7 <- tcrossprod(dot2, dot5)
dotp8 <- tcrossprod(dot3, dot4)
dotp9 <- tcrossprod(dot3, dot5)
dotp10 <- tcrossprod(dot4, dot5)

#Use diag to Isolate the New Vector, the Cross Product
dotp1 <- diag(dotp1)
dotp2 <- diag(dotp2)
dotp3 <- diag(dotp3)
dotp4 <- diag(dotp4)
dotp5 <- diag(dotp5)
dotp6 <- diag(dotp6)
dotp7 <- diag(dotp7)
dotp8 <- diag(dotp8)
dotp9 <- diag(dotp9)
dotp10 <- diag(dotp10)

#Discretize the Dot Products
dotp1 <- as.numeric(unlist(dotp1)) 
dotp1 <- discretize(dotp1, breaks = 5)
dotp1 <- as.integer(dotp1)

dotp2 <- as.numeric(unlist(dotp2)) 
dotp2 <- discretize(dotp2, breaks = 5)
dotp2 <- as.integer(dotp2)

dotp3 <- as.numeric(unlist(dotp3)) 
dotp3 <- discretize(dotp3, breaks = 5)
dotp3 <- as.integer(dotp3)

dotp4 <- as.numeric(unlist(dotp4)) 
dotp4 <- discretize(dotp4, breaks = 5)
dotp4 <- as.integer(dotp4)

dotp5 <- as.numeric(unlist(dotp5)) 
dotp5 <- discretize(dotp5, breaks = 5)
dotp5 <- as.integer(dotp5)

dotp6 <- as.numeric(unlist(dotp6)) 
dotp6 <- discretize(dotp6, breaks = 5)
dotp6 <- as.integer(dotp6)

dotp7 <- as.numeric(unlist(dotp7)) 
dotp7 <- discretize(dotp7, breaks = 3)
dotp7 <- as.integer(dotp7)

dotp8 <- as.numeric(unlist(dotp8)) 
dotp8 <- discretize(dotp8, breaks = 3)
dotp8 <- as.integer(dotp8)

dotp9 <- as.numeric(unlist(dotp9)) 
dotp9 <- discretize(dotp9, breaks = 3)
dotp9 <- as.integer(dotp9)

dotp10 <- as.numeric(unlist(dotp10)) 
dotp10 <- discretize(dotp10, breaks = 3)
dotp10 <- as.integer(dotp10)

#Bind New Variables Into a Dataset, "cross2"
cross2 <- as.data.frame(cbind(dotp1, dotp2, dotp3, dotp4, dotp5, dotp6, dotp7, dotp8, dotp9, dotp10))

#Rename Columns to Reflect Cross Products
colnames(cross2) <- c("age_birads", "age_shape", "age_margin", "age_density", "birads_shape", "birads_margin", "birads_density", "shape_margin", "shape_density", "margin_density")

#Cbind cross2 onto mammMasses as mammMasses2
mammMasses2 <- cbind(mammMasses, cross2)

##########################################################################
#Part III: Data Exploration Transformation
##########################################################################

#Principal  Component Analysis & CorrPlot
pca1 <- PCA(mammMasses2, graph = T)
pca1

#PCA Eigenvalues
pca1$eig

#Descriptive Stats for PCs
dimdesc(pca1)

#PCA Loadings
model <- princomp(~.,mammMasses2[1:829,1:12], na.action = na.omit)
model$loadings

#CorrPlot
corrplot(cor(mammMasses2), method = "circle")

#REMOVE THE VARIABLES THAT ARE STRONGLY CORRELATED WITH VARIABLES THAT ARE *NOT*
#ONE OF THEIR DERIVED COUNTERPARTS(SHAPE, DENSITY, MARGIN)
#HELPS SMOOTH ASSUMPTIONS OF INDEPENDENCE FOR NB CLASSIFIER

#REMOVED SHAPE DENSITY AFTER FALSEPOS/NEG ANALYSIS

#Reorder Variables to Reflect Correct Ordering
mammMasses2 <- mammMasses2[c(1,2,7,8,9,10,11,12,13,14,16,6)]
str(mammMasses2)

#Export mammMasses2 (Adjust Your Working Directory as Needed)
write.csv(mammMasses2, "mammMasses2.csv")

#Use Describe from "psych" Package for Summary Statistics
describe(mammMasses2)

#Lots of Histograms 
mammMasses2 %>% ggvis(~Age) %>% layer_densities()
mammMasses2 %>% ggvis(~BI_RADS) %>% layer_bars()
mammMasses2 %>% ggvis(~age_birads) %>% layer_bars()
mammMasses2 %>% ggvis(~age_shape) %>% layer_bars()
mammMasses2 %>% ggvis(~age_margin) %>% layer_bars()
mammMasses2 %>% ggvis(~age_density) %>% layer_bars()
mammMasses2 %>% ggvis(~birads_shape) %>% layer_bars()
mammMasses2 %>% ggvis(~birads_margin) %>% layer_bars()
mammMasses2 %>% ggvis(~birads_density) %>% layer_bars()
mammMasses2 %>% ggvis(~shape_margin) %>% layer_bars()
mammMasses2 %>% ggvis(~margin_density) %>% layer_bars()

##########################################################################
#Part IV: Naive-Bayesian Modeling
##########################################################################

#Call the NaiveBayes() Function on MammMasses2
NBModel <- naiveBayes(Class ~., mammMasses2)
NBModel

#Create a Classification Task For the Model
require(mlr)
task <- makeClassifTask(data = mammMasses2, target = "Class")

#Initialize the NB Classifier
selected_model <- makeLearner("classif.naiveBayes")

#Train the Model:
NBPred <- train(selected_model, task)
NBPred

#Apply Predictive Model to mammMasses2 Without Passing on the Target Variable
predictions_mlr <- as.data.frame(predict(NBPred, newdata = mammMasses2[1:11]))

#Create a Confusion Matrix 
require(caret)
table1 <- table(predictions_mlr[,1], mammMasses2$Class)
table1
table2 <- prop.table(table1)
table2

confusionMatrix(table1)

#Save the model as an RDS object
#With a new dataset, the RDS model can be re-loaded and used 
#in a new predict() function:
saveRDS(NBPred, file = "initialNaiveBayesModel.rds")
#to restore: readRDS(file = "initialNaiveBayesModel.rds")

##########################################################################
#Part V: Investigation of Errors
###########################################################################

#Create mammMasses3
#Append Predictions to Dataset
predictions_mlr[,1]
Preds <- as.integer(predictions_mlr[,1])
Preds <- ifelse(Preds == 2, 1, 0) #evaluates if preds = 2 and returns a boolean. T = re-evaluates to 1. F = 0. 
Preds                             #therefore, all 2s evaluate to 1s and all 1s evaluate to 0
table(Preds)
mammMasses3 <- cbind(mammMasses2, Preds)
str(mammMasses3)

#Create Error Table
#A Subset of MammMasses3 Where Class != Preds
#Copy mammMasses3

errorTable <- mammMasses3

#Filter Out Correct Predictions, Reassign to errortable
errortable2 <- errorTable %>% filter(errorTable$Class != errorTable$Preds)
str(errortable2)
describe(errortable2)

#Re-Classify mammMasses3
#Call the NaiveBayes() Function on MammMasses2
NBModel2 <- naiveBayes(Class ~., mammMasses3)
NBModel2

#Create a Classification Task For the Model
require(mlr)
task2 <- makeClassifTask(data = mammMasses3, target = "Class")

#Initialize the NB Classifier
selected_model2 <- makeLearner("classif.naiveBayes")

#Train the Model:
NBPred2 <- train(selected_model2, task2)
NBPred2

#Apply Predictive Model to mammMasses3 Without Passing on the Target Variable
predictions_mlr2 <- as.data.frame(predict(NBPred2, newdata = mammMasses3[1:11]))

#Create a Confusion Matrix 
require(caret)
table3 <- table(predictions_mlr2[,1], mammMasses3$Class)
table3
table4 <- prop.table(table3)
table4

confusionMatrix(table3)

#Repeat CorrPlot and PCA for mammMasses3

pca2 <- PCA(mammMasses3, graph = T)
pca2

#PCA Eigenvalues
pca2$eig

#Descriptive Stats for PCs
dimdesc(pca2)

#PCA Loadings
model <- princomp(~.,mammMasses3[1:829,1:11], na.action = na.omit)
model$loadings

#CorrPlot
corrplot(cor(mammMasses3), method = "circle")

#Make errortable2 Into False Positives and False Negatives:
falsePos <- errortable2 %>% filter(errortable2$Class == 0, errortable2$Preds == 1)
falseNeg <- errortable2 %>% filter(errortable2$Class == 1, errortable2$Preds == 0)
str(falsePos)
str(falseNeg)

#Get Summary Statistics and Histograms for False Pos and False Neg Tables
describe(falsePos)
describe(falseNeg)

falsePos %>% ggvis(~Age) %>% layer_densities()
falsePos %>% ggvis(~Age) %>% layer_densities()

falsePos %>% ggvis(~BI_RADS) %>% layer_bars()
falsePos %>% ggvis(~BI_RADS) %>% layer_bars()

falsePos %>% ggvis(~age_birads) %>% layer_bars()
falsePos %>% ggvis(~age_birads) %>% layer_bars()

falsePos %>% ggvis(~age_shape) %>% layer_bars()
falsePos %>% ggvis(~age_shape) %>% layer_bars()

falsePos %>% ggvis(~age_density) %>% layer_bars()
falsePos %>% ggvis(~age_density) %>% layer_bars()

falsePos %>% ggvis(~birads_shape) %>% layer_bars()
falsePos %>% ggvis(~birads_shape) %>% layer_bars()

falsePos %>% ggvis(~birads_margin) %>% layer_bars()
falsePos %>% ggvis(~birads_margin) %>% layer_bars()

falsePos %>% ggvis(~birads_density) %>% layer_bars()
falsePos %>% ggvis(~birads_density) %>% layer_bars()

falsePos %>% ggvis(~shape_margin) %>% layer_bars()
falsePos %>% ggvis(~shape_margin) %>% layer_bars()

falsePos %>% ggvis(~margin_density) %>% layer_bars()
falsePos %>% ggvis(~margin_density) %>% layer_bars()

######################################################################
# Example algorithm for processing new values.
# //read in new observation
# newobs <- read.csv(newObservation)
# 
# //reorder so age is first, class is last
# 
# //check if new obs is numeric -- if not, convert
# for(variable) in (newobs){
#   if is.numeric(variable) = FALSE
#      newobs$variable <- is.numeric(newobs$variable)
# 
# create new variables for each column 
#
# create derived variables
#
# bind derived variables into new set 
#
# rename columns 
#
# load saved RDS model back into memory
#
# call RDS model on new observation
#
# get class value
####################################################################