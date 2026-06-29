"""
demo.py -- Numerical demonstrations for
"The Path Space of Filtrations: Geodesy, Convexity, Contractibility,
 and Functorial Transport of the Interleaving Metric"

A *filtration* on a finite vertex set is a grounded, monotone weight function
on its subsets:

    weight(emptyset) <= 0,   sigma subset tau  =>  weight(sigma) <= weight(tau).

The *interleaving distance* equals (by the isometry formula) the sup over all
subsets of the absolute weight gap:

    d(F, G) = max_sigma |F(sigma) - G(sigma)|.

The *geodesic interpolation* averages weights:

    (lerp F G t)(sigma) = (1 - t) * F(sigma) + t * G(sigma).

This script verifies, on concrete finite examples, the central theorems:
  * lerp is a valid filtration and has the right endpoints
  * constant-speed geodesic identity:  d(lerp s, lerp t) = |s - t| * d(F, G)
  * additive midpoint bisection and the full betweenness law
  * Busemann convexity, and its sharp-diagonal equality at H = F
  * pullback commutes with lerp, is 1-Lipschitz, and short on paths
  * the straight-line contraction of the path space

Pure standard library; run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import chain, combinations
from typing import Callable, Dict, FrozenSet, Iterable, List, Tuple

# A filtration is represented as a dict: subset (frozenset) -> weight (float).
Simplex = FrozenSet[int]
Filtration = Dict[Simplex, float]


# --------------------------------------------------------------------------- #
# Core combinatorics                                                          #
# --------------------------------------------------------------------------- #
def powerset(vertices: Iterable[int]) -> List[Simplex]:
    """All subsets of a finite vertex set, as frozensets (including empty)."""
    items = list(vertices)
    return [
        frozenset(combo)
        for combo in chain.from_iterable(
            combinations(items, r) for r in range(len(items) + 1)
        )
    ]


def is_filtration(F: Filtration) -> bool:
    """Check grounding (weight(emptyset) <= 0) and monotonicity."""
    if F.get(frozenset(), 0.0) > 1e-12:
        return False
    keys = list(F.keys())
    for sigma in keys:
        for tau in keys:
            if sigma <= tau and F[sigma] > F[tau] + 1e-12:
                return False
    return True


# --------------------------------------------------------------------------- #
# Metric, interpolation, pullback                                             #
# --------------------------------------------------------------------------- #
def interleaving_distance(F: Filtration, G: Filtration) -> float:
    """d(F, G) = max_sigma |F(sigma) - G(sigma)|  (isometry formula)."""
    return max(abs(F[sigma] - G[sigma]) for sigma in F)


def lerp(F: Filtration, G: Filtration, t: float) -> Filtration:
    """Geodesic interpolation: (1 - t)*F + t*G, valid for 0 <= t <= 1."""
    return {sigma: (1.0 - t) * F[sigma] + t * G[sigma] for sigma in F}


def pullback(f: Callable[[int], int], F: Filtration, vertices_alpha: Iterable[int]) -> Filtration:
    """(pullback f F)(sigma) = F(image of sigma under f), a filtration on alpha."""
    result: Filtration = {}
    for sigma in powerset(vertices_alpha):
        image = frozenset(f(v) for v in sigma)
        result[sigma] = F[image]
    return result


# --------------------------------------------------------------------------- #
# Example builders                                                            #
# --------------------------------------------------------------------------- #
def random_like_filtration(vertices: Iterable[int], seed: int) -> Filtration:
    """A deterministic, grounded, monotone weight function on the subsets.

    Weight of a nonempty subset = (a hash-derived base) + |subset|, so larger
    subsets always weigh more (monotone); the empty set weighs 0 (grounded).
    """
    F: Filtration = {}
    for sigma in powerset(vertices):
        if len(sigma) == 0:
            F[sigma] = 0.0
        else:
            base = (sum((seed * 7 + 3) * (v + 1) for v in sigma) % 11) / 10.0
            F[sigma] = base + float(len(sigma))
    return F


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_geodesic_constant_speed() -> None:
    print("=" * 70)
    print("DEMO 1  Constant-speed geodesic identity")
    print("=" * 70)
    V = [0, 1, 2]
    F = random_like_filtration(V, seed=1)
    G = random_like_filtration(V, seed=2)
    assert is_filtration(F) and is_filtration(G), "endpoints must be filtrations"

    L0, L1 = lerp(F, G, 0.0), lerp(F, G, 1.0)
    assert all(abs(L0[s] - F[s]) < 1e-12 for s in F), "lerp 0 = F"
    assert all(abs(L1[s] - G[s]) < 1e-12 for s in F), "lerp 1 = G"
    print("  lerp F G 0 == F  and  lerp F G 1 == G   [OK]")

    d_FG = interleaving_distance(F, G)
    print(f"  d(F, G) = {d_FG:.6f}")
    print("   s      t     d(lerp s, lerp t)   |s-t|*d(F,G)   match")
    for (s, t) in [(0.0, 1.0), (0.2, 0.7), (0.5, 0.5), (0.1, 0.9), (0.33, 0.66)]:
        lhs = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        rhs = abs(s - t) * d_FG
        ok = abs(lhs - rhs) < 1e-9
        print(f"  {s:4.2f}  {t:4.2f}     {lhs:12.6f}   {rhs:12.6f}    {ok}")
        assert ok
    print("  All geodesic-speed checks passed.\n")


def demo_betweenness_and_midpoint() -> None:
    print("=" * 70)
    print("DEMO 2  Betweenness (segment additivity) and midpoint bisection")
    print("=" * 70)
    V = [0, 1, 2]
    F = random_like_filtration(V, seed=3)
    G = random_like_filtration(V, seed=5)
    d_FG = interleaving_distance(F, G)

    # midpoint bisection
    mid = lerp(F, G, 0.5)
    left = interleaving_distance(F, mid)
    right = interleaving_distance(mid, G)
    print(f"  d(F, mid) + d(mid, G) = {left:.6f} + {right:.6f} = {left + right:.6f}")
    print(f"  d(F, G)               = {d_FG:.6f}")
    assert abs((left + right) - d_FG) < 1e-9
    print("  midpoint bisection [OK]")

    # full betweenness for s <= u <= t
    for (s, u, t) in [(0.1, 0.4, 0.9), (0.0, 0.5, 1.0), (0.2, 0.2, 0.8)]:
        a = interleaving_distance(lerp(F, G, s), lerp(F, G, u))
        b = interleaving_distance(lerp(F, G, u), lerp(F, G, t))
        c = interleaving_distance(lerp(F, G, s), lerp(F, G, t))
        ok = abs((a + b) - c) < 1e-9
        print(f"  s,u,t=({s},{u},{t}):  {a:.4f} + {b:.4f} = {a + b:.4f}  vs  {c:.4f}  {ok}")
        assert ok
    print("  All betweenness checks passed.\n")


def demo_convexity_and_sharp_diagonal() -> None:
    print("=" * 70)
    print("DEMO 3  Busemann convexity and its sharp diagonal at H = F")
    print("=" * 70)
    V = [0, 1, 2]
    F = random_like_filtration(V, seed=4)
    G = random_like_filtration(V, seed=8)
    H = random_like_filtration(V, seed=6)

    print("  Convexity: d(H, lerp t) <= (1-t)*d(H,F) + t*d(H,G)")
    max_defect = 0.0
    for t in [0.0, 0.25, 0.5, 0.75, 1.0]:
        lhs = interleaving_distance(H, lerp(F, G, t))
        rhs = (1 - t) * interleaving_distance(H, F) + t * interleaving_distance(H, G)
        defect = rhs - lhs
        max_defect = max(max_defect, defect)
        print(f"   t={t:4.2f}:  lhs={lhs:.6f}  rhs={rhs:.6f}  defect={defect:.6f}")
        assert defect > -1e-9, "convexity must hold"
    print(f"  Largest convexity defect (>=0): {max_defect:.6f}")
    if max_defect > 1e-9:
        print("  -> defect is strictly positive: the space is flat (l-infinity), not CAT(0).")

    print("\n  Sharp diagonal: with H = F the inequality becomes equality.")
    for t in [0.0, 0.3, 0.7, 1.0]:
        lhs = interleaving_distance(F, lerp(F, G, t))
        rhs = (1 - t) * interleaving_distance(F, F) + t * interleaving_distance(F, G)
        ok = abs(lhs - rhs) < 1e-9
        print(f"   t={t:4.2f}:  d(F,lerp t)={lhs:.6f}  ==  t*d(F,G)={rhs:.6f}  {ok}")
        assert ok
    print("  Geodesy = the sharp diagonal of convexity.  [OK]\n")


def demo_functorial_transport() -> None:
    print("=" * 70)
    print("DEMO 4  Pullback commutes with lerp; is 1-Lipschitz; short on paths")
    print("=" * 70)
    # beta has 3 vertices; alpha has 4 vertices; f collapses two of them.
    Vbeta = [0, 1, 2]
    Valpha = [0, 1, 2, 3]
    f = lambda v: {0: 0, 1: 1, 2: 2, 3: 2}[v]  # collapses vertex 3 onto 2

    F = random_like_filtration(Vbeta, seed=2)
    G = random_like_filtration(Vbeta, seed=9)

    # commutation: pullback(lerp F G t) == lerp(pullback F)(pullback G) t
    for t in [0.0, 0.4, 1.0]:
        lhs = pullback(f, lerp(F, G, t), Valpha)
        rhs = lerp(pullback(f, F, Valpha), pullback(f, G, Valpha), t)
        ok = all(abs(lhs[s] - rhs[s]) < 1e-12 for s in lhs)
        print(f"   t={t:4.2f}:  pullback(lerp) == lerp(pullbacks)   {ok}")
        assert ok

    # 1-Lipschitz on points and short on paths
    d_up = interleaving_distance(F, G)
    pF, pG = pullback(f, F, Valpha), pullback(f, G, Valpha)
    d_pb = interleaving_distance(pF, pG)
    print(f"\n  d(pullback F, pullback G) = {d_pb:.6f}  <=  d(F, G) = {d_up:.6f}  "
          f"{d_pb <= d_up + 1e-9}")
    assert d_pb <= d_up + 1e-9

    for (s, t) in [(0.2, 0.9), (0.0, 1.0)]:
        transported = interleaving_distance(
            pullback(f, lerp(F, G, s), Valpha),
            pullback(f, lerp(F, G, t), Valpha),
        )
        bound = abs(s - t) * d_up
        print(f"   s,t=({s},{t}):  transported speed {transported:.6f} <= "
              f"|s-t|*d(F,G) {bound:.6f}   {transported <= bound + 1e-9}")
        assert transported <= bound + 1e-9
    print("  Functorial transport checks passed.\n")


def demo_contraction() -> None:
    print("=" * 70)
    print("DEMO 5  Straight-line contraction of the path space")
    print("=" * 70)
    V = [0, 1, 2]
    base = random_like_filtration(V, seed=1)

    # a sampled path gamma(r), r in [0,1], wandering between two filtrations
    A = random_like_filtration(V, seed=7)
    B = random_like_filtration(V, seed=10)
    gamma = lambda r: lerp(A, B, r)

    def H(s: float, r: float) -> Filtration:
        return lerp(base, gamma(r), s)

    rs = [0.0, 0.25, 0.5, 0.75, 1.0]
    # s = 0 row is constant at base
    row0_ok = all(
        all(abs(H(0.0, r)[sig] - base[sig]) < 1e-12 for sig in base) for r in rs
    )
    # s = 1 row recovers gamma
    row1_ok = all(
        all(abs(H(1.0, r)[sig] - gamma(r)[sig]) < 1e-12 for sig in base) for r in rs
    )
    print(f"  H(0, .) == constant basepoint F : {row0_ok}")
    print(f"  H(1, .) == original path gamma  : {row1_ok}")
    assert row0_ok and row1_ok

    # constant speed in s, for each fixed r
    print("  Constant speed in s along each strand:")
    for r in [0.3, 0.8]:
        d_strand = interleaving_distance(base, gamma(r))
        for (s, t) in [(0.0, 1.0), (0.2, 0.6)]:
            lhs = interleaving_distance(H(s, r), H(t, r))
            rhs = abs(s - t) * d_strand
            ok = abs(lhs - rhs) < 1e-9
            print(f"   r={r}: d(H s, H t)={lhs:.6f}  ==  |s-t|*d(F,gamma r)={rhs:.6f}  {ok}")
            assert ok
    print("  The whole path reels into F at constant speed.  [OK]\n")


def main() -> None:
    demo_geodesic_constant_speed()
    demo_betweenness_and_midpoint()
    demo_convexity_and_sharp_diagonal()
    demo_functorial_transport()
    demo_contraction()
    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


if __name__ == "__main__":
    main()
