"""Visualise the Mantel frontier: edge count vs. the n^2/4 ceiling, and the
balanced complete bipartite extremal graph that attains it."""
import matplotlib.pyplot as plt
from math import floor


def mantel_bound(n: int) -> int:
    return floor(n * n / 4)


def main() -> None:
    ns = list(range(2, 21))
    bound = [mantel_bound(n) for n in ns]
    complete = [n * (n - 1) // 2 for n in ns]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ns, complete, "o--", label="K_n  (all edges, full of triangles)")
    ax.plot(ns, bound, "s-", label="floor(n^2/4)  (Mantel ceiling, triangle-free)")
    ax.fill_between(ns, bound, complete, alpha=0.15,
                    label="forbidden: triangle forced here")
    ax.set_xlabel("number of vertices n")
    ax.set_ylabel("number of edges")
    ax.set_title("Mantel's theorem: the triangle-free edge frontier")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("mantel_frontier.png", dpi=150)
    print("wrote mantel_frontier.png")


if __name__ == "__main__":
    main()
