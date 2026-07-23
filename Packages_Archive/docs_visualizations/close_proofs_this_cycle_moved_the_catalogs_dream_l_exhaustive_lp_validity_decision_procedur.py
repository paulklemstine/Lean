from typing import Callable, Dict, List, Set
from itertools import product

FF, BB, TT = 0, 1, 2  # ff < bb < tt

def neg(a: int) -> int:
    return {TT: FF, BB: BB, FF: TT}[a]

def conj(a: int, b: int) -> int:
    return min(a, b)

def disj(a: int, b: int) -> int:
    return max(a, b)

def desig(a: int) -> bool:
    return a in (TT, BB)

Form = dict  # {'kind','n','left','right'}
Valuation = Callable[[int], int]

def eval_form(v: Valuation, a: Form) -> int:
    k = a["kind"]
    if k == "atom":
        return v(a["n"])
    if k == "neg":
        return neg(eval_form(v, a["left"]))
    if k == "conj":
        return conj(eval_form(v, a["left"]), eval_form(v, a["right"]))
    return disj(eval_form(v, a["left"]), eval_form(v, a["right"]))

def atoms_of(a: Form) -> Set[int]:
    if a["kind"] == "atom":
        return {a["n"]}
    out: Set[int] = set()
    for key in ("left", "right"):
        if a.get(key) is not None:
            out |= atoms_of(a[key])
    return out

def is_valid(a: Form) -> bool:
    """LP-validity by exhaustive search over the 3^k atom assignments."""
    idx: List[int] = sorted(atoms_of(a))
    for combo in product((FF, BB, TT), repeat=len(idx)):
        table: Dict[int, int] = dict(zip(idx, combo))
        v: Valuation = lambda n, table=table: table.get(n, FF)
        if not desig(eval_form(v, a)):
            return False
    return True
