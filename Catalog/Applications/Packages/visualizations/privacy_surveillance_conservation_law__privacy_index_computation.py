def compute_privacy_index(f, domain):
    from collections import Counter
    counter = Counter(f(s) for s in domain)
    return sum(k * (k - 1) for k in counter.values())