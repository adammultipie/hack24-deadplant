from __future__ import unicode_literals
import os

from django.conf import settings
from django.db.models.signals import post_save, pre_save, post_init
from django.dispatch import receiver
from rest_framework.authtoken.models import Token
from django.db import models
from django.contrib.auth.models import User

from wand.image import Image
from wand.color import Color

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
    is_alert = models.BooleanField()
    created = models.DateTimeField(auto_now_add=True)
    title = models.TextField(null=True)
    board = models.ForeignKey(NoticeBoard)
    thumbnail = models.ImageField()
    text = models.TextField()
    file = models.FileField()

    def create_thumbnail(self):
        if self.file == '':
            return
        if self.file.name[-3:].lower() == 'gif':
            self.thumbnail = self.file
            self.save()
            return

        with Image(filename=self.file.path + '[0]') as img:
            width, height = img.size
            img.format = 'jpeg'
            img.alpha_channel=False
            img.background_color = Color('white')
            img.transform(resize='1000')
            # img.crop(width=1000, height=1000)
            filename = '{0}-thumb.jpg'.format(self.file.name[2:-4])
            fullpath = os.path.join(settings.MEDIA_ROOT, filename)
            self.thumbnail.name = filename
            img.save(filename=fullpath)
            self.save()
    class Meta:
        ordering = ['-is_alert', '-created']


@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_auth_token(sender, instance=None, created=False, **kwargs):
    if created:
        Token.objects.create(user=instance)

