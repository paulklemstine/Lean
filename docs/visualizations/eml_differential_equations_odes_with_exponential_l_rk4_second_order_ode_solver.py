def rk4_solve(p, q, y0, yp0, x0, x1, n=10000):
    import numpy as np
    h = (x1 - x0) / n
    xs = np.linspace(x0, x1, n+1)
    ys, yps = np.zeros(n+1), np.zeros(n+1)
    ys[0], yps[0] = y0, yp0
    for i in range(n):
        xi, yi, ypi = xs[i], ys[i], yps[i]
        def f(x,y,yp): return (yp, -p(x)*yp - q(x)*y)
        k1 = f(xi, yi, ypi)
        k2 = f(xi+h/2, yi+h*k1[0]/2, ypi+h*k1[1]/2)
        k3 = f(xi+h/2, yi+h*k2[0]/2, ypi+h*k2[1]/2)
        k4 = f(xi+h, yi+h*k3[0], ypi+h*k3[1])
        ys[i+1] = yi + h*(k1[0]+2*k2[0]+2*k3[0]+k4[0])/6
        yps[i+1] = ypi + h*(k1[1]+2*k2[1]+2*k3[1]+k4[1])/6
    return xs, ys, yps