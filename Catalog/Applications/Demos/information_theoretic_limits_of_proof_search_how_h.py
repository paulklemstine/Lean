"""
Information-Theoretic Limits of Proof Search: Demonstrations

Numerical examples illustrating the key theorems.
"""

import math
from algorithms import (
    ProofSearchSpace,
    ProofComplexityProfile,
    sparse_proof_search_bound,
    compressible_fraction,
    search_hierarchy_bound,
    proof_density_at_length,
    information_bottleneck_bound,
    log_factor_prediction,
)


def demo_search_difficulty():
    """Demonstrate exponential search difficulty."""
    print("=" * 60)
    print("DEMO 1: Exponential Search Difficulty")
    print("=" * 60)
    print()

    for n in [10, 20, 30, 40, 50]:
        b = 2
        k = n // 2  # Valid proofs = b^(n/2)
        V = b ** k
        space = ProofSearchSpace(
            alphabet_size=b,
            max_proof_len=n,
            valid_count=min(V, b**n),
            theorem_count=1
        )
        bound = sparse_proof_search_bound(b, n, k)
        print(f"  n={n:3d}:  search space = 2^{n} ≈ {b**n:.1e}")
        print(f"          valid proofs = 2^{k} ≈ {V:.1e}")
        print(f"          search bound = 2^{n-k-1} ≈ {bound:.1e}")
        print(f"          density = {space.proof_density:.2e}")
        print(f"          info content = {space.information_content_bits:.1f} bits")
        print()


def demo_incompressibility():
    """Demonstrate the incompressibility theorem."""
    print("=" * 60)
    print("DEMO 2: Incompressibility of Proofs")
    print("=" * 60)
    print()

    for b in [2, 4, 8, 16, 256]:
        frac = compressible_fraction(b, 10)
        print(f"  Alphabet size b={b:3d}: "
              f"compressible fraction ≤ {frac:.4f} = 1/{b}")
        print(f"    → At least {100*(1-frac):.1f}% of strings are incompressible")
    print()


def demo_hierarchy():
    """Demonstrate the search complexity hierarchy."""
    print("=" * 60)
    print("DEMO 3: Search Complexity Hierarchy")
    print("=" * 60)
    print()

    print(f"  {'Level k':>8} | {'Linear k+1':>12} | {'Exponential 2^k':>16} | {'Gap':>12}")
    print(f"  {'-'*8} | {'-'*12} | {'-'*16} | {'-'*12}")
    for k in range(16):
        lo, hi = search_hierarchy_bound(2, k)
        gap = hi / lo if lo > 0 else float('inf')
        print(f"  {k:8d} | {lo:12d} | {hi:16d} | {gap:12.1f}x")
    print()


def demo_density_decay():
    """Demonstrate proof density exponential decay."""
    print("=" * 60)
    print("DEMO 4: Proof Density Exponential Decay")
    print("=" * 60)
    print()

    V = 1000  # Fixed number of valid proofs
    b = 2
    print(f"  Fixed V = {V} valid proofs, alphabet size b = {b}")
    print()
    print(f"  {'Length n':>10} | {'Space b^n':>16} | {'Density':>14} | {'Info (bits)':>12}")
    print(f"  {'-'*10} | {'-'*16} | {'-'*14} | {'-'*12}")
    for n in range(10, 51, 5):
        density = proof_density_at_length(V, b, n)
        info = -math.log2(density) if density > 0 else float('inf')
        print(f"  {n:10d} | {b**n:16.2e} | {density:14.2e} | {info:12.1f}")
    print()


def demo_bottleneck():
    """Demonstrate the mutual information bottleneck."""
    print("=" * 60)
    print("DEMO 5: Mutual Information Bottleneck")
    print("=" * 60)
    print()

    print("  Maximum theorems provable with proofs of length n:")
    print()
    for b in [2, 10, 256]:
        print(f"  Alphabet size b = {b}:")
        for n in [5, 10, 20, 50]:
            bound = information_bottleneck_bound(b, n)
            bits = n * math.log2(b)
            print(f"    n={n:3d}: T ≤ {bound:.2e}  ({bits:.0f} bits of info)")
        print()


