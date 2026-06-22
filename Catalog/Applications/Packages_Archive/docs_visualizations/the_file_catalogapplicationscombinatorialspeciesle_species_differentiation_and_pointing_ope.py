from fractions import Fraction
from typing import Callable, List

Seq = Callable[[int], Fraction]

def seq_deriv(a: Seq) -> Seq:
    """Derivative species: (F')_n = a_{n+1} (adjoin a ghost label)."""
    return lambda n: a(n + 1)

def seq_point(a: Seq) -> Seq:
    """Pointed species: (F^.)_n = n * a_n (mark a special label)."""
    return lambda n: Fraction(n) * a(n)

def derivative_series(f: List[Fraction]) -> List[Fraction]:
    """Formal derivative d/dX: [X^n] f' = (n+1) [X^{n+1}] f. Equals EGF(seq_deriv a)."""
    return [Fraction(n + 1) * f[n + 1] for n in range(len(f) - 1)]
