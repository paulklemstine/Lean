# M4 method test: is the 97f "n/4 wall" the MATHEMATICAL bound, or the ceiling of a
# FIXED (m,t<=10) parameter sweep?  Re-run the same experiment with the sweep widened.
import sys, random
sys.path.insert(0, '/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, factor_with_top_bits

def trial(N,p,nn,k,mlo,mhi,tlo,thi):
    for m in range(mlo,mhi):
        for t in range(tlo,thi):
            if factor_with_top_bits(N,p,nn,k,m,t): return True
    return False

for n in [48,64,80]:
    random.seed(0)
    while True:
        p=gen_prime(n//2); q=gen_prime(n//2); N=p*q
        if 2**(n-1)<=N<2**n: break
    nn=N.bit_length(); quarter=nn//4
    for (mlo,mhi,tlo,thi,tag) in [(2,10,2,10,'orig m,t in 2..9'),
                                  (2,26,2,26,'WIDE m,t in 2..25')]:
        row=[]
        for k in range(quarter-4, quarter+5):
            row.append('k=%d:%s'%(k,'Y' if trial(N,p,nn,k,mlo,mhi,tlo,thi) else '-'))
        print('n=%d n/4=%d  [%s]'%(nn,quarter,tag)); print('   ',' '.join(row))
