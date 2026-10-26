#!/usr/bin/env python3
"""
Knee stability is equivalent to tail-exchangeability -- numerical companion.

A *demand multiset* D is a finite list of non-negative integers (order irrelevant).

  tail(D, t)  = #{ d in D : d > t }                 (upper-tail counting function)
  knee(D, g)  = least t >= 0 with tail(D, t) <= g    (knee at gate g)

This script checks, on hand-picked and random examples, every result of the paper:

  1. Galois connection      knee(D,g) <= t  <=>  tail(D,t) <= g
  2. Order statistic        knee(D,g) = g-th largest demand (0-indexed), 0 past the end
  3. All-gate theorem       knee(D,.) = knee(D',.) <=> tail(D,.) = tail(D',.)
                            <=> D and D' have the same positive demands
  4. Window theorem         knees agree for a <= g < a+w
                            <=> clamp_[a,a+w] tail(D,t) = clamp_[a,a+w] tail(D',t) for all t
  5. Naive closed band is false (explicit counterexample)
  6. Finite sweep           all-gate equality is decided by gates g < max(|D|,|D'|)
  7. Conjugate duality and the area identity  sum_{g<|D|} knee(D,g) = sum(D)
  8. Stability              (forall g: knee(D',g+k) <= knee(D,g)) <=> (forall t: tail(D',t) <= tail(D,t)+k)
                            contamination and merge bounds

Only the Python standard library is used.
"""
from __future__ import annotations

import random
from collections import Counter
from typing import Callable, Dict, List, Sequence, Tuple

Demands = Sequence[int]


# ---------------------------------------------------------------------------
# Core definitions
# ---------------------------------------------------------------------------

def tail(D: Demands, t: int) -> int:
    """Number of demands strictly greater than the threshold t."""
    return sum(1 for d in D if d > t)


def knee(D: Demands, g: int) -> int:
    """Least threshold t >= 0 exceeded by at most g demands (definition by search)."""
    t = 0
    while tail(D, t) > g:
        t += 1
    return t


def knee_order_statistic(D: Demands, g: int) -> int:
    """The g-th entry (0-indexed) of D sorted in decreasing order; 0 past the end."""
    s = sorted(D, reverse=True)
    return s[g] if g < len(s) else 0


def tail_profile(D: Demands) -> List[int]:
    """tail(D, t) for t = 0 .. max(D) (it is 0 from max(D) on)."""
    top = max(D, default=0)
    return [tail(D, t) for t in range(top + 1)]


def knee_profile(D: Demands, gates: int | None = None) -> List[int]:
    """knee(D, g) for g = 0 .. gates-1 (default |D|)."""
    n = len(D) if gates is None else gates
    return [knee(D, g) for g in range(n)]


def tail_from_histogram(hist: Dict[int, int], t: int) -> int:
    """Tail computed from a histogram {value: multiplicity} -- 'one histogram per corpus'."""
    return sum(c for v, c in hist.items() if v > t)


def clamp_band(a: int, w: int, x: int) -> int:
    """Clamp the count x to the band [a, a+w]."""
    return min(max(x, a), a + w)


def positive_part(D: Demands) -> Counter:
    return Counter(d for d in D if d > 0)


# ---------------------------------------------------------------------------
# Predicates corresponding to the theorems
# ---------------------------------------------------------------------------

def knees_agree_on_window(D: Demands, E: Demands, a: int, w: int) -> bool:
    return all(knee(D, g) == knee(E, g) for g in range(a, a + w))


def clamped_tails_agree(D: Demands, E: Demands, a: int, w: int) -> bool:
    top = max(max(D, default=0), max(E, default=0))
    return all(clamp_band(a, w, tail(D, t)) == clamp_band(a, w, tail(E, t))
               for t in range(top + 1))


def band_form_agrees(D: Demands, E: Demands, a: int, w: int) -> bool:
    """Below-band / above-band classification agrees and tails coincide in the open band."""
    top = max(max(D, default=0), max(E, default=0))
    for t in range(top + 1):
        x, y = tail(D, t), tail(E, t)
        if (x <= a) != (y <= a):
            return False
        if (x >= a + w) != (y >= a + w):
            return False
        if a < x < a + w and x != y:
            return False
    return True


def all_knees_agree(D: Demands, E: Demands) -> bool:
    gates = max(len(D), len(E)) + 3  # a few extra gates beyond the sweep bound
    return all(knee(D, g) == knee(E, g) for g in range(gates))


def all_tails_agree(D: Demands, E: Demands) -> bool:
    top = max(max(D, default=0), max(E, default=0)) + 2
    return all(tail(D, t) == tail(E, t) for t in range(top))


