import sys; sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r113/lattice-obj')
from lib import *
print("bits_p  Nbits  PARI_factor_s  rho_s  rho_iters  rho_ok  pari_ok")
for b in [41,44,48,52,56,60]:
    N,p,q = gen_N(b, seed=1)
    assert p.bit_length()==b and q.bit_length()==b
    tf,ff = pari_time(N)
    pok = (ff==p or ff==q) and (ff*(N//ff)==N)
    t=time.time(); g,it = rho(N, seed=7); tr=time.time()-t
    print("%4d %6d %12.3f %8.3f %10d %8s %8s" % (b, N.bit_length(), tf, tr, it, ok(g,p,q,N), pok))
    sys.stdout.flush()
