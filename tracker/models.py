"""Models for tracking financial transactions: income, expenses, and goals."""

from django.db import models
from django.contrib.auth.models import User


class Transaction(models.Model):
    """Model representing a financial transaction, either income or expense."""
    TYPE_CHOICES = [('income', 'Income'), ('expense', 'Expense')]

    type = models.CharField(max_length=7, choices=TYPE_CHOICES)
    category = models.CharField(max_length=50)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField(auto_now_add=True)
    description = models.TextField(blank=True)

    def __str__(self):
        return f"{self.type} - {self.category} - {self.amount:.2f}"


class Expense(models.Model):
    """Model representing an expense entry."""
    item_description = models.CharField(max_length=255)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField()
    category = models.CharField(max_length=50)

    def __str__(self):
        return f"{self.item_description} - {self.category} - {self.amount:.2f} - {self.date}"


class Income(models.Model):
    """Model to store sources of income."""
    source = models.CharField(max_length=255)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date = models.DateField()

    def __str__(self):
        return f"Income from {self.source}: {self.amount:.2f}"


class SavingGoal(models.Model):
    """Model for user saving goals."""
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    goal_amount = models.DecimalField(max_digits=10, decimal_places=2)
    target_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Goal: {self.goal_amount:.2f} by {self.target_date}"
