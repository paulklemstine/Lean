#!/usr/bin/env python3
"""
Numerical demonstrations of certified robustness for IRV classifiers.

Illustrates the key theorems from the formal development:
  1. Gap certificate computation
  2. Gap preservation under perturbation (Theorem 3.2)
  3. IRV elimination-order stability (Theorem 3.4)
  4. Certified robustness radius computation (Theorem 3.7)

All functions are self-contained with type hints.
"""

from __future__ import annotations
import math
import random


# ──────────────────────────────────────────────────────────────────
# Core IRV implementation
# ──────────────────────────────────────────────────────────────────

def irv_elimination_order(scores: dict[str, float]) -> list[str]:
    """
    Compute the full IRV elimination order for a score vector.

    At each round, the candidate with the minimum score is eliminated.
    Returns a list [first_eliminated, ..., winner].

    >>> irv_elimination_order({"A": 3.0, "B": 1.0, "C": 5.0, "D": 2.0})
    ['B', 'D', 'A', 'C']
    """
    active: dict[str, float] = dict(scores)
    order: list[str] = []
    while len(active) > 1:
        loser = min(active, key=lambda c: active[c])
        order.append(loser)
        del active[loser]
    # Last remaining candidate is the winner
    order.append(next(iter(active)))
    return order


def irv_winner(scores: dict[str, float]) -> str:
    """Return the IRV winner (last survivor of sequential elimination)."""
    return irv_elimination_order(scores)[-1]


# ──────────────────────────────────────────────────────────────────
# Gap certificate computation
# ──────────────────────────────────────────────────────────────────

def compute_round_gap(scores: dict[str, float]) -> tuple[str, float]:
    """
    Compute the gap certificate for the current round.

    Returns (loser, gap) where gap = second_min - min.
    This is the minimum separation between the loser and all other candidates.

    >>> compute_round_gap({"A": 5.0, "B": 1.0, "C": 3.0})
    ('B', 2.0)
    """
    sorted_scores = sorted(scores.values())
    loser = min(scores, key=lambda c: scores[c])
    gap = sorted_scores[1] - sorted_scores[0]
    return loser, gap


def compute_elimination_gap_certificate(scores: dict[str, float]) -> float:
    """
    Compute the full elimination gap certificate: the minimum gap
    across all rounds of IRV elimination.

    This is the parameter gamma in the formal development.

    >>> compute_elimination_gap_certificate({"A": 3.0, "B": 1.0, "C": 5.0})
    2.0
    """
    active = dict(scores)
    min_gap = float("inf")
    while len(active) > 1:
        loser, gap = compute_round_gap(active)
        min_gap = min(min_gap, gap)
        del active[loser]
    return min_gap


# ──────────────────────────────────────────────────────────────────
# Demo 1: Gap Preservation Under Perturbation
# ──────────────────────────────────────────────────────────────────

def demo_gap_preservation() -> None:
    """
    Demonstrates Theorem 3.2 (gap_preserved_under_perturbation):
    If the original gap is gamma and perturbation is at most epsilon,
    the new gap is at least gamma - 2*epsilon.
    """
    print("=" * 65)
    print("DEMO 1: Gap Preservation Under Perturbation")
    print("=" * 65)

    scores = {"A": 1.0, "B": 4.0, "C": 6.5, "D": 8.0}
    loser, gamma = compute_round_gap(scores)
    print(f"\nOriginal scores:  {scores}")
    print(f"Round loser:      {loser} (score = {scores[loser]:.1f})")
    print(f"Gap certificate:  gamma = {gamma:.1f}")

    epsilons = [0.5, 1.0, 1.4, 1.5]
    print(f"\nPerturbation analysis (condition: 2*eps < gamma = {gamma:.1f}):")
    print(f"{'eps':>6} | {'2*eps':>6} | {'gamma-2eps':>10} | {'Stable?':>8} | {'Verified':>10}")
    print("-" * 55)

    for eps in epsilons:
        # Worst-case perturbation: loser goes UP by eps, closest rival goes DOWN by eps
        perturbed = dict(scores)
        perturbed[loser] = scores[loser] + eps  # Worst case for loser
        # Find the second-lowest candidate and decrease their score
        second = sorted(scores, key=lambda c: scores[c])[1]
        perturbed[second] = scores[second] - eps

        new_loser, new_gap = compute_round_gap(perturbed)
        residual = gamma - 2 * eps
        stable = 2 * eps < gamma
        same_loser = new_loser == loser

        print(
            f"{eps:>6.1f} | {2*eps:>6.1f} | {residual:>10.1f} | "
            f"{'YES' if stable else 'NO':>8} | "
            f"{'loser unchanged' if same_loser else 'LOSER CHANGED!'}"
        )

    print()


