"""
Power-sum near misses on arbitrary node sets
============================================

A *near miss at level N* is a pair of distinct multisets s != t of natural numbers,
all of whose values lie in a prescribed node set A with |A| = N + 1, such that

        sum_{x in s} x^k  =  sum_{x in t} x^k        for every k = 0, 1, ..., N - 1.

(This is the classical Prouhet-Tarry-Escott situation, with a bound on the values.)

This script demonstrates, numerically, the results of the accompanying paper:

  1. On the interval A = {0, 1, ..., N} the unique minimal near miss is the
     *binomial pair*: the even side takes each even j <= N with multiplicity C(N, j),
     the odd side each odd j with multiplicity C(N, j).  Each side has 2^(N-1)
     elements, and the supports have sizes ceil((N+1)/2) and floor((N+1)/2).

  2. On an ARBITRARY node set A of N + 1 naturals, the multiplicity difference
     e(a) = mult_s(a) - mult_t(a) of any near miss satisfies

              e(a) * prod_{b in A, b != a} (a - b)  =  c      (one constant c),

     i.e. e is proportional to the inverse nodal weights.  The kernel of the
     truncated Vandermonde system is exactly one-dimensional.

  3. Rigidity: if e vanishes at a single node then s = t; consequently the two
     supports together cover all of A, so |supp s| + |supp t| >= N + 1 and the
     larger support has at least ceil((N+1)/2) distinct values.

  4. Universality: for EVERY test function f, the discrepancy is
     sum_{x in s} f(x) - sum_{x in t} f(x) = lambda * (-1)^N * (Delta^N f)(0)
     on the interval, where lambda is one integer independent of f.
     Equivalently the generating functions satisfy
     sum_{x in s} q^x - sum_{x in t} q^x = lambda * (1 - q)^N.

Run with:  python3 demo.py            (pure standard library, no dependencies)
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, gcd
from typing import Callable, Dict, List, Sequence, Tuple

Multiset = Dict[int, int]  # value -> multiplicity (multiplicities > 0)


# ----------------------------------------------------------------------------
# Basic multiset utilities
# ----------------------------------------------------------------------------

def power_sum(s: Multiset, k: int) -> int:
    """The k-th power sum sum_{x in s} x^k (with 0^0 = 1)."""
    return sum(mult * (x ** k) for x, mult in s.items())


def cardinality(s: Multiset) -> int:
    """Number of elements of the multiset, counted with multiplicity."""
    return sum(s.values())


def support(s: Multiset) -> List[int]:
    """The sorted list of distinct values occurring in s."""
    return sorted(x for x, m in s.items() if m > 0)


def is_near_miss(s: Multiset, t: Multiset, level: int) -> bool:
    """True iff s != t and all power sums of order k < level agree."""
    if s == t:
        return False
    return all(power_sum(s, k) == power_sum(t, k) for k in range(level))


# ----------------------------------------------------------------------------
# 1. The binomial pair on the interval {0, ..., N}
# ----------------------------------------------------------------------------

def even_part(n: int) -> Multiset:
    """Even side of the binomial pair: value j (even, j <= n) with multiplicity C(n, j)."""
    return {j: comb(n, j) for j in range(n + 1) if j % 2 == 0}


def odd_part(n: int) -> Multiset:
    """Odd side of the binomial pair: value j (odd, j <= n) with multiplicity C(n, j)."""
    return {j: comb(n, j) for j in range(n + 1) if j % 2 == 1}


# ----------------------------------------------------------------------------
# 2. Nodal weights and the minimal near miss on an arbitrary node set
# ----------------------------------------------------------------------------

def nodal_weight(nodes: Sequence[int], a: int) -> int:
    """The nodal weight w(a) = prod_{b in A, b != a} (a - b)."""
    w = 1
    for b in nodes:
        if b != a:
            w *= (a - b)
    return w


def lcm(values: Sequence[int]) -> int:
    """Least common multiple of a list of positive integers."""
    out = 1
    for v in values:
        out = out * v // gcd(out, v)
    return out


def minimal_kernel_vector(nodes: Sequence[int]) -> Dict[int, int]:
    """
    The primitive integer vector spanning the kernel of the truncated Vandermonde
    system on the node set A = nodes (|A| = N + 1, conditions k < N).

    By the Vandermonde kernel theorem the kernel is one-dimensional, spanned by the
    inverse nodal weights a -> 1 / w(a).  Clearing denominators and dividing by the
    content gives the unique (up to sign) primitive integer vector.
    """
    weights = {a: nodal_weight(nodes, a) for a in nodes}
    denom = lcm([abs(w) for w in weights.values()])
    # exact integer division: denom is a multiple of |w|, sign carried separately
    raw = {a: (denom // abs(w)) * (1 if w > 0 else -1) for a, w in weights.items()}
    g = 0
    for v in raw.values():
        g = gcd(g, abs(v))
    if g == 0:
        g = 1
    return {a: v // g for a, v in raw.items()}


def near_miss_from_kernel(kernel: Dict[int, int]) -> Tuple[Multiset, Multiset]:
    """Split a signed multiplicity vector into its positive and negative parts."""
    s = {a: v for a, v in kernel.items() if v > 0}
    t = {a: -v for a, v in kernel.items() if v < 0}
    return s, t


def minimal_near_miss(nodes: Sequence[int]) -> Tuple[Multiset, Multiset]:
    """The (essentially unique) minimal near miss supported on the given node set."""
    return near_miss_from_kernel(minimal_kernel_vector(nodes))


# ----------------------------------------------------------------------------
# 3. Universality: test functions, finite differences, generating functions
# ----------------------------------------------------------------------------

def weighted_sum(s: Multiset, f: Callable[[int], int]) -> int:
    """sum_{x in s} f(x)."""
    return sum(m * f(x) for x, m in s.items())


def forward_difference_at_zero(f: Callable[[int], int], n: int) -> int:
    """The n-th forward difference (Delta^n f)(0) = sum_j (-1)^(n-j) C(n, j) f(j)."""
    return sum((-1) ** (n - j) * comb(n, j) * f(j) for j in range(n + 1))


def generating_polynomial(s: Multiset, degree: int) -> List[int]:
    """Coefficient list of sum_{x in s} q^x, padded to the given degree."""
    coeffs = [0] * (degree + 1)
    for x, m in s.items():
        coeffs[x] += m
    return coeffs


def binomial_expansion_of_one_minus_q(n: int) -> List[int]:
    """Coefficient list of (1 - q)^n."""
    return [(-1) ** j * comb(n, j) for j in range(n + 1)]


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def show(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_binomial_pair(max_n: int = 8) -> None:
    show("1. The binomial pair on the interval {0, ..., N}")
    print(f"{'N':>3} {'even side':>34} {'|s|':>6} {'2^(N-1)':>8} "
          f"{'|supp s|':>9} {'|supp t|':>9} {'sum':>4}")
    for n in range(1, max_n + 1):
        s, t = even_part(n), odd_part(n)
        assert is_near_miss(s, t, n), "binomial pair must be a near miss"
        assert power_sum(s, n) != power_sum(t, n), "and must fail at k = N"
        desc = " + ".join(f"{m}*[{x}]" for x, m in sorted(s.items()))
        if len(desc) > 34:
            desc = desc[:31] + "..."
        ss, ts = len(support(s)), len(support(t))
        assert cardinality(s) * 2 == 2 ** n
        assert ss == n // 2 + 1 and ts == (n + 1) // 2 and ss + ts == n + 1
        print(f"{n:>3} {desc:>34} {cardinality(s):>6} {2 ** (n - 1):>8} "
              f"{ss:>9} {ts:>9} {ss + ts:>4}")
    print("\nEach side has exactly 2^(N-1) elements; the supports are disjoint and")
    print("together exhaust {0,...,N}, with sizes ceil((N+1)/2) and floor((N+1)/2).")


def demo_general_nodes() -> None:
    show("2. Near misses on arbitrary node sets: the inverse nodal weight law")
    examples: List[List[int]] = [
        [0, 1, 2, 3],            # interval, N = 3
        [0, 2, 4, 6],            # arithmetic progression, N = 3
        [0, 1, 4, 9],            # squares, N = 3
        [1, 2, 3, 5, 8],         # Fibonacci-ish, N = 4
        [0, 1, 3, 7, 15, 31],    # Mersenne, N = 5
    ]
    for nodes in examples:
        n = len(nodes) - 1
        s, t = minimal_near_miss(nodes)
        assert is_near_miss(s, t, n), "constructed pair must be a near miss"
        print(f"\nA = {nodes}   (N = {n})")
        print(f"  nodal weights w(a) = prod_{{b != a}} (a - b):")
        print("     " + ", ".join(f"w({a}) = {nodal_weight(nodes, a)}" for a in nodes))
        print(f"  s = {dict(sorted(s.items()))}")
        print(f"  t = {dict(sorted(t.items()))}")
        for k in range(n + 1):
            ps, pt = power_sum(s, k), power_sum(t, k)
            flag = "=" if ps == pt else "!="
            print(f"    k = {k}: {ps:>12} {flag} {pt:<12}"
                  + ("   <-- first failure" if ps != pt else ""))
        # the universal constant c = e(a) * w(a)
        cs = {a: (s.get(a, 0) - t.get(a, 0)) * nodal_weight(nodes, a) for a in nodes}
        assert len(set(cs.values())) == 1, "e(a) * w(a) must be independent of a"
        print(f"  e(a) * w(a) = {next(iter(cs.values()))} for every node a  "
              f"(one universal constant)")
        print(f"  |s| = {cardinality(s)}, |t| = {cardinality(t)}; "
              f"|supp s| + |supp t| = {len(support(s))} + {len(support(t))} "
              f"= {len(support(s)) + len(support(t))} >= N + 1 = {n + 1}")
        assert len(support(s)) + len(support(t)) >= n + 1
        assert max(len(support(s)), len(support(t))) >= (n + 2) // 2


def demo_interval_recovers_binomial(max_n: int = 6) -> None:
    show("3. On the interval the nodal-weight law reproduces (-1)^j C(N, j)")
    for n in range(1, max_n + 1):
        nodes = list(range(n + 1))
        kernel = minimal_kernel_vector(nodes)
        vec = [kernel[j] for j in nodes]
        binom = [(-1) ** j * comb(n, j) for j in nodes]
        same = vec == binom or vec == [-v for v in binom]
        print(f"N = {n}: kernel vector {vec}   alternating binomial {binom}   "
              f"{'MATCH' if same else 'MISMATCH'}")
        assert same
    print("\nIndeed w(a) = (-1)^(N-a) a! (N-a)! on {0,...,N}, so 1 / w(a) is")
    print("(-1)^a C(N, a) / N!  --  the alternating binomial profile.")


def demo_extremality_of_the_interval(max_n: int = 5) -> None:
    show("4. The interval does NOT minimise the size of the minimal near miss")
    print("Minimal near-miss cardinality |s| over node sets A of N+1 naturals,")
    print("searched inside {0, 1, ..., 3N}, compared with the interval value 2^(N-1).")
    from itertools import combinations
    for n in range(1, max_n + 1):
        best = None
        best_sets: List[Tuple[int, ...]] = []
        universe = range(0, 3 * n + 1)
        for nodes in combinations(universe, n + 1):
            if nodes[0] != 0:  # translation invariance: normalise min(A) = 0
                continue
            s, _ = minimal_near_miss(list(nodes))
            size = cardinality(s)
            if best is None or size < best:
                best, best_sets = size, [nodes]
            elif size == best:
                best_sets.append(nodes)
        assert best is not None
        verdict = (f"BEATEN by A = {list(best_sets[0])}" if best < 2 ** (n - 1)
                   else "interval is optimal")
        print(f"N = {n}: minimum |s| = {best:>3}, interval value 2^(N-1) = "
              f"{2 ** (n - 1):>3}   {verdict}")
        assert best <= 2 ** (n - 1)
    print("\nTwo explicit counterexamples, checkable by hand:")
    for nodes in ([0, 1, 3, 4], [0, 1, 4, 6, 9, 10]):
        n = len(nodes) - 1
        s, t = minimal_near_miss(nodes)
        sl = sorted(x for x, m in s.items() for _ in range(m))
        tl = sorted(x for x, m in t.items() for _ in range(m))
        print(f"\n  A = {nodes}  (N = {n}):  {sl}  vs  {tl}")
        for k in range(n + 1):
            ps, pt = power_sum(s, k), power_sum(t, k)
            print(f"     k = {k}: {ps:>8} {'=' if ps == pt else '!='} {pt:<8}")
        print(f"     size {cardinality(s)} < 2^(N-1) = {2 ** (n - 1)}")
        assert is_near_miss(s, t, n) and cardinality(s) < 2 ** (n - 1)
    print("\nSo the minimal size on a node set A is the arithmetic functional")
    print("   m(A) = (1/2) * sum_a |v(a)|,  v = primitive integer multiple of 1/w(a),")
    print("and the interval is NOT its minimiser: sparse symmetric node sets do better.")


def demo_universality(n: int = 5) -> None:
    show("5. Universality: one integer controls every test function")
    s, t = even_part(n), odd_part(n)
    lam = s.get(0, 0) - t.get(0, 0)
    print(f"N = {n}, lambda = mult_s(0) - mult_t(0) = {lam}")
    tests: List[Tuple[str, Callable[[int], int]]] = [
        ("f(x) = x^4", lambda x: x ** 4),
        ("f(x) = x^5", lambda x: x ** 5),
        ("f(x) = x^7 - 3x", lambda x: x ** 7 - 3 * x),
        ("f(x) = 2^x", lambda x: 2 ** x),
        ("f(x) = x! ", lambda x: __import__("math").factorial(x)),
        ("f(x) = [x is prime]", lambda x: int(x in (2, 3, 5, 7, 11, 13))),
    ]
    print(f"{'test function':>22} {'sum_s f - sum_t f':>20} "
          f"{'lambda*(-1)^N*Delta^N f(0)':>28}")
    for name, f in tests:
        lhs = weighted_sum(s, f) - weighted_sum(t, f)
        rhs = lam * (-1) ** n * forward_difference_at_zero(f, n)
        assert lhs == rhs
        print(f"{name:>22} {lhs:>20} {rhs:>28}")
    print("\nEvery discrepancy is lambda times the N-th finite difference at 0:")
    print("a near miss is blind to a test function precisely when Delta^N f(0) = 0,")
    print("in particular to every polynomial of degree < N.")


def demo_generating_function(n: int = 6) -> None:
    show("6. Generating-function form: the discrepancy is lambda (1 - q)^N")
    for lam in (1, 2, 3):
        s = {x: lam * m for x, m in even_part(n).items()}
        t = {x: lam * m for x, m in odd_part(n).items()}
        # add a common padding to show it is invisible
        for x, m in {0: 2, 3: 1, n: 4}.items():
            s[x] = s.get(x, 0) + m
            t[x] = t.get(x, 0) + m
        diff = [a - b for a, b in zip(generating_polynomial(s, n),
                                      generating_polynomial(t, n))]
        target = [lam * c for c in binomial_expansion_of_one_minus_q(n)]
        assert diff == target
        print(f"lambda = {lam}, with padding: coefficients of "
              f"sum_s q^x - sum_t q^x = {diff}")
        print(f"                                  lambda*(1-q)^{n} = {target}")
    print("\nAgreeing on the first N power sums == the discrepancy has a zero of")
    print("order N at q = 1; the multiplier lambda is its leading coefficient there.")


def demo_rigidity() -> None:
    show("7. Rigidity: one shared multiplicity forces equality")
    nodes = [0, 1, 3, 7, 15]
    n = len(nodes) - 1
    s, t = minimal_near_miss(nodes)
    print(f"A = {nodes},  s = {dict(sorted(s.items()))},  t = {dict(sorted(t.items()))}")
    print("Multiplicity differences e(a) = mult_s(a) - mult_t(a):")
    for a in nodes:
        e = s.get(a, 0) - t.get(a, 0)
        print(f"   e({a}) = {e:>8}   (never zero, as the theory predicts)")
        assert e != 0
    print(f"\nHence supp(s) U supp(t) = A, so |supp s| + |supp t| >= {n + 1}, "
          f"and the larger side uses at least {(n + 2) // 2} distinct values.")


def demo_concentration(max_n: int = 8) -> None:
    show("8. Concentration: some value must be repeated many times")
    print(f"{'N':>3} {'max multiplicity':>18} {'lower bound 2^N/(2(N+1))':>26}")
    for n in range(1, max_n + 1):
        s = even_part(n)
        top = max(s.values())
        bound = Fraction(2 ** n, 2 * (n + 1))
        assert top >= bound
        print(f"{n:>3} {top:>18} {float(bound):>26.3f}")
    print("\nA near miss has at least 2^(N-1) elements spread over at most N + 1")
    print("values, so its multiplicity vector can never be flat.")


def main() -> None:
    demo_binomial_pair()
    demo_general_nodes()
    demo_interval_recovers_binomial()
    demo_extremality_of_the_interval()
    demo_universality()
    demo_generating_function()
    demo_rigidity()
    demo_concentration()
    print("\nAll assertions passed.")


if __name__ == "__main__":
    main()
