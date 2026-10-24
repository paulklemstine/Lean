#!/usr/bin/env python3
"""
The multiplicative hierarchy of the injective-orbit spectrum -- numerical demonstrations.

A finite group G acts on a finite set X = {0, ..., n-1}.  For r >= 0 let

    t_r = number of G-orbits on injective r-tuples (x_1, ..., x_r) of X.

This script verifies, by brute force on small permutation groups, the results:

  1. Exact fibration formula:
         t_{r+s} = sum over orbit representatives u of injective r-tuples of
                   #( Stab(u)-orbits on injective s-tuples avoiding u ).
  2. Refined hierarchy:   sum_[u] a([u], s) <= t_{r+s},
     where a([u], s) = number of G-orbits of injective s-tuples having a member disjoint from u.
  3. Two-sided sandwich:
         t_r * (t_1 - r)^{(s)}  <=  t_{r+s}  <=  t_r * (n - r)^{(s)},
     where m^{(s)} = m (m-1) ... (m-s+1) is the falling factorial (truncated subtraction).
  4. Sharpness: trivial actions attain the lower bound, free actions attain the upper bound.
  5. The coarse inequality t_{r+s} >= t_r (t_s - r) is FALSE (trivial group, n = 3, r = 1, s = 2).
  6. Repaired coarse inequality:
         t_{r+s} >= t_r * (t_s - (n^{(s)} - (n - r)^{(s)})).

Self-contained: only the Python standard library is used.
"""
from __future__ import annotations

from itertools import permutations
from typing import Dict, FrozenSet, Iterable, List, Sequence, Set, Tuple

Perm = Tuple[int, ...]
Tup = Tuple[int, ...]


# ---------------------------------------------------------------------------
# Elementary arithmetic
# ---------------------------------------------------------------------------

def tsub(a: int, b: int) -> int:
    """Truncated subtraction on the natural numbers: max(a - b, 0)."""
    return a - b if a > b else 0


def falling(m: int, s: int) -> int:
    """Falling factorial m^{(s)} = m (m-1) ... (m-s+1), with truncated factors (0 if s > m)."""
    out = 1
    for i in range(s):
        out *= tsub(m, i)
    return out


# ---------------------------------------------------------------------------
# Permutation groups
# ---------------------------------------------------------------------------

def compose(p: Perm, q: Perm) -> Perm:
    """(p o q)(x) = p(q(x))."""
    return tuple(p[q[x]] for x in range(len(q)))


def generate_group(n: int, gens: Iterable[Perm]) -> List[Perm]:
    """Closure of a set of permutations of {0..n-1} under composition."""
    identity: Perm = tuple(range(n))
    gens = [tuple(g) for g in gens]
    elems: Set[Perm] = {identity}
    frontier: List[Perm] = [identity]
    while frontier:
        new: List[Perm] = []
        for a in frontier:
            for g in gens:
                b = compose(g, a)
                if b not in elems:
                    elems.add(b)
                    new.append(b)
        frontier = new
    return sorted(elems)


def trivial_group(n: int) -> List[Perm]:
    return [tuple(range(n))]


def cyclic_group(n: int) -> List[Perm]:
    """Rotations of an n-gon: a free (regular) action on its vertices."""
    return generate_group(n, [tuple((x + 1) % n for x in range(n))])


def dihedral_group(n: int) -> List[Perm]:
    """Symmetries of a regular n-gon acting on its vertices."""
    rot = tuple((x + 1) % n for x in range(n))
    ref = tuple((-x) % n for x in range(n))
    return generate_group(n, [rot, ref])


def symmetric_group(n: int) -> List[Perm]:
    return [tuple(p) for p in permutations(range(n))]


def act(g: Perm, u: Tup) -> Tup:
    """Diagonal action on tuples: g . (x_1, ..., x_r) = (g x_1, ..., g x_r)."""
    return tuple(g[x] for x in u)


