from fractions import Fraction
from math import comb, factorial

def common_fixed_point_probability(n: int, r: int) -> Fraction:
    """Exact probability r random permutations share a common fixed point."""
    total = Fraction(0)
    nfact = factorial(n)
    for j in range(1, n + 1):
        sign = (-1) ** (j + 1)
        total += sign * comb(n, j) * Fraction(factorial(n - j), nfact) ** r
    return total

# Example
for n in [5, 10, 20, 50]:
    for r in [2, 3, 4]:
        p = common_fixed_point_probability(n, r)
        print(f"n={n}, r={r}: P = {float(p):.8f}")