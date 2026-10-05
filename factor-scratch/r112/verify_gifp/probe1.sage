import time,sys
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/probe1.log','a')
def P(*a):
    LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200; b1,b2=RR(0.1),RR(0.15)
A=0.05; thr=4*float(A)*(1-sqrt(float(A)))
for rat in [1.0,1.4]:
    g=float(snap:=round(thr*rat,6))
    P("ratio %.1f gamma=%.5f"%(rat,g))
    for s in [7000000+7919*k for k in range(2)]:
        t0=time.time()
        try:
            B=build(n,RR(A),RR(g),b1,b2,4,s)
        except Exception as e:
            P("  seed %d EXC %s (%.1fs)"%(s,e,time.time()-t0)); continue
        if B["status"]!="ok_build": P("  seed %d %s"%(s,B["status"])); continue
        t1=time.time(); R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
        P("  seed %d build=%.1fs gb=%s tries=%d best=%s (%.1fs)"%(s,t1-t0,R["status"],R.get("tries",0),bool(R.get("best")),time.time()-t1))
