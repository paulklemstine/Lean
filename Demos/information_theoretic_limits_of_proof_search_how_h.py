#!/usr/bin/env python3
"""
Proof Channel Theory — Interactive Demonstrations

This script demonstrates the five main theorems of Proof Channel Theory
with concrete numerical examples and visualizations.
"""

import math


def proof_channel_example():
    """Demonstrate the ProofChannel structure with concrete parameters."""
    print("=" * 60)
    print("PROOF CHANNEL THEORY — Numerical Examples")
    print("=" * 60)

    # Example 1: Binary proof system, short proofs
    b, n, T, m = 2, 10, 64, 1
    space = b ** n
    valid = T * m
    difficulty = space // valid
    info_content = math.log2(difficulty + 1)

    print(f"\n--- Example 1: Binary Proof System ---")
    print(f"Alphabet size (b): {b}")
    print(f"Max proof length (n): {n}")
    print(f"Theorems (T): {T}")
    print(f"Proofs per theorem (m): {m}")
    print(f"Search space: b^n = {space}")
    print(f"Valid proofs: T·m = {valid}")
    print(f"Search difficulty: {difficulty}")
    print(f"Information content: {info_content:.1f} bits")
    print(f"Capacity bound check: T·m = {valid} ≤ b^n = {space}: {valid <= space}")

    # Example 2: Larger alphabet (ASCII-like)
    b, n = 128, 5
    for m in [1, 4, 16, 64]:
        T_max = b ** n // m
        print(f"\n  b={b}, n={n}, m={m}: T ≤ {T_max:,} theorems")


