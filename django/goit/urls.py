from django.contrib import admin
from django.urls import path
from django.http import HttpResponse

# Функція для Health Check
def health_check(request):
    return HttpResponse("OK")

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', health_check), # маршрут для проб
]