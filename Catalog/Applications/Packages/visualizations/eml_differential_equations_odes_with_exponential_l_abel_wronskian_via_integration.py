def abel_wronskian(p, W0, x0, x, n=1000):
    import numpy as np
    ts = np.linspace(x0, x, n+1)
    integral = np.trapezoid([p(t) for t in ts], dx=(x-x0)/n)
    return W0 * np.exp(-integral)