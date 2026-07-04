"""
Numerical demonstrations of a tractable combinatorial surrogate for
Integrated Information (Phi).

The surrogate is built from the co-activation relation of a finite system of
Boolean variables:

  * A system is a probability distribution over configurations c: {0,...,n-1} -> {0,1},
    given here as exact rational weights (fractions.Fraction).
  * marginal(i)     = P[variable i active]
  * joint(i, j)     = P[variables i and j both active]
  * co-active(i,j)  <=>  marginal(i) * marginal(j) < joint(i, j)   (strict positive correlation)
  * cross-score of a bipartition (A, B) counts co-active pairs crossing the cut.
  * Phi = max over nonempty disjoint bipartitions (A, B) of the cross-score.

All arithmetic is exact (rational), so every printed Phi is a certified integer.

Results demonstrated:
  * Complete Integration Formula:   Phi(complete co-activation on n) = floor(n^2 / 4)
  * Cross-Score Lemma:              cross(A, B) = |A| * |B| for the complete co-activation
  * Monotonicity under Independent Extension:  adding an uncorrelated variable never lowers Phi
  * Worked examples:                correlated triple -> Phi = 2,  independent pair -> Phi = 0
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, List, Tuple

Config = Tuple[int, ...]                       # a configuration, e.g. (0, 1, 1)
Weights = Dict[Config, Fraction]              # exact rational weights on configurations
Relation = Callable[[int, int], bool]         # symmetric co-activation relation


# ---------------------------------------------------------------------------
# Probabilistic statistics from exact rational weights
# ---------------------------------------------------------------------------

def all_configs(n: int) -> List[Config]:
    """Enumerate all 2^n Boolean configurations on n variables."""
    return [tuple(bits) for bits in product((0, 1), repeat=n)]


def marginal(weights: Weights, i: int) -> Fraction:
    """P[variable i is active]."""
    return sum((w for c, w in weights.items() if c[i] == 1), Fraction(0))


def joint(weights: Weights, i: int, j: int) -> Fraction:
    """P[variables i and j are both active]."""
    return sum((w for c, w in weights.items() if c[i] == 1 and c[j] == 1), Fraction(0))


def coactivation_relation(weights: Weights, n: int) -> Relation:
    """Strict positive-correlation co-activation: m_i * m_j < J_ij."""
    m = [marginal(weights, i) for i in range(n)]

    def R(i: int, j: int) -> bool:
        return m[i] * m[j] < joint(weights, i, j)

    return R


# ---------------------------------------------------------------------------
# The surrogate Phi
# ---------------------------------------------------------------------------

def cross_score(R: Relation, A: Tuple[int, ...], B: Tuple[int, ...]) -> int:
    """Number of co-active pairs (i in A, j in B)."""
    return sum(1 for i in A for j in B if R(i, j))


def phi(R: Relation, n: int) -> int:
    """
    Surrogate integrated information: the maximum cross-score over all
    bipartitions of {0,...,n-1} into two disjoint nonempty parts.

    Each element is placed in A (0), B (1), or neither (2); we require both
    A and B nonempty.  O(3^n) enumeration.
    """
    best = 0
    for assignment in product((0, 1, 2), repeat=n):
        A = tuple(i for i in range(n) if assignment[i] == 0)
        B = tuple(i for i in range(n) if assignment[i] == 1)
        if A and B:
            best = max(best, cross_score(R, A, B))
    return best


def complete_coactivation(n: int) -> Relation:
    """The complete co-activation on n variables: every distinct pair co-active."""
    return lambda i, j: i != j


# ---------------------------------------------------------------------------
# Distribution builders
# ---------------------------------------------------------------------------

def perfectly_correlated(n: int) -> Weights:
    """All variables locked together: 1/2 on all-active, 1/2 on all-inactive."""
    on = tuple(1 for _ in range(n))
    off = tuple(0 for _ in range(n))
    return {on: Fraction(1, 2), off: Fraction(1, 2)}


def independent_uniform(n: int) -> Weights:
    """Each of the 2^n configurations equally likely (independent fair variables)."""
    configs = all_configs(n)
    w = Fraction(1, len(configs))
    return {c: w for c in configs}


def independent_extension(weights: Weights, n: int) -> Weights:
    """
    Adjoin one fresh variable independent of everything, active with prob 1/2.
    The new variable sits at index n; it is uncorrelated with all others.
    """
    out: Weights = {}
    for c, w in weights.items():
        out[c + (0,)] = w * Fraction(1, 2)
        out[c + (1,)] = w * Fraction(1, 2)
    return out


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_complete_integration_formula(max_n: int = 8) -> None:
    print("=" * 68)
    print("Complete Integration Formula:  Phi(K_n) = floor(n^2 / 4)")
    print("=" * 68)
    print(f"{'n':>3} | {'Phi(K_n)':>9} | {'floor(n^2/4)':>13} | match")
    print("-" * 44)
    for n in range(1, max_n + 1):
        value = phi(complete_coactivation(n), n)
        formula = (n * n) // 4
        print(f"{n:>3} | {value:>9} | {formula:>13} | {value == formula}")
    print()


def demo_cross_score_lemma(n: int = 6) -> None:
    print("=" * 68)
    print("Cross-Score Lemma:  cross(A, B) = |A| * |B|  (complete co-activation)")
    print("=" * 68)
    R = complete_coactivation(n)
    splits = [((0,), (1, 2)), ((0, 1), (2, 3, 4)), ((0, 1, 2), (3, 4, 5))]
    for A, B in splits:
        cs = cross_score(R, A, B)
        print(f"  A={A}, B={B}:  cross={cs}, |A|*|B|={len(A) * len(B)}, "
              f"match={cs == len(A) * len(B)}")
    print()


def demo_worked_examples() -> None:
    print("=" * 68)
    print("Worked examples")
    print("=" * 68)

    # Perfectly correlated triple -> Phi = 2
    w3 = perfectly_correlated(3)
    R3 = coactivation_relation(w3, 3)
    print(f"  Perfectly correlated triple:  Phi = {phi(R3, 3)}  (expected 2)")

    # Independent pair -> Phi = 0
    w2 = independent_uniform(2)
    R2 = coactivation_relation(w2, 2)
    print(f"  Independent fair pair:        Phi = {phi(R2, 2)}  (expected 0)")
    print()


def demo_monotonicity() -> None:
    print("=" * 68)
    print("Monotonicity under Independent Extension:  Phi(R+) >= Phi(R)")
    print("=" * 68)
    base_builders = {
        "correlated triple": (perfectly_correlated(3), 3),
        "correlated quadruple": (perfectly_correlated(4), 4),
    }
    for name, (weights, n) in base_builders.items():
        R = coactivation_relation(weights, n)
        phi_base = phi(R, n)

        ext = independent_extension(weights, n)
        R_ext = coactivation_relation(ext, n + 1)
        phi_ext = phi(R_ext, n + 1)

        print(f"  {name:>22}:  Phi = {phi_base}  ->  Phi(+1 indep var) = "
              f"{phi_ext}  (>=: {phi_ext >= phi_base})")
    print()


def main() -> None:
    demo_complete_integration_formula()
    demo_cross_score_lemma()
    demo_worked_examples()
    demo_monotonicity()
    print("All demonstrations completed with exact rational arithmetic.")


if __name__ == "__main__":
    main()
