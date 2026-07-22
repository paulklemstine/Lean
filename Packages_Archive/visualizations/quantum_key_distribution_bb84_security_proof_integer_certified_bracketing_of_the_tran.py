import math
from typing import Tuple

def bin_entropy_nats(q: float) -> float:
    if q <= 0.0 or q >= 1.0: return 0.0
    return -q*math.log(q) - (1-q)*math.log(1-q)

def secure_key_rate(q: float) -> float:
    return math.log(2.0) - 2.0*bin_entropy_nats(q)

def certify_eighth() -> Tuple[bool, int, int]:
    """binEntropy(1/8) > (log2)/2  <=>  7^7 < 2^20."""
    return (7**7 < 2**20, 7**7, 2**20)

def certify_sixteenth() -> Tuple[bool, int, int]:
    """binEntropy(1/16) < (log2)/2  <=>  2^56 < 15^15."""
    return (2**56 < 15**15, 2**56, 15**15)

def locate_threshold(lo: float = 1/16, hi: float = 1/8, iters: int = 200) -> float:
    assert secure_key_rate(lo) > 0 > secure_key_rate(hi)
    for _ in range(iters):
        mid = 0.5*(lo+hi)
        if secure_key_rate(mid) > 0: lo = mid
        else: hi = mid
    return 0.5*(lo+hi)
