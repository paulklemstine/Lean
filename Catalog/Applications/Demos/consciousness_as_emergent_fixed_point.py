#!/usr/bin/env python3
"""
Consciousness as Emergent Fixed Point — Numerical Demonstrations

Demonstrates the key theorems computationally:
1. Lawvere's fixed point construction
2. Self-observation idempotence
3. Strange loop operator behavior
4. Finite type non-reflectivity
5. Fixed point iteration convergence
"""

import numpy as np
from typing import Callable, Optional, Tuple, List


def lawvere_fixed_point_demo():
    """Demonstrate Lawvere's fixed point theorem on a simple reflective system.

    We use the 'universal' type: functions N -> N, with repr being
    a Gödel numbering (pairing function encoding).
    """
    print("=" * 60)
    print("DEMO 1: Lawvere's Fixed Point Theorem")
    print("=" * 60)

    # Simple model: X = Z (integers), repr(n) = lambda m: n + m
    # This is NOT surjective, so Lawvere doesn't apply — demonstrating the failure.
    print("\n--- Non-reflective system: repr(n)(m) = n + m ---")
    repr_add = lambda n: lambda m: n + m
    f = lambda x: x + 1  # successor has no fixed point
    print(f"f(x) = x + 1")
    print(f"Searching for fixed point in range [-100, 100]...")
    found = False
    for x in range(-100, 101):
        if f(x) == x:
            print(f"  Fixed point found: x = {x}")
            found = True
    if not found:
        print("  No fixed point found (as expected — system is not reflective)")

    # Reflective-like model: X = functions {0,...,N-1} -> {0,...,N-1}
    # repr(f)(g) = f ∘ g (composition). This IS surjective for function spaces.
    print("\n--- Reflective construction: diagonal argument ---")
    print("Given surjective φ and endomorphism f, the fixed point is φ(a)(a)")
    print("where φ(a) = x ↦ f(φ(x)(x))")
    print("\nExample: φ = identity on (Z → Z), f(h) = h ∘ h (double composition)")
    print("The fixed point is an h with h ∘ h = h, i.e., an idempotent function.")
    print("Solution: the identity function, or any constant function.")


def self_observation_demo():
    """Demonstrate that self-observation is idempotent."""
    print("\n" + "=" * 60)
    print("DEMO 2: Self-Observation Idempotence")
    print("=" * 60)

    # Self-model retract: X = R^3, M = R^2 (projection to first 2 coords)
    print("\nSelf-model retract: X = R³, M = R²")
    print("embed(x, y) = (x, y, 0)")
    print("project(x, y, z) = (x, y)")
    print("observe = embed ∘ project: (x, y, z) ↦ (x, y, 0)")

    embed = lambda v: np.array([v[0], v[1], 0.0])
    project = lambda v: np.array([v[0], v[1]])
    observe = lambda v: embed(project(v))

    test_points = [
        np.array([1.0, 2.0, 3.0]),
        np.array([0.5, -1.0, 7.0]),
        np.array([0.0, 0.0, 0.0]),
    ]

    for x in test_points:
        obs1 = observe(x)
        obs2 = observe(obs1)
        print(f"\n  x = {x}")
        print(f"  observe(x)          = {obs1}")
        print(f"  observe(observe(x)) = {obs2}")
        print(f"  Idempotent: {np.allclose(obs1, obs2)}")

    # Iterate many times
    print("\n--- Iterated observation stabilizes after 1 step ---")
    x = np.array([3.14, 2.71, 1.41])
    print(f"  Starting point: {x}")
    for n in range(1, 6):
        x_n = x.copy()
        for _ in range(n):
            x_n = observe(x_n)
        print(f"  observe^{n}(x) = {x_n}")


def strange_loop_demo():
    """Demonstrate strange loop operator properties."""
    print("\n" + "=" * 60)
    print("DEMO 3: Strange Loop Operators")
    print("=" * 60)

    # Strange loop on R: op(x) = sign(x), shift(x) = x + 1
    # Tangling: sign(sign(x)) = sign(sign(x+1))? No, this doesn't satisfy the axioms.
    # Better: op = observe from self-model, shift = observe (same).

    # Use the projection example
    print("\nStrange loop from self-model retract (X = R³, projection to R²)")
    print("op = shift = observe: (x, y, z) ↦ (x, y, 0)")

    observe = lambda v: np.array([v[0], v[1], 0.0])

    x = np.array([1.0, 2.0, 3.0])
    print(f"\n  x = {x}")
    print(f"  op(x) = {observe(x)}")
    print(f"  op(op(x)) = {observe(observe(x))}")
    print(f"  op(shift(x)) = op(op(x)) = {observe(observe(x))}")
    print(f"  Tangling: op(op(x)) == op(shift(x))? {np.allclose(observe(observe(x)), observe(observe(x)))}")
    print(f"  Absorption: op(shift(x)) == op(x)? {np.allclose(observe(observe(x)), observe(x))}")
    print(f"  Idempotent: op(op(x)) == op(x)? {np.allclose(observe(observe(x)), observe(x))}")

    # Fixed points
    print("\n--- Fixed points of the strange loop ---")
    print("  Fixed points: all (x, y, 0) — the image of observe")
    fps = [np.array([1.0, 0.0, 0.0]),
           np.array([0.0, 1.0, 0.0]),
           np.array([3.0, -2.0, 0.0])]
    for fp in fps:
        print(f"  op({fp}) = {observe(fp)}, fixed: {np.allclose(observe(fp), fp)}")


