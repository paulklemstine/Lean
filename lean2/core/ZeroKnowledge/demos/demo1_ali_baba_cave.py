#!/usr/bin/env python3
"""
Demo 1: The Ali Baba Cave — Visual Zero-Knowledge Proof Analogy

This script simulates and visualizes the classic "Ali Baba cave" thought experiment
that explains zero-knowledge proofs intuitively.

A cave has a ring-shaped tunnel with a locked door. The Prover claims to know the
secret word that opens the door. The Verifier watches from the entrance.

Protocol:
  1. Prover enters the cave, choosing left or right randomly (hidden from Verifier).
  2. Verifier calls out "come out on the LEFT" or "come out on the RIGHT."
  3. If the Prover knows the secret, they can always comply.
  4. If they don't know the secret, they can only comply 50% of the time.

After n rounds, a faker's probability of fooling the verifier is (1/2)^n.
"""

import random
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from matplotlib.gridspec import GridSpec


def simulate_zkp_cave(n_rounds=20, prover_knows_secret=True):
    """Simulate n rounds of the Ali Baba cave protocol."""
    results = []
    for _ in range(n_rounds):
        # Prover enters on a random side
        prover_side = random.choice(["LEFT", "RIGHT"])
        # Verifier challenges with a random side
        challenge = random.choice(["LEFT", "RIGHT"])

        if prover_knows_secret:
            # Prover can always open the door and come out the right side
            success = True
        else:
            # Prover can only succeed if they happened to enter on the challenged side
            success = (prover_side == challenge)

        results.append({
            "prover_entered": prover_side,
            "challenge": challenge,
            "success": success,
        })
    return results


def draw_cave(ax, round_num, prover_side, challenge, success, prover_knows):
    """Draw one round of the cave protocol."""
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3.5)
    ax.set_aspect("equal")
    ax.axis("off")

    # Draw cave walls (ring shape)
    outer = plt.Circle((0, 0), 2.5, fill=False, color="saddlebrown", linewidth=3)
    inner = plt.Circle((0, 0), 1.2, fill=False, color="saddlebrown", linewidth=3)
    ax.add_patch(outer)
    ax.add_patch(inner)

    # Draw entrance at top
    # entrance decoration (skipped for simplicity)
    entrance = patches.FancyBboxPatch((-0.4, 2.4), 0.8, 0.8, boxstyle="round,pad=0.1",
                                       facecolor="lightyellow", edgecolor="black", linewidth=2)
    ax.add_patch(entrance)
    ax.text(0, 2.8, "🚪", fontsize=14, ha="center", va="center")

    # Draw the locked door at the bottom
    door_color = "green" if (prover_knows and prover_side != challenge) else "red"
    if prover_knows and prover_side != challenge:
        door_label = "OPENED"
    elif not prover_knows and prover_side != challenge:
        door_label = "LOCKED"
    else:
        door_label = "—"

    door = patches.FancyBboxPatch((-0.5, -2.8), 1.0, 0.5, boxstyle="round,pad=0.05",
                                   facecolor=door_color, edgecolor="black", linewidth=2, alpha=0.7)
    ax.add_patch(door)
    ax.text(0, -2.55, door_label, fontsize=7, ha="center", va="center", fontweight="bold", color="white")

    # Draw LEFT and RIGHT labels
    ax.text(-2.0, 1.0, "LEFT", fontsize=9, ha="center", va="center",
            fontweight="bold", color="navy",
            bbox=dict(boxstyle="round", facecolor="lightblue", alpha=0.8))
    ax.text(2.0, 1.0, "RIGHT", fontsize=9, ha="center", va="center",
            fontweight="bold", color="darkred",
            bbox=dict(boxstyle="round", facecolor="lightyellow", alpha=0.8))

    # Draw prover position
    if prover_side == "LEFT":
        px, py = -1.85, -0.5
    else:
        px, py = 1.85, -0.5

    ax.plot(px, py, "o", color="blue", markersize=12, zorder=5)
    ax.text(px, py + 0.4, "P", fontsize=10, ha="center", va="center",
            fontweight="bold", color="blue")

    # Draw verifier at entrance
    ax.plot(0, 3.3, "s", color="red", markersize=12, zorder=5)
    ax.text(0, 3.6, "V", fontsize=10, ha="center", va="center",
            fontweight="bold", color="red")

    # Challenge arrow
    if challenge == "LEFT":
        ax.annotate("", xy=(-1.5, 2.0), xytext=(0, 3.1),
                     arrowprops=dict(arrowstyle="->", color="red", lw=2))
    else:
        ax.annotate("", xy=(1.5, 2.0), xytext=(0, 3.1),
                     arrowprops=dict(arrowstyle="->", color="red", lw=2))

    # Title
    result_str = "✅ PASS" if success else "❌ FAIL"
    result_color = "green" if success else "red"
    ax.set_title(f"Round {round_num}: Challenge={challenge}\n{result_str}",
                 fontsize=10, fontweight="bold", color=result_color)


