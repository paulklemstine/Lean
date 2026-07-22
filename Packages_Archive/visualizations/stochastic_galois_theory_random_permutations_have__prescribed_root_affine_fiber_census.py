from itertools import product
from typing import List, Tuple

def value(a: Tuple[int, ...], x: int, p: int) -> int:
    y=1
    for c in reversed(a): y=(y*x+c)%p
    return y

def fibers(p: int, n: int) -> List[int]:
    vectors=list(product(range(p),repeat=n))
    return [sum(value(a,r,p)==0 for a in vectors) for r in range(p)]

if __name__ == "__main__":
    for p,n in [(2,2),(3,3),(5,4)]:
        f=fibers(p,n)
        print(p,n,f,"expected each",p**(n-1))
