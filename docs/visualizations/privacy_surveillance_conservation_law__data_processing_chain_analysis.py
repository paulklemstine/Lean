def data_processing_chain(f, processors, domain):
    from collections import Counter
    results = []
    current = f
    n = len(domain)
    budget = n * (n - 1)
    for h in processors:
        prev = current
        current = lambda x, _f=current, _h=h: _h(_f(x))
        counter = Counter(current(s) for s in domain)
        pi = sum(k*(k-1) for k in counter.values())
        results.append((pi, budget - pi))
    return results