def random_demands(rng: random.Random, n_max: int = 7, v_max: int = 6) -> List[int]:
    return [rng.randint(0, v_max) for _ in range(rng.randint(0, n_max))]


def check(name: str, ok: bool) -> None:
    print(f"  [{'PASS' if ok else 'FAIL'}] {name}")
    if not ok:
        raise SystemExit(f"check failed: {name}")


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_running_example() -> None:
    print("\n=== 1. A running example ===")
    D = [7, 5, 5, 3, 1, 0]
    print(f"  D = {D}")
    print(f"  tail profile  t=0..7 : {[tail(D, t) for t in range(8)]}")
    print(f"  knee profile  g=0..7 : {[knee(D, g) for g in range(8)]}")
    print(f"  sorted decreasingly  : {sorted(D, reverse=True)}")
    check("knee = order statistic at every gate",
          all(knee(D, g) == knee_order_statistic(D, g) for g in range(10)))
    check("Galois connection on a 10x10 grid",
          all((knee(D, g) <= t) == (tail(D, t) <= g) for g in range(10) for t in range(10)))
    s = sum(knee(D, g) for g in range(len(D)))
    print(f"  area identity: sum of knees g<|D| = {s},  sum(D) = {sum(D)}")
    check("area identity", s == sum(D))


def demo_random_galois_and_order_statistic(rng: random.Random, trials: int = 2000) -> None:
    print("\n=== 2. Galois connection and order statistic (random) ===")
    ok_g = ok_o = True
    for _ in range(trials):
        D = random_demands(rng)
        for g in range(9):
            ok_o &= knee(D, g) == knee_order_statistic(D, g)
            for t in range(9):
                ok_g &= (knee(D, g) <= t) == (tail(D, t) <= g)
    check(f"Galois connection on {trials} random multisets", ok_g)
    check(f"order-statistic formula on {trials} random multisets", ok_o)


def demo_all_gates(rng: random.Random, trials: int = 4000) -> None:
    print("\n=== 3. All-gate theorem: knees <=> tails <=> positive demands ===")
    agree_count = 0
    ok = True
    for _ in range(trials):
        D, E = random_demands(rng, 5, 3), random_demands(rng, 5, 3)
        k, t, p = all_knees_agree(D, E), all_tails_agree(D, E), positive_part(D) == positive_part(E)
        ok &= (k == t == p)
        agree_count += k
    check(f"three-way equivalence on {trials} random pairs ({agree_count} agreeing pairs)", ok)
    D, E = [4, 2, 2], [0, 2, 4, 0, 2]
    print(f"  D = {D}, D' = {E}: knees agree? {all_knees_agree(D, E)}; multisets equal? {sorted(D) == sorted(E)}")
    check("zero demands are invisible to knees", all_knees_agree(D, E) and sorted(D) != sorted(E))


def demo_window(rng: random.Random, trials: int = 6000) -> None:
    print("\n=== 4. Window theorem: gate window <=> clamped count band ===")
    D, E = [9, 6, 4, 2], [8, 6, 4, 1, 1]
    a, w = 1, 2
    print(f"  D = {D}  knees {knee_profile(D, 6)}")
    print(f"  D'= {E}  knees {knee_profile(E, 6)}")
    print(f"  window gates {list(range(a, a + w))}: agree? {knees_agree_on_window(D, E, a, w)}")
    print(f"  clamped tails of D : {[clamp_band(a, w, tail(D, t)) for t in range(10)]}")
    print(f"  clamped tails of D': {[clamp_band(a, w, tail(E, t)) for t in range(10)]}")
    check("example satisfies both sides", knees_agree_on_window(D, E, a, w) and clamped_tails_agree(D, E, a, w))
    ok = True
    for _ in range(trials):
        D, E = random_demands(rng, 6, 4), random_demands(rng, 6, 4)
        a, w = rng.randint(0, 5), rng.randint(0, 4)
        lhs = knees_agree_on_window(D, E, a, w)
        ok &= lhs == clamped_tails_agree(D, E, a, w)
        if w > 0:
            ok &= lhs == band_form_agrees(D, E, a, w)
    check(f"window <=> clamp <=> band form on {trials} random instances", ok)


def demo_naive_band_false() -> None:
    print("\n=== 5. The naive closed-band formulation is false ===")
    D, E, a, b = [3], [2], 1, 1
    lhs = all(knee(D, g) == knee(E, g) for g in range(a, b + 1))
    naive = all(tail(D, t) == tail(E, t) for t in range(10) if a <= tail(D, t) <= b)
    print(f"  D={D}, D'={E}, gates [{a},{b}]: knees agree = {lhs}; naive band condition = {naive}")
    print(f"  at t = 2: tail(D,2) = {tail(D, 2)} lies in [1,1] but tail(D',2) = {tail(E, 2)}")
    check("naive formulation fails on the witness", lhs and not naive)
    w = b - a + 1
    check("the correct clamp formulation holds on the witness", clamped_tails_agree(D, E, a, w))


