/* Program: Data Management */
/* Author: Abigail Wee Tynn */
/* Date: 5th October 2023 */

*Print dataset;
proc print data = m_data.house;
run;

*Make a copy of the dataset;
data house;
	set m_data.house;
run;

*Printing the Metadata;
proc contents data = house;
run;


/* ------------------------- */
/* bathrooms VARIBALE */
/* ------------------------- */

*Convert the bathrooms attribute from character to numeric;
data house;
    set house;

    /* Convert the 'bathrooms' character variable to a numeric variable 
       using the INPUT function. The informat 'BEST32.' specifies that 
       the character value should be converted to its numeric representation. */
    bathrooms_num = input(bathrooms, BEST32.);

    /* Assign a format to the newly converted numeric variable.
       The format 'BEST12.' specifies that the numeric value should 
       be displayed with up to 12 characters, using the best format available. */
    format bathrooms_num BEST12.;

    /* Drop the original 'bathrooms' character variable 
       as we now have its numeric counterpart. */
    drop bathrooms;

    /* Rename the newly created numeric variable to the original 
       variable name for consistency and ease of analysis. */
    rename bathrooms_num=bathrooms;
run;

*Printing the Metadata to check if the above changes have been made;
proc contents data = house;
run;

/* Compute quartiles for the 'bathrooms' variable */
PROC UNIVARIATE DATA=house;
    VAR bathrooms;
    OUTPUT OUT=OutliersBathrooms (RENAME=(bedrooms=OriginalBathrooms))
    Q1=Q1_bathrooms Q3=Q3_bathrooms;
RUN;

/* Detect and store outliers for 'bathrooms' in a new dataset */
DATA OutliersListBathrooms (keep=ObsNum OutlierValue);
    SET house;
    IF _N_ = 1 THEN SET OutliersBathrooms;
    IQR = Q3_bathrooms - Q1_bathrooms;
    LowerBound = Q1_bathrooms - 1.5 * IQR;
    UpperBound = Q3_bathrooms + 1.5 * IQR;
    IF bathrooms < LowerBound OR bathrooms > UpperBound THEN DO;
        ObsNum = _N_;
        OutlierValue = bathrooms;
        OUTPUT;
    END;
    DROP IQR LowerBound UpperBound Q1_bathrooms Q3_bathrooms;
RUN;

/* Print detected outliers */
PROC PRINT DATA=OutliersListBathrooms;
RUN;

/* Visualize 'bathrooms' distribution with a boxplot */
PROC SGPLOT DATA=house;
    VBOX bathrooms;
RUN;

/* Scatter plot with regression line for Bathrooms vs. Bedrooms*/
proc sgplot data=house;
    scatter x=bathrooms y=bedrooms;
    reg x=bathrooms y=bedrooms / degree=1 lineattrs=(color=red); 
    title "Scatterplot of Bathrooms vs. Bedrooms with Regression Line";
run;

/* Notice that the min value is 0 which is illogical for a house to have 0 bathrooms */
/* Calculate the mode (most frequent value) for the 'bathrooms' variable */
proc freq data=house;
    tables bathrooms;
    where bathrooms ne 0; /* Exclude observations where bathrooms is 0 */
run;

/* Impute the observations where the bathroom number is 0 with the mode */
data house;
    set house;
    /* If bathrooms is 0, replace it with the mode */
    if bathrooms = 0 then bathrooms = 2.5; /* Replace X with the identified mode value */
run;

/* Check for observations where 'bathrooms' is 0 */
proc sql;
    select count(*) as Zero_Bathrooms_Count
    from house
    where bathrooms = 0;
quit;


/* ------------------------- */
/* bedrooms VARIABLE */
/* ------------------------- */

/* Investigate the 'bedrooms' variable */
PROC UNIVARIATE DATA=house;
    VAR bedrooms;
    OUTPUT OUT=OutliersBedrooms (RENAME=(bedrooms=OriginalBedrooms))
    Q1=Q1_bedrooms Q3=Q3_bedrooms;
RUN;

/* Notice that the min value is 0 which is illogical for a house to have 0 bedrooms */
/* Calculate the mode (most frequent value) for the 'bedrooms' variable */
proc freq data=house noprint;
    tables bedrooms / out=bedroom_freq (drop=percent);
    where bedrooms ne 0; /* Exclude observations where bedrooms is 0 when calculating the mode */
run;

/* Impute the observations where the bedroom number is 0 with the mode */
data house;
    set house;
    /* If bedrooms is 0, replace it with the mode */
    if bedrooms = 0 then bedrooms = 3; /* Replace X with the identified mode value */
run;

/* Check for observations where 'bedrooms' is 0 */
proc sql;
    select count(*) as Zero_Bedrooms_Count
    from house
    where bedrooms = 0;
quit;


/* ------------------------- */
/* date EXTRACTION from date VARIBALE */
/* ------------------------- */

*Extract the year of the sale from the string and convert it to numeric;
data house;
    set house; 

    /* Extract the year from the date string and convert to numeric */
    year_of_sale = input(substr(date, 1, 4), 4.);

    drop date; /* Drop the original date variable */
run;


/* ------------------------- */
/* yr_renovated  VARIABLE (PRE Name Change) */
/* renovation  VARIABLE (POST Name Change) */
/* ------------------------- */

