from typing import List

def diff_monomial_lower_bound(ord_f: int, exponents: List[int]) -> int:
    """Certified lower bound on ord( prod_j f^(k_j) ) using the Iterated Bound
    (ord f <= ord f^(k) + k, i.e. ord f^(k) >= ord f - k) and the Product Law
    (orders add).  exponents = [k_1, ..., k_r]."""
    total = 0
    for k in exponents:
        total += max(ord_f - k, 0)  # ord f^(k) >= ord f - k, never below 0
    return total
