"""
Visualization: Cohomological Defect vs Missing Rate

Generates a plot showing how the cohomological defect scales with
the missing data rate, validating the conjecture that
E[Defect] ≈ m² · n · r · (1-r).
"""

import numpy as np
import matplotlib.pyplot as plt


def cohomological_defect(mask: np.ndarray) -> int:
    m, n = mask.shape
    defect = 0
    for i in range(m):
        for j in range(m):
            defect += int(np.sum(mask[i] & ~mask[j]))
    return defect


def main():
    m, n = 30, 8
    rates = np.linspace(0.01, 0.99, 30)
    n_trials = 50

    avg_defects = []
    std_defects = []
    predicted = []

    for r in rates:
        defects = []
        for seed in range(n_trials):
            rng = np.random.default_rng(seed)
            mask = rng.random((m, n)) > r
            d = cohomological_defect(mask)
            defects.append(d)
        avg_defects.append(np.mean(defects))
        std_defects.append(np.std(defects))
        predicted.append(m * m * n * r * (1 - r))

    avg_defects = np.array(avg_defects)
    std_defects = np.array(std_defects)
    predicted = np.array(predicted)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Defect vs rate
    ax = axes[0]
    ax.fill_between(
        rates,
        avg_defects - 2 * std_defects,
        avg_defects + 2 * std_defects,
        alpha=0.2,
        color="steelblue",
        label="±2σ",
    )
    ax.plot(rates, avg_defects, "o-", color="steelblue", markersize=3, label="Empirical mean")
    ax.plot(rates, predicted, "--", color="crimson", linewidth=2, label=f"m²nr(1-r) = {m}²·{n}·r(1-r)")
    ax.set_xlabel("Missing Rate r", fontsize=12)
    ax.set_ylabel("Cohomological Defect", fontsize=12)
    ax.set_title(f"Defect Scaling (m={m}, n={n}, {n_trials} trials)", fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Plot 2: Ratio
    ax = axes[1]
    ratio = avg_defects / np.maximum(predicted, 1)
    ax.plot(rates, ratio, "s-", color="darkgreen", markersize=4)
    ax.axhline(y=1.0, color="crimson", linestyle="--", linewidth=1.5, label="Ratio = 1")
    ax.set_xlabel("Missing Rate r", fontsize=12)
    ax.set_ylabel("Empirical / Predicted", fontsize=12)
    ax.set_title("Validation Ratio", fontsize=13)
    ax.set_ylim(0.8, 1.2)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("defect_scaling.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved defect_scaling.png")


if __name__ == "__main__":
    main()