/*Deal with the inconsistencies within the yr_renovated column, where '1' indicates ... */
/* ... that renovation has been done and '0' indicates otherwise. */
data house;
    set house;
    
    /* Check if the 'yr_renovated' value is greater than the 'yr_built' value */
    if yr_renovated > yr_built then 
        /* If true (i.e., the house was renovated after it was built), set 'yr_renovated' to 1 */
        yr_renovated = 1;
    else 
        /* If false (i.e., the house was either not renovated or renovated the ... */
        /* ... same year it was built), set 'yr_renovated' to 0 */
        yr_renovated = 0;

    /* Rename the 'yr_renovated' column to 'renovation' */
    rename yr_renovated=renovation;

/* End of the data step */
run;

/* Create a new dataset 'house_updated' without the specified columns */
data house_updated;
  set house;
  drop id zipcode;
run;

*Display the metadata of the modified dataset to see the changes in variable types and attributes;
proc contents data=house_updated;
run;

/* Create a new dataset 'missing_data' from the 'house' dataset */
data missing_data;
    set house_updated;
    
    /* Create arrays to hold numeric and character variables */
    array num_vars[*] _NUMERIC_;      /* Array for numeric variables */
    array char_vars[*] _CHARACTER_;   /* Array for character variables */
    
    /* Initialize a flag to indicate if an observation has missing values */
    missing_flag = 0;
    
    /* Iterate over numeric variables */
    do i = 1 to dim(num_vars);
        /* Check if the current numeric variable has a missing value */
        if num_vars{i} = . then missing_flag = 1;
    end;
    
    /* Iterate over character variables */
    do i = 1 to dim(char_vars);
        /* Check if the current character variable is an empty string (indicating missing) */
        if char_vars{i} = ' ' then missing_flag = 1;
    end;
    
    /* Output rows with missing values to the 'missing_data' dataset */
    if missing_flag then output;

    /* Drop unnecessary variables from the output dataset */
    drop i missing_flag;
run;

/* Print the observations with missing values to the SAS output */
proc print data=missing_data; 
run;

/* Create an initial copy of the dataset for imputation */
data house_imputed;
    set house_updated;
run;


/* ------------------------- */
/* Categorical Variables */
/* ------------------------- */


/* ------------------------- */
/* waterfront VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the waterfront variable */
proc freq data=house_imputed;
    tables waterfront / out=stats_waterfront;
    where waterfront is not missing;
run;

/* Impute missing values for the 'waterfront' variable with "0" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'waterfront' is missing, impute with the mode 0 */
    if waterfront = . then waterfront = 0;

run;

/* Check the number of missing values for 'waterfront' after imputation */
proc means data=house_imputed n nmiss;
    var waterfront;
run;


/* ------------------------- */
/* bedrooms VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the bedrooms variable */
proc freq data=house_imputed;
    tables bedrooms / out=stats_bedrooms;
    where bedrooms is not missing;
run;

/* Impute missing values for the 'bedrooms' variable with "3" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'bedrooms' is missing, impute with the mode 3 */
    if bedrooms = . then bedrooms = 3;

run;

/* Check the number of missing values for 'bedrooms' after imputation */
proc means data=house_imputed n nmiss;
    var bedrooms;
run;


/* ------------------------- */
/* bathrooms VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the bathrooms variable */
proc freq data=house_imputed;
    tables bathrooms / out=stats_bathrooms;
    where bathrooms is not missing;
run;

/* Impute missing values for the 'bathrooms' variable with "2.5" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'bathrooms' is missing, impute with the mode 2.5 */
    if bathrooms = . then bathrooms = 2.5;

run;

/* Check the number of missing values for 'bathrooms' after imputation */
proc means data=house_imputed n nmiss;
    var bathrooms;
run;


/* ------------------------- */
/* floors VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the floors variable */
proc freq data=house_imputed;
    tables floors / out=stats_floors;
    where floors is not missing;
run;

/* Impute missing values for the 'floors' variable with "1" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'floors' is missing, impute with the mode 1 */
    if floors = . then floors = 1;

run;

/* Check the number of missing values for 'floors' after imputation */
proc means data=house_imputed n nmiss;
    var floors;
run;

/* ------------------------- */
/* view VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the view variable */
proc freq data=house_imputed;
    tables view / out=stats_view;
    where view is not missing;
run;

/* Impute missing values for the 'view' variable with "0" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'view' is missing, impute with the mode 0 */
    if view = . then view = 0;

run;

/* Check the number of missing values for 'view' after imputation */
proc means data=house_imputed n nmiss;
    var view;
run;


/* ------------------------- */
/* condition VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the condition variable */
proc freq data=house_imputed;
    tables condition / out=stats_condition;
    where condition is not missing;
run;

/* Impute missing values for the 'condition' variable with "3" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'condition' is missing, impute with the mode 3 */
    if condition = . then condition = 3;

run;

/* Check the number of missing values for 'condition' after imputation */
proc means data=house_imputed n nmiss;
    var condition;
run;


/* ------------------------- */
/* grade VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the grade variable */
proc freq data=house_imputed;
    tables grade / out=stats_grade;
    where grade is not missing;
run;

/* Impute missing values for the 'grade' variable with "7" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'grade' is missing, impute with the mode 7 */
    if grade = . then grade = 7;

run;

/* Check the number of missing values for 'grade' after imputation */
proc means data=house_imputed n nmiss;
    var grade;
run;


