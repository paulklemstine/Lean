"""
Numerical demonstration of the counterexample to

    "Every maximal-fitness limit theory is primitive and rank-minimal."

We model a finite landscape of mathematical theories carrying:
  * a proper sub-theory order (S < T means "S is a proper sub-theory of T"),
  * a natural-number rank,
  * rational traits (connections, proof density, axiom count),
  * a fitness  f(T) = connections(T) * proofDensity(T) / axiomCount(T).

The two-theory landscape {base, ext} satisfies extension monotonicity and
well-founded rank descent, yet its unique maximal-fitness, rank-minimal,
terminal theory (ext) is NOT primitive (base is a proper sub-theory of it).

All arithmetic is exact (fractions.Fraction), mirroring the rational
arithmetic over Q used in the formal development.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Tuple


@dataclass(frozen=True)
class Theory:
    """A theory with a name, structural rank, and three rational traits."""

    name: str
    rank: int
    connections: Fraction
    proof_density: Fraction
    axiom_count: Fraction


def fitness(t: Theory) -> Fraction:
    """f(T) = connections(T) * proofDensity(T) / axiomCount(T)."""
    return t.connections * t.proof_density / t.axiom_count


# ---------------------------------------------------------------------------
# The two-theory landscape.
# ---------------------------------------------------------------------------

BASE = Theory("base", rank=0, connections=Fraction(1),
              proof_density=Fraction(1), axiom_count=Fraction(1))
EXT = Theory("ext", rank=1, connections=Fraction(2),
             proof_density=Fraction(1), axiom_count=Fraction(1))

THEORIES: List[Theory] = [BASE, EXT]

# Proper sub-theory order: only base < ext.
PROPER_SUB: Callable[[Theory, Theory], bool] = (
    lambda s, t: s.name == "base" and t.name == "ext"
)


# ---------------------------------------------------------------------------
# Derived predicates (all decidable by finite enumeration).
# ---------------------------------------------------------------------------

def is_primitive(t: Theory, theories: List[Theory],
                 sub: Callable[[Theory, Theory], bool]) -> bool:
    """T is primitive iff no S is a proper sub-theory of T."""
    return not any(sub(s, t) for s in theories)


def is_max_fitness(t: Theory, theories: List[Theory]) -> bool:
    """T has maximal fitness iff f(U) <= f(T) for all U."""
    return all(fitness(u) <= fitness(t) for u in theories)


def is_rank_minimal_among_max(t: Theory, theories: List[Theory]) -> bool:
    """T is maximal-fitness and of minimal rank among maximal-fitness theories."""
    if not is_max_fitness(t, theories):
        return False
    return all(t.rank <= u.rank
               for u in theories if is_max_fitness(u, theories))


def is_mutation(s: Theory, t: Theory,
                sub: Callable[[Theory, Theory], bool]) -> bool:
    """A mutation is a proper extension that strictly increases fitness."""
    return sub(s, t) and fitness(s) < fitness(t)


def is_terminal(t: Theory, theories: List[Theory],
                sub: Callable[[Theory, Theory], bool]) -> bool:
    """T is terminal iff it admits no fitness-increasing mutation."""
    return not any(is_mutation(t, u, sub) for u in theories)


# ---------------------------------------------------------------------------
# Hypothesis checks (must hold in the model).
# ---------------------------------------------------------------------------

def extension_monotone(theories: List[Theory],
                       sub: Callable[[Theory, Theory], bool]) -> bool:
    """(EM): S < T  =>  f(S) <= f(T)."""
    return all(fitness(s) <= fitness(t)
               for s, t in product(theories, theories) if sub(s, t))


def well_founded_rank_descent(theories: List[Theory],
                              sub: Callable[[Theory, Theory], bool]) -> bool:
    """(WF): S < T  =>  rank(S) < rank(T)."""
    return all(s.rank < t.rank
               for s, t in product(theories, theories) if sub(s, t))


# ---------------------------------------------------------------------------
# Counterexample search.
# ---------------------------------------------------------------------------

def find_counterexample(theories: List[Theory],
                        sub: Callable[[Theory, Theory], bool]
                        ) -> List[Theory]:
    """Return theories that are maximal-fitness, rank-minimal among maxima,
    terminal, yet NOT primitive."""
    return [t for t in theories
            if is_max_fitness(t, theories)
            and is_rank_minimal_among_max(t, theories)
            and is_terminal(t, theories, sub)
            and not is_primitive(t, theories, sub)]


def main() -> None:
    print("=" * 64)
    print("Fitness landscape")
    print("=" * 64)
    for t in THEORIES:
        print(f"  {t.name:5s}  rank={t.rank}  "
              f"connections={t.connections}  "
              f"f(T)={fitness(t)}")

    print()
    print("Structural hypotheses (should both be True):")
    print(f"  extension monotonicity (EM): "
          f"{extension_monotone(THEORIES, PROPER_SUB)}")
    print(f"  well-founded rank descent (WF): "
          f"{well_founded_rank_descent(THEORIES, PROPER_SUB)}")

    print()
    print("Per-theory predicate table:")
    header = f"  {'name':5s} {'maxFit':7s} {'rankMin':8s} {'terminal':9s} {'primitive':10s}"
    print(header)
    for t in THEORIES:
        print(f"  {t.name:5s} "
              f"{str(is_max_fitness(t, THEORIES)):7s} "
              f"{str(is_rank_minimal_among_max(t, THEORIES)):8s} "
              f"{str(is_terminal(t, THEORIES, PROPER_SUB)):9s} "
              f"{str(is_primitive(t, THEORIES, PROPER_SUB)):10s}")

    print()
    witnesses = find_counterexample(THEORIES, PROPER_SUB)
    print("Counterexample witnesses (max-fitness, rank-minimal, terminal, "
          "NOT primitive):")
    for t in witnesses:
        print(f"  -> {t.name}: refutes the conjecture")
    assert [t.name for t in witnesses] == ["ext"], "expected ext as witness"

    print()
    print("=" * 64)
    print("Repair: parsimony  S < T => f(T) <= f(S)")
    print("=" * 64)
    # Swap connection counts so fitness is non-increasing along extension.
    base_par = Theory("base", 0, Fraction(2), Fraction(1), Fraction(1))
    ext_par = Theory("ext", 1, Fraction(1), Fraction(1), Fraction(1))
    par_theories = [base_par, ext_par]
    par_sub: Callable[[Theory, Theory], bool] = (
        lambda s, t: s.name == "base" and t.name == "ext"
    )
    parsimony_holds = all(
        fitness(t) <= fitness(s)
        for s, t in product(par_theories, par_theories) if par_sub(s, t)
    )
    print(f"  parsimony holds: {parsimony_holds}")
    for t in par_theories:
        print(f"  {t.name:5s}  f(T)={fitness(t)}  "
              f"maxFit={is_max_fitness(t, par_theories)}  "
              f"primitive={is_primitive(t, par_theories, par_sub)}")
    crowned = [t for t in par_theories
               if is_max_fitness(t, par_theories)
               and is_primitive(t, par_theories, par_sub)]
    print(f"  under parsimony, the maximal-fitness theory IS primitive: "
          f"{[t.name for t in crowned]}")


if __name__ == "__main__":
    main()
