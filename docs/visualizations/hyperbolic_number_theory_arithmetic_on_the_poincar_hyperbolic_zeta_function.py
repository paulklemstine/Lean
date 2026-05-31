def hyperbolic_zeta(points, s):
    return sum(abs(z)**(-2*s) for z in points if abs(z) > 1e-10)