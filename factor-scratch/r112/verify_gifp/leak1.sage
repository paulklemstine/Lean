import time
_g = globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__']='__main__'

print("=== TRIVIALITY TEST: is N2 factorable with ZERO GIFP knowledge? ===")
for (a,g) in [(0.1,0.7),(0.1,0.3),(0.05,0.5),(0.15,0.6),(0.20,0.6),(0.25,0.5)]:
    r = generate_gifp_instance(200, RR(a), RR(g), RR(0.1), RR(0.15), 4242+int(a*1000)+int(g*10000), max_attempts=10)
    if r is None:
        print("a=%.2f g=%.2f GEN-NONE"%(a,g)); continue
    (p1,q1,N1),(p2t,q2t,N2),share,ds = r
    t0=time.time(); fac=list(factor(N2)); el=time.time()-t0
    got=set(u for u,_ in fac)
    print("a=%.2f g=%.2f  q2_bits=%2d p2_bits=%3d  factor(N2)=%s  %.4fs  ==true? %s"%(
        a,g,q2t.nbits(),p2t.nbits(),fac,el,(p2t in got and q2t in got)))
