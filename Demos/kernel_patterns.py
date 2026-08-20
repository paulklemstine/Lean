"""
Kernel patterns of tuples: numerical demonstration.

The *kernel* (equality pattern) of a tuple x = (x_0, ..., x_{n-1}) is the equivalence
relation  i ~ j  <=>  x_i = x_j  on index positions.  This script demonstrates, by
exhaustive computation on small cases, every quantitative result of the theory:

  1. Canonical form   can(x)_i = min { j : x_j = x_i }   is a complete encoding of the
     kernel, invariant under any injective relabelling of the alphabet.
  2. Patterns (= idempotent contracting retractions p with p(i) <= i and p(p(i)) = p(i))
     are exactly the canonical forms, and they biject with set partitions of [n].
  3. There are exactly B_n patterns on n letters:  1, 1, 2, 5, 15, 52, ...  (A000110).
  4. Orbits of the symmetric group of the alphabet on n-tuples are classified by the
     pattern; their number is B_n when n <= |alphabet|.
  5. Refining by block count gives the Stirling numbers of the second kind S(n,k),
     with sum_k S(n,k) = B_n.
  6. Over an alphabet of size a the orbit count is the truncated row sum_{k<=a} S(n,k);
     closed forms: 2^n orbits for binary (n+1)-tuples, (3^n+1)/2 for ternary.
  7. Connection formula: a^n = sum_k S(n,k) * a^{underline k} (falling factorial).
  8. The space of relabelling-invariant K-valued functions of an n-tuple has
     dimension B_n when n <= |alphabet|.

Self-contained: standard library only.
"""

from __future__ import annotations

from itertools import product, permutations
from math import comb
from typing import Dict, Hashable, List, Sequence, Set, Tuple

# ----------------------------------------------------------------------------------
# 1. Canonical form and patterns
# ----------------------------------------------------------------------------------


def canonical_form(x: Sequence[Hashable]) -> Tuple[int, ...]:
    """can(x)_i = min { j : x_j = x_i }, computed in one O(n) left-to-right pass."""
    first: Dict[Hashable, int] = {}
    out: List[int] = []
    for i, xi in enumerate(x):
        if xi not in first:
            first[xi] = i
        out.append(first[xi])
    return tuple(out)


def same_kernel(x: Sequence[Hashable], y: Sequence[Hashable]) -> bool:
    """True iff x and y realise the same equalities between coordinates."""
    if len(x) != len(y):
        return False
    return canonical_form(x) == canonical_form(y)


def is_pattern(p: Sequence[int]) -> bool:
    """A pattern is contracting (p(i) <= i) and idempotent (p(p(i)) = p(i))."""
    return all(p[i] <= i and p[p[i]] == p[i] for i in range(len(p)))


def all_patterns_bruteforce(n: int) -> List[Tuple[int, ...]]:
    """Filter all n^n maps [n] -> [n] by the two pattern conditions (small n only)."""
    return [p for p in product(range(n), repeat=n) if is_pattern(p)]


def all_patterns(n: int) -> List[Tuple[int, ...]]:
    """Generate every pattern exactly once by the last-letter recursion.

    Extend a pattern q on n letters either by pointing the new coordinate at one of the
    fixed points of q (join an existing block) or at itself (open a new block).
    """
    if n == 0:
        return [()]
    out: List[Tuple[int, ...]] = []
    for q in all_patterns(n - 1):
        reps = [j for j in range(n - 1) if q[j] == j]
        for v in reps + [n - 1]:
            out.append(q + (v,))
    return out


def num_blocks(p: Sequence[int]) -> int:
    """Number of blocks: the number of distinct values (= fixed points) of p."""
    return len(set(p))


def pattern_to_partition(p: Sequence[int]) -> List[List[int]]:
    """The set partition of [n] encoded by the pattern p."""
    blocks: Dict[int, List[int]] = {}
    for i, v in enumerate(p):
        blocks.setdefault(v, []).append(i)
    return [blocks[k] for k in sorted(blocks)]


# ----------------------------------------------------------------------------------
# 2. Bell and Stirling numbers
# ----------------------------------------------------------------------------------


def bell(n: int) -> int:
    """Bell numbers via the binomial recurrence B_{n+1} = sum_k C(n,k) B_{n-k}."""
    b: List[int] = [1]
    for m in range(n):
        b.append(sum(comb(m, k) * b[m - k] for k in range(m + 1)))
    return b[n]


def stirling2(n: int, k: int) -> int:
    """S(n+1,k+1) = (k+1) S(n,k+1) + S(n,k), with S(0,0) = 1."""
    table = [[0] * (k + 1) for _ in range(n + 1)]
    if k >= 0:
        table[0][0] = 1
    for m in range(1, n + 1):
        for j in range(1, k + 1):
            table[m][j] = j * table[m - 1][j] + table[m - 1][j - 1]
    return table[n][k]


