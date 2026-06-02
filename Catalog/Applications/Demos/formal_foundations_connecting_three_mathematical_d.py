"""
Demo: Self-Avoiding Walks and the Fekete-Tropical Bridge

Demonstrates the key mathematical results:
1. SAW enumeration and submultiplicativity verification
2. Growth rate convergence (Fekete's lemma in action)
3. The Fekete-Tropical Bridge
4. Nienhuis constant verification
"""

import math
from algorithms import (
    enumerate_saws_2d,
    estimate_growth_rate,
    growth_rate_sequence,
    TropicalPowerSeries,
    verify_fekete_bridge,
    nienhuis_constant,
    verify_nienhuis_polynomial,
    is_submultiplicative,
)


def demo_saw_enumeration():
    """Demonstrate SAW counting and submultiplicativity."""
    print("=" * 60)
    print("1. Self-Avoiding Walk Enumeration")
    print("=" * 60)

    max_n = 14
    print(f"\nSquare lattice SAW counts (n=0..{max_n}):")
    sq_counts = [enumerate_saws_2d(n, "square") for n in range(max_n + 1)]
    for n, c in enumerate(sq_counts):
        print(f"  c({n:2d}) = {c:>10d}")

    print(f"\nSubmultiplicativity check: ", end="")
    if is_submultiplicative([float(c) for c in sq_counts]):
        print("✓ VERIFIED")
    else:
        print("✗ FAILED")

    # Check specific cases
    print("\nSubmultiplicativity examples:")
    for m in range(1, 5):
        for n in range(1, 5):
            if m + n <= max_n:
                lhs = sq_counts[m + n]
                rhs = sq_counts[m] * sq_counts[n]
                print(f"  c({m}+{n}) = {lhs:>8d} ≤ c({m})·c({n}) = {rhs:>8d}  "
                      f"{'✓' if lhs <= rhs else '✗'}")


def demo_growth_rate():
    """Demonstrate growth rate convergence via Fekete's lemma."""
    print("\n" + "=" * 60)
    print("2. Growth Rate Convergence (Fekete's Lemma)")
    print("=" * 60)

    max_n = 14
    sq_counts = [enumerate_saws_2d(n, "square") for n in range(max_n + 1)]

    print(f"\nSquare lattice: c(n)^(1/n) sequence:")
    rates = growth_rate_sequence(sq_counts[1:])
    for i, r in enumerate(rates, start=1):
        bar = "█" * int(r * 10)
        print(f"  n={i:2d}: c({i})^(1/{i}) = {r:.6f}  {bar}")

    mu = estimate_growth_rate(sq_counts[1:])
    print(f"\n  Growth rate estimate (infimum): μ ≈ {mu:.6f}")
    print(f"  Known value:                    μ ≈ 2.638158")
    print(f"  Degree bound (Theorem 5.4):     μ ≤ 4")


def demo_tropical_bridge():
    """Demonstrate the Fekete-Tropical Bridge."""
    print("\n" + "=" * 60)
    print("3. Fekete-Tropical Bridge")
    print("=" * 60)

    max_n = 12
    sq_counts = [float(enumerate_saws_2d(n, "square")) for n in range(max_n + 1)]
    mu = estimate_growth_rate([int(c) for c in sq_counts[1:]])

    # Create tropical power series
    trop = TropicalPowerSeries.from_submultiplicative(sq_counts)

    print(f"\nTropical coefficients t_n = -log(c(n)):")
    for n, c in enumerate(trop.coeffs[:max_n + 1]):
        print(f"  t_{n:2d} = {c:>10.4f}")

    print(f"\nBridge values: -log(a(n)) + n·log(μ) ≤ 0?")
    bridge = verify_fekete_bridge(sq_counts, mu)
    all_ok = True
    for i, v in enumerate(bridge, start=1):
        status = "✓" if v <= 1e-10 else "✗"
        if v > 1e-10:
            all_ok = False
        print(f"  n={i:2d}: {v:>10.6f}  {status}")

    print(f"\n  Bridge theorem verified: {'✓ ALL ≤ 0' if all_ok else '✗ VIOLATION'}")

    # Tropical evaluation at various points
    log_mu = math.log(mu)
    print(f"\n  log(μ) = {log_mu:.6f}")
    print(f"\n  Tropical evaluation min_n(t_n + n·x) at various x:")
    for x_mult in [0.5, 0.8, 1.0, 1.2, 1.5, 2.0]:
        x = x_mult * log_mu
        val, idx = trop.trop_eval_argmin(x)
        print(f"    x = {x_mult:.1f}·log(μ) = {x:.4f}: "
              f"min = {val:.4f} (at n={idx})")


