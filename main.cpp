#include <QGuiApplication>
#include <QQmlApplicationEngine>

// #include "spmmodel.h"
#include "qclipboardqtquickwrapper.h"
#include "localmodelloader.h"
#include "sessionmanager.h"
#include "settingsmanager.h"
// #include "spmsortfilterproxymodel.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // qmlRegisterType<SPMModel>("com.application.spmmodel", 1, 0, "SPMModel");
    qmlRegisterType<QClipboardQtQuickWrapper>("com.application.qclipboardqtquickwrapper", 1, 0, "QClipboardQtQuickWrapper");
    qmlRegisterType<LocalModelLoader>("com.application.localmodelloader", 1, 0, "LocalModelLoader");
    qmlRegisterType<SessionManager>("com.application.sessionmanager", 1, 0, "SessionManager");
    qmlRegisterType<SettingsManager>("com.application.settingsmanager", 1, 0, "SettingsManager");
    // qmlRegisterType<SPMSortFilterProxyModel>("com.application.spmsortfilterproxymodel", 1, 0, "SPMSortFilterProxyModel");

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SimplePasswordManager", "Main");

    return app.exec();
}
