def interference(t1, t2, x, y):
    e = np.exp(x) - np.log(y)
    return 2 * e**2 * (1 + np.cos(t1 - t2))