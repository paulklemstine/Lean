import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/negctl2.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;a=RR(0.1);b1,b2=RR(0.1),RR(0.15);m=4
pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
# NEGATIVE CONTROL A: use the CORRECT lattice but a DIFFERENT instance's N2 (unrelated factors).
# If the pipeline leaks, it will still "recover" p2 of the wrong instance.
okT=0; okSwap=0; T=6
for k in range(T):
    B=build(n,a,RR(0.7),b1,b2,m,8000000+104729*k)
    R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
    if R.get("best"): okT+=1
    # swapped: attack built on instance A, but we ask whether it "recovers" a divisor of
    # an UNRELATED N2 (instance B). Genuine attack must give 0.
    B2=build(n,a,RR(0.7),b1,b2,m,9500000+104729*k)
    R2=scan_gb(B["polys"],B2["N2"],B2["p2t"],B2["q2t"],n)
    if R2.get("best"): okSwap+=1
P("NEGCTRL-A true N2 recovers p2            : %d/%d"%(okT,T))
P("NEGCTRL-A lattice A vs UNRELATED N2 (B)  : %d/%d  (must be 0)"%(okSwap,T))

# NEGATIVE CONTROL B: random polys, tiny coeffs, few vars (fast)
okR=0; N=8
for k in range(N):
    seed=8000000+104729*k
    B=build(n,a,RR(0.7),b1,b2,m,seed)
    set_random_seed(seed+777)
    fake=[sum(randint(1,10**6)*x**randint(0,2)*y**randint(0,2)*z**randint(0,1)*w**randint(0,2) for _ in range(5)) for d in range(4)]
    R=scan_gb(fake,B["N2"],B["p2t"],B["q2t"],n)
    if R.get("best"): okR+=1
P("NEGCTRL-B RANDOM polys recover p2       : %d/%d  (must be 0)"%(okR,N))
