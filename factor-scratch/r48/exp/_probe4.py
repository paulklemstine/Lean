import time, math
from control import make_instance
from coppersmith import univariate_lattice, poly_eval
from reduce import reduce_fpylll, row_log2norm
p,q,N=make_instance(256,1); nb=p.bit_length()
for unk in (nb//2-8, nb//2, nb//2+8):
    a=p>>unk; X=1<<unk
    for m in (4,8,12,16):
        t=time.time(); rows,scale=univariate_lattice([a,1],N,X,m,1)
        tb=time.time()-t
        t=time.time(); R=reduce_fpylll(rows); tr=time.time()-t
        hg=0.5*m*256-0.5*math.log2(len(rows))
        print("unk=%3d m=%2d dim=%2d build %.2fs red %.2fs ||v||=2^%.1f HG=2^%.1f ratio=2^%.2f"%(
            unk,m,len(rows),tb,tr,row_log2norm(R[0]),hg,row_log2norm(R[0])-hg))
