"""Visualization: the conformability feasibility frontier n <= (d+1)*oddCap(alpha)
as a step function in alpha, contrasted with the naive bound (d+1)*alpha.

Requires matplotlib. Saves 'conformability_frontier.png'.
"""
from typing import List
import matplotlib.pyplot as plt


def odd_cap(a: int) -> int:
    if a <= 0:
        return 0
    return a if a % 2 == 1 else a - 1


def main() -> None:
    d = 4  # so there are d + 1 = 5 colour classes
    alphas: List[int] = list(range(1, 13))
    sharp = [(d + 1) * odd_cap(a) for a in alphas]
    naive = [(d + 1) * a for a in alphas]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.step(alphas, sharp, where="mid", color="crimson", linewidth=2.5,
            label=r"sharp bound $(d{+}1)\,\mathrm{oddCap}(\alpha)$")
    ax.plot(alphas, naive, "o--", color="steelblue", linewidth=1.5,
            label=r"naive bound $(d{+}1)\,\alpha$")
    ax.fill_between(alphas, sharp, naive, step="mid", alpha=0.15, color="crimson",
                    label="excluded by parity")
    ax.set_xlabel(r"independence number $\alpha$")
    ax.set_ylabel(r"maximum odd order $n$")
    ax.set_title(f"Conformability feasibility frontier (d = {d}, {d+1} colours)")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("conformability_frontier.png", dpi=150)
    print("saved conformability_frontier.png")


if __name__ == "__main__":
    main()
