"""
Seed fractions and level sets: exact numerical demonstrations.
==============================================================

Every quantity computed here is an exact rational number (``fractions.Fraction``),
so each printed identity is a genuine equality between rationals rather than a
floating-point coincidence.

The script demonstrates, in order:

  1. The seed-fraction calculus: monotonicity, additivity, complementation, and
     the fact that all normalisation laws fail on an empty seed space.
  2. The Level-Set Partition Theorem, the sublevel identity, and both layer-cake
     identities for the average of a bounded cost function.
  3. Bounded witness search: the guarding facts, honesty, the provably vacuous
     Markov tail bound B/t, and the First-Probe Savings Bound E <= B - (B-1)p.
  4. Exact amplification: 1 - (1 - eps)^k, verified against brute-force
     enumeration of the product seed space.
  5. Sampled monitoring: the compromised fraction (N - floor(N/k))/N, the residue
     formula (k-1)/k + (N mod k)/(k N), the alignment criterion and the 1/N
     envelope, all checked against direct enumeration of the window.
  6. Rewinding: row averaging, the sharp 1/|C| extraction threshold, and the
     heavy-row splitting lemma verified exhaustively over all accepting
     configurations of a small grid.

Run with:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable, Dict, Hashable, Iterable, List, Optional, Sequence, Tuple

Seed = Hashable
Rat = Fraction


# ---------------------------------------------------------------------------
# 1. The seed-fraction calculus
# ---------------------------------------------------------------------------


def good_seeds(omega: Sequence[Seed], event: Callable[[Seed], bool]) -> List[Seed]:
    """The seeds of ``omega`` on which ``event`` holds."""
    return [s for s in omega if event(s)]


def frac(omega: Sequence[Seed], event: Callable[[Seed], bool]) -> Rat:
    """|{s in omega : event(s)}| / |omega|, with the convention x/0 = 0."""
    if len(omega) == 0:
        return Fraction(0)
    return Fraction(len(good_seeds(omega, event)), len(omega))


def exp_cost(omega: Sequence[Seed], cost: Callable[[Seed], int]) -> Rat:
    """The average of a natural-number cost over the seed space."""
    if len(omega) == 0:
        return Fraction(0)
    return Fraction(sum(cost(s) for s in omega), len(omega))


def demo_calculus() -> None:
    print("=" * 78)
    print("1. THE SEED-FRACTION CALCULUS")
    print("=" * 78)

    omega: List[int] = list(range(12))
    even = lambda n: n % 2 == 0
    div4 = lambda n: n % 4 == 0

    f_even = frac(omega, even)
    f_div4 = frac(omega, div4)
    print(f"  Omega = {{0,...,11}}")
    print(f"  frac(even)          = {f_even}")
    print(f"  frac(4 | n)         = {f_div4}")
    print(f"  monotonicity  (4|n => even): {f_div4} <= {f_even}  -> {f_div4 <= f_even}")

    f_not_even = frac(omega, lambda n: not even(n))
    print(f"  complementation: {f_even} + {f_not_even} = {f_even + f_not_even}")

    # additivity on disjoint events
    p = lambda n: n % 4 == 1
    q = lambda n: n % 4 == 2
    lhs = frac(omega, lambda n: p(n) or q(n))
    rhs = frac(omega, p) + frac(omega, q)
    print(f"  additivity (disjoint):  {lhs} = {rhs}  -> {lhs == rhs}")

    # the empty seed space: every normalisation law fails
    empty: List[int] = []
    print("\n  On the EMPTY seed space (convention x/0 = 0):")
    print(f"    frac(sure event)                = {frac(empty, lambda n: True)}  (not 1!)")
    print(f"    frac(A) + frac(not A)           = "
          f"{frac(empty, even) + frac(empty, lambda n: not even(n))}  (not 1!)")
    print("    -> every normalisation statement needs a non-emptiness guard.")


# ---------------------------------------------------------------------------
# 2. Level sets and layer cake
# ---------------------------------------------------------------------------


def level_fractions(omega: Sequence[Seed], cost: Callable[[Seed], int], bound: int) -> List[Rat]:
    """The vector (frac(cost = i))_{i=0..bound}."""
    return [frac(omega, lambda s, i=i: cost(s) == i) for i in range(bound + 1)]


def tail_fractions(omega: Sequence[Seed], cost: Callable[[Seed], int], bound: int) -> List[Rat]:
    """The vector (frac(cost >= t))_{t=1..bound}."""
    return [frac(omega, lambda s, t=t: cost(s) >= t) for t in range(1, bound + 1)]


def demo_level_sets() -> None:
    print()
    print("=" * 78)
    print("2. LEVEL SETS, SUBLEVEL SUMS AND LAYER CAKE")
    print("=" * 78)

    omega = list(range(30))
    cost = lambda n: (n * n) % 7          # a cost bounded by 6
    bound = 6

    levels = level_fractions(omega, cost, bound)
    print("  Omega = {0,...,29},  cost(n) = n^2 mod 7,  B = 6")
    print("  level fractions frac(cost = i):")
    for i, v in enumerate(levels):
        print(f"    i = {i}:  {v}")
    total = sum(levels, Fraction(0))
    print(f"  SUM = {total}   (Level-Set Partition Theorem: must be 1) -> {total == 1}")

    print("\n  sublevel identity  frac(cost <= t) = sum_{i<=t} frac(cost = i):")
    for t in range(bound + 1):
        lhs = frac(omega, lambda s, t=t: cost(s) <= t)
        rhs = sum(levels[: t + 1], Fraction(0))
        print(f"    t = {t}:  {lhs} = {rhs}  -> {lhs == rhs}")

    direct = exp_cost(omega, cost)
    weighted = sum((Fraction(i) * levels[i] for i in range(bound + 1)), Fraction(0))
    tails = sum(tail_fractions(omega, cost, bound), Fraction(0))
    print("\n  average cost, three ways:")
    print(f"    direct                       = {direct}")
    print(f"    weighted layer cake          = {weighted}")
    print(f"    tail layer cake              = {tails}")
    print(f"    all equal -> {direct == weighted == tails}")

    print("\n  Markov, level-set form  frac(cost >= t) <= E[cost]/t:")
    for t in range(1, bound + 1):
        lhs = frac(omega, lambda s, t=t: cost(s) >= t)
        rhs = direct / t
        print(f"    t = {t}:  {lhs} <= {rhs}  -> {lhs <= rhs}")


# ---------------------------------------------------------------------------
# 3. Bounded witness search
# ---------------------------------------------------------------------------


def witnesses(f: Callable[[Seed, int], bool], budget: int, s: Seed) -> List[int]:
    """The successful probes below the budget."""
    return [w for w in range(budget) if f(s, w)]


def found(f: Callable[[Seed, int], bool], budget: int, s: Seed) -> bool:
    """Does the bounded search succeed on the seed s?"""
    return len(witnesses(f, budget, s)) > 0


def search_cost(f: Callable[[Seed, int], bool], budget: int, s: Seed) -> int:
    """Number of probes performed: first witness index + 1, else the full budget."""
    for w in range(budget):
        if f(s, w):
            return w + 1
    return budget


def demo_bounded_search() -> None:
    print()
    print("=" * 78)
    print("3. BOUNDED WITNESS SEARCH")
    print("=" * 78)

    budget = 8
    omega = list(range(40))
    # a seed s has witness w iff (s + w*w) is divisible by 5 -- an arbitrary,
    # structured predicate producing a spread of search costs.
    f = lambda s, w: (s + w * w) % 5 == 0

    costs = {s: search_cost(f, budget, s) for s in omega}
    print(f"  Omega = {{0,...,39}},  budget B = {budget},  f(s,w) = [5 | s + w^2]")
    print(f"  success fraction              = {frac(omega, lambda s: found(f, budget, s))}")
    print(f"  max cost observed             = {max(costs.values())}  (<= B: "
          f"{max(costs.values()) <= budget})")

    # guarding facts
    ok_guard = all(
        (costs[s] <= budget)
        and (costs[s] >= budget or found(f, budget, s))
        and (found(f, budget, s) or costs[s] == budget)
        for s in omega
    )
    print(f"  guarding facts (cost<=B; cost<B => found; not found => cost=B): {ok_guard}")

    # honesty: on the sub-space where every seed has a witness, the fraction is 1
    honest = [s for s in omega if found(f, budget, s)]
    print(f"  honesty: on the seeds that carry a witness, success fraction = "
          f"{frac(honest, lambda s: found(f, budget, s))}")

    # level-set profile
    levels = level_fractions(omega, lambda s: costs[s], budget)
    print("\n  cost level fractions:")
    for i, v in enumerate(levels):
        if v != 0:
            print(f"    cost = {i}:  {v}")
    print(f"  SUM = {sum(levels, Fraction(0))}")

    # Markov is provably vacuous here
    print("\n  Markov tail bound  frac(cost >= t) <= B/t   [provably vacuous]:")
    for t in range(1, budget + 3):
        lhs = frac(omega, lambda s, t=t: costs[s] >= t)
        rhs = Fraction(budget, t)
        verdict = "vacuous (bound >= 1)" if rhs >= 1 else "vacuous (LHS already 0)"
        print(f"    t = {t:2d}:  {str(lhs):>7} <= {str(rhs):>5}   {verdict}")

    # first-probe savings
    p = frac(omega, lambda s: f(s, 0))
    e = exp_cost(omega, lambda s: costs[s])
    bound_fp = Fraction(budget) - (Fraction(budget) - 1) * p
    print("\n  First-Probe Savings Bound   E[cost] <= B - (B-1) * p:")
    print(f"    p = frac(first probe succeeds) = {p}")
    print(f"    E[cost]                        = {e}")
    print(f"    bound                          = {bound_fp}")
    print(f"    holds -> {e <= bound_fp};  strictly better than the trivial B = {budget}"
          f" -> {bound_fp < budget}")


# ---------------------------------------------------------------------------
# 4. Exact amplification
# ---------------------------------------------------------------------------


def amplified_fraction_bruteforce(
    omega: Sequence[Seed], event: Callable[[Seed], bool], k: int
) -> Rat:
    """frac over Omega^k of 'at least one coordinate is good', by enumeration."""
    tuples = list(product(omega, repeat=k))
    return frac(tuples, lambda tup: any(event(s) for s in tup))


def demo_amplification() -> None:
    print()
    print("=" * 78)
    print("4. EXACT AMPLIFICATION:  1 - (1 - eps)^k")
    print("=" * 78)

    omega = list(range(8))
    event = lambda n: n < 2            # one-shot fraction 2/8 = 1/4
    eps = frac(omega, event)
    print(f"  Omega = {{0,...,7}},  good = {{0,1}},  one-shot fraction eps = {eps}")
    print("   k | brute force over Omega^k | 1 - (1-eps)^k | equal?")
    for k in range(0, 6):
        brute = amplified_fraction_bruteforce(omega, event, k)
        closed = 1 - (1 - eps) ** k
        print(f"  {k:2d} | {str(brute):>22} | {str(closed):>13} | {brute == closed}")

    print("\n  monotone amplification (each value >= eps for k >= 1), decay of shortfall:")
    for k in range(1, 12):
        closed = 1 - (1 - eps) ** k
        print(f"    k = {k:2d}:  success = {str(closed):>18}   shortfall = {(1-eps)**k}")


# ---------------------------------------------------------------------------
# 5. Sampled monitoring
# ---------------------------------------------------------------------------


def compromised_fraction_enumerated(n_window: int, period: int) -> Rat:
    """Compromised fraction of {1,...,N}: compromised at n iff period does not divide n."""
    window = list(range(1, n_window + 1))
    return frac(window, lambda n: n % period != 0)


def compromised_fraction_closed(n_window: int, period: int) -> Rat:
    """(N - floor(N/k)) / N."""
    return Fraction(n_window - n_window // period, n_window)


def compromised_fraction_residue(n_window: int, period: int) -> Rat:
    """(k-1)/k + (N mod k)/(k N)."""
    return (Fraction(period - 1, period)
            + Fraction(n_window % period, period * n_window))


def demo_monitoring() -> None:
    print()
    print("=" * 78)
    print("5. SAMPLED MONITORING: THE EXACT COMPROMISED FRACTION")
    print("=" * 78)

    for period in (2, 3, 4):
        print(f"\n  monitoring period k = {period};  folklore value (k-1)/k = "
              f"{Fraction(period - 1, period)}")
        print("    N | enumerated | (N - floor(N/k))/N | (k-1)/k + (N mod k)/(kN) |"
              " aligned | envelope ok")
        for n_window in range(1, 13):
            a = compromised_fraction_enumerated(n_window, period)
            b = compromised_fraction_closed(n_window, period)
            c = compromised_fraction_residue(n_window, period)
            aligned = (a == Fraction(period - 1, period))
            envelope = (a <= Fraction(period - 1, period)
                        + Fraction(period - 1, period * n_window))
            assert a == b == c, "the three formulas must agree exactly"
            assert aligned == (n_window % period == 0), "alignment criterion"
            print(f"   {n_window:2d} | {str(a):>10} | {str(b):>18} | {str(c):>24} |"
                  f" {str(aligned):>7} | {envelope}")

    print("\n  Monitoring Dichotomy:")
    for n_window in (1, 5, 9, 20):
        zero = compromised_fraction_enumerated(n_window, 1)
        worst = min(compromised_fraction_enumerated(n_window, k) for k in range(2, 8))
        print(f"    N = {n_window:2d}:  k = 1 gives {zero};   min over 2 <= k <= 7 gives "
              f"{worst}  (>= 1/2: {worst >= Fraction(1, 2)})")


# ---------------------------------------------------------------------------
# 6. Rewinding, heavy rows and extraction
# ---------------------------------------------------------------------------


def row_fraction(challenges: Sequence[Seed], acc_row: Callable[[Seed], bool]) -> Rat:
    """The accepting fraction of a single row."""
    return frac(challenges, acc_row)


def global_fraction(
    randomness: Sequence[Seed],
    challenges: Sequence[Seed],
    acc: Callable[[Seed, Seed], bool],
) -> Rat:
    """The accepting fraction of the product seed space R x C."""
    grid = [(r, c) for r in randomness for c in challenges]
    return frac(grid, lambda p: acc(p[0], p[1]))


def find_extractable_row(
    randomness: Sequence[Seed],
    challenges: Sequence[Seed],
    acc: Callable[[Seed, Seed], bool],
) -> Optional[Tuple[Seed, Seed, Seed]]:
    """A randomness accepting two distinct challenges, if one exists."""
    for r in randomness:
        good = [c for c in challenges if acc(r, c)]
        if len(good) >= 2:
            return (r, good[0], good[1])
    return None


def demo_rewinding() -> None:
    print()
    print("=" * 78)
    print("6. REWINDING: ROW AVERAGING, THE 1/|C| THRESHOLD, HEAVY ROWS")
    print("=" * 78)

    randomness = list(range(4))
    challenges = list(range(4))
    acc = lambda r, c: (r + c) % 4 != 1        # an arbitrary accepting configuration

    e = global_fraction(randomness, challenges, acc)
    rows = [row_fraction(challenges, lambda c, r=r: acc(r, c)) for r in randomness]
    avg = sum(rows, Fraction(0)) / len(randomness)
    print(f"  |R| = {len(randomness)}, |C| = {len(challenges)}")
    print(f"  row fractions       = {[str(x) for x in rows]}")
    print(f"  global fraction e   = {e}")
    print(f"  average of rows     = {avg}   equal -> {e == avg}")

    print(f"\n  rewinding threshold 1/|C| = {Fraction(1, len(challenges))}; e = {e}")
    if e > Fraction(1, len(challenges)):
        witness = find_extractable_row(randomness, challenges, acc)
        print(f"    e exceeds the threshold, so an extractable row must exist: {witness}")

    # sharpness: exactly one accepting challenge per row
    phi = lambda r: r % len(challenges)
    acc_sharp = lambda r, c: c == phi(r)
    e_sharp = global_fraction(randomness, challenges, acc_sharp)
    print(f"\n  sharpness configuration acc(r,c) <=> c = phi(r):")
    print(f"    global fraction   = {e_sharp} = 1/|C| -> "
          f"{e_sharp == Fraction(1, len(challenges))}")
    print(f"    extractable row   = {find_extractable_row(randomness, challenges, acc_sharp)}"
          "  (none: the strict inequality cannot be weakened)")

    # heavy-row lemma, checked exhaustively over ALL configurations of a 3 x 3 grid
    print("\n  Heavy-Row Splitting Lemma, exhaustive check on every accepting set")
    print("  of a 3 x 3 grid (2^9 = 512 configurations), for several alpha:")
    rr = list(range(3))
    cc = list(range(3))
    cells = [(r, c) for r in rr for c in cc]
    for alpha in (Fraction(1, 4), Fraction(1, 3), Fraction(1, 2), Fraction(2, 3)):
        violations = 0
        slack_min: Optional[Rat] = None
        for mask in range(1 << len(cells)):
            table = {cells[i]: bool(mask >> i & 1) for i in range(len(cells))}
            acc_m = lambda r, c, table=table: table[(r, c)]
            e_m = global_fraction(rr, cc, acc_m)
            heavy = frac(rr, lambda r, e_m=e_m, acc_m=acc_m:
                         row_fraction(cc, lambda c, r=r: acc_m(r, c)) >= alpha * e_m)
            slack = heavy - (1 - alpha) * e_m
            if slack < 0:
                violations += 1
            if slack_min is None or slack < slack_min:
                slack_min = slack
        print(f"    alpha = {str(alpha):>4}: violations = {violations};"
              f"  minimal slack over all 512 configurations = {slack_min}")

    print("\n  Quantitative rewinding: e > 2/|C| forces an e/2 fraction of heavy rows,")
    print("  each of which is individually extractable.")
    threshold = Fraction(2, len(challenges))
    print(f"    2/|C| = {threshold};  e = {e};  above threshold -> {e > threshold}")
    if e > threshold:
        heavy_rows = [r for r in randomness
                      if row_fraction(challenges, lambda c, r=r: acc(r, c)) >= e / 2]
        print(f"    heavy rows = {heavy_rows}; heavy fraction = "
              f"{Fraction(len(heavy_rows), len(randomness))} >= e/2 = {e/2}")


def main() -> None:
    demo_calculus()
    demo_level_sets()
    demo_bounded_search()
    demo_amplification()
    demo_monitoring()
    demo_rewinding()
    print()
    print("=" * 78)
    print("All identities above are exact equalities between rational numbers.")
    print("=" * 78)


if __name__ == "__main__":
    main()
