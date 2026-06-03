def depth_lower_bound(f, domain):
    from math import log2, ceil
    from collections import Counter
    m = max(Counter(f(x) for x in domain).values())
    return ceil(log2(m)) if m > 1 else 0