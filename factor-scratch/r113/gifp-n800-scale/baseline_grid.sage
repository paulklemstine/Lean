# TRIVIAL BASELINE across the sweep grid. For each (N, alpha) we ask:
#   (a) PARI default factor(N)  -- with a hard wall-clock cap
#   (b) ECM with a fixed sensible budget
# GIFP can only be evidence where BOTH fail.
import time, sys, signal
from sage.libs.libecm import ecmfactor
def blum(lo):
    c = next_prime(lo)
    while c % 4 != 3: c = next_prime(c+2)
    return c
nbits=int(sys.argv[1]); alpha=float(sys.argv[2]); seed=int(sys.argv[3])
cap=float(sys.argv[4]) if len(sys.argv)>4 else 60.0
set_random_seed(seed)
qb=int(round(nbits*alpha)); pb=nbits-qb
for _ in range(400):
    q=blum(2**(qb-1)+randint(0,2**(qb-1))); c=blum(2**(pb-1)+randint(0,2**(pb-1)))
    if (c*q).nbits()==nbits: p,q,N=c,q,c*q; break
# (a) PARI default, hard-capped
class TO(Exception): pass
def _h(s,f): raise TO()
signal.signal(signal.SIGALRM,_h)
t0=time.time(); signal.setitimer(signal.ITIMER_REAL, cap)
try:
    f = factor(N); signal.setitimer(signal.ITIMER_REAL,0)
    pr=ZZ(1)
    for e in f: pr*=e[0]**e[1]
    pari_ok = (len(f)>=2 and pr==N); pari_t=time.time()-t0
except TO:
    signal.setitimer(signal.ITIMER_REAL,0); pari_ok=False; pari_t=cap
except Exception:
    signal.setitimer(signal.ITIMER_REAL,0); pari_ok=False; pari_t=time.time()-t0
# (b) ECM, hard-capped
t0=time.time(); signal.setitimer(signal.ITIMER_REAL, cap)
ecm_ok=False
try:
    for B1 in [1e6,3e6,1e7,3e7]:
        res=ecmfactor(N,int(B1))
        if res[0]:
            for fct in res[1:]:
                if fct and N%fct==0 and fct!=1 and fct!=N: ecm_ok=True; break
        if ecm_ok: break
    signal.setitimer(signal.ITIMER_REAL,0)
except TO:
    signal.setitimer(signal.ITIMER_REAL,0)
except Exception:
    signal.setitimer(signal.ITIMER_REAL,0)
ecm_t=time.time()-t0
print("n=%4d a=%.2f |q|=%3d  PARI=%6.2fs(%s)  ECM=%6.2fs(%s)  GIFP-competitive=%s"
      %(nbits,alpha,qb,pari_t,pari_ok,ecm_t,ecm_ok,(not pari_ok) and (not ecm_ok)), flush=True)
