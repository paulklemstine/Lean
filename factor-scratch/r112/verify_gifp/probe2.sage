import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/probe2.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;b1,b2=RR(0.1),RR(0.15); A=0.05; thr=4*A*(1-sqrt(A))
for rat in [1.0,1.2,1.4,1.6]:
    g=float(ZZ(round(thr*rat*n))/n)
    P("a=%.2f ratio=%.1f gamma_snapped=%.5f thr=%.5f"%(A,rat,g,thr))
    for s in [7000000+7919*k for k in range(8)]:
        t0=time.time()
        try: B=build(n,RR(A),RR(g),b1,b2,4,s)
        except Exception as e: P("   seed%d EXC"%(s)); continue
        if B["status"]!="ok_build": P("   seed%d %s"%(s,B["status"])); continue
        R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
        P("   seed%d %s best=%s (%.1fs)"%(s,R["status"],bool(R.get("best")),time.time()-t0))
