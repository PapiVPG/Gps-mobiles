import QtQuick 2.12
//import QtLocation 5.11
//import QtPositioning 5.11
import GeneralMagic 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle{
    property int zoomValue: 70

    LandmarkList {
        id: routingWaypoints
    }
    Component {
        id: landmarkComponent
        Landmark {}
    }

    Component.onCompleted: {
        ServicesManager.logLevel = ServicesManager.Error;
        ServicesManager.settings.allowInternetConnection = true;

        var updater = ServicesManager.contentUpdater( ContentItem.Type.RoadMap );
        updater.autoApplyWhenReady = true;
        updater.update();
    }

    Timer {
        id: searchTimer
        interval: 500
        onTriggered: {
            searchService.searchNow();
        }
    }

    Timer {
        id: searchTimer_2
        interval: 500
        onTriggered: {
            searchService_2.searchNow();
        }
    }

    SearchService {
        id: searchService
        filter: searchBar.text
        searchMapPOIs: true
        searchAddresses: true
        limit: 10

        function searchNow() {
            searchTimer.stop();
            cancel();
            referencePoint = map.cursorWgsPosition();
            search();
        }
    }

    SearchService {
        id: searchService_2
        filter: searchBar_2.text
        searchMapPOIs: true
        searchAddresses: true
        limit: 10

        function searchNow() {
            searchTimer_2.stop();
            cancel();
            referencePoint = map.cursorWgsPosition();
            search();
        }
    }


    MapView {
        id: map
        anchors.fill: parent
        viewAngle: 25
        zoomLevel: zoomValue
        cursorVisibility: false


        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 15
            anchors.leftMargin: 15
            anchors.rightMargin: 15
            anchors.bottomMargin: 30

            TextField {
                id: searchBar
                Layout.fillWidth: true
                placeholderText: qsTr( "Where would you like to go?" )
                onTextChanged: searchTimer.restart()
                onEditingFinished: searchService.searchNow()
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Qt.rgba( 0, 0, 0, 0.5 )
                visible: searchBar.focus
                ListView {
                    id: searchList
                    anchors.fill: parent
                    clip: true
                    model: searchService
                    delegate: Item {
                        height: row.height
                        Rectangle {
                            width: searchList.width
                            height: row.height
                            opacity: 0.6
                            visible: searchList.currentIndex == index
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "lightsteelblue" }
                                GradientStop { position: 0.5; color: "blue" }
                                GradientStop { position: 1.0; color: "lightsteelblue" }
                            }
                        }
                        RowLayout {
                            id: row
                            IconView {
                                iconSource: landmark.icon
                                Layout.maximumHeight: row.height
                                Layout.maximumWidth: row.height
                                width: height
                                height: row.height
                            }
                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: landmark.name + " (" + distance( landmark.coordinates.distance( searchService.referencePoint ) ) + ")"
                                    color: "white"
                                    font.pixelSize: 16
                                    wrapMode: Text.WrapAnywhere
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: landmark.description
                                    color: "white"
                                    font.pixelSize: 14
                                    font.italic: true
                                    wrapMode: Text.WrapAnywhere
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: row
                            onClicked: {
                                searchList.currentIndex = index
                                var landmark = landmarkComponent.createObject( routingWaypoints );
                                landmark.coordinates = searchService.get( index ).coordinates
                                routingWaypoints.append( landmark );
                                map.centerOnCoordinates( searchService.get( index ).coordinates, zoomValue );
                                searchBar.focus = true;
                            }
                        }
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }

            TextField {
                id: searchBar_2
                Layout.fillWidth: true
                placeholderText: qsTr( "Where would you like to go?" )
                onTextChanged: searchTimer_2.restart()
                onEditingFinished: searchService_2.searchNow()
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: Qt.rgba( 0, 0, 0, 0.5 )
                visible: searchBar_2.focus
                ListView {
                    id: searchList_2
                    anchors.fill: parent
                    clip: true
                    model: searchService_2
                    delegate: Item {
                        height: row_2.height
                        Rectangle {
                            width: searchList_2.width
                            height: row_2.height
                            opacity: 0.6
                            visible: searchList_2.currentIndex == index
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "lightsteelblue" }
                                GradientStop { position: 0.5; color: "blue" }
                                GradientStop { position: 1.0; color: "lightsteelblue" }
                            }
                        }
                        RowLayout {
                            id: row_2
                            IconView {
                                iconSource: landmark.icon
                                Layout.maximumHeight: row_2.height
                                Layout.maximumWidth: row_2.height
                                width: height
                                height: row_2.height
                            }
                            ColumnLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Text {
                                    Layout.fillWidth: true
                                    text: landmark.name + " (" + distance( landmark.coordinates.distance( searchService_2.referencePoint ) ) + ")"
                                    color: "white"
                                    font.pixelSize: 16
                                    wrapMode: Text.WrapAnywhere
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: landmark.description
                                    color: "white"
                                    font.pixelSize: 14
                                    font.italic: true
                                    wrapMode: Text.WrapAnywhere
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: row_2
                            onClicked: {
                                searchList_2.currentIndex = index
                                var landmark = landmarkComponent.createObject( routingWaypoints );
                                landmark.coordinates = searchService_2.get( index ).coordinates
                                routingWaypoints.append( landmark );
                                map.centerOnCoordinates( searchService_2.get( index ).coordinates, zoomValue );
                                searchBar_2.focus = true;
                            }
                        }
                    }
                }
            }

            RowLayout {
                Button {
                    enabled: searchService.length
                    text: "Highlight list on the map "
                    onClicked:  {
                        map.highlightLandmarkList( searchService )
                    }
                }
                Button {
                    text: "Hide Highlighted list"
                    onClicked: map.hideHighlights()
                }
            }
        }

        Button {
            anchors {
                left: parent.left
                bottom: parent.bottom
                margins: 5
            }
            enabled: !navigation.active && routingWaypoints.length > 1
            text: "button"
            onClicked: routing.update()
        }

        Button {
            anchors {
                right: parent.right
                bottom: parent.bottom
                margins: 5
            }
            enabled: map.routeCollection.mainRoute.valid
            text: navigation.active ? "Stop" : "Start Navigation"
            onClicked: navigation.active = !navigation.active
        }

        Rectangle {
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            height: 60
            color: Qt.rgba( 1, 1, 1, 0.7 )
            visible: navigation.active

            RowLayout {
                anchors.fill: parent

                DynamicIconView {
                    Layout.fillHeight: true
                    width: height
                    arrowInner:  "darkblue"
                    arrowOuter: "gold"
                    slotInner: "silver"
                    slotOuter: "gold"
                    iconSource: navigation.currentInstruction.nextNextTurnDynamicIcon
                }

                Label {
                    Layout.fillWidth: true
                    font.pixelSize: 16
                    text: { navigation.currentInstruction.nextStreetName
                        + " ( " + distance( navigation.currentInstruction.distanceToNextTurn ) + " )"
                    }
                }
            }
        }

        onRouteSelected: {
            routeCollection.mainRoute = route
            centerOnRoute( route )
        }

        NavigationService {
            id: navigation
            route: map.routeCollection.mainRoute
            simulation: true

            onActiveChanged: {
                if( active ){
                    map.startFollowingPosition()
                    map.routeCollection.clear()
                    map.routeCollection.add( route )
                }
            }
            onDestinationReached: map.routeCollection.clear()
            onNavigationRouteUpdated: {
                map.routeCollection.clear()
                map.routeCollection.add( route )
            }
        }

        RoutingService {
            id: routing
            type: Route.Type.Fastest
            transportMode: Route.Car
            waypoints: routingWaypoints
            onFinished: {
                map.routeCollection.set( routeList )
                map.centerOnRouteList( routeList )
            }
        }
    }
    function distance( meters ){
        return meters >= 1000 ? ( meters / 1000. ).toFixed( 3 ) + "km"
                              : meters.toFixed( 0 ) + "m"
    }
}
