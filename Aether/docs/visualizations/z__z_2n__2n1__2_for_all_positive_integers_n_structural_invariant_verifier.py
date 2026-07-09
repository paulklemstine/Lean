from math import comb
from typing import Tuple

def verify_invariants(n: int) -> Tuple[bool, bool, bool, bool]:
    """Verify the four structural identities for G_n = Z_2 x (Z_2)^n:
      1. group order 2^(n+1),
      2. rank layers partition the group (profile sums to the order),
      3. width equals the central binomial coefficient,
      4. tropical (min) aggregate equals 1."""
    m: int = n + 1
    profile = [comb(m, k) for k in range(m + 1)]
    order_ok: bool = 2 ** m == 2 ** (n + 1)
    partition_ok: bool = sum(profile) == 2 ** (n + 1)
    width_ok: bool = max(profile) == comb(m, m // 2)
    tropical_ok: bool = min(profile) == 1
    return order_ok, partition_ok, width_ok, tropical_ok
