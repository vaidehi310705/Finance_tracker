from rest_framework import serializers
from .models import Expense, Income, Transaction
from .models import SavingGoal


class ExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Expense
        fields = ['item_description', 'amount', 'date', 'category']

class IncomeSerializer(serializers.ModelSerializer):
    class Meta:
        model = Income
        fields = '__all__'

class TransactionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Transaction
        fields = '__all__'
        
class PredictionSerializer(serializers.Serializer):
    item_description = serializers.CharField(max_length=255)
    amount = serializers.FloatField()
    date = serializers.DateField()
    item_description = serializers.CharField()


class SavingGoalSerializer(serializers.ModelSerializer):
    class Meta:
        model = SavingGoal
        fields = ['id', 'user', 'goal_name', 'target_amount', 'current_amount', 'deadline']
        read_only_fields =['id','user']
        read_only_fields = ['id', 'user']
