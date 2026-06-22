from fractions import Fraction
from typing import Callable, List

CountingSeq = Callable[[int], Fraction]

def derivative_species(a: CountingSeq) -> CountingSeq:
    """Joyal's derivative species F'[n] = F[n+1]."""
    return lambda n: a(n + 1)

def iterate_derivative_species(a: CountingSeq, k: int) -> CountingSeq:
    """k-fold derivative species F^(k)[n] = F[n+k]."""
    return lambda n: a(n + k)

def tower_table(a: CountingSeq, K: int, N: int) -> List[List[Fraction]]:
    return [[a(n + k) for n in range(N)] for k in range(K)]
