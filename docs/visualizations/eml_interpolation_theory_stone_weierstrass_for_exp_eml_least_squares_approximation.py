def eml_least_squares(f, degree, interval=(0,1), n=1000):
    x = np.linspace(*interval, n)
    V = np.column_stack([np.exp(k*x) for k in range(degree+1)])
    c, _, _, _ = np.linalg.lstsq(V, f(x), rcond=None)
    return c, float(np.max(np.abs(V@c - f(x))))