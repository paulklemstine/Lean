import math
from control import make_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval
from reduce import reduce_fpylll
from lll import row_log2norm
p,q,N=make_instance(256,1); nb=p.bit_length()
unk=64; a=p>>unk; X=1<<unk; x0=p-a
m=12
rows,scale=univariate_lattice([a,1],N,X,m,1)
R=reduce_fpylll(rows)
for i,r in enumerate(R[:5]):
    pv=poly_trim([r[c]//scale[c] for c in range(len(r))])
    val=poly_eval(pv,x0)
    print("vec%d ||v||=2^%.1f  deg=%d  h(x0)=%s  log2|h(x0)|=%.2f  p^m=2^%.1f"%(
        i,row_log2norm(r),len(pv)-1, "0" if val==0 else "nonzero",
        (abs(val).bit_length()-1) if val else float('-inf'), 128*m))
