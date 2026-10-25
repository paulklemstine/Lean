#!/usr/bin/env python3
"""
Turn-Minimal Normal Form for Record Snakes -- numerical companion.

This script illustrates, on concrete data, every result of the accompanying paper:

  1. The Comb Theorem: a row sequence that visits r distinct rows makes at least
     r - 1 turns, with equality exactly when every row is visited in one
     contiguous block (a "comb").
  2. Step accounting: in a box product G x H every step of a walk moves in exactly
     one factor, so (row turns) + (column turns) = length.
  3. The Block Lemma and the turn lower bound: every maximal constant-row block of
     a snake in G x H is a snake of H, hence
         L + 1 <= (turns + 1) * (S + 1)
     when every snake of H has length at most S.  For Q_{a+b} = Q_a x Q_b this
     gives the unconditional bound L + 1 <= (turns + 1) * 2^b.
  4. The averaging normal form: the flip counts of the n coordinates sum to L,
     so some coordinate (after relabelling, the first) is flipped at most L/n
     times, and some a-set of coordinates is flipped at most aL/n times in total.
  5. Record search for n <= 6 and a one-turn comb in Q_7, together with a check of
     the "comb saturation" phenomenon.

Pure Python 3, no dependencies.  Vertices of Q_n are integers in [0, 2^n);
a snake is given by its start vertex 0 and its *transition sequence*
(the list of coordinates flipped at each step).
"""
from __future__ import annotations

import itertools
import math
import random
import sys
import time
from typing import Callable, Dict, Hashable, List, Optional, Sequence, Tuple

sys.setrecursionlimit(10_000)


# ---------------------------------------------------------------------------
# 1. Hypercube snakes
# ---------------------------------------------------------------------------

def vertices_from_transitions(trans: Sequence[int], start: int = 0) -> List[int]:
    """Vertex sequence p_0, ..., p_L of the walk with the given transition sequence."""
    verts = [start]
    for c in trans:
        verts.append(verts[-1] ^ (1 << c))
    return verts


def hamming(x: int, y: int) -> int:
    return bin(x ^ y).count("1")


def is_snake(verts: Sequence[int]) -> bool:
    """Induced path: distinct vertices, adjacent exactly when consecutive."""
    L = len(verts) - 1
    if len(set(verts)) != len(verts):
        return False
    for i in range(L + 1):
        for j in range(i + 1, L + 1):
            if (hamming(verts[i], verts[j]) == 1) != (j == i + 1):
                return False
    return True


def longest_snake(n: int, target: Optional[int] = None,
                  time_limit: float = 60.0) -> List[int]:
    """Depth-first search for a long snake in Q_n.

    Symmetry breaking: start at vertex 0 and introduce coordinates in increasing
    order (the first use of coordinate i happens after the first use of i-1).
    A vertex may be appended iff it is unused and adjacent to exactly one path
    vertex, namely the current tail.  Returns the transition sequence of the
    longest snake found (stops early once `target` is reached).
    """
    N = 1 << n
    adj_count = [0] * N
    on_path = [False] * N
    on_path[0] = True
    for i in range(n):
        adj_count[1 << i] += 1
    path: List[int] = [0]
    trans: List[int] = []
    best: List[int] = []
    deadline = time.time() + time_limit

    def rec(max_coord: int) -> bool:
        nonlocal best
        if len(trans) > len(best):
            best = list(trans)
        if target is not None and len(best) >= target:
            return True
        if time.time() > deadline:
            return True
        v = path[-1]
        for i in range(min(n, max_coord + 1)):
            w = v ^ (1 << i)
            if on_path[w] or adj_count[w] != 1:
                continue
            path.append(w); trans.append(i); on_path[w] = True
            for j in range(n):
                adj_count[w ^ (1 << j)] += 1
            if rec(max(max_coord, i + 1)):
                return True
            for j in range(n):
                adj_count[w ^ (1 << j)] -= 1
            path.pop(); trans.pop(); on_path[w] = False
        return False

    rec(0)
    return best


# ---------------------------------------------------------------------------
# 2. Turn counts and combs
# ---------------------------------------------------------------------------

def turn_count(seq: Sequence[Hashable]) -> int:
    """Number of indices s with seq[s] != seq[s+1]."""
    return sum(1 for s in range(len(seq) - 1) if seq[s] != seq[s + 1])


