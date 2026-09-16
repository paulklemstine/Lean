"""
The type channel is the abelianization content: numerical demonstrations.
=========================================================================

This self-contained script demonstrates, numerically and symbolically-in-spirit,
the central law

    I( residue class of p ; splitting type of p )
        = I( abelianization coset of Frobenius ; splitting type )
        = H(T) - H(T | coset)                     <=  log2 [G : G'] ,

for the six Galois groups S3, S4, A4, D4, V4, C4, at the level of single primes
and at the level of semiprimes N = p*q.

Four independent demonstrations are run:

  (1) EXACT GROUP-LEVEL TABLE.  Each Galois group is enumerated as an explicit set
      of permutations of the roots.  Entropies and mutual informations are computed
      from exact counting measures and compared against the closed forms
      (with L3 = log2 3, L5 = log2 5):

          field            G    G^ab     H(T)              I               loss
          x^3+x+1          S3   C2       2/3 + L3/2        1               0
          x^4-x-1          S4   C2       3/2 + 3L3/8       1               0
          x^4+8x+12        A4   C3       3L3/4             L3 - 2/3        2/3
          x^4-2            D4   C2xC2    5/2 - 3L3/8       9/4 - 3L3/8     3L3/8 - 1/4
          x^4-2x^2+9       V4   V4       2 - 3L3/4         2 - 3L3/4       3L3/4
          Phi_5            C4   C4       3/2               3/2             1/2

  (2) EXACT SEMIPRIME TABLE.  The pair channel I( coset(x*y) ; {T x, T y} ) is
      enumerated over all of G x G, together with the "which-factor wall": telling
      the reader which factor carried which shape changes nothing.

  (3) EMPIRICAL PRIME-LEVEL CHANNELS.  Splitting types of honest primes are computed
      by distinct-degree factorization of the defining polynomial over F_p, the
      residue dial is read from the abelian subfield, and the measured channel is
      compared with the closed form.

  (4) STRUCTURAL PHENOMENA.  The S4 cap (five types, one bit), the reversal
      (a non-abelian channel strictly richer than an abelian one), and perfect-group
      flatness (A5 leaks exactly zero).

No third-party packages are required.
"""

from __future__ import annotations

from itertools import permutations, product
from math import gcd, log2
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

Perm = Tuple[int, ...]  # a permutation of {0, ..., n-1} given by its image tuple

L3 = log2(3.0)
L5 = log2(5.0)


# ---------------------------------------------------------------------------
# 1. A finite uniform channel calculus
# ---------------------------------------------------------------------------

def entropy(values: Sequence[object]) -> float:
    """Shannon entropy in bits of the empirical distribution of `values`."""
    counts: Dict[object, int] = {}
    for v in values:
        counts[v] = counts.get(v, 0) + 1
    n = len(values)
    return -sum((c / n) * log2(c / n) for c in counts.values())


def joint_entropy(xs: Sequence[object], ys: Sequence[object]) -> float:
    """Shannon entropy in bits of the joint readout (x, y)."""
    return entropy(list(zip(xs, ys)))


def mutual_information(xs: Sequence[object], ys: Sequence[object]) -> float:
    """I(X ; Y) = H(X) + H(Y) - H(X, Y), in bits."""
    return entropy(xs) + entropy(ys) - joint_entropy(xs, ys)


def conditional_entropy(ys: Sequence[object], xs: Sequence[object]) -> float:
    """H(Y | X) = H(X, Y) - H(X), in bits."""
    return joint_entropy(xs, ys) - entropy(xs)


# ---------------------------------------------------------------------------
# 2. Permutation groups of the roots
# ---------------------------------------------------------------------------

def compose(g: Perm, h: Perm) -> Perm:
    """The permutation (g*h)(x) = g(h(x))."""
    return tuple(g[h[x]] for x in range(len(g)))


def inverse(g: Perm) -> Perm:
    out = [0] * len(g)
    for x, y in enumerate(g):
        out[y] = x
    return tuple(out)


def sign(g: Perm) -> int:
    """+1 for even, -1 for odd permutations."""
    n = len(g)
    seen = [False] * n
    s = 1
    for x in range(n):
        if seen[x]:
            continue
        length = 0
        y = x
        while not seen[y]:
            seen[y] = True
            y = g[y]
            length += 1
        if length % 2 == 0:
            s = -s
    return s


