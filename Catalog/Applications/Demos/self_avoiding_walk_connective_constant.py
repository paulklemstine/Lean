#!/usr/bin/env python3
"""
Self-Avoiding Walk: Connective Constant Demo

Demonstrates:
1. Enumeration of SAWs on Z² for small lengths
2. Estimation of the connective constant μ
3. Comparison with Nienhuis's value √(2+√2) for the hexagonal lattice
4. Bridge decomposition statistics
"""

import math
from collections import defaultdict


def enumerate_saws(n: int) -> list[list[tuple[int, int]]]:
    """Enumerate all self-avoiding walks of length n on Z² from the origin."""
    if n == 0:
        return [[(0, 0)]]

    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    result = []

    def backtrack(path: list[tuple[int, int]], visited: set[tuple[int, int]]):
        if len(path) == n + 1:
            result.append(list(path))
            return
        x, y = path[-1]
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                path.append((nx, ny))
                backtrack(path, visited)
                path.pop()
                visited.discard((nx, ny))

    backtrack([(0, 0)], {(0, 0)})
    return result


def saw_count(n: int) -> int:
    """Count SAWs of length n on Z²."""
    return len(enumerate_saws(n))


def estimate_connective_constant(max_n: int = 12) -> list[float]:
    """Estimate μ = lim c_n^{1/n} for increasing n."""
    estimates = []
    for k in range(1, max_n + 1):
        c = saw_count(k)
        mu_est = c ** (1.0 / k)
        estimates.append((k, c, mu_est))
    return estimates


def nienhuis_constant() -> float:
    """The Duminil-Copin–Smirnov constant √(2+√2) for the hexagonal lattice."""
    return math.sqrt(2 + math.sqrt(2))


def verify_algebraic_identity():
    """Verify μ⁴ - 4μ² + 2 = 0 for μ = √(2+√2)."""
    mu = nienhuis_constant()
    result = mu**4 - 4 * mu**2 + 2
    return result


def bridge_count(walks: list[list[tuple[int, int]]]) -> int:
    """Count bridges: SAWs where intermediate x-coords are strictly
    between endpoint x-coords."""
    count = 0
    for walk in walks:
        if len(walk) <= 2:
            count += 1
            continue
        x_start = walk[0][0]
        x_end = walk[-1][0]
        if x_start >= x_end:
            continue
        is_bridge = True
        for i in range(1, len(walk) - 1):
            if not (x_start < walk[i][0] < x_end):
                is_bridge = False
                break
        if is_bridge:
            count += 1
    return count


def submultiplicativity_check(max_n: int = 8):
    """Verify c_{m+n} ≤ c_m · c_n for small m, n."""
    counts = {k: saw_count(k) for k in range(max_n + 1)}
    violations = []
    for m in range(max_n + 1):
        for n in range(max_n + 1 - m):
            if counts[m + n] > counts[m] * counts[n]:
                violations.append((m, n, counts[m + n], counts[m] * counts[n]))
    return violations, counts


