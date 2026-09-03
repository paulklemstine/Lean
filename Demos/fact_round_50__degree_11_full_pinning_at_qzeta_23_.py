#!/usr/bin/env python3
"""
Full pinning and strict decay on the abelian splitting-type ladder
==================================================================

Self-contained numerical demonstration of every result in the accompanying
paper.  No third-party dependencies; the standard library only.

The seven demonstrations are:

  1. The arithmetic splitting law at degree 11 in the maximal real subfield
     of the 23rd cyclotomic field: a prime p splits completely iff
     p = +/-1 (mod 23), and has residue degree 11 otherwise.
  2. The type entropy H(T_11) = log2(11) - (10/11) log2(10), together with the
     *exact integer* certificates 2^2417 * 10^5000 < 11^5500 and
     11^2200 < 2^967 * 10^2000 that bracket it in (0.4394, 0.4396).
  3. Full pinning: the sign-class channel transmits the entire type entropy,
     while the quadratic character mod 23 transmits exactly zero bits.
  4. Universal abelian pinning, verified by brute force over many finite
     abelian groups and all their subgroups.
  5. The exact Bin(2, 1/q) law for the semiprime split count.
  6. The split-count channel I_split(q): direct enumeration against the closed
     form, with the degree-11 value 0.05190... versus the predicted 0.116.
  7. Strict decay of the ladder: the profile h(x) and its derivative
     h'(x) = -ln(x-1) / (x^2 ln 2), the sandwich bounds, and the fact that
     degree 2 is the unique rung carrying a full bit.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import gcd, log, log2
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Section 0.  Counting entropy, conditional entropy, mutual information
# ---------------------------------------------------------------------------


def counting_entropy(space: Sequence[Hashable], read_out: Callable[[Hashable], Hashable]) -> float:
    """Shannon entropy (bits) of the push-forward of the uniform measure on
    `space` under `read_out`.  Equivalently
        log2 |S| - (1/|S|) * sum_x log2 |fibre through x|.
    """
    n: int = len(space)
    if n == 0:
        return 0.0
    counts: Dict[Hashable, int] = {}
    for x in space:
        v = read_out(x)
        counts[v] = counts.get(v, 0) + 1
    return -sum((c / n) * log2(c / n) for c in counts.values())


def conditional_entropy(
    space: Sequence[Hashable],
    read_out: Callable[[Hashable], Hashable],
    channel: Callable[[Hashable], Hashable],
) -> float:
    """H(read_out | channel): the fibre-weighted average of the fibre entropies."""
    n: int = len(space)
    fibres: Dict[Hashable, List[Hashable]] = {}
    for x in space:
        fibres.setdefault(channel(x), []).append(x)
    return sum((len(f) / n) * counting_entropy(f, read_out) for f in fibres.values())


def mutual_information(
    space: Sequence[Hashable],
    read_out: Callable[[Hashable], Hashable],
    channel: Callable[[Hashable], Hashable],
) -> float:
    """I(channel ; read_out) = H(read_out) - H(read_out | channel)."""
    return counting_entropy(space, read_out) - conditional_entropy(space, read_out, channel)


def binary_entropy(total: int, distinguished: int) -> float:
    """B(N, m) = log2 N - (m log2 m + (N-m) log2 (N-m)) / N."""
    n, m = total, distinguished
    return log2(n) - (m * log2(m) + (n - m) * log2(n - m)) / n


def type_entropy(q: int) -> float:
    """H(T_q) = log2 q - ((q-1)/q) log2 (q-1), the entropy of the (1/q, (q-1)/q) source."""
    return log2(q) - ((q - 1) / q) * log2(q - 1)


# ---------------------------------------------------------------------------
# Section 1.  The arithmetic law at degree 11
# ---------------------------------------------------------------------------


def real_residue_degree(f: int, u: int) -> int:
    """Order of the class of u in (Z/f)^x / {+-1}: the residue degree of a prime
    with residue u in the maximal real subfield of the f-th cyclotomic field."""
    assert gcd(u, f) == 1
    power, order = u % f, 1
    while power != 1 % f and power != (f - 1) % f:
        power = (power * u) % f
        order += 1
    return order


def demo_1_splitting_law() -> None:
    print("=" * 78)
    print("1.  The splitting law at degree 11 (maximal real subfield, conductor 23)")
    print("=" * 78)
    units: List[int] = [u for u in range(1, 23) if gcd(u, 23) == 1]
    print(f"    |(Z/23)^x| = {len(units)},  Galois group order = {len(units)//2} (prime)")

    degrees = {u: real_residue_degree(23, u) for u in units}
    split = sorted(u for u, d in degrees.items() if d == 1)
    inert = sorted(u for u, d in degrees.items() if d != 1)
    print(f"    residue degrees observed: {sorted(set(degrees.values()))}   (prime dichotomy)")
    print(f"    split classes  (degree 1) : {split}   <-- exactly {{+1, -1}} mod 23")
    print(f"    inert classes (degree 11) : {inert}")
    assert set(split) == {1, 22}
    assert all(d == 11 for u, d in degrees.items() if u not in (1, 22))

    print(f"    split density  = {len(split)}/{len(units)} = 1/11")
    print(f"    inert density  = {len(inert)}/{len(units)} = 10/11")

    print("\n    Sample primes:")
    for p in (2, 3, 5, 7, 13, 43, 47, 137, 139):
        d = real_residue_degree(23, p % 23)
        verdict = "splits completely" if d == 1 else f"inert, residue degree {d}"
        print(f"      p = {p:4d}   p mod 23 = {p % 23:2d}   {verdict}")
    assert real_residue_degree(23, 47 % 23) == 1  # 47 = 1 mod 23
    assert real_residue_degree(23, 2) == 11
    print()


# ---------------------------------------------------------------------------
# Section 2.  The entropy value and its integer certificates
# ---------------------------------------------------------------------------


def demo_2_entropy_bracket() -> None:
    print("=" * 78)
    print("2.  The degree-11 type entropy and its exact integer certificates")
    print("=" * 78)
    h11: float = type_entropy(11)
    print(f"    H(T_11) = log2(11) - (10/11) log2(10) = {h11:.10f} bits")

    # Certificate 1:  2^2417 * 10^5000 < 11^5500  ==>  0.4394 < H(T_11)
    lower_ok: bool = 2 ** 2417 * 10 ** 5000 < 11 ** 5500
    # Certificate 2:  11^2200 < 2^967 * 10^2000   ==>  H(T_11) < 0.4396
    upper_ok: bool = 11 ** 2200 < 2 ** 967 * 10 ** 2000
    print(f"    integer certificate  2^2417 * 10^5000 < 11^5500       : {lower_ok}")
    print(f"    integer certificate  11^2200 < 2^967 * 10^2000        : {upper_ok}")
    assert lower_ok and upper_ok
    assert 0.4394 < h11 < 0.4396
    print(f"    certified bracket    0.4394 < H(T_11) < 0.4396        : confirmed")
    print(f"    11 * H(T_11) = log2(11^11 / 10^10) = {11 * h11:.10f}")
    print()


# ---------------------------------------------------------------------------
# Section 3.  Pinning at degree 11: a lossless channel and a lossy one
# ---------------------------------------------------------------------------


def demo_3_pinning_and_failure() -> None:
    print("=" * 78)
    print("3.  Full pinning at degree 11, and two channels at opposite extremes")
    print("=" * 78)
    units: List[int] = [u for u in range(1, 23) if gcd(u, 23) == 1]

    def rtype(u: int) -> int:
        return real_residue_degree(23, u)

    def sign_class(u: int) -> Tuple[int, int]:
        return tuple(sorted((u % 23, (-u) % 23)))  # the observable {u, -u}

    squares = {(w * w) % 23 for w in units}

    def legendre(u: int) -> bool:
        return u in squares

    h_t: float = counting_entropy(units, rtype)
    i_sign: float = mutual_information(units, rtype, sign_class)
    i_leg: float = mutual_information(units, rtype, legendre)

    print(f"    H(T)                                  = {h_t:.10f} bits")
    print(f"    I(sign class of p mod 23 ; T)         = {i_sign:.10f} bits   <-- FULL PINNING")
    print(f"    I(quadratic character mod 23 ; T)     = {i_leg:.10f} bits   <-- ZERO")
    assert abs(i_sign - h_t) < 1e-12
    assert abs(i_leg) < 1e-12

    print("\n    Why the quadratic character fails the pinning criterion:")
    print(f"      5^2 mod 23 = {(5 * 5) % 23}, so 2 IS a square mod 23; and 1 is trivially a square.")
    print(f"      residue degree of 1  = {rtype(1)}  (splits completely)")
    print(f"      residue degree of 2  = {rtype(2)}  (inert)")
    print("      the channel merges a split class with an inert one, so it is strictly lossy.")

    print("\n    Exponent model (a in Z/22, type sees a mod 11, character sees a mod 2):")
    exps: List[int] = list(range(22))
    tau: Callable[[int], int] = lambda a: 1 if a % 11 == 0 else 11
    chi: Callable[[int], int] = lambda a: a % 2
    print(f"      H(tau)            = {counting_entropy(exps, tau):.10f}  = B(22,2) = B(11,1)")
    print(f"      H(tau | chi)      = {conditional_entropy(exps, tau, chi):.10f}")
    print(f"      I(chi ; tau)      = {mutual_information(exps, tau, chi):.10f}   (gcd(2,11)=1)")
    assert abs(mutual_information(exps, tau, chi)) < 1e-12
    assert abs(binary_entropy(22, 2) - binary_entropy(11, 1)) < 1e-12
    print()


# ---------------------------------------------------------------------------
# Section 4.  Universal abelian pinning, verified by brute force
# ---------------------------------------------------------------------------


def cyclic_product_elements(moduli: Tuple[int, ...]) -> List[Tuple[int, ...]]:
    return [tuple(t) for t in product(*[range(m) for m in moduli])]


def group_add(x: Tuple[int, ...], y: Tuple[int, ...], moduli: Tuple[int, ...]) -> Tuple[int, ...]:
    return tuple((a + b) % m for a, b, m in zip(x, y, moduli))


def subgroups_of(moduli: Tuple[int, ...]) -> List[frozenset]:
    """All subgroups of the finite abelian group, found by closing over generating sets
    of size at most two (sufficient for the small groups used here)."""
    elements = cyclic_product_elements(moduli)
    found: set = set()
    zero = tuple(0 for _ in moduli)

    def closure(gens: Sequence[Tuple[int, ...]]) -> frozenset:
        seen = {zero}
        frontier = [zero]
        while frontier:
            x = frontier.pop()
            for g in gens:
                y = group_add(x, g, moduli)
                if y not in seen:
                    seen.add(y)
                    frontier.append(y)
        return frozenset(seen)

    for g in elements:
        found.add(closure([g]))
    for g in elements:
        for k in elements:
            found.add(closure([g, k]))
    return sorted(found, key=len)


def quotient_order(x: Tuple[int, ...], subgroup: frozenset, moduli: Tuple[int, ...]) -> int:
    """Order of the class x + H in G/H."""
    zero = tuple(0 for _ in moduli)
    acc, n = x, 1
    while acc not in subgroup:
        acc = group_add(acc, x, moduli)
        n += 1
        if acc == zero:
            break
    return n


def demo_4_universal_pinning() -> None:
    print("=" * 78)
    print("4.  Universal abelian pinning: every finite abelian group, every subgroup")
    print("=" * 78)
    test_groups: List[Tuple[int, ...]] = [(2,), (3,), (5,), (11,), (22,), (2, 2), (2, 6), (4, 4), (3, 9)]
    total_checked: int = 0
    for moduli in test_groups:
        elements = cyclic_product_elements(moduli)
        for hsub in subgroups_of(moduli):
            def klass(x: Tuple[int, ...], _h: frozenset = hsub) -> frozenset:
                return frozenset(group_add(x, y, moduli) for y in _h)

            def typ(x: Tuple[int, ...], _h: frozenset = hsub) -> int:
                return quotient_order(x, _h, moduli)

            cond = conditional_entropy(elements, typ, klass)
            info = mutual_information(elements, typ, klass)
            hgt = counting_entropy(elements, typ)
            assert abs(cond) < 1e-12, (moduli, hsub)
            assert abs(info - hgt) < 1e-12, (moduli, hsub)
            total_checked += 1
        name = " x ".join(f"Z/{m}" for m in moduli)
        print(f"    {name:<12}  all {len(subgroups_of(moduli)):2d} subgroups pinned: H(T|class) = 0")
    print(f"    total (group, subgroup) pairs verified: {total_checked}  -- no exceptions")
    print()


# ---------------------------------------------------------------------------
# Section 5.  The exact Bin(2, 1/q) semiprime split law
# ---------------------------------------------------------------------------


def split_count_profile(q: int) -> Dict[int, int]:
    """Counts of pairs (a1, a2) in (Z/q)^2 by number of split factors."""
    profile: Dict[int, int] = {0: 0, 1: 0, 2: 0}
    for a, b in product(range(q), repeat=2):
        s = (1 if a == 0 else 0) + (1 if b == 0 else 0)
        profile[s] += 1
    return profile


def demo_5_binomial_law() -> None:
    print("=" * 78)
    print("5.  The semiprime split count is exactly Bin(2, 1/q)")
    print("=" * 78)
    for q in (2, 3, 5, 7, 11, 13):
        prof = split_count_profile(q)
        predicted = {2: 1, 1: 2 * (q - 1), 0: (q - 1) ** 2}
        assert prof == predicted
        binom = [Fraction((q - 1) ** 2, q * q), Fraction(2 * (q - 1), q * q), Fraction(1, q * q)]
        print(
            f"    q = {q:2d}:  counts (0,1,2 split) = "
            f"({prof[0]:4d}, {prof[1]:3d}, {prof[2]:2d}) of {q*q:4d}"
            f"   = Bin(2,1/{q}) exactly  {tuple(str(b) for b in binom)}"
        )
    prof11 = split_count_profile(11)
    assert (prof11[0], prof11[1], prof11[2]) == (100, 20, 1)
    print("    degree 11: (100, 20, 1) out of 121 -- the pre-registered profile, confirmed.")
    print()


# ---------------------------------------------------------------------------
# Section 6.  The split-count channel
# ---------------------------------------------------------------------------


def isplit_direct(q: int) -> float:
    """I(class of the semiprime ; number of split prime factors), by enumeration."""
    box: List[Tuple[int, int]] = [(a, b) for a in range(q) for b in range(q)]
    scount: Callable[[Tuple[int, int]], int] = lambda x: (1 if x[0] == 0 else 0) + (1 if x[1] == 0 else 0)
    prod_res: Callable[[Tuple[int, int]], int] = lambda x: (x[0] + x[1]) % q
    return mutual_information(box, scount, prod_res)


def isplit_closed_form(q: int) -> float:
    """The closed form of Theorem 'split-count channel'."""
    unconditional = log2(q ** 2) - (
        (q - 1) ** 2 * log2((q - 1) ** 2) + 2 * (q - 1) * log2(2 * (q - 1))
    ) / q ** 2
    conditional = (1 / q) * binary_entropy(q, 1) + ((q - 1) / q) * binary_entropy(q, 2)
    return unconditional - conditional


def demo_6_split_channel() -> None:
    print("=" * 78)
    print("6.  The split-count channel: closed form, certificates, corrected prediction")
    print("=" * 78)
    print(f"    {'q':>3}  {'enumerated':>14}  {'closed form':>14}   agree")
    for q in (3, 5, 7, 11, 13, 17):
        a, b = isplit_direct(q), isplit_closed_form(q)
        assert abs(a - b) < 1e-12
        print(f"    {q:3d}  {a:14.10f}  {b:14.10f}   yes")

    special = log2(11) + (180 * log2(3) - 210 * log2(5) - 210) / 121
    print(f"\n    I_split(11) via the degree-11 identity")
    print(f"        log2(11) + (180 log2 3 - 210 log2 5 - 210)/121 = {special:.10f}")
    assert abs(special - isplit_direct(11)) < 1e-12

    lower_ok: bool = 2 ** 865 * 5 ** 840 < 11 ** 484 * 3 ** 720
    upper_ok: bool = 11 ** 1210 * 3 ** 1800 < 2 ** 2163 * 5 ** 2100
    print(f"    integer certificate  2^865 * 5^840   < 11^484 * 3^720   : {lower_ok}")
    print(f"    integer certificate  11^1210 * 3^1800 < 2^2163 * 5^2100 : {upper_ok}")
    assert lower_ok and upper_ok and 0.0516 < special < 0.0521

    print(f"\n    pre-registered prediction : 0.1160 bits")
    print(f"    true value                : {special:.4f} bits   (ratio {0.116/special:.2f}x too large)")
    assert special < 0.116
    print("    the prediction is refuted; the closed form and bracket stand.")

    per_factor = 2 * type_entropy(11)
    print(f"\n    for comparison: the two factors' own types are worth {per_factor:.4f} bits,")
    print(f"    of which conditioning on the product leaves only {special:.4f} bits visible.")
    print()


# ---------------------------------------------------------------------------
# Section 7.  Strict decay of the ladder
# ---------------------------------------------------------------------------


def h_profile(x: float) -> float:
    """The real interpolation h(x) = log2 x - ((x-1)/x) log2 (x-1)."""
    return log2(x) - ((x - 1) / x) * log2(x - 1)


def h_derivative(x: float) -> float:
    """The exact derivative h'(x) = -ln(x-1) / (x^2 ln 2)."""
    return -log(x - 1) / (x ** 2 * log(2))


