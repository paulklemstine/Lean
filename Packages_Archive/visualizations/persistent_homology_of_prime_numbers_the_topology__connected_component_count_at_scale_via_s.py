from typing import List


def components_at_scale(gaps: List[int], eps: float) -> int:
    """Number of Vietoris-Rips connected components at scale eps.

    Single-Linkage Theorem: components are maximal runs of gaps <= eps, so the
    count is (number of gaps exceeding eps) + 1.  O(len(gaps)) time.
    """
    return sum(1 for g in gaps if g > eps) + 1


def barcode_step_points(gaps: List[int]) -> List[float]:
    """Scales at which the component count drops: the distinct gap values,
    each drop by the multiplicity of that gap value."""
    return sorted(set(gaps))
