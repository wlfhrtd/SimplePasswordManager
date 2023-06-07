#include "sessionmanager.h"


SessionManager::SessionManager(QObject *parent)
    : QObject{parent}
    , m_username("")
    , m_password("")
    , m_current_file_path("")
{

}


void SessionManager::setUsername(const QString &newUsername)
{
    if (m_username == newUsername) {
        return;
    }

    m_username = newUsername;

    emit usernameChanged();
}

void SessionManager::setPassword(const QString &newPassword)
{
    if (m_password == newPassword) {
        return;
    }

    m_password = newPassword;

    emit passwordChanged();
}

void SessionManager::setCurrentFilePath(const QString &newCurrentFilePath)
{
    if (m_current_file_path == newCurrentFilePath) {
        return;
    }

    m_current_file_path = newCurrentFilePath;

    emit currentFilePathChanged();
}
