"""Visualize the fast-growing hierarchy: F_0, F_1, F_2 over small inputs,
illustrating the jump from +1 to doubling to n*2^n."""
from __future__ import annotations
import matplotlib.pyplot as plt


def fast_growing(level: int, n: int) -> int:
    if level == 0:
        return n + 1
    v = n
    for _ in range(n):
        v = fast_growing(level - 1, v)
    return v


def main() -> None:
    xs = list(range(0, 9))
    fig, ax = plt.subplots(figsize=(8, 5))
    for lvl, name in [(0, "F_0(n)=n+1"), (1, "F_1(n)=2n"), (2, "F_2(n)=n*2^n")]:
        ax.plot(xs, [fast_growing(lvl, n) for n in xs], "o-", label=name)
    ax.set_yscale("log")
    ax.set_title("The fast-growing hierarchy: first three levels (log scale)")
    ax.set_xlabel("n")
    ax.set_ylabel("F_level(n)  (log)")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("fast_growing_hierarchy.png", dpi=140)
    print("wrote fast_growing_hierarchy.png")


if __name__ == "__main__":
    main()
