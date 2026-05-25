def log_slope_simple(f, tc, h):
    from math import log
    val = abs(f(tc + h))
    if val <= 0 or abs(h) <= 0 or abs(h) == 1.0:
        return float('nan')
    return log(val) / log(abs(h))