import QtQuick 2.12
import GeneralMagic 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle{
    id: main
    property int zoom_value: 70
    property int pixel_size: 16
    property int button_margins: 5
    property int layout_margins: 15

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
        onTriggered: searchBar.focus ? searchService.searchNow() : searchService_2.searchNow()
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
            searchTimer.stop();
            cancel();
            referencePoint = map.cursorWgsPosition();
            search();
        }
    }

    MapView {
        id: map
        anchors.fill: parent
        viewAngle: 25
        zoomLevel: zoom_value
        cursorVisibility: false

        LandmarkList {
            id: routingWaypoints
        }
        Component {
            id: landmarkComponent
            Landmark {}
        }

        Rectangle {
            id: searchBar_layout
            anchors {
                left: parent.left
                right: parent. right
                top: parent.top
            }
            height: 120
            color: "#40a347"
            radius: 10
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: layout_margins
            anchors.leftMargin: layout_margins
            anchors.rightMargin: layout_margins
            anchors.bottomMargin: layout_margins * 2

            TextField {
                id: searchBar
                Layout.fillWidth: true
                placeholderText: qsTr( "Where are we starting?" )
                onTextChanged: searchTimer.restart()
                onEditingFinished: searchService.searchNow()
            }

            TextField {
                id: searchBar_2
                Layout.fillWidth: true
                placeholderText: qsTr( "Where would you like to go?" )
                onTextChanged: searchTimer.restart()
                onEditingFinished: searchService_2.searchNow()
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent. right
                top: searchBar_layout.bottom
            }
            height: main.height
            color: Qt.rgba( 0, 0, 0, 0.5 )
            visible: searchBar.focus || searchBar_2.focus
            radius: 10
            ListView {
                id: searchList
                anchors.fill: parent
                clip: true
                model: {
                    if( searchBar.focus )
                        searchService
                    else
                        searchService_2
                }
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
                                font.pixelSize: pixel_size
                                wrapMode: Text.WrapAnywhere
                            }
                            Text {
                                Layout.fillWidth: true
                                text: landmark.description
                                color: "white"
                                font.pixelSize: pixel_size - 2
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

                            if( searchBar.focus ){
                                landmark.coordinates = searchService.get( index ).coordinates
                                routingWaypoints.append( landmark )
                                searchBar.text = searchService.get( index ).name
                                map.centerOnCoordinates( searchService.get( index ).coordinates, zoom_value )
                                searchBar.focus = false
                            } else {
                                landmark.coordinates = searchService_2.get( index ).coordinates
                                routingWaypoints.append( landmark )
                                searchBar_2.text = searchService_2.get( index ).name
                                map.centerOnCoordinates( searchService_2.get( index ).coordinates, zoom_value )
                                searchBar_2.focus = false
                            }
                        }
                    }
                }
            }
        }

        Button {
            id: start_button
            anchors {
                left: parent.left
                bottom: parent.bottom
                right: parent.right
                margins: button_margins
            }
            visible: routingWaypoints.length == 2
            enabled: !navigation.active && routingWaypoints.length > 1
            text: "->"
            onClicked: {
                routing.cancel()
                routing.update()
                searchBar_2.visible = false
                searchBar.visible = false
                searchBar_layout.visible = false
                routingWaypoints.clear()
            }
        }

        Button {
            id: start_navigation_button
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: button_margins
            }
            visible: false
            enabled: start_navigation_button.visible
            text: navigation.active ? "Stop" : "Start Navigation"
            onClicked: {
                navigation.active = !navigation.active
                if( !navigation.active ) {
                    searchBar_2.visible = true
                    searchBar.visible = true
                    searchBar_layout.visible = true
                    start_navigation_button.visible = false
                    map.routeCollection.remove( map.routeCollection.mainRoute )
                    map.routeCollection.clear()
                    searchBar.clear()
                    searchBar_2.clear()
                }
            }
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
                    font.pixelSize: pixel_size
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
                start_navigation_button.visible = true
            }
        }
    }

    function distance( meters ){
        return meters >= 1000 ? ( meters / 1000. ).toFixed( 3 ) + "km"
                              : meters.toFixed( 0 ) + "m"
    }
}
