"""Overlay histograms of a chained product of independent Beta variables and a
single Beta variable, illustrating the distributional collapse."""
import math
import random
import matplotlib.pyplot as plt


def main(trials=100000, seed=0):
    rng = random.Random(seed)
    a0, betas = 1.3, [0.7, 1.1, 0.5, 0.9, 1.4]
    alpha = [a0]
    for b in betas:
        alpha.append(alpha[-1] + b)
    an = alpha[-1]
    prod, single = [], []
    for _ in range(trials):
        x = 1.0
        for j, b in enumerate(betas):
            x *= rng.betavariate(alpha[j], b)
        prod.append(x)
        single.append(rng.betavariate(a0, an - a0))
    plt.figure(figsize=(7, 4))
    plt.hist(prod, bins=80, density=True, alpha=0.5, label="chained product")
    plt.hist(single, bins=80, density=True, alpha=0.5,
             label=f"single Beta({a0},{an - a0:.1f})")
    plt.xlabel("value"); plt.ylabel("density")
    plt.title("Chained product of Betas collapses to a single Beta")
    plt.legend(); plt.tight_layout(); plt.savefig("collapse_hist.png", dpi=150)


if __name__ == "__main__":
    main()
