from playhouse.db_url import connect
from playhouse.shortcuts import Cast
import peewee as pw

db = connect("postgresext://hackfeed:tCH@4b5H@localhost:5432/rk3")


class BaseModel(pw.Model):
    class Meta:
        database = db


class Employee(BaseModel):
    id = pw.PrimaryKeyField()
    fio = pw.CharField()
    dob = pw.DateField()
    dep = pw.CharField()


class Inout(BaseModel):
    empid = pw.ForeignKeyField(Employee, on_delete="cascade")
    evdate = pw.DateField()
    evday = pw.CharField()
    evtime = pw.TimeField()
    evtype = pw.IntegerField()


def task_1():
    cursor = db.execute_sql(" \
        SELECT DISTINCT e.fio FROM employee e JOIN inout i ON e.id=i.empid \
        WHERE i.evdate = '2018-12-14' AND i.evtype = 1 AND DATE_PART('minute', i.evtime::TIME - '9:00'::TIME) < 5; \
    ")
    for row in cursor.fetchall():
        print(row)
    cursor = Employee.select(Employee.fio).join(Inout).where(
        Inout.evdate == "2018-12-14",
        Inout.evtype == 1,
        pw.fn.Date_part('minute', Inout.evtime.cast("time") - Cast("9:00", "time"))
    )
    for row in cursor:
        print(row)


def task_2():
    cursor = db.execute_sql(" \
        SELECT DISTINCT e.fio FROM employee e JOIN inout i ON e.id = i.empid \
        WHERE i.evdate = '2018-12-14' AND i.evtype = 2 AND i.evtime - LAG(i.evtime) OVER (PARTITION BY i.evtime) > 10; \
    ")
    for row in cursor.fetchall():
        print(row)
    cursor = Employee.select(Employee.fio).join(Inout).where(
        Inout.evdate == "2018-12-14",
        Inout.evtype == 2,
        Inout.evtime - pw.fn.Lag(Inout.evtime).over(partition_by=[Inout.evtime])
    )
    for row in cursor:
        print(row)


def task_3():
    cursor = db.execute_sql(" \
        SELECT DISTINCT e.fio, e.dep FROM employee e JOIN inout i on e.id=i.empid \
        WHERE e.dep = 'Бухгалтерия' AND i.evtype = 1 AND i.evtime < '8:00'::TIME \
    ")
    for row in cursor.fetchall():
        print(row)
    cursor = Employee.select(Employee.fio, Employee.dep).join(Inout).where(
        Employee.dep == "Бухгалтерия",
        Inout.evtype == 1,
        Inout.evtime < Cast("8:00", "time")
    )
    for row in cursor:
        print(row)


def main():
    task_1()
    task_2()
    task_3()


if __name__ == "__main__":
    main()
