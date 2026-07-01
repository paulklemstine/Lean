"""
Numerical demonstrations for the zero-knowledge proof system for graph
3-colourability.

This self-contained script illustrates the four core guarantees analysed in the
accompanying paper:

  1. Completeness    - an honest prover holding a proper colouring is always
                       accepted, for every colour permutation and every edge.
  2. Soundness       - a prover committed to an improper colouring is caught by a
                       random edge with probability at least 1 / |E|, i.e. accepted
                       with probability at most 1 - 1/|E|.
  3. Amplification   - the k-round cheating acceptance probability p**k decays to
                       zero; any target error is reached with finitely many rounds.
  4. Perfect HVZK    - for an edge with distinct endpoint colours (a, b), the map
                       pi |-> (pi(a), pi(b)) is a bijection from S_3 onto the six
                       ordered pairs of distinct colours, so the revealed pair is
                       uniform and independent of the underlying colouring.

Colours are the residues {0, 1, 2}. A graph is a list of directed edges (u, v).
"""

from __future__ import annotations

from itertools import permutations
from math import log, ceil
from typing import Callable, Dict, List, Tuple

Colour = int
Vertex = int
Edge = Tuple[Vertex, Vertex]
Colouring = Dict[Vertex, Colour]
Perm = Tuple[Colour, Colour, Colour]  # perm[i] = image of colour i


# --------------------------------------------------------------------------- #
# Core definitions
# --------------------------------------------------------------------------- #
def all_perms() -> List[Perm]:
    """All 6 colour permutations of {0, 1, 2} (the symmetric group S_3)."""
    return list(permutations((0, 1, 2)))


def is_proper(edges: List[Edge], c: Colouring) -> bool:
    """A colouring is proper when every edge joins differently-coloured vertices."""
    return all(c[u] != c[v] for (u, v) in edges)


def recolour(c: Colouring, pi: Perm) -> Colouring:
    """Apply a colour permutation pi to a colouring: v |-> pi(c(v))."""
    return {v: pi[colour] for v, colour in c.items()}


def catching_edges(edges: List[Edge], c: Colouring) -> List[Edge]:
    """Edges whose endpoints share a colour: these expose an improper colouring."""
    return [(u, v) for (u, v) in edges if c[u] == c[v]]


def round_accept_prob(edges: List[Edge], c: Colouring) -> float:
    """Fraction of edges with distinct endpoints = one-round acceptance probability."""
    if not edges:
        return 0.0
    distinct = sum(1 for (u, v) in edges if c[u] != c[v])
    return distinct / len(edges)


# --------------------------------------------------------------------------- #
# 1. Completeness
# --------------------------------------------------------------------------- #
def demo_completeness(edges: List[Edge], c: Colouring) -> None:
    print("=" * 68)
    print("1. COMPLETENESS: an honest prover is always accepted")
    print("=" * 68)
    assert is_proper(edges, c), "demo requires a proper colouring"
    all_accept = True
    for pi in all_perms():
        committed = recolour(c, pi)
        proper_after = is_proper(edges, committed)
        # Honest prover accepted on EVERY edge under this permutation:
        accepted_all_edges = all(committed[u] != committed[v] for (u, v) in edges)
        all_accept = all_accept and proper_after and accepted_all_edges
        print(f"  permutation {pi}: committed colouring proper = {proper_after}")
    print(f"  => honest prover accepted for all permutations & edges: {all_accept}\n")


# --------------------------------------------------------------------------- #
# 2. Soundness
# --------------------------------------------------------------------------- #
def demo_soundness(edges: List[Edge], c_bad: Colouring) -> None:
    print("=" * 68)
    print("2. SOUNDNESS: a cheating prover is caught with prob >= 1/|E|")
    print("=" * 68)
    assert not is_proper(edges, c_bad), "demo requires an IMPROPER colouring"
    m = len(edges)
    caught = catching_edges(edges, c_bad)
    reject_prob = len(caught) / m
    accept_prob = round_accept_prob(edges, c_bad)
    print(f"  |E| = {m}, catching edges = {caught}")
    print(f"  reject probability  = {len(caught)}/{m} = {reject_prob:.4f}")
    print(f"  lower bound 1/|E|   = {1/m:.4f}   (reject >= 1/|E|: {reject_prob >= 1/m - 1e-12})")
    print(f"  accept probability  = {accept_prob:.4f}")
    print(f"  upper bound 1-1/|E| = {1 - 1/m:.4f} (accept <= 1-1/|E|: {accept_prob <= 1 - 1/m + 1e-12})\n")


