# This Python file uses the following encoding: utf-8
import mysql.connector as db_connect

from DataTypes import Pizza, Topping, PizzaOrder, ItemList
from datetime import date

class Database:
    def __init__(self, ip, username, password, database, btc_to_leu):
        self.ip = ip
        self.username = username
        self.password = password
        self.database = database
        self.btc_to_leu = btc_to_leu

        self.db = db_connect.connect(
            host = self.ip,
            user = self.username,
            password = self.password,
            database = self.database
        )

        self.cursor = self.db.cursor()

        self.connected = True

        self._order_id = None
        self._order_code = None
        self._order_code_generated_at = None

    def connect_db(self):
        self.db = db_connect.connect(
            host = self.ip,
            user = self.username,
            password = self.password,
            database = self.database
        )

        self.cursor = self.db.cursor()

        self.connected = True

    def close_db(self):
        self.cursor.close()
        self.db.close()

        self.connected = False

    def fetch_data(self):
        if not self.connected:
           self.connect_db()

        pizza_list = []
        topping_list = []

        sql = "SELECT id, nume, descriere, CAST(CEIL((pret / (%(btc_to_leu)s * 100)) * 10000000) * 10 as INT) as pret, CONCAT(\"data:image/png;base64,\", TO_BASE64(poza)) as poza FROM pizza WHERE ascuns = 0"
        self.cursor.execute(sql, {"btc_to_leu": self.btc_to_leu})

        row = self.cursor.fetchone()

        while row is not None:
            pizza_list.append(Pizza(*row))
            row = self.cursor.fetchone()

        sql = "SELECT id, nume, CAST(CEIL((pret / (%(btc_to_leu)s * 100)) * 10000000) * 10 as INT) as pret FROM condiment_opt WHERE ascuns = 0"
        self.cursor.execute(sql, {"btc_to_leu": self.btc_to_leu})

        row = self.cursor.fetchone()

        while row is not None:
            topping_list.append(Topping(*row))
            row = self.cursor.fetchone()

        return pizza_list, topping_list

    @property
    def order_code(self):
        if self._order_code != None:
            if date.today().isoformat() == self._order_code_generated_at:
                return self._order_code

        if not self.connected:
           self.connect_db()

        latest_order_code = 0

        sql = "SELECT cod_comanda FROM comanda WHERE DATE(data) = CURDATE() ORDER BY data DESC LIMIT 1"
        self.cursor.execute(sql)

        row = self.cursor.fetchone()

        if row:
           latest_order_code = row[0]
        else:
            latest_order_code = 0

        self._order_code = latest_order_code + 1
        self._order_code_generated_at = date.today().isoformat()

        return self._order_code

    def add_order(self, order: ItemList):
        if not self.connected:
           self.connect_db()

        order_pizza_list = order._item_list
        order_code = self.order_code

        sql = "INSERT INTO comanda (data, cod_comanda, status_comanda) VALUES(NOW(), %(order_code)s, 1)"
        self.cursor.execute(sql, {"order_code": order_code})

        self._order_id = self.cursor.lastrowid

        for pizza in order_pizza_list:
            sql = "INSERT INTO comanda_produs(id_comanda, id_pizza) VALUES(%(order_id)s, %(pizza_id)s)"
            self.cursor.execute(sql, {"order_id": self._order_id, "pizza_id": pizza.dbID})

            order_pizza_id = self.cursor.lastrowid

            for topping in pizza.selectedtoppings:
                sql = "INSERT INTO comanda_produs_condiment_opt(id_comanda_produs, id_condiment_opt) VALUES(%(order_pizza_id)s, %(topping_id)s)"
                self.cursor.execute(sql, {"order_pizza_id": order_pizza_id, "topping_id": topping})

        self.db.commit()

        print(f"Created order id {self._order_id} with order code #{order_code}")

    def set_order_status(self, status):
        if not self.connected:
           self.connect_db()

        sql = "UPDATE comanda SET status_comanda = %(status)s WHERE id = %(order_id)s"
        self.cursor.execute(sql, {"status": status, "order_id": self._order_id})

        self.db.commit()

    def add_transaction(self, txid, amount):
        if not self.connected:
           self.connect_db()

        sql = "INSERT INTO tranzactie(txid, data, btc_primit, id_comanda) VALUES(%(txid)s, NOW(), %(amount)s, %(order_id)s)"
        self.cursor.execute(sql, {"txid": txid, "amount": amount, "order_id": self._order_id})

        self.db.commit()

        print(f"Added txid {txid} to order {self._order_id} with amount {amount / 100000000:.7f}")

    def increase_order_code(self):
        if date.today().isoformat() == self._order_code_generated_at:
            self._order_code += 1
        else:
            self.order_code()

    @property
    def order_id(self):
        return self._order_id
