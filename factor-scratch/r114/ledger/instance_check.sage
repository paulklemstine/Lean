import time
_g=globals(); _g['__name__']='gifp_mod'
exec(compile(open('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage').read(),'gifp.sage','exec'), _g)
_g['__name__']='__main__'
# EXACT reproduction of r112/verify_gifp/hardN2.sage.py parameters
r = generate_gifp_instance(Integer(800), RR(0.1), RR(0.7), RR(0.1), RR(0.15), Integer(31337), max_attempts=10)
(p1,q1,N1),(p2t,q2t,N2),sh,ds = r
print("n=800 alpha=0.10 gamma=0.70 seed=31337")
print("  |q2| = %d bits, |p2| = %d bits, N2 = %d bits" % (q2t.nbits(), p2t.nbits(), N2.nbits()))
print("  ground truth p2 == q2 == N2? %s ; p2*q2 == N2 -> %s" % (p2t==q2t, p2t*q2t==N2))
# the factor PARI returned, verbatim from hardN2.log line 6
cand = ZZ(934029894621535196592551)
print("  PARI-logged factor %d:" % cand)
print("    nbits =", cand.nbits(), " == q2 (true) ?", cand == q2t)
print("    divides N2 exactly ?", N2 % cand == 0)
print("    N2/cand == p2 (true) ?", N2//cand == p2t)
