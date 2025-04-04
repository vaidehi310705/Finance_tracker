import pandas as pd
from django.conf import settings
import os

def load_expenses(file_path):
    """Load monthly expenses from a CSV file."""
    df = os.path.join(settings.BASE_DIR, "tracker/ml/model.joblib")
    return df

def calculate_total_expenses(df):
    """Calculate the total monthly expenses."""
    return df['Amount'].sum()  # Make sure your CSV has an 'Amount' column

def suggest_savings_plan(df, total_income, savings_goal):
    """Suggest how the user can reach their savings goal."""
    total_expenses = calculate_total_expenses(df)
    current_savings = total_income - total_expenses
    amount_needed = savings_goal - current_savings

    if amount_needed <= 0:
        return f"✅ Great! You're already meeting your savings goal with a surplus of ₹{abs(amount_needed):,.2f}."

    # Suggest expense reductions
    suggestions = []
    category_expenses = df.groupby('Category')['Amount'].sum()

    for category, amount in category_expenses.items():
        reduction = round((amount / total_expenses) * amount_needed, 2)
        if reduction > 0:
            suggestions.append(f"💡 Reduce *{category}* expenses by ₹{reduction:,.2f}")

    return f"💰 To reach your savings goal, consider these adjustments:\n- " + "\n- ".join(suggestions)

# Example usage
if __name__ == "__main__":
    file_path = "expenses.csv"  # This should contain 'Category' and 'Amount' columns
    df = os.path.join(settings.BASE_DIR, "tracker/ml/model.joblib")

    total_income = float(input("Enter your monthly income: "))
    savings_goal = float(input("Enter your desired savings goal: "))

    result = suggest_savings_plan(df, total_income, savings_goal)
    print(result)
