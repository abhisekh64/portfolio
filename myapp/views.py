from django.shortcuts import render
from django.views import View

# Create your views here.


class Home(View):
    def get(self, request, *args, **kwargs):
        skills = {
            "Python": 90,
            "Django": 85,
            "MySQL": 85,
            "Django REST Framework": 80,
            "FastAPI": 90,
            "Git": 85,
            "Docker": 80,
            "CI/CD Pipelines": 80,
            "AWS": 80,
            "HTML": 90,
            "CSS": 85,
            "JavaScript": 80,
            "Bootstrap": 80,
            "Tailwind CSS": 80,
        }
        return render(request, "pages/home.html", {"skills": skills})
