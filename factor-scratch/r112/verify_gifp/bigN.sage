import time
exec(compile(open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/vcore.sage').read(),'vcore.sage','exec'))
LOG=open('/home/raver1975/lean/factor-scratch/r112/verify_gifp/bigN.log','a')
def P(*a): LOG.write(' '.join(str(x) for x in a)+'\n'); LOG.flush()
# Does the GIFP attack still recover p2 when N2 is a GENUINELY HARD modulus?
# |q2| = alpha*n. n=200,alpha=0.1 -> 20 bits (trivial). Scale n so |q2| ~ 100+ bits.
b1,b2=RR(0.1),RR(0.15)
for (N,A,G) in [(200,0.10,0.70),(400,0.10,0.70),(600,0.10,0.70),(800,0.10,0.70)]:
    P("=== n=%d alpha=%.2f gamma=%.2f -> |q2|=%d bits, |p2|=%d bits ==="%(N,A,G,int(A*N),int((1-A)*N)))
    ok=0;T=3
    for k in range(T):
        seed=31337+104729*k
        t0=time.time()
        try: B=build(N,RR(A),RR(G),b1,b2,4,seed)
        except Exception as e: P("   seed%d GEN-EXC %s"%(seed,e)); continue
        if B["status"]!="ok_build": P("   seed%d %s"%(seed,B["status"])); continue
        tb=time.time()-t0
        t1=time.time(); R=scan_gb(B["polys"],B["N2"],B["p2t"],B["q2t"],N)
        if R.get("best"): ok+=1
        P("   seed%d q2bits=%d build=%.1fs gb=%s recovered=%s (%.1fs)"%(seed,B["q2t"].nbits(),tb,R["status"],bool(R.get("best")),time.time()-t1))
    P("   -> %d/%d recovered p2"%(ok,T))
