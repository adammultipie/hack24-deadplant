from rest_framework import serializers
from rest_framework.fields import ListField, FloatField
from rest_framework.reverse import reverse

from boards import models

class NoticeBoardSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.NoticeBoard
        fields = ('name',)