# -*- coding: utf-8 -*-
# Generated by Django 1.9.4 on 2016-03-19 17:13
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('boards', '0002_auto_20160319_1444'),
    ]

    operations = [
        migrations.AddField(
            model_name='post',
            name='board',
            field=models.ForeignKey(default='', on_delete=django.db.models.deletion.CASCADE, to='boards.NoticeBoard'),
            preserve_default=False,
        ),
    ]