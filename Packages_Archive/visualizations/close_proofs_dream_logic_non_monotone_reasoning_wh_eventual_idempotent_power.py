def eventual_idempotent_power(f, domain):
    """Find N>0 with f^[N] o f^[N] = f^[N] on a finite domain (eventual retract)."""
    seen, k = {}, 0
    while True:
        snap = tuple(_iter(f, k, x) for x in domain)
        if snap in seen:
            m, n = seen[snap], k
            break
        seen[snap] = k; k += 1
    period = n - m
    return period * (m + 1)     # a positive multiple of the period, >= m

def _iter(f, k, x):
    for _ in range(k): x = f(x)
    return x