def cycle_type(g: Perm) -> Tuple[int, ...]:
    """The cycle type of g as a sorted tuple of cycle lengths (the splitting type)."""
    n = len(g)
    seen = [False] * n
    out: List[int] = []
    for x in range(n):
        if seen[x]:
            continue
        length = 0
        y = x
        while not seen[y]:
            seen[y] = True
            y = g[y]
            length += 1
        out.append(length)
    return tuple(sorted(out, reverse=True))


def derived_subgroup(group: Sequence[Perm]) -> List[Perm]:
    """The commutator subgroup [G, G], computed by closure of all commutators."""
    gens = {compose(compose(a, b), compose(inverse(a), inverse(b)))
            for a in group for b in group}
    n = len(group[0])
    closure = {tuple(range(n))}
    frontier = set(gens)
    while frontier:
        new = set()
        for x in frontier:
            if x not in closure:
                closure.add(x)
                for y in list(closure):
                    for z in (compose(x, y), compose(y, x)):
                        if z not in closure:
                            new.add(z)
        frontier = new
    return sorted(closure)


def coset_readout(group: Sequence[Perm], normal: Sequence[Perm]) -> Callable[[Perm], int]:
    """A numeric readout whose level sets are exactly the cosets of `normal` in G.

    This is the abstract form of "the residue class of p modulo the conductor":
    class field theory identifies that residue class with the coset of Frobenius
    modulo the derived subgroup.
    """
    normal_set = set(normal)
    reps: List[Perm] = []
    for g in group:
        if not any(compose(g, inverse(r)) in normal_set for r in reps):
            reps.append(g)
    index: Dict[Perm, int] = {}
    for g in group:
        for i, r in enumerate(reps):
            if compose(g, inverse(r)) in normal_set:
                index[g] = i
                break
    return lambda g: index[g]


# The six Galois groups of the experiment, as permutation groups of the roots.

S3: List[Perm] = [tuple(p) for p in permutations(range(3))]
A3: List[Perm] = [g for g in S3 if sign(g) == 1]
S4: List[Perm] = [tuple(p) for p in permutations(range(4))]
A4: List[Perm] = [g for g in S4 if sign(g) == 1]
V4: List[Perm] = [g for g in S4 if cycle_type(g) in {(1, 1, 1, 1), (2, 2)}]
# D4 = stabiliser of the pairing {{0,2},{1,3}} of the roots a, ia, -a, -ia of x^4 - 2.
D4: List[Perm] = [g for g in S4 if {g[0], g[2]} in ({0, 2}, {1, 3})]
# C4 acting regularly on the four roots of Phi_5.
C4: List[Perm] = [g for g in S4 if g[1] == (g[0] + 1) % 4 and g[2] == (g[0] + 2) % 4
                  and g[3] == (g[0] + 3) % 4]

FIELDS: List[Tuple[str, str, List[Perm]]] = [
    ("x^3 + x + 1", "S3", S3),
    ("x^4 - x - 1", "S4", S4),
    ("x^4 + 8x + 12", "A4", A4),
    ("x^4 - 2", "D4", D4),
    ("x^4 - 2x^2 + 9", "V4", V4),
    ("Phi_5 = x^4+x^3+x^2+x+1", "C4", C4),
]

CLOSED_FORM_PRIME: Dict[str, Tuple[float, float, float]] = {
    # name -> (H(T), I, dial = log2 [G:G'])
    "S3": (2 / 3 + L3 / 2, 1.0, 1.0),
    "S4": (3 / 2 + 3 * L3 / 8, 1.0, 1.0),
    "A4": (3 * L3 / 4, L3 - 2 / 3, L3),
    "D4": (5 / 2 - 3 * L3 / 8, 9 / 4 - 3 * L3 / 8, 2.0),
    "V4": (2 - 3 * L3 / 4, 2 - 3 * L3 / 4, 2.0),
    "C4": (3 / 2, 3 / 2, 2.0),
}

CLOSED_FORM_SEMIPRIME: Dict[str, float] = {
    "S3": 1.0,
    "S4": 1.0,
    "A4": L3 - 10 / 9,
    "D4": 39 / 16 - (3 / 4) * L3 + (5 / 64) * L5,
    "V4": 19 / 8 - (21 / 16) * L3,
    "C4": 5 / 4,
}


# ---------------------------------------------------------------------------
# 3. The exact prime-level law table
# ---------------------------------------------------------------------------

