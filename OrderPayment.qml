import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

ColumnLayout {
    property int secondsRemaining: 120

    Item {
        Layout.alignment: Qt.AlignCenter
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            anchors.leftMargin: parent.width * 0.3 >= 430 ? parent.width * 0.2 : (parent.width * 0.3 >= 330 ? parent.width * 0.15 : 50)
            anchors.rightMargin: parent.width * 0.3 >= 430 ? parent.width * 0.2 : (parent.width * 0.3 >= 330 ? parent.width * 0.15 : 50)

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.maximumHeight: parent.height * 0.1

                Label {
                    anchors.fill: parent

                    text: "Scan to Pay with Bitcoin"
                    fontSizeMode: Label.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 60
                    color: "black"

                    maximumLineCount: 1

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Image {
                    anchors.centerIn: parent
                    height: parent.height

                    fillMode: Image.PreserveAspectFit

                    source: backend.transaction_qr_code
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.maximumHeight: parent.height * 0.1

                Label {
                    anchors.fill: parent

                    text: "<b>Amount</b>: " + backend.final_price / 100000000 + " <b>BTC</b>"
                    fontSizeMode: Label.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 60
                    color: "black"

                    maximumLineCount: 1

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.maximumHeight: parent.height * 0.1

                Label {
                    anchors.fill: parent

                    text: "<b>Address</b>: " + backend.transaction_address
                    fontSizeMode: Label.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 60
                    color: "black"

                    maximumLineCount: 1

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.maximumHeight: parent.height * 0.1

                Label {
                    anchors.fill: parent

                    text: {
                        let min = Math.floor(secondsRemaining / 60).toString().padStart(2, '0')
                        let sec = (secondsRemaining % 60).toString().padStart(2, '0')

                        return "⏳ This transaction will expire in " + min + ":" + sec
                    }

                    fontSizeMode: Label.Fit
                    minimumPixelSize: 10
                    font.pixelSize: 30
                    color: "black"

                    maximumLineCount: 1

                    horizontalAlignment: Label.AlignHCenter
                    verticalAlignment: Label.AlignVCenter
                }
            }
        }
    }

    Item {
        id: itemBottomBarOrderPayment
        Layout.alignment: Qt.AlignBottom
        Layout.fillWidth: true
        Layout.minimumHeight: 100
        Layout.preferredHeight: 100

        readonly property int margins: 10

        Rectangle {
            id: rectangleOrderPaymentBar
            anchors.fill: parent
            color: "#ffffff"
        }

        DropShadow {
            anchors.fill: rectangleOrderPaymentBar
            horizontalOffset: 0
            verticalOffset: -3
            radius: 8.0
            samples: 17
            color: "#20000000"
            source: rectangleOrderPaymentBar
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: parent.margins
            spacing: parent.margins

            Button {
                id: buttonCancelOrderPayment
                Layout.fillWidth: true
                Layout.fillHeight: true
                Material.theme: Material.Light
                Material.background: Material.Amber

                text: qsTr("Cancel order")
                font.pointSize: 25
                font.bold: true

                icon.name: "remove_shopping"
                icon.source: "icon/remove_shopping.svg"
                icon.width: 50
                icon.height: 50

                onClicked: {
                    timerTransactionCancel.stop()
                    backend.cancel_transaction()
                    backend.clear_order()

                    stack.popToIndex(0, StackView.PopTransition)
                }
            }
        }
    }

    Timer {
        id: timerTransactionCancel
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (secondsRemaining > 0) {
                secondsRemaining -= 1
            }
            else {
                timerTransactionCancel.stop()
                timerTransactionVerify.stop()

                backend.cancel_transaction()
                backend.clear_order()

                stack.popToIndex(0, StackView.PopTransition)
            }
        }
    }

    Timer {
        id: timerTransactionVerify
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if (backend.is_transaction_paid) {
                timerTransactionCancel.stop()
                timerTransactionVerify.stop()

                stack.push(orderConfirmation)
            }
        }
    }
}