def run_visualization():
    """Run the full Ali Baba cave visualization."""
    # --- Part 1: Show 6 rounds side by side ---
    fig = plt.figure(figsize=(18, 14))
    fig.suptitle("🏔️  The Ali Baba Cave: Zero-Knowledge Proof Analogy  🏔️",
                 fontsize=18, fontweight="bold", y=0.98)

    gs = GridSpec(3, 4, figure=fig, hspace=0.5, wspace=0.3)

    # Honest prover (knows secret)
    honest_results = simulate_zkp_cave(6, prover_knows_secret=True)
    for i, r in enumerate(honest_results):
        row, col = divmod(i, 3)
        ax = fig.add_subplot(gs[row, col])
        draw_cave(ax, i + 1, r["prover_entered"], r["challenge"], r["success"], True)
        if i == 0:
            ax.text(-3, -3.5, "HONEST PROVER (knows secret)", fontsize=9,
                    color="blue", fontweight="bold")

    # Dishonest prover
    faker_results = simulate_zkp_cave(6, prover_knows_secret=False)
    for i, r in enumerate(faker_results):
        row, col = divmod(i, 3)
        ax = fig.add_subplot(gs[row, col + 1 if col < 2 else col])

    # --- Part 2: Statistical analysis ---
    fig2, axes2 = plt.subplots(1, 3, figsize=(18, 6))
    fig2.suptitle("Statistical Analysis: Why Zero-Knowledge Proofs Work",
                  fontsize=16, fontweight="bold")

    # Plot 1: Probability of faker passing vs number of rounds
    ax = axes2[0]
    rounds = np.arange(1, 41)
    faker_prob = (0.5) ** rounds
    ax.semilogy(rounds, faker_prob, "r-", linewidth=2, label="Faker success probability")
    ax.axhline(y=1e-6, color="green", linestyle="--", alpha=0.7, label="1 in a million")
    ax.axhline(y=2**-128, color="blue", linestyle="--", alpha=0.7, label="Cryptographic security (2⁻¹²⁸)")
    ax.set_xlabel("Number of Rounds", fontsize=12)
    ax.set_ylabel("Probability of Faker Passing All Rounds", fontsize=12)
    ax.set_title("Soundness: Fakers Get Caught", fontsize=13, fontweight="bold")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(1e-40, 1.5)

    # Plot 2: Monte Carlo simulation
    ax = axes2[1]
    n_simulations = 10000
    n_rounds_list = [1, 5, 10, 15, 20, 30]
    faker_success_rates = []
    honest_success_rates = []

    for n in n_rounds_list:
        faker_wins = 0
        honest_wins = 0
        for _ in range(n_simulations):
            faker_result = simulate_zkp_cave(n, prover_knows_secret=False)
            honest_result = simulate_zkp_cave(n, prover_knows_secret=True)
            if all(r["success"] for r in faker_result):
                faker_wins += 1
            if all(r["success"] for r in honest_result):
                honest_wins += 1
        faker_success_rates.append(faker_wins / n_simulations)
        honest_success_rates.append(honest_wins / n_simulations)

    x = np.arange(len(n_rounds_list))
    width = 0.35
    bars1 = ax.bar(x - width / 2, honest_success_rates, width, label="Honest Prover",
                   color="green", alpha=0.8)
    bars2 = ax.bar(x + width / 2, faker_success_rates, width, label="Faker",
                   color="red", alpha=0.8)
    ax.set_xlabel("Number of Rounds", fontsize=12)
    ax.set_ylabel("Success Rate", fontsize=12)
    ax.set_title("Monte Carlo: Honest vs Faker", fontsize=13, fontweight="bold")
    ax.set_xticks(x)
    ax.set_xticklabels(n_rounds_list)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis="y")

    # Add value labels on bars
    for bar in bars1:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width() / 2., height + 0.01,
                f'{height:.2f}', ha='center', va='bottom', fontsize=8)
    for bar in bars2:
        height = bar.get_height()
        if height > 0.001:
            ax.text(bar.get_x() + bar.get_width() / 2., height + 0.01,
                    f'{height:.4f}', ha='center', va='bottom', fontsize=7)

    # Plot 3: Information leaked
    ax = axes2[2]
    rounds_axis = np.arange(1, 21)
    info_leaked_zkp = np.zeros(20)  # ZKP leaks nothing
    info_leaked_reveal = np.ones(20) * 100  # Revealing leaks everything

    ax.fill_between(rounds_axis, info_leaked_reveal, alpha=0.3, color="red",
                    label="Direct reveal")
    ax.plot(rounds_axis, info_leaked_reveal, "r--", linewidth=2)
    ax.fill_between(rounds_axis, info_leaked_zkp, alpha=0.3, color="green",
                    label="Zero-knowledge proof")
    ax.plot(rounds_axis, info_leaked_zkp, "g-", linewidth=3)

    # Confidence gained
    ax2 = ax.twinx()
    confidence = (1 - 0.5 ** rounds_axis) * 100
    ax2.plot(rounds_axis, confidence, "b-", linewidth=2, label="Verifier confidence")
    ax2.set_ylabel("Verifier Confidence (%)", fontsize=12, color="blue")
    ax2.tick_params(axis="y", labelcolor="blue")

    ax.set_xlabel("Number of Rounds", fontsize=12)
    ax.set_ylabel("Information Leaked (%)", fontsize=12)
    ax.set_title("The Magic: Full Confidence,\nZero Information Leakage", fontsize=13, fontweight="bold")
    ax.legend(loc="center left", fontsize=9)
    ax2.legend(loc="center right", fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-5, 110)

    plt.tight_layout()
    fig2.savefig("/workspace/request-project/ZeroKnowledge/demos/ali_baba_statistics.png",
                 dpi=150, bbox_inches="tight")
    plt.close("all")
    print("✅ Demo 1 saved: ali_baba_statistics.png")


if __name__ == "__main__":
    run_visualization()
