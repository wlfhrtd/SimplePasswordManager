#include "spmsortfilterproxymodel.h"

SPMSortFilterProxyModel::SPMSortFilterProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{
    this->setDynamicSortFilter(false);
    this->setSortCaseSensitivity(Qt::CaseSensitive);
    this->setFilterCaseSensitivity(Qt::CaseInsensitive);
}


void SPMSortFilterProxyModel::sort(int column, Qt::SortOrder order)
{
    emit beginSorting();

    QSortFilterProxyModel::sort(column, order);

    emit endSorting();
}
