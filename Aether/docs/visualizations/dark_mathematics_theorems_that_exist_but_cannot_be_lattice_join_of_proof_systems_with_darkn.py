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


def join(s: ProofSys, t: ProofSys) -> ProofSys:
    """Least upper bound of s and t in the simulation preorder.

    A proof of the join is a proof from either component (tagged 'L'/'R');
    provability in the join is the disjunction of the component
    provabilities. Darkness levels combine as a maximum under this join."""
    tagged = tuple(("L", p) for p in s.proofs) + tuple(("R", p) for p in t.proofs)

    def concl(tp: tuple) -> Formula:
        return s.concl(tp[1]) if tp[0] == "L" else t.concl(tp[1])

    return ProofSys(tagged, concl)