def demo_log_factor():
    """Demonstrate the log-factor conjecture prediction."""
    print("=" * 60)
    print("DEMO 6: Log-Factor Conjecture Predictions")
    print("=" * 60)
    print()

    print(f"  {'Stmt len s':>12} | {'Predicted proof len':>20} | {'Ratio p/s':>10} | {'log₂(s)':>8}")
    print(f"  {'-'*12} | {'-'*20} | {'-'*10} | {'-'*8}")
    for s in [4, 8, 16, 32, 64, 128, 256, 512, 1024]:
        p = log_factor_prediction(s)
        ratio = p / s if s > 0 else 0
        log_s = math.log2(s)
        print(f"  {s:12d} | {p:20.1f} | {ratio:10.2f} | {log_s:8.2f}")
    print()


def demo_ordered_vs_unordered():
    """Demonstrate the ordered vs. unordered search gap."""
    print("=" * 60)
    print("DEMO 7: Ordered vs. Unordered Search Gap")
    print("=" * 60)
    print()

    print(f"  {'n':>5} | {'Ordered (n)':>14} | {'Unordered (2^(n-1))':>22} | {'Gap':>14}")
    print(f"  {'-'*5} | {'-'*14} | {'-'*22} | {'-'*14}")
    for n in range(3, 21):
        ordered = n
        unordered = 2 ** (n - 1)
        gap = unordered / ordered
        print(f"  {n:5d} | {ordered:14d} | {unordered:22d} | {gap:14.1f}x")
    print()


def demo_duality():
    """Demonstrate theorem-proof duality."""
    print("=" * 60)
    print("DEMO 8: Theorem-Proof Duality Trade-off")
    print("=" * 60)
    print()

    S = 2 ** 20  # Search space size
    print(f"  Search space S = 2^20 = {S:,}")
    print(f"  Trade-off between theorems (T) and proofs per theorem (k):")
    print()
    print(f"  {'Theorems T':>12} | {'Proofs/thm k':>14} | {'T × k':>12} | {'≤ S?':>6}")
    print(f"  {'-'*12} | {'-'*14} | {'-'*12} | {'-'*6}")
    for T_exp in range(0, 21, 2):
        T = 2 ** T_exp
        k = S // T if T > 0 else 0
        product = T * k
        ok = "✓" if product <= S else "✗"
        print(f"  {T:12,} | {k:14,} | {product:12,} | {ok:>6}")
    print()


if __name__ == "__main__":
    demo_search_difficulty()
    demo_incompressibility()
    demo_hierarchy()
    demo_density_decay()
    demo_bottleneck()
    demo_log_factor()
    demo_ordered_vs_unordered()
    demo_duality()


"""
Visualization: Search Complexity Hierarchy

Plots the exponential hierarchy of search complexities,
showing how b^k dominates k+1 at every level.
"""

import math


def plot():
    """Create the hierarchy visualization."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot generation")
        return

    ks = list(range(0, 16))
    bases = [2, 3, 5, 10]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Hierarchy for different bases
    ax1.plot(ks, [k + 1 for k in ks], 'k--', linewidth=2, label='k + 1 (linear)')
    colors = ['blue', 'red', 'green', 'orange']
    for b, c in zip(bases, colors):
        vals = [b ** k for k in ks]
        ax1.semilogy(ks, vals, f'-o', color=c, linewidth=2, markersize=4,
                     label=f'b^k (b={b})')

    ax1.set_xlabel('Level k', fontsize=12)
    ax1.set_ylabel('Complexity (log scale)', fontsize=12)
    ax1.set_title('Search Complexity Hierarchy: b^k vs k+1', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Gap ratio b^k / (k+1)
    for b, c in zip(bases, colors):
        gaps = [(b ** k) / (k + 1) for k in ks]
        ax2.semilogy(ks, gaps, f'-o', color=c, linewidth=2, markersize=4,
                     label=f'Gap ratio (b={b})')

    ax2.set_xlabel('Level k', fontsize=12)
    ax2.set_ylabel('Gap ratio b^k/(k+1) (log scale)', fontsize=12)
    ax2.set_title('Exponential Dominance Gap', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hierarchy_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved hierarchy_visualization.png")


if __name__ == "__main__":
    plot()


"""
Visualization: Log-Factor Conjecture

