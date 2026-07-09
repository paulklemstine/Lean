from typing import List, Sequence

def lift_sheared_sequence(f: Sequence[int], basepoint: int = 0) -> int:
    """Single stage M containing an eventually-basepoint sequence f: the max over
    its finite essential support, with the constant tail absorbed by basepoint."""
    support_values: List[int] = [x for x in f if x != basepoint]
    return max(support_values + [basepoint])
