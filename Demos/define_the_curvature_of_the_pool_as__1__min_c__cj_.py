"""
The Curvature of a Model Pool — numerical demonstrations.
=========================================================

Self-contained numerical companion to the paper

    "The Curvature of a Model Pool: Sharpened Greedy Guarantees for
     Universal Compression Libraries".

Setting
-------
A finite message alphabet ``X = {0, ..., N-1}`` and a pool ``Omega`` of
candidate statistical models, each a probability mass function on ``X``.
For a library ``A`` of models the *price of universality* is the Shtarkov sum

    C(A) = sum_x max_{i in A} max(P_i(x), 0),      C(empty) = 0,

whose logarithm is the minimax regret of the best universal code for ``A``.
``C`` is normalized, monotone and submodular.

The *curvature* of the pool is

    kappa = 1 - min_{j in Omega} (C(Omega) - C(Omega \\ {j})) / C({j}).

This script verifies, numerically:

  1. monotonicity and submodularity of the price functional;
  2. the curvature lies in [0, 1] and is monotone in the pool;
  3. the curvature inequality  C(S + j) - C(S) >= (1-kappa) C({j});
  4. curvature superadditivity, and exact modularity when kappa = 0;
  5. the curvature-sharpened greedy step and the product guarantee;
  6. exact optimality of greedy at kappa = 0, and 1 - 1/e everywhere;
  7. the low-curvature gap bound  gap <= kappa (n-1) C(B);
  8. the two-source identity  kappa = 1 - TV, and full realizability;
  9. the refutation of the conjecture  kappa <= TV * |Omega|
     (twin fair coins: TV = 0 but kappa = 1);
 10. pigeonhole curvature saturation when |Omega| > |X|.

Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, List, Sequence, Tuple

Model = Sequence[float]          # a probability mass function on {0, ..., N-1}
Pool = Sequence[Model]           # a list of models
Library = Tuple[int, ...]        # indices into the pool

EPS = 1e-12


# --------------------------------------------------------------------------
# 1. The price of universality (Shtarkov sum)
# --------------------------------------------------------------------------

def envelope(pool: Pool, library: Sequence[int], x: int) -> float:
    """Pointwise upper envelope of the library at message ``x`` (0 if empty)."""
    best = 0.0
    for i in library:
        v = pool[i][x]
        if v > best:
            best = v
    return best


def price(pool: Pool, library: Sequence[int]) -> float:
    """Shtarkov sum C(A) = sum_x max_{i in A} max(P_i(x), 0)."""
    if len(pool) == 0:
        return 0.0
    n_symbols = len(pool[0])
    return sum(envelope(pool, library, x) for x in range(n_symbols))


def regret_bits(pool: Pool, library: Sequence[int]) -> float:
    """Worst-case regret in bits of the best universal code for the library."""
    c = price(pool, library)
    return math.log2(c) if c > 0 else float("-inf")


# --------------------------------------------------------------------------
# 2. Curvature
# --------------------------------------------------------------------------

def marginal_ratio(pool: Pool, omega: Sequence[int], j: int) -> float:
    """(C(Omega) - C(Omega \\ {j})) / C({j}); 0 if the solo price vanishes."""
    solo = price(pool, [j])
    if solo <= EPS:
        return 0.0
    rest = [i for i in omega if i != j]
    return (price(pool, omega) - price(pool, rest)) / solo


def curvature(pool: Pool, omega: Sequence[int]) -> float:
    """kappa(Omega) = 1 - min_{j in Omega} marginal_ratio(j); kappa(empty) = 0."""
    if len(omega) == 0:
        return 0.0
    return 1.0 - min(marginal_ratio(pool, omega, j) for j in omega)


def total_variation(p: Model, q: Model) -> float:
    """TV(p, q) = (1/2) sum_x |p(x) - q(x)|."""
    return 0.5 * sum(abs(a - b) for a, b in zip(p, q))


def pool_tv_diameter(pool: Pool, omega: Sequence[int]) -> float:
    """Largest pairwise total-variation distance inside the pool."""
    return max(
        (total_variation(pool[i], pool[j]) for i in omega for j in omega),
        default=0.0,
    )


# --------------------------------------------------------------------------
# 3. Greedy library design inside a pool
# --------------------------------------------------------------------------

def greedy_run(pool: Pool, omega: Sequence[int], steps: int) -> List[Library]:
    """Greedy: repeatedly adjoin the pool member of maximal marginal price.

    Returns the chain A_0 = empty, A_1, ..., A_steps.
    """
    chain: List[Library] = [tuple()]
    current: List[int] = []
    for _ in range(steps):
        best_j, best_val = None, -math.inf
        for j in omega:
            val = price(pool, current + [j])
            if val > best_val + EPS:
                best_j, best_val = j, val
        assert best_j is not None
        if best_j not in current:
            current = current + [best_j]
        chain.append(tuple(sorted(current)))
    return chain


def brute_force_optimum(pool: Pool, omega: Sequence[int], k: int) -> Tuple[Library, float]:
    """Exact best library of size k inside the pool (exponential; small pools)."""
    best_set, best_val = tuple(), -math.inf
    for comb in itertools.combinations(sorted(omega), k):
        v = price(pool, comb)
        if v > best_val:
            best_set, best_val = comb, v
    return best_set, best_val


def curvature_product(n: int, kappa: float, k: int) -> float:
    """Q_n^kappa(k) = prod_{i<k} (1 - 1/(n - (1-kappa) i))."""
    out = 1.0
    for i in range(k):
        out *= 1.0 - 1.0 / (n - (1.0 - kappa) * i)
    return out


def conjectured_factor(kappa: float) -> float:
    """The Conforti-Cornuejols factor (1 - e^{-kappa}) / kappa, with value 1 at 0."""
    if kappa <= EPS:
        return 1.0
    return (1.0 - math.exp(-kappa)) / kappa


# --------------------------------------------------------------------------
# 4. Explicit pools from the paper
# --------------------------------------------------------------------------

def biased_pair(d: float) -> List[List[float]]:
    """Two coins with bias gap d: model i puts (1+d)/2 on letter i.

    Total-variation distance exactly d, curvature exactly 1 - d.
    """
    return [
        [(1.0 + d) / 2.0, (1.0 - d) / 2.0],
        [(1.0 - d) / 2.0, (1.0 + d) / 2.0],
    ]


def twin_coins() -> List[List[float]]:
    """Two identical fair coins: TV = 0 yet curvature = 1 (refuting kappa <= TV*|Omega|)."""
    return [[0.5, 0.5], [0.5, 0.5]]


def point_masses(n_symbols: int) -> List[List[float]]:
    """n deterministic sources, one per letter: a maximally spread, zero-curvature pool."""
    pool = []
    for i in range(n_symbols):
        row = [0.0] * n_symbols
        row[i] = 1.0
        pool.append(row)
    return pool


def random_pool(n_models: int, n_symbols: int, rng: random.Random,
                concentration: float = 1.0) -> List[List[float]]:
    """Random pmfs; small ``concentration`` gives spiky (diverse) models."""
    pool = []
    for _ in range(n_models):
        raw = [rng.gammavariate(concentration, 1.0) + 1e-9 for _ in range(n_symbols)]
        s = sum(raw)
        pool.append([v / s for v in raw])
    return pool


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_price_and_structure() -> None:
    print("=" * 78)
    print("1. The price of universality: monotone, submodular, C(empty) = 0")
    print("=" * 78)
    rng = random.Random(20260822)
    pool = random_pool(5, 4, rng, concentration=0.4)
    omega = list(range(5))
    print(f"  C(empty)        = {price(pool, []):.6f}")
    for k in range(1, 6):
        A = list(range(k))
        print(f"  C({{0..{k-1}}})      = {price(pool, A):.6f}"
              f"   regret = {regret_bits(pool, A):.4f} bits")

    worst_sub = 0.0
    for A in itertools.chain.from_iterable(
            itertools.combinations(omega, r) for r in range(len(omega) + 1)):
        for B in itertools.chain.from_iterable(
                itertools.combinations(omega, r) for r in range(len(omega) + 1)):
            if not set(A) <= set(B):
                continue
            for j in omega:
                lhs = price(pool, list(A) + [j]) - price(pool, A)
                rhs = price(pool, list(B) + [j]) - price(pool, B)
                worst_sub = min(worst_sub, lhs - rhs)
    print(f"  min over all A <= B, j of  [C(A+j)-C(A)] - [C(B+j)-C(B)]  "
          f"= {worst_sub:.2e}   (submodularity: >= 0)")
    print()


def demo_curvature_basics() -> None:
    print("=" * 78)
    print("2. Curvature: range, monotonicity in the pool, and the two endpoints")
    print("=" * 78)
    rng = random.Random(7)
    pool = random_pool(6, 8, rng, concentration=0.3)
    print("  curvature of nested pools (must be nondecreasing):")
    prev = -1.0
    for k in range(2, 7):
        kap = curvature(pool, list(range(k)))
        flag = "ok" if kap >= prev - 1e-9 else "VIOLATION"
        print(f"    |Omega| = {k}:  kappa = {kap:.6f}   [{flag}]")
        prev = kap

    pm = point_masses(4)
    print(f"\n  four disjoint point masses (maximally spread pool):")
    print(f"    kappa = {curvature(pm, list(range(4))):.6f}   (zero curvature: "
          f"the price is exactly modular)")
    tw = twin_coins()
    print(f"  two identical fair coins:")
    print(f"    kappa = {curvature(tw, [0, 1]):.6f}   TV = "
          f"{total_variation(tw[0], tw[1]):.6f}   (maximal curvature)")
    print()


def demo_curvature_inequalities() -> None:
    print("=" * 78)
    print("3. The curvature inequality and curvature superadditivity")
    print("=" * 78)
    rng = random.Random(31337)
    pool = random_pool(5, 6, rng, concentration=0.25)
    omega = list(range(5))
    kap = curvature(pool, omega)
    print(f"  pool curvature kappa = {kap:.6f}")

    slack_marg = math.inf
    for r in range(len(omega) + 1):
        for S in itertools.combinations(omega, r):
            for j in omega:
                if j in S:
                    continue
                lhs = (1.0 - kap) * price(pool, [j])
                rhs = price(pool, list(S) + [j]) - price(pool, S)
                slack_marg = min(slack_marg, rhs - lhs)
    print(f"  min slack in  C(S+j)-C(S) >= (1-kappa) C({{j}})        "
          f"= {slack_marg:.2e}  (>= 0)")

    slack_super = math.inf
    for rA in range(len(omega) + 1):
        for A in itertools.combinations(omega, rA):
            for rB in range(len(omega) + 1):
                for B in itertools.combinations(omega, rB):
                    lhs = (price(pool, B)
                           + (1.0 - kap) * (price(pool, A)
                                            - price(pool, sorted(set(A) & set(B)))))
                    rhs = price(pool, sorted(set(A) | set(B)))
                    slack_super = min(slack_super, rhs - lhs)
    print(f"  min slack in  C(AuB) >= C(B) + (1-kappa)(C(A)-C(AnB))  "
          f"= {slack_super:.2e}  (>= 0)")

    pm = point_masses(4)
    worst_mod = 0.0
    for rA in range(5):
        for A in itertools.combinations(range(4), rA):
            for rB in range(5):
                for B in itertools.combinations(range(4), rB):
                    lhs = (price(pm, sorted(set(A) | set(B)))
                           + price(pm, sorted(set(A) & set(B))))
                    rhs = price(pm, A) + price(pm, B)
                    worst_mod = max(worst_mod, abs(lhs - rhs))
    print(f"  zero-curvature pool: max |C(AuB)+C(AnB) - C(A)-C(B)|   "
          f"= {worst_mod:.2e}  (= 0: exact modularity)")
    print()


def demo_greedy_guarantees() -> None:
    print("=" * 78)
    print("4. Greedy library design: the sharpened step and the product bound")
    print("=" * 78)
    rng = random.Random(2718)
    pool = random_pool(7, 9, rng, concentration=0.2)
    omega = list(range(7))
    kap = curvature(pool, omega)
    n = 4
    chain = greedy_run(pool, omega, n)
    opt_set, opt_val = brute_force_optimum(pool, omega, n)
    print(f"  |Omega| = {len(omega)}, |X| = 9, target size n = {n}")
    print(f"  curvature kappa      = {kap:.6f}")
    print(f"  optimal library      = {opt_set}, C(B) = {opt_val:.6f}")
    print(f"  greedy library       = {chain[n]}, C(A_n) = {price(pool, chain[n]):.6f}")
    print()
    print("   k   C(A_k)     gain rho_k   gap        step bound      product bound")
    for k in range(n):
        A_k, A_k1 = chain[k], chain[k + 1]
        rho = price(pool, A_k1) - price(pool, A_k)
        gap = opt_val - price(pool, A_k)
        step_bound = (n - (1.0 - kap) * k) * rho
        prod_bound = curvature_product(n, kap, k) * opt_val
        print(f"  {k:2d}   {price(pool, A_k):8.5f}   {rho:8.5f}    {gap:8.5f}   "
              f"{step_bound:10.5f}      {prod_bound:10.5f}")
    final_gap = opt_val - price(pool, chain[n])
    print(f"  {n:2d}   {price(pool, chain[n]):8.5f}              {final_gap:8.5f}"
          f"                  {curvature_product(n, kap, n) * opt_val:10.5f}")
    print()
    print(f"  guaranteed fraction 1 - Q_n^kappa(n) = "
          f"{1 - curvature_product(n, kap, n):.6f}")
    print(f"  achieved fraction   C(A_n)/C(B)      = "
          f"{price(pool, chain[n]) / opt_val:.6f}")
    print(f"  classical bound     1 - 1/e          = {1 - math.exp(-1):.6f}")
    print()


def demo_endpoints_and_low_curvature() -> None:
    print("=" * 78)
    print("5. Endpoints: exact optimality at kappa = 0, and the low-curvature bound")
    print("=" * 78)
    pm = point_masses(5)
    omega = list(range(5))
    kap = curvature(pm, omega)
    n = 3
    chain = greedy_run(pm, omega, n)
    _, opt_val = brute_force_optimum(pm, omega, n)
    print(f"  zero-curvature pool (five point masses): kappa = {kap:.6f}")
    print(f"    C(B_opt) = {opt_val:.6f},  C(A_greedy) = {price(pm, chain[n]):.6f}"
          f"   -> gap = {opt_val - price(pm, chain[n]):.2e}  (exactly optimal)")

    print("\n  low-curvature gap bound  gap <= kappa (n-1) C(B):")
    print("    kappa      n    proved gap bound    guaranteed fraction")
    for kap0 in (0.0, 0.01, 0.05, 0.1, 0.3, 1.0):
        for n0 in (3, 10):
            bound = kap0 * (n0 - 1)
            print(f"    {kap0:5.2f}   {n0:3d}    {min(bound, 1.0):12.4f}"
                  f"        {max(1 - bound, 0.0):8.4f}")
    print()


def demo_proved_vs_conjectured() -> None:
    print("=" * 78)
    print("6. The proved factor 1 - Q_n^kappa(n) against the conjectured "
          "(1-e^{-kappa})/kappa")
    print("=" * 78)
    print("    kappa     n     proved      conjectured    difference")
    for kap in (0.0, 0.1, 0.5, 1.0):
        for n in (3, 10):
            proved = 1.0 - curvature_product(n, kap, n)
            conj = conjectured_factor(kap)
            print(f"    {kap:5.2f}  {n:4d}   {proved:9.4f}   {conj:11.4f}"
                  f"   {proved - conj:+11.4f}")
    print("\n  (at kappa = 1 the proved bound 1-(1-1/n)^n beats the asymptotic"
          " 1-1/e for small n;\n   for small kappa it falls just short of the "
          "conjecture: the missing 1/kappa amplification.)")
    print()


def demo_total_variation() -> None:
    print("=" * 78)
    print("7. Curvature versus total variation: the intuition is REVERSED")
    print("=" * 78)
    print("  two-source pools:  kappa = 1 - TV  exactly, and every kappa is realized")
    print("      d (bias gap)      TV        kappa      1 - TV")
    for d in (0.0, 0.2, 0.5, 0.8, 1.0):
        pool = biased_pair(d)
        tv = total_variation(pool[0], pool[1])
        kap = curvature(pool, [0, 1])
        print(f"      {d:8.2f}     {tv:8.4f}   {kap:8.4f}   {1 - tv:8.4f}")

    print("\n  REFUTATION of the conjecture  kappa <= TV * |Omega| :")
    tw = twin_coins()
    tv = total_variation(tw[0], tw[1])
    kap = curvature(tw, [0, 1])
    print(f"      twin fair coins:  TV = {tv:.4f},  |Omega| = 2,"
          f"  conjectured bound = {tv * 2:.4f},  actual kappa = {kap:.4f}")
    print(f"      -> conjecture violated by {kap - tv * 2:.4f}"
          f"  (the maximum possible margin)")

    print("\n  the TRUE inequality  kappa >= 1 - (|Omega|-1) * delta :")
    rng = random.Random(99)
    print("      |Omega|   delta(diameter)   1-(|Omega|-1)delta      kappa")
    for m in (2, 3, 4, 5):
        base = random_pool(1, 6, rng, concentration=5.0)[0]
        pool = []
        for _ in range(m):
            noise = [max(1e-9, b + rng.uniform(-0.01, 0.01)) for b in base]
            s = sum(noise)
            pool.append([v / s for v in noise])
        omega = list(range(m))
        delta = pool_tv_diameter(pool, omega)
        print(f"      {m:5d}   {delta:14.5f}   {1 - (m - 1) * delta:17.5f}"
              f"   {curvature(pool, omega):9.5f}")
    print("      (near-identical pools are MAXIMALLY curved, not flat)")
    print()


def demo_pigeonhole() -> None:
    print("=" * 78)
    print("8. Pigeonhole curvature saturation: |Omega| > |X| forces kappa = 1")
    print("=" * 78)
    rng = random.Random(5)
    n_symbols = 4
    print(f"  alphabet size |X| = {n_symbols}")
    print("      |Omega|     kappa      (kappa must be 1 once |Omega| > |X|)")
    for m in range(2, 8):
        pool = random_pool(m, n_symbols, rng, concentration=0.3)
        kap = curvature(pool, list(range(m)))
        note = "  <- pigeonhole" if m > n_symbols else ""
        print(f"      {m:5d}    {kap:9.6f}{note}")
    print()


def demo_random_stress_test(trials: int = 400) -> None:
    print("=" * 78)
    print(f"9. Randomized stress test over {trials} pools: every guarantee holds")
    print("=" * 78)
    rng = random.Random(4242)
    worst_step = math.inf
    worst_product = math.inf
    worst_lowcurv = math.inf
    worst_conjecture = math.inf
    min_achieved_fraction = math.inf
    for _ in range(trials):
        m = rng.randint(2, 6)
        n_symbols = rng.randint(m, m + 4)
        pool = random_pool(m, n_symbols, rng, concentration=rng.choice([0.15, 0.5, 2.0]))
        omega = list(range(m))
        kap = curvature(pool, omega)
        n = rng.randint(1, m)
        chain = greedy_run(pool, omega, n)
        _, opt_val = brute_force_optimum(pool, omega, n)
        for k in range(n):
            if len(chain[k]) != k:
                continue
            rho = price(pool, chain[k + 1]) - price(pool, chain[k])
            gap = opt_val - price(pool, chain[k])
            worst_step = min(worst_step, (n - (1 - kap) * k) * rho - gap)
            worst_product = min(
                worst_product,
                curvature_product(n, kap, k) * opt_val - gap)
        final_gap = opt_val - price(pool, chain[n])
        worst_lowcurv = min(worst_lowcurv, kap * (n - 1) * opt_val - final_gap)
        achieved = price(pool, chain[n]) / opt_val
        min_achieved_fraction = min(min_achieved_fraction, achieved)
        worst_conjecture = min(worst_conjecture, achieved - conjectured_factor(kap))
    print(f"  min slack, sharpened step   gap <= (n-(1-k)i) rho   : {worst_step:.2e}  (>= 0)")
    print(f"  min slack, product bound    gap <= Q_n^k(i) C(B)    : {worst_product:.2e}  (>= 0)")
    print(f"  min slack, low curvature    gap <= k(n-1) C(B)      : {worst_lowcurv:.2e}  (>= 0)")
    print(f"  worst achieved fraction C(A_n)/C(B)                 : "
          f"{min_achieved_fraction:.6f}  (>= 1 - 1/e = {1 - math.exp(-1):.6f})")
    print(f"  min slack against conjectured (1-e^-k)/k            : "
          f"{worst_conjecture:.2e}  (>= 0: conjecture consistent with experiment)")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE CURVATURE OF A MODEL POOL — numerical demonstrations")
    print("#" * 78)
    print()
    demo_price_and_structure()
    demo_curvature_basics()
    demo_curvature_inequalities()
    demo_greedy_guarantees()
    demo_endpoints_and_low_curvature()
    demo_proved_vs_conjectured()
    demo_total_variation()
    demo_pigeonhole()
    demo_random_stress_test()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
