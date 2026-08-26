#!/usr/bin/env python3
"""
Berggren Moves on (Z/m)^3
=========================

Numerical demonstration of the results on the Barning--Hall / Berggren tree of
primitive Pythagorean triples, its exact linear move classifier, linear-time
seed recovery over the integers, and the information-theoretic collapse of seed
recovery after reduction modulo m.

Everything below is self-contained: no imports beyond the standard library.

Contents
--------
  1.  The three Berggren moves and their explicit integer inverses.
  2.  Lorentz-form invariance and cone invariance.
  3.  The exact linear classifier  which(a,b,c).
  4.  O(k) seed recovery over Z, and freeness of the monoid action.
  5.  Reduction mod m: equivariance, bijectivity, classifier soundness,
      and the explicit failure at m = 7.
  6.  Counting: 3^k words vs m^3 states; measured ambiguity vs the
      Omega(3^k/m^3) and Omega(3^k/2p^2) lower bounds.
  7.  The null cone modulo a prime and the |C_p| <= 2p^2 bound.
  8.  The two-sided threshold  5*7^k < m  vs  m^3 < 3^k.
  9.  Total collapse modulo 2.
 10.  The B_2 spine: silver-ratio spectrum, Pell conic, almost-isosceles
      triples, and the discrete-logarithm / Pell index-finding problem.

Run:  python3 demo.py
"""

from __future__ import annotations

from collections import Counter
from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Triple = Tuple[int, int, int]
Word = Tuple[int, ...]

ROOT: Triple = (3, 4, 5)


# ----------------------------------------------------------------------------
# 1.  The three Berggren moves and their inverses
# ----------------------------------------------------------------------------

def apply_move(i: int, v: Triple) -> Triple:
    """Apply Berggren move B_i (i in {1,2,3}) to the triple v = (a,b,c)."""
    a, b, c = v
    if i == 1:
        return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)
    if i == 2:
        return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)
    if i == 3:
        return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)
    raise ValueError(f"move index must be 1, 2 or 3; got {i}")


def inv_move(i: int, v: Triple) -> Triple:
    """Apply the inverse move B_i^{-1} = Q B_i^T Q,  Q = diag(1,1,-1)."""
    a, b, c = v
    if i == 1:
        return (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)
    if i == 2:
        return (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)
    if i == 3:
        return (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)
    raise ValueError(f"move index must be 1, 2 or 3; got {i}")


BERG_MATRIX: Dict[int, Tuple[Tuple[int, int, int], ...]] = {
    1: ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    2: ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    3: ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
}


def mat_vec(M: Sequence[Sequence[int]], v: Triple, mod: int | None = None) -> Triple:
    """Matrix-vector product, optionally reduced modulo `mod`."""
    out = tuple(sum(M[r][k] * v[k] for k in range(3)) for r in range(3))
    if mod is not None:
        out = tuple(x % mod for x in out)
    return (out[0], out[1], out[2])


def mat_mul(A: Sequence[Sequence[int]], B: Sequence[Sequence[int]],
            mod: int | None = None) -> Tuple[Tuple[int, ...], ...]:
    """3x3 matrix product, optionally reduced modulo `mod`."""
    rows = []
    for r in range(3):
        row = []
        for c in range(3):
            s = sum(A[r][k] * B[k][c] for k in range(3))
            row.append(s % mod if mod is not None else s)
        rows.append(tuple(row))
    return tuple(rows)


def mat_pow(A: Sequence[Sequence[int]], t: int,
            mod: int | None = None) -> Tuple[Tuple[int, ...], ...]:
    """Fast exponentiation of a 3x3 matrix."""
    result: Tuple[Tuple[int, ...], ...] = ((1, 0, 0), (0, 1, 0), (0, 0, 1))
    base = tuple(tuple(r) for r in A)
    while t > 0:
        if t & 1:
            result = mat_mul(result, base, mod)
        base = mat_mul(base, base, mod)
        t >>= 1
    return result


# ----------------------------------------------------------------------------
# 2.  Invariants
# ----------------------------------------------------------------------------

