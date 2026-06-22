"""Visualize the exponential decay of consistency probability (1-r)^C."""
import matplotlib.pyplot as plt
import numpy as np


def overlap_constraint_count(n: int, k: int) -> int:
    """(unordered column-pairs) x (cells) overlap constraints for an n x k grid."""
    return (n * (n - 1) // 2) * (k * n)


def main() -> None:
    rs = np.linspace(0.0, 1.0, 200)
    fig, ax = plt.subplots(figsize=(8, 5))
    for n, k in [(3, 4), (4, 5), (5, 6)]:
        C = overlap_constraint_count(n, k)
        ax.plot(rs, (1.0 - rs) ** C, label=f"n={n}, k={k}, C={C}")
    ax.set_xlabel("per-constraint disagreement rate r")
    ax.set_ylabel("P(sheaf condition) = (1 - r)^C")
    ax.set_title("Exponential decay of database consistency probability")
    ax.set_yscale("log")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("consistency_decay.png", dpi=150)
    print("wrote consistency_decay.png")


if __name__ == "__main__":
    main()
