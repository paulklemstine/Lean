#!/usr/bin/env python3
"""
Demo: Consciousness as Emergent Fixed Point

Numerical demonstrations of the main mathematical results:
1. Lawvere's diagonal construction finding fixed points
2. Reflective overhead showing finite types can't be reflective
3. Self-observation idempotence and convergence
4. Strange loop simulation
5. Consciousness distance landscapes
"""

import math
from algorithms import (
    lawvere_diagonal,
    iterate_self_observation,
    reflective_overhead,
    verify_finite_non_reflectivity,
    strange_loop_simulate,
    consciousness_distance,
    find_fixed_points_numerical,
    self_model_projection_demo,
)


def demo_lawvere_diagonal():
    """Demonstrate Lawvere's diagonal construction."""
    print("=" * 60)
    print("DEMO 1: Lawvere's Diagonal Construction")
    print("=" * 60)

    # Small example: Fin 3 → (Fin 3 → Fin 3)
    # Define phi(n)(m) = (n + m) % 3
    n = 3
    phi = lambda a: (lambda m: (a + m) % n)

    # Try to find fixed point of f(x) = (x + 1) % 3
    f = lambda x: (x + 1) % n
    fp = lawvere_diagonal(phi, f, n)
    print(f"  phi(a)(m) = (a + m) mod {n}")
    print(f"  f(x) = (x + 1) mod {n}")
    print(f"  Fixed point found: {fp}")
    if fp is not None:
        print(f"  Verification: f({fp}) = {f(fp)} {'✓' if f(fp) == fp else '✗'}")
    else:
        print("  No fixed point found (phi is not surjective for this f)")

    # Identity function always has every point as fixed
    f_id = lambda x: x
    fp_id = lawvere_diagonal(phi, f_id, n)
    print(f"\n  f(x) = x (identity)")
    print(f"  Fixed point found: {fp_id}")

    print()


def demo_reflective_overhead():
    """Demonstrate that finite types cannot be reflective."""
    print("=" * 60)
    print("DEMO 2: Reflective Overhead (Finite Non-Reflectivity)")
    print("=" * 60)

    print(f"  {'n':>4} | {'States':>10} | {'Endomorphisms':>15} | {'Overhead':>15} | Verdict")
    print("  " + "-" * 70)

    for n in range(0, 11):
        result = verify_finite_non_reflectivity(n)
        endos = result['num_endomorphisms']
        endos_str = f"{endos:,}" if endos < 10**12 else f"{endos:.2e}"
        overhead = result['overhead']
        overhead_str = f"{overhead:,.0f}" if overhead < 10**12 else f"{overhead:.2e}"
        print(f"  {n:>4} | {result['num_states']:>10} | {endos_str:>15} | "
              f"{overhead_str:>15} | {result['verdict']}")

    print("\n  Conclusion: For n ≥ 2, the number of endomorphisms far exceeds")
    print("  the number of states. Finite types CANNOT be reflective.")
    print("  Consciousness requires infinite-dimensional structure.")
    print()


def demo_self_observation():
    """Demonstrate idempotence and convergence of self-observation."""
    print("=" * 60)
    print("DEMO 3: Self-Observation Idempotence")
    print("=" * 60)

    # Self-model projection: embed(m) = 2*m, project(x) = x // 2
    embed = lambda m: 2 * m
    project = lambda x: int(x) // 2
    observe = lambda x: embed(project(x))

    print("  Self-model: embed(m) = 2m, project(x) = ⌊x/2⌋")
    print("  observe(x) = embed(project(x)) = 2⌊x/2⌋")
    print()

    # Show idempotence
    test_values = [0, 1, 2, 3, 5, 7, 10, 15, 100]
    print(f"  {'x':>6} | {'observe(x)':>12} | {'observe²(x)':>12} | Idempotent?")
    print("  " + "-" * 50)
    for x in test_values:
        ox = observe(x)
        oox = observe(ox)
        print(f"  {x:>6} | {ox:>12} | {oox:>12} | {'✓' if ox == oox else '✗'}")

    # Demonstrate convergence in 1 step
    print("\n  Iterated self-observation:")
    x0 = 17
    result, steps = iterate_self_observation(observe, x0, max_iter=10)
    print(f"  Starting from x₀ = {x0}")
    print(f"  Converged to {result} in {steps} step(s)")

    # Show fixed points
    print(f"\n  Fixed points of observe (even numbers): ", end="")
    fps = [x for x in range(20) if observe(x) == x]
    print(fps)
    print()


