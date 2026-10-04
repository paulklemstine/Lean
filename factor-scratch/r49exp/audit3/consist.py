def dickman(u,N=200000):
    import math
    if u<1: return 1.0
    if u<=2: return 1.0-math.log(u)
    h=(u-2.0)/N
    g=[0.0]*(N+1); g[0]=1.0-math.log(2.0)
    for i in range(1,N+1):
        t=2.0+(i-0.5)*h; s=t-1.0
        rs=1.0-math.log(s) if s<=2 else g[min(int((s-2.0)/h),N)]
        g[i]=g[i-1]-h*rs/t
    return g[N]
rows=[(3.0,6.77e-1,4.86e-2,13.9),(3.5,6.03e-1,1.62e-2,37.2),(4.0,5.39e-1,4.92e-3,109.7),(4.5,4.86e-1,1.37e-3,353.0),(5.0,4.45e-1,3.58e-4,1244.0)]
print("== note table internal consistency: is ratio == Psi/X / rho ? ==")
print("u      Psi/X      rho        implied   note     ok")
for u,p,r,rat in rows:
    imp=p/r
    print("%.1f  %.4e  %.4e  %8.1f  %8.1f  %s"%(u,p,r,imp,rat,abs(imp-rat)/rat<0.02))
print("\n== my rho vs note rho ==")
for u,nr in [(3.0,4.86e-2),(3.5,1.62e-2),(4.0,4.92e-3),(4.5,1.37e-3),(5.0,3.58e-4)]:
    m=dickman(u)
    print("  rho(%.1f) mine=%.4e note=%.4e relerr=%.1f%%"%(u,m,nr,100*abs(m-nr)/nr))
print("\n== given the note's OWN rho column, what Psi/X would 13.9x imply? ==")
for u,nr,rat in [(3.0,4.86e-2,13.9),(5.0,3.58e-4,1244.0)]:
    print("  u=%.1f  13.9x-type: Psi/X would be %.4e ; note prints %.4e"%(u,nr*rat,nr*rat))
