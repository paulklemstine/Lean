from typing import List, Dict, Tuple

def v2(a: int) -> int:
    if a == 0:
        return 10 ** 9
    a, e = abs(a), 0
    while a % 2 == 0:
        a //= 2; e += 1
    return e

def valuation_profile(t: List[int], block: int) -> Dict[int, List[int]]:
    """Given coefficients t and block length (= m-1), return for each block
    index n the list of valuations [nu_2(t[block*n+j]) for j in range(block)].
    Block-constancy holds iff every list has all entries equal."""
    profile: Dict[int, List[int]] = {}
    n = 0
    while block * n + block - 1 < len(t):
        profile[n] = [v2(t[block * n + j]) for j in range(block)]
        n += 1
    return profile

def is_block_constant(profile: Dict[int, List[int]]) -> bool:
    return all(len(set(vals)) == 1 for vals in profile.values())
