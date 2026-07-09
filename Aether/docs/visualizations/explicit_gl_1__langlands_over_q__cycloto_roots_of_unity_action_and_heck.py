"""
Visualization of the explicit GL(1) Langlands correspondence (cyclotomic case).

Two panels:
  (left)  the Galois group Gal(Q(zeta_n)/Q) = (Z/nZ)^* acting on the n-th roots
          of unity:  sigma_a sends zeta_n -> zeta_n^a.
  (right) a Dirichlet character D mod n plotted on the unit circle, with the
          attached Galois representation value rho_D(sigma_a) = D(a) annotated
          on each automorphism (Lean `explicit_reciprocity`).

Run:  python visualize.py    (writes gl1_langlands.png)
"""

from __future__ import annotations

import cmath
import math
from typing import Dict, List

import matplotlib.pyplot as plt


def gcd(a: int, b: int) -> int:
    while b:
        a, b = b, a % b
    return abs(a)


def units_mod(n: int) -> List[int]:
    return [a for a in range(1, n) if gcd(a, n) == 1]


def primitive_root(n: int) -> int:
    units = units_mod(n)
    phi = len(units)
    for g in units:
        seen = set()
        cur = 1
        for _ in range(phi):
            cur = (cur * g) % n
            seen.add(cur)
        if len(seen) == phi:
            return g
    raise ValueError("no primitive root")


def dirichlet_table(n: int, j: int) -> Dict[int, complex]:
    g = primitive_root(n)
    phi = len(units_mod(n))
    table: Dict[int, complex] = {}
    cur = 1
    for k in range(phi):
        table[cur] = cmath.exp(2j * math.pi * (j % phi) * k / phi)
        cur = (cur * g) % n
    return table


def visualize(n: int = 7, j: int = 1, filename: str = "gl1_langlands.png") -> None:
    units = units_mod(n)
    table = dirichlet_table(n, j)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 6))

    # ---- Left: roots of unity and the Artin action ----
    theta = [2 * math.pi * k / n for k in range(n)]
    xs = [math.cos(t) for t in theta]
    ys = [math.sin(t) for t in theta]
    ax1.plot(xs + [xs[0]], ys + [ys[0]], "o-", color="#444", alpha=0.4)
    for k in range(n):
        ax1.annotate(f"$\\zeta^{{{k}}}$", (xs[k], ys[k]),
                     textcoords="offset points", xytext=(8, 6))
    # highlight the action sigma_a: zeta -> zeta^a for the generator a
    a = units[-1]
    ax1.annotate("", xy=(xs[a % n], ys[a % n]), xytext=(xs[1], ys[1]),
                 arrowprops=dict(arrowstyle="->", color="crimson", lw=2))
    ax1.set_title(f"Gal(Q($\\zeta_{{{n}}}$)/Q): $\\sigma_a(\\zeta)=\\zeta^a$\n"
                  f"(arrow: $a={a}$)")
    ax1.set_aspect("equal")
    ax1.axhline(0, color="gray", lw=0.5)
    ax1.axvline(0, color="gray", lw=0.5)

    # ---- Right: Dirichlet character values = Galois rep values ----
    circ_t = [2 * math.pi * t / 200 for t in range(201)]
    ax2.plot([math.cos(t) for t in circ_t], [math.sin(t) for t in circ_t],
             color="#bbb", lw=1)
    for a in units:
        v = table[a]
        ax2.plot([v.real], [v.imag], "o", color="#1f77b4")
        ax2.annotate(f"$\\rho_D(\\sigma_{{{a}}})=D({a})$",
                     (v.real, v.imag),
                     textcoords="offset points", xytext=(8, 4), fontsize=8)
    ax2.set_title(f"Hecke = Galois values  $\\rho_D(\\sigma_a)=D(a)$\n"
                  f"(Dirichlet char mod {n}, index j={j})")
    ax2.set_aspect("equal")
    ax2.axhline(0, color="gray", lw=0.5)
    ax2.axvline(0, color="gray", lw=0.5)

    fig.suptitle("Explicit GL(1) Langlands correspondence (cyclotomic case)")
    fig.tight_layout()
    fig.savefig(filename, dpi=150)
    print(f"wrote {filename}")


if __name__ == "__main__":
    visualize()
