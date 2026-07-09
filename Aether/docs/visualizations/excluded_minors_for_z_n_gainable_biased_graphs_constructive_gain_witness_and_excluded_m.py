from typing import Dict, List, Optional, Tuple

Walk = List[Tuple[int, bool]]

def build_witness(edge_class: Dict[int, int], n: int) -> Optional[Dict[int, int]]:
    """Constructive witness for digon_gainable_iff_card.

    If #classes <= n, assign each balance class a distinct value in Z/n and label
    every edge by its class value. Returns None if no labelling can exist.
    """
    classes = sorted(set(edge_class.values()))
    if len(classes) > n:
        return None
    value_of = {c: i % n for i, c in enumerate(classes)}
    return {e: value_of[c] for e, c in edge_class.items()}

def minor_certificate(edge_class: Dict[int, int], n: int) -> Optional[List[int]]:
    """If #classes >= n+1, return n+1 pairwise non-equivalent edges forming (n+1)K2."""
    reps: Dict[int, int] = {}
    for edge, cls in edge_class.items():
        reps.setdefault(cls, edge)
    if len(reps) < n + 1:
        return None
    return list(reps.values())[: n + 1]
