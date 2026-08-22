#!/usr/bin/env python3
"""
The abelian ceiling: exactly log2 |G^ab| bits of Frobenius information
are visible in a residue.

This self-contained script demonstrates, numerically and by exhaustive
enumeration, every quantitative claim of the accompanying paper:

  1. The Chebotarev channel of the cubic field x^3 + x + 1 (discriminant -31,
     Galois group S_3):  H(T) = 2/3 + (log2 3)/2 = 1.4591...,
     H(T | sign) = (log2 3)/2 - 1/3 = 0.4591..., I(T ; sign) = 1 EXACTLY.

  2. The decomposition H(T | sign) = (1/2) * H(1/3, 2/3):  the odd half of the
     group is pure, the even half splits 1 : 2.

  3. The abelian ceiling: for every surjective character chi : G -> C onto a
     finite abelian group, I(conjugacy class ; chi) = log2 |C|, and every
     post-processing u . chi satisfies I <= log2 |C| (checked by brute-force
     enumeration of ALL set partitions of C).

  4. The dichotomy: an abelian Galois group hides nothing (I = log2 |G|);
     a symmetric group leaks exactly one bit for every n >= 2.

  5. An honest arithmetic scan: factorization types of x^3 + x + 1 modulo the
     primes, stratified by residue mod 31, exhibiting the 15 mixed-type
     residue classes forced by the theory.

Run:  python3 demo.py
Only the standard library is used.
"""

from __future__ import annotations

from collections import Counter, defaultdict
from itertools import permutations
from math import log2
from typing import Callable, Dict, Hashable, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]
Readout = Callable[[Perm], Hashable]


# ----------------------------------------------------------------------
# 1. The counting-entropy calculus (uniform / Chebotarev measure)
# ----------------------------------------------------------------------

def entropy_of_counts(counts: Iterable[int]) -> float:
    """Shannon entropy in bits of the distribution proportional to `counts`."""
    cs: List[int] = [c for c in counts if c > 0]
    total: int = sum(cs)
    if total == 0:
        return 0.0
    return -sum((c / total) * log2(c / total) for c in cs)


def uniform_entropy(domain: Sequence[Hashable], g: Callable[[Hashable], Hashable]) -> float:
    """H(g) for the uniform measure on `domain`."""
    return entropy_of_counts(Counter(g(x) for x in domain).values())


def conditional_entropy(
    domain: Sequence[Hashable],
    g: Callable[[Hashable], Hashable],
    k: Callable[[Hashable], Hashable],
) -> float:
    """H(g | k): the average entropy of g over the fibres of k."""
    blocks: Dict[Hashable, List[Hashable]] = defaultdict(list)
    for x in domain:
        blocks[k(x)].append(x)
    n: int = len(domain)
    return sum((len(b) / n) * uniform_entropy(b, g) for b in blocks.values())


def mutual_information(
    domain: Sequence[Hashable],
    g: Callable[[Hashable], Hashable],
    k: Callable[[Hashable], Hashable],
) -> float:
    """I(g ; k) = H(g) - H(g | k)."""
    return uniform_entropy(domain, g) - conditional_entropy(domain, g, k)


# ----------------------------------------------------------------------
# 2. Permutation groups, cycle types, signs, conjugacy classes
# ----------------------------------------------------------------------

def symmetric_group(n: int) -> List[Perm]:
    """All permutations of {0,...,n-1}, as tuples p with i |-> p[i]."""
    return [tuple(p) for p in permutations(range(n))]


def cycle_type(p: Perm) -> Tuple[int, ...]:
    """Cycle type of p as a weakly decreasing tuple (a partition of n)."""
    n: int = len(p)
    seen: List[bool] = [False] * n
    parts: List[int] = []
    for i in range(n):
        if not seen[i]:
            length, j = 0, i
            while not seen[j]:
                seen[j] = True
                j = p[j]
                length += 1
            parts.append(length)
    return tuple(sorted(parts, reverse=True))


