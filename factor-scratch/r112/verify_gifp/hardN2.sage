import time
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__']='__main__'
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/hardN2.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
b1,b2=RR(0.1),RR(0.15)
for N in [400,600,800]:
    r=generate_gifp_instance(N,RR(0.1),RR(0.7),b1,b2,31337,max_attempts=10)
    if r is None: P("n=%d GEN-NONE"%N); continue
    (p1,q1,N1),(p2t,q2t,N2),sh,ds=r
    P("n=%d |q2|=%d bits |p2|=%d bits  N2=%d bits"%(N,q2t.nbits(),p2t.nbits(),N2.nbits()))
    t0=time.time()
    out=pari(N2).factor()          # PARI: ECM+MPQS; will print "*** at top level: timeout"
    el=time.time()-t0
    P("   factor(N2) in %.2fs -> %s"%(el,str(out)[:120]))
