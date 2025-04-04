from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse

# Home view for the root URL
def home(request):
    return HttpResponse("Welcome to the Finance Tracker API!")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', home, name='home'),  # Root URL to show a welcome message
    path('api/', include('tracker.urls')),  # Include tracker app URLs
   
]
