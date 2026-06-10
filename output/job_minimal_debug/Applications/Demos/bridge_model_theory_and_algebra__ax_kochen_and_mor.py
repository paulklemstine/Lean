#!/usr/bin/env python3
"""
Numerical demonstrations of certified robustness for IRV classifiers.

Demonstrates the key results from the formal development:
  1. IRV elimination procedure
  2. Gap certificate computation
  3. One-round perturbation lemma (gap erosion by 2ε)
  4. Elimination-order stability under bounded perturbation
  5. Certified robustness radius for Lipschitz score functions

All functions are self-contained with type hints.
"""

from __future__ import annotations
import random
import math


# ─── Core IRV Elimination ────────────────────────────────────────────────

def irv_eliminate(scores: dict[int, float]) -> list[int]:
    """
    Run instant-runoff elimination on a score dictionary.
    Returns the elimination order: [first_eliminated, ..., winner].

    >>> irv_eliminate({0: 1.0, 1: 3.5, 2: 2.0, 3: 5.0})
    [0, 2, 1, 3]
    """
    active: dict[int, float] = dict(scores)
    order: list[int] = []
    while len(active) > 1:
        loser: int = min(active, key=lambda k: active[k])
        order.append(loser)
        del active[loser]
    # Last remaining candidate is the winner
    order.append(next(iter(active)))
    return order


def irv_winner(scores: dict[int, float]) -> int:
    """Return the IRV winner (last survivor of elimination)."""
    return irv_eliminate(scores)[-1]


# ─── Gap Certificate ─────────────────────────────────────────────────────

def compute_round_gaps(scores: dict[int, float]) -> list[tuple[int, float]]:
    """
    Compute the gap at each elimination round.
    Returns a list of (loser, gap) pairs.

    The gap is the difference between the second-minimum and the minimum
    score among active candidates at that round.
    """
    active: dict[int, float] = dict(scores)
    gaps: list[tuple[int, float]] = []
    while len(active) > 1:
        sorted_vals: list[tuple[int, float]] = sorted(active.items(), key=lambda x: x[1])
        loser_id, loser_score = sorted_vals[0]
        second_score: float = sorted_vals[1][1]
        gap: float = second_score - loser_score
        gaps.append((loser_id, gap))
        del active[loser_id]
    return gaps


def min_gap(scores: dict[int, float]) -> float:
    """Compute the minimum gap across all elimination rounds."""
    gaps: list[tuple[int, float]] = compute_round_gaps(scores)
    return min(g for _, g in gaps) if gaps else float("inf")


# ─── Perturbation Lemma Demonstration ────────────────────────────────────

def demonstrate_gap_erosion(
    scores: dict[int, float],
    epsilon: float,
    num_trials: int = 10000,
) -> dict[str, float]:
    """
    Empirically verify the gap erosion bound: gap shrinks by at most 2ε.

    Generates random perturbations of size ≤ ε and measures the minimum
    gap of the perturbed scores. Compares with the theoretical prediction.
    """
    original_gap: float = min_gap(scores)
    theoretical_lower_bound: float = original_gap - 2 * epsilon

    worst_gap: float = float("inf")
    for _ in range(num_trials):
        perturbed: dict[int, float] = {
            k: v + random.uniform(-epsilon, epsilon)
            for k, v in scores.items()
        }
        g: float = min_gap(perturbed)
        worst_gap = min(worst_gap, g)

    return {
        "original_gap": original_gap,
        "theoretical_lower_bound": theoretical_lower_bound,
        "empirical_worst_gap": worst_gap,
        "bound_holds": worst_gap >= theoretical_lower_bound - 1e-12,
    }


# ─── Stability Demonstration ────────────────────────────────────────────

def demonstrate_stability(
    scores: dict[int, float],
    epsilon: float,
    num_trials: int = 10000,
) -> dict[str, object]:
    """
    Verify elimination-order stability: if 2ε < γ, the elimination
    order is preserved under all perturbations of size ≤ ε.
    """
    gamma: float = min_gap(scores)
    original_order: list[int] = irv_eliminate(scores)
    condition_met: bool = 2 * epsilon < gamma

    violations: int = 0
    for _ in range(num_trials):
        perturbed: dict[int, float] = {
            k: v + random.uniform(-epsilon, epsilon)
            for k, v in scores.items()
        }
        perturbed_order: list[int] = irv_eliminate(perturbed)
        if perturbed_order != original_order:
            violations += 1

    return {
        "gamma": gamma,
        "epsilon": epsilon,
        "2eps_lt_gamma": condition_met,
        "original_order": original_order,
        "violations": violations,
        "num_trials": num_trials,
        "stability_verified": violations == 0 if condition_met else True,
    }


