from dataclasses import dataclass

@dataclass(frozen=True)
class CanonicalInvariants:
    valency: int
    coefficient: int
    genus: int
    degree: int
    rank: int

def canonical_invariants(n: int) -> CanonicalInvariants:
    if n < 1:
        raise ValueError("n must be positive")
    g = (n - 1) * (n - 2) // 2
    ans = CanonicalInvariants(n - 1, n - 3, g, n * (n - 3), g - 1)
    if ans.degree != 2 * ans.genus - 2:
        raise ArithmeticError("canonical consistency check failed")
    return ans
