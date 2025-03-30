from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ExpenseViewSet, IncomeViewSet, TransactionViewSet, PredictExpenseCategory, get_expenses, add_expense, spend_analysis
from .views import SavingGoalViewSet


router = DefaultRouter()
router.register(r'saving-goals', SavingGoalViewSet, basename='savinggoal')
router.register(r'expenses', ExpenseViewSet)
router.register(r'incomes', IncomeViewSet)
router.register(r'transactions', TransactionViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path("predict/", PredictExpenseCategory.as_view(), name="predict_expense"),
    path('api/spend-analysis/', spend_analysis, name='spend-analysis'),
    path('api/expenses/add/', add_expense, name='add_expense'),  # Change the path here
    path('api/expenses/', get_expenses, name='get_expenses'),
]
