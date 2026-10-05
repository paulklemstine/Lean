# LEAK TEST: is the "recovered" p2 obtainable with ZERO GIFP knowledge / is it trivially there?
import time,sys
LOGF='/home/raver1975/lean/factor-scratch/r112/verify_gifp/leak2.log'
import builtins
_bp=builtins.print
def print(*a,**k):
    _bp(*a,**k)
    fh=open(LOGF,'a'); fh.write(' '.join(str(x) for x in a)+'\n'); fh.close()
builtins.print=print
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
n=200; b1,b2=RR(0.1),RR(0.15)
print("=== A) TRIVIAL ROUTE: factor(N2) with no GIFP at all, n=200 ===")
for A in [0.05,0.10,0.15,0.20,0.25]:
    r=generate_gifp_instance(n,RR(A),RR(0.5),b1,b2,9090+int(A*100),max_attempts=10)
    if r is None: print(" a=%.2f GEN-NONE"%A); continue
    (p1,q1,N1),(p2t,q2t,N2),sh,ds=r
    t0=time.time(); f=list(factor(N2)); el=time.time()-t0
    got=set(u for u,_ in f)
    print("  a=%.2f |q2|=%2d bits  factor(N2) exact=%s  %.4fs"%(A,q2t.nbits(),(p2t in got and q2t in got),el))

print()
print("=== B) BLOW-UP: same attack at n=1000,2000 -- is N2 still trivially factorable? ===")
for N in [1000,2000]:
    r=generate_gifp_instance(N,RR(0.1),RR(0.5),RR(0.1),RR(0.15),77,max_attempts=10)
    if r is None: print("  n=%d GEN-NONE (bit budget not exact)"%N); continue
    (p1,q1,N1),(p2t,q2t,N2),sh,ds=r
    t0=time.time(); f=list(factor(N2)); el=time.time()-t0
    got=set(u for u,_ in f)
    print("  n=%d |q2|=%4d bits factor(N2)=%.2fs exact=%s"%(N,q2t.nbits(),el,p2t in got and q2t in got))
