"""Visualization: the second-moment parabola M(b) and its optimal vertex.

Generates a figure showing M(b) = A b^2 - 2B b + C for a softmax policy, with
the optimal baseline b* = B/A marked at the vertex and the exact excess
A (b - b*)^2 shaded. Requires matplotlib.
"""
from typing import List
import math
import matplotlib.pyplot as plt


def softmax(z: List[float]) -> List[float]:
    m = max(z); e = [math.exp(zi - m) for zi in z]; t = sum(e)
    return [ei / t for ei in e]


def main() -> None:
    z = [0.5, -0.2, 1.1, 0.3]
    pi = softmax(z)
    n = len(pi)
    R = [100.0 + 5.0 * a for a in range(n)]
    s = [(1.0 if a == 0 else 0.0) - pi[0] for a in range(n)]  # psi_0

    A = sum(pi[a] * s[a] ** 2 for a in range(n))
    B = sum(pi[a] * R[a] * s[a] ** 2 for a in range(n))
    C = sum(pi[a] * R[a] ** 2 * s[a] ** 2 for a in range(n))
    b_star = B / A

    bs = [b_star - 40 + 0.8 * i for i in range(101)]
    M = [A * b * b - 2 * B * b + C for b in bs]
    M_star = C - B * B / A

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(bs, M, lw=2.4, color="#2563eb", label=r"$M(b)=A b^2-2B b+C$")
    ax.axvline(b_star, color="#dc2626", ls="--", lw=1.6,
               label=fr"$b^\star=B/A={b_star:.2f}$")
    ax.scatter([b_star], [M_star], color="#dc2626", zorder=5, s=60)
    ax.annotate(fr"$M(b^\star)=C-B^2/A={M_star:.2f}$",
                (b_star, M_star), textcoords="offset points", xytext=(12, 18))
    ax.set_xlabel("baseline  b")
    ax.set_ylabel("second moment  M(b)")
    ax.set_title("Optimal baseline sits at the vertex of the second-moment parabola")
    ax.legend()
    fig.tight_layout()
    fig.savefig("second_moment_parabola.png", dpi=150)
    print("wrote second_moment_parabola.png")


if __name__ == "__main__":
    main()
