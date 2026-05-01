import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    ColumnLayout {
        anchors.fill: parent

        anchors.leftMargin: parent.width * 0.3 >= 430 ? parent.width * 0.2 : (parent.width * 0.3 >= 330 ? parent.width * 0.15 : 50)
        anchors.rightMargin: parent.width * 0.3 >= 430 ? parent.width * 0.2 : (parent.width * 0.3 >= 330 ? parent.width * 0.15 : 50)

        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.maximumHeight: parent.height * 0.1

            Label {
                anchors.fill: parent

                text: "Thank you for your order."
                fontSizeMode: Label.Fit
                minimumPixelSize: 10
                font.pixelSize: 50
                color: "black"

                maximumLineCount: 1

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
            }
        }

        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.maximumHeight: parent.height * 0.1

            Label {
                anchors.fill: parent

                text: "Your Order Number:"
                fontSizeMode: Label.Fit
                minimumPixelSize: 10
                font.pixelSize: 50
                font.bold: true
                color: "black"

                maximumLineCount: 1

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignBottom
            }
        }

        Item {
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.maximumHeight: parent.height * 0.15

            Label {
                anchors.fill: parent

                text: "#" + backend.order_code
                fontSizeMode: Label.Fit
                minimumPixelSize: 10
                font.pixelSize: 60
                font.bold: true
                color: "black"

                maximumLineCount: 1

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignTop
            }
        }

        Item {
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            Layout.fillHeight: true

            Layout.maximumHeight: parent.height * 0.1

            Label {
                anchors.fill: parent
                anchors.leftMargin: 50
                anchors.rightMargin: 50

                text: "We're now preparing your pizza.<br>It will be ready shortly — please wait for your order number to be called."
                fontSizeMode: Label.Fit
                minimumPixelSize: 10
                font.pixelSize: 40
                font.bold: false
                color: "black"

                maximumLineCount: 3
                wrapMode: Label.Wrap

                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
            }
        }
    }

    Timer {
        id: timerOrderConfirmation
        interval: 10000
        running: true

        onTriggered: {
            timerOrderConfirmation.stop()
            backend.end_transaction()
            backend.clear_order()

            stack.popToIndex(0, StackView.PopTransition)
        }
    }
}
