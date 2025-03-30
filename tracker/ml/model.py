import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.feature_extraction.text import TfidfVectorizer
import os
from django.conf import settings

class ExpenseCategorizer:
    def __init__(self):
        model_path =  os.path.join(settings.BASE_DIR, "tracker/ml/model.joblib") 
            
        # load model if exist
        if os.path.exists(model_path):
            self.vectorizer, self.model = joblib.load(model_path)
            print("Model Loaded Successfully")
    
    #coversion from text to numerical feature    
    def train(self,data):
        self.vectorizer = TfidfVectorizer()
        X = self.vectorizer.fit_transform(data['Item'])
        y = data['Category']
        
        #train
        self.model = RandomForestClassifier(n_estimators=100,random_state = 42)
        self.model.fit(X,y)
        
        #save
        model_path = os.path.join(settings.BASE_DIR, "tracker/ml/model.joblib")
        joblib.dump((self.vectorizer, self.model), model_path)
        print("Model Saved")

        
    def predict(self, item_description):
        if not self.model or not self.vectorizer:
            self.vectorizer, self.model = joblib.load("tracker/ml/model.joblib")
        
        X_new = self.vectorizer.transform([item_description])
        predicted_category = self.model.predict(X_new)
        return self.model.predict(X_new)[0]
df = pd.read_csv(os.path.join(settings.BASE_DIR, "tracker/ml/myExpenses1.csv"))

df = pd.read_csv("tracker/ml/myExpenses1.csv")
Categorizer = ExpenseCategorizer()
Categorizer.train(df)

test_item = "Netflix Subscription"
predicted_category = Categorizer.predict(test_item)
print(f"Predicted Category for '{test_item}': {predicted_category}")

