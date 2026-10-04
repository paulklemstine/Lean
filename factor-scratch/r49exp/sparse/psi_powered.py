"""Higher-powered version of the exact Pr[FB0|r] control: c=10 gives b+10 columns."""
import json, random, sys
sys.path.insert(0,"/home/raver1975/lean/factor-scratch/r49exp/sparse")
from spcore import factor_base, fb_exponents, cols_from_rels, make_rels, rand_g
print("POWERED control for (*) : Pr[p|r] = Psi(n/p,B)/Psi(n,B), p = smallest FB prime")
print(f"{'n':>7} {'B':>5} {'b':>4} {'ncols':>6} {'exact':>8} {'measured':>9} {'z':>7} {'top2 rows':>22}")
rows=[]
for n,B in ((997,20),(1009,30),(2003,30),(5003,50)):
    FB=factor_base(B,n); assert 2 in FB
    p0=FB[0]; tot=hit=0
    for r in range(1,n+1):
        _e,rem=fb_exponents(r,FB)
        if rem==1:
            tot+=1
            if r%p0==0: hit+=1
    exact=hit/tot
    rng=random.Random(770000+n); g=rand_g(n,rng); b=len(FB)
    rels,_,_,_=make_rels(n,g,b,10,rng,cap=2_000_000)
    cols=cols_from_rels(rels); rowdeg=[0]*b
    for col in cols:
        for i,_e in col: rowdeg[i]+=1
    nc=len(cols); meas=rowdeg[0]/nc
    sd=(exact*(1-exact)/nc)**0.5
    z=(meas-exact)/sd
    print(f"{n:>7} {B:>5} {b:>4} {nc:>6} {exact:>8.4f} {meas:>9.4f} {z:>7.2f} {str(rowdeg[:2]):>22}")
    rows.append({"n":n,"B":B,"b":b,"ncols":nc,"exact":exact,"measured":meas,"z":z})
    # for scale: exact Pr for p=3 too
    p1=FB[1]; t2=h2=0
    for r in range(1,n+1):
        _e,rem=fb_exponents(r,FB)
        if rem==1:
            t2+=1
            if r%p1==0: h2+=1
    e2=h2/t2; m2=rowdeg[1]/nc; z2=(m2-e2)/((e2*(1-e2)/nc)**0.5)
    print(f"{'':>7} {'(p=3)':>5} {'':>4} {'':>6} {e2:>8.4f} {m2:>9.4f} {z2:>7.2f}")
json.dump(rows,open("psi_powered.json","w"),indent=1)
