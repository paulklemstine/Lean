import time, random
from sympy.polys.matrices import DomainMatrix
from sympy import ZZ

random.seed(1)
for d in (10,20,30):
    rows=[[random.getrandbits(1024) for _ in range(d)] for _ in range(d)]
    M = DomainMatrix.from_list(rows,ZZ)
    t=time.time(); L=M.lll(); print("sympy lll d=%d:"%d, round(time.time()-t,2),"s")