def lorentz(v: Triple) -> int:
    """The Lorentz form a^2 + b^2 - c^2 of signature (2,1)."""
    a, b, c = v
    return a * a + b * b - c * c


def is_valid(v: Triple) -> bool:
    """A *valid* state: a strictly positive Pythagorean triple."""
    a, b, c = v
    return a > 0 and b > 0 and c > 0 and a * a + b * b == c * c


# ----------------------------------------------------------------------------
# 3.  The exact linear classifier
# ----------------------------------------------------------------------------

def which_move(v: Triple) -> int:
    """The Berggren move classifier: two integer comparisons, exactly correct.

        which(a,b,c) = 1  if 5a < 3c
                     = 2  if 3c <= 5a < 4c
                     = 3  if 4c <= 5a
    """
    a, _b, c = v
    if 5 * a < 3 * c:
        return 1
    if 5 * a < 4 * c:
        return 2
    return 3


# ----------------------------------------------------------------------------
# 4.  Words and integer seed recovery
# ----------------------------------------------------------------------------

def apply_word(word: Iterable[int], v: Triple = ROOT) -> Triple:
    """Apply a control word left-to-right: word[0] first, word[-1] last."""
    for i in word:
        v = apply_move(i, v)
    return v


def recover_word(v: Triple, root: Triple = ROOT, max_steps: int = 10_000) -> Word:
    """O(k) seed recovery over Z: peel moves until the root is reached.

    Two comparisons and one 3x3 matrix-vector product per recovered letter.
    """
    peeled: List[int] = []
    steps = 0
    while v != root:
        if steps > max_steps:
            raise RuntimeError("did not terminate; input not in the tree?")
        i = which_move(v)
        peeled.append(i)
        v = inv_move(i, v)
        steps += 1
    return tuple(reversed(peeled))


# ----------------------------------------------------------------------------
# 5.  Reduction modulo m
# ----------------------------------------------------------------------------

def red(v: Triple, m: int) -> Triple:
    """Coordinatewise reduction Z^3 -> (Z/m)^3, representatives in [0, m)."""
    return (v[0] % m, v[1] % m, v[2] % m)


def apply_move_mod(i: int, w: Triple, m: int) -> Triple:
    """The Berggren move acting directly on (Z/m)^3."""
    return red(apply_move(i, w), m)


def which_move_mod(w: Triple, m: int) -> int:
    """The classifier as an observer of a modular state: lift to [0,m), test."""
    return which_move(red(w, m))


def state_mod(word: Iterable[int], m: int) -> Triple:
    """The observation: the state after running `word` from (3,4,5), mod m.

    Computed entirely inside (Z/m)^3, which is legitimate precisely because
    reduction is equivariant:  red(u . v) = u ._m red(v).
    """
    w = red(ROOT, m)
    for i in word:
        w = apply_move_mod(i, w, m)
    return w


# ----------------------------------------------------------------------------
# 6.  The B_2 spine: Pell data
# ----------------------------------------------------------------------------

def pell_pair(t: int) -> Tuple[int, int]:
    """(S_t, C_t) = (a_t + b_t, c_t) for the t-th point of the B_2 orbit.

    Satisfies S_{t+1} = 3 S_t + 4 C_t,  C_{t+1} = 2 S_t + 3 C_t, hence
    x_{t+2} = 6 x_{t+1} - x_t, and the conic S^2 - 2 C^2 = -1.
    """
    S, C = 7, 5
    for _ in range(t):
        S, C = 3 * S + 4 * C, 2 * S + 3 * C
    return S, C


def b2_orbit(t: int) -> Triple:
    """The state after t applications of B_2 to (3,4,5)."""
    return apply_word([2] * t)


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def all_words(k: int) -> List[Word]:
    return [tuple(w) for w in product((1, 2, 3), repeat=k)]


# ----------------------------------------------------------------------------
# Section 1 -- the tree and its invariants
# ----------------------------------------------------------------------------

