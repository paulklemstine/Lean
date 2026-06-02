"""
Sheaf-Theoretic Data Integration: Demo

Demonstrates the key results:
1. Consistency checking for partial databases
2. Sheaf imputation vs mean imputation
3. Exponential decay of consistency probability
4. Verification of δ² = 0
"""

import numpy as np
from algorithms import (
    PartialDatabase, consistent_pair, gluing_map,
    pairwise_disagreement, consistency_defect, overlap_count,
    consistency_probability, sheaf_imputation, mean_imputation,
    cech_coboundary_zero, cech_coboundary_one, verify_coboundary_sq_zero
)

np.random.seed(42)


def demo_consistency():
    """Demo 1: Partial database consistency."""
    print("=" * 60)
    print("DEMO 1: Partial Database Consistency")
    print("=" * 60)

    # Create two consistent partial databases
    db1_data = np.array([
        [1.0, np.nan, 3.0],
        [np.nan, 5.0, np.nan],
        [7.0, np.nan, 9.0]
    ])
    db2_data = np.array([
        [1.0, 2.0, np.nan],
        [4.0, 5.0, np.nan],
        [np.nan, 8.0, 9.0]
    ])

    db1 = PartialDatabase(db1_data)
    db2 = PartialDatabase(db2_data)

    print(f"DB1:\n{db1.data}")
    print(f"DB2:\n{db2.data}")
    print(f"Consistent: {consistent_pair(db1, db2)}")
    print(f"Disagreements: {pairwise_disagreement(db1, db2)}")

    # Glue them
    glued = gluing_map(db1, db2)
    print(f"Glued:\n{glued.data}")

    # Create an inconsistent pair
    db3_data = np.array([
        [999.0, np.nan, 3.0],
        [np.nan, 5.0, np.nan],
        [7.0, np.nan, 9.0]
    ])
    db3 = PartialDatabase(db3_data)
    print(f"\nDB1 vs DB3 (inconsistent):")
    print(f"Consistent: {consistent_pair(db1, db3)}")
    print(f"Disagreements: {pairwise_disagreement(db1, db3)}")
    print()


def demo_defect_vs_overlap():
    """Demo 2: Consistency defect ≤ overlap count."""
    print("=" * 60)
    print("DEMO 2: Defect ≤ Overlap Count (Verified Theorem)")
    print("=" * 60)

    for trial in range(5):
        nRows, nCols, n = 10, 5, 4
        dbs = []
        for _ in range(n):
            data = np.random.randint(0, 3, size=(nRows, nCols)).astype(float)
            mask = np.random.random((nRows, nCols)) < 0.4
            data[mask] = np.nan
            dbs.append(PartialDatabase(data))

        defect = consistency_defect(dbs)
        overlap = overlap_count(dbs)
        print(f"Trial {trial+1}: defect={defect}, overlap={overlap}, "
              f"defect ≤ overlap: {defect <= overlap}")
    print()


def demo_exponential_decay():
    """Demo 3: Exponential decay of consistency probability."""
    print("=" * 60)
    print("DEMO 3: Exponential Decay of Consistency Probability")
    print("=" * 60)

    rates = [0.1, 0.2, 0.3, 0.5]
    constraints = [10, 50, 100, 500, 1000]

    print(f"{'Rate':>6} | " + " | ".join(f"C={c:>4}" for c in constraints))
    print("-" * 60)
    for r in rates:
        probs = [consistency_probability(r, c) for c in constraints]
        print(f"{r:>6.1f} | " + " | ".join(f"{p:>8.2e}" for p in probs))

    print("\nFor n=20 columns, k=100 rows, r=0.3:")
    C = 20 * 19 // 2 * 100  # n*(n-1)/2 * k
    prob = consistency_probability(0.3, C)
    print(f"  Constraints C = {C}")
    print(f"  P(consistent) = {prob:.2e}")
    print(f"  This is essentially zero → random databases are almost never consistent")
    print()


def demo_coboundary_sq_zero():
    """Demo 4: δ¹ ∘ δ⁰ = 0 (Verified Theorem)."""
    print("=" * 60)
    print("DEMO 4: Čech Coboundary δ² = 0 (Verified Theorem)")
    print("=" * 60)

    for n in [3, 5, 10]:
        result = verify_coboundary_sq_zero(n)
        print(f"  n={n}: δ¹∘δ⁰ = 0? {result}")
    print()


