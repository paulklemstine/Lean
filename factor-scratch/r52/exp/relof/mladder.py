"""Q1: MEASURED relation-collection cost. Positive control F(1,0)==N asserted
on EVERY cell (BUG: an earlier version filtered on N.bit_length()==bits and
silently produced ZERO rows -- a harness that measures nothing)."""
import sys,time,math,json
sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r52/exp/relof')
from sympy import nextprime, primepi
from nfsrel import sieve_collect, mont_cubic

def rand_rsa(bits):
    p=int(nextprime(int(2**(bits/2)))); q=int(nextprime(int(1.3*2**(bits/2))))
    return p*q

print(f"{'bits':>5} {'BB':>7} {'u=lnV/lnB':>11} {'|FB|':>7} {'X':>5} {'cells':>8} "
      f"{'sieve_mk':>10} {'n_surv':>7} {'mk/cell':>8} {'t_sieve':>9}", flush=True)
rows=[]
for bits,BB,X in [(40,300,25),(44,600,30),(48,1200,35),(52,2400,40),(56,4800,45),
                  (60,9600,50),(64,19200,55)]:
    N=rand_rsa(bits); d,c=mont_cubic(N)
    assert d**3+c==N, f"POSITIVE CONTROL FAILED at {bits}b"
    V=(d*X)**3; u=math.log(V)/math.log(BB)
    t0=time.time()
    r=sieve_collect(N,BB,X,X,collect=False,d=d,c=c)
    dt=time.time()-t0; mk=r['sieve_marks']
    print(f"{bits:>5} {BB:>7} {u:>11.3f} {int(primepi(BB)):>7} {X:>5} {r['cells']:>8} "
          f"{mk:>10} {r['n_surv']:>7} {mk/r['cells']:>8.3f} {r['t_sieve']:>9.4f}  ({dt:.1f}s)", flush=True)
    rows.append(dict(bits=bits,N_bits=N.bit_length(),BB=BB,u=u,X=X,cells=r['cells'],
                     sieve_marks=mk,n_surv=r['n_surv'],t_sieve=r['t_sieve'],wall=dt))
json.dump(rows,open('/home/raver1975/lean/factor-scratch/r52/exp/relof/results/q1_measured.json','w'),indent=1)
print("\nsaved results/q1_measured.json")
