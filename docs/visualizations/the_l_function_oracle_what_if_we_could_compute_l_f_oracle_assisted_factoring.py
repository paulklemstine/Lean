def oracle_factor(n, oracle=None):
    for a in range(2, n):
        from math import gcd
        g = gcd(a, n)
        if 1 < g < n:
            return (g, n // g)
    raise ValueError(f'Cannot factor {n}')