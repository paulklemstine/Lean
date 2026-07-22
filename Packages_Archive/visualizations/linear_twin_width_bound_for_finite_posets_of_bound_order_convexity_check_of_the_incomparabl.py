from typing import Sequence


def incomp_is_interval(seq: Sequence[str]) -> bool:
    """
    Verify incomp_ord_convex: the Incomp entries of a position-type sequence
    form one contiguous block (a single order-interval of the chain).
    """
    idx = [i for i, s in enumerate(seq) if s == "Incomp"]
    if not idx:
        return True
    return idx == list(range(idx[0], idx[-1] + 1))
