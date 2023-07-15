#include "localmodelloader.h"


LocalModelLoader::LocalModelLoader(QObject *parent)
    : QObject{parent}
    , m_error_message("")
{

}


void LocalModelLoader::loadWithCredentials(
    QObject* parent, QObject* currentModel, QString username, QString password, QString filename)
{
    // workaround for windows not working with file:/// scheme from QML dialogs
    QString path = QUrl(filename).toString(QUrl::PreferLocalFile);

    QFile inputFile(path);
    if (!inputFile.open(QIODevice::ReadOnly)) {
        m_error_message = QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN QFILE IN READONLY MODE");

        emit errorOccurred();

        return;
    }

    QByteArray encryptedCompressedInputData = inputFile.readAll();

    inputFile.close();
    // authorization - username/password
    // decryption of qCompressed data
    // Sha256 hash - 32 bytes length; Md5 hash - 16 bytes length
    QByteArray hashedKey = QCryptographicHash::hash(username.toLocal8Bit(), QCryptographicHash::Sha256);
    QByteArray hashedIV = QCryptographicHash::hash(password.toLocal8Bit(), QCryptographicHash::Md5);

    QByteArray decoded = QAESEncryption::Decrypt(
        QAESEncryption::AES_256, QAESEncryption::OFB, encryptedCompressedInputData, hashedKey, hashedIV);
    // optional; depends on MODE (ECB, CBC, CFB ??) and blocksize~key~iv
    // QByteArray decodedWithoutPadding = QAESEncryption::RemovePadding(decoded);
    // shouldn't be needed with fixed hash length

    // qUncompress
    QByteArray decompressedInputData = qUncompress(decoded);
    if (decompressedInputData.isEmpty()) {
        m_error_message = QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "QUNCOMPRESS: INPUT DATA IS CORRUPTED");

        emit errorOccurred();

        return;
    }

    QDataStream inputDataStream(&decompressedInputData, QIODevice::ReadOnly);
    // handle model and memory
    SPMSortFilterProxyModel* proxyModel = new SPMSortFilterProxyModel(true, parent);
    SPMModel* sourceModel = new SPMModel(proxyModel);

    proxyModel->setSourceModel(sourceModel);

    delete currentModel;
    currentModel = nullptr;

    parent->setProperty("model", QVariant::fromValue(proxyModel));

    inputDataStream >> *sourceModel;

    emit modelLoaded();
}

void LocalModelLoader::create(QObject *parent, QObject *currentModel)
{
    // manual memory management instead of destroying parent obj
    SPMSortFilterProxyModel* proxyModel = new SPMSortFilterProxyModel(true, parent);
    SPMModel* sourceModel = new SPMModel(proxyModel);

    proxyModel->setSourceModel(sourceModel);

    delete currentModel;
    currentModel = nullptr;

    parent->setProperty("model", QVariant::fromValue(proxyModel));

    emit modelCreated();
}

void LocalModelLoader::saveWithCredentials(
    SPMSortFilterProxyModel* proxyModel, QString username, QString password, QString filename)
{
    // workaround for windows not working with file:/// scheme from QML dialogs
    QString path = QUrl(filename).toString(QUrl::PreferLocalFile);

    QFile outputFile(path);
    if (!outputFile.open(QIODevice::WriteOnly)) {
        m_error_message = QString::asprintf(
            "file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN QFILE WITH WRITEONLY FLAG");

        emit errorOccurred();

        return;
    }

    QByteArray outputData;
    QDataStream outputStream(&outputData, QIODevice::WriteOnly);
    outputStream << *((SPMModel*)proxyModel->sourceModel());

    QByteArray compressed = qCompress(outputData, 9);
    // authorization - username/password
    // encryption of qCompressed data
    // Sha256 hash - 32 bytes length; Md5 hash - 16 bytes length
    QByteArray hashedKey = QCryptographicHash::hash(username.toLocal8Bit(), QCryptographicHash::Sha256);
    QByteArray hashedIV = QCryptographicHash::hash(password.toLocal8Bit(), QCryptographicHash::Md5);

    QByteArray encrypted = QAESEncryption::Crypt(QAESEncryption::AES_256, QAESEncryption::OFB, compressed, hashedKey, hashedIV);

    if (outputFile.write(encrypted) == -1) {
        m_error_message = QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "ERROR OCCURRED WHILE WRITING INTO QFILE");

        emit errorOccurred();

        return;
    }

    if (!outputFile.flush()) {
        m_error_message = QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "ERROR OCCURRED WHILE FLUSHING INTO FILE");

        emit errorOccurred();

        return;
    }

    outputFile.close();

    emit modelSaved();
}

void LocalModelLoader::unloadModel(QObject *parent, QObject *currentModel)
{
    // manual memory management instead of destroying parent obj
    delete currentModel;
    currentModel = nullptr;

    parent->setProperty("model", QVariant::fromValue(nullptr));

    emit modelDestroyed();
}
