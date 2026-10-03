"""T1 core sweep: the UNKNOWN-bit count is the natural axis.  For each unk,
does the attack recover p?  Reported per-unk so the break is at the bit."""
import sys, time
from control import make_instance
from coppersmith import univariate_small_roots

bits = int(sys.argv[1]); lo=int(sys.argv[2]); hi=int(sys.argv[3])
seeds=[int(s) for s in sys.argv[4].split(',')]
print("N=%d bits, p=%d bits, N^0.25 = 2^%d"%(bits,bits//2,bits//4))
print("unknown  leak%%   outcome")
for unk in range(lo,hi+1):
    row=[]
    for seed in seeds:
        p,q,N=make_instance(bits,seed)
        a=(p>>unk)<<unk; X=1<<unk
        roots,diag=univariate_small_roots([a,1],N,X,mod_is_factor=True,cross_check=False)
        row.append(bool(roots))
    verdict = 'WORKS' if all(row) else ('FAILS' if not any(row) else 'MIXED')
    print("unk=%2d leak=%5.1f%%  %-6s %s"%(unk,100*(1-unk/(bits//2)),verdict,' '.join('Y' if r else '.' for r in row)),flush=True)
