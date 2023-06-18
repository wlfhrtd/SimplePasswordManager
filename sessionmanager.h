#ifndef SESSIONMANAGER_H
#define SESSIONMANAGER_H

#include <QObject>


class SessionManager : public QObject
{
private:
    Q_OBJECT

    Q_PROPERTY(QString username READ username WRITE setUsername NOTIFY usernameChanged);
    Q_PROPERTY(QString password READ password WRITE setPassword NOTIFY passwordChanged);
    Q_PROPERTY(QString currentFilePath READ currentFilePath WRITE setCurrentFilePath NOTIFY currentFilePathChanged);


    QString m_username;
    QString m_password;
    QString m_current_file_path;

public:
    explicit SessionManager(QObject *parent = nullptr);


    inline QString username() const { return m_username; }
    void setUsername(const QString &newUsername);

    inline QString password() const { return m_password; }
    void setPassword(const QString &newPassword);

    inline QString currentFilePath() const { return m_current_file_path; }
    void setCurrentFilePath(const QString &newCurrentFilePath);

signals:
    void usernameChanged();
    void passwordChanged();
    void currentFilePathChanged();

};

#endif // SESSIONMANAGER_H
