/*
 * Copyright (C) 2015 Florent Revest <revestflo@gmail.com>
 *               2014 Aleksi Suomalainen <suomalainen.aleksi@gmail.com>
 *               2012 Jolla Ltd.
 * All rights reserved.
 *
 * You may use this file under the terms of BSD license as follows:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the author nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import QtQuick 2.0
import org.asteroid.controls 1.0
import org.nemomobile.lipstick 0.1
import "../desktop.js" as Desktop

Item {
    id: notificationWindow
    property alias summary: summary.text
    property alias body: body.text
    property alias icon: icon.source
    width: Desktop.instance.parent.width
    height: Desktop.instance.parent.height
    rotation: Desktop.instance.parent.rotation
    x: Desktop.instance.parent.x
    y: Desktop.instance.parent.y

    MouseArea {
        id: notificationArea
        anchors.top: parent.top
        anchors.left: parent.left
        width: notificationWindow.width
        height: 80
        enabled: notificationPreview.state == "show"

        onClicked: if (notificationPreviewPresenter.notification != null) notificationPreviewPresenter.notification.actionInvoked("default")

        Rectangle {
            id: notificationPreview
            anchors.fill: parent
            color: "#DD222222"

            states: [
                State {
                    name: "show"
                    PropertyChanges {
                        target: notificationPreview
                        opacity: 1
                    }
                    StateChangeScript {
                        name: "notificationShown"
                        script: {
                            notificationTimer.start()
                        }
                    }
                },
                State {
                    name: "hide"
                    PropertyChanges {
                        target: notificationPreview
                        opacity: 0
                    }
                    StateChangeScript {
                        name: "notificationHidden"
                        script: {
                            notificationTimer.stop()
                            notificationPreviewPresenter.showNextNotification()
                        }
                    }
                }
            ]
            Rectangle {
                id: dimmer

                height: 15

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right

                gradient: Gradient {
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 1.0; color: "#111111" }
                }
            }
            transitions: [
                Transition {
                    to: "show"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 200 }
                        ScriptAction { scriptName: "notificationShown" }
                    }
                },
                Transition {
                    to: "hide"
                    SequentialAnimation {
                        NumberAnimation { property: "opacity"; duration: 200 }
                        ScriptAction { scriptName: "notificationHidden" }
                    }
                }
            ]

            Timer {
                id: notificationTimer
                interval: 3000
                repeat: false
                onTriggered: notificationPreview.state = "hide"
            }

            Image {
                id: icon
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 10
                }
                width: 50
                height: width
                source: {
                            var notif = notificationPreviewPresenter.notification;
                            if(notif==null)
                                return "";
                            else if(notif.icon == "")
                                return "image://theme/user-info";
                            else if(notif.icon.indexOf("/") == 0)
                                return "file://" + notif.icon;
                            else
                                return "image://theme/" + notif.icon;
                        }
            }

            Text {
                id: summary
                anchors {
                    top: parent.top
                    left: icon.right
                    right: parent.right
                    topMargin: 7
                    leftMargin: 26
                    rightMargin: 5
                }
                font {
                    pixelSize: 36
                }
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewSummary : ""
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            Text {
                id: body
                anchors {
                    bottom: parent.bottom
                    left: summary.left
                    right: summary.right
                    bottomMargin: 7
                }
                font {
                    pixelSize: 18
                    bold: true
                }
                text: notificationPreviewPresenter.notification != null ? notificationPreviewPresenter.notification.previewBody : ""
                color: "white"
                clip: true
                elide: Text.ElideRight
            }

            Connections {
                target: notificationPreviewPresenter;
                onNotificationChanged: notificationPreview.state = (notificationPreviewPresenter.notification != null) ? "show" : "hide"
            }
        }
    }
}
