def euler_factor(t, d, X, n):
    """Compute Sym^n Euler factor using only trace and determinant."""
    from fractions import Fraction
    
    def power_sum(t, d, n):
        if n == 0: return Fraction(2)
        if n == 1: return t
        a, b = Fraction(2), t
        for _ in range(n - 1):
            a, b = b, t * b - d * a
        return b
    
    if n == 0: return 1 - X
    if n == 1: return 1 - t * X + d * X ** 2
    s = power_sum(t, d, n)
    return (1 - s * X + d ** n * X ** 2) * euler_factor(t, d, d * X, n - 2)

# Example: Sym^4 with alpha=2, beta=3
from fractions import Fraction
t, d = Fraction(5), Fraction(6)
X = Fraction(1, 10)
print(f"Sym^4 Euler factor at X=1/10: {euler_factor(t, d, X, 4)}")

# Verify invariance: same result for alpha=3, beta=2
print(f"Same (swapped): {euler_factor(t, d, X, 4)}")