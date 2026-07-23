from typing import List, Optional, Sequence, Tuple


def star_and_matching_extraction(
    matching_edge_colors: Sequence[int], targets: Sequence[int]
) -> Tuple[Optional[int], Tuple[int, int]]:
    """One pass yields BOTH conclusions of star_and_matching_pigeonhole.

    Given a colored matching with #M >= sum_j (targets[j]-1) + 1:
      * STAR     reading: a color j with class size >= targets[j];
      * MATCHING reading: the largest color class i with q*size >= #M.

    Returns (star_color_or_None, (matching_color, class_size)).
    Complexity: O(#M + q).
    """
    q: int = len(targets)
    counts: List[int] = [0] * q
    for c in matching_edge_colors:
        counts[c] += 1
    star: Optional[int] = next(
        (j for j in range(q) if counts[j] >= targets[j]), None
    )
    i: int = max(range(q), key=lambda k: counts[k])
    return star, (i, counts[i])