def demo_tree() -> None:
    banner("1.  The Berggren tree, its invariants, and the exact classifier")

    print(f"root                      = {ROOT}")
    for i in (1, 2, 3):
        child = apply_move(i, ROOT)
        print(f"  B_{i} (3,4,5)             = {child:}"
              f"   Lorentz = {lorentz(child)}   valid = {is_valid(child)}")

    print("\nClassifier check on the first four levels of the tree:")
    total = 0
    ok = 0
    for k in range(1, 5):
        for w in all_words(k):
            v_parent = apply_word(w[:-1])
            v_child = apply_move(w[-1], v_parent)
            total += 1
            ok += int(which_move(v_child) == w[-1])
    print(f"  which(B_i v) == i  on {ok}/{total} parent-child pairs  "
          f"(levels 1..4)   -> {'EXACT' if ok == total else 'FAILURE'}")

    print("\nInverse identities and Lorentz invariance (random-ish sample):")
    for w in [(1,), (2, 3), (3, 1, 2), (2, 2, 2, 1), (1, 3, 3, 2, 1)]:
        v = apply_word(w)
        inv_ok = all(inv_move(i, apply_move(i, v)) == v for i in (1, 2, 3))
        lor_ok = all(lorentz(apply_move(i, v)) == lorentz(v) for i in (1, 2, 3))
        print(f"  word {str(w):<18} state {str(v):<22} "
              f"B^-1 B = id: {inv_ok}   L invariant: {lor_ok}")

    print("\nGrading: each move multiplies the hypotenuse by a factor in (1, 7].")
    v = ROOT
    ratios = []
    for w in all_words(3):
        v = apply_word(w)
        parent = apply_word(w[:-1])
        ratios.append(v[2] / parent[2])
    print(f"  observed factor range over level 3: "
          f"[{min(ratios):.4f}, {max(ratios):.4f}]   (theory: (1, 7])")


# ----------------------------------------------------------------------------
# Section 2 -- integer seed recovery and freeness
# ----------------------------------------------------------------------------

def demo_integer_recovery() -> None:
    banner("2.  Integer seed recovery is exact and linear-time; the action is free")

    examples: List[Word] = [
        (), (1,), (2,), (3,), (1, 2, 3), (2, 2, 2, 2), (3, 1, 3, 1, 2), (1, 1, 1, 1, 1, 1),
    ]
    print(f"{'control word':<24}{'observed state':<34}{'recovered':<22}{'ok'}")
    print("-" * 84)
    for w in examples:
        v = apply_word(w)
        r = recover_word(v)
        print(f"{str(w):<24}{str(v):<34}{str(r):<22}{r == w}")

    print("\nExhaustive freeness / recovery check up to length 8:")
    for k in range(1, 9):
        seen = set()
        good = True
        for w in all_words(k):
            v = apply_word(w)
            seen.add(v)
            if recover_word(v) != w:
                good = False
        print(f"  k = {k}:  distinct states = {len(seen):>6} / 3^{k} = {3**k:<6} "
              f"free = {len(seen) == 3**k}   all words recovered = {good}")


# ----------------------------------------------------------------------------
# Section 3 -- modular soundness and its sharpness
# ----------------------------------------------------------------------------

def demo_modular_soundness() -> None:
    banner("3.  The classifier stays sound modulo m -- until the state wraps around")

    print("Theorem: if the child's hypotenuse c < m, the modular observer's")
    print("canonical lift is the true state and the classifier is correct.\n")

    print(f"{'m':>8}{'words tested':>16}{'no-wrap cases':>16}"
          f"{'correct on those':>20}{'sound?':>10}")
    print("-" * 70)
    for m in (7, 13, 101, 1009, 100003):
        tested = wrapped_free = correct = 0
        for k in range(1, 6):
            for w in all_words(k):
                v = apply_word(w)
                tested += 1
                if v[2] < m:
                    wrapped_free += 1
                    correct += int(which_move_mod(red(v, m), m) == w[-1])
        print(f"{m:>8}{tested:>16}{wrapped_free:>16}{correct:>20}"
              f"{str(correct == wrapped_free):>10}")

    print("\nSharpness: the smallness hypothesis cannot be dropped.")
    child = apply_move(1, ROOT)
    r7 = red(child, 7)
    print(f"  B_1 (3,4,5) = {child}, which = {which_move(child)}")
    print(f"  reduced mod 7 -> {r7}: 5a = {5*r7[0]}, 3c = {3*r7[2]}, 4c = {4*r7[2]}")
    print(f"  classifier verdict mod 7 = B_{which_move_mod(r7, 7)}  "
          f"(true move was B_1)  -> {'FAILS' if which_move_mod(r7,7) != 1 else 'ok'}")


