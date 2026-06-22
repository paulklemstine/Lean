from fractions import Fraction


def weil_factor_product(n: int, q: int, T: Fraction, reflected: bool) -> Fraction:
    """Evaluate one side of the Weil functional equation for P^n.

    reflected=False -> prod_{i=0}^{n} (1 - q^i T)
    reflected=True  -> prod_{i=0}^{n} (q^{n-i} T - 1)

    The identity weil_factor_product(reflected=True)
      = (-1)^{n+1} * weil_factor_product(reflected=False)
    is the division-free Weil functional equation. O(n) multiplications.
    """
    prod = Fraction(1)
    for i in range(n + 1):
        if reflected:
            prod *= Fraction(q) ** (n - i) * T - 1
        else:
            prod *= 1 - Fraction(q) ** i * T
    return prod
