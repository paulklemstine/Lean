from typing import List, Set, Tuple

Frame = Tuple[List[object], Set[Tuple[object, object]]]

def synchronized_product(F: Frame, G: Frame) -> Frame:
    WF, RF = F
    WG, RG = G
    worlds = [(a, b) for a in WF for b in WG]
    R = {((a, b), (c, d)) for (a, c) in RF for (b, d) in RG}
    return worlds, R

def rectangle(A: Set[object], B: Set[object]) -> Set[Tuple[object, object]]:
    return {(a, b) for a in A for b in B}

def diamond_factors(F: Frame, G: Frame,
                    A: Set[object], B: Set[object]) -> bool:
    P = synchronized_product(F, G)
    lhs = diamond(P, rectangle(A, B))
    rhs = rectangle(diamond(F, A), diamond(G, B))
    return lhs == rhs
