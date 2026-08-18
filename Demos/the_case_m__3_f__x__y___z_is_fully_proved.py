"""
Kernel spectra of Diophantine cones: numerical demonstrations.

This script is fully self-contained (standard library only) and reproduces, by
explicit computation, every quantitative claim of the accompanying paper:

  * the equality-pattern ("kernel") calculus for tuples;
  * the closed-form realisation criteria for the three mixed patterns of a
    ternary conic  A x^2 + B y^2 = C z^2;
  * the defect of the pencil  x^2 + y^2 = C z^2  for C = 50, 1, 8, 2, 3,
    exhibiting every possible value 0, 1, 2, 3, 4;
  * diagonal degeneracy: A + B = C blocks all three mixed patterns at once;
  * hypotenuse-leg rigidity and the spectrum of  x^2 + y^2 + z^2 = w^2
    (8 of 15 patterns, defect 7);
  * the constant-legs criterion in every dimension: realised iff the leg count
    is a perfect square other than 1;
  * the Fermat pencil at the cubic exponent: blocked for C = 1 (power
    obstruction), blocked for C = 2 (degeneracy obstruction), realised for
    C = 16.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import isqrt
from typing import Dict, Iterable, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1.  Equality patterns (kernels) and Bell numbers
# ---------------------------------------------------------------------------


def canonical_pattern(t: Sequence[int]) -> Tuple[int, ...]:
    """Canonical form of a tuple: entry i is the least index j with t[j] == t[i].

    Two tuples have the same canonical form exactly when they induce the same
    partition of the index set into level sets.
    """
    first: Dict[int, int] = {}
    out: List[int] = []
    for i, v in enumerate(t):
        if v not in first:
            first[v] = i
        out.append(first[v])
    return tuple(out)


def all_patterns(n: int) -> List[Tuple[int, ...]]:
    """Every canonical pattern of length n, i.e. every set partition of n points."""
    seen: Set[Tuple[int, ...]] = set()
    # A canonical pattern of length n uses labels among 0..n-1; enumerating all
    # tuples over that alphabet and canonicalising is exhaustive.
    for t in product(range(n), repeat=n):
        seen.add(canonical_pattern(t))
    return sorted(seen)


def bell(n: int) -> int:
    """The n-th Bell number, via the Bell triangle."""
    row: List[int] = [1]
    for _ in range(n):
        nxt = [row[-1]]
        for x in row:
            nxt.append(nxt[-1] + x)
        row = nxt
    return row[0]


def pattern_name_3(p: Tuple[int, ...]) -> str:
    """Human-readable name for one of the five patterns of a triple."""
    return {
        (0, 1, 2): "<012>  all distinct",
        (0, 0, 2): "<002>  equal legs      x = y != z",
        (0, 1, 0): "<010>  leg = hypotenuse x = z != y",
        (0, 1, 1): "<011>  leg = hypotenuse y = z != x",
        (0, 0, 0): "<000>  all equal",
    }[p]


# ---------------------------------------------------------------------------
# 2.  The arithmetic engine
# ---------------------------------------------------------------------------


def is_square(n: int) -> bool:
    """True iff the non-negative integer n is a perfect square."""
    if n < 0:
        return False
    r = isqrt(n)
    return r * r == n


def is_perfect_power(n: int, p: int) -> bool:
    """True iff the non-negative integer n is a perfect p-th power."""
    if n < 0:
        return False
    r = round(n ** (1.0 / p)) if n > 0 else 0
    for cand in (r - 1, r, r + 1):
        if cand >= 0 and cand ** p == n:
            return True
    return False


def descent_solvable(P: int, Q: int) -> bool:
    """Two-parameter descent with non-degeneracy.

    For Q != 0: there are u, v >= 0 with u != 0, u != v and P u^2 = Q v^2
    if and only if P*Q is a perfect square and P != Q.
    """
    assert Q != 0
    return is_square(P * Q) and P != Q


# ---------------------------------------------------------------------------
# 3.  Closed-form criteria for a ternary conic  A x^2 + B y^2 = C z^2
# ---------------------------------------------------------------------------


def conic_spectrum_by_criteria(A: int, B: int, C: int, search: int = 400) -> Set[Tuple[int, ...]]:
    """The kernel spectrum of A x^2 + B y^2 = C z^2 from the closed-form criteria.

    The four non-generic patterns are decided exactly; the all-distinct pattern
    is decided by a bounded search (sound positively, heuristic negatively).
    """
    assert A > 0 and B > 0 and C > 0
    spec: Set[Tuple[int, ...]] = {(0, 0, 0)}  # the origin always solves the cone

    if is_square((A + B) * C) and A + B != C:
        spec.add((0, 0, 2))
    if A <= C and is_square((C - A) * B) and A + B != C:
        spec.add((0, 1, 0))
    if B <= C and is_square((C - B) * A) and A + B != C:
        spec.add((0, 1, 1))

    for x in range(search + 1):
        for y in range(search + 1):
            lhs = A * x * x + B * y * y
            if lhs % C:
                continue
            z2 = lhs // C
            z = isqrt(z2)
            if z * z == z2 and len({x, y, z}) == 3:
                spec.add((0, 1, 2))
                break
        if (0, 1, 2) in spec:
            break
    return spec


def conic_spectrum_by_search(A: int, B: int, C: int, bound: int = 120) -> Set[Tuple[int, ...]]:
    """Brute-force spectrum: canonicalise every solution with entries <= bound."""
    spec: Set[Tuple[int, ...]] = set()
    for x in range(bound + 1):
        for y in range(bound + 1):
            lhs = A * x * x + B * y * y
            if lhs % C:
                continue
            z2 = lhs // C
            z = isqrt(z2)
            if z * z == z2:
                spec.add(canonical_pattern((x, y, z)))
    return spec


def conic_defect(A: int, B: int, C: int) -> int:
    """5 minus the number of realised patterns."""
    return 5 - len(conic_spectrum_by_criteria(A, B, C))


def witness_002(A: int, B: int, C: int) -> Tuple[int, int, int] | None:
    """Explicit equal-legs witness (u, u, v) supplied by the descent lemma."""
    if not (is_square((A + B) * C) and A + B != C):
        return None
    m = isqrt((A + B) * C)
    return (C, C, m)


# ---------------------------------------------------------------------------
# 4.  Higher-dimensional cones  x_1^2 + ... + x_k^2 = y^2
# ---------------------------------------------------------------------------


def cone_spectrum_by_search(k: int, bound: int = 40) -> Set[Tuple[int, ...]]:
    """Patterns realised by sum_{i<k} x_i^2 = y^2, searching legs up to `bound`."""
    spec: Set[Tuple[int, ...]] = set()
    for legs in product(range(bound + 1), repeat=k):
        s = sum(x * x for x in legs)
        y = isqrt(s)
        if y * y == s:
            spec.add(canonical_pattern(tuple(legs) + (y,)))
    return spec


def constant_legs_realised(k: int) -> bool:
    """Criterion: all legs equal and nonzero, hypotenuse different, is realised
    iff k is a perfect square and k != 1."""
    return is_square(k) and k != 1


def rigidity_check(bound: int = 60) -> bool:
    """Empirical check of hypotenuse-leg rigidity for k = 3: if the hypotenuse
    equals a leg then every other leg vanishes."""
    for a, b, c in product(range(bound + 1), repeat=3):
        s = a * a + b * b + c * c
        d = isqrt(s)
        if d * d != s:
            continue
        legs = (a, b, c)
        for j in range(3):
            if legs[j] == d and any(legs[i] != 0 for i in range(3) if i != j):
                return False
    return True


# ---------------------------------------------------------------------------
# 5.  The Fermat pencil  A x^p + B y^p = C z^p
# ---------------------------------------------------------------------------


def fermat_equal_legs_realised(p: int, A: int, B: int, C: int) -> bool:
    """Equal-legs criterion: realised iff (A+B) C^(p-1) is a p-th power and A+B != C."""
    assert p >= 1 and C != 0
    return is_perfect_power((A + B) * C ** (p - 1), p) and (A + B) != C


def fermat_equal_legs_witness(p: int, A: int, B: int, C: int, bound: int = 60):
    """Search for an explicit equal-legs solution (a, a, z) with a != z."""
    for a in range(1, bound + 1):
        lhs = (A + B) * a ** p
        if lhs % C:
            continue
        q = lhs // C
        z = round(q ** (1.0 / p))
        for cand in (z - 1, z, z + 1):
            if cand >= 0 and cand ** p == q and cand != a:
                return (a, a, cand)
    return None


# ---------------------------------------------------------------------------
# 6.  Reporting
# ---------------------------------------------------------------------------


def hr(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_bell() -> None:
    hr("1.  Patterns of an n-tuple are counted by the Bell numbers")
    for n in range(1, 5):
        pats = all_patterns(n)
        print(f"  n = {n}:  {len(pats):3d} patterns,  Bell({n}) = {bell(n)}")
    print("\n  The five patterns of a triple:")
    for p in all_patterns(3):
        print("    ", pattern_name_3(p))


def demo_pythagoras() -> None:
    hr("2.  The Pythagorean cone  x^2 + y^2 = z^2:  defect 1")
    spec = conic_spectrum_by_criteria(1, 1, 1)
    for p in all_patterns(3):
        mark = "realised" if p in spec else "BLOCKED "
        print(f"    {mark}  {pattern_name_3(p)}")
    print(f"\n  |Spec| = {len(spec)},  defect = {5 - len(spec)}")
    print("  Witnesses: (3,4,5), (7,0,7), (0,7,7), (0,0,0).")
    print("  The blocked pattern needs (1+1)*1 = 2 to be a perfect square:",
          is_square(2))
    print("  Cross-check against brute-force enumeration up to 120:",
          spec == conic_spectrum_by_search(1, 1, 1))


def demo_defect_surjectivity() -> None:
    hr("3.  The pencil  x^2 + y^2 = C z^2:  the defect attains every value 0..4")
    print(f"  {'C':>4} {'|Spec|':>7} {'defect':>7}   realised patterns")
    achieved: Dict[int, int] = {}
    for C in (50, 1, 8, 2, 3):
        spec = conic_spectrum_by_criteria(1, 1, C)
        d = 5 - len(spec)
        achieved[d] = C
        names = " ".join("".join(map(str, p)) for p in sorted(spec))
        print(f"  {C:>4} {len(spec):>7} {d:>7}   {names}")
        brute = conic_spectrum_by_search(1, 1, C)
        assert brute <= spec, (C, brute - spec)
    print("\n  Every defect value is attained:",
          sorted(achieved) == [0, 1, 2, 3, 4])
    print("  Witnessed by C =", {d: achieved[d] for d in sorted(achieved)})
    print("\n  Certificates:")
    print("    C = 50 : (1+1)*50 = 100 = 10^2 (equal legs), (50-1)*1 = 49 = 7^2,")
    print("             17^2 + 31^2 = 1250 = 50*5^2 (all distinct)  ->  defect 0")
    print("    C =  8 : (1+1)*8 = 16 = 4^2 gives 2^2 + 2^2 = 8*1^2, but (8-1)*1 = 7")
    print("             is not a square, killing both mixed patterns -> defect 2")
    print("    C =  2 : 1 + 1 = 2 = C, diagonal degeneracy kills all three -> defect 3")
    print("    C =  3 : descent at the prime 3 leaves only the origin      -> defect 4")


def demo_degeneracy() -> None:
    hr("4.  Diagonal degeneracy:  A + B = C blocks all three mixed patterns")
    print(f"  {'(A,B,C)':>12} {'|Spec|':>7} {'defect':>7}   realised")
    for (A, B, C) in [(1, 1, 2), (1, 2, 3), (2, 3, 5), (3, 4, 7), (1, 3, 4)]:
        spec = conic_spectrum_by_criteria(A, B, C)
        names = " ".join("".join(map(str, p)) for p in sorted(spec))
        print(f"  {str((A,B,C)):>12} {len(spec):>7} {5-len(spec):>7}   {names}")
    print("\n  In every case the spectrum is contained in {<012>, <000>}:")
    print("  the conic passes through (1,1,1) and no partial coincidence survives,")
    print("  even though solutions abound, e.g. 1^2 + 7^2 = 2 * 5^2.")


def demo_descent_three() -> None:
    hr("5.  Descent at 3:  x^2 + y^2 = 3 z^2 has only the trivial point")
    found = [(x, y, z) for x in range(200) for y in range(200)
             for z in [isqrt((x * x + y * y) // 3)]
             if (x * x + y * y) % 3 == 0 and 3 * z * z == x * x + y * y
             and (x, y, z) != (0, 0, 0)]
    print("  Non-trivial solutions with x, y < 200:", found)
    print("  Modular reason: squares are 0 or 1 mod 3, so 3 | x^2 + y^2 forces")
    print("  3 | x and 3 | y; then 3 | z, and the solution descends strictly.")
    residues = sorted({(x * x) % 3 for x in range(30)})
    print("  Squares modulo 3:", residues)


def demo_higher_dimension() -> None:
    hr("6.  Higher dimension:  x^2 + y^2 + z^2 = w^2  realises 8 of 15 patterns")
    spec = cone_spectrum_by_search(3, bound=40)
    print(f"  Bell(4) = {bell(4)},  |Spec| = {len(spec)},  defect = {bell(4) - len(spec)}")
    print("  Realised:")
    for p in sorted(spec):
        print("    ", "".join(map(str, p)))
    missing = [p for p in all_patterns(4) if p not in spec]
    print("  Missing (7 patterns):", " ".join("".join(map(str, p)) for p in missing))
    print("\n  Hypotenuse-leg rigidity verified up to 60:", rigidity_check(60))
    print("  Six of the seven missing patterns merge the hypotenuse with a leg while")
    print("  separating two other legs - impossible by rigidity. The seventh is")
    print("  'all legs equal, hypotenuse apart', blocked since 3 is not a square.")


def demo_constant_legs() -> None:
    hr("7.  Constant legs in dimension k:  realised iff k is a square, k != 1")
    print(f"  {'k':>3} {'criterion':>10} {'witness':>28}")
    for k in range(1, 13):
        ok = constant_legs_realised(k)
        w = ""
        if ok:
            a, y = 1, isqrt(k)
            w = f"{k} * {a}^2 = {y}^2"
        print(f"  {k:>3} {str(ok):>10} {w:>28}")
    print("\n  k = 2 and k = 3 are blocked (2 and 3 are not squares): these are the")
    print("  missing Pythagorean pattern and the seventh missing pattern above.")
    print("  k = 4 is realised: 1^2 + 1^2 + 1^2 + 1^2 = 2^2.")
    print("  Empirical confirmation for k = 4 by search:",
          (0, 0, 0, 0, 4) in {canonical_pattern((a, a, a, a, y))
                              for a in range(1, 30)
                              for y in [isqrt(4 * a * a)]
                              if y * y == 4 * a * a and y != a})


def demo_fermat_pencil() -> None:
    hr("8.  The cubic pencil  x^3 + y^3 = C z^3:  two independent obstructions")
    print(f"  {'C':>4} {'power cond.':>12} {'A+B != C':>10} {'realised':>10}   witness")
    for C in (1, 2, 16, 54):
        power = is_perfect_power(2 * C ** 2, 3)
        nondeg = 2 != C
        ok = fermat_equal_legs_realised(3, 1, 1, C)
        w = fermat_equal_legs_witness(3, 1, 1, C)
        print(f"  {C:>4} {str(power):>12} {str(nondeg):>10} {str(ok):>10}   {w}")
    print("\n  C = 1 : blocked by the power obstruction (2 is not a cube).")
    print("  C = 2 : the power condition holds (2 * 2^2 = 8 = 2^3) yet the pattern")
    print("          is blocked - purely by degeneracy, since 1 + 1 = 2 = C.")
    print("  C = 16: realised, 2^3 + 2^3 = 16 * 1^3, with 2 * 16^2 = 512 = 8^3.")
    print("  So the two obstructions are logically independent.")


def demo_fermat_defect() -> None:
    hr("9.  The Fermat family  x^p + y^p = z^p:  defect 1 at p = 2, defect 2 beyond")
    for p in (2, 3, 4, 5):
        spec: Set[Tuple[int, ...]] = {(0, 0, 0)}
        bound = 200 if p == 2 else 60
        for x in range(bound + 1):
            for y in range(bound + 1):
                s = x ** p + y ** p
                z = round(s ** (1.0 / p)) if s > 0 else 0
                for cand in (z - 1, z, z + 1):
                    if cand >= 0 and cand ** p == s:
                        spec.add(canonical_pattern((x, y, cand)))
        names = " ".join("".join(map(str, q)) for q in sorted(spec))
        print(f"  p = {p}:  |Spec| = {len(spec)},  defect = {5 - len(spec)}   {names}")
    print("\n  For p >= 3 exactly three patterns occur: the origin and the two")
    print("  'one leg vanishes' patterns. Equal legs is blocked because 2 is not a")
    print("  p-th power; all-distinct is blocked by Fermat's Last Theorem.")


def main() -> None:
    demo_bell()
    demo_pythagoras()
    demo_defect_surjectivity()
    demo_degeneracy()
    demo_descent_three()
    demo_higher_dimension()
    demo_constant_legs()
    demo_fermat_pencil()
    demo_fermat_defect()
    print()
    print("=" * 78)
    print("All demonstrations completed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
