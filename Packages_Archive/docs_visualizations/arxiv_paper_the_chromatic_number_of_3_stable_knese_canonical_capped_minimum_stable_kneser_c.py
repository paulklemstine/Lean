from itertools import combinations
from typing import List, Tuple

StableSet = Tuple[int, ...]

def stable(a: StableSet, n: int, s: int) -> bool:
    gaps=[a[i+1]-a[i] for i in range(len(a)-1)]+[n+a[0]-a[-1]]
    return min(gaps) >= s

def color(a: StableSet, r: int) -> int:
    return min(a[0], r-1)

def check(n: int, s: int, k: int, r: int) -> bool:
    if n != r+s*(k-1): raise ValueError("threshold identity required")
    vs=[a for a in combinations(range(n),k) if stable(a,n,s)]
    return all(not set(a).isdisjoint(b) or color(a,r)!=color(b,r)
               for a,b in combinations(vs,2))

if __name__ == "__main__":
    print("(9,3,3,3):", check(9,3,3,3))
    print("(8,2,3,4):", check(8,2,3,4))
