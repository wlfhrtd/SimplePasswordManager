#ifndef SPMSORTFILTERPROXYMODEL_H
#define SPMSORTFILTERPROXYMODEL_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "columnssorter.h"
#include "alphanumcomparer.h"


class SPMSortFilterProxyModel : public QSortFilterProxyModel
{
private:
    Q_OBJECT

    // sorting
    ColumnsSorter m_columns_sorter;
    // filtering
    QMap<int, QRegularExpression> m_multiFilterMap;
    bool m_is_multiFilterModel = false;

protected:
    // sorting
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;
    // filtering
    virtual bool filterAcceptsRow(int source_row, const QModelIndex& source_parent) const override;

public:
    explicit SPMSortFilterProxyModel(bool is_multiFilterModel, QObject* parent = nullptr);

    // sorting
    Q_INVOKABLE void setSortIcons(QChar ascIcon, QChar descIcon) { m_columns_sorter.setIcons(ascIcon, descIcon); }
    Q_INVOKABLE void sortColumn(int column);
    void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;
    // filtering
    Q_INVOKABLE void setMultiFilterRegularExpression(const int& column, const QString& pattern);
    Q_INVOKABLE void clearMultiFilter();

signals:
    // sorting
    void beginSorting();
    void endSorting();

};

#endif // SPMSORTFILTERPROXYMODEL_H