# ──────────────────────────────────────────────────────────────────
# Demo 2: Elimination-Order Stability
# ──────────────────────────────────────────────────────────────────

def demo_elimination_order_stability() -> None:
    """
    Demonstrates Theorem 3.4 (eliminationOrderOn_stable):
    When 2*eps < gamma, the entire elimination order is preserved.
    """
    print("=" * 65)
    print("DEMO 2: Elimination-Order Stability")
    print("=" * 65)

    scores = {"A": 2.0, "B": 5.0, "C": 8.0, "D": 11.0, "E": 15.0}
    gamma = compute_elimination_gap_certificate(scores)
    order = irv_elimination_order(scores)

    print(f"\nOriginal scores:     {scores}")
    print(f"Elimination order:   {order}")
    print(f"Gap certificate:     gamma = {gamma:.1f}")
    print(f"Safe perturbation:   eps < gamma/2 = {gamma/2:.1f}")

    random.seed(42)
    print(f"\n{'eps':>6} | {'2*eps < gamma?':>15} | {'Order preserved?':>18} | Perturbed order")
    print("-" * 75)

    for eps in [0.5, 1.0, 1.4, 2.0, 3.0]:
        perturbed = {
            c: v + random.uniform(-eps, eps) for c, v in scores.items()
        }
        p_order = irv_elimination_order(perturbed)
        safe = 2 * eps < gamma
        preserved = p_order == order
        print(
            f"{eps:>6.1f} | {'YES' if safe else 'NO':>15} | "
            f"{'YES' if preserved else 'NO':>18} | {p_order}"
        )
        random.seed(42 + int(eps * 10))  # Reproducible

    print()


# ──────────────────────────────────────────────────────────────────
# Demo 3: Certified Robustness Radius
# ──────────────────────────────────────────────────────────────────

def demo_certified_robustness() -> None:
    """
    Demonstrates Theorem 3.7 (irvWinner_certified_robust):
    For a K-Lipschitz score function, the certified robustness radius is gamma/(2K).
    """
    print("=" * 65)
    print("DEMO 3: Certified Robustness Radius (Lipschitz Score Maps)")
    print("=" * 65)

    # Simulate a 3-class tropical linear score function on R^4
    # s(x) = min over rows of (W @ x + b)  [tropical linear map]
    # Each class has a weight vector and bias
    weights: dict[str, list[float]] = {
        "cat":  [0.8, -0.3, 0.5, 0.1],
        "dog":  [-0.2, 0.9, -0.1, 0.4],
        "bird": [0.1, 0.2, -0.6, 0.7],
    }
    biases: dict[str, float] = {"cat": 1.0, "dog": 0.5, "bird": -0.3}

    def score_fn(x: list[float]) -> dict[str, float]:
        """Simple linear score function: s_c(x) = w_c . x + b_c."""
        return {
            c: sum(w * xi for w, xi in zip(weights[c], x)) + biases[c]
            for c in weights
        }

    def lipschitz_constant() -> float:
        """Lipschitz constant K = max_c ||w_c||_1 (L_inf -> L_inf)."""
        return max(sum(abs(w) for w in wv) for wv in weights.values())

    x0 = [1.0, 2.0, -0.5, 0.3]
    scores = score_fn(x0)
    gamma = compute_elimination_gap_certificate(scores)
    K = lipschitz_constant()
    r_star = gamma / (2 * K) if K > 0 else float("inf")

    print(f"\nInput x0:               {x0}")
    print(f"Scores s(x0):           { {c: round(v, 3) for c, v in scores.items()} }")
    print(f"IRV winner:             {irv_winner(scores)}")
    print(f"Gap certificate gamma:  {gamma:.4f}")
    print(f"Lipschitz constant K:   {K:.4f}")
    print(f"Certified radius r*:    gamma/(2K) = {r_star:.4f}")
    print(f"\nGuarantee: any x' with ||x' - x||_inf <= {r_star:.4f} yields the same IRV winner.")

    # Verify empirically
    print(f"\nEmpirical verification (1000 random perturbations within r*):")
    random.seed(123)
    n_trials = 1000
    n_safe = 0
    for _ in range(n_trials):
        perturbation = [random.uniform(-r_star, r_star) for _ in x0]
        x_pert = [xi + di for xi, di in zip(x0, perturbation)]
        if irv_winner(score_fn(x_pert)) == irv_winner(scores):
            n_safe += 1
    print(f"  Winner preserved: {n_safe}/{n_trials} ({100*n_safe/n_trials:.1f}%)")

    # Also test beyond the radius
    print(f"\nBeyond the certified radius (r = 2 * r*):")
    n_safe_beyond = 0
    for _ in range(n_trials):
        perturbation = [random.uniform(-2 * r_star, 2 * r_star) for _ in x0]
        x_pert = [xi + di for xi, di in zip(x0, perturbation)]
        if irv_winner(score_fn(x_pert)) == irv_winner(scores):
            n_safe_beyond += 1
    print(f"  Winner preserved: {n_safe_beyond}/{n_trials} ({100*n_safe_beyond/n_trials:.1f}%)")
    print()