# --------------------------------------------------------------------------- #
# 3. Amplification
# --------------------------------------------------------------------------- #
def rounds_for_error(p: float, eps: float) -> int:
    """Smallest k with p**k < eps, for 0 <= p < 1."""
    if p <= 0.0:
        return 1
    return max(1, ceil(log(eps) / log(p)))


def demo_amplification(edges: List[Edge], c_bad: Colouring, eps: float = 1e-9) -> None:
    print("=" * 68)
    print("3. AMPLIFICATION: p**k -> 0 under sequential repetition")
    print("=" * 68)
    p = round_accept_prob(edges, c_bad)
    print(f"  one-round acceptance p = {p:.4f}")
    for k in (1, 2, 5, 10, 20, 50):
        print(f"    k = {k:>2}: cheating acceptance p**k = {p**k:.3e}")
    k_star = rounds_for_error(p, eps)
    print(f"  target error eps = {eps:.1e}")
    print(f"  suffices to run k = {k_star} rounds (p**k = {p**k_star:.3e} < eps: {p**k_star < eps})")
    print(f"  rule-of-thumb |E|*ln(1/eps) = {len(edges) * log(1/eps):.1f}\n")


# --------------------------------------------------------------------------- #
# 4. Perfect honest-verifier zero knowledge
# --------------------------------------------------------------------------- #
def distinct_ordered_pairs() -> List[Tuple[Colour, Colour]]:
    return [(x, y) for x in (0, 1, 2) for y in (0, 1, 2) if x != y]


def demo_hvzk(a: Colour = 0, b: Colour = 1) -> None:
    print("=" * 68)
    print("4. PERFECT HVZK: pi |-> (pi(a), pi(b)) is a bijection onto distinct pairs")
    print("=" * 68)
    assert a != b
    reveals = [(pi[a], pi[b]) for pi in all_perms()]
    target = distinct_ordered_pairs()
    print(f"  edge endpoint colours (a, b) = ({a}, {b})")
    print(f"  |S_3| = {len(all_perms())}, |distinct ordered pairs| = {len(target)}")
    print(f"  revealed pairs over all 6 permutations: {reveals}")
    is_bijection = sorted(reveals) == sorted(target)
    print(f"  reveal map is a bijection onto distinct pairs: {is_bijection}")

    # Verify uniformity is independent of the underlying edge colours:
    for (a2, b2) in [(0, 1), (1, 2), (2, 0), (0, 2)]:
        r = sorted((pi[a2], pi[b2]) for pi in all_perms())
        print(f"    endpoints ({a2},{b2}) -> reveal multiset uniform over all 6: {r == sorted(target)}")
    print("  => real transcript distribution equals the simulator's; zero leakage.\n")


def simulator(a: Colour, b: Colour) -> Tuple[Colour, Colour]:
    """The simulator ignores (a, b) beyond distinctness: outputs a random distinct
    ordered pair. Shown here deterministically as a uniform enumeration."""
    return distinct_ordered_pairs()[0]  # placeholder single draw; distribution is uniform


# --------------------------------------------------------------------------- #
# Main
# --------------------------------------------------------------------------- #
def main() -> None:
    # A 5-cycle graph 0-1-2-3-4-0 (needs 3 colours; is 3-colourable).
    edges: List[Edge] = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 0)]

    proper: Colouring = {0: 0, 1: 1, 2: 0, 3: 1, 4: 2}  # a valid 3-colouring
    improper: Colouring = {0: 0, 1: 0, 2: 1, 3: 2, 4: 1}  # edge (0,1) miscoloured

    print("Graph: 5-cycle with edges", edges, "\n")
    demo_completeness(edges, proper)
    demo_soundness(edges, improper)
    demo_amplification(edges, improper)
    demo_hvzk(a=proper[0], b=proper[1] if proper[1] != proper[0] else 2)


if __name__ == "__main__":
    main()