def falling_factorial(a: int, k: int) -> int:
    """a^{underline k} = a (a-1) ... (a-k+1); zero when k > a."""
    result = 1
    for t in range(k):
        result *= a - t
    return result


# ----------------------------------------------------------------------------------
# 3. Orbits of the symmetric group of the alphabet on tuples
# ----------------------------------------------------------------------------------


def orbit_count_bruteforce(alphabet_size: int, n: int) -> int:
    """Count orbits of Sym(alphabet) on n-tuples by explicitly applying every letter
    permutation and taking the number of resulting equivalence classes."""
    letters = list(range(alphabet_size))
    seen: Set[Tuple[int, ...]] = set()
    reps = 0
    for x in product(letters, repeat=n):
        if x in seen:
            continue
        reps += 1
        for sigma in permutations(letters):
            seen.add(tuple(sigma[xi] for xi in x))
    return reps


def orbit_count_formula(alphabet_size: int, n: int) -> int:
    """Predicted orbit count: the truncated Stirling row sum_{k <= a} S(n,k)."""
    return sum(stirling2(n, k) for k in range(alphabet_size + 1))


def invariant_dimension(alphabet_size: int, n: int) -> int:
    """Dimension of the space of relabelling-invariant scalar functions of an n-tuple:
    one degree of freedom per orbit."""
    return orbit_count_formula(alphabet_size, n)


# ----------------------------------------------------------------------------------
# 4. Demonstrations
# ----------------------------------------------------------------------------------


def demo_canonical_forms() -> None:
    print("=" * 78)
    print("1. CANONICAL FORMS: the shape of sameness")
    print("=" * 78)
    words = ["BANANA", "XYZYZY", "LOLOLO", "SUSUSU", "MISSISSIPPI", "AABBCCAABBC"]
    for w in words:
        print(f"  {w:<12} -> can = {canonical_form(w)}   blocks = {num_blocks(canonical_form(w))}")
    print()
    print(f"  BANANA ~ XYZYZY ? {same_kernel('BANANA', 'XYZYZY')}   (renamings of each other)")
    print(f"  BANANA ~ LOLOLO ? {same_kernel('BANANA', 'LOLOLO')}")
    print(f"  LOLOLO ~ SUSUSU ? {same_kernel('LOLOLO', 'SUSUSU')}")
    print()
    # Invariance under an arbitrary injective relabelling into a different alphabet.
    x = [3, 3, 7, 1, 7]
    f = {3: "cat", 7: "dog", 1: "emu"}  # injective, into a completely different alphabet
    print(f"  x        = {x}          can = {canonical_form(x)}")
    fx = [f[v] for v in x]
    print(f"  f o x    = {fx}   can = {canonical_form(fx)}")
    print(f"  invariance under injective relabelling: {canonical_form(x) == canonical_form(fx)}")
    print()


def demo_patterns_are_partitions() -> None:
    print("=" * 78)
    print("2. PATTERNS = SET PARTITIONS, counted by the Bell numbers")
    print("=" * 78)
    for n in range(4):
        pats = all_patterns(n)
        print(f"  n = {n}:  {len(pats)} patterns")
        for p in pats:
            part = pattern_to_partition(p)
            shown = "{" + ", ".join("{" + ",".join(map(str, b)) + "}" for b in part) + "}"
            print(f"        {p}  <->  {shown}")
    print()
    print("  Pattern counts against the Bell numbers:")
    print("    n | #patterns (recursive) | #patterns (brute force) | B_n")
    for n in range(7):
        rec = len(all_patterns(n))
        brute = len(all_patterns_bruteforce(n)) if n <= 6 else None
        print(f"    {n} | {rec:>21} | {str(brute):>23} | {bell(n)}")
    assert [len(all_patterns(n)) for n in range(6)] == [1, 1, 2, 5, 15, 52]
    assert all(len(all_patterns(n)) == bell(n) for n in range(8))
    print("  -> first six values 1, 1, 2, 5, 15, 52  (OEIS A000110).  VERIFIED")
    print()


