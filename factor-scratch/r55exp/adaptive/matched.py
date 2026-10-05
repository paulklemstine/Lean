#!/usr/bin/env python3
"""
matched.py -- THE HONEST CROSSOVER TEST: at EQUAL cost budget, how many moduli
does each strategy factor?

Comparing "cost per factored" across strategies with different success rates is
the wrong metric when the strategies also stop at different depths, because a
degenerate strategy that never succeeds has infinite cost/factored and looks
"safe".  The right picture is the cost-BUDGET curve:

    for each budget B (in seconds, and in lattice-solve COUNT):
        run each strategy with budget B
        report the fraction of the T moduli factored

Two budgets are reported because the answer depends on which currency you use:
 * SECONDS   -- favours axis M only if its big lattices are cheap, which they are not
 * CELL COUNT -- the unit the hypothesis is stated in ("d+1 times a single attempt")

STRATEGIES
  K(d)   n/4 sweep (cost-greedy) then k=n/4-1..n/4-d      -- the hypothesis
  M(d)   k=n/4 sweep but taking the best-d cells first     -- the theory-licensed axis
"""
import sys, json, statistics, argparse
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')

def load(p):
    D=json.load(open(p)); rows=D["rows"]; T=D["T"]; n4=rows[0]["n4"]
    order=[tuple(int(x) for x in mt.split(",")) for mt in D["cells_order"]]
    ks=sorted({int(k.split("|")[0]) for k in rows[0]["cells"]},reverse=True)
    OK={}; C={}
    for r in rows:
        for key,v in r["cells"].items():
            k,m,t=key.split("|"); kk=(int(k),int(m),int(t))
            OK.setdefault(r["N"],{})[kk]=bool(v[0]); C.setdefault(kk,[]).append(v[1])
    med={k:statistics.median(v) for k,v in C.items()}
    return D,T,n4,order,ks,OK,med,[r["N"] for r in rows]

def main(path):
    D,T,n4,order,ks,OK,med,Ns=load(path)
    asc=sorted(order,key=lambda z:(z[0]*z[1],z[0],z[1]))       # cost-greedy
    desc=sorted(order,key=lambda z:(-z[0]*z[1],z[0],z[1]))      # biggest lattice first
    def curve(order_per_k, budget, currency):
        hit=0
        for N in Ns:
            spent=0.0; cnt=0; done=False
            for k in ks:
                for mt in order_per_k(k):
                    c=med[(k,mt[0],mt[1])]
                    if currency=="s" and spent+c>budget: break
                    if currency=="c" and cnt>=budget: break
                    spent+=c; cnt+=1
                    if OK[N][(k,mt[0],mt[1])]: done=True;break
                if done: break
            hit+=done
        return hit/T
    print(f"\n### n={D['nbits']} (n/4={n4}), T={T}")
    budgets_s=[0.01,0.03,0.1,0.3,1.0,3.0]
    budgets_c=[1,5,20,81,200]
    for cur,bl in (("s",budgets_s),("c",budgets_c)):
        unit="seconds" if cur=="s" else "lattice solves"
        print(f"  -- budget in {unit}: fraction of {T} moduli factored --")
        print(f"     {'budget':>9s}  {'K: n/4 then below':>19s}  {'M: bigger lattice @n/4':>23s}   winner")
        for b in bl:
            fk=curve(lambda k: asc, b, cur)
            fm=curve(lambda k: desc, b, cur)
            w = "K" if fk>fm else ("M" if fm>fk else "tie")
            print(f"     {b:9.3g}  {fk:19.1%}  {fm:23.1%}   {w}")
    # the specific claim: "d+1 times a single attempt"
    print(f"\n  -- the hypothesis' own cost model: how many cells does K(d) use,")
    print(f"     as a multiple of the n/4-only sweep, and what does it buy? --")
    for d in range(0,min(4,len(ks)-1)):
        strat_ks=ks[:d+1]
        cs=[];sc=[];cn=[]
        for N in Ns:
            c=0.0;n=0;done=False
            for k in strat_ks:
                for mt in asc:
                    c+=med[(k,mt[0],mt[1])]; n+=1
                    if OK[N][(k,mt[0],mt[1])]: done=True;break
                if done:break
            cs.append(c);sc.append(done);cn.append(n)
        r=sum(sc)/T
        print(f"     d={d}: rate {r:6.1%}  mean cells {statistics.mean(cn):6.1f}  "
              f"mean seconds {statistics.mean(cs):7.4f}")

if __name__=="__main__":
    main(sys.argv[1])
