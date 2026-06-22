from typing import FrozenSet, Tuple

Vector = Tuple[int, ...]
Code = FrozenSet[Vector]


def gleason_master_value(card: int, n: int) -> complex:
    '''Return (1 + i)^n; equals |C| for a doubly-even self-dual code.'''
    return (1 + 1j) ** n


def gleason_certify(C: Code, n: int, eps: float = 1e-9) -> bool:
    '''Verify |C| = (1+i)^n and certify 8 | n via period-8 sign analysis.'''
    lhs = complex(len(C), 0)
    rhs = gleason_master_value(len(C), n)
    if abs(lhs - rhs) >= eps:
        return False
    # (1+i)^r is a positive real only when r = 0 (since (1+i)^4 = -4)
    return n % 8 == 0
