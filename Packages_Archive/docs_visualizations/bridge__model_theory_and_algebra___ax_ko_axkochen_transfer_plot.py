"""Visualization: the cofinite filter makes the finite exceptional set invisible.

Plots, prime by prime, where Artin's C2 property holds on the function-field side
F_p((t)) (always) and on the arithmetic side Q_p (all but finitely many p), and
shades the finite exceptional set that the cofinite ultrafilter ignores.
"""
from __future__ import annotations
from typing import List
import matplotlib.pyplot as plt

def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n + 1); sieve[0:2] = [False, False]
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]

def main() -> None:
    ps = primes_up_to(80)
    exceptional = {2}  # illustrative finite exceptional set on the Q_p side
    q_side = [0 if p in exceptional else 1 for p in ps]
    f_side = [1 for _ in ps]
    fig, ax = plt.subplots(figsize=(11, 4))
    ax.step(ps, f_side, where="mid", label="F_p((t)) |= C2 (all p)", lw=2)
    ax.step(ps, [v - 0.05 for v in q_side], where="mid",
            label="Q_p |= C2 (almost all p)", lw=2)
    for p in exceptional:
        ax.axvspan(p - 0.6, p + 0.6, color="red", alpha=0.15)
    ax.set_yticks([0, 1]); ax.set_yticklabels(["fails", "holds"])
    ax.set_xlabel("prime p"); ax.set_title(
        "Ax-Kochen transfer: agreement for all but finitely many primes")
    ax.legend(loc="center right"); ax.set_ylim(-0.3, 1.3)
    plt.tight_layout(); plt.savefig("axkochen_transfer.png", dpi=150)
    print("wrote axkochen_transfer.png")

if __name__ == "__main__":
    main()
