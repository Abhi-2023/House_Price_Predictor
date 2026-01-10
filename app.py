import pickle
from flask import Flask, render_template, jsonify, url_for, request
import numpy as np
import pandas as pd
import os

app = Flask(__name__)

# Load the model
model = pickle.load(open('house_pred.pkl', 'rb'))

@app.route('/')
def home():
    return render_template('home.html')

@app.route('/predict', methods=['POST'])
def predict_price():
    required_fields = ['MedInc', 'HouseAge', 'AveRooms', 'AveBedrooms', 'Population', 'AveOccup', 'Latitude', 'Longitude']
    try :
        data = []

        for field in required_fields:
            value = request.form.get(field)

            if value is None or value.strip() == "":
                return render_template(
                    'home.html',
                    error=f"Please fill in all fields. Missing: {field}"
                )

            data.append(float(value))
            data = np.array(data, dtype=float).reshape(1,-1)
        # Load the scaler zip
        scaler = pickle.load(open('scaler.pkl', 'rb'))
        # Transform the data
        scaled_data = scaler.transform(data)
        # Make the prediction
        predicted_price = model.predict(scaled_data)[0]
        
        return render_template('home.html', prediction=predicted_price)
    
    except ValueError:
        return render_template(
            'home.html',
            error="Please enter valid numeric values only."
        )
    except Exception as e:
        return render_template(
            'home.html',
            error="Something went wrong. Please try again."
        )

    
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))  #  dynamic port
    app.run(host="localhost", port=port)