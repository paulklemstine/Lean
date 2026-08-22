"""
Joint capacity of a battery of bounded-modulus dials — numerical demonstrations.

This script is self-contained (standard library only) and illustrates every
result of the accompanying paper:

  1.  Empirical capacity of a statistic on a finite population.
  2.  Monotone scaling:  S ⊆ T  ⇒  C(S) ≤ C(T).
  3.  The strict scaling criterion (a new dial that resolves an old collision).
  4.  The multiplicative ("CRT") ceiling  C(S) ≤ log2 ∏ m_i  and its attainment
      on the Chinese-Remainder population Z/31 × Z/23  (exactly log2 713).
  5.  The sample ceiling  C(S) ≤ log2 N, and the population lower bound it
      implies for a reported capacity.
  6.  The per-dial budget  C(S) ≤ Σ c_i and the increment bound
      C(S ∪ {a}) - C(S) ≤ c_a, turned into a falsification test that the
      reported figures fail by 3.38 bits.
  7.  The audited reported table: moduli 31, 23, 9, 8 with cell counts
      713 / 6417 / 51336 and measured 7.9455 / 10.4462 / 12.1080 bits.
  8.  Wall inversion: recovering the class imbalance p from a binary capacity,
      in particular p ≈ 0.0996 from the reported wall 0.4677 bits.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

Individual = Hashable
Reading = Hashable


# --------------------------------------------------------------------------
# 1.  The empirical Shannon calculus
# --------------------------------------------------------------------------

def block_sizes(population: Sequence[Individual],
                statistic: Callable[[Individual], Reading]) -> Dict[Reading, int]:
    """Sizes n_a of the level sets (blocks) of a statistic on a population."""
    counts: Counter = Counter()
    for x in population:
        counts[statistic(x)] += 1
    return dict(counts)


def capacity_bits(population: Sequence[Individual],
                  statistic: Callable[[Individual], Reading]) -> float:
    """Empirical capacity  C(f) = Σ_a (n_a/N) log2(N/n_a)  in bits.

    Equal to the mutual information I(individual ; reading) under the uniform
    measure on the population, because the reading is deterministic.
    """
    n_total = len(population)
    if n_total == 0:
        return 0.0
    return sum((n / n_total) * math.log2(n_total / n)
               for n in block_sizes(population, statistic).values())


def binary_entropy(p: float) -> float:
    """h(p) = -p log2 p - (1-p) log2(1-p), with h(0) = h(1) = 0."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * math.log2(p) - (1.0 - p) * math.log2(1.0 - p)


def invert_binary_entropy(target: float, tol: float = 1e-14) -> float:
    """Unique p in [0, 1/2] with h(p) = target (bisection; h is strictly
    increasing there, so the inverse is well defined for 0 ≤ target ≤ 1)."""
    if target <= 0.0:
        return 0.0
    if target >= 1.0:
        return 0.5
    lo, hi = 0.0, 0.5
    while hi - lo > tol:
        mid = 0.5 * (lo + hi)
        if binary_entropy(mid) < target:
            lo = mid
        else:
            hi = mid
    return 0.5 * (lo + hi)


# --------------------------------------------------------------------------
# 2.  Dials and batteries
# --------------------------------------------------------------------------

class Dial:
    """A reading of the population with values in {0, ..., modulus-1}."""

    def __init__(self, name: str, modulus: int,
                 read: Callable[[Individual], int]) -> None:
        self.name = name
        self.modulus = modulus
        self.read = read

    def check(self, population: Sequence[Individual]) -> None:
        for x in population:
            value = self.read(x)
            assert 0 <= value < self.modulus, f"dial {self.name} out of range at {x!r}"


def joint_reading(dials: Sequence[Dial]) -> Callable[[Individual], Tuple[int, ...]]:
    """The joint reading of a sub-battery: the tuple of its dials' readings."""
    return lambda x: tuple(d.read(x) for d in dials)


def joint_capacity(population: Sequence[Individual],
                   dials: Sequence[Dial]) -> float:
    """C(S) in bits."""
    return capacity_bits(population, joint_reading(dials))


def crt_ceiling(dials: Sequence[Dial]) -> float:
    """log2 ∏ m_i — the multiplicative ceiling."""
    product = 1
    for d in dials:
        product *= d.modulus
    return math.log2(product)


def sample_ceiling(population: Sequence[Individual]) -> float:
    """log2 N — the sample ceiling (sparse-table bias)."""
    return math.log2(len(population))


