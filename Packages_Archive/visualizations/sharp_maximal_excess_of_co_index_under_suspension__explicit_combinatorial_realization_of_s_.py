from typing import Callable, Tuple

OctVertex = Tuple[int, int]           # (axis, sign)
SuspVertex = Tuple[str, object]       # ("base", OctVertex) | ("apex", int)

def connecting_map(n: int) -> Callable[[OctVertex], SuspVertex]:
    """phi_n : Oct(n+1) -> S(Oct n) realizing S^{n+1} ~= S(S^n)."""
    def phi(v: OctVertex) -> SuspVertex:
        i, sign = v
        if i <= n:
            return ("base", (i, sign))
        return ("apex", sign)          # extra axis -> North (+1) / South (-1)
    return phi

def oct_alpha(v: OctVertex) -> OctVertex:
    i, s = v
    return (i, -s)

def susp_alpha(v: SuspVertex) -> SuspVertex:
    tag, x = v
    if tag == "base":
        return ("base", oct_alpha(x))
    return ("apex", -x)

def is_equivariant(phi, src_vertices) -> bool:
    return all(phi(oct_alpha(v)) == susp_alpha(phi(v)) for v in src_vertices)
