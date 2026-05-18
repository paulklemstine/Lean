# See algorithms.py for full implementation
import math

def triangular_critical_poly(p):
    return p**3 - 3*p + 1

def find_root(a, b, tol=1e-15):
    fa = triangular_critical_poly(a)
    while b - a > tol:
        mid = (a + b) / 2
        fmid = triangular_critical_poly(mid)
        if fa * fmid < 0:
            b = mid
        else:
            a, fa = mid, fmid
    return (a + b) / 2

root = find_root(0, 1)
print(f'Root: {root:.15f}')
print(f'2*sin(pi/18): {2*math.sin(math.pi/18):.15f}')
print(f'Match: {abs(root - 2*math.sin(math.pi/18)) < 1e-12}')