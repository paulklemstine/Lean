#!/usr/bin/env python3
"""
Visualization 2: Shannon Entropy Evolution During Werewolf Games

Shows how the Shannon entropy of the Bayesian belief state evolves
over the course of a game. Entropy decreases as information is gained
through eliminations and observations. This connects game theory
to information theory — the key cross-domain bridge in our research.
"""

import numpy as np
import matplotlib.pyplot as plt
import math
import random


def binary_entropy(p: float) -> float:
    """Binary entropy H(p) = -p log p - (1-p) log(1-p)."""
    if p <= 0 or p >= 1:
        return 0.0
    return -(p * math.log(p) + (1 - p) * math.log(1 - p))


def simulate_game_entropy(n: int, k: int, seed: int = 42) -> tuple[list[int], list[float], list[float]]:
    """
    Simulate a game tracking entropy evolution.

    Returns:
        rounds: List of round numbers
        entropies: Shannon entropy at each round
        max_beliefs: Maximum belief (suspicion) at each round
    """
    random.seed(seed)
    wolves = set(random.sample(range(n), k))
    alive = list(range(n))
    beliefs = [k / n] * n

    rounds = [0]
    entropies = [sum(binary_entropy(p) for p in beliefs)]
    max_beliefs_list = [max(beliefs)]

    round_num = 0
    while True:
        alive_wolves = [p for p in alive if p in wolves]
        alive_villagers = [p for p in alive if p not in wolves]

        if len(alive_wolves) == 0 or len(alive_wolves) >= len(alive_villagers):
            break

        # Day: eliminate random player
        target = random.choice(alive)
        is_wolf = target in wolves
        alive.remove(target)

        # Update beliefs after elimination reveal
        beliefs[target] = 1.0 if is_wolf else 0.0
        remaining = [i for i in alive if beliefs[i] not in (0.0, 1.0)]
        known_wolf_count = sum(1 for i in range(n) if beliefs[i] == 1.0)
        remaining_wolves_est = k - known_wolf_count

        if remaining and remaining_wolves_est >= 0:
            for i in remaining:
                beliefs[i] = max(0, min(1, remaining_wolves_est / len(remaining)))

        round_num += 1
        rounds.append(round_num)
        entropies.append(sum(binary_entropy(beliefs[i]) for i in alive))
        max_beliefs_list.append(max(beliefs[i] for i in alive) if alive else 0)

        # Check win
        alive_wolves = [p for p in alive if p in wolves]
        alive_villagers = [p for p in alive if p not in wolves]
        if len(alive_wolves) == 0 or len(alive_wolves) >= len(alive_villagers):
            break

        # Night: wolves kill a villager
        if alive_villagers:
            victim = random.choice(alive_villagers)
            alive.remove(victim)
            beliefs[victim] = 0.0

            remaining = [i for i in alive if beliefs[i] not in (0.0, 1.0)]
            if remaining and remaining_wolves_est >= 0:
                for i in remaining:
                    beliefs[i] = max(0, min(1, remaining_wolves_est / len(remaining)))

            round_num += 1
            rounds.append(round_num)
            entropies.append(sum(binary_entropy(beliefs[i]) for i in alive))
            max_beliefs_list.append(max(beliefs[i] for i in alive) if alive else 0)

    return rounds, entropies, max_beliefs_list


fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot multiple game simulations
ax1 = axes[0]
colors = plt.cm.viridis(np.linspace(0, 0.9, 5))
configs = [(7, 2), (9, 3), (11, 3), (13, 4), (15, 5)]

for i, (n, k) in enumerate(configs):
    rounds, entropies, _ = simulate_game_entropy(n, k, seed=42 + i)
    max_entropy = n * math.log(2)
    normalized = [e / max_entropy for e in entropies]
    ax1.plot(rounds, normalized, 'o-', color=colors[i],
             label=f'n={n}, k={k}', linewidth=2, markersize=5)

ax1.set_xlabel('Round', fontsize=13)
ax1.set_ylabel('Normalized Entropy (H / n·ln2)', fontsize=13)
ax1.set_title('Entropy Decrease During Games\n(Information Gain)', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(-0.05, 1.05)

# Plot entropy bound verification
ax2 = axes[1]
ns = list(range(5, 21))
for k in [1, 2, 3]:
    initial_entropies = []
    bounds = []
    for n in ns:
        if k < n // 2:
            prior = k / n
            h = n * binary_entropy(prior)
            bound = n * math.log(2)
            initial_entropies.append(h)
            bounds.append(bound)
        else:
            initial_entropies.append(None)
            bounds.append(None)

    valid = [(n, e, b) for n, e, b in zip(ns, initial_entropies, bounds)
             if e is not None]
    if valid:
        vn, ve, vb = zip(*valid)
        ax2.plot(vn, ve, 'o-', label=f'H(prior), k={k}', linewidth=2)

ax2.plot(ns, [n * math.log(2) for n in ns], 'k--',
         label='n·ln(2) (upper bound)', linewidth=2)

ax2.set_xlabel('Number of Players (n)', fontsize=13)
ax2.set_ylabel('Shannon Entropy', fontsize=13)
ax2.set_title('Entropy Bound Verification\n(Theorem: H ≤ n·ln(2))', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_entropy_evolution.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_evolution.png")
