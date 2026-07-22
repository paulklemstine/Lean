from fractions import Fraction
from typing import Sequence

def exact_rank(a: Sequence[Sequence[int]]) -> int:
    m=[[Fraction(x) for x in row] for row in a]
    if not m: return 0
    r=0
    for c in range(len(m[0])):
        p=next((i for i in range(r,len(m)) if m[i][c]),None)
        if p is None: continue
        m[r],m[p]=m[p],m[r]; d=m[r][c]; m[r]=[x/d for x in m[r]]
        for i in range(len(m)):
            if i != r:
                d=m[i][c]; m[i]=[x-d*y for x,y in zip(m[i],m[r])]
        r += 1
        if r == len(m): break
    return r
