"""
Visualization of the 2D/3D Navier-Stokes regularity divide.

Generates a figure with two panels:

  (left)  2D model: enstrophy Omega(t) = <A u, u> decays monotonically -- a
          Lyapunov function -- because the vortex-stretching term cancels.
  (right) 3D model: with the SAME energy-preserving nonlinearity but no
          stretching cancellation, the enstrophy transiently RISES (vortex
          stretching pumps gradients) before viscosity eventually wins.

In both panels the energy E(t) = <u, u> is overlaid and is monotone
nonincreasing -- Leray's unconditional bound, valid in every dimension.

Requires numpy and matplotlib. Saves 'regularity_divide.png'.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

import numpy as np
import matplotlib.pyplot as plt

Vector = np.ndarray


def inner(x: Vector, y: Vector) -> float:
    return float(np.dot(x, y))


def make_skew_transport(S: np.ndarray) -> Callable[[Vector, Vector], Vector]:
    """Energy-preserving nonlinearity: <B(v,v), v> = 0 (stretching not killed)."""
    def B(v: Vector, w: Vector) -> Vector:
        raw = S @ (v * w)
        vv = inner(v, v)
        if vv == 0.0:
            return raw
        return raw - (inner(raw, v) / vv) * v
    return B


def make_2d_transport(A: np.ndarray, S: np.ndarray
                      ) -> Callable[[Vector, Vector], Vector]:
    """Nonlinearity with BOTH cancellations (2D): <B,v>=0 and <B,Av>=0."""
    def B(v: Vector, w: Vector) -> Vector:
        out = (S @ (v * w)).copy()
        ortho: List[Vector] = []
        for b in (v, A @ v):
            b = b.copy()
            for e in ortho:
                b = b - inner(b, e) * e
            nb = np.sqrt(inner(b, b))
            if nb > 1e-14:
                ortho.append(b / nb)
        for e in ortho:
            out = out - inner(out, e) * e
        return out
    return B


def integrate(nu: float, A: np.ndarray,
              B: Callable[[Vector, Vector], Vector], u0: Vector,
              t_final: float, n_steps: int) -> Tuple[np.ndarray, List[Vector]]:
    dt = t_final / n_steps
    times = np.linspace(0.0, t_final, n_steps + 1)
    states = [u0.copy()]
    u = u0.copy()
    f = lambda x: -nu * (A @ x) - B(x, x)
    for _ in range(n_steps):
        k1 = f(u); k2 = f(u + 0.5 * dt * k1)
        k3 = f(u + 0.5 * dt * k2); k4 = f(u + dt * k3)
        u = u + (dt / 6.0) * (k1 + 2 * k2 + 2 * k3 + k4)
        states.append(u.copy())
    return times, states


def main() -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # 2D panel ---------------------------------------------------------------
    rng = np.random.default_rng(1)
    n = 5
    nu = 0.25
    A = np.diag(np.array([1.0, 1.5, 2.0, 2.5, 3.0]))
    B2 = make_2d_transport(A, rng.standard_normal((n, n)))
    u0 = rng.standard_normal(n)
    t, states = integrate(nu, A, B2, u0, 5.0, 5000)
    E = [inner(u, u) for u in states]
    Om = [inner(A @ u, u) for u in states]
    ax = axes[0]
    ax.plot(t, Om, color="#1f77b4", lw=2.2, label=r"enstrophy $\Omega(t)=\langle Au,u\rangle$")
    ax.plot(t, E, color="#2ca02c", lw=1.8, ls="--", label=r"energy $E(t)=\langle u,u\rangle$")
    ax.set_title("2D model: enstrophy is a Lyapunov function\n"
                 r"$\langle B(v,v),Av\rangle=0\Rightarrow\Omega'\leq 0$")
    ax.set_xlabel("time $t$"); ax.set_ylabel("observable")
    ax.legend(); ax.grid(alpha=0.3)

    # 3D panel ---------------------------------------------------------------
    rng = np.random.default_rng(7)
    n = 6
    nu = 0.02
    A = np.diag(np.array([1.0, 2.0, 4.0, 8.0, 16.0, 32.0]))
    B3 = make_skew_transport(6.0 * rng.standard_normal((n, n)))
    u0 = rng.standard_normal(n)
    t, states = integrate(nu, A, B3, u0, 0.5, 5000)
    E = [inner(u, u) for u in states]
    Om = [inner(A @ u, u) for u in states]
    ax = axes[1]
    ax.plot(t, Om, color="#d62728", lw=2.2, label=r"enstrophy $\Omega(t)$ (rises!)")
    ax.plot(t, E, color="#2ca02c", lw=1.8, ls="--", label=r"energy $E(t)$ (still decays)")
    ax.set_title("3D model: vortex stretching pumps enstrophy\n"
                 r"$\langle B(u,u),Au\rangle\neq 0$")
    ax.set_xlabel("time $t$"); ax.set_ylabel("observable")
    ax.legend(); ax.grid(alpha=0.3)

    fig.suptitle("The Navier-Stokes 2D/3D regularity divide, localized to one term",
                 fontsize=13, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("regularity_divide.png", dpi=150)
    print("Saved regularity_divide.png")


if __name__ == "__main__":
    main()
