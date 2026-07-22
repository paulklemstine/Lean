from itertools import combinations
from typing import Tuple

StableSet = Tuple[int, ...]

def cyclic_gaps(a: StableSet, n: int) -> Tuple[int, ...]:
    return tuple(a[i+1]-a[i] for i in range(len(a)-1))+(n+a[0]-a[-1],)

def main() -> None:
    triples=((0,3,6),(1,4,7),(2,5,8))
    for a in triples:
        print(a, "gaps", cyclic_gaps(a,9), "color", min(a[0],2))
    print("pairwise disjoint:", all(set(a).isdisjoint(b) for a,b in combinations(triples,2)))
    A,B=(1,4),(2,5)
    print("counterexample", A, B, "colors", min(A[0],1), min(B[0],1))
if __name__ == "__main__": main()
