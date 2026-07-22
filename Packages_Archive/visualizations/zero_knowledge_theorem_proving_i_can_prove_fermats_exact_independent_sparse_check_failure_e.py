from fractions import Fraction

def failure(n: int, k: int) -> Fraction:
    if n <= 0 or k < 0:
        raise ValueError("require n > 0 and k >= 0")
    return Fraction(n - 1, n) ** k

for n, k in [(4, 10), (22, 10), (102, 50)]:
    print(n, k, float(failure(n, k)), float(Fraction(1, 2) ** k))
