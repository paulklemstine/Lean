from __future__ import annotations
from itertools import product
from typing import Callable, FrozenSet, List, Sequence, Tuple

Partition = Tuple[FrozenSet[int], ...]


def is_prime_congruence(
    part: Partition,
    carrier: Sequence[int],
    mul: Callable[[int, int], int],
    zero: int,
) -> bool:
    """Algorithm B: test the integral-domain law
       a*b ~ 0  =>  a ~ 0  or  b ~ 0   for a congruence given as a partition."""
    rep = {x: block for block in part for x in block}
    rel = lambda a, b: rep[a] is rep[b]
    for a, b in product(carrier, repeat=2):
        if rel(mul(a, b), zero) and not (rel(a, zero) or rel(b, zero)):
            return False
    return True


def proof_spectrum(
    congruences: List[Partition],
    carrier: Sequence[int],
    mul: Callable[[int, int], int],
    zero: int,
) -> List[FrozenSet[int]]:
    """The prime congruences, returned as their zero classes (multiples of 0)."""
    spec: List[FrozenSet[int]] = []
    for part in congruences:
        if is_prime_congruence(part, carrier, mul, zero):
            rep = {x: block for block in part for x in block}
            zero_block = rep[zero]
            spec.append(frozenset(zero_block))
    return spec
