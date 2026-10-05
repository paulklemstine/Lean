# THE BASELINE THAT MATTERS.
# N = p*q with |q| = alpha*n. PARI's default factor() is trial-div+rho and times
# out at n=800; PARI factor(n,1) additionally runs ECM (Montgomery multiple-
# precision gcd), which is THE correct generic method for a known-small-factor
# instance. If ECM wins, "GIFP beats generic factoring" is false -- GIFP only
# beats PARI's DEFAULT heuristic.
import time, sys
def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
nbits = int(sys.argv[1]); alpha = float(sys.argv[2]); seed = int(sys.argv[3])
set_random_seed(seed)
qb = int(round(nbits*alpha)); pb = nbits - qb
for _ in range(400):
    q = blum(2**(qb-1) + randint(0, 2**(qb-1)))
    c = blum(2**(pb-1) + randint(0, 2**(pb-1)))
    if (c*q).nbits()==nbits: p,q,N = c,q,c*q; break
pari_N = pari(N)
t0=time.time(); f = pari_N.factor(1); dt=time.time()-t0
prod = ZZ(1)
for i in range(f.nrows()): prod *= ZZ(f[i,0])**int(f[i,1])
# POSITIVE CONTROL: the same call on the 720-bit prime p must be slow and 1-row.
t0=time.time(); f2 = pari(p).factor(1); dt2=time.time()-t0
print("n=%4d a=%.2f |q|=%3d  PARI factor(N,1)[ECM]=%8.3fs rows=%d COMPLETE=%s correct=%s  | CONTROL factor(p),%d-bit prime: %.3fs rows=%d"
      % (nbits, alpha, qb, dt, f.nrows(), f.nrows()>=2, prod==N, p.nbits(), dt2, f2.nrows()), flush=True)