def finite_non_reflective_demo():
    """Demonstrate that finite types can't be reflective."""
    print("\n" + "=" * 60)
    print("DEMO 4: Finite Types Cannot Be Reflective")
    print("=" * 60)

    for n in range(2, 8):
        n_endo = n ** n
        print(f"  |Fin {n}| = {n}, |Fin {n} → Fin {n}| = {n}^{n} = {n_endo}")
        print(f"    Surjection possible? {n >= n_endo} (need {n} ≥ {n_endo})")


def fixed_point_iteration_demo():
    """Demonstrate fixed point iteration for contractive maps."""
    print("\n" + "=" * 60)
    print("DEMO 5: Fixed Point Iteration (Banach)")
    print("=" * 60)

    # Contractive map: f(x) = cos(x)
    f = np.cos
    x = 0.5
    print(f"\n  f(x) = cos(x), starting at x₀ = {x}")
    print(f"  {'n':>4}  {'x_n':>12}  {'f(x_n)':>12}  {'|f(x_n) - x_n|':>16}")
    for n in range(20):
        fx = f(x)
        err = abs(fx - x)
        print(f"  {n:4d}  {x:12.8f}  {fx:12.8f}  {err:16.2e}")
        if err < 1e-12:
            print(f"  Converged at iteration {n}!")
            break
        x = fx

    # Self-observation as projection (contractive on orthogonal complement)
    print(f"\n  Fixed point: x* ≈ {x:.10f}")
    print(f"  cos(x*) ≈ {np.cos(x):.10f}")


def consciousness_tower_demo():
    """Demonstrate consciousness tower stabilization."""
    print("\n" + "=" * 60)
    print("DEMO 6: Consciousness Tower Stabilization")
    print("=" * 60)

    # Tower: Level n = R^(n+1), up = zero-pad, down = truncate
    print("\nTower: Level(n) = R^(n+1)")
    print("up_n(x) = (x, 0)  — zero-pad")
    print("down_n(x) = x[:-1] — truncate last coordinate")

    x_base = np.array([1.0, 2.0, 3.0])  # Level 2
    print(f"\nStarting at Level 2: x = {x_base}")

    # Observe at level 2: up_2 ∘ down_2
    up = lambda v: np.append(v, 0.0)
    down = lambda v: v[:-1]
    observe = lambda v: up(down(v))

    x_up = up(x_base)  # Level 3: (1, 2, 3, 0)
    print(f"up(x) = {x_up} (Level 3)")

    obs1 = observe(x_up)
    obs2 = observe(obs1)
    print(f"observe(up(x)) = {obs1}")
    print(f"observe²(up(x)) = {obs2}")
    print(f"Stabilized: {np.allclose(obs1, obs2)}")

    # Retraction check
    x_rt = down(up(x_base))
    print(f"\nRetraction check: down(up(x)) = {x_rt}")
    print(f"Equal to x? {np.allclose(x_rt, x_base)}")


