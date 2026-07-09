"""Visualize p-adic Newton polygons of characteristic elements g in Z_p[[T]],
reading off the Iwasawa invariants mu (height of the bottom edge) and lambda
(rightmost x-coordinate of the lowest point) for each example.
Requires matplotlib."""
from typing import List, Tuple
import matplotlib.pyplot as plt

def p_val(x: int, p: int, cap: int = 8) -> int:
    if x == 0:
        return cap
    v = 0
    while x % p == 0:
        x //= p
        v += 1
    return v

def newton_points(coeffs: List[int], p: int) -> List[Tuple[int, int]]:
    return [(i, p_val(c, p)) for i, c in enumerate(coeffs)]

def main() -> None:
    p = 5
    examples = {
        "T^2 + 5T + 25 (mu=0, lam=2)": [25, 5, 1],
        "5(T+1) (mu=1, lam=0)":         [5, 5],
        "T^5 + 5 (mu=0, lam=5)":        [5, 0, 0, 0, 0, 1],
    }
    fig, axes = plt.subplots(1, len(examples), figsize=(13, 4))
    for ax, (label, coeffs) in zip(axes, examples.items()):
        pts = newton_points(coeffs, p)
        xs = [a for a, _ in pts]
        ys = [b for _, b in pts]
        ax.scatter(xs, ys, color="crimson", zorder=3)
        mu = min(ys)
        lam = next(i for i, b in enumerate(ys) if b == mu)
        ax.axhline(mu, color="steelblue", ls="--", label=f"mu={mu}")
        ax.axvline(lam, color="seagreen", ls=":", label=f"lambda={lam}")
        ax.set_title(label, fontsize=9)
        ax.set_xlabel("i (degree in T)")
        ax.set_ylabel("v_p(a_i)")
        ax.legend(fontsize=8)
        ax.grid(alpha=0.3)
    fig.suptitle("Newton polygons & Iwasawa invariants of characteristic elements")
    fig.tight_layout()
    fig.savefig("newton_polygons.png", dpi=130)
    print("Saved newton_polygons.png")

if __name__ == "__main__":
    main()
