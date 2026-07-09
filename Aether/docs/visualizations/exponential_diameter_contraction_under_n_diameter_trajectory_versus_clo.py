"""Visualization: diameter trajectories vs. the closed-form bound and attractor.

Generates a figure showing (i) the exact noisy trajectory d_{k+1}=a d_k+b,
(ii) the closed-form upper bound a^k d0 + b(1-a^k)/(1-a), and (iii) the
attractor radius L = b/(1-a), illustrating geometric decay of the transient.
"""
from typing import List
import matplotlib.pyplot as plt


def exact_trajectory(a: float, b: float, d0: float, n: int) -> List[float]:
    d, out = d0, [d0]
    for _ in range(n):
        d = a * d + b
        out.append(d)
    return out


def closed_form_bound(a: float, b: float, d0: float, k: int) -> float:
    return a ** k * d0 + b * (1.0 - a ** k) / (1.0 - a)


def main() -> None:
    a, b, d0, n = 0.5, 1.0, 100.0, 18
    L = b / (1.0 - a)
    ks = list(range(n + 1))
    traj = exact_trajectory(a, b, d0, n)
    bound = [closed_form_bound(a, b, d0, k) for k in ks]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(ks, traj, "o-", label="exact trajectory $d_{k+1}=a d_k+b$")
    ax.semilogy(ks, bound, "s--", label="closed-form bound")
    ax.axhline(L, color="red", ls=":", label=f"attractor $L=b/(1-a)={L:.2f}$")
    ax.set_xlabel("refinement round $k$")
    ax.set_ylabel("worst simplex diameter (log scale)")
    ax.set_title("Inhomogeneous Delaunay contraction (a=0.5, b=1, $d_0$=100)")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("contraction_trajectory.png", dpi=150)
    print("saved contraction_trajectory.png")


if __name__ == "__main__":
    main()
