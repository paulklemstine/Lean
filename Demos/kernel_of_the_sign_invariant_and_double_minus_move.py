#!/usr/bin/env python3
"""
Kernel of the Sign Invariant and Double-Minus Moves -- numerical demonstrations.

Self-contained (standard library only).  Throughout we normalise eigenvalues by
s = sqrt(Q):  an eigenvalue alpha is recorded as x = alpha / s.  In these units

    duality      x  |->  1/x          (alpha |-> Q/alpha)
    fixed points x = +1, x = -1       (alpha = +sqrt(Q), -sqrt(Q))
    sign         eps = prod(x)        (prod(alpha) / s^d)

Sections
  1. The sign formula  eps = (-1)^{n_-}  on random eigensystems.
  2. Real-world eigensystems: elliptic curves over F_p and tensor squares.
  3. The original moves: invariants and the decision procedure.
  4. Brute-force confirmation of the classification theorem.
  5. The verdict: an infinite family inside one sign class.
  6. The repair: dual-pair moves and the four normal forms.
  7. Counting move classes per sign class over a finite alphabet.
"""
from __future__ import annotations

import cmath
import random
from collections import Counter, deque
from fractions import Fraction
from itertools import combinations_with_replacement
from typing import Callable, Dict, FrozenSet, Hashable, Iterable, List, Optional, Sequence, Tuple, Union

Num = Union[Fraction, complex]
MSet = Tuple[Fraction, ...]          # multiset of exact eigenvalues, stored sorted

ONE, MONE = Fraction(1), Fraction(-1)


# ---------------------------------------------------------------------------
# Basic notions
# ---------------------------------------------------------------------------

def key(x: Num, digits: int = 9) -> Hashable:
    """Hashable key: exact for Fractions, rounded for complex numbers."""
    if isinstance(x, Fraction):
        return x
    z = complex(x)
    return (round(z.real, digits) + 0.0, round(z.imag, digits) + 0.0)


def is_eigensystem(xs: Sequence[Num]) -> bool:
    """Nonzero entries and multiset stable under x -> 1/x."""
    if any(x == 0 for x in xs):
        return False
    return Counter(key(x) for x in xs) == Counter(key(1 / x) for x in xs)


def sign(xs: Sequence[Num]) -> Num:
    """The functional-equation sign  prod(alpha_i) / s^d = prod(x_i)."""
    p: Num = Fraction(1) if all(isinstance(x, Fraction) for x in xs) else 1 + 0j
    for x in xs:
        p = p * x
    return p


def n_plus(xs: Sequence[Num]) -> int:
    return sum(1 for x in xs if key(x) == key(ONE if isinstance(x, Fraction) else 1 + 0j))


def n_minus(xs: Sequence[Num]) -> int:
    return sum(1 for x in xs if key(x) == key(MONE if isinstance(x, Fraction) else -1 + 0j))


def core(xs: Sequence[Num]) -> Counter:
    """Multiset of entries different from +1 and -1."""
    return Counter(key(x) for x in xs if key(x) not in (key(ONE), key(1 + 0j), key(MONE), key(-1 + 0j)))


def neg_core(c: Counter) -> Counter:
    out: Counter = Counter()
    for k, m in c.items():
        if isinstance(k, Fraction):
            out[-k] += m
        else:
            out[(-k[0] + 0.0, -k[1] + 0.0)] += m
    return out


# ---------------------------------------------------------------------------
# 1. The sign formula
# ---------------------------------------------------------------------------

def random_eigensystem(rng: random.Random, pairs: int, plus: int, minus: int) -> List[complex]:
    xs: List[complex] = [1 + 0j] * plus + [-1 + 0j] * minus
    for _ in range(pairs):
        b = complex(rng.uniform(-3, 3), rng.uniform(-3, 3))
        xs += [b, 1 / b]
    rng.shuffle(xs)
    return xs


