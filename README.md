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

#### 📌 Attribute Data Type Corrections, Year Data Extraction & Renaming of Attributes

Four attributes were corrected:

    ▪️ "bathrooms" was initially categorized as a character data type and was converted to numeric.
    
    ▪️ "bedrooms" was also incorrectly categorized as character and changed to numeric.
    
    ▪️ "yr_renovated" was originally a numeric type but was transformed into a binary indicator (0 for no renovation, 1 for renovated) and renamed to "renovation" for better clarity.
    
    ▪️ "date" was originally recorded in a string format and was processed to extract the year, creating a new numeric attribute, "year_of_sale."
    
  
#### 📌 Inconsistency Resolution

    ▪️ "bedrooms" values of 0 were replaced with the mode (3 bedrooms).
    

#### 📌 Creation of the "house_updated" Dataset

    ▪️ A new dataset called "house_updated" was created by dropping the "id" attribute, as it lacked meaningful information. The "zipcode" attribute was also removed due to its limited explanatory and predictive power.  Instead, the geographical attributes "lat" (latitude) and "long" (longitude) were retained, as they provided more useful information.


#### 📌 Handling Missing Values

Missing values were handled through imputation:

    ▪️ Categorical variables: "waterfront", "bedrooms", "bathrooms", "floors", "view", "grade", "condition", "yr_built", "renovation", and "year_of_sale". 
    
    ▪️ Continuous variables: "price," "sqft_living," "sqft_lot," "sqft_above," "sqft_basement," "lat," "long," "sqft_living15," and "sqft_lot15," were imputed using their median given the skewness of their distributions.
    

#### 📌 Outlier Treatment

    ▪️ The "sqft_lot" outlier was adjusted by calculating the average ratio between "sqft_lot" and "sqft_lot15" (the average lot size of the 15 nearest neighbors).
    
    ▪️ This ratio was then used to impute a more reasonable value, reducing the outlier from 533,610 to approximately 254,996. However, this new value was still too large, given the small interior living space of 800 sqft.
    
    ▪️ As a result, the observation with the outlier was ultimately removed from the dataset to maintain data integrity.

---

### 3.0 Exploratory Data Analysis (EDA)

#### 📌 Metadata Inspection

![Screenshot 2024-10-23 175528](https://github.com/user-attachments/assets/d81ad2e1-4174-4173-92ff-7ebda1fedcea)
    
    ▪️ Reviewed the dataset’s structure after data pre-processing, confirming that it now contains 19 variables (after removing irrelevant ones) and that all variables are assigned the correct data types.

#### 📌 Descriptive Statistics

![Screenshot 2024-10-23 175817](https://github.com/user-attachments/assets/94a1aa6f-533b-4593-8cc5-b0f0335c0a3c)

    ▪️ Generated summary statistics for all the 19 attributes. 
    
    ▪️ Price: The average house price was $543,406, with wide variability.
        
    ▪️ Bedrooms and Bathrooms: Most homes had 3 bedrooms and 2 bathrooms, with means of 3.34 and 2.04, respectively.
        
    ▪️ Living and Lot Size: The average living area was 2061 sqft, and lot sizes varied significantly with a mean of 14,838 sqft.
    
    ▪️ Floors: Most homes were single-storied, averaging 1.49 floors.
        
    ▪️ Waterfront and View: Few homes had waterfront access (mean near 0), and most had low or no view ratings (mean of 0.23).
        
    ▪️ Condition and Grade: Homes were in average condition (mean 3.41) with above-average grade (mean 7.65).
    
    ▪️ Sqft Above and Basement: The average above-ground area was 1,771 sqft, and basements averaged 288.9 sqft.
        
    ▪️ Year Built and Renovation: The average build year was 1970, and most homes had not been renovated.
    
    ▪️ Lat and Long: Homes were clustered around coordinates (47.56, -122.21).
    
    ▪️ Neighboring Homes: The average neighboring living area was 1983 sqft, with lot sizes averaging 12,465 sqft.
    

#### 📌 Missing Value Check

![Screenshot 2024-10-23 180455](https://github.com/user-attachments/assets/43acdeea-f260-429f-bbab-711c720fadf3)

    ▪️ Ensured that no missing values remained in the dataset post-imputation and cleaning steps.


#### 📌 Univariate Visualizations

    ▪️ Created individual bar plots for ordinal and variables. 
    
    ▪️ Findings from the bar plots: Most homes lacked a waterfront view, had not been renovated, and received low view ratings. They were generally in moderate condition (rated 3) with a grade of 7. Most had 3 bedrooms and 2.5 bathrooms.


#### 📌 Continuous Variables Visualization

    ▪️ Plotted histograms for continuous variables. 
    
    ▪️ Findings are: Observations showed that these variables were positively skewed, indicating that high-value houses and large properties were relatively rare. Analysis of latitude and longitude variables revealed clustering of homes within specific geographical bands, possibly indicating denser neighborhoods.


#### 📌 Bivariate Relationships

    ▪️ Used scatterplots to examine potential relationships between key attributes.  
    
    ▪️ Findings are: Larger homes, more bathrooms, and higher view ratings were positively correlated with higher prices. Newer homes and those in neighborhoods with larger living spaces also tended to have higher prices. Lot size showed a mild positive relationship, while bedroom count had a mixed impact on prices.


#### 📌 Correlation Analysis

    ▪️ Computed correlations for all continuous and ordinal variables.
    
    ▪️ Findings are: A strong positive correlation was observed between "price" and "sqft_living" (0.7 or higher). Moderate correlations were found between "price" and other variables like "bathrooms," "view," and "sqft_living15," suggesting that these factors contribute to price but are not as strongly correlated as living space.


### 4.0 Feature Enginering

#### 📌 Metadata Inspection








