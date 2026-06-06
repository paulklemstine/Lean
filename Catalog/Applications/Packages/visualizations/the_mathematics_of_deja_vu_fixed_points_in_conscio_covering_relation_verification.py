def covering_check(f, a, b, c, d, n=1000):
    import numpy as np
    xs = np.linspace(a, b, n)
    ys = [f(x) for x in xs]
    return min(ys) <= c + 1e-10 and max(ys) >= d - 1e-10