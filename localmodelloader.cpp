#include "localmodelloader.h"


LocalModelLoader::LocalModelLoader(QObject *parent)
    : QObject{parent}
{

}

/*
//void LocalModelLoader::save(SPMModel* model)
//{
//    QString prefix = QDir::currentPath() + QDir::separator();
//    QString path = prefix + "app.mpdb";

//    QuaZipNewInfo outputInfo("db", path);

//    QuaZip outputZip(path);
//    if (!outputZip.open(QuaZip::mdCreate)) {
//        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN OUTPUTZIP WITH MDCREATE FLAG");

//        return;
//    }

//    QuaZipFile outputZipFile(&outputZip);
//    if (!outputZipFile.open(QIODevice::WriteOnly, outputInfo, "secret")) {   // TODO WORK WITH PASSWORD
//        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN OUTPUTZIPFILE WITH WRITEONLY FLAG");

//        return;
//    }

//    QByteArray outputData;
//    QDataStream outputStream(&outputData, QIODevice::WriteOnly);
//    outputStream << *model;

//    QByteArray compressed = qCompress(outputData, 9);
//    // encryption of qCompressed data
////    QString key("28DF61953B41B30FD508D9E679D6A6B8FAD7598531AAFF45A0B36DE90274D8E3");
////    QString iv("BD8D3F4406789E597CA74BD2C69556AD");

//    // Sha256 and Md5 hash are different anyways so don't need to overcomplicate things
//    QString key("MyNickname");
//    QString iv("MyNickname");

//    QByteArray hashedKey = QCryptographicHash::hash(key.toLocal8Bit(), QCryptographicHash::Sha256);
//    QByteArray hashedIV = QCryptographicHash::hash(iv.toLocal8Bit(), QCryptographicHash::Md5);

//    QByteArray encrypted = QAESEncryption::Crypt(QAESEncryption::AES_256, QAESEncryption::OFB, compressed, hashedKey, hashedIV);

//    outputZipFile.write(encrypted);

//    if (outputZipFile.getZipError() != UNZ_OK) {
//        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "ERROR OCCURRED WHILE WRITING INTO OUTPUTZIPFILE");

//        return;
//    }

//    outputZipFile.close();
//    outputZip.close();

//    qDebug() << "SAVED!" << model->rowCount() << model->columnCount();
//}
*/

void LocalModelLoader::loadWithCredentials(QObject* parent, QObject* currentModel, QString username, QString password, QString filename)
{
    SPMModel* model = new SPMModel(parent);

    parent->setProperty("model", QVariant::fromValue(model));

    delete currentModel;
    currentModel = nullptr;

    QString path = filename.sliced(8); // cutting-off "file:///" protocol prefix

    QuaZipFileInfo inputInfo;

    QuaZip inputZip(path);
    if (!inputZip.open(QuaZip::mdUnzip)) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN INPUTZIP IN MDUNZIP MODE");

        return;
    }

    QuaZipFile inputZipFile(&inputZip);

    inputZip.goToFirstFile();

    if (!inputZip.getCurrentFileInfo(&inputInfo)) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO ACQUIRE CURRENTFILEINFO");

        return;
    }
    qDebug() << password;
    // authorization - password
    if (!inputZipFile.open(QIODevice::ReadOnly, password.toLatin1())) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN INPUTZIPFILE IN READONLY MODE AND CURRENT PASSWORD");

        return;
    }

    if (inputZipFile.getZipError() != UNZ_OK) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "ERROR OCCURRED WHILE READING INPUTZIPFILE");

        return;
    }

    QByteArray encryptedCompressedInputData = inputZipFile.readAll();

    inputZipFile.close();
    inputZip.close();
    // authorization - username
    // decryption of qCompressed data
    // Sha256 and Md5 hash are different anyways so don't need to overcomplicate things
    qDebug() << username;
    QByteArray hashedKey = QCryptographicHash::hash(username.toLocal8Bit(), QCryptographicHash::Sha256);
    QByteArray hashedIV = QCryptographicHash::hash(username.toLocal8Bit(), QCryptographicHash::Md5);

    QByteArray decoded = QAESEncryption::Decrypt(QAESEncryption::AES_256, QAESEncryption::OFB, encryptedCompressedInputData, hashedKey, hashedIV);
    // optional; depends on MODE (ECB, CBC, CFB ??) and blocksize~key~iv
    // QByteArray decodedWithoutPadding = QAESEncryption::RemovePadding(decoded);

    // qUncompress
    QByteArray decompressedInputData = qUncompress(decoded);

    QDataStream inputDataStream(&decompressedInputData, QIODevice::ReadOnly);

    inputDataStream >> *model;

    qDebug() << "LOADED: " << model->rowCount() << model->columnCount();

    return;
}

