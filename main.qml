/****************************************************************************
**
** Copyright (C) 2011 Kirill (spirit) Klochkov.
** Contact: klochkov.kirill@gmail.com
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
****************************************************************************/

import QtQuick 1.0
import flood 1.0

Rectangle {
    id: window

    width: 320
    height: 480

    gradient: Gradient {
        GradientStop { position: 1.0; color: "white" }
        GradientStop { position: 0.0; color: "darkgray" }
    }

    FloodModel {
        id: floodModel

        rows: 12
        columns: 12
        colors: internal.colorModel

        onColorChanged: {
            var rectangle = board.children[row * floodModel.columns + column];
            var oldColor = rectangle.color
            rectangle.color = floodModel.color(row, column);
            rectangle.setAnimationColors(oldColor, floodModel.color(row, column));
        }

        onNewArrangment: board.initBoard()
    }

    QtObject {
        id: internal

        property variant colorModel: ["red", "yellow", "green", "blue", "purple", "cyan"]
        property int gridMargin: 2
        property int controlButtonsMargin: 10
        property int stepsCount: floodModel.rows + floodModel.columns
        property int currentStep: 0
    }

    Column {
        anchors.centerIn: parent

        spacing: 5

        Item {
            anchors.horizontalCenter: parent.horizontalCenter

            width: board.width + border.width
            height: width + 1

            Grid {
                id: board

                anchors.centerIn: parent
                width: childrenRect.width
                height: width

                rows: floodModel.rows
                columns: floodModel.columns

                function initBoard()
                {
                    repeater.model = board.colorModel();
                }

                Repeater {
                    id: repeater

                    model: board.colorModel()

                    Rectangle {
                        id: cell

                        width: window.width / floodModel.columns - internal.gridMargin
                        height: width
                        color: modelData
                        border.color: "lightgray"
                        smooth: true
                        radius: 5

                        function setAnimationColors(fromColor, toColor)
                        {
                            cellAnimation.from = fromColor;
                            cellAnimation.to = toColor;
                            cellAnimation.start();
                        }

                        ColorAnimation on color { id: cellAnimation; duration: 500 }

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.lighter(Qt.lighter(cell.color)) }
                            GradientStop { position: 0.3; color: Qt.lighter(cell.color) }
                            GradientStop { position: 0.4; color: cell.color }
                            GradientStop { position: 1.0; color: Qt.darker(cell.color) }
                        }

                        Behavior on opacity { NumberAnimation { duration: Math.random() * 2000 } }

                        opacity: 0.0

                        Component.onCompleted: cell.opacity = 1.0
                    }
                }

                function colorModel()
                {
                    var res = new Array();
                    for (var row = 0; row < floodModel.rows; ++row) {
                        for (var column = 0; column < floodModel.columns; ++column)
                            res.push(floodModel.color(row, column));
                    }
                    return res;
                }
            }
        }

        Row {
            spacing: 5

            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: internal.colorModel

                Button {
                    id: button

                    width: window.width / internal.colorModel.length - internal.controlButtonsMargin
                    height: width

                    color: modelData

                    normalGradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.lighter(Qt.lighter(modelData)) }
                        GradientStop { position: 0.3; color: Qt.lighter(modelData) }
                        GradientStop { position: 0.4; color: modelData }
                        GradientStop { position: 1.0; color: Qt.darker(modelData) }
                    }
                    pressedGradient: Gradient {
                        GradientStop { position: 1.0; color: Qt.lighter(Qt.lighter(modelData)) }
                        GradientStop { position: 0.4; color: Qt.lighter(modelData) }
                        GradientStop { position: 0.3; color: modelData }
                        GradientStop { position: 0.0; color: Qt.darker(modelData) }
                    }

                    onClicked: {
                        ++internal.currentStep;
                        floodModel.setColor(0, 0, button.color);

                        var isGameFinished = true;
                        for (var r = 0; r < floodModel.rows; ++r) {
                            for (var c = 0; c < floodModel.columns; ++c) {
                                if (button.color != floodModel.color(r, c)) {
                                    isGameFinished = false;
                                    break;
                                }
                            }
                        }

                        if (isGameFinished) {
                            informationDialog.text = qsTr("You won!");
                            informationDialog.visible = true;
                        } else if (internal.currentStep == internal.stepsCount) {
                            informationDialog.text = qsTr("The game is lost.\nTo start a new game press 'New game'.");
                            informationDialog.visible = true;
                            return;
                        }
                    }
                }
            }
        }

        Row {
            spacing: 5

            anchors.horizontalCenter: parent.horizontalCenter

            Item {
                width: scoreText.width + 10
                height: scoreText.height + 10

                Text {
                    id: scoreText
                    anchors.centerIn: parent
                    text: qsTr("Steps: %1/%2").arg(internal.currentStep).arg(internal.stepsCount)
                    font.bold: true
                    font.pixelSize: 16
                }
            }

            Button {
                text: qsTr("New game")

                onClicked: {
                    internal.currentStep = 0;
                    floodModel.init();
                }
            }

            Button {
                text: qsTr("Help")

                onClicked: {
                    informationDialog.text = qsTr("The game starts at top left corner.\nThe goal of the game it's to fill a board with one color.\nA color can be selected by pressing one of 6 colored buttons.\nGood luck!");
                    informationDialog.visible = true;
                }
            }
        }
    }

    Dialog {
        id: informationDialog

        width: window.width - 20
        height: window.height / 3

        anchors.centerIn: parent
    }
}
