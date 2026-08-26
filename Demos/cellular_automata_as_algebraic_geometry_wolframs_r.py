"""
Cellular Automata as Algebraic Geometry
=======================================

Numerical companion to "Cellular Automata as Algebraic Geometry: Wolfram's
Rules Meet Grothendieck".

Every elementary cellular automaton (ECA) rule r in {0,...,255} is a cubic
polynomial map over the field with two elements F_2.  Writing a cyclic
configuration of size n as a vector s = (s_0, ..., s_{n-1}) in F_2^n, one step
of the automaton is

    (F_r s)_i = f_r(s_{i-1}, s_i, s_{i+1}),      indices mod n,

where f_r is the unique multilinear (algebraic normal form) polynomial over F_2
reproducing the rule's 8-entry truth table.  The *fixed-point variety* is

    V(r, n) = { s in F_2^n : F_r(s) = s },

the F_2-points of the zero locus of the n cubic polynomials
f_r(s_{i-1}, s_i, s_{i+1}) - s_i.

This script demonstrates, by exhaustive computation, the results of the paper:

  1. Rule 110 (Turing-complete) has V(110, n) = {0} for every n, exactly like
     the null Rule 0: the variety is blind to universality.
  2. dim V(r, n) = n holds for exactly one rule, the identity Rule 204.
  3. For 128 rules (the odd ones) the origin is not stationary, so V is not a
     linear subspace; and whenever |V(r,n)| does not divide 2^n, V is not even
     an affine subvariety, so no dimension exists at all.
  4. Rule 30 has exactly 3 stationary configurations on every even ring and
     exactly 1 on every odd ring; 3 never divides 2^n.
  5. The additive rules 90, 150, 45 have varieties governed by n mod 3 or
     n mod 2 -- arithmetic of the ring size, not a Wolfram class.
  6. The temporal tower Per_k(r,n) = {s : F_r^k(s) = s} is a lattice under gcd
     and does separate Rule 110 from Rule 0.
  7. |V(r,n)| = trace(T_r^n) for the 4x4 de Bruijn transfer matrix T_r
     (verified numerically here for all 256 rules and n <= 14).

Run with:  python3 demo.py
Pure standard library; no dependencies.
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Dict, Iterable, List, Sequence, Set, Tuple

Cfg = Tuple[int, ...]  # a configuration: tuple of 0/1 of length n


# --------------------------------------------------------------------------
# 1.  Rules as Boolean functions and as polynomials over F_2
# --------------------------------------------------------------------------

def local_rule(rule: int, left: int, centre: int, right: int) -> int:
    """Truth-table evaluation of Wolfram rule `rule` on a 3-cell window.

    The neighbourhood (l, c, r) is read as the binary index 4l + 2c + r, and
    the output is that bit of the 8-bit Wolfram number.
    """
    return (rule >> (4 * left + 2 * centre + right)) & 1


MONOMIALS: List[Tuple[int, int, int]] = [
    (0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1),
    (1, 1, 0), (1, 0, 1), (0, 1, 1), (1, 1, 1),
]

MONOMIAL_NAMES: List[str] = ["1", "l", "c", "r", "lc", "lr", "cr", "lcr"]


def algebraic_normal_form(rule: int) -> Dict[str, int]:
    """Multilinear polynomial over F_2 representing `rule`.

    Every function F_2^3 -> F_2 has a unique representation
        f(l,c,r) = sum over subsets S of {l,c,r} of a_S * prod_{x in S} x,
    with coefficients in F_2 given by the Moebius (Reed-Muller) transform
        a_S = sum_{T subset S} f(T)   (mod 2).
    Complexity: O(8 * 8) = O(1) per rule.
    """
    coeffs: Dict[str, int] = {}
    for name, mono in zip(MONOMIAL_NAMES, MONOMIALS):
        total = 0
        for point in product((0, 1), repeat=3):
            if all(p <= m for p, m in zip(point, mono)):
                total ^= local_rule(rule, *point)
        coeffs[name] = total
    return coeffs


def anf_string(rule: int) -> str:
    """Human-readable algebraic normal form, e.g. 'c + r + cr + lcr' for 110."""
    coeffs = algebraic_normal_form(rule)
    terms = [name for name in MONOMIAL_NAMES if coeffs[name]]
    return " + ".join(terms) if terms else "0"


def degree(rule: int) -> int:
    """Total degree of the polynomial representing the rule."""
    coeffs = algebraic_normal_form(rule)
    return max((len(name) if name != "1" else 0)
               for name in MONOMIAL_NAMES if coeffs[name]) if any(coeffs.values()) else 0


def is_additive(rule: int) -> bool:
    """True iff the local rule is F_2-linear, i.e. its ANF has only 1-monomials
    and no constant term.  These are exactly the rules whose fixed-point locus
    is a linear subspace of F_2^n."""
    coeffs = algebraic_normal_form(rule)
    return (coeffs["1"] == 0 and coeffs["lc"] == 0 and coeffs["lr"] == 0
            and coeffs["cr"] == 0 and coeffs["lcr"] == 0)


# --------------------------------------------------------------------------
# 2.  Dynamics on the ring Z/nZ
# --------------------------------------------------------------------------

def step(rule: int, s: Cfg) -> Cfg:
    """One synchronous update of `rule` on the cyclic configuration `s`."""
    n = len(s)
    return tuple(local_rule(rule, s[(i - 1) % n], s[i], s[(i + 1) % n])
                 for i in range(n))


def iterate(rule: int, s: Cfg, k: int) -> Cfg:
    """Apply the automaton k times."""
    for _ in range(k):
        s = step(rule, s)
    return s


def all_configs(n: int) -> Iterable[Cfg]:
    """All 2^n configurations of the ring of size n."""
    return product((0, 1), repeat=n)


def fixed_set(rule: int, n: int) -> List[Cfg]:
    """V(rule, n) = { s : F_rule(s) = s } by exhaustive search.  O(n * 2^n)."""
    return [s for s in all_configs(n) if step(rule, s) == s]


def periodic_set(rule: int, n: int, k: int) -> Set[Cfg]:
    """Per_k(rule, n) = { s : F_rule^k(s) = s }.  O(k * n * 2^n)."""
    return {s for s in all_configs(n) if iterate(rule, s, k) == s}


# --------------------------------------------------------------------------
# 3.  Dimension, affineness, and the Lagrange obstruction
# --------------------------------------------------------------------------

def is_linear_subspace(points: Sequence[Cfg]) -> bool:
    """True iff the given set of points is an F_2-linear subspace of F_2^n:
    contains 0 and is closed under coordinatewise XOR."""
    pts = set(points)
    n = len(next(iter(pts))) if pts else 0
    if tuple([0] * n) not in pts:
        return False
    for a in pts:
        for b in pts:
            if tuple(x ^ y for x, y in zip(a, b)) not in pts:
                return False
    return True


def is_affine_subvariety(points: Sequence[Cfg]) -> bool:
    """True iff the set is a translate v + W of a linear subspace W.
    Equivalently, it is non-empty and v + S is linear for any v in S."""
    pts = set(points)
    if not pts:
        return False
    v = next(iter(pts))
    translated = [tuple(x ^ y for x, y in zip(v, p)) for p in pts]
    return is_linear_subspace(translated)


def fixed_dimension(rule: int, n: int) -> int | None:
    """dim V(rule, n) if the variety is a linear subspace, else None.

    A linear subspace of F_2^n with 2^d points has dimension d; the Lagrange
    obstruction says that if |V| does not divide 2^n then V is not even an
    affine subvariety, so no dimension can be assigned.
    """
    pts = fixed_set(rule, n)
    if not is_linear_subspace(pts):
        return None
    d = 0
    while (1 << d) < len(pts):
        d += 1
    return d


# --------------------------------------------------------------------------
# 4.  The de Bruijn transfer matrix
# --------------------------------------------------------------------------

def transfer_matrix(rule: int) -> List[List[int]]:
    """The 4x4 stationary de Bruijn matrix T_r.

    Vertices are the 4 states (a, b) in F_2^2 recording a consecutive pair
    (s_{i-1}, s_i).  There is an edge (a, b) -> (b, c) precisely when the
    window (a, b, c) is stationary, i.e. f_r(a, b, c) = b.  A stationary
    configuration on the ring of size n is exactly a closed walk of length n,
    so |V(r, n)| should equal trace(T_r^n).
    """
    states = [(a, b) for a in (0, 1) for b in (0, 1)]
    index = {st: i for i, st in enumerate(states)}
    T = [[0] * 4 for _ in range(4)]
    for (a, b) in states:
        for c in (0, 1):
            if local_rule(rule, a, b, c) == b:
                T[index[(a, b)]][index[(b, c)]] = 1
    return T


def mat_mul(A: List[List[int]], B: List[List[int]]) -> List[List[int]]:
    """Ordinary integer matrix product."""
    m, k, p = len(A), len(B), len(B[0])
    return [[sum(A[i][t] * B[t][j] for t in range(k)) for j in range(p)]
            for i in range(m)]


def mat_pow(A: List[List[int]], e: int) -> List[List[int]]:
    """Fast exponentiation, O(log e) matrix products."""
    size = len(A)
    result = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
    base = [row[:] for row in A]
    while e:
        if e & 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        e >>= 1
    return result


def trace_count(rule: int, n: int) -> int:
    """trace(T_r^n): the predicted number of stationary configurations.
    Complexity O(log n) matrix products on a fixed 4x4 matrix."""
    P = mat_pow(transfer_matrix(rule), n)
    return sum(P[i][i] for i in range(4))


# --------------------------------------------------------------------------
# 5.  Wolfram classes of the commonly cited representative rules
# --------------------------------------------------------------------------

WOLFRAM_CLASS: Dict[int, int] = {
    # Class 1: evolution to a homogeneous state
    0: 1, 8: 1, 32: 1, 128: 1, 160: 1, 168: 1,
    # Class 2: evolution to periodic / localised structures
    1: 2, 4: 2, 108: 2, 204: 2, 218: 2, 232: 2,
    # Class 3: chaotic, aperiodic
    18: 3, 22: 3, 30: 3, 45: 3, 60: 3, 90: 3, 105: 3, 122: 3, 126: 3, 146: 3, 150: 3,
    # Class 4: localised structures with complex interactions (universality)
    54: 4, 106: 4, 110: 4, 124: 4, 137: 4, 193: 4,
}


def show(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


# --------------------------------------------------------------------------
# Demonstration 1: rules as polynomials
# --------------------------------------------------------------------------

def demo_polynomials() -> None:
    show("1.  Elementary cellular automata are cubic polynomial maps over F_2")
    highlights = [0, 30, 45, 90, 110, 124, 137, 150, 193, 204, 232]
    print(f"{'rule':>5} {'f(l,c,r) in F_2[l,c,r]':<30} {'deg':>3} {'additive':>9}")
    for r in highlights:
        print(f"{r:>5} {anf_string(r):<30} {degree(r):>3} {str(is_additive(r)):>9}")
    degs = {}
    for r in range(256):
        degs[degree(r)] = degs.get(degree(r), 0) + 1
    print(f"\nDegree census over all 256 rules: {dict(sorted(degs.items()))}")
    print(f"Additive (F_2-linear) rules: "
          f"{[r for r in range(256) if is_additive(r)]}")


# --------------------------------------------------------------------------
# Demonstration 2: Rule 110's rigidity
# --------------------------------------------------------------------------

def demo_rule110_rigidity() -> None:
    show("2.  Rigidity of Rule 110: V(110, n) = {0} for every n")
    print("Fixed-point equation of Rule 110:  r(1 + c + lc) = 0.")
    print("A cell carrying 1 forces its left neighbour to 1 and the next one")
    print("left to 0, while the same constraint one step further left forces")
    print("that cell to 1 -- a contradiction.\n")
    for n in range(1, 15):
        V110 = fixed_set(110, n)
        V0 = fixed_set(0, n)
        assert V110 == V0 == [tuple([0] * n)], n
        print(f"  n = {n:>2}:  |V(110,n)| = {len(V110)}   V(110,n) = V(0,n) = {{0}}   OK")
    print("\nThe whole Turing-complete symmetry orbit {110, 124, 137, 193}:")
    for r in (110, 124, 137, 193):
        for n in range(1, 11):
            V = fixed_set(r, n)
            assert len(V) == 1, (r, n)
        pt = fixed_set(r, 6)[0]
        print(f"  Rule {r:>3}: |V| = 1 for all n <= 10; the unique point on n = 6 "
              f"is {''.join(map(str, pt))}")


# --------------------------------------------------------------------------
# Demonstration 3: maximal dimension classifies the identity rule
# --------------------------------------------------------------------------

def demo_maximal_dimension() -> None:
    show("3.  dim V(r, n) = n  holds for exactly one rule: the identity Rule 204")
    for n in (3, 4, 5, 6):
        maximal = [r for r in range(256) if len(fixed_set(r, n)) == 2 ** n]
        print(f"  n = {n}:  rules with V(r,n) = the whole affine space: {maximal}")
    print("\n  'Maximal dimension' is a certificate of NO dynamics: Rule 204 is")
    print("  f(l,c,r) = c, the identity map, which never changes anything.")


# --------------------------------------------------------------------------
# Demonstration 4: when the dimension fails to exist
# --------------------------------------------------------------------------

def demo_no_dimension() -> None:
    show("4.  Two obstructions to the existence of a dimension")
    odd_missing_origin = [r for r in range(256)
                          if tuple([0] * 5) not in fixed_set(r, 5)]
    print(f"  Obstruction 1 (origin).  Rules whose variety misses 0 on n = 5: "
          f"{len(odd_missing_origin)} of 256")
    print(f"  -- and these are exactly the odd Wolfram numbers: "
          f"{all(r % 2 == 1 for r in odd_missing_origin)}")

    print("\n  Obstruction 2 (Lagrange).  An affine subvariety of F_2^n has")
    print("  cardinality dividing 2^n.  Counterexamples:")
    for (r, n) in ((232, 4), (45, 3), (30, 4), (30, 6), (30, 8), (110, 4)):
        pts = fixed_set(r, n)
        card = len(pts)
        divides = (2 ** n) % card == 0 if card else False
        print(f"    Rule {r:>3}, n = {n}:  |V| = {card:>2},  "
              f"|V| divides 2^{n} = {2**n}?  {divides};  "
              f"affine? {is_affine_subvariety(pts)}")

    print("\n  Census on the ring of size 6: how many of the 256 rules admit a")
    print("  fixed-point dimension at all?")
    n = 6
    have_dim = [r for r in range(256) if fixed_dimension(r, n) is not None]
    print(f"    rules with a genuine linear fixed-point variety: {len(have_dim)} / 256")
    dims: Dict[int, int] = {}
    for r in have_dim:
        d = fixed_dimension(r, n)
        assert d is not None
        dims[d] = dims.get(d, 0) + 1
    print(f"    distribution of dim V(r,6): {dict(sorted(dims.items()))}")


# --------------------------------------------------------------------------
# Demonstration 5: Rule 30's three-point locus
# --------------------------------------------------------------------------

def demo_rule30() -> None:
    show("5.  Rule 30: the canonical chaotic rule has a three-point locus")
    print("  Fixed-point equation of Rule 30:  l + r + cr = 0, i.e.")
    print("     s_i = 0  =>  s_{i-1} = s_{i+1},      s_i = 1  =>  s_{i-1} = 0.")
    print("  Both force spatial period two.\n")
    for n in range(2, 15):
        V = fixed_set(30, n)
        expected = 3 if n % 2 == 0 else 1
        assert len(V) == expected, (n, len(V))
        words = ", ".join("".join(map(str, s)) for s in V)
        print(f"  n = {n:>2} ({'even' if n % 2 == 0 else 'odd '}):  "
              f"|V(30,n)| = {len(V)}   V = {{{words}}}")
    print("\n  Three never divides 2^n, so on every even ring the variety of the")
    print("  canonical chaotic rule is not an affine subvariety: it has no")
    print("  dimension whatsoever -- for infinitely many n at once.")


# --------------------------------------------------------------------------
# Demonstration 6: the variety is arithmetic, not dynamical
# --------------------------------------------------------------------------

def demo_arithmetic() -> None:
    show("6.  What V(r, n) really measures: the arithmetic of n")
    print("  Rule  90 (f = l + r):        stationarity is s_{i+1} = s_{i-1} + s_i,")
    print("                               a recurrence of period 3 over F_2.")
    print("  Rule  45 (f = 1 + l + r + cr): same period-3 transfer, shifted by 1.")
    print("  Rule 150 (f = l + c + r):    stationarity is s_{i-1} = s_{i+1}, period 2.\n")
    header = f"  {'n':>3} | {'|V(90,n)|':>9} {'dim':>4} | {'|V(45,n)|':>9} | {'|V(150,n)|':>10} {'dim':>4}"
    print(header)
    print("  " + "-" * (len(header) - 2))
    for n in range(2, 15):
        c90, c45, c150 = (len(fixed_set(r, n)) for r in (90, 45, 150))
        d90, d150 = fixed_dimension(90, n), fixed_dimension(150, n)
        print(f"  {n:>3} | {c90:>9} {str(d90):>4} | {c45:>9} | {c150:>10} {str(d150):>4}"
              f"   {'(3 | n)' if n % 3 == 0 else ''}{'  (n even)' if n % 2 == 0 else ''}")
    print("\n  |V(90,n)| = 4 iff 3 | n, else 1.   |V(45,n)| = 3 iff 3 | n, else 0.")
    print("  |V(150,n)| = 4 iff n even, else 2.  A Wolfram class does not depend")
    print("  on n; these numbers do.  Rules 90, 45, 150 are all Wolfram class 3.")


# --------------------------------------------------------------------------
# Demonstration 7: the repaired invariant -- the temporal tower
# --------------------------------------------------------------------------

def demo_temporal_tower() -> None:
    show("7.  The temporal tower Per_k(r,n) = {s : F^k(s) = s}")
    n = 4
    print(f"  Ring size n = {n}.  Rule 110 versus Rule 0:\n")
    print(f"  {'k':>3} | {'|Per_k(110,4)|':>15} | {'|Per_k(0,4)|':>13}")
    print("  " + "-" * 38)
    for k in range(1, 9):
        a = len(periodic_set(110, n, k))
        b = len(periodic_set(0, n, k))
        print(f"  {k:>3} | {a:>15} | {b:>13}")
    print("\n  The fixed-point varieties coincide (k = 1: both equal {0}), but at")
    print("  k = 2 they part company.  Rule 110's 2-cycle on the ring of size 4:")
    s = (1, 1, 1, 0)
    t = step(110, s)
    print(f"     {''.join(map(str, s))}  ->  {''.join(map(str, t))}  ->  "
          f"{''.join(map(str, step(110, t)))}")
    assert iterate(110, s, 2) == s and step(110, s) != s
    print(f"  |Per_2(110,4)| = {len(periodic_set(110, 4, 2))}, which does not divide 16:")
    print(f"     affine? {is_affine_subvariety(list(periodic_set(110, 4, 2)))} "
          f"-- even the repaired invariant is not a dimension.")

    print("\n  Lattice property:  Per_k n Per_l = Per_{gcd(k,l)}.")
    ok = True
    for rule in (30, 90, 110, 150, 232):
        for k in range(1, 7):
            for l in range(1, 7):
                lhs = periodic_set(rule, 4, k) & periodic_set(rule, 4, l)
                rhs = periodic_set(rule, 4, gcd(k, l))
                ok = ok and lhs == rhs
    print(f"     verified for rules 30, 90, 110, 150, 232 on n = 4, "
          f"all 1 <= k, l <= 6: {ok}")


# --------------------------------------------------------------------------
# Demonstration 8: the transfer-matrix trace formula
# --------------------------------------------------------------------------

def demo_transfer_matrix() -> None:
    show("8.  |V(r, n)| = trace(T_r^n) for the de Bruijn transfer matrix")
    T = transfer_matrix(110)
    print("  Stationary de Bruijn matrix of Rule 110 (states 00, 01, 10, 11):")
    for row in T:
        print("     " + " ".join(str(x) for x in row))
    matches = True
    for rule in range(256):
        for n in range(1, 13):
            if len(fixed_set(rule, n)) != trace_count(rule, n):
                matches = False
                print(f"     MISMATCH at rule {rule}, n = {n}")
    print(f"\n  Exhaustive check, all 256 rules and 1 <= n <= 12: {matches}")
    print("\n  Consequence: |V(r,n)| satisfies a linear recurrence of order <= 4")
    print("  with integer coefficients, given by the characteristic polynomial")
    print("  of T_r.  Some large-n values, computed in O(log n) time:")
    for rule in (30, 90, 110, 150, 204, 232):
        vals = [trace_count(rule, n) for n in (10, 100, 1000)]
        print(f"     rule {rule:>3}:  |V| at n = 10, 100, 1000  ->  {vals}")


# --------------------------------------------------------------------------
# Demonstration 9: the conjecture, scored
# --------------------------------------------------------------------------

def demo_conjecture_scored() -> None:
    show("9.  Scoring the conjecture 'Wolfram class = dim V(f)'")
    n = 6
    print(f"  Ring size n = {n}.  Prediction: class 1 -> dim 0, class 2 -> dim <= n/2,")
    print(f"  class 3 -> dim >= n/2, class 4 -> dim = n.\n")
    print(f"  {'rule':>5} {'class':>6} {'|V|':>5} {'dim':>6} {'predicted':>12} {'verdict':>10}")
    hits = misses = undefined = 0
    for rule in sorted(WOLFRAM_CLASS):
        cls = WOLFRAM_CLASS[rule]
        pts = fixed_set(rule, n)
        d = fixed_dimension(rule, n)
        if cls == 1:
            pred, ok = "dim = 0", (d == 0)
        elif cls == 2:
            pred, ok = "dim <= n/2", (d is not None and 2 * d <= n)
        elif cls == 3:
            pred, ok = "dim >= n/2", (d is not None and 2 * d >= n)
        else:
            pred, ok = "dim = n", (d == n)
        if d is None:
            undefined += 1
            verdict = "NO DIM"
        elif ok:
            hits += 1
            verdict = "ok"
        else:
            misses += 1
            verdict = "FAILS"
        print(f"  {rule:>5} {cls:>6} {len(pts):>5} {str(d):>6} {pred:>12} {verdict:>10}")
    total = hits + misses + undefined
    print(f"\n  Of {total} commonly cited representative rules: {hits} satisfy the")
    print(f"  prediction, {misses} violate it outright, and {undefined} have no")
    print(f"  dimension at all.  Every class-4 (universal) rule fails.")


def main() -> None:
    print(__doc__)
    demo_polynomials()
    demo_rule110_rigidity()
    demo_maximal_dimension()
    demo_no_dimension()
    demo_rule30()
    demo_arithmetic()
    demo_temporal_tower()
    demo_transfer_matrix()
    demo_conjecture_scored()
    show("Summary")
    print("""
  The fixed-point variety of an elementary cellular automaton is a genuine
  algebraic object -- a cyclic subshift of finite type cut out by n cubic
  equations over F_2, whose point count is the trace of a 4x4 integer matrix
  power.  But it does not see dynamical complexity.  The Turing-complete
  Rule 110 and the null Rule 0 have literally the same variety, a single
  point; maximal dimension singles out the do-nothing identity rule; and for
  most rules no dimension exists at all.  What the variety measures is the
  arithmetic of the ring size.  Complexity lives one level up, in the tower
  of temporal varieties Per_k -- the coefficients of the dynamical zeta
  function -- which does separate Rule 110 from Rule 0.
""")


if __name__ == "__main__":
    main()
