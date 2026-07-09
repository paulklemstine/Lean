"""Bar/scatter plot showing value(embed(n)) collapsing to sign(n)."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

def value(x, y): return y * (2.0 * x - 1.0)
def embed(n): return (0.5 + 1.0 / (2.0 * n), float(abs(n)))

def main() -> None:
    ns = [n for n in range(-12, 13) if n != 0]
    vals = [value(*embed(n)) for n in ns]
    fig, ax = plt.subplots(figsize=(9, 4))
    ax.axhline(1, color="red", ls=":", lw=1)
    ax.axhline(-1, color="blue", ls=":", lw=1)
    ax.scatter(ns, vals, c=["red" if v > 0 else "blue" for v in vals], s=60, zorder=3)
    ax.set_ylim(-1.6, 1.6)
    ax.set_xlabel("integer n"); ax.set_ylabel("value(embed(n))")
    ax.set_title("The embedding collapses: value = sign(n), image = {-1, +1}")
    fig.tight_layout(); fig.savefig("collapse.png", dpi=140); print("wrote collapse.png")

if __name__ == "__main__":
    main()
