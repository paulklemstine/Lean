from fractions import Fraction


def oracle_count(n: int, a: int = 3) -> int:
    """Number of a-valued oracles on n statements: a ** n."""
    return a ** n


def reachable_fraction(n: int, budget: int, a: int = 3) -> Fraction:
    """Exact fraction min(budget, a**n) / a**n reachable by `budget` programs."""
    total = oracle_count(n, a)
    return Fraction(min(budget, total), total)


def binary_geometric_law(n: int) -> Fraction:
    """Exact binary-reachable fraction 2**N / 3**N == (2/3)**N."""
    frac = Fraction(2 ** n, 3 ** n)
    assert frac == Fraction(2, 3) ** n  # binary_fraction_eq
    return frac
