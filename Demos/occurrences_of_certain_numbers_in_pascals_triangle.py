"""
Singmaster multiplicity in Pascal's triangle — numerical demonstrations.
========================================================================

This self-contained script illustrates, numerically, every result discussed in the
accompanying article and research paper:

  1. The multiplicity function N(t) = #{(n,k) : 0 <= k <= n, C(n,k) = t}
     and its reflection decomposition  N(t) = 2 + 2*L(t) + Z(t),  Z(t) in {0,1}.
  2. The smoothness theorem:  N(t) >= 3  =>  p(p-1) <= 2t  for every prime p | t.
  3. The smoothness hierarchy: N(t) >= 2m+2  =>  C(p, m+1) <= t for every prime p | t.
  4. The growth threshold:     N(t) >= 2m+2  =>  t >= C(2m+3, m+1),
     and the sharp thresholds 6, 10, 120, 3003.
  5. The counting bound:   #{t <= X : N(t) >= 3} <= (floor(sqrt(2X)) + 2)(floor(log2 X) + 1),
     hence density one for multiplicity exactly two.
  6. The sharpened logarithmic bound: N(t) <= log2 t + log2(2 log2 t + 1) + 1.
  7. The complete classification of adjacent repetitions C(n,k) = C(n-1,k+1):
     the Lucas form 5n+1 = L_{4j+9}, 5(n-k) = L_{4j+8}+3, equivalently the Fibonacci
     form n = F_{2i+4}F_{2i+5}, k = F_{2i+2}F_{2i+5}, together with Cassini's identity
     which bridges the two.

Run with:  python3 demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import sys
from math import comb, isqrt
from typing import Dict, List, Tuple

sys.set_int_max_str_digits(1000000)


# ---------------------------------------------------------------------------
# 1. Multiplicities by direct enumeration
# ---------------------------------------------------------------------------

def multiplicity_table(limit: int) -> Dict[int, int]:
    """Return {t: N(t)} for all 2 <= t <= limit, where N(t) counts the pairs
    (n, k) with 0 <= k <= n and C(n,k) = t.

    Only rows n <= limit need be scanned, because C(n,1) = n and every interior
    entry of row n is at least C(n,1).
    """
    counts: Dict[int, int] = {}
    n = 2
    while n <= limit:
        # entries of row n are unimodal; stop as soon as they exceed the limit
        for k in range(0, n + 1):
            value = comb(n, k)
            if value > limit:
                # by unimodality the rest of the left half also exceeds limit,
                # so jump to the mirrored tail
                k_mirror = n - k + 1
                for kk in range(k_mirror, n + 1):
                    v = comb(n, kk)
                    if 2 <= v <= limit:
                        counts[v] = counts.get(v, 0) + 1
                break
            if value >= 2:
                counts[value] = counts.get(value, 0) + 1
        n += 1
    return counts


def occurrences(t: int) -> List[Tuple[int, int]]:
    """All positions (n,k) in Pascal's triangle carrying the value t >= 2."""
    out: List[Tuple[int, int]] = []
    for n in range(2, t + 1):
        for k in range(0, n // 2 + 1):
            v = comb(n, k)
            if v > t:
                break
            if v == t:
                out.append((n, k))
                if k != n - k:
                    out.append((n, n - k))
    return sorted(out)


def reflection_decomposition(t: int) -> Tuple[int, int, int]:
    """Return (N(t), L(t), Z(t)) where L(t) counts the strictly left-interior
    occurrences (2 <= k, 2k < n) and Z(t) counts central occurrences (n = 2k).
    The identity N(t) = 2 + 2 L(t) + Z(t) is checked by the caller."""
    occ = occurrences(t)
    left_interior = [(n, k) for (n, k) in occ if k >= 2 and 2 * k < n]
    central = [(n, k) for (n, k) in occ if n == 2 * k]
    return len(occ), len(left_interior), len(central)


# ---------------------------------------------------------------------------
# 2. Smoothness theorem and hierarchy
# ---------------------------------------------------------------------------

def prime_factors(t: int) -> List[int]:
    """The distinct prime factors of t >= 2, by trial division."""
    out: List[int] = []
    d, m = 2, t
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def smoothness_certificate(t: int) -> Tuple[bool, List[Tuple[int, int, int]]]:
    """Check the smoothness theorem for t: if N(t) >= 3 then p(p-1) <= 2t for
    every prime p | t.  Returns (holds, [(p, p(p-1), 2t)])."""
    rows = [(p, p * (p - 1), 2 * t) for p in prime_factors(t)]
    return all(a <= b for (_, a, b) in rows), rows


def hierarchy_ceiling(t: int, m: int) -> int:
    """Largest prime p that a number t of multiplicity >= 2m+2 may contain:
    the hierarchy forces C(p, m+1) <= t."""
    p = 2
    best = 2
    while comb(p, m + 1) <= t:
        best = p
        p += 1
    return best


# ---------------------------------------------------------------------------
# 3. Bounds
# ---------------------------------------------------------------------------

def ilog2(x: int) -> int:
    """floor(log2 x) for x >= 1."""
    return x.bit_length() - 1


def counting_bound(X: int) -> int:
    """(floor(sqrt(2X)) + 2) * (floor(log2 X) + 1)."""
    return (isqrt(2 * X) + 2) * (ilog2(X) + 1)


def classical_log_bound(t: int) -> int:
    """The classical elementary bound 2 log2 t."""
    return 2 * ilog2(t)


def sharpened_log_bound(t: int) -> int:
    """log2 t + log2(2 log2 t + 1) + 1."""
    L = ilog2(t)
    return L + ilog2(2 * L + 1) + 1


def growth_threshold(m: int) -> int:
    """C(2m+3, m+1): the least possible value of a number of multiplicity >= 2m+2."""
    return comb(2 * m + 3, m + 1)


# ---------------------------------------------------------------------------
# 4. Adjacent repetitions: Lucas and Fibonacci parametrisations
# ---------------------------------------------------------------------------

def fib(n: int) -> int:
    """Fibonacci numbers F_0 = 0, F_1 = 1."""
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def luc(n: int) -> int:
    """Lucas numbers L_0 = 2, L_1 = 1."""
    a, b = 2, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_family(i: int) -> Tuple[int, int]:
    """The i-th member (n, k) = (F_{2i+4} F_{2i+5}, F_{2i+2} F_{2i+5})."""
    return fib(2 * i + 4) * fib(2 * i + 5), fib(2 * i + 2) * fib(2 * i + 5)


def is_adjacent_repetition(n: int, k: int) -> bool:
    """C(n,k) = C(n-1,k+1)."""
    return comb(n, k) == comb(n - 1, k + 1)


def diophantine_form(n: int, k: int) -> bool:
    """The cleared-factorial equivalent  n(k+1) = (n-k)(n-k-1)."""
    return n * (k + 1) == (n - k) * (n - k - 1)


def norm_form(x: int, y: int) -> int:
    """The binary quadratic (norm) form x^2 - xy - y^2."""
    return x * x - x * y - y * y


def cassini(a: int) -> int:
    """F_{a+1}^2 - F_a F_{a+2}, which equals (-1)^a."""
    return fib(a + 1) ** 2 - fib(a) * fib(a + 2)


def abbreviate(value: int, digits: int = 24) -> str:
    """Print gigantic integers compactly: leading digits, digit count."""
    s = format(value, 'd') if value.bit_length() < 40000 else None
    if s is None:
        return "<astronomically large>"
    if len(s) <= digits:
        return s
    return f"{s[:12]}...{s[-6:]}  ({len(s)} digits)"


def brute_force_adjacent(max_row: int) -> List[Tuple[int, int]]:
    """All (n,k) with 1 <= k, k+2 <= n <= max_row and C(n,k) = C(n-1,k+1)."""
    out: List[Tuple[int, int]] = []
    for n in range(3, max_row + 1):
        for k in range(1, n - 1):
            if is_adjacent_repetition(n, k):
                out.append((n, k))
    return out


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_multiplicities(limit: int = 5000) -> None:
    print("=" * 74)
    print("1.  Multiplicity N(t) — the repeat-offenders of Pascal's triangle")
    print("=" * 74)
    table = multiplicity_table(limit)
    interesting = sorted(t for t, c in table.items() if c >= 3)
    exceptional = sorted(t for t, c in table.items() if c >= 5)
    print(f"Numbers t <= {limit} with N(t) >= 3:  {len(interesting)} of them "
          f"(a vanishing proportion).")
    print(f"The first few: {interesting[:12]} ...")
    print(f"Numbers t <= {limit} with N(t) >= 5:")
    for t in exceptional:
        print(f"   N({t:5d}) = {table[t]}   occurrences: {occurrences(t)}")
    print()
    print("Sharp thresholds (smallest t attaining each multiplicity):")
    for target in (3, 4, 6, 8):
        first = min(t for t, c in table.items() if c >= target)
        print(f"   least t with N(t) >= {target}:  {first}")
    print()
    print("Reflection decomposition  N(t) = 2 + 2 L(t) + Z(t):")
    for t in (6, 10, 20, 120, 3003):
        N, L, Z = reflection_decomposition(t)
        assert N == 2 + 2 * L + Z, (t, N, L, Z)
        assert Z <= 1
        print(f"   t = {t:5d}:  N = {N}, L = {L}, Z = {Z}   -> 2 + 2*{L} + {Z} = {N}")
    print()


def demo_smoothness() -> None:
    print("=" * 74)
    print("2.  Smoothness:  N(t) >= 3  =>  p(p-1) <= 2t  for every prime p | t")
    print("=" * 74)
    for t in (6, 10, 21, 120, 3003):
        ok, rows = smoothness_certificate(t)
        assert ok
        detail = ", ".join(f"{p}*{p-1}={a} <= {b}" for (p, a, b) in rows)
        print(f"   t = {t:5d}:  {detail}")
    print()
    print("Contrapositive in action: a large prime factor forces N(t) = 2.")
    for t in (2 * 101, 3 * 1009, 7 * 10007):
        ps = prime_factors(t)
        p = max(ps)
        print(f"   t = {t:8d} = {' * '.join(map(str, ps))}:  "
              f"p(p-1) = {p*(p-1)} > 2t = {2*t}  =>  N(t) = 2")
    print()
    print("The hierarchy:  N(t) >= 2m+2  =>  C(p, m+1) <= t.")
    print("For t = 3003 (multiplicity 8, i.e. m = 3):")
    print(f"   largest admissible prime factor: {hierarchy_ceiling(3003, 3)}"
          f"   (C(18,4) = {comb(18,4)} > 3003)")
    print(f"   3003 = {' * '.join(map(str, prime_factors(3003)))} — all below 18.  OK")
    print()
    print("Level m = 2 (multiplicity >= 6):  p(p-1)(p-2) <= 6t.")
    for t in (120, 3003):
        for p in prime_factors(t):
            print(f"   t = {t:5d}, p = {p:2d}:  {p*(p-1)*(p-2)} <= {6*t}")
    print()


def demo_bounds() -> None:
    print("=" * 74)
    print("3.  Upper bounds on the multiplicity")
    print("=" * 74)
    print(f"{'t':>10} {'2 log2 t':>10} {'sharpened':>10}")
    for t in (3003, 10 ** 6, 2 ** 16, 2 ** 32, 10 ** 20):
        print(f"{t:>10} {classical_log_bound(t):>10} {sharpened_log_bound(t):>10}")
    print()
    print("Growth threshold:  N(t) >= 2m+2  =>  t >= C(2m+3, m+1).")
    for m in range(1, 7):
        print(f"   m = {m}:  N(t) >= {2*m+2}  =>  t >= C({2*m+3},{m+1}) = "
              f"{growth_threshold(m)}")
    print("   (the true sharp thresholds are 6, 10, 120, 3003 for N >= 3,4,6,8)")
    print()
    print("Counting bound  #{t <= X : N(t) >= 3} <= (sqrt(2X)+2)(log2 X + 1):")
    for X in (100, 1000, 10 ** 4, 10 ** 6, 10 ** 9):
        print(f"   X = {X:>12}:  bound = {counting_bound(X):>10}"
              f"   ratio bound/X = {counting_bound(X)/X:.3e}")
    print("   (density of the exceptional set tends to 0, so N(t) = 2 has density one)")
    print()


def demo_adjacent() -> None:
    print("=" * 74)
    print("4.  Adjacent repetitions  C(n,k) = C(n-1,k+1) — complete classification")
    print("=" * 74)
    found = brute_force_adjacent(1200)
    print(f"Brute force over all rows n <= 1200 finds: {found}")
    predicted = [fib_family(i) for i in range(4)]
    print(f"Fibonacci family (i = 0..3):               {predicted}")
    assert found == [p for p in predicted if p[0] <= 1200]
    print()
    print("Each member, and its Lucas certificate  5n+1 = L_{4j+9}, 5(n-k) = L_{4j+8}+3:")
    for i in range(5):
        n, k = fib_family(i)
        assert diophantine_form(n, k)
        assert 5 * n + 1 == luc(4 * i + 9)
        assert 5 * (n - k) == luc(4 * i + 8) + 3
        val = comb(n, k)
        print(f"   i={i}: (n,k) = ({n},{k})   C(n,k) = C(n-1,k+1) = {abbreviate(val)}")
        print(f"        5n+1 = {5*n+1} = L_{4*i+9};   5(n-k) = {5*(n-k)} = L_{4*i+8} + 3")
    print()
    print("Cassini's identity  F_{a+1}^2 - F_a F_{a+2} = (-1)^a  (the bridge):")
    print("   a :", "  ".join(f"{a:>3}" for a in range(9)))
    print("   C :", "  ".join(f"{cassini(a):>3}" for a in range(9)))
    print()
    print("The Lucas dictionary  L_{2a} = 5 F_a^2 + 2(-1)^a,  "
          "L_{2a+1} = 5 F_a F_{a+1} + (-1)^a:")
    for a in range(7):
        assert luc(2 * a) == 5 * fib(a) ** 2 + 2 * (-1) ** a
        assert luc(2 * a + 1) == 5 * fib(a) * fib(a + 1) + (-1) ** a
        print(f"   a={a}:  L_{2*a} = {luc(2*a):>5} = 5*{fib(a)}^2 + 2*({(-1)**a});"
              f"   L_{2*a+1} = {luc(2*a+1):>5} = 5*{fib(a)}*{fib(a+1)} + ({(-1)**a})")
    print()
    print("Consecutive Lucas pairs are exactly the solutions of x^2 - xy - y^2 = +-5:")
    for i in range(8):
        x, y = luc(i + 1), luc(i)
        print(f"   (L_{i+1}, L_{i}) = ({x:>4},{y:>4}):  x^2 - xy - y^2 = {norm_form(x,y):>3}")
    print()
    print("Consequently each family member yields a number of multiplicity >= 6:")
    for i in range(3):
        n, k = fib_family(i)
        t = comb(n, k)
        if t <= 10 ** 7:
            N, L, Z = reflection_decomposition(t)
            print(f"   i={i}: t = C({n},{k}) = {t}, N(t) = {N}")
        else:
            print(f"   i={i}: t = C({n},{k}) = {abbreviate(t)}; the six positions are "
                  f"({n},{k}), ({n},{n-k}), ({n-1},{k+1}), ({n-1},{n-k-2}), "
                  f"(t,1), (t,t-1)")
    print()


def demo_3003() -> None:
    print("=" * 74)
    print("5.  The champion: 3003 occurs eight times")
    print("=" * 74)
    occ = occurrences(3003)
    print(f"   positions: {occ}")
    print(f"   N(3003) = {len(occ)}")
    print(f"   3003 = {' * '.join(map(str, prime_factors(3003)))}"
          f"  (all prime factors < 18, as the hierarchy demands)")
    print("   3003 is simultaneously triangular (C(78,2)), a member of the")
    print("   Fibonacci family of adjacent repetitions (C(15,5) = C(14,6)),")
    print("   and the smallest number of multiplicity 8.")
    print()
    print("   Verification of the four defining coincidences:")
    for (n, k) in [(3003, 1), (78, 2), (15, 5), (14, 6)]:
        print(f"      C({n},{k}) = {comb(n,k)}")
    print()


def main() -> None:
    demo_multiplicities()
    demo_smoothness()
    demo_bounds()
    demo_adjacent()
    demo_3003()
    print("All assertions verified.")


if __name__ == "__main__":
    main()


"""Algorithm: complete enumeration of the adjacent repetitions
C(n,k) = C(n-1,k+1) in Pascal's triangle, together with their Lucas
certificates, plus the descent that proves the classification.

By the classification theorem the solutions are exactly
    (n, k) = (F_{2i+4} F_{2i+5},  F_{2i+2} F_{2i+5}),   i >= 0,
equivalently the pairs satisfying 5n+1 = L_{4i+9} and 5(n-k) = L_{4i+8} + 3.
"""

from __future__ import annotations

from typing import Iterator, List, Optional, Tuple


def fibonacci_upto(m: int) -> List[int]:
    """F_0 .. F_m with F_0 = 0, F_1 = 1."""
    out = [0, 1]
    while len(out) <= m:
        out.append(out[-1] + out[-2])
    return out[: m + 1]


def lucas_upto(m: int) -> List[int]:
    """L_0 .. L_m with L_0 = 2, L_1 = 1."""
    out = [2, 1]
    while len(out) <= m:
        out.append(out[-1] + out[-2])
    return out[: m + 1]


def adjacent_repetitions(count: int) -> Iterator[Tuple[int, int, int, int]]:
    """Yield (i, n, k, n-k) for the first `count` adjacent repetitions.

    Complexity: O(1) big-integer additions/multiplications per member — the
    enumeration is *complete*, so no search over rows of the triangle is
    needed.  A brute-force scan of all rows up to n would cost O(n^2)
    binomial comparisons on numbers with O(n) digits.
    """
    fib = fibonacci_upto(2 * count + 6)
    for i in range(count):
        n = fib[2 * i + 4] * fib[2 * i + 5]
        k = fib[2 * i + 2] * fib[2 * i + 5]
        yield i, n, k, n - k


def lucas_certificate(i: int) -> Tuple[int, int]:
    """Return (L_{4i+9}, L_{4i+8} + 3), the certificate pair for member i."""
    luc = lucas_upto(4 * i + 9)
    return luc[4 * i + 9], luc[4 * i + 8] + 3


def norm_form(x: int, y: int) -> int:
    """The norm form x^2 - xy - y^2 of Z[(1+sqrt 5)/2]."""
    return x * x - x * y - y * y


def descend(x: int, y: int) -> Optional[List[Tuple[int, int, int]]]:
    """Vieta/Euclidean descent (x,y) -> (y, x-y) on x^2 - xy - y^2 = +-5.

    Returns the full descent chain as [(x, y, form value)] ending at the base
    solution (1,2), or None if (x,y) does not solve the form.  Each step
    negates the form value and strictly decreases the first coordinate, so the
    descent terminates in O(log_phi x) steps — this is exactly the argument
    that every solution is a consecutive Lucas pair.
    """
    if abs(norm_form(x, y)) != 5:
        return None
    chain = [(x, y, norm_form(x, y))]
    while (x, y) != (1, 2):
        x, y = y, x - y
        if y < 0:
            return chain           # should not happen for genuine solutions
        chain.append((x, y, norm_form(x, y)))
    return chain


if __name__ == "__main__":
    print("Complete list of adjacent repetitions C(n,k) = C(n-1,k+1):")
    for i, n, k, gap in adjacent_repetitions(7):
        L1, L2 = lucas_certificate(i)
        assert 5 * n + 1 == L1 and 5 * gap == L2
        assert n * (k + 1) == gap * (gap - 1)
        print(f"  i={i}: (n,k) = ({n},{k});  5n+1 = {5*n+1} = L_{4*i+9};  "
              f"5(n-k) = {5*gap} = L_{4*i+8} + 3")
    print()
    print("Descent chain for the certificate of the first member (76, 47):")
    for (x, y, f) in descend(76, 47) or []:
        print(f"   ({x:>4}, {y:>4})   x^2 - xy - y^2 = {f:>3}")


"""Algorithm: multiplicity of an integer in Pascal's triangle, with the
row bound n(n-1) <= 2t used to confine the interior search."""

from __future__ import annotations

from math import comb, isqrt
from typing import List, Tuple


def multiplicity(t: int) -> Tuple[int, List[Tuple[int, int]]]:
    """Return (N(t), sorted list of all positions (n,k) with C(n,k) = t).

    Interior occurrences (2 <= k <= n-2) satisfy n(n-1) <= 2t, so only rows
    n <= isqrt(2t) + 1 need be scanned; the two boundary occurrences (t,1),
    (t,t-1) are added separately.  Complexity: O(sqrt(t) * log t) big-integer
    operations, versus O(t log t) for a naive full scan.
    """
    if t < 2:
        raise ValueError("multiplicity is defined for t >= 2")
    positions: List[Tuple[int, int]] = []

    # boundary occurrences
    if t == 2:
        positions.append((2, 1))          # (t,1) and (t,t-1) coincide
    else:
        positions.extend([(t, 1), (t, t - 1)])

    # interior occurrences: rows are capped by the geometric bound
    n_max = isqrt(2 * t) + 1
    for n in range(4, n_max + 1):
        for k in range(2, n // 2 + 1):
            value = comb(n, k)
            if value > t:
                break                      # unimodality: rest of half-row is larger
            if value == t:
                positions.append((n, k))
                if 2 * k != n:
                    positions.append((n, n - k))
    positions = sorted(set(positions))
    return len(positions), positions


def reflection_decomposition(t: int) -> Tuple[int, int, int]:
    """Return (N(t), L(t), Z(t)) with N(t) = 2 + 2 L(t) + Z(t) for t >= 3,
    where L counts left-interior occurrences (2 <= k, 2k < n) and Z counts
    central ones (n = 2k, k >= 2).  Always Z(t) <= 1."""
    n_total, positions = multiplicity(t)
    left = sum(1 for (n, k) in positions if k >= 2 and 2 * k < n)
    central = sum(1 for (n, k) in positions if k >= 2 and n == 2 * k)
    return n_total, left, central


if __name__ == "__main__":
    for t in (2, 3, 6, 10, 20, 120, 210, 1540, 3003):
        N, L, Z = reflection_decomposition(t) if t >= 3 else (1, 0, 0)
        print(f"N({t:5d}) = {N};  left-interior = {L}, central = {Z};  "
              f"positions = {multiplicity(t)[1]}")


"""Algorithm: smoothness certificate turning a factorisation of t into an
unconditional ceiling on the multiplicity N(t).

Mathematical basis (smoothness hierarchy): if N(t) >= 2m+2 then every prime
factor p of t satisfies C(p, m+1) <= t.  Since C(p, m+1) is increasing in p,
the largest prime factor P of t gives the strongest constraint: if
C(P, m+1) > t for some m >= 1, then N(t) <= 2m+1, and N(t) <= 2m unless t is
itself a central binomial coefficient (odd multiplicity requires one).

If C(P, j) <= t for every j (which happens exactly when t is large relative to
2^P, i.e. t is extremely smooth), the method yields no finite ceiling — and
that is the honest answer: those are precisely the candidates for high
multiplicity, such as t = 3003 = 3*7*11*13, whose multiplicity really is 8.
"""

from __future__ import annotations

from math import comb
from typing import Dict, List, Optional, Tuple


def prime_factors(t: int) -> List[int]:
    """Distinct prime factors of t >= 2 by trial division: O(sqrt t)."""
    out: List[int] = []
    d, m = 2, t
    while d * d <= m:
        if m % d == 0:
            out.append(d)
            while m % d == 0:
                m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def is_central_binomial(t: int) -> Optional[int]:
    """Return c with C(2c,c) = t, or None.  Central binomials grow like 4^c."""
    c = 1
    while True:
        v = comb(2 * c, c)
        if v == t:
            return c
        if v > t:
            return None
        c += 1


def multiplicity_ceiling(t: int) -> Tuple[Optional[int], Dict[str, object]]:
    """Return (ceiling, certificate).

    `ceiling` is an unconditional upper bound on N(t) derived from the
    smoothness hierarchy, or None when the hierarchy gives no finite bound.

    Complexity: O(sqrt t) for the trial-division factorisation, then at most
    P/2 levels, each a single binomial evaluation.
    """
    ps = prime_factors(t)
    p_max = max(ps)
    central = is_central_binomial(t)
    failing_m: Optional[int] = None
    for m in range(1, p_max):                     # need m + 1 <= p_max
        if comb(p_max, m + 1) > t:
            failing_m = m
            break
    if failing_m is None:
        certificate: Dict[str, object] = {
            "t": t,
            "prime_factors": ps,
            "largest_prime_factor": p_max,
            "verdict": "no finite ceiling: t is too smooth for the hierarchy to bite",
            "is_central_binomial": central,
        }
        return None, certificate
    ceiling = 2 * failing_m + 1 if central is not None else 2 * failing_m
    certificate = {
        "t": t,
        "prime_factors": ps,
        "largest_prime_factor": p_max,
        "failing_level_m": failing_m,
        "witness": f"C({p_max},{failing_m + 1}) = {comb(p_max, failing_m + 1)} > {t}",
        "is_central_binomial": central,
        "ceiling": ceiling,
    }
    return ceiling, certificate


if __name__ == "__main__":
    for t in (3003, 120, 210, 1540, 2 * 101, 7 * 10007, 999983, 2 ** 10 * 3):
        ceiling, cert = multiplicity_ceiling(t)
        if ceiling is None:
            print(f"t = {t}:  hierarchy gives no ceiling "
                  f"(prime factors {cert['prime_factors']}) — a genuine candidate "
                  f"for high multiplicity")
        else:
            print(f"t = {t}:  N(t) <= {ceiling}   ({cert['witness']}; "
                  f"prime factors {cert['prime_factors']})")


"""Assemble PACKAGE.json from the project's prose, code, and formal sources."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "package_assets")


def read(path: str) -> str:
    with open(path, "r", encoding="utf-8") as fh:
        return fh.read()


LEAN_FILES: List[str] = [
    "Catalog/Novelty/SingmasterSmoothness.lean",
    "Catalog/Novelty/SingmasterSmoothHierarchy.lean",
    "Catalog/Novelty/SingmasterSharpLog.lean",
    "Catalog/Novelty/SingmasterDensity.lean",
    "Catalog/Novelty/SingmasterMinimalValues.lean",
    "Catalog/Novelty/AdjacentBinomialLucas.lean",
    "Catalog/Novelty/AdjacentBinomialFibonacci.lean",
]


def lean_bundle() -> str:
    chunks = []
    for rel in LEAN_FILES:
        chunks.append(f"/- ===== {rel} ===== -/\n" + read(os.path.join(ROOT, rel)))
    return "\n\n".join(chunks)


def main() -> None:
    article = read(os.path.join(ROOT, "ARTICLE.md"))
    paper = read(os.path.join(ROOT, "RESEARCH_PAPER.md"))
    tex = read(os.path.join(ROOT, "RESEARCH_PAPER.tex"))
    demo = read(os.path.join(ROOT, "demo.py"))

    demo_record = read(os.path.join(ASSETS, "demo_record_search.py"))
    alg_mult = read(os.path.join(ASSETS, "alg_multiplicity.py"))
    alg_smooth = read(os.path.join(ASSETS, "alg_smoothness_certificate.py"))
    alg_adj = read(os.path.join(ASSETS, "alg_adjacent_enum.py"))
    viz_land = read(os.path.join(ASSETS, "viz_multiplicity_landscape.py"))
    viz_hier = read(os.path.join(ASSETS, "viz_smoothness_hierarchy.py"))
    widget_tri = read(os.path.join(ASSETS, "widget_pascal_explorer.html"))
    widget_adj = read(os.path.join(ASSETS, "widget_adjacent_machine.html"))
    layout = read(os.path.join(ASSETS, "interactive_layout.md"))
    future = read(os.path.join(ASSETS, "future_directions.md"))

    package: Dict[str, Any] = {
        "title": "The Loneliest Numbers in Pascal's Triangle: Smoothness Hierarchies, "
                 "Density, and the Complete Classification of Adjacent Repetitions",
        "domain": "Novelty",
        "description":
            "A study of how often an integer can occur in Pascal's triangle: high multiplicity "
            "forces extreme smoothness and large size, the exceptional numbers have density "
            "zero, and the adjacent repetitions C(n,k) = C(n-1,k+1) are classified completely "
            "as the Fibonacci pairs (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5}).",
        "authors": ["Aristotle"],
        "date": "2026-08-09",
        "key_results": [
            "Smoothness theorem: if an integer occurs three or more times in Pascal's triangle, "
            "then every prime factor p of it satisfies p(p-1) <= 2t, hence p <= sqrt(2t) + 1; "
            "consequently any integer with a larger prime factor occurs exactly twice.",
            "Smoothness hierarchy: multiplicity at least 2m+2 forces C(p, m+1) <= t for every "
            "prime factor p, so that a number occurring 2m+2 times is essentially "
            "t^(1/(m+1))-smooth; for 3003 this caps every prime factor at 17.",
            "Density one for multiplicity two: the count of t <= X occurring three or more "
            "times is at most (sqrt(2X)+2)(log_2 X + 1), so almost every integer occurs "
            "exactly twice.",
            "A factor-two sharpening of the elementary logarithmic bound: every t >= 2 occurs "
            "at most log_2 t + log_2(2 log_2 t + 1) + 1 times, strictly better than 2 log_2 t "
            "for t >= 2^16.",
            "Sharp thresholds and complete classification of adjacent repetitions: 6, 10, 120 "
            "and 3003 are the least integers of multiplicity at least 3, 4, 6 and 8, and "
            "C(n,k) = C(n-1,k+1) holds exactly for the Fibonacci pairs "
            "(n,k) = (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5}), namely (15,5), (104,39), (714,272), ...",
        ],
        "keywords": [
            "Pascal's triangle",
            "binomial coefficients",
            "Singmaster's conjecture",
            "multiplicity",
            "smooth numbers",
            "Fibonacci numbers",
            "Lucas numbers",
            "Cassini's identity",
        ],
        "article": article,
        "research_paper": paper,
        "research_paper_tex": tex,
        "demo": demo,
        "demos": [
            {
                "name": "Complete Numerical Tour of Multiplicity in Pascal's Triangle",
                "description":
                    "Enumerates every integer up to 5000 together with its multiplicity, "
                    "verifies the reflection decomposition N(t) = 2 + 2L(t) + Z(t) with "
                    "Z(t) <= 1 on the record holders, checks the smoothness theorem "
                    "p(p-1) <= 2t on each prime factor, exhibits the contrapositive killing "
                    "off numbers with a large prime factor, tabulates the smoothness hierarchy "
                    "at levels m = 2 and m = 3 (including the ceiling of 17 on the prime "
                    "factors of 3003), compares the classical bound 2 log_2 t against the "
                    "sharpened one, evaluates the counting bound for the exceptional set, "
                    "cross-validates the Fibonacci family of adjacent repetitions against a "
                    "brute-force row scan up to row 1200, prints Cassini's identity and the "
                    "Lucas-Fibonacci dictionary, runs the norm-form descent on consecutive "
                    "Lucas pairs, and dissects the eight occurrences of 3003.",
                "code": demo,
            },
            {
                "name": "Exhaustive Record Hunt: Multiplicity Statistics up to Ten Million",
                "description":
                    "Scans all values up to 10^7 using the row bound n(n-1) <= 2t to confine "
                    "the search, then tabulates the full multiplicity distribution. It "
                    "confirms that no integer below ten million has multiplicity five or "
                    "seven, that 3003 is the unique integer of multiplicity eight in that "
                    "range, that the sharp thresholds for multiplicities 3, 4, 6, 8 are "
                    "6, 10, 120, 3003, and that the proved counting bound "
                    "(sqrt(2X)+2)(log_2 X + 1) dominates the true count of exceptional numbers "
                    "at every scale; it closes with the classical versus sharpened logarithmic "
                    "bounds on each record holder.",
                "code": demo_record,
            },
        ],
        "algorithms": [
            {
                "name": "Bounded Enumeration of Binomial Occurrences and the Reflection "
                        "Decomposition",
                "description":
                    "Computes the multiplicity N(t) together with the explicit list of "
                    "positions, and splits it as N(t) = 2 + 2L(t) + Z(t). The essential trick "
                    "is that a genuinely interior occurrence C(n,k) = t with 2 <= k <= n-2 "
                    "obeys C(n,2) <= t, i.e. n(n-1) <= 2t, so only rows n <= sqrt(2t) + 1 need "
                    "be scanned; within a row, unimodality permits an early break as soon as "
                    "an entry exceeds t. The two boundary occurrences (t,1) and (t,t-1) are "
                    "added directly. Complexity: O(sqrt(t) log t) big-integer operations, "
                    "against O(t log t) for a naive scan of all rows up to t.",
                "pseudocode":
                    "function MULTIPLICITY(t):\n"
                    "    require t >= 2\n"
                    "    P <- empty set of positions\n"
                    "    if t = 2 then add (2,1) to P else add (t,1) and (t,t-1) to P\n"
                    "    n <- 4\n"
                    "    while n*(n-1) <= 2t do            # geometric row bound\n"
                    "        for k <- 2 to floor(n/2) do\n"
                    "            v <- C(n,k)\n"
                    "            if v > t then break        # unimodality\n"
                    "            if v = t then\n"
                    "                add (n,k) to P\n"
                    "                if 2k != n then add (n, n-k) to P\n"
                    "        n <- n + 1\n"
                    "    return (|P|, sorted P)\n"
                    "\n"
                    "function REFLECTION_DECOMPOSITION(t):\n"
                    "    (N, P) <- MULTIPLICITY(t)\n"
                    "    L <- #{(n,k) in P : k >= 2 and 2k < n}\n"
                    "    Z <- #{(n,k) in P : k >= 2 and n = 2k}\n"
                    "    assert N = 2 + 2L + Z and Z <= 1\n"
                    "    return (N, L, Z)",
                "code": alg_mult,
            },
            {
                "name": "Smoothness Certificate: From a Factorisation to a Multiplicity Ceiling",
                "description":
                    "Turns the prime factorisation of t into an unconditional upper bound on "
                    "N(t) via the smoothness hierarchy, which states that N(t) >= 2m+2 forces "
                    "C(p, m+1) <= t for every prime p dividing t. Since C(p, m+1) increases "
                    "with p, the largest prime factor P gives the strongest constraint: the "
                    "first level m with C(P, m+1) > t certifies N(t) <= 2m+1, and N(t) <= 2m "
                    "unless t is itself a central binomial coefficient (odd multiplicity "
                    "requires one). When no level fails, the method honestly reports no "
                    "ceiling: those are precisely the extremely smooth candidates for high "
                    "multiplicity, such as 3003 = 3*7*11*13, whose multiplicity really is 8. "
                    "Complexity: O(sqrt t) for trial division, then at most P/2 binomial "
                    "evaluations.",
                "pseudocode":
                    "function MULTIPLICITY_CEILING(t):\n"
                    "    F <- distinct prime factors of t          # trial division, O(sqrt t)\n"
                    "    P <- max F\n"
                    "    c <- the unique c with C(2c,c) = t, or NONE\n"
                    "    for m <- 1 to P-1 do\n"
                    "        if C(P, m+1) > t then\n"
                    "            # hierarchy at level m is violated, so N(t) < 2m+2\n"
                    "            if c != NONE then return 2m+1 else return 2m\n"
                    "    return NONE        # t too smooth: no ceiling from this method",
                "code": alg_smooth,
            },
            {
                "name": "Complete Enumeration of Adjacent Repetitions with Lucas Certificates "
                        "and Norm-Form Descent",
                "description":
                    "Generates every solution of C(n,k) = C(n-1,k+1) directly from the "
                    "Fibonacci recursion, exploiting the classification theorem: the solutions "
                    "are exactly (n,k) = (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5}). Each member is "
                    "emitted with its Lucas certificate 5n+1 = L_{4i+9}, 5(n-k) = L_{4i+8}+3, "
                    "and validated against the cleared-factorial identity n(k+1) = "
                    "(n-k)(n-k-1) - no binomial coefficient is ever computed. The routine also "
                    "implements the Vieta descent (x,y) -> (y, x-y) on the norm form "
                    "x^2 - xy - y^2 = +-5, which negates the form at each step, strictly "
                    "decreases x, and terminates at (1,2) = (L_1, L_0): this is the "
                    "constructive core of the proof that all solutions are consecutive Lucas "
                    "pairs. Complexity: O(1) big-integer operations per family member (against "
                    "O(n^2) binomial comparisons for a brute-force row scan) and "
                    "O(log_phi x) steps for the descent.",
                "pseudocode":
                    "function ADJACENT_REPETITIONS(count):\n"
                    "    F <- Fibonacci numbers F_0 .. F_{2*count+6}\n"
                    "    for i <- 0 to count-1 do\n"
                    "        n <- F[2i+4] * F[2i+5]\n"
                    "        k <- F[2i+2] * F[2i+5]\n"
                    "        assert n*(k+1) = (n-k)*(n-k-1)          # the Diophantine form\n"
                    "        assert 5n+1 = L[4i+9] and 5(n-k) = L[4i+8] + 3\n"
                    "        emit (i, n, k)\n"
                    "\n"
                    "function DESCEND(x, y):\n"
                    "    if |x^2 - xy - y^2| != 5 then return NONE\n"
                    "    chain <- [(x, y, x^2 - xy - y^2)]\n"
                    "    while (x, y) != (1, 2) do\n"
                    "        (x, y) <- (y, x - y)                     # negates the form\n"
                    "        append (x, y, x^2 - xy - y^2) to chain\n"
                    "    return chain                                  # ends at (L_1, L_0)",
                "code": alg_adj,
            },
        ],
        "visualizations": [
            {
                "name": "The Multiplicity Landscape and the Density-Zero Phenomenon",
                "description":
                    "A two-panel figure. The left panel plots every integer up to 20000 "
                    "against its multiplicity, greying out the overwhelming majority with "
                    "N(t) = 2 and highlighting the exceptional numbers, with the record "
                    "holders 6, 10, 120, 210, 1540 and 3003 annotated. The right panel plots, "
                    "on log-log axes, the true counting function of the exceptional set "
                    "against the proved bound (sqrt(2X)+2)(log_2 X + 1) and against the line "
                    "X, exhibiting visually why multiplicity exactly two has density one.",
                "code": viz_land,
            },
            {
                "name": "The Smoothness Hierarchy: Each Extra Repetition Costs a Root",
                "description":
                    "For each level m, the largest prime factor permitted by the hierarchy, "
                    "P(t,m) = max{p : C(p, m+1) <= t}, is plotted against t on log-log axes. "
                    "The curves have slopes 1/2, 1/3, 1/4, ... reflecting the bound "
                    "p <= m + ((m+1)! t)^(1/(m+1)): a number occurring six times is essentially "
                    "t^(1/3)-smooth, one occurring eight times essentially t^(1/4)-smooth. The "
                    "known repeat offenders 120, 210, 1540 and 3003 are overlaid with their "
                    "true largest prime factors, all sitting just beneath the ceiling their "
                    "multiplicity imposes.",
                "code": viz_hier,
            },
        ],
        "interactive_demos": [
            {
                "title": "Pascal Multiplicity Explorer: Find Every Hiding Place of a Number",
                "description":
                    "An interactive Pascal's triangle in which you choose a value and instantly "
                    "see all of its occurrences highlighted by type - left-interior in red, "
                    "mirror images in pink, a central occurrence in blue. The panel above "
                    "reports the multiplicity, the reflection decomposition "
                    "N(t) = 2 + 2L(t) + Z(t), and the largest prime factor, then applies the "
                    "smoothness test p(p-1) <= 2t live: when a prime factor is too large the "
                    "widget certifies N(t) = 2 without any search at all. It also computes the "
                    "smoothness-hierarchy ceiling, reporting the first level m with "
                    "C(p, m+1) > t and the resulting bound on the multiplicity. Preset chips "
                    "cover the classical specimens 6, 10, 20, 120, 210, 1540, 3003 and the "
                    "29-digit value C(104,39) of the second adjacent repetition. All "
                    "arithmetic is exact big-integer arithmetic.",
                "html": widget_tri,
            },
            {
                "title": "The Adjacent-Repetition Machine: Fibonacci, Lucas, Cassini, and a "
                         "Descent You Can Watch",
                "description":
                    "A four-panel laboratory for the complete classification of adjacent "
                    "repetitions C(n,k) = C(n-1,k+1). Panel 1 generates any member of the "
                    "Fibonacci family (F_{2i+4}F_{2i+5}, F_{2i+2}F_{2i+5}) with a slider, "
                    "highlights the three Fibonacci numbers used, verifies the "
                    "cleared-factorial identity n(k+1) = (n-k)(n-k-1) and displays the Lucas "
                    "certificate 5n+1 = L_{4i+9}, 5(n-k) = L_{4i+8}+3. Panel 2 lets you test "
                    "any pair (n,k) yourself and tells you whether - and which - family member "
                    "it is. Panel 3 runs the Vieta descent (x,y) -> (y, x-y) on the norm form "
                    "x^2 - xy - y^2 = +-5, printing the whole chain with its alternating signs "
                    "and naming the consecutive Lucas pairs as it falls to the base solution "
                    "(1,2). Panel 4 exhibits Cassini's identity and the Lucas-Fibonacci "
                    "dictionary L_{2a} = 5F_a^2 + 2(-1)^a, L_{2a+1} = 5F_aF_{a+1} + (-1)^a, "
                    "the bridge that identifies the Lucas classification with the Fibonacci "
                    "one.",
                "html": widget_adj,
            },
        ],
        "interactive_layout": layout,
        "lean_proofs": lean_bundle(),
        "future_directions": future,
        "modules": {"demo": demo},
        "lean_files": LEAN_FILES,
    }

    out = os.path.join(ROOT, "PACKAGE.json")
    with open(out, "w", encoding="utf-8") as fh:
        json.dump(package, fh, indent=2, ensure_ascii=False)
    print(f"wrote {out} ({os.path.getsize(out):,} bytes)")


if __name__ == "__main__":
    main()


"""Demonstration: an exhaustive record hunt in Pascal's triangle.

We enumerate every value t <= LIMIT that occurs three or more times, tabulate
the multiplicity distribution, confirm empirically that

  * no t has multiplicity 5 or 7,
  * the only t with multiplicity 8 is 3003,
  * the sharp thresholds for multiplicity >= 3, 4, 6, 8 are 6, 10, 120, 3003,
  * the proved counting bound (sqrt(2X)+2)(log2 X + 1) dominates the true count
    of exceptional numbers for every X,

and we compare the classical bound 2 log2 t with the sharpened bound
log2 t + log2(2 log2 t + 1) + 1 on the record holders.

The enumeration is fast because interior occurrences satisfy n(n-1) <= 2t:
only rows n <= sqrt(2 LIMIT) + 1 need be scanned.
"""

from __future__ import annotations

from collections import Counter
from math import comb, isqrt
from typing import Dict, List, Tuple

LIMIT = 10 ** 7


def interior_counts(limit: int) -> Dict[int, int]:
    """{t: number of interior occurrences of t} for 2 <= t <= limit, counting
    mirror images separately and central occurrences once."""
    counts: Dict[int, int] = {}
    n = 4
    while n * (n - 1) <= 2 * limit:
        for k in range(2, n // 2 + 1):
            v = comb(n, k)
            if v > limit:
                break
            counts[v] = counts.get(v, 0) + (1 if 2 * k == n else 2)
        n += 1
    return counts


def multiplicities(limit: int) -> Dict[int, int]:
    """{t: N(t)} restricted to t with N(t) >= 3."""
    interior = interior_counts(limit)
    return {t: c + 2 for t, c in interior.items() if c >= 1}


def ilog2(x: int) -> int:
    return x.bit_length() - 1


def main() -> None:
    mults = multiplicities(LIMIT)
    dist = Counter(mults.values())
    print(f"Exhaustive scan of all values t <= {LIMIT:,}")
    print("-" * 62)
    print("multiplicity distribution among the exceptional numbers:")
    for m in sorted(dist):
        print(f"   N(t) = {m}:  {dist[m]:>6} values")
    print(f"   N(t) = 2:  everything else "
          f"({LIMIT - 1 - sum(dist.values()):,} values)")
    print()

    for m in (5, 7):
        witnesses = [t for t, c in mults.items() if c == m]
        print(f"   values with N(t) = {m}: {witnesses if witnesses else 'NONE'}")
    eights = sorted(t for t, c in mults.items() if c >= 8)
    print(f"   values with N(t) >= 8: {eights}")
    print()

    print("sharp thresholds (least t attaining each multiplicity):")
    for target in (3, 4, 6, 8):
        first = min(t for t, c in mults.items() if c >= target)
        print(f"   least t with N(t) >= {target}: {first}")
    print()

    print("counting bound versus reality:")
    exceptional = sorted(mults)
    print(f"{'X':>12} {'actual':>10} {'bound':>12} {'ratio':>8}")
    for X in (10 ** 3, 10 ** 4, 10 ** 5, 10 ** 6, 10 ** 7):
        actual = sum(1 for t in exceptional if t <= X)
        bound = (isqrt(2 * X) + 2) * (ilog2(X) + 1)
        print(f"{X:>12,} {actual:>10} {bound:>12} {bound/max(actual,1):>8.2f}")
    print()

    print("upper bounds on the record holders:")
    print(f"{'t':>8} {'N(t)':>5} {'2 log2 t':>10} {'sharpened':>10}")
    for t in (6, 10, 120, 210, 1540, 3003):
        L = ilog2(t)
        print(f"{t:>8} {mults.get(t, 2):>5} {2*L:>10} {L + ilog2(2*L+1) + 1:>10}")


if __name__ == "__main__":
    main()


"""Visualization: the multiplicity landscape of Pascal's triangle.

Left panel  — every integer 2 <= t <= T plotted against its multiplicity N(t),
              with the exceptional numbers (N >= 3) picked out and the record
              holders 6, 10, 120, 210, 1540, 3003 annotated.
Right panel — the counting function #{t <= X : N(t) >= 3} against the proved
              bound (sqrt(2X) + 2)(log2 X + 1), on log-log axes, exhibiting the
              density-zero phenomenon.

Run:  python3 viz_multiplicity_landscape.py   (writes multiplicity_landscape.png)
"""

from __future__ import annotations

from math import comb, isqrt, log2
from typing import Dict, List

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


T = 20000


def multiplicity_table(limit: int) -> Dict[int, int]:
    """{t: N(t)} for 2 <= t <= limit.  Boundary occurrences contribute 2 (1 for
    t = 2); interior occurrences are found by scanning rows n <= sqrt(2 limit)+1."""
    counts: Dict[int, int] = {t: 2 for t in range(3, limit + 1)}
    counts[2] = 1
    n_max = isqrt(2 * limit) + 1
    for n in range(4, n_max + 1):
        for k in range(2, n // 2 + 1):
            v = comb(n, k)
            if v > limit:
                break
            counts[v] = counts.get(v, 0) + (1 if 2 * k == n else 2)
    return counts


def main() -> None:
    table = multiplicity_table(T)
    ts = sorted(table)
    ys = [table[t] for t in ts]
    exceptional = [(t, table[t]) for t in ts if table[t] >= 3]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.5))

    ax1.scatter(ts, ys, s=1, color="#c8d0e0", label="all integers ($N(t)=2$)")
    ax1.scatter([t for t, _ in exceptional], [c for _, c in exceptional],
                s=14, color="#d1495b", label=r"exceptional ($N(t)\geq 3$)")
    for t in (6, 10, 120, 210, 1540, 3003):
        if t in table:
            ax1.annotate(str(t), (t, table[t]), textcoords="offset points",
                         xytext=(4, 6), fontsize=9, color="#20304a")
    ax1.set_xscale("log")
    ax1.set_xlabel("$t$")
    ax1.set_ylabel("multiplicity $N(t)$")
    ax1.set_title(r"Multiplicity of $t$ in Pascal's triangle, $t \leq %d$" % T)
    ax1.set_yticks(range(1, 9))
    ax1.grid(alpha=0.25)
    ax1.legend(loc="upper left", frameon=False)

    xs: List[int] = []
    actual: List[int] = []
    bound: List[float] = []
    running = 0
    for t in ts:
        if table[t] >= 3:
            running += 1
        if t % 25 == 0 and t >= 100:
            xs.append(t)
            actual.append(running)
            bound.append((isqrt(2 * t) + 2) * (int(log2(t)) + 1))

    ax2.plot(xs, bound, color="#0b6e4f", lw=2,
             label=r"proved bound $(\sqrt{2X}+2)(\log_2 X+1)$")
    ax2.plot(xs, actual, color="#d1495b", lw=2,
             label=r"actual $\#\{t\leq X: N(t)\geq 3\}$")
    ax2.plot(xs, xs, color="#7a869a", ls="--", lw=1, label="$X$ (all integers)")
    ax2.set_xscale("log")
    ax2.set_yscale("log")
    ax2.set_xlabel("$X$")
    ax2.set_ylabel("count")
    ax2.set_title("The exceptional numbers have density zero")
    ax2.grid(alpha=0.25, which="both")
    ax2.legend(loc="upper left", frameon=False)

    fig.tight_layout()
    fig.savefig("multiplicity_landscape.png", dpi=160)
    print("wrote multiplicity_landscape.png")


if __name__ == "__main__":
    main()


"""Visualization: the smoothness hierarchy — how repetition forces small primes.

For each level m >= 1 the hierarchy states that a number t with N(t) >= 2m+2
must satisfy C(p, m+1) <= t for every prime factor p of t.  Solving for p gives
a ceiling
        P(t, m) = max{ p : C(p, m+1) <= t },
which behaves like ((m+1)! t)^{1/(m+1)} + m.  The plot shows these ceilings
against t on log-log axes: each extra pair of occurrences drags the admissible
prime factors down by another root.  The known repeat offenders (120, 210,
1540, 3003) are plotted with their true largest prime factors, all comfortably
underneath the ceiling their multiplicity imposes.

Run:  python3 viz_smoothness_hierarchy.py   (writes smoothness_hierarchy.png)
"""

from __future__ import annotations

from math import comb
from typing import List, Tuple

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def prime_ceiling(t: int, m: int) -> int:
    """Largest p with C(p, m+1) <= t (a real cap only while p > m)."""
    p = m + 1
    while comb(p + 1, m + 1) <= t:
        p += 1
    return p


def largest_prime_factor(t: int) -> int:
    d, m, best = 2, t, 1
    while d * d <= m:
        if m % d == 0:
            best = d
            while m % d == 0:
                m //= d
        d += 1
    return max(best, m)


def main() -> None:
    ts = [int(10 ** (k / 12)) for k in range(12, 12 * 9)]
    ts = sorted(set(t for t in ts if t >= 10))

    fig, ax = plt.subplots(figsize=(9.5, 6))
    colours = ["#0b6e4f", "#1b6ca8", "#7b2cbf", "#d1495b", "#e07a5f"]
    for idx, m in enumerate((1, 2, 3, 4, 5)):
        ys: List[int] = [prime_ceiling(t, m) for t in ts]
        ax.plot(ts, ys, lw=2, color=colours[idx % len(colours)],
                label=rf"$N(t)\geq {2*m+2}$:  $p \leq P(t,{m})$")

    specimens: List[Tuple[int, int]] = [(120, 6), (210, 6), (1540, 6), (3003, 8)]
    ax.scatter([t for t, _ in specimens],
               [largest_prime_factor(t) for t, _ in specimens],
               s=60, zorder=5, color="#20304a", marker="D",
               label="known repeat offenders (largest prime factor)")
    for t, mult in specimens:
        ax.annotate(f"{t}  ($N={mult}$)", (t, largest_prime_factor(t)),
                    textcoords="offset points", xytext=(8, -12), fontsize=9)

    ax.set_xscale("log")
    ax.set_yscale("log")
    ax.set_xlabel("$t$")
    ax.set_ylabel("largest admissible prime factor")
    ax.set_title("The smoothness hierarchy: more repetitions force smaller primes")
    ax.grid(alpha=0.25, which="both")
    ax.legend(loc="upper left", frameon=False, fontsize=9)

    fig.tight_layout()
    fig.savefig("smoothness_hierarchy.png", dpi=160)
    print("wrote smoothness_hierarchy.png")


if __name__ == "__main__":
    main()
