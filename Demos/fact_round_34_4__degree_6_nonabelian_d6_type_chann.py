#!/usr/bin/env python3
"""
The D6 splitting-type channel of x^6 - 2: numerical companion.

This script is fully self-contained (standard library only).  It

  1. builds the dihedral group D6 acting on the six roots of x^6 - 2
     (equivalently, on the vertices Z/6 of a regular hexagon);
  2. computes the exact splitting-type distribution {0: 8, 2: 3, 6: 1} / 12;
  3. computes the exact entropies / mutual informations of the type channel
     for the conductor-3 dial (p mod 3), the abelian dial (p mod 24), and the
     semiprime pair dial (N = pq mod 3), and compares them with the closed forms;
  4. computes the Bayes (misclassification) errors of the best predictors;
  5. counts roots of x^6 - 2 modulo actual primes and checks the prime-level
     root-count law and the Chebotarev frequencies empirically.
"""
from __future__ import annotations

import math
from collections import Counter
from itertools import product
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

T = TypeVar("T")
N_GON = 6

# ---------------------------------------------------------------------------
# 1. The group D6 and its action on the roots
# ---------------------------------------------------------------------------
# An element is a pair (kind, i): kind 'r' is the rotation j -> i + j,
# kind 's' is the reflection j -> -i - j   (all indices mod 6).
Elem = tuple[str, int]
D6: list[Elem] = [("r", i) for i in range(N_GON)] + [("s", i) for i in range(N_GON)]


def act(g: Elem, j: int, n: int = N_GON) -> int:
    """Image of the root/vertex j under g."""
    kind, i = g
    return (i + j) % n if kind == "r" else (-i - j) % n


def fix_count(g: Elem, n: int = N_GON) -> int:
    """Number of fixed roots of g: the splitting type of a prime with Frobenius g."""
    return sum(1 for j in range(n) if act(g, j, n) == j)


def rot_sign(g: Elem) -> int:
    """Rotation character D6 -> Z/2 (0 on rotations, 1 on reflections) <-> p mod 3."""
    return 0 if g[0] == "r" else 1


def ab_map(g: Elem) -> tuple[int, int]:
    """Abelianisation D6 -> Z/2 x Z/2 <-> (p mod 3, p mod 8 up to sign) <-> p mod 24."""
    return (rot_sign(g), g[1] % 2)


# ---------------------------------------------------------------------------
# 2. Counting information calculus (uniform source)
# ---------------------------------------------------------------------------
def entropy_of_counts(counts: Iterable[int]) -> float:
    c = [x for x in counts if x > 0]
    tot = sum(c)
    return -sum(x / tot * math.log2(x / tot) for x in c)


def u_ent(src: Sequence[T], read: Callable[[T], Hashable]) -> float:
    """Entropy of read(X) for X uniform on src."""
    return entropy_of_counts(Counter(read(x) for x in src).values())


def cond_ent(src: Sequence[T], read: Callable[[T], Hashable],
             dial: Callable[[T], Hashable]) -> float:
    """H(read | dial) = sum over dial fibres of (fibre size / |src|) * fibre entropy."""
    fibres: dict[Hashable, list[T]] = {}
    for x in src:
        fibres.setdefault(dial(x), []).append(x)
    return sum(len(f) / len(src) * u_ent(f, read) for f in fibres.values())


def mut_info(src: Sequence[T], read: Callable[[T], Hashable],
             dial: Callable[[T], Hashable]) -> float:
    return u_ent(src, read) - cond_ent(src, read, dial)


def bayes_errors(src: Sequence[T], read: Callable[[T], Hashable],
                 dial: Callable[[T], Hashable]) -> int:
    """Minimal number of misclassified elements over all predictors f(dial(x))."""
    fibres: dict[Hashable, Counter] = {}
    for x in src:
        fibres.setdefault(dial(x), Counter())[read(x)] += 1
    return sum(sum(c.values()) - max(c.values()) for c in fibres.values())


# ---------------------------------------------------------------------------
# 3. Prime-level root counts
# ---------------------------------------------------------------------------
def primes_up_to(n: int) -> list[int]:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return [i for i in range(n + 1) if sieve[i]]


