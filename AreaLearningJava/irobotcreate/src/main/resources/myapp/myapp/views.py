from rest_framework.parsers import JSONParser
from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import render
from myapp.models import *


class SignUp(APIView):
    
    parser_classes = (JSONParser,)
    
    def post(self, request, *args, **kwargs):
        temp = request.DATA  
        
        profiles = Profile.objects.filter()
                           
        return Response({'received data':temp['name']})

def my_view(request):
    # View code here...
    return render(request, 'test.html')