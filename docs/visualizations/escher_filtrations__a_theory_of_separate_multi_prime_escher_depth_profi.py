#!/usr/bin/env python3
"""
Visualization: Multi-Prime Escher Depth Profile

Shows the p-adic valuation (Escher depth) of integers 1-100 across
three different prime filtrations (p=2, 3, 5). Each subplot shows
how deeply each integer penetrates the corresponding Escher filtration.

The key insight: every nonzero integer has FINITE depth in every
prime filtration (vanishing core theorem), but the depth profiles
are independent across different primes — reflecting the independence
of prime Escher filtrations.
"""

import numpy as np
import matplotlib.pyplot as plt


def p_adic_valuation(x: int, p: int) -> int:
    """Compute v_p(x)."""
    if x == 0:
        return 0
    x = abs(x)
    v = 0
    while x % p == 0:
        v += 1
        x //= p
    return v


# Parameters
max_x = 120
primes = [2, 3, 5]
colors = ['#e94560', '#0f3460', '#16c79a']
x_values = list(range(1, max_x + 1))

fig, axes = plt.subplots(3, 1, figsize=(14, 10), sharex=True)
fig.suptitle("Multi-Prime Escher Depth Profiles\n"
             "Each bar shows how deep an integer sits in the p-adic filtration",
             fontsize=14, fontweight='bold')

for idx, (p, color) in enumerate(zip(primes, colors)):
    ax = axes[idx]
    depths = [p_adic_valuation(x, p) for x in x_values]

    ax.bar(x_values, depths, width=1.0, color=color, alpha=0.8, edgecolor='none')
    ax.set_ylabel(f"v_{p}(x)", fontsize=12)
    ax.set_title(f"Escher depth in ({p}ⁿ)ℤ filtration", fontsize=11)

    # Highlight maximum depth elements
    max_depth = max(depths)
    for x, d in zip(x_values, depths):
        if d == max_depth:
            ax.annotate(f"{x}", (x, d), textcoords="offset points",
                       xytext=(0, 5), ha='center', fontsize=7, color='black')

    ax.set_ylim(0, max_depth + 1)
    ax.grid(axis='y', alpha=0.3)

axes[-1].set_xlabel("Integer x", fontsize=12)

# Add annotation about vanishing core
fig.text(0.5, 0.01,
         "Vanishing Core Theorem: Every bar has finite height — no nonzero integer has infinite depth.",
         ha='center', fontsize=10, style='italic', color='#333333')

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig("viz_depth_profile.png", dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_depth_profile.png")