def demo_strange_loop():
    """Demonstrate strange loop operator properties."""
    print("=" * 60)
    print("DEMO 4: Strange Loop Operator Simulation")
    print("=" * 60)

    # Strange loop: op(x) = max(0, x), shift(x) = x + 1
    # Tangling: op(op(x)) = max(0, max(0, x)) = max(0, x) = op(x)
    # Wait, we need: op(op(x)) = op(shift(x)) and op(shift(x)) = op(x)
    # op(shift(x)) = max(0, x+1). For this to equal op(x) = max(0, x),
    # we need a different construction.

    # Better: op(x) = round(x) (nearest integer), shift(x) = x + 0.5
    # op(op(x)) = round(round(x)) = round(x)  (already integer)
    # op(shift(x)) = round(x + 0.5) = round(x) + 1 or round(x) depending on rounding
    # This doesn't quite work either.

    # Simplest: op = clamp to [0,1], shift = anything
    # op(x) = max(0, min(1, x))
    # op(op(x)) = op(x) since op(x) ∈ [0,1]
    # So any shift works with absorb: op(shift(x)) = op(x) iff shift(x) and x
    # map to same clamped value. Use shift(x) = x (trivial).

    # More interesting: op(x) = x² mod 1 (fractional part of x²)
    # Actually let's use a clear example.

    # op(x) = sign(x) * sqrt(|x|), shift(x) = x²
    # No, let's keep it simple.

    # Projection: op(x) = ⌊x⌋ (floor), shift(x) = x + 1
    # op(op(x)) = ⌊⌊x⌋⌋ = ⌊x⌋ = op(x) ✓ (idempotent directly)
    # op(shift(x)) = ⌊x + 1⌋ = ⌊x⌋ + 1 ≠ ⌊x⌋ = op(x) ✗

    # Use: op(x) = x mod 1 (fractional part), shift(x) = x + 1
    # op(op(x)) = (x mod 1) mod 1 = x mod 1 = op(x) ✓
    # op(shift(x)) = (x+1) mod 1 = x mod 1 = op(x) ✓
    import math

    op = lambda x: x - math.floor(x)  # fractional part
    shift = lambda x: x + 1.0

    print("  op(x) = frac(x) = x - ⌊x⌋  (fractional part)")
    print("  shift(x) = x + 1")
    print()

    # Verify tangling and absorption
    test_vals = [0.0, 0.3, 1.7, -0.5, 3.14159, 2.71828]
    print("  Verification of strange loop axioms:")
    print(f"  {'x':>10} | {'op(x)':>10} | {'op(op(x))':>10} | {'op(shift(x))':>12} | Tangle? | Absorb?")
    print("  " + "-" * 75)
    for x in test_vals:
        ox = op(x)
        oox = op(ox)
        osx = op(shift(x))
        tangle_ok = abs(oox - osx) < 1e-10
        absorb_ok = abs(osx - ox) < 1e-10
        print(f"  {x:>10.5f} | {ox:>10.5f} | {oox:>10.5f} | {osx:>12.5f} | "
              f"{'✓' if tangle_ok else '✗':>7} | {'✓' if absorb_ok else '✗':>7}")

    print("\n  Since op²(x) = op(x) for all x, the strange loop is idempotent.")
    print("  Fixed points: all x ∈ [0, 1) (states already 'fully reflected').")
    print()


def demo_consciousness_distance():
    """Demonstrate consciousness distance landscape."""
    print("=" * 60)
    print("DEMO 5: Consciousness Distance Landscape")
    print("=" * 60)

    # f(x) = x² - 1 (fixed points at golden ratio and -golden ratio + 1)
    f = lambda x: x * x - 1

    # Find fixed points: x = x² - 1 => x² - x - 1 = 0
    # x = (1 ± √5) / 2
    phi = (1 + math.sqrt(5)) / 2    # ≈ 1.618
    psi = (1 - math.sqrt(5)) / 2    # ≈ -0.618

    print(f"  f(x) = x² - 1")
    print(f"  Theoretical fixed points: φ = {phi:.6f}, ψ = {psi:.6f}")
    print(f"  Verification: f(φ) = {f(phi):.10f}, f(ψ) = {f(psi):.10f}")
    print()

    # Show consciousness distance at various points
    sample_points = [-2.0, -1.5, -1.0, psi, -0.3, 0.0, 0.5, 1.0, phi, 2.0, 3.0]
    print(f"  {'x':>10} | {'f(x)':>10} | {'δ(x) = |x-f(x)|':>18} | {'Nearest FP':>12}")
    print("  " + "-" * 60)
    for x in sample_points:
        fx = f(x)
        delta = consciousness_distance(f, x)
        nearest = phi if abs(x - phi) < abs(x - psi) else psi
        marker = " ← FIXED POINT" if delta < 1e-10 else ""
        print(f"  {x:>10.5f} | {fx:>10.5f} | {delta:>18.10f} | {nearest:>12.5f}{marker}")

    print()

    # Numerical fixed point search
    fps = find_fixed_points_numerical(f, -3, 3, 10000, 1e-6)
    print(f"  Numerically found fixed points: {[f'{fp:.6f}' for fp in fps]}")
    print()