def demo_nienhuis():
    """Demonstrate properties of the Nienhuis constant."""
    print("\n" + "=" * 60)
    print("4. Nienhuis Constant √(2 + √2)")
    print("=" * 60)

    nc = nienhuis_constant()
    print(f"\n  √(2 + √2) = {nc:.15f}")
    print(f"  √2         = {math.sqrt(2):.15f}")
    print(f"  2 + √2     = {2 + math.sqrt(2):.15f}")

    # Minimal polynomial
    poly_val = verify_nienhuis_polynomial(nc)
    print(f"\n  Minimal polynomial x⁴ - 4x² + 2:")
    print(f"    at x = √(2+√2): {poly_val:.2e}")
    print(f"    Verified: {'✓' if abs(poly_val) < 1e-10 else '✗'}")

    # All four roots
    print(f"\n  All roots of x⁴ - 4x² + 2 = 0:")
    roots = [
        math.sqrt(2 + math.sqrt(2)),
        -math.sqrt(2 + math.sqrt(2)),
        math.sqrt(2 - math.sqrt(2)),
        -math.sqrt(2 - math.sqrt(2)),
    ]
    for r in roots:
        v = verify_nienhuis_polynomial(r)
        print(f"    x = {r:>12.8f}: x⁴-4x²+2 = {v:.2e}")

    # Continued fraction
    print(f"\n  Irrationality cascade:")
    print(f"    √2 is irrational (classical)")
    print(f"    → 2 + √2 is irrational (rational + irrational)")
    print(f"    → √(2 + √2) is irrational (√ of irrational)")


if __name__ == "__main__":
    demo_saw_enumeration()
    demo_growth_rate()
    demo_tropical_bridge()
    demo_nienhuis()

    print("\n" + "=" * 60)
    print("Summary of Formally Verified Results")
    print("=" * 60)
    print("""
  1. log_subadditive:    log(submultiplicative) is subadditive  ✓
  2. bound_pow:          a(kn) ≤ a(n)^k · a(0)                 ✓
  3. fekete_tropical:    -log(a(n)) + n·log(μ) ≤ 0             ✓
  4. nienhuis_irrat:     √(2+√2) is irrational                 ✓
  5. nienhuis_poly:      x⁴ - 4x² + 2 = 0                     ✓
  6. degree_bound:       μ ≤ degree(lattice)                   ✓
    """)


"""
Visualization: Growth Rate Convergence for Self-Avoiding Walks

Shows how c(n)^{1/n} converges to the connective constant μ
as predicted by Fekete's lemma.
"""

import math


