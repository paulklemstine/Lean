"""Visualization: the quadrant-balance identity N(c,d)=N(1-c,1-d) underlying pairwise flips."""
import matplotlib.pyplot as plt
from itertools import product

def quadrant_counts(S, i, j):
    N = {(c, d): 0 for c in (0, 1) for d in (0, 1)}
    for v in S:
        N[(v[i], v[j])] += 1
    return N

def main() -> None:
    n = 3
    S = [tuple(b) for b in product((0, 1), repeat=n)]  # full cube: balanced
    N = quadrant_counts(S, 0, 1)
    fig, ax = plt.subplots(figsize=(5, 5))
    for (c, d), cnt in N.items():
        ax.add_patch(plt.Rectangle((c, d), 1, 1, fc="#bde" if (c+d)%2==0 else "#edb",
                                   ec="k"))
        ax.text(c + 0.5, d + 0.5, f"N({c},{d})={cnt}", ha="center", va="center")
    ax.set_xlim(0, 2); ax.set_ylim(0, 2)
    ax.set_xlabel("coordinate i"); ax.set_ylabel("coordinate j")
    ax.set_title("Quadrant counts: N(0,0)=N(1,1), N(0,1)=N(1,0)")
    plt.tight_layout(); plt.savefig("quadrant_balance.png", dpi=140)
    print("saved quadrant_balance.png")

if __name__ == "__main__":
    main()
