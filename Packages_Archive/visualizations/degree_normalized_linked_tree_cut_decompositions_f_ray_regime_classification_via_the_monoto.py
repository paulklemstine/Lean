from typing import List, Optional, Tuple

def displayed_edge_degree(sizes: List[int]) -> int:
    """inf_n |F_{e_n}| on a finite prefix (Definition: displayedEdgeDegree)."""
    if not sizes:
        raise ValueError("non-empty ray required")
    return min(sizes)

def classify_ray(sizes: List[int]) -> Tuple[str, Optional[int]]:
    """Classify a root-to-end ray per degreeNormalization_dichotomy.

    Returns (regime, witness) where regime in
    {"finite", "infinite", "oscillating"} and witness is the stabilized
    degree d (finite case) or None otherwise.
    """
    antitone = all(sizes[i + 1] <= sizes[i] for i in range(len(sizes) - 1))
    monotone = all(sizes[i + 1] >= sizes[i] for i in range(len(sizes) - 1))
    if antitone:
        return "finite", displayed_edge_degree(sizes)
    if monotone:
        if sizes[-1] > sizes[0]:
            return "infinite", None
        return "finite", displayed_edge_degree(sizes)
    return "oscillating", None

def stabilization_index(sizes: List[int]) -> Optional[int]:
    """Least N0 with sizes[n] == displayedEdgeDegree for n >= N0 (Theorem 1)."""
    d = displayed_edge_degree(sizes)
    for N0 in range(len(sizes)):
        if all(sizes[m] == d for m in range(N0, len(sizes))):
            return N0
    return None
