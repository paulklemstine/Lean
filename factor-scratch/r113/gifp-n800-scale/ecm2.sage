# HONEST GENERIC BASELINE for an instance with a known alpha*n-bit factor.
# Trial division equivalent is factor(N2) [PARI default]; ECM is the real method.
import time, sys
from sage.libs.libecm import ecmfactor
def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
nbits=int(sys.argv[1]); alpha=float(sys.argv[2]); seed=int(sys.argv[3])
set_random_seed(seed)
qb=int(round(nbits*alpha)); pb=nbits-qb
for _ in range(400):
    q=blum(2**(qb-1)+randint(0,2**(qb-1))); c=blum(2**(pb-1)+randint(0,2**(pb-1)))
    if (c*q).nbits()==nbits: p,q,N=c,q,c*q; break
t0=time.time(); found=None
# escalate B1; 80-bit factor needs B1 ~ 1e7-3e7 for good odds on a few curves
for B1 in [1e6, 3e6, 1e7, 3e7, 1e8, 3e8]:
    for trial in range(3):
        res = ecmfactor(N, int(B1))
        if res[0]:
            for fct in res[1:]:
                if fct and N % fct==0 and fct!=1 and fct!=N: found=(B1,ZZ(fct)); break
        if found: break
    if found: break
dt=time.time()-t0
print("n=%4d a=%.2f |q|=%3d  ECM total = %7.2f s  found=%s correct=%s"
      %(nbits,alpha,qb,dt,found is not None, found is not None and found[1] in (p,q)), flush=True)
