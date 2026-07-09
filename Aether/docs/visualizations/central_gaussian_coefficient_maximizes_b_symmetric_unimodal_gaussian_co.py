"""Bar-chart visualization of Gaussian binomial coefficient rows.

Renders classSize(n,k,.) for several (n,k) and marks the central index, showing
the symmetric, unimodal "staircase to a plateau" shape. Requires matplotlib.
"""
from itertools import combinations
import matplotlib.pyplot as plt


def inversion_number(positions, n):
    ones = set(positions)
    return sum(1 for i in range(n) for j in range(i + 1, n)
               if i in ones and j not in ones)


def gaussian_row(n, k):
    max_inv = k * (n - k)
    row = [0] * (max_inv + 1)
    for positions in combinations(range(n), k):
        row[inversion_number(positions, n)] += 1
    return row


def main():
    cases = [(8, 4), (10, 5), (12, 4)]
    fig, axes = plt.subplots(1, len(cases), figsize=(15, 4))
    for ax, (n, k) in zip(axes, cases):
        row = gaussian_row(n, k)
        xs = list(range(len(row)))
        ax.bar(xs, row, color="#4C72B0")
        c = k * (n - k) // 2
        ax.axvline(c, color="#C44E52", linestyle="--", label=f"central {c}")
        ax.set_title(f"[{n} choose {k}]_q  (sum = C({n},{k}))")
        ax.set_xlabel("inversion number i")
        ax.set_ylabel("classSize(n,k,i)")
        ax.legend()
    fig.suptitle("Central coefficient is the maximum: symmetric, unimodal rows")
    fig.tight_layout()
    fig.savefig("gaussian_rows.png", dpi=150)
    print("Saved gaussian_rows.png")


if __name__ == "__main__":
    main()
