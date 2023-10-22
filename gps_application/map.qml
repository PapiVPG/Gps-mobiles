import QtQuick 2.12
//import QtLocation 5.11
//import QtPositioning 5.11
import GeneralMagic 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle{
    Component.onCompleted:
    {
        ServicesManager.logLevel = ServicesManager.Error;
        ServicesManager.settings.allowInternetConnection = true;

        var updater = ServicesManager.contentUpdater( ContentItem.Type.RoadMap );
        updater.autoApplyWhenReady = true;
        updater.update();
    }

    function distance( meters ){
        return meters >= 1000 ? ( meters / 1000. ).toFixed( 3 ) + "km"
                              : meters.toFixed( 0 ) + "m"
    }

    MapView
    {
        id: map
        anchors.fill: parent
        viewAngle: 25
        zoomLevel: 69

        Button {
            anchors {
                left: parent.left
                bottom: parent.bottom
                margins: 5
            }
            enabled: !navigation.active
            text: "button"
            onClicked: routing.update()
        }

        Button{
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
        waypoints: LandmarkList {
            Landmark {
                name: "Departure"
                coordinates: Coordinates{
                    latitude: 52.8822568
                    longitude: 15.5228932
                }
            }
            Landmark {
                name: "Destination"
                coordinates: Coordinates{
                    latitude: 48.874630
                    longitude: 2.331512
                }
            }
        }
        onFinished: {
            map.routeCollection.set( routeList )
            map.centerOnRouteList( routeList )
        }
    }
}
