load('/home/raver1975/lean/factor-scratch/r113/gifp-n800-scale/gifp_indep.sage')
import time, sys
N, alpha, gamma, beta1, beta2, m, seed = sys.argv[1:8]
t0=time.time()
res = attack(int(N), float(alpha), float(gamma), float(beta1), float(beta2), int(m), int(seed))
dt=time.time()-t0
if res is None: print("GENFAIL seed=%s t=%.2f"%(seed,dt))
else: print("ok=%d t=%.2f dim=%s npolys=%d"%(res["ok"],dt,res["latdim"],res.get("npolys",-1)), flush=True)
