from fractions import Fraction

def check_refinement(n, k, X):
    """Check refinement invariance of expectation."""
    mass_c = Fraction(1, n + 1)
    coarse = sum(X(i) * mass_c for i in range(n + 1))
    fine_n = k * (n + 1) - 1
    mass_f = Fraction(1, fine_n + 1)
    fine = sum(X(j // k) * mass_f for j in range(fine_n + 1))
    return coarse == fine

# Example
X = lambda i: Fraction(i * i)
print(check_refinement(5, 3, X))  # True