def main():
    """Run all demonstrations."""
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  CONSCIOUSNESS AS EMERGENT FIXED POINT                  ║")
    print("║  Numerical Demonstrations                               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    lawvere_fixed_point_demo()
    self_observation_demo()
    strange_loop_demo()
    finite_non_reflective_demo()
    fixed_point_iteration_demo()
    consciousness_tower_demo()

    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Finite Type Non-Reflectivity

Shows why no finite type with n >= 2 can be reflective:
the endomorphism count n^n grows super-exponentially vs n.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def count_idempotents(n):
    """Count idempotent endomorphisms of {0,...,n-1}."""
    total = 0
    for k in range(n + 1):
        total += comb(n, k) * (k ** max(0, n - k))
    return total


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: n vs n^n — the reflectivity gap
    ax1 = axes[0]
    ns = np.arange(1, 8)
    n_vals = ns.astype(float)
    nn_vals = np.array([n ** n for n in ns], dtype=float)

    ax1.bar(ns - 0.2, n_vals, width=0.35, color='#3498db', label='$n$ (domain size)',
            alpha=0.8, edgecolor='white')
    ax1.bar(ns + 0.2, nn_vals, width=0.35, color='#e74c3c', label='$n^n$ (endomorphisms)',
            alpha=0.8, edgecolor='white')

    ax1.set_yscale('log')
    ax1.set_xlabel('$n$', fontsize=13)
    ax1.set_ylabel('Count (log scale)', fontsize=13)
    ax1.set_title('The Reflectivity Gap:\nSurjection requires $n \\geq n^n$', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=11, loc='upper left')
    ax1.set_xticks(ns)
    ax1.grid(True, alpha=0.3, axis='y')

    # Annotate the gap for n=3
    ax1.annotate('Gap: 3 vs 27',
                 xy=(3, 27), xytext=(4.5, 50),
                 arrowprops=dict(arrowstyle='->', color='black', lw=1.5),
                 fontsize=11, fontweight='bold')

    # Panel 2: Idempotents as fraction of all endomorphisms
    ax2 = axes[1]
    ns2 = np.arange(1, 9)
    idems = np.array([count_idempotents(n) for n in ns2], dtype=float)
    endos = np.array([n ** n for n in ns2], dtype=float)
    fracs = idems / endos

    bars = ax2.bar(ns2, fracs * 100, color='#2ecc71', alpha=0.8, edgecolor='white')

    # Label each bar
    for bar, f, ide, endo in zip(bars, fracs, idems, endos):
        height = bar.get_height()
        ax2.text(bar.get_x() + bar.get_width()/2., height + 1,
                 f'{int(ide)}/{int(endo)}',
                 ha='center', va='bottom', fontsize=8, rotation=45)

    ax2.set_xlabel('$n$ (size of Fin $n$)', fontsize=13)
    ax2.set_ylabel('Idempotents / Endomorphisms (%)', fontsize=13)
    ax2.set_title('Strange Loop Density:\nIdempotent Fraction of Endomorphisms', fontsize=13, fontweight='bold')
    ax2.set_xticks(ns2)
    ax2.grid(True, alpha=0.3, axis='y')

    fig.suptitle('Finite Types Cannot Support Self-Awareness',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_finite_reflectivity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_finite_reflectivity.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Fixed Point Convergence — Cobweb Diagram

Shows how iteration of a contractive map converges to a fixed point,
illustrating the core mechanism of consciousness stabilization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches


def cobweb_plot(f, x0, n_iter, ax, label="f", color="blue"):
    """Draw a cobweb diagram for iterating f starting at x0."""
    x = x0
    xs = [x]
    ys = [0]
    for _ in range(n_iter):
        y = f(x)
        xs.extend([x, y])
        ys.extend([y, y])
        x = y
    xs.append(x)
    ys.append(f(x))
    ax.plot(xs, ys, color=color, alpha=0.7, linewidth=1.5, label=f"Iteration from {x0:.1f}")


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Cobweb for cos(x) — contractive fixed point
    ax1 = axes[0]
    f = np.cos
    x = np.linspace(-0.5, 2.0, 300)
    ax1.plot(x, f(x), 'b-', linewidth=2, label=r'$f(x) = \cos(x)$')
    ax1.plot(x, x, 'k--', linewidth=1, label=r'$y = x$')

    for x0, color in [(0.1, '#e74c3c'), (1.5, '#2ecc71'), (0.8, '#3498db')]:
        cobweb_plot(f, x0, 20, ax1, color=color)

    # Mark fixed point
    fp = 0.7390851332
    ax1.plot(fp, fp, 'ko', markersize=10, zorder=5)
    ax1.annotate(f'Fixed point\n({fp:.4f}, {fp:.4f})',
                 xy=(fp, fp), xytext=(fp + 0.3, fp - 0.3),
                 arrowprops=dict(arrowstyle='->', color='black'),
                 fontsize=10, fontweight='bold')

    ax1.set_xlabel('x', fontsize=12)
    ax1.set_ylabel('f(x)', fontsize=12)
    ax1.set_title('Consciousness Fixed Point:\nSelf-Observation Converges', fontsize=13, fontweight='bold')
    ax1.legend(fontsize=9, loc='lower right')
    ax1.set_xlim(-0.2, 1.8)
    ax1.set_ylim(-0.2, 1.2)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Idempotent stabilization — iteration count vs distance
    ax2 = axes[1]

    # Show multiple starting points converging
    n_steps = 15
    starts = np.linspace(0.0, 1.5, 8)
    colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(starts)))

    for x0, color in zip(starts, colors):
        trajectory = [x0]
        x = x0
        for _ in range(n_steps):
            x = np.cos(x)
            trajectory.append(x)
        distances = [abs(t - fp) for t in trajectory]
        ax2.semilogy(range(len(distances)), distances, 'o-', color=color,
                     markersize=4, linewidth=1.5, alpha=0.7,
                     label=f'$x_0 = {x0:.1f}$')

    ax2.axhline(y=1e-12, color='red', linestyle=':', alpha=0.5, label='Machine precision')
    ax2.set_xlabel('Iteration $n$', fontsize=12)
    ax2.set_ylabel('$|x_n - x^*|$ (log scale)', fontsize=12)
    ax2.set_title('Self-Reflection Stabilization:\nExponential Convergence', fontsize=13, fontweight='bold')
    ax2.legend(fontsize=8, ncol=2, loc='upper right')
    ax2.grid(True, alpha=0.3)
    ax2.set_ylim(1e-16, 10)

    fig.suptitle('Consciousness as Fixed Point of Self-Modeling',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_fixed_point_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: viz_fixed_point_convergence.png")


if __name__ == "__main__":
    main()