/* ------------------------- */
/* yr_built VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the yr_built variable */
/* Order the output by frequency in descending order */
proc freq data=house_imputed order=freq;
    tables yr_built / out=stats_yr_built;
    where yr_built is not missing;
run;

/* Impute missing values for the 'yr_built' variable with "2014" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'yr_built' is missing, impute with the mode 2014 */
    if yr_built = . then yr_built = 2014;

run;

/* Check the number of missing values for 'yr_built' after imputation */
proc means data=house_imputed n nmiss;
    var yr_built;
run;


/* ------------------------- */
/* renovation VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the renovation variable */
proc freq data=house_imputed;
    tables renovation / out=stats_renovation;
    where renovation is not missing;
run;

/* Impute missing values for the 'renovation' variable with "0" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'renovation' is missing, impute with the mode 0 */
    if renovation = . then renovation = 0;

run;

/* Check the number of missing values for 'renovation' after imputation */
proc means data=house_imputed n nmiss;
    var renovation;
run;


/* ------------------------- */
/* year_of_sale VARIABLE */
/* ------------------------- */

/* Calculate and display mode for the year_of_sale variable */
proc freq data=house_imputed;
    tables year_of_sale / out=stats_year_of_sale;
    where year_of_sale is not missing;
run;

/* Impute missing values for the 'year_of_sale' variable with "2014" since it is the mode */
data house_imputed;
    set house_imputed;

    /* If 'year_of_sale' is missing, impute with the mode 2014 */
    if year_of_sale = . then year_of_sale = 2014;

run;

/* Check the number of missing values for 'year_of_sale' after imputation */
proc means data=house_imputed n nmiss;
    var year_of_sale;
run;


/* ------------------------- */
/* Continuous Variables */
/* ------------------------- */

/* Check skewness for each numerical variable */
proc means data=house_imputed skewness;
    var price sqft_living sqft_lot sqft_above sqft_basement
        lat long sqft_living15 sqft_lot15;
    output out=SkewnessOutput skewness=;
run;

/* Calculate the mean and median for each continuous variable in the house_imputed dataset. */
proc means data=house_imputed mean median;
    /* List of continuous variables for which we want to calculate mean and median */
    var price sqft_living sqft_lot sqft_above sqft_basement lat long sqft_living15 sqft_lot15;
    
    /* Output the calculated mean and median values to the stats_continuous dataset. */
    /* The mean and median values will be named with suffixes _mean and _median, respectively. */
    output out=stats_continuous mean= median= / autoname;
run;


/* ------------------------- */
/* DATA Step for Imputation */
/* ------------------------- */

/* Begin a new DATA step to handle imputation of missing values in the house_imputed dataset. */
data house_imputed (keep = price bedrooms sqft_living sqft_lot floors waterfront view condition 
                           grade sqft_above sqft_basement yr_built renovation lat long 
                           sqft_living15 sqft_lot15 bathrooms year_of_sale);
    /* Read the house_imputed dataset */
    set house_imputed;
    
    /* For the first observation, read in the mean and median values from stats_continuous */
    /* These values will be available for all subsequent observations in the DATA step */
    if _N_ = 1 then set stats_continuous;

    /* Impute missing values for each continuous variable based on skewness */
    /* For each variable, if its value is missing (represented by .), */
    /* replace it with its corresponding median value. */
    if price = . then price = price_median;
    if sqft_living = . then sqft_living = sqft_living_median;
    if sqft_lot = . then sqft_lot = sqft_lot_median;
    if sqft_above = . then sqft_above = sqft_above_median;
    if sqft_basement = . then sqft_basement = sqft_basement_median;
    if lat = . then lat = lat_median;
    if long = . then long = long_median;
    if sqft_living15 = . then sqft_living15 = sqft_living15_median;
    if sqft_lot15 = . then sqft_lot15 = sqft_lot15_median;

    /* End the DATA step. The modified data will be written back to the house_imputed dataset. */
run;

/* Check for missing values in the continuous variables */
proc means data=house_imputed n nmiss;
    var price sqft_living sqft_lot sqft_above sqft_basement lat long sqft_living15 sqft_lot15;
run;


/* ------------------------- */
/* Treatment of outliers initially detected in Assignment 1 */
/* ------------------------- */

/* Identify and display the observation with sqft_lot = 533610 in house_imputed dataset */
proc print data=house_imputed; 
    where sqft_lot = 533610;
run;

/* Compute the mean (average) values for the variables sqft_lot and sqft_lot15 in the house_imputed dataset */
proc means data=house_imputed mean;
    /* Specify the two variables of interest */
    var sqft_lot;
    var sqft_lot15;
    
    /* Output the computed mean values to a new dataset called average_ratios */
    /* The mean values for sqft_lot and sqft_lot15 are saved as mean_sqft_lot and mean_sqft_lot15, respectively */
    output out=average_ratios mean=mean_sqft_lot mean_sqft_lot15;
run;

/* Calculate the average ratio of sqft_lot to sqft_lot15 using the mean values computed in the previous step */
data ratios;
    /* Read the average_ratios dataset containing the mean values */
    set average_ratios;
    
    /* Compute the average ratio by dividing the mean of sqft_lot by the mean of sqft_lot15 */
    avg_ratio = mean_sqft_lot / mean_sqft_lot15;
run;

/* Display the computed average ratio in the ratios dataset */
proc print data=ratios; 
run;

