from typing import List

def mval(bs: List[int], ds: List[int]) -> int:
    """Decode a mixed-radix digit list back to its integer value (Horner form).

    Implements MixedRadix.mval: evaluates
        d0 + b0*(d1 + b1*(d2 + ...))
    by a single right-to-left Horner fold. O(k) multiply-adds, optimal in the
    number of multiplications. Inverse of mdigits on valid digit lists; together
    they realize the bijection Fin(prod bs) <-> {valid digit lists}.
    """
    acc = 0
    for i in range(len(ds) - 1, -1, -1):
        b = bs[i] if i < len(bs) else 1
        acc = ds[i] + b * acc
    return acc
