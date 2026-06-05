def spectral_count(q: float, T: float) -> int:
    n = 0
    while True:
        qi_n = sum(q**(n-1-2*k) for k in range(n)) if n > 0 else 0
        qi_n1 = sum(q**(n-2*k) for k in range(n+1))
        if qi_n * qi_n1 > T:
            return n
        n += 1