"""
Visualization: Sheaf Imputation vs Mean Imputation

Compares imputation quality (coboundary norm) and RMSE across
different missing rates for sheaf-theoretic and baseline methods.
"""

import numpy as np
import matplotlib.pyplot as plt


def overlap_weight(mask: np.ndarray, i: int, j: int) -> int:
    return int(np.sum(mask[i] & mask[j]))


def coboundary_operator(data: np.ndarray) -> np.ndarray:
    m, n = data.shape
    delta = np.zeros((m, m, n))
    for i in range(m):
        for j in range(m):
            delta[i, j, :] = data[j, :] - data[i, :]
    return delta


def masked_norm_sq(mask: np.ndarray, delta: np.ndarray) -> float:
    m, n = mask.shape
    total = 0.0
    for i in range(m):
        for j in range(m):
            shared = mask[i] & mask[j]
            for k in range(n):
                if shared[k]:
                    total += delta[i, j, k] ** 2
    return total


def mean_imputation(data: np.ndarray, mask: np.ndarray) -> np.ndarray:
    imputed = data.copy()
    for k in range(data.shape[1]):
        col = data[:, k]
        observed = col[mask[:, k]]
        if len(observed) > 0:
            imputed[~mask[:, k], k] = np.mean(observed)
        else:
            imputed[~mask[:, k], k] = 0.0
    return imputed


def sheaf_imputation(data: np.ndarray, mask: np.ndarray, max_iter: int = 50) -> np.ndarray:
    m, n = data.shape
    imputed = mean_imputation(data, mask)
    for _ in range(max_iter):
        old = imputed.copy()
        for i in range(m):
            for k in range(n):
                if not mask[i, k]:
                    observers = np.where(mask[:, k])[0]
                    if len(observers) > 0:
                        weights = np.array(
                            [overlap_weight(mask, i, j) for j in observers],
                            dtype=float,
                        )
                        if weights.sum() > 0:
                            weights /= weights.sum()
                            imputed[i, k] = np.dot(weights, imputed[observers, k])
        if np.max(np.abs(imputed - old)) < 1e-6:
            break
    return imputed


def main():
    m, n = 25, 6
    rates = np.linspace(0.05, 0.8, 16)
    n_trials = 20

    mean_rmses = []
    sheaf_rmses = []
    mean_quals = []
    sheaf_quals = []

    for r in rates:
        mr, sr, mq, sq = [], [], [], []
        for seed in range(n_trials):
            rng = np.random.default_rng(seed)
            data = rng.standard_normal((m, n))
            mask = rng.random((m, n)) > r
            missing = data.copy()
            missing[~mask] = np.nan

            mi = mean_imputation(missing, mask)
            si = sheaf_imputation(missing, mask)

            mr.append(np.sqrt(np.mean((mi - data) ** 2)))
            sr.append(np.sqrt(np.mean((si - data) ** 2)))

            md = coboundary_operator(mi)
            sd = coboundary_operator(si)
            mq.append(masked_norm_sq(mask, md))
            sq.append(masked_norm_sq(mask, sd))

        mean_rmses.append(np.mean(mr))
        sheaf_rmses.append(np.mean(sr))
        mean_quals.append(np.mean(mq))
        sheaf_quals.append(np.mean(sq))

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    ax = axes[0]
    ax.plot(rates, mean_rmses, "o-", color="coral", label="Mean imputation", markersize=4)
    ax.plot(rates, sheaf_rmses, "s-", color="steelblue", label="Sheaf imputation", markersize=4)
    ax.set_xlabel("Missing Rate", fontsize=12)
    ax.set_ylabel("RMSE", fontsize=12)
    ax.set_title("Reconstruction Error", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    ax = axes[1]
    ax.plot(rates, mean_quals, "o-", color="coral", label="Mean imputation", markersize=4)
    ax.plot(rates, sheaf_quals, "s-", color="steelblue", label="Sheaf imputation", markersize=4)
    ax.set_xlabel("Missing Rate", fontsize=12)
    ax.set_ylabel("Coboundary Norm² (Quality)", fontsize=12)
    ax.set_title("Imputation Quality (lower = better)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("imputation_comparison.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved imputation_comparison.png")


if __name__ == "__main__":
    main()
