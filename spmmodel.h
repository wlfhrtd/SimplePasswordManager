#ifndef SPMMODEL_H
#define SPMMODEL_H

#include <QAbstractTableModel>
#include <QQmlEngine>


class SPMModel : public QAbstractTableModel
{
private:
    Q_OBJECT
    QML_ELEMENT


    static constexpr int columns = 2;
    QList<QStringList> m_table;

public:
    explicit SPMModel(QObject *parent = nullptr);

    // QAbstractItemModel interface
    Q_INVOKABLE inline int rowCount(const QModelIndex &parent = QModelIndex()) const override { return parent.isValid() ? 0 : m_table.size(); }
    inline int columnCount(const QModelIndex &parent = QModelIndex()) const override { return parent.isValid() ? 0 : columns; }

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;

    Q_INVOKABLE QVariant headerData(int section, Qt::Orientation orientation, int role) const override;

    bool insertRows(int row, int count, const QModelIndex &parent) override;
    bool removeRows(int row, int count, const QModelIndex &parent) override;

    inline Qt::ItemFlags flags(const QModelIndex &index) const override
    {
        return index.isValid()
                   ? QAbstractItemModel::flags(index) | Qt::ItemIsEditable | Qt::ItemIsSelectable | Qt::ItemIsEnabled
                   : Qt::NoItemFlags;
    }

    friend QDataStream& operator << (QDataStream& out, const SPMModel& obj)
    {
        out << obj.m_table;

        return out;
    }
    friend QDataStream& operator >> (QDataStream& in, SPMModel& obj)
    {
        in >> obj.m_table;

        return in;
    }
};

#endif // SPMMODEL_H
