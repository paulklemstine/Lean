"""
demo.py — Numerical demonstrations of the Vietoris-Rips edge-count profile.

This script is fully self-contained (standard library only). It reproduces, on
concrete finite metric spaces, every theorem of the accompanying paper:

  * Theorem 3.1 (Monotonicity):      r <= s  =>  E(r) <= E(s)
  * Theorem 3.3 (Vanishing at 0):    E(0) = 0  in a genuine metric space
  * Theorem 3.4 (Pairwise ceiling):  E(r) <= C(n,2)
  * Theorem 4.2 (Domination):        injective nonexpanding f  =>  E_alpha(r) <= E_beta(r)
  * Proposition 6.1 (Histogram):     the discrete derivative of E recovers the
                                     multiset of pairwise distances.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, List, Sequence, Tuple

Point = Tuple[float, ...]


# --------------------------------------------------------------------------- #
# Core construction: Rips edges and the edge-count profile                     #
# --------------------------------------------------------------------------- #

def euclidean(x: Point, y: Point) -> float:
    """Standard Euclidean distance between two equal-length tuples."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def rips_edges(points: Sequence[Point], r: float,
               dist: Callable[[Point, Point], float] = euclidean) -> List[Tuple[int, int]]:
    """Edges {i, j} (i < j) of the Rips graph at scale r: pairs within distance r."""
    n = len(points)
    return [(i, j) for i in range(n) for j in range(i + 1, n)
            if i != j and dist(points[i], points[j]) <= r]


def edge_count(points: Sequence[Point], r: float,
               dist: Callable[[Point, Point], float] = euclidean) -> int:
    """E(r): the number of Rips edges at scale r."""
    return len(rips_edges(points, r, dist))


def edge_count_profile(points: Sequence[Point], scales: Sequence[float],
                       dist: Callable[[Point, Point], float] = euclidean) -> List[int]:
    """The edge-count profile sampled at the given scales."""
    return [edge_count(points, r, dist) for r in scales]


def pairwise_distance_multiset(points: Sequence[Point],
                               dist: Callable[[Point, Point], float] = euclidean) -> List[float]:
    """The sorted multiset of all pairwise distances."""
    return sorted(dist(points[i], points[j])
                  for i in range(len(points)) for j in range(i + 1, len(points)))


# --------------------------------------------------------------------------- #
# Demonstration routines                                                       #
# --------------------------------------------------------------------------- #

def demo_monotonicity_and_bounds() -> None:
    """Theorems 3.1, 3.3, 3.4 on a small 2D point cloud."""
    print("=" * 70)
    print("DEMO 1 — Monotonicity, vanishing at 0, and the pairwise ceiling")
    print("=" * 70)
    pts: List[Point] = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (3.0, 3.0)]
    n = len(pts)
    ceiling = n * (n - 1) // 2
    scales = [0.0, 0.5, 1.0, 1.5, 2.0, 4.0, 5.0, 10.0]
    profile = edge_count_profile(pts, scales)

    print(f"points = {pts}")
    print(f"C(n,2) ceiling = {ceiling}\n")
    print(f"{'scale r':>8} | {'E(r)':>5}")
    print("-" * 18)
    for r, e in zip(scales, profile):
        print(f"{r:>8.2f} | {e:>5}")

    assert profile[0] == 0, "Theorem 3.3 failed: E(0) must be 0"
    assert all(a <= b for a, b in zip(profile, profile[1:])), "Theorem 3.1 (monotone) failed"
    assert all(e <= ceiling for e in profile), "Theorem 3.4 (ceiling) failed"
    print("\n[OK] E(0)=0, profile nondecreasing, and E(r) <= C(n,2) everywhere.\n")


def demo_domination() -> None:
    """Theorem 4.2: injective nonexpanding map => E_alpha(r) <= E_beta(r)."""
    print("=" * 70)
    print("DEMO 2 — Domination under an injective nonexpanding embedding")
    print("=" * 70)
    # alpha embeds isometrically into the larger cloud beta (inclusion map):
    # f is injective and isometric, hence in particular nonexpanding.  Adding the
    # extra points of beta can only create more edges, so E_alpha(r) <= E_beta(r).
    alpha: List[Point] = [(0.0, 0.0), (2.0, 0.0), (0.0, 2.0)]
    beta: List[Point] = [(0.0, 0.0), (2.0, 0.0), (0.0, 2.0), (2.0, 2.0), (1.0, 1.0)]

    # Verify f := inclusion alpha -> beta (index k -> same point) is nonexpanding:
    f_index = [0, 1, 2]
    nonexpanding = all(
        euclidean(beta[f_index[i]], beta[f_index[j]]) <= euclidean(alpha[i], alpha[j])
        for i, j in itertools.combinations(range(len(alpha)), 2)
    )
    print(f"alpha = {alpha}")
    print(f"beta  = {beta}")
    print(f"f injective: True;  f nonexpanding: {nonexpanding}\n")

    scales = [0.0, 1.0, 1.5, 2.0, 2.5, 3.0]
    print(f"{'scale r':>8} | {'E_alpha':>8} | {'E_beta':>7} | dominates?")
    print("-" * 44)
    for r in scales:
        ea, eb = edge_count(alpha, r), edge_count(beta, r)
        print(f"{r:>8.2f} | {ea:>8} | {eb:>7} | {ea <= eb}")
        assert ea <= eb, "Theorem 4.2 (domination) failed"
    print("\n[OK] E_alpha(r) <= E_beta(r) at every scale.\n")


