#!/usr/bin/env python3
"""
Demo: Rota's Basis Conjecture — Greedy Algorithm and Verification

Demonstrates the greedy deficiency-reduction algorithm on random basis
arrangements for dimensions 2 through 6.
"""

import numpy as np
from algorithms import (
    random_basis,
    greedy_rota_solve,
    total_deficiency,
    verify_arrangement,
    build_column,
    independence_deficiency,
)


def demo_small_case():
    """Demonstrate the n=2 case with explicit bases."""
    print("=" * 60)
    print("DEMO 1: Rota's Basis Conjecture for n = 2")
    print("=" * 60)

    # Two bases of R^2
    v = np.array([[1.0, 0.0], [0.0, 1.0]])  # Standard basis
    w = np.array([[1.0, 1.0], [1.0, -1.0]])  # Another basis

    print(f"\nBasis 1 (v): {v.tolist()}")
    print(f"Basis 2 (w): {w.tolist()}")

    # Try identity arrangement
    perms_id = [[0, 1], [0, 1]]
    def_id = total_deficiency([v, w], perms_id)
    print(f"\nIdentity arrangement deficiency: {def_id}")
    print(f"  Column 0: [{v[0]}, {w[0]}] — rank = {np.linalg.matrix_rank(np.array([v[0], w[0]]))}")
    print(f"  Column 1: [{v[1]}, {w[1]}] — rank = {np.linalg.matrix_rank(np.array([v[1], w[1]]))}")

    # Try swap arrangement
    perms_sw = [[0, 1], [1, 0]]
    def_sw = total_deficiency([v, w], perms_sw)
    print(f"\nSwap arrangement deficiency: {def_sw}")
    print(f"  Column 0: [{v[0]}, {w[1]}] — rank = {np.linalg.matrix_rank(np.array([v[0], w[1]]))}")
    print(f"  Column 1: [{v[1]}, {w[0]}] — rank = {np.linalg.matrix_rank(np.array([v[1], w[0]]))}")

    result = greedy_rota_solve([v, w])
    print(f"\nGreedy solution: {result}")
    print(f"Valid: {verify_arrangement([v, w], result)}")


def demo_greedy_algorithm():
    """Run the greedy algorithm on random instances."""
    print("\n" + "=" * 60)
    print("DEMO 2: Greedy Algorithm on Random Instances")
    print("=" * 60)

    rng = np.random.default_rng(42)

    for n in range(2, 7):
        successes = 0
        total_swaps = 0
        num_trials = 100 if n <= 5 else 20

        for _ in range(num_trials):
            bases = [random_basis(n, rng) for _ in range(n)]
            result = greedy_rota_solve(bases)
            if result is not None:
                successes += 1
                # Count how many non-identity positions
                swaps = sum(1 for i in range(n) for j in range(n) if result[i][j] != j)
                total_swaps += swaps

        avg_swaps = total_swaps / max(successes, 1)
        print(f"  n = {n}: {successes}/{num_trials} solved, avg displaced entries = {avg_swaps:.1f}")


def demo_deficiency_landscape():
    """Show how deficiency varies across different arrangements."""
    print("\n" + "=" * 60)
    print("DEMO 3: Deficiency Landscape for n = 3")
    print("=" * 60)

    rng = np.random.default_rng(123)
    n = 3
    bases = [random_basis(n, rng) for _ in range(n)]

    print(f"\nBases:")
    for i, b in enumerate(bases):
        print(f"  B{i+1} = {np.round(b, 3).tolist()}")

    # Identity arrangement
    perms_id = [list(range(n)) for _ in range(n)]
    def_id = total_deficiency(bases, perms_id)
    print(f"\nIdentity arrangement: total deficiency = {def_id}")
    for j in range(n):
        col = build_column(bases, perms_id, j)
        d = independence_deficiency(col, n)
        print(f"  Column {j}: deficiency = {d}")

    # Greedy solution
    result = greedy_rota_solve(bases)
    if result:
        def_final = total_deficiency(bases, result)
        print(f"\nGreedy solution: {result}")
        print(f"Final deficiency: {def_final}")
        print(f"Valid arrangement: {verify_arrangement(bases, result)}")


