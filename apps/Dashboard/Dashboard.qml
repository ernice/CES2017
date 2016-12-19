/*
 * Copyright (C) 2016 The Qt Company Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import QtQuick 2.6
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.0

ApplicationWindow {
    //visible: true;
    id: root
    function languageChanged(lang) {
        //console.log("land is ", lang)
        if(lang === 'fr') {
            unit.text = 'KMH'
            speedvalue.text = '100,000.5 KM'
            tireLeftFront.title = 'PNEU AVANT GAUCHE'
            tireLeftFront.pressure = '1.59 BAR'
            tireRightFront.title = 'PNEU AVANT DROIT'
            tireRightFront.pressure = '1.67 BAR'
            tireLeftRear.title = 'PNEU ARRIERE GAUCHE'
            tireLeftRear.pressure = '2.16 BAR'
            tireRightRear.title = 'PNEU ARRIERE DROIT'
            tireRightRear.pressure = '2.28 BAR'
            labelSpeed.text = 'VITESSE (KMH)'
            levelUnit.text = 'NIVEAU'
            levelValue.text = '34 LITRES'
            levelRange.text = 'AUTONOMIE'
            levelRangeValue.text = '369 KM'
            levelAverage.text = 'MOY'
            levelAverageValue.text = '9.2 L/100KM'
            fuel.text = 'CARBURANT'
        } else {
            unit.text = 'MPH'
            speedvalue.text = '100,000.5 MI'
            tireLeftFront.title = 'LEFT FRONT TIRE'
            tireLeftFront.pressure = '23.1 PSI'
            tireRightFront.title = 'RIGHT FRONT TIRE'
            tireRightFront.pressure = '24.2 PSI'
            tireLeftRear.title = 'LEFT REAR TIRE'
            tireLeftRear.pressure = '31.35 PSI'
            tireRightRear.title = 'RIGHT REAR TIRE'
            tireRightRear.pressure = '33.0 PSI'
            labelSpeed.text = 'SPEED (MPH)'
            levelUnit.text = 'LEVEL'
            levelValue.text = '9 GALLONS'
            levelRange.text = 'RANGE'
            levelRangeValue.text = '229 MI'
            levelAverage.text = 'AVG'
            levelAverageValue.text = '25.5 MPG'
            fuel.text = 'FUEL'
        }
    }

    Label {
        id: speed
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        text: '1'
        font.pixelSize: 256
    }
    Label {
        id: unit
        anchors.left: speed.right
        anchors.baseline: speed.baseline
        text: 'MPH'
        font.pixelSize: 64
    }
    Label {
        id: speedvalue
        anchors.left: unit.left
        anchors.top: unit.bottom
        text: '100,000.5 MI'
        font.pixelSize: 32
        opacity: 0.5
    }

    Image {
        id: car
        anchors.centerIn: parent
        source: './images/HMI_Dashboard_Car.png'
    }

    TirePressure {
        id: tireLeftFront
        anchors.right: car.left
        anchors.rightMargin: -20
        anchors.top: car.top
        anchors.topMargin: 150
        title: 'LEFT FRONT TIRE'
        pressure: '23.1 PSI'
    }

    TirePressure {
        id: tireLeftRear
        anchors.right: car.left
        anchors.rightMargin: -20
        anchors.bottom: car.bottom
        anchors.bottomMargin: 120
        title: 'LEFT REAR TIRE'
        pressure: '31.35 PSI'
    }

    TirePressure {
        id: tireRightFront
        mirror: true
        anchors.left: car.right
        anchors.leftMargin: -20
        anchors.top: car.top
        anchors.topMargin: 150
        title: 'RIGHT FRONT TIRE'
        pressure: '24.2 PSI'
    }

    TirePressure {
        id: tireRightRear
        mirror: true
        anchors.left: car.right
        anchors.leftMargin: -20
        anchors.bottom: car.bottom
        anchors.bottomMargin: 120
        title: 'RIGHT REAR TIRE'
        pressure: '33.0 PSI'
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 100

        Image {
            id: speedIcon
            source: './images/HMI_Dashboard_Speed_Icon.svg'
        }
        ProgressBar {
            Layout.fillWidth: true
            value: 0.25
            Label {
                id: labelSpeed
                anchors.left: parent.left
                anchors.top: parent.bottom
                anchors.topMargin: 10
                text: 'SPEED (MPH)'
                font.pixelSize: 26
            }
        }
        Item {
            width: 30
            height: 30
        }
        Image {
            id: fuelIcon
            source: './images/HMI_Dashboard_Fuel_Icon.svg'
        }
        ProgressBar {
            Layout.fillWidth: true
            value: 0.66
            Image {
                anchors.left: parent.left
                anchors.leftMargin: -40
                anchors.bottom: parent.top
                source: './images/HMI_Dashboard_Fuel_Details.svg'
                GridLayout {
                    anchors.fill: parent
                    columns: 2
                    rowSpacing: -10
                    Label {
                        id: levelUnit
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        Layout.fillHeight: true
                        verticalAlignment: Label.AlignVCenter
                        horizontalAlignment: Label.AlignRight
                        text: 'LEVEL:'
                        font.pixelSize: 24
                    }
                    Label {
                        id: levelValue
                        Layout.fillWidth: true
                        Layout.preferredWidth: 4
                        Layout.fillHeight: true
                        verticalAlignment: Label.AlignVCenter
                        horizontalAlignment: Label.AlignLeft
                        text: '9 GALLONS'
                        font.pixelSize: 24
                        color: '#66FF99'
                    }
                    Label {
                        id: levelRange
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        Layout.fillHeight: true
                        verticalAlignment: Label.AlignVCenter
                        horizontalAlignment: Label.AlignRight
                        text: 'RANGE:'
                        font.pixelSize: 24
                    }
                    Label {
                        id: levelRangeValue
                        Layout.fillWidth: true
                        Layout.preferredWidth: 4
                        Layout.fillHeight: true
                        verticalAlignment: Label.AlignVCenter
                        horizontalAlignment: Label.AlignLeft
                        text: '229 MI'
                        font.pixelSize: 24
                        color: '#66FF99'
                    }
                    Label {
                        id: levelAverage
                        Layout.fillWidth: true
                        Layout.preferredWidth: 3
                        Layout.fillHeight: true
                        verticalAlignment: Label.AlignVCenter
                        horizontalAlignment: Label.AlignRight
                        text: 'AVG:'
                        font.pixelSize: 24
                    }
                    Label {
                        id: levelAverageValue
                        Layout.fillWidth: true
                        Layout.preferredWidth: 4
                        Layout.fillHeight: true
                        verticalAlignment: Label.AlignVCenter
                        horizontalAlignment: Label.AlignLeft
                        text: '25.5 MPG'
                        font.pixelSize: 24
                        color: '#66FF99'
                    }
                }
            }

            Label {
                id: fuel
                anchors.left: parent.left
                anchors.top: parent.bottom
                anchors.topMargin: 10
                text: 'FUEL'
                font.pixelSize: 26
            }
        }
    }
}
