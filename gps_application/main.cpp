#include "mainwindow.h"

#include <QApplication>

int main(int argc, char *argv[])
{

    QCoreApplication::setAttribute( Qt::AA_EnableHighDpiScaling );

    QApplication app(argc, argv);

    QQmlApplicationEngine engine;
    const QUrl url( QStringLiteral( "qrc:/map.qml" ) );
    QObject::connect( &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url]( QObject *obj, const QUrl &objUrl ){
            if ( !obj && url == objUrl ){
                QCoreApplication::exit( -1 );
            }
    }, Qt::QueuedConnection );


    engine.rootContext()->setContextProperty( "__my_secret_token" , "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiIzYTE4NjY1NC01MjI4LTQ1MjgtODNkMi1jNzAxOThmZTY3MGIiLCJleHAiOjE2OTgwOTQ4MDAsImlzcyI6IkdlbmVyYWwgTWFnaWMiLCJqdGkiOiIxM2RmYWQzYy00MmI0LTQ3NDQtYjExYy1lNGRiMmM5MTU2NmQiLCJuYmYiOjE2OTc0OTA4NDJ9.k6hc3xU6ZoAtspNAqNY0hNb0uk2etTrPlCDK4AQOLtRaz6FEEA-asovijy8IpiWJjbXDJaq2bwwfSAXXNlibkQ" );
//    MainWindow window;
//    window.show();
    engine.load(url);



    return app.exec();
}
