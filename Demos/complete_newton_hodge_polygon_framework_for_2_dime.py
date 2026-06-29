#!/usr/bin/env python3
"""
Newton-Hodge Polygon Framework: Numerical Demonstrations

Demonstrates the key theorems about the monodromy defect δ as the
universal parameter for 2-dimensional filtered φ-modules.
"""

import math


def defect(w1, w2, s1, s2):
    """Monodromy defect δ = s₁ - w₁."""
    return s1 - w1


def hodge_gap(w1, w2):
    """Hodge gap γ = w₂ - w₁."""
    return w2 - w1


def newton_spread(s1, s2):
    """Newton spread σ = s₂ - s₁."""
    return s2 - s1


def hodge_polygon(w1, w2, x):
    """Hodge polygon H(x) on [0, 2]."""
    if x <= 1:
        return w1 * x
    else:
        return w1 + w2 * (x - 1)


def newton_polygon(s1, s2, x):
    """Newton polygon N(x) on [0, 2]."""
    if x <= 1:
        return s1 * x
    else:
        return s1 + s2 * (x - 1)


def polygon_gap(w1, w2, s1, s2, x):
    """Gap function G(x) = N(x) - H(x)."""
    return newton_polygon(s1, s2, x) - hodge_polygon(w1, w2, x)


def tropical_dist(m1, m2):
    """Tropical distance |δ₁ - δ₂|."""
    d1 = defect(*m1)
    d2 = defect(*m2)
    return abs(d1 - d2)


def classify(w1, w2, s1, s2, tol=1e-12):
    """Classify module as ordinary, supersingular, or generic."""
    d = defect(w1, w2, s1, s2)
    g = hodge_gap(w1, w2)
    if abs(d) < tol:
        return "ordinary"
    elif abs(d - g / 2) < tol:
        return "supersingular"
    else:
        return "generic"


def reconstruct_from_defect(w1, w2, delta):
    """Reconstruct Newton slopes from Hodge weights and defect."""
    s1 = w1 + delta
    s2 = w2 - delta
    return s1, s2


# ============================================================
# DEMONSTRATIONS
# ============================================================

print("=" * 60)
print("Newton-Hodge Polygon Framework: Key Theorem Demonstrations")
print("=" * 60)

# Demo 1: Defect Symmetry
print("\n--- Demo 1: Defect Symmetry (δ = s₁ - w₁ = w₂ - s₂) ---")
examples = [
    (0, 4, 1, 3),   # generic
    (0, 6, 0, 6),   # ordinary
    (0, 6, 3, 3),   # supersingular
    (1, 5, 2, 4),   # generic
    (-2, 8, 1, 5),  # generic
]

for w1, w2, s1, s2 in examples:
    d = defect(w1, w2, s1, s2)
    d_sym = w2 - s2
    assert abs(d - d_sym) < 1e-12, "Defect symmetry failed!"
    print(f"  w=({w1},{w2}), s=({s1},{s2}): δ = s₁-w₁ = {d:.2f}, w₂-s₂ = {d_sym:.2f} ✓")

# Demo 2: Discriminant Formula
print("\n--- Demo 2: Discriminant Formula (σ = γ - 2δ) ---")
for w1, w2, s1, s2 in examples:
    d = defect(w1, w2, s1, s2)
    g = hodge_gap(w1, w2)
    ns = newton_spread(s1, s2)
    pred = g - 2 * d
    assert abs(ns - pred) < 1e-12, "Discriminant formula failed!"
    print(f"  w=({w1},{w2}), s=({s1},{s2}): σ={ns:.2f}, γ-2δ={pred:.2f} ✓")

# Demo 3: Classification
print("\n--- Demo 3: Module Classification ---")
for w1, w2, s1, s2 in examples:
    cls = classify(w1, w2, s1, s2)
    d = defect(w1, w2, s1, s2)
    g = hodge_gap(w1, w2)
    print(f"  w=({w1},{w2}), s=({s1},{s2}): δ={d:.2f}, γ/2={g/2:.2f} → {cls}")

# Demo 4: Polygon Gap (Tent Function)
print("\n--- Demo 4: Polygon Gap (Tent Function) ---")
w1, w2, s1, s2 = 0, 4, 1, 3
d = defect(w1, w2, s1, s2)
print(f"  Module: w=({w1},{w2}), s=({s1},{s2}), δ={d}")
for x in [0.0, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]:
    g = polygon_gap(w1, w2, s1, s2, x)
    expected = d * x if x <= 1 else d * (2 - x)
    assert abs(g - expected) < 1e-12, f"Gap mismatch at x={x}"
    print(f"  G({x:.2f}) = {g:.4f} (tent: {expected:.4f}) ✓")

# Demo 5: Tropical Metric
print("\n--- Demo 5: Tropical Metric Properties ---")
m1 = (0, 6, 1, 5)  # δ₁ = 1
m2 = (0, 6, 2, 4)  # δ₂ = 2
m3 = (0, 6, 3, 3)  # δ₃ = 3

d12 = tropical_dist(m1, m2)
d23 = tropical_dist(m2, m3)
d13 = tropical_dist(m1, m3)
print(f"  d(M₁,M₂) = {d12:.2f}")
print(f"  d(M₂,M₃) = {d23:.2f}")
print(f"  d(M₁,M₃) = {d13:.2f}")
print(f"  Triangle inequality: {d13:.2f} ≤ {d12:.2f} + {d23:.2f} = {d12+d23:.2f} ✓")
assert d13 <= d12 + d23 + 1e-12

