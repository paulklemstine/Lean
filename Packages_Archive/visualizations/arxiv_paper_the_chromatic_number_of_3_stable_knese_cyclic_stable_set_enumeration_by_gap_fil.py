from itertools import combinations
from typing import List, Tuple

StableSet = Tuple[int, ...]

def gaps(a: StableSet, n: int) -> Tuple[int, ...]:
    return tuple(a[i+1]-a[i] for i in range(len(a)-1)) + (n+a[0]-a[-1],)

def stable_sets(n: int, s: int, k: int) -> List[StableSet]:
    return [a for a in combinations(range(n), k) if all(g >= s for g in gaps(a, n))]

if __name__ == "__main__":
    for n, s, k in [(9,3,3), (8,2,3), (12,3,3)]:
        sets=stable_sets(n,s,k)
        print((n,s,k), len(sets), sets[:8])