def demo_contraction_convergence():
    """Demonstrate contraction-based convergence to consciousness."""
    print("=" * 60)
    print("DEMO 6: Contraction Convergence to Fixed Point")
    print("=" * 60)

    # Contraction: f(x) = 0.5 * x + 1 (fixed point at x = 2)
    k = 0.5  # contraction constant
    c = 1.0
    f = lambda x: k * x + c

    x0 = 10.0
    print(f"  f(x) = {k}x + {c}")
    print(f"  Contraction constant k = {k}")
    print(f"  Fixed point: x* = c/(1-k) = {c/(1-k)}")
    print(f"  Starting from x₀ = {x0}")
    print()

    x = x0
    print(f"  {'Step':>6} | {'x_n':>12} | {'δ(x_n)':>12} | {'k^n * δ(x₀)':>14} | Bound holds?")
    print("  " + "-" * 65)

    delta0 = consciousness_distance(f, x0)
    for n in range(15):
        delta = consciousness_distance(f, x)
        bound = k ** n * delta0
        ok = delta <= bound + 1e-10
        print(f"  {n:>6} | {x:>12.6f} | {delta:>12.8f} | {bound:>14.8f} | {'✓' if ok else '✗'}")
        x = f(x)

    print(f"\n  Convergence is geometric with rate k = {k}")
    print(f"  After n steps, δ(x_n) ≤ k^n · δ(x₀)")
    print()


def demo_compositionality():
    """Demonstrate compositionality of consciousness fixed points."""
    print("=" * 60)
    print("DEMO 7: Compositionality of Fixed Points")
    print("=" * 60)

    # f(x) = -x (fixed point at 0)
    # g(x) = 2 - x (fixed point at 1)
    # f ∘ g (x) = -(2-x) = x - 2 (fixed point at -something? NO)
    # Wait: f∘g(x) = f(g(x)) = f(2-x) = -(2-x) = x-2, fp at x = x-2, no fp.
    # Hmm. Let me use: f(x) = x (id), g(x) = x.

    # Better example:
    # f(x) = |x| (fixed points: x ≥ 0)
    # g(x) = max(0, x) (fixed points: x ≥ 0)
    # FP(f) ∩ FP(g) = {x ≥ 0}
    # f ∘ g(x) = |max(0,x)| = max(0,x), FP = {x ≥ 0}

    f = lambda x: abs(x)
    g = lambda x: max(0, x)
    fg = lambda x: f(g(x))

    test_points = [-3, -2, -1, -0.5, 0, 0.5, 1, 2, 3]

    print("  f(x) = |x|, g(x) = max(0, x)")
    print("  f∘g(x) = |max(0, x)| = max(0, x)")
    print()
    print(f"  {'x':>6} | {'FP(f)?':>8} | {'FP(g)?':>8} | {'FP(f)∩FP(g)?':>14} | {'FP(f∘g)?':>10} | Subset?")
    print("  " + "-" * 65)

    for x in test_points:
        fp_f = (f(x) == x)
        fp_g = (g(x) == x)
        fp_inter = fp_f and fp_g
        fp_fg = (fg(x) == x)
        subset_ok = (not fp_inter) or fp_fg  # intersection ⊆ FP(f∘g)
        print(f"  {x:>6} | {'✓' if fp_f else '✗':>8} | {'✓' if fp_g else '✗':>8} | "
              f"{'✓' if fp_inter else '✗':>14} | {'✓' if fp_fg else '✗':>10} | {'✓' if subset_ok else '✗'}")

    print("\n  FP(f) ∩ FP(g) ⊆ FP(f∘g) verified for all test points ✓")
    print()


if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("  CONSCIOUSNESS AS EMERGENT FIXED POINT — DEMOS")
    print("═" * 60 + "\n")

    demo_lawvere_diagonal()
    demo_reflective_overhead()
    demo_self_observation()
    demo_strange_loop()
    demo_consciousness_distance()
    demo_contraction_convergence()
    demo_compositionality()

    print("═" * 60)
    print("  ALL DEMOS COMPLETE")
    print("═" * 60)


