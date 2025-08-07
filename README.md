# LSTM Forecasting API

This project deploys an LSTM model for real-time food vendor sales forecasting.

## 🚀 API Endpoint

POST `/predict`

**Input**:
```json
{
  "sequence": [30-day list of sales]
}
```

**Output**:
```json
{
  "forecast": 102.67
}
```

## 🐳 Local Docker Instructions

```bash
docker build -t lstm-api .
docker run -p 8080:8080 lstm-api
```

## 🌐 Deploy to Render

1. Push repo to GitHub
2. Go to [Render.com](https://render.com/)
3. New → Web Service
4. Connect GitHub repo
5. Use `render.yaml` (auto-deploys)