def demo_greedy_conjecture_test():
    """Test the Greedy Rota Conjecture computationally."""
    print("\n" + "=" * 60)
    print("DEMO 4: Testing the Greedy Rota Conjecture")
    print("=" * 60)
    print("(Does a deficiency-reducing swap ALWAYS exist?)")

    rng = np.random.default_rng(999)

    for n in [2, 3, 4]:
        counterexamples = 0
        tests = 500 if n <= 3 else 100

        for _ in range(tests):
            bases = [random_basis(n, rng) for _ in range(n)]
            # Start with a random (possibly bad) arrangement
            perms = [list(rng.permutation(n)) for _ in range(n)]
            current_def = total_deficiency(bases, perms)

            if current_def == 0:
                continue

            # Check if any swap reduces deficiency
            found_improvement = False
            for i in range(n):
                for a in range(n):
                    for b in range(a + 1, n):
                        perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                        new_def = total_deficiency(bases, perms)
                        perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                        if new_def < current_def:
                            found_improvement = True
                            break
                    if found_improvement:
                        break
                if found_improvement:
                    break

            if not found_improvement:
                counterexamples += 1

        status = "✓ No counterexamples" if counterexamples == 0 else f"✗ {counterexamples} counterexamples!"
        print(f"  n = {n}: {tests} random arrangements tested — {status}")


if __name__ == "__main__":
    demo_small_case()
    demo_greedy_algorithm()
    demo_deficiency_landscape()
    demo_greedy_conjecture_test()
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Deficiency landscape for Rota's Basis Conjecture.

Shows how total deficiency varies across different permutation arrangements
for small dimensions, and how the greedy algorithm converges.
"""

import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("matplotlib not available; skipping plots")


def compute_rank(vectors):
    return int(np.linalg.matrix_rank(vectors, tol=1e-10))


def independence_deficiency(vectors, n):
    return n - compute_rank(vectors)


def build_column(bases, perms, col):
    n = len(bases)
    return np.array([bases[i][perms[i][col]] for i in range(n)])


def total_deficiency(bases, perms):
    n = len(bases)
    return sum(independence_deficiency(build_column(bases, perms, j), n) for j in range(n))


def random_basis(n, rng):
    while True:
        M = rng.standard_normal((n, n))
        if abs(np.linalg.det(M)) > 1e-6:
            return M


def greedy_trace(bases, max_iter=1000):
    """Run greedy with deficiency trace."""
    n = len(bases)
    perms = [list(rng.permutation(n)) for _ in range(n)]
    trace = [total_deficiency(bases, perms)]

    for _ in range(max_iter):
        if trace[-1] == 0:
            break
        improved = False
        for i in range(n):
            for a in range(n):
                for b in range(a + 1, n):
                    perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                    new_def = total_deficiency(bases, perms)
                    if new_def < trace[-1]:
                        trace.append(new_def)
                        improved = True
                        break
                    else:
                        perms[i][a], perms[i][b] = perms[i][b], perms[i][a]
                if improved:
                    break
            if improved:
                break
        if not improved:
            break

    return trace


if HAS_MPL:
    rng = np.random.default_rng(42)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Plot 1: Greedy convergence traces for n=4
    ax1 = axes[0]
    for trial in range(10):
        bases = [random_basis(4, rng) for _ in range(4)]
        trace = greedy_trace(bases)
        ax1.plot(range(len(trace)), trace, alpha=0.7, linewidth=1.5)
    ax1.set_xlabel('Swap iteration')
    ax1.set_ylabel('Total deficiency')
    ax1.set_title('Greedy Convergence (n=4, 10 trials)')
    ax1.set_ylim(bottom=-0.5)

    # Plot 2: Initial vs final deficiency histogram for n=3
    ax2 = axes[1]
    initial_defs = []
    for _ in range(200):
        bases = [random_basis(3, rng) for _ in range(3)]
        perms = [list(rng.permutation(3)) for _ in range(3)]
        initial_defs.append(total_deficiency(bases, perms))
    ax2.hist(initial_defs, bins=range(max(initial_defs) + 2), edgecolor='black', alpha=0.7)
    ax2.set_xlabel('Total deficiency')
    ax2.set_ylabel('Count')
    ax2.set_title('Initial Deficiency Distribution (n=3)')

    # Plot 3: Success rate vs dimension
    ax3 = axes[2]
    dims = list(range(2, 7))
    rates = []
    for n in dims:
        success = 0
        trials = 50 if n <= 5 else 10
        for _ in range(trials):
            bases = [random_basis(n, rng) for _ in range(n)]
            perms = [list(range(n)) for _ in range(n)]
            if total_deficiency(bases, perms) == 0:
                success += 1
        rates.append(success / trials * 100)
    ax3.bar(dims, rates, color='steelblue', edgecolor='black')
    ax3.set_xlabel('Dimension n')
    ax3.set_ylabel('Identity success rate (%)')
    ax3.set_title('Identity Arrangement Success Rate')

    plt.tight_layout()
    plt.savefig('rota_deficiency_landscape.png', dpi=150)
    print("Saved rota_deficiency_landscape.png")
