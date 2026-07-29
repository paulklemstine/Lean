#!/usr/bin/env python3
"""Numerical demonstrations for zero-knowledge verifiable computation.

The script uses only the Python standard library.  It demonstrates:
1. exact transcript equality for the three-color protocol;
2. the polynomial root bound behind a random-point QAP check; and
3. two-query local rejection of invalid graph colorings.
"""

from __future__ import annotations

from collections import Counter
from fractions import Fraction
from itertools import permutations
from typing import Dict, Iterable, List, Mapping, Optional, Sequence, Tuple

Color = int
Transcript = Tuple[Color, Color]
Edge = Tuple[int, int]
Polynomial = Sequence[int]  # coefficients in increasing degree order


def transcript_distribution(a: Color, b: Color) -> Dict[Transcript, Fraction]:
    """Return the exact opened-color distribution under all color permutations."""
    if a not in range(3) or b not in range(3) or a == b:
        raise ValueError("a and b must be distinct elements of {0, 1, 2}")
    outcomes = [(perm[a], perm[b]) for perm in permutations(range(3))]
    counts = Counter(outcomes)
    return {pair: Fraction(counts.get(pair, 0), len(outcomes))
            for pair in ((x, y) for x in range(3) for y in range(3))}


def simulator_distribution() -> Dict[Transcript, Fraction]:
    """Return the uniform simulator law on ordered pairs of distinct colors."""
    return {(x, y): Fraction(1, 6) if x != y else Fraction(0, 1)
            for x in range(3) for y in range(3)}


def eval_poly(coefficients: Polynomial, x: int, prime: int) -> int:
    """Evaluate a coefficient-list polynomial modulo a prime via Horner's rule."""
    if prime < 2:
        raise ValueError("prime must be at least 2")
    value = 0
    for coefficient in reversed(coefficients):
        value = (value * x + coefficient) % prime
    return value


def trim_poly(coefficients: Polynomial, prime: int) -> List[int]:
    """Normalize coefficients modulo prime and remove trailing zero terms."""
    result = [coefficient % prime for coefficient in coefficients]
    while len(result) > 1 and result[-1] == 0:
        result.pop()
    return result or [0]


def add_poly(left: Polynomial, right: Polynomial, prime: int) -> List[int]:
    """Add polynomials over the prime field."""
    size = max(len(left), len(right))
    result = [0] * size
    for index in range(size):
        result[index] = ((left[index] if index < len(left) else 0)
                         + (right[index] if index < len(right) else 0)) % prime
    return trim_poly(result, prime)


def sub_poly(left: Polynomial, right: Polynomial, prime: int) -> List[int]:
    """Subtract polynomials over the prime field."""
    size = max(len(left), len(right))
    result = [0] * size
    for index in range(size):
        result[index] = ((left[index] if index < len(left) else 0)
                         - (right[index] if index < len(right) else 0)) % prime
    return trim_poly(result, prime)


def mul_poly(left: Polynomial, right: Polynomial, prime: int) -> List[int]:
    """Multiply polynomials over the prime field by coefficient convolution."""
    result = [0] * (len(left) + len(right) - 1)
    for i, a in enumerate(left):
        for j, b in enumerate(right):
            result[i + j] = (result[i + j] + a * b) % prime
    return trim_poly(result, prime)


def polynomial_degree(coefficients: Polynomial, prime: int) -> int:
    """Return the normalized degree; the zero polynomial is assigned degree 0."""
    return len(trim_poly(coefficients, prime)) - 1


def passing_points(
    p: Polynomial, h: Polynomial, t: Polynomial, prime: int
) -> List[int]:
    """Enumerate field points where p(s) = h(s)t(s)."""
    return [s for s in range(prime)
            if eval_poly(p, s, prime)
            == eval_poly(h, s, prime) * eval_poly(t, s, prime) % prime]


def qap_soundness_audit(
    p: Polynomial, h: Polynomial, t: Polynomial, prime: int
) -> Tuple[List[int], int, Fraction]:
    """Return passing points, discrepancy degree, and exact acceptance rate."""
    discrepancy = sub_poly(p, mul_poly(h, t, prime), prime)
    points = passing_points(p, h, t, prime)
    return points, polynomial_degree(discrepancy, prime), Fraction(len(points), prime)


def first_rejecting_edge(
    edges: Iterable[Edge], coloring: Mapping[int, Color]
) -> Optional[Edge]:
    """Find a monochromatic edge, reading only its two endpoint symbols."""
    for u, v in edges:
        if coloring[u] == coloring[v]:
            return (u, v)
    return None


def rejecting_edges(edges: Iterable[Edge], coloring: Mapping[int, Color]) -> List[Edge]:
    """List all local two-query tests rejected by an alleged coloring."""
    return [(u, v) for u, v in edges if coloring[u] == coloring[v]]


def demo_transcripts() -> None:
    """Print exact real and simulated graph-protocol transcript laws."""
    print("\n=== Perfect graph three-color transcript simulation ===")
    simulated = simulator_distribution()
    for a, b in ((0, 1), (0, 2), (1, 2)):
        real = transcript_distribution(a, b)
        assert real == simulated
        nonzero = {pair: str(prob) for pair, prob in real.items() if prob}
        print(f"actual endpoint colors ({a}, {b}): {nonzero}")
    print("All witness choices give the same uniform law on six distinct pairs.")


def demo_qap() -> None:
    """Print a sharp degree-three random-point soundness example over F_101."""
    print("\n=== Random-point polynomial soundness over F_101 ===")
    prime = 101
    t = [1, 0, 1]             # x^2 + 1
    h = [2, 3]                # 3x + 2
    discrepancy = [0, 2, -3, 1]  # x(x-1)(x-2)
    p = add_poly(mul_poly(h, t, prime), discrepancy, prime)
    points, degree, rate = qap_soundness_audit(p, h, t, prime)
    assert points == [0, 1, 2]
    assert len(points) <= degree
    print(f"discrepancy degree: {degree}")
    print(f"passing points: {points}")
    print(f"false-acceptance rate: {rate} = {float(rate):.6f}")
    print(f"rejection rate: {1 - rate} = {float(1 - rate):.6f}")


def demo_local_verifier() -> None:
    """Show local rejection for an alleged three-coloring of K4."""
    print("\n=== Two-query local verifier on K4 ===")
    vertices = range(4)
    edges = [(u, v) for u in vertices for v in vertices if u < v]
    alleged_coloring = {0: 0, 1: 1, 2: 2, 3: 0}
    bad = rejecting_edges(edges, alleged_coloring)
    first = first_rejecting_edge(edges, alleged_coloring)
    assert first is not None and bad
    print(f"alleged colors: {alleged_coloring}")
    print(f"each edge test reads at most two symbols")
    print(f"rejecting edges: {bad}")
    print(f"first rejecting query: {first}")
    print(f"uniform-edge rejection probability: {len(bad)}/{len(edges)}")


def main() -> None:
    """Run all demonstrations and their consistency assertions."""
    demo_transcripts()
    demo_qap()
    demo_local_verifier()


if __name__ == "__main__":
    main()
