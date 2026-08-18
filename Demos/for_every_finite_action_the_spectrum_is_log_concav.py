"""
The subset spectrum of a finite group action: numerical demonstrations.

For a finite group G acting on a finite set X with |X| = n, the *subset spectrum*
is the sequence

    t_r = number of G-orbits on the r-element subsets of X,   0 <= r <= n.

This script demonstrates, by explicit computation:

  1. Basic structure: t_0 = t_n = 1, the complementation symmetry t_r = t_{n-r},
     and the sandwich  C(n,r)/|G| <= t_r <= C(n,r).
  2. Burnside's mass formula  t_r * |G| = sum over g of #{ r-subsets fixed by g }.
  3. The failure of log-concavity: t_r^2 >= t_{r-1} * t_{r+1} is FALSE in general.
     The smallest counterexample is the cyclic group C_4 acting on 4 points,
     whose spectrum is (1, 1, 2, 1, 1): here t_1^2 = 1 < 2 = t_0 * t_2.
     Every regular action on n >= 4 points fails in the same way.
  4. The rigidity theorem: for a transitive action, log-concavity of the spectrum
     is equivalent to set-transitivity (t_r = 1 for all r), which forces
     C(n,r) <= |G| for every r.
  5. The two surviving guarded inequalities, valid for EVERY finite action:
         t_{r-1} * t_{r+1} <= |G|^2 * t_r^2        (group-size guard)
         t_{r-1} * t_{r+1} <= r(n-r) * t_r^2       (group-free shadow guard)

Everything is self-contained: groups are represented as explicit lists of
permutations of {0, ..., n-1}, and no external libraries are used.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, permutations
from math import comb
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]  # a permutation of {0,...,n-1}, as the tuple of images
Subset = Tuple[int, ...]  # a sorted tuple of points


# ----------------------------------------------------------------------------
# Permutation groups
# ----------------------------------------------------------------------------

def compose(p: Perm, q: Perm) -> Perm:
    """Composition (p . q)(x) = p(q(x))."""
    return tuple(p[q[x]] for x in range(len(p)))


def generated_group(n: int, gens: Sequence[Perm]) -> List[Perm]:
    """Closure of the given generators under composition (orbit of the identity)."""
    identity: Perm = tuple(range(n))
    seen = {identity}
    frontier = [identity]
    while frontier:
        p = frontier.pop()
        for g in gens:
            q = compose(g, p)
            if q not in seen:
                seen.add(q)
                frontier.append(q)
    return sorted(seen)


def cyclic_group(n: int) -> List[Perm]:
    """The regular action of the cyclic group C_n on n points (rotation)."""
    shift: Perm = tuple((x + 1) % n for x in range(n))
    return generated_group(n, [shift])


def dihedral_group(n: int) -> List[Perm]:
    """The dihedral group D_n acting on the n vertices of a regular n-gon."""
    shift: Perm = tuple((x + 1) % n for x in range(n))
    flip: Perm = tuple((-x) % n for x in range(n))
    return generated_group(n, [shift, flip])


def symmetric_group(n: int) -> List[Perm]:
    """The full symmetric group S_n."""
    return [tuple(p) for p in permutations(range(n))]


def alternating_group(n: int) -> List[Perm]:
    """The alternating group A_n (even permutations)."""
    return [p for p in symmetric_group(n) if _sign(p) == 1]


def _sign(p: Perm) -> int:
    """Sign of a permutation, computed by counting inversions."""
    n = len(p)
    inversions = sum(1 for i in range(n) for j in range(i + 1, n) if p[i] > p[j])
    return 1 if inversions % 2 == 0 else -1


def trivial_group(n: int) -> List[Perm]:
    """The trivial group acting on n points."""
    return [tuple(range(n))]


def klein_four_on_four() -> List[Perm]:
    """The Klein four-group as the regular action on 4 points."""
    return generated_group(4, [(1, 0, 3, 2), (2, 3, 0, 1)])


def affine_group_mod_p(p: int) -> List[Perm]:
    """The affine group  x -> a x + b  (a nonzero) acting on Z/p, p prime."""
    gens: List[Perm] = [tuple((x + 1) % p for x in range(p))]
    for a in range(2, p):
        gens.append(tuple((a * x) % p for x in range(p)))
    return generated_group(p, gens)


# ----------------------------------------------------------------------------
# The subset spectrum
# ----------------------------------------------------------------------------

def act_on_subset(g: Perm, s: Subset) -> Subset:
    """The induced action of a permutation on a subset."""
    return tuple(sorted(g[x] for x in s))


def orbit_of_subset(group: Sequence[Perm], s: Subset) -> frozenset:
    """The G-orbit of the subset s, as a frozen set of subsets."""
    return frozenset(act_on_subset(g, s) for g in group)


def spectrum_term(n: int, group: Sequence[Perm], r: int) -> int:
    """t_r: the number of G-orbits on the r-element subsets of an n-point set."""
    orbits = set()
    for s in combinations(range(n), r):
        orbits.add(orbit_of_subset(group, s))
    return len(orbits)


def spectrum(n: int, group: Sequence[Perm]) -> List[int]:
    """The full subset spectrum t_0, t_1, ..., t_n."""
    return [spectrum_term(n, group, r) for r in range(n + 1)]


def orbit_representatives(n: int, group: Sequence[Perm], r: int) -> List[Subset]:
    """One representative for each orbit of r-subsets (lexicographically least)."""
    seen = set()
    reps: List[Subset] = []
    for s in combinations(range(n), r):
        orb = orbit_of_subset(group, s)
        if orb not in seen:
            seen.add(orb)
            reps.append(s)
    return reps


# ----------------------------------------------------------------------------
# Diagnostics
# ----------------------------------------------------------------------------

def log_concavity_defects(t: Sequence[int]) -> List[int]:
    """t_{r-1} t_{r+1} - t_r^2 for r = 1 ... n-1.  Positive entries are violations."""
    return [t[r - 1] * t[r + 1] - t[r] ** 2 for r in range(1, len(t) - 1)]


def is_log_concave(t: Sequence[int]) -> bool:
    """True iff  t_r^2 >= t_{r-1} t_{r+1}  for all 1 <= r <= n-1."""
    return all(d <= 0 for d in log_concavity_defects(t))


def shadow_slack(n: int, t: Sequence[int]) -> List[int]:
    """r(n-r) t_r^2 - t_{r-1} t_{r+1} for r = 1 ... n-1.  Provably nonnegative."""
    return [r * (n - r) * t[r] ** 2 - t[r - 1] * t[r + 1] for r in range(1, len(t) - 1)]


def group_guard_slack(n: int, order: int, t: Sequence[int]) -> List[int]:
    """|G|^2 t_r^2 - t_{r-1} t_{r+1} for r = 1 ... n-1.  Provably nonnegative."""
    return [order ** 2 * t[r] ** 2 - t[r - 1] * t[r + 1] for r in range(1, len(t) - 1)]


def burnside_check(n: int, group: Sequence[Perm], r: int) -> Tuple[int, int]:
    """Both sides of Burnside's mass formula  t_r |G| = sum_g #{fixed r-subsets}."""
    lhs = spectrum_term(n, group, r) * len(group)
    rhs = sum(
        sum(1 for s in combinations(range(n), r) if act_on_subset(g, s) == s)
        for g in group
    )
    return lhs, rhs


