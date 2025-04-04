from rest_framework import viewsets, status,permissions
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.db.models import Sum
from .models import Expense, Income, Transaction
from .serializers import ExpenseSerializer, IncomeSerializer, TransactionSerializer, PredictionSerializer
from .ml.model import ExpenseCategorizer
import json
from django.shortcuts import render
from django.http import JsonResponse 
from .models import SavingGoal
from .serializers import SavingGoalSerializer
from rest_framework.views import APIView
from rest_framework import status
# pylint: disable=no-member

# Expense ViewSet
class ExpenseViewSet(viewsets.ModelViewSet):
    serializer_class = ExpenseSerializer
    queryset = Expense.objects.all()

    def create(self, request, *args, **kwargs):
        print("Received Data:", request.data)  
        return super().create(request, *args, **kwargs)

# Income ViewSet
class IncomeViewSet(viewsets.ModelViewSet):
    queryset = Income.objects.all()
    serializer_class = IncomeSerializer
    permission_classes = [IsAuthenticated]

# Transaction ViewSet
class TransactionViewSet(viewsets.ModelViewSet):
    queryset = Transaction.objects.all()
    serializer_class = TransactionSerializer
    permission_classes = [IsAuthenticated]

# Expense Prediction API
class PredictExpenseCategory(APIView):
    def post(self, request):
        serializer = PredictionSerializer(data=request.data)
        if serializer.is_valid():
            try:
                item_description = serializer.validated_data['item_description']
                amount = serializer.validated_data['amount']
                date = serializer.validated_data['date']

                # Load ML model
                categorizer = ExpenseCategorizer()
                predicted_category = categorizer.predict(item_description)

                # Check if the expense already exists based on description, amount, and date
                existing_expense = Expense.objects.filter(
                    item_description=item_description,
                    amount=amount,
                    date=date
                ).first()

                # If not exists, save the expense
                if not existing_expense:
                    expense = Expense(
                        item_description=item_description,
                        amount=amount,
                        date=date,
                        category=predicted_category,
                    )
                    expense.save()

                return Response({"category": predicted_category}, status=status.HTTP_200_OK)
            except Exception as e:
                return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

# Add Expense (Manual Entry)
def add_expense(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            # Ensure proper extraction of data fields
            item_description = data.get("item_description")
            amount = data.get("amount")
            date = data.get("date")
            category = data.get("category")

            if not all([item_description, amount, date, category]):
                return JsonResponse({"error": "All fields are required."}, status=400)

            # Check if the expense already exists before saving
            existing_expense = Expense.objects.filter(
                item_description=item_description,
                amount=amount,
                date=date
            ).first()

            if existing_expense:
                return JsonResponse({"error": "This expense already exists."}, status=400)

            # Save new expense if it doesn't exist
            expense = Expense.objects.create(
                item_description=item_description,
                amount=amount,
                date=date,
                category=category
            )
            return JsonResponse({"message": "Expense added successfully."}, status=201)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)

# Get All Expenses
def get_expenses(request):
    try:
        expenses = Expense.objects.all().values("item_description", "amount", "date", "category")
        expenses_list = list(expenses)
        return JsonResponse(expenses_list, safe=False, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)

# Spending Analysis API
@api_view(['GET'])
def spend_analysis(request):
    try:
        data = Expense.objects.values('category').annotate(total_spent=Sum('amount'))
        return Response(data, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
class SavingGoalViewSet(viewsets.ModelViewSet):
    queryset = SavingGoal.objects.all()
    serializer_class = SavingGoalSerializer
    permission_classes = [IsAuthenticated]
    
class SavingGoalView(APIView):
    def post(self, request):
        # Your savings plan logic here (income, expenses, goal)
        income = request.data.get("income")
        expenses = request.data.get("expenses")
        goal = request.data.get("goal")

        try:
            income = float(income)
            expenses = float(expenses)
            goal = float(goal)
        except:
            return Response({"error": "Invalid input data."}, status=400)

        current_savings = income - expenses
        amount_needed = goal - current_savings

        if amount_needed <= 0:
            message = f"Great! You're already meeting your savings goal with a surplus of {abs(amount_needed)}."
        else:
            message = f"To reach your goal, try reducing some spending or increase income by ₹{amount_needed:.2f}."

        return Response({"message": message}, status=200)
