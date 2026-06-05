def mobius(n):
    if n == 1: return 1
    factors, d, t = [], 2, n
    while d*d <= t:
        if t%d == 0:
            factors.append(d); t //= d
            if t%d == 0: return 0
        d += 1
    if t > 1: factors.append(t)
    return (-1)**len(factors)

def count_min_period(phi_values, n):
    return sum(mobius(n//d) * phi_values.get(d, 0) for d in range(1,n+1) if n%d == 0)