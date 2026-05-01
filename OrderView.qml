import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

ColumnLayout {
    Item {
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        visible: backend.is_cart_empty
        enabled: backend.is_cart_empty

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: 40
            anchors.rightMargin: 40

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: parent.height * 0.5

                text: "Oops! Your order looks empty."
                fontSizeMode: Label.Fit
                minimumPixelSize: 10
                font.pixelSize: 70
                font.bold: true
                color: "black"

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignBottom
            }

            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 50
                Layout.rightMargin: 50

                text: "Browse our menu to get started."
                fontSizeMode: Label.Fit
                minimumPixelSize: 10
                font.pixelSize: 50
                font.bold: false
                color: "black"

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignTop
            }
        }
    }

    ScrollView {
        id: scrollViewOrder
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true

        Layout.leftMargin: parent.width * 0.2 >= 280 ? parent.width * 0.2 : 0
        Layout.rightMargin: parent.width * 0.2 >= 280 ? parent.width * 0.2 : 0

        visible: !backend.is_cart_empty
        enabled: !backend.is_cart_empty

        Item {
            id: containerItemOrder

            readonly property int margins: 30

            width: scrollViewOrder.availableWidth
            height: Math.max(implicitHeight, scrollViewOrder.availableHeight)

            implicitHeight: columnLayoutOrder.implicitHeight + margins * 2

            ColumnLayout {
                id: columnLayoutOrder
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                anchors.margins: containerItemOrder.margins

                spacing: containerItemOrder.margins

                Repeater {
                    model: backend.order

                    Item {
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        //Layout.preferredHeight: backend.order.get(index).strToppings === "" ? 120 : 220
                        Layout.preferredHeight: 220

                        Button {
                            id: buttonOrderEdit
                            anchors.fill: parent

                            contentItem: RowLayout {
                                anchors.fill: parent

                                readonly property int contentMargins: 10

                                anchors.margins: contentMargins

                                Item {
                                    Layout.alignment: Qt.AlignCenter

                                    Layout.maximumWidth: parent.width * 0.2
                                    Layout.maximumHeight: parent.height

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Image {
                                        anchors.top: parent.top
                                        anchors.bottom: parent.bottom
                                        anchors.centerIn: parent.Center

                                        width: parent.width

                                        fillMode: Image.PreserveAspectFit

                                        source: backend.pizza_list.get(backend.order.get(index).pizzaIndex).image
                                    }
                                }

                                ColumnLayout {
                                    Layout.maximumWidth: parent.width * 0.5
                                    Layout.maximumHeight: parent.height

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    Item {
                                        Layout.alignment: Qt.AlignTop
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.maximumHeight: parent.height * 0.25

                                        /*
                                        Rectangle {
                                            anchors.fill: parent

                                            color: "#00ffff"
                                        }
                                        */

                                        Label {
                                            anchors.fill: parent

                                            text: backend.pizza_list.get(backend.order.get(index).pizzaIndex).name
                                            fontSizeMode: Label.Fit
                                            minimumPixelSize: 10
                                            font.pixelSize: 30
                                            font.bold: true
                                            color: "black"

                                            horizontalAlignment: Label.AlignLeft
                                            verticalAlignment: Label.AlignVCenter
                                        }
                                    }

                                    Item {
                                        Layout.alignment: Qt.AlignTop
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.maximumHeight: parent.height * 0.2

                                        /*
                                        Rectangle {
                                            anchors.fill: parent

                                            color: "#ff00ff"
                                        }
                                        */

                                        Label {
                                            anchors.fill: parent

                                            text: backend.pizza_list.get(backend.order.get(index).pizzaIndex).description
                                            fontSizeMode: Label.Fit
                                            minimumPixelSize: 10
                                            font.pixelSize: 15
                                            font.bold: false
                                            color: "black"

                                            maximumLineCount: 2
                                            wrapMode: Label.Wrap

                                            horizontalAlignment: Label.AlignLeft
                                            verticalAlignment: Label.AlignVCenter
                                        }
                                    }

                                    Item {
                                        Layout.alignment: Qt.AlignTop
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        Layout.maximumHeight: parent.height * 0.4

                                        visible: backend.order.get(index).strToppings !== ""

                                        /*
                                        Rectangle {
                                            anchors.fill: parent

                                            color: "#ffff00"
                                        }
                                        */

                                        Label {
                                            anchors.fill: parent

                                            text: "<b>Toppings selected:</b> " + backend.order.get(index).strToppings
                                            fontSizeMode: Label.Fit
                                            minimumPixelSize: 10
                                            font.pixelSize: 15
                                            font.bold: false
                                            color: "black"

                                            maximumLineCount: 3
                                            wrapMode: Label.Wrap

                                            horizontalAlignment: Label.AlignLeft
                                            verticalAlignment: Label.AlignVCenter
                                        }
                                    }

                                    Item {
                                        Layout.alignment: Qt.AlignBottom
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true

                                        /*
                                        Rectangle {
                                            anchors.fill: parent

                                            color: "#0000ff"
                                        }
                                        */

                                        Label {
                                            anchors.fill: parent

                                            text: backend.order.get(index).price / 100000 + " <b>mBTC</b>"
                                            fontSizeMode: Label.Fit
                                            minimumPixelSize: 20
                                            font.pixelSize: 25
                                            font.bold: false
                                            color: "black"

                                            horizontalAlignment: Label.AlignLeft
                                            verticalAlignment: Label.AlignBottom
                                        }
                                    }

                                }
                            }

                            background: Item {
                                anchors.fill: parent

                                Rectangle {
                                    id: orderBG
                                    anchors.fill: parent
                                    radius: 5
                                    border.width: buttonOrderEdit.down ? 2 : 0
                                    border.color: "black"
                                    //color: buttonProdus.down ? "#f2f2f2" : "#ffffff"

                                }

                                DropShadow {
                                    anchors.fill: orderBG
                                    horizontalOffset: -3
                                    verticalOffset: 3
                                    radius: 8.0
                                    samples: 17
                                    color: buttonOrderEdit.down ? "#80000000" : "#50000000"
                                    source: orderBG
                                }
                            }

                            onClicked: {
                                backend.select_pizza_from_order(index)

                                stack.push(productEditView)
                            }

                        }

                        Button {
                            id: buttonOrderDelete
                            anchors.right: parent.right
                            anchors.rightMargin: (parent.height - height) / 2

                            anchors.verticalCenter: parent.verticalCenter

                            height: parent.height * 0.35
                            width: height

                            contentItem: Image {
                                anchors.fill: parent
                                anchors.margins: 10
                                anchors.centerIn: parent.Center

                                sourceSize.width: parent.width - anchors.margins * 2
                                sourceSize.height: parent.height - anchors.margins * 2

                                source: buttonOrderDelete.down ? "icon/delete_red.svg" : "icon/delete.svg"
                            }

                            background: Rectangle {
                                id: orderBGDelete
                                anchors.fill: parent
                                radius: 5
                                border.width: buttonOrderDelete.down ? 2 : 1
                                border.color: buttonOrderDelete.down ? "#EA3323" : "#80000000"

                            }

                            onClicked: {
                                backend.remove_from_order(index)
                            }
                        }
                    }

                }
            }
        }
    }

    Item {
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: 100
        Layout.maximumHeight: 100

        Layout.leftMargin: parent.width * 0.2 >= 280 ? parent.width * 0.2 : 0
        Layout.rightMargin: parent.width * 0.2 >= 280 ? parent.width * 0.2 : 0

        visible: !backend.is_cart_empty
        enabled: !backend.is_cart_empty

        readonly property int margins: 20

        RowLayout {
            anchors.fill: parent

            anchors.margins: 20

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    anchors.fill: parent

                    text: "Total price:"
                    fontSizeMode: Label.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 40
                    font.bold: true
                    color: "black"

                    horizontalAlignment: Label.AlignLeft
                    verticalAlignment: Label.AlignVCenter
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Label {
                    anchors.fill: parent

                    text: backend.final_price / 100000 + " <b>mBTC</b>"
                    fontSizeMode: Label.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 40
                    font.bold: false
                    color: "black"

                    horizontalAlignment: Label.AlignRight
                    verticalAlignment: Label.AlignVCenter
                }
            }
        }
    }

    Item {
        id: itemBottomBarOrder
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
        Layout.minimumHeight: 100
        Layout.preferredHeight: 100

        readonly property int margins: 10

        Rectangle {
            id: rectangleOrderBar
            anchors.fill: parent
            color: "#ffffff"
        }

        DropShadow {
            anchors.fill: rectangleOrderBar
            horizontalOffset: 0
            verticalOffset: -3
            radius: 8.0
            samples: 17
            color: "#20000000"
            source: rectangleOrderBar
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: parent.margins
            spacing: parent.margins

            Button {
                id: buttonBackOrder
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 250
                Layout.minimumWidth: 250
                Material.theme: Material.Light
                Material.background: Material.Amber

                text: qsTr("Return")
                font.pointSize: 25
                font.bold: true

                icon.name: "keyboard_return"
                icon.source: "icon/keyboard_return.svg"
                icon.width: 50
                icon.height: 50

                onClicked: {
                    stack.popToIndex(1, StackView.PopTransition)
                }
            }

            Button {
                id: buttonCompleteOrder
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 260
                Material.theme: Material.Light
                Material.background: Material.Amber

                visible: !backend.is_cart_empty
                enabled: !backend.is_cart_empty

                text: qsTr("Complete Order")
                font.pointSize: 25
                font.bold: true

                icon.name: "shopping_cart_checkout"
                icon.source: "icon/shopping_cart_checkout.svg"
                icon.width: 50
                icon.height: 50

                onClicked: {
                    backend.create_transaction()

                    stack.push(orderPayment)
                }
            }
        }
    }
}
