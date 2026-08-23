#!/usr/bin/env python3
"""
Numerical demonstration of the radix-growth threshold.

Setting
-------
A *radix schedule* is a function r : N -> N with r(x) >= 2.  It generates the
place weights of a self-escalating positional numeral system

        V_0 = 1,      V_{k+1} = r(V_k) * V_k,

so that digit position k carries weight V_k and uses the alphabet
{0, ..., r(V_k) - 1}.  The *radix height* of n is

        K_r(n) = min { k : n < V_k },

the number of digit positions needed to write n.

The iterated binary logarithm and the tower of twos are

        log*(n) = 0                          if n <= 1
                = 1 + log*(floor(log2 n))    if n > 1

        T_0 = 1,   T_{k+1} = 2^(T_k),

and they are inverse to one another: log*(T_j) = j and n < T_{log*(n) + 1}.

What is demonstrated
--------------------
1.  log* inverts the tower exactly, and n < T_{log* n + 1} for every n.
2.  Exponential regime: for r(x) = max(2, 2^x) one has, for every n,
        (1/2) log* n  <=  K_r(n)  <=  log* n + 1,
    i.e. the radix height is Theta(log* n).
3.  Polynomial regime: for r(x) = x^C + 2 the weights obey the doubly
    exponential bound V_k <= M^(E^k) with M = r(x0) 2^C, E = C + 2, so
    log*(V_k) grows like log log k while K_r(V_k) = k + 1 exactly.  Hence for
    every constant c there are arbitrarily large n with c(log* n + 1) < K_r(n).
4.  Explicit certificates: for each c an input n = V_k with c(log* n+1) < K_r(n).
5.  The fixed-height phenomenon: log*(E^(h)(y)) <= h + log*(y), so any bound
    V_k <= E^(h)(M + E k) with a FIXED height h already forces failure.
6.  The intrinsic criterion: K_r is O(log*) iff T_k <= V_{c(k+1)} for some
    constant c and all k.  The tower-tracking inequality is tested exactly.

Arithmetic notes.  Radix heights are computed with saturating multiplication so
that astronomically large exponential weights never have to be materialised;
this is safe because the loop terminates at the first weight exceeding the
target.  The tower-tracking test uses exact comparisons: "v >= T_k" is decided
by k iterated bit-length reductions, never by constructing T_k.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

# --------------------------------------------------------------------------- #
# Saturating arithmetic (used only where a value is compared against a small
# target, so that saturation cannot change any answer)
# --------------------------------------------------------------------------- #

SAT: int = 1 << 4096


def sat_mul(a: int, b: int) -> int:
    """Multiplication saturating at SAT."""
    if a >= SAT or b >= SAT:
        return SAT
    p = a * b
    return SAT if p >= SAT else p


def sat_pow2(e: int) -> int:
    """2**e, saturating at SAT."""
    return SAT if e >= 4096 else 1 << e


# --------------------------------------------------------------------------- #
# log*, tower, iterated exponential
# --------------------------------------------------------------------------- #


def ilog2(n: int) -> int:
    """floor(log2 n) for n >= 1, and 0 for n <= 0."""
    return n.bit_length() - 1 if n > 0 else 0


def log_star(n: int) -> int:
    """Iterated binary logarithm log*(n)."""
    count = 0
    while n > 1:
        n = ilog2(n)
        count += 1
    return count


def tower(k: int) -> int:
    """Tower of twos T_k (saturating); exact for k <= 4."""
    v = 1
    for _ in range(k):
        v = sat_pow2(v)
    return v


def exp_iter(h: int, x: int) -> int:
    """Iterated exponential E^(h)(x): E^(0)(x) = x, E^(h+1)(x) = 2^(E^(h)(x))."""
    v = x
    for _ in range(h):
        v = sat_pow2(v)
    return v


def ge_tower(v: int, k: int) -> bool:
    """
    Exact test of  v >= T_k  without materialising T_k.

    For k = 0 the condition is v >= 1.  For k >= 1, v >= 2^(T_(k-1)) holds iff
    floor(log2 v) >= T_(k-1), i.e. iff ge_tower(floor(log2 v), k - 1).
    """
    while k > 0:
        if v < 1:
            return False
        v = ilog2(v)
        k -= 1
    return v >= 1


def decimal_digits(v: int) -> int:
    """Decimal digit count of v, from its bit length (avoids huge string conversions)."""
    return 1 if v <= 0 else int(v.bit_length() * 0.30102999566398) + 1


# --------------------------------------------------------------------------- #
# Weights and radix height
# --------------------------------------------------------------------------- #

Schedule = Callable[[int], int]
BitEstimate = Callable[[int], int]


def weights(r: Schedule, kmax: int) -> List[int]:
    """Weights V_0, ..., V_kmax with saturating arithmetic."""
    out = [1]
    for _ in range(kmax):
        v = out[-1]
        out.append(sat_mul(r(v) if v < SAT else SAT, v))
    return out


def exact_weights(
    r: Schedule, rbits: BitEstimate, max_bits: int = 3_000_000, max_terms: int = 20
) -> List[int]:
    """
    Exact weights V_0, V_1, ..., generated while the next value provably fits in
    max_bits bits and at most max_terms weights have been produced.  `rbits(v)`
    returns the bit length of r(v) cheaply, without computing r(v) itself for
    explosive schedules.
    """
    out = [1]
    while len(out) <= max_terms and rbits(out[-1]) + out[-1].bit_length() <= max_bits:
        v = out[-1]
        out.append(r(v) * v)
    return out


def radix_height(r: Schedule, n: int) -> int:
    """K_r(n) = min { k : n < V_k }, computed with saturating arithmetic."""
    k, v = 0, 1
    while v <= n:
        v = sat_mul(r(v), v)
        k += 1
    return k


# --------------------------------------------------------------------------- #
# Concrete schedules, each with a bit-length estimator for its value
# --------------------------------------------------------------------------- #


def exp_schedule(x: int) -> int:
    """Canonical exponential schedule r(x) = max(2, 2^x) (saturating)."""
    return max(2, sat_pow2(x))


def exp_schedule_exact(x: int) -> int:
    """Canonical exponential schedule, exact."""
    return max(2, 1 << x)


def exp_schedule_bits(x: int) -> int:
    """Bit length of max(2, 2^x)."""
    return max(2, x + 1)


def exp_offset_exact(x: int) -> int:
    """Pure exponential schedule with offset, r(x) = 2^(x+1), exact."""
    return 1 << (x + 1)


def exp_offset_bits(x: int) -> int:
    """Bit length of 2^(x+1)."""
    return x + 2


def poly_schedule(C: int) -> Schedule:
    """Polynomial family r(x) = x^C + 2 (exact)."""
    return lambda x: x**C + 2


def poly_bits(C: int) -> BitEstimate:
    """Bit length estimate for x^C + 2."""
    return lambda x: C * max(1, x.bit_length()) + 2


def constant_schedule(b: int) -> Schedule:
    """Fixed base b: r(x) = b, giving V_k = b^k."""
    return lambda _x: b


def constant_bits(b: int) -> BitEstimate:
    return lambda _x: b.bit_length()


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def demo_log_star_inverts_tower(jmax: int = 5) -> None:
    print("=" * 74)
    print("1.  log* inverts the tower of twos")
    print("=" * 74)
    print(f"{'j':>3} {'T_j':>30} {'log*(T_j)':>12}")
    for j in range(jmax + 1):
        t = tower(j)
        if t >= SAT:
            shown, ls = "> 2^4096 (saturated)", j
        else:
            shown = str(t) if t < 10**6 else f"~10^{decimal_digits(t) - 1}"
            ls = log_star(t)
            assert ls == j, "log*(T_j) = j must hold"
        print(f"{j:>3} {shown:>30} {ls:>12}")
    print("\n   n < T_(log* n + 1) for a sample of n:")
    for n in [0, 1, 2, 3, 16, 17, 1000, 65535, 65536, 65537, 10**30]:
        j = log_star(n) + 1
        assert n < tower(j)
        print(f"     n = {n:<22} log* n = {log_star(n)}   n < T_{j}   OK")
    print()


def demo_exponential_regime() -> None:
    print("=" * 74)
    print("2.  Exponential regime:  (1/2) log* n  <=  K_r(n)  <=  log* n + 1")
    print("    schedule r(x) = max(2, 2^x)")
    print("=" * 74)
    ws = weights(exp_schedule, 4)
    print(
        "    weights V_0..V_4 =",
        [w if w < 10**8 else f"~10^{decimal_digits(w) - 1}" for w in ws],
    )
    print(f"\n{'n':>26} {'log* n':>8} {'K_r(n)':>8} {'lower ok':>9} {'upper ok':>9}")
    samples = [0, 1, 2, 3, 7, 8, 9, 100, 2047, 2048, 2049, 10**6, 10**12, 2**600, 2**2048]
    for n in samples:
        ls, k = log_star(n), radix_height(exp_schedule, n)
        lo, hi = ls <= 2 * k, k <= ls + 1
        assert lo and hi
        label = str(n) if n < 10**8 else f"2^{n.bit_length() - 1}"
        print(f"{label:>26} {ls:>8} {k:>8} {str(lo):>9} {str(hi):>9}")
    print("\n    Both bounds hold for every sampled n: the height is Theta(log* n).")
    print()


def demo_polynomial_regime(C: int = 2, kmax: int = 14) -> None:
    print("=" * 74)
    print(f"3.  Polynomial regime: r(x) = x^{C} + 2")
    print("    K_r(V_k) = k + 1 exactly, while log*(V_k) stays tiny")
    print("=" * 74)
    r = poly_schedule(C)
    ws = exact_weights(r, poly_bits(C), max_bits=20_000, max_terms=kmax)[: kmax + 1]
    print(f"{'k':>3} {'digits of V_k':>16} {'log*(V_k)':>10} {'K_r(V_k)':>10} {'ratio':>8}")
    for k, v in enumerate(ws):
        ls = log_star(v)
        kh = radix_height(r, v) if v < SAT else k + 1
        assert kh == k + 1, "radix height at a weight must be k+1"
        print(f"{k:>3} {decimal_digits(v):>16} {ls:>10} {kh:>10} {(k + 1) / (ls + 1):>8.2f}")
    print("\n    The ratio K_r(n)/(log* n + 1) grows without bound along n = V_k,")
    print("    so no constant c can satisfy K_r(n) <= c (log* n + 1) for all n.")
    print()


def log_star_bound_pow(M: int, E: int, k: int) -> int:
    """
    A certified upper bound for log*(x) valid for every x <= M^(E^k), obtained
    from the bit length E^k * bitlen(M) of that bound without materialising it.
    """
    bits = (E**k) * M.bit_length()
    return 1 + log_star(bits)


def certify_failure(M: int, E: int, c: int, kmax: int = 4000) -> Tuple[int, int, int]:
    """
    Find an explicit witness index k such that n = V_k satisfies
    c * (log* n + 1) < K_r(n), using K_r(V_k) = k + 1 and the certified weight
    bound V_k <= M^(E^k).

    Returns (k, upper bound for log*(V_k), K_r(V_k) = k + 1).
    """
    for k in range(kmax):
        ls = log_star_bound_pow(M, E, k)
        if c * (ls + 1) < k + 1:
            return k, ls, k + 1
    raise RuntimeError("no witness found within kmax")


def demo_certificates(C: int = 2) -> None:
    print("=" * 74)
    print(f"4.  Explicit certificates of failure for r(x) = x^{C} + 2")
    print("    (using V_k <= M^(E^k) with M = r(3)*2^(C+1), E = C+3, and K_r(V_k) = k+1)")
    print("=" * 74)
    Cp = C + 1
    M, E = poly_schedule(C)(3) * 2**Cp, Cp + 2
    print(f"{'c':>5} {'witness k':>10} {'log*(V_k) <=':>13} {'K_r(V_k)':>10} {'c(log*+1) < K':>15}")
    for c in [1, 2, 3, 5, 10, 20, 40]:
        k, ls, kh = certify_failure(M, E, c)
        assert c * (ls + 1) < kh
        print(f"{c:>5} {k:>10} {ls:>13} {kh:>10} {'True':>15}")
    print("\n    Witnesses n = V_k satisfy n >= 2^k, so they are arbitrarily large.")
    print()


def demo_fixed_height() -> None:
    print("=" * 74)
    print("5.  Fixed height is what matters:  log*(E^(h)(y)) <= h + log*(y)")
    print("=" * 74)
    print(f"{'h':>3} {'y':>8} {'log*(E^h(y))':>14} {'h + log* y':>12}")
    for h in range(4):
        for y in [2, 3, 10, 1000]:
            val = exp_iter(h, y)
            if val >= SAT:
                continue
            lhs, rhs = log_star(val), h + log_star(y)
            assert lhs <= rhs
            print(f"{h:>3} {y:>8} {lhs:>14} {rhs:>12}")
    print("\n    A fixed number h of exponentiations shifts log* by at most h.")
    print("    Only a tower whose HEIGHT grows with k can keep pace with log*.")
    print()


def demo_tower_tracking(cmax: int = 3) -> None:
    print("=" * 74)
    print("6.  Intrinsic criterion:  K_r is O(log*)  <=>  exists c, T_k <= V_(c(k+1))")
    print("    (comparisons are exact: v >= T_k is decided by iterated bit lengths)")
    print("=" * 74)
    table: List[Tuple[str, Schedule, BitEstimate]] = [
        ("max(2, 2^x)  [fast]", exp_schedule_exact, exp_schedule_bits),
        ("2^(x+1)      [fast]", exp_offset_exact, exp_offset_bits),
        ("x^2 + 2      [slow]", poly_schedule(2), poly_bits(2)),
        ("x^7 + 2      [slow]", poly_schedule(7), poly_bits(7)),
        ("constant 10  [slow]", constant_schedule(10), constant_bits(10)),
    ]
    for name, r, rb in table:
        ws = exact_weights(r, rb, max_bits=3_000_000, max_terms=20)
        top = len(ws) - 1
        print(f"    r(x) = {name}   (weights V_0..V_{top} available exactly)")
        for c in range(1, cmax + 1):
            kmax = top // c - 1
            failure = next((k for k in range(kmax + 1) if not ge_tower(ws[c * (k + 1)], k)), None)
            if failure is None:
                print(f"        c = {c}: holds for every k <= {kmax} (limit of exact arithmetic)")
            else:
                print(f"        c = {c}: FAILS already at k = {failure}")
        print()
    print("    The fast schedules satisfy the tower-tracking inequality throughout the")
    print("    exactly computable range, while the slow ones already break it at k = 5")
    print("    or k = 6 -- exactly as the characterization predicts.  (Larger c can only")
    print("    be probed at correspondingly larger indices, hence the ranges shown.)")
    print()


def demo_doubly_exponential_bound(C: int = 2, kmax: int = 8) -> None:
    print("=" * 74)
    print(f"7.  Doubly exponential weight bound V_k <= M^(E^k) for r(x) = x^{C} + 2")
    print("=" * 74)
    r = poly_schedule(C)
    x0, Cp = 3, C + 1  # r(x) <= x^(C+1) for x >= 3
    M, E = r(x0) * 2**Cp, Cp + 2
    print(f"    x0 = {x0}, exponent C' = {Cp}, M = r(x0)*2^C' = {M}, E = C'+2 = {E}")
    print(f"{'k':>3} {'digits V_k':>12} {'digits M^(E^k)':>16} {'bound holds':>13}")
    ws = exact_weights(r, poly_bits(C), max_bits=200_000, max_terms=kmax)[: kmax + 1]
    for k, v in enumerate(ws):
        bound = M ** (E**k)
        assert v <= bound
        print(f"{k:>3} {decimal_digits(v):>12} {decimal_digits(bound):>16} {'True':>13}")
    print("\n    One exponential separates M^(E^k) from the tower T_k, and that single")
    print("    missing level is exactly what puts the schedule on the slow side.")
    print()


def main() -> None:
    print()
    print("THE RADIX-GROWTH THRESHOLD -- numerical demonstration")
    print()
    demo_log_star_inverts_tower()
    demo_exponential_regime()
    demo_polynomial_regime()
    demo_certificates()
    demo_fixed_height()
    demo_tower_tracking()
    demo_doubly_exponential_bound()
    print("=" * 74)
    print("All assertions passed: the exponential regime is Theta(log* n), the")
    print("polynomial regime provably is not O(log* n), and the tower-tracking")
    print("criterion separates the two.")
    print("=" * 74)


if __name__ == "__main__":
    main()
