"""
Certified Novelty Detection for Theorem Provers — numerical demonstrations.

This self-contained script illustrates the metric core of the novelty
certification system:

  * novelty(C, x) = min_{c in C} dist(x, c)
  * a novelty certificate at level eps is a proof that eps <= novelty(C, x), eps > 0
  * soundness:       novelty(C, x) > 0  =>  x not in C
  * separation:      eps <= novelty(C, x)  =>  eps <= dist(x, c) for all c in C
  * stability:       |novelty(C, x) - novelty(C, y)| <= dist(x, y)  (1-Lipschitz)
  * monotonicity:    C subset of D  =>  novelty(D, x) <= novelty(C, x)
  * insert update:   novelty(C + {a}, x) = min(dist(x, a), novelty(C, x))
  * packing budget:  an eps-separated catalog in a bounded box is finite
  * Fibonacci stream: an unbounded 1-separated catalog from primitive primes

No third-party dependencies are required.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# Core metric machinery
# ----------------------------------------------------------------------------

Point = Sequence[float]
Metric = Callable[[Point, Point], float]


def euclidean(x: Point, y: Point) -> float:
    """Standard Euclidean distance on R^d (a genuine metric)."""
    return math.sqrt(sum((a - b) ** 2 for a, b in zip(x, y)))


def novelty(catalog: Sequence[Point], x: Point, dist: Metric = euclidean) -> float:
    """Novelty of x = minimum distance to a nonempty catalog C."""
    if not catalog:
        raise ValueError("novelty is undefined for an empty catalog")
    return min(dist(x, c) for c in catalog)


def nearest(catalog: Sequence[Point], x: Point, dist: Metric = euclidean) -> Point:
    """The catalog entry realizing the novelty (exists_eq_novelty)."""
    if not catalog:
        raise ValueError("nearest is undefined for an empty catalog")
    return min(catalog, key=lambda c: dist(x, c))


def is_certified(catalog: Sequence[Point], x: Point, eps: float,
                 dist: Metric = euclidean) -> bool:
    """A novelty certificate at level eps holds iff eps > 0 and eps <= novelty."""
    return eps > 0.0 and eps <= novelty(catalog, x, dist)


def verify_separation(catalog: Sequence[Point], x: Point, eps: float,
                      dist: Metric = euclidean) -> bool:
    """Separation: eps <= dist(x, c) for EVERY catalog entry c (cert_separation)."""
    return all(eps <= dist(x, c) for c in catalog)


# ----------------------------------------------------------------------------
# Demo 1 — soundness and separation
# ----------------------------------------------------------------------------

def demo_soundness_and_separation() -> None:
    print("=" * 70)
    print("DEMO 1 — Soundness (no false novelty) and separation")
    print("=" * 70)
    catalog: List[Point] = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (3.0, 4.0)]

    # A point already in the catalog has novelty 0 -> never certified novel.
    known = (1.0, 0.0)
    print(f"novelty of known point {known} = {novelty(catalog, known):.4f}")
    print(f"  certified novel at eps=0.5? {is_certified(catalog, known, 0.5)}  (soundness: must be False)")

    # A genuinely distant point.
    cand = (5.0, 5.0)
    nov = novelty(catalog, cand)
    print(f"novelty of candidate {cand} = {nov:.4f}; nearest = {nearest(catalog, cand)}")
    eps = 1.0
    print(f"  certified novel at eps={eps}? {is_certified(catalog, cand, eps)}")
    print(f"  separation holds at eps={eps}? {verify_separation(catalog, cand, eps)}")
    print()


# ----------------------------------------------------------------------------
# Demo 2 — 1-Lipschitz stability under embedding error
# ----------------------------------------------------------------------------

def demo_stability() -> None:
    print("=" * 70)
    print("DEMO 2 — 1-Lipschitz stability: bounded embedding error is safe")
    print("=" * 70)
    catalog: List[Point] = [(0.0, 0.0), (2.0, 2.0), (5.0, 1.0)]
    x: Point = (3.0, 4.0)

    # Perturb the embedding by up to delta and confirm novelty never moves more.
    perturbations = [(0.1, -0.05), (-0.2, 0.15), (0.3, 0.25)]
    base = novelty(catalog, x)
    print(f"true novelty(x) = {base:.4f}")
    for p in perturbations:
        y = (x[0] + p[0], x[1] + p[1])
        delta = euclidean(x, y)
        change = abs(novelty(catalog, x) - novelty(catalog, y))
        ok = change <= delta + 1e-12
        print(f"  ||error||={delta:.4f}  |dnovelty|={change:.4f}  "
              f"<= error? {ok}")

    # Certificate survival: margin eps must exceed worst-case error delta.
    eps, delta = 0.8, 0.5
    print(f"\nCertificate margin eps={eps}, embedding error bound delta={delta}")
    print(f"  guaranteed surviving novelty >= eps - delta = {eps - delta:.4f} > 0? "
          f"{eps - delta > 0}")
    print()


# ----------------------------------------------------------------------------
# Demo 3 — monotonicity and the incremental insert update
# ----------------------------------------------------------------------------

def demo_monotonicity_and_insert() -> None:
    print("=" * 70)
    print("DEMO 3 — Monotonicity and the O(1) incremental update law")
    print("=" * 70)
    x: Point = (4.0, 4.0)
    C: List[Point] = [(0.0, 0.0), (1.0, 1.0)]
    print(f"novelty over C        = {novelty(C, x):.4f}")

    a: Point = (3.5, 3.5)  # a new theorem close to x
    D = C + [a]
    direct = novelty(D, x)
    incremental = min(euclidean(x, a), novelty(C, x))  # novelty_insert
    print(f"novelty over C + {{a}}  = {direct:.4f}  (direct)")
    print(f"insert update law      = {incremental:.4f}  (min(dist(x,a), novelty(C,x)))")
    print(f"  agree? {math.isclose(direct, incremental)}")
    print(f"  monotone (enlarging lowers novelty)? {direct <= novelty(C, x) + 1e-12}")
    print()


# ----------------------------------------------------------------------------
# Demo 4 — the packing novelty budget in a bounded box
# ----------------------------------------------------------------------------

def packing_budget(side: float, eps: float, dim: int) -> int:
    """Upper bound on an eps-separated catalog in a box of given side (Prop 7.1)."""
    cells_per_axis = max(1, math.ceil(side / (eps / math.sqrt(dim))))
    return cells_per_axis ** dim


def greedy_eps_separated(points: Sequence[Point], eps: float,
                         dist: Metric = euclidean) -> List[Point]:
    """Greedily extract an eps-separated subset (each pair >= eps apart)."""
    chosen: List[Point] = []
    for p in points:
        if all(dist(p, c) >= eps for c in chosen):
            chosen.append(p)
    return chosen


def demo_packing_budget() -> None:
    print("=" * 70)
    print("DEMO 4 — Novelty budget: only finitely many mutually-novel results")
    print("=" * 70)
    side, eps, dim = 10.0, 2.0, 2
    grid: List[Point] = [(i * 0.5, j * 0.5)
                         for i in range(int(side / 0.5) + 1)
                         for j in range(int(side / 0.5) + 1)]
    sep = greedy_eps_separated(grid, eps)
    bound = packing_budget(side, eps, dim)
    print(f"box side={side}, eps={eps}, dim={dim}")
    print(f"  packing upper bound on eps-separated catalog : {bound}")
    print(f"  greedily realized eps-separated catalog size  : {len(sep)}")
    print(f"  within budget? {len(sep) <= bound}")
    print()


# ----------------------------------------------------------------------------
# Demo 5 — unbounded novelty stream from Fibonacci primitive prime divisors
# ----------------------------------------------------------------------------

def primitive_prime_of_fib(p: int, fib_cache: List[int]) -> int:
    """Smallest primitive prime divisor of F_p: a prime dividing F_p but no F_k, k<p."""
    fp = fib_cache[p]
    q = 2
    while q <= fp:
        if fp % q == 0 and all(fib_cache[k] % q != 0 for k in range(1, p)):
            return q
        q += 1
    raise RuntimeError(f"no primitive prime found for F_{p}")


def demo_fibonacci_stream() -> None:
    print("=" * 70)
    print("DEMO 5 — Unbounded, 1-separated novelty stream (Fibonacci primitives)")
    print("=" * 70)
    n_max = 30
    fib = [0, 1] + [0] * (n_max - 1)
    for k in range(2, n_max + 1):
        fib[k] = fib[k - 1] + fib[k - 2]

    def is_prime(m: int) -> bool:
        return m >= 2 and all(m % d for d in range(2, int(m ** 0.5) + 1))

    prime_indices = [p for p in range(3, n_max + 1) if is_prime(p)]
    embeds: List[Tuple[int, int]] = [(p, primitive_prime_of_fib(p, fib))
                                     for p in prime_indices]
    print("prime index p ->  F_p  ->  primitive prime carPrime(p) = carEmbed(p)")
    for p, q in embeds:
        print(f"   p={p:2d}   F_p={fib[p]:8d}   carEmbed(p)={q}")

    values = [float(q) for _, q in embeds]
    catalog: List[Point] = [(v,) for v in values]
    min_gap = min(abs(values[i] - values[j])
                  for i in range(len(values)) for j in range(i + 1, len(values)))
    print(f"\n  all primitive primes distinct? {len(set(values)) == len(values)}")
    print(f"  minimum pairwise gap = {min_gap:.1f}  (>= 1  => 1-separated catalog)")
    # Every member is certified novel at level 1 against the others.
    all_certified = all(
        is_certified([c for j, c in enumerate(catalog) if j != i], catalog[i], 1.0)
        for i in range(len(catalog))
    )
    print(f"  every entry certified novel at eps=1 vs. the rest? {all_certified}")
    print()


# ----------------------------------------------------------------------------

def main() -> None:
    demo_soundness_and_separation()
    demo_stability()
    demo_monotonicity_and_insert()
    demo_packing_budget()
    demo_fibonacci_stream()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
