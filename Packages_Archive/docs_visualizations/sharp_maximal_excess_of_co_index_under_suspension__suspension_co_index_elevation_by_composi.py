from typing import Callable, Tuple

OctVertex = Tuple[int, int]

def suspend_map(g: Callable):
    """Functorial suspension S(g): base uses g, apexes are fixed."""
    def Sg(v):
        tag, x = v
        if tag == "base":
            return ("base", g(x))
        return ("apex", x)
    return Sg

def connecting_map(m: int) -> Callable[[OctVertex], object]:
    def phi(v: OctVertex):
        i, sign = v
        if i <= m:
            return ("base", (i, sign))
        return ("apex", sign)
    return phi

def elevate_coindex(g: Callable, m: int) -> Callable[[OctVertex], object]:
    """From g: Oct(m)->K build a map Oct(m+1)->S(K): coind rises by 1."""
    phi = connecting_map(m)
    Sg = suspend_map(g)
    return lambda v: Sg(phi(v))
