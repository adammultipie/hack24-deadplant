from __future__ import unicode_literals
from django.conf import settings
from django.db.models.signals import post_save
from django.dispatch import receiver
from rest_framework.authtoken.models import Token

from django.db import models
from django.contrib.auth.models import User

from jsonfield import JSONField

class Triggers(models.Model):
    IBEACON = 0
    NFC = 1
    QR = 2

    TYPES = ((IBEACON,'iBeacon'), (NFC, 'NFC'), (QR, 'QR'))

    board = models.ForeignKey('NoticeBoard')
    type = models.IntegerField(default=IBEACON, choices=TYPES)
    uuid = models.TextField(null=True)
    major = models.IntegerField(null=True)
    minor = models.IntegerField(null=True)

class NoticeBoard(models.Model):
    name = models.TextField()

class NoticeBoardOwner(models.Model):
    board = models.ForeignKey(NoticeBoard)
    user = models.ForeignKey(User)

class Post(models.Model):
    creator = models.ForeignKey(User)
    created = models.DateTimeField(auto_now_add=True)
    title = models.TextField(null=True)
    board = models.ForeignKey(NoticeBoard)
    file = models.FileField()

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)
