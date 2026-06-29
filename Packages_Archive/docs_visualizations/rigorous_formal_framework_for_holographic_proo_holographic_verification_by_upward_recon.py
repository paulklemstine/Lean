from typing import Callable, List

Hash = Callable[[int, int], int]


def reconstruct(h: Hash, x: int, p: List[bool], cert: List[int]) -> int:
    """Fold a claimed leaf value x and its certificate back up to a root.

    Mirrors the Lean `reconstruct`. At a left step (False) the running digest
    is the left child and the certificate entry is the right sibling; at a right
    step (True) the roles swap. Cost: exactly len(cert) = O(depth) = O(log n)
    hash evaluations for a balanced proof -- independent of total proof size.
    """
    if len(p) == 0:
        return x
    sub = reconstruct(h, x, p[1:], cert[1:])
    return h(sub, cert[0]) if p[0] is False else h(cert[0], sub)


def verify(h: Hash, claimed_leaf: int, p: List[bool], cert: List[int],
           published_root: int) -> bool:
    """Accept iff the reconstructed root matches the published commitment.

    Completeness: an honest (leaf, cert) always passes. Binding: if h is
    injective (collision resistant), only the committed leaf passes.
    """
    return reconstruct(h, claimed_leaf, p, cert) == published_root
