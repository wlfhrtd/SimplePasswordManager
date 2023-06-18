#ifndef LOCALMODELLOADER_H
#define LOCALMODELLOADER_H

#include <QObject>
#include <QFile>
#include <QUrl>

#include "spmmodel.h"
// Qt-AES
#include <QCryptographicHash>
#include "qaesencryption.h"


class LocalModelLoader : public QObject
{
private:
    Q_OBJECT

    Q_PROPERTY(QString errorMessage READ errorMessage CONSTANT)


    QString m_error_message;

public:
    explicit LocalModelLoader(QObject *parent = nullptr);


    inline QString errorMessage() const { return m_error_message; }

public slots:
    Q_INVOKABLE void loadWithCredentials(QObject* parent, QObject* currentModel, QString username, QString password, QString filename);
    Q_INVOKABLE void create(QObject* parent, QObject* currentModel);
    Q_INVOKABLE void saveWithCredentials(SPMModel* model, QString username, QString password, QString filename);
    Q_INVOKABLE void unloadModel(QObject *parent, QObject *currentModel);

signals:
    void modelLoaded();
    void modelCreated();
    void modelSaved();
    void modelDestroyed();

    void errorOccurred();

};

#endif // LOCALMODELLOADER_H
