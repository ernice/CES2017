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
import '..'

SettingPage {
    id: root
    icon: '/wifi/images/HMI_Settings_WifiIcon.svg'
    title: 'Wifi'
    checkable: true

    property string protocol: 'http://'
    property string ipAddress: '127.0.0.1'
    property string portNumber: Qt.application.arguments[1]
    property string tokenString: Qt.application.arguments[2]
    property string wifiAPI: '/api/wifi-manager/'
    property string wifiAPIpath: protocol + ipAddress + ':' + portNumber + wifiAPI

    Text {
        id: log
        anchors.fill: parent
        anchors.margins: 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        //text: "log"
    }

    onCheckedChanged: {
        console.log("Wifi set to", checked)
        if (checked == true) {
            periodicRefresh.start()
            request(wifiAPIpath + 'activate', function (o) {
                // log the json response
                console.log(o.responseText)
            })

        } else {
            //console.log(networkPath)
            networkList.clear()
            request(wifiAPIpath + 'deactivate', function (o) {
                // log the json response
                console.log(o.responseText)
            })
        }
    }
    function listWifiNetworks() {
        console.log("test #4")
    }
    ListModel {
        id: networkList
    }

    Rectangle {
        id: buttonNetworkList
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 10
        width: buttonNetworkListText.width + 10
        height: buttonScanText.height + 10
        border.width: buttonNetworkListMouseArea.pressed ? 2 : 1
        radius: 5
        antialiasing: true
        color: "#222"
        border.color: "white"
        Text {
            color: "white"
            id: buttonNetworkListText
            anchors.centerIn: parent
            text: "GET NETWORK LIST"
            font.pixelSize: 40
        }
        ListModel {
            id: listModel
        }
        MouseArea {
            id: buttonNetworkListMouseArea
            anchors.fill: parent
            onClicked: {
                log.text = ""
                console.log("\n")
                networkList.clear()
                request(wifiAPIpath + 'scan_result', function (o) {
                    // log the json response
                    console.log(o.responseText)
                    // translate response into object
                    var jsonObject = eval('(' + o.responseText + ')')
                    var jsonObjectNetworks = eval(
                                '(' + JSON.stringify(jsonObject.response) + ')')
                    //console.log(jsonObject.response)
                    for (var i = 0; i < jsonObjectNetworks.length; i++) {
                        networkList.append({
                                               number: jsonObjectNetworks[i].Number,
                                               name: jsonObjectNetworks[i].ESSID,
                                               strength: jsonObjectNetworks[i].Strength,
                                               serviceState: jsonObjectNetworks[i].State,
                                               security: jsonObjectNetworks[i].Security,
                                               address: jsonObjectNetworks[i].IPAddress
                                           })
                        console.log(jsonObjectNetworks[i].Number,
                                    jsonObjectNetworks[i].ESSID,
                                    jsonObjectNetworks[i].Strength,
                                    jsonObjectNetworks[i].State,
                                    jsonObjectNetworks[i].Security,
                                    jsonObjectNetworks[i].IPAddress)
                    }
                })
            }
        }
    }
    Rectangle {
        id: buttonScan
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.margins: 80
        width: buttonScanText.width + 10
        height: buttonScanText.height + 10
        border.width: mouseArea.pressed ? 2 : 1
        //radius: 5
        //antialiasing: true
        //color: "black"
        color: "#222"
        border.color: "white"
        Text {
              id: buttonScanText
              anchors.centerIn: parent
              text: "SCAN"
              color: "white"
              font.pixelSize: 40
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                log.text = ""
                console.log("\n")
                request(wifiAPIpath + 'scan', function (o) {
                    // log the json response
                    console.log(o.responseText)
                })
            }
        }
    }
    function request(url, callback) {
        var xhr = new XMLHttpRequest()
        xhr.onreadystatechange = (function (myxhr) {
            return function () {
                if (xhr.readyState == 4 && xhr.status == 200)
                    callback(myxhr)
            }
        })
        (xhr)
        xhr.open('GET', url, false)
        xhr.send('')
    }

    function securityType(security) {
       if (security === "Open")
           return "unsecured"
       else
           return "secured"
    }

    Component {
        id: wifiDevice
        Rectangle {
            height: 150
            width: parent.width
            color: "#222"
            Image {
                anchors.top: parent.top
                anchors.topMargin: 7
                anchors.left: parent.left
                width: 70
                height: 50
                id: icon
                source: {
                    if (securityType(security) === "unsecured") {
                        if (strength < 30)
                            source = "images/HMI_Settings_Wifi_1Bar.svg"
                        else if (strength >= 30 && strength < 50)
                            source = "images/HMI_Settings_Wifi_2Bars.svg"
                        else if (strength >= 50 && strength < 70)
                            source = "images/HMI_Settings_Wifi_3Bars.svg"
                        else
                            source = "images/HMI_Settings_Wifi_Full.svg"
                    } else {
                        if (strength < 30)
                            source = "images/HMI_Settings_Wifi_Locked_1Bar.svg"
                        else if (strength >= 30 && strength < 50)
                            source = "images/HMI_Settings_Wifi_Locked_2Bars.svg"
                        else if (strength >= 50 && strength < 70)
                            source = "images/HMI_Settings_Wifi_Locked_3Bars.svg"
                        else
                            source = "images/HMI_Settings_Wifi_Locked_Full.svg"
                    }
                }
            }
            Column {
                anchors.left: icon.right
                anchors.leftMargin: 10
                Text {
                    text: name
                    font.pointSize: 30
                    font.bold: {
                        if ((serviceState === "ready")
                                || serviceState === "online")
                            font.bold = true
                        else
                            font.bold = false
                    }
                    color: {
                        if ((serviceState === "ready")
                                || serviceState === "online")
                            color = "#00ff00"
                        else
                            color = "#ffffff"
                    }
                }
                Text {
                    visible: ((serviceState === "ready")
                              || serviceState === "online") ? true : false
                    text: "connected, " + address
                    font.pointSize: 18
                    color: "#ffffff"
                    font.italic: true
                }
            }
            Button {
                id: connectButton
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 5
                width: 250

                MouseArea {
                    anchors.fill: parent

                    Text {
                        anchors.fill: parent
                        id: buttonTextLabel
                        font.pixelSize: 15
                        font.bold: true
                        color: "black"
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: {
                            if ((serviceState === "ready")
                                    || serviceState === "online")
                                text = "Forget"
                            else
                                text = "Connect"
                        }
                    }

                    onClicked: {

                        //connectButton.border.color = "steelblue"
                        if ((serviceState === "ready")
                                || serviceState === "online") {

                            //means we are connected
                            console.log("Disconnecting from", index, " ,", name)
                            request(wifiAPIpath + 'disconnect?network=' + index,
                                    function (o) {

                                        //showRequestInfo(o.responseText)
                                        console.log(o.responseText)
                                    })
                        } else {
                            console.log("Conect to", index, " ,", name)

                            //passwordDialog.open()
                            request(wifiAPIpath + 'connect?network=' + index,
                                    function (o) {

                                        // log the json response
                                        //showRequestInfo(o.responseText)
                                        console.log(o.responseText)
                                    })
                        }
                    }
                }
            }

            Button {
                id: passwordButton
                anchors.top: parent.top
                anchors.right: parent.right
                width: 40
                visible: (securityType(security) === "unsecured") ? false : true

                //anchors.rightMargin: connectButton.width + 5
                //buttonText: "Connect"
                text: {
                    "Key" //or some icon?
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {

                        //connectButton.border.color = "steelblue"
                        passwordInputText.visible = true
                        connectButton.visible = false
                        passwordValidateButton.visible = true

                        System.showKeyboard = visible

                        //passwordInputText.o
                        periodicRefresh.stop()

                        var passkey = passwordInputText.text.valueOf()

                        //var passkey = 'randompassword'
                        console.log("Disconnecting from", index, " ,", name)
                    }
                }
            }

            Button {
                id: passwordValidateButton
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: connectButton.width + 5
                width: 40
                visible: false

                //anchors.rightMargin: connectButton.width + 5
                //buttonText: "Connect"
                text: {
                    "ok" //or some icon?
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        //passwordInputText = ""
                        var passkey = passwordInputText.text.valueOf()
                        console.log("Validating", passkey)
                        System.showKeyboard = false

                        console.log("Passkey is", passkey)
                        request(wifiAPIpath + 'security?passkey=' + passkey,
                                function (o) {

                                    //showRequestInfo(o.responseText)
                                    console.log(o.responseText)
                                })
                        passwordValidateButton.visible = false
                        passwordInputText.visible = false
                        connectButton.visible = true

                        keyboard.currentString = ""

                        periodicRefresh.start()
                    }
                }
            }

            TextInput {
                id: passwordInputText
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 5

                font.pointSize: 15
                color: "#ffffff"

                width: connectButton.width
                visible: false
                text: keyboard.currentString
            }
        }
    }
    ListView {
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: 70
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 150
        model: networkList //WifiList {}
        delegate: wifiDevice
        clip: true
    }

    //Timer for periodic refresh; this is BAD solution, need to figure out how to subscribe for events
    Timer {
        id: periodicRefresh
        interval: 5000 // 5seconds
        onTriggered: {

            networkList.clear()
            request(wifiAPIpath + 'scan_result', function (o) {
                // log the json response
                console.log(o.responseText)

                // translate response into object
                var jsonObject = eval('(' + o.responseText + ')')
                var jsonObjectNetworks = eval('(' + JSON.stringify(
                                                  jsonObject.response) + ')')
                console.log("WiFi list refreshed")
                //console.log(jsonObject.response)
                for (var i = 0; i < jsonObjectNetworks.length; i++) {
                    networkList.append({
                                           number: jsonObjectNetworks[i].Number,
                                           name: jsonObjectNetworks[i].ESSID,
                                           strength: jsonObjectNetworks[i].Strength,
                                           serviceState: jsonObjectNetworks[i].State,
                                           security: jsonObjectNetworks[i].Security,
                                           address: jsonObjectNetworks[i].IPAddress
                                       })
                }
            })
            start()
        }
    }
}
