from math import log, log2
lb = log2
def H(p):
    if p <= 0 or p >= 1: return 0.0
    return -p*lb(p) - (1-p)*lb(1-p)
def X(n): return 1 - H(0.5 + 1.0/n)
def A(n): return lb(n)/n**2
def g(n):
    u = 1.0/n**2
    return -(1-u)*lb(1-u) - u
def R(n):
    if n <= 2: return float('inf')
    return -0.5*lb(1 - 4.0/n**2)
print("n  X*n^2  g*n^2  A*n^2/lb n  R*n^2   X/g    A-X")
for n in [2,3,4,5,6,7,8,9,16,64,1024,65536,655360]:
    r = R(n)*n*n if n > 2 else float('inf')
    print("%7d %.9f %.9f %.9f %.9f %.6f %+.6e" % (n, X(n)*n*n, g(n)*n*n, A(n)*n*n/lb(n), r, X(n)/g(n), A(n)-X(n)))
print("limits:", 2/log(2), 1/log(2)-1, 2/(1-log(2)))
print("exact n=2:", X(2), A(2), g(2), 5/4 - 0.75*lb(3))
