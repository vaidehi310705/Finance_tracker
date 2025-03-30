import pandas as pd
import joblib
from sklearn.ensemble import RandomForestRegressor
import os
from django.conf import settings

class SavingGoals:
    def __init__(self):
        self.model_path = os.path.join(settings.BASE_DIR, "tracker/ml/saving_goals_model.joblib")
        self.model = None

        # Load model if it exists
        if os.path.exists(self.model_path):
            self.model = joblib.load(self.model_path)
            print("Saving Goals Model Loaded Successfully")

    def train(self, data, user_income):
        # Ensure column names are stripped of whitespace
        data.columns = data.columns.str.strip()

        # Check if 'Amount' column exists (Expenses)
        if "Amount" not in data.columns:
            raise KeyError("Dataset must contain an 'Amount' column representing expenses.")

        # Assign values
        data["income"] = user_income  # Set income from user input
        data["expenses"] = data["Amount"]  # Use 'Amount' as expenses
        data["savings_target"] = data["income"] - data["expenses"]  # Calculate savings

        # Define features (X) and target (y)
        X = data[["income", "expenses"]]
        y = data["savings_target"]

        # Train model
        self.model = RandomForestRegressor(n_estimators=100, random_state=42)
        self.model.fit(X, y)

        # Save model
        joblib.dump(self.model, self.model_path)
        print("Saving Goals Model Saved")

    def predict(self, income, expenses):
        # Load model if not already loaded
        if not self.model:
            if os.path.exists(self.model_path):
                self.model = joblib.load(self.model_path)
            else:
                return {"error": "Model not trained yet. Please train the model first."}
        X_new = pd.DataFrame([[income, expenses]], columns=['income', 'expenses'])
        predicted_savings = self.model.predict(X_new)[0]
        return {"predicted_savings": predicted_savings}
