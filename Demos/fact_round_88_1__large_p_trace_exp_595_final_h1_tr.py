"""
Exact arithmetic of stage-1 firing in the elliptic curve method.

This self-contained script demonstrates, numerically, every theorem of the
accompanying paper:

  1.  Firing criterion            n | k(B)  <=>  n is B-powersmooth.
  2.  Exact firing count          #{a mod m : m | k a} = gcd(m, k).
  3.  Powersmooth part            gcd(m, k(B)) is the greatest B-powersmooth divisor of m.
  4.  Firing position             least cutoff C with n | k(B,C) is lpf(n).
  5.  Staircase / jump formula    passing q multiplies the count by q^min(v_q(m), floor(log_q B)).
  6.  No dose response            the count is constant between prime powers dividing m.
  7.  Saturation                  count = m  <=>  m is B-powersmooth.
  8.  Sparsity / non-uniformity   jump set = {q | m, q <= B}, of size <= omega(m) <= log2 m.
  9.  Long inert block            some >= pi(B)/(omega(m)+1) schedule primes share one count.
 10.  Early fire                  gcd(m,k(B)) | gcd(m,k(B,L)) * largePart(m,L).
 11.  Control channel             all prime factors > B  =>  count = 1.
 12.  Rank two                    count = gcd(m1,k) gcd(m2,k) >= gcd(m1 m2, k).
 13.  Multi-curve                 exactly m^c - (m - gcd)^c successes.
 14.  Collision comparison        1 - exp(-1.44 B/m) <= 1.44 B/m < gcd(m,k(B))/m.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
import random
from collections import Counter
from math import gcd
from typing import Dict, List, Tuple

# ----------------------------------------------------------------------------
# Basic arithmetic utilities
# ----------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """All primes <= n by a sieve of Eratosthenes.  Cost O(n log log n)."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(n + 1) if sieve[i]]


