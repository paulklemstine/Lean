from __future__ import annotations
from dataclasses import dataclass
from typing import Callable


@dataclass(frozen=True)
class Formula:
    kind: str
    value: int


@dataclass(frozen=True)
class ProofSys:
    proofs: tuple
    concl: Callable[[object], Formula]

    def provable(self, f: Formula) -> bool:
        return any(self.concl(p) == f for p in self.proofs)


def darkness_level(s: ProofSys, max_k: int) -> int:
    """Return the top darkness level of s, or -1 if some instance is provable.

    The level is the largest k <= max_k with the counting statement
    atLeast(k) provable, provided no instance statement inst(n) is provable
    for n <= max_k; otherwise -1 (the system is not dark)."""
    names_witness = any(
        s.provable(Formula("inst", n)) for n in range(max_k + 1)
    )
    if names_witness:
        return -1
    top = -1
    for k in range(max_k + 1):
        if s.provable(Formula("atLeast", k)):
            top = k
    return top
