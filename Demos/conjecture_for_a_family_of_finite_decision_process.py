"""
The Dimension Spectrum of Truth — numerical demonstrations.

Statements of length n are bit strings in {0,1}^n.  A *theory* assigns to each
length n a set of accepted strings T_n.  Its fractal (box-counting) dimension is

    dim T = limsup_n  log2 |T_n| / n.

For the *periodic density theory* D(m, R) — coordinate i is free iff i mod m is
in R, and frozen (forced to 0) otherwise — the development proves:

    (1) exact counting law        |D(m,R)_n| = 2 ** F(n),   F(n) = #{i<n : i%m in R}
    (2) period relation           F(n+m) = F(n) + |R|
    (3) two-sided sandwich        |R|*floor(n/m) <= F(n) <= |R|*floor(n/m) + |R|
    (4) quantitative convergence  | F(n)/n - |R|/m |  <=  |R| / n
    (5) Density Theorem           dim D(m,R) = |R| / m
    (6) Realization Theorem       every rational p/q in [0,1] is a dimension,
                                  realized by D(q, {0,...,p-1})
    (7) monotonicity              T subset T'  =>  dim T <= dim T'
    (8) universal bounds          0 <= dim T <= 1, both attained

This script verifies all of them numerically, by brute-force enumeration at
small lengths and by the closed forms at large ones.

Run:  python3 demo.py          (pure standard library, no dependencies)
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import log2, floor, gcd
from typing import Dict, Iterator, List, Set, Tuple


# --------------------------------------------------------------------------
# Core definitions
# --------------------------------------------------------------------------

def is_free(i: int, m: int, R: Set[int]) -> bool:
    """Coordinate i is information-bearing iff its residue mod m is admissible."""
    return (i % m) in R


def enumerate_level(n: int, m: int, R: Set[int]) -> Iterator[Tuple[int, ...]]:
    """Brute-force enumeration of level n of the periodic density theory D(m,R)."""
    choices: List[Tuple[int, ...]] = [
        (0, 1) if is_free(i, m, R) else (0,) for i in range(n)
    ]
    yield from product(*choices)


def count_bruteforce(n: int, m: int, R: Set[int]) -> int:
    """|D(m,R)_n| computed by enumerating every accepted string."""
    return sum(1 for _ in enumerate_level(n, m, R))


def free_count_naive(n: int, m: int, R: Set[int]) -> int:
    """F(n) = #{ i < n : i mod m in R }, computed directly.  O(n)."""
    return sum(1 for i in range(n) if is_free(i, m, R))


def free_count_closed(n: int, m: int, R: Set[int]) -> int:
    """F(n) via the closed form  |R|*floor(n/m) + #{r in R : r < n mod m}.  O(|R|)."""
    q, s = divmod(n, m)
    return len(R) * q + sum(1 for r in R if r < s)


def count_exact(n: int, m: int, R: Set[int]) -> int:
    """|D(m,R)_n| = 2 ** F(n), the exact counting law (no enumeration)."""
    return 2 ** free_count_closed(n, m, R)


def dim_estimate(n: int, m: int, R: Set[int]) -> Fraction:
    """Finite-scale estimate log2(count)/n, which equals the exact rational F(n)/n."""
    if n == 0:
        return Fraction(0)
    return Fraction(free_count_closed(n, m, R), n)


def dim_estimate_via_log(n: int, m: int, R: Set[int]) -> float:
    """The same estimate computed the 'naive' way, through a floating-point log."""
    if n == 0:
        return 0.0
    c = count_exact(n, m, R)
    return (0.0 if c == 0 else log2(c)) / n


def box_dimension(m: int, R: Set[int]) -> Fraction:
    """dim D(m,R) = |R| / m  (Density Theorem)."""
    return Fraction(len(R), m)


