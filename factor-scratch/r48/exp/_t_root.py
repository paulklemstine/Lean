import time, sympy
from sympy import Symbol, Poly
from control import top_bits_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval, integer_roots
from reduce import reduce_fpylll
inst=top_bits_instance(256,1,1,2); p,N=inst['p'],inst['N']
unk=57; a=(p>>unk)<<unk; X=1<<unk; x0=p-a
m=t=8
rows,scale=univariate_lattice([a,1],N,X,m,t)
R=reduce_fpylll(rows)
pv=poly_trim([R[0][c]//scale[c] for c in range(len(R[0]))])
print("deg",len(pv)-1,"| coef bits",[c.bit_length() for c in pv[:4]])
print("h(x0) =", poly_eval(pv,x0))
x=Symbol('x')
t0=time.time()
try:
    gr=Poly(pv,x,domain='ZZ').ground_roots(); print("ground_roots %.1fs"%(time.time()-t0), dict(list(gr.items())[:5]))
except Exception as e: print("ground_roots ERR",type(e).__name__, "%.1fs"%(time.time()-t0))
t0=time.time(); print("integer_roots:",integer_roots(pv,-X,X),"%.1fs"%(time.time()-t0))
