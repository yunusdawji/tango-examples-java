from django.db import models

class Profile(models.Model):
    name = models.CharField(max_length = 50)
    id = models.IntegerField()
    catergory = models.CharField(max_length = 100)
    facebook_id = models.CharField(max_length = 20)

