from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, List

@dataclass
class ProofSys:
    name: str
    provable: Callable[[object], bool]

def consistent(S: ProofSys, bot: object) -> bool:
    return not S.provable(bot)

def simulates(S: ProofSys, T: ProofSys, probe: List[object]) -> bool:
    return all((not T.provable(f)) or S.provable(f) for f in probe)

def transfer(tower: List[ProofSys], probe: List[object], bot: object) -> bool:
    """Certify downward consistency transfer along a simulation tower."""
    if not consistent(tower[0], bot):
        return False
    for k in range(len(tower) - 1):
        if not simulates(tower[k], tower[k + 1], probe):
            return False
    return all(consistent(T, bot) for T in tower)
