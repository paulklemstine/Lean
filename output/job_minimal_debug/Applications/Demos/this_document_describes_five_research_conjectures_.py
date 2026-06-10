#!/usr/bin/env python3
"""
Numerical demonstrations of certified robustness for IRV classifiers.

Implements the key definitions and theorems from the formalization in
Catalog/Bridges/IRVStability.lean, including:

  - Sequential elimination (IRV) winner computation
  - Gap certificate computation
  - Certified robustness radius under Lipschitz score maps
  - Monte Carlo verification of the robustness guarantee
"""

from __future__ import annotations

import math
import random
from typing import Callable


# ── Core IRV Definitions ─────────────────────────────────────────────


def round_loser(scores: dict[int, float]) -> int:
    """Return the candidate with the minimum score (ties broken by index)."""
    return min(scores, key=lambda k: (scores[k], k))


def irv_elimination_order(scores: dict[int, float]) -> list[int]:
    """
    Compute the full elimination order for IRV.

    Returns a list [first_eliminated, ..., winner].
    Mirrors `eliminationOrderOn` from the Lean formalization.
    """
    active: dict[int, float] = dict(scores)
    order: list[int] = []
    while len(active) > 1:
        loser: int = round_loser(active)
        order.append(loser)
        del active[loser]
    order.append(next(iter(active)))
    return order


def irv_winner(scores: dict[int, float]) -> int:
    """Return the IRV winner (last survivor of sequential elimination)."""
    return irv_elimination_order(scores)[-1]


# ── Gap Certificate ──────────────────────────────────────────────────


def compute_round_gap(scores: dict[int, float]) -> tuple[int, float]:
    """
    Compute the round loser and the gap to the next-lowest scorer.

    Mirrors `HasGapAtLeast` from the Lean formalization.
    Returns (loser_id, gap).
    """
    loser: int = round_loser(scores)
    loser_score: float = scores[loser]
    others: list[float] = [v for k, v in scores.items() if k != loser]
    gap: float = min(others) - loser_score if others else math.inf
    return loser, gap


def compute_gap_certificate(scores: dict[int, float]) -> float:
    """
    Compute the minimum gap across all elimination rounds.

    This is the largest γ for which `EliminationGapCertified` holds.
    Mirrors the recursive definition from the Lean formalization.
    """
    active: dict[int, float] = dict(scores)
    min_gap: float = math.inf
    while len(active) > 1:
        loser, gap = compute_round_gap(active)
        min_gap = min(min_gap, gap)
        del active[loser]
    return min_gap


# ── Certified Robustness ─────────────────────────────────────────────


def certified_radius(gamma: float, lipschitz_k: float) -> float:
    """
    Compute the certified L∞ robustness radius.

    From `irvWinner_certified_robust`: winner is stable for any
    perturbation r satisfying 2·K·r < γ, so the certified radius
    is γ / (2K).
    """
    if lipschitz_k <= 0.0:
        return math.inf
    return gamma / (2.0 * lipschitz_k)


# ── Perturbation Verification ────────────────────────────────────────


def verify_gap_preservation(
    scores: dict[int, float],
    perturbed: dict[int, float],
    epsilon: float,
) -> dict[str, object]:
    """
    Verify the gap preservation lemma numerically.

    Checks that if the original gap is γ, then the perturbed gap
    is at least γ - 2ε, matching `gap_preserved_under_perturbation`.
    """
    _, original_gap = compute_round_gap(scores)
    _, perturbed_gap = compute_round_gap(perturbed)
    predicted_lower_bound: float = original_gap - 2.0 * epsilon
    return {
        "original_gap": original_gap,
        "perturbed_gap": perturbed_gap,
        "predicted_lower_bound": predicted_lower_bound,
        "bound_holds": perturbed_gap >= predicted_lower_bound - 1e-12,
    }


def monte_carlo_robustness_test(
    scores: dict[int, float],
    epsilon: float,
    num_trials: int = 10000,
    seed: int = 42,
) -> dict[str, object]:
    """
    Monte Carlo test of the robustness guarantee.

    Generates random perturbations within L∞-ball of radius ε and
    checks that the IRV winner is preserved whenever 2ε < γ.
    """
    rng = random.Random(seed)
    original_winner: int = irv_winner(scores)
    gamma: float = compute_gap_certificate(scores)
    certified: bool = 2.0 * epsilon < gamma
    flips: int = 0

    for _ in range(num_trials):
        perturbed: dict[int, float] = {
            k: v + rng.uniform(-epsilon, epsilon) for k, v in scores.items()
        }
        if irv_winner(perturbed) != original_winner:
            flips += 1

    return {
        "original_winner": original_winner,
        "gamma": gamma,
        "epsilon": epsilon,
        "certified": certified,
        "num_trials": num_trials,
        "flips": flips,
        "flip_rate": flips / num_trials,
        "guarantee_met": flips == 0 if certified else True,
    }


