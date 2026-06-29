"""
Categorical Tropical Rips Interleaving — Numerical Demonstrations
================================================================

Self-contained Python illustrations of the formalized results:

  * persistence modules as monotone step functions R -> (ordered set),
  * epsilon-interleavings and the interleaving (pseudo)distance in [0, +inf],
  * the tropical (min-plus) reformulation: the triangle inequality is exactly
    submultiplicativity of trop o interleavingDist,
  * Vietoris-Rips edge-set modules and the stability theorem,
  * the 1-Lipschitz rank (edge-count / Betti-0) functor,
  * the constant-shift functor: isometry, <= c displacement, tropical unit,
    and the finite-distance equivalence relation.

Everything is inlined; only the standard library is used.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import inf
from typing import Callable, FrozenSet, List, Sequence, Tuple

Edge = Tuple[int, int]


# ---------------------------------------------------------------------------
# 1. Persistence modules as monotone step objects on a finite breakpoint grid
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class StepModule:
    """A persistence module valued in subsets of a finite ground set, sampled
    as a right-continuous step function.

    `breaks` are increasing real scales; `objs[i]` is the object (a frozenset)
    in force on the half-open interval [breaks[i], breaks[i+1]). The object is
    empty below breaks[0].  Monotonicity (objs nested increasing) is required.
    """

    breaks: Tuple[float, ...]
    objs: Tuple[FrozenSet[Edge], ...]

    def obj(self, t: float) -> FrozenSet[Edge]:
        """Return the scale-t object M.obj(t)."""
        current: FrozenSet[Edge] = frozenset()
        for b, o in zip(self.breaks, self.objs):
            if t >= b:
                current = o
            else:
                break
        return current


def rips_module(points: Sequence[Tuple[float, ...]],
                dist: Callable[[Tuple[float, ...], Tuple[float, ...]], float]
                ) -> StepModule:
    """Vietoris-Rips edge-set module of a finite point cloud.

    At scale t the object is the set of edges {(i,j) : dist(p_i, p_j) <= t}.
    """
    n = len(points)
    edge_scale: List[Tuple[float, Edge]] = []
    for i, j in combinations(range(n), 2):
        edge_scale.append((dist(points[i], points[j]), (i, j)))
    edge_scale.sort()
    breaks: List[float] = []
    objs: List[FrozenSet[Edge]] = []
    acc: set[Edge] = set()
    for scale, e in edge_scale:
        acc.add(e)
        if breaks and breaks[-1] == scale:
            objs[-1] = frozenset(acc)
        else:
            breaks.append(scale)
            objs.append(frozenset(acc))
    return StepModule(tuple(breaks), tuple(objs))


# ---------------------------------------------------------------------------
# 2. Interleaving check and interleaving distance
# ---------------------------------------------------------------------------

def is_interleaved(M: StepModule, N: StepModule, eps: float,
                   probe: Sequence[float]) -> bool:
    """Check (on a probe grid) the two shifted dominations defining an
    eps-interleaving:  M.obj(t) <= N.obj(t+eps) and N.obj(t) <= M.obj(t+eps).
    """
    for t in probe:
        if not M.obj(t) <= N.obj(t + eps):
            return False
        if not N.obj(t) <= M.obj(t + eps):
            return False
    return True


def interleaving_distance(M: StepModule, N: StepModule,
                          probe: Sequence[float],
                          eps_grid: Sequence[float]) -> float:
    """Approximate interleavingDist(M, N) = inf { eps >= 0 : eps-interleaved }.

    Returns +inf if no eps on the grid works (the empty-infimum convention).
    """
    for eps in sorted(eps_grid):
        if eps >= 0 and is_interleaved(M, N, eps, probe):
            return eps
    return inf


# ---------------------------------------------------------------------------
# 3. Tropical (min-plus) semiring on [0, +inf]
# ---------------------------------------------------------------------------

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication a (x) b = a + b (unit is 0)."""
    return a + b


def trop_add(a: float, b: float) -> float:
    """Tropical addition a (+) b = min(a, b) (unit is +inf)."""
    return min(a, b)


TROP_UNIT: float = 0.0  # trop(0) is the tropical multiplicative unit "1".


# ---------------------------------------------------------------------------
# 4. The rank (edge-count / Betti-0) functor: PersMod(Set) -> PersMod(N)
# ---------------------------------------------------------------------------

def rank_module(M: StepModule) -> Tuple[Tuple[float, ...], Tuple[int, ...]]:
    """Apply ncard pointwise: returns (breaks, counts) of the rank curve."""
    return (M.breaks, tuple(len(o) for o in M.objs))


def rank_obj(M: StepModule, t: float) -> int:
    """The rank curve value (number of edges) at scale t."""
    return len(M.obj(t))


def is_rank_interleaved(M: StepModule, N: StepModule, eps: float,
                        probe: Sequence[float]) -> bool:
    """Check eps-interleaving of the rank curves as N-valued modules:
    rank(M, t) <= rank(N, t+eps) and symmetrically.
    """
    for t in probe:
        if not rank_obj(M, t) <= rank_obj(N, t + eps):
            return False
        if not rank_obj(N, t) <= rank_obj(M, t + eps):
            return False
    return True


# ---------------------------------------------------------------------------
# 5. The shift functor
# ---------------------------------------------------------------------------

