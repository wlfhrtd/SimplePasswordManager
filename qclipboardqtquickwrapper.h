#ifndef QCLIPBOARDQTQUICKWRAPPER_H
#define QCLIPBOARDQTQUICKWRAPPER_H

#include <QObject>
#include <QClipboard>
#include <QGuiApplication>


class QClipboardQtQuickWrapper : public QObject
{
private:
    Q_OBJECT

    QClipboard* m_clipboard;

public:
    explicit QClipboardQtQuickWrapper(QObject *parent = nullptr) : QObject(parent) {
        m_clipboard = QGuiApplication::clipboard();
    }

    Q_INVOKABLE void setText(QString text) {
        m_clipboard->setText(text, QClipboard::Clipboard);
        // m_clipboard->setText(text, QClipboard::Selection); // X11
    }
};

#endif // QCLIPBOARDQTQUICKWRAPPER_H
