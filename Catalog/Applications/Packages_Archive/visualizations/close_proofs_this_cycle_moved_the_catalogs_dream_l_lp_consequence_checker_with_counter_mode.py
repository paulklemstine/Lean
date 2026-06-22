from typing import Callable, List, Set
from itertools import product

FF, BB, TT = 0, 1, 2

def neg(a: int) -> int:
    return {TT: FF, BB: BB, FF: TT}[a]

def desig(a: int) -> bool:
    return a in (TT, BB)

Form = dict
Valuation = Callable[[int], int]

def eval_form(v: Valuation, a: Form) -> int:
    k = a["kind"]
    if k == "atom":
        return v(a["n"])
    if k == "neg":
        return neg(eval_form(v, a["left"]))
    if k == "conj":
        return min(eval_form(v, a["left"]), eval_form(v, a["right"]))
    return max(eval_form(v, a["left"]), eval_form(v, a["right"]))

def atoms_of(a: Form) -> Set[int]:
    if a["kind"] == "atom":
        return {a["n"]}
    out: Set[int] = set()
    for key in ("left", "right"):
        if a.get(key) is not None:
            out |= atoms_of(a[key])
    return out

def entails(gamma: List[Form], concl: Form) -> bool:
    """LP-consequence: every valuation designating all premises designates the
    conclusion. Returns False with a counter-model existing otherwise."""
    idx: List[int] = sorted(set().union(*[atoms_of(f) for f in gamma],
                                        atoms_of(concl)) or {0})
    for combo in product((FF, BB, TT), repeat=len(idx)):
        table = dict(zip(idx, combo))
        v: Valuation = lambda n, table=table: table.get(n, FF)
        if all(desig(eval_form(v, g)) for g in gamma) \
           and not desig(eval_form(v, concl)):
            return False  # counter-model found
    return True