def sandwich_check(n: int, group: Sequence[Perm]) -> bool:
    """Verify  C(n,r)/|G| <= t_r <= C(n,r)  for every r (in integer form)."""
    t = spectrum(n, group)
    order = len(group)
    return all(comb(n, r) <= order * t[r] and t[r] <= comb(n, r) for r in range(n + 1))


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def show_spectrum(name: str, n: int, group: Sequence[Perm]) -> List[int]:
    t = spectrum(n, group)
    flag = "log-concave" if is_log_concave(t) else "NOT log-concave"
    print(f"{name:<26} n={n:<3} |G|={len(group):<5} t = {t}   [{flag}]")
    return t


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_basic_structure() -> None:
    banner("1. Basic structure of the spectrum")
    print("Boundary values t_0 = t_n = 1, symmetry t_r = t_{n-r},")
    print("and the sandwich  C(n,r) <= |G| * t_r  and  t_r <= C(n,r).")
    print()
    families: List[Tuple[str, int, List[Perm]]] = [
        ("trivial group on 5", 5, trivial_group(5)),
        ("C_5 (regular)", 5, cyclic_group(5)),
        ("D_6 on hexagon", 6, dihedral_group(6)),
        ("A_5 on 5 points", 5, alternating_group(5)),
        ("S_5 on 5 points", 5, symmetric_group(5)),
        ("AGL(1,5) on 5 points", 5, affine_group_mod_p(5)),
    ]
    for name, n, grp in families:
        t = show_spectrum(name, n, grp)
        assert t[0] == 1 and t[n] == 1
        assert all(t[r] == t[n - r] for r in range(n + 1))
        assert sandwich_check(n, grp)
    print()
    print("All boundary, symmetry and sandwich assertions hold.")


