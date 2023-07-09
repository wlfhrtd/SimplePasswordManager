#ifndef SPMSORTFILTERPROXYMODEL_H
#define SPMSORTFILTERPROXYMODEL_H

#include <QObject>
#include <QSortFilterProxyModel>


class SPMSortFilterProxyModel : public QSortFilterProxyModel
{
private:
    Q_OBJECT

public:
    explicit SPMSortFilterProxyModel(QObject *parent = nullptr);


    Q_INVOKABLE void sort(int column, Qt::SortOrder order = Qt::AscendingOrder) override;

signals:
    void beginSorting();
    void endSorting();

};

#endif // SPMSORTFILTERPROXYMODEL_H
