# -*- coding: utf-8 -*-
# Generated by Django 1.9.4 on 2016-03-19 14:44
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('boards', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='triggers',
            name='info',
        ),
        migrations.AddField(
            model_name='triggers',
            name='major',
            field=models.IntegerField(null=True),
        ),
        migrations.AddField(
            model_name='triggers',
            name='minor',
            field=models.IntegerField(null=True),
        ),
        migrations.AddField(
            model_name='triggers',
            name='uuid',
            field=models.TextField(null=True),
        ),
    ]
