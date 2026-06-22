from fractions import Fraction
from typing import List

Seq = List[Fraction]

def species_derivative(f: Seq) -> Seq:
    """Derivative species F'[n] = F[n+1] on counting sequences (Theorem 5.3)."""
    return [f[n + 1] for n in range(len(f) - 1)]

def species_pointed(f: Seq) -> Seq:
    """Pointed species F*[n] = n * F[n] on counting sequences (Theorem 5.4)."""
    return [Fraction(n) * f[n] for n in range(len(f))]

def egf_derivative(c: Seq) -> Seq:
    """Formal derivative on EGF coefficients: c_n -> (n+1) c_{n+1}."""
    return [Fraction(n + 1) * c[n + 1] for n in range(len(c) - 1)]

def egf_euler(c: Seq) -> Seq:
    """Euler operator X d/dX on EGF coefficients: c_n -> n c_n."""
    return [Fraction(n) * c[n] for n in range(len(c))]
