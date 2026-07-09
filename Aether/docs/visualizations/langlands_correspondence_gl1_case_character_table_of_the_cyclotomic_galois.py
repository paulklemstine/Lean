import cmath, math
from typing import Dict, List, Tuple

def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)

def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1] or [1]

def _cyclic_subgroup(g: int, n: int) -> Dict[int, int]:
    sub: Dict[int, int] = {}
    x, e = 1, 0
    while x not in sub:
        sub[x] = e
        x = (x * g) % n
        e += 1
    return sub

def independent_generators(n: int) -> Tuple[List[int], List[int], Dict[int, Tuple[int, ...]]]:
    units = units_mod(n)
    gens: List[int] = []
    orders: List[int] = []
    coords: Dict[int, Tuple[int, ...]] = {1: ()}
    subgroup = {1}
    while len(subgroup) < len(units):
        best_g, best_order, best_sub = -1, 0, {}
        for g in units:
            if g in subgroup:
                continue
            sub = _cyclic_subgroup(g, n)
            if all((s == 1) or (s not in subgroup) for s in sub) and len(sub) > best_order:
                best_g, best_order, best_sub = g, len(sub), sub
        for e in list(coords.keys()):
            coords[e] = coords[e] + (0,)
        new_sub = {}
        for s, exps in list(coords.items()):
            for j, gj in best_sub.items():
                key = (s * j) % n
                if key not in new_sub:
                    new_sub[key] = exps[:-1] + (gj,)
        coords.update(new_sub)
        subgroup = set(coords.keys())
        gens.append(best_g)
        orders.append(best_order)
    return gens, orders, coords

def character_table(n: int) -> List[Dict[int, complex]]:
    """All phi(n) characters of (Z/nZ)^x = Dirichlet characters = 1-dim Galois reps."""
    units = units_mod(n)
    if len(units) == 1:
        return [{u: 1 + 0j for u in units}]
    gens, orders, coords = independent_generators(n)
    out: List[Dict[int, complex]] = []
    def build(idx: int, choice: List[int]) -> None:
        if idx == len(gens):
            chi = {}
            for u in units:
                val = 1 + 0j
                for k, ck in enumerate(coords[u]):
                    val *= cmath.exp(2j * math.pi * choice[k] * ck / orders[k])
                chi[u] = val
            out.append(chi)
            return
        for j in range(orders[idx]):
            build(idx + 1, choice + [j])
    build(0, [])
    return out