def sign(p: Perm) -> int:
    """Sign of a permutation: +1 if even, -1 if odd."""
    ct: Tuple[int, ...] = cycle_type(p)
    return (-1) ** sum(length - 1 for length in ct)


def conj_class(p: Perm) -> Tuple[int, ...]:
    """For a symmetric group, the conjugacy class is exactly the cycle type."""
    return cycle_type(p)


def type_label(ct: Tuple[int, ...]) -> str:
    """'111', '12', '3', ... — the classical splitting-type notation."""
    return "".join(str(part) for part in sorted(ct))


# ----------------------------------------------------------------------
# 3. Demonstration 1 — the S_3 cubic x^3 + x + 1, discriminant -31
# ----------------------------------------------------------------------

def demo_s3_channel() -> None:
    print("=" * 72)
    print("1. THE CUBIC x^3 + x + 1,  disc = -31,  Galois group S_3")
    print("=" * 72)

    G: List[Perm] = symmetric_group(3)
    counts: Counter = Counter(type_label(cycle_type(p)) for p in G)
    print("\nChebotarev densities (fraction of the group per splitting type):")
    for label in ("111", "12", "3"):
        print(f"   type {label:>3} : {counts[label]}/6 = {counts[label] / 6:.6f}")

    H_T: float = uniform_entropy(G, lambda p: cycle_type(p))
    H_sign: float = uniform_entropy(G, sign)
    H_T_given_sign: float = conditional_entropy(G, lambda p: cycle_type(p), sign)
    I: float = mutual_information(G, lambda p: cycle_type(p), sign)

    exact_H_T: float = 2 / 3 + log2(3) / 2
    exact_res: float = log2(3) / 2 - 1 / 3

    print(f"\n   H(T)              = {H_T:.10f}   (exact 2/3 + (log2 3)/2 = {exact_H_T:.10f})")
    print(f"   H(sign)           = {H_sign:.10f}   (a fair coin: 3 odd, 3 even)")
    print(f"   H(T | sign)       = {H_T_given_sign:.10f}   (exact (log2 3)/2 - 1/3 = {exact_res:.10f})")
    print(f"   I(T ; sign)       = {I:.10f}   <-- EXACTLY ONE BIT")
    print(f"   visible fraction  = {I / H_T:.4%}")

    assert abs(I - 1.0) < 1e-12
    assert abs(H_T - exact_H_T) < 1e-12
    assert abs(H_T_given_sign - exact_res) < 1e-12

    # symmetry of mutual information: the trivial direction
    H_sign_given_T: float = conditional_entropy(G, sign, lambda p: cycle_type(p))
    print(f"\n   H(sign | T)       = {H_sign_given_T:.10f}   (the sign IS a function of the type)")
    print("   hence  I(T ; sign) = I(sign ; T) = H(sign) - 0 = 1.")
    assert abs(H_sign_given_T) < 1e-12

    # the paper's decomposition
    half_binary: float = 0.5 * entropy_of_counts([1, 2])
    print(f"\n   Decomposition:  (1/2) * H(1/3, 2/3) = {half_binary:.10f}")
    print("   the odd half is pure (all type '12'); the even half splits 1 : 2.")
    assert abs(H_T_given_sign - half_binary) < 1e-12

    # strictness: a coarser read-out loses
    splits_completely: Readout = lambda p: cycle_type(p) == (1, 1, 1)
    I_coarse: float = mutual_information(G, splits_completely, sign)
    print(f"\n   Coarse read-out 'does p split completely?':  I = {I_coarse:.10f} < 1")
    print("   so the one-bit value is a property of the splitting type, not of the framework.")
    assert I_coarse < 1 - 1e-9


# ----------------------------------------------------------------------
# 4. Demonstration 2 — the abelian ceiling, verified by brute force
# ----------------------------------------------------------------------

def set_partitions(items: Sequence[Hashable]) -> Iterable[List[List[Hashable]]]:
    """All set partitions of `items` (Bell-number many)."""
    if not items:
        yield []
        return
    first, rest = items[0], items[1:]
    for partition in set_partitions(rest):
        for i in range(len(partition)):
            yield partition[:i] + [[first] + partition[i]] + partition[i + 1:]
        yield [[first]] + partition


