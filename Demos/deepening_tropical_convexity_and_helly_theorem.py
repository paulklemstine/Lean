"""
Tropical convexity: numerical demonstrations
============================================

Self-contained numerical illustration of the max-plus (tropical) convexity
results:

  * tropical determinants and the Cramer dependence theorem
    (any d+1 vectors of R^d are tropically dependent, with weights given by the
    tropical determinants of the row-deleted minors);
  * the tropical Helly theorem with Helly number exactly d for tropical cones
    in R^d, and its extremal family;
  * Helly number exactly d+1 for tropically convex sets;
  * the tropical Caratheodory number d for cone hulls, and the colourful
    Caratheodory selection;
  * max-plus residuation, the greatest subsolution, and the principal-solution
    solvability criterion for A (x) x = b;
  * difference-constraint feasibility and its agreement with the
    negative-cycle (Bellman-Ford) criterion.

Everything runs on plain Python floats; no third-party dependencies.
"""

from __future__ import annotations

from itertools import combinations, permutations, product
from typing import Callable, Iterable, Sequence

Vector = list[float]
Matrix = list[list[float]]

NEG_INF = float("-inf")


# ---------------------------------------------------------------------------
# 1. Max-plus arithmetic
# ---------------------------------------------------------------------------


def trop_add(a: float, b: float) -> float:
    """Tropical addition a (+) b = max(a, b)."""
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication a (x) b = a + b."""
    return a + b


def trop_det(M: Matrix) -> float:
    """Tropical determinant  max over permutations pi of  sum_r M[r][pi(r)].

    This is the value of the optimal assignment problem with cost matrix M.
    Brute force over m! permutations; fine for the small m used here.
    """
    m = len(M)
    if m == 0:
        return 0.0
    return max(sum(M[r][pi[r]] for r in range(m)) for pi in permutations(range(m)))


def mul_vec(A: Matrix, x: Vector) -> Vector:
    """Max-plus matrix-vector product  (A (x) x)_i = max_j (A[i][j] + x[j])."""
    return [max(A[i][j] + x[j] for j in range(len(x))) for i in range(len(A))]


def resid(A: Matrix, b: Vector) -> Vector:
    """Residuated vector  (A # b)_j = min_i (b[i] - A[i][j]).

    By the residuation theorem this is the greatest x with A (x) x <= b.
    """
    m, n = len(A), len(A[0])
    return [min(b[i] - A[i][j] for i in range(m)) for j in range(n)]


# ---------------------------------------------------------------------------
# 2. Tropical Cramer dependence
# ---------------------------------------------------------------------------


def delete_row(A: Matrix, k: int) -> Matrix:
    """The row-deleted minor A^(k-hat)."""
    return [row[:] for i, row in enumerate(A) if i != k]


def cramer_weights(A: Matrix) -> Vector:
    """Cramer weights lambda_k = tropdet(A with row k deleted).

    A is (d+1) x d.  By the tropical Cramer dependence theorem, for every
    column i the maximum of lambda_k + A[k][i] is attained at >= 2 rows.
    """
    return [trop_det(delete_row(A, k)) for k in range(len(A))]


def column_argmax_profile(A: Matrix, lam: Vector) -> list[tuple[float, int]]:
    """For each column: (value of the max, number of rows attaining it)."""
    out: list[tuple[float, int]] = []
    for i in range(len(A[0])):
        vals = [lam[k] + A[k][i] for k in range(len(A))]
        best = max(vals)
        out.append((best, sum(1 for v in vals if abs(v - best) < 1e-9)))
    return out


def is_tropically_dependent(A: Matrix, lam: Vector) -> bool:
    """Every column maximum of lambda_k + A[k][i] is attained at least twice."""
    return all(cnt >= 2 for _, cnt in column_argmax_profile(A, lam))


def demo_cramer() -> None:
    print("=" * 74)
    print("1.  TROPICAL CRAMER DEPENDENCE:  any d+1 vectors of R^d are dependent")
    print("=" * 74)
    examples: list[Matrix] = [
        [[0, 0], [1, 3], [4, 1]],
        [[0, 0, 0], [3, 1, 4], [1, 5, 9], [2, 6, 5]],
        [[2, -1, 0], [0, 0, 0], [-3, 4, 1], [5, 5, -2]],
    ]
    for A in examples:
        d = len(A[0])
        lam = cramer_weights(A)
        prof = column_argmax_profile(A, lam)
        print(f"\n  A ({len(A)} points in R^{d}) = {A}")
        print(f"  Cramer weights lambda      = {lam}")
        print(f"  (column max, #argmax)      = {prof}")
        print(f"  tropically dependent?        {is_tropically_dependent(A, lam)}")

    print("\n  Randomised check over 2000 random matrices:")
    import random

    random.seed(20260810)
    ok = 0
    for _ in range(2000):
        d = random.choice([1, 2, 3, 4])
        A = [[float(random.randint(-6, 6)) for _ in range(d)] for _ in range(d + 1)]
        if is_tropically_dependent(A, cramer_weights(A)):
            ok += 1
    print(f"    dependence certificate valid in {ok}/2000 cases")

    print("\n  Sharpness: d vectors of R^d need NOT be tropically dependent.")
    A2: Matrix = [[0, 0], [1, 3]]
    print(f"    A = {A2}: a dependence needs lam0 = lam1 + 1 and lam0 = lam1 + 3.")
    best_lam = [1.0, 0.0]
    print(f"    best attempt lam = {best_lam} -> "
          f"{column_argmax_profile(A2, best_lam)} (second column: unique argmax)")


# ---------------------------------------------------------------------------
# 3. Tropical Helly:  Helly number d for cones
# ---------------------------------------------------------------------------


def helly_tight_set(k: int, d: int) -> Callable[[Vector], bool]:
    """Membership test for T_k = {x : exists j != k with x_k + 1 <= x_j}.

    Each T_k is a tropical cone; the family T_1..T_d has empty intersection but
    every d-1 of them meet.  This is the extremal family for Helly number d.
    """

    def member(x: Vector) -> bool:
        return any(j != k and x[k] + 1 <= x[j] + 1e-12 for j in range(d))

    return member


def is_trop_cone_numeric(member: Callable[[Vector], bool], d: int,
                         trials: int = 400) -> bool:
    """Monte-Carlo check that a set is closed under max-plus combinations."""
    import random

    for _ in range(trials):
        x = [float(random.randint(-5, 5)) for _ in range(d)]
        y = [float(random.randint(-5, 5)) for _ in range(d)]
        if not (member(x) and member(y)):
            continue
        s, t = float(random.randint(-4, 4)), float(random.randint(-4, 4))
        z = [max(s + x[i], t + y[i]) for i in range(d)]
        if not member(z):
            return False
    return True


def demo_helly() -> None:
    print()
    print("=" * 74)
    print("2.  TROPICAL HELLY:  Helly number exactly d for tropical cones in R^d")
    print("=" * 74)
    for d in (2, 3, 4):
        members = [helly_tight_set(k, d) for k in range(d)]
        cone_ok = all(is_trop_cone_numeric(m, d) for m in members)
        # total intersection is empty: the largest coordinate can never be beaten
        grid = [list(p) for p in product(range(-3, 4), repeat=d)]
        total = [x for x in grid if all(m(x) for m in members)]
        # every (d-1)-subfamily meets: the explicit witness of the proof
        all_small_meet = True
        for I in combinations(range(d), d - 1):
            k0 = next(k for k in range(d) if k not in I)
            witness = [0.0 if j == k0 else -1.0 for j in range(d)]
            if not all(members[k](witness) for k in I):
                all_small_meet = False
        print(f"\n  d = {d}:  family T_1..T_{d} of tropical cones")
        print(f"    all members are tropical cones (sampled):   {cone_ok}")
        print(f"    total intersection empty (grid search):     {len(total) == 0}")
        print(f"    every (d-1)-subfamily has a common point:   {all_small_meet}")
        print(f"    => Helly number is exactly d = {d}")

    print("\n  Helly FAILS for infinite families: C_k = {x in R^2 : x_0 + k <= x_1}.")
    for N in (3, 10, 100):
        x = [0.0, float(N)]
        print(f"    finite subfamily k <= {N:3d}: witness x = {x} works: "
              f"{all(x[0] + k <= x[1] for k in range(N + 1))}")
    print("    but no x satisfies x_1 - x_0 >= k for every k in N.")


def demo_helly_convex() -> None:
    print()
    print("=" * 74)
    print("3.  HELLY NUMBER d+1 FOR TROPICALLY CONVEX SETS (no scaling invariance)")
    print("=" * 74)
    for d in (1, 2, 3):
        # U_k = { x in R^d : (x,0) in T_k }  with T_k living in R^{d+1}
        def U(k: int, x: Vector) -> bool:
            xx = list(x) + [0.0]
            return any(j != k and xx[k] + 1 <= xx[j] + 1e-12 for j in range(d + 1))

        grid = [list(p) for p in product([-2.0, -1.0, 0.0, 1.0, 2.0], repeat=d)]
        total = [x for x in grid if all(U(k, x) for k in range(d + 1))]
        all_small_meet = True
        for I in combinations(range(d + 1), d):
            k0 = next(k for k in range(d + 1) if k not in I)
            u = [0.0 if j == k0 else -1.0 for j in range(d + 1)]
            x = [u[i] - u[d] for i in range(d)]  # dehomogenise
            if not all(U(k, x) for k in I):
                all_small_meet = False
        print(f"\n  d = {d}: d+1 = {d + 1} tropically convex sets in R^{d}")
        print(f"    total intersection empty (grid search):   {len(total) == 0}")
        print(f"    every d-subfamily has a common point:     {all_small_meet}")
        print(f"    => Helly number is exactly d+1 = {d + 1}")
        print(f"    (the previously conjectured bound 2d = {2 * d} holds but is "
              f"{'sharp' if 2 * d == d + 1 else 'not sharp'})")


# ---------------------------------------------------------------------------
# 4. Caratheodory
# ---------------------------------------------------------------------------


def cone_hull_point(P: Matrix, lam: Vector) -> Vector:
    """z_i = max_k (lam[k] + P[k][i])  -- a point of the tropical cone hull."""
    d = len(P[0])
    return [max(lam[k] + P[k][i] for k in range(len(P))) for i in range(d)]


def caratheodory_reduce(P: Matrix, lam: Vector) -> tuple[list[int], Vector]:
    """Select one generator per coordinate: at most d of them suffice."""
    z = cone_hull_point(P, lam)
    chosen: list[int] = []
    for i in range(len(z)):
        k_star = max(range(len(P)), key=lambda k: lam[k] + P[k][i])
        if k_star not in chosen:
            chosen.append(k_star)
    return sorted(chosen), z


def demo_caratheodory() -> None:
    print()
    print("=" * 74)
    print("4.  TROPICAL CARATHEODORY:  cone-hull number exactly d")
    print("=" * 74)
    import random

    random.seed(11)
    d, m = 3, 9
    P: Matrix = [[float(random.randint(-5, 5)) for _ in range(d)] for _ in range(m)]
    lam: Vector = [float(random.randint(-4, 4)) for _ in range(m)]
    G, z = caratheodory_reduce(P, lam)
    z_small = cone_hull_point([P[k] for k in G], [lam[k] for k in G])
    print(f"\n  {m} generators in R^{d}, point z = {z}")
    print(f"  reduced generator set G = {G}  (|G| = {len(G)} <= d = {d})")
    print(f"  z recomputed from G      = {z_small}   equal: {z == z_small}")

    print("\n  Sharpness: the d tropical unit vectors e^(k) "
          "(0 on the diagonal, -1 off).")
    for d in (2, 3, 4):
        E: Matrix = [[0.0 if i == k else -1.0 for i in range(d)] for k in range(d)]
        zero = [0.0] * d
        full = cone_hull_point(E, [0.0] * d)
        # brute-force: can a proper subfamily generate 0?  Try residuated weights.
        proper_ok = False
        for r in range(1, d):
            for G in combinations(range(d), r):
                sub = [E[k] for k in G]
                # greatest weights with lam_k + e^(k) <= 0 : residuation
                w = [min(0.0 - sub[t][i] for i in range(d)) for t in range(len(sub))]
                if cone_hull_point(sub, w) == zero:
                    proper_ok = True
        print(f"    d = {d}: full family generates 0: {full == zero}; "
              f"some proper subfamily does: {proper_ok}")


def demo_colourful() -> None:
    print()
    print("=" * 74)
    print("5.  COLOURFUL TROPICAL CARATHEODORY:  an explicit rainbow selection")
    print("=" * 74)
    import random

    random.seed(7)
    d = 3
    z: Vector = [0.0, 0.0, 0.0]
    classes: list[Matrix] = []
    weights: list[Vector] = []
    for _c in range(d):  # build each colour class so that its hull contains z
        P: Matrix = [[float(random.randint(-4, 0)) for _ in range(d)]
                     for _ in range(4)]
        # residuate so that the hull point is exactly z (adjust one generator)
        for i in range(d):
            P[i % 4][i] = 0.0
        lam = [min(z[i] - P[k][i] for i in range(d)) for k in range(4)]
        assert cone_hull_point(P, lam) == z
        classes.append(P)
        weights.append(lam)

    sel = [max(range(4), key=lambda k: weights[c][k] + classes[c][k][c])
           for c in range(d)]
    w = [weights[c][sel[c]] for c in range(d)]
    rainbow: Matrix = [classes[c][sel[c]] for c in range(d)]
    z_rainbow = cone_hull_point(rainbow, w)
    print(f"\n  target point z              = {z}")
    print(f"  rainbow selection (one per colour), indices {sel}")
    for c in range(d):
        print(f"    colour {c}: generator {rainbow[c]}  weight {w[c]}")
    print(f"  hull of the rainbow gives   = {z_rainbow}   equal: {z_rainbow == z}")


# ---------------------------------------------------------------------------
# 5. Residuation and the principal solution
# ---------------------------------------------------------------------------


def solve_maxplus(A: Matrix, b: Vector) -> tuple[bool, Vector, Vector]:
    """Decide A (x) x = b via the principal solution.  Returns
    (solvable, candidate A#b, residual A (x) (A#b))."""
    x_hat = resid(A, b)
    r = mul_vec(A, x_hat)
    return all(abs(r[i] - b[i]) < 1e-9 for i in range(len(b))), x_hat, r


def demo_residuation() -> None:
    print()
    print("=" * 74)
    print("6.  MAX-PLUS RESIDUATION AND THE PRINCIPAL SOLUTION")
    print("=" * 74)
    tests: list[tuple[Matrix, Vector]] = [
        ([[0, 2], [3, 1]], [5, 4]),
        ([[0, 2], [3, 1]], [5, 10]),
        ([[1, 0, 3], [2, 4, 1], [0, 0, 0]], [7, 8, 5]),
    ]
    for A, b in tests:
        ok, x_hat, r = solve_maxplus(A, [float(v) for v in b])
        print(f"\n  A = {A},  b = {b}")
        print(f"    A # b (greatest subsolution) = {x_hat}")
        print(f"    A (x) (A # b)                = {r}")
        print(f"    solvable: {ok}" + ("" if ok else "   (best approximation from below)"))

    print("\n  Galois connection  A (x) x <= b  <=>  x <= A # b  (random check):")
    import random

    random.seed(3)
    good = 0
    for _ in range(3000):
        m, n = random.randint(1, 4), random.randint(1, 4)
        A = [[float(random.randint(-5, 5)) for _ in range(n)] for _ in range(m)]
        b = [float(random.randint(-5, 5)) for _ in range(m)]
        x = [float(random.randint(-8, 8)) for _ in range(n)]
        lhs = all(mul_vec(A, x)[i] <= b[i] + 1e-9 for i in range(m))
        rhs = all(x[j] <= resid(A, b)[j] + 1e-9 for j in range(n))
        good += int(lhs == rhs)
    print(f"    equivalence held in {good}/3000 random instances")

    print("\n  Principal-solution criterion (random check):")
    detected = 0
    greatest = 0
    for _ in range(1500):
        m, n = random.randint(1, 4), random.randint(1, 4)
        A = [[float(random.randint(-3, 3)) for _ in range(n)] for _ in range(m)]
        x0 = [float(random.randint(-3, 3)) for _ in range(n)]
        b = mul_vec(A, x0)  # solvable by construction, witness x0
        ok, x_hat, _ = solve_maxplus(A, b)
        detected += int(ok)
        greatest += int(all(x0[j] <= x_hat[j] + 1e-9 for j in range(n)))
    print(f"    solvable systems detected by the candidate A # b: {detected}/1500")
    print(f"    every actual solution dominated by A # b:         {greatest}/1500")


# ---------------------------------------------------------------------------
# 6. Difference constraints:  Helly bound vs. negative cycles
# ---------------------------------------------------------------------------


def diff_feasible(d: int, cons: Sequence[tuple[int, int, float]]) -> bool:
    """Feasibility of  x[t] - x[s] <= w  by Bellman-Ford negative-cycle test."""
    dist = [0.0] * d
    for _ in range(d):
        for (s, t, w) in cons:
            if dist[s] + w < dist[t] - 1e-12:
                dist[t] = dist[s] + w
    return not any(dist[s] + w < dist[t] - 1e-12 for (s, t, w) in cons)


def demo_difference_constraints() -> None:
    print()
    print("=" * 74)
    print("7.  DIFFERENCE CONSTRAINTS:  feasibility is d-local (Helly number d)")
    print("=" * 74)
    import random

    random.seed(1234)
    d = 4
    agree = 0
    infeasible_cases = 0
    for _ in range(400):
        n = random.randint(3, 9)
        cons = [(random.randrange(d), random.randrange(d),
                 float(random.randint(-4, 4))) for _ in range(n)]
        full = diff_feasible(d, cons)
        local = all(diff_feasible(d, [cons[k] for k in I])
                    for r in range(min(d, n) + 1)
                    for I in combinations(range(n), r))
        agree += int(full == local)
        infeasible_cases += int(not full)
    print(f"\n  d = {d} variables, 400 random systems:")
    print(f"    'feasible'  <=>  'every {d} constraints feasible':  "
          f"{agree}/400 agreements")
    print(f"    ({infeasible_cases} of the systems were infeasible)")
    print("\n  Interpretation: an infeasible system always contains an infeasible")
    print(f"  subsystem of at most d = {d} constraints -- exactly a simple negative")
    print("  cycle, so the Helly bound reproves the Bellman-Ford criterion.")


# ---------------------------------------------------------------------------


def main() -> None:
    demo_cramer()
    demo_helly()
    demo_helly_convex()
    demo_caratheodory()
    demo_colourful()
    demo_residuation()
    demo_difference_constraints()
    print()
    print("=" * 74)
    print("All demonstrations completed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
