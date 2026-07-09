from typing import List

def sites_rule(m: int, k: int) -> List[int]:
    """Active-sites succession rule S_m(k) = [1, 2, ..., m*k + 1] (root label 1)."""
    return list(range(1, m * k + 2))

def shifted_rule(m: int, k: int) -> List[int]:
    """Shifted succession rule T_m(k) = [2, 3, ..., m*(k-1) + 2] (root label 2)."""
    return list(range(2, (m * k - m + 1) + 2))
