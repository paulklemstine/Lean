from fractions import Fraction
from typing import Sequence

def solve(a: Sequence[Sequence[int]], b: Sequence[int]) -> list[Fraction]:
    n = len(a)
    m = [[Fraction(x) for x in a[i]] + [Fraction(b[i])] for i in range(n)]
    for c in range(n):
        pivot = next((r for r in range(c,n) if m[r][c]), None)
        if pivot is None: raise ValueError("noninjective encoding")
        m[c], m[pivot] = m[pivot], m[c]
        d=m[c][c]; m[c]=[x/d for x in m[c]]
        for r in range(n):
            if r != c:
                d=m[r][c]; m[r]=[x-d*y for x,y in zip(m[r],m[c])]
    return [m[i][-1] for i in range(n)]

if __name__ == "__main__":
    print(solve([[1,1],[1,-1]], [5,1]))
