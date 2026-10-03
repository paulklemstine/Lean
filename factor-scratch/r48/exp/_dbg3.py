import math
from control import top_bits_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval, integer_roots
from reduce import reduce_fpylll
from lll import row_log2norm
inst=top_bits_instance(256,1,1,2)
p,N,a,X=inst['p'],inst['N'],inst['a'],inst['X']; x0=p-a
for m in (4,8,12,16):
    rows,scale=univariate_lattice([a,1],N,X,m,1)
    R=reduce_fpylll(rows)
    hg=0.5*m*256-0.5*math.log2(len(rows))
    print("m=%2d dim=%2d ||v||=2^%.1f HG=2^%.1f"%(m,len(rows),row_log2norm(R[0]),hg))
    for i in range(min(3,len(R))):
        pv=poly_trim([R[i][c]//scale[c] for c in range(len(R[i]))])
        val=poly_eval(pv,x0)
        print("   vec%d deg=%d ||v||=2^%.1f h(x0)=%s"%(i,len(pv)-1,row_log2norm(R[i]),"ZERO" if val==0 else "2^%.1f"%((abs(val).bit_length()-1))))