# ----------------------------------------------------------------------------
# Section 4 -- counting and ambiguity
# ----------------------------------------------------------------------------

def reachable_set(m: int, depth: int) -> set:
    """All states in (Z/m)^3 reachable from (3,4,5) by words of length <= depth.

    Breadth-first in the modular state space: because reduction is equivariant
    and each modular move is a bijection, this is a genuine orbit computation
    and costs O(depth * |frontier|) rather than O(3^depth).
    """
    seen = {red(ROOT, m)}
    frontier = list(seen)
    for _ in range(depth):
        nxt = []
        for w in frontier:
            for i in (1, 2, 3):
                x = apply_move_mod(i, w, m)
                if x not in seen:
                    seen.add(x)
                    nxt.append(x)
        frontier = nxt
        if not frontier:
            break
    return seen


def null_cone_size(m: int) -> int:
    """|{ (a,b,c) in (Z/m)^3 : a^2 + b^2 = c^2 }|, by brute force."""
    sq = [(x * x) % m for x in range(m)]
    count = 0
    for a in range(m):
        for b in range(m):
            target = (sq[a] + sq[b]) % m
            count += sum(1 for c in range(m) if sq[c] == target)
    return count


def demo_ambiguity() -> None:
    banner("4.  Counting: 3^k control words squeezed into m^3 observations")

    print("Theorem (impossibility): m^3 < 3^k  =>  no function of the observed")
    print("modular state recovers the control word.")
    print("Theorem (ambiguity):     m^3 * n < 3^k  =>  some observation is")
    print("consistent with more than n distinct length-k words.\n")

    print(f"{'m':>6}{'k':>4}{'3^k':>10}{'m^3':>10}{'distinct obs':>14}"
          f"{'max fibre':>12}{'3^k/m^3':>12}{'3^k/|obs|':>12}")
    print("-" * 80)
    for m, k in [(3, 4), (3, 6), (5, 5), (5, 7), (7, 6), (7, 8), (11, 8), (13, 9)]:
        buckets: Counter[Triple] = Counter()
        for w in all_words(k):
            buckets[state_mod(w, m)] += 1
        max_fibre = max(buckets.values())
        print(f"{m:>6}{k:>4}{3**k:>10}{m**3:>10}{len(buckets):>14}"
              f"{max_fibre:>12}{3**k / m**3:>12.2f}{3**k / len(buckets):>12.2f}")

    print("\nEvery measured 'max fibre' exceeds the guaranteed floor 3^k/m^3,")
    print("and tracks 3^k/|observed set| closely -- evidence that the reachable")
    print("set is a fixed, structured subset of the null cone, not all of (Z/m)^3.")

    print("\nThe null cone bound |C_p| <= 2p^2 for prime p, and the reachable set:")
    primes = (3, 5, 7, 11, 13)
    reachable = {p: reachable_set(p, depth=11) for p in primes}
    print(f"{'p':>6}{'p^3':>10}{'|null cone|':>14}{'2p^2':>10}"
          f"{'|reachable|':>14}")
    print("-" * 54)
    for p in primes:
        print(f"{p:>6}{p**3:>10}{null_cone_size(p):>14}"
              f"{2*p*p:>10}{len(reachable[p]):>14}")

    print("\nThe reachable set is close to half the punctured cone.  The exact")
    print("value 1/2 * m^2 * prod_{p|m} (1 - p^-2) -- i.e. (p^2-1)/2 for prime p --")
    print("is conjectural; here is the measurement.")
    for p in primes:
        conj = (p * p - 1) // 2
        got = len(reachable[p])
        print(f"  p = {p:>3}:  measured {got:>5}   "
              f"conjectured (p^2-1)/2 = {conj:>5}   "
              f"{'MATCH' if got == conj else 'differs'}")


