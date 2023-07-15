#ifndef COLUMNSSORTER_H
#define COLUMNSSORTER_H


#include <QHash>


class ColumnsSorter
{
private:
    QChar m_asc_icon;
    QChar m_desc_icon;

    QHash<int, int> m_sorted_columns;
    QList<int> m_sorted_columns_order;

    void add_sorted_column(int column);
    void change_sort_order(int column);
    inline void clear_sorted_columns() { m_sorted_columns.clear(); m_sorted_columns_order.clear(); }

public:
    ColumnsSorter();


    inline void setIcons(QChar ascIcon, QChar descIcon) { m_asc_icon = ascIcon; m_desc_icon = descIcon; }

    void sortColumn(int column);

    inline int columnIndex(int columnOrder) const { return m_sorted_columns_order.value(columnOrder); }
    inline int columnsOrder(int column) const { return m_sorted_columns_order.indexOf(column); }
    inline int columnSortOrder(int column) const { return m_sorted_columns.value(column); }
    inline int columnsCount() const { return m_sorted_columns_order.size(); }

    QChar columnIcon(int column) const;
};

#endif // COLUMNSSORTER_H
