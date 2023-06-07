#ifndef LOCALMODELLOADER_H
#define LOCALMODELLOADER_H

#include <QObject>
#include <QFile>
#include <QDir>

#include <quazipnewinfo.h>
#include <quazip.h>
#include <quazipfile.h>

#include "spmmodel.h"

#include <QCryptographicHash>
#include "qaesencryption.h"


class LocalModelLoader : public QObject
{
private:
    Q_OBJECT
    QML_ELEMENT


public:
    explicit LocalModelLoader(QObject *parent = nullptr);

    // Q_INVOKABLE void save(SPMModel* model);
    Q_INVOKABLE void loadWithCredentials(QObject* parent, QObject* currentModel, QString username, QString password, QString filename);
    Q_INVOKABLE void create(QObject* parent, QObject* currentModel);
    Q_INVOKABLE void saveWithCredentials(SPMModel* model, QString username, QString password, QString filename);
    Q_INVOKABLE void unloadModel(QObject *parent, QObject *currentModel);

signals:

};

#endif // LOCALMODELLOADER_H
