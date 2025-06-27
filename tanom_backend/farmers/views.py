from rest_framework.decorators import api_view
from .serializers import RegisterSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from django.contrib.auth.tokens import default_token_generator
from django.utils.http import urlsafe_base64_decode
from django.contrib.auth.models import User
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import CustomTokenObtainPairSerializer
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags
from django.conf import settings
import random

class CustomTokenObtainPairView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer

@api_view(['POST'])
def  register_view(request):
    serializer = RegisterSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        return Response({
            'message': "User created sucessfully",
            'username': user.username,
            'email': user.email
        }, status=status.HTTP_201_CREATED)
    
    error_messages = []

    for field_errors in serializer.errors.values():
        if isinstance(field_errors, list):
            error_messages.extend(field_errors)

    return Response({'error': error_messages[0] if error_messages else 'Unknown error'}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def logout_view(request):
    try:
        refresh_token = request.data['refresh']
        token = RefreshToken(refresh_token)
        token.blacklist()
        return Response({"message": "Logout successful"}, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def verify_otp(request):
    username = request.data.get('username')
    otp = request.data.get('otp')

    if not username or not otp:
        return Response({'error': 'Missing username or OTP'}, status=400)

    try:
        user = User.objects.get(username=username)
        profile = user.profile  
        
        if str(profile.otp) == str(otp):
            user.is_active = True
            user.save()
            return Response({'message': 'Account verified successfully'}, status=200)
        else:
            return Response({'error': 'Invalid OTP'}, status=400)

    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['POST'])
def resend_otp(request):
    username = request.data.get('username')

    if not username:
        return Response({'error': 'Username is required'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        user = User.objects.get(username=username)
        if user.is_active:
            return Response({'error': 'Account is already verified'}, status=status.HTTP_400_BAD_REQUEST)
        
        otp = random.randint(100000,999999)
        user.profile.otp = otp
        user.profile.save()

        html_message = render_to_string('emails/otp_verification.html', {
            'username': user.username,
            'otp': otp,
            'app_name': 'Tanom'
        })
        
        plain_message = strip_tags(html_message)

        send_mail(
            subject='Your Tanom Verification Code',
            message=plain_message,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[user.email],
            html_message=html_message,
            fail_silently=False
        )

        return Response({'message': 'OTP resent successfully'}, status=status.HTTP_200_OK)

    except User.DoesNotExist:
        return Response({'error': 'User not found'}, status=status.HTTP_404_NOT_FOUND)