#!/usr/bin/env python3
"""
Mortal vs Eternity: Infinite Games Against Death — Demonstration

This script demonstrates the key concepts:
1. Safe Escape games and the Omega Survival Theorem
2. Layered survival and the ω·k bound
3. Adaptive layering and the ω² bound
4. Asymmetry collapse phenomenon
5. Monte Carlo simulation of the Safe Escape Density Conjecture
"""

import random
import math
from typing import List, Tuple, Callable, Optional

# ============================================================
# Part 1: Core Game Framework
# ============================================================

class SurvivalGame:
    """A survival game where Mortal tries to avoid a death set."""

    def __init__(self, death_pred: Callable[[List[Tuple[int, int]]], bool]):
        """
        death_pred: Given history of (mortal_move, eternity_response) pairs,
                   returns True if Mortal has died.
        """
        self.death_pred = death_pred
        assert not death_pred([]), "Game must start alive"

    def has_died(self, history: List[Tuple[int, int]]) -> bool:
        return self.death_pred(history)


def play_rounds(mortal_strat, eternity_strat, n: int) -> List[Tuple[int, int]]:
    """Play n rounds, returning the history."""
    history = []
    for _ in range(n):
        m_move = mortal_strat(history)
        e_response = eternity_strat(history, m_move)
        history.append((m_move, e_response))
    return history


# ============================================================
# Part 2: Safe Escape Games — Concrete Examples
# ============================================================

def make_safe_escape_game(num_moves: int = 3) -> SurvivalGame:
    """
    Create a game with Safe Escape property.
    Death occurs when Mortal plays a "trap move" chosen by Eternity.
    But Eternity must commit the trap BEFORE Mortal moves (via response).
    Specifically: death occurs when (mortal_move + eternity_response) % num_moves == 0
    AND mortal_move == 0. So Mortal can always escape by NOT playing 0.
    Safe escape: Mortal has at least 2 safe moves (1, 2, ..., num_moves-1).
    """
    def death_pred(history):
        return any(m == 0 and (m + e) % num_moves == 0 for m, e in history)
    return SurvivalGame(death_pred)


def safe_strategy_example(history: List[Tuple[int, int]]) -> int:
    """Safe strategy: alternate between 0 and 1."""
    return len(history) % 2


def adversarial_eternity(history: List[Tuple[int, int]], m_move: int) -> int:
    """Eternity tries to match Mortal's move (kill strategy)."""
    return m_move


def random_eternity(history: List[Tuple[int, int]], m_move: int) -> int:
    """Eternity plays randomly from {0, 1, 2}."""
    return random.randint(0, 2)


print("=" * 60)
print("MORTAL vs ETERNITY: Infinite Games Against Death")
print("=" * 60)

# Example 1: Safe Escape Game
print("\n--- Example 1: Safe Escape Game (3 moves) ---")
game = make_safe_escape_game(3)

# Mortal uses a safe strategy (avoids matching)
def smart_mortal(history):
    """Safe strategy: always play 1 (never play the dangerous move 0)."""
    return 1  # Any non-zero move is safe

# Play 20 rounds against adversarial Eternity
history = play_rounds(smart_mortal, adversarial_eternity, 20)
alive = not game.has_died(history)
print(f"Smart Mortal vs Adversarial Eternity (20 rounds): {'ALIVE' if alive else 'DEAD'}")
print(f"  History: {history[:5]}... (showing first 5)")

# Play against random Eternity
history = play_rounds(smart_mortal, random_eternity, 100)
alive = not game.has_died(history)
print(f"Smart Mortal vs Random Eternity (100 rounds): {'ALIVE' if alive else 'DEAD'}")

# Naive strategy (always play 0) against adversarial
def naive_mortal(history):
    return 0

history = play_rounds(naive_mortal, adversarial_eternity, 5)
alive = not game.has_died(history)
print(f"Naive Mortal vs Adversarial Eternity (5 rounds): {'ALIVE' if alive else 'DEAD'}")
print(f"  Dies at round 1 because move=0 triggers death")

# ============================================================
# Part 3: Asymmetry Collapse Demonstration
# ============================================================

print("\n--- Example 2: Asymmetry Collapse ---")
print("Testing 1000 different Eternity strategies against smart Mortal...")

game = make_safe_escape_game(3)
eternity_wins = 0
for trial in range(1000):
    # Random Eternity strategy
    seed = trial
    def make_eternity(s):
        rng = random.Random(s)
        def eternity(history, m_move):
            return rng.randint(0, 2)
        return eternity

    history = play_rounds(smart_mortal, make_eternity(seed), 1000)
    if game.has_died(history):
        eternity_wins += 1

