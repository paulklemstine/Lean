from typing import List, Set

def adhesion_sizes(adhesions: List[Set[int]]) -> List[int]:
    return [len(F) for F in adhesions]

def linked_min_cut_sequence(adhesions: List[Set[int]]) -> List[int]:
    """Edge min-cut to the end along a LINKED ray.

    By linked_adhesion_eq_minCut, in a linked decomposition the adhesion size
    equals the edge min-cut of its side, so the min-cut sequence is exactly the
    adhesion-size sequence. This realizes Theorem 2 / Proposition A numerically.
    """
    return adhesion_sizes(adhesions)

def menger_edge_degree(adhesions: List[Set[int]]) -> int:
    """The stabilized min-cut = Menger edge-connectivity to the end (finite case).

    Requires a nested (antitone) linked ray; returns inf of the min-cut sequence.
    """
    cuts = linked_min_cut_sequence(adhesions)
    return min(cuts)
