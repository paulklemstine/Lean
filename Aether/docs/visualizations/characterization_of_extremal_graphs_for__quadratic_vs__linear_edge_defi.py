"""Visualization 2: the deficit between conjectured T(n) and true |E(H(k))|."""
from __future__ import annotations
import matplotlib.pyplot as plt

def plot(kmax: int = 20) -> None:
    ks = list(range(1, kmax + 1))
    edges = [6 * k * k for k in ks]
    target = [2 * (2 * k - 1) ** 2 for k in ks]
    complete = [(4 * k) * (4 * k - 1) // 2 for k in ks]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ks, complete, "k--", label=r"$\binom{n}{2}$ (complete)")
    ax.plot(ks, target, "o-", color="seagreen", label=r"$T(n)=2(2k-1)^2$ (conjectured)")
    ax.plot(ks, edges, "s-", color="crimson", label=r"$|E(H(k))|=6k^2$ (actual)")
    ax.set_xlabel("k  (n = 4k)")
    ax.set_ylabel("number of edges")
    ax.set_title("H(k) misses $\\Theta(n^2)$ edges; conjectured extremum misses $\\Theta(n)$")
    ax.legend()
    plt.tight_layout()
    plt.savefig("deficit.png", dpi=150)
    print("saved deficit.png")

if __name__ == "__main__":
    plot()
