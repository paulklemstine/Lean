from __future__ import annotations
from fractions import Fraction
from typing import Callable, List, Optional


def fitness(connections: Fraction, proof_density: Fraction,
            axiom_count: Fraction) -> Fraction:
    """Exact rational fitness f = connections * proofDensity / axiomCount."""
    return connections * proof_density / axiom_count


def counterexample_search(
    theories: List[str],
    rank: Callable[[str], int],
    fit: Callable[[str], Fraction],
    proper_sub: Callable[[str, str], bool],
) -> Optional[str]:
    """Return the first theory that is maximal-fitness, rank-minimal among
    maximal-fitness theories, and terminal, yet not primitive -- or None."""

    def is_max_fitness(t: str) -> bool:
        return all(fit(u) <= fit(t) for u in theories)

    def is_rank_minimal_among_max(t: str) -> bool:
        if not is_max_fitness(t):
            return False
        return all(rank(t) <= rank(u) for u in theories if is_max_fitness(u))

    def is_terminal(t: str) -> bool:
        return not any(proper_sub(t, u) and fit(t) < fit(u) for u in theories)

    def is_primitive(t: str) -> bool:
        return not any(proper_sub(s, t) for s in theories)

    for t in theories:
        if (is_max_fitness(t)
                and is_rank_minimal_among_max(t)
                and is_terminal(t)
                and not is_primitive(t)):
            return t
    return None