def prime_level_table() -> None:
    print("=" * 88)
    print("(1) EXACT PRIME-LEVEL TABLE   I(coset ; type) = H(T) - H(T | coset) <= log2 [G:G']")
    print("=" * 88)
    index_col = "index"
    header = (f"{'field':<24}{'G':<5}{'|G|':>5}{index_col:>9}{'H(T)':>10}"
              f"{'I':>10}{'law':>10}{'loss':>10}")
    print(header)
    print("-" * len(header))
    for poly, name, group in FIELDS:
        derived = derived_subgroup(group)
        coset = coset_readout(group, derived)
        types = [cycle_type(g) for g in group]
        cosets = [coset(g) for g in group]
        h_type = entropy(types)
        info = mutual_information(cosets, types)
        dial = log2(len(group) // len(derived))
        loss = dial - info
        h_form, i_form, dial_form = CLOSED_FORM_PRIME[name]
        assert abs(h_type - h_form) < 1e-12, (name, h_type, h_form)
        assert abs(info - i_form) < 1e-12, (name, info, i_form)
        assert abs(dial - dial_form) < 1e-12, (name, dial, dial_form)
        # decomposition and loss identities
        assert abs(info - (h_type - conditional_entropy(types, cosets))) < 1e-12
        assert abs(loss - conditional_entropy(cosets, types)) < 1e-12
        print(f"{poly:<24}{name:<5}{len(group):>5}{len(group)//len(derived):>9}"
              f"{h_type:>10.5f}{info:>10.5f}{i_form:>10.5f}{loss:>10.5f}")
    print("\nAll six channels match their closed forms exactly, and in every case")
    print("I = H(T) - H(T | coset) and  log2[G:G'] - I = H(coset | T).\n")


# ---------------------------------------------------------------------------
# 4. The exact semiprime table and the which-factor wall
# ---------------------------------------------------------------------------

def semiprime_table() -> None:
    print("=" * 88)
    print("(2) EXACT SEMIPRIME TABLE   I2 = I( coset(x*y) ; {T x, T y} ),  (x,y) uniform in GxG")
    print("=" * 88)
    header = (f"{'field':<24}{'G':<5}{'I2 (unordered)':>16}{'I2 (ordered)':>15}"
              f"{'closed form':>14}{'wall':>8}")
    print(header)
    print("-" * len(header))
    for poly, name, group in FIELDS:
        derived = derived_subgroup(group)
        coset = coset_readout(group, derived)
        pairs = list(product(group, group))
        prod_coset = [coset(compose(x, y)) for x, y in pairs]
        unordered = [tuple(sorted((cycle_type(x), cycle_type(y)))) for x, y in pairs]
        ordered = [(cycle_type(x), cycle_type(y)) for x, y in pairs]
        i_sym = mutual_information(prod_coset, unordered)
        i_ord = mutual_information(prod_coset, ordered)
        form = CLOSED_FORM_SEMIPRIME[name]
        assert abs(i_sym - form) < 1e-12, (name, i_sym, form)
        assert abs(i_sym - i_ord) < 1e-12, (name, i_sym, i_ord)
        print(f"{poly:<24}{name:<5}{i_sym:>16.5f}{i_ord:>15.5f}{form:>14.5f}"
              f"{abs(i_sym - i_ord):>8.1e}")
    print("\nThe C2 cap survives the passage to semiprimes: the five-type S4 field still")
    print("delivers exactly one bit, while the two-dimensional abelianization of D4 lets")
    print("its non-abelian channel rise to 1.43018 bits, above every quadratic field.\n")


# ---------------------------------------------------------------------------
# 5. Splitting types of honest primes: distinct-degree factorization over F_p
# ---------------------------------------------------------------------------

def poly_trim(a: List[int]) -> List[int]:
    while a and a[-1] == 0:
        a.pop()
    return a


def poly_mulmod(a: List[int], b: List[int], f: List[int], p: int) -> List[int]:
    """(a*b) mod f over F_p, with f monic."""
    out = [0] * (len(a) + len(b) - 1) if a and b else []
    for i, ai in enumerate(a):
        if ai:
            for j, bj in enumerate(b):
                out[i + j] = (out[i + j] + ai * bj) % p
    return poly_mod(out, f, p)


def poly_mod(a: List[int], f: List[int], p: int) -> List[int]:
    a = [x % p for x in a]
    df = len(f) - 1
    while len(a) - 1 >= df and a:
        c = a[-1] % p
        shift = len(a) - 1 - df
        if c:
            for i, fi in enumerate(f):
                a[shift + i] = (a[shift + i] - c * fi) % p
        a.pop()
        poly_trim(a)
    return poly_trim(a)


def poly_gcd(a: List[int], b: List[int], p: int) -> List[int]:
    a = poly_trim([x % p for x in a])
    b = poly_trim([x % p for x in b])
    while b:
        a = poly_mod(a, monic(b, p), p)
        a, b = b, a
    return monic(a, p) if a else a


def monic(a: List[int], p: int) -> List[int]:
    if not a:
        return a
    inv = pow(a[-1], p - 2, p)
    return [(x * inv) % p for x in a]


def poly_powmod(base: List[int], e: int, f: List[int], p: int) -> List[int]:
    result = [1]
    b = poly_mod(list(base), f, p)
    while e:
        if e & 1:
            result = poly_mulmod(result, b, f, p)
        b = poly_mulmod(b, b, f, p)
        e >>= 1
    return result


def splitting_type(f: List[int], p: int) -> Tuple[int, ...] | None:
    """The factorization shape of the squarefree polynomial f modulo p.

    Returned as the sorted multiset of the degrees of the irreducible factors, which
    for an unramified prime is exactly the cycle type of Frobenius on the roots.
    Returns None if p is ramified (f mod p is not squarefree) or divides the leading
    coefficient.
    """
    fp = poly_trim([c % p for c in f])
    if len(fp) != len(f):
        return None
    fp = monic(fp, p)
    deriv = poly_trim([(i * c) % p for i, c in enumerate(fp)][1:])
    if not deriv or len(poly_gcd(fp, deriv, p)) > 1:
        return None
    shape: List[int] = []
    current = fp
    d = 0
    while len(current) - 1 > 0:
        d += 1
        if 2 * d > len(current) - 1:
            shape.append(len(current) - 1)
            break
        h = poly_powmod([0, 1], p ** d, current, p)   # x^(p^d) mod current
        hx = poly_trim([(hi - (1 if i == 1 else 0)) % p
                        for i, hi in enumerate(h + [0] * max(0, 2 - len(h)))])
        g = poly_gcd(hx, current, p) if hx else list(current)
        # g = gcd(x^(p^d) - x, current): product of the irreducible factors of degree d
        if len(g) - 1 > 0:
            shape.extend([d] * ((len(g) - 1) // d))
            current = monic(poly_mod_div(current, g, p), p)
    return tuple(sorted(shape, reverse=True))


def poly_mod_div(a: List[int], b: List[int], p: int) -> List[int]:
    """Exact quotient a / b over F_p (b assumed to divide a)."""
    a = list(a)
    q = [0] * (len(a) - len(b) + 1)
    binv = pow(b[-1], p - 2, p)
    for shift in range(len(a) - len(b), -1, -1):
        c = (a[shift + len(b) - 1] * binv) % p
        q[shift] = c
        if c:
            for i, bi in enumerate(b):
                a[shift + i] = (a[shift + i] - c * bi) % p
    return poly_trim(q)


def primes_up_to(n: int) -> List[int]:
    sieve = [True] * (n + 1)
    sieve[0:2] = [False, False]
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def legendre(a: int, p: int) -> int:
    a %= p
    if a == 0:
        return 0
    return 1 if pow(a, (p - 1) // 2, p) == 1 else -1


def empirical_channels(bound: int = 60000) -> None:
    print("=" * 88)
    print(f"(3) EMPIRICAL PRIME-LEVEL CHANNELS (primes up to {bound})")
    print("=" * 88)
    ps = [p for p in primes_up_to(bound) if p > 3]

    # (polynomial coefficients low-to-high, name, residue dial, closed-form I)
    experiments: List[Tuple[str, List[int], str, Callable[[int], int], float]] = [
        ("x^3 + x + 1", [1, 1, 0, 1], "S3", lambda p: legendre(-31, p), 1.0),
        ("x^3 - x + 1", [1, -1, 0, 1], "S3", lambda p: legendre(-23, p), 1.0),
        ("x^4 - x - 1", [-1, -1, 0, 0, 1], "S4", lambda p: legendre(-283, p), 1.0),
        ("x^4 - 2", [-2, 0, 0, 0, 1], "D4", lambda p: p % 8, 9 / 4 - 3 * L3 / 8),
        ("Phi_5", [1, 1, 1, 1, 1], "C4", lambda p: p % 5, 3 / 2),
    ]
    header = f"{'field':<16}{'G':<5}{'#primes':>9}{'H(T)':>10}{'I measured':>12}{'law':>10}{'|diff|':>9}"
    print(header)
    print("-" * len(header))
    for poly_name, coeffs, group_name, dial, law in experiments:
        types: List[Tuple[int, ...]] = []
        dials: List[int] = []
        for p in ps:
            t = splitting_type(coeffs, p)
            if t is None:
                continue
            types.append(t)
            dials.append(dial(p))
        info = mutual_information(dials, types)
        print(f"{poly_name:<16}{group_name:<5}{len(types):>9}{entropy(types):>10.5f}"
              f"{info:>12.5f}{law:>10.5f}{abs(info - law):>9.5f}")
    print("\nThe measured channels of honest primes sit on the group-theoretic law to")
    print("within finite-sample noise; the residue dial never learns more about the")
    print("factorization shape than the abelianization coset already knows.\n")


# ---------------------------------------------------------------------------
# 6. Structural phenomena: the cap, the reversal, and perfect-group flatness
# ---------------------------------------------------------------------------

def structural_phenomena() -> None:
    print("=" * 88)
    print("(4) STRUCTURAL PHENOMENA")
    print("=" * 88)

    # The S4 cap: five types, more than two bits of type entropy, exactly one bit out.
    types_s4 = [cycle_type(g) for g in S4]
    coset_s4 = coset_readout(S4, derived_subgroup(S4))
    i_s4 = mutual_information([coset_s4(g) for g in S4], types_s4)
    print(f"S4: {len(set(types_s4))} distinct splitting types, H(T) = {entropy(types_s4):.5f} bits,")
    print(f"    channel = {i_s4:.5f} bit.  The cap log2 [S4 : A4] = 1 is a statement about the")
    print("    abelianization, not about the number of types.")

    # The reversal.
    i_v4 = mutual_information([coset_readout(V4, derived_subgroup(V4))(g) for g in V4],
                              [cycle_type(g) for g in V4])
    i_d4 = mutual_information([coset_readout(D4, derived_subgroup(D4))(g) for g in D4],
                              [cycle_type(g) for g in D4])
    print(f"\nReversal: abelian V4 channel = {i_v4:.5f} < non-abelian D4 channel = {i_d4:.5f},")
    print("    both under the same two-bit cap.  Richness is decided by how well the readout")
    print("    separates cosets, not by whether the group is abelian.")
    assert i_v4 < i_d4

    # Completeness criterion, field by field.
    print("\nCompleteness criterion (channel attains the cap iff the type determines the coset):")
    for poly, name, group in FIELDS:
        coset = coset_readout(group, derived_subgroup(group))
        determines = True
        by_type: Dict[Tuple[int, ...], int] = {}
        for g in group:
            t = cycle_type(g)
            if t in by_type and by_type[t] != coset(g):
                determines = False
            by_type.setdefault(t, coset(g))
        dial = log2(len(group) // len(derived_subgroup(group)))
        info = mutual_information([coset(g) for g in group], [cycle_type(g) for g in group])
        complete = abs(info - dial) < 1e-12
        assert determines == complete
        print(f"    {name:<3} type determines coset: {str(determines):<5}  "
              f"channel attains cap: {str(complete):<5}  loss = {dial - info:.5f}")

    # Perfect group flatness: A5.
    A5 = [g for g in (tuple(p) for p in permutations(range(5))) if sign(g) == 1]
    derived_a5 = derived_subgroup(A5)
    coset_a5 = coset_readout(A5, derived_a5)
    i_a5 = mutual_information([coset_a5(g) for g in A5], [cycle_type(g) for g in A5])
    print(f"\nPerfect group: |A5| = {len(A5)}, |[A5, A5]| = {len(derived_a5)}, so the coset readout")
    print(f"    is constant and the channel is exactly {i_a5:.5f} bits: an A5 field's splitting")
    print("    statistics are statistically independent of every residue dial.")
    assert abs(i_a5) < 1e-12


def main() -> None:
    prime_level_table()
    semiprime_table()
    empirical_channels()
    structural_phenomena()
    print("=" * 88)
    print("All assertions passed.")
    print("=" * 88)


if __name__ == "__main__":
    main()
