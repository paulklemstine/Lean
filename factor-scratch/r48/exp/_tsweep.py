from control import top_bits_instance
from coppersmith import univariate_lattice, poly_trim, poly_eval
from reduce import reduce_fpylll
inst=top_bits_instance(256,1,1,2)
p,N=inst['p'],inst['N']
for unk in (56,64,72):
    a=(p>>unk)<<unk; X=1<<unk; x0=p-a
    print("=== unk=%d  leak=%.1f%% of p  (need X < N^0.25 = 2^64)"%(unk,100*(1-unk/128)))
    for m,t in ((8,8),(12,12),(16,16),(20,20),(16,8),(20,10),(24,12),(30,15),(24,24)):
        rows,scale=univariate_lattice([a,1],N,X,m,t)
        R=reduce_fpylll(rows)
        rec=poly_trim([R[0][c]//scale[c] for c in range(len(R[0]))])
        val=poly_eval(rec,x0)
        print("   m=%2d t=%2d dim=%2d  %s"%(m,t,len(rows),"FOUND h(x0)=0" if val==0 else "log2|h|=%.0f vs log2 p^m=%.0f"%(val.bit_length()-1,(p**m).bit_length()-1)))
