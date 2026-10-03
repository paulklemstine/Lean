import time
from control import make_instance
from coppersmith import univariate_lattice, poly_trim
from reduce import reduce_fpylll
from lll import row_log2norm
p,q,N=make_instance(256,1); nb=p.bit_length()
unk=64; a=p>>unk; X=1<<unk
rows,scale=univariate_lattice([a,1],N,X,12,1)
R=reduce_fpylll(rows)
for i,r in enumerate(R[:4]):
    pv=poly_trim([r[c]//scale[c] for c in range(len(r))])
    print("vec%d deg=%d log2norm=%.1f coef bits=%s"%(i,len(pv)-1,row_log2norm(r),[c.bit_length() for c in pv[:6]]))
# try sympy root finding on the first
import sympy
t=time.time()
pv=poly_trim([R[0][c]//scale[c] for c in range(len(R[0]))])
print("deg",len(pv)-1)
g=sympy.Poly(pv, sympy.Symbol('x')).ground_roots()
print("ground_roots %.2fs"%(time.time()-t), g)
print("x0 should be", p-a, "= 2^%.1f"%((p-a).bit_length()-1))