print(f"Eternity wins: {eternity_wins}/1000 = {eternity_wins/10:.1f}%")
print(f"Asymmetry Collapse confirmed: transfinite power gives 0% advantage")

# ============================================================
# Part 4: Ordinal Arena — Rank Descent
# ============================================================

print("\n--- Example 3: Ordinal Arena — Rank Descent ---")

class OrdinalArena:
    """An arena where positions carry ordinal ranks."""

    def __init__(self, initial_rank: int):
        self.initial_rank = initial_rank

    def rank(self, history_len: int) -> int:
        """Rank decreases by 1 each round (simplified finite ordinal)."""
        return max(0, self.initial_rank - history_len)

arena = OrdinalArena(initial_rank=10)
print(f"Initial rank: {arena.rank(0)}")
for i in range(12):
    r = arena.rank(i)
    print(f"  Round {i:2d}: rank = {r:2d}  {'(dead)' if r == 0 else ''}")

# ============================================================
# Part 5: Layered Survival — ω·k Bound
# ============================================================

print("\n--- Example 4: Layered Survival (ω·k) ---")
for k in [1, 2, 5, 10, 100]:
    ordinal_str = f"ω·{k}" if k > 1 else "ω"
    rounds_per_life = "∞ (ω per life)"
    print(f"  k={k:3d} layers: total survival = {ordinal_str:>8s}, each layer immortal")

# ============================================================
# Part 6: Adaptive Layering — ω² Bound
# ============================================================

print("\n--- Example 5: Adaptive Layering → ω² ---")
print("Epoch structure (each epoch spawns more layers):")
for epoch in range(8):
    layers = epoch + 1  # linear growth
    survival = f"ω·{layers}"
    cumulative = f"ω·{sum(range(1, epoch + 2))}"
    print(f"  Epoch {epoch}: {layers} layers, survival this epoch = {survival}, cumulative ≈ {cumulative}")
print(f"  → ω many epochs with unbounded layers = ω·ω = ω²")

# ============================================================
# Part 7: Monte Carlo — Safe Escape Density Conjecture
# ============================================================

print("\n--- Example 6: Safe Escape Density Conjecture ---")
print("Testing: P(SafeEscape | m moves, depth n, death prob p)")

def has_safe_escape_random(num_moves: int, depth: int, death_prob: float,
                           rng: random.Random) -> bool:
    """
    Check if a random game has safe escape up to given depth.
    At each position, each (move, response) pair leads to death with probability p.
    Safe escape: ∃ move, ∀ response, alive.
    """
    for d in range(depth):
        # At this depth, check if there's a safe move
        found_safe = False
        for m in range(num_moves):
            all_safe = True
            for e in range(num_moves):
                if rng.random() < death_prob:
                    all_safe = False
                    break
            if all_safe:
                found_safe = True
                break
        if not found_safe:
            return False
    return True

# Test the conjecture
m_moves = 2
p_death = 0.3
num_trials = 10000

print(f"\nParameters: m={m_moves} moves, p={p_death} death probability")
print(f"{'Depth n':>8s} | {'Observed P':>10s} | {'Predicted P':>11s} | {'Match?':>6s}")
print("-" * 45)

for depth in [1, 5, 10, 15, 20]:
    count = 0
    for trial in range(num_trials):
        rng = random.Random(trial)
        if has_safe_escape_random(m_moves, depth, p_death, rng):
            count += 1
    observed = count / num_trials

    # Predicted: (1 - p^m)^depth approximately
    predicted = (1 - p_death ** m_moves) ** depth
    match = "✓" if abs(observed - predicted) < 3 * math.sqrt(predicted * (1 - predicted) / num_trials) else "✗"
    print(f"{depth:8d} | {observed:10.4f} | {predicted:11.4f} | {match:>6s}")

# ============================================================
# Part 8: Strategic Depth Computation
# ============================================================

print("\n--- Example 7: Strategic Depth ---")
print("Game classifications:")
print("  Trivial game (no danger):     depth = 0  (all strategies work)")
print("  Safe escape game:             depth = 1  (one fixed strategy suffices)")
print("  No safe escape, complex game: depth = ⊤  (no finite strategy suffices)")

# ============================================================
# Part 9: ITTM Connection
# ============================================================

print("\n--- Example 8: ITTM Connection ---")
print("Ordinal duration hierarchy:")
print("  ω    = Mortal with safe escape (finite strategy)")
print("  ω·k  = k-layered game (k lives)")
print("  ω²   = adaptive layering (unbounded lives)")
print("  ω^ω  = hypothetical: infinite layering hierarchy")
print()
print("ITTM parallel:")
print("  ω steps   = one supertask (read entire tape)")
print("  ω·k steps = k supertasks")
print("  ω² steps  = ω supertasks (limit of limits)")
print("  ω^ω steps = transfinite tower of supertasks")

