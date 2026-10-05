import time, sys
def blum(lo, hi):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
def make(nbits, alpha):
    qb = int(round(nbits*alpha)); pb = nbits - qb
    for _ in range(500):
        q = blum(2**(qb-1), 2**qb)
        p = blum(2**(pb-1), 2**pb)
        if (p*q).nbits() == nbits: return p,q,p*q
    return None
nbits = int(sys.argv[1]); alpha = float(sys.argv[2])
r = make(nbits, alpha)
if r is None: print("genfail"); sys.exit(1)
p,q,N = r
t0=time.time(); f = factor(N); dt=time.time()-t0
print("nbits=%d alpha=%.2f |q|=%d bits  PARI factor(N) = %.3f s  correct=%s"
      % (nbits, alpha, int(round(nbits*alpha)), dt, f[0]*f[1]==N), flush=True)
