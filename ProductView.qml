import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtQuick.Controls.Material

ColumnLayout {

    ScrollView {
        id: scrollViewProduct
        Material.theme: Material.Light
        Layout.alignment: Qt.AlignTop
        Layout.fillWidth: true
        Layout.fillHeight: true

        Item {
            id: containerItemProduct

            readonly property int margins: 20

            width: scrollViewProduct.availableWidth
            height: Math.max(implicitHeight, scrollViewProduct.availableHeight)

            implicitHeight: gridLayoutProduct.implicitHeight + margins * 2

            GridLayout {
                id: gridLayoutProduct
                anchors.fill: parent
                anchors.margins: containerItemProduct.margins
                rowSpacing: containerItemProduct.margins
                columnSpacing: containerItemProduct.margins

                readonly property int minColumnWidth: 400

                columns: (width + containerItemProduct.margins) / (minColumnWidth + containerItemProduct.margins)

                Repeater {
                    model: backend.pizza_list

                    Button {
                        id: buttonProdus
                        Layout.alignment: Qt.AlignCenter
                        Layout.fillWidth: true
                        Layout.preferredHeight: 450

                        contentItem: Item {
                            anchors.fill: parent

                            readonly property int contentMargins: 10

                            anchors.margins: contentMargins

                            Image {
                                id: imageProduct
                                anchors.top: parent.top
                                anchors.bottom: labelProductName.top
                                width: parent.width
                                fillMode: Image.PreserveAspectFit
                                source: model.image
                            }

                            Label {
                                id: labelProductName
                                anchors.bottom: labelProductDescription.top
                                width: parent.width

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                text: model.name
                                font.pointSize: 20
                                font.bold: true
                                color: "black"

                                maximumLineCount: 2
                                wrapMode: Label.Wrap
                            }

                            Label {
                                id: labelProductDescription
                                anchors.bottom: labelProductPrice.top
                                anchors.bottomMargin: [50, 30, 20][lineCount - 1]
                                width: parent.width

                                horizontalAlignment: Text.AlignLeft
                                verticalAlignment: Text.AlignVCenter

                                text: model.description
                                font.pointSize: 14
                                font.bold: false
                                color: "black"

                                maximumLineCount: 3
                                wrapMode: Label.Wrap
                            }

                            Label {
                                id: labelProductPrice
                                anchors.bottom: parent.bottom
                                width: parent.width

                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter

                                //text: model.price / 100000000 + " <b>BTC</b> (~" + priceRON + " Lei)"
                                text: model.price / 100000 + " <b>mBTC</b>"
                                font.pointSize: 18
                                color: "black"

                                maximumLineCount: 2
                                wrapMode: Label.Wrap
                            }
                        }

                        background: Item {
                            anchors.fill: parent

                            Rectangle {
                                id: productBG
                                anchors.fill: parent
                                radius: 5
                                border.width: buttonProdus.down ? 2 : 0
                                border.color: "black"
                                //color: buttonProdus.down ? "#f2f2f2" : "#ffffff"

                            }

                            DropShadow {
                                anchors.fill: productBG
                                horizontalOffset: -3
                                verticalOffset: 3
                                radius: 8.0
                                samples: 17
                                color: buttonProdus.down ? "#80000000" : "#50000000"
                                source: productBG
                            }
                        }

                        onClicked: {
                            backend.select_pizza(index)

                            stack.push(productEditView)
                        }
                    }
                }
            }
        }

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn

        ScrollBar.horizontal.interactive: false
        ScrollBar.vertical.interactive: true
    }

    Item {
        id: itemBottomBarProduct
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
                id: buttonExitProduct
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumWidth: 200
                Layout.minimumWidth: 200
                Material.theme: Material.Light
                Material.background: Material.Amber

                text: qsTr("Close")
                font.pointSize: 25
                font.bold: true

                icon.name: "close"
                icon.source: "icon/close.svg"
                icon.width: 50
                icon.height: 50

                onClicked: {
                    backend.clear_order()
                    stack.popToIndex(0, StackView.PopTransition)
                }
            }

            Button {
                id: buttonCartProduct
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 260
                Material.theme: Material.Light
                Material.background: Material.Amber

                text: qsTr("View Cart")
                font.pointSize: 25
                font.bold: true

                icon.name: "shopping_cart"
                icon.source: "icon/shopping_cart.svg"
                icon.width: 50
                icon.height: 50

                onClicked: {
                    stack.push(orderView)
                }
            }
        }
    }
}
