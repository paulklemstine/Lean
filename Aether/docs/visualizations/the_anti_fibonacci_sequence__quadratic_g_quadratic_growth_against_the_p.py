"""Visualization 1: Anti-Fibonacci growth vs the parabola n^2/2, and A(n)/n^2 -> 1/2."""
from __future__ import annotations
import matplotlib.pyplot as plt


def closed(n: int) -> int:
    return 1 + n * (n - 1) // 2


def main() -> None:
    ns = list(range(1, 61))
    a = [closed(n) for n in ns]
    para = [n * n / 2 for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.plot(ns, a, "o-", ms=3, label="A(n) = 1 + n(n-1)/2")
    ax1.plot(ns, para, "--", label="n^2 / 2")
    ax1.set_title("Anti-Fibonacci grows quadratically")
    ax1.set_xlabel("n"); ax1.set_ylabel("value"); ax1.legend()

    ratio = [closed(n) / (n * n) for n in ns]
    ax2.plot(ns, ratio, "o-", ms=3, color="crimson", label="A(n)/n^2")
    ax2.axhline(0.5, ls="--", color="black", label="limit 1/2")
    ax2.set_title("A(n)/n^2 converges to 1/2")
    ax2.set_xlabel("n"); ax2.set_ylabel("A(n)/n^2"); ax2.legend()

    fig.tight_layout()
    fig.savefig("antifib_growth.png", dpi=150)
    print("saved antifib_growth.png")


if __name__ == "__main__":
    main()