def demo_abelian_ceiling(n: int = 4) -> None:
    print()
    print("=" * 72)
    print(f"2. THE ABELIAN CEILING for G = S_{n},  chi = sign,  C = {{+1,-1}}")
    print("=" * 72)

    G: List[Perm] = symmetric_group(n)
    ceiling: float = log2(2)

    I_exact: float = mutual_information(G, conj_class, sign)
    print(f"\n   I(conjugacy class ; sign) = {I_exact:.10f}   = log2 |C| = {ceiling:.10f}")
    assert abs(I_exact - ceiling) < 1e-12

    H_class: float = uniform_entropy(G, conj_class)
    deficit: float = conditional_entropy(G, conj_class, sign)
    print(f"   H(class)                  = {H_class:.10f}")
    print(f"   H(class | sign)           = {deficit:.10f}   = H(class) - log2 |C|")
    assert abs(deficit - (H_class - ceiling)) < 1e-12

    # every post-processing u of chi: enumerate ALL set partitions of C
    print("\n   Every read-out computed from the character (all set partitions of C):")
    for partition in set_partitions([1, -1]):
        lookup: Dict[int, int] = {}
        for idx, block in enumerate(partition):
            for value in block:
                lookup[value] = idx
        w: Readout = lambda p, lookup=lookup: lookup[sign(p)]
        I_w: float = mutual_information(G, conj_class, w)
        blocks_str: str = " | ".join("{" + ",".join(f"{v:+d}" for v in b) + "}" for b in partition)
        print(f"      u = {blocks_str:<20}  I = {I_w:.10f}  <= {ceiling:.6f}")
        assert I_w <= ceiling + 1e-12


def demo_dichotomy() -> None:
    print()
    print("=" * 72)
    print("3. THE DICHOTOMY: abelian groups hide nothing, S_n hides all but one bit")
    print("=" * 72)

    # abelian: the cyclic group Z/m under addition, conjugacy classes are singletons
    print("\n   Cyclic Galois group Z/m (e.g. a cyclic cubic or a cyclotomic field):")
    for m in (2, 3, 4, 6):
        elements: List[int] = list(range(m))
        I_ab: float = mutual_information(elements, lambda x: x, lambda x: x)
        print(f"      m = {m}:  I(class ; residue) = {I_ab:.6f} = log2 {m} = {log2(m):.6f}  (all of it)")
        assert abs(I_ab - log2(m)) < 1e-12

    print("\n   Symmetric Galois group S_n:")
    print("      n    H(cycle type)   I(type ; sign)   hidden bits   visible fraction")
    for n in range(2, 8):
        G: List[Perm] = symmetric_group(n)
        H_T: float = uniform_entropy(G, cycle_type)
        I: float = mutual_information(G, cycle_type, sign)
        print(f"      {n}    {H_T:13.6f}   {I:14.10f}   {H_T - I:11.6f}   {I / H_T:15.2%}")
        assert abs(I - 1.0) < 1e-12


# ----------------------------------------------------------------------
# 5. Demonstration 3 — an honest arithmetic scan
# ----------------------------------------------------------------------

def primes_up_to(limit: int) -> List[int]:
    """Sieve of Eratosthenes."""
    sieve: List[bool] = [True] * (limit + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, is_p in enumerate(sieve) if is_p]


def splitting_type_of_cubic(p: int) -> str:
    """
    Splitting type of x^3 + x + 1 modulo p, for p not dividing 31.

    A cubic over a finite field is determined by its number of roots:
      3 roots -> '111' (splits completely), 1 root -> '12', 0 roots -> '3'.
    """
    roots: int = sum(1 for x in range(p) if (x * x * x + x + 1) % p == 0)
    if roots == 3:
        return "111"
    if roots == 1:
        return "12"
    return "3"