# ----------------------------------------------------------------------------
# Section 5 -- the two-sided threshold
# ----------------------------------------------------------------------------

def demo_threshold() -> None:
    banner("5.  The two-sided threshold:  5*7^k < m  (easy)  vs  m^3 < 3^k  (impossible)")

    print("Growth bound: a length-k word from (3,4,5) has hypotenuse <= 5 * 7^k.\n")
    print(f"{'k':>4}{'max c observed':>18}{'bound 5*7^k':>16}{'ratio':>10}")
    print("-" * 48)
    for k in range(0, 9):
        mx = max(apply_word(w)[2] for w in all_words(k))
        print(f"{k:>4}{mx:>18}{5 * 7**k:>16}{mx / (5 * 7**k):>10.4f}")

    print("\nThe two regimes never overlap:")
    print(f"{'k':>4}{'recovery guaranteed if m >':>28}{'impossible if m <':>22}")
    print("-" * 54)
    for k in range(2, 13, 2):
        lo = round((3 ** k) ** (1 / 3), 2)
        print(f"{k:>4}{5 * 7**k:>28}{lo:>22}")
    print("\nWriting m = 7^(alpha k), the transition lies in "
          "alpha in [log3/(3 log7), 1] ~ [0.188, 1].")
    print("Conjectured exact location: alpha = log 3 / log 7 ~ 0.5646.")

    print("\nDirect verification of the positive side (5*7^k < m => recovery works):")
    for k in (1, 2, 3, 4):
        m = 5 * 7 ** k + 1
        good = all(_recover_mod(state_mod(w, m), m) == w for w in all_words(k))
        print(f"  k = {k}, m = {m:>7}:  all {3**k:>4} words recovered from residues: {good}")


def _recover_mod(w: Triple, m: int, max_steps: int = 10_000) -> Word:
    """Self-terminating modular peeling, using only the residue."""
    target = red(ROOT, m)
    peeled: List[int] = []
    steps = 0
    while w != target:
        if steps > max_steps:
            raise RuntimeError("modular recovery did not terminate")
        i = which_move_mod(w, m)
        peeled.append(i)
        w = red(inv_move(i, red(w, m)), m)
        steps += 1
    return tuple(reversed(peeled))


# ----------------------------------------------------------------------------
# Section 6 -- total collapse mod 2, local separation
# ----------------------------------------------------------------------------

def demo_collapse() -> None:
    banner("6.  Degenerate moduli: total collapse modulo 2, and local separation")

    print("Modulo 2 every Berggren move is the identity on (Z/2)^3:")
    all_id = True
    for i in (1, 2, 3):
        for w in product((0, 1), repeat=3):
            tw = (w[0], w[1], w[2])
            if apply_move_mod(i, tw, 2) != tw:
                all_id = False
    print(f"  B_i acts as the identity on all 8 states, for all i: {all_id}")
    obs = {state_mod(w, 2) for k in range(0, 8) for w in all_words(k)}
    print(f"  observations of every word of length <= 7 mod 2: {obs}")
    print("  -> the observation is a constant function of the word; recovery is")
    print("     not merely hard but carries zero information.")

    print("\nLocal separation.  With parent w = (a,b,c) the three children differ by")
    print("    B_1 w - B_2 w = (-4b, -2b, -4b)")
    print("    B_2 w - B_3 w = ( 2a,  4a,  4a)")
    print("    B_1 w - B_3 w = (2a-4b, 4a-2b, 4a-4b)")
    print("so branching is visible mod m iff 2a, 2b, 2a-4b are all nonzero.\n")
    print(f"{'m':>6}{'states':>10}{'separated':>12}{'fraction':>12}")
    print("-" * 40)
    for m in (2, 3, 5, 7, 11, 13):
        sep = 0
        for a, b, c in product(range(m), repeat=3):
            if (2 * a) % m and (2 * b) % m and (2 * a - 4 * b) % m:
                sep += 1
        print(f"{m:>6}{m**3:>10}{sep:>12}{sep / m**3:>12.4f}")


