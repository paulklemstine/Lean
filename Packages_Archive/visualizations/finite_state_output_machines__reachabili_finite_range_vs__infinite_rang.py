"""Visualise finite range (Theorem 13): the running count of distinct values of
the Thue-Morse DFAO output saturates at 2, while the identity's distinct-value
count grows linearly (Corollary 16). Produces finite_vs_infinite_range.png."""
from __future__ import annotations
from typing import List, Set
import matplotlib.pyplot as plt

def thue_morse(n: int) -> int:
    return bin(n).count("1") & 1

def main() -> None:
    N = 200
    tm_seen: Set[int] = set(); id_seen: Set[int] = set()
    tm_curve: List[int] = []; id_curve: List[int] = []
    for n in range(N):
        tm_seen.add(thue_morse(n)); id_seen.add(n)
        tm_curve.append(len(tm_seen)); id_curve.append(len(id_seen))
    fig, ax = plt.subplots(figsize=(9, 4))
    ax.plot(range(N), tm_curve, label="Thue-Morse DFAO (finite range = 2)",
            color="#2f855a", lw=2)
    ax.plot(range(N), id_curve, label="identity n->n (infinite range)",
            color="#c53030", lw=2, ls="--")
    ax.set_xlabel("n"); ax.set_ylabel("# distinct values in 0..n")
    ax.set_title("Automatic sequences have finite range; the identity does not")
    ax.legend(); fig.tight_layout()
    fig.savefig("finite_vs_infinite_range.png", dpi=140)
    print("wrote finite_vs_infinite_range.png")

if __name__ == "__main__":
    main()
