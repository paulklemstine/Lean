#!/usr/bin/env python3
"""
Parity-Preserving Self-Reduction for Jigsaw Assembly Counting -- numerical demo.

A framed jigsaw puzzle on n sockets is a list of clause pieces; each clause piece is
a list of literal inputs (i, p) with i a socket in {0,...,n-1} and p a polarity in
{0,1} (0 = blank, 1 = tab).  A choice a in {0,1}^n of variable pieces *assembles*
the puzzle when every clause piece has an input (i, p) with a[i] == p.

This script checks, on exhaustively enumerated and random small instances:

  1. Signed-permutation (hyperoctahedral) invariance of the assembly count, via an
     explicit witness bijection.
  2. Compatibility of the action with the group law of signed permutations.
  3. Global complementation is a parsimonious, involutive, size-preserving
     self-reduction; every modular count is a complementation invariant.
  4. Complementation is free away from puzzles whose clause pieces are all empty.
  5. 2-adic divisibility: the polarity-mask symmetry group has order 2^k dividing
     the count; odd counts force a trivial symmetry group; the order is a
     hyperoctahedral invariant.
  6. The mod-2 count via signless inclusion-exclusion, and the affine-subcube
     criterion (only consistent, fully pinning clause subsets contribute).
  7. The labelled physical count count * (m+2)! * n! * n! is always even and is
     never equal to the count of a solvable puzzle.
  8. #SAT <-> #Jigsaw parsimonious translation on DIMACS-style CNFs.

Only the Python standard library is used.
"""
from __future__ import annotations

import itertools
import math
import random
from typing import Iterable, List, Sequence, Tuple

Lit = Tuple[int, int]
Clause = List[Lit]
Puzzle = List[Clause]
Cube = Tuple[int, ...]
SignedPerm = Tuple[Tuple[int, ...], Tuple[int, ...]]  # (perm, mask)


# ----------------------------------------------------------------------------
# The model
# ----------------------------------------------------------------------------
def fits(a: Cube, lit: Lit) -> bool:
    """A literal input mates with the variable piece at its socket."""
    return a[lit[0]] == lit[1]


def assembles(puzzle: Puzzle, a: Cube) -> bool:
    """Every clause piece has a mating input."""
    return all(any(fits(a, l) for l in c) for c in puzzle)


def cube(n: int) -> Iterable[Cube]:
    return itertools.product((0, 1), repeat=n)


def assemblies(puzzle: Puzzle, n: int) -> List[Cube]:
    return [a for a in cube(n) if assembles(puzzle, a)]


def count(puzzle: Puzzle, n: int) -> int:
    return len(assemblies(puzzle, n))


# ----------------------------------------------------------------------------
# Hyperoctahedral action
# ----------------------------------------------------------------------------
def act_lit(g: SignedPerm, lit: Lit) -> Lit:
    perm, mask = g
    i, p = lit
    return (perm[i], (p + mask[i]) % 2)


def act_puzzle(g: SignedPerm, puzzle: Puzzle) -> Puzzle:
    return [[act_lit(g, l) for l in c] for c in puzzle]


def act_cube(g: SignedPerm, a: Cube) -> Cube:
    perm, mask = g
    n = len(perm)
    inv = [0] * n
    for i, j in enumerate(perm):
        inv[j] = i
    return tuple((a[inv[j]] + mask[inv[j]]) % 2 for j in range(n))


def mul(g: SignedPerm, h: SignedPerm) -> SignedPerm:
    """g * h acts as 'first h, then g'."""
    gp, gm = g
    hp, hm = h
    n = len(gp)
    perm = tuple(gp[hp[i]] for i in range(n))
    mask = tuple((hm[i] + gm[hp[i]]) % 2 for i in range(n))
    return (perm, mask)


def complement(puzzle: Puzzle, n: int) -> Puzzle:
    """Global tab/blank swap: the signed permutation (id, all-ones)."""
    return act_puzzle((tuple(range(n)), (1,) * n), puzzle)


def all_signed_perms(n: int) -> List[SignedPerm]:
    return [(p, m) for p in itertools.permutations(range(n)) for m in cube(n)]


