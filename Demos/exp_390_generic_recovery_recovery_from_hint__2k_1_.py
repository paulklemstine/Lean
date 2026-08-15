"""
demo.py -- Numerical demonstration of the closed taxonomy of t-bit hints.

Everything below is self-contained: no imports beyond the standard library.

We verify, by exhaustive computation:

  1. MASTER BOUND          worst-case class size >= |S| / 2^t, for every hint.
  2. SHARPNESS             the block hint p -> p // q attains |S| / 2^t exactly,
                           with every one of its 2^t fibres of size exactly q.
  3. INFORMATION-EXACTNESS random GF(2) linear hints on the k-bit primes split
                           the set into classes of size ~ |P_k| / 2^t with no
                           anomalous (super-resolving) class.
  4. AVERAGE-CASE BOUND    |S|^2 <= 2^t * sum_y cost(y)^2  (Cauchy-Schwarz):
                           the expected scan length also exceeds |S| / 2^t.
  5. POSITION-FREENESS     reading |A| bits of a k-bit secret leaves 2^(k-|A|)
                           candidates, whichever positions A are read.
  6. PARITY TAX            c*p mod 2^t and (p ^ m) mod 2^t on odd candidates
                           realise only 2^(t-1) readings: exactly one bit lost.
  7. FOUR SQUARE ROOTS     x^2 = u^2 (mod 2^t) has exactly 4 solutions for odd u
                           and t >= 3, namely  +-u  and  +-u + 2^(t-1).
  8. TRACE HINT = t-3      squaring on the odd residues mod 2^t realises exactly
                           2^(t-3) readings, with every class of size 4.
  9. KLEIN SYMMETRY        {1, -1, 1+2^(t-1), -(1+2^(t-1))} is a Klein four-group
                           of square roots of unity, and it is the invariance
                           group responsible for the two lost bits.
 10. PUBLIC HINTS SEALED   a hint recomputable from N has one class: zero value.
"""

from __future__ import annotations

import random
from collections import Counter
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# The cost model
# ----------------------------------------------------------------------------


def classes(candidates: Sequence[int], hint: Callable[[int], Hashable]) -> Dict[Hashable, int]:
    """Map each hint reading to the number of candidates producing it."""
    counts: Counter = Counter()
    for p in candidates:
        counts[hint(p)] += 1
    return dict(counts)


def worst_cost(candidates: Sequence[int], hint: Callable[[int], Hashable]) -> int:
    """Largest fibre: the worst-case number of candidates left to scan."""
    return max(classes(candidates, hint).values())


def mean_cost(candidates: Sequence[int], hint: Callable[[int], Hashable]) -> float:
    """Expected scan length when the secret is uniform on the candidate set."""
    sizes = classes(candidates, hint).values()
    total = sum(sizes)
    return sum(c * c for c in sizes) / total


def num_readings(candidates: Sequence[int], hint: Callable[[int], Hashable]) -> int:
    return len(classes(candidates, hint))


# ----------------------------------------------------------------------------
# Candidate sets
# ----------------------------------------------------------------------------