def legendre_symbol(a: int, p: int) -> int:
    """The Legendre symbol (a|p) by Euler's criterion, p an odd prime."""
    a %= p
    if a == 0:
        return 0
    r: int = pow(a, (p - 1) // 2, p)
    return 1 if r == 1 else -1


def demo_prime_scan(limit: int = 20000) -> None:
    print()
    print("=" * 72)
    print(f"4. ARITHMETIC SCAN: x^3 + x + 1 modulo the primes p < {limit}")
    print("=" * 72)

    ps: List[int] = [p for p in primes_up_to(limit) if p != 31 and p != 2]
    types: List[str] = [splitting_type_of_cubic(p) for p in ps]
    counts: Counter = Counter(types)
    total: int = len(ps)

    print(f"\n   {total} primes scanned.")
    print("   type   observed density   Chebotarev prediction")
    for label, predicted in (("111", 1 / 6), ("12", 1 / 2), ("3", 1 / 3)):
        print(f"   {label:>4}   {counts[label] / total:16.6f}   {predicted:21.6f}")

    # the character really is the sign: (-31|p) = -1 exactly for type '12'
    mismatches: int = sum(
        1
        for p, t in zip(ps, types)
        if legendre_symbol(-31, p) != (-1 if t == "12" else 1)
    )
    print(f"\n   primes where (-31|p) disagrees with the parity of the type: {mismatches}")
    assert mismatches == 0

    # empirical entropies
    H_T: float = entropy_of_counts(counts.values())
    by_sign: Dict[int, Counter] = defaultdict(Counter)
    for p, t in zip(ps, types):
        by_sign[legendre_symbol(-31, p)][t] += 1
    H_T_given_sign: float = sum(
        (sum(c.values()) / total) * entropy_of_counts(c.values()) for c in by_sign.values()
    )
    print(f"\n   empirical H(T)        = {H_T:.6f}   (theory 1.459148)")
    print(f"   empirical H(T | sign) = {H_T_given_sign:.6f}   (theory 0.459148)")
    print(f"   empirical I           = {H_T - H_T_given_sign:.6f}   (theory 1.000000)")

    # residue stratification mod 31: which classes host more than one type?
    by_residue: Dict[int, set] = defaultdict(set)
    for p, t in zip(ps, types):
        by_residue[p % 31].add(t)
    mixed: List[int] = sorted(r for r, s in by_residue.items() if len(s) > 1)
    pure: List[int] = sorted(r for r, s in by_residue.items() if len(s) == 1)
    print(f"\n   residue classes mod 31 hosting >1 splitting type: {len(mixed)}")
    print(f"      {mixed}")
    print(f"   residue classes hosting exactly one type: {len(pure)}")
    print(f"      {pure}")
    print("\n   The mixed classes are exactly the 15 quadratic residues mod 31, i.e. the")
    print("   classes with (-31|p) = +1: the character separates even from odd and no")
    print("   more, so within the even classes the 1 : 2 split of identity vs 3-cycles")
    print("   is residue-independent.  These mixed classes ARE the 0.4591 hidden bits.")

    qrs: List[int] = sorted({(x * x) % 31 for x in range(1, 31)})
    assert mixed == qrs, (mixed, qrs)

    # empirical mutual information from the full residue, not just the sign
    I_residue: float = mutual_information(
        list(zip(ps, types)), lambda pt: pt[1], lambda pt: pt[0] % 31
    )
    print(f"\n   empirical I(p mod 31 ; type) = {I_residue:.6f}")
    print("   (finite-sample noise inflates this slightly above the exact value 1;")
    print("    the excess shrinks as the scan is extended)")


def main() -> None:
    demo_s3_channel()
    demo_abelian_ceiling(n=3)
    demo_abelian_ceiling(n=5)
    demo_dichotomy()
    demo_prime_scan(limit=20000)
    print()
    print("=" * 72)
    print("All assertions passed: the character captures exactly one bit, and the")
    print("abelian ceiling log2 |G^ab| is attained and never exceeded.")
    print("=" * 72)


if __name__ == "__main__":
    main()
