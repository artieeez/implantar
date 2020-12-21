from django.shortcuts import render
from rest_framework.response import Response
from db_version.models import *
from rest_framework.views import APIView
from rest_framework import status


# Auth
from rest_framework.authentication import SessionAuthentication, TokenAuthentication
from rest_framework.permissions import IsAuthenticated, IsAdminUser, AllowAny


# Create your views here.
class DbVersionView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        try:
            instance = Version.objects.last()
        except:
            print("new db version")
            instance = Version.objects.create()
        return Response({'version': instance.number}, status=status.HTTP_200_OK)