void LocalModelLoader::create(QObject *parent, QObject *currentModel)
{
    SPMModel* model = new SPMModel(parent); // tableView is parent but never destroyed yet, thats why handling model/children manually

    parent->setProperty("model", QVariant::fromValue(model));

    delete currentModel;
    currentModel = nullptr;
}

void LocalModelLoader::saveWithCredentials(SPMModel *model, QString username, QString password, QString filename)
{
    QString path = filename.sliced(8); // cutting-off "file:///" protocol prefix

    QuaZipNewInfo outputInfo("db", path);

    QuaZip outputZip(path);
    if (!outputZip.open(QuaZip::mdCreate)) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN OUTPUTZIP WITH MDCREATE FLAG");

        return;
    }
    // authorization - password
    QuaZipFile outputZipFile(&outputZip);
    if (!outputZipFile.open(QIODevice::WriteOnly, outputInfo, password.toLatin1())) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "UNABLE TO OPEN OUTPUTZIPFILE WITH WRITEONLY FLAG");

        return;
    }

    QByteArray outputData;
    QDataStream outputStream(&outputData, QIODevice::WriteOnly);
    outputStream << *model;

    QByteArray compressed = qCompress(outputData, 9);
    // authorization - username
    // encryption of qCompressed data
    // Sha256 and Md5 hash are different anyways so don't need to overcomplicate things
    QByteArray hashedKey = QCryptographicHash::hash(username.toLocal8Bit(), QCryptographicHash::Sha256);
    QByteArray hashedIV = QCryptographicHash::hash(username.toLocal8Bit(), QCryptographicHash::Md5);

    QByteArray encrypted = QAESEncryption::Crypt(QAESEncryption::AES_256, QAESEncryption::OFB, compressed, hashedKey, hashedIV);

    outputZipFile.write(encrypted);

    if (outputZipFile.getZipError() != UNZ_OK) {
        qDebug() << QString::asprintf("file:///%s:%i: %s", __FILE__, __LINE__, "ERROR OCCURRED WHILE WRITING INTO OUTPUTZIPFILE");

        return;
    }

    outputZipFile.close();
    outputZip.close();

    qDebug() << "SAVED!" << model->rowCount() << model->columnCount();
}

void LocalModelLoader::unloadModel(QObject *parent, QObject *currentModel)
{
    parent->setProperty("model", QVariant::fromValue(nullptr)); // tableView is parent but never destroyed yet, thats why handling model/children manually

    delete currentModel;
    currentModel = nullptr;
}

//SPMModel *LocalModelLoader::load(QObject* parent)
//{
//    SPMModel* model = new SPMModel(parent);

//    QString prefix = QDir::currentPath() + QDir::separator();
//    QString path = prefix + "app.mdb";
//    QFile file(path);

//    if(!file.open(QIODevice::ReadOnly)) {

//        return model;
//    }

//    QByteArray compressed = file.readAll();

//    QByteArray decompressed = qUncompress(compressed);
//    QDataStream raw_data(&decompressed, QIODevice::ReadOnly);

//    // QDataStream in(&file);
//    // in >> *model;

//    raw_data >> *model;

//    qDebug() << model->rowCount() << model->columnCount();

//    return model;
//}
