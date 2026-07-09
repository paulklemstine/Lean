"""Visualization: required containing stage grows with active-support size."""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    ns = np.arange(1, 31)
    # identity prefix of length n needs stage n-1 (diverges)
    naive = ns - 1
    # sheared: support of size s with values <= V needs only max(values) (bounded)
    rng = np.random.default_rng(0)
    sheared = [int(rng.integers(0, 10)) for _ in ns]  # bounded regardless of n
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ns, naive, "o-", color="crimson", label="naive (identity) — diverges")
    ax.plot(ns, sheared, "s-", color="seagreen",
            label="sheared (finite support) — bounded")
    ax.set_xlabel("sequence length n")
    ax.set_ylabel("required containing stage M")
    ax.set_title("Stage cost: naive power diverges, sheared power stays bounded")
    ax.legend(); fig.tight_layout(); fig.savefig("stage_cost.png", dpi=130)
    print("wrote stage_cost.png")


if __name__ == "__main__":
    main()