def primes_below(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve = bytearray([1]) * limit
    sieve[0:2] = b"\x00\x00"
    i = 2
    while i * i < limit:
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
        i += 1
    return [n for n in range(limit) if sieve[n]]


def k_bit_primes(k: int) -> List[int]:
    """All primes p with 2^(k-1) <= p < 2^k."""
    return [p for p in primes_below(1 << k) if p >= (1 << (k - 1))]


# ----------------------------------------------------------------------------
# Hint families
# ----------------------------------------------------------------------------


def block_hint(q: int) -> Callable[[int], int]:
    """p -> floor(p/q): the hint attaining the master bound with equality."""
    return lambda p: p // q


def gf2_linear_hint(masks: Sequence[int]) -> Callable[[int], Tuple[int, ...]]:
    """t random GF(2) linear forms of the bits of p, given as bit masks."""
    return lambda p: tuple(bin(p & m).count("1") & 1 for m in masks)


def coordinate_hint(positions: Sequence[int]) -> Callable[[int], Tuple[int, ...]]:
    """Read the bits of p in the given positions."""
    return lambda p: tuple((p >> i) & 1 for i in positions)


def mul_hint(c: int, t: int) -> Callable[[int], int]:
    """Multiplicative value hash c*p mod 2^t (c odd)."""
    return lambda p: (c * p) % (1 << t)


def xor_hint(m: int, t: int) -> Callable[[int], int]:
    """XOR-mask value hash (p XOR m) mod 2^t."""
    return lambda p: (p ^ m) % (1 << t)


def square_hint(t: int) -> Callable[[int], int]:
    """The content of a trace hint after completing the square: p^2 mod 2^t."""
    return lambda p: (p * p) % (1 << t)


# ----------------------------------------------------------------------------
# 1-2.  Master bound and its sharpness
# ----------------------------------------------------------------------------


def demo_master_and_sharpness() -> None:
    print("=" * 74)
    print("1-2.  MASTER BOUND AND SHARPNESS (block hint p -> p // q)")
    print("=" * 74)
    print(f"{'q':>5} {'t':>3} {'|S|':>8} {'readings':>9} {'worst':>7} {'|S|/2^t':>9} {'equal?':>7}")
    for q, t in [(3, 4), (7, 5), (11, 6), (25, 3)]:
        S = list(range(q * (1 << t)))
        h = block_hint(q)
        sizes = classes(S, h)
        ok = num_readings(S, h) == (1 << t) and set(sizes.values()) == {q}
        print(
            f"{q:>5} {t:>3} {len(S):>8} {num_readings(S, h):>9} "
            f"{worst_cost(S, h):>7} {len(S) // (1 << t):>9} {str(ok):>7}"
        )
    print("  -> every fibre has exactly q elements and all 2^t readings occur:")
    print("     the reduction factor of a t-bit hint is EXACTLY 2^t.\n")


# ----------------------------------------------------------------------------
# 3-4.  Information-exactness and the average-case bound on real primes
# ----------------------------------------------------------------------------


def demo_generic_hints(k: int = 16, trials: int = 20, seed: int = 20260815) -> None:
    print("=" * 74)
    print(f"3-4.  GENERIC GF(2) LINEAR HINTS ON THE {k}-BIT PRIMES")
    print("=" * 74)
    rng = random.Random(seed)
    P = k_bit_primes(k)
    n = len(P)
    print(f"|P_{k}| = {n}\n")
    print(
        f"{'t':>3} {'mean class':>11} {'|S|/2^t':>10} {'worst':>7} "
        f"{'min class':>10} {'CS ok':>6}"
    )
    for t in [1, 2, 4, 6, 8]:
        means, worsts, mins, cs_ok = [], [], [], True
        for _ in range(trials):
            masks = [rng.getrandbits(k) for _ in range(t)]
            h = gf2_linear_hint(masks)
            sizes = list(classes(P, h).values())
            means.append(mean_cost(P, h))
            worsts.append(max(sizes))
            mins.append(min(sizes))
            # Cauchy-Schwarz / average-case master bound
            if n * n > (1 << t) * sum(c * c for c in sizes):
                cs_ok = False
        print(
            f"{t:>3} {sum(means)/len(means):>11.1f} {n/(1<<t):>10.1f} "
            f"{max(worsts):>7} {min(mins):>10} {str(cs_ok):>6}"
        )
    print("  -> measured class sizes track |P_k|/2^t; no anomalous small class,")
    print("     hence no super-resolution.  Cauchy-Schwarz bound holds throughout.\n")


# ----------------------------------------------------------------------------
# 5.  Position-freeness
# ----------------------------------------------------------------------------


def demo_position_freeness(k: int = 12) -> None:
    print("=" * 74)
    print("5.  POSITION-FREENESS OF BIT LEAKS")
    print("=" * 74)
    cube = list(range(1 << k))
    print(f"{'positions':>34} {'|A|':>4} {'fibre size':>11} {'2^(k-|A|)':>10}")
    position_sets = [
        list(range(k // 2, k)),          # contiguous top half (Coppersmith)
        list(range(0, k // 2)),          # contiguous bottom half
        list(range(0, k, 2)),            # every other bit
        [1, 4, 5, 7, 9, 11],             # scattered
    ]
    for A in position_sets:
        h = coordinate_hint(A)
        sizes = set(classes(cube, h).values())
        label = str(A)
        print(f"{label:>34} {len(A):>4} {str(sorted(sizes)):>11} {1 << (k - len(A)):>10}")
    print("  -> the fibre size depends only on HOW MANY bits leak, never WHICH.")
    print("     Coppersmith's top-half advantage is algorithmic, not informational.\n")


# ----------------------------------------------------------------------------
# 6.  The parity tax on value hints
# ----------------------------------------------------------------------------


def demo_parity_tax(k: int = 16) -> None:
    print("=" * 74)
    print(f"6.  VALUE HINTS LOSE EXACTLY ONE BIT ({k}-bit primes)")
    print("=" * 74)
    P = k_bit_primes(k)
    n = len(P)
    print(
        f"{'t':>3} {'linear mean':>12} {'mul mean':>10} {'xor mean':>10} "
        f"{'|S|/2^t':>9} {'|S|/2^(t-1)':>12}"
    )
    rng = random.Random(7)
    for t in [3, 4, 5, 6]:
        masks = [rng.getrandbits(k) for _ in range(t)]
        lin = mean_cost(P, gf2_linear_hint(masks))
        mul = mean_cost(P, mul_hint(0x9E37 | 1, t))
        xor = mean_cost(P, xor_hint(0x5A5A, t))
        print(
            f"{t:>3} {lin:>12.1f} {mul:>10.1f} {xor:>10.1f} "
            f"{n/(1<<t):>9.1f} {n/(1<<(t-1)):>12.1f}"
        )
    print("  -> p is odd and c is odd, so the low output bit is a constant:")
    print("     value hashes realise only 2^(t-1) readings.\n")


# ----------------------------------------------------------------------------
# 7-8.  Four square roots, and the trace hint's t-3 bits
# ----------------------------------------------------------------------------


def sqrt_fiber(u: int, t: int) -> List[int]:
    """All x mod 2^t with x^2 = u^2 (mod 2^t)."""
    M = 1 << t
    target = (u * u) % M
    return [x for x in range(M) if (x * x) % M == target]


def demo_four_roots(tmax: int = 12) -> None:
    print("=" * 74)
    print("7.  EXACTLY FOUR SQUARE ROOTS MOD 2^t  (t >= 3, u odd)")
    print("=" * 74)
    print(f"{'t':>3} {'u':>5} {'#roots':>7} {'roots':>32} {'matches +-u, +-u+2^(t-1)':>26}")
    for t in range(3, min(tmax, 9) + 1):
        M = 1 << t
        for u in (1, 3, 5):
            if u >= M:
                continue
            roots = sqrt_fiber(u, t)
            predicted = sorted({u % M, (-u) % M, (u + (M >> 1)) % M, (-u + (M >> 1)) % M})
            print(
                f"{t:>3} {u:>5} {len(roots):>7} {str(roots):>32} "
                f"{str(roots == predicted):>26}"
            )
    print()


def demo_trace_hint(tmax: int = 14) -> None:
    print("=" * 74)
    print("8.  THE t-BIT TRACE HINT CARRIES EXACTLY t-3 BITS")
    print("=" * 74)
    print(f"{'t':>3} {'#odd residues':>14} {'#readings':>10} {'2^(t-3)':>9} {'all classes = 4':>16}")
    for t in range(3, tmax + 1):
        M = 1 << t
        odd = list(range(1, M, 2))
        h = square_hint(t)
        sizes = classes(odd, h)
        print(
            f"{t:>3} {len(odd):>14} {len(sizes):>10} {1 << (t - 3):>9} "
            f"{str(set(sizes.values()) == {4}):>16}"
        )
    print("  -> one bit lost to parity, two to the square-root ambiguity.\n")


def demo_trace_recovery_cost(k: int = 16, t: int = 6) -> None:
    print("=" * 74)
    print(f"8b.  RECOVERY COST OF A TRACE HINT ON THE {k}-BIT PRIMES (t = {t})")
    print("=" * 74)
    P = k_bit_primes(k)
    n = len(P)
    rng = random.Random(11)
    masks = [rng.getrandbits(k) for _ in range(t)]
    generic = mean_cost(P, gf2_linear_hint(masks))
    trace = mean_cost(P, square_hint(t))
    print(f"|P_{k}|                              = {n}")
    print(f"generic t-bit hint, mean class      = {generic:8.1f}   (|S|/2^t = {n/(1<<t):.1f})")
    print(f"trace hint, mean class              = {trace:8.1f}   "
          f"(4|S|/2^(t-1) = {4*n/(1<<(t-1)):.1f})")
    print(f"penalty factor                      = {trace/generic:8.2f}  "
          f"(~ 2^3 = 8 up to sparse-set noise)\n")


# ----------------------------------------------------------------------------
# 9.  The Klein four-group is the invariance group
# ----------------------------------------------------------------------------


def demo_klein(tmax: int = 10) -> None:
    print("=" * 74)
    print("9.  THE KLEIN FOUR-GROUP {1, -1, 1+2^(t-1), -(1+2^(t-1))} MOD 2^t")
    print("=" * 74)
    print(f"{'t':>3} {'group':>34} {'order':>6} {'all square to 1':>16} {'preserves x^2':>14}")
    for t in range(3, tmax + 1):
        M = 1 << t
        K = sorted({1 % M, (-1) % M, (1 + (M >> 1)) % M, (-(1 + (M >> 1))) % M})
        squares_to_one = all((c * c) % M == 1 for c in K)
        preserves = all(
            ((c * x) ** 2) % M == (x * x) % M for c in K for x in range(1, M, 2)
        )
        print(f"{t:>3} {str(K):>34} {len(K):>6} {str(squares_to_one):>16} {str(preserves):>14}")
    print("  -> the deficit of the trace hint IS the order of this group.\n")


# ----------------------------------------------------------------------------
# 10.  Public hints are sealed
# ----------------------------------------------------------------------------


def demo_public_hint(k: int = 14) -> None:
    print("=" * 74)
    print("10.  A HINT RECOMPUTABLE FROM N HAS ONE CLASS")
    print("=" * 74)
    P = k_bit_primes(k)
    p_true, q_true = P[10], P[40]
    N = p_true * q_true
    S = P  # the adversary's candidate pool

    def public(_p: int) -> int:
        """A 32-bit 'hint' that in fact depends only on the public modulus N."""
        return (N * 0x9E3779B1) % (1 << 32)
    sizes = classes(S, public)
    print(f"N = {N},  candidate pool |S| = {len(S)}")
    print(f"readings realised by the N-derived hint: {len(sizes)}")
    print(f"worst-case recovery cost: {worst_cost(S, public)}  (= |S|)")
    print("  -> zero information, however many bits it is allowed to output.\n")


# ----------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 74)
    print("#  A CLOSED TAXONOMY OF t-BIT HINTS -- NUMERICAL DEMONSTRATION")
    print("#" * 74)
    print()
    demo_master_and_sharpness()
    demo_generic_hints(k=16)
    demo_position_freeness(k=12)
    demo_parity_tax(k=16)
    demo_four_roots()
    demo_trace_hint()
    demo_trace_recovery_cost(k=16, t=6)
    demo_klein()
    demo_public_hint()
    print("=" * 74)
    print("SUMMARY:  t bits buy a factor 2^t -- never more (master bound),")
    print("          attained by block and linear hints (sharpness),")
    print("          2^(t-1) for value hashes (parity tax),")
    print("          2^(t-3) for trace hints (parity + Klein four-group),")
    print("          and 1 for anything recomputable from public data.")
    print("=" * 74)


if __name__ == "__main__":
    main()