# ─── Certified Robustness Radius ─────────────────────────────────────────

def certified_radius(
    scores: dict[int, float],
    lipschitz_K: float,
) -> float:
    """
    Compute the certified robustness radius for an IRV classifier.

    For a K-Lipschitz score function with gap certificate γ,
    the certified radius is γ / (2K).
    """
    gamma: float = min_gap(scores)
    if lipschitz_K <= 0:
        return float("inf") if gamma > 0 else 0.0
    return gamma / (2 * lipschitz_K)


def demonstrate_lipschitz_robustness(
    d: int = 5,
    m: int = 4,
    lipschitz_K: float = 2.0,
    num_trials: int = 10000,
) -> dict[str, object]:
    """
    End-to-end demonstration: random linear score function (K-Lipschitz),
    compute certified radius, verify no perturbation within radius
    changes the IRV winner.
    """
    # Random weight matrix (each row has L1 norm ≤ K for L∞→L∞ Lipschitz)
    W: list[list[float]] = []
    for _ in range(m):
        raw: list[float] = [random.gauss(0, 1) for _ in range(d)]
        norm: float = sum(abs(r) for r in raw)
        scale: float = lipschitz_K / norm if norm > 0 else 0.0
        W.append([r * scale for r in raw])

    bias: list[float] = [random.uniform(-1, 1) for _ in range(m)]

    def score_fn(x: list[float]) -> dict[int, float]:
        return {
            i: sum(W[i][j] * x[j] for j in range(d)) + bias[i]
            for i in range(m)
        }

    # Random input
    x0: list[float] = [random.uniform(-1, 1) for _ in range(d)]
    scores0: dict[int, float] = score_fn(x0)
    original_winner: int = irv_winner(scores0)
    radius: float = certified_radius(scores0, lipschitz_K)

    # Test perturbations within certified radius
    violations: int = 0
    for _ in range(num_trials):
        r: float = radius * 0.99  # Stay strictly inside
        x_pert: list[float] = [
            xi + random.uniform(-r, r) for xi in x0
        ]
        if irv_winner(score_fn(x_pert)) != original_winner:
            violations += 1

    return {
        "input_dim": d,
        "num_classes": m,
        "lipschitz_K": lipschitz_K,
        "min_gap_gamma": min_gap(scores0),
        "certified_radius": radius,
        "original_winner": original_winner,
        "perturbation_violations": violations,
        "num_trials": num_trials,
    }


# ─── Tropical Score Function Example ────────────────────────────────────

def tropical_score(
    weights: list[list[list[float]]],
    x: list[float],
) -> dict[int, float]:
    """
    Compute tropical polynomial scores: s_i(x) = max_j (a_{i,j} + <w_{i,j}, x>).

    weights[i][j] = [a_{i,j}, w_{i,j,0}, ..., w_{i,j,d-1}]
    """
    m: int = len(weights)
    scores: dict[int, float] = {}
    for i in range(m):
        terms: list[float] = []
        for coeff_and_w in weights[i]:
            a: float = coeff_and_w[0]
            w: list[float] = coeff_and_w[1:]
            terms.append(a + sum(wk * xk for wk, xk in zip(w, x)))
        scores[i] = max(terms)
    return scores


def demonstrate_tropical_irv() -> dict[str, object]:
    """
    Demonstrate IRV classification with tropical polynomial scores
    in 2D input space.
    """
    # 3 classes, each with 2 tropical terms, 2D input
    weights: list[list[list[float]]] = [
        [[0.0, 1.0, 0.5], [1.0, -0.5, 1.0]],   # class 0
        [[0.5, 0.0, 1.5], [-0.5, 1.0, 0.0]],    # class 1
        [[-0.3, 0.8, -0.2], [0.7, -0.3, 0.8]],  # class 2
    ]

    x: list[float] = [0.5, 0.3]
    scores: dict[int, float] = tropical_score(weights, x)
    order: list[int] = irv_eliminate(scores)
    gamma: float = min_gap(scores)

    # Compute Lipschitz constant: max over all terms of L1 norm of weight
    K: float = 0.0
    for class_terms in weights:
        for coeff_and_w in class_terms:
            w: list[float] = coeff_and_w[1:]
            K = max(K, sum(abs(wk) for wk in w))

    radius: float = gamma / (2 * K) if K > 0 else float("inf")

    return {
        "input": x,
        "scores": scores,
        "elimination_order": order,
        "winner": order[-1],
        "min_gap": gamma,
        "lipschitz_K": K,
        "certified_radius": radius,
    }


