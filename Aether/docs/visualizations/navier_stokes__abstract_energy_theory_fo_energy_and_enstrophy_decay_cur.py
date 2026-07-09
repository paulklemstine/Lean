"""
Visualization: energy and enstrophy decay for the abstract Navier-Stokes model.

Generates a two-panel figure:
  (left)  E(t) on a log scale vs the theoretical envelope E0 * exp(-2 nu lambda t),
          illustrating the exponential energy decay theorem.
  (right) Omega(t) the enstrophy, monotonically decreasing (2D Lyapunov mechanism).

Requires matplotlib. Saves 'navier_stokes_decay.png'.
"""

from __future__ import annotations

import math
from typing import Callable, List

import matplotlib.pyplot as plt

Vector = List[float]
Matrix = List[List[float]]


def dot(a: Vector, b: Vector) -> float:
    return sum(x * y for x, y in zip(a, b))


def matvec(M: Matrix, v: Vector) -> Vector:
    return [dot(row, v) for row in M]


def axpy(alpha: float, x: Vector, y: Vector) -> Vector:
    return [alpha * xi + yi for xi, yi in zip(x, y)]


def vector_field(nu: float, A: Matrix, u: Vector) -> Vector:
    # cross-product transport vanishes on the diagonal, so B(u,u)=0 here
    return axpy(-nu, matvec(A, u), [0.0, 0.0, 0.0])


def rk4(f: Callable[[Vector], Vector], u: Vector, dt: float) -> Vector:
    k1 = f(u)
    k2 = f(axpy(dt / 2, k1, u))
    k3 = f(axpy(dt / 2, k2, u))
    k4 = f(axpy(dt, k3, u))
    incr = [(a + 2 * b + 2 * c + d) / 6 for a, b, c, d in zip(k1, k2, k3, k4)]
    return axpy(dt, incr, u)


def main() -> None:
    nu = 0.5
    A = [[2.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 5.0]]
    lam = min(A[i][i] for i in range(3))
    u = [1.0, -0.5, 0.7]
    dt, steps = 0.01, 600

    ts, Es, Oms = [], [], []
    for n in range(steps + 1):
        ts.append(n * dt)
        Es.append(dot(u, u))
        Oms.append(dot(matvec(A, u), u))
        u = rk4(lambda w: vector_field(nu, A, w), u, dt)

    E0 = Es[0]
    envelope = [E0 * math.exp(-2 * nu * lam * t) for t in ts]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
    ax1.semilogy(ts, Es, label=r"$E(t)=\|u\|^2$", lw=2)
    ax1.semilogy(ts, envelope, "--", label=r"$E_0 e^{-2\nu\lambda t}$", lw=2)
    ax1.set_xlabel("t")
    ax1.set_ylabel("energy")
    ax1.set_title("Exponential energy decay under coercivity")
    ax1.legend()
    ax1.grid(True, which="both", alpha=0.3)

    ax2.semilogy(ts, Oms, color="crimson", lw=2, label=r"$\Omega(t)=\langle Au,u\rangle$")
    ax2.set_xlabel("t")
    ax2.set_ylabel("enstrophy")
    ax2.set_title("Enstrophy as a Lyapunov function")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    fig.suptitle("Abstract Navier-Stokes: energy & enstrophy dissipation", fontsize=14)
    fig.tight_layout()
    fig.savefig("navier_stokes_decay.png", dpi=150)
    print("saved navier_stokes_decay.png")


if __name__ == "__main__":
    main()