def root_count6(p: int) -> int:
    """T(p) = #{x in F_p : x^6 = 2}, by the cyclic-group law (0 or gcd(p-1, 6))."""
    g = math.gcd(p - 1, 6)
    # 2 is a 6th power iff 2^((p-1)/g) = 1 (Euler's criterion in a cyclic group)
    return g if pow(2, (p - 1) // g, p) == 1 else 0


def root_count6_brute(p: int) -> int:
    return sum(1 for x in range(p) if (pow(x, 6, p) - 2) % p == 0)


def predicted_type(p: int) -> str:
    """The root-count law: what p mod 24 says about T(p)."""
    r = p % 24
    if r in (5, 11, 13, 19):
        return "0"
    if r in (17, 23):
        return "2"
    return "0 or 6"


# ---------------------------------------------------------------------------
def main() -> None:
    L, L5, L17 = math.log2(3), math.log2(5), math.log2(17)

    print("=" * 72)
    print("1. Fixed points of D6 on the six roots of x^6 - 2")
    print("=" * 72)
    for g in D6:
        print(f"  {g[0]}{g[1]}: fixes {fix_count(g)} roots   "
              f"rotSign={rot_sign(g)}  ab={ab_map(g)}")
    dist = Counter(fix_count(g) for g in D6)
    print("  type distribution:", dict(sorted(dist.items())), "out of 12")
    print("  Burnside check: sum of fixed points =", sum(fix_count(g) for g in D6),
          "(= 12, one orbit)")

    print("\n" + "=" * 72)
    print("2. Exact channel values vs closed forms (bits)")
    print("=" * 72)
    rows = [
        ("H(T)", u_ent(D6, fix_count), 3 / 4 * L, 1.1835),
        ("I(p mod 3 ; T)", mut_info(D6, fix_count, rot_sign), L / 4 + 5 / 12 * L5 - 1, 0.3630),
        ("I(p mod 24 ; T)", mut_info(D6, fix_count, ab_map), L / 2 + 1 / 6, None),
        ("H(T | p mod 24)", cond_ent(D6, fix_count, ab_map), L / 4 - 1 / 6, None),
    ]
    pairs = list(product(D6, D6))
    pair_type = lambda q: (fix_count(q[0]), fix_count(q[1]))  # noqa: E731
    pair_dial = lambda q: (rot_sign(q[0]) + rot_sign(q[1])) % 2  # noqa: E731
    rows.append(("H(T1, T2)", u_ent(pairs, pair_type), 3 / 2 * L, None))
    rows.append(("I(pq mod 3 ; T1,T2)", mut_info(pairs, pair_type, pair_dial),
                 3 / 8 * L + 35 / 72 * L5 + 17 / 72 * L17 - 23 / 9, 0.1321))
    print(f"  {'quantity':22s} {'computed':>10s} {'closed form':>12s} {'observed':>9s}")
    for name, comp, closed, obs in rows:
        o = f"{obs:.4f}" if obs is not None else "   -"
        print(f"  {name:22s} {comp:10.6f} {closed:12.6f} {o:>9s}")
        assert abs(comp - closed) < 1e-12

    print("\n  Fibres of the pair dial (N mod 3):")
    for d in (0, 1):
        c = Counter(pair_type(q) for q in pairs if pair_dial(q) == d)
        print(f"   dial={d}: {dict(sorted(c.items()))}")
    print("   note (0,0) occurs 34 = 25 + 9 times in fibre 0: the prime 17 appears.")
    ratio = (L / 2 + 1 / 6) / (3 / 4 * L)
    print(f"\n  abelian ceiling captures {ratio:.4f} of H(T); residue = {L/4-1/6:.4f} bits")

    print("\n" + "=" * 72)
    print("3. Information versus prediction (misclassified classes out of 12)")
    print("=" * 72)
    print("  no dial        :", bayes_errors(D6, fix_count, lambda g: 0))
    print("  p mod 3 dial   :", bayes_errors(D6, fix_count, rot_sign),
          " <- 0.36 bits, zero predictive gain")
    print("  p mod 24 dial  :", bayes_errors(D6, fix_count, ab_map),
          " <- abelian floor 1/12 (identity vs r^2, r^4)")
    print("  full Frobenius :", bayes_errors(D6, fix_count, lambda g: g))

    print("\n" + "=" * 72)
    print("4. Real primes: root-count law and Chebotarev frequencies")
    print("=" * 72)
    ps = [p for p in primes_up_to(200_000) if p >= 5]
    for p in ps[:400]:
        assert root_count6(p) == root_count6_brute(p) if p < 3000 else True
    viol = 0
    for p in ps:
        t = root_count6(p)
        if str(t) not in predicted_type(p).split(" or "):
            viol += 1
    print(f"  primes 5..200000: {len(ps)};  violations of the mod-24 law: {viol}")
    print("  least prime with T = 6:", next(p for p in ps if root_count6(p) == 6))
    freq = Counter(root_count6(p) for p in ps)
    for t in (0, 2, 6):
        print(f"   T={t}: empirical {freq[t]/len(ps):.4f}   Chebotarev {dist[t]/12:.4f}")
    emp_types = [root_count6(p) for p in ps]
    emp_mod3 = [p % 3 for p in ps]
    idx = list(range(len(ps)))
    h = u_ent(idx, lambda i: emp_types[i])
    i3 = mut_info(idx, lambda i: emp_types[i], lambda i: emp_mod3[i])
    print(f"   empirical H(T) = {h:.4f}  (exact {3/4*L:.4f})")
    print(f"   empirical I(p mod 3; T) = {i3:.4f}  (exact {L/4+5/12*L5-1:.4f})")


if __name__ == "__main__":
    main()
