import time
from control import top_bits_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval, integer_roots
from reduce import reduce_fpylll
inst=top_bits_instance(256,1,1,2); p,N=inst['p'],inst['N']
unk=57; a=(p>>unk)<<unk; X=1<<unk; x0=p-a
rows,scale=univariate_lattice([a,1],N,X,8,8)
R=reduce_fpylll(rows)
for i in (0,1):
    pv=poly_trim([R[i][c]//scale[c] for c in range(len(R[i]))])
    t0=time.time(); rs=integer_roots(pv,-X,X,nbits=X.bit_length())
    print("vec%d deg=%d h(x0)=%s roots=%s %.1fs"%(i,len(pv)-1,poly_eval(pv,x0)==0,rs[:3],time.time()-t0),flush=True)