def demo_finite_sweep(rng: random.Random, trials: int = 3000) -> None:
    print("\n=== 6. A finite sweep of max(|D|,|D'|) gates decides everything ===")
    ok = True
    for _ in range(trials):
        D, E = random_demands(rng, 5, 3), random_demands(rng, 5, 3)
        m = max(len(D), len(E))
        sweep = all(knee(D, g) == knee(E, g) for g in range(m))
        ok &= sweep == all_knees_agree(D, E)
        ok &= all(knee(D, g) == 0 for g in range(len(D), len(D) + 5))
    check(f"sweep bound on {trials} random pairs", ok)


def demo_duality(rng: random.Random, trials: int = 2000) -> None:
    print("\n=== 7. Conjugate-partition duality and the area identity ===")
    ok = True
    for _ in range(trials):
        D = random_demands(rng, 8, 9)
        n, top = len(D), max(D, default=0)
        for t in range(top + 2):
            ok &= tail(D, t) == sum(1 for g in range(n) if t < knee(D, g))
        for g in range(n + 2):
            ok &= knee(D, g) == sum(1 for t in range(top) if g < tail(D, t))
        ok &= sum(knee(D, g) for g in range(n)) == sum(D)
        ok &= sum(tail(D, t) for t in range(top)) == sum(D)
    check(f"tail = conjugate of knees, knee = conjugate of tails, areas agree ({trials} trials)", ok)
    D = [5, 3, 3, 1]
    print("  Ferrers diagram of D = [5,3,3,1]: rows are knees, columns are tails")
    for g in range(len(D)):
        print("   " + "#" * knee(D, g) + f"   knee({g}) = {knee(D, g)}")
    print("   column heights:", [tail(D, t) for t in range(max(D))])


def demo_stability(rng: random.Random, trials: int = 3000) -> None:
    print("\n=== 8. Stability: gate shifts, contamination, merging ===")
    ok_shift = ok_cont = ok_merge = True
    for _ in range(trials):
        D, E = random_demands(rng, 6, 5), random_demands(rng, 6, 5)
        k = rng.randint(0, 3)
        G = max(len(D), len(E)) + 4
        T = max(max(D, default=0), max(E, default=0)) + 2
        left = all(knee(E, g + k) <= knee(D, g) for g in range(G))
        right = all(tail(E, t) <= tail(D, t) + k for t in range(T))
        ok_shift &= left == right
        P = D + E
        for g in range(G):
            ok_cont &= knee(D, g) <= knee(P, g) and knee(P, g + len(E)) <= knee(D, g)
            ok_merge &= max(knee(D, g), knee(E, g)) <= knee(P, g)
            for h in range(4):
                ok_merge &= knee(P, g + h) <= max(knee(D, g), knee(E, h))
    check("k-gate shift <=> uniform tail bound k", ok_shift)
    check("contamination by |E| demands moves knees by at most |E| gates", ok_cont)
    check("merge bounds max(kD(g),kE(g)) <= kDE(g) and kDE(g+h) <= max(kD(g),kE(h))", ok_merge)


def demo_one_histogram() -> None:
    print("\n=== 9. One histogram replaces a sweep ===")
    rng = random.Random(7)
    corpus = [int(1000 / (rng.random() ** 0.8 * 50 + 1)) for _ in range(5000)]
    hist = Counter(corpus)
    print(f"  synthetic heavy-tailed corpus: {len(corpus)} demands, {len(hist)} distinct values")
    gates = [0, 10, 50, 100, 500, 1000]
    srt = sorted(corpus, reverse=True)
    via_sweep = [knee(corpus, g) for g in gates]
    via_hist = []
    for g in gates:  # binary search on the histogram tail
        lo, hi = 0, max(hist)
        while lo < hi:
            mid = (lo + hi) // 2
            if tail_from_histogram(hist, mid) <= g:
                hi = mid
            else:
                lo = mid + 1
        via_hist.append(lo)
    print(f"  gates            : {gates}")
    print(f"  knees by search  : {via_sweep}")
    print(f"  knees from hist  : {via_hist}")
    print(f"  order statistics : {[srt[g] for g in gates]}")
    check("histogram, search and order statistic agree", via_sweep == via_hist == [srt[g] for g in gates])


def main() -> None:
    rng = random.Random(2026)
    demo_running_example()
    demo_random_galois_and_order_statistic(rng)
    demo_all_gates(rng)
    demo_window(rng)
    demo_naive_band_false()
    demo_finite_sweep(rng)
    demo_duality(rng)
    demo_stability(rng)
    demo_one_histogram()
    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
