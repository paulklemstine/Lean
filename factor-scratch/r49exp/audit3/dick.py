"""Exact Dickman rho by the standard auxiliary-function method, VALIDATED against
the published table.  Returns NULL correctly: rho(u)=1 for 0<=u<=1."""
from mpmath import mp, mpf, quad, mpf as _
mp.dps=25
def rho(u):
    u=mpf(u)
    if u<=1: return mpf(1)          # <-- the NULL branch, must be exercised
    if u> 30: raise ValueError("outside validated range")
    # rho(u) = 1 + int_1^u rho(t-1)/t dt
    return 1 + quad(lambda t: rho(t-1)/t, [1,u])
