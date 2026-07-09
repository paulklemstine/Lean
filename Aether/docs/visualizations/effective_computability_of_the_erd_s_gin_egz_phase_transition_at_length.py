"""Visualization: phase transition of the EGZ property at length 2n-1.

For each n, exhaustively measure the fraction of random length-m sequences over
Z/nZ that admit a size-n zero-sum subset, for m around the threshold 2n-1, and
plot the sharp jump to 1.0 exactly at m = 2n - 1.
"""
import random
from itertools import combinations
import matplotlib.pyplot as plt


def has_zero_sum_subset(seq, n):
    return any(sum(seq[i] for i in c) % n == 0
               for c in combinations(range(len(seq)), n))


def fraction_with_subset(n, m, trials=400):
    hits = 0
    for _ in range(trials):
        seq = [random.randrange(n) for _ in range(m)]
        if has_zero_sum_subset(seq, n):
            hits += 1
    return hits / trials


def main():
    random.seed(0)
    plt.figure(figsize=(8, 5))
    for n in [3, 4, 5]:
        ms = list(range(n, 2 * n + 2))
        fr = [fraction_with_subset(n, m) for m in ms]
        plt.plot(ms, fr, marker="o", label=f"n = {n}")
        plt.axvline(2 * n - 1, color="gray", linestyle="--", alpha=0.4)
    plt.xlabel("sequence length m")
    plt.ylabel("fraction with a size-n zero-sum subset")
    plt.title("EGZ phase transition: guarantee becomes certain at m = 2n - 1")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("egz_phase_transition.png", dpi=150)
    print("saved egz_phase_transition.png")


if __name__ == "__main__":
    main()
