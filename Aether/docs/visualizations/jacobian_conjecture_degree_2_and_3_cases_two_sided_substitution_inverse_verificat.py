from typing import Dict, List, Tuple

Monomial = Tuple[int, ...]
PolyDict = Dict[Monomial, int]
PolyMap = List[PolyDict]


def _add(a: PolyDict, b: PolyDict) -> PolyDict:
    out = dict(a)
    for m, c in b.items():
        out[m] = out.get(m, 0) + c
    return {m: c for m, c in out.items() if c != 0}


def _mul(a: PolyDict, b: PolyDict) -> PolyDict:
    out: PolyDict = {}
    for m1, c1 in a.items():
        for m2, c2 in b.items():
            m = tuple(x + y for x, y in zip(m1, m2))
            out[m] = out.get(m, 0) + c1 * c2
    return {m: c for m, c in out.items() if c != 0}


def subst(p: PolyDict, g: PolyMap, nvars: int) -> PolyDict:
    """Substitute the tuple g into polynomial p (pcomp on a single component)."""
    result: PolyDict = {}
    for mono, coeff in p.items():
        term: PolyDict = {tuple([0] * nvars): coeff}
        for vi, exp in enumerate(mono):
            for _ in range(exp):
                term = _mul(term, g[vi])
        result = _add(result, term)
    return result


def identity_map(nvars: int) -> PolyMap:
    out: PolyMap = []
    for i in range(nvars):
        e = [0] * nvars
        e[i] = 1
        out.append({tuple(e): 1})
    return out


def is_poly_aut(f: PolyMap, g: PolyMap) -> bool:
    """Verify that f and g are mutual two-sided substitution inverses (IsPolyAut)."""
    nvars = len(f)
    ident = identity_map(nvars)
    fg = [subst(fi, g, nvars) for fi in f]
    gf = [subst(gi, f, nvars) for gi in g]
    return fg == ident and gf == ident
