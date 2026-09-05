"""
demo.py — The degree-seven rung of the abelian splitting-type ladder.

Self-contained numerical companion to the paper
"Full pinning at degree seven: the abelian splitting-type ladder,
its two channels, and the exact price of primality".

Everything is computed from first principles (no third-party imports):

  1.  The septic subfield of Q(zeta_29): the splitting law
      T(p) = 1  <=>  p mod 29 in {1, 12, 17, 28}, densities 1/7 and 6/7.
  2.  Full pinning: I(Frobenius class ; T) = H(T) = log2 7 - (6/7) log2 6.
  3.  Orthogonality: the quartic character mod 29 carries zero information
      about the septic type.
  4.  Conductor-freeness: the same entropy at conductors 29, 43, 71, 113, ...
  5.  The semiprime Bin(2, 1/7) law: (36, 12, 1) out of 49.
  6.  The two channels of a degree n:
          Ipair(n)   = I(type pair ; product residue)
          Isplit(n)  = I(split count ; product residue)
          G(n)       = I(at-least-one-splits ; product residue)
      with the closed forms
          Isplit(7) = log2 7 + (30 log2 5 - 78 log2 3 - 78)/49 = 0.1141063...
          G(7)      = log2 7 + (30 log2 5 - 66 log2 3 - 13 log2 13 - 54)/49
                    = 0.0103041...
  7.  Primality as the exact sufficient-statistic condition:
          Ipair(q) = Isplit(q) for every prime q,
          Ipair(4) = 5/4  >  Isplit(4) = 19/8 - (21/16) log2 3 = 0.2947...
  8.  The conjectural second-order decay law
          q^2 Isplit(q) - log2 q  ->  2 log2 e = 2.885390...
          q^2 G(q)                ->  log2 e - 1 = 0.442695...

Run:  python3 demo.py
"""

from __future__ import annotations

from math import gcd, log, log2
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------
# 0.  Entropy toolkit (base-2, counting measure on a finite set)
# ----------------------------------------------------------------------


