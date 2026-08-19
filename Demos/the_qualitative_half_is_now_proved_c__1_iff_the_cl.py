"""
The Price of Universality as a Submodular Set Function
======================================================

Numerical demonstration of the exact "marginal value of a model" formula for
Shtarkov sums, of the resulting submodularity of the price of universality on
libraries of models, and of the (1 - 1/e) guarantee for greedy library design.

Background
----------
For a finite message set X and a class S = {p_1, ..., p_k} of probability
distributions on X, the maximum-likelihood envelope is

    env_S(x) = max_i p_i(x),

the Shtarkov sum is C(S) = sum_x env_S(x), and the *price of universality* is
log2 C(S) bits: the minimax pointwise regret of any code against the best
member of S in hindsight (attained by the normalized maximum likelihood code
q(x) = env_S(x) / C(S)).

The results demonstrated here:

  1. Marginal value formula   C(A + j) - C(A) = sum_x (P_j(x) - env_A(x))^+
  2. Dichotomy                the increment is 0 iff P_j <= env_A pointwise
  3. Mixtures are free        convex combinations of members cost nothing
  4. Submodularity            C(A u B) + C(A n B) <= C(A) + C(B)
  5. Multiplicative form      C(A u B) * C(A n B) <= C(A) * C(B)
  6. Bit-level submodularity  log2 C is submodular when C(A n B) > 0,
                              and fails for disjoint point-mass libraries
  7. Two-model identity       C({p, q}) = 1 + TV(p, q)
  8. Greedy guarantee         C(greedy_n) >= (1 - 1/e) * C(best library of size n)

Everything is self-contained: only the Python standard library is used.

Run with:  python demo.py
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import combinations, chain
from typing import Iterable, List, Sequence, Tuple

Number = float
Vector = Sequence[float]

# --------------------------------------------------------------------------- #
#  Core functional
# --------------------------------------------------------------------------- #


def envelope(pool: Sequence[Vector], library: Iterable[int]) -> List[float]:
    """Pointwise maximum-likelihood envelope of a library, with env(empty) = 0."""
    idx = list(library)
    if not idx:
        return [0.0] * len(pool[0])
    n = len(pool[0])
    return [max(pool[i][x] for i in idx) for x in range(n)]


def shtarkov(pool: Sequence[Vector], library: Iterable[int]) -> float:
    """Library price factor C(A) = sum_x env_A(x) (the Shtarkov sum of A)."""
    return float(sum(envelope(pool, library)))


def price_bits(pool: Sequence[Vector], library: Iterable[int]) -> float:
    """Price of universality of a library in bits, log2 C(A)."""
    c = shtarkov(pool, library)
    return math.log2(c) if c > 0 else float("-inf")


def marginal_value(pool: Sequence[Vector], library: Iterable[int], j: int) -> float:
    """Closed-form marginal value sum_x (P_j(x) - env_A(x))^+ of inserting j."""
    env = envelope(pool, library)
    return float(sum(max(pool[j][x] - env[x], 0.0) for x in range(len(env))))


def total_variation(p: Vector, q: Vector) -> float:
    """Total variation distance (1/2) * sum_x |p(x) - q(x)|."""
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


# --------------------------------------------------------------------------- #
#  Greedy and exhaustive library design
# --------------------------------------------------------------------------- #


def greedy_library(pool: Sequence[Vector], budget: int) -> Tuple[List[int], float]:
    """Greedy maximisation of C: repeatedly insert the model of largest marginal
    value.  Cost O(budget * |pool| * |X|).  Returns (library, C(library))."""
    chosen: List[int] = []
    for _ in range(budget):
        best_j, best_gain = None, 0.0
        for j in range(len(pool)):
            if j in chosen:
                continue
            gain = marginal_value(pool, chosen, j)
            if gain > best_gain + 1e-15:
                best_j, best_gain = j, gain
        if best_j is None:
            break
        chosen.append(best_j)
    return chosen, shtarkov(pool, chosen)


def optimal_library(pool: Sequence[Vector], budget: int) -> Tuple[List[int], float]:
    """Exhaustive search over all libraries of size <= budget (small pools only)."""
    best_set: List[int] = []
    best_val = 0.0
    for size in range(1, budget + 1):
        for combo in combinations(range(len(pool)), size):
            val = shtarkov(pool, combo)
            if val > best_val:
                best_set, best_val = list(combo), val
    return best_set, best_val


def all_subsets(m: int) -> Iterable[Tuple[int, ...]]:
    return chain.from_iterable(combinations(range(m), r) for r in range(m + 1))


# --------------------------------------------------------------------------- #
#  Example pools
# --------------------------------------------------------------------------- #

#  The worked four-model pool on a three-letter alphabet.
POOL_EXACT: List[List[Fraction]] = [
    [Fraction(1, 2), Fraction(1, 4), Fraction(1, 4)],   # P0: skewed to a0
    [Fraction(1, 4), Fraction(1, 2), Fraction(1, 4)],   # P1: skewed to a1
    [Fraction(1, 3), Fraction(1, 3), Fraction(1, 3)],   # P2: uniform
    [Fraction(0, 1), Fraction(0, 1), Fraction(1, 1)],   # P3: point mass on a2
]
POOL = [[float(v) for v in row] for row in POOL_EXACT]
NAMES = ["P0 (skew a0)", "P1 (skew a1)", "P2 (uniform)", "P3 (point mass a2)"]


def random_pool(m: int, n: int, rng: random.Random) -> List[List[float]]:
    """m random probability vectors on an n-letter alphabet (Dirichlet-ish)."""
    pool = []
    for _ in range(m):
        raw = [rng.expovariate(1.0) for _ in range(n)]
        s = sum(raw)
        pool.append([v / s for v in raw])
    return pool


# --------------------------------------------------------------------------- #
#  Demonstrations
# --------------------------------------------------------------------------- #


def banner(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_exact_prices() -> None:
    banner("1.  Exact prices of small libraries in the worked pool")
    print("alphabet {a0, a1, a2}; pool:")
    for name, row in zip(NAMES, POOL_EXACT):
        print(f"    {name:22s} ({row[0]}, {row[1]}, {row[2]})")
    print()

    def exact_C(lib: Sequence[int]) -> Fraction:
        return sum(
            (max(POOL_EXACT[i][x] for i in lib) for x in range(3)), Fraction(0)
        )

    for lib in [(0,), (1,), (0, 1), (0, 3), (0, 1, 2), (0, 1, 3), (0, 1, 2, 3)]:
        c = exact_C(lib)
        print(
            f"    C({set(lib)!s:14s}) = {str(c):6s} = {float(c):.4f}"
            f"    price = {math.log2(float(c)):.4f} bits"
        )
    print("\n    Note C({0,1,2}) = 4/3 < 7/4 = C({0,3}):")
    print("    the *uniform* model is nearly worthless next to P0 and P1,")
    print("    while the eccentric point mass P3 is worth 3/4 on its own.")


def demo_marginal_formula() -> None:
    banner("2.  The marginal value formula, checked on every (library, model)")
    worst = 0.0
    for lib in all_subsets(len(POOL)):
        for j in range(len(POOL)):
            if j in lib:
                continue
            direct = shtarkov(POOL, tuple(sorted(set(lib) | {j}))) - shtarkov(POOL, lib)
            formula = marginal_value(POOL, lib, j)
            worst = max(worst, abs(direct - formula))
    print(f"    all {2**len(POOL)} libraries x 4 models checked")
    print(f"    max |C(A+j) - C(A)  -  sum_x (P_j - env_A)^+|  =  {worst:.2e}")

    print("\n    marginal values on top of the library {P0}:")
    for j in range(4):
        g = marginal_value(POOL, [0], j)
        verdict = "free (dominated)" if g == 0 else "pays its way"
        print(f"        {NAMES[j]:22s} gain = {g:.4f}   {verdict}")


def demo_mixtures_are_free() -> None:
    banner("3.  Mixtures of library members are free")
    lib = [0, 1]
    env = envelope(POOL, lib)
    rng = random.Random(7)
    print("    library {P0, P1}, envelope =", [f"{v:.4f}" for v in env])
    for trial in range(4):
        w = rng.random()
        mix = [w * POOL[0][x] + (1 - w) * POOL[1][x] for x in range(3)]
        gain = sum(max(mix[x] - env[x], 0.0) for x in range(3))
        print(f"        mixture with w = {w:.3f}: marginal value = {gain:.2e}")
    print("    every convex combination lies under the envelope, so it costs nothing:")
    print("    the price of universality sees only the extreme points of a library.")


def demo_two_model_identity() -> None:
    banner("4.  Two-model libraries:  C({p,q}) = 1 + TV(p,q)")
    for i, j in combinations(range(4), 2):
        c = shtarkov(POOL, [i, j])
        tv = total_variation(POOL[i], POOL[j])
        print(
            f"    {NAMES[i]:22s} vs {NAMES[j]:22s}"
            f"   C = {c:.4f}   1 + TV = {1 + tv:.4f}"
        )


def demo_submodularity() -> None:
    banner("5.  Submodularity, additive and multiplicative, over all pairs")
    add_slack = math.inf
    mul_slack = math.inf
    for A in all_subsets(len(POOL)):
        for B in all_subsets(len(POOL)):
            sA, sB = set(A), set(B)
            u = shtarkov(POOL, tuple(sorted(sA | sB)))
            i = shtarkov(POOL, tuple(sorted(sA & sB)))
            a, b = shtarkov(POOL, A), shtarkov(POOL, B)
            add_slack = min(add_slack, (a + b) - (u + i))
            mul_slack = min(mul_slack, (a * b) - (u * i))
    print(f"    all {2**len(POOL)}^2 = {4**len(POOL)} pairs of libraries checked")
    print(f"    min slack in  C(AuB) + C(AnB) <= C(A) + C(B) :  {add_slack:+.6f}")
    print(f"    min slack in  C(AuB) * C(AnB) <= C(A) * C(B) :  {mul_slack:+.6f}")

    print("\n    diminishing returns  D(j|B) <= D(j|A)  for A subset B:")
    worst = math.inf
    for A in all_subsets(len(POOL)):
        for B in all_subsets(len(POOL)):
            if not set(A) <= set(B):
                continue
            for j in range(len(POOL)):
                worst = min(
                    worst, marginal_value(POOL, A, j) - marginal_value(POOL, B, j)
                )
    print(f"    min slack over all nested pairs and insertions: {worst:+.6f}")


def demo_bit_submodularity_boundary() -> None:
    banner("6.  Bit-level submodularity and its boundary case")
    print("    with genuine sources and A n B nonempty, log2 C is submodular:")
    shown = 0
    for A in all_subsets(len(POOL)):
        for B in all_subsets(len(POOL)):
            sA, sB = set(A), set(B)
            if not (sA & sB):
                continue
            lhs = price_bits(POOL, tuple(sorted(sA | sB))) + price_bits(
                POOL, tuple(sorted(sA & sB))
            )
            rhs = price_bits(POOL, A) + price_bits(POOL, B)
            assert lhs <= rhs + 1e-12
            if shown < 3 and sA != sB:
                print(
                    f"        A={set(A)!s:12s} B={set(B)!s:12s}"
                    f"  lhs = {lhs:.4f} <= rhs = {rhs:.4f}"
                )
                shown += 1
    print("    ...all such pairs verified.")

    print("\n    the guard C(A n B) > 0 cannot be dropped.  Two point masses:")
    pm = [[1.0, 0.0], [0.0, 1.0]]
    cA, cB = shtarkov(pm, [0]), shtarkov(pm, [1])
    cU, cI = shtarkov(pm, [0, 1]), shtarkov(pm, [])
    print(f"        C({{0}}) = {cA}, C({{1}}) = {cB}, C(union) = {cU}, C(inter) = {cI}")
    print(
        "        bits:  log2 2 + log2 0  <=  log2 1 + log2 1   reads"
        "  1 + (-inf) <= 0"
    )
    print("        true only with the convention log2 0 = -inf; with real numbers")
    print("        (log2 0 treated as 0) the inequality 1 <= 0 is false.")


def demo_greedy_worked_pool() -> None:
    banner("7.  Greedy library design on the worked pool")
    lib: List[int] = []
    for step in range(3):
        gains = {j: marginal_value(POOL, lib, j) for j in range(4) if j not in lib}
        j = max(gains, key=lambda k: gains[k])
        lib.append(j)
        pretty = ", ".join(f"{NAMES[k].split()[0]}:{gains[k]:.4f}" for k in sorted(gains))
        print(f"    step {step + 1}: gains ({pretty})  ->  take {NAMES[j]}")
        print(f"             library {sorted(lib)}   C = {shtarkov(POOL, lib):.4f}")
    opt_set, opt_val = optimal_library(POOL, 3)
    print(f"\n    greedy library of size 3 : {sorted(lib)}  C = {shtarkov(POOL, lib):.4f}")
    print(f"    optimal library of size 3: {opt_set}  C = {opt_val:.4f}")
    print(f"    ratio = {shtarkov(POOL, lib) / opt_val:.4f}   (guarantee 1 - 1/e = 0.6321)")


def demo_greedy_random_pools() -> None:
    banner("8.  Greedy vs optimal on random pools (worst observed ratio)")
    rng = random.Random(2024)
    print("     m    N    n    worst ratio    guarantee   worst bit shortfall")
    for (m, n_alpha, budget) in [(8, 6, 3), (10, 8, 4), (12, 5, 3), (9, 12, 5)]:
        worst_ratio = math.inf
        worst_bits = 0.0
        for _ in range(60):
            pool = random_pool(m, n_alpha, rng)
            _, g = greedy_library(pool, budget)
            _, o = optimal_library(pool, budget)
            worst_ratio = min(worst_ratio, g / o)
            worst_bits = max(worst_bits, math.log2(o) - math.log2(g))
        print(
            f"    {m:2d}   {n_alpha:2d}   {budget:2d}      {worst_ratio:.4f}"
            f"        0.6321          {worst_bits:.4f} bits"
        )
    print("\n    the theory guarantees ratio >= 1 - 1/e = 0.6321, i.e. a shortfall of")
    print("    at most log2(e/(e-1)) = 0.6617 bits; in practice greedy is far better.")


def demo_gap_decay() -> None:
    banner("9.  Geometric decay of the optimality gap:  gap_k <= (1 - 1/n)^k C(B)")
    rng = random.Random(11)
    pool = random_pool(14, 10, rng)
    n = 6
    B, cB = optimal_library(pool, n)
    lib: List[int] = []
    print(f"    target library B (size {len(B)}): C(B) = {cB:.4f}")
    print("     k    C(A_k)      gap        bound (1-1/n)^k C(B)")
    for k in range(n + 1):
        gap = cB - shtarkov(pool, lib)
        bound = (1 - 1 / n) ** k * cB
        print(f"    {k:2d}   {shtarkov(pool, lib):7.4f}   {gap:8.4f}   {bound:8.4f}")
        if k < n:
            gains = {j: marginal_value(pool, lib, j) for j in range(len(pool)) if j not in lib}
            lib.append(max(gains, key=lambda t: gains[t]))
    print(f"\n    final ratio C(A_n)/C(B) = {shtarkov(pool, lib) / cB:.4f} >= 0.6321")


def main() -> None:
    print(__doc__.split("Run with:")[0])
    demo_exact_prices()
    demo_marginal_formula()
    demo_mixtures_are_free()
    demo_two_model_identity()
    demo_submodularity()
    demo_bit_submodularity_boundary()
    demo_greedy_worked_pool()
    demo_greedy_random_pools()
    demo_gap_decay()
    banner("All demonstrations completed.")


if __name__ == "__main__":
    main()
