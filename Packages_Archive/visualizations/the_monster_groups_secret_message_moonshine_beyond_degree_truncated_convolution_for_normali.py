from fractions import Fraction
from typing import Sequence

def product(factors: Sequence[Sequence[int]], degree: int) -> tuple[int, list[Fraction]]:
    p = [Fraction(1)] + [Fraction(0)] * degree
    for factor in factors:
        if not factor or factor[0] != 1:
            raise ValueError("normalization requires constant coefficient 1")
        p = [sum((p[i] * Fraction(factor[k-i]) for i in range(k+1)
                  if i < len(p) and k-i < len(factor)), Fraction(0))
             for k in range(degree+1)]
    return -len(factors), p

if __name__ == "__main__":
    print(product([[1,1], [1,2], [1,-1,1]], 4))
