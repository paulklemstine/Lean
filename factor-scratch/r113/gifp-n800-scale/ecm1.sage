# The honest baseline question: N = p*q with |q| = alpha*n.
# PARI factor() times out at n=800. But is ECM instant? If so the "GIFP beats
# generic factoring" claim is FALSE -- it beats PARI's DEFAULT heuristic only.
import time, sys
from sage.libs.libecm import ecmfactor
def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
nbits = int(sys.argv[1]); alpha = float(sys.argv[2]); seed = int(sys.argv[3])
set_random_seed(seed)
qb = int(round(nbits*alpha)); pb = nbits - qb
p = None
for _ in range(300):
    q = blum(2**(qb-1) + randint(0, 2**(qb-1)))
    c = blum(2**(pb-1) + randint(0, 2**(pb-1)))
    if (c*q).nbits()==nbits: p,q,N = c,q,c*q; break
t0=time.time(); ok,fct = ecmfactor(N, 11000); dt=time.time()-t0
good = bool(ok) and N % fct == 0 and fct != 1 and fct != N
print("n=%4d a=%.2f |q|=%3d bits -> ECM(B1=11000) = %7.3f s  found=%s (correct=%s)"
      % (nbits, alpha, qb, dt, ok, good and (fct==p or fct==q)), flush=True)
