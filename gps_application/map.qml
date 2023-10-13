import QtQuick 2.15
import QtLocation

Rectangle{
    Plugin{
        id: mapPlugin
        name: "osm"
    }
    Map{
        id:map
        plugin: mapPlugin
        anchors.fill: parent
        center: QtPositioning.coordinate(25,125)
        zoomLevel: 14
    }
}
