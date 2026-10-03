from control import top_bits_instance
from coppersmith import univariate_lattice
from reduce import det, reduce_fpylll
inst=top_bits_instance(256,1,1,4)
for m,t in ((8,8),(12,12),(20,20)):
    rows,scale=univariate_lattice([inst['a'],1],inst['N'],inst['X'],m,t)
    din=det(rows)
    R=reduce_fpylll(rows); dout=det(R)
    print("m=%d t=%d dim=%d det_in_bits=%s det_out_bits=%s equal=%s"%(
        m,t,len(rows),(din.bit_length()-1) if din else 'ZERO',(dout.bit_length()-1) if dout else 'ZERO',abs(din)==abs(dout)))
