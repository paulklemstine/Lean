def standard_part(f, n=10000):
    from collections import Counter
    vals = [f(i) for i in range(n)]
    counter = Counter(vals)
    for val, count in counter.most_common():
        if count / n > 0.5:
            return val
    return None