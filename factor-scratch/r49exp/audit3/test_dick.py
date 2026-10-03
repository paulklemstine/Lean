from dick import rho
from mpmath import mp, mpf
mp.dps=20
TAB={2:0.3068528194,3:0.0486083883,4:0.0049109256,5:0.0003547242,6:1.96497e-5,7:9.3736e-7,8:3.8658e-8}
print("=== NEGATIVE CONTROL: the NULL branch rho(u)=1 for u<=1 ===")
for u in (0,0.5,1.0):
    v=rho(u); print(f"  rho({u}) = {v}   {'OK null' if v==1 else '**NULL BROKEN**'}")
print("=== validation against published table ===")
ok=True
for u,t in TAB.items():
    m=rho(u); d=abs(m-t)/t
    print(f"  rho({u}) mine={float(m):.10g} table={t:.10g} relerr={float(d):.2e} {'OK' if d<2e-6 else '**FAIL**'}")
    ok &= d<2e-6
print("validated:",ok)
print()
print("=== §2 of #521: rho(1.0754) claimed 0.927264 ===")
u=mpf('1.0754'); print("  rho(1.0754) =", rho(u))
u2=__import__('math').log2(1684)/__import__('math').log2(1000)
print("  exact u = log2(1684)/log2(1000) =", u2)
print("  rho(u) =", rho(u2))
print()
print("=== §3.5 tower table of #522: ln rho(k*7.35) claimed -12.4/-39.4/-71.1/-105.9 ===")
import math
for k in (1,2,3,4):
    u=7.35*k
    v=float(mp.log(rho(u)))
    claim={1:-12.4,2:-39.4,3:-71.1,4:-105.9}[k]
    # also crude first-order asymptotic the paper may have used
    crud=-(u*(math.log(u)+math.log(math.log(u))-1))
    print(f"  k={k} u={u:.2f} exact ln rho = {v:9.2f}  paper={claim:7.1f}  delta={v-claim:+7.2f}   crude-1st-order={crud:9.2f}")
