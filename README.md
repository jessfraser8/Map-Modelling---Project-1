# Map-Modelling---Project-1

Dataset:

Stroke Prediction Dataset - 
Contains 11 variables to be used for education purposes to predict whether a patient will have a stroke. All quantitative variables were turned categorical within the Logistic Regression(R) script. For preprocessing the data, missing data was imputed with their means/modes, and for the logistic regression, quantitative variables were transformed into categories. For looking at the knn-clustering results, the quantitative variables used had to be normalized. Our four methods used to analyze the data were knn-clustering to see if there were any interesting trends/shapes in the data, logistic regression, xgboost, and random forest algorithms to build models for the data.
https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset/data 


Research Questions:

How do different factors affect the risk of a stroke?
What social determinant of health is most important in predicting a stroke in order to minimize stroke risks within a population?


Instructions:

First, ensure that all necessary packages are installed. Run the R script for the logistic regression model and VIP. Run the Python script for the Random Forest and XGboost models. Explanations of each code block are contained in the scripts.


Research:

Stroke is the leading cause of long-term adult disability and the fifth leading cause of death in the United States. Risk-factors can be categorized as modifiable and non-modifiable. Knowing what these factors are can be beneficial in preventing stoke by encouraging changes to modifiable risk-factors. It could also help to decrease the fatality of strokes if people are aware of their risk. 

A case-control study in 22 countries found that 90% of the risk of stroke are associated with 10 risk factors: hypertension, current smoking, waist-to-hip ratio, diet risk score, regular physical activity, diabetes mellitus, binge alcohol consumption, psychosocial stress and depression, cardiac disease, and ratio of apolipoprotein B to A1.

As for non-modifiable risk factors, risk of stroke increases with age. Whites have a lower risk of stroke, although it is unclear whether this is due to increased risk factors or disparities in healthcare. Women also have a higher risk of stroke, although this may be because female-specific risk factors are often not considered.

Risk scoring systems have been created to help identify patients with the greatest risk of stroke which could then help with prevention. The Framingham Stroke Risk Profile is a widely-used system, and the ASCVD risk estimator was the first to consider large amounts of data from black people.


Results:

KNN Clustering:

<img width="626" alt="knn clustering" src="https://github.com/user-attachments/assets/d28d0223-a372-4a6e-a76d-55951a227777" />

The knn clustering was divided into 3 clusters based on age, average glucose level, and BMI. It appears the green cluster represents older people with higher BMI and glucose levels, the blue cluster represents younger people with lower BMI and glucose levels, and the red cluster represents people in the middle. The overlap occurs because people do not follow script patters (there are young people with high BMI and glucose levels, and older people with low BMI and glucose levels). Individuals in the green cluster may be at higher risk of stroke and need further health monitoring. Individuals in the blue cluster may not need as much medical intervention based on these statistics.

Logistic Regression:

<img width="668" alt="Logistic Regression" src="https://github.com/user-attachments/assets/3b2015cd-3b50-4cf1-a0f3-9eba1d2bd7c4" />

The logistic regression is a variable of importance plot that displays which social determinant of health have the most impact. Based on this, it appears obesity and hypertension have the most impact on the risk of having a stroke. The logistic regression is 72.23% accurate.

Random Forest:

<img width="530" alt="Random Forest" src="https://github.com/user-attachments/assets/a2fa0f23-4e69-4af5-ac2b-c19488d7ab30" />


The Random Forest model had an accuracy of 88.58%. Although this seems accurate, when looking at the precision, we can see that the model predicts "No Stroke" correctly 95% of the time, but only predicts a stroke correctly 15% of the times. This results in many false positives.

XGBoost:

<img width="639" alt="XGBoost" src="https://github.com/user-attachments/assets/b67f6c68-0650-48eb-bbd1-d07980821d5d" />


The XGBoost model had an accuracy of 88.52%. Similarly to the Random Forest model, when looking at the precision, we can see that the model predicts "No Stroke" correctly 95% of the time, but only predicts a stroke correctly 13% of the times. This is slightly worse than the Random Forest model although both models are good at predicting "No Stroke" but bad at predicting a stroke.

Conclusion:

Overall, the results show that the social determinants of health that contribute most to stroke risk is obesity and high-blood pressure. In order to minimize the risk of stroke as much as possible, people should try to live healthy lifestyles to lower their blood-pressure and BMI. 

With more time and resources it would be beneficial to create predictor models that are more accurate at predicting strokes.

Sources:

https://www.kaggle.com/datasets/fedesoriano/stroke-prediction-dataset/data

https://www.ahajournals.org/doi/full/10.1161/CIRCRESAHA.116.308398#sec-3

https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(10)60834-3/abstract?rss=yes&TB_iframe=true&width=850&keepThis=true&height=650

https://www.ahajournals.org/doi/full/10.1161/STR.0b013e3182213e24#sec-11

https://www.ahajournals.org/doi/full/10.1161/CIRCRESAHA.121.319915#sec-8


Credit:

Wellington Gray - Wrote code scripts.

Jessica Fraser - Did the write up.

