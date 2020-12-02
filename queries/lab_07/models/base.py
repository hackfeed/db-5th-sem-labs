from db.db import db
import peewee as pw


class BaseModel(pw.Model):
    class Meta:
        database = db
