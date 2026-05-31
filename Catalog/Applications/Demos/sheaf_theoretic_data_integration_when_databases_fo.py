"""
Sheaf-Theoretic Data Integration: Demo

Demonstrates the key concepts:
1. Consistency checking of partial databases
2. Coboundary norm computation
3. Exponential decay of consistency probability
4. Sheaf imputation vs. mean and KNN imputation
"""

import numpy as np
from algorithms import (
    consistency_check,
    sheaf_condition,
    gluing_map,
    coboundary_norm,
    consistency_probability,
    overlap_constraint_count,
    sheaf_imputation,
    mean_imputation,
    knn_imputation,
)


def demo_consistency():
    """Demonstrate consistency checking of partial databases."""
    print("=" * 60)
    print("DEMO 1: Partial Database Consistency")
    print("=" * 60)

    # Two consistent partial databases
    db1 = {(0, 0): 1.0, (0, 1): 2.0, (1, 0): None}
    db2 = {(0, 0): 1.0, (0, 1): None, (1, 0): 3.0}
    print(f"\ndb1 = {db1}")
    print(f"db2 = {db2}")
    print(f"Consistent? {consistency_check(db1, db2)}")

    # Two inconsistent partial databases
    db3 = {(0, 0): 1.0, (0, 1): 2.0}
    db4 = {(0, 0): 999.0, (0, 1): 2.0}
    print(f"\ndb3 = {db3}")
    print(f"db4 = {db4}")
    print(f"Consistent? {consistency_check(db3, db4)}")

    # Gluing consistent databases
    glued = gluing_map(db1, db2)
    print(f"\nGlued db1 ∪ db2 = {glued}")

    # Sheaf condition for a family
    print(f"\nSheaf condition for [db1, db2]: {sheaf_condition([db1, db2])}")
    print(f"Sheaf condition for [db1, db4]: {sheaf_condition([db1, db4])}")


def demo_coboundary():
    """Demonstrate coboundary norm computation."""
    print("\n" + "=" * 60)
    print("DEMO 2: Coboundary Norm (Inconsistency Measurement)")
    print("=" * 60)

    n_rows, n_cols = 3, 3

    # Consistent family
    db1 = {(r, c): float(r + c) for r in range(n_rows) for c in range(n_cols)}
    db2 = {(r, c): float(r + c) for r in range(n_rows) for c in range(n_cols)}
    norm_consistent = coboundary_norm([db1, db2], n_rows, n_cols)
    print(f"\nConsistent family coboundary norm: {norm_consistent}")
    print(f"Sheaf condition satisfied: {norm_consistent == 0}")

    # Inconsistent family
    db3 = {(r, c): float(r + c + 100) for r in range(n_rows) for c in range(n_cols)}
    norm_inconsistent = coboundary_norm([db1, db3], n_rows, n_cols)
    print(f"\nInconsistent family coboundary norm: {norm_inconsistent}")
    print(f"Sheaf condition satisfied: {norm_inconsistent == 0}")


def demo_exponential_decay():
    """Demonstrate exponential decay of consistency probability."""
    print("\n" + "=" * 60)
    print("DEMO 3: Exponential Decay of Consistency Probability")
    print("=" * 60)

    print(f"\n{'n_dbs':>6} {'n_rows':>7} {'n_cols':>7} {'constraints':>12} {'P(consistent)':>15}")
    print("-" * 55)

    r = 0.1  # 10% disagreement rate per constraint
    for n_dbs in [2, 5, 10]:
        for n_rows in [10, 50]:
            for n_cols in [5, 10]:
                C = overlap_constraint_count(n_dbs, n_rows, n_cols)
                p = consistency_probability(r, C)
                print(f"{n_dbs:>6} {n_rows:>7} {n_cols:>7} {C:>12} {p:>15.2e}")

    print(f"\nKey insight: Even at r=0.1, probability drops to ~0 rapidly!")
    print(f"This proves that accidental consistency is exponentially unlikely.")