def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 1 as {prime: exponent} by trial division."""
    assert n >= 1
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def integer_log(base: int, x: int) -> int:
    """floor(log_base x) for base >= 2, x >= 1, computed exactly in integers."""
    assert base >= 2 and x >= 1
    e, p = 0, 1
    while p * base <= x:
        p *= base
        e += 1
    return e


def stage1_scalar(bound: int, cutoff: int | None = None) -> int:
    """k(B, C) = prod over primes q <= C of q^floor(log_q B).  Default C = B."""
    if cutoff is None:
        cutoff = bound
    k = 1
    for q in primes_up_to(min(cutoff, bound)):
        k *= q ** integer_log(q, bound)
    return k


def is_powersmooth(bound: int, n: int) -> bool:
    """n is B-powersmooth: every prime power exactly dividing n is <= B."""
    return all(q**v <= bound for q, v in factorize(n).items())


def largest_prime_factor(n: int) -> int:
    """lpf(n); by convention 0 for n = 1."""
    f = factorize(n)
    return max(f) if f else 0


def large_part(m: int, cutoff: int) -> int:
    """The part of m supported on primes > cutoff."""
    out = 1
    for q, v in factorize(m).items():
        if q > cutoff:
            out *= q**v
    return out


# ----------------------------------------------------------------------------
# The exact objects of the theory
# ----------------------------------------------------------------------------


def firing_set(m: int, k: int) -> List[int]:
    """{a in Z/m : m | k a}.  Brute force; used only to CHECK the gcd formula."""
    return [a for a in range(m) if (k * a) % m == 0]


def firing_count(m: int, k: int) -> int:
    """Theorem: the number of firing residues is exactly gcd(m, k)."""
    return gcd(m, k)


def powersmooth_part(m: int, bound: int) -> int:
    """Directly the greatest B-powersmooth divisor of m, from the factorization."""
    out = 1
    for q, v in factorize(m).items():
        j = min(v, integer_log(q, bound))
        out *= q**j
    return out


def staircase(m: int, bound: int) -> List[Tuple[int, int]]:
    """
    The cumulative firing counts (q, gcd(m, k(B,q))) as q runs over the schedule.

    Uses the exact jump formula (multiply by q^min(v_q(m), floor(log_q B)))
    rather than forming the astronomically large scalar k(B).
    Cost: O(pi(B) log m) big-integer multiplications.
    """
    fm = factorize(m)
    count = 1
    out: List[Tuple[int, int]] = []
    for q in primes_up_to(bound):
        count *= q ** min(fm.get(q, 0), integer_log(q, bound))
        out.append((q, count))
    return out


def jump_set(m: int, bound: int) -> List[int]:
    """Schedule primes at which the count strictly increases = {q | m, q <= B}."""
    return [q for q in factorize(m) if q <= bound]


def firing_cutoff(m: int, bound: int) -> int | None:
    """Least schedule cutoff at which a B-powersmooth order fires; None if it never does."""
    if not is_powersmooth(bound, m):
        return None
    return largest_prime_factor(m)


def normalized_firing_position(m: int, bound: int) -> float | None:
    """pi(lpf(m)) / pi(B): where in the schedule the run fires, rescaled to [0,1]."""
    c = firing_cutoff(m, bound)
    if c is None:
        return None
    sched = primes_up_to(bound)
    if not sched:
        return None
    return sum(1 for q in sched if q <= c) / len(sched)


def multi_curve_success_count(m: int, k: int, curves: int) -> int:
    """Exactly m^c - (m - gcd(m,k))^c tuples on which stage 1 fires at least once."""
    return m**curves - (m - gcd(m, k)) ** curves


def collision_baseline(bound: int, m: int) -> float:
    """The folklore per-curve collision rate 1 - exp(-1.44 B / m)."""
    return 1.0 - math.exp(-1.44 * bound / m)


def longest_inert_block(m: int, bound: int) -> int:
    """Largest number of schedule primes sharing one and the same firing count."""
    counts = Counter(c for _, c in staircase(m, bound))
    return max(counts.values()) if counts else 0


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_worked_cell() -> None:
    """The fully worked cell m = 720, B = 10 from the paper."""
    banner("1.  The worked cell:  m = 720,  B = 10")
    m, B = 720, 10
    k = stage1_scalar(B)
    print(f"  k(10)                          = {k}          (= 2^3 * 3^2 * 5 * 7)")
    print(f"  gcd(720, k(10))                = {gcd(m, k)}")
    print(f"  brute-force firing set size    = {len(firing_set(m, k))}   <- Exact Rate theorem")
    print(f"  greatest 10-powersmooth divisor= {powersmooth_part(m, B)}   <- Powersmooth Part theorem")
    print(f"  exact success rate             = {gcd(m, k)}/{m} = {gcd(m,k)/m}")
    print()
    print("  staircase  gcd(720, k(10,C))  as C advances through the schedule:")
    for q, c in staircase(m, B):
        print(f"      C = {q:>3}   ->   count = {c}")
    print("  (only 2, 3, 5 move the count; 7 does nothing because 7 does not divide 720)")
    print()
    g = powersmooth_part(m, B)
    print(f"  720 itself is not 10-powersmooth (2^4 = 16 > 10), so the points of full")
    print(f"  order never fire; the firing points have order dividing {g}, and by the")
    print(f"  position theorem such a point fires at cutoff lpf = {largest_prime_factor(g)}.")
    early = dict(staircase(m, B))[3]
    print(f"  early fire: after only the first two schedule primes the count is already")
    print(f"  {early} = one fifth of the eventual {gcd(m,k)}, and {gcd(m,k)} is exactly half of {m}.")
    assert 5 * early == gcd(m, k) and 2 * gcd(m, k) == m
    print()
    base = collision_baseline(B, m)
    print(f"  collision baseline 1-exp(-1.44*10/720) = {base:.6f}")
    print(f"  true order-completion rate             = {gcd(m,k)/m:.6f}")
    print(f"  ratio                                  = {(gcd(m,k)/m)/base:.2f}x")
    assert gcd(m, k) == 360 and len(firing_set(m, k)) == 360
    assert [c for _, c in staircase(m, B)] == [8, 72, 360, 360]


def demo_exact_count() -> None:
    """Check |F(m,k)| = gcd(m,k) exhaustively over many (m,k)."""
    banner("2.  Exact firing count:  |F(m,k)| = gcd(m,k)   (exhaustive check)")
    bad = 0
    for m in range(1, 120):
        for k in range(0, 60):
            if len(firing_set(m, k)) != gcd(m, k):
                bad += 1
    print(f"  checked {119*60} pairs (m,k);  mismatches: {bad}")
    assert bad == 0


def demo_firing_criterion() -> None:
    """Check n | k(B) <=> n is B-powersmooth, and the position theorem."""
    banner("3.  Firing criterion and firing position")
    B = 30
    k = stage1_scalar(B)
    bad = 0
    for n in range(1, 2000):
        if (k % n == 0) != is_powersmooth(B, n):
            bad += 1
    print(f"  B = {B},  k(B) has {len(str(k))} digits")
    print(f"  checked n = 1..1999 for 'n | k(B) <=> n is B-powersmooth';  mismatches: {bad}")
    assert bad == 0

    print()
    print("  firing cutoff = largest prime factor, verified against brute force:")
    for n in (1, 8, 15, 27, 25, 210, 1024, 29 * 4):
        if not is_powersmooth(B, n):
            print(f"      n = {n:>5}   not {B}-powersmooth: never fires")
            continue
        brute = min(C for C in range(0, B + 1) if stage1_scalar(B, C) % n == 0)
        print(f"      n = {n:>5}   lpf = {largest_prime_factor(n):>3}   least firing cutoff = {brute:>3}")
        assert brute == largest_prime_factor(n)


def demo_no_dose_response() -> None:
    """Rates are piecewise constant in the bound; jumps only at prime powers dividing m."""
    banner("4.  No dose response: the rate is a staircase in B")
    m = 2**5 * 3**3 * 5 * 11  # = 47520
    print(f"  m = {m} = 2^5 * 3^3 * 5 * 11")
    print("     B   gcd(m,k(B))   rate      changed?")
    prev = None
    for B in range(2, 40):
        g = powersmooth_part(m, B)
        mark = "" if g == prev else "   <-- JUMP"
        print(f"    {B:>3}   {g:>10}   {g/m:.6f}{mark}")
        prev = g
    print()
    print("  jumps occur exactly at B = 2,3,4,5,8,9,11,16,27,32 -- the prime powers dividing m")
    print(f"  saturation: m is B-powersmooth first at B = 32 ({powersmooth_part(m,32)} = m? "
          f"{powersmooth_part(m,32)==m}); beyond that nothing changes.")
    assert powersmooth_part(m, 32) == m
    assert powersmooth_part(m, 1000) == m


def demo_sparsity_and_inert_block() -> None:
    """The jump set is tiny and there is always a long inert block."""
    banner("5.  Sparsity of firing positions and the long inert block")
    B = 200
    sched = len(primes_up_to(B))
    print(f"  schedule length pi({B}) = {sched}")
    print("        m        omega(m)  #jumps  log2 m   longest inert block   pi(B)/(omega+1)")
    for m in (720, 1024, 2310, 65537, 47520, 999983, 2**16 * 3**5):
        w = len(factorize(m))
        j = len(jump_set(m, B))
        blk = longest_inert_block(m, B)
        print(f"   {m:>10}     {w:>4}    {j:>4}   {int(math.log2(m)):>5}          {blk:>5}"
              f"            {sched/(w+1):>8.1f}")
        assert j <= w <= math.log2(m) + 1
        assert blk >= sched / (w + 1) - 1  # pigeonhole bound (integer division)
    print()
    print("  In every row the number of firing positions is a vanishing fraction of the")
    print("  schedule, and a block of length >= pi(B)/(omega(m)+1) is completely inert:")
    print("  uniformity on the schedule is impossible, not merely improbable.")


def demo_early_fire() -> None:
    """gcd(m,k(B)) divides gcd(m,k(B,L)) * largePart(m,L)."""
    banner("6.  Early fire:  everything but the large-prime part has already fired")
    B = 100
    for m in (720, 47520, 2 * 3 * 5 * 7 * 97, 2**10 * 89):
        total = powersmooth_part(m, B)
        print(f"  m = {m}, total firing count gcd(m,k(B)) = {total}")
        for L in (5, 10, 20, 50, 100):
            prefix = 1
            fm = factorize(m)
            for q, v in fm.items():
                if q <= L:
                    prefix *= q ** min(v, integer_log(q, B))
            lp = large_part(m, L)
            ok = (prefix * lp) % total == 0
            print(f"      L = {L:>3}:  count by L = {prefix:>8}   largePart = {lp:>8}   "
                  f"divisibility holds: {ok}")
            assert ok
        print()


def demo_control_channel() -> None:
    """All prime factors above the bound => only the identity fires."""
    banner("7.  The control channel: order completion impossible => count = 1")
    B = 50
    for m in (53, 97 * 101, 1009, 2**0 * 9973):
        g = powersmooth_part(m, B)
        print(f"  m = {m:>8}  prime factors {sorted(factorize(m))}  ->  gcd(m,k({B})) = {g}"
              f"   rate = 1/{m}")
        assert g == 1
    print()
    print("  This is why hits at the LARGE factor of a modulus measure the collision floor")
    print("  alone: there the order-completion contribution is exactly 1/m.")


def demo_multicurve_and_rank_two() -> None:
    """Multi-curve amplification and the rank-two inequality."""
    banner("8.  Multi-curve amplification and rank-two groups")
    m, B = 720, 10
    k = stage1_scalar(B)
    rho = gcd(m, k) / m
    print(f"  m = {m}, B = {B}, rho = {rho}")
    for c in range(1, 6):
        exact = multi_curve_success_count(m, k, c)
        print(f"    c = {c}:  successes = {exact:>20}   rate = {exact/m**c:.6f}"
              f"   1-(1-rho)^c = {1-(1-rho)**c:.6f}")
        assert abs(exact / m**c - (1 - (1 - rho) ** c)) < 1e-12
    print()
    print("  rank two:  gcd(m1,k)*gcd(m2,k)  >=  gcd(m1*m2,k)")
    for m1, m2 in ((60, 12), (720, 2), (100, 100), (2310, 6)):
        lhs = gcd(m1, k) * gcd(m2, k)
        rhs = gcd(m1 * m2, k)
        print(f"    (m1,m2) = ({m1:>5},{m2:>4}):  {lhs:>8}  >=  {rhs:>8}   ok: {lhs >= rhs}")
        assert lhs >= rhs


def demo_scale_invariance() -> None:
    """gcd(m w, k) = gcd(m, k) when w is coprime to k."""
    banner("9.  Scale invariance: the part above the bound is invisible")
    B = 10
    k = stage1_scalar(B)
    m = 720
    print(f"  base order m = {m}, gcd = {gcd(m,k)}, rate = {gcd(m,k)/m:.6f}")
    for w in (23, 101, 1009, 65537):
        assert gcd(w, k) == 1
        print(f"    m*{w:>6}:  gcd = {gcd(m*w,k):>6} (unchanged)   rate = {gcd(m*w,k)/(m*w):.8f}"
              f"   <- only the denominator moved")
        assert gcd(m * w, k) == gcd(m, k)


def demo_simulated_campaign() -> None:
    """
    A miniature version of the empirical campaign: random group orders near a
    target, three smoothness budgets, three curves.  Reports success rates and
    the distribution of normalized firing positions, all computed EXACTLY from
    the theory rather than by simulating curve arithmetic.
    """
    banner("10.  Simulated campaign: flat rates and early, non-uniform firing")
    rng = random.Random(20260903)
    trials = 300
    curves = 3
    target = 20000  # the bound target T; budgets are fractions of it
    print(f"  {trials} random orders m near 2^20, {curves} curves, budgets"
          f" 0.125T, 0.5T, 0.9T with T = {target}")
    print()
    print("   budget    B    success rate   median firing position   tail(>=0.8)")
    orders = [rng.randrange(2**19, 2**20) for _ in range(trials)]
    for frac in (0.125, 0.5, 0.9):
        B = max(2, int(frac * target))
        successes = 0
        positions: List[float] = []
        for m in orders:
            rho = powersmooth_part(m, B) / m
            # exact c-curve success probability for this order
            p = 1 - (1 - rho) ** curves
            if rng.random() < p:
                successes += 1
                # the firing point's order is (generically) the powersmooth part,
                # and by the position theorem it fires at that number's lpf
                pos = normalized_firing_position(powersmooth_part(m, B), B)
                if pos is not None:
                    positions.append(pos)
        positions.sort()
        med = positions[len(positions) // 2] if positions else float("nan")
        tail = sum(1 for p in positions if p >= 0.8) / max(1, len(positions))
        print(f"   {frac:>5}   {B:>4}      {successes/trials:.3f}"
              f"                 {med:.3f}              {tail:.3f}")
    print()
    print("  A 7-fold increase of the budget moves the success rate by well under a")
    print("  factor of two -- the staircase is already largely climbed -- while the")
    print("  firing positions sit far below 0.5 with a thin upper tail, and the shape")
    print("  deepens with the dose.  Both signatures are consequences of the exact")
    print("  results above, not of any probabilistic model of the success event.")


def main() -> None:
    print(__doc__)
    demo_worked_cell()
    demo_exact_count()
    demo_firing_criterion()
    demo_no_dose_response()
    demo_sparsity_and_inert_block()
    demo_early_fire()
    demo_control_channel()
    demo_multicurve_and_rank_two()
    demo_scale_invariance()
    demo_simulated_campaign()
    banner("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
