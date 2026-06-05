def abel_predict(W0, p, x0, x, n=1000):
    import numpy as np
    ts = np.linspace(x0, x, n+1)
    dt = (x - x0) / n
    integral = np.trapz([p(t) for t in ts], ts)
    return W0 * np.exp(-integral)