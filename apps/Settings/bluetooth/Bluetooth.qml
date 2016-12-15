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
    icon: '/bluetooth/images/HMI_Settings_BluetoothIcon.svg'
    title: 'Bluetooth'
    checkable: true

    property string protocol: 'http://'
    property string ipAddress: '127.0.0.1'
    property string portNumber: Qt.application.arguments[1]
    property string tokenString: Qt.application.arguments[2]
    property string btAPI: '/api/Bluetooth-manager/'
    property string btAPIpath: protocol + ipAddress + ':' + portNumber + btAPI
    property var jsonObjectBT
    property string currentState: 'idle'

    Text {
        id: log
        anchors.fill: parent
        anchors.margins: 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        //text: "log"
    }

    onCheckedChanged: {
        console.log("Bluetooth set to", checked)
        if (checked == true) {
            request(btAPIpath + 'power?value=1', function (o) {
                // log the json response
                console.log(o.responseText)
            })
            request(btAPIpath + 'start_discovery', function (o) {
               console.log(o.responseText)
            })
            currentState = 'discovering'
            //search_device()
            periodicRefresh.start()

        } else {
            //console.log(networkPath)
            btDeviceList.clear()
            periodicRefresh.stop()
            request(btAPIpath + 'stop_discovery', function (o) {
               // log the json response
               console.log(o.responseText)
            })
            request(btAPIpath + 'power?value=0', function (o) {
                // log the json response
                //showRequestInfo(o.responseText)
                console.log(o.responseText)
            })
            currentState = 'idle'
        }
    }

    ListModel {
      id: btDeviceList
    }

    Rectangle {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.margins: 80
      width: buttonScan.width + 10
      height: buttonScan.height + 10
      color: "#222"
      border.color: "white"

                Button {
                    id: buttonScan
                    anchors.centerIn: parent
                    width: 100
                    text: "SEARCH"

                    MouseArea {
                        //id: mouseArea
                        anchors.fill: parent

                        onClicked: {
                            if (buttonScan.text == "SEARCH"){
                                request(btAPIpath + 'start_discovery', function (o) {

                                    // log the json response
                                    //showRequestInfo(o.responseText)
                                    console.log(o.responseText)
                                })
                                buttonScan.text = "CANCEL"
                                currentState = 'discovering'
                                periodicRefresh.start()
                            }else{
                                request(btAPIpath + 'stop_discovery', function (o) {

                                    // log the json response
                                    //showRequestInfo(o.responseText)
                                    console.log(o.responseText)
                                })
                                buttonScan.text = "SEARCH"
                                currentState = 'idle'
                                //periodicRefresh.stop()  //in order to update the content from bluez
                            }
                        }
                    }
                }
      }

      function request(url, callback) {
            var xhr = new XMLHttpRequest()
            xhr.onreadystatechange = (function (myxhr) {
            return function () {
                     if (xhr.readyState == 4 && xhr.status == 200){
                         callback(myxhr)
                     }
                 }
             })(xhr)
             xhr.open('GET', url, false)
             xhr.send('')
       }

      Component {
         id:blueToothDevice
         Rectangle {
         height: 150
         width: parent.width
         color: "#222"

         Column {
             Text {
                id: btName
                text: deviceName
                font.pointSize: 36
                color: "#ffffff"
             }
             Text {
                id: btAddr
                text: deviceAddress
                visible: false
             }
             Text {
                text: {
                  if ((devicePairable === "True")
                         && (deviceConnect === "False"))
                         text = "paired"
                  else if ((devicePairable === "True")
                           && (deviceConnect === "True")
                           && (connectAVP) === "True")
                           text = "AV Connection"
                  else if ((devicePairable === "True")
                            && (deviceConnect === "True")
                            && (connectHFP) === "True")
                            text = "Handsfree Connection"
                  else
                     text = ""
                }
                font.pointSize: 18
                color: "#ffffff"
                font.italic: true
             }
             Text {
               id: btPairable
               text: devicePairable
               visible: false
             }
             Text {
               id: btConnectstatus
               text: deviceConnect
               visible: false
             }

         }
         Button {
             id: removeButton
             anchors.top:parent.top
             anchors.topMargin: 15
             anchors.right: parent.right
             anchors.rightMargin: 10

             text: "X"
             MouseArea {
                 anchors.fill: parent
                 onClicked: {
                     request(btAPIpath + 'remove_device?value=' + btAddr.text, function (o) {
                         console.log(o.responseText)
                     })
                     btDeviceList.remove(findDevice(btAddr.text))
                 }
             }

         }

         Button {
          id: connectButton
          anchors.top:parent.top
          anchors.topMargin: 15
          anchors.right: removeButton.left
          anchors.rightMargin: 10

          text:(btConnectstatus.text == "True")? "Disconnect":((btPairable.text == "True")? "Connect":"Pair")
          MouseArea {
             anchors.fill: parent
             onClicked: {
                if (currentState == 'discovering'){
                     request(btAPIpath + 'stop_discovery', function (o) {
                       currentState = "idle"
                       console.log(o.responseText)
                     })
                   }
                if (connectButton.text == "Pair"){
                     connectButton.text = "Connect"
                     request(btAPIpath + 'pair?value=' + btAddr.text, function (o) {
                     btPairable.text = "True"
                        console.log(o.responseText)
                     })
                     request(btAPIpath + 'set_property?Address=' + btAddr.text + '\&Property=Trusted\&value=true', function (o) {
                        console.log(o.responseText)
                     })
                 }
                 else if (connectButton.text == "Connect"){
                          connectButton.text = "Disconnect"
                          request(btAPIpath + 'connect?value=' + btAddr.text, function (o) {
                            console.log(o.responseText)
                          })
                 }
                 else if (connectButton.text == "Disconnect"){
                          request(btAPIpath + 'disconnect?value=' + btAddr.text, function (o) {
                            console.log(o.responseText)
                          })
                          connectButton.text = "Connect"
                          btDeviceList.remove(findDevice(btAddr.text))
                  }
              }
            }
          }
        }
      }

      ListView {
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 200
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 150
                model: btDeviceList
                delegate: blueToothDevice
                clip: true
      }

      function findDevice(address){
                for (var i = 0; i < jsonObjectBT.length; i++) {
                    if (address === jsonObjectBT[i].Address){
                        return i
                }
          }
      }
      function search_device(){
                btDeviceList.clear()
                request(btAPIpath + 'discovery_result', function (o) {

                    // log the json response
                    console.log(o.responseText)

                    // translate response into object
                    var jsonObject = eval('(' + o.responseText + ')')

                    jsonObjectBT = eval('(' + JSON.stbtPairableringify(
                                                      jsonObject.response) + ')')

                    console.log("BT list refreshed")

                    //console.log(jsonObject.response)
                    for (var i = 0; i < jsonObjectBT.length; i++) {
                    btDeviceList.append({
                                            deviceAddress: jsonObjectBT[i].Address,
                                            deviceName: jsonObjectBT[i].Name,
                                            devicePairable:jsonObjectBT[i].Paired,
                                            deviceConnect: jsonObjectBT[i].Connected,
                                            connectAVP: jsonObjectBT[i].AVPConnected,
                                            connectHFP: jsonObjectBT[i].HFPConnected
                                        })
                     }
               })
      }

      //Timer for periodic refresh; this is BAD solution, need to figure out how to subscribe for events
      Timer {
                id: periodicRefresh
                interval: (currentState == "idle")? 10000:5000 // 5seconds
                onTriggered: {

                    btDeviceList.clear()

                    request(btAPIpath + 'discovery_result', function (o) {

                        // log the json response
                        console.log(o.responseText)

                        // translate response into object
                        var jsonObject = eval('(' + o.responseText + ')')

                        jsonObjectBT = eval('(' + JSON.stringify(
                                                          jsonObject.response) + ')')

                        console.log("BT list refreshed")

                        //console.log(jsonObject.response)
                        for (var i = 0; i < jsonObjectBT.length; i++) {
                        btDeviceList.append({
                                                deviceAddress: jsonObjectBT[i].Address,
                                                deviceName: jsonObjectBT[i].Name,
                                                devicePairable:jsonObjectBT[i].Paired,
                                                deviceConnect: jsonObjectBT[i].Connected,
                                                connectAVP: jsonObjectBT[i].AVPConnected,
                                                connectHFP: jsonObjectBT[i].HFPConnected
                                            })
                       }
                    })
                    start()
                }
            }
 }

