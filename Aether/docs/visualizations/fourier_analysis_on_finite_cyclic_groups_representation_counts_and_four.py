"""Visualize the Fourier spectrum and representation counts of a set in Z/NZ.

Generates a two-panel figure:
  (left)  the representation function r_A(a) = #{(x,y) in A^2 : x+y = a};
  (right) the Fourier magnitudes |1A_hat[k]|, whose fourth moment gives N * E[A].
Requires matplotlib.
"""
from __future__ import annotations
import cmath, math
from typing import List, Set
import matplotlib.pyplot as plt

def spectrum_figure(N: int, A: Set[int]) -> None:
    ind: List[complex] = [1.0 if x in A else 0.0 for x in range(N)]
    r = [sum(1 for x in A for y in A if (x + y) % N == a) for a in range(N)]
    ahat = [abs(sum(cmath.exp(-2j*math.pi*(j*k)/N)*ind[j] for j in range(N))) for k in range(N)]
    energy = sum(v**4 for v in ahat) / N

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4))
    ax1.bar(range(N), r, color="#3b6ea5")
    ax1.set_title(f"Representation counts r_A(a),  E[A]=sum r^2={sum(v*v for v in r)}")
    ax1.set_xlabel("a"); ax1.set_ylabel("r_A(a)")
    ax2.bar(range(N), ahat, color="#a53b5b")
    ax2.set_title(f"|1A_hat(k)|,  (1/N) sum |.|^4 = {energy:.2f}")
    ax2.set_xlabel("k"); ax2.set_ylabel("|1A_hat(k)|")
    fig.suptitle(f"Set A = {sorted(A)} in Z/{N}Z")
    fig.tight_layout()
    plt.savefig("spectrum.png", dpi=150)
    print("wrote spectrum.png")

if __name__ == "__main__":
    spectrum_figure(13, {0, 1, 2, 3, 7})