def section_sign_formula() -> None:
    print("=" * 76)
    print("1. SIGN FORMULA:  eps = prod(alpha)/s^d = (-1)^(number of -sqrt(Q) eigenvalues)")
    print("=" * 76)
    rng = random.Random(2026)
    worst = 0.0
    for trial in range(2000):
        xs = random_eigensystem(rng, rng.randint(0, 6), rng.randint(0, 4), rng.randint(0, 5))
        assert is_eigensystem(xs)
        eps = sign(xs)
        predicted = (-1) ** n_minus(xs)
        worst = max(worst, abs(eps - predicted))
        if trial < 4:
            print(f"  degree {len(xs):2d}, n_- = {n_minus(xs)}:  product/s^d = {eps.real:+.12f}{eps.imag:+.1e}i"
                  f"   (-1)^n_- = {predicted:+d}")
    print(f"  2000 random eigensystems checked; max |eps - (-1)^n_-| = {worst:.2e}\n")


# ---------------------------------------------------------------------------
# 2. Elliptic curves
# ---------------------------------------------------------------------------

def count_points(p: int, a: int, b: int) -> int:
    """Projective points on y^2 = x^3 + a x + b over F_p (p odd prime)."""
    squares = Counter((y * y) % p for y in range(p))
    return 1 + sum(squares[(x * x * x + a * x + b) % p] for x in range(p))


def frobenius_eigenvalues(p: int, trace: int) -> Tuple[complex, complex]:
    disc = complex(trace * trace - 4 * p)
    r = cmath.sqrt(disc)
    return (trace + r) / 2, (trace - r) / 2


def section_elliptic() -> None:
    print("=" * 76)
    print("2. ELLIPTIC CURVES  y^2 = x^3 + a x + b  over F_p")
    print("=" * 76)
    for (p, a, b) in [(5, 1, 1), (7, 3, 2), (11, 1, 0), (13, 2, 5), (3, 1, 0)]:
        N = count_points(p, a, b)
        t = p + 1 - N
        al, be = frobenius_eigenvalues(p, t)
        s = cmath.sqrt(p)
        h1 = [al / s, be / s]                       # weight 1, Q = p
        h11 = [u * v for u in h1 for v in h1]       # H^1 (x) H^1, weight 2, Q = p^2
        print(f"  p={p:2d} a={a} b={b}: #E={N:2d}, trace={t:+d}")
        print(f"     H^1 : eigensystem={is_eigensystem(h1)}, sign={sign(h1).real:+.6f}, n_-={n_minus(h1)}")
        print(f"     H^1(x)H^1 : sign={sign(h11).real:+.6f}, n_+={n_plus(h11)}, n_-={n_minus(h11)},"
              f" core size={sum(core(h11).values())}"
              + ("   <- supersingular: -sqrt(Q) occurs twice" if t == 0 else ""))
    print()


# ---------------------------------------------------------------------------
# 3. Original moves: invariants and decision procedure
# ---------------------------------------------------------------------------

def old_moves_equivalent(xs: Sequence[Num], ys: Sequence[Num]) -> bool:
    """Classification theorem: decide equivalence under permutations,
    (-s,-s) insertion/deletion and even-degree twists, via invariants."""
    if len(xs) % 2 == 1:
        return (core(xs) == core(ys) and n_plus(xs) == n_plus(ys)
                and n_minus(xs) % 2 == n_minus(ys) % 2)
    same = (core(xs) == core(ys) and n_plus(xs) % 2 == n_plus(ys) % 2
            and n_minus(xs) % 2 == n_minus(ys) % 2)
    twisted = (core(ys) == neg_core(core(xs)) and n_plus(ys) % 2 == n_minus(xs) % 2
               and n_minus(ys) % 2 == n_plus(xs) % 2)
    return same or twisted


def msort(xs: Iterable[Fraction]) -> MSet:
    return tuple(sorted(xs))


def old_neighbours(m: MSet, max_len: int) -> List[MSet]:
    out: List[MSet] = []
    if len(m) + 2 <= max_len:
        out.append(msort(list(m) + [MONE, MONE]))
    c = Counter(m)
    if c[MONE] >= 2:
        l = list(m); l.remove(MONE); l.remove(MONE); out.append(msort(l))
    if len(m) % 2 == 0:
        out.append(msort(-x for x in m))
    return out


