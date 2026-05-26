#!/usr/bin/env python3
"""
Visualization: Refinement Ladder and Monotonicity

Visualizes the certificate refinement process: starting from a coarse
certificate and iteratively splitting the worst torus type. The global
bound decreases monotonically at each step (proven formally as
globalBound_mono_under_refinement).

SELF-CONTAINED: All functions are inlined. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

# ─── Inline certificate logic ───────────────────────────────────────────────

def generate_certificate(num_types, max_bound, seed=42):
    rng = random.Random(seed)
    bounds = [rng.uniform(0.05, max_bound) for _ in range(num_types)]
    complexities = [rng.randint(1, 50) for _ in range(num_types)]
    return bounds, complexities

def refine_step(bounds, complexities, rng):
    """Split the worst torus type into 3 subtypes with reduced bounds."""
    argmax = bounds.index(max(bounds))
    worst = bounds[argmax]
    worst_c = complexities[argmax]

    new_bounds = list(bounds)
    new_complexities = list(complexities)
    new_bounds.pop(argmax)
    new_complexities.pop(argmax)

    for i in range(3):
        new_bounds.append(worst * rng.uniform(0.7, 0.95))
        new_complexities.append(worst_c + i + 1)

    return new_bounds, new_complexities

# ─── Generate refinement ladder data ────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

for idx, (lie_type, n_types, color) in enumerate([
    ("F₄", 25, "#2196F3"),
    ("E₆", 25, "#4CAF50"),
    ("E₇", 60, "#FF9800"),
    ("E₈", 112, "#F44336"),
]):
    ax = axes[idx // 2][idx % 2]
    rng = random.Random(42 + idx)

    bounds, complexities = generate_certificate(n_types, 0.8, seed=42+idx)
    global_bounds = [max(bounds)]
    num_types_history = [len(bounds)]
    margin_history = [1.0 - max(bounds)]

    for step in range(12):
        bounds, complexities = refine_step(bounds, complexities, rng)
        global_bounds.append(max(bounds))
        num_types_history.append(len(bounds))
        margin_history.append(1.0 - max(bounds))

    steps = list(range(len(global_bounds)))

    # Plot global bound
    ax.plot(steps, global_bounds, 'o-', color=color, linewidth=2.5, markersize=7,
            label='Global bound', zorder=3)
    ax.fill_between(steps, global_bounds, alpha=0.15, color=color)

    # Plot safety margin
    ax.plot(steps, margin_history, 's--', color='gray', linewidth=1.5, markersize=5,
            label='Safety margin', alpha=0.7)

    ax.axhline(y=1.0, color='black', linestyle=':', alpha=0.3)
    ax.set_xlabel("Refinement step", fontsize=11)
    ax.set_ylabel("Bound value", fontsize=11)
    ax.set_title(f"{lie_type}: Refinement Ladder ({n_types} initial types)", fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.2)

    # Annotate monotonicity
    for i in range(1, len(global_bounds)):
        if global_bounds[i] <= global_bounds[i-1]:
            pass  # All steps should satisfy this
        else:
            ax.annotate("VIOLATION!", (i, global_bounds[i]), color='red', fontsize=8)

plt.suptitle("Certificate Refinement Monotonicity\n(globalBound decreases at each step — formally proven)",
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig("refinement_ladder_visualization.png", dpi=150, bbox_inches='tight')
print("Saved: refinement_ladder_visualization.png")
