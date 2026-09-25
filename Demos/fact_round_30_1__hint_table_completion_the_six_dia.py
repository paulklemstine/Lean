#!/usr/bin/env python3
"""
The hint value of a sum/difference reading: numerical companion.

A *battery* is a finite list of samples x, each carrying a pair (P(x), Q(x)) of
residues in a finite commutative ring R and a label T(x).  All information
quantities are computed on the uniform empirical distribution over samples.

    capacity    I(T ; N)        with N = P * Q            (product reading)
    joint read  I(T ; (s, d))   with s = P + Q, d = P - Q  (sum/difference reading)
    hint value  I(T ; (s, d)) - I(T ; N)

This script demonstrates, with exact arithmetic on small batteries:

  1. the odd/even dichotomy: the hint value is never negative mod an odd n,
     never below -1 bit mod an even n, and -1 is attained at every even n;
  2. the collision witnesses realising -1 bit;
  3. the two-factor floor of -2 bits over Z/8 x Z/8, attained;
  4. the four corners: (capacity, hint) reaches all of {0,1}^2 over Z/5;
  5. the ceiling 2 log2 n and the budget  capacity + hint <= H(T);
  6. the six-dial table: totals, windows and the Pearson correlation;
  7. (exploratory) the largest product fibre M(n) behind the conjectured ceiling.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from collections import Counter
from typing import Callable, Hashable, List, Sequence, Tuple

Pair = Tuple[int, int]


# ---------------------------------------------------------------------------
# Empirical information theory (bits)
# ---------------------------------------------------------------------------

def entropy(values: Sequence[Hashable]) -> float:
    """Shannon entropy (bits) of the empirical distribution of `values`."""
    n = len(values)
    h = -sum((c / n) * math.log2(c / n) for c in Counter(values).values())
    return h + 0.0 if abs(h) > 1e-12 else 0.0


def mutual_information(labels: Sequence[Hashable], stat: Sequence[Hashable]) -> float:
    """I(T ; f) = H(T) + H(f) - H(T, f), on the uniform distribution over samples."""
    joint = list(zip(labels, stat))
    return max(0.0, entropy(labels) + entropy(stat) - entropy(joint))


# ---------------------------------------------------------------------------
# Readings of a battery over Z/n  (or a product of cyclic rings)
# ---------------------------------------------------------------------------

def product_view(P: Sequence, Q: Sequence, mul: Callable) -> List:
    return [mul(p, q) for p, q in zip(P, Q)]


def residue_view(P: Sequence, Q: Sequence, add: Callable, sub: Callable) -> List:
    return [(add(p, q), sub(p, q)) for p, q in zip(P, Q)]


def cyclic_ops(n: int) -> Tuple[Callable, Callable, Callable]:
    return (lambda a, b: (a + b) % n, lambda a, b: (a - b) % n, lambda a, b: (a * b) % n)


def product_ring_ops(n1: int, n2: int) -> Tuple[Callable, Callable, Callable]:
    add = lambda a, b: ((a[0] + b[0]) % n1, (a[1] + b[1]) % n2)
    sub = lambda a, b: ((a[0] - b[0]) % n1, (a[1] - b[1]) % n2)
    mul = lambda a, b: ((a[0] * b[0]) % n1, (a[1] * b[1]) % n2)
    return add, sub, mul


def capacity_and_hint(labels: Sequence[Hashable], P: Sequence, Q: Sequence,
                      ops: Tuple[Callable, Callable, Callable]) -> Tuple[float, float]:
    """Return (capacity I(T;N), hint value I(T;(s,d)) - I(T;N))."""
    add, sub, mul = ops
    cap = mutual_information(labels, product_view(P, Q, mul))
    joint = mutual_information(labels, residue_view(P, Q, add, sub))
    return cap, joint - cap


# ---------------------------------------------------------------------------
# 1. The odd/even dichotomy
# ---------------------------------------------------------------------------

def collision_witness(k: int) -> Tuple[List[int], List[int]]:
    """Two samples in Z/2k sharing (s,d) but with different products."""
    if k % 2 == 0:
        return [0, k], [1, k + 1]      # samples (0,1) and (k,k+1)
    return [0, k], [0, k]              # samples (0,0) and (k,k)


def random_min_hint(n: int, trials: int, rng: random.Random) -> float:
    """Minimum hint value over random batteries mod n (2..10 samples, 2..5 labels)."""
    ops = cyclic_ops(n)
    best = math.inf
    for _ in range(trials):
        m = rng.randint(2, 10)
        labels = [rng.randrange(rng.randint(2, 5)) for _ in range(m)]
        P = [rng.randrange(n) for _ in range(m)]
        Q = [rng.randrange(n) for _ in range(m)]
        best = min(best, capacity_and_hint(labels, P, Q, ops)[1])
    return best if abs(best) > 1e-12 else 0.0


def exhaustive_two_sample_min(n: int) -> float:
    """Exact minimum over all two-sample, two-label batteries mod n."""
    ops = cyclic_ops(n)
    best = math.inf
    for p0 in range(n):
        for q0 in range(n):
            for p1 in range(n):
                for q1 in range(n):
                    best = min(best, capacity_and_hint([0, 1], [p0, p1], [q0, q1], ops)[1])
    return best


def half_selector_is_sound(k: int) -> bool:
    """Check: in Z/2k, 2a = 2b and [a < k] = [b < k] force a = b."""
    n = 2 * k
    return all(a == b for a in range(n) for b in range(n)
               if (2 * a - 2 * b) % n == 0 and (a < k) == (b < k))


def section_dichotomy() -> None:
    print("=" * 72)
    print("1. THE ODD/EVEN DICHOTOMY")
    print("=" * 72)
    rng = random.Random(104)
    print(f"{'n':>4} {'parity':>7} {'exact min (2 samples)':>22} {'random min':>11} {'floor':>6}")
    for n in [5, 7, 8, 9, 10, 11, 12, 16, 23, 31]:
        exact = exhaustive_two_sample_min(n) if n <= 16 else float("nan")
        rnd = random_min_hint(n, 4000, rng)
        floor = 0 if n % 2 else -1
        ex = f"{exact:+.4f}" if not math.isnan(exact) else "   (skipped)"
        print(f"{n:>4} {'odd' if n % 2 else 'even':>7} {ex:>22} {rnd:>+11.4f} {floor:>+6d}")
    print("\nHalf-range selector sound for 2k = 2..40:",
          all(half_selector_is_sound(k) for k in range(1, 21)))
    print("\nCollision witnesses (distinct labels -> hint exactly -1 bit):")
    for k in [1, 2, 3, 4, 5, 6]:
        n = 2 * k
        P, Q = collision_witness(k)
        add, sub, mul = cyclic_ops(n)
        sd = residue_view(P, Q, add, sub)
        prods = product_view(P, Q, mul)
        _, h = capacity_and_hint([0, 1], P, Q, (add, sub, mul))
        print(f"  mod {n:>2}: samples {list(zip(P, Q))}, (s,d) = {sd}, products {prods}, hint {h:+.4f}")


# ---------------------------------------------------------------------------
# 2. Two even factors: the -2 bit floor
# ---------------------------------------------------------------------------

def section_square() -> None:
    print("\n" + "=" * 72)
    print("2. ONE NEGATIVE BIT PER EVEN FACTOR: Z/8 x Z/8")
    print("=" * 72)
    P = [(0, 0), (0, 4), (4, 0), (4, 4)]
    Q = [(1, 1), (1, 5), (5, 1), (5, 5)]
    ops = product_ring_ops(8, 8)
    add, sub, mul = ops
    print("  (s,d) readings:", residue_view(P, Q, add, sub))
    print("  products      :", product_view(P, Q, mul))
    cap, h = capacity_and_hint([0, 1, 2, 3], P, Q, ops)
    print(f"  capacity = {cap:.4f} bits, hint = {h:+.4f} bits  (floor -2 attained)")


# ---------------------------------------------------------------------------
# 3. The four corners over Z/5
# ---------------------------------------------------------------------------

def section_corners() -> None:
    print("\n" + "=" * 72)
    print("3. CAPACITY AND HINT ARE INDEPENDENT: THE FOUR CORNERS (mod 5)")
    print("=" * 72)
    ops = cyclic_ops(5)
    W = ([1, 1, 2, 2], [1, 2, 3, 1])     # samples (1,1),(1,2),(2,3),(2,1)
    C = ([1, 1, 1, 1], [1, 1, 2, 2])     # samples (1,1),(1,1),(1,2),(1,2)
    cases = [("constant labels, witness", [0, 0, 0, 0], W),
             ("labels 0,0,1,1, witness", [0, 0, 1, 1], W),
             ("labels 0,0,1,1, product-measurable", [0, 0, 1, 1], C),
             ("labels 0,1,2,3, witness", [0, 1, 2, 3], W)]
    for name, L, (P, Q) in cases:
        cap, h = capacity_and_hint(L, P, Q, ops)
        print(f"  {name:<38} capacity {cap:.4f}  hint {h:+.4f}  H(T) {entropy(L):.4f}")


# ---------------------------------------------------------------------------
# 4. Ceiling and budget
# ---------------------------------------------------------------------------

def section_budget() -> None:
    print("\n" + "=" * 72)
    print("4. CEILING 2 log2 n AND THE BUDGET capacity + hint <= H(T)")
    print("=" * 72)
    rng = random.Random(7)
    worst_ceiling, worst_budget, worst_floor = -math.inf, -math.inf, -math.inf
    for _ in range(20000):
        n = rng.choice([5, 8, 9, 11, 12])
        m = rng.randint(2, 12)
        L = [rng.randrange(rng.randint(2, 6)) for _ in range(m)]
        P = [rng.randrange(n) for _ in range(m)]
        Q = [rng.randrange(n) for _ in range(m)]
        cap, h = capacity_and_hint(L, P, Q, cyclic_ops(n))
        worst_ceiling = max(worst_ceiling, h - 2 * math.log2(n))
        worst_budget = max(worst_budget, cap + h - entropy(L))
        worst_floor = max(worst_floor, -cap - h + 0.0)
    print(f"  max (hint - 2 log2 n)       = {worst_ceiling:+.4f}  (must be <= 0)")
    print(f"  max (cap + hint - H(T))     = {worst_budget:+.2e}  (<= 0 up to rounding)")
    print(f"  max (-cap - hint)           = {worst_floor:+.2e}  (must be <= 0)")


# ---------------------------------------------------------------------------
# 5. The six-dial table
# ---------------------------------------------------------------------------

DIALS = [("C5@11", 11, 1.2062, 1.5896), ("F20@5", 5, 0.2920, 0.9538),
         ("S3a@31", 31, 1.0011, 0.5201), ("S3b@23", 23, 1.0008, 0.5121),
         ("D4@8", 8, 1.9999, 0.5032), ("A4@9", 9, 0.0015, 0.0120)]


def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    mx, my = sum(xs) / len(xs), sum(ys) / len(ys)
    cxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    cxx = sum((x - mx) ** 2 for x in xs)
    cyy = sum((y - my) ** 2 for y in ys)
    return cxy / math.sqrt(cxx * cyy)


def section_table() -> None:
    print("\n" + "=" * 72)
    print("5. THE SIX-DIAL TABLE AGAINST THE PROVED WINDOWS")
    print("=" * 72)
    print(f"  {'dial':<8}{'m':>4}{'capacity':>10}{'hint':>9}   window")
    for name, m, cap, h in DIALS:
        lo = 0.0 if m % 2 else -min(1.0, cap)
        hi = 2 * math.log2(m)
        ok = lo <= h <= hi
        law = "forced >= 0" if m % 2 else "NOT forced"
        print(f"  {name:<8}{m:>4}{cap:>10.4f}{h:>+9.4f}   [{lo:+.4f}, {hi:.3f}]  {'ok' if ok else 'VIOLATION'}  ({law})")
    caps = [d[2] for d in DIALS]
    hints = [d[3] for d in DIALS]
    r = pearson(caps, hints)
    print(f"\n  total hint = {sum(hints):.4f}, total capacity = {sum(caps):.4f}")
    print(f"  Pearson r = {r:.5f}, r^2 = {r * r:.5f}")


# ---------------------------------------------------------------------------
# 6. Exploratory: the largest product fibre (conjectured ceiling log2 M(n))
# ---------------------------------------------------------------------------

def largest_product_fibre(n: int) -> int:
    return max(Counter((p * q) % n for p in range(n) for q in range(n)).values())


def section_fibre() -> None:
    print("\n" + "=" * 72)
    print("6. EXPLORATORY: LARGEST PRODUCT FIBRE M(n)  (conjectured sup of hint = log2 M(n))")
    print("=" * 72)
    for n in [5, 7, 8, 9, 11, 12, 16]:
        M = largest_product_fibre(n)
        print(f"  n = {n:>2}: M(n) = {M:>3}   log2 M(n) = {math.log2(M):.4f}   2 log2 n = {2 * math.log2(n):.4f}")
    # the construction: one sample per pair of the zero fibre, all labels distinct
    n = 5
    pairs = [(p, q) for p in range(n) for q in range(n) if (p * q) % n == 0]
    P, Q = [a for a, _ in pairs], [b for _, b in pairs]
    cap, h = capacity_and_hint(list(range(len(pairs))), P, Q, cyclic_ops(n))
    print(f"  mod 5, zero fibre ({len(pairs)} pairs), distinct labels: capacity {cap:.4f}, hint {h:.4f}")


if __name__ == "__main__":
    section_dichotomy()
    section_square()
    section_corners()
    section_budget()
    section_table()
    section_fibre()
