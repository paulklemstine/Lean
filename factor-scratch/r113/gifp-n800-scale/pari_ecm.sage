# HONEST BASELINE. In PARI, factor(n) uses trial division + rho; factor(n,1)
# additionally uses Montgomery's multiple-precision GCD = Elliptic Curve Method.
# An alpha*n-bit factor is EXACTLY the ECM regime. Measure both.
import time, sys
def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
nbits = int(sys.argv[1]); alpha = float(sys.argv[2]); seed = int(sys.argv[3])
mode = sys.argv[4] if len(sys.argv)>4 else 'ecm'
set_random_seed(seed)
qb = int(round(nbits*alpha)); pb = nbits - qb
for _ in range(300):
    q = blum(2**(qb-1) + randint(0, 2**(qb-1)))
    c = blum(2**(pb-1) + randint(0, 2**(pb-1)))
    if (c*q).nbits()==nbits: p,q,N = c,q,c*q; break
pari_N = pari(N)
t0=time.time()
if mode=='ecm': f = pari_N.factor(1)
elif mode=='rho': f = pari_N.factor(0)
else: f = factor(N)
dt=time.time()-t0
rows = list(f)   # matrix -> list of column vectors
nf = len(rows)
prod = ZZ(1)
for r in rows:
    rr = list(r)
    base = ZZ(rr[0]); expo = int(rr[1]) if len(rr) > 1 else 1
    prod *= base**expo
print("n=%4d a=%.2f |q|=%3d  PARI factor(N,%s) = %8.3f s  COMPLETE=%s  correct=%s"
      % (nbits, alpha, qb, mode, dt, nf>=2, prod==N), flush=True)
