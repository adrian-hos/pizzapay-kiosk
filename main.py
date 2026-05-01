# This Python file uses the following encoding: utf-8
import sys
from pathlib import Path

from PySide6.QtCore import QObject, Property, Slot, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

import qrcode
import base64
from io import BytesIO

from Database import Database
from DataTypes import ItemList, Pizza, Topping, PizzaOrder
from Wallet import Wallet

# TODO: Checkboxes can be clicked behind "added to order" pop-up
# TODO: Clicking too fast on add to order and then back will not add order

cache_path = Path(__file__).resolve().parent / "wallet_cache.json"
vpub = ""

class Backend(QObject):
    isCartEmptyChanged = Signal()
    finalPriceChanged = Signal()
    orderChanged = Signal()
    editingOrderChanged = Signal()
    selectedPizzaChanged = Signal()
    selectedToppingPrice = Signal()
    transactionQrCodeChanged = Signal()
    transactionAddressChanged = Signal()
    isTransactionPaidChanged = Signal()
    orderCodeChanged = Signal()

    def __init__(self, database, wallet):
        QObject.__init__(self)

        self.database = database
        self.wallet = wallet

        raw_pizza_list, raw_topping_list = self.database.fetch_data()

        self._pizza_list = ItemList(raw_pizza_list, Pizza, 1)
        self._topping_list = ItemList(raw_topping_list, Topping, 1)

        self._current_pizza: PizzaOrder
        self._selected_pizza = 0
        self._selected_topping_price = 0

        self._is_cart_empty = True
        self._order: ItemList
        self._final_price = 0
        self._editing_order = False
        self._editing_order_id = 0

        self._transaction_uri = ""
        self._transaction_address = ""
        self._order_code = 0
        self._transaction_qr_code = ""
        self._is_transaction_paid = False

    @Property(QObject, constant=True)
    def pizza_list(self):
        return self._pizza_list

    @Property(QObject, constant=True)
    def topping_list(self):
        return self._topping_list

    @Property(bool, notify=isCartEmptyChanged)
    def is_cart_empty(self):
        return self._is_cart_empty

    @Property(bool, notify=editingOrderChanged)
    def editing_order(self):
        return self._editing_order

    @Property(QObject, notify=orderChanged)
    def order(self):
        if self._is_cart_empty:
            return None
        else:
            return self._order

    @Property(int, notify=finalPriceChanged)
    def final_price(self):
        return self._final_price

    @Property(int, notify=selectedPizzaChanged)
    def selected_pizza(self):
        return self._selected_pizza

    def get_selected_topping_price(self):
        return self._selected_topping_price

    def set_selected_topping_price(self, value):
        self._selected_topping_price = value
        self.selectedToppingPrice.emit()

    selected_topping_price = Property(int, get_selected_topping_price, set_selected_topping_price, notify=selectedToppingPrice)

    @Slot(int)
    def select_pizza(self, index):
        pizza = self._pizza_list.get(index)

        self._current_pizza = PizzaOrder(index, pizza["dbID"], pizza["price"], [], [False for i in range(self._topping_list.rowCount())], "")

        self._selected_pizza = index
        self.selectedPizzaChanged.emit()

        self.set_selected_topping_price(0)

        print(f"Selected: {pizza['name']}")

        return

    @Slot(int)
    def select_pizza_from_order(self, index):
        self._current_pizza = PizzaOrder(**self._order.getCopy(index))

        self._selected_pizza = self._current_pizza.pizzaIndex
        self.selectedPizzaChanged.emit()

        self._selected_topping_price = 0

        for i in range(self._topping_list.rowCount()):
            if self._current_pizza.isSelectedToppings[i]:
                self._selected_topping_price += self._topping_list.get(i)["price"]

        self.selectedToppingPrice.emit()

        self._editing_order = True
        self.editingOrderChanged.emit()

        self._editing_order_id = index

    @Slot(int, bool)
    def select_topping(self, index, is_selected):
        topping = self._topping_list.get(index)

        self._current_pizza.isSelectedToppings[index] = is_selected

        if is_selected:
            self._current_pizza.price += topping["price"]
        else:
            self._current_pizza.price -= topping["price"]

    @Slot(int, result=bool)
    def is_topping_selected(self, index):
        return self._current_pizza.isSelectedToppings[index]

    @Slot()
    def add_to_order(self):
        topping_list = []

        for i in range(0, self._topping_list.rowCount()):
            if self._current_pizza.isSelectedToppings[i]:
                topping = self._topping_list.get(i)

                self._current_pizza.selectedtoppings.append(topping["dbID"])
                topping_list.append(topping["name"])

        self._current_pizza.strToppings = ", ".join(topping_list)

        if self._is_cart_empty:
            order_list = [self._current_pizza]
            self._order = ItemList(order_list, PizzaOrder, 0)

            self._final_price += self._current_pizza.price
            self._is_cart_empty = False

            self.isCartEmptyChanged.emit()

        else:
            self._order.appendItem(self._current_pizza)

            self._final_price += self._current_pizza.price

        self.clear_current_pizza()

        del self._current_pizza

        self.finalPriceChanged.emit()
        self.orderChanged.emit()

        print([pizza_order for pizza_order in self._order._item_list])

    @Slot()
    def edit_order(self):
        topping_list = []

        for i in range(0, self._topping_list.rowCount()):
            if self._current_pizza.isSelectedToppings[i]:
                topping = self._topping_list.get(i)

                self._current_pizza.selectedtoppings.append(topping["dbID"])
                topping_list.append(topping["name"])

        self._current_pizza.strToppings = ", ".join(topping_list)

        self._final_price = 0

        for i in range(self._order.rowCount()):
            if i != self._editing_order_id:
                self._final_price += self._order.get(i)["price"]

        self._order.editItem(self._editing_order_id, self._current_pizza)

        self._final_price += self._current_pizza.price

        self.clear_current_pizza()

        del self._current_pizza

        self.finalPriceChanged.emit()
        self.orderChanged.emit()

        print([pizza_order for pizza_order in self._order._item_list])
        print(f"Edited {self._editing_order_id}: {self._order._item_list[self._editing_order_id]}")

    @Slot()
    def clear_current_pizza(self):
        self._selected_topping_price = 0
        self._selected_pizza = 0
        self._editing_order = False
        self._editing_order_id = 0

    @Slot(int)
    def remove_from_order(self, index):
        if not self._is_cart_empty:
            item = self._order.get(index)

            self._final_price -= item["price"]

            self._order.removeItem(index)

            if self._order.rowCount() == 0:
                self.clear_order()
            else:
                self.finalPriceChanged.emit()
                self.orderChanged.emit()

    @Slot()
    def clear_order(self):
        if not self._is_cart_empty:
            del self._order
            self._final_price = 0
            self._is_cart_empty = True

            self.isCartEmptyChanged.emit()
            self.finalPriceChanged.emit()
            self.orderChanged.emit()

    @Property(str, notify=transactionQrCodeChanged)
    def transaction_qr_code(self):
        return self._transaction_qr_code

    @Property(str, notify=transactionAddressChanged)
    def transaction_address(self):
        return self._transaction_address

    @Property(int, notify=orderCodeChanged)
    def order_code(self):
        return self._order_code

    @Slot()
    def create_transaction(self):
        self.database.add_order(self._order)
        self._order_code = self.database.order_code
        self.orderCodeChanged.emit()
        #self._order_code = 1
        self._transaction_address, self._transaction_uri = self.wallet.create_transaction(self._final_price, self._order_code)
        self.transactionAddressChanged.emit()

        qr = qrcode.make(self._transaction_uri)
        buffer = BytesIO()
        qr.save(buffer, format="PNG")
        base64_data = base64.b64encode(buffer.getvalue()).decode("utf-8")

        self._transaction_qr_code = f"data:image/png;base64,{base64_data}"
        self.transactionQrCodeChanged.emit()

    @Property(bool, notify=isTransactionPaidChanged)
    def is_transaction_paid(self):
        if self._is_transaction_paid:
            pass
        else:
            self._is_transaction_paid = wallet.is_transaction_paid

            if self._is_transaction_paid:
                self.database.set_order_status(2)
                self.database.add_transaction(self.wallet.transaction_txid, self._final_price)
                self.isTransactionPaidChanged.emit()
                self.database.increase_order_code()
                print("Order has been paid!")

        return self._is_transaction_paid

    @Slot()
    def end_transaction(self):
        self.clear_order()
        self.wallet.end_transaction()

        self._transaction_uri = ""
        self._transaction_address = ""
        self.transactionAddressChanged.emit()
        self._order_code = 0
        self.orderCodeChanged.emit()
        self._transaction_qr_code = ""
        self.transactionQrCodeChanged.emit()
        self._is_transaction_paid = False
        self.isTransactionPaidChanged.emit()

    @Slot()
    def cancel_transaction(self):
        self.end_transaction()
        self.database.set_order_status(4)


if __name__ == "__main__":
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    wallet = Wallet(vpub, cache_path)
    database = Database("localhost", "admin", "parola", "pizzapay", wallet.btc_to_leu)

    backend = Backend(database, wallet)
    engine.rootContext().setContextProperty("backend", backend)

    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(qml_file)

    if not engine.rootObjects():
        database.close_db()
        sys.exit(-1)
    sys.exit(app.exec())
