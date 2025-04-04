import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
def analyze_budget(expenses_df):
    """
    AI-powered budget analysis using K-Means clustering.

    Args:
    expenses_df (pd.DataFrame): DataFrame containing expense data with columns ['Category', 'Amount'].

    Returns:
    dict: Clustered budget insights.
    """

    # Preprocessing
    expenses_df = expenses_df.groupby('Category').sum().reset_index()
    scaler = StandardScaler()
    expenses_df['Scaled_Amount'] = scaler.fit_transform(expenses_df[['Amount']])

    # Applying K-Means clustering
    kmeans = KMeans(n_clusters=3, random_state=42, n_init=10)
    expenses_df['Cluster'] = kmeans.fit_predict(expenses_df[['Scaled_Amount']])

    # Categorizing clusters
    cluster_map = {}
    cluster_centers = kmeans.cluster_centers_.flatten()
    sorted_clusters = np.argsort(cluster_centers)
    cluster_map[sorted_clusters[0]] = 'Low Spending'
    cluster_map[sorted_clusters[1]] = 'Moderate Spending'
    cluster_map[sorted_clusters[2]] = 'High Spending'

    expenses_df['Spending Category'] = expenses_df['Cluster'].map(cluster_map)

    # Returning insights
    insights = expenses_df[['Category', 'Amount', 'Spending Category']].to_dict(orient='records')
    return insights  # ✅ Fixed missing return statement

# Example Usage
if __name__ == "__main__":
    df = pd.DataFrame({
        'Category': ['Food', 'Transport', 'Rent', 'Entertainment', 'Utilities', 'Shopping'],
        'Amount': [200, 100, 1000, 150, 300, 400]
    })
    
    insights = analyze_budget(df)
    print(insights)
