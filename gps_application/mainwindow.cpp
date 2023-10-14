#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    ui->quickWidget->setSource(QUrl( QStringLiteral( "qrc:/map.qml" )));
    ui->quickWidget->show();

    auto obj = ui->quickWidget->rootObject();
    connect( this, SIGNAL( setCenter( QVariant, QVariant ) ), obj, SLOT( setCenter( QVariant, QVariant ) ) );
    connect( this, SIGNAL( setLocationMarker( QVariant, QVariant ) ), obj, SLOT( setLocationMarker( QVariant, QVariant ) ) );
    emit setCenter( 52.8822568, 15.5228932 );
    emit setLocationMarker( 52.8822568, 15.5228932 );
}

MainWindow::~MainWindow()
{
    delete ui;
}

