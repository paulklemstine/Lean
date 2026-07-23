from math import ceil
from typing import List, Tuple

def cg_round(c: List[int], d: int, k: int) -> Tuple[List[int], int]:
    assert k > 0 and all(ci % k == 0 for ci in c)
    return [ci // k for ci in c], ceil(d / k)
