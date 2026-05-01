import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Window {
    id: root
    title: qsTr("PizzaPayKiosk")
    width: 1920
    height: 1080
    visible: true
    color: "#ffffff"

    ListModel {
        id: orderList

        ListElement {
            name: "Pizza Prosciutto E Funghi"
            price: 9130
            extraToppings: "Mushrooms, Olives"
        }

        ListElement {
            name: "Pizza Milanese"
            price: 7350
            extraToppings: ""
        }
    }

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: welcomeView
    }

    Component {
        id: welcomeView

        WelcomeView {}
    }

    Component {
        id: productView

        ProductView {}
    }

    Component {
        id: productEditView

        ProductEditView {}
    }

    Component {
        id: orderView

        OrderView {}
    }

    Component {
        id: orderPayment

        OrderPayment {}
    }

    Component {
        id: orderConfirmation

        OrderConfirmation {}
    }

}
