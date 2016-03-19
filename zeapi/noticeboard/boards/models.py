from __future__ import unicode_literals

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
    created = models.DateTimeField()
    file = models.FileField()