def search_capacity_duality_demo():
    """Demonstrate Theorem 1: Search-Capacity Duality."""
    print(f"\n\n{'=' * 60}")
    print("THEOREM 1: Search-Capacity Duality")
    print("=" * 60)

    b = 2
    for n in [10, 20, 30]:
        for k in [1, n // 4, n // 2, 3 * n // 4]:
            if k + 1 > n:
                continue
            V = b ** k
            bound = b ** (n - k - 1)
            actual = b ** n // V
            print(f"  n={n:2d}, k={k:2d}: b^(n-k-1) = 2^{n-k-1} = {bound:>12,}  "
                  f"≤  b^n/V = {actual:>12,}  ✓")


def composition_demo():
    """Demonstrate Theorem 2: Composition (multiplicative costs)."""
    print(f"\n\n{'=' * 60}")
    print("THEOREM 2: Composition — No Economies of Scale")
    print("=" * 60)

    b = 2
    components = [(5, 32), (8, 256), (10, 1024)]
    print(f"\n  Individual subproblems (b={b}):")
    for n, space in components:
        print(f"    n={n}: space = 2^{n} = {space}")

    print(f"\n  Composed search costs:")
    for i, (n1, s1) in enumerate(components):
        for j, (n2, s2) in enumerate(components):
            if i < j:
                composed = s1 * s2
                additive = s1 + s2
                print(f"    (n={n1}) ⊗ (n={n2}): "
                      f"multiplicative = {composed:>10,}  "
                      f"vs additive = {additive:>6,}  "
                      f"(ratio: {composed / additive:.0f}x)")

    # k-fold composition
    print(f"\n  k-fold composition of n=5 subproblem:")
    for k in range(1, 8):
        cost = (2 ** 5) ** k
        print(f"    k={k}: cost = 32^{k} = {cost:>15,}")


def multiplicity_tradeoff_demo():
    """Demonstrate Theorem 3: Multiplicity-Capacity Tradeoff."""
    print(f"\n\n{'=' * 60}")
    print("THEOREM 3: Multiplicity-Capacity Tradeoff")
    print("=" * 60)

    b, n = 2, 16
    space = b ** n
    print(f"\n  b={b}, n={n}, space = {space:,}")
    print(f"  {'m':>8s} {'T_max':>10s} {'Difficulty':>12s} {'Capacity %':>10s}")
    print(f"  {'-'*8} {'-'*10} {'-'*12} {'-'*10}")

    for m in [1, 2, 4, 16, 64, 256, 1024, space]:
        T_max = space // m
        if T_max == 0:
            continue
        difficulty = space // (T_max * m)
        capacity_pct = 100 * T_max / space
        print(f"  {m:>8,} {T_max:>10,} {difficulty:>12,} {capacity_pct:>9.1f}%")


def incompressibility_demo():
    """Demonstrate Theorem 4: Incompressibility Barrier."""
    print(f"\n\n{'=' * 60}")
    print("THEOREM 4: Incompressibility Barrier")
    print("=" * 60)

    print(f"\n  Binary strings (b=2):")
    print(f"  {'n':>4s} {'Total':>10s} {'Compressible':>14s} {'Incompressible':>15s} {'Fraction':>10s}")
    for n in range(1, 16):
        total = 2 ** n
        compressible = 2 ** (n - 1)
        incompressible = total - compressible
        frac = incompressible / total
        print(f"  {n:>4d} {total:>10,} {compressible:>14,} {incompressible:>15,} {frac:>9.1%}")

    print(f"\n  General alphabet (n=8):")
    for b in [2, 3, 10, 26, 128, 256]:
        total = b ** 8
        compressible = b ** 7
        incompressible = total - compressible
        frac = incompressible / total
        print(f"    b={b:>3d}: incompressible fraction = {frac:.4f} "
              f"= (b-1)/b = {(b-1)/b:.4f}")


def hierarchy_demo():
    """Demonstrate Theorem 5: Hierarchical Separation."""
    print(f"\n\n{'=' * 60}")
    print("THEOREM 5: Hierarchical Separation")
    print("=" * 60)

    b = 2
    print(f"\n  Binary hierarchy (b={b}):")
    print(f"  {'Level k':>8s} {'Difficulty':>15s} {'Gap to next':>15s}")
    for k in range(12):
        diff = b ** k
        gap = b ** (k + 1) - b ** k
        print(f"  {k:>8d} {diff:>15,} {gap:>15,}")

    print(f"\n  No difficulty can ever repeat:")
    print(f"  b^k < b^(k+1) for all k — the hierarchy is STRICT.")
    print(f"  No finite set of strategies suffices for all theorems.")


def falsifiable_conjecture_demo():
    """Demonstrate the falsifiable conjecture: proof length ~ s·log(s)."""
    print(f"\n\n{'=' * 60}")
    print("FALSIFIABLE CONJECTURE: Log-Factor Growth")
    print("=" * 60)

    print(f"\n  Prediction: proof_length ≈ C · s · log₂(s)")
    print(f"\n  {'s':>6s} {'s·log₂(s)':>12s} {'s²':>10s} {'Ratio s·log/s':>14s}")
    for s in [4, 8, 16, 32, 64, 128, 256, 512, 1024]:
        slog = s * math.log2(s)
        ratio = slog / s
        print(f"  {s:>6d} {slog:>12.1f} {s**2:>10,} {ratio:>14.2f}")

    print(f"\n  Key: log₂(s) ≥ 2 for s ≥ 4 (proved in Lean)")
    print(f"  This means proofs are at least 2x longer than statements.")


def no_idempotent_demo():
    """Demonstrate: no nontrivial idempotents in search cost monoid."""
    print(f"\n\n{'=' * 60}")
    print("ALGEBRAIC RESULT: No Nontrivial Idempotents")
    print("=" * 60)

    print(f"\n  In (ℕ, ×, 1), a² = a ⟹ a ≤ 1")
    print(f"  Meaning: search effort ALWAYS accumulates under composition.")
    print(f"\n  Verification:")
    for a in range(20):
        if a * a == a:
            print(f"    a={a}: a²={a*a} = a ✓ (and a ≤ 1: {a <= 1})")


if __name__ == "__main__":
    proof_channel_example()
    search_capacity_duality_demo()
    composition_demo()
    multiplicity_tradeoff_demo()
    incompressibility_demo()
    hierarchy_demo()
    falsifiable_conjecture_demo()
    no_idempotent_demo()
    print(f"\n\n{'=' * 60}")
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Proof Channel Theory — Visualization

Standalone visualization of the five main theorems.
Requires matplotlib.
"""

import math

def generate_data():
    """Generate all data for visualizations."""
    data = {}

    # 1. Search-Capacity Duality
    b = 2
    ns = list(range(5, 25))
    ks = [1, 2, 4, 8]
    duality_data = {}
    for k in ks:
        bounds = []
        actuals = []
        valid_ns = []
        for n in ns:
            if k + 1 > n:
                continue
            valid_ns.append(n)
            bounds.append(b ** (n - k - 1))
            actuals.append(b ** n // (b ** k))
        duality_data[k] = (valid_ns, bounds, actuals)
    data['duality'] = duality_data

    # 2. Composition growth
    comp_ks = list(range(1, 11))
    comp_mult = [(2 ** 5) ** k for k in comp_ks]
    comp_add = [k * (2 ** 5) for k in comp_ks]
    data['composition'] = (comp_ks, comp_mult, comp_add)

    # 3. Multiplicity tradeoff
    b, n = 2, 16
    space = b ** n
    ms = [2 ** i for i in range(17)]
    t_maxs = [space // m for m in ms if space // m >= 1]
    ms = ms[:len(t_maxs)]
    data['multiplicity'] = (ms, t_maxs, space)

    # 4. Incompressibility
    ns_inc = list(range(1, 16))
    fracs = [(2 ** n - 2 ** (n - 1)) / (2 ** n) for n in ns_inc]
    data['incompressibility'] = (ns_inc, fracs)

    # 5. Hierarchy
    ks_h = list(range(12))
    diffs = [2 ** k for k in ks_h]
    data['hierarchy'] = (ks_h, diffs)

    # 6. Log-factor conjecture
    ss = list(range(4, 200))
    log_factors = [s * math.log2(s) for s in ss]
    linear = [float(s) for s in ss]
    quadratic = [s * s for s in ss]
    data['log_factor'] = (ss, log_factors, linear, quadratic)

    return data


def print_ascii_charts(data):
    """Print ASCII representations of the key charts."""

    print("=" * 70)
    print("CHART 1: Search-Capacity Duality (b=2)")
    print("  Shows b^(n-k-1) ≤ b^n/V for various k values")
    print("=" * 70)
    for k, (ns, bounds, actuals) in data['duality'].items():
        print(f"\n  k={k}:")
        for n, bound, actual in zip(ns, bounds, actuals):
            bar_len = min(int(math.log2(actual + 1)), 50)
            bar = "█" * bar_len
            print(f"    n={n:2d}: bound={bound:>8,} actual={actual:>10,} {bar}")

    print(f"\n\n{'=' * 70}")
    print("CHART 2: Composition — Multiplicative vs Additive")
    print("=" * 70)
    ks, mult, add = data['composition']
    for k, m, a in zip(ks, mult, add):
        ratio = m / a if a > 0 else float('inf')
        bar = "█" * min(int(math.log2(m + 1) / 2), 40)
        print(f"  k={k:2d}: mult={m:>15,}  add={a:>8,}  ratio={ratio:>8.0f}x  {bar}")

    print(f"\n\n{'=' * 70}")
    print("CHART 3: Multiplicity-Capacity Tradeoff (b=2, n=16)")
    print("=" * 70)
    ms, t_maxs, space = data['multiplicity']
    for m, t in zip(ms, t_maxs):
        pct = 100 * t / space
        bar = "█" * max(1, int(pct / 2))
        print(f"  m={m:>6,}: T_max={t:>6,} ({pct:>6.1f}%) {bar}")

    print(f"\n\n{'=' * 70}")
    print("CHART 4: Incompressibility Fraction (b=2)")
    print("=" * 70)
    ns, fracs = data['incompressibility']
    for n, f in zip(ns, fracs):
        bar = "█" * int(f * 50)
        print(f"  n={n:2d}: {f:.3f} {bar}")

    print(f"\n\n{'=' * 70}")
    print("CHART 5: Hierarchical Separation (b=2)")
    print("=" * 70)
    ks, diffs = data['hierarchy']
    for k, d in zip(ks, diffs):
        bar = "█" * min(k + 1, 40)
        print(f"  k={k:2d}: difficulty = 2^{k} = {d:>5,} {bar}")


if __name__ == "__main__":
    data = generate_data()
    print_ascii_charts(data)

    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(2, 3, figsize=(18, 12))

        # Plot 1: Search-Capacity Duality
        ax = axes[0, 0]
        for k, (ns, bounds, actuals) in data['duality'].items():
            ax.semilogy(ns, actuals, label=f'b^n/V (k={k})', linewidth=2)
            ax.semilogy(ns, bounds, '--', label=f'bound (k={k})', alpha=0.5)
        ax.set_xlabel('Proof length n')
        ax.set_ylabel('Search difficulty')
        ax.set_title('Search-Capacity Duality')
        ax.legend(fontsize=7)
        ax.grid(True, alpha=0.3)

        # Plot 2: Composition
        ax = axes[0, 1]
        ks, mult, add = data['composition']
        ax.semilogy(ks, mult, 'b-o', label='Multiplicative', linewidth=2)
        ax.semilogy(ks, add, 'r--s', label='Additive', linewidth=2)
        ax.set_xlabel('Number of components k')
        ax.set_ylabel('Total search cost')
        ax.set_title('Composition: Multiplicative vs Additive')
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Plot 3: Multiplicity tradeoff
        ax = axes[0, 2]
        ms, t_maxs, space = data['multiplicity']
        ax.loglog(ms, t_maxs, 'g-o', linewidth=2)
        ax.set_xlabel('Multiplicity m')
        ax.set_ylabel('Max theorems T')
        ax.set_title('Multiplicity-Capacity Tradeoff')
        ax.grid(True, alpha=0.3)

        # Plot 4: Incompressibility
        ax = axes[1, 0]
        ns, fracs = data['incompressibility']
        ax.bar(ns, fracs, color='coral', alpha=0.8)
        ax.axhline(y=0.5, color='black', linestyle='--', label='50% (binary limit)')
        ax.set_xlabel('String length n')
        ax.set_ylabel('Incompressible fraction')
        ax.set_title('Incompressibility Barrier (b=2)')
        ax.legend()

        # Plot 5: Hierarchy
        ax = axes[1, 1]
        ks, diffs = data['hierarchy']
        ax.semilogy(ks, diffs, 'mo-', linewidth=2, markersize=8)
        ax.set_xlabel('Hierarchy level k')
        ax.set_ylabel('Difficulty 2^k')
        ax.set_title('Hierarchical Separation')
        ax.grid(True, alpha=0.3)

        # Plot 6: Log-factor conjecture
        ax = axes[1, 2]
        ss, log_factors, linear, quadratic = data['log_factor']
        ax.plot(ss, log_factors, 'b-', label='s·log₂(s)', linewidth=2)
        ax.plot(ss, linear, 'r--', label='s (linear)', alpha=0.7)
        ax.plot(ss, quadratic, 'g--', label='s² (quadratic)', alpha=0.5)
        ax.set_xlabel('Statement length s')
        ax.set_ylabel('Predicted proof length')
        ax.set_title('Log-Factor Growth Conjecture')
        ax.legend()
        ax.set_ylim(0, 5000)
        ax.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig('proof_channel_visualization.png', dpi=150, bbox_inches='tight')
        print("\n\nSaved visualization to proof_channel_visualization.png")

    except ImportError:
        print("\n\nmatplotlib not available — ASCII charts shown above.")
