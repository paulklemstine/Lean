from itertools import product
from typing import Dict, Hashable, List, Tuple

Var = Hashable
Lit = Tuple[Var, bool]
Clause = List[Lit]
Assignment = Dict[Var, bool]

def resolvent(c1: Clause, c2: Clause, p: Var) -> Clause:
    left = [l for l in c1 if l != (p, True)]
    right = [l for l in c2 if l != (p, False)]
    return left + right

def clause_sat(a: Assignment, c: Clause) -> bool:
    return any(a[v] == pos for (v, pos) in c)

def check_sound(c1: Clause, c2: Clause, p: Var) -> bool:
    r = resolvent(c1, c2, p)
    vs = sorted({v for c in (c1, c2, r) for (v, _) in c}, key=str)
    for bits in product([False, True], repeat=len(vs)):
        a = dict(zip(vs, bits))
        if clause_sat(a, c1) and clause_sat(a, c2) and not clause_sat(a, r):
            return False
    return True
