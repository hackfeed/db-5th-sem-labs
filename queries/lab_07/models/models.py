import peewee as pw
from playhouse.postgres_ext import BinaryJSONField

from models.base import BaseModel


class Neighbourhoods(BaseModel):
    neighbourhood = pw.CharField(primary_key=True)
    rating = pw.DecimalField(max_digits=4, decimal_places=2)
    chairman = pw.CharField()
    chairman_phone = pw.CharField(max_length=15)
    context = BinaryJSONField()


class Listings(BaseModel):
    id = pw.IntegerField(primary_key=True)
    name = pw.CharField()
    host_id = pw.IntegerField()
    host_name = pw.CharField()
    neighbourhood = pw.CharField()
    latitude = pw.DecimalField(max_digits=16, decimal_places=14)
    longitude = pw.DecimalField(max_digits=16, decimal_places=14)
    room_type = pw.CharField()
    price = pw.DecimalField(max_digits=6, decimal_places=2, constraints=[pw.Check('price >=0')])
    minimum_nights = pw.IntegerField()
    number_of_reviews = pw.IntegerField()
    last_review = pw.DateField()
    reviews_per_month = pw.DecimalField(max_digits=5, decimal_places=2)
    calculated_host_listings_count = pw.IntegerField()
    availability_365 = pw.IntegerField()


class Reviews(BaseModel):
    listing_id = pw.ForeignKeyField(Listings, on_delete="cascade")
    id = pw.IntegerField(primary_key=True)
    date = pw.DateField()
    reviewer_id = pw.IntegerField()
    reviewer_name = pw.CharField()
    comments = pw.CharField()


class Calendar(BaseModel):
    listing_id = pw.ForeignKeyField(Listings, on_delete="cascade")
    date = pw.DateField()
    available = pw.BooleanField()
    price = pw.DecimalField(max_digits=6, decimal_places=2, constraints=[pw.Check('price >=0')])
