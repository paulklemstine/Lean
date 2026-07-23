from typing import Sequence

def mat_vec(M: Sequence[Sequence[int]], x: Sequence[int], p: int) -> tuple[int,...]:
    return tuple(sum(a*b for a,b in zip(row,x)) % p for row in M)

def collide(M: Sequence[Sequence[int]], a: Sequence[int], b: Sequence[int], p: int) -> bool:
    difference=tuple((x-y)%p for x,y in zip(a,b))
    return all(v==0 for v in mat_vec(M,difference,p))

if __name__ == "__main__":
    M=[[1,0,1,0],[0,1,0,1]]
    a=(1,2,3,4); b=(3,3,1,3)
    print(collide(M,a,b,5))