# ──────────────────────────────────────────────────────────────────
# Demo 4: The Factor of 2 is Tight
# ──────────────────────────────────────────────────────────────────

def demo_tightness() -> None:
    """
    Demonstrates that the factor of 2 in the condition 2*eps < gamma is tight.
    Constructs the worst-case perturbation that flips the outcome at eps = gamma/2.
    """
    print("=" * 65)
    print("DEMO 4: Tightness of the 2*eps < gamma Bound")
    print("=" * 65)

    scores = {"A": 0.0, "B": 3.0}
    gamma = 3.0  # gap between A and B
    eps_critical = gamma / 2

    print(f"\nTwo-candidate example: scores = {scores}")
    print(f"Gap gamma = {gamma:.1f}, critical eps = gamma/2 = {eps_critical:.1f}")
    print(f"\nWorst-case perturbation: A goes up by eps, B goes down by eps")

    for eps in [1.0, 1.4, 1.499, 1.5, 1.501, 2.0]:
        perturbed = {"A": scores["A"] + eps, "B": scores["B"] - eps}
        residual_gap = gamma - 2 * eps
        winner = irv_winner(perturbed)
        print(
            f"  eps={eps:>5.3f}: perturbed={{'A': {perturbed['A']:.3f}, 'B': {perturbed['B']:.3f}}} "
            f"residual_gap={residual_gap:>+6.3f}  winner={winner}"
        )

    print()


# ──────────────────────────────────────────────────────────────────
# Demo 5: Multi-Round Gap Certificate Visualization (text)
# ──────────────────────────────────────────────────────────────────

def demo_multi_round_gaps() -> None:
    """
    Shows the gap certificate at each round of a 6-candidate elimination.
    The overall certificate is the minimum across rounds.
    """
    print("=" * 65)
    print("DEMO 5: Per-Round Gap Certificates")
    print("=" * 65)

    scores = {"A": 1.0, "B": 3.5, "C": 5.0, "D": 7.0, "E": 10.0, "F": 14.0}
    active = dict(scores)
    round_num = 0

    print(f"\nInitial scores: {scores}")
    print(f"\n{'Round':>5} | {'Active Set':>35} | {'Loser':>5} | {'Gap':>6}")
    print("-" * 65)

    overall_gamma = float("inf")

    while len(active) > 1:
        round_num += 1
        loser, gap = compute_round_gap(active)
        overall_gamma = min(overall_gamma, gap)
        active_str = str({c: active[c] for c in sorted(active)})
        print(f"{round_num:>5} | {active_str:>35} | {loser:>5} | {gap:>6.1f}")
        del active[loser]

    winner = next(iter(active))
    print(f"\nWinner: {winner}")
    print(f"Overall gap certificate gamma = {overall_gamma:.1f}")
    print(f"Safe perturbation: eps < {overall_gamma / 2:.2f}")
    print()


# ──────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_gap_preservation()
    demo_elimination_order_stability()
    demo_certified_robustness()
    demo_tightness()
    demo_multi_round_gaps()
