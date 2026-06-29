#!/usr/bin/env python3
"""
Numerical demonstrations of certified robustness for IRV classifiers.

This module implements the core definitions from the formalized framework
(gap certificates, IRV elimination, robustness radii) and demonstrates
them on concrete examples.

All functions are self-contained — no external dependencies beyond the
Python standard library.
"""

from __future__ import annotations
import math
from typing import Optional


# ──────────────────────────────────────────────────────────────────────
#  Core IRV Engine
# ──────────────────────────────────────────────────────────────────────

def round_loser(active: list[int], scores: list[float]) -> int:
    """Return the index of the active candidate with the lowest score."""
    return min(active, key=lambda i: scores[i])


def irv_elimination_order(
    active: list[int], scores: list[float]
) -> list[int]:
    """
    Compute the full IRV elimination order.

    Returns a list [first_eliminated, second_eliminated, ..., winner].
    Mirrors `eliminationOrderOn` from the Lean formalization.
    """
    active = list(active)
    order: list[int] = []
    while len(active) > 1:
        loser = round_loser(active, scores)
        order.append(loser)
        active.remove(loser)
    order.append(active[0])
    return order


def irv_winner(active: list[int], scores: list[float]) -> int:
    """
    Compute the IRV winner on a given active set.
    Mirrors `irvWinnerOn` from the Lean formalization.
    """
    return irv_elimination_order(active, scores)[-1]


# ──────────────────────────────────────────────────────────────────────
#  Gap Certificate Computation
# ──────────────────────────────────────────────────────────────────────

def has_gap_at_least(
    active: list[int], scores: list[float], candidate: int, gamma: float
) -> bool:
    """
    Check whether `candidate` has gap at least γ in `active` under `scores`.
    Mirrors `HasGapAtLeast` from the Lean formalization.
    """
    if candidate not in active:
        return False
    for j in active:
        if j != candidate and scores[candidate] + gamma > scores[j]:
            return False
    return True


def compute_gap(active: list[int], scores: list[float], loser: int) -> float:
    """Compute the actual gap for a given loser: min_{j ≠ loser} (scores[j] - scores[loser])."""
    return min(scores[j] - scores[loser] for j in active if j != loser)


def elimination_gap_certificate(
    active: list[int], scores: list[float]
) -> float:
    """
    Compute the minimum gap across all elimination rounds.

    This is the largest γ for which `EliminationGapCertified` holds.
    A larger value means the elimination is more robust.
    """
    active = list(active)
    min_gap = float("inf")
    while len(active) > 1:
        loser = round_loser(active, scores)
        gap = compute_gap(active, scores, loser)
        min_gap = min(min_gap, gap)
        active.remove(loser)
    return min_gap


def certified_robustness_radius(
    active: list[int],
    scores: list[float],
    lipschitz_K: float = 1.0,
) -> float:
    """
    Compute the certified robustness radius γ / (2K).

    For score perturbations (K=1), this is γ/2.
    For input perturbations with Lipschitz constant K, this is γ/(2K).
    Mirrors `irvWinner_certified_robust` from the Lean formalization.
    """
    gamma = elimination_gap_certificate(active, scores)
    if lipschitz_K <= 0:
        return float("inf")
    return gamma / (2.0 * lipschitz_K)


# ──────────────────────────────────────────────────────────────────────
#  Perturbation Verification
# ──────────────────────────────────────────────────────────────────────

def gap_after_perturbation(
    gamma: float, epsilon: float
) -> float:
    """
    Residual gap after perturbation.
    Mirrors `gap_preserved_under_perturbation`: residual = γ − 2ε.
    """
    return gamma - 2.0 * epsilon


def verify_stability(
    active: list[int],
    original_scores: list[float],
    perturbed_scores: list[float],
) -> dict[str, object]:
    """
    Verify whether the IRV winner is preserved under a given perturbation.
    Returns diagnostic information.
    """
    epsilon = max(
        abs(perturbed_scores[i] - original_scores[i]) for i in active
    )
    gamma = elimination_gap_certificate(active, original_scores)
    residual = gap_after_perturbation(gamma, epsilon)
    original_winner = irv_winner(active, original_scores)
    perturbed_winner = irv_winner(active, perturbed_scores)

    return {
        "epsilon": epsilon,
        "gamma": gamma,
        "residual_gap": residual,
        "certified_stable": residual > 0,
        "actually_stable": original_winner == perturbed_winner,
        "original_winner": original_winner,
        "perturbed_winner": perturbed_winner,
        "original_order": irv_elimination_order(active, original_scores),
        "perturbed_order": irv_elimination_order(active, perturbed_scores),
    }


# ══════════════════════════════════════════════════════════════════════
#  DEMONSTRATIONS
# ══════════════════════════════════════════════════════════════════════

