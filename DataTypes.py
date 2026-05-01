# This Python file uses the following encoding: utf-8

# if __name__ == "__main__":
#     pass

from dataclasses import dataclass

from PySide6.QtCore import Qt, QAbstractListModel, Slot, QModelIndex

import copy

# Data type for Pizza
@dataclass
class Pizza:
    dbID: int
    name: str
    description: str
    price: int
    # Image file stored in base64
    image: str

# Data type for Topping
@dataclass
class Topping:
    dbID: int
    name: str
    price: int

@dataclass
class PizzaOrder:
    pizzaIndex: int
    dbID: int
    price: int
    selectedtoppings: list
    isSelectedToppings: list
    strToppings: str

class ItemList(QAbstractListModel):
    def __init__(self, item_list, dataclass_type, default_value):
        QAbstractListModel.__init__(self)

        self._item_list = item_list
        self._default_value = default_value

        self._variable_names = dataclass_type.__match_args__
        self._roleNames = {(i + Qt.UserRole + 1):self._variable_names[i].encode("utf-8") for i in range(len(self._variable_names))}

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        item = self._item_list[index.row()]

        if role == Qt.DisplayRole:
            return item.__dict__[self._variable_names[self._default_value]]
        elif role > Qt.UserRole and role <= Qt.UserRole + len(self._variable_names):
            return item.__dict__[self._roleNames[role].decode("utf-8")]
        else:
            return None

    def setData(self, index, value, role=Qt.EditRole):
        if index.isValid() and 0 <= index.row() < self.rowCount() and role == Qt.EditRole:
            self._item_list[index.row()] = value
            self.dataChanged.emit(index, index, [role])
            return True
        return False

    def appendItem(self, item):
        self.beginInsertRows(QModelIndex(), self.rowCount(), self.rowCount())
        self._item_list.append(item)
        self.endInsertRows()

    def removeItem(self, index):
        if 0 <= index < self.rowCount():
            self.beginRemoveRows(QModelIndex(), index, index)
            del self._item_list[index]
            self.endRemoveRows()

    def editItem(self, index, item):
        index = self.index(index)
        self.setData(index, item, Qt.EditRole)

    @Slot(int, result=dict)
    def get(self, index):
        if 0 <= index < self.rowCount():
            return self._item_list[index].__dict__

    def getCopy(self, index):
        if 0 <= index < self.rowCount():
            return copy.deepcopy(self._item_list[index].__dict__)

    def roleNames(self):
        return self._roleNames

    def rowCount(self, parent=QModelIndex()):
        return len(self._item_list)