def demo_imputation():
    """Compare sheaf imputation with baselines on synthetic data."""
    print("\n" + "=" * 60)
    print("DEMO 4: Sheaf Imputation vs. Baselines")
    print("=" * 60)

    np.random.seed(42)

    # Generate correlated synthetic data
    n_rows, n_cols = 200, 8
    # Create data with known structure: y = Ax + noise
    latent = np.random.randn(n_rows, 3)
    A = np.random.randn(3, n_cols)
    ground_truth = latent @ A + 0.1 * np.random.randn(n_rows, n_cols)

    print(f"\nData: {n_rows} rows × {n_cols} columns (rank-3 latent structure)")

    for missing_rate in [0.1, 0.2, 0.3, 0.5]:
        # Create mask
        mask = np.random.rand(n_rows, n_cols) > missing_rate
        observed = ground_truth.copy()
        observed[~mask] = np.nan

        # Impute with different methods
        imputed_mean = mean_imputation(observed, mask)
        imputed_knn = knn_imputation(observed, mask, k=5)
        imputed_sheaf = sheaf_imputation(observed, mask, max_iter=50)

        # Compute RMSE on missing values only
        missing = ~mask
        rmse_mean = np.sqrt(np.mean((imputed_mean[missing] - ground_truth[missing]) ** 2))
        rmse_knn = np.sqrt(np.mean((imputed_knn[missing] - ground_truth[missing]) ** 2))
        rmse_sheaf = np.sqrt(np.mean((imputed_sheaf[missing] - ground_truth[missing]) ** 2))

        n_missing = np.sum(~mask)
        C = overlap_constraint_count(n_cols, n_rows, n_cols)
        p_consistency = consistency_probability(missing_rate, min(C, 1000))

        print(f"\n  Missing rate: {missing_rate:.0%} ({n_missing} cells)")
        print(f"  Overlap constraints: {C}")
        print(f"  P(consistency): {p_consistency:.2e}")
        print(f"  RMSE Mean:  {rmse_mean:.4f}")
        print(f"  RMSE KNN:   {rmse_knn:.4f}")
        print(f"  RMSE Sheaf: {rmse_sheaf:.4f}")

        if rmse_sheaf < rmse_mean:
            improvement = (rmse_mean - rmse_sheaf) / rmse_mean * 100
            print(f"  Sheaf beats mean by {improvement:.1f}%")


def demo_filtration():
    """Demonstrate sheaf filtration: progressive imputation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Sheaf Filtration (Progressive Imputation)")
    print("=" * 60)

    np.random.seed(123)
    n_rows, n_cols = 50, 5
    ground_truth = np.random.randn(n_rows, n_cols)

    # Start with 80% missing
    initial_mask = np.random.rand(n_rows, n_cols) > 0.8

    print(f"\nFiltration depth | Filled cells | RMSE")
    print("-" * 45)

    mask = initial_mask.copy()
    observed = ground_truth.copy()
    observed[~mask] = np.nan

    for depth in range(1, 6):
        # Fill in more cells at each level
        imputed = sheaf_imputation(observed, mask, max_iter=20)

        # Mark high-confidence imputations as "observed"
        for r in range(n_rows):
            for c in range(n_cols):
                if not mask[r, c]:
                    # Simple confidence: how close is imputed to column mean?
                    col_std = np.nanstd(observed[:, c])
                    if col_std > 0:
                        z = abs(imputed[r, c] - np.nanmean(observed[:, c])) / col_std
                        if z < 1.5:  # High confidence
                            observed[r, c] = imputed[r, c]
                            mask[r, c] = True

        filled = np.sum(mask)
        rmse = np.sqrt(np.mean((imputed[~initial_mask] - ground_truth[~initial_mask]) ** 2))
        print(f"  Level {depth:>2}       | {filled:>4}/{n_rows * n_cols}    | {rmse:.4f}")


if __name__ == "__main__":
    demo_consistency()
    demo_coboundary()
    demo_exponential_decay()
    demo_imputation()
    demo_filtration()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization: Exponential Decay of Consistency Probability

Shows how the probability of database consistency decays exponentially
with the number of overlap constraints, for different disagreement rates.
"""

import numpy as np
import matplotlib.pyplot as plt


def consistency_probability(r: float, C: int) -> float:
    """Compute (1-r)^C, the consistency probability."""
    return (1.0 - r) ** C


def overlap_constraint_count(n: int, n_rows: int, n_cols: int) -> int:
    """n*(n-1)/2 * n_rows * n_cols"""
    return n * (n - 1) // 2 * (n_rows * n_cols)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: P(consistent) vs constraint count for different rates
    ax = axes[0]
    constraints = np.arange(0, 201)
    for r in [0.01, 0.05, 0.1, 0.2, 0.3]:
        probs = [(1 - r) ** c for c in constraints]
        ax.plot(constraints, probs, label=f"r = {r}")
    ax.set_xlabel("Number of constraints C")
    ax.set_ylabel("P(consistent) = (1-r)^C")
    ax.set_title("Exponential Decay of Consistency")
    ax.legend()
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # Panel 2: Log-scale version
    ax = axes[1]
    constraints = np.arange(1, 501)
    for r in [0.01, 0.05, 0.1, 0.2]:
        log_probs = [c * np.log10(1 - r) for c in constraints]
        ax.plot(constraints, log_probs, label=f"r = {r}")
    ax.set_xlabel("Number of constraints C")
    ax.set_ylabel("log₁₀ P(consistent)")
    ax.set_title("Consistency Decay (Log Scale)")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Constraint count vs database dimensions
    ax = axes[2]
    n_dbs_values = [2, 3, 5, 10]
    n_cols_range = range(2, 21)
    n_rows = 50
    for n_dbs in n_dbs_values:
        counts = [overlap_constraint_count(n_dbs, n_rows, nc) for nc in n_cols_range]
        ax.plot(list(n_cols_range), counts, marker="o", markersize=3, label=f"n_dbs = {n_dbs}")
    ax.set_xlabel("Number of columns")
    ax.set_ylabel("Overlap constraint count")
    ax.set_title(f"Constraint Growth (n_rows = {n_rows})")
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("viz_consistency_decay.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved viz_consistency_decay.png")


