import numpy as np
from tensorflow.keras.models import load_model

MODEL_PATH = "model/lstm_model.h5"

def load_lstm_model():
    return load_model(MODEL_PATH)

def predict_sales(model, input_sequence):
    sequence = np.array(input_sequence).reshape((1, 30, 1))
    prediction = model.predict(sequence)
    return prediction[0][0]
