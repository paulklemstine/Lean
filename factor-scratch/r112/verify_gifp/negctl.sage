import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/negctl.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
n=200;a=RR(0.1);b1,b2=RR(0.1),RR(0.15);m=4
okT=0;okS=0;T=10
pr=ZZ["x","y","z","w"];x,y,z,w=pr.gens()
for k in range(T):
    seed=8000000+104729*k
    B=build(n,a,RR(0.7),b1,b2,m,seed)
    R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
    if R.get("best"): okT+=1
    # NEGATIVE CONTROL: random polys, SMALL coeffs (fast), same shape
    set_random_seed(seed+555)
    fake=[]
    for d in range(5):
        g=0
        for i in range(8):
            g+= randint(1,10**12)*x**randint(0,2)*y**randint(0,2)*z**randint(0,1)*w**randint(0,2)
        fake.append(g)
    R2=scan_gb(fake,B["N2"],B["p2t"],B["q2t"],n)
    if R2.get("best"): okS+=1
P("NEGCTRL true-lattice recovers p2 : %d/%d"%(okT,T))
P("NEGCTRL RANDOM polys recover p2 : %d/%d  (must be 0)"%(okS,T))
