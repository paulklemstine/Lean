from dick import rho
import math
TAB={2:0.3068528194,3:0.0486083883,4:0.0049109256,5:0.0003547242,6:1.96497e-5,7:9.3736e-7,8:3.8658e-8,9:1.4331e-9,10:4.7694e-11,12:3.4187e-14}
print("=== SELF-TEST A: NULL branch rho(u)=1 for u<=1 (null is CORRECT there) ===")
for u in (-1,0,0.3,0.9999,1.0):
    v=rho(u); print(f"  rho({u}) = {v}   {'OK null returned' if v==1.0 else '**NULL BROKEN**'}")
print("=== SELF-TEST B: published table (positive control) ===")
bad=[]
for u,t in TAB.items():
    m=rho(u); d=abs(m-t)/t
    if d>2e-6: bad.append(u)
    print(f"  rho({u:>2}) mine={m:.10g} table={t:.10g} relerr={d:.2e} {'OK' if d<2e-6 else '**FAIL**'}")
print("  continuity at knot 3:", rho(3-1e-9), rho(3), rho(3+1e-9))
print("  monotone decreasing [1,12]:", all(rho(u)>rho(u+1) for u in range(1,12)))
print("  ALL TABLE POINTS PASS:", not bad)
print()
print("=== #521 sec 2: rho at u=ln1684/ln1000 ; paper claims rho=0.927264, reported 'EC baseline' 0.925 ===")
u=math.log(1684)/math.log(1000)
print("  u = ln(1684)/ln(1000) =",u," (paper prints 1.0754)")
print("  rho(u) =",rho(u))
print("  rho(1.0754) =",rho(1.0754))
print("  -> rounds to %.4f ; gap to reported 0.925 = %.4f"%(rho(u),rho(u)-0.925))
print()
print("=== #522 sec 3.5 tower table: paper ln rho(k*7.35) = -12.4/-39.4/-71.1/-105.9 ===")
claim={1:-12.4,2:-39.4,3:-71.1,4:-105.9}
for k in (1,2,3,4):
    uu=7.35*k; v=math.log(rho(uu)); u_=uu
    crud=-(uu*(math.log(uu)+math.log(math.log(uu))-1))
    print(f"  k={k} u={uu:6.2f}  exact ln rho={v:9.2f}  paper={claim[k]:7.1f}  delta={v-claim[k]:+8.2f}   1st-order-asympt={crud:9.2f}")
print()
print("  'cost vs k=1' column paper = 1.00/3.18/5.74/8.54 ; rho(7.35)/rho(k*7.35) =")
for k in (1,2,3,4):
    print(f"    k={k}: rho(7.35)/rho({7.35*k:.2f}) = {rho(7.35)/rho(7.35*k):.4g}")