def demo_basic_irv() -> None:
    """Demo 1: Basic IRV elimination with 5 candidates."""
    print("=" * 65)
    print("DEMO 1: Basic IRV Elimination")
    print("=" * 65)

    scores = [2.0, 7.0, 3.5, 9.0, 5.0]
    candidates = list(range(5))

    print(f"Candidates:  {candidates}")
    print(f"Scores:      {scores}")
    print()

    order = irv_elimination_order(candidates, scores)
    print(f"Elimination order: {order}")
    print(f"  Round 1: eliminate {order[0]} (score {scores[order[0]]})")
    print(f"  Round 2: eliminate {order[1]} (score {scores[order[1]]})")
    print(f"  Round 3: eliminate {order[2]} (score {scores[order[2]]})")
    print(f"  Round 4: eliminate {order[3]} (score {scores[order[3]]})")
    print(f"  Winner:  {order[4]} (score {scores[order[4]]})")
    print()

    gamma = elimination_gap_certificate(candidates, scores)
    radius = certified_robustness_radius(candidates, scores)
    print(f"Gap certificate γ = {gamma}")
    print(f"Certified robustness radius ε* = γ/2 = {radius}")
    print(f"  → Any score perturbation with |v'(i) - v(i)| < {radius}")
    print(f"    for all i is guaranteed to preserve the winner.")
    print()


def demo_gap_certificate() -> None:
    """Demo 2: Gap certificate computation and verification."""
    print("=" * 65)
    print("DEMO 2: Gap Certificate Analysis")
    print("=" * 65)

    scores = [1.0, 4.0, 6.0, 10.0]
    candidates = [0, 1, 2, 3]

    print(f"Scores: {scores}")
    print()

    # Walk through each round
    active = list(candidates)
    round_num = 1
    while len(active) > 1:
        loser = round_loser(active, scores)
        gap = compute_gap(active, scores, loser)
        print(f"Round {round_num}: active = {active}")
        print(f"  Loser = {loser} (score {scores[loser]:.1f})")
        print(f"  Gap = {gap:.1f}")
        print(f"  HasGapAtLeast(γ={gap:.1f}): {has_gap_at_least(active, scores, loser, gap)}")
        active.remove(loser)
        round_num += 1

    print(f"\nOverall gap certificate γ = {elimination_gap_certificate(candidates, scores):.1f}")
    print()


def demo_perturbation_stability() -> None:
    """Demo 3: Perturbation stability — within and outside the certified radius."""
    print("=" * 65)
    print("DEMO 3: Perturbation Stability")
    print("=" * 65)

    scores = [1.0, 5.0, 8.0, 12.0]
    candidates = [0, 1, 2, 3]
    gamma = elimination_gap_certificate(candidates, scores)
    radius = certified_robustness_radius(candidates, scores)

    print(f"Original scores: {scores}")
    print(f"Gap certificate γ = {gamma}")
    print(f"Certified radius ε* = {radius}")
    print()

    # Test 1: perturbation well within radius
    eps1 = radius * 0.5
    perturbed1 = [s + eps1 * ((-1) ** i) for i, s in enumerate(scores)]
    result1 = verify_stability(candidates, scores, perturbed1)
    print(f"Test A: ε = {eps1:.2f} (within radius)")
    print(f"  Perturbed scores: {[f'{s:.2f}' for s in perturbed1]}")
    print(f"  Residual gap: {result1['residual_gap']:.2f}")
    print(f"  Certified stable: {result1['certified_stable']}")
    print(f"  Actually stable:  {result1['actually_stable']}")
    print(f"  Winner: {result1['original_winner']} → {result1['perturbed_winner']}")
    print()

    # Test 2: perturbation at the boundary
    eps2 = radius * 0.99
    perturbed2 = [s + eps2 * ((-1) ** i) for i, s in enumerate(scores)]
    result2 = verify_stability(candidates, scores, perturbed2)
    print(f"Test B: ε = {eps2:.2f} (near boundary)")
    print(f"  Perturbed scores: {[f'{s:.2f}' for s in perturbed2]}")
    print(f"  Residual gap: {result2['residual_gap']:.2f}")
    print(f"  Certified stable: {result2['certified_stable']}")
    print(f"  Actually stable:  {result2['actually_stable']}")
    print(f"  Winner: {result2['original_winner']} → {result2['perturbed_winner']}")
    print()

    # Test 3: perturbation beyond the radius (adversarial)
    eps3 = radius * 2.5
    perturbed3 = list(scores)
    perturbed3[0] = scores[0] + eps3   # boost the loser
    perturbed3[1] = scores[1] - eps3   # suppress the second
    result3 = verify_stability(candidates, scores, perturbed3)
    print(f"Test C: ε = {eps3:.2f} (beyond radius, adversarial)")
    print(f"  Perturbed scores: {[f'{s:.2f}' for s in perturbed3]}")
    print(f"  Residual gap: {result3['residual_gap']:.2f}")
    print(f"  Certified stable: {result3['certified_stable']}")
    print(f"  Actually stable:  {result3['actually_stable']}")
    print(f"  Winner: {result3['original_winner']} → {result3['perturbed_winner']}")
    print()


