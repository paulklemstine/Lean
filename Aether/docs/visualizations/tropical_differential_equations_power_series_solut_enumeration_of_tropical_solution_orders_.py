from typing import Dict, List, Sequence, Tuple

def enumerate_tropical_solution_orders(
    terms: Sequence[Dict[int, int]], n_lo: int, n_hi: int
) -> List[int]:
    """Enumerate candidate solution orders of a differential polynomial (Theorem `tropical_FTDA`).

    Each term is an exponent vector e^{(k)}; its tropicalized order at f-order n is
    sum_i e^{(k)}_i (n - i). A value n is a *tropical solution order* iff the minimum over
    terms is attained at least twice. By the containment direction of the tropical fundamental
    theorem of differential algebra, every classical power-series solution has its order in
    this finite set. Complexity: O((n_hi - n_lo) * t).
    """
    def term_order(e: Dict[int, int], n: int) -> int:
        return sum(c * (n - i) for i, c in e.items())

    out: List[int] = []
    for n in range(n_lo, n_hi + 1):
        vals = [term_order(e, n) for e in terms]
        m = min(vals)
        if vals.count(m) >= 2:
            out.append(n)
    return out
