# Capstone Project: Forecasting Food Vendor Sales

This capstone project presents the development and scaling of a deep learning-based time series forecasting model. The project simulates a real-world scenario in which millions of food vendor sales records must be processed efficiently to generate accurate predictions. The structure and complexity of the dataset are modeled after the Favorita Grocery Sales dataset.

## Objective

The primary objective is to create a scalable machine learning solution that forecasts daily food vendor sales using historical data. The solution demonstrates the application of batch processing, deep learning techniques, and pipeline optimization to handle large volumes of time series data.

## Project Files

- `Capstone_Steps_7_and_8_Complete.ipynb`: Consolidated notebook containing the experimentation phase and scalable prototype implementation.
- `Favorita_train.csv`: Synthetic dataset containing 2 million rows of time-series sales data.
- `README.md`: Project documentation and methodology.

## Tools and Libraries

- Python 3.11
- Dask
- Pandas and NumPy
- TensorFlow and Keras
- tf.data API
- Matplotlib
- Google Colab environment

## Step 7: Experimentation and Model Training

In Step 7, the focus was on developing an initial forecasting model using a sample dataset. Key tasks included:

- Building an LSTM-based recurrent neural network for time series forecasting.
- Aggregating historical daily sales into structured input sequences.
- Preparing train/validation datasets.
- Conducting model training and performance evaluation using Mean Squared Error.
- Selecting LSTM due to its proven performance on sequential time series data.

This step resulted in a functional prototype capable of forecasting food vendor sales using a simplified dataset.

## Step 8: Scaling the Prototype

In Step 8, the model and pipeline were adapted to handle a larger, production-level dataset containing over 2 million rows.

Enhancements included:

- Using Dask to efficiently ingest and manipulate large CSV files in memory-constrained environments.
- Implementing a TensorFlow `tf.data` pipeline to batch, shuffle, and prefetch data for optimal GPU/CPU performance.
- Training a two-layer LSTM model with rolling 30-day windows to predict future daily sales.
- Scaling batch size and applying memory-efficient training methods such as `.prefetch()` and `.cache()`.

The final model is capable of training on web-scale data while maintaining reliability and reproducibility.

## Model Summary

- Input: 30-day rolling window of daily unit sales
- Architecture: Two-layer LSTM network with 64 and 32 units, followed by a Dense output layer
- Loss Function: Mean Squared Error (MSE)
- Optimizer: Adam
- Batch Size: 128
- Epochs: 10

## Key Considerations

- Scalable data handling was achieved using Dask and TensorFlow’s data pipeline features.
- A balance was maintained between model complexity and training efficiency.
- The project simulates a real-world ML engineering workflow with scalability and resource constraints in mind.

## Repository Structure

