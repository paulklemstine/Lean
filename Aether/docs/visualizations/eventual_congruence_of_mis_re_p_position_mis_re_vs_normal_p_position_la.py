"""Visualization: P-position ladders for misere vs normal play.

Renders, for several granularities m, a grid of positions 0..R colored by
outcome (P vs N) under both conventions, making the 'shift by one' visible.
Requires matplotlib."""
import matplotlib.pyplot as plt
import numpy as np


def outcomes(m: int, r_max: int, misere: bool):
    wins = [False] * (r_max + 1)
    wins[0] = misere
    for r in range(1, r_max + 1):
        wins[r] = any((not wins[r - s]) for s in range(1, min(m, r) + 1))
    return np.array([0 if w else 1 for w in wins])  # 1 == P-position


def main():
    R = 30
    ms = [1, 2, 3, 4]
    fig, axes = plt.subplots(len(ms), 2, figsize=(12, 6))
    for i, m in enumerate(ms):
        for j, mis in enumerate([True, False]):
            row = outcomes(m, R, mis).reshape(1, -1)
            axes[i, j].imshow(row, aspect="auto", cmap="RdYlGn_r")
            axes[i, j].set_yticks([])
            axes[i, j].set_title(
                f"m={m} {'misere (P: r=1 mod '+str(m+1)+')' if mis else 'normal (P: r=0 mod '+str(m+1)+')'}"
            )
            axes[i, j].set_xlabel("position r")
    plt.tight_layout()
    plt.savefig("escalation_ppositions.png", dpi=120)
    print("saved escalation_ppositions.png")


if __name__ == "__main__":
    main()
