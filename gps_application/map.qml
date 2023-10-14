import QtQuick 2.15
import QtLocation 5.11
import QtPositioning 5.11

Rectangle{
    id: window
    property double latitude: 25.0434 // or current localization
    property double longitude: 25.0434 // or current localization

    Plugin{
        id:google_map_view
        name:"osm"
    }

    Map{
        id:map_view
        anchors.fill: parent
        plugin: google_map_view
        center: QtPositioning.coordinate(52.8822568,15.5228932)
        zoomLevel: 15
    }
    MouseArea{
        anchors.fill: parent

        property int lastX : 0
        property int lastY : 0

        onPressed : {
            lastX = mouse.x
            lastY = mouse.y
        }

        onPositionChanged: {
            map_view.pan(lastX-mouse.x, lastY-mouse.y)
            lastX = mouse.x
            lastY = mouse.y
        }
//        onClicked:  lineEdit.text = ""+ map_view.toCoordinate(Qt.point(mouse.x,mouse.y))
    }
    function setCenter( lati, longi ){
        map_view.pan( latitude - lati, longitude - longi )
        latitude = lati
        longitude = longi
    }
}