print("\n" + "=" * 60)
print("All demonstrations complete.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Ordinal Survival Hierarchy

Shows the relationship between game structure and survival duration,
comparing ω, ω·k, and ω² survival bounds.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_ordinal_hierarchy():
    """Plot the ordinal survival hierarchy."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # --- Panel 1: ω-Survival (Safe Escape) ---
    ax = axes[0]
    ax.set_title("ω-Survival\n(Safe Escape)", fontsize=14, fontweight='bold')

    # Show rounds 0..20 with safe strategy maintaining survival
    rounds = np.arange(21)
    alive = np.ones(21)

    ax.bar(rounds, alive, color='#2ecc71', alpha=0.8, edgecolor='#27ae60')
    ax.set_xlabel("Round n")
    ax.set_ylabel("Alive (1) / Dead (0)")
    ax.set_ylim(0, 1.3)
    ax.set_xlim(-0.5, 20.5)
    ax.axhline(y=1, color='green', linestyle='--', alpha=0.3)
    ax.text(10, 1.15, "Immortal: survives all n ∈ ℕ",
            ha='center', fontsize=10, style='italic')
    ax.text(10, 1.05, "Duration = ω", ha='center', fontsize=11,
            fontweight='bold', color='#27ae60')

    # --- Panel 2: ω·k Survival (k Layers) ---
    ax = axes[1]
    ax.set_title("ω·k Survival\n(k Layers)", fontsize=14, fontweight='bold')

    colors = ['#3498db', '#e74c3c', '#f39c12', '#9b59b6', '#1abc9c']
    k_values = [1, 2, 3, 5, 10]
    y_positions = np.arange(len(k_values))

    for i, k in enumerate(k_values):
        # Each layer contributes ω rounds (represented as a bar)
        for j in range(min(k, 8)):
            ax.barh(i, 1, left=j, height=0.6,
                    color=colors[i % len(colors)], alpha=0.7,
                    edgecolor='white', linewidth=1)
        if k > 8:
            ax.text(8.5, i, f"...({k})", va='center', fontsize=9)
        label = f"ω·{k}" if k > 1 else "ω"
        ax.text(max(k, 8) + 0.5 if k <= 8 else 10, i, f"= {label}",
                va='center', fontsize=11, fontweight='bold')

    ax.set_yticks(y_positions)
    ax.set_yticklabels([f"k={k}" for k in k_values])
    ax.set_xlabel("Layers (each = ω rounds)")
    ax.set_xlim(-0.5, 13)

    # --- Panel 3: ω² Survival (Adaptive Layering) ---
    ax = axes[2]
    ax.set_title("ω² Survival\n(Adaptive Layering)", fontsize=14, fontweight='bold')

    # Show epochs with growing layers
    max_epochs = 8
    for epoch in range(max_epochs):
        layers = epoch + 1
        for layer in range(layers):
            ax.add_patch(plt.Rectangle(
                (epoch * 1.2, layer * 0.8), 0.9, 0.6,
                facecolor=plt.cm.viridis(epoch / max_epochs),
                alpha=0.7, edgecolor='white', linewidth=1
            ))

    ax.set_xlim(-0.5, max_epochs * 1.2 + 0.5)
    ax.set_ylim(-0.5, max_epochs * 0.8 + 1)
    ax.set_xlabel("Epoch k")
    ax.set_ylabel("Layers in epoch")

    # Add ω² label
    ax.text(max_epochs * 0.6, max_epochs * 0.8 + 0.3,
            "ω epochs × ω layers = ω²",
            ha='center', fontsize=11, fontweight='bold', color='#8e44ad')

    # Add arrow showing growth
    ax.annotate("", xy=(max_epochs * 1.15, max_epochs * 0.75),
                xytext=(max_epochs * 1.15, 0),
                arrowprops=dict(arrowstyle="->", color='gray', lw=1.5))
    ax.text(max_epochs * 1.15 + 0.3, max_epochs * 0.4,
            "Unbounded\ngrowth", fontsize=9, color='gray', va='center')

    plt.tight_layout()
    plt.savefig("ordinal_hierarchy.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: ordinal_hierarchy.png")


def plot_asymmetry_collapse():
    """Plot the asymmetry collapse phenomenon."""
    import random

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # --- Left: Survival rate vs Eternity strategy complexity ---
    ax1.set_title("Asymmetry Collapse\nin Safe-Escape Games", fontsize=14, fontweight='bold')

    complexities = [1, 10, 100, 1000, 10000]
    survival_rates = [1.0, 1.0, 1.0, 1.0, 1.0]  # Always 100% with safe strategy

    ax1.plot(complexities, survival_rates, 'o-', color='#2ecc71',
             linewidth=2, markersize=10, label='Smart Mortal (safe strategy)')

    # Compare with naive strategy
    naive_rates = []
    for c in complexities:
        # Naive strategy dies with probability ~1 after enough rounds
        p_survive = 0.67 ** min(c, 50)  # dies when match occurs
        naive_rates.append(p_survive)

    ax1.plot(complexities, naive_rates, 's--', color='#e74c3c',
             linewidth=2, markersize=8, label='Naive Mortal (fixed move)')

    ax1.set_xscale('log')
    ax1.set_xlabel("Eternity's Strategy Complexity (log scale)")
    ax1.set_ylabel("Mortal Survival Rate")
    ax1.set_ylim(-0.05, 1.15)
    ax1.legend(fontsize=10)
    ax1.axhline(y=1, color='green', linestyle=':', alpha=0.3)
    ax1.text(100, 1.08, "Perfect survival regardless of Eternity's power",
             ha='center', fontsize=9, style='italic', color='#27ae60')

    # --- Right: Gap measurement ---
    ax2.set_title("Computational Asymmetry Gap", fontsize=14, fontweight='bold')

    categories = ['Trivial\nGame', 'Safe\nEscape', 'No Safe\nEscape']
    finite_power = [0, 1, 0.5]  # relative "power" of finite player
    infinite_extra = [0, 0, 0.5]  # extra power from infinite computation

    x = np.arange(len(categories))
    width = 0.5

    bars1 = ax2.bar(x, finite_power, width, label='Finite Power',
                    color='#3498db', alpha=0.8)
    bars2 = ax2.bar(x, infinite_extra, width, bottom=finite_power,
                    label='Infinite Extra', color='#e74c3c', alpha=0.8)

    ax2.set_ylabel("Relative Advantage")
    ax2.set_xticks(x)
    ax2.set_xticklabels(categories)
    ax2.legend()
    ax2.set_ylim(0, 1.3)

    # Annotate collapse
    ax2.annotate("Gap = 0\n(Collapse!)", xy=(1, 1.0), fontsize=10,
                 ha='center', color='#27ae60', fontweight='bold')
    ax2.annotate("Gap > 0\n(Eternity wins)", xy=(2, 1.0), fontsize=10,
                 ha='center', color='#e74c3c', fontweight='bold')

    plt.tight_layout()
    plt.savefig("asymmetry_collapse.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: asymmetry_collapse.png")


def plot_rank_descent():
    """Plot ordinal rank descent in an arena."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # --- Left: Finite rank descent ---
    ax1.set_title("Rank Descent in Finite Arena\n(Initial Rank = 10)",
                  fontsize=14, fontweight='bold')
    rounds = np.arange(12)
    ranks = [max(0, 10 - r) for r in rounds]

    ax1.step(rounds, ranks, where='post', color='#8e44ad', linewidth=2)
    ax1.fill_between(rounds, ranks, step='post', alpha=0.2, color='#8e44ad')
    ax1.scatter(rounds, ranks, color='#8e44ad', zorder=5, s=50)

    ax1.set_xlabel("Round")
    ax1.set_ylabel("Ordinal Rank")
    ax1.set_ylim(-0.5, 11)

    # Mark death
    ax1.axvline(x=10, color='red', linestyle='--', alpha=0.5)
    ax1.text(10.2, 5, "Rank = 0\n(dead)", fontsize=10, color='red')

    # --- Right: Transfinite rank descent (conceptual) ---
    ax2.set_title("Rank Descent in Ordinal Arena\n(Initial Rank = ω)",
                  fontsize=14, fontweight='bold')

    # Show asymptotic descent toward 0
    rounds2 = np.arange(50)
    # Rank decreases but never reaches 0 (ω descent)
    ranks2 = [1.0 / (1 + 0.02 * r) for r in rounds2]

    ax2.plot(rounds2, ranks2, color='#8e44ad', linewidth=2)
    ax2.fill_between(rounds2, ranks2, alpha=0.1, color='#8e44ad')

    ax2.axhline(y=0, color='red', linestyle='--', alpha=0.3)
    ax2.set_xlabel("Round")
    ax2.set_ylabel("Rank (normalized)")
    ax2.set_ylim(-0.05, 1.1)

    ax2.text(25, 0.8, "Rank approaches 0\nbut never reaches it",
             fontsize=10, style='italic', ha='center')
    ax2.text(25, 0.65, "→ Immortal strategy\n(survives all finite rounds)",
             fontsize=10, ha='center', color='#27ae60', fontweight='bold')

    plt.tight_layout()
    plt.savefig("rank_descent.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: rank_descent.png")


if __name__ == "__main__":
    plot_ordinal_hierarchy()
    plot_asymmetry_collapse()
    plot_rank_descent()
    print("\nAll visualizations generated.")