/* Impute the sqft_lot for the specific observation based on its sqft_lot15 value and the computed avg_ratio */
data house_imputed;
    set house_imputed;
    
    /* If the sqft_lot is the identified outlier value (533610), then compute the imputed value */
    if sqft_lot = 533610 then sqft_lot = sqft_lot15 * 1.18023;
run;

/* Display the observation where the original sqft_lot was the identified outlier value (533610) */
proc print data=house_imputed; 
    where sqft_lot15 = 216057; /* Using the sqft_lot15 value to identify the specific observation */
run;

/* Given the revised observation and considering the features of the house, It's still indeed unusual for a ... */
/*... property with such a large lot size to have such a small living space. */
/* Remove the observation with sqft_lot15 = 216057 from the house_imputed dataset */
data house_imputed;
    set house_imputed;

    /* Exclude the observation with sqft_lot15 = 216057 */
    if sqft_lot15 ne 216057;
run;

/* Display the observation with sqft_lot15 = 216057 to verify its removal */
proc print data=house_imputed; 
    where sqft_lot15 = 216057;
run;


/* ------------------------- */
/* EXPLORATORY DATA ANALYSIS */
/* ------------------------- */

*Printing the Metadata for the house_imputed to once again identify the data types of each attributes;
proc contents data = house_imputed;
run;

/* Descriptive Statistics */
proc means data=house_imputed mean median mode std var min max;
run;

/* Checking for missing values */
proc means data=house_imputed nmiss;
run;


/* ------------------------- */
/* Visualization */
/* ------------------------- */

/* ORDINAL and DUMMY VARIABLES */
/* Create a subset of the original dataset with only the specified categorical and ordinal variables */
data subset_cats;
    set house_imputed(keep = waterfront renovation view condition grade bedrooms bathrooms floors);
    /* Convert the numeric variables to character to treat them as categorical */
    waterfront_c = put(waterfront, 1.);
    renovation_c = put(renovation, 1.);
    view_c = put(view, 1.);
    condition_c = put(condition, 1.);
    grade_c = put(grade, 1.);
run;

/* Define a macro to generate bar plots for a list of categorical variables */
%macro plotBars(data, varlist);

    /* Count the number of variables in the provided list */
    %let numVars = %sysfunc(countw(&varlist));
    
    /* Loop through each variable in the list */
    %do i = 1 %to &numVars;
        /* Extract the current variable name */
        %let currentVar = %scan(&varlist, &i);
        
        /* Generate a bar plot for the current variable */
        proc sgplot data=&data;
            vbar &currentVar / datalabel;
            title "Distribution of &currentVar";
        run;
        
    %end; /* End of loop */

%mend; /* End of macro definition */

/* Call the macro with the dataset name 'subset_cats' and the list of ordinal and dummy variables */
%plotBars(subset_cats, waterfront renovation view condition grade bedrooms bathrooms floors);


/*CONTINUOUS VARIABLES */
/* Create a subset of the original dataset with only the specified continuous variables */
data subset;
    set house_imputed(keep = price sqft_living sqft_lot sqft_above sqft_basement 
                          sqft_living15 sqft_lot15 lat long yr_built year_of_sale);
run;

/* Define a macro to generate histograms for a list of variables */
%macro plotHistograms(data, varlist);

    /* Count the number of variables in the provided list */
    %let numVars = %sysfunc(countw(&varlist));
    
    /* Loop through each variable in the list */
    %do i = 1 %to &numVars;
        /* Extract the current variable name */
        %let currentVar = %scan(&varlist, &i);
        
        /* Generate a histogram for the current variable */
        proc sgplot data=&data;
            histogram &currentVar;
            title "Distribution of &currentVar";
        run;
        
    %end; /* End of loop */

%mend; /* End of macro definition */

/* Call the macro with the dataset name 'subset' and the list of numeric variables */
%plotHistograms(subset, price sqft_living sqft_lot sqft_above sqft_basement 
                          sqft_living15 sqft_lot15 lat long yr_built year_of_sale);


/* ------------------------- */
/* Potential observations between attributes */
/* ------------------------- */

/* Price vs House Age */
/* Scatter plot with regression line for Price vs. Year Built*/
proc sgplot data=house_imputed;
    scatter x=yr_built y=price;
    reg x=yr_built y=price / degree=1 lineattrs=(color=red); /* This adds a linear regression line in red color */
    title "Scatterplot of Year Built vs. Price with Regression Line";
run;


/* Price vs Neighbourhood Living Space */
/* Scatter plot with regression line for Price vs. Neighbourhood Living Space */
proc sgplot data=house_imputed;
    scatter x=sqft_living15 y=price;
    reg x=sqft_living15 y=price / degree=1 lineattrs=(color=red); /* This adds a linear regression line in red color */
    title "Scatterplot of Sqft Living of 15 Nearest Neighbors vs. Price with Regression Line";
run;


/* Price vs Bedrooms and Bathrooms */
/* Scatter plot with regression line for Price vs. Bedrooms */
proc sgplot data=house_imputed;
    scatter y=price x=bedrooms;
    reg y=price x=bedrooms / lineattrs=(color=red); /* Adds a regression line */
    xaxis label="Number of Bedrooms";
    yaxis label="Price";
    title "Scatterplot of Price vs. Bedrooms with Regression Line";
run;

