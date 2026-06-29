#!/usr/bin/env python3
"""
Dimensional Gravity: The Goldilocks Theorem — Interactive Demo

Demonstrates the key results:
1. Dimension scan showing why only n=3 works
2. Bertrand classification of force-law exponents
3. Effective potential visualization data
4. Apsidal angle analysis
"""

from algorithms import (
    goldilocks_scan,
    classify_bertrand_exponents,
    effective_potential,
    find_circular_orbit_radius,
    apsidal_ratio,
    apsidal_angle,
    is_goldilocks_dimension,
)
import math


def demo_goldilocks_scan():
    """Demonstrate the Goldilocks theorem by scanning dimensions."""
    print("=" * 70)
    print("THE GOLDILOCKS THEOREM: Which dimensions support viable solar systems?")
    print("=" * 70)
    print()

    results = goldilocks_scan(10)

    print(f"{'Dim':>4} | {'Stable':>7} | {'Closed':>7} | {'Escape':>7} | "
          f"{'Goldilocks':>10} | {'ρ(n)':>8} | {'Ψ (deg)':>10}")
    print("-" * 70)

    for r in results:
        dim = r["dimension"]
        stable = "✓" if r["stable"] else "✗"
        closed = "✓" if r["closed"] else "✗"
        escape = "✓" if r["finite_escape"] else "✗"
        gold = "★ YES ★" if r["goldilocks"] else "no"
        rho = f"{r['apsidal_ratio']:.4f}" if isinstance(r['apsidal_ratio'], float) else str(r['apsidal_ratio'])
        angle = r["apsidal_angle_deg"]
        angle_str = f"{angle:.2f}°" if isinstance(angle, float) else str(angle)

        print(f"{dim:>4} | {stable:>7} | {closed:>7} | {escape:>7} | "
              f"{gold:>10} | {rho:>8} | {angle_str:>10}")

    print()
    print("Result: Only dimension 3 satisfies ALL THREE conditions.")
    print("  • n=1,2: Orbits don't close (√3, √2 are irrational)")
    print("  • n=1,2: Escape velocity is infinite")
    print("  • n≥4: No stable orbits exist")
    print()


def demo_bertrand_classification():
    """Demonstrate Bertrand's theorem for integer force exponents."""
    print("=" * 70)
    print("BERTRAND'S THEOREM: Which force laws give closed orbits?")
    print("=" * 70)
    print()

    results = classify_bertrand_exponents(-3, 5)

    print(f"{'α':>4} | {'F(r)':>30} | {'√(3+α)':>8} | {'Rational':>9} | {'Status':>10}")
    print("-" * 70)

    for alpha, info in sorted(results.items()):
        force = info["force_type"]
        rho = f"{info['apsidal_ratio']:.4f}"
        rational = "✓" if info["rational"] else "✗"
        status = info["status"]

        print(f"{alpha:>4} | {force:>30} | {rho:>8} | {rational:>9} | {status:>10}")

    print()
    print("Only α = -2 (gravity) and α = 1 (spring) give closed orbits.")
    print("This is Bertrand's theorem (1873), here derived from number theory.")
    print()


def demo_effective_potential():
    """Show effective potential structure across dimensions."""
    print("=" * 70)
    print("EFFECTIVE POTENTIAL STRUCTURE")
    print("=" * 70)
    print()

    for n in [2, 3, 4, 5]:
        r0 = find_circular_orbit_radius(n)
        rho = apsidal_ratio(n)

        print(f"Dimension n = {n}:")
        if r0 is not None:
            v_min = effective_potential(r0, n)
            print(f"  Circular orbit radius:  r₀ = {r0:.4f}")
            print(f"  V_eff(r₀) = {v_min:.6f}")
            print(f"  Apsidal ratio ρ = {rho:.6f}")
            if rho > 0:
                psi = math.degrees(math.pi / rho)
                print(f"  Apsidal angle Ψ = {psi:.2f}°")
                print(f"  Orbits close: {'YES' if abs(rho - round(rho)) < 1e-10 else 'NO'}")
        else:
            print("  No stable circular orbit exists!")
        print()


def demo_number_theory_bridge():
    """Demonstrate the number theory connection."""
    print("=" * 70)
    print("NUMBER THEORY GOVERNS DIMENSIONAL PHYSICS")
    print("=" * 70)
    print()
    print("The viability of dimension n reduces to: Is √(4-n) rational?")
    print()

    for n in range(1, 4):
        arg = 4 - n
        sqrt_val = math.sqrt(arg)
        # Check rationality
        is_rational = abs(sqrt_val - round(sqrt_val)) < 1e-10

        print(f"  n = {n}: √(4-{n}) = √{arg} = {sqrt_val:.10f}")
        if is_rational:
            print(f"         = {int(round(sqrt_val))} (RATIONAL) → Orbits close ✓")
        else:
            if arg == 2:
                print(f"         ≈ 1.414... (IRRATIONAL, proved ~500 BCE) → Orbits don't close ✗")
            elif arg == 3:
                print(f"         ≈ 1.732... (IRRATIONAL, 3 is prime) → Orbits don't close ✗")
        print()

    print("Ancient number theory (irrationality of √2 and √3) determines")
    print("which universes can have stable planetary systems!")
    print()


