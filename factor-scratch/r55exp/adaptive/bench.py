import sys, time, random
sys.path.insert(0,'/home/raver1975/lean/Experiments/UMWWindow')
from coppersmith_lattice import gen_prime, factor_with_top_bits, _reduced_polys
random.seed(20261004)
n=64
while True:
    p=gen_prime(n//2); q=gen_prime(n//2); N=p*q
    if 2**(n-1)<=N<2**n: break
nn=N.bit_length(); q4=nn//4
print("nn",nn,"q4",q4)
for (m,t) in [(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8),(9,9),(10,10)]:
    for k in (q4, q4-2):
        tb=nn//2-k; X=1<<tb
        t0=time.time()
        _reduced_polys([(p>>tb)*X,1],N,X,m,t)
        dt=time.time()-t0
        print(f"  m={m} t={t} k={k} time={dt*1000:.1f}ms", flush=True)
