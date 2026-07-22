from typing import Dict, List, Tuple

Vertex = Tuple[int, ...]


def theta_classes_and_semicubes(pc: List[Vertex]
                                ) -> Dict[int, Tuple[frozenset, frozenset]]:
    """Recover the Djokovic-Winkler theta-classes and their opposite semicubes
    from a Hamming labeling.  Each used coordinate i yields the theta-class of
    all edges flipping i, whose opposite semicubes are {v_i = 0} and {v_i = 1}.
    Returns coordinate -> (W0, W1)."""
    n: int = len(pc[0])
    out: Dict[int, Tuple[frozenset, frozenset]] = {}
    for i in range(n):
        w0 = frozenset(v for v in pc if v[i] == 0)
        w1 = frozenset(v for v in pc if v[i] == 1)
        if w0 and w1:                          # coordinate is actually used
            out[i] = (w0, w1)
    return out
