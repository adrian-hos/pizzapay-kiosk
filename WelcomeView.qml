import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    id: containerItemWelcome

    readonly property int margins: 20

    GridLayout {
        id: gridLayoutWelcome
        anchors.fill: parent
        anchors.margins: containerItemWelcome.margins
        rowSpacing: containerItemWelcome.margins
        columnSpacing: containerItemWelcome.margins

        readonly property int minColumnWidth: 500

        columns: (width + containerItemWelcome.margins) / (minColumnWidth + containerItemWelcome.margins)

        Item {
            id: containerItemWelcomeContent
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent

                Item {
                    Layout.alignment: Qt.AlignBottom
                    Layout.fillWidth: true
                    Layout.minimumHeight: width / (imageWelcome.sourceSize.width / imageWelcome.sourceSize.height)
                    Layout.maximumHeight: parent.height * 0.8

                    Image {
                        id: imageWelcome
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width
                        fillMode: Image.PreserveAspectFit
                        source: "image/pizza.png"
                    }
                }

                Item {
                    Layout.alignment: Qt.AlignTop
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.maximumHeight: parent.height * 0.25

                    Label {
                        id: labelWelcome
                        anchors.fill: parent

                        text: "Welcome to PizzaPay!"
                        fontSizeMode: Label.Fit
                        minimumPixelSize: 20
                        font.pixelSize: 80
                        font.bold: true
                        color: "black"

                        horizontalAlignment: Label.AlignHCenter
                        verticalAlignment: Label.Top
                    }
                }

            }
        }

        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumHeight: parent.columns === 2 ? parent.height : parent.height * 0.2

            Button {
                id: buttonWelcome
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 100
                width: parent.width

                Material.theme: Material.Light
                Material.background: Material.Amber

                text: qsTr("Order Now")
                font.pointSize: 25
                font.bold: true

                icon.name: "shopping_cart"
                icon.source: "icon/shopping_cart.svg"
                icon.width: 50
                icon.height: 50

                onClicked: {
                    stack.push(productView)
                }
            }
        }
    }
}
