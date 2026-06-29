from typing import Dict, List

RANK: Dict[str, int] = {"OWF": 0, "PRG": 1, "PRF": 2, "ENC": 3}

def implies(a: str, b: str) -> bool:
    """A <= B in implication order: A is implied by the stronger primitive B."""
    return RANK[b] <= RANK[a]

def verify_total_order() -> bool:
    levels: List[str] = list(RANK)
    injective = len(set(RANK.values())) == len(RANK)
    total = all(implies(a, b) or implies(b, a) for a in levels for b in levels)
    weakest = all(implies(a, "OWF") for a in levels)
    strongest = all(implies("ENC", a) for a in levels)
    return injective and total and weakest and strongest
