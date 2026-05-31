def orbit_signature(c, p):
    from collections import Counter
    periods = Counter()
    for x in range(p):
        # Floyd's cycle detection
        t = (x*x+c)%p
        h = ((t*t+c)%p*(t*t+c)%p+c)%p  # actually recompute
        t = (x*x+c)%p; h = t; h = (h*h+c)%p; h = (h*h+c)%p
        # Use find_rho_shape from algorithms.py for full impl
        mp = minimal_period(c, x, p)
        if mp > 0: periods[mp] += 1
    return periods