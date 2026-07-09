"""Visualization: viscous energy decay vs. tropical energy antitonicity.

Generates a two-panel figure showing that BOTH a continuous viscous solution and
a discrete tropical iteration carry a Lyapunov observable that never increases.
Requires matplotlib. Saves 'anti_blowup.png'.
"""
import math
from typing import List, Sequence, Tuple
import matplotlib.pyplot as plt

Vec = List[float]
Matrix = List[List[float]]


def inner(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(u, v))


def rhs(u: Sequence[float], nu: float) -> Vec:
    au = [nu * ((i + 1) ** 2) * ui for i, ui in enumerate(u)]
    m = (u[0], 2 * u[1], 3 * u[2])
    bu = [u[1] * m[2] - u[2] * m[1], u[2] * m[0] - u[0] * m[2], u[0] * m[1] - u[1] * m[0]]
    return [-a - b for a, b in zip(au, bu)]


def viscous_trace(u0: Vec, nu: float, dt: float, steps: int) -> Tuple[List[float], List[float]]:
    def add(a, b, s): return [x + s * y for x, y in zip(a, b)]
    u, ts, es = list(u0), [0.0], [inner(u0, u0)]
    for n in range(1, steps + 1):
        k1 = rhs(u, nu); k2 = rhs(add(u, k1, dt / 2), nu)
        k3 = rhs(add(u, k2, dt / 2), nu); k4 = rhs(add(u, k3, dt), nu)
        u = [ui + (dt / 6) * (a + 2 * b + 2 * c + d) for ui, a, b, c, d in zip(u, k1, k2, k3, k4)]
        ts.append(n * dt); es.append(inner(u, u))
    return ts, es


def trop_trace(K: Matrix, u0: Vec, steps: int) -> Tuple[List[int], List[float]]:
    def step(u): return [max(u[j] - K[i][j] for j in range(len(u))) for i in range(len(u))]
    u, ns, es = list(u0), [0], [max(u0)]
    for n in range(1, steps + 1):
        u = step(u); ns.append(n); es.append(max(u))
    return ns, es


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 4.2))
    ts, es = viscous_trace([3.0, -2.0, 1.5], nu=0.1, dt=0.01, steps=400)
    ax1.plot(ts, es, color="#c0392b", lw=2)
    ax1.set_title("Viscous energy ||u(t)||^2 (nonincreasing)")
    ax1.set_xlabel("time t"); ax1.set_ylabel("energy"); ax1.grid(alpha=0.3)
    K = [[0, .5, 1, 1.5], [.5, 0, .5, 1], [1, .5, 0, .5], [1.5, 1, .5, 0]]
    ns, te = trop_trace(K, [4.0, 1.0, -2.0, 0.5], steps=6)
    ax2.step(ns, te, where="post", color="#2980b9", lw=2)
    ax2.set_title("Tropical energy max_j u_j (antitone)")
    ax2.set_xlabel("iteration n"); ax2.set_ylabel("tropEnergy"); ax2.grid(alpha=0.3)
    fig.suptitle("Anti-blowup = a Lyapunov observable that never increases")
    fig.tight_layout()
    fig.savefig("anti_blowup.png", dpi=140)
    print("wrote anti_blowup.png")


if __name__ == "__main__":
    main()