Plots the predicted proof length growth as s · log(s)
and the resulting search difficulty 2^(s · log(s)).
"""

import math


def plot():
    """Create the log-factor conjecture visualization."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot generation")
        return

    ss = list(range(4, 101))
    C = 3.0

    proof_lens = [C * s * math.log2(s) for s in ss]
    linear = [C * s for s in ss]
    quadratic = [C * s * s for s in ss]
    ratios = [proof_lens[i] / ss[i] for i in range(len(ss))]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Proof length growth
    ax1.plot(ss, proof_lens, 'r-', linewidth=2, label='s · log₂(s) (conjecture)')
    ax1.plot(ss, linear, 'b--', linewidth=1.5, label='s (linear)', alpha=0.7)
    ax1.plot(ss, quadratic, 'g:', linewidth=1.5, label='s² (quadratic)', alpha=0.7)
    ax1.set_xlabel('Statement length s', fontsize=12)
    ax1.set_ylabel('Proof length', fontsize=12)
    ax1.set_title('Proof Length Growth: The Log-Factor Conjecture', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(0, 5000)

    # Plot 2: Ratio p/s
    ax2.plot(ss, ratios, 'r-', linewidth=2)
    ax2.set_xlabel('Statement length s', fontsize=12)
    ax2.set_ylabel('Proof/statement ratio p/s', fontsize=12)
    ax2.set_title('Proof-to-Statement Ratio (should grow as log s)', fontsize=14)
    ax2.grid(True, alpha=0.3)

    # Add log₂(s) reference line
    log_refs = [math.log2(s) * C for s in ss]
    ax2.plot(ss, log_refs, 'b--', linewidth=1.5, label='C · log₂(s)', alpha=0.7)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('log_factor_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved log_factor_visualization.png")


if __name__ == "__main__":
    plot()


"""
Visualization: Search Difficulty vs. Proof Length

Plots the exponential growth of search difficulty as a function
of proof length, comparing brute-force search cost with
verification cost.
"""

import math

def generate_data():
    """Generate data for search difficulty visualization."""
    ns = list(range(1, 31))
    b = 2

    search_costs = []
    verification_costs = []
    densities = []

    for n in ns:
        k = n // 2
        search_bound = b ** (n - k - 1) if n > k + 1 else 1
        verif_cost = n  # Linear verification
        V = b ** k
        total = b ** n
        density = V / total

        search_costs.append(math.log2(search_bound) if search_bound > 0 else 0)
        verification_costs.append(math.log2(verif_cost) if verif_cost > 0 else 0)
        densities.append(density)

    return ns, search_costs, verification_costs, densities


def plot():
    """Create the visualization."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available; skipping plot generation")
        return

    ns, search_costs, verif_costs, densities = generate_data()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Search vs Verification
    ax1.plot(ns, search_costs, 'r-o', linewidth=2, markersize=4,
             label='Search cost (log₂)')
    ax1.plot(ns, verif_costs, 'b-s', linewidth=2, markersize=4,
             label='Verification cost (log₂)')
    ax1.fill_between(ns, verif_costs, search_costs, alpha=0.2, color='red',
                     label='Exponential gap')
    ax1.set_xlabel('Proof length n', fontsize=12)
    ax1.set_ylabel('Cost (log₂ scale)', fontsize=12)
    ax1.set_title('Search vs. Verification: The Exponential Gap', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Density Decay
    ax2.semilogy(ns, densities, 'g-^', linewidth=2, markersize=4)
    ax2.set_xlabel('Proof length n', fontsize=12)
    ax2.set_ylabel('Proof density (log scale)', fontsize=12)
    ax2.set_title('Proof Density Exponential Decay', fontsize=14)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('search_bounds_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved search_bounds_visualization.png")


if __name__ == "__main__":
    plot()
