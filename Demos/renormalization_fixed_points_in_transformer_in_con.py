"""
Numerical demonstrations for:
  "Renormalization Fixed Points in Transformer In-Context Learning
   via p-adic Attention"

This script is fully self-contained (standard library only) and demonstrates,
numerically, every main result of the two pillars:

  Pillar I  (geometry)  : ultrametric balls are nested-or-disjoint; the
                          same-resolution clustering is an equivalence relation;
                          clusters are closed balls; shrinking the resolution
                          refines the partition (the levels of a rooted tree).

  Pillar II (dynamics)  : the affine RG step x -> g*x + b has a unique fixed
                          point b/(1-g), the exact flow law g^n (x - x*),
                          convergence and exact universality when |g| < 1;
                          the p-adic RG step x -> p*x contracts exactly as
                          p^{-n}, converges to 0, and gives exact data collapse
                          of normalized error curves onto n -> p^{-n}.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Dict, List, Sequence, Set, Tuple


# ---------------------------------------------------------------------------
# p-adic absolute value and ultrametric distance on Q_p (rational sample)
# ---------------------------------------------------------------------------

def padic_valuation(x: Fraction, p: int) -> float:
    """v_p(x): the exponent of p in x (float('inf') for x = 0)."""
    if x == 0:
        return float("inf")
    num, den = abs(x.numerator), x.denominator
    v = 0
    while num % p == 0:
        num //= p
        v += 1
    while den % p == 0:
        den //= p
        v -= 1
    return v


def padic_abs(x: Fraction, p: int) -> float:
    """|x|_p = p^{-v_p(x)}, with |0|_p = 0."""
    v = padic_valuation(x, p)
    return 0.0 if v == float("inf") else float(p) ** (-v)


def padic_dist(x: Fraction, y: Fraction, p: int) -> float:
    """Ultrametric distance d_p(x, y) = |x - y|_p."""
    return padic_abs(x - y, p)


# ---------------------------------------------------------------------------
# Pillar I -- the hierarchical tree
# ---------------------------------------------------------------------------

def closed_ball(points: Sequence[Fraction], center: Fraction,
                radius: float, p: int) -> Set[int]:
    """Indices of points within ultrametric distance `radius` of `center`."""
    return {i for i, q in enumerate(points)
            if padic_dist(center, q, p) <= radius + 1e-12}


def check_nested_or_disjoint(points: Sequence[Fraction], p: int,
                             radii: Sequence[float]) -> bool:
    """Verify Theorem 3.2: any two closed balls are nested or disjoint."""
    balls: List[Set[int]] = []
    for r in radii:
        for c in points:
            balls.append(closed_ball(points, c, r, p))
    for a, b in combinations(balls, 2):
        inter = a & b
        if inter and not (a <= b or b <= a):
            return False  # partial overlap -> would break the tree property
    return True


def same_cluster(x: Fraction, y: Fraction, eps: float, p: int) -> bool:
    """Definition 3.3: SameCluster(eps, x, y) iff d_p(x, y) <= eps."""
    return padic_dist(x, y, p) <= eps + 1e-12


def is_equivalence(points: Sequence[Fraction], eps: float, p: int) -> bool:
    """Verify Lemma 3.4: same-cluster is reflexive, symmetric, transitive."""
    n = len(points)
    for i in range(n):
        if not same_cluster(points[i], points[i], eps, p):       # reflexive
            return False
        for j in range(n):
            if same_cluster(points[i], points[j], eps, p) != \
               same_cluster(points[j], points[i], eps, p):       # symmetric
                return False
            for k in range(n):
                if (same_cluster(points[i], points[j], eps, p) and
                        same_cluster(points[j], points[k], eps, p) and
                        not same_cluster(points[i], points[k], eps, p)):
                    return False                                  # transitive
    return True


def partition(points: Sequence[Fraction], eps: float, p: int) -> List[Set[int]]:
    """Cluster classes at resolution eps (each class is a closed ball)."""
    classes: List[Set[int]] = []
    assigned: Set[int] = set()
    for i in range(len(points)):
        if i in assigned:
            continue
        cls = {j for j in range(len(points))
               if same_cluster(points[i], points[j], eps, p)}
        classes.append(cls)
        assigned |= cls
    return classes


def refines(fine: List[Set[int]], coarse: List[Set[int]]) -> bool:
    """True if every fine class is contained in some coarse class."""
    return all(any(f <= c for c in coarse) for f in fine)


# ---------------------------------------------------------------------------
# Pillar II -- the renormalization-group flow
# ---------------------------------------------------------------------------

def rg_step(g: float, b: float, x: float) -> float:
    """Affine RG step: rgStep(g, b, x) = g*x + b."""
    return g * x + b


def rg_fixed(g: float, b: float) -> float:
    """Unique fixed point b/(1-g) (requires g != 1)."""
    return b / (1.0 - g)


def rg_iterate(g: float, b: float, x0: float, n: int) -> List[float]:
    """Trajectory [x0, rgStep(x0), rgStep^2(x0), ...] of length n+1."""
    traj = [x0]
    x = x0
    for _ in range(n):
        x = rg_step(g, b, x)
        traj.append(x)
    return traj


def padic_rg_norm(x: Fraction, p: int, n: int) -> float:
    """Exact p-adic norm of p^n * x  (Theorem 4.8): p^{-n} |x|_p."""
    return padic_abs((p ** n) * x, p)


def padic_data_collapse(x: Fraction, p: int, n_max: int) -> List[float]:
    """Normalized p-adic error curve; equals p^{-n} for n = 0..n_max."""
    base = padic_abs(x, p)
    return [padic_abs((p ** n) * x, p) / base for n in range(n_max + 1)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_tree(p: int = 2) -> None:
    print("=" * 70)
    print(f"PILLAR I -- ultrametric hierarchical tree over Q_{p}")
    print("=" * 70)
    pts = [Fraction(0), Fraction(p), Fraction(p * p), Fraction(1),
           Fraction(1 + p), Fraction(p + p * p)]
    radii = [float(p) ** (-k) for k in range(-1, 4)]

    ok = check_nested_or_disjoint(pts, p, radii)
    print(f"All ball pairs nested-or-disjoint (Thm 3.2): {ok}")

    for eps in [float(p), 1.0, float(p) ** -1, float(p) ** -2]:
        eq = is_equivalence(pts, eps, p)
        part = partition(pts, eps, p)
        print(f"  eps={eps:8.4f} | equivalence={eq} | "
              f"#clusters={len(part)} | sizes={sorted(len(c) for c in part)}")

    print("Refinement under shrinking eps (Lemma 3.6 / Thm 3.7):")
    eps_seq = [float(p), 1.0, float(p) ** -1, float(p) ** -2]
    parts = [partition(pts, e, p) for e in eps_seq]
    for i in range(len(parts) - 1):
        print(f"  partition(eps={eps_seq[i+1]:.4f}) refines "
              f"partition(eps={eps_seq[i]:.4f}): "
              f"{refines(parts[i+1], parts[i])}")
    print()


def demo_affine_rg() -> None:
    print("=" * 70)
    print("PILLAR II(a) -- affine RG flow  x -> g*x + b")
    print("=" * 70)
    g, b = 0.5, 3.0
    xstar = rg_fixed(g, b)
    print(f"g={g}, b={b}, fixed point x* = b/(1-g) = {xstar}")
    print(f"check g*x* + b == x* : {abs(rg_step(g, b, xstar) - xstar) < 1e-12}")

    n = 12
    for x0 in [0.0, 10.0, -7.0]:
        traj = rg_iterate(g, b, x0, n)
        dev = traj[-1] - xstar
        exact = (g ** n) * (x0 - xstar)            # Theorem 4.4
        print(f"  x0={x0:6.1f}: x_n={traj[-1]:.6f}  dev={dev:.3e}  "
              f"g^n(x0-x*)={exact:.3e}  match={abs(dev-exact)<1e-9}")

    # Universality: two trajectories merge (Theorem 4.6).
    t1 = rg_iterate(g, b, 10.0, n)
    t2 = rg_iterate(g, b, -7.0, n)
    print(f"Universality |x_n^(1) - x_n^(2)| = {abs(t1[-1]-t2[-1]):.3e} "
          f"-> 0 (predicted g^n*|x1-x2| = {abs((g**n)*(10.0-(-7.0))):.3e})")
    print()


def demo_padic_rg(p: int = 3) -> None:
    print("=" * 70)
    print(f"PILLAR II(b) -- p-adic RG flow  x -> {p}*x  (data collapse)")
    print("=" * 70)
    n_max = 6
    for x in [Fraction(1), Fraction(5), Fraction(7, 2), Fraction(2, p)]:
        curve = padic_data_collapse(x, p, n_max)
        master = [float(p) ** (-n) for n in range(n_max + 1)]
        match = all(abs(a - b) < 1e-12 for a, b in zip(curve, master))
        print(f"  x={str(x):6s}: normalized curve == p^(-n) master curve: "
              f"{match}")
    print(f"Master collapse curve n -> {p}^(-n): "
          f"{[round(float(p)**(-n), 5) for n in range(n_max + 1)]}")
    print()


def main() -> None:
    demo_tree(p=2)
    demo_affine_rg()
    demo_padic_rg(p=3)
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
