from enum import Enum
from typing import Callable, List

class Belnap(Enum):
    T = 'T'; F = 'F'; B = 'B'; N = 'N'

def neg(v: Belnap) -> Belnap:
    return {Belnap.T: Belnap.F, Belnap.F: Belnap.T,
            Belnap.B: Belnap.B, Belnap.N: Belnap.N}[v]

def diagonal_values() -> List[Belnap]:
    """Return all solutions of x = neg(x): exactly {B, N}."""
    return [v for v in Belnap if v == neg(v)]

def resolve_diagonal(apply: Callable[[int, int], Belnap], diag: int) -> Belnap:
    """Resolve the value of a diagonal (Liar/Russell) system."""
    v = apply(diag, diag)
    assert v == neg(apply(diag, diag)), 'diagonal law violated'
    assert v in (Belnap.B, Belnap.N), 'diagonal value theorem violated'
    return v