def sandwich_bounds(n: int, m: int, R: Set[int]) -> Tuple[int, int]:
    """The proved two-sided bounds  |R|*floor(n/m) <= F(n) <= |R|*floor(n/m) + |R|."""
    lo = len(R) * (n // m)
    return lo, lo + len(R)


def certified_length(m: int, R: Set[int], eps: Fraction) -> int:
    """Smallest n guaranteeing |estimate(n) - dim| <= eps, from the O(1/n) bound."""
    if len(R) == 0:
        return 1
    return max(1, floor(Fraction(len(R)) / eps) + 1)


def realize_rational(p: int, q: int) -> Tuple[int, Set[int]]:
    """Realization Theorem: D(q, {0,...,p-1}) has dimension exactly p/q."""
    assert 0 <= p <= q and q >= 1
    return q, set(range(p))


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_counting_law() -> None:
    print("=" * 74)
    print("1. EXACT COUNTING LAW:  |D(m,R)_n| = 2^F(n)")
    print("=" * 74)
    print("   Brute-force enumeration vs. the closed formula.\n")
    for (m, R) in [(2, {0}), (3, {0, 1}), (4, {1, 3}), (5, {0})]:
        print(f"   m = {m}, R = {sorted(R)}   (predicted dimension {len(R)}/{m})")
        header = "     n : " + "".join(f"{n:>7d}" for n in range(9))
        print(header)
        brute = [count_bruteforce(n, m, R) for n in range(9)]
        exact = [count_exact(n, m, R) for n in range(9)]
        free = [free_count_closed(n, m, R) for n in range(9)]
        print("  F(n) : " + "".join(f"{f:>7d}" for f in free))
        print(" brute : " + "".join(f"{c:>7d}" for c in brute))
        print(" 2^F(n): " + "".join(f"{c:>7d}" for c in exact))
        assert brute == exact, "counting law failed"
        print("     -> agreement at every length. OK\n")


def demo_period_and_sandwich() -> None:
    print("=" * 74)
    print("2. PERIOD RELATION  F(n+m) = F(n) + |R|   AND THE TWO-SIDED SANDWICH")
    print("=" * 74)
    m, R = 7, {0, 2, 5}
    print(f"   m = {m}, R = {sorted(R)}, |R| = {len(R)}\n")
    print("      n   F(n)  F(n+m)  F(n)+|R|   lower <= F(n) <= upper")
    for n in range(0, 30, 3):
        f = free_count_closed(n, m, R)
        f_shift = free_count_closed(n + m, m, R)
        lo, hi = sandwich_bounds(n, m, R)
        assert f_shift == f + len(R), "period relation failed"
        assert lo <= f <= hi, "sandwich failed"
        print(f"   {n:4d}  {f:5d}  {f_shift:6d}  {f + len(R):8d}      {lo:3d} <= {f:3d} <= {hi:3d}")
    print("\n   -> period relation and sandwich hold at every tested n. OK\n")


def demo_convergence() -> None:
    print("=" * 74)
    print("3. QUANTITATIVE CONVERGENCE:  |F(n)/n - |R|/m|  <=  |R|/n")
    print("=" * 74)
    m, R = 7, {0, 1, 2}
    d = box_dimension(m, R)
    print(f"   Theory D({m}, {sorted(R)}),  dimension = {d} = {float(d):.9f}\n")
    print("        n     estimate F(n)/n      float log2 route     |error|      bound |R|/n")
    for n in [1, 2, 5, 10, 100, 1_000, 10_000, 100_000, 1_000_000]:
        est = dim_estimate(n, m, R)
        err = abs(est - d)
        bound = Fraction(len(R), n)
        via_log = dim_estimate_via_log(n, m, R) if n <= 10_000 else float("nan")
        assert err <= bound, "convergence bound violated"
        log_str = f"{via_log:>18.12f}" if n <= 10_000 else " " * 12 + "(skipped)"
        print(f"   {n:8d}   {float(est):>16.12f} {log_str}   {float(err):.3e}   {float(bound):.3e}")
    print("\n   -> the certified error bar |R|/n always dominates the true error. OK\n")


def demo_rational_spectrum() -> None:
    print("=" * 74)
    print("4. REALIZATION THEOREM: every rational in [0,1] is a dimension")
    print("=" * 74)
    print("   For each target p/q we build D(q, {0,...,p-1}) and measure it.\n")
    print("     target      m   R                     dim      estimate n=20000    error")
    targets = [(0, 1), (1, 5), (1, 3), (3, 7), (1, 2), (5, 8), (2, 3), (9, 10), (1, 1)]
    for (p, q) in targets:
        m, R = realize_rational(p, q)
        d = box_dimension(m, R)
        assert d == Fraction(p, q), "realization failed"
        n = 20_000
        est = dim_estimate(n, m, R)
        rs = "{" + ",".join(str(r) for r in sorted(R)[:5]) + ("...}" if len(R) > 5 else "}")
        if not R:
            rs = "{}"
        print(f"     {p:>2d}/{q:<3d}   {m:>3d}   {rs:<20s} {str(d):>6s}   {float(est):>16.10f}   {float(abs(est - d)):.2e}")
    print("\n   -> every rational target is realized exactly. OK\n")


def demo_landmarks_and_bounds() -> None:
    print("=" * 74)
    print("5. LANDMARK VALUES AND SHARPNESS OF 0 <= dim <= 1")
    print("=" * 74)
    landmarks: List[Tuple[str, int, Set[int], Fraction]] = [
        ("full space  (every coordinate free)", 1, {0}, Fraction(1)),
        ("half-information theory", 2, {0}, Fraction(1, 2)),
        ("single statement per length", 1, set(), Fraction(0)),
    ]
    for name, m, R, expected in landmarks:
        d = box_dimension(m, R)
        assert d == expected
        n = 12
        c = count_exact(n, m, R)
        assert c == count_bruteforce(n, m, R)
        print(f"   {name:<40s} dim = {str(d):>4s}   |level 12| = {c}")
    print("\n   Both endpoints of [0,1] are attained, so the universal bounds are sharp. OK\n")


def demo_monotonicity() -> None:
    print("=" * 74)
    print("6. MONOTONICITY:  T subset T'  =>  dim T <= dim T'")
    print("=" * 74)
    m = 12
    print(f"   Nested residue sets modulo m = {m}: each frees one more class.\n")
    print("      R                                   dim     level-24 count   nested?")
    prev_level: Set[Tuple[int, ...]] | None = None
    prev_dim = Fraction(-1)
    for k in range(0, m + 1, 2):
        R = set(range(k))
        d = box_dimension(m, R)
        level = set(enumerate_level(12, m, R))
        nested = "-" if prev_level is None else ("yes" if prev_level <= level else "NO")
        assert prev_dim <= d
        if prev_level is not None:
            assert prev_level <= level, "inclusion failed"
        rs = "{" + ",".join(str(r) for r in sorted(R)) + "}"
        print(f"   {rs:<35s} {str(d):>5s}   {count_exact(24, m, R):>14d}   {nested}")
        prev_level, prev_dim = level, d
    print("\n   -> dimensions increase along the chain of inclusions. OK\n")


def demo_identity_blindness() -> None:
    print("=" * 74)
    print("7. DIMENSION SEES ONLY HOW MANY COORDINATES ARE FREE, NOT WHICH")
    print("=" * 74)
    m = 5
    from itertools import combinations
    print("   Counts at intermediate lengths DO depend on which residues are free,")
    print("   but they coincide at every multiple of the period, and so do the dimensions.\n")
    for k in range(m + 1):
        sets = [set(R) for R in combinations(range(m), k)]
        # counts at multiples of the period are identical across all choices of R
        counts_at_periods = {tuple(count_exact(m * q, m, R) for q in range(5)) for R in sets}
        dims = {box_dimension(m, R) for R in sets}
        # spread of the finite estimates at a non-multiple length
        spread = {free_count_closed(7, m, R) for R in sets}
        assert len(counts_at_periods) == 1 and len(dims) == 1
        assert max(spread) - min(spread) <= k, "sandwich gap exceeded"
        print(f"   |R| = {k}: all C({m},{k}) = {len(sets):>2d} residue sets share dimension "
              f"{str(dims.pop()):>5s}, identical counts at n = 0,5,10,15,20,"
              f" and F(7) spread {min(spread)}..{max(spread)} (<= |R| = {k})")
    print("\n   -> only the cardinality |R| matters asymptotically; this is why every")
    print("      rational is hit. OK\n")


def demo_compression_reading() -> None:
    print("=" * 74)
    print("8. DIMENSION AS A COMPRESSION RATIO")
    print("=" * 74)
    print("   An accepted string of length n is determined by its F(n) free bits,")
    print("   so membership in the theory is a lossless code of ratio ~ dim.\n")
    m, R = 8, {0, 3, 6}
    n = 64
    F = free_count_closed(n, m, R)
    d = box_dimension(m, R)
    sample = tuple(1 if is_free(i, m, R) and i % 3 == 0 else 0 for i in range(n))
    packed = tuple(sample[i] for i in range(n) if is_free(i, m, R))
    restored = [0] * n
    j = 0
    for i in range(n):
        if is_free(i, m, R):
            restored[i] = packed[j]
            j += 1
    assert tuple(restored) == sample, "round-trip failed"
    print(f"   theory D({m}, {sorted(R)}),  dimension {d} = {float(d):.4f}")
    print(f"   nominal length      n = {n} bits")
    print(f"   free coordinates F(n) = {F} bits")
    print(f"   realized ratio        = {F}/{n} = {F / n:.4f}   (asymptotically {float(d):.4f})")
    print(f"   original : {''.join(map(str, sample))}")
    print(f"   packed   : {''.join(map(str, packed))}")
    print("   round-trip decode reproduces the original exactly. OK\n")


def demo_limsup_needed() -> None:
    print("=" * 74)
    print("9. WHY limsup AND NOT lim: AN OSCILLATING (APERIODIC) THEORY")
    print("=" * 74)
    print("   Free a coordinate i iff floor(log2(i+1)) is even: long alternating blocks.\n")

    def free_osc(i: int) -> bool:
        return (i + 1).bit_length() % 2 == 0

    prefix: List[int] = [0]
    for i in range(1, 2 ** 22):
        prefix.append(prefix[-1] + (1 if free_osc(i) else 0))
    print("           n      estimate F(n)/n")
    lo, hi = 1.0, 0.0
    for e in range(2, 22):
        n = 2 ** e
        est = prefix[n] / n
        lo, hi = min(lo, est), max(hi, est)
        print(f"   {n:9d}      {est:.6f}")
    print(f"\n   estimates oscillate in about [{lo:.3f}, {hi:.3f}] and never settle:")
    print("   the limit does not exist, but the limsup does. OK\n")


def main() -> None:
    print()
    print("#" * 74)
    print("#  THE DIMENSION SPECTRUM OF TRUTH — numerical demonstrations")
    print("#" * 74)
    print()
    demo_counting_law()
    demo_period_and_sandwich()
    demo_convergence()
    demo_rational_spectrum()
    demo_landmarks_and_bounds()
    demo_monotonicity()
    demo_identity_blindness()
    demo_compression_reading()
    demo_limsup_needed()
    print("=" * 74)
    print("All demonstrations completed; every asserted identity and bound held.")
    print("=" * 74)


if __name__ == "__main__":
    main()
