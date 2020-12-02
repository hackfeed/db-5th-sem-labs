import peewee as pw
from tabulate import tabulate

from db.db import db
from meta import menumsg, menudict
from models.models import Neighbourhoods, Listings, Reviews


def linq_to_object():
    return {
        "SELECT neighbourhood FROM neighbourhoods WHERE rating = 2.3":
        [
            ["neighbbourhood"],
            [[rec.neighbourhood] for rec in Neighbourhoods.select(
                Neighbourhoods.neighbourhood).where(Neighbourhoods.rating == 2.3)]
        ],
        "SELECT host_name, price FROM listings WHERE price < 80 ORDER BY price":
        [
            ["host_name", "price"],
            [[rec.host_name, rec.price] for rec in Listings.select(
                Listings.host_name, Listings.price).where(Listings.price < 80).order_by(Listings.price)]
        ],
        "SELECT AVG(price) AS avgprice, room_type FROM listings GROUP BY room_type":
        [
            ["avgprice"],
            [[rec.avgprice, rec.room_type] for rec in Listings.select(
                pw.fn.Avg(Listings.price).alias("avgprice"), Listings.room_type).group_by(Listings.room_type)]
        ],
        "SELECT COUNT(*) AS cpr FROM listings WHERE room_type = 'Private room'":
        [
            ["cpr"],
            [[rec.cpr] for rec in Listings.select(pw.fn.Count(Listings).alias(
                "cpr")).where(Listings.room_type == "Private room")]
        ],
        "SELECT name, price FROM listings WHERE number_of_reviews > 100 ORDER BY price":
        [
            ["name", "price"],
            [[rec.name, rec.price] for rec in Listings.select(Listings.name, Listings.price).where(
                Listings.number_of_reviews > 100).order_by(Listings.price)]
        ]
    }


def linq_to_json():
    return {
        "SELECT context->'houses' houses FROM neighbourhoods":
        [
            ["houses"],
            [[rec.houses] for rec in Neighbourhoods.select(
                Neighbourhoods.context["houses"].alias("houses"))]
        ],
        "UPDATE neighbourhoods SET context = context || '{\"houses\": 50}":
        Neighbourhoods.update(
            context={**Neighbourhoods.get(Neighbourhoods.chairman == 'Joseph').context, **{"animals": 100}}).execute,
    }


def linq_to_sql():
    def find_host_listings():
        return db.execute_sql(f"SELECT * FROM find_host_listings('David')")

    return {
        "SELECT neighbourhood FROM neighbourhoods":
        [
            ["neighbourhood"],
            [[rec.neighbourhood] for rec in Neighbourhoods.select(Neighbourhoods.neighbourhood)]
        ],
        "SELECT reviewer_name FROM reviews r JOIN listings l ON l.id = r.listing_id WHERE l.host_name = r.reviewer_name":
        [
            ["number_of_reviews"],
            [[rec.reviewer_name]
                for rec in Reviews.select(Reviews.reviewer_name).join(Listings).where(Listings.host_name == Reviews.reviewer_name)]
        ],
        "INSERT INTO neighbourhoods VALUES ('Moscow', 10, 'Sergey', 'cool', '{\"houses\": 10})":
        Neighbourhoods.insert(neighbourhood="Moscow", rating=10.0,
                              chairman="Sergey", chairman_phone="cool", context={"houses": 10}).execute,
        "UPDATE neighbourhoods SET rating = 10 WHERE chairman = 'Joseph'":
        Neighbourhoods.update(rating=10).where(Neighbourhoods.chairman == "Joseph").execute,
        "DELETE FROM neighbourhoods WHERE chairman = 'Sergey'":
        Neighbourhoods.delete().where(Neighbourhoods.chairman == "Sergey").execute,
        "SELECT * FROM find_host_listings('David')":
        find_host_listings
    }


def print_table(table):
    print(tabulate(table[1], headers=[desc for desc in table[0]], tablefmt="psql"))


if __name__ == "__main__":
    while (True):
        ltoo = linq_to_object()
        ltoj = linq_to_json()
        ltos = linq_to_sql()

        print(menumsg)
        opt = int(input("Input option: "))

        if not opt:
            break

        if opt in [1, 2, 3, 4, 5]:
            print_table(ltoo[menudict[opt]])
        elif opt == 6:
            print_table(ltoj[menudict[opt]])
        elif opt == 7:
            ltoj[menudict[opt]](db)
        elif opt in [8, 9]:
            print_table(ltos[menudict[opt]])
        else:
            ltos[menudict[opt]]
