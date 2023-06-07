#include "spmmodel.h"


SPMModel::SPMModel(QObject *parent)
    : QAbstractTableModel{parent}
{
//    QStringList row0;
//    row0.resize(columns); // 2
//    row0.fill("");
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
//    m_table.append(row0);
}


QVariant SPMModel::data(const QModelIndex &index, int role) const
{
    if(role == Qt::DisplayRole || role == Qt::EditRole) {
        return m_table[index.row()][index.column()];
    }

    return QVariant();
}

bool SPMModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
// qDebug() << "Before setData(): " << m_table;

    if(role != Qt::EditRole || data(index, role) == value) {
        return false;
    }

    m_table[index.row()][index.column()] = value.toString();

    emit dataChanged(index, index, {role});
// qDebug() << "After setData(): " << m_table;
    return true;
}

QVariant SPMModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if(orientation == Qt::Horizontal && role == Qt::DisplayRole) {
        switch (section) {
        case 0:
            return "Instance";
        case 1:
            return "Password";
        default:
            return "";
        }
    }

    return QVariant();
}

bool SPMModel::insertRows(int row, int count, const QModelIndex &parent)
{
// qDebug() << "Before insertRows(): " << m_table;
    beginInsertRows(parent, row, row + count - 1);

    for (int i = 0; i < count; ++i) {
        QStringList new_row(columnCount(parent), "");
        m_table.insert(row + i, new_row);
    }

    endInsertRows();
// qDebug() << "After insertRows(): " << m_table;
    return true;
}

bool SPMModel::removeRows(int row, int count, const QModelIndex &parent)
{
    beginRemoveRows(parent, row, row + count - 1);

    for (int i = 0; i < count; ++i) {
        m_table.remove(row + i);
    }

    endRemoveRows();

    return true;
}