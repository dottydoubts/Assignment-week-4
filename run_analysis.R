## create a folder to work from
setwd("/week4")
if(!file.exists("./temp")){dir.create("./temp")}

## fetching the data and unzip
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
temp <- tempfile()
download.file(fileUrl, destfile = ("./temp/SmartphoneData.zip"))
unzip(zipfile="./temp/SmartphoneData.zip",exdir="./temp")
unlink(temp)

## read training raw data
setwd("/week4/temp/UCI HAR Dataset/train")
trainingData_df <- read.table("X_train.txt")
trainingActivityCodes_df <- read.table("y_train.txt")
trainingSubjectCodes_df <- read.table("subject_train.txt")

## read test raw data
setwd("/week4/temp/UCI HAR Dataset/test")
testData_df <- read.table("X_test.txt")
testActivityCodes_df <- read.table("y_test.txt")
testSubjectCodes_df <- read.table("subject_test.txt")

## add subject code column to training data
trainingData_df <- cbind(trainingSubjectCodes_df, trainingData_df)
## add activity code column to training data
trainingData_df <- cbind(trainingActivityCodes_df, trainingData_df)

## add subject code column to test data
testData_df <- cbind(testSubjectCodes_df, testData_df)
## add activity code column to test data
testData_df <- cbind(testActivityCodes_df, testData_df)

## read activity labels
setwd("/week4/temp/UCI HAR Dataset")
activityLabels_df <- read.table("activity_labels.txt")

## merge test and training data
merged_df <- rbind(testData_df, trainingData_df)

## read variable labels
setwd("/week4/temp/UCI HAR Dataset")
variableLabels_df <- read.table("features.txt")

## create new dataframe with extra labels
V1 <- c(0, 0)
V2 <- c("activityType", "subject")
extraLabels_df <- data.frame(V1, V2)
variableLabels_df <- rbind(extraLabels_df, variableLabels_df)

## renaming all columns 
variableLabels = as.vector(variableLabels_df$V2)
colnames(merged_df) <- variableLabels

## remove duplicate colnames without mean or std
merged_df <- merged_df[ !duplicated(colnames(merged_df))]

## extracts only the mean and std columns
library(dplyr)
merged_df <- select(merged_df, matches("activityType|subject|mean|std"))

## replace activity codes with descriptions
merged_df$activityType[merged_df$activityType == 1] <- "WALKING"
merged_df$activityType[merged_df$activityType == 2] <- "WALKING_UPSTAIRS"
merged_df$activityType[merged_df$activityType == 3] <- "WALKING_DOWNSTAIRS"
merged_df$activityType[merged_df$activityType == 4] <- "SITTING"
merged_df$activityType[merged_df$activityType == 5] <- "STANDING"
merged_df$activityType[merged_df$activityType == 6] <- "LAYING"

## creates a second, independent tidy data set with the average of each variable for each activity and each subject.
grp_cols <- c("activityType","subject")
dots <- lapply(grp_cols, as.symbol)
averages_df <- group_by_(merged_df, .dots=dots)
averages_df <- summarise_each(averages_df, funs(mean))

setwd("/week4")
write.table(averages_df, "averages.txt", row.name=FALSE)
unlink("averages.txt")
