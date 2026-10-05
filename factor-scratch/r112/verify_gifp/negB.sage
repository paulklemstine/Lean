import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/negB.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;a=RR(0.1);b1,b2=RR(0.1),RR(0.15);m=4
pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
# Fast control: keep the SAME z*w-N2 constraint (so GB reaches len 4 fast)
# but replace the lattice polys by random ones. Must give 0.
ok=0;N=10
for k in range(N):
    seed=8000000+104729*k
    B=build(n,a,RR(0.7),b1,b2,m,seed)
    set_random_seed(seed+31337)
    # random polys that all vanish at NOTHING in particular, small coeffs, low degree
    fake=[sum(randint(1,10**9)*x**randint(0,2)*y**randint(0,2)*z**randint(0,1)*w**randint(0,2) for _ in range(4)) for d in range(3)]
    R=scan_gb(fake,B["N2"],B["p2t"],B["q2t"],n)
    if R.get("best"): ok+=1
    P("  seed%d fake-gb=%s best=%s"%(seed,R["status"],bool(R.get("best"))))
P("NEGCTRL-B RANDOM polys recover p2 : %d/%d  (must be 0)"%(ok,N))
