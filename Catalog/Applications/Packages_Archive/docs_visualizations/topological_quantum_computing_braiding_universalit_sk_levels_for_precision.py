from __future__ import annotations
import math


def sk_levels_for_precision(eps0: float, eps_target: float) -> int:
    """Smallest number of Solovay-Kitaev recursion levels n such that the error
    eps0 ** (3/2)^n drops below eps_target.

    Mathematical foundation: each SK level replaces an eps-approximation by an
    eps**(3/2)-approximation (group-commutator construction), so after n levels
    the error is eps0 ** (3/2)^n -- a doubly-exponential collapse. Requires
    0 < eps0 < 1 and 0 < eps_target < eps0.

    Complexity: O(log log (1/eps_target)) iterations; each costs O(1).
    """
    if not (0.0 < eps0 < 1.0):
        raise ValueError("need 0 < eps0 < 1")
    if not (0.0 < eps_target < eps0):
        raise ValueError("need 0 < eps_target < eps0")
    n = 0
    err = eps0
    while err >= eps_target:
        n += 1
        err = eps0 ** ((3.0 / 2.0) ** n)
    return n