def demo_apsidal_angle_visualization_data():
    """Generate data for apsidal angle visualization."""
    print("=" * 70)
    print("APSIDAL ANGLE DATA (for plotting)")
    print("=" * 70)
    print()

    # Continuous dimension parameter (for conceptual plotting)
    print("n (continuous) | ρ(n) = √(4-n) | Ψ = π/ρ (degrees)")
    print("-" * 55)
    for n_10 in range(5, 40):
        n = n_10 / 10.0
        arg = 4 - n
        if arg > 0:
            rho = math.sqrt(arg)
            psi = math.degrees(math.pi / rho) if rho > 0 else float('inf')
            print(f"  {n:>5.1f}         | {rho:>12.6f}   | {psi:>10.2f}°")
    print()


if __name__ == "__main__":
    demo_goldilocks_scan()
    demo_bertrand_classification()
    demo_effective_potential()
    demo_number_theory_bridge()
    demo_apsidal_angle_visualization_data()


#!/usr/bin/env python3
"""
Visualization: Bertrand's Theorem — Force Law Classification

Shows the apsidal ratio √(3+α) as a function of force-law exponent α,
highlighting the two rational values (α=-2 and α=1) predicted by
Bertrand's theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


fig, ax = plt.subplots(figsize=(12, 7))

# Continuous curve
alpha_cont = np.linspace(-2.9, 6, 1000)
beta_cont = np.sqrt(np.maximum(3 + alpha_cont, 0))

ax.plot(alpha_cont, beta_cont, 'b-', linewidth=2, alpha=0.4,
        label='β(α) = √(3+α)')

# Integer points
for alpha in range(-3, 6):
    arg = 3 + alpha
    if arg < 0:
        continue
    beta = math.sqrt(arg)
    is_rational = abs(beta - round(beta)) < 1e-10

    if is_rational:
        ax.plot(alpha, beta, 'o', color='#4CAF50', markersize=15,
                markeredgecolor='black', markeredgewidth=2, zorder=5)
        label = f'α={alpha}: β={int(round(beta))}'
        if alpha == -2:
            label += '\n(inverse-square law)'
        elif alpha == 1:
            label += '\n(linear spring)'
        ax.annotate(label, (alpha, beta),
                    textcoords="offset points", xytext=(15, 10),
                    fontsize=11, fontweight='bold', color='#2E7D32',
                    arrowprops=dict(arrowstyle='->', color='#2E7D32'))
    else:
        ax.plot(alpha, beta, 's', color='#F44336', markersize=10,
                markeredgecolor='black', markeredgewidth=1, zorder=5)
        irr_name = {2: '√2', 3: '√3', 5: '√5', 6: '√6', 7: '√7', 8: '√8'}
        name = irr_name.get(arg, f'√{arg}')
        ax.annotate(f'α={alpha}: {name}', (alpha, beta),
                    textcoords="offset points", xytext=(15, -15),
                    fontsize=9, color='#C62828')

# Degenerate case
ax.plot(-3, 0, 'D', color='#9E9E9E', markersize=10,
        markeredgecolor='black', markeredgewidth=1, zorder=5)
ax.annotate('α=-3: degenerate\n(β=0)', (-3, 0),
            textcoords="offset points", xytext=(15, 15),
            fontsize=9, color='gray')

ax.set_xlabel('Force-law exponent α  (F ∝ r^α)', fontsize=14)
ax.set_ylabel('Apsidal ratio β(α) = √(3+α)', fontsize=14)
ax.set_title("Bertrand's Theorem: Only Two Force Laws Give Closed Orbits",
             fontsize=16, fontweight='bold')

ax.axhline(y=0, color='gray', linewidth=0.5)
ax.axvline(x=-3, color='gray', linewidth=0.5, linestyle='--', alpha=0.5)

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='#4CAF50',
           markersize=12, markeredgecolor='black', label='Rational β → Closed orbits'),
    Line2D([0], [0], marker='s', color='w', markerfacecolor='#F44336',
           markersize=10, markeredgecolor='black', label='Irrational β → Open orbits'),
]
ax.legend(handles=legend_elements, loc='upper left', fontsize=12)

ax.set_xlim(-3.5, 5.5)
ax.set_ylim(-0.3, 3.5)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('bertrand_classification.png', dpi=150, bbox_inches='tight')
print("Saved bertrand_classification.png")


#!/usr/bin/env python3
"""
Visualization: Effective Potential Across Dimensions

Shows how the effective radial potential V_eff(r) changes with spatial
dimension, illustrating the stability transition at n=4.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def effective_potential(r, n, L=1.0, k=1.0):
    """Compute effective potential for dimension n."""
    centrifugal = L**2 / (2 * r**2)
    if n == 1:
        gravitational = k * r
    elif n == 2:
        gravitational = -k * np.log(r)
    else:
        gravitational = -k / ((n - 2) * r**(n - 2))
    return centrifugal + gravitational


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
axes = axes.flatten()

