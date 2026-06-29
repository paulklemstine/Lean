from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

FF, BB, TT = 0, 1, 2  # the chain ff < bb < tt; bb is the glut


def desig(a: int) -> bool:
    return a >= BB


def neg(a: int) -> int:
    return BB if a == BB else (TT if a == FF else FF)


def evaluate(val: Dict[int, int], a: dict) -> int:
    """Evaluate a formula dict {kind, idx?, left?, right?} under a valuation."""
    k = a["kind"]
    if k == "atom":
        return val.get(a["idx"], FF)
    if k == "neg":
        return neg(evaluate(val, a["left"]))
    if k == "conj":
        return min(evaluate(val, a["left"]), evaluate(val, a["right"]))
    if k == "disj":
        return max(evaluate(val, a["left"]), evaluate(val, a["right"]))
    raise ValueError(k)


def atoms_of(a: dict) -> set:
    if a["kind"] == "atom":
        return {a["idx"]}
    if a["kind"] == "neg":
        return atoms_of(a["left"])
    return atoms_of(a["left"]) | atoms_of(a["right"])


def is_lp_valid(a: dict) -> Tuple[bool, Optional[Dict[int, int]]]:
    """Decide LP-validity by enumerating all 3^k valuations; return a countermodel
    on failure. Complexity Theta(3^k * |A|)."""
    atoms = sorted(atoms_of(a))
    for assign in product((FF, BB, TT), repeat=len(atoms)):
        val = dict(zip(atoms, assign))
        if not desig(evaluate(val, a)):
            return False, val
    return True, None


def entails(gamma: List[dict], a: dict) -> Tuple[bool, Optional[Dict[int, int]]]:
    """Decide LP-consequence; return a witnessing valuation on failure."""
    atoms = sorted(set().union(*[atoms_of(f) for f in gamma + [a]]))
    for assign in product((FF, BB, TT), repeat=len(atoms)):
        val = dict(zip(atoms, assign))
        if all(desig(evaluate(val, b)) for b in gamma) and not desig(evaluate(val, a)):
            return False, val
    return True, None
