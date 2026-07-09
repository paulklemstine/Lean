from typing import Tuple, List

def digits_base(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b); n //= b
    return out

def half_split(b: int, p: int) -> Tuple[int, int, int, int]:
    """For even ord_p(b), exhibit N = k*(b^h - 1) = (k-1)*b^h + (b^h - k).

    Returns (h, k, top, bottom); top and bottom are nines-complementary halves
    with top + bottom == b^h - 1. Uses the bridge p | b^h + 1 forced by even order.
    """
    value, l = 1 % p, 0
    for l in range(1, p):
        value = (value * b) % p
        if value == 1:
            break
    if l % 2 != 0:
        raise ValueError("order is odd; no two-halves split")
    h = l // 2
    k = (b ** h + 1) // p
    assert (b ** h + 1) % p == 0
    N = (b ** l - 1) // p
    top, bottom = k - 1, b ** h - k
    assert N == k * (b ** h - 1) == top * b ** h + bottom
    return h, k, top, bottom
