import math
from control import top_bits_instance
from coppersmith import univariate_lattice, poly_eval, poly_trim
from reduce import det, reduce_fpylll
inst=top_bits_instance(256,1,1,2)
p,N=inst['p'],inst['N']
for unk in (57,64,96):
    a=(p>>unk)<<unk; X=1<<unk; x0=p-a
    print("=== unk=%d x0=2^%.0f (N^0.25=2^64)"%(unk,x0.bit_length()-1))
    for (m,t) in ((8,8),(10,10),(12,12),(14,14),(16,16),(8,16),(16,8),(20,20)):
        rows,scale=univariate_lattice([a,1],N,X,m,t)
        D=abs(det(rows))
        dim=len(rows)
        # LLL guarantee on ||v0||, and HG need: 2^{(dim-1)/4} det^{1/dim} < p^m/sqrt(dim)
        lhs = (dim-1)/4.0 + math.log2(D)/dim
        rhs = 0.5*m*256 - 0.5*math.log2(dim)
        print("   dim=%2d  LLL-guaranteed ||v||=2^%.1f   HG needs 2^%.1f   margin=2^%.2f  %s"%(
            dim,lhs,rhs,rhs-lhs,"OK" if lhs<rhs else "insufficient"))
