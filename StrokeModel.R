# Load necessary libraries
library(tidymodels)
library(dplyr)
library(ggeasy)
library(themis)

# Load the dataset
StrokeData <- read.csv("C:\\Users\\Wellington\\Downloads\\Stroke\\healthcare-dataset-stroke-data.csv")

# Convert necessary variables to factors and select relevant columns
StrokeData <- StrokeData %>%
  mutate(across(c(Gender, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, SmokingStatus, Stroke), as.factor)) %>%
  select(Gender, Age, Hypertension, HeartDisease, EverMarried, WorkType, ResidenceType, AvgGlucoseLevel, BMI, SmokingStatus, Stroke)


StrokeData <- StrokeData %>%
  filter(Age >= 18) %>%
  mutate(
    BMI_Category = case_when(
      BMI < 18.5 ~ "Underweight",
      BMI < 25 ~ "Healthy Weight",
      BMI < 30 ~ "Overweight",
      BMI < 35 ~ "Obese",
      TRUE ~ "Severely Obese"
    ),
    Glucose_Category = case_when(
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
  step_impute_mean(all_numeric(), -all_outcomes()) %>%
  step_impute_mode(all_nominal_predictors(), -all_outcomes()) %>% 
  step_dummy(all_nominal(), -all_outcomes()) %>% 
  step_corr(all_numeric_predictors(), threshold = 0.6) %>% #remember it was 0.8
  step_zv(all_predictors()) %>%  # Remove zero-variance predictors
  step_smote(Stroke)  

stroke_recipe |> 
  prep() |> 
  bake(new_data = StrokeData)


stroke_spec <- 
  logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm") 

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



coefs <- model1 %>% 
  tidy() %>%
  filter(term != "(Intercept)")

# Plot the coefficients
ggplot(coefs, aes(x = estimate, y = reorder(term, estimate))) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Effect Sizes of Predictors in Logistic Regression Model",
       x = "Coefficient Estimate",
       y = "Predictors") +
  theme_minimal()





augment(model1, StrokeData) |> 
  select(Stroke, .pred_class, .pred_0, .pred_1) |> 
  conf_mat(Stroke, .pred_class)

#Under here is experimentation!!!!!!! To be deleted or made tidier in the future
library(ggplot2)

# Check the structure of coefs
print(coefs)

# Ensure the estimate column exists and is numeric
if (!"estimate" %in% colnames(coefs)) {
  stop("Column 'estimate' is missing from coefficients data.")
}

# Plot the coefficients
ggplot(coefs, aes(x = estimate, y = reorder(term, estimate))) +
  geom_point() +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  labs(title = "Effect Sizes of Predictors in Logistic Regression Model",
       x = "Coefficient Estimate",
       y = "Predictors") +
  theme_minimal()  

#Bam, Variable importance plot working
#Now knn exploration
library(tidymodels)
library(cluster) # For kmeans
library(factoextra) # Visualization
library(themis) # For SMOTE

# Load the dataset again
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

# Define the recipe including clusters
stroke_recipe_knn <- recipe(Stroke ~ ., data = StrokeData) %>%
  step_impute_mean(all_numeric(), -all_outcomes()) %>%
  step_impute_mode(all_nominal_predictors(), -all_outcomes()) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_corr(all_numeric_predictors(), threshold = 0.6) %>%
  step_zv(all_predictors()) %>%
  step_smote(Stroke)

# Define logistic regression model
stroke_spec_knn <- 
  logistic_reg() %>% 
  set_mode("classification") %>% 
  set_engine("glm")

# Create workflow
stroke_workflow_knn <- 
  workflow() %>% 
  add_recipe(stroke_recipe_knn) %>% 
  add_model(stroke_spec_knn)

# Train new model with clusters
model_knn <- 
  fit(stroke_workflow_knn, data = StrokeData)

# Extract and plot coefficients
stroke_model_knn <- 
  model_knn |>
  tidy(exponentiate = TRUE)

ggplot(stroke_model_knn, aes(x = estimate, y = reorder(term, estimate))) +
  geom_point() +
  geom_vline(xintercept = 1, linetype = "dashed", color = "red") +
  labs(title = "Effect Sizes of Predictors (Logistic Regression after KNN)",
       x = "Coefficient Estimate (Odds Ratio)",
       y = "Predictors") +
  theme_minimal()

# Confusion Matrix
conf_matrix_knn <- 
  augment(model_knn, StrokeData) %>%
  select(Stroke, .pred_class, .pred_0, .pred_1) %>%
  conf_mat(Stroke, .pred_class)

conf_matrix_knn