def demo_lipschitz_robustness() -> None:
    """Demo 4: End-to-end Lipschitz robustness for a tropical classifier."""
    print("=" * 65)
    print("DEMO 4: Tropical/Lipschitz Classifier Robustness")
    print("=" * 65)

    # A simple piecewise-linear (tropical) score map: s(x) = W @ max(x, 0)
    # This is a 1-layer ReLU network
    W = [
        [1.0, -0.5, 0.3],   # class 0 weights
        [-0.2, 1.5, -0.1],  # class 1 weights
        [0.4, 0.1, 1.2],    # class 2 weights
    ]

    def relu(x: float) -> float:
        return max(x, 0.0)

    def score_map(x: list[float]) -> list[float]:
        hidden = [relu(xi) for xi in x]
        return [sum(W[c][j] * hidden[j] for j in range(3)) for c in range(3)]

    # Lipschitz constant: max row-sum of |W|
    K = max(sum(abs(w) for w in row) for row in W)

    x = [2.0, 1.0, 0.5]
    scores = score_map(x)
    candidates = [0, 1, 2]

    gamma = elimination_gap_certificate(candidates, scores)
    radius = certified_robustness_radius(candidates, scores, lipschitz_K=K)

    print(f"Score map: 1-layer ReLU network")
    print(f"Input x = {x}")
    print(f"Scores s(x) = {[f'{s:.3f}' for s in scores]}")
    print(f"Lipschitz constant K = {K:.2f}")
    print(f"Gap certificate γ = {gamma:.3f}")
    print(f"Certified input radius r* = γ/(2K) = {radius:.4f}")
    print()
    print(f"IRV winner: class {irv_winner(candidates, scores)}")
    print(f"  → Guaranteed stable for any ‖x' - x‖∞ < {radius:.4f}")
    print()

    # Verify with a perturbation within the radius
    delta = radius * 0.8
    x_pert = [xi + delta * ((-1) ** i) for i, xi in enumerate(x)]
    scores_pert = score_map(x_pert)
    winner_pert = irv_winner(candidates, scores_pert)
    print(f"Verification: x' = {[f'{xi:.4f}' for xi in x_pert]}")
    print(f"  s(x') = {[f'{s:.3f}' for s in scores_pert]}")
    print(f"  Winner = class {winner_pert} (same: {winner_pert == irv_winner(candidates, scores)})")
    print()


def demo_tightness() -> None:
    """Demo 5: Tightness of the factor-2 bound."""
    print("=" * 65)
    print("DEMO 5: Tightness of the 2ε < γ Condition")
    print("=" * 65)

    gamma = 4.0
    scores = [0.0, gamma, gamma + 1.0]
    candidates = [0, 1, 2]

    print(f"Scores: {scores}")
    print(f"Gap γ = {gamma}")
    print(f"Winner: {irv_winner(candidates, scores)}")
    print()

    # Perturb with ε approaching γ/2
    for fraction in [0.25, 0.49, 0.50, 0.51, 0.75]:
        eps = gamma * fraction
        perturbed = [scores[0] + eps, scores[1] - eps, scores[2]]
        winner = irv_winner(candidates, perturbed)
        residual = gamma - 2 * eps
        cert = "✓ certified" if residual > 0 else "✗ not certified"
        flip = " (FLIPPED!)" if winner != 2 else ""
        print(
            f"  ε = {eps:.2f} (ε/γ = {fraction:.2f}): "
            f"scores = [{perturbed[0]:.2f}, {perturbed[1]:.2f}, {perturbed[2]:.2f}], "
            f"residual = {residual:.2f}, winner = {winner}{flip} {cert}"
        )

    print()
    print("Note: At ε = γ/2 (fraction = 0.50), candidates 0 and 1 are tied.")
    print("The winner can flip for any ε > γ/2, confirming the bound is tight.")
    print()


def demo_scaling_candidates() -> None:
    """Demo 6: How robustness scales with the number of candidates."""
    print("=" * 65)
    print("DEMO 6: Robustness vs. Number of Candidates")
    print("=" * 65)

    print(f"{'m':>4}  {'γ':>8}  {'radius':>10}  {'winner':>8}")
    print("-" * 36)

    for m in range(3, 12):
        # Uniformly spaced scores: 1, 2, ..., m
        scores = [float(i + 1) for i in range(m)]
        candidates = list(range(m))
        gamma = elimination_gap_certificate(candidates, scores)
        radius = certified_robustness_radius(candidates, scores)
        winner = irv_winner(candidates, scores)
        print(f"{m:>4}  {gamma:>8.2f}  {radius:>10.4f}  {winner:>8}")

    print()
    print("With uniformly spaced scores, the gap is always 1.0 regardless")
    print("of the number of candidates — the robustness radius is constant.")
    print()


# ──────────────────────────────────────────────────────────────────────
#  Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_basic_irv()
    demo_gap_certificate()
    demo_perturbation_stability()
    demo_lipschitz_robustness()
    demo_tightness()
    demo_scaling_candidates()
