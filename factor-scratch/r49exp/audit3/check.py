import math
# 1. Dickman rho
def rho(u):
    if u<=1: return 1.0
    if u<2:
        return 1-math.log(u)
    v=u-1
    # numerical integration: rho(u)=int_u^inf rho(t-1)/t dt
    # use the standard iterative approach on fine grid
    import numpy as np
    N=2_000_000
    du=1e-5
    # build rho on [0, u+something]
    umax=u+40*du
    n=int(umax/du)+2
    r=np.zeros(n+1)
    r[1]=1.0
    # rho(u) = 1 - log u on [1,2]; for u>2: rho(u)=rho(u-1) - du*rho'(u-1)/... use derivative form
    # rho'(u) = -rho(u-1)/u  -> integrate with simple Euler backwards from 2
    r2=r[2]
    # fill [1,2] analytically
    for k in range(1,int(2/du)+1):
        uk=k*du
        if uk<=1: r[k]=1.0
        else: r[k]=1-math.log(uk)
    # for u in [2,umax]: d rho/du = -rho(u-1)/u
    i2=int(round(2/du))
    for k in range(i2+1,n):
        uk=k*du
        r[k]=r[k-1]-du*r[k-1-int(round(1/du))]/uk
    return float(r[int(round(u/du))])

u=math.log2(1684)/math.log2(1000)
print("E-6b: u =",u," rho =",rho(u), " (note claims 0.927264 / census 0.9273)")
u29=29/math.log2(1000)
print("E-6c M_forensics: u =",u29," rho =",rho(u29), " (note claims 0.0587)")
print("  rho at 29bit B=1000 per re-run JSON: 0.06477590983125796")
print()
print("0.720/0.0587 =",0.720/0.0587, " (note: 12.3x above uniform)")
print("0.720/0.0624 =",0.720/0.0624, " (note/census: 11.5x vs measured)")
print("0.720/0.06478=",0.720/0.06478)
