# Load necessary libraries
#If these packages are not already downloaded, uncomment the package installations below
#install.packages("tidymodels")
#install.packages("dplyr")
#install.packages("ggeasy")
#install.packages("themis")
#install.packages("cluster")
#install.packages("factoextra")


#Loading utilized packages
library(tidymodels)
library(dplyr)
library(ggeasy)
library(themis)
library(cluster)
library(factoextra)

# Load the dataset
StrokeData <- read.csv("C:\\Users\\Wellington\\Downloads\\Stroke\\healthcare-dataset-stroke-data.csv")
#Change the read.csv to match your file path, copying it from its directory

# Convert necessary variables to factors and select relevant columns for logistic regression
StrokeData <- StrokeData %>%
  mutate(across(c(Gender, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, SmokingStatus, Stroke), as.factor)) %>%
  select(Gender, Age, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, AvgGlucoseLevel, BMI, SmokingStatus, Stroke)


#
StrokeData <- StrokeData %>%
  filter(Age >= 18) %>% #Filtered participants below 18 due to them heavily skewing the data
  mutate(
    BMI_Category = case_when( #Categorizing BMI
      BMI < 18.5 ~ "Underweight",
      BMI < 25 ~ "Healthy Weight",
      BMI < 30 ~ "Overweight",
      BMI < 35 ~ "Obese",
      TRUE ~ "Severely Obese"
    ),
    Glucose_Category = case_when( #Categorizing Glucose Level
      AvgGlucoseLevel < 70 ~ "Very Low",
      AvgGlucoseLevel < 100 ~ "Low",
      AvgGlucoseLevel < 126 ~ "Healthy",
      AvgGlucoseLevel < 200 ~ "High",
      TRUE ~ "Very High"
    )
  ) %>%
  select(Gender, Age, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, SmokingStatus, Stroke, BMI_Category, Glucose_Category)



# Define the recipe
stroke_recipe <- recipe(Stroke ~ ., data = StrokeData) %>%
  step_impute_mean(all_numeric(), -all_outcomes()) %>% #Impute all numeric missing data with their mean
  step_impute_mode(all_nominal_predictors(), -all_outcomes()) %>%  #Impute all categorical missing data with their modes
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_corr(all_numeric_predictors(), threshold = 0.6) %>% #remember it was 0.8. Removes colinear variables
  step_zv(all_predictors()) %>%  # Remove zero-variance predictors
  step_smote(Stroke)  

stroke_recipe |> 
  prep() |> 
  bake(new_data = StrokeData)


stroke_spec <- 
  logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm") #Logistic Regression

stroke_spec

stroke_workflow <- 
  workflow() %>% 
  add_recipe(stroke_recipe) %>% 
  add_model(stroke_spec) 

stroke_workflow

model1 <- 
  fit(stroke_workflow, data = StrokeData) 

model1

stroke_model <- 
  model1 |>
  tidy(exponentiate = TRUE)

stroke_model





augment(model1, StrokeData) |> 
  select(Stroke, .pred_class, .pred_0, .pred_1) |> 
  conf_mat(Stroke, .pred_class)
#Adding a confusion matrix to access the accuracy of the model
#The model is 72.23% accurate based on the confusion matrix.

# Check the structure of coefs
print(coefs)

# Ensure the estimate column exists and is numeric
if (!"estimate" %in% colnames(coefs)) {
  stop("Column 'estimate' is missing from coefficients data.")
}

#Plotting the coefficients(Variable Importance Plot)
ggplot(coefs, aes(x = estimate, y = reorder(term, estimate))) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Effect Sizes of Predictors in Logistic Regression Model",
       x = "Coefficient Estimate",
       y = "Predictors") +
  theme_minimal()  

#Bam, Variable importance plot working

#Now knn clustering exploration 

# Load the dataset into a variable again
StrokeData <- read.csv("C:\\Users\\Wellington\\Downloads\\Stroke\\healthcare-dataset-stroke-data.csv")

# Convert necessary variables to factors and select relevant columns
StrokeData <- StrokeData %>%
  mutate(across(c(Gender, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, SmokingStatus, Stroke), as.factor)) %>%
  select(Gender, Age, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, AvgGlucoseLevel, BMI, SmokingStatus, Stroke)

# Filter adults only
StrokeData <- StrokeData %>%
  filter(Age >= 18)

# Normalize numerical data for KNN
# Ensure numeric columns are properly selected and converted
StrokeData_numeric <- StrokeData %>%
  mutate(
    Age = as.numeric(Age),
    AvgGlucoseLevel = as.numeric(AvgGlucoseLevel),
    BMI = as.numeric(BMI)
  ) %>%
  select(Age, AvgGlucoseLevel, BMI)

# Store row indices before removing NAs
StrokeData_numeric <- StrokeData_numeric %>%
  mutate(RowIndex = row_number()) %>% # Add index column
  drop_na() %>%  # Remove rows with missing values before scaling
  column_to_rownames(var = "RowIndex") %>%  # Keep index for merging
  scale()  # Normalize numerical data for clustering

# Apply K-Means Clustering
set.seed(42)
kmeans_result <- kmeans(StrokeData_numeric, centers = 3, nstart = 25)

# Convert cluster labels into a dataframe
ClusteredData <- data.frame(RowIndex = as.numeric(rownames(StrokeData_numeric)), Cluster = as.factor(kmeans_result$cluster))

# Merge cluster labels back into the original StrokeData
StrokeData <- StrokeData %>%
  mutate(RowIndex = row_number()) %>%
  left_join(ClusteredData, by = "RowIndex") %>%
  select(-RowIndex)  # Remove temporary index column

# Visualize Clusters
fviz_cluster(kmeans_result, data = StrokeData_numeric)








