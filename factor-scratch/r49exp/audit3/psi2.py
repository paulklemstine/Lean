import numpy as np, math, sys
sys.path.insert(0,'.')
def psi_count(x,y):
    sieve=np.ones(y+1,bool); sieve[:2]=False
    for i in range(2,int(y**.5)+1):
        if sieve[i]: sieve[i*i::i]=False
    ps=np.nonzero(sieve)[0]
    vals=np.ones(1,dtype=np.int64)
    for p in ps:
        p=int(p); new=[vals]; cur=vals*p
        while True:
            m=cur[cur<=x]
            if m.size==0: break
            new.append(m); cur=m*p
        vals=np.concatenate(new)
    return int(vals.size)
X=10**8; Y=10**4
c=psi_count(X,Y)
from dick import rho
r2=rho(2.0)
print("=== CENSUS line 537: 'rho(2)=0.3069 is a lower bound at finite scale. Exact Psi gives 0.3327 at x=1e8' ===")
print(f"  my exact Psi(10^4,10^8) = {c}  ->  Psi/x = {c/X:.6f}   (census prints 0.3327)")
print(f"  rho(2) = {r2:.6f}  (paper line 79 prints 0.3069)")
print(f"  Psi/rho = {(c/X)/r2:.4f}  -> Dickman a lower bound here? {(c/X)>r2}")
print()
print("=== TENSION: #521 lines 79-80/482 'null reproduces rho to within 1.43 sigma' ===")
for n in (100,10**3,10**4,10**5,10**6):
    sd=math.sqrt(r2*(1-r2)/n)
    print(f"  at n={n:>8}: gap {abs(c/X-r2)/sd:>7.2f} sigma")
