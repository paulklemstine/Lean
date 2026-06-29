"""Visualize the Berggren tree of Pythagorean triples (matplotlib).

Plots each primitive triple as a point (leg a, leg b) colored by tree depth,
and draws parent->child edges. Saves berggren_tree.png.
"""
from typing import List, Tuple, Dict
import matplotlib.pyplot as plt

Vec3 = Tuple[int, int, int]


def child_A(v: Vec3) -> Vec3:
    a, b, c = v
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)


def child_B(v: Vec3) -> Vec3:
    a, b, c = v
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)


def child_C(v: Vec3) -> Vec3:
    a, b, c = v
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)


def build(max_hyp: int) -> List[Tuple[Vec3, Vec3, int]]:
    """Return (node, parent, depth) records."""
    recs: List[Tuple[Vec3, Vec3, int]] = []
    stack: List[Tuple[Vec3, Vec3, int]] = [((3, 4, 5), (3, 4, 5), 0)]
    while stack:
        v, p, d = stack.pop()
        if v[2] > max_hyp:
            continue
        recs.append((v, p, d))
        for fn in (child_A, child_B, child_C):
            ch = fn(v)
            if ch[2] <= max_hyp:
                stack.append((ch, v, d + 1))
    return recs


def main() -> None:
    recs = build(max_hyp=400)
    fig, ax = plt.subplots(figsize=(9, 8))
    for v, p, d in recs:
        if v != p:
            ax.plot([p[0], v[0]], [p[1], v[1]], color="0.8", lw=0.6, zorder=1)
    xs = [v[0] for v, _, _ in recs]
    ys = [v[1] for v, _, _ in recs]
    ds = [d for _, _, d in recs]
    sc = ax.scatter(xs, ys, c=ds, cmap="viridis", s=40, zorder=2)
    plt.colorbar(sc, label="tree depth")
    ax.set_xlabel("leg a")
    ax.set_ylabel("leg b")
    ax.set_title("Berggren tree of primitive Pythagorean triples (hyp <= 400)")
    fig.tight_layout()
    fig.savefig("berggren_tree.png", dpi=140)
    print("saved berggren_tree.png with", len(recs), "triples")


if __name__ == "__main__":
    main()