/* Scatter plot with regression line for Price vs. Bathrooms */
proc sgplot data=house_imputed;
    scatter y=price x=bathrooms;
    reg y=price x=bathrooms / lineattrs=(color=red); /* Adds a regression line */
    xaxis label="Number of Bathrooms";
    yaxis label="Price";
    title "Scatterplot of Price vs. Bathrooms with Regression Line";
run;


/*Price vs Living and Lot Utilization */
/* Scatterplot of sqft_living vs. Price with Regression Line */
proc sgplot data=house_imputed;
    scatter x=sqft_living y=price;
    reg x=sqft_living y=price / degree=1 lineattrs=(color=red); /* Add a linear regression line in red color */
    title "Scatterplot of Sqft Living vs. Price with Regression Line";
run;

/* Scatterplot of sqft_lot vs. Price with Regression Line */
proc sgplot data=house_imputed;
    scatter x=sqft_lot y=price;
    reg x=sqft_lot y=price / degree=1 lineattrs=(color=red); /* Add a linear regression line in red color */
    title "Scatterplot of Sqft Lot vs. Price with Regression Line";
run;


/*Price vs View */
/* SGPLOT Procedure to Visualize Data Graphically */
proc sgplot data=house_imputed;  /* Use the 'house_imputed' dataset for the plot */

    /* Generate a vertical boxplot of 'price' across different categories of 'view' */
    vbox price / category=view;  

    /* Set the title for the plot */
    title "Boxplot of Price Across Different View Ratings"; 

/* End the SGPLOT procedure */
run;


/* ------------------------- */
/* CORRELATION ANALYSIS */
/* ------------------------- */

/* Compute correlations for continuous and ordinal variables */
proc corr data=house_imputed out=corr_out noprob;
    var bathrooms bedrooms floors lat long price sqft_above sqft_basement sqft_living 
    sqft_living15 sqft_lot sqft_lot15 yr_built year_of_sale view condition grade waterfront renovation;
run;


/* Sort the corr_out dataset based on _NAME_ and _TYPE_ 
   This is a necessary step before using PROC TRANSPOSE on data with BY groups. */
proc sort data=corr_out; 
    by _NAME_ _TYPE_; 
run;

/* Transpose the data from a wide format to a long format. 
   In the original data, each row represented a variable's correlation with every other variable in columns.
   After transpose, each row will represent a correlation between two specific variables.
   
   The name= option specifies a new name for the column that holds the names of the original variables.
   The rename= option changes the default column name 'col1' to 'Value' which holds the correlation values. */
proc transpose data=corr_out out=long_format_correlations (rename=(col1=Value))
                name=Variable;  
    by _NAME_ _TYPE_;
    /* List of variables for which correlations were computed */
    var bathrooms bedrooms floors lat long price sqft_above sqft_basement sqft_living
    sqft_living15 sqft_lot sqft_lot15 yr_built year_of_sale view condition grade waterfront renovation;
run;

/* Filter the correlations for specific pairs of interest */
proc sql;
    create table filtered_correlations as
    select 
        _NAME_ as Var1,  /* Variable name from the original data */
        Variable as Var2,  /* Transposed variable name from the original data */
        Value as Correlation  /* Correlation value between Var1 and Var2 */
    from 
        long_format_correlations
    where upcase(_TYPE_) = 'CORR'  /* Only pick correlation values, not N or other types */
    and ((_NAME_ = 'price' and Variable in ('yr_built', 'sqft_living15', 'bedrooms', 'bathrooms', 'view', 'sqft_lot', 'sqft_living'))
         or (Variable = 'price' and _NAME_ in ('yr_built', 'sqft_living15', 'bedrooms', 'bathrooms', 'view', 'sqft_lot', 'sqft_living')))
    and _NAME_ < Variable; /* This will avoid the duplicates */
quit;

/* Print the table of filtered correlations. 
   This will display the correlations in a table format in the SAS output window. */
proc print data=filtered_correlations;
    title "Filtered Correlations for Specific Pairs";
run;


/* ------------------------- */
/* Feature Creation */
/* ------------------------- */


/* ------------------------- */
/* Hypothesis 1: House Age and Price */
/* ------------------------- */

/* house_age VARIABLE */

data house_features;
    set house_imputed;
    /* Calculate the age of the house at the time of sale */
    /* This will be used to test if older houses tend to have lower prices */
    house_age = year_of_sale - yr_built;
run;

/* Summary Statistics */

proc means data=house_features mean median min max std;
    var house_age;
run;

/* Notice that the minimum value is -1 which is illogical given the context of the age of the house */

/* Identify which records have a negative house_age */
proc print data=house_features; 
    where house_age < 0;
    var yr_built year_of_sale house_age;
    title "Houses with Negative Age";
run;

/* Since there is no way to determine whether the yr_built or year_of_sale ...*/
/*...is the incorrect value, these two records will be removed */
data house_features;
    set house_features;
    if house_age >= 0;
run;

/* Confirm Removal */
proc means data=house_features;
    var house_age;
run;

/* Distribution */
proc sgplot data=house_features;
    histogram house_age;
    title "Distribution of House Age";
run;

*Compute quartiles for the 'house_age' variable;
PROC UNIVARIATE DATA=house_features;
    VAR house_age;
    OUTPUT OUT=OutliersHouseAge (RENAME=(house_age=OriginalHouseAge))
    Q1=Q1_house_age Q3=Q3_house_age;
