def spectral_complexity(d: int, mu: list) -> float:
    from fractions import Fraction
    return d + sum(abs(m) for m in mu)