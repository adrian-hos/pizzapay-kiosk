import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

Item {
    ColumnLayout {
        id: containerProductEdit
        anchors.fill: parent

        GridLayout {
            id: gridLayoutProductEdit
            readonly property int margins: 10

            readonly property int minColumnWidth: 600

            columns: Math.min((width + margins) / (minColumnWidth + margins), 2)

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: gridLayoutProductEdit.columns === 2 ? gridLayoutProductEdit.height : gridLayoutProductEdit.height * 0.4

                Rectangle {
                    id: rectangleProductEdit
                    anchors.fill: parent
                    color: "#ffffff"
                }

                DropShadow {
                    anchors.fill: rectangleProductEdit
                    horizontalOffset: 0
                    verticalOffset: 3
                    radius: 8.0
                    samples: 17
                    color: "#20000000"
                    visible: gridLayoutProductEdit.columns !== 2
                    source: rectangleProductEdit
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: gridLayoutProductEdit.margins

                    Item {
                        Layout.alignment: Qt.AlignBottom
                        Layout.fillWidth: true
                        Layout.minimumHeight: width / (imageProductEdit.sourceSize.width / imageProductEdit.sourceSize.height)
                        Layout.maximumHeight: parent.height * 0.65

                        Image {
                            id: imageProductEdit
                            Layout.alignment: Qt.AlignBottom
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            width: parent.width
                            fillMode: Image.PreserveAspectFit
                            source: backend.pizza_list.get(backend.selected_pizza).image
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: parent.height * 0.15

                        Label {
                            id: labelProductEditName
                            anchors.fill: parent
                            anchors.leftMargin: 40
                            anchors.rightMargin: 40

                            text: backend.pizza_list.get(backend.selected_pizza).name
                            fontSizeMode: Label.Fit
                            minimumPixelSize: 10
                            font.pixelSize: 70
                            font.bold: true
                            color: "black"

                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignVCenter
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.maximumHeight: parent.height * 0.2

                        Label {
                            id: labelProductEditDescription
                            anchors.fill: parent
                            anchors.leftMargin: 40
                            anchors.rightMargin: 40

                            text: backend.pizza_list.get(backend.selected_pizza).description
                            fontSizeMode: Label.Fit
                            minimumPixelSize: 10
                            font.pixelSize: gridLayoutProductEdit.columns === 2 ? 28 : 20
                            font.bold: false
                            color: "black"

                            maximumLineCount: 2
                            wrapMode: Label.Wrap

                            horizontalAlignment: Label.AlignHCenter
                            verticalAlignment: Label.AlignTop
                        }
                    }

                }
            }

            Item {
                Layout.alignment: Qt.AlignBottom
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: gridLayoutProductEdit.margins

                    Item {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ScrollView {
                            id: scrollViewProductEdit
                            anchors.fill: parent

                            Item {
                                id: containerItemProductEdit

                                readonly property int margins: 20

                                width: scrollViewProductEdit.availableWidth
                                height: Math.max(implicitHeight, scrollViewProductEdit.availableHeight)

                                implicitHeight: columnLayoutProductEdit.implicitHeight + margins * 2

                                ColumnLayout {
                                    id: columnLayoutProductEdit
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: containerItemProductEdit.margins
                                    spacing: containerItemProductEdit.margins

                                    Material.theme: Material.Light
                                    Material.accent: Material.Amber

                                    Label {
                                        text: "Add toppings"
                                        font.bold: true
                                        font.pixelSize: 40
                                    }

                                    Repeater {
                                        model: backend.topping_list

                                        CheckBox {
                                            id: checkboxProductEdit
                                            //text: model.name + "  (" + model.price / 100000000 + " <b>BTC</b>;  ~" + model.priceRON + " <b>RON</b>)"
                                            text: model.name + "  (" + model.price / 100000 + " <b>mBTC</b>)"
                                            scale: 1.8
                                            transformOrigin: CheckBox.TopLeft
                                            checked: backend.editing_order ? backend.is_topping_selected(index) : false

                                            onToggled: {
                                                backend.select_topping(index, checked)

                                                if (checked) {
                                                    backend.selected_topping_price += model.price
                                                }
                                                else {
                                                    backend.selected_topping_price -= model.price
                                                }
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
                        Layout.maximumHeight: 100

                        readonly property int margins: 20

                        RowLayout {
                            anchors.fill: parent

                            anchors.margins: containerItemProductEdit.margins

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Label {
                                    anchors.fill: parent

                                    text: "Price:"
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

                                    text: (backend.pizza_list.get(backend.selected_pizza).price + backend.selected_topping_price) / 100000 + " <b>mBTC</b>"
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
                }
            }
        }

        Item {
            id: itemBottomBarProductEdit
            Layout.alignment: Qt.AlignBottom
            Layout.fillWidth: true
            Layout.minimumHeight: 100
            Layout.preferredHeight: 100

            readonly property int margins: 10

            Rectangle {
                id: rectangleCartBar
                anchors.fill: parent
                color: "#ffffff"
            }

            DropShadow {
                anchors.fill: rectangleCartBar
                horizontalOffset: 0
                verticalOffset: -3
                radius: 8.0
                samples: 17
                color: "#20000000"
                source: rectangleCartBar
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: parent.margins
                spacing: parent.margins

                Button {
                    id: buttonBackProductEdit
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumWidth: backend.editing_order ? 380 : 250
                    Layout.minimumWidth: backend.editing_order ? 380 : 250
                    Material.theme: Material.Light
                    Material.background: backend.editing_order ? Material.Grey300 : Material.Amber

                    text: backend.editing_order ? qsTr("Cancel Changes") : qsTr("Return")
                    font.pointSize: 25
                    font.bold: true

                    icon.name: backend.editing_order ? "close" : "keyboard_return"
                    icon.source: backend.editing_order ? "icon/close.svg" : "icon/keyboard_return.svg"
                    icon.width: 50
                    icon.height: 50

                    onClicked: {
                        backend.clear_current_pizza()

                        stack.pop()
                    }
                }

                Button {
                    id: buttonAddToCartProductEdit
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumWidth: 260
                    Material.theme: Material.Light
                    Material.background: Material.Amber

                    //text: qsTr("Add to order") + " (" + (productModel.get(backend.selected_pizza).price + selectedToppingPrice) / 100000 + " <b>mBTC</b>)"
                    text: backend.editing_order ? qsTr("Update Pizza") : qsTr("Add to order")
                    font.pointSize: 25
                    font.bold: true

                    icon.name: backend.editing_order ? "edit_note" : "add_shopping_cart"
                    icon.source: backend.editing_order ? "icon/edit_note.svg" : "icon/add_shopping_cart.svg"
                    icon.width: 50
                    icon.height: 50

                    onClicked: {
                        if (!backend.editing_order) {
                            backend.add_to_order()
                        }
                        else {
                            backend.edit_order()
                        }

                        popupProductEdit.open()
                    }
                }
            }
        }
    }

    Popup {
        id: popupProductEdit
        anchors.centerIn: parent
        parent: Overlay.overlay

        width: parent.width > 900 ? parent.width * 0.55 : parent.width
        height: parent.height > 350 ? 350 : parent.height
        dim: true

        contentItem: Label {
            anchors.fill: parent

            anchors.leftMargin: parent.width * 0.15
            anchors.rightMargin: parent.width * 0.15

            text: backend.editing_order ? "Pizza updated" : "Pizza added to order!"
            fontSizeMode: Label.Fit
            minimumPixelSize: 10
            font.pixelSize: 70
            font.bold: true
            color: "black"

            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
        }

        onOpened: {
            timerProductEditAdd.start()

            backend.clear_current_pizza()
        }

        onClosed: {
            timerProductEditAdd.stop()

            stack.pop()
        }
    }

    Timer {
        id: timerProductEditAdd
        interval: 800
        running: false
        repeat: false
        onTriggered: {
            popupProductEdit.close()
        }
    }
}
