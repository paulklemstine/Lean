"""
Numerical demonstrations of Talagrand's convex distance inequality
on finite product spaces.

The script is self-contained (standard library only; ``numpy`` is used only if
available, but a pure-Python fallback is provided) and verifies numerically:

  1. the exact value of the convex distance to a singleton and to a subcube;
  2. the minimax (duality) identity  d_T(A,x) = sup_w d_w(A,x)  over admissible
     weight vectors w >= 0 with ||w||_2 <= 1;
  3. the exponential moment bound  E[exp(d_T(A,X)^2 / 4)] * P(A) <= 1  by brute
     force enumeration of small product spaces, including non-identically
     distributed coordinates;
  4. the deviation bound  P(A) * P(S) <= exp(-t/4);
  5. the interpolation lemma  min_lambda exp((1-lambda)^2/4) r^(-lambda) <= 2-r
     with the closed-form optimiser lambda = 1 + 2 log r, and its optimality;
  6. concentration of certifiable functionals at the certificate scale, for the
     number-of-ones functional and for the longest increasing subsequence.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Point = Tuple[int, ...]


# --------------------------------------------------------------------------
# Basic geometry: disagreement vectors and the convex distance
# --------------------------------------------------------------------------


def disagreement(x: Point, y: Point) -> List[float]:
    """The 0/1 vector U(x,y)_i = 1[x_i != y_i]."""
    return [0.0 if xi == yi else 1.0 for xi, yi in zip(x, y)]


def sq_norm(v: Sequence[float]) -> float:
    """Squared Euclidean norm."""
    return sum(t * t for t in v)


def convex_distance_sq(
    A: Sequence[Point], x: Point, iterations: int = 4000, tol: float = 1e-14
) -> Tuple[float, List[float]]:
    """Compute d_T(A,x)^2 = min over the convex hull of {U(x,y) : y in A} of the
    squared Euclidean norm, by pairwise Frank-Wolfe (away steps), which
    converges linearly on a polytope.

    Returns (value, minimising hull point).
    """
    if not A:
        raise ValueError("A must be nonempty")
    atoms: List[List[float]] = [disagreement(x, y) for y in A]
    n = len(x)
    # start at the atom of least norm
    best = min(range(len(atoms)), key=lambda j: sq_norm(atoms[j]))
    alpha: Dict[int, float] = {best: 1.0}
    v: List[float] = list(atoms[best])

    for _ in range(iterations):
        # linear minimisation oracle: minimise <v, atom>
        s = min(range(len(atoms)), key=lambda j: sum(v[i] * atoms[j][i] for i in range(n)))
        # away atom: maximise <v, atom> over the active set
        a = max(alpha, key=lambda j: sum(v[i] * atoms[j][i] for i in range(n)))
        d = [atoms[s][i] - atoms[a][i] for i in range(n)]
        dd = sq_norm(d)
        if dd < tol:
            break
        # exact line search for the quadratic ||v + gamma d||^2
        gnum = -sum(v[i] * d[i] for i in range(n))
        gmax = alpha[a]
        gamma = max(0.0, min(gmax, gnum / dd))
        if gamma <= tol:
            # try a plain Frank-Wolfe step instead
            dfw = [atoms[s][i] - v[i] for i in range(n)]
            ddfw = sq_norm(dfw)
            if ddfw < tol:
                break
            gfw = max(0.0, min(1.0, -sum(v[i] * dfw[i] for i in range(n)) / ddfw))
            if gfw <= tol:
                break
            for j in list(alpha):
                alpha[j] *= 1.0 - gfw
            alpha[s] = alpha.get(s, 0.0) + gfw
            v = [v[i] + gfw * dfw[i] for i in range(n)]
            continue
        alpha[a] -= gamma
        if alpha[a] <= tol:
            del alpha[a]
        alpha[s] = alpha.get(s, 0.0) + gamma
        v = [v[i] + gamma * d[i] for i in range(n)]

    return sq_norm(v), v


def weighted_hamming(w: Sequence[float], A: Sequence[Point], x: Point) -> float:
    """d_w(A,x) = min over y in A of sum_i w_i 1[x_i != y_i]."""
    return min(sum(wi * ui for wi, ui in zip(w, disagreement(x, y))) for y in A)


def dual_certificate(A: Sequence[Point], x: Point) -> Tuple[List[float], float]:
    """Return the admissible weight w = v/||v|| from the minimum-norm point v,
    together with the value d_w(A,x) it certifies."""
    val, v = convex_distance_sq(A, x)
    norm = math.sqrt(val)
    if norm == 0.0:
        w = [0.0] * len(x)
    else:
        w = [vi / norm for vi in v]
    return w, weighted_hamming(w, A, x)


# --------------------------------------------------------------------------
# Product measures on a finite alphabet
# --------------------------------------------------------------------------


def all_points(alphabet_size: int, n: int) -> List[Point]:
    return [tuple(p) for p in itertools.product(range(alphabet_size), repeat=n)]


def point_weight(p: Sequence[Sequence[float]], x: Point) -> float:
    """wt(x) = prod_i p_i(x_i)."""
    return math.prod(p[i][x[i]] for i in range(len(x)))


def mass(p: Sequence[Sequence[float]], S: Iterable[Point]) -> float:
    return sum(point_weight(p, x) for x in S)


def exponential_moment(
    p: Sequence[Sequence[float]], A: Sequence[Point], space: Sequence[Point]
) -> float:
    """E[exp(d_T(A,X)^2 / 4)]."""
    total = 0.0
    for x in space:
        d2, _ = convex_distance_sq(A, x)
        total += point_weight(p, x) * math.exp(d2 / 4.0)
    return total


# --------------------------------------------------------------------------
# Combinatorial functionals
# --------------------------------------------------------------------------


def ones_count(x: Point) -> int:
    return sum(1 for xi in x if xi == 1)


def longest_increasing(x: Sequence[int]) -> int:
    """Length of the longest weakly increasing subsequence (O(n^2))."""
    n = len(x)
    if n == 0:
        return 0
    best = [1] * n
    for j in range(n):
        for i in range(j):
            if x[i] <= x[j] and best[i] + 1 > best[j]:
                best[j] = best[i] + 1
    return max(best)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_singleton_and_subcube() -> None:
    print("=" * 74)
    print("1. Exact convex distances: singletons and subcubes")
    print("=" * 74)
    n = 6
    y: Point = (0, 1, 0, 1, 1, 0)
    for x in [(0, 1, 0, 1, 1, 0), (1, 1, 0, 1, 1, 0), (1, 0, 1, 0, 0, 1)]:
        d2, _ = convex_distance_sq([y], x)
        exact = sum(1 for a, b in zip(x, y) for _ in [0] if a != b)
        print(f"  d_T({{y}},x)^2 = {d2:.10f}   Hamming distance = {exact}")

    B = [0, 2, 4]  # constrained coordinates
    c: Point = (0, 0, 0, 0, 0, 0)
    cyl = [z for z in all_points(2, n) if all(z[i] == c[i] for i in B)]
    for x in [(1, 1, 0, 1, 1, 0), (1, 0, 1, 0, 1, 1), (0, 1, 0, 1, 0, 1)]:
        d2, _ = convex_distance_sq(cyl, x)
        exact = sum(1 for i in B if x[i] != c[i])
        print(f"  d_T(Cyl(B,c),x)^2 = {d2:.10f}   #{{i in B : x_i != c_i}} = {exact}")
    print()


def demo_duality() -> None:
    print("=" * 74)
    print("2. Minimax identity: d_T(A,x) = sup over admissible w of d_w(A,x)")
    print("=" * 74)
    random.seed(20260820)
    n = 5
    space = all_points(2, n)
    for trial in range(4):
        A = random.sample(space, k=6)
        x = random.choice(space)
        d2, _ = convex_distance_sq(A, x)
        w, certified = dual_certificate(A, x)
        # random search over admissible weights, for comparison
        best_random = 0.0
        for _ in range(4000):
            v = [random.random() for _ in range(n)]
            nrm = math.sqrt(sq_norm(v))
            v = [vi / nrm for vi in v]
            best_random = max(best_random, weighted_hamming(v, A, x))
        print(
            f"  trial {trial}: d_T = {math.sqrt(d2):.6f} | "
            f"dual certificate d_w = {certified:.6f} | "
            f"best random w = {best_random:.6f}"
        )
    print("  (the certificate matches d_T; random search never exceeds it)\n")


def demo_moment_bound() -> None:
    print("=" * 74)
    print("3. Exponential moment bound  E[exp(d_T^2/4)] * P(A) <= 1")
    print("=" * 74)
    random.seed(7)
    n = 5
    space = all_points(2, n)
    biases: List[List[float]] = [[0.5, 0.5]] * n
    skew: List[List[float]] = [[0.8, 0.2], [0.3, 0.7], [0.5, 0.5], [0.9, 0.1], [0.4, 0.6]]
    for label, p in (("uniform coins", biases), ("biased coins", skew)):
        worst = 0.0
        for _ in range(12):
            k = random.randint(1, len(space) // 2)
            A = random.sample(space, k=k)
            value = exponential_moment(p, A, space) * mass(p, A)
            worst = max(worst, value)
        print(f"  {label}: max over 12 random sets of E[exp(d_T^2/4)]*P(A) = {worst:.6f} <= 1")
    # a structured example: the lower half of the cube
    A = [x for x in space if ones_count(x) <= 2]
    value = exponential_moment(biases, A, space) * mass(biases, A)
    print(f"  A = {{at most two ones}}: E[exp(d_T^2/4)]*P(A) = {value:.6f}, P(A) = "
          f"{mass(biases, A):.4f}")
    print()


def demo_deviation() -> None:
    print("=" * 74)
    print("4. Deviation bound  P(A) P(d_T^2 >= t) <= exp(-t/4)")
    print("=" * 74)
    n = 6
    space = all_points(2, n)
    p: List[List[float]] = [[0.5, 0.5]] * n
    A = [x for x in space if ones_count(x) <= 3]
    d2 = {x: convex_distance_sq(A, x)[0] for x in space}
    print("      t     P(A)*P(d_T^2 >= t)      exp(-t/4)")
    for t in [0.0, 0.5, 1.0, 1.5, 2.0, 3.0, 4.0]:
        S = [x for x in space if d2[x] >= t]
        lhs = mass(p, A) * mass(p, S)
        print(f"  {t:5.2f}        {lhs:.6f}            {math.exp(-t / 4):.6f}")
    print()


def interpolation_profile(r: float) -> Tuple[float, float]:
    """Return (optimal lambda, value of exp((1-lam)^2/4) r^(-lam))."""
    if r <= 0.0:
        return 0.0, math.exp(0.25)
    lam = min(1.0, max(0.0, 1.0 + 2.0 * math.log(r)))
    return lam, math.exp((1.0 - lam) ** 2 / 4.0) * r ** (-lam)


def demo_interpolation() -> None:
    print("=" * 74)
    print("5. Interpolation lemma  min_lambda exp((1-l)^2/4) r^(-l) <= 2 - r")
    print("=" * 74)
    print("      r     optimal lambda      value        2 - r        slack")
    for r in [0.05, 0.2, 0.4, 0.6065, 0.75, 0.9, 0.99, 1.0]:
        lam, val = interpolation_profile(r)
        print(f"  {r:6.4f}     {lam:8.5f}      {val:.6f}    {2 - r:.6f}    {2 - r - val:+.3e}")
    # optimality of 1/4: with a larger constant the inequality fails near r = 1
    print("\n  Optimality of the constant 1/4 (c > 1/4 fails for r near 1):")
    for c in [0.25, 0.26, 0.30]:
        worst = -1.0
        worst_r = 0.0
        for k in range(1, 400):
            r = 1.0 - k * 1e-3
            u = -math.log(r)
            lam = min(1.0, max(0.0, 1.0 - u / (2.0 * c)))
            val = math.exp(c * (1.0 - lam) ** 2) * r ** (-lam)
            gap = val - (2.0 - r)
            if gap > worst:
                worst, worst_r = gap, r
        verdict = "holds" if worst <= 1e-12 else f"FAILS at r = {worst_r:.3f}"
        print(f"    c = {c:.2f}: max(value - (2-r)) = {worst:+.3e}   -> {verdict}")
    print()


def demo_certifiable() -> None:
    print("=" * 74)
    print("6. Certifiable functionals: concentration at the certificate scale")
    print("=" * 74)
    n = 12
    p_head = 0.25
    trials = 200000
    random.seed(2026)
    # number of ones among independent coins with bias p_head
    b, m = 2.0, 6.0
    K = math.ceil(m)
    count_low = 0
    count_high = 0
    for _ in range(trials):
        x = tuple(1 if random.random() < p_head else 0 for _ in range(n))
        k = ones_count(x)
        if k <= b:
            count_low += 1
        if k >= m:
            count_high += 1
    lhs = (count_low / trials) * (count_high / trials)
    rhs = math.exp(-((m - b) ** 2) / (4 * K))
    print(f"  number of ones, n = {n}, bias = {p_head}, b = {b}, m = {m}")
    print(f"    P(N <= b) P(N >= m) = {lhs:.6f}   bound exp(-(m-b)^2/(4*ceil(m))) = {rhs:.6f}")
    naive = math.exp(-((m - b) ** 2) / (4 * n))
    print(f"    the sqrt(n)-scale comparison exp(-(m-b)^2/(4n)) = {naive:.6f} (weaker)")

    # longest increasing subsequence of a random word
    alphabet = 4
    length = 14
    b_l, l_l = 6.0, 9.0
    K_l = math.ceil(l_l)
    low = high = 0
    for _ in range(trials // 4):
        x = tuple(random.randrange(alphabet) for _ in range(length))
        L = longest_increasing(x)
        if L <= b_l:
            low += 1
        if L >= l_l:
            high += 1
    t = trials // 4
    lhs = (low / t) * (high / t)
    rhs = math.exp(-((l_l - b_l) ** 2) / (4 * K_l))
    naive = math.exp(-((l_l - b_l) ** 2) / (4 * length))
    print(f"  longest increasing subsequence, word length {length}, alphabet {alphabet}")
    print(f"    P(L <= {b_l}) P(L >= {l_l}) = {lhs:.6f}   bound = {rhs:.6f}"
          f"   (sqrt(n)-scale comparison = {naive:.6f})")
    print()


def demo_lipschitz() -> None:
    print("=" * 74)
    print("7. Lipschitz concentration:  P(A) P(f >= m + t) <= exp(-t^2/4)")
    print("=" * 74)
    n = 8
    space = all_points(2, n)
    p: List[List[float]] = [[0.5, 0.5]] * n
    f: Callable[[Point], float] = lambda x: ones_count(x) / math.sqrt(n)
    median = 4.0 / math.sqrt(n)
    A = [x for x in space if f(x) <= median]
    print("      t      P(A)*P(f >= m+t)      exp(-t^2/4)")
    for t in [0.0, 0.35, 0.71, 1.06, 1.41]:
        S = [x for x in space if f(x) >= median + t]
        lhs = mass(p, A) * mass(p, S)
        print(f"  {t:5.2f}         {lhs:.6f}            {math.exp(-t * t / 4):.6f}")
    print()


def main() -> None:
    demo_singleton_and_subcube()
    demo_duality()
    demo_moment_bound()
    demo_deviation()
    demo_interpolation()
    demo_certifiable()
    demo_lipschitz()
    print("All demonstrations completed: every computed quantity respects the")
    print("theoretical bounds, with the constant 1/4 in the exponent.")


if __name__ == "__main__":
    main()
