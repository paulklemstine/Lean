from typing import Callable, Hashable, Set

def reachable_set(encoder: Callable[[int], Hashable], n: int, k: int) -> Set[Hashable]:
    """Return R_k(E) = { E(i) : 0 <= i < n, i <= k }.

    By the Counting Bound theorem, |R_k(E)| <= k + 1 for every encoder E,
    independently of n or the structure of E.
    """
    return {encoder(i) for i in range(n) if i <= k}

def counting_bound_holds(encoder: Callable[[int], Hashable], n: int, k: int) -> bool:
    """Verify the exact counting bound |R_k(E)| <= k + 1 on a concrete encoder."""
    return len(reachable_set(encoder, n, k)) <= k + 1
