from control import make_instance
from coppersmith import univariate_lattice, poly_eval
p,q,N=make_instance(256,1); nb=p.bit_length()
unk=64; a=p>>unk; X=1<<unk; x0=p-a
print("x0 bits",x0.bit_length(),"X bits",X.bit_length(),"p bits",nb)
rows,scale=univariate_lattice([a,1],N,X,6,1)
print("dim",len(rows),"nrows",len(rows))
# round-trip check on the raw basis rows
for i,r in enumerate(rows):
    rec=[r[c]//scale[c] for c in range(len(r))]
    ok=all(rec[c]*scale[c]==r[c] for c in range(len(r)))
    val=poly_eval(rec,x0)
    if i<3 or i>=len(rows)-2:
        print("row%d roundtrip=%s  eval(x0) log2=%s  p^6 log2=%.1f"%(i,ok,(abs(val).bit_length()-1) if val else '-inf',6*128))
# is eval divisible by p^6?
r=rows[6]; rec=[r[c]//scale[c] for c in range(len(r))]
val=poly_eval(rec,x0)
print("row6 = %s"%(rec[:3]))
print("val mod p^6 =", val % (p**6))
