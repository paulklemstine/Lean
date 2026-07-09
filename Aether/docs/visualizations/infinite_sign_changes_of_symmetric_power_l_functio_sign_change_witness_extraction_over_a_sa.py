from typing import Dict, List, Tuple


def sign_change_witnesses(a: Dict[int, float],
                          sample: List[int]) -> Tuple[List[int], List[int]]:
    """Given a real sequence a and an increasing sample set, return the lists of
    positions where a is positive and where a is negative.  Both lists growing
    without bound as the sample grows witnesses infinitely many sign changes.

    Complexity O(|sample|).
    """
    pos: List[int] = []
    neg: List[int] = []
    for n in sample:
        v = a.get(n, 0.0)
        if v > 0:
            pos.append(n)
        elif v < 0:
            neg.append(n)
    return pos, neg
