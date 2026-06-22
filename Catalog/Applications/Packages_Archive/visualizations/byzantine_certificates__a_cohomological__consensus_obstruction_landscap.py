"""Visualization: the consensus obstruction landscape over Z/m -> Z/q.

For each pattern f(g) = c*g (mod q) under a trivial action, we mark whether a
coboundary witness exists. Under the trivial action a coboundary is identically
zero, so only c=0 is resolvable -- a vivid picture of a nonzero H^1.
Generates a matplotlib heatmap (requires matplotlib)."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def coboundary_exists(m: int, q: int, c: int) -> bool:
    f = lambda g: (c * g) % q          # homomorphism, trivial action
    for a in range(q):
        if all(f(g) % q == (a - a) % q for g in range(m)):  # g.a - a = 0
            return True
    return False

def main() -> None:
    m, q = 12, 12
    grid = np.zeros((q, q))
    for c in range(q):
        for s_idx in range(q):
            # s_idx encodes a nontrivial action s = s_idx (mod q); a coboundary
            # delta(a)(g) = (s^g - 1) a. Mark resolvable patterns f = delta(a).
            s = s_idx
            resolvable = False
            for a in range(q):
                f = lambda g, a=a, s=s: (pow(s, g, q) * a - a) % q
                # test against the candidate target pattern c*g
                if all(f(g) == (c * g) % q for g in range(m)):
                    resolvable = True
                    break
            grid[c, s_idx] = 1.0 if resolvable else 0.0
    plt.figure(figsize=(7, 6))
    plt.imshow(grid, origin="lower", cmap="viridis", aspect="auto")
    plt.colorbar(label="resolvable (1) / obstructed (0)")
    plt.xlabel("action parameter s (mod q)")
    plt.ylabel("pattern slope c in f(g)=c*g")
    plt.title("Consensus obstruction landscape  (Z/%d on Z/%d)" % (m, q))
    plt.tight_layout()
    plt.savefig("obstruction_landscape.png", dpi=150)
    print("Saved obstruction_landscape.png")

if __name__ == "__main__":
    main()
