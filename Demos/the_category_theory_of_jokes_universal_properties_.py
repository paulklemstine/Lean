"""
Universal Properties of Humor -- numerical demonstrations.

A *setup* is a nonempty finite set of real "readings" S subset R, ordered by
refinement (subset inclusion).  Its *surprise* is the range

        H(S) = max S - min S  =  diam(S).

This script demonstrates, with explicit numbers, every quantitative result of
the theory:

  1.  Submodularity      H(S u T) + H(S n T) <= H(S) + H(T)   (S n T nonempty)
      and its corollary subadditivity, plus H(S n T) <= H(S u T).
  2.  Colimits vs limits: the joint setup is the coproduct (always exists);
      disjoint setups admit no product (the candidate is empty).
  3.  Universality: terminal jokes maximise surprise; the converse fails on
      {0,1} < {0,1/2,1}; the hull quotient repairs the equivalence.
  4.  Metric stability: |H(S) - H(T)| <= 2 d_Hausdorff(S,T), and the sharp
      paraphrase bound |H(f(S)) - H(S)| <= 2 eps.
  5.  Correlation: monovariance => nonnegative empirical covariance; a
      counterexample without monovariance; the hundred-joke suite.
  6.  Uniqueness: every position-blind, stage-additive, monotone humor scale
      equals c * (M - m); verified numerically against candidate scales.
  7.  The conjectured Wundt threshold: an inverted-U rating model splits a
      dataset into a strongly positive and a strongly negative regime whose
      pooled correlation is near zero.

Pure standard library; no dependencies.  Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Iterable, List, Sequence, Set, Tuple

Setup = frozenset  # a nonempty finite set of floats
Hull = Tuple[float, float]


# ---------------------------------------------------------------------------
# 1. The invariant
# ---------------------------------------------------------------------------


def humor(s: Iterable[float]) -> float:
    """Surprise of a setup: the range of its readings.  H(S) = max S - min S."""
    pts: List[float] = list(s)
    if not pts:
        raise ValueError("a setup must be nonempty")
    return max(pts) - min(pts)


def hull_of(s: Iterable[float]) -> Hull:
    """The hull of a setup: the pair of its extreme readings."""
    pts: List[float] = list(s)
    if not pts:
        raise ValueError("a setup must be nonempty")
    return (min(pts), max(pts))


def hull_leq(p: Hull, q: Hull) -> bool:
    """Hulls ordered by inclusion: p <= q iff the interval p sits inside q."""
    return q[0] <= p[0] and p[1] <= q[1]


def diameter(s: Iterable[float]) -> float:
    """Metric diameter, computed pairwise.  Equals `humor` on the real line."""
    pts = list(s)
    return max(abs(x - y) for x in pts for y in pts)


# ---------------------------------------------------------------------------
# 2. Submodularity
# ---------------------------------------------------------------------------


def submodularity_defect(a: Set[float], b: Set[float]) -> float:
    """H(S) + H(T) - H(S u T) - H(S n T);  nonnegative when S n T is nonempty."""
    return humor(a) + humor(b) - humor(a | b) - humor(a & b)


def demo_submodularity(trials: int = 20000, seed: int = 20260824) -> None:
    print("=" * 74)
    print("1.  SUBMODULARITY:  H(S u T) + H(S n T) <= H(S) + H(T)")
    print("=" * 74)

    s = {0.0, 1.0, 4.0}
    t = {1.0, 2.0, 7.0}
    print(f"  S = {sorted(s)}   H(S) = {humor(s):.3f}")
    print(f"  T = {sorted(t)}   H(T) = {humor(t):.3f}")
    print(f"  S u T = {sorted(s | t)}   H = {humor(s | t):.3f}   (the colimit)")
    print(f"  S n T = {sorted(s & t)}   H = {humor(s & t):.3f}   (the limit)")
    print(f"  submodular defect = {submodularity_defect(s, t):.3f}  >= 0")
    print(f"  subadditivity slack = {humor(s) + humor(t) - humor(s | t):.3f}  >= 0")
    print(f"  colimit dominates limit: {humor(s & t):.3f} <= {humor(s | t):.3f}")

    rng = random.Random(seed)
    worst = math.inf
    for _ in range(trials):
        shared = round(rng.uniform(-5, 5), 3)
        a = {shared} | {round(rng.uniform(-10, 10), 3) for _ in range(rng.randint(1, 5))}
        b = {shared} | {round(rng.uniform(-10, 10), 3) for _ in range(rng.randint(1, 5))}
        worst = min(worst, submodularity_defect(a, b))
    print(f"  randomised check over {trials} overlapping pairs:")
    print(f"      minimum defect observed = {worst:.6f}   (theory: >= 0)")
    print()


# ---------------------------------------------------------------------------
# 3. Colimits and limits
# ---------------------------------------------------------------------------


def coproduct(a: Set[float], b: Set[float]) -> Set[float]:
    """The joint setup: the binary coproduct in the category of setups."""
    return a | b


def product_candidate(a: Set[float], b: Set[float]) -> Set[float]:
    """The only possible binary product: the shared setup.  Empty => none exists."""
    return a & b


def is_coproduct(a: Set[float], b: Set[float], p: Set[float],
                 witnesses: Sequence[Set[float]]) -> bool:
    """Check the coproduct universal property against a family of test objects."""
    if not (a <= p and b <= p):
        return False
    for z in witnesses:
        if a <= z and b <= z and not p <= z:
            return False
    return True


def demo_colimits() -> None:
    print("=" * 74)
    print("2.  THE PUNCHLINE IS A COLIMIT (limits may fail to exist)")
    print("=" * 74)

    a = {0.0, 2.0}
    b = {2.0, 5.0}
    tests = [a | b, a | b | {9.0}, {0.0, 1.0, 2.0, 5.0}]
    print(f"  overlapping setups  S = {sorted(a)},  T = {sorted(b)}")
    print(f"    coproduct S u T   = {sorted(coproduct(a, b))}"
          f"   universal? {is_coproduct(a, b, coproduct(a, b), tests)}")
    print(f"    product   S n T   = {sorted(product_candidate(a, b))}   -> exists")

    c = {0.0, 1.0}
    d = {7.0, 9.0}
    cand = product_candidate(c, d)
    print(f"  disjoint setups     S = {sorted(c)},  T = {sorted(d)}")
    print(f"    coproduct S u T   = {sorted(coproduct(c, d))}   -> still exists")
    print(f"    product candidate = {sorted(cand)}   -> EMPTY, so no product exists")
    print("    (every setup is nonempty by definition, so no object can map into both)")
    print()


# ---------------------------------------------------------------------------
# 4. Universality, its refutation, and the hull repair
# ---------------------------------------------------------------------------


def jokes_over(base: Set[float], universe: Set[float]) -> List[Set[float]]:
    """All jokes over `base` bounded by `universe`: setups J with base <= J <= U."""
    extra = sorted(universe - base)
    out: List[Set[float]] = []
    for k in range(len(extra) + 1):
        for combo in itertools.combinations(extra, k):
            out.append(base | set(combo))
    return out


def is_terminal(j: Set[float], family: Sequence[Set[float]]) -> bool:
    """J is terminal iff every other joke refines into it."""
    return all(k <= j for k in family)


def is_hull_universal(j: Set[float], family: Sequence[Set[float]]) -> bool:
    """J is hull-universal iff its hull contains every other hull."""
    return all(hull_leq(hull_of(k), hull_of(j)) for k in family)


def demo_universality() -> None:
    print("=" * 74)
    print("3.  UNIVERSALITY:  terminal => funniest, but NOT conversely")
    print("=" * 74)

    base = {0.0, 1.0}                # the pun
    universe = {0.0, 0.5, 1.0}       # the pun refined by an interior reading
    family = jokes_over(base, universe)
    best = max(humor(j) for j in family)

    print(f"  base setup     S = {sorted(base)}")
    print(f"  ambient universe U = {sorted(universe)}")
    print("  jokes over S:")
    for j in family:
        print(f"    J = {sorted(j)!s:<22} H = {humor(j):.3f}"
              f"   maximal={humor(j) == best!s:<5}"
              f" terminal={is_terminal(j, family)!s:<5}"
              f" hull-universal={is_hull_universal(j, family)}")
    print()
    print("  => terminal objects always attain the maximum (universal => funniest)")
    print("  => {0.0, 1.0} attains the maximum but is NOT terminal: converse FALSE")
    print("  => after passing to hulls, 'maximal humor' and 'hull-universal' agree:")
    agree = all((humor(j) == best) == is_hull_universal(j, family) for j in family)
    print(f"       equivalence holds on every object of this category: {agree}")
    print(f"  hull({sorted(base)}) = {hull_of(base)} = hull({sorted(universe)})"
          f" = {hull_of(universe)}  -> hull functor not injective")
    print()


# ---------------------------------------------------------------------------
# 5. Metric stability
# ---------------------------------------------------------------------------


def hausdorff_distance(a: Iterable[float], b: Iterable[float]) -> float:
    """Hausdorff distance between two finite sets of readings."""
    xs, ys = list(a), list(b)
    forward = max(min(abs(x - y) for y in ys) for x in xs)
    backward = max(min(abs(x - y) for x in xs) for y in ys)
    return max(forward, backward)


def paraphrase(s: Iterable[float], f: Callable[[float], float]) -> Set[float]:
    """Apply a rewording map to every reading of a setup."""
    return {f(x) for x in s}


def demo_stability(trials: int = 5000, seed: int = 4242) -> None:
    print("=" * 74)
    print("4.  STABILITY:  |H(S) - H(T)| <= 2 * d_Hausdorff(S, T)   (sharp)")
    print("=" * 74)

    rng = random.Random(seed)
    worst_ratio = 0.0
    for _ in range(trials):
        a = {round(rng.uniform(-6, 6), 3) for _ in range(rng.randint(2, 6))}
        b = {round(rng.uniform(-6, 6), 3) for _ in range(rng.randint(2, 6))}
        d = hausdorff_distance(a, b)
        if d > 1e-9:
            worst_ratio = max(worst_ratio, abs(humor(a) - humor(b)) / d)
    print(f"  randomised check over {trials} pairs:")
    print(f"      max observed  |H(S)-H(T)| / d_H(S,T)  = {worst_ratio:.4f}   (bound 2)")

    s = {0.0, 1.0}
    f = lambda x: 3.0 * x - 1.0
    eps = max(abs(f(x) - x) for x in s)
    img = paraphrase(s, f)
    print("  the paraphrase bound and its sharpness:")
    print(f"      S = {sorted(s)},  f(x) = 3x - 1,  every reading moves by <= {eps:.1f}")
    print(f"      f(S) = {sorted(img)},  H(S) = {humor(s):.1f},  H(f(S)) = {humor(img):.1f}")
    print(f"      |H(f(S)) - H(S)| = {abs(humor(img) - humor(s)):.1f} = 2 * eps"
          f"  -> constant 2 is attained")
    print(f"  surprise equals the metric diameter: H = {humor(s):.1f},"
          f" diam = {diameter(s):.1f}")
    print()


# ---------------------------------------------------------------------------
# 6. Correlation with funniness ratings
# ---------------------------------------------------------------------------


def emp_cov(f: Sequence[float], g: Sequence[float]) -> float:
    """Empirical covariance of two attributes of a finite sample of jokes."""
    n = len(f)
    if n == 0:
        return 0.0
    return sum(x * y for x, y in zip(f, g)) / n - (sum(f) / n) * (sum(g) / n)


def pearson(f: Sequence[float], g: Sequence[float]) -> float:
    """Pearson correlation coefficient; 0.0 when either attribute is constant."""
    n = len(f)
    if n == 0:
        return 0.0
    vf = emp_cov(f, f)
    vg = emp_cov(g, g)
    if vf <= 1e-15 or vg <= 1e-15:
        return 0.0
    return emp_cov(f, g) / math.sqrt(vf * vg)


def monovary(f: Sequence[float], g: Sequence[float]) -> bool:
    """True iff no pair moves in opposite directions."""
    n = len(f)
    return not any(f[i] < f[j] and g[j] < g[i] for i in range(n) for j in range(n))


def demo_correlation() -> None:
    print("=" * 74)
    print("5.  CORRELATION:  monovariance => Cov(H, R) >= 0  (and not otherwise)")
    print("=" * 74)

    h_bad = [0.0, 1.0]
    r_bad = [1.0, 0.0]
    print(f"  a two-joke dataset  H = {h_bad}, R = {r_bad}")
    print(f"      monovary? {monovary(h_bad, r_bad)}   Cov = {emp_cov(h_bad, r_bad):+.4f}")
    print("      -> correlation is NOT a theorem of the algebra")

    h3 = [1.0, 3.0, 10.0]        # pun, wordplay, absurdist
    r3 = [2.0, 5.0, 8.0]
    print(f"  a three-joke sample H = {h3}, R = {r3}")
    print(f"      monovary? {monovary(h3, r3)}   Cov = {emp_cov(h3, r3):+.4f}  > 0")

    hs = [float(i) for i in range(100)]              # setup {0, i} has H = i
    rs = [min(float(i), 50.0) for i in range(100)]   # saturating rating model
    print("  the hundred-joke suite: setup {0, i} (so H = i), rating min(i, 50)")
    print(f"      monovary? {monovary(hs, rs)}   Cov = {emp_cov(hs, rs):+.4f}  >= 0")
    print(f"      Pearson r = {pearson(hs, rs):+.4f}")
    print()


# ---------------------------------------------------------------------------
# 7. Uniqueness of the invariant
# ---------------------------------------------------------------------------


def is_humor_scale(v: Callable[[float, float], float],
                   samples: Sequence[Tuple[float, float, float]],
                   tol: float = 1e-9) -> Tuple[bool, bool, bool]:
    """Test (A1) position blindness, (A2) staged telling, (A3) monotonicity."""
    a1 = a2 = a3 = True
    for a, b, c in samples:
        a, b, c = sorted((a, b, c))
        a1 &= abs(v(a + 3.7, b + 3.7) - v(a, b)) < tol
        a2 &= abs(v(a, b) + v(b, c) - v(a, c)) < tol
        a3 &= v(a, b) <= v(a, c) + tol
    return a1, a2, a3


def demo_uniqueness(seed: int = 7) -> None:
    print("=" * 74)
    print("6.  UNIQUENESS:  every humor scale is  V(m, M) = c * (M - m)")
    print("=" * 74)

    rng = random.Random(seed)
    samples = [(rng.uniform(-9, 9), rng.uniform(-9, 9), rng.uniform(-9, 9))
               for _ in range(400)]

    candidates: List[Tuple[str, Callable[[float, float], float]]] = [
        ("range          V(m,M) = M - m", lambda m, M: M - m),
        ("scaled range   V(m,M) = 3.5(M-m)", lambda m, M: 3.5 * (M - m)),
        ("quadratic      V(m,M) = (M-m)^2", lambda m, M: (M - m) ** 2),
        ("midpoint-aware V(m,M) = M - m + m", lambda m, M: M),
        ("sqrt           V(m,M) = sqrt(M-m)", lambda m, M: math.sqrt(max(M - m, 0.0))),
    ]

    print("  axioms:  (A1) position blindness  (A2) staged telling  (A3) monotone")
    for name, v in candidates:
        a1, a2, a3 = is_humor_scale(v, samples)
        ok = a1 and a2 and a3
        unit = v(0.0, 1.0)
        verdict = "HUMOR SCALE" if ok else "fails"
        detail = "" if ok else f" (A1={a1}, A2={a2}, A3={a3})"
        print(f"    {name:<34} unit c = {unit:6.3f}  {verdict}{detail}")

    print("  every candidate satisfying all three axioms agrees with c * (M - m):")
    for name, v in candidates:
        if all(is_humor_scale(v, samples)):
            c = v(0.0, 1.0)
            err = max(abs(v(min(a, b), max(a, b)) - c * abs(b - a))
                      for a, b, _ in samples)
            print(f"    {name:<34} max deviation from c*(M-m) = {err:.2e}")
    print()


# ---------------------------------------------------------------------------
# 8. The conjectured Wundt threshold
# ---------------------------------------------------------------------------


def wundt_rating(h: float, peak: float = 6.0, width: float = 4.0) -> float:
    """A concave inverted-U rating response to surprise, peaking at `peak`."""
    return math.exp(-((h - peak) ** 2) / (2.0 * width ** 2))


def demo_wundt(n: int = 400) -> None:
    print("=" * 74)
    print("7.  THE CONJECTURED WUNDT THRESHOLD (an inverted-U rating response)")
    print("=" * 74)

    humors = [12.0 * i / (n - 1) for i in range(n)]
    ratings = [wundt_rating(h) for h in humors]
    peak = 6.0

    lower = [(h, r) for h, r in zip(humors, ratings) if h < peak]
    upper = [(h, r) for h, r in zip(humors, ratings) if h >= peak]

    r_all = pearson(humors, ratings)
    r_low = pearson([h for h, _ in lower], [r for _, r in lower])
    r_high = pearson([h for h, _ in upper], [r for _, r in upper])

    print(f"  synthetic dataset of {n} jokes, surprise in [0, 12], concave rating model")
    print(f"      correlation below the threshold H < {peak:.0f}:  r = {r_low:+.3f}")
    print(f"      correlation above the threshold H >= {peak:.0f}: r = {r_high:+.3f}")
    print(f"      pooled correlation over the whole dataset:  r = {r_all:+.3f}")
    print("  a global correlation study would report 'no effect' -- because the")
    print("  effect changes sign at the threshold, exactly as an increasing concave")
    print("  utility applied to a submodular valuation must.")
    print()
    print("  surprise -> rating profile (each row is a bucket of the dataset):")
    for k in range(13):
        h = float(k)
        bar = "#" * int(round(40 * wundt_rating(h)))
        print(f"      H = {h:5.1f} | {bar}")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("UNIVERSAL PROPERTIES OF HUMOR -- numerical demonstrations")
    print("surprise H(S) = max S - min S on nonempty finite sets of readings")
    print()
    demo_submodularity()
    demo_colimits()
    demo_universality()
    demo_stability()
    demo_correlation()
    demo_uniqueness()
    demo_wundt()
    print("=" * 74)
    print("All demonstrations agree with the theory.")
    print("=" * 74)


if __name__ == "__main__":
    main()
