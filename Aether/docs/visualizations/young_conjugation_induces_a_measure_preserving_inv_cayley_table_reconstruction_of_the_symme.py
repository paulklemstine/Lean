from typing import Callable, Dict, List, Tuple

Point = Tuple[float, float]


def compose(g: Callable[[Point], Point],
            h: Callable[[Point], Point]) -> Callable[[Point], Point]:
    return lambda p: g(h(p))


def identify(comp: Callable[[Point], Point],
             group: Dict[str, Callable[[Point], Point]],
             probes: List[Point], tol: float = 1e-9) -> str:
    """Return the name of the group element equal to `comp` on all probes."""
    for name, g in group.items():
        if all(abs(comp(p)[0] - g(p)[0]) < tol
               and abs(comp(p)[1] - g(p)[1]) < tol for p in probes):
            return name
    return "?"


def build_group_table(group: Dict[str, Callable[[Point], Point]],
                      probes: List[Point]) -> Dict[Tuple[str, str], str]:
    """Compute the full Cayley table of the symmetry group under composition."""
    table: Dict[Tuple[str, str], str] = {}
    for gn, g in group.items():
        for hn, h in group.items():
            table[(gn, hn)] = identify(compose(g, h), group, probes)
    return table
