from typing import List


def odd_regular_forbidden(n: int, d: int) -> bool:
    """Parity obstruction: a d-regular red colouring on n vertices is impossible
    iff n*d is odd (handshake lemma)."""
    return (n * d) % 2 == 1


def degree_sequence_feasible(degrees: List[int]) -> bool:
    """A degree sequence on |W| vertices is parity-feasible only if it is NOT the
    case that |W| is odd while every red-degree is odd."""
    n = len(degrees)
    all_odd = all(d % 2 == 1 for d in degrees)
    return not (n % 2 == 1 and all_odd)
