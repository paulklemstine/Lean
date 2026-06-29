from typing import List

def binary_strings_upto(k: int) -> List[str]:
    """All binary strings of length at most k (lengths 0..k).

    The count is exactly 2^(k+1) - 1, giving the classical Kolmogorov-style
    bound: at most 2^(k+1) - 1 objects have a description of bitlength <= k.
    """
    out: List[str] = [""]
    for length in range(1, k + 1):
        out.extend(format(v, "0" + str(length) + "b") for v in range(2 ** length))
    return out

def kolmogorov_bound(k: int) -> int:
    """Maximum number of objects describable with bitlength at most k."""
    return 2 ** (k + 1) - 1
