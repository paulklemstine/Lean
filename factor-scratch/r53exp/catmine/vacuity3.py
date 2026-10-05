import sys, random
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, _reduced_polys, evalp
random.seed(7)
nsub=vac=0; shown=0
for i in range(12):
    while True:
        p=gen_prime(32); q=gen_prime(32); N=p*q
        if 2**47<=N<2**48: break
    nn=N.bit_length(); q4=nn//4
    for k in range(max(1,q4-3), q4):
        tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X; f=[p0,1]
        for m in range(2,5):
            for t in range(2,5):
                polys=_reduced_polys(f,N,X,m,t)
                if not any(evalp(h,p-p0)==0 for h in polys): continue
                nsub+=1
                rnd=random.randrange(1,X)
                hit=any(evalp(h,rnd)==0 for h in polys)
                if hit: vac+=1
                if shown<10:
                    print(f"n={nn} k={k} n/4={q4} (m,t)=({m},{t}) dim={m*t} "
                          f"random-x annihilated: {hit}", flush=True)
                    shown+=1
                break
            else: continue
            break
print(f"\nsub-n/4 successes: {nsub}; ALSO annihilate a random point: {vac}")
