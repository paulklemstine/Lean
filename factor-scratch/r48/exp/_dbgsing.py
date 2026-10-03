from coppersmith import univariate_lattice, polypow, poly_trim
from reduce import det
N=1000003; a=12345; X=64
rows,scale=univariate_lattice([a,1],N,X,3,3)
print("dim",len(rows),"det",det(rows))
for i,r in enumerate(rows):
    nz=[(c,v) for c,v in enumerate(r) if v]
    print("row%d nzcols=%s"%(i,[c for c,v in nz]))
