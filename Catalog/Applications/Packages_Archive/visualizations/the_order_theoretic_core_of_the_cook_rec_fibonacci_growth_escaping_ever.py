"""Visualization: polynomial blow-up bounds vs Fibonacci growth (log scale).

Generates a matplotlib figure showing (n+2)^k for several k against F(n), making the
crossover (where Fibonacci escapes every fixed polynomial) visually explicit.
Requires matplotlib. Run: python visualize_separation.py
"""
from __future__ import annotations
import matplotlib.pyplot as plt


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def main() -> None:
    ns = list(range(0, 60))
    fibs = [fib(n) for n in ns]
    plt.figure(figsize=(9, 6))
    plt.semilogy(ns, [max(f, 1) for f in fibs], "k-", lw=2.5, label="F(n)  (Fibonacci)")
    for k in (3, 5, 8, 12):
        plt.semilogy(ns, [(n + 2) ** k for n in ns], "--", label=f"(n+2)^{k}")
    plt.xlabel("n")
    plt.ylabel("size (log scale)")
    plt.title("Fibonacci growth escapes every fixed polynomial blow-up")
    plt.legend()
    plt.grid(True, which="both", alpha=0.3)
    plt.tight_layout()
    plt.savefig("separation.png", dpi=150)
    print("wrote separation.png")


if __name__ == "__main__":
    main()