RUN;

*Detect and store outliers for 'house_age' in the OutliersListHouseAge dataset;
DATA OutliersListHouseAge (keep=ObsNum OutlierValue);
    SET house_features;
    IF _N_ = 1 THEN SET OutliersHouseAge;

    IQR = Q3_house_age - Q1_house_age;
    LowerBound = Q1_house_age - 1.5 * IQR;
    UpperBound = Q3_house_age + 1.5 * IQR;

    /* Check if the house_age value is an outlier */
    IF house_age < LowerBound OR house_age > UpperBound THEN DO;
        ObsNum = _N_;
        OutlierValue = house_age;
        OUTPUT;
    END;

    DROP IQR LowerBound UpperBound Q1_house_age Q3_house_age;
RUN;

*Print detected outliers;
PROC PRINT DATA=OutliersListHouseAge;
RUN;

*Visualize 'house_age' distribution with a boxplot;
PROC SGPLOT DATA=house_features;
    VBOX house_age;
RUN;



/* ------------------------- */
/* Hypothesis 2: Larger Neighborhood Living Spaces Indicate Pricier Areas */
/* ------------------------- */

/* No additional feature creation required for this hypothesis */
/* The variable 'sqft_living15' in 'house_features' already captures the average living space of the 15 nearest neighbors */
/* It will be used to test if houses in areas with larger average living spaces tend to have higher prices */


/* ------------------------- */
/* Hypothesis 3: Bedroom-Bathroom Ratio */
/* ------------------------- */

/* bed_bath_ratio VARIABLE */

data house_features;
    set house_features;
    /* Calculate the ratio of bedrooms to bathrooms */
    /* This will be used to test if houses with more bedrooms per bathroom tend to be priced lower */
    bed_bath_ratio = bedrooms / bathrooms;
run;

/* Summary Statistics */
proc means data=house_features mean median min max std;
    var bed_bath_ratio;
run;

/* Distribution */
proc sgplot data=house_features;
    histogram bed_bath_ratio;
    title "Distribution of Bedroom-Bathroom Ratio";
run;

*Compute quartiles for the 'bed_bath_ratio' variable;
PROC UNIVARIATE DATA=house_features;
    VAR bed_bath_ratio;
    OUTPUT OUT=OutliersBedBathRatio (RENAME=(bed_bath_ratio=OriginalBedBathRatio))
    Q1=Q1_bed_bath_ratio Q3=Q3_bed_bath_ratio;
RUN;

*Detect and store outliers for 'bed_bath_ratio' in the OutliersListBedBathRatio dataset;
DATA OutliersListBedBathRatio (keep=ObsNum OutlierValue);
    SET house_features;
    IF _N_ = 1 THEN SET OutliersBedBathRatio;

    IQR = Q3_bed_bath_ratio - Q1_bed_bath_ratio;
    LowerBound = Q1_bed_bath_ratio - 1.5 * IQR;
    UpperBound = Q3_bed_bath_ratio + 1.5 * IQR;

    /* Check if the bed_bath_ratio value is an outlier */
    IF bed_bath_ratio < LowerBound OR bed_bath_ratio > UpperBound THEN DO;
        ObsNum = _N_;
        OutlierValue = bed_bath_ratio;
        OUTPUT;
    END;

    DROP IQR LowerBound UpperBound Q1_bed_bath_ratio Q3_bed_bath_ratio;
RUN;

*Print detected outliers;
PROC PRINT DATA=OutliersListBedBathRatio;
RUN;

*Visualize 'bed_bath_ratio' distribution with a boxplot;
PROC SGPLOT DATA=house_features;
    VBOX bed_bath_ratio;
RUN;

/* Add ObsNum to house_features */
data house_features;
    set house_features;
    ObsNum = _N_;
run;

/* Merge OutliersListBedBathRatio with house_features */
data OutliersWithSqft;
    merge house_features(rename=(bed_bath_ratio=OriginalBedBathRatio)) OutliersListBedBathRatio;
    by ObsNum;
run;

/* Scatterplot of OutlierValue vs. sqft_living */
proc sgplot data=OutliersWithSqft;
    scatter x=sqft_living y=OutlierValue;
    title "Scatterplot of Outliers in Bedroom-Bathroom Ratio vs. Sqft Living";
    xaxis label="Square Foot Living";
    yaxis label="Outlier Bedroom-Bathroom Ratio";
run;

/* Drop the ObsNum column from house_features dataset */
data house_features;
    set house_features(drop=ObsNum);
run;


/* ------------------------- */
/* Hypothesis 4: Lot Utilization */
/* ------------------------- */

/* lot_utilization VARIABLE */
data house_features;
    set house_features;
    /* Calculate the proportion of the lot that's occupied by living space */
    /* This will be used to test if houses that utilize more of their lot for living space tend to have a higher price */
    lot_utilization = sqft_living / sqft_lot;
run;

/* Summary Statistics */
proc means data=house_features mean median min max std;
    var lot_utilization;
run;

/* Distribution */
proc sgplot data=house_features;
    histogram lot_utilization;
    title "Distribution of Lot Utilization";
run;

*Compute quartiles for the 'lot_utilization' variable;
PROC UNIVARIATE DATA=house_features;
    VAR lot_utilization;
    OUTPUT OUT=OutliersLotUtilization (RENAME=(lot_utilization=OriginalLotUtilization))
    Q1=Q1_lot_utilization Q3=Q3_lot_utilization;