def is_comb(seq: Sequence[Hashable]) -> bool:
    """Every value occupies one contiguous block of indices."""
    seen = set()
    for s, x in enumerate(seq):
        if s > 0 and x != seq[s - 1] and x in seen:
            return False
        seen.add(x)
    return True


def blocks(seq: Sequence[Hashable]) -> List[Tuple[int, int]]:
    """Maximal constant blocks as inclusive index intervals [start, end]."""
    out: List[Tuple[int, int]] = []
    start = 0
    for s in range(1, len(seq) + 1):
        if s == len(seq) or seq[s] != seq[start]:
            out.append((start, s - 1))
            start = s
    return out


def check_comb_theorem(alphabet: int = 3, max_len: int = 8) -> int:
    """Exhaustively check: turns >= r - 1, with equality iff comb."""
    checked = 0
    for length in range(1, max_len + 1):
        for seq in itertools.product(range(alphabet), repeat=length):
            r = len(set(seq))
            t = turn_count(seq)
            assert t >= r - 1
            assert (t == r - 1) == is_comb(seq)
            checked += 1
    return checked


# ---------------------------------------------------------------------------
# 3. Coordinate splits Q_{a+b} = Q_a x Q_b
# ---------------------------------------------------------------------------

def project(v: int, coords: Sequence[int]) -> Tuple[int, ...]:
    """Restriction of the vertex v to the coordinates in `coords`."""
    return tuple((v >> c) & 1 for c in coords)


def row_col_sequences(verts: Sequence[int], row_coords: Sequence[int],
                      n: int) -> Tuple[List[Tuple[int, ...]], List[Tuple[int, ...]]]:
    col_coords = [c for c in range(n) if c not in set(row_coords)]
    rows = [project(v, row_coords) for v in verts]
    cols = [project(v, col_coords) for v in verts]
    return rows, cols


def flip_profile(trans: Sequence[int], n: int) -> List[int]:
    """How many times each coordinate is flipped."""
    prof = [0] * n
    for c in trans:
        prof[c] += 1
    return prof


def best_row_set(trans: Sequence[int], n: int, a: int) -> Tuple[Tuple[int, ...], int]:
    """An a-set of row coordinates minimising the number of direction changes.

    The row sequence changes at step s exactly when the flipped coordinate lies in
    the row set R, so the turn count of R is the sum of the flip counts over R; the
    minimum is attained by the a least-flipped coordinates (O(L + n log n))."""
    prof = flip_profile(trans, n)
    best = tuple(sorted(sorted(range(n), key=lambda c: (prof[c], c))[:a]))
    return best, sum(prof[c] for c in best)


# ---------------------------------------------------------------------------
# 4. One-turn combs in Q_1 x Q_{n-1}
# ---------------------------------------------------------------------------

