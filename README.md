#  Capstone Project: Forecasting Food Vendor Sales at Amusement Parks

**Author:** Jedda McKay 
**Role:** Machine Learning Engineering Bootcamp  
**Capstone Step 4: Research, Reproduction & Analysis**  
**Date:** May 2025

---

##  Project Overview

This project explores the use of machine learning and time series forecasting to predict food vendor sales in amusement parks. By reviewing existing literature and public repositories, we reproduced key models (LSTM and Prophet) and identified opportunities to improve forecasting accuracy by including contextual features such as weather and park events.

---

##  Research Summary

| Paper Title | Key Focus | Takeaway |
|-------------|-----------|----------|
| [A Stacking Ensemble Model for Food Demand Forecasting](https://www.sciencedirect.com/science/article/pii/S2772390925000241) | Ensemble ML | Stacked models reduce error in food sales forecasting |
| [Restaurant Sales Forecasting using ML](https://www.mdpi.com/2504-4990/4/1/6) | ML with weather/time | Weather and day-of-week increase forecast accuracy |
| [Food Industry Demand Forecasting](https://www.researchgate.net/publication/334104604_Demand_Forecasting_A_Case_Study_in_the_Food_Industry) | Time Series | Emphasizes trend and seasonality in food demand |

---

## Reproduced Models

### 1. LSTM (Reproduced from GitHub)
- File: `/notebooks/lstm_reproduction.ipynb`
- Source: [Erdos1729/food-demand-forecasting](https://github.com/Erdos1729/food-demand-forecasting)
- Accuracy: ~85%, RMSE: 0.321

### 2. Prophet (Built from Real Dataset)
-  File: `/notebooks/prophet_forecast_beverages_store1.ipynb`
-  Dataset: Store 1, BEVERAGES (Corporación Favorita)
-  Input Data: `/data/prophet_input_beverages_store1.csv`
-  Forecast Horizon: 90 days

#### Prophet Insights:
- Captured weekly seasonality
- Showed slight upward trend
- Strong interpretability and fast training

---

## Insights & Next Steps

### Key Learnings:
- Public ML models provide a solid base, but context (e.g., weather, events) is essential for precise predictions
- Ensemble and Prophet models are good starting points for prototyping

### Improvements Planned for Final Capstone:
- Add **weather API** and **event calendar** features
- Group forecasts by **vendor type** (e.g., snacks, drinks)
- Compare LSTM, Prophet, and XGBoost for best performance

  ### Prophet Model Evaluation

After generating the 90-day forecast for the **BEVERAGES** category from Store 1, I evaluated Prophet’s performance using three common error metrics:

- **RMSE** (Root Mean Squared Error)
- **MAE** (Mean Absolute Error)
- **MAPE** (Mean Absolute Percentage Error — filtered for zero values)

> ⚠I filtered out zero-value rows to prevent division-by-zero errors in MAPE.

#### 🔢 Metrics

| Metric | Value     |
|--------|-----------|
| RMSE   | 408.87    |
| MAE    | 304.65    |
| MAPE   | 24.95     |

#### Interpretation

Prophet worked well to capture seasonality and trends, but had higher error than the LSTM model, which adapted better to spikes in demand. Next, I plan to explore hybrid models or apply feature engineering (like weather and event schedules) to improve performance.

---


- ## Notebooks

- [Prophet Forecast Notebook](notebooks/prophet_forecast_beverages_store1.ipynb)




##  Repository Structure

capstone-forecasting-food-sales/
│
├── README.md  

├── notebooks/
│   └── prophet_forecast_beverages_store1.ipynb 

├── research/
│   └── Research Review, Reproduction & Analysis.docx  

├── data/
│   └── prophet_input_beverages_store1.csv  

├── analysis/
│   └── results.summary.md

├── presentation/
   └── Forecasting Food Vendor Sales at Amusement Parks.pdf

##  Supporting Materials
- Dataset: [Kaggle - Corporación Favorita](https://www.kaggle.com/c/favorita-grocery-sales-forecasting)

---



