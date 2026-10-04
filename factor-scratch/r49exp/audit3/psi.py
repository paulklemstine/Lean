import math
def psi_count(x,y):
    sieve=bytearray([1])*(y+1); sieve[0]=sieve[1]=0
    for i in range(2,int(y**.5)+1):
        if sieve[i]: sieve[i*i::i]=bytearray(len(sieve[i*i::i]))
    ps=[i for i in range(2,y+1) if sieve[i]]
    vals=[1]
    for p in ps:
        new=[]
        for v in vals:
            while v<=x: new.append(v); v*=p
        vals=new
    return len(vals)
X=10**8; Y=10**4
c=psi_count(X,Y)
def rho2(u):  # rebuild rho locally (validated) to avoid re-running the big grid
    import sys; sys.path.insert(0,'.'); from dick import rho; return rho(u)
r2=rho2(2.0)
print(f"=== CENSUS line 537: 'rho(2)=0.3069 is a lower bound at finite scale. Exact Psi gives 0.3327 at x=1e8' ===")
print(f"  my exact Psi(10^4,10^8) = {c}   ->  Psi/x = {c/X:.6f}   (census prints 0.3327)")
print(f"  rho(2) = {r2:.6f}   (paper line 79 prints 0.3069)")
print(f"  Psi/rho = {(c/X)/r2:.4f}  -> Dickman IS a lower bound at this x: {(c/X)>r2}")
print()
print("=== TENSION: #521 lines 79-80 / 482 'null harness reproduces rho to within 1.43 sigma' ===")
for n in (100,10**3,10**4,10**5,10**6):
    sd=math.sqrt(r2*(1-r2)/n)
    print(f"  at n={n:>8}: the Psi-vs-rho gap {c/X:.4f} is {abs(c/X-r2)/sd:>7.2f} sigma")