# Demo 6: Defect Rigidity
print("\n--- Demo 6: Defect Rigidity ---")
w1, w2 = 0, 10
for delta in [0, 1, 2, 3, 4, 5]:
    s1, s2 = reconstruct_from_defect(w1, w2, delta)
    d_check = defect(w1, w2, s1, s2)
    assert abs(d_check - delta) < 1e-12
    assert abs(s1 + s2 - w1 - w2) < 1e-12
    assert s1 <= s2 + 1e-12
    print(f"  δ={delta} → s=({s1:.1f},{s2:.1f}), "
          f"class={classify(w1, w2, s1, s2)}")

# Demo 7: Normalized Defect
print("\n--- Demo 7: Normalized Defect Range [0, 1/2] ---")
w1, w2 = 0, 8
g = hodge_gap(w1, w2)
for delta in [0, 0.5, 1, 2, 3, 4]:
    s1, s2 = reconstruct_from_defect(w1, w2, delta)
    d_norm = delta / g if g > 0 else 0
    print(f"  δ={delta:.1f}, δ_norm={d_norm:.4f} ∈ [0, 0.5] ✓")
    assert 0 <= d_norm <= 0.5 + 1e-12

print("\n" + "=" * 60)
print("All demonstrations passed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Newton-Hodge Polygons and Gap Functions

Generates plots showing the Newton and Hodge polygons for various
defect values, the tent-shaped gap function, and the admissibility
interval parameterized by the defect.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def hodge_polygon(w1: float, w2: float, x: np.ndarray) -> np.ndarray:
    return np.where(x <= 1, w1 * x, w1 + w2 * (x - 1))


def newton_polygon(s1: float, s2: float, x: np.ndarray) -> np.ndarray:
    return np.where(x <= 1, s1 * x, s1 + s2 * (x - 1))


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    x = np.linspace(0, 2, 500)

    # --- Panel 1: Three polygon pairs ---
    ax = axes[0, 0]
    w1, w2 = 0, 6
    configs = [
        (0, 6, "Ordinary (δ=0)", "C0"),
        (1.5, 4.5, "Generic (δ=1.5)", "C1"),
        (3, 3, "Supersingular (δ=3)", "C2"),
    ]
    ax.plot(x, hodge_polygon(w1, w2, x), "k-", linewidth=2.5, label="Hodge")
    for s1, s2, label, color in configs:
        ax.plot(x, newton_polygon(s1, s2, x), "--", color=color, linewidth=1.8, label=label)
    ax.set_xlabel("x")
    ax.set_ylabel("Polygon value")
    ax.set_title("Newton vs Hodge Polygons (w=(0,6))")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Gap (tent) functions ---
    ax = axes[0, 1]
    for delta in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        s1, s2 = w1 + delta, w2 - delta
        gap = newton_polygon(s1, s2, x) - hodge_polygon(w1, w2, x)
        ax.plot(x, gap, linewidth=1.5, label=f"δ={delta:.1f}")
    ax.set_xlabel("x")
    ax.set_ylabel("G(x) = N(x) - H(x)")
    ax.set_title("Polygon Gap (Tent Functions)")
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Defect vs Newton spread ---
    ax = axes[1, 0]
    deltas = np.linspace(0, 3, 100)
    gamma = w2 - w1
    spreads = gamma - 2 * deltas
    ax.plot(deltas, spreads, "b-", linewidth=2)
    ax.axhline(y=0, color="gray", linestyle=":", alpha=0.5)
    ax.fill_between(deltas, 0, spreads, alpha=0.15, color="blue")
    ax.plot(0, gamma, "go", markersize=10, label="Ordinary (δ=0, σ=γ)")
    ax.plot(gamma / 2, 0, "rs", markersize=10, label="Supersingular (δ=γ/2, σ=0)")
    ax.set_xlabel("Defect δ")
    ax.set_ylabel("Newton spread σ")
    ax.set_title("Discriminant Formula: σ = γ − 2δ")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # --- Panel 4: Admissibility interval as tropical space ---
    ax = axes[1, 1]
    ax.set_xlim(-0.5, 4)
    ax.set_ylim(-0.5, 2)
    # Draw the interval [0, γ/2]
    ax.plot([0, gamma / 2], [1, 1], "k-", linewidth=4)
    ax.plot(0, 1, "go", markersize=14, zorder=5)
    ax.plot(gamma / 2, 1, "rs", markersize=14, zorder=5)
    # Mark some interior points
    for d in [0.5, 1.0, 1.5, 2.0, 2.5]:
        ax.plot(d, 1, "ko", markersize=6, zorder=4)
        ax.annotate(f"δ={d}", (d, 1), textcoords="offset points",
                    xytext=(0, 12), ha="center", fontsize=8)
    ax.annotate("Ordinary\n(δ=0)", (0, 1), textcoords="offset points",
                xytext=(0, -25), ha="center", fontsize=9, color="green")
    ax.annotate(f"Supersingular\n(δ={gamma/2:.0f})", (gamma / 2, 1),
                textcoords="offset points", xytext=(0, -25),
                ha="center", fontsize=9, color="red")
    ax.set_title("Admissibility Space (Tropical Interval)")
    ax.set_xlabel("Defect δ (tropical coordinate)")
    ax.set_yticks([])
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("newton_hodge_polygons.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved newton_hodge_polygons.png")


if __name__ == "__main__":
    main()
