from itertools import product
from typing import Dict, FrozenSet, List, Optional, Tuple

FF, BB, TT = 0, 1, 2


def desig(a: int) -> bool:
    return a >= BB


def glut_set(val: Dict[int, int]) -> FrozenSet[int]:
    """The atoms a valuation sends to the glut bb."""
    return frozenset(n for n, x in val.items() if x == BB)


def entails_min(gamma: List[dict], a: dict, evaluate, atoms_of) -> Tuple[
        bool, Optional[Dict[int, int]]]:
    """LPm-consequence: evaluate A only on the subset-minimal-glut models of Gamma.

    Step 1: collect every model of Gamma.
    Step 2: keep those whose glut set is not strictly contained in another model's.
    Step 3: A is an LPm-consequence iff it holds on every minimal model.
    Complexity: Theta(3^k * |Gamma|) to collect + Theta(m^2 * k) to filter, m models.
    """
    atoms = sorted(set().union(*[atoms_of(f) for f in gamma + [a]]))
    mods: List[Dict[int, int]] = []
    for assign in product((FF, BB, TT), repeat=len(atoms)):
        val = dict(zip(atoms, assign))
        if all(desig(evaluate(val, b)) for b in gamma):
            mods.append(val)
    minimal = [v for v in mods
               if not any(glut_set(w) < glut_set(v) for w in mods)]
    for v in minimal:
        if not desig(evaluate(v, a)):
            return False, v
    return True, None
