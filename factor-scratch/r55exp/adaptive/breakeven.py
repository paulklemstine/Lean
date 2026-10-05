#!/usr/bin/env python3
"""
breakeven.py -- WHAT WOULD IT TAKE for the hypothesis to be true?

The negative result is a statement about THESE parameters.  This turns it into the
threshold that a future round must beat, which is the useful form of a negative.

Model, stated explicitly.  Let
    r4   = P(the n/4 sweep factors an instance)          [measured]
    a    = P(the n/4 sweep fails AND k=n/4-1 succeeds)   [measured: the marginal tail]
    c4   = expected cost of the n/4 sweep                [measured]
    ca   = extra cost of running the n/4-1 sweep         [measured]

Adaptive pays off iff
       r4 + a  over  (c4 + ca)   beats   r4 / c4
   i.e.  a*c4  >  r4*ca   i.e.   a/r4  >  ca/c4.

  a/r4  is the RELATIVE YIELD of one extra bit of budget below n/4.
  ca/c4 is the RELATIVE COST of one extra bit of budget below n/4.

We measure both, and then SOLVE for the a that would be needed.  That number is the
target for any future attempt, and it is a much more useful object than the negative.
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
    Ns=[r["N"] for r in rows]
    return D,T,n4,order,ks,OK,med,Ns

def main(path):
    D,T,n4,order,ks,OK,med,Ns=load(path)
    def run(strat):
        cs=[];sc=[]
        for N in Ns:
            c=0.0;done=False
            for k in strat:
                for mt in order:
                    c+=med[(k,mt[0],mt[1])]
                    if OK[N][(k,mt[0],mt[1])]: done=True;break
                if done: break
            cs.append(c);sc.append(done)
        return sum(sc)/T, statistics.mean(cs)
    r4,c4=run([n4])
    r1,c1=run([n4,n4-1])
    r2,c2=run([n4,n4-1,n4-2])
    a1=r1-r4; ca1=c1-c4
    a2=r2-r1; ca2=c2-c1
    print(f"\n### n={D['nbits']} (n/4={n4}) T={T}   [grid m,t<=10, {len(order)} cells/k]")
    print(f"  r4 = {r4:.3f}   c4 = {c4:.4f}s")
    for tag,(a,ca,r,c) in (("+1 bit (k=n/4-1)",(a1,ca1,r1,c1)),
                           ("+2 bits (k=n/4-2)",(a2,ca2,r2,c2))):
        if a<=0:
            print(f"  {tag}: marginal yield a = {a:+.4f} (NON-POSITIVE -- no win is even possible)")
            continue
        need_yield=ca/c4
        have_yield=a/r4
        print(f"  {tag}: marginal yield a = {a:+.4f}  (a/r4 = {have_yield:.4f})")
        print(f"           marginal cost  = {ca:.4f}s (ca/c4 = {need_yield:.4f})")
        print(f"           -> {'BEATS n/4' if have_yield>need_yield else 'LOSES to n/4'} "
              f"by a factor of {have_yield/need_yield:.3f}")
        print(f"           -> the a that WOULD be needed: a* = {r4*ca:.4f} "
              f"({r4*ca/a:.1f}x the observed a)")

if __name__=="__main__":
    for p in sys.argv[1:]: main(p)
