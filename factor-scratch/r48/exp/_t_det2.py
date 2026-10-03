import random
from lll import _det_int
random.seed(5); bad=0
for t in range(200):
    n=random.randint(2,7)
    M=[[random.randint(-50,50) for _ in range(n)] for _ in range(n)]
    # exact det by permutation expansion
    import itertools
    tot=0
    for perm in itertools.permutations(range(n)):
        s=1
        for i,j in enumerate(perm): s*=M[i][j]
        inv=sum(1 for i in range(n) for j in range(i+1,n) if perm[i]>perm[j])
        tot+=(-1)**inv*s
    if _det_int(M)!=tot:
        bad+=1
        if bad<4: print("MISMATCH",M,_det_int(M),tot)
print("det_int mismatches out of 200:",bad)
