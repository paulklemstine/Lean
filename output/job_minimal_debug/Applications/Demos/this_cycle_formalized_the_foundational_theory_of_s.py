#!/usr/bin/env python3
"""
Demo: Self-Avoiding Walk Theory Computations

Demonstrates key numerical results from the formalized SAW theory:
1. SAW enumeration on the square lattice
2. Connective constant approximation via c(n)^{1/n}
3. Nienhuis constant verification
4. Tropical polynomial evaluation
"""

import math
from typing import List, Tuple, Set, Dict

# ============================================================
# SAW Enumeration by Backtracking
# ============================================================

def count_saws(n: int) -> int:
    """Count self-avoiding walks of length n on Z^2 starting at origin."""
    if n == 0:
        return 1

    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    count = 0

    def backtrack(x: int, y: int, steps: int, visited: Set[Tuple[int, int]]):
        nonlocal count
        if steps == n:
            count += 1
            return
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1, visited)
                visited.remove((nx, ny))

    visited = {(0, 0)}
    backtrack(0, 0, 0, visited)
    return count


def demonstrate_saw_counts():
    """Show SAW counts and connective constant approximation."""
    print("=" * 60)
    print("Self-Avoiding Walk Counts c(n) on the Square Lattice")
    print("=" * 60)

    known_values = {
        0: 1, 1: 4, 2: 12, 3: 36, 4: 100, 5: 284, 6: 780,
        7: 2172, 8: 5916, 9: 16268, 10: 44100
    }

    print(f"\n{'n':>4} {'c(n)':>12} {'c(n)^(1/n)':>14} {'log c(n)/n':>14}")
    print("-" * 48)

    for n in range(11):
        cn = known_values[n]
        if n > 0:
            root = cn ** (1.0 / n)
            log_ratio = math.log(cn) / n
        else:
            root = float('inf')
            log_ratio = float('inf')
        print(f"{n:>4} {cn:>12} {root:>14.6f} {log_ratio:>14.6f}")

    print(f"\nTrue connective constant μ ≈ 2.63815853...")
    print(f"c(10)^(1/10) = {44100 ** 0.1:.8f} (upper bound)")


def demonstrate_nienhuis():
    """Verify properties of the Nienhuis constant."""
    print("\n" + "=" * 60)
    print("The Nienhuis Constant μ_hex = √(2 + √2)")
    print("=" * 60)

    sqrt2 = math.sqrt(2)
    nienhuis = math.sqrt(2 + sqrt2)

    print(f"\n√2 = {sqrt2:.10f}")
    print(f"2 + √2 = {2 + sqrt2:.10f}")
    print(f"μ_hex = √(2 + √2) = {nienhuis:.10f}")
    print(f"\nVerification:")
    print(f"  μ² = {nienhuis**2:.10f} (should be {2 + sqrt2:.10f})")
    print(f"  μ⁴ - 4μ² + 2 = {nienhuis**4 - 4*nienhuis**2 + 2:.2e} (should be 0)")
    print(f"  μ is irrational: True (proven formally)")


def demonstrate_tropical():
    """Show tropical polynomial evaluation."""
    print("\n" + "=" * 60)
    print("Tropical Polynomial for the Nienhuis Constant")
    print("=" * 60)

    print(f"\nMinimal polynomial: x⁴ - 4x² + 2 = 0")
    print(f"Tropical version: max(4v, 2v + log(4), log(2))")
    print(f"\nTropical root at v = log(2) = {math.log(2):.6f}:")
    v = math.log(2)
    t1 = 4 * v
    t2 = 2 * v + math.log(4)
    t3 = math.log(2)
    print(f"  4v        = {t1:.6f}")
    print(f"  2v + ln4  = {t2:.6f}")
    print(f"  ln2       = {t3:.6f}")
    print(f"  First two terms equal: {abs(t1 - t2) < 1e-10}")


def demonstrate_convergence():
    """Show the convergence criterion."""
    print("\n" + "=" * 60)
    print("Convergence Criterion for SAW Generating Function")
    print("=" * 60)

    # Known c(n) values
    cn = [1, 4, 12, 36, 100, 284, 780, 2172, 5916, 16268, 44100]
    mu_approx = 2.63815853

    print(f"\nConnective constant μ ≈ {mu_approx}")
    print(f"Critical fugacity x_c = 1/μ ≈ {1/mu_approx:.8f}")
    print(f"\nPartial sums Σ c(n) x^n for various x:")

    for x in [0.3, 0.35, 0.37, 0.378, 0.379]:
        partial_sum = sum(cn[n] * x**n for n in range(len(cn)))
        print(f"  x = {x:.3f}: S₁₀ = {partial_sum:.4f}"
              f" {'(converging)' if x < 1/mu_approx else '(diverging)'}")


