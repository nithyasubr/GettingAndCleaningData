run_analysis <- function ()
{
  ## Compute step1 outout and write to txt file
  ## This data contains all the fields from both test and training dataset
  print ("Step1 in progress... ")
  tidy_data_step1 <- get_tidy_data_step1 ()
  write.table (tidy_data_step1, "combined_data_step1.txt", sep = " ", row.names = FALSE)
  print ("Step1 COMPLETE ")
  
  ## Compute step2 outout and write to txt file
  ## This data contains only mean and std variables, 
  ## along with activity and subject
  
  print ("Step2 in progress... ")
  tidy_data_step2 <- get_tidy_data_step2 (tidy_data_step1)
  write.table (tidy_data_step2, "Tidy_Data.txt", sep = " ", row.names = FALSE)  
  print ("Step2 COMPLETE")
  
  print ("Step3,4 COMPLETE (Data is already enriched while combining in step1)")
  
  ## Compute step5 outout and write to txt file
  ## This data contains baggregated value of all variables
  ## across activity and subject
  
  print ("Step5 in progress...")
  tidy_data_step5 <- get_tidy_data_step5 (tidy_data_step2)
  
  ## Create txt file to upload to course project
  write.table (tidy_data_step5, "Narrow_Data.txt", sep = " ", row.names = FALSE)  

  print ("Step5 COMPLETE")
}
get_tidy_data_step1 <- function ()
{
  ## If the data is not downloaded yet, get data from web and unzip
  ## If already downloaded, use the existing data 
  
  if (!file.exists("UCI HAR Dataset")) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", "data.zip")
    unzip("data.zip")
    file.remove("data.zip")  
  }
  
  ## Set working directory
  ## Assumption : The downloaded data is unzipped to the current
  ##              working directory
  
  curr_dir <- getwd()
  setwd(paste(curr_dir, "/", "UCI HAR Dataset", sep = ""))
  
  ## Combine test data and training data separately
  test <- combine_dataset ("test")
  train <- combine_dataset ("train")
  
  ## Merge both test and training data to get one tidy dataset
  tidy_set <- rbind(train, test)
  
  ## Setting appropriate column names
  
  ## Store the features in a vector 
  ## to set the column names of the tidy set
  features <- getfeatures()
  
  col_names <- c("Case","Subject","Activity_Label",
                  "Activity_Label_Description", features)
  names(tidy_set) <- col_names
  
  ## Set the working dir back to original
  setwd (curr_dir)
  
  ## Return the tidy set
  tidy_set
}

combine_dataset <- function(folder) {
  
  ## Set folder directory
  ## Present in the current directory 
  
  curr_dir <- getwd()
  
  ## Get the contents of the folder
  UCI_dir_files <- list.files()
  
  ## Store the lables in a vector to be used to merge
  ## with the tidy data frame being created
  labels <- getlabels()
  
  setwd(paste(curr_dir, "/", folder, sep = ""))
  
  ## List files in Working Directory
  required_files <- list.files(getwd())
  
  ## Get the required files
  data_set <- required_files[3]
  label <- required_files[4]
  subject <- required_files[2]

  ## Extract the data files and merge them 
  ## Merging the dataset , label and the subject
  ## Label is merged into 2 columns inorder to get the activity 
  ## description in the next step below
  
  library(plyr)
  merged_data <- do.call("cbind", 
                  lapply(c(subject, label, label, data_set),
                         function(set) data.frame(read.table(set))))
  
  ## Enrich the tidy_set with activity description
  activity_label <- merged_data[, 3]
  
  ## Enrich activity_label to Activity_labels_description
  for (i in activity_label) {
    activity_label[activity_label == i] = labels[i]
  }
  merged_data[, 3] <- activity_label
  
  ## Add column for subject
  sub <- rep(paste(folder, "set", sep = ""), nrow(merged_data))
  merged_data <- cbind(data.frame(sub), merged_data)
  
  ## Set the working directory back to original
  setwd(curr_dir)
    
  ## Return combined dataset
  merged_data
}

getfeatures <- function () {
  
  ## Set folder directory
  ## Present in the current directory 
  
  curr_dir <- getwd()
  
  ## Get the contents of the folder
  UCI_dir_files <- list.files()
  
  features <- read.table(UCI_dir_files[2])
  features <- as.vector(features$V2)
  
  features
}
getlabels <- function () {
  ## Set folder directory
  ## Present in the current directory 
  
  curr_dir <- getwd()
  
  ## Get the contents of the folder
  UCI_dir_files <- list.files()
  
  labels <- read.table(UCI_dir_files[1])
  labels <- as.vector(labels$V2)
  
  labels
}

get_tidy_data_step2 <- function (ds) {
  
  # Copying the first few columns 
  # Subject, Activity, Activity_Description
  keyDf <- data.frame(ds$Subject,ds$Activity_Label,ds$Activity_Label_Description)
  
  # Get the mean and std variables and cbind it to the main dataset
  ds1 <- cbind(keyDf, ds[,grep("-mean()",names(ds))])
  ds2 <- cbind(ds1, ds[,grep("-std()",names(ds))])
  
  # Returning a dataset that has 79 variables
  ds2
}

get_tidy_data_step5 <- function (ds) {
 
  library(plyr)
  library(reshape2)
  
  # Removing the activity label numeric column before melt
  ds[,2] <- NULL
  
  # Melting the data to order based on subject 
  # and activity_label_descrition
  melted <- melt (ds,id.vars = c("ds.Subject", "ds.Activity_Label_Description"))
  
  # Compute the average of the variables for each subject and activity
  # 180 variables per subject and activity 
  narrow_set <- ddply(melted, c("ds.Subject",
                                "ds.Activity_Label_Description",
                                "variable"), 
                      summarise, mean = mean(value))
  
  names(narrow_set) <- c("Subject", "Activity_Description", "Variable", "Mean")
  narrow_set
  
}