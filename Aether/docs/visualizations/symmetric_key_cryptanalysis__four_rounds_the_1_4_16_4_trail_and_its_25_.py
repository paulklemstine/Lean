"""Visualization: the 1-4-16-4 AES trail and its 25 active S-boxes.

Renders the four 4x4 states of the canonical tight trail, shading active
(nonzero) bytes and annotating each round's weight.  Requires matplotlib.
"""

from typing import List
import matplotlib.pyplot as plt

State = List[List[int]]


def make_trail() -> List[State]:
    t1 = [[1 if (i == 0 and j == 0) else 0 for j in range(4)] for i in range(4)]
    t2 = [[1 if j == 0 else 0 for j in range(4)] for i in range(4)]
    t3 = [[1 for _ in range(4)] for _ in range(4)]
    t4 = [[1 if i == 0 else 0 for _ in range(4)] for i in range(4)]
    return [t1, t2, t3, t4]


def main() -> None:
    trail = make_trail()
    labels = ["a1 (in)", "a2", "a3", "a4 (out)"]
    fig, axes = plt.subplots(1, 4, figsize=(13, 3.6))
    total = 0
    for ax, state, label in zip(axes, trail, labels):
        w = sum(x for row in state for x in row)
        total += w
        ax.imshow(state, cmap="Reds", vmin=0, vmax=1)
        ax.set_title(f"{label}\nweight = {w}")
        ax.set_xticks(range(4))
        ax.set_yticks(range(4))
        for i in range(4):
            for j in range(4):
                ax.text(j, i, "S" if state[i][j] else ".",
                        ha="center", va="center",
                        color="white" if state[i][j] else "lightgray")
    fig.suptitle(f"AES 1-4-16-4 trail: {total} active S-boxes "
                 f"(= 5^2, the tight minimum)", fontsize=13)
    fig.tight_layout()
    fig.savefig("aes_trail.png", dpi=150)
    print("Saved aes_trail.png with total active S-boxes =", total)


if __name__ == "__main__":
    main()
