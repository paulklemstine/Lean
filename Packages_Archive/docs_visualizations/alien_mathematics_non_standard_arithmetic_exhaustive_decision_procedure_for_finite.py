"""Exhaustive decision procedure for the finite chain semiring axioms."""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple


def chain_add(x: int, y: int) -> int:
    """Chain addition = join = max."""
    return max(x, y)


def chain_mul(x: int, y: int) -> int:
    """Chain multiplication = meet = min."""
    return min(x, y)


def verify_commutative_semiring(n: int) -> Dict[str, bool]:
    """Decide every commutative-semiring axiom on C_n = {0,...,n} by exhaustion.

    Returns a dict mapping each axiom name to its truth value. Each universally
    quantified axiom over k variables is checked over all (n+1)^k tuples, so the
    cost is O((n+1)^3) comparisons (cubic, from the distributive laws).
    """
    rng = range(n + 1)
    bot, top = 0, n
    axioms: Dict[str, bool] = {}

    axioms["add_comm"] = all(
        chain_add(x, y) == chain_add(y, x) for x, y in product(rng, repeat=2)
    )
    axioms["add_assoc"] = all(
        chain_add(chain_add(x, y), z) == chain_add(x, chain_add(y, z))
        for x, y, z in product(rng, repeat=3)
    )
    axioms["mul_comm"] = all(
        chain_mul(x, y) == chain_mul(y, x) for x, y in product(rng, repeat=2)
    )
    axioms["mul_assoc"] = all(
        chain_mul(chain_mul(x, y), z) == chain_mul(x, chain_mul(y, z))
        for x, y, z in product(rng, repeat=3)
    )
    axioms["zero_add"] = all(chain_add(bot, x) == x for x in rng)
    axioms["one_mul"] = all(chain_mul(top, x) == x for x in rng)
    axioms["zero_mul"] = all(chain_mul(bot, x) == bot for x in rng)
    axioms["left_distrib"] = all(
        chain_mul(x, chain_add(y, z))
        == chain_add(chain_mul(x, y), chain_mul(x, z))
        for x, y, z in product(rng, repeat=3)
    )
    axioms["right_distrib"] = all(
        chain_mul(chain_add(x, y), z)
        == chain_add(chain_mul(x, z), chain_mul(y, z))
        for x, y, z in product(rng, repeat=3)
    )
    return axioms


def no_additive_inverse_certificate(n: int) -> Tuple[bool, int]:
    """Certify (in O(1)) that the unit ⊤ = n has no additive inverse for n >= 1.

    Returns (holds, witness) where witness = ⊤ is the element with no inverse.
    """
    if n < 1:
        return (False, n)
    top = n
    holds = all(chain_add(top, z) != 0 for z in range(n + 1))
    return (holds, top)


if __name__ == "__main__":
    for n in range(1, 6):
        result = verify_commutative_semiring(n)
        ok = all(result.values())
        cert, witness = no_additive_inverse_certificate(n)
        print(f"C_{n}: all axioms = {ok}; ⊤={witness} has no additive inverse = {cert}")
