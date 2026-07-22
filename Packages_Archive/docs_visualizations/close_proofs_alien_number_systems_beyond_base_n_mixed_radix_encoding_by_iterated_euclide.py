from typing import List

def mixed_radix_encode(n: int, bases: List[int]) -> List[int]:
    """Encode n as mixed-radix digits (least significant first).

    Implements MixedRadix.mdigits: emit n % b_i, then recurse on n // b_i.
    Produces a valid digit list (each digit < its base) for positive bases,
    and round-trips exactly for n < prod(bases).
    """
    digits: List[int] = []
    for b in bases:
        digits.append(n % b)
        n //= b
    return digits