def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy (bits) of the empirical distribution given by `counts`."""
    cs: List[int] = [c for c in counts if c > 0]
    total: int = sum(cs)
    if total == 0:
        return 0.0
    return -sum((c / total) * log2(c / total) for c in cs)


def uniform_entropy(points: Sequence[object], readout: Callable[[object], object]) -> float:
    """H(readout) under the uniform measure on `points`."""
    tally: Dict[object, int] = {}
    for x in points:
        key = readout(x)
        tally[key] = tally.get(key, 0) + 1
    return entropy_of_counts(tally.values())


def conditional_entropy(
    points: Sequence[object],
    readout: Callable[[object], object],
    side: Callable[[object], object],
) -> float:
    """H(readout | side) under the uniform measure on `points`."""
    fibres: Dict[object, List[object]] = {}
    for x in points:
        fibres.setdefault(side(x), []).append(x)
    n: int = len(points)
    return sum(
        (len(fib) / n) * uniform_entropy(fib, readout) for fib in fibres.values()
    )


def mutual_information(
    points: Sequence[object],
    readout: Callable[[object], object],
    side: Callable[[object], object],
) -> float:
    """I(readout ; side) = H(readout) - H(readout | side)."""
    return uniform_entropy(points, readout) - conditional_entropy(points, readout, side)


def binary_entropy(p: float) -> float:
    """Binary entropy function h(p) in bits."""
    if p <= 0.0 or p >= 1.0:
        return 0.0
    return -p * log2(p) - (1 - p) * log2(1 - p)


# ----------------------------------------------------------------------
# 1.  The septic subfield of Q(zeta_29): splitting law and densities
# ----------------------------------------------------------------------


def units_mod(f: int) -> List[int]:
    """The unit group (Z/f)^x as a sorted list of representatives."""
    return [u for u in range(1, f) if gcd(u, f) == 1]


def power_subgroup(f: int, q: int) -> List[int]:
    """The subgroup of q-th powers inside (Z/f)^x."""
    return sorted({pow(u, q, f) for u in units_mod(f)})


def residue_degree(f: int, q: int, u: int) -> int:
    """Order of the class of u in (Z/f)^x / ((Z/f)^x)^q: the residue degree."""
    powers: set = set(power_subgroup(f, q))
    d: int = 1
    v: int = u % f
    while v not in powers:
        v = (v * u) % f
        d += 1
    return d


def septic_type(p: int) -> int:
    """Residue degree of the prime p in the septic subfield of Q(zeta_29)."""
    return residue_degree(29, 7, p % 29)


def demo_splitting_law() -> None:
    print("=" * 72)
    print("1.  The septic subfield of Q(zeta_29): the splitting law")
    print("=" * 72)
    seventh_powers = power_subgroup(29, 7)
    print(f"  seventh powers mod 29        : {seventh_powers}")
    fourth_roots = [u for u in units_mod(29) if pow(u, 4, 29) == 1]
    print(f"  fourth roots of unity mod 29 : {fourth_roots}")
    assert seventh_powers == fourth_roots == [1, 12, 17, 28]
    print("  => u is a seventh power mod 29  <=>  u^4 = 1   (C_28 / C_4 = C_7)")

    degrees = {u: residue_degree(29, 7, u) for u in units_mod(29)}
    assert set(degrees.values()) <= {1, 7}
    split = sorted(u for u, d in degrees.items() if d == 1)
    print(f"  totally split classes        : {split}   (density {len(split)}/28 = 1/7)")
    print(f"  inert classes (degree 7)     : {28 - len(split)}/28 = 6/7")

    primes = [p for p in range(2, 400) if all(p % k for k in range(2, int(p**0.5) + 1))]
    sample = [p for p in primes if p != 29][:18]
    print("\n  prime : p mod 29 : residue degree")
    for p in sample:
        print(f"  {p:5d} : {p % 29:8d} : {septic_type(p):d}")
    for p in primes:
        if p != 29:
            predicted = 1 if p % 29 in (1, 12, 17, 28) else 7
            assert septic_type(p) == predicted
    print("  (splitting criterion verified for every prime below 400)")


# ----------------------------------------------------------------------
# 2.  Full pinning and the type entropy
# ----------------------------------------------------------------------


def type_entropy(q: int) -> float:
    """H(T) = log2 q - ((q-1)/q) log2 (q-1) for the degree-q rung."""
    return log2(q) - ((q - 1) / q) * log2(q - 1)


def demo_full_pinning() -> None:
    print()
    print("=" * 72)
    print("2.  Full pinning: the Frobenius class determines the type")
    print("=" * 72)
    us = units_mod(29)
    quartic_class = lambda u: tuple(sorted((u * h) % 29 for h in [1, 12, 17, 28]))
    ent = uniform_entropy(us, lambda u: residue_degree(29, 7, u))
    cond = conditional_entropy(us, lambda u: residue_degree(29, 7, u), quartic_class)
    info = ent - cond
    print(f"  H(T)                     = {ent:.10f} bits")
    print(f"  closed form log2 7 - (6/7) log2 6 = {type_entropy(7):.10f} bits")
    print(f"  H(T | Frobenius class)   = {cond:.10f}")
    print(f"  I(Frobenius class ; T)   = {info:.10f}  =  H(T)")
    assert abs(ent - type_entropy(7)) < 1e-12
    assert cond < 1e-12
    print("  => the channel is FULLY PINNED: capacity attained, no leakage.")
    print(f"  certified bracket 0.5916 < H(T) < 0.5918: {0.5916 < ent < 0.5918}")


def demo_quartic_character() -> None:
    print()
    print("=" * 72)
    print("3.  The quartic character carries ZERO information (CRT orthogonality)")
    print("=" * 72)
    # exponent (discrete-log) model: a runs over Z/28, type sees a mod 7 only
    exps = list(range(28))
    septic = lambda a: 1 if a % 7 == 0 else 7
    quartic = lambda a: a % 4
    ent = uniform_entropy(exps, septic)
    info = mutual_information(exps, septic, quartic)
    print(f"  H(T)  in the exponent model      = {ent:.10f} bits")
    print(f"  I(quartic character ; T)         = {info:.2e}   (exactly 0)")
    assert abs(info) < 1e-12
    for c in range(4):
        fib = [a for a in exps if a % 4 == c]
        counts = [sum(1 for a in fib if septic(a) == 1), sum(1 for a in fib if septic(a) == 7)]
        print(f"    fibre  a = {c} (mod 4):  split/inert counts = {counts}")
    print("  Every fibre of the quartic character has the same 1:6 type split,")
    print("  because gcd(4, 7) = 1 splits C_28 as C_4 x C_7.")


def demo_conductor_freeness() -> None:
    print()
    print("=" * 72)
    print("4.  Conductor-freeness of the degree-7 rung")
    print("=" * 72)
    print("  conductor f :   |(Z/f)^x| : split classes : H(T)")
    for f in (29, 43, 71, 113, 127, 197):
        us = units_mod(f)
        ent = uniform_entropy(us, lambda u: residue_degree(f, 7, u))
        n_split = sum(1 for u in us if residue_degree(f, 7, u) == 1)
        print(f"  {f:11d} : {len(us):10d} : {n_split:13d} : {ent:.10f}")
        assert abs(ent - type_entropy(7)) < 1e-12
        assert n_split * 7 == len(us)
    print("  Every prime conductor f = 1 (mod 7) gives the SAME entropy 0.5917 bits.")


# ----------------------------------------------------------------------
# 5-7.  The exponent box, the three channels, primality
# ----------------------------------------------------------------------


def ord_type(n: int, a: int) -> int:
    """Residue degree attached to the discrete-log class a: n / gcd(n, a)."""
    return n // gcd(n, a)


def type_pair(n: int, x: Tuple[int, int]) -> Tuple[int, int]:
    """Unordered pair of residue degrees of the two prime factors."""
    a, b = x
    u, v = ord_type(n, a), ord_type(n, b)
    return (min(u, v), max(u, v))


def split_count(t: Tuple[int, int]) -> int:
    """How many of the two prime factors split completely."""
    return (1 if t[0] == 1 else 0) + (1 if t[1] == 1 else 0)


def or_readout(t: Tuple[int, int]) -> int:
    """Does at least one of the two factors split completely?"""
    return min(split_count(t), 1)


def exponent_box(n: int) -> List[Tuple[int, int]]:
    return [(a, b) for a in range(n) for b in range(n)]


def product_residue(n: int, x: Tuple[int, int]) -> int:
    """Discrete log of the semiprime N = p*q: a + b mod n."""
    return (x[0] + x[1]) % n


def I_pair(n: int) -> float:
    box = exponent_box(n)
    return mutual_information(box, lambda x: type_pair(n, x), lambda x: product_residue(n, x))


def I_split(n: int) -> float:
    box = exponent_box(n)
    return mutual_information(
        box, lambda x: split_count(type_pair(n, x)), lambda x: product_residue(n, x)
    )


def I_or(n: int) -> float:
    box = exponent_box(n)
    return mutual_information(
        box, lambda x: or_readout(type_pair(n, x)), lambda x: product_residue(n, x)
    )


def I_split_closed(q: int) -> float:
    """Closed form of the split-count channel at prime degree q."""
    p = 1.0 / q
    h_s = entropy_of_counts([(q - 1) ** 2, 2 * (q - 1), 1])
    h_cond = p * binary_entropy(1.0 / q) + (1 - p) * binary_entropy(2.0 / q)
    return h_s - h_cond


def I_or_closed(q: int) -> float:
    """Closed form of the OR channel at prime degree q."""
    h_or = entropy_of_counts([q * q - (2 * q - 1), 2 * q - 1])
    h_cond = (1.0 / q) * binary_entropy(1.0 / q) + ((q - 1.0) / q) * binary_entropy(2.0 / q)
    return h_or - h_cond


def demo_semiprime_law() -> None:
    print()
    print("=" * 72)
    print("5.  The semiprime split-count law at degree 7: Bin(2, 1/7)")
    print("=" * 72)
    box = exponent_box(7)
    counts = [sum(1 for x in box if split_count(type_pair(7, x)) == s) for s in (0, 1, 2)]
    print(f"  observed counts out of 49      : {counts}")
    print(f"  binomial law 49 * Bin(2, 1/7)  : {[36, 12, 1]}")
    assert counts == [36, 12, 1]
    print(f"  P(both split) = 1/49 = {1/49:.6f}   P(exactly one) = 12/49 = {12/49:.6f}")


def demo_channels() -> None:
    print()
    print("=" * 72)
    print("6.  The three channels at degree 7")
    print("=" * 72)
    isp, ior, ipair = I_split(7), I_or(7), I_pair(7)
    closed_isp = log2(7) + (30 * log2(5) - 78 * log2(3) - 78) / 49
    closed_ior = log2(7) + (30 * log2(5) - 66 * log2(3) - 13 * log2(13) - 54) / 49
    print(f"  Ipair(7)  (type pair)        = {ipair:.10f}")
    print(f"  Isplit(7) (split count)      = {isp:.10f}")
    print(f"  closed form                  = {closed_isp:.10f}")
    print(f"  G(7)      (OR read-out)      = {ior:.10f}")
    print(f"  closed form                  = {closed_ior:.10f}")
    assert abs(isp - closed_isp) < 1e-12 and abs(ior - closed_ior) < 1e-12
    assert abs(ipair - isp) < 1e-12
    print(f"  certified bracket 0.1140 < Isplit(7) < 0.1142 : {0.1140 < isp < 0.1142}")
    print(f"  certified bracket 0.01027 < G(7) < 0.01035    : {0.01027 < ior < 0.01035}")
    print(f"  reported anchor 0.1161 vs true value         : gap = {0.1161 - isp:.6f}")
    print(f"  ledger anchor 0.0103 identified as G(7)      : |G(7)-0.0103| = {abs(ior-0.0103):.6f}")
    print(f"  OR coarsening loses a factor  Isplit/G = {isp/ior:.3f}  (> 11)")
    print(f"  ladder monotonicity: Isplit(11) = {I_split(11):.6f} < Isplit(7) = {isp:.6f}")
    print(f"  anchor 0.116 sits nearer degree 7: "
          f"|Isplit(7)-0.116| = {abs(isp-0.116):.6f} < |Isplit(11)-0.116| = {abs(I_split(11)-0.116):.6f}")


def demo_primality() -> None:
    print()
    print("=" * 72)
    print("7.  Primality is exactly the sufficient-statistic condition")
    print("=" * 72)
    print("   n : prime? :   Ipair(n) :  Isplit(n) :    gap")
    for n in range(2, 13):
        ip, isp = I_pair(n), I_split(n)
        is_prime = n > 1 and all(n % k for k in range(2, int(n**0.5) + 1))
        print(f"  {n:2d} : {str(is_prime):6s} : {ip:10.6f} : {isp:10.6f} : {ip - isp:9.6f}")
        if is_prime:
            assert abs(ip - isp) < 1e-12
        else:
            assert ip - isp > 1e-9
    print("\n  Degree 4 in closed form:")
    print(f"    Ipair(4)  = 5/4                       = {I_pair(4):.10f}")
    print(f"    Isplit(4) = 19/8 - (21/16) log2 3     = {19/8 - (21/16)*log2(3):.10f}")
    assert abs(I_pair(4) - 1.25) < 1e-12
    assert abs(I_split(4) - (19 / 8 - (21 / 16) * log2(3))) < 1e-12
    print("    the type pair breaks the one-bit cap; the split count restores it,")
    print("    losing more than three quarters of the channel.")


def demo_asymptotics() -> None:
    print()
    print("=" * 72)
    print("8.  The conjectural second-order decay law")
    print("=" * 72)
    print(f"  target constants:  2 log2 e = {2*log2(2.718281828459045):.6f}, "
          f"log2 e - 1 = {log2(2.718281828459045)-1:.6f}")
    print("      q      q^2 Isplit(q) - log2 q      q^2 G(q)")
    for q in (7, 101, 1009, 10007, 100003):
        a = q * q * I_split_closed(q) - log2(q)
        b = q * q * I_or_closed(q)
        print(f"  {q:7d}   {a:22.6f}   {b:12.6f}")


def main() -> None:
    demo_splitting_law()
    demo_full_pinning()
    demo_quartic_character()
    demo_conductor_freeness()
    demo_semiprime_law()
    demo_channels()
    demo_primality()
    demo_asymptotics()
    print()
    print("All assertions passed.")


if __name__ == "__main__":
    main()
