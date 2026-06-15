from __future__ import annotations
from itertools import product
from typing import Dict, List, Set
# (reuses LP, Form, eval_form from the evaluation algorithm)


def atoms_of(f: Form) -> Set[int]:
    if f.kind == "atom":
        return {f.n}
    if f.kind == "neg":
        return atoms_of(f.a)
    return atoms_of(f.a) | atoms_of(f.b)


def desig(x: LP) -> bool:
    return x != LP.ff


def entails(gamma: List[Form], a: Form) -> bool:
    """Classical-style LP consequence over a finite atom set.

    Enumerate all 3^k valuations of the occurring atoms; A is a consequence iff
    every model of gamma (valuation designating all premises) designates A.
    Complexity O(3^k * (|gamma| * formula_size)).
    """
    ids: List[int] = sorted(set().union(*[atoms_of(f) for f in gamma + [a]]))
    for combo in product(LP, repeat=len(ids)):
        v: Dict[int, LP] = {i: val for i, val in zip(ids, combo)}
        if all(desig(eval_form(v, b)) for b in gamma):   # v is a model
            if not desig(eval_form(v, a)):               # but refutes a
                return False
    return True