# ── Tropical Score Function Demo ─────────────────────────────────────


def tropical_matmul(a: list[list[float]], b: list[float]) -> list[float]:
    """Max-plus matrix-vector product: (A ⊕ x)_i = max_j (A[i][j] + x[j])."""
    return [max(a[i][j] + b[j] for j in range(len(b))) for i in range(len(a))]


def tropical_score(
    w1: list[list[float]],
    w2: list[list[float]],
    x: list[float],
) -> list[float]:
    """Two-layer tropical (max-plus) neural network score function."""
    hidden: list[float] = tropical_matmul(w1, x)
    return tropical_matmul(w2, hidden)


def tropical_lipschitz(
    w1: list[list[float]], w2: list[list[float]]
) -> float:
    """
    Compute L∞ Lipschitz constant of a two-layer tropical network.

    K = max_i sum_j max_k (W2[i][k] + W1[k][j])  ... but simplified
    to the max row-sum of the composed weight matrix.
    """
    n: int = len(w1)
    d: int = len(w1[0]) if w1 else 0
    m: int = len(w2)
    # Tropical composition: C[i][j] = max_k (W2[i][k] + W1[k][j])
    c: list[list[float]] = [
        [max(w2[i][k] + w1[k][j] for k in range(n)) for j in range(d)]
        for i in range(m)
    ]
    # L∞→L∞ operator norm = max row sum (of exp, but for tropical = max row max)
    return max(max(row) for row in c)


# ── Demo Runners ─────────────────────────────────────────────────────


def demo_basic_irv() -> None:
    """Demo 1: Basic IRV elimination and gap certificate."""
    print("=" * 65)
    print("DEMO 1: Basic IRV Elimination and Gap Certificate")
    print("=" * 65)

    scores: dict[int, float] = {0: 1.0, 1: 3.5, 2: 2.0, 3: 5.0, 4: 4.2}
    print(f"\nCandidate scores: {scores}")

    order: list[int] = irv_elimination_order(scores)
    print(f"Elimination order: {order}")
    print(f"Winner: {order[-1]}")

    gamma: float = compute_gap_certificate(scores)
    print(f"Minimum gap (γ): {gamma}")
    print(f"Certified ε-robustness for any ε < γ/2 = {gamma / 2}")

    # Show round-by-round gaps
    active: dict[int, float] = dict(scores)
    print("\nRound-by-round breakdown:")
    rnd: int = 1
    while len(active) > 1:
        loser, gap = compute_round_gap(active)
        print(f"  Round {rnd}: loser={loser} (score={active[loser]:.1f}), gap={gap:.1f}")
        del active[loser]
        rnd += 1
    print()


def demo_perturbation_lemma() -> None:
    """Demo 2: Verify the gap preservation lemma numerically."""
    print("=" * 65)
    print("DEMO 2: Gap Preservation Under Perturbation")
    print("=" * 65)

    scores: dict[int, float] = {0: 1.0, 1: 4.0, 2: 2.5}
    epsilon: float = 0.3
    perturbed: dict[int, float] = {
        0: 1.0 + 0.25,  # shifted up by 0.25
        1: 4.0 - 0.30,  # shifted down by 0.30
        2: 2.5 + 0.10,  # shifted up by 0.10
    }

    print(f"\nOriginal scores:  {scores}")
    print(f"Perturbed scores: {perturbed}")
    print(f"Max perturbation ε = {epsilon}")

    result: dict[str, object] = verify_gap_preservation(scores, perturbed, epsilon)
    print(f"\nOriginal gap:          {result['original_gap']}")
    print(f"Perturbed gap:         {result['perturbed_gap']}")
    print(f"Predicted lower bound: {result['predicted_lower_bound']} (= γ - 2ε)")
    print(f"Bound holds:           {result['bound_holds']}")
    print()


def demo_monte_carlo() -> None:
    """Demo 3: Monte Carlo robustness verification."""
    print("=" * 65)
    print("DEMO 3: Monte Carlo Robustness Verification")
    print("=" * 65)

    scores: dict[int, float] = {0: 1.0, 1: 3.5, 2: 2.0, 3: 5.0, 4: 4.2}
    gamma: float = compute_gap_certificate(scores)

    # Test within certified radius
    eps_safe: float = gamma / 2.0 - 0.01
    result_safe: dict[str, object] = monte_carlo_robustness_test(scores, eps_safe)
    print(f"\nScores: {scores}")
    print(f"Minimum gap γ = {gamma}")
    print(f"\n--- Within certified radius (ε = {eps_safe:.3f}, 2ε < γ) ---")
    print(f"  Winner preserved: {result_safe['flips'] == 0} ({result_safe['flips']}/{result_safe['num_trials']} flips)")
    print(f"  Guarantee met: {result_safe['guarantee_met']}")

    # Test beyond certified radius
    eps_unsafe: float = gamma / 2.0 + 0.3
    result_unsafe: dict[str, object] = monte_carlo_robustness_test(scores, eps_unsafe)
    print(f"\n--- Beyond certified radius (ε = {eps_unsafe:.3f}, 2ε > γ) ---")
    print(f"  Flips: {result_unsafe['flips']}/{result_unsafe['num_trials']}")
    print(f"  Flip rate: {result_unsafe['flip_rate']:.4f}")
    print()


