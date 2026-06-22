from __future__ import annotations
from itertools import product
from typing import Callable, List, Optional

def audit_consensus_certificate(
    elements: List[int],
    op: Callable[[int, int], int],
    act: Callable[[int, int], int],
    f: Callable[[int], int],
    witness: int,
    modulus: int,
    n_agents: int,
    fault_count: int,
) -> tuple[bool, str]:
    """Audit a Byzantine consensus certificate.

    Returns (accepted, reason). The procedure has three stages:
      1. Feasibility   - classical Byzantine bound 3f+1 <= n          O(1)
      2. Coherence     - cocycle condition over all pairs (g,h)       O(|G|^2)
      3. Resolvability - coboundary check f(g) = g.a - a              O(|G|)
    A rejection at stage 3 despite passing stage 2 certifies a nonzero
    class in H^1(G, A): an irreducible obstruction to consensus.
    """
    # Stage 1: feasibility
    if not (3 * fault_count + 1 <= n_agents):
        return (False, "REJECT: insufficient redundancy (3f+1 > n)")
    # Stage 2: coherence (cocycle), O(|G|^2)
    for g, h in product(elements, elements):
        lhs = f(op(g, h)) % modulus
        rhs = (f(g) + act(g, f(h))) % modulus
        if lhs != rhs:
            return (False, f"REJECT: incoherent pattern at (g={g}, h={h})")
    # Stage 3: resolvability (coboundary), O(|G|)
    for g in elements:
        if f(g) % modulus != (act(g, witness) - witness) % modulus:
            return (False, f"REJECT: not a coboundary of {witness} at g={g}")
    return (True, f"ACCEPT: consensus certified with value {witness}")


def search_consensus_value(
    elements: List[int],
    act: Callable[[int, int], int],
    f: Callable[[int], int],
    modulus: int,
) -> Optional[int]:
    """Brute-force search A for a coboundary witness; None => nonzero H^1 class."""
    for a in range(modulus):
        if all(f(g) % modulus == (act(g, a) - a) % modulus for g in elements):
            return a
    return None