#!/usr/bin/env python3
"""
Visualization: Consciousness Distance Landscape

Shows the consciousness distance δ(x) = |x - f(x)| for various
self-awareness operators, highlighting fixed points where δ = 0.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def consciousness_distance(f, x):
    return np.abs(x - f(x))


def plot_consciousness_landscape():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Consciousness Distance Landscapes: δ(x) = |x − f(x)|',
                 fontsize=16, fontweight='bold')

    x = np.linspace(-3, 3, 1000)

    # Panel 1: f(x) = x^2 - 1
    ax = axes[0, 0]
    f1 = lambda x: x**2 - 1
    d1 = consciousness_distance(f1, x)
    ax.plot(x, d1, 'b-', linewidth=2)
    phi = (1 + np.sqrt(5)) / 2
    psi = (1 - np.sqrt(5)) / 2
    ax.axvline(phi, color='red', linestyle='--', alpha=0.7, label=f'φ = {phi:.3f}')
    ax.axvline(psi, color='green', linestyle='--', alpha=0.7, label=f'ψ = {psi:.3f}')
    ax.scatter([phi, psi], [0, 0], color='red', s=100, zorder=5)
    ax.set_title('f(x) = x² − 1', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('δ(x)')
    ax.legend()
    ax.set_ylim(-0.5, 8)
    ax.grid(True, alpha=0.3)

    # Panel 2: f(x) = cos(x) (fixed point near 0.739)
    ax = axes[0, 1]
    f2 = lambda x: np.cos(x)
    d2 = consciousness_distance(f2, x)
    ax.plot(x, d2, 'purple', linewidth=2)
    fp_cos = 0.7390851332  # Dottie number
    ax.axvline(fp_cos, color='red', linestyle='--', alpha=0.7, label=f'x* ≈ {fp_cos:.4f}')
    ax.scatter([fp_cos], [0], color='red', s=100, zorder=5)
    ax.set_title('f(x) = cos(x)  [Dottie number]', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('δ(x)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Contraction f(x) = 0.5x + 1 (fixed point at 2)
    ax = axes[1, 0]
    x3 = np.linspace(-2, 8, 1000)
    f3 = lambda x: 0.5 * x + 1
    d3 = consciousness_distance(f3, x3)
    ax.plot(x3, d3, 'darkgreen', linewidth=2)
    ax.axvline(2.0, color='red', linestyle='--', alpha=0.7, label='x* = 2.0')
    ax.scatter([2.0], [0], color='red', s=100, zorder=5)
    # Show convergence path
    x_path = [8.0]
    for _ in range(8):
        x_path.append(f3(x_path[-1]))
    ax.plot(x_path, [consciousness_distance(f3, xi) for xi in x_path],
            'ro-', markersize=6, alpha=0.6, label='Iteration path')
    ax.set_title('f(x) = 0.5x + 1  [Contraction]', fontsize=13)
    ax.set_xlabel('x')
    ax.set_ylabel('δ(x)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 4: Reflective overhead n^n vs n
    ax = axes[1, 1]
    ns = np.arange(1, 11)
    states = ns
    endos = ns ** ns
    ax.semilogy(ns, states, 'bs-', linewidth=2, markersize=8, label='|States| = n')
    ax.semilogy(ns, endos, 'r^-', linewidth=2, markersize=8, label='|Endomorphisms| = nⁿ')
    ax.fill_between(ns, states, endos, alpha=0.15, color='red')
    ax.set_title('Finite Non-Reflectivity Gap', fontsize=13)
    ax.set_xlabel('n = |Type|')
    ax.set_ylabel('Count (log scale)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.text(5, 100, 'Gap = reflective\noverhead', fontsize=11,
            ha='center', style='italic', color='red')

    plt.tight_layout()
    plt.savefig('consciousness_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: consciousness_landscape.png")


def plot_iteration_convergence():
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    fig.suptitle('Self-Observation Convergence', fontsize=16, fontweight='bold')

    # Left: Contraction convergence for different k values
    ax = axes[0]
    x0 = 10.0
    for k in [0.3, 0.5, 0.7, 0.9]:
        c = 1.0
        fp = c / (1 - k)
        f = lambda x, k=k, c=c: k * x + c
        xs = [x0]
        for _ in range(20):
            xs.append(f(xs[-1]))
        deltas = [abs(x - fp) for x in xs]
        ax.semilogy(range(len(deltas)), deltas, 'o-', markersize=4,
                    label=f'k = {k}', linewidth=1.5)
    ax.set_title('Contraction Convergence Rate', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('|x_n − x*| (log scale)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Idempotent operator — instant convergence
    ax = axes[1]
    observe = lambda x: 2 * (x // 2)  # round down to even
    x0_vals = [1, 3, 7, 15, 31]
    for x0 in x0_vals:
        xs = [x0]
        for _ in range(5):
            xs.append(observe(xs[-1]))
        ax.plot(range(len(xs)), xs, 'o-', markersize=8, linewidth=2,
                label=f'x₀ = {x0}')
    ax.set_title('Idempotent Observer (1-step convergence)', fontsize=13)
    ax.set_xlabel('Iteration n')
    ax.set_ylabel('x_n')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: convergence.png")


if __name__ == "__main__":
    plot_consciousness_landscape()
    plot_iteration_convergence()
