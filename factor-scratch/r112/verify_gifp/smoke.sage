import time
_g = globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__']='__main__'
t0=time.time()
r = generate_gifp_instance(200, RR(0.1), RR(0.7), RR(0.1), RR(0.15), 1791165034802635, max_attempts=10)
print("gen time", time.time()-t0)
print("is None:", r is None)
(p1,q1,N1),(p2t,q2t,N2),share,ds = r
print("N1 bits",N1.nbits(),"N2 bits",N2.nbits())
print("p1*q1==N1", p1*q1==N1, "p2*q2==N2", p2t*q2t==N2)
print("p2t",p2t); print("q2t",q2t); print("ds",ds)
print("N1",N1); print("N2",N2)
print("p1",p1); print("q1",q1)
