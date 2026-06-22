"""
Visualization: the grid search of the constructive approximate IVT in action.

Plots f(x) = x^2 - 2 on [0, 2], the uniform grid nodes, highlights the adjacent
pair where the sampled sign changes, and marks the certified approximate root
where |f(x)| <= eps. Requires matplotlib.
"""
from __future__ import annotations

from math import ceil
from typing import Callable, List
import matplotlib.pyplot as plt


def grid(a: float, b: float, N: int, i: int) -> float:
    return a + i * (b - a) / N


def approx_root(f: Callable[[float], float], a: float, b: float,
                eps: float, L: float) -> tuple[float, int, int]:
    """Return (x, N, idx) for an L-Lipschitz f with f(a) <= 0 <= f(b)."""
    delta = eps / L
    N = max(1, ceil((b - a) / delta))
    u: List[float] = [f(grid(a, b, N, i)) for i in range(N + 1)]
    for i in range(N):
        if u[i] <= 0.0 <= u[i + 1]:
            return grid(a, b, N, i + 1), N, i + 1
    return grid(a, b, N, N), N, N


def main() -> None:
    a, b, eps, L = 0.0, 2.0, 0.05, 4.0
    f = lambda x: x * x - 2.0
    x_star, N, idx = approx_root(f, a, b, eps, L)

    xs = [a + k * (b - a) / 600 for k in range(601)]
    ys = [f(x) for x in xs]

    fig, ax = plt.subplots(figsize=(9, 5))
    ax.axhline(0.0, color="gray", lw=1)
    ax.plot(xs, ys, color="#1f77b4", lw=2, label=r"$f(x)=x^2-2$")

    # show a coarse grid (use a coarser N for visual clarity)
    Nshow = 16
    gx = [grid(a, b, Nshow, i) for i in range(Nshow + 1)]
    gy = [f(x) for x in gx]
    ax.plot(gx, gy, "o", color="#bbbbbb", ms=5, label="grid samples")

    ax.plot([x_star], [f(x_star)], "*", color="#d62728", ms=18,
            label=fr"certified root $|f(x)|\leq{eps}$")
    ax.fill_between(xs, -eps, eps, color="#2ca02c", alpha=0.15,
                    label=r"$|f|\leq\varepsilon$ band")

    ax.set_title("Constructive approximate IVT: grid search for a crossing")
    ax.set_xlabel("x")
    ax.set_ylabel("f(x)")
    ax.legend(loc="upper left")
    fig.tight_layout()
    fig.savefig("approx_ivt_grid.png", dpi=150)
    print(f"saved approx_ivt_grid.png ; x*={x_star:.6f}, N={N}, idx={idx}")


if __name__ == "__main__":
    main()
