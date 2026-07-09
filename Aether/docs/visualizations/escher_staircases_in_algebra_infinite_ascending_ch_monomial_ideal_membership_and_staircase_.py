from __future__ import annotations
from typing import Set, Tuple

Monomial = Tuple[Tuple[int, int], ...]  # sorted (variable_index, positive_exponent) pairs

def in_variable_ideal(m: Monomial, gens: Set[int]) -> bool:
    """Decide membership of a monomial in a monomial ideal <x_i : i in gens>.

    A monomial belongs to a monomial ideal iff at least one generator divides it;
    for variable generators this means the monomial has a positive exponent at some
    generating index.  Runs in O(len(m)) time.
    """
    return any(exp > 0 and idx in gens for idx, exp in m)

def strict_jump_witness(n: int) -> Monomial:
    """Return x_n, the witness that V_n = <x_0,...,x_{n-1}> is strictly below V_{n+1}."""
    return ((n, 1),)

def certify_variable_staircase(depth: int) -> bool:
    """Verify V_0 < V_1 < ... < V_depth is strictly ascending."""
    for n in range(depth):
        xn = strict_jump_witness(n)
        if not (in_variable_ideal(xn, set(range(n + 1))) and
                not in_variable_ideal(xn, set(range(n)))):
            return False
    return True