# ----------------------------------------------------------------------------
# Section 7 -- the B_2 spine, silver ratio, Pell
# ----------------------------------------------------------------------------

def demo_silver_pell() -> None:
    banner("7.  The B_2 spine: silver-ratio spectrum, Pell conic, discrete logarithm")

    B2 = BERG_MATRIX[2]
    print("Characteristic polynomial of B_2:  L^3 - 5L^2 - 5L + 1 "
          "= (L+1)(L^2 - 6L + 1)")
    print("Roots: -1 and 3 +- 2*sqrt(2) = (1 +- sqrt 2)^2  (silver ratio squared)\n")

    # Cayley-Hamilton:  B2^3 = 5 B2^2 + 5 B2 - I
    B2_2 = mat_mul(B2, B2)
    B2_3 = mat_mul(B2_2, B2)
    rhs = tuple(
        tuple(5 * B2_2[r][c] + 5 * B2[r][c] - (1 if r == c else 0) for c in range(3))
        for r in range(3)
    )
    print(f"  Cayley-Hamilton   B_2^3 = 5 B_2^2 + 5 B_2 - I : {B2_3 == rhs}")

    # Silver factorization:  (B2 + I)(B2^2 - 6 B2 + I) = 0
    left = tuple(tuple(B2[r][c] + (1 if r == c else 0) for c in range(3)) for r in range(3))
    right = tuple(
        tuple(B2_2[r][c] - 6 * B2[r][c] + (1 if r == c else 0) for c in range(3))
        for r in range(3)
    )
    prod_ = mat_mul(left, right)
    zero = ((0, 0, 0), (0, 0, 0), (0, 0, 0))
    print(f"  Silver identity   (B_2+I)(B_2^2 - 6B_2 + I) = 0 : {prod_ == zero}")

    print("\nThe orbit of (3,4,5) under B_2 -- the almost-isosceles Pythagorean triples:")
    print(f"{'t':>4}{'(a,b,c)':>26}{'S=a+b':>12}{'C=c':>10}"
          f"{'S^2-2C^2':>12}{'a-b':>7}")
    print("-" * 72)
    for t in range(8):
        v = b2_orbit(t)
        S, C = pell_pair(t)
        assert (v[0] + v[1], v[2]) == (S, C)
        print(f"{t:>4}{str(v):>26}{S:>12}{C:>10}{S*S - 2*C*C:>12}{v[0]-v[1]:>7}")
    print("\n  S^2 - 2C^2 = -1 always: the orbit IS the negative Pell ladder.")
    print("  a - b = (-1)^(t+1) always: the eigenvalue -1 of B_2 in action.")
    print("  Recurrence x_{t+2} = 6 x_{t+1} - x_t for both S and C:")
    for t in range(5):
        s0, _ = pell_pair(t)
        s1, _ = pell_pair(t + 1)
        s2, _ = pell_pair(t + 2)
        print(f"    t={t}: {s2} = 6*{s1} - {s0} -> {6*s1 - s0 == s2}")

    print("\nIterating B_2 modulo m is matrix exponentiation, so recovering t")
    print("from the observed state is a discrete logarithm in GL_3(Z/m).")
    print(f"\n{'m':>8}{'orbit period of B_2 on (3,4,5)':>34}{'m^3':>12}")
    print("-" * 54)
    for m in (7, 11, 13, 17, 23, 29, 41, 101):
        seen: Dict[Triple, int] = {}
        w = red(ROOT, m)
        t = 0
        while w not in seen:
            seen[w] = t
            w = apply_move_mod(2, w, m)
            t += 1
        print(f"{m:>8}{t - seen[w]:>34}{m**3:>12}")

    print("\nPell index-finding = the same problem.  For odd m and matching parity,")
    print("two B_2-powers are indistinguishable mod m iff their (S,C) agree mod m.")
    for m in (11, 13, 17):
        pairs_ok = True
        for t1 in range(0, 30):
            for t2 in range(t1 % 2, 30, 2):
                lhs = state_mod([2] * t1, m) == state_mod([2] * t2, m)
                S1, C1 = pell_pair(t1)
                S2, C2 = pell_pair(t2)
                rhs_ = (S1 % m == S2 % m) and (C1 % m == C2 % m)
                if lhs != rhs_:
                    pairs_ok = False
        print(f"  m = {m:>3}: equivalence verified on all same-parity "
              f"pairs t1,t2 < 30: {pairs_ok}")

    print("\nBaby-step giant-step: recovering t from B_2^t (3,4,5) mod m in O(sqrt N).")
    for m, t_secret in ((10007, 733), (10007, 4001), (100003, 5555)):
        target = state_mod([2] * t_secret, m)
        found = _bsgs_b2(target, m)
        ok = found is not None and state_mod([2] * found, m) == target
        verdict = "OK" if ok else "FAIL"
        print(f"  m = {m:>7}, secret t = {t_secret:>5}  ->  "
              f"recovered t = {found}   {verdict}")


