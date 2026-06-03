def functorial_entropy(f, domain, codomain):
    N = len(domain)
    if N == 0: return 0.0
    from collections import Counter
    counts = Counter(f(a) for a in domain)
    return sum((fc / N) * math.log(fc) for fc in counts.values() if fc > 0)