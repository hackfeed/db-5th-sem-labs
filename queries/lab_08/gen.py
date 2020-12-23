import random
import string
import json
from time import sleep
from datetime import datetime

neighbourhoods = [
    "Bijlmer-Centrum",
    "Bijlmer-Oost",
    "Bos en Lommer",
    "Buitenveldert - Zuidas",
    "Centrum-Oost",
    "Centrum-West",
    "De Aker - Nieuw Sloten",
    "De Baarsjes - Oud-West",
    "De Pijp - Rivierenbuurt",
    "Gaasperdam - Driemond",
    "Geuzenveld - Slotermeer",
    "IJburg - Zeeburgereiland",
    "Noord-Oost",
    "Noord-West",
    "Oostelijk Havengebied - Indische Buurt",
    "Osdorp",
    "Oud-Noord",
    "Oud-Oost",
    "Slotervaart",
    "Westerpark",
    "Zuid",
    "Watergraafsmeer"
]


def gen_new_neighbourhood():
    neighbourhood = "Bijlmer-Centrum"
    while neighbourhood in neighbourhoods:
        neighbourhood = "".join(random.choice(string.ascii_lowercase)
                                for _ in range(10)).capitalize()
    rating = round(random.uniform(0, 10), 2)
    chairman = "".join(random.choice(string.ascii_lowercase) for _ in range(5)).capitalize()
    chairman_phone = f"({int(random.uniform(100, 999))}) {int(random.uniform(100, 999))}-{int(random.uniform(1000, 9999))}"
    context = json.dumps({"houses": int(random.uniform(100, 999)),
                          "animals": int(random.uniform(100, 999))})

    neighbourhoods.append(neighbourhood)

    rec = {
        "neighbourhood": neighbourhood,
        "rating": rating,
        "chairman": chairman,
        "chairman_phone": chairman_phone,
        "context": context
    }

    return json.dumps(rec)


if __name__ == "__main__":
    file_id = 1
    table = "neighbourhoods"
    while True:
        time = datetime.now().strftime("%Y-%m-%d_%H:%M:%S")
        with open(f"{file_id}_{table}_{time}.json", "w") as file:
            file.write(gen_new_neighbourhood())
        file_id += 1
        sleep(20)
