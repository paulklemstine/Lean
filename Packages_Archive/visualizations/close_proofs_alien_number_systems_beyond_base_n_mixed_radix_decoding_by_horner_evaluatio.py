from typing import List

def mixed_radix_decode(digits: List[int], bases: List[int]) -> int:
    """Decode mixed-radix digits back to an integer (Horner form).

    Implements MixedRadix.mval: value = d0 + b0*(d1 + b1*(d2 + ...)).
    Inverse of mixed_radix_encode on valid digit lists (uniqueness theorem).
    """
    acc = 0
    for i in reversed(range(len(digits))):
        b = bases[i] if i < len(bases) else 1
        acc = digits[i] + b * acc
    return acc
