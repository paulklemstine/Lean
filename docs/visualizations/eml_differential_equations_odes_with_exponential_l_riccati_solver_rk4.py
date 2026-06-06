def riccati_solve(q, v0, x_span, n=10000):
    import numpy as np
    x0, x1 = x_span
    h = (x1 - x0) / n
    x, v = np.zeros(n+1), np.zeros(n+1)
    x[0], v[0] = x0, v0
    f = lambda t, vt: -(vt**2) - q(t)
    for i in range(n):
        k1 = f(x[i], v[i])
        k2 = f(x[i]+h/2, v[i]+h*k1/2)
        k3 = f(x[i]+h/2, v[i]+h*k2/2)
        k4 = f(x[i]+h, v[i]+h*k3)
        v[i+1] = v[i] + h/6*(k1+2*k2+2*k3+k4)
        x[i+1] = x[i] + h
        if abs(v[i+1]) > 1e10: return x[:i+2], v[:i+2]
    return x, v