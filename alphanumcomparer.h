#ifndef ALPHANUMCOMPARER_H
#define ALPHANUMCOMPARER_H


#include <QString>


class AlphanumComparer
{
private:
    static int compare(QString left, QString right);

public:
    static bool lessThan(const QString& s1, const QString& s2) { return compare(s1, s2) < 0; }
};

#endif // ALPHANUMCOMPARER_H
