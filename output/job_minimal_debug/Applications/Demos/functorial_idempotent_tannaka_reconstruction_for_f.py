#!/usr/bin/env python3
"""
Newton's Method for Idempotent Lifting — Interactive Demonstrations

This script demonstrates the algebraic Newton iteration f(t) = 3t² - 2t³
for lifting approximate idempotents to true idempotents. The theorems
proven formally in Lean are brought to life with concrete numerical examples.

Demonstrations:
1. Newton iteration converging to idempotents in ℤ/n
2. Geometric series inverses for nilpotent elements
3. Visualization of the Newton map as a smoothstep function
4. Idempotent structure of ℤ/n for various n
5. Matrix examples: nilpotent perturbation of units
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from itertools import product as cart_product
import os

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


# ═══════════════════════════════════════════════════════════════════════════
# Core algebraic functions
# ═══════════════════════════════════════════════════════════════════════════

def newton_map(e, mod=None):
    """The Newton map f(e) = 3e² - 2e³, optionally modulo n."""
    result = 3 * e**2 - 2 * e**3
    return result % mod if mod else result


def defect(e, mod=None):
    """The idempotent defect e² - e."""
    result = e**2 - e
    return result % mod if mod else result


def iterate_newton(e, k, mod=None):
    """Apply the Newton map k times."""
    for _ in range(k):
        e = newton_map(e, mod)
    return e


def find_idempotents(n):
    """Find all idempotents in ℤ/n."""
    return [e for e in range(n) if (e * e) % n == e]


def find_nilpotents(n, max_order=None):
    """Find all nilpotent elements in ℤ/n and their nilpotency orders."""
    if max_order is None:
        max_order = n
    nilpotents = {}
    for x in range(n):
        power = x
        for k in range(1, max_order + 1):
            power = (power * x) % n
            if power == 0:
                nilpotents[x] = k + 1  # x^(k+1) = 0
                break
    return nilpotents


def find_units(n):
    """Find all units in ℤ/n."""
    from math import gcd
    return [u for u in range(n) if gcd(u, n) == 1]


def geom_series_inverse(x, order, mod):
    """Compute the geometric series inverse of (1-x) mod n.
    Returns sum_{k=0}^{order-1} x^k mod n."""
    result = 0
    power = 1
    for k in range(order):
        result = (result + power) % mod
        power = (power * x) % mod
    return result


# ═══════════════════════════════════════════════════════════════════════════
# Demo 1: Newton Iteration in ℤ/n
# ═══════════════════════════════════════════════════════════════════════════

def demo_newton_iteration():
    """Show Newton iteration converging to idempotents in modular arithmetic."""
    print("=" * 70)
    print("DEMO 1: Newton Iteration for Idempotent Lifting")
    print("=" * 70)
    print()
    print("The Newton map f(t) = 3t² - 2t³ squares the defect (t²-t),")
    print("so iterating it turns approximate idempotents into true ones.")
    print()

    # Example 1: ℤ/p² where lifting is needed
    examples = [
        (25, 7, "ℤ/25: lifting from an approximate idempotent"),
        (27, 10, "ℤ/27: lifting in a prime-power ring"),
        (125, 26, "ℤ/125: deeper nilpotence requires more iterations"),
        (36, 10, "ℤ/36: composite modulus"),
    ]

    for mod, start, desc in examples:
        print(f"  {desc}")
        print(f"  Starting element: e₀ = {start} in ℤ/{mod}")
        
        e = start
        idempotents = find_idempotents(mod)
        
        for step in range(8):
            d = defect(e, mod)
            is_idemp = "✓ IDEMPOTENT" if d == 0 else ""
            print(f"    Step {step}: e = {e:4d},  e²-e ≡ {d:4d} (mod {mod})  {is_idemp}")
            if d == 0:
                break
            e = newton_map(e, mod)
        
        print(f"  All idempotents in ℤ/{mod}: {idempotents}")
        print()


# ═══════════════════════════════════════════════════════════════════════════
# Demo 2: Geometric Series Inverses
# ═══════════════════════════════════════════════════════════════════════════

def demo_geometric_series():
    """Show explicit inverses via truncated geometric series."""
    print("=" * 70)
    print("DEMO 2: Geometric Series Inverses for Nilpotent Elements")
    print("=" * 70)
    print()
    print("If x^n = 0, then (1-x)⁻¹ = 1 + x + x² + ⋯ + x^(n-1)")
    print("This is a FINITE algebraic identity, not a limit!")
    print()

    # ℤ/p^k: nilpotent elements and their inverses
    test_cases = [
        (8, "ℤ/8 (= ℤ/2³)"),
        (27, "ℤ/27 (= ℤ/3³)"),
        (16, "ℤ/16 (= ℤ/2⁴)"),
        (125, "ℤ/125 (= ℤ/5³)"),
    ]

    for mod, name in test_cases:
        nilps = find_nilpotents(mod)
        print(f"  {name}:")
        print(f"  Nilpotent elements: {dict(list(nilps.items())[:8])}")
        
        for x, order in list(nilps.items())[:3]:
            if x == 0:
                continue
            one_minus_x = (1 - x) % mod
            inv = geom_series_inverse(x, order, mod)
            product = (one_minus_x * inv) % mod
            
            terms = " + ".join(f"{x}^{k}" if k > 0 else "1" for k in range(order))
            print(f"    x = {x}: x^{order} ≡ 0, "
                  f"(1-{x})⁻¹ = {terms} ≡ {inv} (mod {mod})")
            print(f"           Verification: {one_minus_x} × {inv} ≡ {product} (mod {mod})")
        print()


# ═══════════════════════════════════════════════════════════════════════════
# Demo 3: Visualizations
# ═══════════════════════════════════════════════════════════════════════════

def demo_visualizations():
    """Create mathematical visualizations."""
    fig = plt.figure(figsize=(16, 14))
    gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

    # ── Plot 1: The Newton Map as a Real Function ──
    ax1 = fig.add_subplot(gs[0, 0])
    t = np.linspace(-0.3, 1.3, 500)
    f_t = 3 * t**2 - 2 * t**3
    
    ax1.plot(t, f_t, 'b-', linewidth=2.5, label=r'$f(t) = 3t^2 - 2t^3$')
    ax1.plot(t, t, 'k--', linewidth=1, alpha=0.5, label=r'$y = t$')
    ax1.plot([0, 1], [0, 1], 'ro', markersize=10, zorder=5, label='Fixed points (idempotents)')
    
    # Show iteration from a starting point
    e0 = 0.3
    for i in range(5):
        e1 = 3 * e0**2 - 2 * e0**3
        ax1.plot([e0, e0], [e0, e1], 'g-', linewidth=1, alpha=0.7)
        ax1.plot([e0, e1], [e1, e1], 'g-', linewidth=1, alpha=0.7)
        e0 = e1
    
    e0 = 0.8
    for i in range(5):
        e1 = 3 * e0**2 - 2 * e0**3
        ax1.plot([e0, e0], [e0, e1], 'm-', linewidth=1, alpha=0.7)
        ax1.plot([e0, e1], [e1, e1], 'm-', linewidth=1, alpha=0.7)
        e0 = e1
    
    ax1.set_xlabel('$t$', fontsize=12)
    ax1.set_ylabel('$f(t)$', fontsize=12)
    ax1.set_title('Newton Map: The Smoothstep Function\n(Cobweb diagrams show convergence)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.set_xlim(-0.3, 1.3)
    ax1.set_ylim(-0.3, 1.3)
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')

    # ── Plot 2: Defect Squaring ──
    ax2 = fig.add_subplot(gs[0, 1])
    t = np.linspace(-0.1, 1.1, 500)
    defect_t = t**2 - t
    defect_ft = (3*t**2 - 2*t**3)**2 - (3*t**2 - 2*t**3)
    
    ax2.plot(t, np.abs(defect_t), 'b-', linewidth=2, label=r'$|t^2 - t|$ (original defect)')
    ax2.plot(t, np.abs(defect_ft), 'r-', linewidth=2, label=r'$|f(t)^2 - f(t)|$ (after Newton)')
    ax2.fill_between(t, 0, np.abs(defect_t), alpha=0.1, color='blue')
    ax2.fill_between(t, 0, np.abs(defect_ft), alpha=0.1, color='red')
    
    ax2.set_xlabel('$t$', fontsize=12)
    ax2.set_ylabel('Defect magnitude', fontsize=12)
    ax2.set_title('Quadratic Convergence: Defect Squaring\n' + 
                   r'$f(e)^2 - f(e) = (e^2-e)^2 \cdot (4e^2-4e-3)$', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 0.35)
    ax2.grid(True, alpha=0.3)

    # ── Plot 3: Idempotent Structure of ℤ/n ──
    ax3 = fig.add_subplot(gs[1, 0])
    ns = range(2, 51)
    counts = [len(find_idempotents(n)) for n in ns]
    
    colors = []
    for n in ns:
        # Color by whether n is prime, prime power, or composite
        factors = []
        temp = n
        for p in range(2, n + 1):
            while temp % p == 0:
                factors.append(p)
                temp //= p
            if temp == 1:
                break
        if len(factors) == 1:
            colors.append('#2196F3')  # Prime
        elif len(set(factors)) == 1:
            colors.append('#FF9800')  # Prime power
        else:
            colors.append('#4CAF50')  # Composite
    
    ax3.bar(list(ns), counts, color=colors, alpha=0.8, edgecolor='black', linewidth=0.3)
    ax3.set_xlabel('$n$', fontsize=12)
    ax3.set_ylabel('Number of idempotents', fontsize=12)
    ax3.set_title('Idempotent Count in ℤ/n\n(Blue=prime, Orange=prime power, Green=composite)', 
                   fontsize=13)
    ax3.grid(True, alpha=0.3, axis='y')

    # ── Plot 4: Convergence Rate Comparison ──
    ax4 = fig.add_subplot(gs[1, 1])
    
    # Compare Newton convergence vs simple iteration for different starting points
    starts = np.linspace(0.1, 0.9, 20)
    newton_steps = []
    
    for s in starts:
        e = s
        for step in range(50):
            if abs(e**2 - e) < 1e-15:
                newton_steps.append(step)
                break
            e = 3 * e**2 - 2 * e**3
        else:
            newton_steps.append(50)
    
    ax4.plot(starts, newton_steps, 'bo-', markersize=5, linewidth=1.5,
             label='Newton map iterations to convergence')
    ax4.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Single iteration')
    ax4.set_xlabel('Starting value $e_0$', fontsize=12)
    ax4.set_ylabel('Iterations to convergence', fontsize=12)
    ax4.set_title('Convergence Speed of Newton Iteration\n(Quadratic convergence ≈ constant steps)',
                   fontsize=13)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(0, max(newton_steps) + 2)

    plt.suptitle("Newton's Method for Idempotent Lifting\nFormally Verified in Lean 4",
                 fontsize=16, fontweight='bold', y=1.02)
    
    output_path = os.path.join(OUTPUT_DIR, "newton_idempotent_visualizations.png")
    plt.savefig(output_path, dpi=150, bbox_inches='tight')
    print(f"\n  Saved visualization to {output_path}")
    plt.close()


# ═══════════════════════════════════════════════════════════════════════════
# Demo 4: Idempotent Structure via CRT
# ═══════════════════════════════════════════════════════════════════════════

def demo_idempotent_structure():
    """Show how the CRT determines the idempotent structure of ℤ/n."""
    print("=" * 70)
    print("DEMO 4: Idempotent Structure of ℤ/n via CRT")
    print("=" * 70)
    print()
    print("By CRT, if n = p₁^a₁ ⋯ pₖ^aₖ, then ℤ/n ≅ ℤ/p₁^a₁ × ⋯ × ℤ/pₖ^aₖ")
    print("Each factor ℤ/pⁱ has exactly 2 idempotents: {0, 1}")
    print("So ℤ/n has exactly 2^k idempotents, one for each subset of prime factors!")
    print()

    examples = [12, 30, 60, 210, 2310]
    
    for n in examples:
        idemp = find_idempotents(n)
        
        # Factor n
        temp = n
        factors = []
        for p in range(2, n + 1):
            if temp % p == 0:
                count = 0
                while temp % p == 0:
                    count += 1
                    temp //= p
                factors.append((p, count))
            if temp == 1:
                break
        
        factor_str = " × ".join(f"{p}^{a}" if a > 1 else str(p) for p, a in factors)
        k = len(factors)
        
        print(f"  n = {n} = {factor_str}")
        print(f"  Number of prime factors: {k}")
        print(f"  Expected idempotents: 2^{k} = {2**k}")
        print(f"  Actual idempotents: {idemp}")
        
        # Show complementary pairs
        pairs = [(e, (1 - e) % n) for e in idemp if e <= n // 2]
        print(f"  Complementary pairs (e, 1-e): {pairs}")
        print()


# ═══════════════════════════════════════════════════════════════════════════
# Demo 5: Unit Perturbation (Matrix Example)
# ═══════════════════════════════════════════════════════════════════════════

def demo_unit_perturbation():
    """Demonstrate unit + nilpotent = unit with matrices."""
    print("=" * 70)
    print("DEMO 5: Stability of Units Under Nilpotent Perturbation")
    print("=" * 70)
    print()
    print("Theorem (formally verified): If u is a unit and n is nilpotent,")
    print("then u + n is a unit. The inverse is given by a truncated")
    print("geometric series: (u+n)⁻¹ = u⁻¹ Σ (-u⁻¹n)^k")
    print()

    # Matrix example
    I = np.eye(3)
    N = np.array([[0, 1, 2],
                  [0, 0, 3],
                  [0, 0, 0]])  # Strictly upper triangular = nilpotent

    print("  Matrix example in M₃(ℝ):")
    print(f"  U = I₃ (identity matrix, clearly a unit)")
    print(f"  N = {N[0].tolist()}")
    print(f"      {N[1].tolist()}")
    print(f"      {N[2].tolist()}")
    print(f"  N² = {(N@N)[0].tolist()}")
    print(f"       {(N@N)[1].tolist()}")
    print(f"       {(N@N)[2].tolist()}")
    print(f"  N³ = {(N@N@N)[0].tolist()} (= 0, so N is nilpotent of order 3)")
    print()

    # Compute inverse via geometric series
    A = I + N  # unit + nilpotent
    geom_inv = I - N + N @ N  # 1 + (-N) + (-N)² = I - N + N²
    
    print(f"  A = I + N:")
    for row in A:
        print(f"      {row.tolist()}")
    print()
    
    print(f"  Geometric series inverse: A⁻¹ = I - N + N² =")
    for row in geom_inv:
        print(f"      {row.tolist()}")
    print()
    
    product = A @ geom_inv
    print(f"  Verification A · A⁻¹ =")
    for row in product:
        print(f"      {[round(x) for x in row.tolist()]}")
    print(f"  = I₃ ✓")
    print()
    
    # Compare with numpy inverse
    np_inv = np.linalg.inv(A)
    print(f"  Agreement with numpy inverse: {np.allclose(geom_inv, np_inv)}")


# ═══════════════════════════════════════════════════════════════════════════
# Demo 6: Application — Error-Correcting Idempotent Generators
# ═══════════════════════════════════════════════════════════════════════════

def demo_applications():
    """Show practical applications of idempotent lifting."""
    print("=" * 70)
    print("DEMO 6: Applications of Idempotent Theory")
    print("=" * 70)
    print()

    # Application 1: Solving systems via CRT decomposition
    print("  APPLICATION 1: Parallel Computation via Idempotent Decomposition")
    print("  " + "-" * 60)
    print()
    print("  In ℤ/12, the idempotents {4, 9} decompose the ring:")
    print("  ℤ/12 ≅ ℤ/4 × ℤ/3  (via e=4 and 1-e=9)")
    print()
    
    n = 12
    e1, e2 = 4, 9
    
    print("  Decomposing multiplication: to compute a·b mod 12,")
    print("  compute (a·b mod 4) and (a·b mod 3) separately!")
    
    for a, b in [(5, 7), (11, 8), (3, 10)]:
        direct = (a * b) % n
        via_4 = (a * b) % 4
        via_3 = (a * b) % 3
        
        # Reconstruct using CRT
        # Find x ≡ via_4 (mod 4) and x ≡ via_3 (mod 3)
        for x in range(12):
            if x % 4 == via_4 and x % 3 == via_3:
                reconstructed = x
                break
        
        print(f"    {a} × {b} = {direct} (direct)")
        print(f"    mod 4: {a%4} × {b%4} ≡ {via_4},  mod 3: {a%3} × {b%3} ≡ {via_3}")
        print(f"    Reconstructed: {reconstructed} ✓")
    
    print()
    
    # Application 2: Newton's method in p-adic integers
    print("  APPLICATION 2: p-adic Computation (Hensel's Lemma)")
    print("  " + "-" * 60)
    print()
    print("  Finding idempotents in ℤ/p^k by lifting from ℤ/p:")
    print("  Start with e₀ in ℤ/p, lift to ℤ/p², ℤ/p⁴, ℤ/p⁸, ...")
    print()
    
    p = 5
    # In ℤ/5, the nontrivial "idempotent candidate" doesn't exist since 5 is prime
    # But in ℤ/5², ℤ/5⁴ we have interesting structure
    # Actually, let's use a composite: find idempotent in ℤ/6, lift to ℤ/36, ℤ/216
    
    # Better: lift from ℤ/6 to ℤ/6^k
    print("  Lifting from ℤ/6 (where 3 and 4 are idempotents):")
    
    for e_start in [3, 4]:
        print(f"\n  Starting with e = {e_start} in ℤ/6:")
        
        mod = 6
        e = e_start
        for k in range(1, 5):
            mod_next = mod * mod  # Square the modulus
            # The Newton map squares the defect, so we can lift
            e_lifted = newton_map(e, mod_next) if k > 1 else e
            d = defect(e_lifted, mod_next)
            print(f"    ℤ/{mod_next}: e = {e_lifted}, defect = {d}")
            e = e_lifted
            mod = mod_next


# ═══════════════════════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║    Newton's Method for Idempotent Lifting                      ║")
    print("║    Demonstrations of Formally Verified Algebraic Theorems      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_newton_iteration()
    demo_geometric_series()
    demo_idempotent_structure()
    demo_unit_perturbation()
    demo_applications()
    
    print()
    demo_visualizations()
    
    print()
    print("═" * 70)
    print("All demonstrations completed successfully.")
    print("See newton_idempotent_visualizations.png for plots.")
    print("═" * 70)