dimensions = [1, 2, 3, 4, 5, 6]
colors = ['#E91E63', '#FF5722', '#4CAF50', '#9E9E9E', '#607D8B', '#455A64']
titles = [
    'n=1: Stable min, but √3 irrational',
    'n=2: Stable min, but √2 irrational',
    'n=3: Stable min, √1=1 rational ★',
    'n=4: No minimum (marginal)',
    'n=5: Unstable maximum only',
    'n=6: Unstable maximum only',
]

for idx, (n, color, title) in enumerate(zip(dimensions, colors, titles)):
    ax = axes[idx]

    r = np.linspace(0.3, 5.0, 500)
    V = np.array([effective_potential(ri, n) for ri in r])

    # Clip for visibility
    V_clipped = np.clip(V, -3, 5)

    ax.plot(r, V_clipped, color=color, linewidth=2.5)
    ax.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax.set_xlim(0.3, 5.0)
    ax.set_ylim(-3, 5)
    ax.set_xlabel('r', fontsize=11)
    ax.set_ylabel('V_eff(r)', fontsize=11)
    ax.set_title(title, fontsize=11, fontweight='bold')

    # Mark minimum if it exists
    if n < 4:
        V_min_idx = np.argmin(V_clipped)
        ax.plot(r[V_min_idx], V_clipped[V_min_idx], 'o', color='black',
                markersize=8, zorder=5)
        ax.annotate('stable\nminimum', (r[V_min_idx], V_clipped[V_min_idx]),
                    textcoords="offset points", xytext=(20, 10),
                    fontsize=9, ha='center')

    if n == 3:
        ax.patch.set_facecolor('#E8F5E9')

fig.suptitle('Effective Potential V_eff(r) Across Spatial Dimensions',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('effective_potentials.png', dpi=150, bbox_inches='tight')
print("Saved effective_potentials.png")


#!/usr/bin/env python3
"""
Visualization: The Goldilocks Theorem — Dimension Scan

Creates a bar chart showing the three conditions (stability, closure,
finite escape velocity) across dimensions 1-8, highlighting that only
dimension 3 satisfies all three.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def apsidal_ratio(n):
    arg = 4 - n
    if arg <= 0:
        return 0.0
    return math.sqrt(arg)

def is_orbit_closed(n):
    arg = 4 - n
    if arg < 0:
        return False
    if arg == 0:
        return True
    sqrt_val = int(math.isqrt(arg))
    return sqrt_val * sqrt_val == arg

def has_stable_orbits(n):
    return n < 4

def has_finite_escape_velocity(n):
    return n >= 3

def is_goldilocks(n):
    return has_stable_orbits(n) and is_orbit_closed(n) and has_finite_escape_velocity(n) and n >= 1


dims = list(range(1, 9))
n_dims = len(dims)

stable = [has_stable_orbits(n) for n in dims]
closed = [is_orbit_closed(n) for n in dims]
escape = [has_finite_escape_velocity(n) for n in dims]
gold = [is_goldilocks(n) for n in dims]

fig, ax = plt.subplots(figsize=(12, 6))

x = np.arange(n_dims)
width = 0.25

colors_stable = ['#4CAF50' if s else '#FFCDD2' for s in stable]
colors_closed = ['#2196F3' if c else '#FFCDD2' for c in closed]
colors_escape = ['#FF9800' if e else '#FFCDD2' for e in escape]

bars1 = ax.bar(x - width, [1 if s else 0.3 for s in stable], width,
               color=colors_stable, edgecolor='black', linewidth=0.5, label='Stable orbits (n < 4)')
bars2 = ax.bar(x, [1 if c else 0.3 for c in closed], width,
               color=colors_closed, edgecolor='black', linewidth=0.5, label='Closed orbits (√(4-n) ∈ ℚ)')
bars3 = ax.bar(x + width, [1 if e else 0.3 for e in escape], width,
               color=colors_escape, edgecolor='black', linewidth=0.5, label='Finite escape (n ≥ 3)')

# Highlight dimension 3
for i, g in enumerate(gold):
    if g:
        ax.axvspan(i - 0.45, i + 0.45, alpha=0.15, color='gold', zorder=0)
        ax.text(i, 1.1, '★ GOLDILOCKS ★', ha='center', fontsize=12,
                fontweight='bold', color='#D4AF37')

ax.set_xlabel('Spatial Dimension n', fontsize=14)
ax.set_ylabel('Condition Satisfied', fontsize=14)
ax.set_title('The Goldilocks Theorem: Only Dimension 3 Supports Viable Solar Systems',
             fontsize=16, fontweight='bold')
ax.set_xticks(x)
ax.set_xticklabels([str(d) for d in dims], fontsize=12)
ax.set_ylim(0, 1.3)
ax.set_yticks([0.3, 1.0])
ax.set_yticklabels(['✗', '✓'], fontsize=14)
ax.legend(loc='upper right', fontsize=10)

plt.tight_layout()
plt.savefig('goldilocks_scan.png', dpi=150, bbox_inches='tight')
print("Saved goldilocks_scan.png")
