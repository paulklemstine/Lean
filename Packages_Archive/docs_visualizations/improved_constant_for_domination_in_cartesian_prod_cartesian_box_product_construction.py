from typing import FrozenSet, List, Set, Tuple

Graph = Tuple[int, Set[FrozenSet[int]]]


def box_product(g: Graph, h: Graph) -> Graph:
    """Construct the Cartesian (box) product G [] H.

    Vertices of G (n_g) and H (n_h) are combined as a*n_h + b. Two product
    vertices are adjacent iff they agree in one coordinate and are adjacent in
    the other (the fixed-coordinate property). Time O(n_g*n_h*(d_g+d_h)) where
    d is the maximum degree; the result has n_g*n_h vertices.
    """
    ng, eg = g
    nh, eh = h

    def idx(a: int, b: int) -> int:
        return a * nh + b

    def adj(edges: Set[FrozenSet[int]], u: int, v: int) -> bool:
        return frozenset((u, v)) in edges

    edges: Set[FrozenSet[int]] = set()
    for a in range(ng):
        for b in range(nh):
            for b2 in range(nh):
                if adj(eh, b, b2):
                    edges.add(frozenset((idx(a, b), idx(a, b2))))
            for a2 in range(ng):
                if adj(eg, a, a2):
                    edges.add(frozenset((idx(a, b), idx(a2, b))))
    return (ng * nh, edges)
