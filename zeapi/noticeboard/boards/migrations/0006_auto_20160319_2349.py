# -*- coding: utf-8 -*-
# Generated by Django 1.9.4 on 2016-03-19 23:49
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('boards', '0005_auto_20160319_2055'),
    ]

    operations = [
        migrations.AddField(
            model_name='post',
            name='text',
            field=models.TextField(default=''),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='post',
            name='thumbnail',
            field=models.ImageField(upload_to=b''),
        ),
    ]
