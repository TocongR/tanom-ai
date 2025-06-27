from rest_framework import serializers
from django.contrib.auth.models import User
from django.core.mail import send_mail
from django.conf import settings
import random
from django.contrib.auth.tokens import default_token_generator
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username','email','password')
        extra_kwargs = {
            'password': {'write_only':True},
            'email': {'validators': []},
        }

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError('Email is already in use')
        return value

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password'],
            is_active=False
        )

        otp = random.randint(100000, 999999)
        user.profile.otp = otp
        user.profile.save()

        send_mail(
            'Your verification code',
            f'Use this code to verify your account: {otp}',
            settings.DEFAULT_FROM_EMAIL,
            [user.email],
            fail_silently=False
        )

        return user

class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')

        try:
            user = User.objects.get(username=username)
        except User.DoesNotExist:
            raise serializers.ValidationError({'error':'User not found'})
        
        if not user.check_password(password):
            raise serializers.ValidationError({'error':'Incorrect password'})
        
        if not user.is_active:
            raise serializers.ValidationError({
                'error': 'Account not verified. Please enter your otp',
                'requires_otp': True,
                'username': user.username,
            })
        
        return super().validate(attrs)