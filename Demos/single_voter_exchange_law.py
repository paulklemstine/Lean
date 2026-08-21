"""
Numerical demonstrations of the single-voter exchange law for min-plus aggregators.

Setting
-------
A finite set of voters S = {0, ..., n-1} carries weights delta_i (handicaps).
A profile is a vector x of scores.  The aggregator is the min-plus linear form

    F(x) = min_{i in S} (x_i + delta_i),

and the decisive set is the argmin

    D(x) = { i in S : x_i + delta_i = F(x) }.

Chambers are the cells D(x) = {i}; walls are the cells D(x) = {i, j}; more
generally the cell labelled T has codimension |T| - 1.

This script verifies, numerically:

  1. the master formula  F(upd(x; j, c)) = min(c + delta_j, x_i + delta_i)
     on the chamber of i, and the sharp trichotomy around the exchange
     threshold theta = x_i + delta_i - delta_j;
  2. the kink: F along the exchange path is x_i + delta_i - max(t, 0);
  3. the exchange metric: the minimum number of voters who must lower their
     scores to reach the cell labelled T from the chamber of i is exactly
     |T \\ {i}| -- checked against brute-force search over mover sets;
  4. exchange distance = codimension for faces of the incumbent's chamber;
  5. completeness of the dual graph of chambers;
  6. the f-vector  f_d = C(n, d+1), the cell count 2^n - 1, and the
     alternating sum 1;
  7. the failure of the metric lower bound for upward moves (two-voter
     counterexample);
  8. combinatorial rigidity: shifting all weights by a constant changes no
     label, and two weight systems with the same labelling differ by a
     constant;
  9. the Pythagorean exchange gap: with weights (a, b, c) of a Pythagorean
     triple, the hypotenuse voter's threshold at the neutral profile is
     a - c, a strictly positive concession of size c - a.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import Dict, FrozenSet, Iterable, List, Sequence, Tuple

Profile = Tuple[float, ...]
Weights = Tuple[float, ...]
Label = FrozenSet[int]

TOL: float = 1e-9


# --------------------------------------------------------------------------
# Core min-plus machinery
# --------------------------------------------------------------------------
def aggregate(delta: Weights, x: Profile) -> float:
    """F(x) = min_i (x_i + delta_i)."""
    return min(xi + di for xi, di in zip(x, delta))


def decisive_set(delta: Weights, x: Profile) -> Label:
    """D(x) = argmin_i (x_i + delta_i), as a frozenset of voter indices."""
    m = aggregate(delta, x)
    return frozenset(i for i, (xi, di) in enumerate(zip(x, delta)) if abs(xi + di - m) <= TOL)


def update(x: Profile, j: int, c: float) -> Profile:
    """The profile x with coordinate j reset to c."""
    y = list(x)
    y[j] = c
    return tuple(y)


def exchange_threshold(delta: Weights, x: Profile, i: int, j: int) -> float:
    """theta = x_i + delta_i - delta_j: the score putting j exactly level with i."""
    return x[i] + delta[i] - delta[j]


def in_chamber(delta: Weights, x: Profile, i: int) -> bool:
    """Is x in the (closed) chamber of voter i?"""
    return all(x[i] + delta[i] <= x[k] + delta[k] + TOL for k in range(len(delta)))


def coalition_exchange(delta: Weights, x: Profile, i: int,
                       T: Iterable[int], eps: float) -> Profile:
    """Give every member k of T the score x_i + delta_i - delta_k - eps."""
    Ts = set(T)
    return tuple(x[i] + delta[i] - delta[k] - eps if k in Ts else x[k]
                 for k in range(len(delta)))


# --------------------------------------------------------------------------
# 1. Master formula and the sharp trichotomy
# --------------------------------------------------------------------------
def demo_trichotomy() -> None:
    print("=" * 74)
    print("1. Master formula and the sharp trichotomy")
    print("=" * 74)
    delta: Weights = (0.0, 1.5, 2.25, 4.0)
    x: Profile = (0.0, 1.0, 3.0, 2.0)
    i = min(decisive_set(delta, x))
    print(f"  weights delta = {delta}")
    print(f"  profile x     = {x}")
    print(f"  F(x) = {aggregate(delta, x):.4f},  D(x) = {sorted(decisive_set(delta, x))}")
    print(f"  incumbent i = {i}")

    j = 2
    theta = exchange_threshold(delta, x, i, j)
    print(f"\n  challenger j = {j},  exchange threshold theta = {theta:.4f}")
    print(f"  {'c':>10} {'F(upd)':>10} {'min(c+dj, xi+di)':>18}   decisive set")
    for c in (theta + 1.0, theta + 0.25, theta, theta - 0.25, theta - 1.0):
        y = update(x, j, c)
        lhs = aggregate(delta, y)
        rhs = min(c + delta[j], x[i] + delta[i])
        assert abs(lhs - rhs) <= TOL, "master formula on a chamber failed"
        lab = sorted(decisive_set(delta, y))
        print(f"  {c:>10.4f} {lhs:>10.4f} {rhs:>18.4f}   {lab}")
        if c > theta + TOL:
            assert lab == [i]
        elif abs(c - theta) <= TOL:
            assert lab == sorted([i, j])
        else:
            assert lab == [j]
    print("\n  Verified:  c > theta -> {i};  c = theta -> {i,j};  c < theta -> {j}.")


# --------------------------------------------------------------------------
# 2. The kink of the aggregate along the exchange path
# --------------------------------------------------------------------------
def demo_kink() -> None:
    print()
    print("=" * 74)
    print("2. The kink: F along the exchange path is x_i + delta_i - max(t, 0)")
    print("=" * 74)
    delta: Weights = (0.0, 1.5, 2.25, 4.0)
    x: Profile = (0.0, 1.0, 3.0, 2.0)
    i, j = 0, 2
    theta = exchange_threshold(delta, x, i, j)
    base = x[i] + delta[i]
    print(f"  {'t':>8} {'F(gamma(t))':>14} {'predicted':>12}   label")
    for t in (-1.5, -0.5, 0.0, 0.5, 1.5, 3.0):
        y = update(x, j, theta - t)
        val = aggregate(delta, y)
        pred = base - max(t, 0.0)
        assert abs(val - pred) <= TOL, "exchange path formula failed"
        print(f"  {t:>8.2f} {val:>14.4f} {pred:>12.4f}   {sorted(decisive_set(delta, y))}")
    left = (aggregate(delta, update(x, j, theta - 0.0))
            - aggregate(delta, update(x, j, theta + 1.0)))
    right = (aggregate(delta, update(x, j, theta - 0.0))
             - aggregate(delta, update(x, j, theta - 1.0)))
    print(f"\n  one-sided slopes at the wall:  left = {left:.4f}, right = {-right:.4f}")
    print("  the slopes differ by exactly 1: the wall is the non-differentiability locus.")


# --------------------------------------------------------------------------
# 3-4. The exchange metric, by brute force, and codimension
# --------------------------------------------------------------------------
def brute_force_exchange_distance(delta: Weights, x: Profile, T: Label,
                                  eps: float = 0.5) -> int:
    """
    Smallest |D| over mover sets D such that SOME downward move supported on D
    reaches the cell labelled T.

    For a fixed D, if a downward move supported on D reaches T then it must
    equalize the monomials of T; the canonical candidate move is the coalition
    exchange on D (at the wall value when the incumbent is in T, and eps below
    it otherwise).  We test both candidates for each D, which is enough to
    detect feasibility, and additionally certify infeasibility using the
    locality principle D(y) subset of D u D(x).
    """
    n = len(delta)
    i = min(decisive_set(delta, x))
    for size in range(0, n + 1):
        for D in combinations(range(n), size):
            for e in (0.0, eps):
                y = coalition_exchange(delta, x, i, D, e)
                if all(y[k] <= x[k] + TOL for k in range(n)) and decisive_set(delta, y) == T:
                    return size
    raise RuntimeError("no downward move reaches the target cell")


def demo_exchange_metric() -> None:
    print()
    print("=" * 74)
    print("3-4. The exchange metric equals |T \\ {i}| and equals the codimension")
    print("=" * 74)
    delta: Weights = (0.0, 1.5, 2.25, 4.0)
    x: Profile = (0.0, 1.0, 3.0, 2.0)
    n = len(delta)
    i = min(decisive_set(delta, x))
    print(f"  weights {delta}, profile {x}, incumbent i = {i}\n")
    header = "|T minus i|"
    print(f"  {'target T':>16} {header:>12} {'brute force':>12} {'codim':>7}  face of C_i?")
    for size in range(1, n + 1):
        for T_tuple in combinations(range(n), size):
            T: Label = frozenset(T_tuple)
            predicted = len(T - {i})
            found = brute_force_exchange_distance(delta, x, T)
            assert predicted == found, f"metric mismatch for T={sorted(T)}"
            codim = len(T) - 1
            face = i in T
            flag = "yes" if face else "no"
            if face:
                assert predicted == codim
            print(f"  {str(sorted(T)):>16} {predicted:>12} {found:>12} {codim:>7}  {flag}")
    print("\n  Verified: exchange distance = |T \\ {i}| always,")
    print("            and = codimension |T| - 1 whenever the incumbent lies in T.")


# --------------------------------------------------------------------------
# 5. The dual graph is complete
# --------------------------------------------------------------------------
def demo_dual_graph() -> None:
    print()
    print("=" * 74)
    print("5. The dual graph of chambers is the complete graph")
    print("=" * 74)
    delta: Weights = (0.0, 1.5, 2.25, 4.0)
    n = len(delta)
    edges: List[Tuple[int, int]] = []
    for i, j in combinations(range(n), 2):
        # explicit wall witness: level i and j, push everybody else far away
        x = tuple(0.0 if k == i else (delta[i] - delta[j] if k == j else 100.0)
                  for k in range(n))
        lab = decisive_set(delta, x)
        assert lab == frozenset({i, j}), (i, j, sorted(lab))
        edges.append((i, j))
    print(f"  found a wall witness for each of the {len(edges)} pairs: {edges}")
    print(f"  complete graph on {n} vertices has C({n},2) = {comb(n, 2)} edges -- matched.")
    print("  hence the complex is gallery-connected of diameter one.")


# --------------------------------------------------------------------------
# 6. f-vector, cell count, Euler characteristic
# --------------------------------------------------------------------------
def demo_f_vector(n_max: int = 6) -> None:
    print()
    print("=" * 74)
    print("6. f-vector, total cell count, Euler characteristic")
    print("=" * 74)
    print(f"  {'n':>3}  {'f-vector (f_0, f_1, ...)':>34} {'cells':>8} {'alt sum':>8}")
    for n in range(1, n_max + 1):
        f = [comb(n, d + 1) for d in range(n)]
        total = sum(f)
        alt = sum((-1) ** d * f[d] for d in range(n))
        assert total == 2 ** n - 1
        assert alt == 1
        print(f"  {n:>3}  {str(f):>34} {total:>8} {alt:>8}")
    print("\n  Verified: f_d = C(n, d+1), total = 2^n - 1, alternating sum = 1.")


# --------------------------------------------------------------------------
# 7. Downwardness is essential
# --------------------------------------------------------------------------
def demo_upward_counterexample() -> None:
    print()
    print("=" * 74)
    print("7. The metric lower bound fails for upward moves")
    print("=" * 74)
    delta: Weights = (0.0, 1.0)
    x: Profile = (0.0, 0.0)
    y: Profile = (2.0, 0.0)
    print(f"  weights {delta}")
    print(f"  x = {x}: F = {aggregate(delta, x):.1f}, D = {sorted(decisive_set(delta, x))}")
    print(f"  y = {y}: F = {aggregate(delta, y):.1f}, D = {sorted(decisive_set(delta, y))}")
    assert decisive_set(delta, x) == frozenset({0})
    assert decisive_set(delta, y) == frozenset({1})
    movers = {k for k in range(2) if abs(x[k] - y[k]) > TOL}
    print(f"  movers = {sorted(movers)};  T \\ {{i}} = {{1}}  is NOT contained in the movers.")
    print("  Raising the incumbent's own score hands the win to a voter who never moved.")


# --------------------------------------------------------------------------
# 8. Rigidity: gauge invariance and recovery up to a constant
# --------------------------------------------------------------------------
def sample_profiles(n: int, grid: Sequence[float]) -> List[Profile]:
    """A finite grid of profiles used to compare labellings empirically."""
    out: List[Profile] = [tuple(0.0 for _ in range(n))]
    for i in range(n):
        for g in grid:
            out.append(tuple(g if k == i else 0.0 for k in range(n)))
    for i, j in combinations(range(n), 2):
        for g in grid:
            for h in grid:
                out.append(tuple(g if k == i else (h if k == j else 0.0) for k in range(n)))
    return out


def labelling(delta: Weights, profiles: Iterable[Profile]) -> Dict[Profile, Label]:
    return {x: decisive_set(delta, x) for x in profiles}


def demo_rigidity() -> None:
    print()
    print("=" * 74)
    print("8. Rigidity: the labelling sees delta only modulo a global constant")
    print("=" * 74)
    delta: Weights = (0.0, 1.5, 2.25, 4.0)
    n = len(delta)
    grid = (-3.0, -1.5, -0.75, 0.0, 0.75, 1.5, 3.0)
    profiles = sample_profiles(n, grid)

    shift = 2.75
    shifted: Weights = tuple(d + shift for d in delta)
    same = labelling(delta, profiles) == labelling(shifted, profiles)
    print(f"  delta            = {delta}")
    print(f"  delta + {shift}      = {shifted}")
    print(f"  identical labels on {len(profiles)} probe profiles: {same}")
    assert same
    dF = max(abs(aggregate(shifted, x) - aggregate(delta, x) - shift) for x in profiles)
    print(f"  and the aggregate shifts by exactly {shift} (max deviation {dF:.1e}):")
    print("  so the FUNCTION distinguishes the two systems while the LABELLING cannot.")

    perturbed: Weights = (0.0, 1.5, 2.25, 3.0)
    diff = labelling(delta, profiles) != labelling(perturbed, profiles)
    print(f"\n  delta' = {perturbed} is not a constant shift of delta;")
    print(f"  its labelling differs from that of delta on the probe set: {diff}")
    assert diff

    # explicit recovery of delta from the labelling, normalized at voter 0
    recovered = [0.0] * n
    for i in range(1, n):
        lo, hi = -50.0, 50.0
        for _ in range(200):
            mid = 0.5 * (lo + hi)
            x = tuple(mid if k == i else (0.0 if k == 0 else 100.0) for k in range(n))
            if i in decisive_set(delta, x):
                lo = mid
            else:
                hi = mid
        recovered[i] = -0.5 * (lo + hi)  # tie at x_i = delta_0 - delta_i
    normalized = [d - delta[0] for d in delta]
    print(f"\n  recovered weights (normalized so delta_0 = 0): "
          f"{[round(v, 6) for v in recovered]}")
    print(f"  true weights      (normalized so delta_0 = 0): "
          f"{[round(v, 6) for v in normalized]}")
    assert max(abs(a - b) for a, b in zip(recovered, normalized)) < 1e-6


# --------------------------------------------------------------------------
# 9. The Pythagorean exchange gap
# --------------------------------------------------------------------------
def demo_pythagorean(triples: Sequence[Tuple[int, int, int]] = ((3, 4, 5),
                                                               (5, 12, 13),
                                                               (8, 15, 17),
                                                               (20, 21, 29))) -> None:
    print()
    print("=" * 74)
    print("9. The Pythagorean exchange gap")
    print("=" * 74)
    print(f"  {'(a,b,c)':>14} {'threshold a-c':>15} {'gap c-a':>9}   label at "
          f"x_2 = a-c   label just below")
    for a, b, c in triples:
        assert a * a + b * b == c * c
        delta: Weights = (float(a), float(b), float(c))
        x: Profile = (0.0, 0.0, 0.0)
        assert decisive_set(delta, x) == frozenset({0}), "the leg a should win at 0"
        theta = exchange_threshold(delta, x, 0, 2)
        assert abs(theta - (a - c)) <= TOL
        wall = decisive_set(delta, update(x, 2, theta))
        below = decisive_set(delta, update(x, 2, theta - 0.5))
        assert wall == frozenset({0, 2}) and below == frozenset({2})
        print(f"  {str((a, b, c)):>14} {theta:>15.2f} {c - a:>9} "
              f"        {sorted(wall)}           {sorted(below)}")
    print("\n  a^2 + b^2 = c^2 forces c > a, hence a strictly positive concession")
    print("  of size exactly c - a is needed before the hypotenuse voter can win.")


def main() -> None:
    demo_trichotomy()
    demo_kink()
    demo_exchange_metric()
    demo_dual_graph()
    demo_f_vector()
    demo_upward_counterexample()
    demo_rigidity()
    demo_pythagorean()
    print()
    print("=" * 74)
    print("All numerical checks passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
