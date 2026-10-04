from math import log, exp
# 16 ln L = L has TWO roots; the relevant boundary is the LARGE one.
# Solve 16 ln L - L = 0 by bisection on [50,100].
def bisect(f,a,b,it=200):
    fa=f(a)
    for _ in range(it):
        m=(a+b)/2; fm=f(m)
        if fa*fm<=0: b=m
        else: a=m; fa=fm
    return (a+b)/2
f=lambda L: 16*log(L)-L
# scan to find the large root
xs=[1+0.01*i for i in range(1,2000)]
roots=[]
prev=None
for x in xs:
    v=f(x)
    if prev is not None and prev*v<0: roots.append(bisect(f,max(1,x-0.02),x))
    prev=v
print("roots of 16 ln L = L :", [f"{r:.6f}" for r in roots])
Lstar=max(roots)
print(f"large root L* = {Lstar:.6f}   paper says 67.361 -> {'MATCH' if abs(Lstar-67.361)<1e-2 else 'MISMATCH'}")
print(f"N* = e^L*  = {exp(Lstar):.4e}    paper says 1.797e29 -> {'MATCH' if abs(exp(Lstar)-1.797e29)/1.797e29<2e-3 else 'MISMATCH'}")
print(f"  NOTE: e^67.361 = {exp(67.361):.4e}  (the paper's 1.797e29 vs exact e^L*")
print()
print("ln k at n=2^1024:")
L=1024*log(2); lk=4*(L*log(L))**0.5-L
print(f"  L={L:.4f}  ln k={lk:.2f}   paper says -436.7 -> {'MATCH' if abs(lk+436.7)<1.0 else 'MISMATCH'}")
print()
print("Table: is 16 ln L < L at each L?")
for L in [10,20,30,50,60,67.361,80,100,200,500,709.78,1000]:
    print(f"  L={L:9.3f}  16lnL={16*log(L):9.3f}  excluded? {'YES' if 16*log(L)<L else 'no'}")
