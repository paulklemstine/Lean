def verify_gauss_ode(a, b, c, n):
    import math
    def poch(x, k):
        r = 1.0
        for i in range(k): r *= (x + i)
        return r
    def coeff(m): return poch(a,m)*poch(b,m)/(poch(c,m)*math.factorial(m))
    lhs = (n+1)*(n+c)*coeff(n+1)
    rhs = (n+a)*(n+b)*coeff(n)
    return abs(lhs - rhs)