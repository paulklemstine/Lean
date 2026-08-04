#!/usr/bin/env python3
"""
Numerical demonstration of the graph 3-colouring zero-knowledge proof system.

This self-contained script verifies, numerically and symbolically, the results of
the accompanying paper:

  1. Complementarity          alpha(E, c) + rho(E, c) = 1
  2. Perfect completeness     alpha(E, c) = 1 for a proper colouring c
  3. One-round soundness      alpha(E, c') <= 1 - 1/|E| for improper c'
  4. Amplification            alpha(E, c')^k <= (1 - 1/|E|)^k
  5. Round-count selection    k = ceil(|E| * ln(1/eps)) forces error <= eps
  6. Transcript uniformity    every ordered pair of distinct colours has mass 1/6
  7. Colour/edge independence the transcript law does not depend on (E, c, e)
  8. Perfect zero knowledge   real transcript law == colouring-oblivious simulator law
  9. Zero advantage           every one of the 64 deterministic distinguishers has
                              acceptance probability difference exactly 0

All probabilities are computed with exact rational arithmetic (fractions.Fraction),
so the equalities below are exact, not approximate.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Basic types
# ----------------------------------------------------------------------------

Vertex = int
Edge = Tuple[Vertex, Vertex]
Colour = int                      # element of {0, 1, 2}
Colouring = Dict[Vertex, Colour]  # total on the vertices used
Pair = Tuple[Colour, Colour]      # element of the transcript space

COLOURS: Tuple[Colour, ...] = (0, 1, 2)

#: The six ordered pairs of distinct colours -- the transcript space P.
DISTINCT_PAIRS: Tuple[Pair, ...] = tuple(
    (a, b) for a in COLOURS for b in COLOURS if a != b
)

#: The six permutations of the three-element colour set, as tuples
#: perm[i] = image of colour i.
PERMUTATIONS: Tuple[Tuple[Colour, Colour, Colour], ...] = tuple(
    itertools.permutations(COLOURS)
)


# ----------------------------------------------------------------------------
# Colourings and the acceptance / rejection model
# ----------------------------------------------------------------------------

def is_proper_colouring(edges: Sequence[Edge], colouring: Colouring) -> bool:
    """Return True iff no edge has both endpoints the same colour."""
    return all(colouring[u] != colouring[v] for (u, v) in edges)


def acceptance_probability(edges: Sequence[Edge], colouring: Colouring) -> Fraction:
    """Exact one-round acceptance probability: fraction of bichromatic edges."""
    if len(edges) == 0:
        raise ValueError("acceptance probability undefined for an empty edge set")
    good = sum(1 for (u, v) in edges if colouring[u] != colouring[v])
    return Fraction(good, len(edges))


def rejection_probability(edges: Sequence[Edge], colouring: Colouring) -> Fraction:
    """Exact one-round rejection probability: fraction of monochromatic edges."""
    if len(edges) == 0:
        raise ValueError("rejection probability undefined for an empty edge set")
    bad = sum(1 for (u, v) in edges if colouring[u] == colouring[v])
    return Fraction(bad, len(edges))


def soundness_bound(num_edges: int) -> Fraction:
    """The one-round soundness bound 1 - 1/|E| for an improper commitment."""
    if num_edges <= 0:
        raise ValueError("need at least one edge")
    return Fraction(1) - Fraction(1, num_edges)


def rounds_for_error(num_edges: int, epsilon: float) -> int:
    """Smallest k with (1 - 1/|E|)^k <= epsilon guaranteed by k >= m ln(1/eps)."""
    if not (0.0 < epsilon < 1.0):
        raise ValueError("epsilon must lie strictly between 0 and 1")
    return math.ceil(num_edges * math.log(1.0 / epsilon))


# ----------------------------------------------------------------------------
# Transcript distributions
# ----------------------------------------------------------------------------

def real_transcript_law(a: Colour, b: Colour) -> Dict[Pair, Fraction]:
    """
    Law of (pi(a), pi(b)) for pi uniform over the six colour permutations.

    Requires a != b.  By simple transitivity of S_3 on ordered distinct pairs the
    result is uniform on the six pairs; this function computes it by brute force
    rather than assuming the theorem.
    """
    if a == b:
        raise ValueError("real transcript law requires distinct endpoint colours")
    law: Dict[Pair, Fraction] = {p: Fraction(0) for p in DISTINCT_PAIRS}
    for perm in PERMUTATIONS:
        law[(perm[a], perm[b])] += Fraction(1, len(PERMUTATIONS))
    return law


def simulator_law() -> Dict[Pair, Fraction]:
    """The colouring-oblivious simulator: uniform on the six distinct pairs."""
    return {p: Fraction(1, len(DISTINCT_PAIRS)) for p in DISTINCT_PAIRS}


def edge_transcript_law(
    edges: Sequence[Edge], colouring: Colouring, edge: Edge
) -> Dict[Pair, Fraction]:
    """Transcript law on a challenged edge of a properly coloured graph."""
    if edge not in edges:
        raise ValueError("challenged edge is not in the edge set")
    if not is_proper_colouring(edges, colouring):
        raise ValueError("transcript law requires a proper colouring")
    u, v = edge
    return real_transcript_law(colouring[u], colouring[v])


def distinguisher_acceptance(
    law: Dict[Pair, Fraction], predicate: Callable[[Pair], bool]
) -> Fraction:
    """Total mass the law assigns to the transcripts the distinguisher accepts."""
    return sum((law[p] for p in DISTINCT_PAIRS if predicate(p)), Fraction(0))


def all_deterministic_distinguishers() -> Iterable[Callable[[Pair], bool]]:
    """Enumerate all 2^6 = 64 Boolean functions on the transcript space."""
    for bits in itertools.product([False, True], repeat=len(DISTINCT_PAIRS)):
        table = dict(zip(DISTINCT_PAIRS, bits))
        yield (lambda p, table=table: table[p])


# ----------------------------------------------------------------------------
# Protocol execution (Monte Carlo, for illustration)
# ----------------------------------------------------------------------------

def run_round(
    edges: Sequence[Edge], colouring: Colouring, rng: random.Random
) -> Tuple[Pair, bool]:
    """One protocol round: random palette permutation, random edge, open, decide."""
    perm = rng.choice(PERMUTATIONS)
    u, v = rng.choice(list(edges))
    revealed: Pair = (perm[colouring[u]], perm[colouring[v]])
    return revealed, revealed[0] != revealed[1]


def run_protocol(
    edges: Sequence[Edge], colouring: Colouring, rounds: int, rng: random.Random
) -> bool:
    """Verifier accepts only if all rounds accept (legitimate: completeness is perfect)."""
    return all(run_round(edges, colouring, rng)[1] for _ in range(rounds))


# ----------------------------------------------------------------------------
# Example graphs
# ----------------------------------------------------------------------------

def triangle() -> Tuple[List[Edge], Colouring]:
    """K_3 with its (essentially unique) proper 3-colouring."""
    return [(0, 1), (1, 2), (2, 0)], {0: 0, 1: 1, 2: 2}


def petersen() -> Tuple[List[Edge], Colouring]:
    """The Petersen graph (15 edges) with a known proper 3-colouring."""
    outer: List[Edge] = [(i, (i + 1) % 5) for i in range(5)]
    spokes: List[Edge] = [(i, i + 5) for i in range(5)]
    inner: List[Edge] = [(5 + i, 5 + ((i + 2) % 5)) for i in range(5)]
    edges = outer + spokes + inner
    colouring: Colouring = {0: 0, 1: 1, 2: 0, 3: 1, 4: 2,
                            5: 1, 6: 2, 7: 2, 8: 0, 9: 0}
    assert is_proper_colouring(edges, colouring), "Petersen colouring must be proper"
    return edges, colouring


def near_miss_path(num_edges: int) -> Tuple[List[Edge], Colouring]:
    """
    A path with `num_edges` edges, 2-coloured alternately except that the final
    vertex copies its neighbour: exactly one monochromatic edge.  This attains
    the one-round soundness bound with equality.
    """
    edges: List[Edge] = [(i, i + 1) for i in range(num_edges)]
    colouring: Colouring = {i: i % 2 for i in range(num_edges + 1)}
    colouring[num_edges] = colouring[num_edges - 1]
    return edges, colouring


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_completeness_and_complementarity() -> None:
    print("=" * 74)
    print("1-2.  COMPLEMENTARITY AND PERFECT COMPLETENESS")
    print("=" * 74)
    for name, (edges, colouring) in [("triangle K3", triangle()),
                                     ("Petersen graph", petersen())]:
        alpha = acceptance_probability(edges, colouring)
        rho = rejection_probability(edges, colouring)
        print(f"  {name:16s} |E| = {len(edges):3d}   "
              f"alpha = {alpha}   rho = {rho}   alpha + rho = {alpha + rho}")
        assert alpha + rho == 1, "complementarity must hold exactly"
        assert is_proper_colouring(edges, colouring)
        assert alpha == 1, "perfect completeness: proper colourings always accepted"
    print("  -> alpha + rho = 1 exactly, and alpha = 1 for every proper colouring.\n")


def demo_soundness() -> None:
    print("=" * 74)
    print("3.  ONE-ROUND SOUNDNESS:  alpha <= 1 - 1/|E|, and it is tight")
    print("=" * 74)
    print(f"  {'|E|':>5} {'alpha (cheat)':>16} {'bound 1-1/|E|':>16} {'tight?':>8}")
    for m in (3, 5, 10, 25, 100):
        edges, colouring = near_miss_path(m)
        assert not is_proper_colouring(edges, colouring)
        alpha = acceptance_probability(edges, colouring)
        bound = soundness_bound(m)
        assert alpha <= bound
        print(f"  {m:5d} {str(alpha):>16} {str(bound):>16} "
              f"{str(alpha == bound):>8}")
    print("  -> the near-miss path attains the bound with equality.\n")


def demo_amplification() -> None:
    print("=" * 74)
    print("4-5.  AMPLIFICATION AND ROUND-COUNT SELECTION")
    print("=" * 74)
    m = 15
    edges, colouring = near_miss_path(m)
    alpha = acceptance_probability(edges, colouring)
    bound = soundness_bound(m)
    print(f"  Graph with |E| = {m}, cheating acceptance alpha = {alpha} "
          f"= {float(alpha):.6f}")
    print(f"  {'k':>6} {'alpha^k':>16} {'(1-1/|E|)^k':>16}")
    for k in (1, 5, 15, 50, 150, 500):
        lhs = alpha ** k
        rhs = bound ** k
        assert lhs <= rhs, "amplification bound must hold"
        print(f"  {k:6d} {float(lhs):16.10e} {float(rhs):16.10e}")
    print()
    print(f"  {'target eps':>12} {'k = ceil(m ln(1/eps))':>24} "
          f"{'achieved (1-1/m)^k':>22}")
    for eps in (1e-3, 1e-6, 1e-12, 1e-30):
        k = rounds_for_error(m, eps)
        achieved = float(bound ** k)
        assert achieved <= eps, "selected round count must meet the target"
        print(f"  {eps:12.0e} {k:24d} {achieved:22.6e}")
    print("  -> a number of rounds linear in |E| gives cryptographic-grade error.\n")


def demo_transcript_uniformity() -> None:
    print("=" * 74)
    print("6-7.  TRANSCRIPT UNIFORMITY AND COLOUR/EDGE INDEPENDENCE")
    print("=" * 74)
    tri_edges, tri_col = triangle()
    pet_edges, pet_col = petersen()

    reference = edge_transcript_law(tri_edges, tri_col, tri_edges[0])
    print("  Law of the opened pair on the triangle, edge (0,1):")
    for p in DISTINCT_PAIRS:
        print(f"     P[transcript = {p}] = {reference[p]}")
    assert all(reference[p] == Fraction(1, 6) for p in DISTINCT_PAIRS)

    instances = ([(tri_edges, tri_col, e) for e in tri_edges]
                 + [(pet_edges, pet_col, e) for e in pet_edges])
    laws = [edge_transcript_law(E, c, e) for (E, c, e) in instances]
    assert all(law == reference for law in laws)
    print(f"  Checked {len(laws)} distinct (graph, colouring, edge) instances: "
          "all laws identical.")
    print("  -> the transcript law is uniform (1/6 each) and independent of "
          "graph, colouring and edge.\n")


def demo_perfect_zero_knowledge() -> None:
    print("=" * 74)
    print("8-9.  PERFECT ZERO KNOWLEDGE AND ZERO DISTINGUISHING ADVANTAGE")
    print("=" * 74)
    pet_edges, pet_col = petersen()
    sim = simulator_law()

    max_abs_advantage = Fraction(0)
    checked = 0
    for edge in pet_edges:
        real = edge_transcript_law(pet_edges, pet_col, edge)
        assert real == sim, "real and simulated laws must coincide exactly"
        for D in all_deterministic_distinguishers():
            a_real = distinguisher_acceptance(real, D)
            a_sim = distinguisher_acceptance(sim, D)
            assert a_real - a_sim == 0 and a_sim - a_real == 0
            max_abs_advantage = max(max_abs_advantage, abs(a_real - a_sim))
            checked += 1
    print(f"  Edges tested                       : {len(pet_edges)}")
    print(f"  Deterministic distinguishers each  : "
          f"{2 ** len(DISTINCT_PAIRS)}")
    print(f"  Total (edge, distinguisher) checks : {checked}")
    print(f"  Maximum |advantage| observed       : {max_abs_advantage}")
    print(f"  Statistical (total variation) dist : {max_abs_advantage}")
    print("  -> real and simulated transcripts are the same distribution; "
          "every advantage is exactly 0.\n")


def demo_monte_carlo() -> None:
    print("=" * 74)
    print("MONTE CARLO SANITY CHECK (empirical frequencies)")
    print("=" * 74)
    rng = random.Random(20260803)
    trials = 200_000

    pet_edges, pet_col = petersen()
    counts: Dict[Pair, int] = {p: 0 for p in DISTINCT_PAIRS}
    accepts = 0
    for _ in range(trials):
        pair, ok = run_round(pet_edges, pet_col, rng)
        counts[pair] += 1
        accepts += int(ok)
    print(f"  Honest prover on the Petersen graph, {trials} rounds:")
    print(f"     empirical acceptance rate = {accepts / trials:.6f}  "
          "(theory: exactly 1)")
    print("     empirical transcript frequencies (theory: 1/6 = 0.166667 each):")
    print("       " + "  ".join(f"{p}:{counts[p] / trials:.4f}"
                                for p in DISTINCT_PAIRS))

    m = 15
    bad_edges, bad_col = near_miss_path(m)
    alpha = acceptance_probability(bad_edges, bad_col)
    for k in (1, 10, 50):
        survived = sum(run_protocol(bad_edges, bad_col, k, rng)
                       for _ in range(5000))
        print(f"  Cheating prover, k = {k:2d}: empirical survival "
              f"{survived / 5000:.5f}   theory alpha^k = {float(alpha ** k):.5f}"
              f"   bound = {float(soundness_bound(m) ** k):.5f}")
    print()


def main() -> None:
    print()
    print("ZERO-KNOWLEDGE PROOFS FOR GRAPH 3-COLOURABILITY")
    print("Exact verification of completeness, soundness, amplification, privacy")
    print()
    demo_completeness_and_complementarity()
    demo_soundness()
    demo_amplification()
    demo_transcript_uniformity()
    demo_perfect_zero_knowledge()
    demo_monte_carlo()
    print("=" * 74)
    print("All assertions passed: every theorem of the paper is confirmed "
          "on these instances.")
    print("=" * 74)


if __name__ == "__main__":
    main()
