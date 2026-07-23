from typing import List


def hull_profile(spectrum: List[int]) -> List[int]:
    """
    Reduce the weight spectrum to the surviving tropical slopes.
    For lines through the origin only the extreme weights (1-D convex-hull
    vertices) survive; the profile is t -> min(w_min * t, w_max * t).
    Runs in O(k log k) from an unsorted spectrum of k distinct weights.
    """
    if not spectrum:
        return []
    s = sorted(set(spectrum))
    return sorted({s[0], s[-1]})