def dual_neighbours(m: MSet, max_len: int, alphabet: Sequence[Fraction]) -> List[MSet]:
    out: List[MSet] = []
    if len(m) + 2 <= max_len:
        for b in alphabet:
            out.append(msort(list(m) + [b, 1 / b]))
    c = Counter(m)
    for b in set(m):
        need = Counter([b, 1 / b])
        if all(c[k] >= v for k, v in need.items()):
            l = list(m); l.remove(b); l.remove(1 / b); out.append(msort(l))
    return out


def components(nodes: Iterable[MSet], nbrs: Callable[[MSet], List[MSet]]) -> Dict[MSet, int]:
    comp: Dict[MSet, int] = {}
    cid = 0
    for start in nodes:
        if start in comp:
            continue
        comp[start] = cid
        dq = deque([start])
        while dq:
            u = dq.popleft()
            for v in nbrs(u):
                if v not in comp:
                    comp[v] = cid
                    dq.append(v)
        cid += 1
    return comp


ALPHABET: List[Fraction] = [ONE, MONE, Fraction(2), Fraction(-2), Fraction(1, 2), Fraction(-1, 2)]


def all_msets(max_len: int, alphabet: Sequence[Fraction]) -> List[MSet]:
    out: List[MSet] = []
    for d in range(max_len + 1):
        out += [msort(c) for c in combinations_with_replacement(alphabet, d)]
    return out


def section_classification(max_len: int = 6) -> None:
    print("=" * 76)
    print("3-4. CLASSIFICATION OF THE ORIGINAL MOVES (brute force vs. invariants)")
    print("=" * 76)
    nodes = all_msets(max_len, ALPHABET)
    comp = components(nodes, lambda m: old_neighbours(m, max_len))
    checked = disagreements = 0
    by_len: Dict[int, List[MSet]] = {}
    for m in nodes:
        by_len.setdefault(len(m), []).append(m)
    for d, ms in by_len.items():
        for i, a in enumerate(ms):
            for b in ms[i:]:
                checked += 1
                if (comp[a] == comp[b]) != old_moves_equivalent(a, b):
                    disagreements += 1
    print(f"  alphabet (in units of sqrt(Q)) = {[str(x) for x in ALPHABET]}")
    print(f"  all {len(nodes)} lists of length <= {max_len}; {checked} same-degree pairs compared")
    print(f"  disagreements between connectivity and the invariant criterion: {disagreements}")
    a: MSet = msort([ONE, ONE, Fraction(2), Fraction(1, 2)])
    b: MSet = msort([MONE, MONE, Fraction(-2), Fraction(-1, 2)])
    print(f"  example (even degree, twisted branch): {[str(x) for x in a]} ~ {[str(x) for x in b]} :"
          f" {old_moves_equivalent(a, b)}")
    print()


# ---------------------------------------------------------------------------
# 5. The verdict
# ---------------------------------------------------------------------------

def fam(n: int, k: int) -> List[Fraction]:
    """F_{n,k} = [n s, s/n, s, ..., s]  (k trailing copies of s)."""
    return [Fraction(n), Fraction(1, n)] + [ONE] * k


def section_verdict() -> None:
    print("=" * 76)
    print("5. VERDICT: completeness of the original moves fails for every degree >= 2")
    print("=" * 76)
    for k in (0, 1, 2):
        ns = range(2, 7)
        print(f"  degree {k + 2}: F_n = [n s, s/n] + [s]*{k};  signs = "
              f"{[str(sign(fam(n, k))) for n in ns]}")
        mat = [["~" if old_moves_equivalent(fam(n, k), fam(m, k)) else "." for m in ns] for n in ns]
        for n, row in zip(ns, mat):
            print(f"     n={n}: {' '.join(row)}")
    x3, y3 = [ONE, ONE, ONE], [ONE, MONE, MONE]
    print(f"  core-free odd counterexample: sign{[str(v) for v in x3]}={sign(x3)}, "
          f"sign{[str(v) for v in y3]}={sign(y3)}, related by moves: {old_moves_equivalent(x3, y3)}")
    print("  degrees 0 and 1: the only eigensystems are [], [s], [-s] -> completeness holds\n")


