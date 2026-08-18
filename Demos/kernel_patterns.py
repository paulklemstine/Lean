"""
Kernel patterns: numerical demonstrations.

This self-contained script demonstrates, by direct computation, every quantitative
claim of the accompanying paper:

  1. The canonical form (least-element labelling) of a tuple, and the fact that it
     is a COMPLETE invariant for renaming the alphabet symbols: two tuples over a
     finite alphabet lie in the same renaming-orbit iff their canonical forms agree.
  2. Enumeration of the patterns of length n (restricted growth strings) and the
     verification that their number is the Bell number B_n = 1, 1, 2, 5, 15, 52, ...
  3. The block-count refinement S(n,k) (Stirling numbers of the second kind, defined
     combinatorially), the recursion S(n+1,k+1) = S(n,k) + (k+1) S(n,k+1), the row
     sums sum_k S(n,k) = B_n, and the closed forms
         S(n+1,2) = 2^n - 1,  S(n+1,n) = C(n+1,2),  S(n+2,n) = C(n+2,3) + 3 C(n+2,4),
         6 S(n,3)  = 3^n - 3*2^n + 3,
         24 S(n,4) = 4^n - 4*3^n + 6*2^n - 4,
         120 S(n,5)= 5^n - 5*4^n + 10*3^n - 10*2^n + 5.
  4. The falling-factorial expansion m^n = sum_k S(n,k) * m^(k)  and the surjection
     count k! S(n,k).
  5. Orbit counts over an alphabet of size m: sum_{k<=m} S(n,k), equal to B_n exactly
     when m >= n, strictly smaller otherwise.
  6. Growth: strict monotonicity of B_n from n = 1, and strict super-multiplicativity
     B_m B_n < B_{m+n} for m, n >= 1, hence 2^k <= B_{2k}.
  7. Touchard's congruence B_{p+n} = B_{n+1} + B_n  (mod p) for primes p, and its
     corollary B_p = 2 (mod p).
  8. Kernel spectra: the Pythagorean equation a^2 + b^2 = c^2 realises exactly four
     of the five patterns of a triple (the equal-legs pattern is missing); the
     k-dimensional equal-legs configuration exists iff k is a perfect square; and the
     Fermat equation x^p + y^p = z^p realises three patterns for p >= 3 and four for
     p = 2, with all five occurring at p = 1.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

from itertools import product
from math import comb, factorial, isqrt
from typing import Dict, Iterator, List, Sequence, Set, Tuple

# ---------------------------------------------------------------------------
# 1. Canonical form and completeness of the invariant
# ---------------------------------------------------------------------------


def canon(tup: Sequence[object]) -> Tuple[int, ...]:
    """Least-element labelling: canon(f)[i] = min{ j : f[j] == f[i] }.

    Linear time and space: scan left to right, recording the first occurrence
    index of each value.
    """
    first: Dict[object, int] = {}
    out: List[int] = []
    for i, x in enumerate(tup):
        if x not in first:
            first[x] = i
        out.append(first[x])
    return tuple(out)


def nblocks(pattern: Sequence[int]) -> int:
    """Number of blocks (distinct labels) of a pattern."""
    return len(set(pattern))


def same_orbit_by_search(f: Sequence[int], g: Sequence[int], alphabet_size: int) -> bool:
    """Brute force: is there a permutation sigma of the alphabet with sigma(f) = g?

    Exponential in the alphabet size; used only to validate the linear-time test.
    """
    from itertools import permutations

    for sigma in permutations(range(alphabet_size)):
        if tuple(sigma[x] for x in f) == tuple(g):
            return True
    return False


def demo_completeness(n: int = 4, m: int = 4) -> None:
    print("=" * 74)
    print(f"1. COMPLETENESS OF THE KERNEL INVARIANT  (tuples of length {n} over {m} letters)")
    print("=" * 74)
    examples = [
        ((0, 1, 2, 0), (3, 1, 0, 3)),
        ((0, 0, 1, 1), (2, 2, 3, 3)),
        ((0, 1, 0, 1), (0, 1, 1, 0)),
        ((0, 1, 2, 3), (3, 2, 1, 0)),
    ]
    for f, g in examples:
        by_canon = canon(f) == canon(g)
        by_search = same_orbit_by_search(f, g, m)
        flag = "OK" if by_canon == by_search else "MISMATCH"
        print(
            f"  f={f}  g={g} | canon(f)={canon(f)} canon(g)={canon(g)}"
            f" -> same orbit? canon-test {by_canon}, brute force {by_search}  [{flag}]"
        )

    # Exhaustive check of the completeness theorem for all tuples.
    bad = 0
    for f in product(range(m), repeat=n):
        for g in product(range(m), repeat=n):
            if (canon(f) == canon(g)) != same_orbit_by_search(f, g, m):
                bad += 1
    print(f"  exhaustive check over all {m ** n}^2 pairs: {bad} disagreements (expected 0)")
    print()


# ---------------------------------------------------------------------------
# 2. Enumeration of patterns; Bell numbers
# ---------------------------------------------------------------------------


def patterns(n: int) -> Iterator[Tuple[int, ...]]:
    """Enumerate the patterns of length n, in least-element labelling.

    The restricted growth strings (p[0] = 0 and p[i] <= 1 + max(p[0..i-1])) are
    generated with no rejection, then relabelled by `canon` so that each block
    carries the index of its own least element.  Cost O(n * B_n) time, O(n) space.
    """
    if n == 0:
        yield ()
        return
    prefix: List[int] = [0]

    def extend(maximum: int) -> Iterator[Tuple[int, ...]]:
        if len(prefix) == n:
            yield canon(prefix)
            return
        for label in range(maximum + 2):
            prefix.append(label)
            yield from extend(max(maximum, label))
            prefix.pop()

    yield from extend(0)


def bell_numbers(upto: int) -> List[int]:
    """Bell numbers via the binomial recursion B_{n+1} = sum_i C(n,i) B_{n-i}."""
    bell = [1]
    for n in range(upto):
        bell.append(sum(comb(n, i) * bell[n - i] for i in range(n + 1)))
    return bell


def demo_bell(upto: int = 8) -> None:
    print("=" * 74)
    print("2. PATTERNS ARE COUNTED BY THE BELL NUMBERS")
    print("=" * 74)
    bell = bell_numbers(upto)
    for n in range(upto + 1):
        if n <= 6:
            counted = sum(1 for _ in patterns(n))
            mark = "OK" if counted == bell[n] else "MISMATCH"
            print(f"  n={n}:  #patterns = {counted:6d}   B_n = {bell[n]:6d}   [{mark}]")
        else:
            print(f"  n={n}:  (enumeration skipped)      B_n = {bell[n]:6d}")
    print("  the five patterns of a triple:", [p for p in patterns(3)])
    print()


# ---------------------------------------------------------------------------
# 3. The block-count refinement: Stirling numbers of the second kind
# ---------------------------------------------------------------------------


def stirling_by_enumeration(n: int, k: int) -> int:
    """S(n,k) defined combinatorially: patterns of length n with exactly k blocks."""
    return sum(1 for p in patterns(n) if nblocks(p) == k)


def stirling_table(upto: int) -> List[List[int]]:
    """Fill the triangle with the recursion S(n+1,k+1) = S(n,k) + (k+1) S(n,k+1).

    O(upto^2) integer operations.
    """
    table = [[0] * (upto + 1) for _ in range(upto + 1)]
    table[0][0] = 1
    for n in range(upto):
        for k in range(upto):
            table[n + 1][k + 1] = table[n][k] + (k + 1) * table[n][k + 1]
    return table


def demo_stirling(upto: int = 8) -> None:
    print("=" * 74)
    print("3. THE BLOCK-COUNT TRIANGLE  S(n,k)  AND ITS CLOSED FORMS")
    print("=" * 74)
    table = stirling_table(upto)
    header = "   n\\k " + "".join(f"{k:7d}" for k in range(upto + 1)) + "     row sum"
    print(header)
    bell = bell_numbers(upto)
    for n in range(upto + 1):
        row = "".join(f"{table[n][k]:7d}" for k in range(upto + 1))
        s = sum(table[n])
        mark = "OK" if s == bell[n] else "MISMATCH"
        print(f"  {n:4d} {row}   {s:8d} = B_{n} [{mark}]")

    print("\n  recursion checked against direct enumeration:")
    for n in range(6):
        for k in range(n + 1):
            assert stirling_by_enumeration(n, k) == table[n][k], (n, k)
    print("    S(n,k) from enumeration == S(n,k) from the recursion for all n <= 5   [OK]")

    print("\n  closed forms:")
    for n in range(1, upto - 1):
        assert table[n + 1][2] == 2 ** n - 1
        assert table[n + 1][n] == comb(n + 1, 2)
        assert table[n + 2][n] == comb(n + 2, 3) + 3 * comb(n + 2, 4)
        assert 6 * table[n][3] == 3 ** n - 3 * 2 ** n + 3
        assert 24 * table[n][4] == 4 ** n - 4 * 3 ** n + 6 * 2 ** n - 4
        assert 120 * table[n][5] == 5 ** n - 5 * 4 ** n + 10 * 3 ** n - 10 * 2 ** n + 5
    print("    S(n+1,2) = 2^n - 1                                   [OK]")
    print("    S(n+1,n) = C(n+1,2)                                  [OK]")
    print("    S(n+2,n) = C(n+2,3) + 3 C(n+2,4)                     [OK]")
    print("    6 S(n,3) = 3^n - 3*2^n + 3                           [OK]")
    print("    24 S(n,4) = 4^n - 4*3^n + 6*2^n - 4                  [OK]")
    print("    120 S(n,5) = 5^n - 5*4^n + 10*3^n - 10*2^n + 5       [OK]")
    print(f"    row 6 = {table[6][:7]} sums to {sum(table[6])}")
    print(f"    row 7 = {table[7][:8]} sums to {sum(table[7])}")
    print(f"    row 8 = {table[8][:9]} sums to {sum(table[8])}")
    print()


# ---------------------------------------------------------------------------
# 4-5. Falling factorials, surjections, orbit counts
# ---------------------------------------------------------------------------


def falling_factorial(m: int, k: int) -> int:
    """m^(k) = m (m-1) ... (m-k+1)."""
    result = 1
    for i in range(k):
        result *= max(m - i, 0) if m - i > 0 else 0
    return result if m >= k else 0


def demo_fibres(nmax: int = 6, mmax: int = 6) -> None:
    print("=" * 74)
    print("4. FIBRES, FALLING FACTORIALS, SURJECTIONS, ORBIT COUNTS")
    print("=" * 74)
    table = stirling_table(nmax)
    bell = bell_numbers(nmax)

    print("  m^n = sum_k S(n,k) m^(k):")
    for n in range(nmax + 1):
        for m in range(mmax + 1):
            rhs = sum(table[n][k] * falling_factorial(m, k) for k in range(n + 1))
            assert m ** n == rhs, (n, m, m ** n, rhs)
    print("    verified for all 0 <= n <= %d, 0 <= m <= %d                [OK]" % (nmax, mmax))

    print("\n  number of surjections [n] -> [k] equals k! S(n,k):")
    for n in range(1, 5):
        for k in range(1, 5):
            brute = sum(
                1 for f in product(range(k), repeat=n) if len(set(f)) == k
            )
            assert brute == factorial(k) * table[n][k], (n, k)
            if n == 4:
                print(f"    n=4, k={k}: {brute:4d} = {k}! * S(4,{k}) = {factorial(k)} * {table[n][k]}")

    print("\n  orbit counts of the symmetric group of an m-letter alphabet on n-tuples:")
    print("    (theory: sum_{k<=m} S(n,k); equals B_n iff m >= n)")
    for n in range(1, 5):
        for m in range(1, 5):
            predicted = sum(table[n][k] for k in range(min(m, n) + 1))
            orbits: Set[Tuple[int, ...]] = {canon(f) for f in product(range(m), repeat=n)}
            status = "= B_n" if predicted == bell[n] else "< B_n"
            assert predicted == len(orbits), (n, m)
            print(
                f"    n={n}, m={m}: orbits = {len(orbits):3d} (predicted {predicted:3d}) "
                f"{status} = {bell[n]}"
            )
    print()


# ---------------------------------------------------------------------------
# 6. Growth: monotonicity and super-multiplicativity
# ---------------------------------------------------------------------------


def demo_growth(upto: int = 14) -> None:
    print("=" * 74)
    print("5. GROWTH OF THE BELL NUMBERS")
    print("=" * 74)
    bell = bell_numbers(upto)
    print("  B_n for n = 0..%d:" % upto)
    print("   ", bell)
    assert all(bell[n] < bell[n + 1] for n in range(1, upto))
    print("  strict monotonicity B_n < B_{n+1} for n >= 1                 [OK]")
    print("  super-multiplicativity B_m B_n < B_{m+n} for m,n >= 1:")
    for m in range(1, 6):
        for n in range(1, 6):
            if m + n <= upto:
                assert bell[m] * bell[n] < bell[m + n]
    print("    checked for all 1 <= m,n <= 5                              [OK]")
    print(f"    e.g. B_2 * B_2 = {bell[2] * bell[2]} < {bell[4]} = B_4")
    print(f"         B_3 * B_4 = {bell[3] * bell[4]} < {bell[7]} = B_7")
    print("  consequence 2^k <= B_{2k}:")
    for k in range(upto // 2 + 1):
        assert 2 ** k <= bell[2 * k]
    print(f"    e.g. 2^7 = {2 ** 7} <= {bell[14]} = B_14                     [OK]")
    print()


# ---------------------------------------------------------------------------
# 7. Touchard's congruence
# ---------------------------------------------------------------------------


def demo_touchard(upto: int = 24) -> None:
    print("=" * 74)
    print("6. TOUCHARD'S CONGRUENCE   B_{p+n} = B_{n+1} + B_n  (mod p)")
    print("=" * 74)
    bell = bell_numbers(upto)
    primes = [p for p in range(2, 12) if all(p % d for d in range(2, isqrt(p) + 1))]
    for p in primes:
        for n in range(0, min(6, upto - p) + 1):
            lhs = bell[p + n] % p
            rhs = (bell[n + 1] + bell[n]) % p
            assert lhs == rhs, (p, n, lhs, rhs)
        print(f"  p = {p:2d}: verified for 0 <= n <= {min(6, upto - p)}   [OK]"
              f"   B_{p} mod {p} = {bell[p] % p} (theory: 2 mod {p} = {2 % p})")
    print("  worked example: p=5, n=3  ->  B_8 = B_4 + B_3 = 15 + 5 = 20 = 0 (mod 5),")
    print(f"                  and indeed B_8 = {bell[8]} = 5 * {bell[8] // 5}")
    print()


# ---------------------------------------------------------------------------
# 8. Kernel spectra of Diophantine equations
# ---------------------------------------------------------------------------


def pythagorean_spectrum(bound: int = 60) -> Set[Tuple[int, ...]]:
    """Patterns realised by solutions of a^2 + b^2 = c^2 with entries <= bound."""
    found: Set[Tuple[int, ...]] = set()
    for a in range(bound + 1):
        for b in range(bound + 1):
            s = a * a + b * b
            c = isqrt(s)
            if c * c == s and c <= bound:
                found.add(canon((a, b, c)))
    return found


def fermat_spectrum(p: int, bound: int = 60) -> Set[Tuple[int, ...]]:
    """Patterns realised by solutions of x^p + y^p = z^p with entries <= bound."""
    powers = {x ** p: x for x in range(bound + 1)}
    found: Set[Tuple[int, ...]] = set()
    for x in range(bound + 1):
        for y in range(bound + 1):
            s = x ** p + y ** p
            z = powers.get(s)
            if z is not None:
                found.add(canon((x, y, z)))
    return found


def equal_legs_dimension(k: int, bound: int = 200) -> Tuple[bool, Tuple[int, int] | None]:
    """Does sum_{i<k} a^2 = y^2 have a solution with a != 0?  (Theory: iff k is a square.)"""
    for a in range(1, bound + 1):
        s = k * a * a
        y = isqrt(s)
        if y * y == s:
            return True, (a, y)
    return False, None


def demo_spectra(bound: int = 60) -> None:
    print("=" * 74)
    print("7. KERNEL SPECTRA OF DIOPHANTINE EQUATIONS")
    print("=" * 74)
    names = {
        (0, 1, 2): "discrete   (all distinct)",
        (0, 1, 1): "legs differ, b = c",
        (0, 1, 0): "a = c, b differs",
        (0, 0, 0): "all equal",
        (0, 0, 2): "EQUAL LEGS a = b, c differs",
    }
    all_patterns = list(patterns(3))

    spec = pythagorean_spectrum(bound)
    print(f"  a^2 + b^2 = c^2 with entries <= {bound}:")
    for pat in all_patterns:
        mark = "realised    " if pat in spec else "NOT realised"
        witness = ""
        if pat == (0, 1, 2):
            witness = "  e.g. (3,4,5)"
        if pat == (0, 0, 2):
            witness = "  (would need 2a^2 = c^2, impossible: 2 is not a square)"
        print(f"    {pat} {names[pat]:<28} {mark}{witness}")
    print(f"    |spectrum| = {len(spec)} = B_3 - 1 = 4   -> defect one")

    print("\n  equal legs in dimension k:  sum_{i<k} a^2 = y^2 with a != 0")
    print("    (theory: solvable iff k is a perfect square)")
    for k in range(1, 10):
        ok, witness = equal_legs_dimension(k)
        square = isqrt(k) ** 2 == k
        assert ok == square, k
        w = f"  witness a={witness[0]}, y={witness[1]}" if witness else ""
        print(f"    k={k}: solvable {str(ok):5s} | k a perfect square: {str(square):5s}{w}")

    print(f"\n  x^p + y^p = z^p with entries <= {bound}:")
    for p in range(1, 6):
        spec_p = fermat_spectrum(p, bound)
        pats = sorted(spec_p)
        note = ""
        if p == 1:
            note = "  all five patterns (1+1=2 gives equal legs)"
        elif p == 2:
            note = "  four patterns (3,4,5 gives the discrete one)"
        else:
            note = "  three patterns: discrete missing <=> no positive solution"
        print(f"    p={p}: |spectrum| = {len(spec_p)}  {pats}{note}")
    print("\n  For p >= 3 the discrete pattern is realised iff x^p + y^p = z^p has a")
    print("  positive solution, so its absence is exactly Fermat's Last Theorem at p.")
    print()


# ---------------------------------------------------------------------------


def main() -> None:
    print()
    print("KERNEL PATTERNS -- NUMERICAL DEMONSTRATIONS")
    print()
    demo_completeness()
    demo_bell()
    demo_stirling()
    demo_fibres()
    demo_growth()
    demo_touchard()
    demo_spectra()
    print("All demonstrations completed; every assertion above verified numerically.")


if __name__ == "__main__":
    main()