def demo_trivial_action_is_binomial() -> None:
    banner("2. The trivial action realises the binomial row (and IS log-concave)")
    for n in range(2, 8):
        t = spectrum(n, trivial_group(n))
        binom = [comb(n, r) for r in range(n + 1)]
        assert t == binom
        print(f"n = {n}:  t = {t}   =  C({n},r);  log-concave: {is_log_concave(t)}")
    print()
    print("Log-concavity of the binomial row, C(n,k) C(n,k+2) <= C(n,k+1)^2,")
    print("follows from  C(n,k+1)(k+1) = C(n,k)(n-k)  and  (k+1)(n-k-1) <= (n-k)(k+2).")


def demo_counterexample_C4() -> None:
    banner("3. The conjecture is FALSE: the cyclic group C_4 on 4 points")
    n = 4
    grp = cyclic_group(4)
    t = spectrum(n, grp)
    print(f"Spectrum of C_4 acting on 4 points:  t = {t}")
    print()
    for r, rep in enumerate(orbit_representatives(n, grp, 2)):
        kind = "adjacent pair" if (rep[1] - rep[0]) % 4 in (1, 3) else "opposite pair"
        print(f"  orbit {r + 1} of 2-subsets: representative {rep}  ({kind})")
    print()
    print(f"  t_0 * t_2 = {t[0] * t[2]}   but   t_1^2 = {t[1] ** 2}")
    print(f"  => log-concavity fails at r = 1: {t[0] * t[2]} > {t[1] ** 2}")
    assert not is_log_concave(t)
    print()
    lhs, rhs = burnside_check(n, grp, 2)
    print(f"Burnside check at r = 2:  t_2 * |G| = {lhs}  =  sum of fixed 2-subsets = {rhs}")
    assert lhs == rhs


def demo_regular_actions_all_fail() -> None:
    banner("4. Every regular action on n >= 4 points fails log-concavity")
    print("A regular action is transitive with |G| = |X| = n, so t_1 = 1, while")
    print("t_2 >= C(n,2)/n = (n-1)/2 > 1 for n >= 4; hence t_0 t_2 = t_2 > 1 = t_1^2.")
    print()
    for n in range(3, 11):
        grp = cyclic_group(n)
        t = spectrum(n, grp)
        d = log_concavity_defects(t)
        print(f"C_{n:<2}  t = {str(t):<40} defects = {d}")
    print()
    print("The Klein four-group (the other regular action on 4 points):")
    t = spectrum(4, klein_four_on_four())
    print(f"  t = {t};  log-concave: {is_log_concave(t)}")


def demo_rigidity() -> None:
    banner("5. Rigidity: transitive + log-concave  <=>  set-transitive")
    print("Collapse principle: if t_m = t_{m+1} = 1 and log-concavity holds from m on,")
    print("then t_r = 1 for all r >= m (since t_{r+1} <= t_r^2 / t_{r-1} = 1).")
    print("For a transitive action t_0 = t_1 = 1, so log-concavity forces t_r = 1")
    print("for every r: the group is r-homogeneous for all r, i.e. set-transitive.")
    print("Consequently C(n,r) <= |G| for every r, so |G| >= C(n, n//2).")
    print()
    header = f"{'group':<26}{'n':>3}{'|G|':>8}{'transitive':>12}{'log-concave':>13}{'C(n,n//2)':>11}"
    print(header)
    print("-" * len(header))
    cases: List[Tuple[str, int, List[Perm]]] = [
        ("S_4", 4, symmetric_group(4)),
        ("A_4", 4, alternating_group(4)),
        ("C_4", 4, cyclic_group(4)),
        ("D_4 (square)", 4, dihedral_group(4)),
        ("S_5", 5, symmetric_group(5)),
        ("A_5", 5, alternating_group(5)),
        ("AGL(1,5)", 5, affine_group_mod_p(5)),
        ("C_5", 5, cyclic_group(5)),
        ("D_6 (hexagon)", 6, dihedral_group(6)),
        ("S_6", 6, symmetric_group(6)),
    ]
    for name, n, grp in cases:
        t = spectrum(n, grp)
        trans = (t[1] == 1)
        lc = is_log_concave(t)
        print(f"{name:<26}{n:>3}{len(grp):>8}{str(trans):>12}{str(lc):>13}{comb(n, n // 2):>11}")
        if trans and lc:
            assert all(x == 1 for x in t), "rigidity theorem violated!"
            assert all(comb(n, r) <= len(grp) for r in range(n + 1))
    print()
    print("Every transitive log-concave example above is set-transitive (all t_r = 1),")
    print("and its order dominates the middle binomial coefficient, as the theorem predicts.")


