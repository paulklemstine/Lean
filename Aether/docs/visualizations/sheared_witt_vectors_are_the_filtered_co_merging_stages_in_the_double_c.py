"""Visualization: descent of a sheared polynomial vector to one stage.
Plots each coordinate's minimal stage and the merged common stage M."""
from __future__ import annotations
import matplotlib.pyplot as plt

def main() -> None:
    coords = ["x_2", "x_0+5", "x_5", "0", "0"]
    stages = [3, 1, 6, 0, 0]
    M = max(stages)
    N = 3
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.bar(range(len(coords)), stages, color="#38a169")
    ax.axhline(M, color="#c53030", linestyle="--", label=f"merged stage M={M}")
    ax.axvline(N - 0.5, color="#2b6cb0", linestyle=":", label=f"support level N={N}")
    ax.set_xticks(range(len(coords)))
    ax.set_xticklabels(coords)
    ax.set_xlabel("coordinate")
    ax.set_ylabel("minimal stage index i with coord in S_i")
    ax.set_title("Merging finitely many stages into one (double colimit)")
    ax.legend()
    fig.tight_layout()
    fig.savefig("descent.png", dpi=150)
    print("wrote descent.png")

if __name__ == "__main__":
    main()