if __name__ == "__main__":
    print("=" * 60)
    print("Self-Avoiding Walk: Connective Constant Demo")
    print("=" * 60)

    # 1. SAW counts
    print("\n1. SAW counts c_n on Z²:")
    print(f"   {'n':>3} | {'c_n':>10} | {'c_n^(1/n)':>12} | {'log(c_n)/n':>12}")
    print("   " + "-" * 45)
    estimates = estimate_connective_constant(14)
    for n, c, mu in estimates:
        print(f"   {n:3d} | {c:10d} | {mu:12.6f} | {math.log(c)/n:12.6f}")

    # 2. Nienhuis constant
    mu_hex = nienhuis_constant()
    print(f"\n2. Nienhuis constant (hexagonal lattice):")
    print(f"   μ_hex = √(2+√2) = {mu_hex:.10f}")
    print(f"   μ_hex² = {mu_hex**2:.10f}  (should be 2+√2 = {2+math.sqrt(2):.10f})")
    print(f"   μ_hex⁴ - 4μ_hex² + 2 = {verify_algebraic_identity():.2e}")

    # 3. Submultiplicativity
    print("\n3. Submultiplicativity check c_{m+n} ≤ c_m · c_n:")
    violations, counts = submultiplicativity_check(8)
    if violations:
        print("   VIOLATIONS FOUND:", violations)
    else:
        print("   ✓ No violations found (checked m+n ≤ 8)")
        # Show some examples
        for m in [2, 3, 4]:
            for n in [2, 3, 4]:
                if m + n <= 8:
                    print(f"   c_{m+n} = {counts[m+n]:6d} ≤ c_{m} · c_{n} = "
                          f"{counts[m]:4d} × {counts[n]:4d} = {counts[m]*counts[n]:8d}")

    # 4. Bridge decomposition
    print("\n4. Bridge decomposition:")
    for n in range(1, 10):
        walks = enumerate_saws(n)
        bc = bridge_count(walks)
        print(f"   n={n}: {len(walks):6d} SAWs, {bc:5d} bridges "
              f"({100*bc/len(walks) if walks else 0:.1f}%)")

    # 5. Known bounds for Z² connective constant
    print("\n5. Known bounds for μ (Z² square lattice):")
    print(f"   Best known: μ ≈ 2.63815853...")
    print(f"   Our estimate c_14^(1/14) = {estimates[-1][2]:.8f}")
    print(f"   Nienhuis (hexagonal): μ_hex = {mu_hex:.8f}")
    print(f"   Note: Z² and hexagonal lattice have DIFFERENT connective constants")

    print("\n" + "=" * 60)
    print("Key proven results (in Lean 4):")
    print("  • c_0 = 1")
    print("  • c_{m+n} ≤ c_m · c_n (submultiplicativity)")
    print("  • μ_hex⁴ - 4μ_hex² + 2 = 0 (algebraic identity)")
    print("  • μ_hex > 1 and x_c = 1/μ_hex < 1")
    print("  • Walk coordinates bounded by walk length")
    print("  • Subadditivity of log(c_n) (Fekete's lemma prerequisite)")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of self-avoiding walks and connective constant convergence.