# ---------------------------------------------------------------------------
# Orbits of injective tuples
# ---------------------------------------------------------------------------

def injective_tuples(points: Sequence[int], r: int) -> List[Tup]:
    return list(permutations(points, r))


def canonical(G: Sequence[Perm], u: Tup) -> Tup:
    """Lexicographically least element of the G-orbit of u (an orbit invariant)."""
    return min(act(g, u) for g in G)


def orbit_reps(G: Sequence[Perm], tuples: Iterable[Tup]) -> List[Tup]:
    """One canonical representative for each G-orbit met by `tuples`."""
    return sorted({canonical(G, u) for u in tuples})


def t_spectrum(G: Sequence[Perm], n: int, r: int) -> int:
    """t_r = number of G-orbits of injective r-tuples."""
    return len(orbit_reps(G, injective_tuples(range(n), r)))


def stabilizer(G: Sequence[Perm], u: Tup) -> List[Perm]:
    """Pointwise stabiliser of the tuple u."""
    return [g for g in G if act(g, u) == u]


def rel_count(G: Sequence[Perm], n: int, u: Tup, s: int) -> int:
    """Number of Stab(u)-orbits on injective s-tuples in X minus the entries of u."""
    H = stabilizer(G, u)
    rest = [x for x in range(n) if x not in u]
    return len(orbit_reps(H, injective_tuples(rest, s)))


def avoid_count(G: Sequence[Perm], n: int, u: Tup, s: int) -> int:
    """Number of G-orbits of injective s-tuples that contain a tuple disjoint from u."""
    rest = [x for x in range(n) if x not in u]
    return len(orbit_reps(G, injective_tuples(rest, s)))


# ---------------------------------------------------------------------------
# Checks
# ---------------------------------------------------------------------------

def fibration_table(G: Sequence[Perm], n: int, r: int, s: int) -> List[Tuple[Tup, int, int, int]]:
    """For each orbit [u] of injective r-tuples: (u, |Stab u|, relCount, avoidCount)."""
    rows = []
    for u in orbit_reps(G, injective_tuples(range(n), r)):
        rows.append((u, len(stabilizer(G, u)), rel_count(G, n, u, s), avoid_count(G, n, u, s)))
    return rows


def check_all(name: str, G: Sequence[Perm], n: int, verbose: bool = True) -> Dict[str, bool]:
    """Verify every theorem for all r, s with r + s <= n."""
    t = [t_spectrum(G, n, r) for r in range(n + 1)]
    ok = {"fibration": True, "refined": True, "lower": True, "upper": True, "repaired": True}
    for r in range(n + 1):
        for s in range(n + 1 - r):
            rows = fibration_table(G, n, r, s)
            exact = sum(rc for (_, _, rc, _) in rows)
            ok["fibration"] &= exact == t[r + s]
            ok["refined"] &= sum(ac for (_, _, _, ac) in rows) <= t[r + s]
            ok["lower"] &= t[r] * falling(tsub(t[1], r), s) <= t[r + s]
            ok["upper"] &= t[r + s] <= t[r] * falling(n - r, s)
            corr = falling(n, s) - falling(n - r, s)
            ok["repaired"] &= t[r] * tsub(t[s], corr) <= t[r + s]
    if verbose:
        print(f"\n=== {name}: |G| = {len(G)}, |X| = {n} ===")
        print("  spectrum t_0..t_n =", t)
        for key, val in ok.items():
            print(f"  {key:10s}: {'holds' if val else 'FAILS'}")
    return ok


def sandwich_report(name: str, G: Sequence[Perm], n: int, r: int) -> None:
    t = [t_spectrum(G, n, k) for k in range(n + 1)]
    print(f"\n  Sandwich for {name}, r = {r}:")
    print("     s | lower t_r(t_1-r)^(s) | t_(r+s) | upper t_r(n-r)^(s)")
    for s in range(n + 1 - r):
        lo = t[r] * falling(tsub(t[1], r), s)
        hi = t[r] * falling(n - r, s)
        print(f"    {s:2d} | {lo:20d} | {t[r + s]:7d} | {hi:18d}")


