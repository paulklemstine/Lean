from enum import IntEnum
from typing import List, Tuple


class Primitive(IntEnum):
    OWF = 0
    PRG = 1
    PRF = 2
    ENC = 3


def rank(p: Primitive) -> int:
    """The conserved scalar of the construction calculus."""
    return int(p)


_UPGRADES: List[Tuple[Primitive, Primitive]] = [
    (Primitive.OWF, Primitive.PRG),
    (Primitive.PRG, Primitive.PRF),
    (Primitive.PRF, Primitive.ENC),
]


def crypto_implies(x: Primitive, y: Primitive) -> bool:
    """Reachability in the construction calculus (refl + trans + 3 upgrades)."""
    if x == y:
        return True
    frontier, seen = [x], {x}
    while frontier:
        cur = frontier.pop()
        for src, dst in _UPGRADES:
            if src == cur and dst not in seen:
                if dst == y:
                    return True
                seen.add(dst)
                frontier.append(dst)
    return False


def rank_separation_oracle(x: Primitive, y: Primitive) -> str:
    """If rank x > rank y, no black-box construction CryptoImplies x y exists."""
    if rank(x) > rank(y):
        return f"SEPARATED: rank {x.name}={rank(x)} > rank {y.name}={rank(y)}"
    return "UNKNOWN to the rank oracle"