def demo_7_strict_decay() -> None:
    print("=" * 78)
    print("7.  Strict decay of the ladder, with the exact derivative")
    print("=" * 78)
    primes: List[int] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 101]
    print(f"    {'q':>4}  {'H(T_q)':>10}  {'log2 q / q':>11}  {'(log2 q+1/ln2)/q':>17}  {'q H - log2 q':>13}")
    previous: float = float("inf")
    for q in primes:
        h = type_entropy(q)
        lo = log2(q) / q
        hi = (log2(q) + 1 / log(2)) / q
        excess = q * h - log2(q)
        assert lo <= h <= hi + 1e-15
        assert h < previous
        previous = h
        print(f"    {q:4d}  {h:10.6f}  {lo:11.6f}  {hi:17.6f}  {excess:13.6f}")
    print(f"    the excess q H(T_q) - log2 q = (q-1) log2(q/(q-1)) increases to "
          f"1/ln 2 = {1/log(2):.6f}")

    print("\n    the interpolation h reproduces the ladder and is strictly antitone:")
    for x in (2.0, 2.5, 3.0, 4.0, 7.0, 11.0, 20.0):
        num = (h_profile(x + 1e-6) - h_profile(x - 1e-6)) / 2e-6
        print(f"      x = {x:5.1f}   h(x) = {h_profile(x):9.6f}   h'(x) = {h_derivative(x):10.6f}"
              f"   (numerical {num:10.6f})")
        assert abs(num - h_derivative(x)) < 1e-6
    assert abs(h_profile(2.0) - 1.0) < 1e-15
    assert abs(h_derivative(2.0)) < 1e-15
    print("      h(2) = 1 exactly and h'(2) = 0 exactly: degree 2 is the unique full-bit rung,")
    print("      and h'(x) < 0 for every x > 2, so the ladder strictly decays along the primes.")

    print("\n    the first five rungs, in the reported order:")
    reported = {2: 1.0, 3: 0.9183, 5: 0.7219, 7: 0.5917, 11: 0.4395}
    for q, r in reported.items():
        h = type_entropy(q)
        assert abs(h - r) < 5e-5
        print(f"      degree {q:2d}:  H = {h:.6f}  (reported {r})")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("#" * 78)
    print("#  FULL PINNING AND STRICT DECAY ON THE ABELIAN SPLITTING-TYPE LADDER")
    print("#" * 78)
    print()
    demo_1_splitting_law()
    demo_2_entropy_bracket()
    demo_3_pinning_and_failure()
    demo_4_universal_pinning()
    demo_5_binomial_law()
    demo_6_split_channel()
    demo_7_strict_decay()
    print("=" * 78)
    print("All assertions passed: every numerical claim in the paper is reproduced.")
    print("=" * 78)


if __name__ == "__main__":
    main()
