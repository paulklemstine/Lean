load("hnp_baseline_lib.sage")
from sage.modules.free_module_integer import IntegerLattice
import time
inst = build_instance(64, 4, 32, "msb", sd=0)
n, t, l = inst["n"], inst["t"], inst["l"]
c = [(inst["z"][i] - inst["s"][i]*inst["a"][i]) % n for i in range(t)]
beta, vp = [], []
for i in range(t):
    si = inverse_mod(inst["s"][i], n)
    beta.append((inst["r"][i]*si) % n); vp.append((c[i]*si) % n)
S = [ZZ(1)] + [ZZ(1) << l for _ in range(t)]
Bm = matrix(ZZ, t+1, t+1); Bm[0,0]=1
for i in range(t): Bm[0,1+i] = S[1+i]*beta[i]
for i in range(t): Bm[1+i,1+i] = n*S[1+i]
t0=time.time(); R = Bm.LLL(); print("LLL:", round(time.time()-t0,3), "s")
t0=time.time(); L = IntegerLattice(R); print("construct:", round(time.time()-t0,3), "s")
tau = vector(QQ, t+1); tau[0] = QQ(n//2)
for i in range(t): tau[1+i] = QQ((1<<(64-l))//2) - QQ(S[1+i])*QQ(vp[i])
for meth in ('babai', 'nearest', 'voronoi'):
    t0=time.time()
    try:
        v = L.closest_vector(tau, method=meth)
        print(f"  closest_vector(method={meth}): {round(time.time()-t0,3)}s ->", v)
    except Exception as e:
        print(f"  closest_vector(method={meth}) FAILED: {type(e).__name__}: {e}")
