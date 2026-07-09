"""Visualize the magnitude hierarchy: infinitesimals < finite < infinite surreals."""
import matplotlib.pyplot as plt
import numpy as np


def main() -> None:
    labels = ["1/w^2", "1/w", "1/2", "1", "1000", "w", "w^2", "w^w"]
    scale = [-2, -1, 0, 0, 0, 1, 2, 3]  # leading exponent (order of magnitude)
    colors = ["#4C72B0" if s <= 0 else "#C44E52" for s in scale]
    fig, ax = plt.subplots(figsize=(11, 3.5))
    ax.bar(range(len(labels)), [s if s != 0 else 0.15 for s in scale], color=colors)
    ax.set_xticks(range(len(labels))); ax.set_xticklabels(labels)
    ax.axhline(0, color="black", lw=1)
    ax.set_ylabel("leading omega-exponent")
    ax.set_title("Blue = finite (in F), Red = infinite (in complement of F)")
    plt.tight_layout(); plt.savefig("surreal_hierarchy.png", dpi=150)
    print("wrote surreal_hierarchy.png")


if __name__ == "__main__":
    main()
