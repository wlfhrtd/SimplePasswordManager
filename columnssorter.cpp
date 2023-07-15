#include "columnssorter.h"


ColumnsSorter::ColumnsSorter()
{

}


void ColumnsSorter::sortColumn(int column)
{
    if(m_sorted_columns.contains(column)) {
        change_sort_order(column);

        return;
    }

    add_sorted_column(column);
}

QChar ColumnsSorter::columnIcon(int column) const
{
    QChar columnIcon;

    if(!m_sorted_columns.contains(column)) {
        return columnIcon;
    }

    if(m_sorted_columns.value(column) == Qt::AscendingOrder) {
        columnIcon = m_asc_icon;

        return columnIcon;
    }

    columnIcon = m_desc_icon;

    return columnIcon;
}

void ColumnsSorter::add_sorted_column(int column)
{
    m_sorted_columns.insert(column, Qt::AscendingOrder);

    m_sorted_columns_order.append(column);
}

void ColumnsSorter::change_sort_order(int column)
{
    int currentOrder = m_sorted_columns.value(column);
    int changedOrder = 1;

    if(currentOrder == 1) changedOrder = -1;
    if(currentOrder == -1) changedOrder = 0;

    m_sorted_columns.insert(column, changedOrder);
}
