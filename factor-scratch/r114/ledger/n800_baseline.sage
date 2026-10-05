import time
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__']='__main__'
r = generate_gifp_instance(Integer(800), RR(0.1), RR(0.7), RR(0.1), RR(0.15), Integer(31337), max_attempts=10)
(p1,q1,N1),(p2t,q2t,N2),sh,ds = r
print("instance: |q2|=%d |p2|=%d N2=%d bits" % (q2t.nbits(), p2t.nbits(), N2.nbits()))
print("r112 hardN2.log claimed factor(N2) succeeded in 310.72 s. REPRODUCING:", flush=True)
t0=time.time(); out = pari(N2).factor(); dt=time.time()-t0
print("pari(N2).factor() -> %.2f s" % dt, flush=True)
M = matrix(ZZ, out)
got = sorted([ZZ(M[i][0]) for i in range(M.nrows())])
print("rows=%d  solved=%s  ground-truth-exact=%s" % (M.nrows(), got != [N2], got == sorted([p2t,q2t])))
