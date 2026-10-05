#!/usr/bin/env python3'
"""
whycost.py -- WHY the adaptive rule loses, in one number.

breakeven.py shows a* is only 1.1-2.2x the observed marginal yield at +1 bit: the
hypothesis is NOT short on raw hit rate, it is short on COST EFFICIENCY.  This
script isolates the cause.

The intuition the hypothesis rests on is "try a few budgets, take the best".  That is
cheap only if a BELOW-n/4 lattice is about as cheap as an n/4 lattice.  It is not:
a sub-n/4 lattice needs a LARGER dimension to have any chance, because the Howgrave-
Graham bound ||h|| < N^m/sqrt(d) must still hold when X is bigger by 2^j.

So the cells that produce the marginal tail are systematically the EXPENSIVE ones.
We measure, per k, the cheapest cell that succeeds on even ONE instance -- the
"entry price" of that budget -- and compare it to the n/4 sweep's average cell.
"""
import sys, json, statistics

def load(p):
    D=json.load(open(p)); rows=D["rows"]; T=D["T"]; n4=rows[0]["n4"]
    order=[tuple(int(x) for x in mt.split(",")) for mt in D["cells_order"]]
    ks=sorted({int(k.split("|")[0]) for k in rows[0]["cells"]},reverse=True)
    OK={};C={}
    for r in rows:
        for key,v in r["cells"].items():
            k,m,t=key.split("|"); kk=(int(k),int(m),int(t))
            OK.setdefault(r["N"],{})[kk]=bool(v[0]); C.setdefault(kk,[]).append(v[1])
    med={k:statistics.median(v) for k,v in C.items()}
    return D,T,n4,order,ks,OK,med,[r["N"] for r in rows]

for path in sys.argv[1:]:
    D,T,n4,order,ks,OK,med,Ns=load(path)
    print(f"\n### n={D['nbits']} (n/4={n4}) T={T}")
    print("  ENTRY PRICE per budget: cost of the CHEAPEST cell that succeeds at all,")
    print("  and the cost of the cheapest cell that succeeds on a MARGINAL instance")
    print("  (one the n/4 sweep already failed):")
    print(f"    {'k':>4s} {'n/4-k':>6s} {'min d hitting':>13s} {'cheapest hit cell s':>21s} "
          f"{'cheapest MARGINAL hit s':>25s}")
    for k in ks:
        hit=[(med[(k,m[0],m[1])],m[0]*m[1]) for m in order
             if any(OK[N][(k,m[0],m[1])] for N in Ns)]
        marg=[(med[(k,m[0],m[1])],m[0]*m[1]) for m in order
              if any(OK[N][(k,m[0],m[1])] and not any(OK[N][(n4,a,b)] for a,b in order) for N in Ns)]
        if not hit:
            print(f"    {k:4d} {k-n4:+6d} {'--':>13s} {'NO HIT AT ALL':>21s}")
            continue
        cm=min(marg)[0] if marg else float('nan')
        print(f"    {k:4d} {k-n4:+6d} {min(h[1] for h in hit):13d} "
              f"{min(hit)[0]:21.6f} {cm:25.6f}")
    # average cell cost actually paid by the n/4-only sweep
    asc=sorted(order,key=lambda z:(z[0]*z[1],z[0],z[1]))
    paid=[]
    for N in Ns:
        c=0.0
        for mt in asc:
            c+=med[(n4,mt[0],mt[1])]
            if OK[N][(n4,mt[0],mt[1])]: break
        paid.append(c)
    print(f"    mean cost actually paid by the n/4 sweep: {statistics.mean(paid):.6f}s")
