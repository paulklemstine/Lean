def count_linear_regions(f, a, b, n=100000):
    import numpy as np
    xs = np.linspace(a, b, n)
    ys = np.array([f(x) for x in xs])
    slopes = np.diff(ys) / np.diff(xs)
    return int(np.sum(np.abs(np.diff(slopes)) > 1e-6) + 1)