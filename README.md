# Data Pre-processing, Feature Engineering, and Hypothesis Testing for King County Housing Data

## 📚 Introduction

An extension of the work done in [Part I](https://github.com/Weetynn/housingdata-dm-i.git), detailing the data preparation steps for further analysis of the King County housing dataset. Includes data pre-processing, feature engineering, and the testing of five key hypotheses to explore how attributes namely square footage, bedrooms, house age, lot utilization, and view ratings influence house prices.

## 🗒️ Main Areas of Discussion

### 1.0 Related Work

#### 📌 Literature Review

    ▪️ The literature review examines key factors influencing real estate prices, focusing on both internal and external factors.
    
    ▪️ Internal factors include structural features of the property, such as the number of bedrooms, bathrooms, total square footage, condition, and age of the property.
    
    ▪️ External factors include location, proximity to amenities like schools and public transport, and neighborhood characteristics such as population density and social status.
    
    ▪️ Previous studies are referenced to highlight how housing attributes affect property prices.
    
    ▪️ The findings from the literature are used as benchmarks for validating the hypothesis testing results in this report.

---

### 2.0 Data Preprocessing

#### 📌 Attribute Data Type Corrections & Renaming of Attributes

Four attributes were corrected for their data types:

    ▪️ "bathrooms" was initially categorized as a character data type and was converted to numeric.
    
    ▪️ "bedrooms" was also incorrectly categorized as character and changed to numeric.
    
    ▪️ "yr_renovated" was originally a numeric type but was transformed into a binary indicator (0 for no renovation, 1 for renovated) and renamed to "renovation" for better clarity.
    
    ▪️ "date" was originally recorded in a string format and was processed to extract the year, creating a new numeric attribute, "year_of_sale."
  
#### 📌 Handling Missing Values

Missing values were handled through imputation:

    ▪️ Categorical variables: "waterfront", "bedrooms", "bathrooms", "floors", "view", "grade", "condition", "yr_built", "renovation", and "year_of_sale". 
    
    ▪️ Continuous variables: "price," "sqft_living," "sqft_lot," "sqft_above," "sqft_basement," "lat," "long," "sqft_living15," and "sqft_lot15," were imputed using their median given the skewness of their distributions.
    
#### 📌 Inconsistency Resolution

    ▪️ "bedrooms" values of 0 were replaced with the mode (3 bedrooms).

#### 📌 Outlier Treatment

    ▪️ The "sqft_lot" outlier was adjusted by calculating the average ratio between "sqft_lot" and "sqft_lot15" (the average lot size of the 15 nearest neighbors).
    
    ▪️ This ratio was then used to impute a more reasonable value, reducing the outlier from 533,610 to approximately 254,996. However, this new value was still too large, given the small interior living space of 800 sqft.
    
    ▪️ As a result, the observation with the outlier was ultimately removed from the dataset to maintain data integrity.






