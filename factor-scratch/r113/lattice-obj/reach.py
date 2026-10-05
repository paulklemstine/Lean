import sys; sys.path.insert(0,'/home/raver1975/lean/factor-scratch/r113/lattice-obj')
from lib import *
from sage.all import log, exp, RealField
R = RealField(60)
def LN13(N):   # NFS L-notation
    N = R(N); return R((R(64)/R(9)).n())**(R(1)/R(3))/R(3) * N.n()**(R(1)/R(3)) * log(N).n()**(R(2)/R(3))
def LN12(N):   # ECM L-notation (rigorous, Shoup 15.6 has constant 2*sqrt(2))
    N = R(N); return R(2)*R(2).sqrt() * log(N).n().sqrt()*log(N).n().log().sqrt()
print("L_N[1/3] (NFS heuristic)  vs  N:")
for N in [1000,5400,10**4,10**6,10**8,10**12,10**20,10**40,10**60,10**100,10**300,2**2048]:
    print("  N=%-10.4g  L[1/3]=%-12.5f  L[1/2]=%-12.5f" % (N, LN13(N), LN12(N)))
# solve L[1/3]=8.6
from sage.all import find_root
f = lambda x: LN13(x) - R('8.6')
lo=R(100); hi=R(10**8)
print("\nL[1/3]=8.6 at N =", find_root(f, lo, hi))
print("bits of that N =", R(find_root(f,lo,hi)).nbits() if hasattr(R(find_root(f,lo,hi)),'nbits') else float(log(R(find_root(f,lo,hi)),2)))
