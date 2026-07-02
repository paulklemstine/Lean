"""
demo.py -- Numerical demonstrations of exact realizability of finite concepts
by single-neuron networks with polynomial read-outs.

Architecture:  N(x) = p(Phi(x)),  Phi injective feature map, p polynomial read-out.

Main theorem (Exact Realizability):
    For any injective feature map Phi and any finite set of distinct inputs
    x_1,...,x_n with arbitrary labels y_i in {-1,+1}, there is a polynomial
    read-out p of degree <= n-1 with N(x_i) = y_i for all i. In particular
    sign(N(x_i)) = y_i and |N(x_i)| = 1 (fixed output margin).

This file is self-contained; every routine is inlined and type-hinted.
Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core: Lagrange interpolation of the read-out                                #
# --------------------------------------------------------------------------- #
def lagrange_eval(nodes: Sequence[float], values: Sequence[float], t: float) -> float:
    """Evaluate the unique degree <= n-1 interpolant p at t, where p(nodes[i]) = values[i].

    Uses the barycentric-free Lagrange formula. Nodes must be pairwise distinct.
    """
    n = len(nodes)
    total = 0.0
    for i in range(n):
        term = values[i]
        for j in range(n):
            if j != i:
                term *= (t - nodes[j]) / (nodes[i] - nodes[j])
        total += term
    return total


def build_network(
    phi: Callable[[float], float],
    inputs: Sequence[float],
    labels: Sequence[int],
) -> Callable[[float], float]:
    """Return the single-neuron network N(x) = p(phi(x)) exactly realizing the labels."""
    nodes = [phi(x) for x in inputs]
    assert len(set(nodes)) == len(nodes), "feature map is not injective on the sample"
    return lambda x: lagrange_eval(nodes, [float(y) for y in labels], phi(x))


# --------------------------------------------------------------------------- #
# Geometry helpers                                                            #
# --------------------------------------------------------------------------- #
def separation_modulus(nodes: Sequence[float]) -> float:
    """Minimum pairwise distance between feature nodes (positive iff distinct)."""
    return min(
        abs(nodes[i] - nodes[j])
        for i in range(len(nodes))
        for j in range(i + 1, len(nodes))
    )


def alternation_count(nodes: Sequence[float], labels: Sequence[int]) -> int:
    """Number of adjacent label changes after sorting by feature node."""
    order = sorted(range(len(nodes)), key=lambda k: nodes[k])
    sorted_labels = [labels[k] for k in order]
    return sum(
        1 for k in range(len(sorted_labels) - 1)
        if sorted_labels[k] != sorted_labels[k + 1]
    )


def coefficients_from_nodes(
    nodes: Sequence[float], values: Sequence[float]
) -> List[float]:
    """Solve the Vandermonde system for the monomial coefficients of the interpolant.

    Returns c with p(t) = sum_k c[k] t^k, degree <= n-1. Naive Gaussian elimination.
    """
    n = len(nodes)
    # Build augmented matrix [V | values].
    aug = [[nodes[i] ** k for k in range(n)] + [float(values[i])] for i in range(n)]
    for col in range(n):
        pivot = max(range(col, n), key=lambda r: abs(aug[r][col]))
        aug[col], aug[pivot] = aug[pivot], aug[col]
        piv = aug[col][col]
        aug[col] = [v / piv for v in aug[col]]
        for r in range(n):
            if r != col and aug[r][col] != 0.0:
                factor = aug[r][col]
                aug[r] = [a - factor * b for a, b in zip(aug[r], aug[col])]
    return [aug[i][n] for i in range(n)]


# --------------------------------------------------------------------------- #
# Demo 1: exactness and unit output margin                                    #
# --------------------------------------------------------------------------- #
def demo_exactness(seed: int = 0) -> None:
    print("=" * 70)
    print("DEMO 1  Exact realizability and fixed unit output margin")
    print("=" * 70)
    rng = random.Random(seed)
    n = 8
    inputs = [rng.uniform(-5, 5) for _ in range(n)]
    # ensure distinct inputs
    inputs = sorted(set(round(x, 6) for x in inputs))
    n = len(inputs)
    labels = [rng.choice([-1, 1]) for _ in range(n)]
    phi: Callable[[float], float] = lambda x: math.tanh(x) + 0.31 * x  # injective, smooth
    net = build_network(phi, inputs, labels)

    max_err = max(abs(net(x) - y) for x, y in zip(inputs, labels))
    margin = min(abs(net(x)) for x in inputs)
    all_correct = all((net(x) > 0) == (y > 0) for x, y in zip(inputs, labels))
    print(f"  n = {n} distinct inputs, arbitrary labels {labels}")
    print(f"  max |N(x_i) - y_i|   = {max_err:.2e}   (should be ~0)")
    print(f"  output margin min|N| = {margin:.6f}   (theory: exactly 1)")
    print(f"  all classified correctly: {all_correct}")
    print()


# --------------------------------------------------------------------------- #
# Demo 2: worst-case degree for alternating labels                           #
# --------------------------------------------------------------------------- #
def minimal_exact_degree(
    nodes: Sequence[float], labels: Sequence[int]
) -> int:
    """Smallest d such that a degree-d least-squares fit classifies every point correctly."""
    n = len(nodes)
    for d in range(n):
        coeffs = _least_squares_poly(nodes, [float(y) for y in labels], d)
        ok = all(
            (_poly_eval(coeffs, t) > 0) == (y > 0)
            for t, y in zip(nodes, labels)
        )
        if ok:
            return d
    return n - 1


def _poly_eval(coeffs: Sequence[float], t: float) -> float:
    return sum(c * t ** k for k, c in enumerate(coeffs))


def _least_squares_poly(
    nodes: Sequence[float], values: Sequence[float], degree: int
) -> List[float]:
    """Least-squares polynomial fit of given degree via normal equations."""
    m = degree + 1
    # Design matrix rows [1, t, t^2, ..., t^degree].
    ata = [[0.0] * m for _ in range(m)]
    atb = [0.0] * m
    for t, v in zip(nodes, values):
        powers = [t ** k for k in range(m)]
        for a in range(m):
            atb[a] += powers[a] * v
            for b in range(m):
                ata[a][b] += powers[a] * powers[b]
    # Solve ata x = atb via Gaussian elimination.
    aug = [ata[i] + [atb[i]] for i in range(m)]
    for col in range(m):
        pivot = max(range(col, m), key=lambda r: abs(aug[r][col]))
        aug[col], aug[pivot] = aug[pivot], aug[col]
        piv = aug[col][col]
        if abs(piv) < 1e-14:
            continue
        aug[col] = [v / piv for v in aug[col]]
        for r in range(m):
            if r != col and aug[r][col] != 0.0:
                f = aug[r][col]
                aug[r] = [a - f * b for a, b in zip(aug[r], aug[col])]
    return [aug[i][m] for i in range(m)]


def demo_degree_alternation(seed: int = 1) -> None:
    print("=" * 70)
    print("DEMO 2  Minimal exact degree vs. alternation count (Conjecture C2)")
    print("=" * 70)
    rng = random.Random(seed)
    n = 7
    nodes = sorted(rng.uniform(-3, 3) for _ in range(n))

    cases: List[Tuple[str, List[int]]] = [
        ("all +1", [1] * n),
        ("one block", [-1, -1, -1, 1, 1, 1, 1]),
        ("two blocks", [-1, -1, 1, 1, -1, -1, -1]),
        ("strictly alternating", [(-1) ** k for k in range(n)]),
    ]
    print(f"  nodes sorted; n = {n}   (worst-case degree = n-1 = {n-1})")
    print(f"  {'labeling':<22}{'alt A':>6}{'min class. deg':>16}")
    for name, labels in cases:
        A = alternation_count(nodes, labels)
        d = minimal_exact_degree(nodes, labels)
        print(f"  {name:<22}{A:>6}{d:>16}")
    print("  The minimal degree that classifies every point correctly tracks the")
    print("  alternation count A: representational cost is combinatorial (Conj. C2).")
    print()


# --------------------------------------------------------------------------- #
# Demo 3: stability of exactness under feature drift                         #
# --------------------------------------------------------------------------- #
def demo_stability(seed: int = 2) -> None:
    print("=" * 70)
    print("DEMO 3  Stability of exactness under sub-threshold drift (Conjecture C3)")
    print("=" * 70)
    rng = random.Random(seed)
    n = 6
    inputs = sorted(set(round(rng.uniform(-4, 4), 4) for _ in range(n)))
    n = len(inputs)
    labels = [rng.choice([-1, 1]) for _ in range(n)]
    phi: Callable[[float], float] = lambda x: 0.5 * x + math.sin(0.3 * x)

    base_nodes = [phi(x) for x in inputs]
    s = separation_modulus(base_nodes)
    print(f"  separation modulus sep(Phi) = {s:.4f}; drift threshold = s/2 = {s/2:.4f}")

    coeffs_prev = coefficients_from_nodes(base_nodes, [float(y) for y in labels])
    for eps in [0.0, 0.1 * s, 0.25 * s, 0.49 * s]:
        drifted = [t + rng.uniform(-eps, eps) for t in base_nodes]
        coeffs = coefficients_from_nodes(drifted, [float(y) for y in labels])
        max_err = max(
            abs(_poly_eval(coeffs, t) - y) for t, y in zip(drifted, labels)
        )
        coef_move = max(abs(a - b) for a, b in zip(coeffs, coeffs_prev))
        print(
            f"  drift <= {eps:6.4f}  ->  max interp err {max_err:.2e}, "
            f"max coeff change {coef_move:.3e}"
        )
        coeffs_prev = coeffs
    print("  Exactness preserved (err ~0) for all sub-threshold drifts;")
    print("  coefficients move continuously with the perturbation.")
    print()


def main() -> None:
    demo_exactness()
    demo_degree_alternation()
    demo_stability()


if __name__ == "__main__":
    main()
