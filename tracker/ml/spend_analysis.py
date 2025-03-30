import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
from sklearn.ensemble import IsolationForest

# Sample data loading (replace with your actual dataset)
data = {
    'amount': [50, 200, 20, 100, 300, 60, 120, 45],
    'merchant': ['Restaurant', 'Supermarket', 'Gym', 'Restaurant', 'Shopping', 'Transport', 'Supermarket', 'Transport'],
    'user_age': [30, 25, 30, 30, 35, 40, 22, 28],
    'category': ['food', 'groceries', 'health', 'food', 'shopping', 'transport', 'groceries', 'transport']
}

df = pd.DataFrame(data)

# Map categories to numbers
category_mapping = {'food': 0, 'groceries': 1, 'health': 2, 'shopping': 3, 'transport': 4}
df['category'] = df['category'].map(category_mapping)

# Features: Amount, Merchant, User Age
X = df[['amount', 'user_age']]
y = df['category']

# Train-test split for categorization model
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Initialize Random Forest model for categorization
model = RandomForestClassifier(n_estimators=100)

# Train the model
model.fit(X_train, y_train)

# Predict categories on test data
y_pred = model.predict(X_test)
print("Categorization model evaluation:")
print(classification_report(y_test, y_pred))

# Spending Analysis: Budget vs Actual Spending
user_budget = {'food': 150, 'groceries': 200, 'health': 100, 'shopping': 250, 'transport': 120}
category_spending = {'food': 160, 'groceries': 180, 'health': 50, 'shopping': 300, 'transport': 100}

def send_budget_alert(category, actual_spending, budget):
    if actual_spending > budget:
        print(f"Alert: You have exceeded your budget for {category}. You spent ${actual_spending - budget} over budget!")

for category, budget in user_budget.items():
    send_budget_alert(category, category_spending.get(category, 0), budget)

# Anomaly Detection for Unusual Spending
anomaly_model = IsolationForest(contamination=0.1)
spending_data = df[['amount', 'user_age']]
anomaly_model.fit(spending_data)

df['anomaly'] = anomaly_model.predict(spending_data)

anomalies = df[df['anomaly'] == -1]

if not anomalies.empty:
    print("\nUnusual transactions detected!")
    print(anomalies[['amount', 'merchant', 'user_age']])



