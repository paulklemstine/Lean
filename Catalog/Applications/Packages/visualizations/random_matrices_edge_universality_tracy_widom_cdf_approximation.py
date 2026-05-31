def tracy_widom_cdf(s, N=200, L=10.0):
    from scipy.special import airy
    x = np.linspace(s, s+L, N)
    dx = x[1]-x[0]
    ai = np.array([airy(xi)[0] for xi in x])
    aip = np.array([airy(xi)[1] for xi in x])
    K = np.zeros((N,N))
    for i in range(N):
        for j in range(N):
            if i==j: K[i,j] = aip[i]**2 - x[i]*ai[i]**2
            else: K[i,j] = (ai[i]*aip[j]-aip[i]*ai[j])/(x[i]-x[j])
    return np.linalg.det(np.eye(N) - K*dx)