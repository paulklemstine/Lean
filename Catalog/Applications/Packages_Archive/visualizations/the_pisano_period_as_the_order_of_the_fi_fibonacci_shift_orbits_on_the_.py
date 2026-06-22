"""Visualization: the orbit of the Fibonacci shift Q on (Z/mZ)^2.

Plots, for a chosen modulus m, the cycle of states (F_k mod m, F_{k+1} mod m)
for k = 0..pi(m)-1 as a closed path on the m x m torus of residues, making the
period pi(m) literally visible as the length of the loop that returns to (0,1).
Requires matplotlib.
"""
from __future__ import annotations
import matplotlib.pyplot as plt

def pisano_period(m: int) -> int:
    if m == 1:
        return 1
    a, b = 0, 1
    for k in range(1, 6 * m + 1):
        a, b = b % m, (a + b) % m
        if a == 0 and b == 1:
            return k
    raise RuntimeError

def orbit(m: int):
    a, b = 0, 1
    xs, ys = [a], [b]
    pi = pisano_period(m)
    for _ in range(pi):
        a, b = b % m, (a + b) % m
        xs.append(a); ys.append(b)
    return xs, ys, pi

def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(11, 11))
    for ax, m in zip(axes.ravel(), [8, 11, 12, 21]):
        xs, ys, pi = orbit(m)
        ax.plot(xs, ys, "-", lw=0.8, color="#3b6", alpha=0.8)
        ax.scatter(xs, ys, s=18, color="#163", zorder=3)
        ax.scatter([0], [1], s=90, color="crimson", zorder=4, label="seed (0,1)")
        ax.set_title(f"m = {m},  pi(m) = {pi}")
        ax.set_xlabel("F_k mod m"); ax.set_ylabel("F_{k+1} mod m")
        ax.set_aspect("equal"); ax.legend(loc="upper right", fontsize=8)
    fig.suptitle("The Fibonacci shift orbit: the Pisano period is the loop length",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("pisano_orbits.png", dpi=140)
    print("wrote pisano_orbits.png")

if __name__ == "__main__":
    main()