# ----------------------------------------------------------------------------
# Mask symmetries and 2-adic divisibility
# ----------------------------------------------------------------------------
def mask_symm(puzzle: Puzzle, n: int) -> List[Cube]:
    """Polarity masks mu whose flip maps the assembly space of P onto itself."""
    A = set(assemblies(puzzle, n))
    out = []
    for mu in cube(n):
        if {tuple((x + y) % 2 for x, y in zip(a, mu)) for a in A} == A:
            out.append(mu)
    return out


def v2(x: int) -> int:
    if x == 0:
        return 10 ** 9
    k = 0
    while x % 2 == 0:
        x //= 2
        k += 1
    return k


# ----------------------------------------------------------------------------
# Mod-2 inclusion-exclusion and the affine-subcube criterion
# ----------------------------------------------------------------------------
def falsifiers(clauses: Sequence[Clause], n: int) -> int:
    """Number of a falsifying every clause in the given subset."""
    return sum(1 for a in cube(n) if all(not any(fits(a, l) for l in c) for c in clauses))


def mod2_by_inclusion_exclusion(puzzle: Puzzle, n: int) -> int:
    total = 0
    for r in range(len(puzzle) + 1):
        for S in itertools.combinations(puzzle, r):
            total += falsifiers(S, n)
    return total % 2


def pins_consistently_everything(clauses: Sequence[Clause], n: int) -> bool:
    """Falsifying all of S forces a[i] = p+1 for each input (i,p); consistent & full?"""
    pinned: dict[int, int] = {}
    for c in clauses:
        for i, p in c:
            v = (p + 1) % 2
            if pinned.get(i, v) != v:
                return False
            pinned[i] = v
    return len(pinned) == n


def mod2_by_affine_criterion(puzzle: Puzzle, n: int) -> int:
    k = 0
    for r in range(len(puzzle) + 1):
        for S in itertools.combinations(puzzle, r):
            k += pins_consistently_everything(S, n)
    return k % 2


# ----------------------------------------------------------------------------
# Encoding: labelled physical assemblies
# ----------------------------------------------------------------------------
def labelled_count(puzzle: Puzzle, n: int) -> int:
    m = len(puzzle)
    return count(puzzle, n) * math.factorial(m + 2) * math.factorial(n) ** 2


# ----------------------------------------------------------------------------
# SAT <-> Jigsaw
# ----------------------------------------------------------------------------
def dimacs_to_puzzle(cnf: List[List[int]]) -> Puzzle:
    """DIMACS literal +v / -v (v >= 1) -> input at socket v-1, polarity 1 / 0."""
    return [[(abs(x) - 1, 1 if x > 0 else 0) for x in c] for c in cnf]


def puzzle_to_dimacs(puzzle: Puzzle) -> List[List[int]]:
    return [[(i + 1) if p == 1 else -(i + 1) for i, p in c] for c in puzzle]


def sat_count(cnf: List[List[int]], n: int) -> int:
    return sum(1 for a in cube(n)
               if all(any((a[abs(x) - 1] == 1) == (x > 0) for x in c) for c in cnf))


# ----------------------------------------------------------------------------
def random_puzzle(n: int, m: int, width: int, rng: random.Random) -> Puzzle:
    return [[(rng.randrange(n), rng.randrange(2)) for _ in range(rng.randint(0, width))]
            for _ in range(m)]


