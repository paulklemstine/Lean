def fiber_profile(f, domain):
    from collections import Counter
    counts = Counter(f(x) for x in domain)
    return sorted(counts.values(), reverse=True)