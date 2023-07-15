#include "alphanumcomparer.h"


int AlphanumComparer::compare(QString left, QString right)
{
    enum AlphanumComparerMode { STRING, NUMBER } mode = STRING;

    int size;
    if (left.size() < right.size())
        size = left.size();
    else
        size = right.size();

    int i = 0;
    // traverse both strings to position "size-1"
    while(i < size) {
        if (mode == STRING) {
            QChar lchar;
            QChar rchar;
            bool ldigit;
            bool rdigit;

            while(i < size) {
                lchar  = left.at(i);
                rchar  = right.at(i);
                ldigit = lchar.isDigit();
                rdigit = rchar.isDigit();
                // if both symbols are numbers use numbers state
                if (ldigit && rdigit) {
                    mode = NUMBER;
                    break;
                }
                if (ldigit) return -1;
                if (rdigit) return +1;
                // both symbols are letters
                if (lchar < rchar) return -1;
                if (lchar > rchar) return +1;
                // symbols are equal
                i++;
            }
        } else {
            // mode == NUMBER
            unsigned long long lnum = 0;
            unsigned long long rnum = 0;
            // local indexes
            int li = i;
            int ri = i;
            // numbers
            int ld = 0;
            int rd = 0;
            // make left number
            while (li < left.size()) {
                ld = left.at(li).digitValue();

                if (ld < 0) break;

                lnum = lnum * 10 + ld;
                li++;
            }
            // make right number
            while(ri < right.size()) {
                rd = right.at(ri).digitValue();

                if (rd < 0) break;

                rnum = rnum * 10 + rd;
                ri++;
            }

            long long delta = lnum - rnum;

            if (delta) return delta;
            // numbers are equal
            mode = STRING;
            if (li <= ri)
                i = li;
            else
                i = ri;
        }
    }
    // for situation when both strings to position "size-1" equals
    if (i < right.size()) return -1;
    if (i < left.size()) return +1;

    // strings are fully equal
    return 0;
}