def main() -> None:
    rng = random.Random(2026)

    print("=" * 72)
    print("1. A worked example")
    n = 3
    P: Puzzle = [[(0, 1), (1, 1)], [(1, 0), (2, 1)]]
    Pc = complement(P, n)
    print("  P        =", P)
    print("  comp(P)  =", Pc)
    print("  assemblies(P)       =", assemblies(P, n))
    print("  assemblies(comp(P)) =", assemblies(Pc, n))
    print("  counts:", count(P, n), count(Pc, n))

    print("=" * 72)
    print("2. Hyperoctahedral invariance with explicit witness bijection")
    checked = 0
    for _ in range(300):
        n = rng.randint(1, 4)
        Q = random_puzzle(n, rng.randint(0, 5), 3, rng)
        for g in rng.sample(all_signed_perms(n), min(6, 2 ** n * math.factorial(n))):
            A = assemblies(Q, n)
            B = set(assemblies(act_puzzle(g, Q), n))
            image = {act_cube(g, a) for a in A}
            assert image == B and len(image) == len(A)
            checked += 1
    print(f"  {checked} (puzzle, signed permutation) pairs: g maps assemblies(P) onto assemblies(gP)")

    print("=" * 72)
    print("3. Group law: (g*h).P == g.(h.P)")
    for _ in range(300):
        n = rng.randint(1, 4)
        Q = random_puzzle(n, 4, 3, rng)
        G = all_signed_perms(n)
        g, h = rng.choice(G), rng.choice(G)
        assert act_puzzle(mul(g, h), Q) == act_puzzle(g, act_puzzle(h, Q))
    print("  verified on 300 random triples")

    print("=" * 72)
    print("4. Complementation: parsimonious, involutive, size preserving, free")
    for n in range(1, 4):
        lits = [(i, p) for i in range(n) for p in (0, 1)]
        clauses = [list(c) for r in range(0, 3) for c in itertools.combinations(lits, r)]
        tot = 0
        for Q in itertools.product(clauses, repeat=2):
            Q = list(map(list, Q))
            Qc = complement(Q, n)
            assert count(Q, n) == count(Qc, n)
            for k in (2, 3, 5):
                assert count(Q, n) % k == count(Qc, n) % k
            assert complement(Qc, n) == Q
            assert sum(map(len, Q)) == sum(map(len, Qc))
            assert (Qc == Q) == all(len(c) == 0 for c in Q)
            tot += 1
        print(f"  n={n}: all {tot} two-clause puzzles (clause width <= 2) pass")

    print("=" * 72)
    print("5. 2-adic certificates from polarity-mask symmetries")
    stats = {"equal": 0, "gap": 0}
    for _ in range(400):
        n = rng.randint(1, 4)
        Q = random_puzzle(n, rng.randint(0, 4), 3, rng)
        c = count(Q, n)
        H = mask_symm(Q, n)
        k = int(math.log2(len(H)))
        assert 2 ** k == len(H) and c % len(H) == 0
        if c % 2 == 1:
            assert len(H) == 1
        g = rng.choice(all_signed_perms(n))
        assert len(mask_symm(act_puzzle(g, Q), n)) == len(H)
        if c > 0:
            stats["equal" if v2(c) == k else "gap"] += 1
    print("  |H| = 2^k divides count, odd count => H trivial, |H| invariant: OK")
    print(f"  among solvable samples: v2(count) = k in {stats['equal']}, strict gap in {stats['gap']}")

    print("=" * 72)
    print("6. Mod-2 count: signless inclusion-exclusion and affine-subcube criterion")
    for _ in range(300):
        n = rng.randint(1, 4)
        Q = random_puzzle(n, rng.randint(0, 5), 3, rng)
        c2 = count(Q, n) % 2
        assert c2 == mod2_by_inclusion_exclusion(Q, n) == mod2_by_affine_criterion(Q, n)
    print("  three ways of computing count mod 2 agree on 300 random puzzles")

    print("=" * 72)
    print("7. The encoding breaks parsimony")
    for n, Q in [(3, P), (2, [[(0, 1)], [(1, 0)]]), (2, [[(0, 1)], [(0, 0)]])]:
        c, L = count(Q, n), labelled_count(Q, n)
        print(f"  n={n}, m={len(Q)}: count={c:3d}  labelled={L:8d}  even={L % 2 == 0}"
              f"  parsimonious={L == c}")

    print("=" * 72)
    print("8. #SAT <-> #Jigsaw")
    for _ in range(200):
        n = rng.randint(1, 5)
        cnf = [[rng.choice([1, -1]) * rng.randint(1, n) for _ in range(rng.randint(1, 3))]
               for _ in range(rng.randint(0, 6))]
        Q = dimacs_to_puzzle(cnf)
        assert count(Q, n) == sat_count(cnf, n)
        assert puzzle_to_dimacs(Q) == cnf
    print("  translations are mutually inverse and count-preserving on 200 random CNFs")
    print("=" * 72)
    print("All checks passed.")


if __name__ == "__main__":
    main()
