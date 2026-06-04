def find_critical_density(gap_fn, tol=1e-12):
    lo, hi = 0.0, 1.0
    while hi - lo > tol:
        mid = (lo + hi) / 2
        if gap_fn(mid) > tol:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2