"""

import math
import random
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def enumerate_saws(n):
    """Enumerate all SAWs of length n on Z²."""
    if n == 0:
        return [[(0, 0)]]
    directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
    result = []
    def backtrack(path, visited):
        if len(path) == n + 1:
            result.append(list(path))
            return
        x, y = path[-1]
        for dx, dy in directions:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                path.append((nx, ny))
                backtrack(path, visited)
                path.pop()
                visited.discard((nx, ny))
    backtrack([(0, 0)], {(0, 0)})
    return result


def pivot_sample(n, steps=5000, seed=42):
    """Generate a sample SAW using pivot algorithm."""
    random.seed(seed)
    current = [(i, 0) for i in range(n + 1)]
    symmetries = [
        lambda p, c: (c[0] - (p[1] - c[1]), c[1] + (p[0] - c[0])),
        lambda p, c: (c[0] - (p[0] - c[0]), c[1] - (p[1] - c[1])),
        lambda p, c: (c[0] + (p[1] - c[1]), c[1] - (p[0] - c[0])),
        lambda p, c: (c[0] - (p[0] - c[0]), c[1] + (p[1] - c[1])),
        lambda p, c: (c[0] + (p[0] - c[0]), c[1] - (p[1] - c[1])),
    ]
    for _ in range(steps):
        pivot_idx = random.randint(1, n)
        pivot = current[pivot_idx]
        sym = random.choice(symmetries)
        new_tail = [sym(current[j], pivot) for j in range(pivot_idx, n + 1)]
        head_set = set(current[:pivot_idx])
        tail_set = set(new_tail)
        if len(tail_set) == len(new_tail) and head_set.isdisjoint(tail_set):
            current = current[:pivot_idx] + new_tail
    return current


def plot_saw_gallery():
    """Plot a gallery of SAWs of various lengths."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 9))
    fig.suptitle('Self-Avoiding Walks on ℤ²', fontsize=16, fontweight='bold')

    # Small exact SAWs
    for idx, n in enumerate([4, 6, 8]):
        ax = axes[0][idx]
        walks = enumerate_saws(n)
        # Plot a few random walks
        random.seed(42)
        sample = random.sample(walks, min(20, len(walks)))
        colors = plt.cm.viridis(np.linspace(0, 1, len(sample)))
        for walk, color in zip(sample, colors):
            xs = [p[0] for p in walk]
            ys = [p[1] for p in walk]
            ax.plot(xs, ys, '-', color=color, alpha=0.5, linewidth=1)
            ax.plot(xs[0], ys[0], 'ko', markersize=3)
            ax.plot(xs[-1], ys[-1], 's', color=color, markersize=3)
        ax.set_title(f'n={n}, c_{n}={len(walks)}', fontsize=12)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    # Longer pivot-sampled SAWs
    for idx, n in enumerate([50, 200, 500]):
        ax = axes[1][idx]
        walk = pivot_sample(n, steps=10000, seed=42 + idx)
        xs = [p[0] for p in walk]
        ys = [p[1] for p in walk]
        # Color by position along walk
        for i in range(len(walk) - 1):
            t = i / (len(walk) - 1)
            color = plt.cm.plasma(t)
            ax.plot([xs[i], xs[i+1]], [ys[i], ys[i+1]], '-', color=color, linewidth=1.5)
        ax.plot(xs[0], ys[0], 'go', markersize=6, label='start')
        ax.plot(xs[-1], ys[-1], 'rs', markersize=6, label='end')
        ax.set_title(f'Pivot sample, n={n}', fontsize=12)
        ax.set_aspect('equal')
        ax.legend(fontsize=8)

    plt.tight_layout()
    plt.savefig('saw_gallery.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved saw_gallery.png")


def plot_connective_constant():
    """Plot the convergence of c_n^{1/n} to μ."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Known SAW counts for Z² (from OEIS A001411)
    known_counts = {
        0: 1, 1: 4, 2: 12, 3: 36, 4: 100, 5: 284,
        6: 780, 7: 2172, 8: 5916, 9: 16268, 10: 44100,
        11: 120292, 12: 324932, 13: 881500, 14: 2374444,
        15: 6416596, 16: 17245332
    }

    ns = sorted(known_counts.keys())[1:]  # skip n=0
    mu_estimates = [known_counts[n] ** (1.0/n) for n in ns]
    log_estimates = [math.log(known_counts[n]) / n for n in ns]

    # Best known value
    mu_best = 2.63815853

    ax1.plot(ns, mu_estimates, 'bo-', markersize=6, label=r'$c_n^{1/n}$')
    ax1.axhline(y=mu_best, color='r', linestyle='--', alpha=0.7,
                label=f'μ ≈ {mu_best}')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel(r'$c_n^{1/n}$', fontsize=12)
    ax1.set_title('Convergence of SAW growth rate (Z²)', fontsize=13)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Nienhuis constant comparison
    mu_hex = math.sqrt(2 + math.sqrt(2))
    ax1.axhline(y=mu_hex, color='g', linestyle=':', alpha=0.7,
                label=f'μ_hex = √(2+√2) ≈ {mu_hex:.4f}')
    ax1.legend(fontsize=10)

    # Log plot
    ax2.plot(ns, log_estimates, 'go-', markersize=6, label=r'$\log(c_n)/n$')
    ax2.axhline(y=math.log(mu_best), color='r', linestyle='--', alpha=0.7,
                label=f'log(μ) ≈ {math.log(mu_best):.6f}')
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel(r'$\log(c_n)/n$', fontsize=12)
    ax2.set_title('Log growth rate (Fekete\'s lemma)', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('connective_constant.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved connective_constant.png")


def plot_nienhuis_polynomial():
    """Plot the minimal polynomial x⁴ - 4x² + 2 of μ_hex."""
    fig, ax = plt.subplots(figsize=(8, 5))

    x = np.linspace(0, 2.5, 1000)
    y = x**4 - 4*x**2 + 2

    mu_hex = math.sqrt(2 + math.sqrt(2))

    ax.plot(x, y, 'b-', linewidth=2, label=r'$p(x) = x^4 - 4x^2 + 2$')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.plot(mu_hex, 0, 'ro', markersize=10, zorder=5,
            label=fr'$\mu_{{hex}} = \sqrt{{2+\sqrt{{2}}}} \approx {mu_hex:.4f}$')

    # Other roots
    root2 = math.sqrt(2 - math.sqrt(2))
    ax.plot(root2, 0, 'gs', markersize=8, zorder=5,
            label=fr'$\sqrt{{2-\sqrt{{2}}}} \approx {root2:.4f}$')

    ax.set_xlabel('x', fontsize=12)
    ax.set_ylabel('p(x)', fontsize=12)
    ax.set_title('Minimal polynomial of the hexagonal connective constant', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-3, 5)

    plt.tight_layout()
    plt.savefig('nienhuis_polynomial.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved nienhuis_polynomial.png")


if __name__ == "__main__":
    plot_saw_gallery()
    plot_connective_constant()
    plot_nienhuis_polynomial()
    print("All visualizations generated.")
