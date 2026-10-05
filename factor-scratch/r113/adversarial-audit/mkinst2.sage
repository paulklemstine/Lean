import json, os
os.chdir('/home/raver1975/lean/factor-scratch/r113/adversarial-audit')
from sage.all import *
load('/home/raver1975/lean/Experiments/UMWWindow/gifp_ref/gifp.sage')
# gifp.sage is designed to be IMPORTED FROM PYTHON, where 0.15 is a float.
# Under the .sage preparser 0.15 becomes an exact Rational and randint() rejects it.
# Pass Python floats explicitly.
for s in range(20261005, 20261020):
    r = generate_gifp_instance(600, float(0.15), float(0.70), float(0.1), float(0.15), seed=s, max_attempts=1)
    if r is not None:
        (p1,q1,N1),(p2,q2,N2),share,sol = r
        assert p2*q2==N2
        print("n600a15 seed=%d N2=%d bits |q2|=%d bits |p2|=%d bits"%(s,int(N2).nbits(),ZZ(q2).nbits(),ZZ(p2).nbits()))
        open('n600a15_N2.txt','w').write(str(int(N2))+'\n')
        json.dump(dict(N2=int(N2),p2=int(p2),q2=int(q2),seed=int(s)), open('n600a15.json','w'))
        break
else:
    print("FAILED all seeds")
