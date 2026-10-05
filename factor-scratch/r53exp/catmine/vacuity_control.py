# NEGATIVE CONTROL for the sub-n/4 successes.
# The test in coppersmith_lattice.py evaluates the recovered h at the KNOWN
# x_true and accepts if h(x_true)==0.  If the same lattice ALSO "succeeds" at a
# RANDOM point of the same size, the test is VACUOUS (any tiny lattice contains a
# low-degree polynomial vanishing at whatever point you hand it), and the
# "sub-n/4 successes" carry no information.
import sys, random
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, factor_with_top_bits, _reduced_polys, evalp

def probe(N,p,nn,k,m,t,x_probe):
    tb=nn//2-k; X=1<<tb; p0=(p>>tb)*X
    f=[p0,1]
    return any(evalp(h,x_probe)==0 for h in _reduced_polys(f,N,X,m,t))

random.seed(12345)
print("n   k  n/4  (m,t)  hits@x_true  hits@random-x  dim=m*t")
nsub=vac=0; tot=0
for i in range(60):
    while True:
        p=gen_prime(32); q=gen_prime(32); N=p*q
        if 2**47<=N<2**48: break
    nn=N.bit_length(); q4=nn//4
    for k in range(max(1,q4-4), q4):
        for m in range(2,10):
            for t in range(2,10):
                if not factor_with_top_bits(N,p,nn,k,m,t): continue
                nsub+=1
                tb=nn//2-k; X=1<<tb
                rnd=random.randrange(1,X)
                h=probe(N,p,nn,k,m,t,rnd)
                tot+=1
                if h: vac+=1
                if nsub<=12:
                    print(f"{nn} {k:2d} {q4:4d}  ({m},{t})      Y            "
                          f"{'Y  <-- VACUOUS' if h else 'n':>10}        {m*t}")
                break
            else: continue
            break
print(f"\nTOTAL sub-n/4 successes examined: {nsub}")
print(f"  of which the SAME lattice also annihilates a RANDOM point: {vac}")
print(f"  => vacuity rate {vac}/{tot}")
