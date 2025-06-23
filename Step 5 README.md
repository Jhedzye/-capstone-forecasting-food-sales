# Step 5: Data Cleaning, Wrangling, and Exploratory Analysis

This repository documents the data preparation work conducted in Step 5 of the Machine Learning Engineering Capstone project at UMass Global. The objective of this step is to ensure that the dataset is clean, consistent, and structured appropriately for forecasting model development in subsequent phases of the project.

## Project Context

The project focuses on forecasting daily beverage sales for Store 1 within an amusement park setting. Accurate forecasting is critical to support vendor decision-making around staffing, inventory management, and operational planning. The raw dataset consists of timestamped sales data prepared for input into time series models, including Prophet and LSTM.

This step involved a comprehensive data cleaning and wrangling process to improve data quality, enhance interpretability, and prepare the dataset for feature engineering.

## Objectives

- Identify and address missing values and data type inconsistencies
- Verify correct formatting of temporal data
- Detect and handle outliers using statistical techniques
- Perform preliminary exploratory data analysis (EDA)
- Export a cleaned dataset suitable for modeling

## Files and Structure

| File Name                                 | Description                                                     |
|------------------------------------------|-----------------------------------------------------------------|
| `prophet_input_beverages_store1-2.csv`   | Raw time series sales data for Store 1                          |
| `cleaned_beverage_sales_store1.csv`      | Cleaned dataset after preprocessing and validation              |
| `Step_5_Data_Cleaning_and_Wrangling.ipynb` | Jupyter Notebook documenting the full data cleaning workflow   |

All files are stored in CSV format and follow a standardized structure expected by time series forecasting models.

## Processing Summary

The following procedures were applied to the dataset:

- Ensured datetime parsing of the `ds` column
- Validated the structure and integrity of the time series
- Checked for and removed duplicate entries
- Identified and handled outliers using the IQR method
- Visualized key temporal trends to inform subsequent modeling

These steps were implemented using standard libraries such as pandas, matplotlib, and seaborn, and are fully documented in the accompanying notebook.

## Exploratory Analysis

Exploratory data analysis was conducted to understand the behavior of sales over time, including trend consistency, potential seasonality, and volatility. Visualization techniques were used to support hypothesis generation for feature engineering in Step 6.

## Completion Status

The following deliverables have been completed:

- Raw dataset uploaded and validated
- Data cleaning and wrangling completed with supporting documentation
- Cleaned dataset exported for modeling
- GitHub repository updated and made publicly accessible

## Author

**Jett**  
Machine Learning Engineering Candidate  
UMass Global

## License and Acknowledgements

This repository is maintained for academic and educational purposes as part of a capstone requirement. All data has been anonymized and does not reflect proprietary or confidential information. The work is original and intended to demonstrate applied machine learning engineering skills in the area of time series forecasting.

