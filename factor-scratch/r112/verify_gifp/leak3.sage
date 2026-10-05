# NEGATIVE CONTROL: shuffle the Groebner basis elements / random polynomials.
# If "recovery" is real, only the TRUE lattice polys give p2.
import time,sys
LOGF='/home/raver1975/lean/factor-scratch/r112/verify_gifp/leak3.log'
import builtins
_bp=builtins.print
def print(*a,**k):
    _bp(*a,**k)
    fh=open(LOGF,'a'); fh.write(' '.join(str(x) for x in a)+'\n'); fh.close()
builtins.print=print
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
n=200; a=RR(0.1); b1,b2=RR(0.1),RR(0.15); m=4
import random
ok_true=0; ok_scram=0; T=8
for k in range(T):
    seed=8000000+104729*k
    B=build(n,a,RR(0.7),b1,b2,m,seed)
    R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
    if R.get("best"): ok_true+=1
    # SCRAMBLE: replace the lattice polys with random degree-5 polys of the same shape
    pr=ZZ["x","y","z","w"]; x,y,z,w=pr.gens()
    set_random_seed(seed+999)
    fake=[]
    for d in range(5):
        g=0
        for i in range(6):
            g+= randint(-2**40,2**40)*x**randint(0,3)*y**randint(0,3)*z**randint(0,1)*w**randint(0,3)
        fake.append(g)
    R2=scan_gb(fake,B["N2"],B["p2t"],B["q2t"],n)
    if R2.get("best"): ok_scram+=1
print("NEGATIVE CONTROL: true lattice polys recover p2 : %d/%d"%(ok_true,T))
print("NEGATIVE CONTROL: RANDOM polys recover p2     : %d/%d"%(ok_scram,T))
print("(random polys must give 0 -- if >0 the 'recovery' is a harness artifact)")

# DEGENERATE-PATH TEST: is `a` ever N2 itself, or 1?
print()
print("=== degenerate-path check: distribution of recovered divisor size ===")
for k in range(6):
    B=build(n,a,RR(0.7),b1,b2,m,7000000+104729*k)
    R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],n)
    if R.get("best"):
        h=R["best"]; c=ZZ(h["coef"])
        print("  seed: |a|=%d bits, N2=%d bits, a==N2? %s a==1? %s divides? %s ==p2? %s"%(
            abs(c).nbits(), B["N2"].nbits(), abs(c)==B["N2"], abs(c)==1, B["N2"]%c==0, h["equals_p2"]))