def demo_tropical_robustness() -> None:
    """Demo 4: Full tropical classifier robustness certificate."""
    print("=" * 65)
    print("DEMO 4: Tropical Classifier Certified Robustness")
    print("=" * 65)

    # Two-layer tropical network: 3 inputs → 4 hidden → 5 classes
    w1: list[list[float]] = [
        [0.5, -0.2, 0.8],
        [-0.1, 0.6, 0.3],
        [0.4, 0.4, -0.5],
        [0.2, -0.3, 0.7],
    ]
    w2: list[list[float]] = [
        [0.3, -0.1, 0.5, 0.2],
        [-0.2, 0.4, 0.1, 0.6],
        [0.1, 0.3, -0.2, 0.4],
        [0.6, 0.2, 0.3, -0.1],
        [-0.3, 0.5, 0.4, 0.1],
    ]
    x: list[float] = [1.0, 0.5, -0.3]

    scores_vec: list[float] = tropical_score(w1, w2, x)
    scores_dict: dict[int, float] = {i: s for i, s in enumerate(scores_vec)}
    k: float = tropical_lipschitz(w1, w2)
    gamma: float = compute_gap_certificate(scores_dict)
    radius: float = certified_radius(gamma, k)

    print(f"\nInput x = {x}")
    print(f"Tropical scores: {[f'{s:.3f}' for s in scores_vec]}")
    print(f"IRV winner: class {irv_winner(scores_dict)}")
    print(f"Minimum gap γ = {gamma:.4f}")
    print(f"Lipschitz constant K = {k:.4f}")
    print(f"Certified L∞ radius r* = γ/(2K) = {radius:.4f}")

    # Verify with Monte Carlo
    n_trials: int = 5000
    rng = random.Random(123)
    flips: int = 0
    orig_winner: int = irv_winner(scores_dict)

    for _ in range(n_trials):
        x_pert: list[float] = [
            xi + rng.uniform(-radius * 0.99, radius * 0.99) for xi in x
        ]
        pert_scores: list[float] = tropical_score(w1, w2, x_pert)
        pert_dict: dict[int, float] = {i: s for i, s in enumerate(pert_scores)}
        if irv_winner(pert_dict) != orig_winner:
            flips += 1

    print(f"\nMonte Carlo verification ({n_trials} trials within 0.99·r*):")
    print(f"  Flips: {flips}/{n_trials} (expected: 0)")
    print()


def demo_election_audit() -> None:
    """Demo 5: Election audit scenario."""
    print("=" * 65)
    print("DEMO 5: Election Audit — Is a Recount Needed?")
    print("=" * 65)

    # Simulated ranked-choice election with 6 candidates
    # Scores represent (negative of) first-preference vote counts
    # (lower score = fewer votes = eliminated first)
    vote_counts: dict[str, int] = {
        "Alice": 4521,
        "Bob": 3890,
        "Carol": 5102,
        "Dave": 2145,
        "Eve": 4730,
        "Frank": 3210,
    }
    # IRV uses -votes as scores (eliminate lowest vote-getter)
    scores: dict[int, float] = {
        i: float(-v) for i, (_, v) in enumerate(vote_counts.items())
    }
    names: list[str] = list(vote_counts.keys())

    order: list[int] = irv_elimination_order(scores)
    gamma: float = compute_gap_certificate(scores)
    max_error: float = 50.0  # maximum plausible tabulation error per candidate

    print(f"\nVote counts: {vote_counts}")
    print(f"Elimination order: {[names[i] for i in order]}")
    print(f"Winner: {names[order[-1]]}")
    print(f"Minimum gap γ = {gamma} votes")
    print(f"Max tabulation error ε = {max_error} votes")
    print(f"2ε = {2 * max_error}")
    print(f"Certified (2ε < γ)? {'YES ✓' if 2 * max_error < gamma else 'NO ✗ — recount recommended'}")
    print()


if __name__ == "__main__":
    demo_basic_irv()
    demo_perturbation_lemma()
    demo_monte_carlo()
    demo_tropical_robustness()
    demo_election_audit()
