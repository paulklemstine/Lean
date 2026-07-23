from itertools import product
from typing import Sequence

def representatives(M: Sequence[Sequence[int]], p: int) -> dict[tuple[int,...],tuple[int,...]]:
    n=len(M[0]); result={}
    for x in product(range(p),repeat=n):
        y=tuple(sum(a*b for a,b in zip(row,x))%p for row in M)
        result.setdefault(y,x)
    return result

if __name__ == "__main__":
    reps=representatives([[1,0,1,0],[0,1,0,1]],5)
    print(f"{len(reps)} canonical representatives")
    print(list(reps.items())[:5])
