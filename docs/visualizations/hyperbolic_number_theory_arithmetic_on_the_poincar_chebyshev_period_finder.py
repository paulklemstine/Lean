def cheb_trace_period_mod(t: int, m: int) -> int:
    init = (2 % m, t % m)
    a, b = init
    for k in range(1, m * m + 1):
        a, b = b, (t * b - a) % m
        if (a, b) == init: return k
    return m * m