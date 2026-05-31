def eml_piecewise_approx(f, n, a=0.1, b=1.0):
    import numpy as np, math
    mesh = [a + i*(b-a)/(n-1) for i in range(n)]
    values = [f(x) for x in mesh]
    A = np.array([[math.log(mesh[i]+mesh[j]) for j in range(n)] for i in range(n)])
    w = np.linalg.solve(A, values)
    def net(x): return sum(w[j]*math.log(x+mesh[j]) for j in range(n))
    return net