from typing import Sequence


def complete_graph_star_threshold(targets: Sequence[int]) -> int:
    """The forcing bound N >= sum_j (targets[j]-1) + 2 for K_N.

    Realizes StarRamsey.Graph.completeGraph_hasMonoStar: every q-edge-coloring
    of K_N with N >= this value contains a monochromatic star. Sufficient bound.

    Complexity: O(q).
    """
    return sum(max(tj - 1, 0) for tj in targets) + 2


def forces_on_complete_graph(n: int, targets: Sequence[int]) -> bool:
    """True iff N = n meets the complete-graph forcing bound."""
    return n >= complete_graph_star_threshold(targets)