# ---------------------------------------------------------------------------
# 6. Dual-pair moves: constructive reduction to normal form
# ---------------------------------------------------------------------------

def dual_reduce(xs: Sequence[Num]) -> Tuple[List[Num], List[str]]:
    """Delete dual pairs {b, 1/b} until only [1]^(n_+ mod 2) + [-1]^(n_- mod 2) remain.
    Returns the normal form and the log of deletions performed."""
    assert is_eigensystem(xs)
    bag: Dict[Hashable, List[Num]] = {}
    for x in xs:
        bag.setdefault(key(x), []).append(x)
    log: List[str] = []
    changed = True
    while changed:
        changed = False
        for k in list(bag.keys()):
            if not bag.get(k):
                continue
            x = bag[k][0]
            kd = key(1 / x)
            needed = 2 if kd == k else 1
            if (len(bag[k]) >= needed) if kd == k else (len(bag.get(kd, [])) >= 1):
                bag[k].pop()
                bag[kd].pop()
                log.append(f"delete {{{fmt(x)}, {fmt(1 / x)}}}")
                changed = True
    rest = [x for v in bag.values() for x in v]
    return rest, log


def fmt(x: Num) -> str:
    if isinstance(x, Fraction):
        return str(x)
    z = complex(x)
    return f"{z.real:+.3f}{z.imag:+.3f}i"


def section_repair() -> None:
    print("=" * 76)
    print("6. REPAIR: dual-pair moves; the four normal forms [], [s,-s], [s], [-s]")
    print("=" * 76)
    rng = random.Random(7)
    seen: Dict[Tuple[int, int], Counter] = {}
    for _ in range(3000):
        xs = random_eigensystem(rng, rng.randint(0, 4), rng.randint(0, 4), rng.randint(0, 4))
        nf, _ = dual_reduce(xs)
        tag = (len(xs) % 2, int(round(sign(xs).real)))
        seen.setdefault(tag, Counter())[tuple(sorted(fmt(v) for v in nf))] += 1
    for tag in sorted(seen):
        print(f"  degree parity {tag[0]}, sign {tag[1]:+d}: normal forms reached -> {dict(seen[tag])}")
    xs = [Fraction(2), Fraction(1, 2)]
    ys = [Fraction(3), Fraction(1, 3)]
    print(f"  [2s, s/2] vs [3s, s/3]: original moves {old_moves_equivalent(xs, ys)}, "
          f"dual-pair moves: delete {{2s, s/2}} then insert {{3s, s/3}} -> True")
    big = [Fraction(5), Fraction(1, 5), ONE, ONE, ONE, MONE, MONE, MONE, Fraction(-3), Fraction(-1, 3)]
    nf, log = dual_reduce(big)
    print(f"  sample reduction of {[str(x) for x in big]}:")
    for line in log:
        print(f"     {line}")
    print(f"     normal form {[str(x) for x in nf]}  (sign {sign(big)}, degree {len(big)})\n")


# ---------------------------------------------------------------------------
# 7. Counting classes per sign class
# ---------------------------------------------------------------------------

def section_counts(max_len: int = 8) -> None:
    print("=" * 76)
    print("7. NUMBER OF MOVE CLASSES INSIDE EACH SIGN CLASS (finite alphabet)")
    print("=" * 76)
    nodes = all_msets(max_len, ALPHABET)
    old = components(nodes, lambda m: old_neighbours(m, max_len))
    new = components(nodes, lambda m: dual_neighbours(m, max_len, ALPHABET))
    print("  degree | sign | #eigensystems | #original-move classes | #dual-pair-move classes")
    for d in range(max_len + 1):
        for eps in (ONE, MONE):
            ms = [m for m in nodes if len(m) == d and is_eigensystem(m) and sign(m) == eps]
            if not ms:
                continue
            print(f"  {d:6d} | {str(eps):>4} | {len(ms):13d} | {len({old[m] for m in ms}):22d} |"
                  f" {len({new[m] for m in ms}):23d}")
    print()


if __name__ == "__main__":
    section_sign_formula()
    section_elliptic()
    section_classification()
    section_verdict()
    section_repair()
    section_counts()