def separating_pair(population: Sequence[Individual],
                    small: Sequence[Dial],
                    large: Sequence[Dial]) -> Tuple[Individual, Individual] | None:
    """Find x ≠ y confused by every dial of `small` but separated by some dial
    of `large`.  Its existence certifies strict growth of the joint capacity."""
    fine, coarse = joint_reading(large), joint_reading(small)
    seen: Dict[Tuple[int, ...], Individual] = {}
    for x in population:
        key = coarse(x)
        if key in seen:
            y = seen[key]
            if fine(x) != fine(y):
                return (y, x)
        else:
            seen[key] = x
    return None


# --------------------------------------------------------------------------
# Demonstration 1 — the toy witness on {0,1,2,3}
# --------------------------------------------------------------------------

def demo_toy_witness() -> None:
    print("=" * 72)
    print("1.  Strict scaling on the four-element population {0,1,2,3}")
    print("=" * 72)
    population = [0, 1, 2, 3]
    parity = Dial("parity", 2, lambda x: x % 2)
    half = Dial("half", 2, lambda x: x // 2)
    for d in (parity, half):
        d.check(population)

    c1 = joint_capacity(population, [parity])
    c2 = joint_capacity(population, [parity, half])
    pair = separating_pair(population, [parity], [parity, half])

    print(f"  C({{parity}})        = {c1:.6f} bits   (two blocks of size 2)")
    print(f"  C({{parity, half}})  = {c2:.6f} bits   (four singletons)")
    print(f"  separating pair confused by parity alone: {pair}")
    print(f"  strict growth?  {c1 < c2}")
    print(f"  ceilings: log2(2*2) = {crt_ceiling([parity, half]):.6f},"
          f"  log2 N = {sample_ceiling(population):.6f}  -> both attained\n")


# --------------------------------------------------------------------------
# Demonstration 2 — the Chinese Remainder witness
# --------------------------------------------------------------------------

def demo_crt_saturation() -> None:
    print("=" * 72)
    print("2.  The multiplicative ceiling is attained: Z/31 x Z/23")
    print("=" * 72)
    population: List[Tuple[int, int]] = [(a, b) for a in range(31) for b in range(23)]
    d31 = Dial("coord mod 31", 31, lambda x: x[0])
    d23 = Dial("coord mod 23", 23, lambda x: x[1])
    for d in (d31, d23):
        d.check(population)

    measured = joint_capacity(population, [d31, d23])
    ceiling = crt_ceiling([d31, d23])
    print(f"  population size N        = {len(population)}  (= 31 * 23)")
    print(f"  joint capacity           = {measured:.10f} bits")
    print(f"  multiplicative ceiling   = {ceiling:.10f} bits  (log2 713)")
    print(f"  gap                      = {ceiling - measured:.2e}  -> exact saturation")
    print(f"  individual dials         : {joint_capacity(population, [d31]):.6f}"
          f" + {joint_capacity(population, [d23]):.6f}"
          f" = {joint_capacity(population, [d31]) + joint_capacity(population, [d23]):.6f}")
    print("  (per-dial budget is tight here: the two dials are independent)\n")


# --------------------------------------------------------------------------
# Demonstration 3 — a sparse table: the four-dial battery simulated
# --------------------------------------------------------------------------

def demo_sparse_battery(n_population: int = 4500, seed: int = 20260822) -> None:
    print("=" * 72)
    print("3.  A sparse four-dial battery (moduli 31, 23, 9, 8)")
    print("=" * 72)
    rng = random.Random(seed)
    population = list(range(n_population))
    moduli = [31, 23, 9, 8]
    # Independent pseudo-random residues: the generic, collision-free-ish case.
    tables = [[rng.randrange(m) for _ in population] for m in moduli]
    dials = [Dial(f"dial@{m}", m, (lambda t: (lambda x: t[x]))(tables[k]))
             for k, m in enumerate(moduli)]
    for d in dials:
        d.check(population)

    print(f"  population size N = {n_population},  log2 N = {sample_ceiling(population):.4f} bits")
    print()
    print("   dials on   cells M      C(S)      log2 M    log2 N   shortfall")
    print("   " + "-" * 63)
    previous = 0.0
    for k in range(1, 5):
        sub = dials[:k]
        cells = 1
        for d in sub:
            cells *= d.modulus
        c = joint_capacity(population, sub)
        assert c >= previous - 1e-12, "monotone scaling violated"
        previous = c
        print(f"   {k:^8d}   {cells:7d}   {c:8.4f}   {crt_ceiling(sub):7.4f}"
              f"   {sample_ceiling(population):6.4f}   {crt_ceiling(sub) - c:8.4f}")
    print()
    per_dial = [joint_capacity(population, [d]) for d in dials]
    print("   per-dial capacities: "
          + ", ".join(f"{d.name}={c:.4f}" for d, c in zip(dials, per_dial)))
    print(f"   per-dial budget:  C(all) = {joint_capacity(population, dials):.4f}"
          f"  <=  sum = {sum(per_dial):.4f}  (slack = mutual information)")
    print("   note how the shortfall against log2 M grows as the table sparsifies\n")


# --------------------------------------------------------------------------
# Demonstration 4 — the increment bound and the falsification test
# --------------------------------------------------------------------------

def demo_increment_bound(seed: int = 7) -> None:
    print("=" * 72)
    print("4.  The increment bound: no dial contributes more than it is worth")
    print("=" * 72)
    rng = random.Random(seed)
    n = 4096
    population = list(range(n))

    # A coarse sub-battery: 512 blocks of 8 individuals each.
    base = Dial("base", 512, lambda x: x // 8)

    # Three companion dials of modulus 31, all nearly blind but with very
    # different relationships to `base`.  In every case the increment is the
    # CONDITIONAL capacity given `base`, which can never exceed the solo value.
    companions = {
        "independent": Dial("c-indep", 31, lambda x: 1 if (x % 8) == 0 else 0),
        "aligned to base": Dial("c-align", 31, lambda x: 1 if (x // 8) % 8 == 0 else 0),
        "random sparse": Dial("c-rand", 31,
                              (lambda t: (lambda x: t[x]))(
                                  [1 if rng.random() < 0.01 else 0 for _ in population])),
    }
    for d in [base, *companions.values()]:
        d.check(population)

    c_base = joint_capacity(population, [base])
    print(f"  C(base alone) = {c_base:.4f} bits  (512 blocks of 8)\n")
    print("   companion dial      solo c_a   increment   c_a - increment (= I)")
    print("   " + "-" * 62)
    for label, dial in companions.items():
        solo = joint_capacity(population, [dial])
        increment = joint_capacity(population, [base, dial]) - c_base
        assert increment <= solo + 1e-12, "increment bound violated"
        print(f"   {label:<18s}  {solo:8.4f}   {increment:9.4f}   {solo - increment:12.4f}")
    print("\n  the last column is the mutual information I(dial ; base) >= 0:")
    print("  conditioning never increases capacity, so a near-blind dial is")
    print("  near-useless jointly as well as alone.\n")

    # The consistency test this implies, applied to the reported figures.
    print("  consequence - a falsification test for a reported pair of tables:")
    c31_reported = 0.04
    cap = c31_reported + math.log2(23)
    print(f"     reported solo capacity of the modulus-31 dial : {c31_reported} bits")
    print(f"     best conceivable partner (modulus 23)         : log2 23 ="
          f" {math.log2(23):.4f} bits")
    print(f"     per-dial budget for the pair                  : <= {cap:.4f} bits")
    print(f"     reported joint capacity of the pair           :    7.9455 bits")
    print(f"     budget satisfied? {7.9455 <= cap}   (excess = {7.9455 - cap:.4f} bits)")
    print("     => the per-dial and joint tables cannot describe the same dials")
    print("        on the same population.\n")


# --------------------------------------------------------------------------
# Demonstration 5 — auditing the reported table
# --------------------------------------------------------------------------

def demo_audit_table() -> None:
    print("=" * 72)
    print("5.  Auditing the reported reported table")
    print("=" * 72)
    reported = [(713, 7.9455), (6417, 10.4462), (51336, 12.1080)]
    print("      M       reported   log2 M    admissible?   shortfall")
    print("   " + "-" * 58)
    for cells, value in reported:
        ceiling = math.log2(cells)
        print(f"   {cells:6d}   {value:8.4f}   {ceiling:7.4f}"
              f"        {str(value < ceiling):5s}      {ceiling - value:7.4f}")
    increasing = all(reported[i][1] < reported[i + 1][1] for i in range(len(reported) - 1))
    print(f"\n   increasing chain? {increasing}   (forced by monotone scaling)")

    top = reported[-1][1]
    print(f"   sample ceiling inverted: N >= 2^{top} = {2 ** top:.1f}"
          f"  -> at least {math.ceil(2 ** top)} individuals")

    # Integer certificates used in the paper.
    print("\n   integer certificates:")
    print(f"     2^8  = {2**8} <= 713     so log2 713   >= 8  > 7.9455 : {2**8 <= 713}")
    print(f"     2^12 = {2**12} <= 6417    so log2 6417  >= 12 > 10.4462: {2**12 <= 6417}")
    print(f"     2^15 = {2**15} <= 51336   so log2 51336 >= 15 > 12.1080: {2**15 <= 51336}")
    print(f"     11^50 < 2^173                  so log2 11 < 3.46      : {11**50 < 2**173}")
    print(f"     2^49  < 31^10                  so log2 31 > 4.9       : {2**49 < 31**10}")
    print(f"\n   log2 11 = {math.log2(11):.6f}  -> reported 3.46 is a SATURATED dial"
          f" (gap {3.46 - math.log2(11):.6f} bits)")
    print(f"   log2 31 = {math.log2(31):.6f}  -> reported 0.04 is"
          f" {0.04 / math.log2(31) * 100:.2f}% of ceiling: a BLIND dial")
    print(f"   per-dial spread = {3.46 / 0.04:.0f}x\n")


# --------------------------------------------------------------------------
# Demonstration 6 — wall inversion
# --------------------------------------------------------------------------

def demo_wall_inversion() -> None:
    print("=" * 72)
    print("6.  Wall inversion: a binary capacity is an imbalance meter")
    print("=" * 72)
    wall = 0.4677
    p = invert_binary_entropy(wall)
    print(f"  reported which-factor wall  = {wall} bits  (< 1 bit, so admissible)")
    print(f"  unique p in [0, 1/2] with h(p) = wall :  p = {p:.6f}"
          f"   ({100 * p:.2f}% / {100 * (1 - p):.2f}% split)")
    print(f"  check: h({p:.6f}) = {binary_entropy(p):.6f}")

    slope = math.log2((1 - p) / p)
    print(f"  sensitivity h'(p) = log2((1-p)/p) = {slope:.4f} bits per unit p")
    for eps in (0.01, 0.001, 0.0001):
        print(f"     capacity uncertainty +-{eps:<7} -> imbalance uncertainty"
              f" +-{eps / slope:.6f}")

    print("\n  empirical check on a synthetic population:")
    n = 100000
    minority = round(p * n)
    population = list(range(n))
    flag = Dial("which-factor", 2, lambda x: 1 if x < minority else 0)
    flag.check(population)
    measured = joint_capacity(population, [flag])
    print(f"     population {n}, minority class {minority}"
          f"  ->  measured capacity {measured:.6f} bits  (target {wall})")

    print("\n  monotonicity of h on [0, 1/2] (so the inversion is unique):")
    for q in (0.02, 0.05, 0.10, 0.20, 0.35, 0.50):
        print(f"     h({q:.2f}) = {binary_entropy(q):.6f}")
    print()


# --------------------------------------------------------------------------
# Demonstration 7 — occupancy: why sparse tables lose capacity
# --------------------------------------------------------------------------

def expected_occupied_cells(n_rows: int, n_cells: int) -> float:
    """M (1 - (1 - 1/M)^N): expected number of occupied cells for a uniformly
    random assignment of N rows to M cells."""
    return n_cells * (1.0 - (1.0 - 1.0 / n_cells) ** n_rows)


def demo_occupancy(n_rows: int = 4500) -> None:
    print("=" * 72)
    print("7.  Occupancy: the two ceilings and the regime transition")
    print("=" * 72)
    print(f"  population N = {n_rows},  log2 N = {math.log2(n_rows):.4f} bits")
    print("\n       M      log2 M   E[occupied]  log2 E[occ]   binding ceiling")
    print("   " + "-" * 64)
    for cells in (713, 6417, 51336, 10 ** 6, 10 ** 8):
        occ = expected_occupied_cells(n_rows, cells)
        binding = "sample" if math.log2(n_rows) < math.log2(cells) else "product"
        print(f"   {cells:8d}   {math.log2(cells):7.4f}   {occ:10.1f}"
              f"   {math.log2(occ):10.4f}      {binding}")
    print("\n  the achievable capacity lies below min(log2 M, log2 N) and, for a")
    print("  well-spread battery, close to log2 E[occupied cells]: as M grows the")
    print("  occupancy saturates at N and the capacity stops improving.\n")


def main() -> None:
    demo_toy_witness()
    demo_crt_saturation()
    demo_sparse_battery()
    demo_increment_bound()
    demo_audit_table()
    demo_wall_inversion()
    demo_occupancy()
    print("=" * 72)
    print("All demonstrations complete.")
    print("=" * 72)


if __name__ == "__main__":
    main()
