from control import top_bits_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval
from reduce import reduce_fpylll
from lll import row_log2norm
inst=top_bits_instance(256,1,1,2)
p,N=inst['p'],inst['N']
for unk in (48,56,60,64):
    a=(p>>unk)<<unk; X=1<<unk; x0=p-a
    print("=== unk=%d (leak %.1f%%) x0=2^%.0f, N^0.25=2^64"%(unk,100*(1-unk/128),(x0).bit_length()-1))
    for m in (8,12,16,20,24):
        rows,scale=univariate_lattice([a,1],N,X,m,1)
        R=reduce_fpylll(rows)
        rec=poly_trim([R[0][c]//scale[c] for c in range(len(R[0]))])
        val=poly_eval(rec,x0)
        pm=p**m
        print("   m=%2d dim=%2d ||v||=2^%.1f  log2|h(x0)|=%s  log2(p^m)=%.1f  ratio=2^%.2f"%(
            m,len(rows),row_log2norm(R[0]), ("ZERO" if val==0 else "%.1f"%(val.bit_length()-1)), pm.bit_length()-1,
            (val.bit_length()-1)-(pm.bit_length()-1) if val else -999))
