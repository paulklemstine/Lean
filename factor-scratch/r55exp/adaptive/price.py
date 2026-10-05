#!/usr/bin/env python3
"""
price.py -- PRICE THE ADAPTIVE STRATEGY.  No modelling assumptions: every cost is a
measured wall-clock number from sweep.py, every strategy is an ORDERED list of
cells, and the per-instance cost is exactly "sum of cell costs up to first success".

ERROR LOG (mine, r55, v1): the first version indexed the per-instance success vector
by position in the JSON dict (k-major) but looked it up with an index into the
COST-GREEDY (m,t) order.  Those are different orderings, so it silently read the
WRONG cells -- and printed the absurd result that all six k values succeed on exactly
the same 117/200 instances.  Caught because identical rates at k=n/4 and k=n/4-5 are
impossible: smaller k means LARGER X, i.e. strictly harder.  Now every cell is keyed
by (k,m,t) and looked up by key.

STRATEGIES (identical known-bits budget; they differ only in which k they may try):
  B0  single cheapest (m,t) cell at k=n/4          -- ONE lattice
  Bd  full (m,t) sweep at k=n/4                    -- 81 lattices, cost-greedy order
  Ad  Bd, then k=n/4-1, ..., n/4-d                -- the hypothesis under test

METRIC: cost per FACTORED modulus = mean cost over all instances / fraction factored.
"""
import sys, json, statistics

def analyse(path, verbose=True):
    D=json.load(open(path)); rows=D["rows"]; T=D["T"]
    n4=rows[0]["n4"]
    order=[tuple(int(x) for x in mt.split(",")) for mt in D["cells_order"]]  # (m,t) cost-greedy
    ks=sorted({int(k.split("|")[0]) for k in rows[0]["cells"]}, reverse=True)   # n/4 first
    OK={}; COST={}
    for r in rows:
        for key,v in r["cells"].items():
            k,m,t=key.split("|"); key=(int(k),int(m),int(t))
            OK.setdefault(r["N"],{})[key]=bool(v[0])
            COST.setdefault(key,[]).append(v[1])
    Ns=[r["N"] for r in rows]
    med={key:statistics.median(v) for key,v in COST.items()}
    kat={k:[((k,mt[0],mt[1]),) for mt in order] for k in ks}

    def strat(strat_ks):
        cost=[];suc=[];tried=[]
        for N in Ns:
            c=0.0;done=False;nt=0
            for k in strat_ks:
                for (key,) in kat[k]:
                    nt+=1; c+=med[key]
                    if OK[N][key]: done=True;break
                if done: break
            cost.append(c);suc.append(done);tried.append(nt)
        rate=sum(suc)/T; mc=statistics.mean(cost)
        return rate, mc, (mc/rate if rate else float("inf")), statistics.mean(tried)

    if verbose:
        print(f"\n{'='*84}\nn = {D['nbits']} bits (n/4 = {n4}), T = {T}, "
              f"{len(order)} (m,t) cells/k, k in {ks[0]}..{ks[-1]}\n{'='*84}")
        print("\n--- PER-K SUCCESS (distribution, not a threshold) ---")
        print("    k    n/4-k   log2(X)=n/2-k   X/N^(1/4)      hit      count    note")
        for k in ks:
            js=[(k,mt[0],mt[1]) for mt in order]
            h=sum(1 for N in Ns if any(OK[N][j] for j in js))
            note="UNDERPOWERED (count<20) -- do not interpret" if h<20 else ""
            print(f"  {k:4d}   {k-n4:+3d}      {D['nbits']//2-k:5d}      "
                  f"2^{k-n4:+3d}      {h:4d}/{T}   {h:5.1f}    {note}")
        print("\n--- SINGLE-CELL rate at k=n/4: the multiple-comparisons price ---")
        sc=sorted(((sum(OK[N][(n4,mt[0],mt[1])] for N in Ns)/T, mt,
                    med[(n4,mt[0],mt[1])]) for mt in order), key=lambda z:-z[0])
        for r,mt,c in sc[:5]:
            print(f"    (m,t)=({str(mt):7s}) single-cell {r:6.1%}   cost {c*1e3:7.3f} ms")
        for r,mt,c in sc[-3:]:
            print(f"    (m,t)=({str(mt):7s}) single-cell {r:6.1%}   cost {c*1e3:7.3f} ms")
        print("\n--- STRATEGY COMPARISON (measured costs; median per cell) ---")
        print(f"    {'strategy':38s} {'rate':>7s} {'mean_s':>9s} {'s/factored':>11s} {'cells':>7s}")
        cheap=((n4,order[0][0],order[0][1]),)
        r=sum(OK[N][cheap[0]] for N in Ns)/T
        c=med[cheap[0]]
        print(f"    {'B0 single cheapest cell @ n/4':38s} {r:7.1%} {c:9.6f} "
              f"{(c/r if r else float('inf')):11.6f} {1:7.1f}")
        br,bmc,bcpf,bnt=strat([n4])
        print(f"    {'Bd full (m,t) sweep @ n/4':38s} {br:7.1%} {bmc:9.6f} {bcpf:11.6f} {bnt:7.1f}")
        print()
        for d in range(1,len(ks)):
            sk=[n4-j for j in range(d+1)]
            if not all(k in kat for k in sk): break
            r,mc,cpf,nt=strat(sk)
            gain=cpf<bcpf
            print(f"    A{d:<2d} n/4 .. n/4-{d:<2d}{'':14s}      {r:7.1%} {mc:9.6f} "
                  f"{cpf:11.6f} {nt:7.1f}  x{nt/bnt:4.2f} "
                  f"{'<<< BEATS n/4 sweep' if gain else ''}")
        # how many instances does adaptivity ADD over the n/4 sweep?
        base={N for N in Ns if any(OK[N][(n4,mt[0],mt[1])] for mt in order)}
        full={N for N in Ns if any(OK[N][(k,mt[0],mt[1])] for k in ks for mt in order)}
        print(f"\n    instances factored by the n/4 sweep alone : {len(base)}/{T}")
        print(f"    instances factored by ANY k tried         : {len(full)}/{T}")
        print(f"    ADDED by going below n/4                  : {len(full-base)}/{T} "
              f"({len(full-base)/T:.1%})")
    return dict(D=D,OK=OK,med=med,order=order,ks=ks,n4=n4,T=T,Ns=Ns,kat=kat,strat=strat)

if __name__=="__main__":
    for p in sys.argv[1:]: analyse(p)