B2_INV_MATRIX: Tuple[Tuple[int, int, int], ...] = (
    (1, 2, -2),
    (2, 1, -2),
    (-2, -2, 3),
)


def _bsgs_b2(target: Triple, m: int, bound: int | None = None) -> int | None:
    """Baby-step giant-step for the B_2 discrete logarithm modulo m.

    Finds t with B_2^t (3,4,5) = target in (Z/m)^3, searching t < `bound`.
    Writing t = i*s + j with s = ceil(sqrt(bound)), the equation
        B_2^{i s + j} r = target
    is equivalent to
        B_2^{j} r = (B_2^{-s})^{i} target,
    so we tabulate the left-hand sides (baby steps) and stride the right-hand
    side (giant steps).  Time and space O(sqrt(bound)).
    """
    if bound is None:
        bound = 8 * m + 8
    s = int(bound ** 0.5) + 1

    baby: Dict[Triple, int] = {}
    w = red(ROOT, m)
    for j in range(s):
        baby.setdefault(w, j)
        w = apply_move_mod(2, w, m)

    giant_inv = mat_pow(B2_INV_MATRIX, s, m)
    cur = red(target, m)
    for i in range(s + 1):
        if cur in baby:
            return i * s + baby[cur]
        cur = mat_vec(giant_inv, cur, m)
    return None


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_tree()
    demo_integer_recovery()
    demo_modular_soundness()
    demo_ambiguity()
    demo_threshold()
    demo_collapse()
    demo_silver_pell()
    banner("Summary")
    print("""
Over Z the Berggren system is an encoder with a perfect decoder: the exact
linear classifier which(a,b,c) = [5a<3c -> B_1; 5a<4c -> B_2; else B_3] reads
off the last move from a single state, and peeling recovers the whole control
word in O(k) operations.  The monoid acts freely, so length-k words really
occupy 3^k distinct states.

Reduction modulo m changes nothing about the encoder: every move stays a
bijection of (Z/m)^3, the Lorentz form stays invariant, and the classifier
stays sound on every state that has not wrapped around.  What changes is the
observation channel.  With only m^3 possible observations and 3^k possible
messages, the pigeonhole principle forces ambiguity Omega(3^k/m^3) -- sharpened
to Omega(3^k / 2p^2) modulo a prime, because the observation lies on the null
cone -- and outright impossibility once m^3 < 3^k.  Modulo 2 the collapse is
total.

Layered on top is a computational obstruction: the B_2-power words hide a
discrete logarithm in GL_3(Z/m), which the silver-ratio spectral identity
(B_2+I)(B_2^2 - 6B_2 + I) = 0 identifies with index-finding on the negative
Pell ladder x^2 - 2y^2 = -1.
""")


if __name__ == "__main__":
    main()
