from typing import Dict

def differential_monomial_order(n: int, exps: Dict[int, int]) -> int:
    """Order of prod_i (d^i f)^{e_i} given ord(f) = n  (Theorem `order_diff_monomial`).

    Each derivative d^i f has order n - i (`order_iterate_derivativeFun`); products add
    orders and powers multiply them, giving the affine min-plus formula sum_i e_i (n - i).
    Complexity: O(|support(exps)|) integer operations.
    """
    return sum(e * (n - i) for i, e in exps.items())