RUN;

*Detect and store outliers for 'lot_utilization' in the OutliersListLotUtilization dataset;
DATA OutliersListLotUtilization (keep=ObsNum OutlierValue);
    SET house_features;
    IF _N_ = 1 THEN SET OutliersLotUtilization;

    IQR = Q3_lot_utilization - Q1_lot_utilization;
    LowerBound = Q1_lot_utilization - 1.5 * IQR;
    UpperBound = Q3_lot_utilization + 1.5 * IQR;

    /* Check if the lot_utilization value is an outlier */
    IF lot_utilization < LowerBound OR lot_utilization > UpperBound THEN DO;
        ObsNum = _N_;
        OutlierValue = lot_utilization;
        OUTPUT;
    END;

    DROP IQR LowerBound UpperBound Q1_lot_utilization Q3_lot_utilization;
RUN;

*Print detected outliers;
PROC PRINT DATA=OutliersListLotUtilization;
RUN;

*Visualize 'lot_utilization' distribution with a boxplot;
PROC SGPLOT DATA=house_features;
    VBOX lot_utilization;
RUN;

/* Filter observations where sqft_living is greater than sqft_lot and compute the difference */
data LivingGreaterLot;
    set house_features;
    where sqft_living > sqft_lot;
    
    /* Compute the difference between sqft_living and sqft_lot */
    living_lot_diff = sqft_living - sqft_lot;
run;

/* Display filtered observations with the new difference column */
proc print data=LivingGreaterLot; 
run;

/* Filter out observations where sqft_living is greater than sqft_lot */
data house_filtered;
    set house_features;
    if sqft_living <= sqft_lot;
run;

/* Confirm that the observations have been removed */
proc sql;
    select count(*) as CountOfInvalidObservations
    from house_filtered
    where sqft_living > sqft_lot;
quit;

*Visualize 'lot_utilization' distribution with a boxplot once again;
PROC SGPLOT DATA=house_filtered;
    VBOX lot_utilization;
RUN;


/* ------------------------- */
/* Hypothesis 5: Rare Views Command Premium Prices */
/* ------------------------- */

/* No additional feature creation required for this hypothesis */
/* The variable 'view' in 'house_features' already captures the view of the respective house */
/* It will be used to test if houses with rare views tend to have higher prices */


/* ------------------------- */
/* Transformation */
/* ------------------------- */

/* Start by creating a copy of the original dataset to apply transformations */
data house_transformed;
    set house_filtered;
run;


/* ------------------------- */
/* sqft_lot */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram sqft_lot;
    title "Distribution of sqft_lot (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_sqft_lot = log(sqft_lot + 1);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_sqft_lot;
    title "Distribution of log_sqft_lot (After Transformation)";
run;


/* ------------------------- */
/* sqft_lot15 */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram sqft_lot15;
    title "Distribution of sqft_lot15 (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_sqft_lot15 = log(sqft_lot15 + 1);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_sqft_lot15;
    title "Distribution of log_sqft_lot15 (After Transformation)";
run;


/* ------------------------- */
/* price */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram price;
    title "Distribution of price (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_price = log(price);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_price;
    title "Distribution of log_price (After Transformation)";
run;


/* ------------------------- */
/* sqft_basement */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram sqft_basement;
    title "Distribution of sqft_basement (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_sqft_basement = log(sqft_basement + 1);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_sqft_basement;
    title "Distribution of log_sqft_basement (After Transformation)";
run;


/* The transformed variable will be retained in the dataset */
/* Reason being that even though a variable may not have a perfect distribution, it can still however be predictive
/* The key is to understand the chosen model's assumptions (which is not known as this point of time) and evaluate the variable's impact on the model's performance and interpretability. */

/* ------------------------- */
/* bed_bath_ratio */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram bed_bath_ratio;
    title "Distribution of bed_bath_ratio (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_bed_bath_ratio = log(bed_bath_ratio);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_bed_bath_ratio;
    title "Distribution of log_bed_bath_ratio (After Transformation)";
run;


/* ------------------------- */
/* sqft_above */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram sqft_above;
    title "Distribution of sqft_above (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_sqft_above = log(sqft_above);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_sqft_above;
    title "Distribution of log_sqft_above (After Transformation)";
run;


/* ------------------------- */
/* sqft_living */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram sqft_living;
    title "Distribution of sqft_living (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_sqft_living = log(sqft_living);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_sqft_living;
    title "Distribution of log_sqft_living (After Transformation)";
run;


/* ------------------------- */
/* lot_utilization */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram lot_utilization;
    title "Distribution of lot_utilization (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_lot_utilization = log(lot_utilization);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_lot_utilization;
    title "Distribution of log_lot_utilization (After Transformation)";
run;


/* ------------------------- */
/* sqft_living15 */
/* ------------------------- */

/* Before Transformation */
proc sgplot data=house_filtered;
    histogram sqft_living15;
    title "Distribution of sqft_living15 (Before Transformation)";
run;

/* Transformation */
data house_transformed;
    set house_transformed;
    log_sqft_living15 = log(sqft_living15);
run;

/* After Transformation */
proc sgplot data=house_transformed;
    histogram log_sqft_living15;
    title "Distribution of log_sqft_living15 (After Transformation)";
run;