def demo_orbits() -> None:
    print("=" * 78)
    print("3. ORBITS OF THE SYMMETRIC GROUP ON TUPLES")
    print("=" * 78)
    print("   a = alphabet size, n = tuple length")
    print("    a  n | brute-force orbits | sum_{k<=a} S(n,k) | B_n | equal to B_n?")
    for a in range(1, 5):
        for n in range(0, 5):
            if a ** n > 20000:
                continue
            brute = orbit_count_bruteforce(a, n)
            pred = orbit_count_formula(a, n)
            assert brute == pred, (a, n, brute, pred)
            tag = "yes" if pred == bell(n) else "no (alphabet too small)"
            print(f"    {a}  {n} | {brute:>18} | {pred:>17} | {bell(n):>3} | {tag}")
    print()
    print("  The complete invariant separating orbits is the pattern.  Check for a = 3,")
    print("  n = 4: group the 81 tuples by pattern and confirm each class is one orbit.")
    by_pattern: Dict[Tuple[int, ...], List[Tuple[int, ...]]] = {}
    for x in product(range(3), repeat=4):
        by_pattern.setdefault(canonical_form(x), []).append(x)
    for p, cls in sorted(by_pattern.items()):
        rep = cls[0]
        orbit = {tuple(sigma[xi] for xi in rep) for sigma in permutations(range(3))}
        assert orbit == set(cls)
        print(f"    pattern {p}  blocks={num_blocks(p)}  class size {len(cls):>2}"
              f"  = 3^(underline {num_blocks(p)}) = {falling_factorial(3, num_blocks(p))}")
    print("  -> pattern classes coincide with orbits, sizes are falling factorials.  VERIFIED")
    print()


def demo_stirling_refinement() -> None:
    print("=" * 78)
    print("4. BLOCK REFINEMENT: Stirling numbers of the second kind")
    print("=" * 78)
    for n in range(7):
        counts = [0] * (n + 1)
        for p in all_patterns(n):
            counts[num_blocks(p)] += 1
        predicted = [stirling2(n, k) for k in range(n + 1)]
        assert counts == predicted, (n, counts, predicted)
        print(f"    n = {n}:  S(n,0..n) = {predicted}   sum = {sum(predicted)} = B_{n} = {bell(n)}")
        assert sum(predicted) == bell(n)
    print("  -> patterns with k blocks number S(n,k), and the rows sum to B_n.  VERIFIED")
    print()


def demo_small_alphabet_closed_forms() -> None:
    print("=" * 78)
    print("5. SMALL ALPHABETS: closed forms")
    print("=" * 78)
    print("    binary alphabet, tuples of length n+1: orbits should equal 2^n")
    for n in range(0, 8):
        got = orbit_count_formula(2, n + 1)
        assert got == 2 ** n, (n, got)
        print(f"      n = {n}:  orbits on {n+1}-tuples = {got:>4} = 2^{n}"
              f"   (B_{n+1} = {bell(n+1)})")
    print("    ternary alphabet, tuples of length n+1: 2 * orbits should equal 3^n + 1")
    for n in range(0, 8):
        got = orbit_count_formula(3, n + 1)
        assert 2 * got == 3 ** n + 1, (n, got)
        print(f"      n = {n}:  orbits on {n+1}-tuples = {got:>5},  2*{got} = 3^{n}+1"
              f" = {3 ** n + 1}")
    print("    strictness: from length 3 on, the binary count is below the Bell number")
    for n in range(3, 8):
        b2 = orbit_count_formula(2, n)
        print(f"      n = {n}:  binary orbits = {b2:>4}  <  B_{n} = {bell(n)}")
        assert b2 < bell(n)
    print("  VERIFIED")
    print()


def demo_connection_formula() -> None:
    print("=" * 78)
    print("6. CONNECTION FORMULA  a^n = sum_k S(n,k) * a^(underline k)")
    print("=" * 78)
    for a in range(0, 6):
        for n in range(0, 7):
            rhs = sum(stirling2(n, k) * falling_factorial(a, k) for k in range(n + 1))
            assert a ** n == rhs, (a, n, a ** n, rhs)
        print(f"    a = {a}: verified for n = 0..6")
    a, n = 3, 4
    terms = [f"{stirling2(n,k)}*{falling_factorial(a,k)}" for k in range(n + 1)]
    print(f"    example a=3, n=4:  3^4 = 81 = " + " + ".join(terms)
          + f" = {sum(stirling2(n,k)*falling_factorial(a,k) for k in range(n+1))}")
    print("  VERIFIED")
    print()


def demo_invariant_dimension() -> None:
    print("=" * 78)
    print("7. DIMENSION OF THE SPACE OF RELABELLING-INVARIANT FUNCTIONS")
    print("=" * 78)
    print("    (one degree of freedom per orbit)")
    print("    a  n | dimension | B_n")
    for a in range(1, 7):
        for n in range(0, 6):
            d = invariant_dimension(a, n)
            note = "= B_n" if d == bell(n) else "< B_n (alphabet too small)"
            print(f"    {a}  {n} | {d:>9} | {bell(n):>3}   {note}")
    assert invariant_dimension(5, 5) == 52 == bell(5)
    print("  -> for n <= a the dimension is exactly B_n; e.g. n = a = 5 gives 52.  VERIFIED")
    print()


def main() -> None:
    demo_canonical_forms()
    demo_patterns_are_partitions()
    demo_orbits()
    demo_stirling_refinement()
    demo_small_alphabet_closed_forms()
    demo_connection_formula()
    demo_invariant_dimension()
    print("=" * 78)
    print("All demonstrations completed and all assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
