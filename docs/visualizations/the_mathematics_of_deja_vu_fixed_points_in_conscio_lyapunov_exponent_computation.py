def lyapunov_exponent(r, x0=0.5, n=10000, warmup=1000):
    import numpy as np
    x = x0
    for _ in range(warmup): x = r*x*(1-x)
    s = 0.0
    for _ in range(n):
        d = abs(r*(1-2*x))
        if d > 0: s += np.log(d)
        x = r*x*(1-x)
    return s/n