from typing import List

def rank_profile_linear(n: int) -> List[int]:
    """Build the rank profile [C(n+1,k)] in O(n) integer operations using the
    multiplicative recurrence C(m,k+1) = C(m,k) * (m-k) / (k+1)."""
    m: int = n + 1
    profile: List[int] = [1] * (m + 1)
    c: int = 1
    for k in range(m):
        c = c * (m - k) // (k + 1)
        profile[k + 1] = c
    return profile
