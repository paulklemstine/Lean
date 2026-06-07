def abel_wronskian_formula(W0, p, x0, x, n_steps=1000):
    import numpy as np
    t = np.linspace(x0, x, n_steps + 1)
    dt = (x - x0) / n_steps
    p_vals = np.array([p(ti) for ti in t])
    integral = np.trapz(p_vals, dx=dt)
    return W0 * np.exp(-integral)