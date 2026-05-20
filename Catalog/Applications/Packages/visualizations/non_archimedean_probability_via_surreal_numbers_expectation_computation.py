from fractions import Fraction

def na_expectation(n, X):
    """Compute E[X] under uniform grid probability on Fin(n+1)."""
    mass = Fraction(1, n + 1)
    return sum(X(i) * mass for i in range(n + 1))

# Example: E[2x+1] on Fin(5)
a, b = Fraction(2), Fraction(1)
X = lambda i: a * Fraction(i, 4) + b
print(f"E[2x+1] = {na_expectation(4, X)}")  # Output: 2