"""
demo.py — Numerical demonstrations for the Collatz Sharp Contraction Threshold.

This script illustrates, with concrete numbers, the results formally verified in the
accompanying Lean development:

    * pow3_lt_pow2_iff_log         : 3^j < 2^m  <->  j*log3 < m*log2
    * pow3_lt_pow2_of_density      : j*(log3/log2) < m  ==>  3^j < 2^m
    * log_of_two_mul_lt            : 2j < m  ==>  j*log3 < m*log2  (naive => sharp)
    * sharp_threshold_strictly_..  : (j,m)=(1,2) sharp-true but naive-false
    * log3_div_log2_mem_Ioo        : 1 < log3/log2 < 2

Everything is self-contained: only the Python standard library is used.
Run directly:  python demo.py
"""

from __future__ import annotations

import math
from typing import Iterator

# --- Fundamental constants of the theory --------------------------------------

LOG2: float = math.log(2.0)
LOG3: float = math.log(3.0)
LOG2_OF_3: float = LOG3 / LOG2          # halvings needed per tripling  ~ 1.584963
LOG3_OF_2: float = LOG2 / LOG3          # optimal odd/even step ratio   ~ 0.630930
NAIVE_THRESHOLD: float = 0.5            # the classical 2j < m  (density 1/2)


# --- The Collatz map ----------------------------------------------------------

def collatz_step(n: int) -> int:
    """One step of the Collatz map T: n/2 if even, 3n+1 if odd."""
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_trajectory(n: int, max_steps: int = 100000) -> list[int]:
    """Full trajectory from n until reaching 1 (or max_steps), inclusive of n and 1."""
    seq: list[int] = [n]
    while n != 1 and len(seq) <= max_steps:
        n = collatz_step(n)
        seq.append(n)
    return seq


def parity_word(n: int, k: int) -> list[int]:
    """Parity word w_i = (T^i n) mod 2 for i = 0..k-1.  Contains no '11' (parity exclusion)."""
    word: list[int] = []
    cur = n
    for _ in range(k):
        word.append(cur % 2)
        cur = collatz_step(cur)
    return word


# --- The three contraction tests ----------------------------------------------

def naive_test(j: int, m: int) -> bool:
    """Classical sufficient condition for 3^j < 2^m:  2j < m  (odd density < 1/2)."""
    return 2 * j < m


def exact_test(j: int, m: int) -> bool:
    """Exact integer comparison 3^j < 2^m (ground truth, arbitrary precision)."""
    return 3 ** j < 2 ** m


def sharp_log_test(j: int, m: int) -> bool:
    """Sharp logarithmic criterion:  j*log3 < m*log2  (equiv. j*(log3/log2) < m)."""
    return j * LOG3 < m * LOG2


# --- Demonstration routines ---------------------------------------------------

def demo_threshold_constants() -> None:
    print("=" * 72)
    print("THRESHOLD CONSTANTS  (Theorem log3_div_log2_mem_Ioo: 1 < log3/log2 < 2)")
    print("=" * 72)
    print(f"  log 2                 = {LOG2:.9f}")
    print(f"  log 3                 = {LOG3:.9f}")
    print(f"  log3/log2 = log_2 3   = {LOG2_OF_3:.9f}   (halvings per tripling)")
    print(f"  log2/log3 = log_3 2   = {LOG3_OF_2:.9f}   (OPTIMAL odd/even ratio)")
    print(f"  naive threshold       = {NAIVE_THRESHOLD:.9f}   (the suboptimal 1/2)")
    print(f"  1 < log3/log2 < 2 ?   = {1.0 < LOG2_OF_3 < 2.0}")
    print(f"  reclaimed band width  = {LOG3_OF_2 - NAIVE_THRESHOLD:.9f}")
    print()


def demo_iff_characterization() -> None:
    print("=" * 72)
    print("EXACT CHARACTERIZATION  (pow3_lt_pow2_iff_log): 3^j<2^m  <->  jlog3<mlog2")
    print("=" * 72)
    print(f"  {'j':>3} {'m':>3} | {'3^j<2^m (exact)':>16} | {'jlog3<mlog2 (log)':>18} | agree")
    print("  " + "-" * 60)
    cases = [(1, 2), (2, 3), (5, 8), (10, 16), (62, 100), (63, 100), (64, 100)]
    for j, m in cases:
        e, s = exact_test(j, m), sharp_log_test(j, m)
        print(f"  {j:>3} {m:>3} | {str(e):>16} | {str(s):>18} | {'OK' if e == s else 'MISMATCH'}")
    print()


def demo_strict_domination() -> None:
    print("=" * 72)
    print("STRICT DOMINATION  (log_of_two_mul_lt + sharp_threshold_strictly_stronger)")
    print("=" * 72)
    print("  Scanning all (j,m) with 1<=j<=20, j<m<=40.")
    naive_yes = sharp_yes = gap = 0
    witnesses: list[tuple[int, int]] = []
    for j in range(1, 21):
        for m in range(j + 1, 41):
            n_ok, s_ok = naive_test(j, m), sharp_log_test(j, m)
            assert s_ok == exact_test(j, m), "log test must equal exact test"
            if n_ok:
                naive_yes += 1
                assert s_ok, "containment: naive => sharp must hold"  # log_of_two_mul_lt
            if s_ok:
                sharp_yes += 1
            if s_ok and not n_ok:
                gap += 1
                if len(witnesses) < 8:
                    witnesses.append((j, m))
    print(f"  segments certified by NAIVE (2j<m)        : {naive_yes}")
    print(f"  segments certified by SHARP (jlog3<mlog2) : {sharp_yes}")
    print(f"  extra segments reclaimed by SHARP only    : {gap}")
    print(f"  first witnesses (sharp-true, naive-false) : {witnesses}")
    print(f"  canonical separation witness (1,2): 3^1={3**1} < 2^2={2**2} "
          f"but 2*1<2 is {naive_test(1, 2)}")
    print()


def demo_real_orbits() -> None:
    print("=" * 72)
    print("REAL ORBITS — realized density vs the sharp threshold (log_3 2 ~ 0.6309)")
    print("=" * 72)
    print(f"  {'n':>5} | {'steps':>5} | {'peak':>7} | {'odd':>4} {'even':>4} | "
          f"{'odd/even':>9} | {'below thr?':>10}")
    print("  " + "-" * 60)
    for n in [6, 7, 11, 27, 97, 871]:
        traj = collatz_trajectory(n)
        k = len(traj) - 1
        word = parity_word(n, k)
        j = sum(word)          # odd steps
        m = k - j              # even steps
        ratio = j / m if m else float("inf")
        peak = max(traj)
        below = ratio < LOG3_OF_2
        # parity exclusion sanity check: no two consecutive odd parities
        assert "11" not in "".join(map(str, word)), "parity exclusion violated!"
        print(f"  {n:>5} | {k:>5} | {peak:>7} | {j:>4} {m:>4} | "
              f"{ratio:>9.4f} | {str(below):>10}")
    print("\n  (All converging orbits have realized odd/even ratio below the sharp")
    print("   threshold, consistent with contraction; parity exclusion verified.)")
    print()


def main() -> None:
    demo_threshold_constants()
    demo_iff_characterization()
    demo_strict_domination()
    demo_real_orbits()
    print("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
