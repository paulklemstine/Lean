"""Visualize the naturality square on the 2-simplex (triangle).

Plots, for a coarse-graining f : 3 -> 2, the two paths
  raw -> pushforward -> normalize    and    raw -> normalize -> pushforward
landing at the SAME point of the 1-simplex (a segment), illustrating commutativity.
Requires matplotlib.
"""
from typing import Callable, List, Sequence
import matplotlib.pyplot as plt


def normalize(v: Sequence[float]) -> List[float]:
    total = sum(v)
    return [0.0 for _ in v] if total == 0.0 else [x / total for x in v]


def pushforward(f: Callable[[int], int], v: Sequence[float], m: int) -> List[float]:
    w = [0.0 for _ in range(m)]
    for i, vi in enumerate(v):
        w[f(i)] += vi
    return w


def main() -> None:
    f: Callable[[int], int] = lambda i: 0 if i < 2 else 1
    raws = [[7, 2, 1], [1, 1, 8], [4, 4, 2], [9, 0, 1], [3, 3, 3]]
    fig, ax = plt.subplots(figsize=(7, 4))
    for v in raws:
        left = normalize(pushforward(f, v, 2))
        right = pushforward(f, normalize(v), 2)
        ax.scatter([left[0]], [0.0], s=120, marker="o", label=f"coarsen->norm {v}")
        ax.scatter([right[0]], [0.0], s=40, marker="x")
    ax.set_title("Naturality square: both paths land at the same simplex point")
    ax.set_xlabel("probability of coarse category 0")
    ax.set_yticks([])
    ax.set_xlim(-0.05, 1.05)
    ax.legend(fontsize=7, loc="upper center", ncol=2)
    plt.tight_layout()
    plt.savefig("naturality_square.png", dpi=150)
    print("saved naturality_square.png")


if __name__ == "__main__":
    main()
