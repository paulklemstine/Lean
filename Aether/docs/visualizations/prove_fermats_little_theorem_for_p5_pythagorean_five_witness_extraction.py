from typing import Tuple

def five_witness(triple: Tuple[int, int, int]) -> int:
    """Return the entry guaranteed divisible by 5 in a Pythagorean triple."""
    for x in triple:
        if x % 5 == 0:
            return x
    raise ValueError('no multiple of 5: input is not a Pythagorean triple')
