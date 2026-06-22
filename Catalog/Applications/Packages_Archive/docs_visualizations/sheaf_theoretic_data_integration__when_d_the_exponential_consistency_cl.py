"""
Visualization: the exponential consistency cliff  P = (1 - r)^C.

Plots log10 P(consistent) against the number of columns n (with k rows fixed),
for several disagreement rates r, using the overlap constraint count
C = C(n,2) * k * n. Saves 'consistency_cliff.png'.
"""
from math import log10
from typing import List
import matplotlib.pyplot as plt


def overlap_constraint_count(n: int, n_rows: int, n_cols: int) -> int:
    return n * (n - 1) // 2 * (n_rows * n_cols)


def main() -> None:
    k: int = 100
    ns: List[int] = list(range(2, 21))
    plt.figure(figsize=(9, 6))
    for r in (0.05, 0.10, 0.20, 0.30):
        log_p = [overlap_constraint_count(n, k, n) * log10(1.0 - r) for n in ns]
        plt.plot(ns, log_p, marker="o", label=f"r = {r}")
    plt.xlabel("number of columns n  (k = 100 rows)")
    plt.ylabel("log10  P(database is globally consistent)")
    plt.title("The Exponential Consistency Cliff:  P = (1 - r)^C")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("consistency_cliff.png", dpi=150)
    print("wrote consistency_cliff.png")


if __name__ == "__main__":
    main()
