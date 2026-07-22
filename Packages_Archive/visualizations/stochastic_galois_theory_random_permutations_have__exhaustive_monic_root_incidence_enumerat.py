from itertools import product
from typing import Dict, Tuple

def value(a: Tuple[int, ...], x: int, p: int) -> int:
    y = 1
    for c in reversed(a):
        y = (y*x+c) % p
    return y

def root_distribution(p: int, n: int) -> Dict[int, int]:
    out: Dict[int, int] = {}
    for a in product(range(p), repeat=n):
        k = sum(value(a, x, p) == 0 for x in range(p))
        out[k] = out.get(k, 0) + 1
    return dict(sorted(out.items()))

if __name__ == "__main__":
    for p, n in [(2,2),(3,2),(3,3),(5,3)]:
        d=root_distribution(p,n)
        total=sum(k*v for k,v in d.items())
        print(p,n,d,total,"expected",p**n)
