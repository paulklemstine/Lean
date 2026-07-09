"""Bar chart: proven base g(n,k) vs conjectured Hilton-Milner base h(n,k)."""
from math import comb
from typing import List, Tuple
import matplotlib.pyplot as plt


def g(n: int, k: int) -> int:
    return comb(n, k) - comb(n - k, k)


def h(n: int, k: int) -> int:
    return comb(n - 1, k - 1) - comb(n - k - 1, k - 1) + 1


def main() -> None:
    triples: List[Tuple[int, int]] = [(6, 3), (7, 3), (8, 3), (8, 4), (10, 4), (10, 5)]
    labels = [f"({n},{k})" for n, k in triples]
    gs = [g(n, k) for n, k in triples]
    hs = [h(n, k) for n, k in triples]
    x = range(len(triples))
    plt.figure(figsize=(9, 5))
    plt.bar([i - 0.2 for i in x], gs, width=0.4, label="g(n,k) (proven base)")
    plt.bar([i + 0.2 for i in x], hs, width=0.4, label="h(n,k) (conjectured sharp)")
    plt.xticks(list(x), labels)
    plt.xlabel("(n, k)")
    plt.ylabel("per-family bound")
    plt.title("Proven g(n,k) vs conjectured Hilton-Milner h(n,k)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("g_vs_h.png", dpi=150)
    print("saved g_vs_h.png")


if __name__ == "__main__":
    main()
