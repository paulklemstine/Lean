import sys; sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r113/lattice-obj')
from lib import *
# WHERE DOES THE TRIVIAL BASELINE DIE?  (r113 #1 trap)
import signal
class TO(Exception): pass
def _h(s,f): raise TO()
signal.signal(signal.SIGALRM, _h)
print("bits_p  Nbits  PARI_s  status  pari_ok")
for b in [64,70,76,80,84,88,92,96,100,110,120]:
    N,p,q = gen_N(b, seed=11)
    signal.alarm(300)
    t=time.time()
    try:
        tf,ff = pari_time(N)
        pok = (ff==p or ff==q) and (ff*(N//ff)==N)
        st = "FACTORED"
    except TO:
        tf = time.time()-t; pok=None; st="TIMEOUT>300s"
    except Exception as e:
        tf = time.time()-t; pok=None; st="ERR:%s"%str(e)[:30]
    finally:
        signal.alarm(0)
    print("%4d %6d %8.2f  %-12s %s" % (b, N.bit_length(), tf, st, pok))
    sys.stdout.flush()