def demonstrate_fekete():
    """Show Fekete's lemma in action."""
    print("\n" + "=" * 60)
    print("Fekete's Lemma: log c(n)/n Converges")
    print("=" * 60)

    cn = [1, 4, 12, 36, 100, 284, 780, 2172, 5916, 16268, 44100]

    print(f"\n{'n':>4} {'log c(n)/n':>14} {'Δ from μ':>12}")
    print("-" * 34)
    mu = math.log(2.63815853)
    for n in range(1, len(cn)):
        ratio = math.log(cn[n]) / n
        print(f"{n:>4} {ratio:>14.8f} {ratio - mu:>12.8f}")

    print(f"\nlog(μ) = {mu:.8f}")
    print(f"The ratios approach log(μ) from above (Fekete's lemma)")


if __name__ == "__main__":
    demonstrate_saw_counts()
    demonstrate_nienhuis()
    demonstrate_tropical()
    demonstrate_convergence()
    demonstrate_fekete()


#!/usr/bin/env python3
"""
Visualization: Self-Avoiding Walk Growth Rate Convergence

Shows how c(n)^{1/n} converges to the connective constant μ ≈ 2.638,
demonstrating Fekete's lemma in action.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    # Known SAW counts on the square lattice
    cn = [1, 4, 12, 36, 100, 284, 780, 2172, 5916, 16268, 44100,
          120292, 324932, 881500, 2374444, 6416596, 17245332]

    n_values = list(range(1, len(cn)))
    roots = [cn[n] ** (1.0 / n) for n in n_values]
    log_ratios = [math.log(cn[n]) / n for n in n_values]

    mu_true = 2.63815853
    log_mu = math.log(mu_true)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: c(n)^{1/n} convergence
    ax1.plot(n_values, roots, 'bo-', markersize=6, label=r'$c(n)^{1/n}$')
    ax1.axhline(y=mu_true, color='r', linestyle='--', linewidth=2,
                label=rf'$\mu \approx {mu_true}$')
    ax1.set_xlabel('Walk length n', fontsize=12)
    ax1.set_ylabel(r'$c(n)^{1/n}$', fontsize=14)
    ax1.set_title('Connective Constant Convergence\n(Fekete\'s Lemma)', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(0, len(cn))

    # Right: log c(n)/n convergence
    ax2.plot(n_values, log_ratios, 'gs-', markersize=6, label=r'$\log c(n) / n$')
    ax2.axhline(y=log_mu, color='r', linestyle='--', linewidth=2,
                label=rf'$\log \mu \approx {log_mu:.4f}$')
    ax2.set_xlabel('Walk length n', fontsize=12)
    ax2.set_ylabel(r'$\log c(n) / n$', fontsize=14)
    ax2.set_title('Log-Growth Rate Convergence\n(Subadditivity)', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    ax2.set_xlim(0, len(cn))

    plt.tight_layout()
    plt.savefig('saw_convergence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved saw_convergence.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical Polynomial of the Nienhuis Constant

Shows the tropical polynomial max(4v, 2v + log(4), log(2)) and its root
at v = log(2), where two linear pieces intersect.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    v = np.linspace(-0.5, 2.0, 500)

    # Three linear pieces
    piece1 = 4 * v  # from x^4 term
    piece2 = 2 * v + np.log(4)  # from -4x^2 term
    piece3 = np.full_like(v, np.log(2))  # from +2 term

    # Tropical polynomial = max of all pieces
    trop = np.maximum(np.maximum(piece1, piece2), piece3)

    # Root: where two pieces meet
    v_root = np.log(2)

    fig, ax = plt.subplots(figsize=(10, 7))

    ax.plot(v, piece1, 'b--', alpha=0.5, linewidth=1.5, label=r'$4v$ (from $x^4$)')
    ax.plot(v, piece2, 'g--', alpha=0.5, linewidth=1.5, label=r'$2v + \ln 4$ (from $4x^2$)')
    ax.plot(v, piece3, 'r--', alpha=0.5, linewidth=1.5, label=r'$\ln 2$ (from $2$)')
    ax.plot(v, trop, 'k-', linewidth=3, label='Tropical polynomial')

    # Mark the root
    ax.plot(v_root, 4 * v_root, 'ro', markersize=12, zorder=5)
    ax.annotate(f'Tropical root\nv = ln(2) ≈ {v_root:.4f}',
                xy=(v_root, 4 * v_root),
                xytext=(v_root + 0.3, 4 * v_root + 0.5),
                fontsize=11,
                arrowprops=dict(arrowstyle='->', color='red'),
                color='red')

    ax.set_xlabel('Tropical variable v', fontsize=13)
    ax.set_ylabel('Tropical polynomial value', fontsize=13)
    ax.set_title('Tropical Polynomial of the Nienhuis Constant\n'
                 r'$\mathrm{trop}(x^4 - 4x^2 + 2) = \max(4v,\; 2v + \ln 4,\; \ln 2)$',
                 fontsize=14)
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_nienhuis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved tropical_nienhuis.png")


if __name__ == "__main__":
    main()
