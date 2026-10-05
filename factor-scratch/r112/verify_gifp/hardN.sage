import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/hardN.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
b1,b2=RR(0.1),RR(0.15)
for N in [400,600,800]:
    r=generate_gifp_instance(N,RR(0.1),RR(0.7),b1,b2,31337,max_attempts=10)
    if r is None: P("n=%d GEN-NONE"%N); continue
    (p1,q1,N1),(p2t,q2t,N2),sh,ds=r
    P("n=%d |q2|=%d bits |p2|=%d bits"%(N,q2t.nbits(),p2t.nbits()))
    t0=time.time()
    try:
        g=pari(N2).factor(timeout=60)
        P("   factor(N2) via PARI in %.2fs -> %s"%(time.time()-t0,"COMPLETE" if str(g)!='[1, ...]' else "GAVE UP (timeout)"))
    except Exception as e:
        P("   factor(N2) -> %.2fs EXC %s"%(time.time()-t0,e))
