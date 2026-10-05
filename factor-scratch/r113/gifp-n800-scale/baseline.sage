# BASELINE AXIS: for N = p*q with |q| = alpha*n, what does each generic method cost?
# PARI factor() is NOT the strongest baseline. ECM is. Measure both.
import time, sys
from sage.libs.libecm import ecmfactor

def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c

def make(nbits, alpha, seed):
    set_random_seed(seed)
    qb = int(round(nbits*alpha)); pb = nbits - qb
    for _ in range(300):
        q = blum(2**(qb-1) + randint(0, 2**(qb-1)))
        p = blum(2**(pb-1) + randint(0, 2**(pb-1)))
        if (p*q).nbits() == nbits and p != q: return p,q,p*q
    return None

nbits = int(sys.argv[1]); alpha = float(sys.argv[2]); seed = int(sys.argv[3])
r = make(nbits, alpha, seed)
p,q,N = r
qb = int(round(nbits*alpha))
# 1. PARI default
t0=time.time(); f = factor(N); t_pari = time.time()-t0
pari_ok = (f[0]*f[1] == N)
# 2. ECM (the real generic baseline for a known-small-factor instance)
t0=time.time(); ok, fct = ecmfactor(N, 11000); t_ecm = time.time()-t0
ecm_ok = (ok and N % fct == 0 and fct != 1 and fct != N)
print("n=%4d a=%.2f |q|=%3d  PARI=%8.3fs(%s)  ECM=%8.3fs(%s)" % (
      nbits, alpha, qb, t_pari, pari_ok, t_ecm, ecm_ok), flush=True)