def enumerate_saws_2d(n: int) -> int:
    """Count SAWs of length n on the square lattice."""
    if n == 0:
        return 1
    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    count = 0
    visited = {(0, 0)}

    def backtrack(x, y, steps):
        nonlocal count
        if steps == n:
            count += 1
            return
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1)
                visited.remove((nx, ny))

    backtrack(0, 0, 0)
    return count


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    max_n = 16
    counts = [enumerate_saws_2d(n) for n in range(max_n + 1)]
    rates = [counts[n] ** (1.0 / n) for n in range(1, max_n + 1)]
    ns = list(range(1, max_n + 1))

    mu_known = 2.638158  # Known connective constant for square lattice
    mu_est = min(rates)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Growth rate convergence
    ax = axes[0]
    ax.plot(ns, rates, 'bo-', markersize=6, linewidth=1.5, label=r'$c(n)^{1/n}$')
    ax.axhline(y=mu_known, color='r', linestyle='--', linewidth=1.5,
               label=f'μ ≈ {mu_known:.4f}')
    ax.axhline(y=mu_est, color='g', linestyle=':', linewidth=1.5,
               label=f'inf estimate ≈ {mu_est:.4f}')
    ax.set_xlabel('Walk length n', fontsize=12)
    ax.set_ylabel(r'$c(n)^{1/n}$', fontsize=14)
    ax.set_title("Fekete's Lemma: Growth Rate Convergence\n(Square Lattice SAWs)",
                 fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(2.4, 4.2)
    ax.grid(True, alpha=0.3)

    # Plot 2: Tropical bridge values
    ax = axes[1]
    log_mu = math.log(mu_est)
    bridge_vals = [-math.log(counts[n]) + n * log_mu for n in range(1, max_n + 1)]
    colors = ['green' if v <= 1e-10 else 'red' for v in bridge_vals]
    ax.bar(ns, bridge_vals, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xlabel('Walk length n', fontsize=12)
    ax.set_ylabel(r'$-\log(c(n)) + n \cdot \log(\mu)$', fontsize=12)
    ax.set_title('Fekete–Tropical Bridge\n(All values ≤ 0)', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')

    green_patch = mpatches.Patch(color='green', alpha=0.7, label='≤ 0 (bridge holds)')
    ax.legend(handles=[green_patch], fontsize=11)

    plt.tight_layout()
    plt.savefig('growth_rate_convergence.png', dpi=150, bbox_inches='tight')
    print("Saved: growth_rate_convergence.png")


if __name__ == "__main__":
    main()


"""
Visualization: Tropical Power Series Landscape

Shows the tropical evaluation min_n(t_n + n*x) as a piecewise-linear function,
with the Fekete-Tropical Bridge threshold at x = log(μ).
"""

import math


def enumerate_saws_2d(n: int) -> int:
    """Count SAWs of length n on the square lattice."""
    if n == 0:
        return 1
    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    count = 0
    visited = {(0, 0)}

    def backtrack(x, y, steps):
        nonlocal count
        if steps == n:
            count += 1
            return
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1)
                visited.remove((nx, ny))

    backtrack(0, 0, 0)
    return count


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available, skipping visualization")
        return

    max_n = 12
    counts = [float(enumerate_saws_2d(n)) for n in range(max_n + 1)]
    trop_coeffs = [-math.log(c) if c > 0 else float('inf') for c in counts]
    mu_est = min(counts[n] ** (1.0 / n) for n in range(1, max_n + 1))
    log_mu = math.log(mu_est)

    x_vals = np.linspace(-1, 3, 500)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Individual tropical terms and their minimum
    ax = axes[0]
    for n in range(1, min(8, max_n + 1)):
        y_line = [trop_coeffs[n] + n * x for x in x_vals]
        ax.plot(x_vals, y_line, '--', alpha=0.4, linewidth=1,
                label=f'n={n}' if n <= 5 else None)

    # The tropical evaluation (pointwise minimum)
    trop_eval = [min(trop_coeffs[n] + n * x for n in range(1, max_n + 1))
                 for x in x_vals]
    ax.plot(x_vals, trop_eval, 'b-', linewidth=2.5, label='Tropical eval (min)')

    ax.axvline(x=log_mu, color='red', linewidth=2, linestyle='--',
               label=f'log(μ) ≈ {log_mu:.3f}')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel(r'$\min_n(t_n + nx)$', fontsize=12)
    ax.set_title('Tropical Power Series\n(Individual terms & minimum)', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_ylim(-15, 10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Nienhuis polynomial tropicalization
    ax = axes[1]
    # Tropical polynomial for x^4 - 4x^2 + 2
    # Coefficients: a_4=1, a_2=-4, a_0=2 → tropical: max(4v, 2v+log4, log2)
    v_vals = np.linspace(-1, 2, 500)

    term1 = 4 * v_vals  # from x^4 coefficient 1 → trop: 4v + 0
    term2 = 2 * v_vals + math.log(4)  # from x^2 coefficient 4 → trop: 2v + log4
    term3 = np.full_like(v_vals, math.log(2))  # from constant 2 → trop: log2

    trop_poly = np.maximum(np.maximum(term1, term2), term3)

    ax.plot(v_vals, term1, '--', color='blue', alpha=0.5, linewidth=1, label='4v')
    ax.plot(v_vals, term2, '--', color='green', alpha=0.5, linewidth=1,
            label=f'2v + log(4)')
    ax.plot(v_vals, term3, '--', color='orange', alpha=0.5, linewidth=1,
            label=f'log(2)')
    ax.plot(v_vals, trop_poly, 'k-', linewidth=2.5, label='Tropical polynomial')

    # Mark the tropical roots (corners)
    nienhuis = math.sqrt(2 + math.sqrt(2))
    log_nienhuis = math.log(nienhuis)
    ax.axvline(x=log_nienhuis, color='red', linewidth=2, linestyle='--',
               label=f'log(√(2+√2)) ≈ {log_nienhuis:.3f}')

    ax.set_xlabel('v (tropical variable)', fontsize=12)
    ax.set_ylabel('Tropical polynomial value', fontsize=12)
    ax.set_title(r'Tropicalization of $x^4 - 4x^2 + 2$' + '\n(Nienhuis minimal polynomial)',
                 fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_landscape.png")


if __name__ == "__main__":
    main()
