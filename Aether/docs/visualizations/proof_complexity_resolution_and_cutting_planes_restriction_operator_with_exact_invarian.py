from itertools import product
from typing import Dict, Hashable, List, Optional, Tuple

Var = Hashable
Lit = Tuple[Var, bool]
Clause = List[Lit]
CNF = List[Clause]
Restriction = Dict[Var, Optional[bool]]

def killed(rho: Restriction, c: Clause) -> bool:
    return any(rho.get(v) == pos for (v, pos) in c)

def cnf_restrict(rho: Restriction, f: CNF) -> CNF:
    return [[(v, p) for (v, p) in c if rho.get(v) is None]
            for c in f if not killed(rho, c)]

def subst(rho: Restriction, a: Dict[Var, bool]) -> Dict[Var, bool]:
    out = {}
    for v in set(rho) | set(a):
        fx = rho.get(v)
        out[v] = a[v] if fx is None else fx
    return out

def cnf_sat(a, f) -> bool:
    return all(any(a[v] == p for (v, p) in c) for c in f)

def check_invariance(rho: Restriction, f: CNF) -> bool:
    g = cnf_restrict(rho, f)
    vs = sorted({v for c in f for (v, _) in c if rho.get(v) is None}, key=str)
    for bits in product([False, True], repeat=len(vs)):
        a = dict(zip(vs, bits))
        if cnf_sat(a, g) != cnf_sat(subst(rho, a), f):
            return False
    return True
