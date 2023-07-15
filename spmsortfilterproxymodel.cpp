#include "spmsortfilterproxymodel.h"

SPMSortFilterProxyModel::SPMSortFilterProxyModel(bool is_multiFilterModel, QObject* parent)
    : QSortFilterProxyModel{parent}
{
    // if is_multiFilterModel false setMultiFilterRegularExpression and clearMultifilter will do nothing
    m_is_multiFilterModel = is_multiFilterModel;

    this->setDynamicSortFilter(true);
    this->setSortCaseSensitivity(Qt::CaseSensitive);
}


void SPMSortFilterProxyModel::sortColumn(int column)
{
    m_columns_sorter.sortColumn(column);
    // "count - 1" because indices are started from zero
    for(int i = m_columns_sorter.columnsCount() - 1; i >= 0; i--) {
        int col = m_columns_sorter.columnIndex(i);

        if(m_columns_sorter.columnSortOrder(col) == -1) {
            sort(-1);
        }
    }
    // "count - 1" because indices are started from zero
    for(int i = m_columns_sorter.columnsCount() - 1; i >= 0; i--) {
        int col = m_columns_sorter.columnIndex(i);

        int columnSortOrder = m_columns_sorter.columnSortOrder(col);

        if(columnSortOrder != -1) {
            sort(col, (Qt::SortOrder)columnSortOrder);
        }
    }
}

void SPMSortFilterProxyModel::setMultiFilterRegularExpression(const int& column, const QString& pattern)
{
    if(!m_is_multiFilterModel)
    {
        return;
    }

    QRegularExpression filter;
    filter.setPatternOptions(QRegularExpression::CaseInsensitiveOption);
    filter.setPattern(pattern);

    m_multiFilterMap.insert(column, filter);

    invalidateFilter(); // triggers filterAcceptsRow()
}

void SPMSortFilterProxyModel::clearMultiFilter()
{
    if(!m_is_multiFilterModel)
    {
        return;
    }

    QMap<int, QRegularExpression>::const_iterator i = m_multiFilterMap.constBegin();

    while(i != m_multiFilterMap.constEnd())
    {
        QRegularExpression blankExpression("");
        m_multiFilterMap.insert(i.key(), blankExpression);
        i++;
    }

    invalidateFilter(); // triggers filterAcceptsRow()
}

bool SPMSortFilterProxyModel::filterAcceptsRow(int source_row, const QModelIndex& source_parent) const
{
    if(!m_is_multiFilterModel) {
        // standard model
        QModelIndex index = sourceModel()->index(source_row, filterKeyColumn(), source_parent);
        QString indexValue = sourceModel()->data(index).toString();

        return indexValue.contains(filterRegularExpression());
    }
    // multifiltered model
    QMap<int, QRegularExpression>::const_iterator i = m_multiFilterMap.constBegin();

    while(i != m_multiFilterMap.constEnd())
    {
        QModelIndex index = sourceModel()->index(source_row, i.key(), source_parent);
        QString indexValue = sourceModel()->data(index).toString();

        if(!indexValue.contains(i.value()))
        {
            return false;
        }

        i++;
    }

    return true;
}

void SPMSortFilterProxyModel::sort(int column, Qt::SortOrder order)
{
    emit beginSorting();

    QSortFilterProxyModel::sort(column, order);

    emit endSorting();
}

bool SPMSortFilterProxyModel::lessThan(const QModelIndex& source_left, const QModelIndex& source_right) const
{
    QVariant leftData = sourceModel()->data(source_left);
    QVariant rightData = sourceModel()->data(source_right);

    return AlphanumComparer::lessThan(leftData.toString(), rightData.toString());
}