def shift_module(c: float, M: StepModule) -> StepModule:
    """(shift c M).obj(t) = M.obj(t + c): slide the breakpoints down by c."""
    return StepModule(tuple(b - c for b in M.breaks), M.objs)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def euclid(p: Tuple[float, ...], q: Tuple[float, ...]) -> float:
    return sum((a - b) ** 2 for a, b in zip(p, q)) ** 0.5


def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def demo_stability() -> None:
    banner("Vietoris-Rips stability: |d - d'| <= eps  =>  eps-interleaved")
    pts = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]
    pts_pert = [(0.0, 0.0), (1.1, 0.0), (0.0, 0.9), (1.05, 1.0)]
    M = rips_module(pts, euclid)
    N = rips_module(pts_pert, euclid)

    # Maximum pointwise perturbation of the dissimilarity:
    eps = max(abs(euclid(pts[i], pts[j]) - euclid(pts_pert[i], pts_pert[j]))
              for i, j in combinations(range(4), 2))
    probe = [k * 0.02 for k in range(0, 120)]
    print(f"sup |d(x,y) - d'(x,y)| = {eps:.4f}")
    ok = is_interleaved(M, N, eps + 1e-9, probe)
    print(f"eps-interleaved at eps = sup perturbation? {ok}")
    d = interleaving_distance(M, N, probe, [k * 0.01 for k in range(0, 200)])
    print(f"approx interleaving distance = {d:.3f}  (<= eps = {eps:.3f}: "
          f"{d <= eps + 1e-6})")


def demo_triangle_tropical() -> None:
    banner("Triangle inequality == tropical submultiplicativity")
    a = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
    b = [(0.0, 0.0), (1.3, 0.0), (0.0, 1.2)]
    c = [(0.0, 0.0), (1.6, 0.0), (0.0, 1.5)]
    A, B, C = (rips_module(x, euclid) for x in (a, b, c))
    probe = [k * 0.005 for k in range(0, 640)]
    grid = [k * 0.001 for k in range(0, 3000)]
    tol = 2e-3  # accounts for finite grid/probe discretization
    dAB = interleaving_distance(A, B, probe, grid)
    dBC = interleaving_distance(B, C, probe, grid)
    dAC = interleaving_distance(A, C, probe, grid)
    print(f"d(A,B) = {dAB:.3f}, d(B,C) = {dBC:.3f}, d(A,C) = {dAC:.3f}")
    print(f"ordinary triangle:  d(A,C) <= d(A,B) + d(B,C)?  "
          f"{dAC <= dAB + dBC + tol}")
    print(f"tropical form:      trop d(A,C) <= trop d(A,B) (x) trop d(B,C)")
    print(f"                    {dAC:.3f} <= {trop_mul(dAB, dBC):.3f}  "
          f"-> {dAC <= trop_mul(dAB, dBC) + tol}")


def demo_rank_lipschitz() -> None:
    banner("Rank functor is 1-Lipschitz (and preserves interleavings)")
    a = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (2.0, 2.0)]
    b = [(0.0, 0.0), (1.2, 0.0), (0.0, 0.8), (2.1, 1.9)]
    A, B = rips_module(a, euclid), rips_module(b, euclid)
    probe = [k * 0.02 for k in range(0, 250)]
    grid = [k * 0.01 for k in range(0, 500)]
    d_lattice = interleaving_distance(A, B, probe, grid)

    # rank curves as N-valued modules; their distance via the same scan:
    eps_rank = inf
    for eps in grid:
        if eps >= 0 and is_rank_interleaved(A, B, eps, probe):
            eps_rank = eps
            break
    print(f"lattice interleaving distance d(A,B)        = {d_lattice:.3f}")
    print(f"rank-curve interleaving distance d(rkA,rkB) = {eps_rank:.3f}")
    print(f"1-Lipschitz:  d(rank) <= d(lattice)?  "
          f"{eps_rank <= d_lattice + 1e-6}")
    print("Rank curve A (breaks, counts):", rank_module(A))


def demo_shift() -> None:
    banner("Shift functor: isometry, <= c displacement, tropical unit")
    pts = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0)]
    M = rips_module(pts, euclid)
    c = 0.5
    Mc = shift_module(c, M)
    probe = [k * 0.02 for k in range(-40, 160)]
    grid = [k * 0.01 for k in range(0, 200)]

    d_self_shift = interleaving_distance(M, Mc, probe, grid)
    print(f"d(M, shift c M) = {d_self_shift:.3f}  (<= c = {c}:  "
          f"{d_self_shift <= c + 1e-6})")

    # isometry: shifting both leaves distances unchanged
    pts2 = [(0.0, 0.0), (1.2, 0.0), (0.0, 0.9)]
    N = rips_module(pts2, euclid)
    Nc = shift_module(c, N)
    dMN = interleaving_distance(M, N, probe, grid)
    dMcNc = interleaving_distance(Mc, Nc, probe, grid)
    print(f"d(M,N) = {dMN:.3f},  d(shift M, shift N) = {dMcNc:.3f}  "
          f"-> isometry: {abs(dMN - dMcNc) < 1e-6}")
    print(f"self-distance d(M,M) = "
          f"{interleaving_distance(M, M, probe, grid):.3f}  "
          f"==> trop(0) is the tropical unit {TROP_UNIT}")


def main() -> None:
    demo_stability()
    demo_triangle_tropical()
    demo_rank_lipschitz()
    demo_shift()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