def one_turn_comb(A: Sequence[int], n_minus_1: int, time_limit: float = 20.0) -> List[int]:
    """Given a snake A in Q_{n-1} (transition list from 0), search a second snake B in
    Q_{n-1} starting at A's endpoint and avoiding A's other vertices.  The walk
    A, (flip new coordinate), B is then a snake in Q_n with exactly one turn in the
    new coordinate.  Returns the transitions of B."""
    m = n_minus_1
    verts = vertices_from_transitions(A)
    forbidden = set(verts[:-1])
    u = verts[-1]
    best: List[int] = []
    deadline = time.time() + time_limit

    def ok(w: int, on: set, v: int) -> bool:
        if w in forbidden or w in on:
            return False
        return not any((w ^ (1 << j)) in on and (w ^ (1 << j)) != v for j in range(m))

    def rec(path: List[int], on: set, tr: List[int]) -> None:
        nonlocal best
        if len(tr) > len(best):
            best = list(tr)
        if time.time() > deadline:
            return
        v = path[-1]
        for i in range(m):
            w = v ^ (1 << i)
            if ok(w, on, v):
                path.append(w); on.add(w); tr.append(i)
                rec(path, on, tr)
                path.pop(); on.discard(w); tr.pop()

    rec([u], {u}, [])
    return best


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def main() -> None:
    random.seed(2026)

    banner("1. The Comb Theorem (exhaustive check on short sequences)")
    k = check_comb_theorem(3, 8)
    print(f"checked {k} sequences over a 3-letter alphabet: "
          f"turns >= rows - 1, with equality exactly for combs.")
    ex_comb = list("AAABBCCCC")
    ex_back = list("AABBAACCC")
    for ex in (ex_comb, ex_back):
        print(f"  {''.join(ex)}: rows={len(set(ex))}, turns={turn_count(ex)}, comb={is_comb(ex)}")

    banner("2. Record snakes for n <= 6 (depth-first search)")
    S: Dict[int, int] = {0: 0}
    records: Dict[int, List[int]] = {}
    known = {1: 1, 2: 2, 3: 4, 4: 7, 5: 13, 6: 26}
    for n in range(1, 7):
        t0 = time.time()
        tr = longest_snake(n, target=known[n], time_limit=60)
        verts = vertices_from_transitions(tr)
        assert is_snake(verts)
        S[n] = len(tr)
        records[n] = tr
        print(f"  n={n}: length {len(tr):2d} (known maximum {known[n]:2d})  "
              f"[{time.time() - t0:.2f}s]  transitions={tr}")

    banner("3. Step accounting and the turn lower bound in Q_n = Q_a x Q_b")
    for n in (5, 6):
        tr = records[n]
        verts = vertices_from_transitions(tr)
        L = len(tr)
        for a in (1, 2):
            R = list(range(a))
            rows, cols = row_col_sequences(verts, R, n)
            rt, ct = turn_count(rows), turn_count(cols)
            b = n - a
            assert rt + ct == L
            # Block lemma: every row block is a snake of the column factor
            for (s, e) in blocks(rows):
                block_cols = [int("".join(map(str, c)) or "0", 2) for c in cols[s:e + 1]]
                assert is_snake(block_cols)
            assert L + 1 <= (rt + 1) * (S[b] + 1) <= (rt + 1) * 2 ** b
            print(f"  n={n}, L={L}, rows=first {a} coord(s): row turns={rt}, col turns={ct}, "
                  f"sum={rt + ct};  L+1={L + 1} <= (rt+1)(S({b})+1)={(rt + 1) * (S[b] + 1)}"
                  f" <= (rt+1)2^{b}={(rt + 1) * 2 ** b}")

    banner("4. Averaging normal form: some a-set of coordinates gives <= aL/n turns")
    for n in (5, 6):
        tr = records[n]
        L = len(tr)
        prof = flip_profile(tr, n)
        print(f"  n={n}, L={L}, flip profile={prof}, sum={sum(prof)}")
        for a in range(1, n):
            R, t = best_row_set(tr, n, a)
            assert t * n <= a * L
            print(f"     a={a}: best row set {R} has {t} turns  <=  aL/n = {a * L / n:.2f}")

    banner("5. A one-turn comb in Q_7 built from two snakes of Q_6")
    A6 = records[6]
    best_total, bestA, bestB = -1, [], []
    for A in (A6[1:], A6[::-1][1:], A6):
        B = one_turn_comb(A, 6, time_limit=8)
        if len(A) + len(B) + 1 > best_total:
            best_total, bestA, bestB = len(A) + len(B) + 1, list(A), B
    tr7 = bestA + [6] + bestB
    verts7 = vertices_from_transitions(tr7)
    assert is_snake(verts7)
    prof7 = flip_profile(tr7, 7)
    print(f"  snake in Q_7 of length {len(tr7)}  = {len(bestA)} + 1 + {len(bestB)}")
    print(f"  flip profile = {prof7}  (coordinate 6 flips exactly once)")
    rows7 = [project(v, [6]) for v in verts7]
    print(f"  row sequence in Q_1 x Q_6 is a comb: {is_comb(rows7)}, turns = {turn_count(rows7)}")
    S[7] = len(tr7)
    records[7] = tr7

    banner("6. Comb saturation: does min-flip meet ceil((L+1)/(S(n-1)+1)) - 1 ?")
    print("   (S(n-1) taken as the known maximum; S(6) = 26)")
    exact = {0: 0, 1: 1, 2: 2, 3: 4, 4: 7, 5: 13, 6: 26}
    for n in range(2, 8):
        tr = records[n]
        L = len(tr)
        prof = flip_profile(tr, n)
        lower = math.ceil((L + 1) / (exact[n - 1] + 1)) - 1
        mn = min(prof)
        print(f"  n={n}: L={L:2d}  min flip={mn}  lower bound={lower}  "
              f"averaging bound floor(L/n)={L // n}  saturated={mn == lower}")

    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
