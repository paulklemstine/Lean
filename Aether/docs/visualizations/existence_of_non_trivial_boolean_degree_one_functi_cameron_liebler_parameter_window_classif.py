from typing import Dict, List, Set, Tuple

def classify_parameters(q: int) -> Dict[str, object]:
    """Classify the Cameron-Liebler parameter range of J_q(4,2).

    Returns the line counts, the maximal parameter q^2+1, the Bruen-Drudge
    midpoint floor((q^2+1)/2), the trivial parameter set, the non-trivial
    open window (2, q^2-1) as an explicit integer list, whether the midpoint
    is an honest integer half (true iff q is odd), and whether the midpoint
    lies in the non-trivial window (true iff q >= 3).
    """
    nltp: int = q * q + q + 1
    nlines: int = (q * q + 1) * nltp
    maxparam: int = q * q + 1
    bd: int = (q * q + 1) // 2
    trivial: Set[int] = {0, 1, 2, q * q - 1, q * q, q * q + 1}
    window: List[int] = [x for x in range(0, maxparam + 1) if 2 < x < q * q - 1]
    is_integer_midpoint: bool = (2 * bd == q * q + 1)   # <=> q odd
    midpoint_nontrivial: bool = (2 < bd < q * q - 1)    # <=> q >= 3
    return {
        "q": q,
        "num_lines_through_point": nltp,
        "num_lines": nlines,
        "max_param": maxparam,
        "bd_param": bd,
        "trivial_set": sorted(trivial),
        "nontrivial_window": window,
        "is_integer_midpoint": is_integer_midpoint,
        "midpoint_nontrivial": midpoint_nontrivial,
    }
