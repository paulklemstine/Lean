"""Visualise the provability ladder box^k BOT = Iio k and the descending
iteration converging to the Sambin fixed point on the frame (Fin n, <)."""
from __future__ import annotations
from typing import Callable, FrozenSet, List
import matplotlib.pyplot as plt

Elem = FrozenSet[int]

def box(n: int, s: Elem) -> Elem:
    return frozenset(x for x in range(n) if all((y in s) for y in range(x)))

def himp(n: int, a: Elem, b: Elem) -> Elem:
    return (frozenset(range(n)) - a) | b

def grid_row(n: int, s: Elem, y: int, ax, color: str) -> None:
    for x in range(n):
        ax.add_patch(plt.Rectangle((x, y), 0.9, 0.9,
                     facecolor=color if x in s else "#eeeeee",
                     edgecolor="black", linewidth=0.6))

def main(n: int = 6) -> None:
    fig, axes = plt.subplots(1, 2, figsize=(13, 5))

    # Left: the provability ladder box^k BOT = {0,...,k-1}
    ax = axes[0]
    s: Elem = frozenset()
    for k in range(n + 1):
        grid_row(n, s, n - k, ax, "#2c7fb8")
        ax.text(-1.4, n - k + 0.4, f"box^{k} BOT", va="center", fontsize=9)
        s = box(n, s)
    ax.set_xlim(-2.5, n + 0.5); ax.set_ylim(-0.5, n + 1.5)
    ax.set_aspect("equal"); ax.axis("off")
    ax.set_title("Provability ladder:  box^k BOT = {0,...,k-1}")

    # Right: descending iteration of the square of the Sambin map (c = {2})
    ax = axes[1]
    c: Elem = frozenset({2})
    f: Callable[[Elem], Elem] = lambda p: himp(n, box(n, p), c)
    g: Callable[[Elem], Elem] = lambda p: f(f(p))
    x: Elem = frozenset(range(n))
    trace: List[Elem] = [x]
    while len(trace) < 16:
        nxt = g(x)
        trace.append(nxt)
        if nxt == x:
            break
        x = nxt
    rows = trace
    for i, s in enumerate(rows):
        grid_row(n, s, len(rows) - i, ax, "#d95f0e")
        ax.text(-2.0, len(rows) - i + 0.4, f"(f.f)^{i} TOP", va="center", fontsize=9)
    ax.set_xlim(-3.0, n + 0.5); ax.set_ylim(-0.5, len(rows) + 1.5)
    ax.set_aspect("equal"); ax.axis("off")
    ax.set_title("Descending iteration -> Sambin fixed point  (c = {2})")

    plt.tight_layout()
    plt.savefig("gl_fixed_point_visualization.png", dpi=140)
    print("saved gl_fixed_point_visualization.png")

if __name__ == "__main__":
    main()
