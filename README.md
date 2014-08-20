GettingAndCleaningData
======================

Contains the course project submission for the Getting and Cleaning data course
==================================================================

Files submitted
=========================================

- 'README.md' : Provides explanation and details on the submitted files

- 'Tidy_Data.txt' : The combined dataset that has only mean and std variables (Step-2)

- 'Narrow_Data.txt': The dataset that has the average of each variable for every 
		     subject and activity	 (Step-5 data)

- 'combined_data_step1.txt' : The combined dataset that has all the 561 variables
			      I created this in the first step and also enriched
			      as per step 3 and 4. Though this dataset file is not 
			      requested as per the submission, uploading this file 
			      for reference since this is the first dataset that I used for steps 2 through 5

- run_analysis.R : The R script that reads the data and performs the requested analyis

Steps performed in the R script (run_analysis.R)
======================================================

I have broken down the script into multiple functions to get a modular structure 
the run_analysis is the main function that will give the output files.
Another main function is the combine_dataset that will combine the datasets, given the folder name


Each function described:
============================
Function 1 : run_analysis()

Input : None
Output : Tidy_Data.txt, Narrow_Data.txt, combined_data_step1.txt

Processing steps:
1. Call the get_tidy_set_step1() 
 - This combines the test and train datasets and writes to file
2. Call the get_tidy_set_step2() 
- This uses data from previous step and subsets only the mean and std variables
3. Call the get_tidy_set_step5() 
- Creates a dataset that has the average of each variable for every subject and activity


Function 2 : get_tidy_set_step1 () 

Input : None
Output : 'combined_data_step1' - a dataframe object
Assumption : the data is present in the working directory. if not, download using URL

Processing steps:
1. Download the data if not already present in the working directory and unzip
2. Combine test data set by calling combine_dataset ("test")
3. Combine train data set by calling combine_dataset ("train")
4. Rbind the outout of steps 2 and 3 to get one tidy dataset
5. Add appropriate column names to the dataset by reading the 
variable names from the 'features' file. The first 4 columns are,
(a) Case: That says, if it is training set or test set
(b) Subject: Subject of the experiment
(c) Activity_Label : Numeric value of the activity
(d) Activity_Label_DEscription : Description of the activity


Function 3 : get_tidy_set_step2(combined_data_step1)  

Input: combined_data_step1 - a dataframe object
Output : Tidy_data - a dataframe object

Processing steps:
1. Extract only the required columns into a new dataframe - subject, activity, activity_desc
2. cbind above with only the column names that has '-mean()' variables
3. cbind above with only the column names that has '-std()' variables
4. Now, the output is a dataset that has only the mean and sd variables 

Function 4 : combine_dataset(folder)

Input: The folder that contains the dataset files to be combined
Output: A dataframe object that contains the merged dataset 

Processing steps:
1. Read the labels file and store in the labels vector, to be used later
2. Read all the files in the folder, that needs to be combined
 (a) In train folder - X_train, y_train and subject_train
 (b) In test folder - X_test, y_test and subject_test
 -I have named these as 'data_set', 'label' and 'subject' for easier reading
3. Using the lapply method, read all the files using read.table in the order data_Set, label, label and subject
4. Label is read twice inorder to join this with the label description, 
   i.e. convert "1" to "WALKING", etc
5. cbind that above step - so I have done this in 1 step by using the do.call method

merged_data <- do.call("cbind", 
                  lapply(c(subject, label, label, data_set),
                         function(set) data.frame(read.table(set))))
 
6. Now, enrich the 3rd column of merged_data by joining it with the labels
7. Add the "Subject" column
8. Return the merged_data 

Function 5 : getfeatures()

Input: None
Output : 'features' - a vector object of that contains the names of the 561 variables listed

Processing steps:
1. Read the features file
2. create a vector of the above and return this object

Function 6 : getlabels()

Input: None
Output : 'labels' - a vector object that contains the activity descriptions listed

Processing steps:
1. Read the labels file
2. create a vector of the above and return this object
