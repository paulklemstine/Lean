from typing import List, Sequence, Tuple

def tropical_balancing_check(term_orders: Sequence[float]) -> Tuple[bool, List[int]]:
    """Decide whether a tropicalized relation is balanced (`tropical_balancing`).

    Given the orders of the terms of a finite sum, the minimum is `attained at least twice`
    iff the relation *can* vanish classically. Returns (balanced, minimizers), where
    `minimizers` are the indices achieving the minimum among the nonzero (finite-order) terms.
    If balanced is False, no classical solution exists at this order (contrapositive of the
    balancing lemma / `tropical_FTDA`). Complexity: O(t) for t terms.
    """
    finite = [(i, o) for i, o in enumerate(term_orders) if o != float("inf")]
    if not finite:
        return True, []
    m = min(o for _, o in finite)
    minimizers = [i for i, o in finite if o == m]
    return (len(minimizers) >= 2), minimizers
