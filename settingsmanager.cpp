#include "settingsmanager.h"


SettingsManager::SettingsManager(QObject *parent)
    : QObject{parent}
{

}


void SettingsManager::saveSettings(QString identifier1, QString identifier2, QVariantMap settingsObj)
{
    QStringList keys = settingsObj.keys();
    QList<QVariant> values = settingsObj.values();

    QSettings settings(identifier1, identifier2);

    for (int i = 0; i < settingsObj.size(); ++i) {
        settings.setValue(keys[i], values[i]);
    }
}

QVariantMap SettingsManager::loadSettings(QString identifier1, QString identifier2)
{
    QVariantMap settingsObj;

    QSettings settings(identifier1, identifier2);

    QStringList keys = settings.allKeys();

    for (int i = 0; i < keys.size(); ++i) {
        settingsObj[keys[i]] = settings.value(keys[i], QVariant(0));
    }

    return settingsObj;
}
