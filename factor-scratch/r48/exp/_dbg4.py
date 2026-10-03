from control import top_bits_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval
from reduce import reduce_fpylll
from lll import row_log2norm
inst=top_bits_instance(256,1,1,2)
p,N=inst['p'],inst['N']; unk=56; a=(p>>unk)<<unk; X=1<<unk; x0=p-a
m=8
rows,scale=univariate_lattice([a,1],N,X,m,1)
print("x0 = a+x0 == p?", a+x0==p, " x0< X?", x0<X)
for i,r in enumerate(rows):
    rec=[r[c]//scale[c] for c in range(len(r))]
    val=poly_eval(rec,x0)
    print("basis row%d deg=%d eval mod p^m = %s"%(i,len(rec)-1, val%(p**m)))
R=reduce_fpylll(rows)
for i in range(3):
    rec=poly_trim([R[i][c]//scale[c] for c in range(len(R[i]))])
    val=poly_eval(rec,x0)
    print("reduced vec%d ||v||=2^%.1f  eval=%s  eval mod p^m=%s"%(i,row_log2norm(R[i]),"ZERO" if val==0 else "2^%.0f"%(val.bit_length()-1), val%(p**m)))