def demo_imputation_comparison():
    """Demo 5: Sheaf imputation vs mean imputation."""
    print("=" * 60)
    print("DEMO 5: Sheaf vs Mean Imputation")
    print("=" * 60)

    nRows, nCols = 50, 10
    # Generate ground truth with structure (correlated columns)
    ground_truth = np.random.randn(nRows, nCols)
    # Add correlations: columns 0-4 are correlated, 5-9 are correlated
    for i in range(1, 5):
        ground_truth[:, i] = ground_truth[:, 0] + 0.3 * np.random.randn(nRows)
    for i in range(6, 10):
        ground_truth[:, i] = ground_truth[:, 5] + 0.3 * np.random.randn(nRows)

    missing_rates = [0.1, 0.2, 0.3, 0.4, 0.5]

    print(f"{'Rate':>6} | {'Mean MSE':>10} | {'Sheaf MSE':>10} | {'Winner':>8}")
    print("-" * 50)

    for rate in missing_rates:
        mse_mean_list = []
        mse_sheaf_list = []
        for _ in range(10):
            observed_data = ground_truth.copy()
            mask = np.random.random((nRows, nCols)) < rate
            observed_data[mask] = np.nan
            observed = PartialDatabase(observed_data)

            # Feature subsets for sheaf imputation
            feature_subsets = [
                set(range(0, 5)),
                set(range(5, 10)),
                set(range(0, 3)),
                set(range(3, 7)),
                set(range(7, 10)),
            ]

            mean_result = mean_imputation(observed)
            sheaf_result = sheaf_imputation(observed, feature_subsets, n_iterations=50)

            mse_mean = np.mean((mean_result - ground_truth) ** 2)
            mse_sheaf = np.mean((sheaf_result - ground_truth) ** 2)

            mse_mean_list.append(mse_mean)
            mse_sheaf_list.append(mse_sheaf)

        avg_mean = np.mean(mse_mean_list)
        avg_sheaf = np.mean(mse_sheaf_list)
        winner = "Sheaf" if avg_sheaf < avg_mean else "Mean"
        print(f"{rate:>6.1f} | {avg_mean:>10.4f} | {avg_sheaf:>10.4f} | {winner:>8}")

    print()


def demo_pair_cost_bound():
    """Demo 6: Pair imputation cost ≥ disagreement (Verified Theorem)."""
    print("=" * 60)
    print("DEMO 6: Imputation Cost ≥ Disagreement (Verified Theorem)")
    print("=" * 60)

    for trial in range(5):
        nRows, nCols = 20, 8
        db1_data = np.random.randint(0, 5, (nRows, nCols)).astype(float)
        db2_data = np.random.randint(0, 5, (nRows, nCols)).astype(float)
        mask1 = np.random.random((nRows, nCols)) < 0.3
        mask2 = np.random.random((nRows, nCols)) < 0.3
        db1_data[mask1] = np.nan
        db2_data[mask2] = np.nan

        db1 = PartialDatabase(db1_data)
        db2 = PartialDatabase(db2_data)

        disagreement = pairwise_disagreement(db1, db2)

        # Try random candidate
        candidate = np.random.randint(0, 5, (nRows, nCols)).astype(float)

        cost1 = int(np.sum((~np.isnan(db1.data)) & (db1.data != candidate)))
        cost2 = int(np.sum((~np.isnan(db2.data)) & (db2.data != candidate)))

        print(f"Trial {trial+1}: disagreement={disagreement}, "
              f"cost1+cost2={cost1+cost2}, "
              f"bound holds: {disagreement <= cost1 + cost2}")
    print()


if __name__ == "__main__":
    demo_consistency()
    demo_defect_vs_overlap()
    demo_exponential_decay()
    demo_coboundary_sq_zero()
    demo_imputation_comparison()
    demo_pair_cost_bound()

    print("=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Exponential Decay of Consistency Probability

Shows how the probability of database consistency decays exponentially
with the number of constraints, parameterized by disagreement rate.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def consistency_probability(r, C):
    """P(consistent) = (1-r)^C"""
    return (1.0 - r) ** C

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Probability vs constraint count for various rates
    ax1 = axes[0]
    constraints = np.arange(0, 101)
    rates = [0.01, 0.05, 0.1, 0.2, 0.3, 0.5]
    colors = plt.cm.viridis(np.linspace(0, 0.9, len(rates)))

    for r, color in zip(rates, colors):
        probs = [consistency_probability(r, C) for C in constraints]
        ax1.plot(constraints, probs, color=color, linewidth=2, label=f'r={r}')

    ax1.set_xlabel('Number of Constraints (C)', fontsize=12)
    ax1.set_ylabel('P(consistent)', fontsize=12)
    ax1.set_title('Consistency Probability Decay', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.set_ylim(-0.05, 1.05)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Log probability vs constraints (shows exponential nature)
    ax2 = axes[1]
    constraints_log = np.arange(1, 501)

    for r, color in zip(rates, colors):
        log_probs = [np.log10(max(consistency_probability(r, C), 1e-300))
                     for C in constraints_log]
        ax2.plot(constraints_log, log_probs, color=color, linewidth=2, label=f'r={r}')

    ax2.set_xlabel('Number of Constraints (C)', fontsize=12)
    ax2.set_ylabel('log₁₀ P(consistent)', fontsize=12)
    ax2.set_title('Log Consistency Probability (Linear = Exponential Decay)', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('consistency_decay.png', dpi=150, bbox_inches='tight')
    print("Saved consistency_decay.png")

if __name__ == "__main__":
    main()