/* ------------------------- */
/* Scaling */
/* ------------------------- */

/* Start by creating a copy of the original dataset to apply scaling */
data house_scaled;
    set house_transformed;
run;

/* Use PROC STANDARD to scale the variables to have a mean of 0 and standard deviation of 1 */
proc standard data=house_scaled out=house_scaled mean=0 std=1;
    var lat 
        long 
        log_bed_bath_ratio
        house_age 
        log_sqft_lot
        log_sqft_lot15
        log_sqft_above
        log_sqft_basement
        log_sqft_living
        log_sqft_living15
        log_lot_utilization;
run;

/* 
The PROC STANDARD procedure is used to scale (standardize) the variables. 
This ensures that the selected variables have a mean of 0 and a standard deviation of 1, 
making them comparable in terms of scale.
The output dataset "house_scaled" now contains the scaled versions of the specified variables.
*/

/* Check mean and standard deviation of the scaled variables */
proc means data=house_scaled mean std;
    var lat long log_bed_bath_ratio house_age 
        log_sqft_lot log_sqft_lot15 log_sqft_above log_sqft_basement
        log_sqft_living log_sqft_living15 log_lot_utilization;
run;


/* ------------------------- */
/* Hypothesis Testing */
/* ------------------------- */

/* Since tests used for the hypothesis testing is linear regression and ANOVA test, scaling is not necessary */
/* Nevertheless, when building a predictive model later on (especially one that's distance-based or uses regularization), one might consider scaling as a preprocessing step before modeling */
/* With that, the dataset used for the following hypothesis testing will be "house_transformed" instead of "house_scaled". 
/* The former dataset has no scaling applied to it while the latter dateset has scaling performed on it. */


/* ------------------------- */
/* Hypothesis 1: House Age and Price */
/* ------------------------- */

/* Linear Regression for House Age and Price */
/* Here is the modeling of the relationship between the price and the year the house was built */
/* The yr_built will demonstatre if older homes are priced differently than newer ones */

proc reg data=house_transformed;
    model log_price = house_age; /* price is the dependent variable and yr_built is the independent variable */
    title "Linear Regression: Log-Transformed Price vs. House Age";
run;


/* ------------------------- */
/* Hypothesis 2: Larger Neighborhood Living Spaces Indicate Pricier Areas */
/* ------------------------- */

/* Linear Regression for Neighborhood Living Space and Price */
/* Here is the modeling of the relationship between the price and the average living space of the 15 nearest neighbors (sqft_living15) */
/* This will help determine if houses in neighborhoods with larger average living spaces are pricier */

proc reg data=house_transformed;
    model log_price = log_sqft_living15; /* price is the dependent variable and sqft_living15 is the independent variable */
    title "Linear Regression: Log-Transformed Price vs. Average Living Space of 15 Nearest Neighbors";
run;


/* ------------------------- */
/* Hypothesis 3: Bedroom-Bathroom Ratio */
/* ------------------------- */

/* Linear Regression for Bedroom-Bathroom Ratio and Price */
/* Here is the modeling of the relationship between the price and the ratio of bedrooms to bathrooms (bed_bath_ratio) */
/* This will test if homes with more bedrooms per bathroom are priced lower */

proc reg data=house_transformed;
    model log_price = log_bed_bath_ratio; /* price is the dependent variable and log_bed_bath_ratio is the independent variable */
    title "Linear Regression: Log- Transformed Price vs. Log-Transformed Bedroom-Bathroom Ratio";
run;


/* ------------------------- */
/* Hypothesis 4: Lot Utilization*/
/* ------------------------- */

/* Linear Regression for Lot Utilization and Price */
/* Here is the modeling of the relationship between the price and lot utilization (ratio of living space to lot size) */
/* This tests if houses that utilize a higher proportion of their lot for living space tend to be pricier */

proc reg data=house_transformed;
    model log_price = log_lot_utilization; /* price is the dependent variable and log_lot_utilization is the independent variable */
    title "Linear Regression: Log-Transformed Price vs. Log Transformed Lot Utilization";
run;


/* ------------------------- */
/* Hypothesis 5: Rare Views Command Premium Prices*/
/* ------------------------- */

/* Creating dummy variables for 'view' */
/* Since 'view' is a categorical variable with multiple categories, it should then be converted to multiple binary (0 or 1) dummy variables */
/* Each dummy variable represents one category of the 'view' variable */

data house_transformed_with_dummies;
    set house_transformed;
    if view = 0 then view_0 = 1; else view_0 = 0; /* Dummy for view rating 0 */
    if view = 1 then view_1 = 1; else view_1 = 0; /* Dummy for view rating 1 */
    if view = 2 then view_2 = 1; else view_2 = 0; /* Dummy for view rating 2 */
    if view = 3 then view_3 = 1; else view_3 = 0; /* Dummy for view rating 3 */
    if view = 4 then view_4 = 1; else view_4 = 0; /* Dummy for view rating 4 */
run;

/* ANOVA for Price and View Rating */
/* The ANOVA test is used to test if there's a significant difference in the house prices across different view ratings */
/* This will help determine if rare views indeed command premium prices */

proc glm data=house_transformed_with_dummies;
    class view; /* 'view' is treated as a categorical variable */
    model log_price = view; /* log-transformed price is the dependent variable and 'view' dummies are the independent variables */
    title "ANOVA: Log-Transformed Price vs. View Rating";
run;
