import math, sys
sys.path.insert(0,'.')
from dick import rho
def psi_count(x,y):
    ps=[];  sieve=[True]*(y+1); sieve[0]=sieve[1]=False
    for i in range(2,y+1):
        if sieve[i]:
            ps.append(i)
            for j in range(i*i,y+1,i): sieve[j]=False
    vals=[1]
    for p in ps:
        new=[]
        for v in vals:
            while v<=x:
                new.append(v); v*=p
        vals=new
    return len(vals)
print("=== CENSUS: 'Exact Psi gives 0.3327 at x=1e8' (rho(2) => y = sqrt(x) = 1e4) ===")
X=10**8; Y=10**4
c=psi_count(X,Y)
print(f"  my exact Psi(10^4,10^8) = {c}  ->  Psi/x = {c/X:.6f}")
print(f"  census prints 0.3327 ; my value {c/X:.6f} ; rho(2) = {rho(2):.6f}")
print(f"  census claim 'Dickman is a LOWER bound at finite scale': Psi/rho = {(c/X)/rho(2):.4f} -> {(c/X)>rho(2)}")
print()
print("  also check a smaller x to show the direction of convergence:")
for x in (10**6,10**7,10**8):
    y=int(round(math.sqrt(x)))
    print(f"    x=1e{len(str(x))-1}: y={y}  Psi/y -> {psi_count(x,y)/x:.6f}")
print()
print("=== TENSION: #521 'null harness reproduces rho to within 1.43 sigma' (lines 79-80, 482) ===")
print(f"  rho(2)={rho(2):.6f}, exact finite-scale {c/X:.6f}, gap {100*((c/X)-rho(2))/rho(2):.1f}%")
p=rho(2)
for n in (100,1000,10**4,10**5,10**6):
    sd=math.sqrt(p*(1-p)/n)
    print(f"    at n={n:>7}: that gap = {abs(c/X-p)/sd:>6.2f} sigma")
