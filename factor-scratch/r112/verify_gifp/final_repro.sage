# SECOND independent run of Claims 1 & 2, different seed block, plus 10.9 cross-check at claim 1.
import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/final_repro.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;a=RR(0.1);b1,b2=RR(0.1),RR(0.15);m=4
def run(gam,seeds):
    ok=0
    for s in seeds:
        B=build(n,RR(a),gam,b1,b2,m,s)
        if B["status"]!="ok_build": continue
        R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
        if R.get("best"): ok+=1
    return ok,len(seeds)
P("RUN2 (fresh seed block, independent of run1):")
o,t=run(RR(0.7),[11000000+15485863*k for k in range(20)]); P("  CLAIM1 gamma=0.70 : %d/%d"%(o,t))
o,t=run(RR(0.2),[11000000+104729*k for k in range(10)]);   P("  CLAIM2 gamma=0.20 : %d/%d"%(o,t))
o,t=run(RR(0.3),[11000000+104729*k for k in range(10)]);   P("  CLAIM2 gamma=0.30 : %d/%d"%(o,t))
