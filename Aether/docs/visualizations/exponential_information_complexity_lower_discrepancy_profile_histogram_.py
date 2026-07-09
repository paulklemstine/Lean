"""Visualization: discrepancy profile vs the exact mean (matplotlib)."""
import itertools, random
from math import comb
import matplotlib.pyplot as plt

def main() -> None:
    q, n, r = 2, 6, 2
    random.seed(7)
    G = list(itertools.product(range(q), repeat=n))
    code = random.sample(G, 10)
    cs = set(code)
    counts = []
    for z in G:
        counts.append(sum(1 for x in cs if sum(a != b for a, b in zip(x, z)) <= r))
    volume = sum(comb(n, i) * (q - 1) ** i for i in range(r + 1))
    mean = len(code) * volume / q**n
    plt.figure(figsize=(8, 5))
    plt.hist(counts, bins=range(min(counts), max(counts) + 2), align="left",
             color="#4C72B0", edgecolor="white", alpha=0.85)
    plt.axvline(mean, color="#C44E52", linewidth=2.5,
                label=f"exact mean = |C||B_r|/q^n = {mean:.3f}")
    plt.title("Hamming-ball discrepancy profile vs proved exact mean")
    plt.xlabel("local count  N_C(z) = |C n B_r(z)|")
    plt.ylabel("number of centres z")
    plt.legend()
    plt.tight_layout()
    plt.savefig("discrepancy_profile.png", dpi=150)
    print("saved discrepancy_profile.png")

if __name__ == "__main__":
    main()
