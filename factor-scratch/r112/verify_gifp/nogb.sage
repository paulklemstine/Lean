# Is `no_gb` a failure of the MATH or an artifact of (a) the pop-loop or (b) only looking at G[1].gcd(G[2])?
import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/nogb.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;a=RR(0.1);b1,b2=RR(0.1),RR(0.15);m=4
pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()

def deep_scan(B, N2, p2t, q2t, budget=25):
    """Try EVERY prefix of the polynomial list (no popping), every Groebner basis,
       EVERY pair, EVERY monomial coefficient."""
    pols=list(B); pols.insert(0, z*w-N2)
    found=[]
    Lk=len(pols)
    # try full list and each truncation from the front
    for cut in range(1, Lk+1):
        sub=pols[:cut]
        S=Sequence(sub, pr.change_ring(QQ, order='lex'))
        try: G=S.groebner_basis()
        except Exception: continue
        for i in range(len(G)):
            for j in range(i+1,len(G)):
                try: gd=G[i].gcd(G[j])
                except Exception: continue
                if gd.is_constant(): continue
                try: fs=gd.factor()
                except Exception: continue
                for fac,mu in fs:
                    for mono in fac.monomials():
                        cc=fac.monomial_coefficient(mono)
                        if cc in (0,1,-1): continue
                        if N2 % cc==0 and (int(cc)==p2t or int(cc)==q2t):
                            found.append((cut,i,j,int(cc)))
    return found

for lbl,gam,seeds in [("ABOVE-thr gamma=0.70",RR(0.7),[5000000+15485863*k for k in range(4)]),
                      ("BELOW-thr gamma=0.30",RR(0.3),[3000000+104729*k for k in range(4)])]:
    st={}; deep_hits=0
    for s in seeds:
        B=build(n,a,gam,b1,b2,m,s)
        if B["status"]!="ok_build": st[B["status"]]=st.get(B["status"],0)+1; continue
        R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
        st[R["status"]]=st.get(R["status"],0)+1
        if R.get("best"): continue
        # it FAILED via the standard path -> does a deeper scan rescue it?
        f=deep_scan(B["polys"],B["N2"],B["p2t"],B["q2t"])
        if f: deep_hits+=1; P("  DEEP RESCUE at %s seed=%d : %s"%(lbl,s,f[:3]))
    P("%s : %s  deep-rescues=%d/%d"%(lbl,st,deep_hits,len(seeds)))