if __name__ == "__main__":
    main()


"""
Visualization: Sheaf Imputation vs. Baselines

Compares RMSE of sheaf imputation, mean imputation, and KNN imputation
across different missing rates.
"""

import numpy as np
import matplotlib.pyplot as plt


def sheaf_imputation_simple(observed, mask, max_iter=50, tol=1e-6):
    """Simplified sheaf imputation for visualization."""
    n_rows, n_cols = observed.shape
    result = observed.copy()
    for c in range(n_cols):
        col_mean = np.nanmean(observed[:, c]) if np.any(mask[:, c]) else 0.0
        result[~mask[:, c], c] = col_mean

    for _ in range(max_iter):
        prev = result.copy()
        for c1 in range(n_cols):
            for c2 in range(c1 + 1, n_cols):
                both_obs = mask[:, c1] & mask[:, c2]
                if np.sum(both_obs) < 3:
                    continue
                x = result[both_obs, c1]
                y = result[both_obs, c2]
                sx, sy = np.std(x), np.std(y)
                if sx < 1e-10 or sy < 1e-10:
                    continue
                a = np.corrcoef(x, y)[0, 1] * sy / sx
                b = np.mean(y) - a * np.mean(x)

                miss_c2 = ~mask[:, c2] & mask[:, c1]
                result[miss_c2, c2] = 0.5 * result[miss_c2, c2] + 0.5 * (a * result[miss_c2, c1] + b)
                miss_c1 = ~mask[:, c1] & mask[:, c2]
                if abs(a) > 1e-10:
                    result[miss_c1, c1] = 0.5 * result[miss_c1, c1] + 0.5 * (result[miss_c1, c2] - b) / a

        if np.max(np.abs(result - prev)) < tol:
            break
    return result


def mean_imputation_simple(observed, mask):
    """Mean imputation baseline."""
    result = observed.copy()
    for c in range(observed.shape[1]):
        col_mean = np.nanmean(observed[:, c]) if np.any(mask[:, c]) else 0.0
        result[~mask[:, c], c] = col_mean
    return result


def main():
    np.random.seed(42)

    n_rows, n_cols = 200, 10
    latent = np.random.randn(n_rows, 3)
    A = np.random.randn(3, n_cols)
    ground_truth = latent @ A + 0.1 * np.random.randn(n_rows, n_cols)

    missing_rates = np.arange(0.05, 0.65, 0.05)
    rmse_mean_list = []
    rmse_sheaf_list = []

    for mr in missing_rates:
        mask = np.random.rand(n_rows, n_cols) > mr
        observed = ground_truth.copy()
        observed[~mask] = np.nan

        imp_mean = mean_imputation_simple(observed, mask)
        imp_sheaf = sheaf_imputation_simple(observed, mask)

        missing = ~mask
        rmse_mean_list.append(np.sqrt(np.mean((imp_mean[missing] - ground_truth[missing]) ** 2)))
        rmse_sheaf_list.append(np.sqrt(np.mean((imp_sheaf[missing] - ground_truth[missing]) ** 2)))

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Panel 1: RMSE comparison
    ax = axes[0]
    ax.plot(missing_rates * 100, rmse_mean_list, "o-", label="Mean Imputation", color="tab:blue")
    ax.plot(missing_rates * 100, rmse_sheaf_list, "s-", label="Sheaf Imputation", color="tab:red")
    ax.set_xlabel("Missing Rate (%)")
    ax.set_ylabel("RMSE")
    ax.set_title("Imputation Error: Sheaf vs. Mean")
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Relative improvement
    ax = axes[1]
    improvement = [(m - s) / m * 100 if m > 0 else 0
                   for m, s in zip(rmse_mean_list, rmse_sheaf_list)]
    ax.bar(missing_rates * 100, improvement, width=4, color="tab:green", alpha=0.7)
    ax.set_xlabel("Missing Rate (%)")
    ax.set_ylabel("Improvement over Mean (%)")
    ax.set_title("Sheaf Imputation Advantage")
    ax.axhline(y=0, color="black", linewidth=0.5)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("viz_imputation_comparison.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved viz_imputation_comparison.png")


if __name__ == "__main__":
    main()