def coarse_counterexample() -> None:
    """The coarse inequality t_{r+s} >= t_r (t_s - r) fails for the trivial group on 3 points."""
    n, r, s = 3, 1, 2
    G = trivial_group(n)
    t = [t_spectrum(G, n, k) for k in range(n + 1)]
    lhs, rhs = t[r + s], t[r] * tsub(t[s], r)
    print("\n=== The coarse form of the conjecture ===")
    print(f"  trivial group on {n} points, r = {r}, s = {s}: t = {t}")
    print(f"  t_(r+s) = {lhs}   versus   t_r (t_s - r) = {t[r]} * ({t[s]} - {r}) = {rhs}")
    print(f"  inequality {'holds' if lhs >= rhs else 'FAILS'}: {lhs} {'>=' if lhs >= rhs else '<'} {rhs}")
    corr = falling(n, s) - falling(n - r, s)
    print(f"  repaired correction n^(s) - (n-r)^(s) = {falling(n, s)} - {falling(n - r, s)} = {corr}")
    print(f"  repaired bound t_r (t_s - {corr}) = {t[r] * tsub(t[s], corr)} <= {lhs}")


def search_coarse_failures(max_n: int = 5) -> None:
    """Scan a few families for failures of the coarse inequality."""
    print("\n=== Failures of the coarse inequality t_(r+s) >= t_r (t_s - r) ===")
    fams = [("trivial", trivial_group), ("cyclic", cyclic_group),
            ("dihedral", dihedral_group), ("symmetric", symmetric_group)]
    for fname, fam in fams:
        for n in range(1, max_n + 1):
            G = fam(n)
            t = [t_spectrum(G, n, k) for k in range(n + 1)]
            bad = [(r, s) for r in range(n + 1) for s in range(n + 1 - r)
                   if t[r + s] < t[r] * tsub(t[s], r)]
            if bad:
                print(f"  {fname:9s} n={n}: failing (r, s) = {bad}")


def main() -> None:
    print("Multiplicative hierarchy of the injective-orbit spectrum")
    examples = [
        ("trivial group on 4 points", trivial_group(4), 4),
        ("cyclic group C_5 (free)", cyclic_group(5), 5),
        ("dihedral group D_4 on a square", dihedral_group(4), 4),
        ("dihedral group D_5 on a pentagon", dihedral_group(5), 5),
        ("symmetric group S_4", symmetric_group(4), 4),
        ("C_2 x C_2 swapping {0,1} and {2,3} separately",
         generate_group(5, [(1, 0, 2, 3, 4), (0, 1, 3, 2, 4)]), 5),
    ]
    for name, G, n in examples:
        check_all(name, G, n)

    print("\n=== Exact fibration for D_4 on a square, r = 1, s = 2 ===")
    print("  rep u | |Stab u| | Stab(u)-orbits avoiding u | G-orbits avoiding u")
    G = dihedral_group(4)
    rows = fibration_table(G, 4, 1, 2)
    for u, st, rc, ac in rows:
        print(f"  {str(u):5s} | {st:8d} | {rc:25d} | {ac:19d}")
    print(f"  sum = {sum(r[2] for r in rows)} = t_3 = {t_spectrum(G, 4, 3)}")

    sandwich_report("trivial group, n = 5 (lower bound attained)", trivial_group(5), 5, 1)
    sandwich_report("cyclic C_6, n = 6 (upper bound attained)", cyclic_group(6), 6, 1)
    sandwich_report("dihedral D_6, n = 6 (strictly between)", dihedral_group(6), 6, 1)

    coarse_counterexample()
    search_coarse_failures()


if __name__ == "__main__":
    main()