def demo_guarded_inequalities() -> None:
    banner("6. The two surviving guarded inequalities")
    print("For EVERY finite action and every 1 <= r < n:")
    print("    (a)  t_{r-1} t_{r+1} <= |G|^2 t_r^2")
    print("    (b)  t_{r-1} t_{r+1} <= r(n-r) t_r^2   (no reference to the group)")
    print()
    cases: List[Tuple[str, int, List[Perm]]] = [
        ("C_6", 6, cyclic_group(6)),
        ("C_8", 8, cyclic_group(8)),
        ("C_10", 10, cyclic_group(10)),
        ("D_8 (octagon)", 8, dihedral_group(8)),
    ]
    for name, n, grp in cases:
        t = spectrum(n, grp)
        print(f"{name}: t = {t}")
        print(f"   log-concavity defects  t_{{r-1}}t_{{r+1}} - t_r^2 : {log_concavity_defects(t)}")
        print(f"   shadow slack  r(n-r)t_r^2 - t_{{r-1}}t_{{r+1}}    : {shadow_slack(n, t)}")
        print(f"   group slack   |G|^2 t_r^2 - t_{{r-1}}t_{{r+1}}    : "
              f"{group_guard_slack(n, len(grp), t)}")
        assert all(s >= 0 for s in shadow_slack(n, t))
        assert all(s >= 0 for s in group_guard_slack(n, len(grp), t))
        print()
    print("Both guards hold in every case, as proved.")


def demo_shadow_inequalities() -> None:
    banner("7. The shadow inequalities behind the group-free guard")
    print("Extension:  t_{r+1} <= (n-r) t_r     (adjoin one of the n-r outside points)")
    print("Deletion :  t_r     <= (r+1) t_{r+1} (complementary statement)")
    print("Multiplying the two gives  t_{r-1} t_{r+1} <= r(n-r) t_r^2.")
    print()
    cases: List[Tuple[str, int, List[Perm]]] = [
        ("C_7", 7, cyclic_group(7)),
        ("D_6", 6, dihedral_group(6)),
        ("AGL(1,7)", 7, affine_group_mod_p(7)),
    ]
    for name, n, grp in cases:
        t = spectrum(n, grp)
        print(f"{name} (n = {n}): t = {t}")
        for r in range(n):
            ext_ok = t[r + 1] <= (n - r) * t[r]
            del_ok = t[r] <= (r + 1) * t[r + 1]
            assert ext_ok and del_ok
            print(f"   r = {r}:  t_{r + 1} = {t[r + 1]:>3} <= {(n - r) * t[r]:>4} = (n-r)t_r "
                  f"  |   t_{r} = {t[r]:>3} <= {(r + 1) * t[r + 1]:>4} = (r+1)t_{{r+1}}")
        print()


def demo_search_for_log_concave_transitive() -> None:
    banner("8. Exhaustive search: which transitive actions are log-concave?")
    print("We scan all transitive permutation groups of small degree that are generated")
    print("by at most two of our standard generators, and record the log-concave ones.")
    print()
    found: List[str] = []
    catalogue: List[Tuple[str, int, List[Perm]]] = []
    for n in range(2, 7):
        catalogue.append((f"S_{n}", n, symmetric_group(n)))
        catalogue.append((f"A_{n}", n, alternating_group(n)))
        catalogue.append((f"C_{n}", n, cyclic_group(n)))
        catalogue.append((f"D_{n}", n, dihedral_group(n)))
    catalogue.append(("AGL(1,5)", 5, affine_group_mod_p(5)))
    for name, n, grp in catalogue:
        t = spectrum(n, grp)
        if t[1] == 1 and is_log_concave(t):
            found.append(f"{name} on {n} points  (|G| = {len(grp)}, t = {t})")
    for entry in sorted(set(found)):
        print("  log-concave transitive:", entry)
    print()
    print("Every group in this list has the constant spectrum (1,1,...,1): the symmetric")
    print("groups in all degrees, the small alternating groups A_4, A_5, A_6, the affine")
    print("group AGL(1,5), and the degenerate degrees n <= 3 where every transitive group")
    print("is automatically set-transitive.  This is exactly the rigidity theorem in")
    print("action: no transitive group with a non-constant spectrum survives.")


def main() -> None:
    print(__doc__)
    demo_basic_structure()
    demo_trivial_action_is_binomial()
    demo_counterexample_C4()
    demo_regular_actions_all_fail()
    demo_rigidity()
    demo_guarded_inequalities()
    demo_shadow_inequalities()
    demo_search_for_log_concave_transitive()
    banner("Summary")
    print("* The spectrum of a finite action need NOT be log-concave; the smallest")
    print("  counterexample is C_4 on 4 points with spectrum (1, 1, 2, 1, 1).")
    print("* For transitive actions, log-concavity is EQUIVALENT to set-transitivity,")
    print("  and therefore forces |G| >= C(n, n//2).")
    print("* Two guarded inequalities survive for every finite action:")
    print("      t_{r-1} t_{r+1} <= |G|^2 t_r^2   and   t_{r-1} t_{r+1} <= r(n-r) t_r^2.")


if __name__ == "__main__":
    main()