def demo_histogram_recovery() -> None:
    """Proposition 6.1: discrete derivative of E recovers the distance histogram."""
    print("=" * 70)
    print("DEMO 3 — The profile's jumps recover the distance histogram")
    print("=" * 70)
    # Integer-distance space on a line: distances are exactly differences.
    pts: List[Point] = [(0.0,), (1.0,), (2.0,), (4.0,)]
    dists = pairwise_distance_multiset(pts)
    max_r = int(max(dists))
    integer_scales = list(range(0, max_r + 1))
    profile = edge_count_profile(pts, [float(r) for r in integer_scales])

    increments = [profile[0]] + [profile[k] - profile[k - 1] for k in range(1, len(profile))]
    histogram: Dict[int, int] = {}
    for d in dists:
        histogram[int(d)] = histogram.get(int(d), 0) + 1

    print(f"points              = {[p[0] for p in pts]}")
    print(f"pairwise distances  = {[d for d in dists]}")
    print(f"profile E(0..{max_r})    = {profile}")
    print(f"increments  Delta(r) = {increments}\n")
    print(f"{'r':>3} | {'Delta(r)':>8} | {'#pairs at dist r':>16}")
    print("-" * 34)
    for r in integer_scales:
        print(f"{r:>3} | {increments[r]:>8} | {histogram.get(r, 0):>16}")
        assert increments[r] == histogram.get(r, 0), "Proposition 6.1 failed"
    print("\n[OK] Delta(r) equals the number of pairs at distance exactly r.\n")


def demo_circle_saturation() -> None:
    """A 'shape' example: points on a circle saturate at the complete graph."""
    print("=" * 70)
    print("DEMO 4 — Points on a circle: profile climbs to the complete graph")
    print("=" * 70)
    n = 8
    pts: List[Point] = [(math.cos(2 * math.pi * k / n), math.sin(2 * math.pi * k / n))
                        for k in range(n)]
    diameter = 2.0  # the circle has radius 1, so diameter = 2
    scales = [0.0, 0.5, 0.77, 1.0, 1.42, 1.85, 2.0, 2.5]
    profile = edge_count_profile(pts, scales)
    ceiling = n * (n - 1) // 2
    print(f"{n} equally spaced points on the unit circle (diameter {diameter}).")
    print(f"complete-graph edge count C({n},2) = {ceiling}\n")
    print(f"{'scale r':>8} | {'E(r)':>5}")
    print("-" * 18)
    for r, e in zip(scales, profile):
        print(f"{r:>8.2f} | {e:>5}")
    assert profile[-1] == ceiling, "expected saturation at the diameter"
    print(f"\n[OK] By scale {diameter} every pair is connected: E = {ceiling}.\n")


def main() -> None:
    demo_monotonicity_and_bounds()
    demo_domination()
    demo_histogram_recovery()
    demo_circle_saturation()
    print("All demonstrations passed: the formalized theorems hold numerically.")


if __name__ == "__main__":
    main()


"""
visualize_profile.py — Plot the Rips edge-count profile as a monotone staircase.

Generates a figure with two panels:
  (left)  a point cloud with the Rips edges drawn at a chosen scale;
  (right) the edge-count profile E(r), a nondecreasing staircase, annotated with
          the complete-graph ceiling C(n,2) and the chosen scale.

Requires matplotlib.  Run:  python3 visualize_profile.py
"""

from __future__ import annotations

import math
from typing import List, Sequence, Tuple

import matplotlib.pyplot as plt

Point = Tuple[float, float]


def dist(a: Point, b: Point) -> float:
    return math.hypot(a[0] - b[0], a[1] - b[1])


def rips_edges(points: Sequence[Point], r: float) -> List[Tuple[int, int]]:
    n = len(points)
    return [(i, j) for i in range(n) for j in range(i + 1, n)
            if dist(points[i], points[j]) <= r]


def profile(points: Sequence[Point], rs: Sequence[float]) -> List[int]:
    return [len(rips_edges(points, r)) for r in rs]


def main() -> None:
    pts: List[Point] = [(math.cos(2 * math.pi * k / 10), math.sin(2 * math.pi * k / 10))
                        for k in range(10)]
    n = len(pts)
    ceiling = n * (n - 1) // 2
    r_show = 1.0
    rs = [i / 100.0 for i in range(0, 251)]
    ys = profile(pts, rs)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(11, 5))

    # Left: point cloud + edges at r_show
    for (i, j) in rips_edges(pts, r_show):
        ax1.plot([pts[i][0], pts[j][0]], [pts[i][1], pts[j][1]],
                 color="#4cc9f0", lw=1.3, alpha=0.7, zorder=1)
    xs, ysc = zip(*pts)
    ax1.scatter(xs, ysc, color="#6ea8fe", s=60, zorder=2)
    ax1.set_title(f"Rips graph at scale r = {r_show}")
    ax1.set_aspect("equal")
    ax1.set_xticks([]); ax1.set_yticks([])

    # Right: profile staircase
    ax2.plot(rs, ys, color="#4cc9f0", lw=2.2, label="E(r)")
    ax2.axhline(ceiling, color="#f4a261", ls="--", lw=1.3,
                label=f"ceiling C(n,2) = {ceiling}")
    ax2.axvline(r_show, color="#6ea8fe", ls=":", lw=1.3, label=f"r = {r_show}")
    ax2.set_xlabel("scale r")
    ax2.set_ylabel("edge count E(r)")
    ax2.set_title("Edge-count profile (monotone staircase)")
    ax2.legend(loc="lower right", fontsize=9)
    ax2.grid(alpha=0.2)

    fig.suptitle("Vietoris–Rips edge-count profile of 10 points on a circle",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("rips_profile.png", dpi=150)
    print("Saved rips_profile.png")


if __name__ == "__main__":
    main()
