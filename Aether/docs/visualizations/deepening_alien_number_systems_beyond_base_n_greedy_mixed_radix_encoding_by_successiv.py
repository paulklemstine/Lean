from typing import List

def mdigits(bs: List[int], n: int) -> List[int]:
    """Encode n into mixed-radix digits under bases bs (least significant first).

    Implements MixedRadix.mdigits: repeated Euclidean division, peeling off
    (n mod b_i) at each position and recursing on the quotient. O(k) divisions
    for k bases. Produces a valid digit list (each d_i < b_i) whenever every
    base is positive; for n < prod(bs) the result is the unique representation.
    """
    digits: List[int] = []
    for b in bs:
        digits.append(n % b)
        n //= b
    return digits