# ─── Main ────────────────────────────────────────────────────────────────

def main() -> None:
    random.seed(42)

    print("=" * 70)
    print("DEMO 1: Basic IRV Elimination")
    print("=" * 70)
    scores1: dict[int, float] = {0: 1.0, 1: 3.5, 2: 2.0, 3: 5.0, 4: 4.2}
    order1: list[int] = irv_eliminate(scores1)
    gaps1: list[tuple[int, float]] = compute_round_gaps(scores1)
    print(f"  Scores:            {scores1}")
    print(f"  Elimination order: {order1}")
    print(f"  Round gaps:        {gaps1}")
    print(f"  Min gap (γ):       {min_gap(scores1):.4f}")
    print(f"  Winner:            {order1[-1]}")
    print()

    print("=" * 70)
    print("DEMO 2: Gap Erosion Under Perturbation (Theorem 1)")
    print("=" * 70)
    scores2: dict[int, float] = {0: 0.0, 1: 2.0, 2: 3.5, 3: 6.0}
    for eps in [0.1, 0.3, 0.5, 0.8]:
        result = demonstrate_gap_erosion(scores2, eps, num_trials=50000)
        print(f"  ε = {eps:.1f}: "
              f"original γ = {result['original_gap']:.2f}, "
              f"theoretical lower = {result['theoretical_lower_bound']:.2f}, "
              f"empirical worst = {result['empirical_worst_gap']:.4f}, "
              f"bound holds: {result['bound_holds']}")
    print()

    print("=" * 70)
    print("DEMO 3: Elimination-Order Stability (Theorem 2)")
    print("=" * 70)
    scores3: dict[int, float] = {0: 1.0, 1: 3.0, 2: 5.5, 3: 8.0}
    gamma3: float = min_gap(scores3)
    print(f"  Scores: {scores3}")
    print(f"  Min gap (γ): {gamma3:.2f}")
    print(f"  Critical ε = γ/2 = {gamma3/2:.2f}")
    print()
    for eps in [0.5, 0.9, 0.99, 1.01, 1.5]:
        result = demonstrate_stability(scores3, eps, num_trials=20000)
        status = "STABLE" if result["violations"] == 0 else f"UNSTABLE ({result['violations']} violations)"
        cond = "2ε < γ ✓" if result["2eps_lt_gamma"] else "2ε ≥ γ ✗"
        print(f"  ε = {eps:.2f}: {cond} → {status}")
    print()

    print("=" * 70)
    print("DEMO 4: Certified Robustness Radius (Theorem 4)")
    print("=" * 70)
    result4 = demonstrate_lipschitz_robustness(d=5, m=4, lipschitz_K=2.0)
    print(f"  Input dimension:      {result4['input_dim']}")
    print(f"  Number of classes:    {result4['num_classes']}")
    print(f"  Lipschitz constant K: {result4['lipschitz_K']}")
    print(f"  Min gap γ:            {result4['min_gap_gamma']:.6f}")
    print(f"  Certified radius:     {result4['certified_radius']:.6f}")
    print(f"  Original winner:      {result4['original_winner']}")
    print(f"  Violations in {result4['num_trials']} trials within radius: "
          f"{result4['perturbation_violations']}")
    print()

    print("=" * 70)
    print("DEMO 5: Tropical Score Function IRV")
    print("=" * 70)
    result5 = demonstrate_tropical_irv()
    print(f"  Input:             {result5['input']}")
    print(f"  Tropical scores:   {result5['scores']}")
    print(f"  Elimination order: {result5['elimination_order']}")
    print(f"  Winner:            {result5['winner']}")
    print(f"  Min gap (γ):       {result5['min_gap']:.4f}")
    print(f"  Lipschitz K:       {result5['lipschitz_K']:.4f}")
    print(f"  Certified radius:  {result5['certified_radius']:.6f}")
    print()

    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()
