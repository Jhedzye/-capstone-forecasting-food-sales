from flask import Flask, request, jsonify
from api.inference import load_lstm_model, predict_sales

app = Flask(__name__)
model = load_lstm_model()

@app.route("/predict", methods=["POST"])
def predict():
    data = request.get_json()
    input_seq = data.get("sequence")

    if not input_seq or len(input_seq) != 30:
        return jsonify({"error": "Input must be a list of 30 numeric values."}), 400

    try:
        result = predict_sales(model, input_seq)
        return jsonify({"forecast": float(result)})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
