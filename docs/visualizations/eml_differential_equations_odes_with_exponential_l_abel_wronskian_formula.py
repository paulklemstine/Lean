def abel_wronskian(p, W0, x0, x, n=1000):
    import numpy as np
    t = np.linspace(x0, x, 2*n+1)
    dt = (x - x0) / (2*n)
    vals = np.array([p(ti) for ti in t])
    integral = dt/3 * (vals[0] + vals[-1] + 4*np.sum(vals[1::2]) + 2*np.sum(vals[2:-1:2]))
    return W0 * np.exp(-integral)