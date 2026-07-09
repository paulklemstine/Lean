"""Visualization: roots-of-unity character tables and the totient count.

Produces two panels:
  (left)  the phi(p) Galois representations of Gal(Q(zeta_p)/Q) plotted as points
          on the unit circle (each character traces zeta-power values);
  (right) a bar chart confirming #characters = phi(n) for n = 1..30.

Requires: matplotlib, numpy.  Run: python3 visualization.py
"""
from __future__ import annotations
import math
from itertools import product
from typing import List, Tuple
import numpy as np
import matplotlib.pyplot as plt


def euler_totient(n: int) -> int:
    return sum(1 for a in range(1, n + 1) if math.gcd(a, n) == 1)


def _order(a: int, n: int) -> int:
    o, c = 1, a % n
    while c != 1:
        c = (c * a) % n
        o += 1
    return o


def basis(n: int) -> Tuple[List[int], List[int]]:
    units = [a for a in range(1, n) if math.gcd(a, n) == 1]
    target = euler_totient(n)
    gens: List[int] = []
    ords: List[int] = []
    H = {1}
    def span(gs, os):
        e = {1}
        for ex in product(*[range(o) for o in os]):
            v = 1
            for g, x in zip(gs, ex):
                v = (v * pow(g, x, n)) % n
            e.add(v)
        return e
    while len(H) < target:
        bg, bo = None, 0
        for g in units:
            o = _order(g, n)
            v, ok = 1, True
            for _ in range(1, o):
                v = (v * g) % n
                if v in H:
                    ok = False
                    break
            if ok and o > bo:
                bo, bg = o, g
        gens.append(bg); ords.append(bo); H = span(gens, ords)
    return gens, ords


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # Panel 1: characters mod p = 7 on the unit circle
    p = 7
    gens, ords = basis(p)
    units = [a for a in range(1, p) if math.gcd(a, p) == 1]
    dlog = {}
    for ex in product(*[range(o) for o in ords]):
        v = 1
        for g, x in zip(gens, ex):
            v = (v * pow(g, x, p)) % p
        dlog[v] = ex
    theta = np.linspace(0, 2 * np.pi, 400)
    ax1.plot(np.cos(theta), np.sin(theta), color="0.85", lw=1)
    colors = plt.cm.viridis(np.linspace(0, 1, len(list(product(*[range(o) for o in ords])))))
    for idx, char in enumerate(product(*[range(o) for o in ords])):
        xs, ys = [], []
        for k in units:
            ph = sum(a * c / d for a, c, d in zip(char, dlog[k], ords))
            z = complex(math.cos(2*math.pi*ph), math.sin(2*math.pi*ph))
            xs.append(z.real); ys.append(z.imag)
        ax1.scatter(xs, ys, color=colors[idx], s=60, zorder=3,
                    label=f"rep {idx}")
    ax1.set_aspect("equal")
    ax1.set_title(f"The {p-1} Galois reps of Gal(Q(zeta_{p})/Q)\non the unit circle")
    ax1.legend(fontsize=7, loc="upper right")

    # Panel 2: totient count
    ns = list(range(1, 31))
    phis = [euler_totient(n) for n in ns]
    ax2.bar(ns, phis, color="#3b7dd8")
    ax2.set_xlabel("n")
    ax2.set_ylabel("phi(n) = #Dirichlet chars = #Galois reps")
    ax2.set_title("Arithmetic shadow: #1-dim Galois reps = phi(n)")

    plt.tight_layout()
    plt.savefig("langlands_gl1_visualization.png", dpi=150)
    print("saved langlands_gl1_visualization.png")


if __name__ == "__main__":
    main()
