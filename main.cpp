#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "qclipboardqtquickwrapper.h"
#include "localmodelloader.h"
#include "sessionmanager.h"
#include "settingsmanager.h"


int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<QClipboardQtQuickWrapper>("com.application.qclipboardqtquickwrapper", 1, 0, "QClipboardQtQuickWrapper");
    qmlRegisterType<LocalModelLoader>("com.application.localmodelloader", 1, 0, "LocalModelLoader");
    qmlRegisterType<SessionManager>("com.application.sessionmanager", 1, 0, "SessionManager");
    qmlRegisterType<SettingsManager>("com.application.settingsmanager", 1, 0, "SettingsManager");

    QQmlApplicationEngine engine;
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed,
        &app, []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SimplePasswordManager", "Main");

    return app.exec();
}
