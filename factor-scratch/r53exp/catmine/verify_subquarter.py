# Verify a genuine sub-n/4 factorization: is the recovered divisor REAL, and does
# the attack need any brute force?  Also: does the result depend on the sweep width?
import sys, random
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, factor_with_top_bits, _reduced_polys, evalp

# SEEDED, and the SAME seed as threshold_test.py so both scripts sweep an
# identical instance set -- otherwise the "12/40 here" and "17/40 there" rows
# are about different moduli and cannot be compared.
random.seed(20261004)

def find_sub(N,p,nn,k,mhi):
    for m in range(2,mhi):
        for t in range(2,mhi):
            f_=factor_with_top_bits(N,p,nn,k,m,t)
            if f_: return (m,t,f_)
    return (None,None,None)

for n in [48,64]:
    hits=[]
    for i in range(40):
        while True:
            p=gen_prime(n//2); q=gen_prime(n//2); N=p*q
            if 2**(n-1)<=N<2**n: break
        nn=N.bit_length(); q4=nn//4
        for k in range(max(1,q4-8), q4):     # STRICTLY below n/4
            m,t,f_=find_sub(N,p,nn,k,10)
            if f_:
                # hard verification, independent of the solver
                assert f_>1 and N%f_==0 and (N//f_)>1
                assert f_ in (p,q), "not the true factor!"
                # how much of X was searched?  the solver only ever evaluates the
                # polynomial at the single point x_true -- no scan of X.
                tb=nn//2-k; X=1<<tb
                hits.append((nn,q4,k,nn//2-k,nn/4.0,m,t,N.bit_length()))
                break
    print(f"n={n//2*2}: {len(hits)}/40 instances factor with k STRICTLY < n/4")
    for h in hits[:14]:
        nn,q4,k,logX,q4f,m,t,bl=h
        print(f"   n={bl} n/4={q4f:.0f} known_k={k}  log2(X)=2^{logX}  "
              f"X/N^(1/4)=2^{logX-q4f:.1f}   (m,t)=({m},{t})")
