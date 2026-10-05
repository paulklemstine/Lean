# Fast vacuity control at small n so LLL is cheap.
import sys, random
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, _reduced_polys, evalp
random.seed(11)
nsub=vac=0; shown=0; TOT=200
for i in range(25):
    while True:
        p=gen_prime(16); q=gen_prime(16); N=p*q
        if 2**31<=N<2**32: break
    nn=N.bit_length(); q4=nn//4
    for k in range(max(1,q4-3), q4):
        tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X; f=[p0,1]
        for m in range(2,5):
            for t in range(2,5):
                polys=_reduced_polys(f,N,X,m,t)
                if not any(evalp(h,p-p0)==0 for h in polys): continue
                nsub+=1
                hits=sum(1 for _ in range(TOT)
                         if any(evalp(h,random.randrange(1,X))==0 for h in polys))
                exp=TOT/len(polys)   # baseline if polys were generic
                if hits > 3*exp: vac+=1
                if shown<12:
                    print(f"n={nn} k={k} n/4={q4} (m,t)=({m},{t}) dim={m*t} "
                          f"npolys={len(polys)} random-pts annihilated {hits}/{TOT} "
                          f"(generic expectation {exp:.1f})", flush=True)
                    shown+=1
                break
            else: continue
            break
print(f"\nsub-n/4 successes: {nsub};  VACUOUS (>3x generic rate): {vac}")
