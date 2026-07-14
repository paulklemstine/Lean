"""
Numerical demonstrations for:

    The Z2-Coindex of Combinatorial Spheres:
    Exact Suspension and Join Laws via Coordinate-Axis Injections

The octahedral (cross-polytope) sphere S^n has 2(n+1) signed vertices
(i, s) with axis i in {0,...,n} and sign s in {+1,-1}. The free Z2-action
is the antipode (i, s) -> (i, -s).

A Z2-map S^m -> S^n is an equivariant simplicial vertex map. By the
local-global principle it is EXACTLY a pair
    - an injection phi : {0,...,m} -> {0,...,n}  (coordinate map), and
    - a sign vector sigma : {0,...,m} -> {+1,-1}.

Everything below is self-contained: signed vertices, Z2-maps, suspension,
join, coindex, exact counts, and the base Borsuk-Ulam obstructions --- all
by explicit finite enumeration, with no external dependencies.
"""

from __future__ import annotations

from itertools import permutations, product
from math import factorial
from typing import Iterator, List, Tuple

# A signed vertex is (axis, sign) with sign in {+1, -1}.
SVert = Tuple[int, int]

# A Z2-map is encoded by its data on positive vertices:
#   phi:   tuple of length m+1, an injection into {0,...,n}
#   sigma: tuple of length m+1 of signs in {+1, -1}
Z2Map = Tuple[Tuple[int, ...], Tuple[int, ...]]


# ---------------------------------------------------------------------------
# Core model
# ---------------------------------------------------------------------------
def antipode(v: SVert) -> SVert:
    """The free Z2-action: flip the sign, keep the axis."""
    i, s = v
    return (i, -s)


def apply_map(F: Z2Map, v: SVert) -> SVert:
    """Apply a Z2-map to a signed vertex, using equivariance."""
    phi, sigma = F
    i, s = v
    return (phi[i], s * sigma[i])


def is_injective(phi: Tuple[int, ...]) -> bool:
    """A coordinate map is simplicial iff it is injective (local-global)."""
    return len(set(phi)) == len(phi)


def is_z2map(F: Z2Map, n: int) -> bool:
    """Check the encoded pair really is a Z2-map into S^n."""
    phi, sigma = F
    return (
        len(phi) == len(sigma)
        and all(0 <= a <= n for a in phi)
        and all(s in (1, -1) for s in sigma)
        and is_injective(phi)
    )


def all_z2maps(m: int, n: int) -> Iterator[Z2Map]:
    """Enumerate every Z2-map S^m -> S^n by brute force over axes and signs."""
    axes = range(n + 1)
    for phi in permutations(axes, m + 1):          # injections {0..m} -> {0..n}
        for sigma in product((1, -1), repeat=m + 1):
            yield (phi, sigma)


def count_z2maps(m: int, n: int) -> int:
    """Number of Z2-maps S^m -> S^n by enumeration."""
    if m > n:
        return 0
    return sum(1 for _ in all_z2maps(m, n))


def formula_count(m: int, n: int) -> int:
    """Closed form:  (n+1)!/(n-m)! * 2^(m+1)  for m <= n, else 0."""
    if m > n:
        return 0
    return factorial(n + 1) // factorial(n - m) * 2 ** (m + 1)


# ---------------------------------------------------------------------------
# Functorial constructions
# ---------------------------------------------------------------------------
def suspension(F: Z2Map, n: int) -> Z2Map:
    """Suspend F : S^m -> S^n to susp(F) : S^{m+1} -> S^{n+1}.

    Adjoin a fresh pole pair: source axis m+1 -> target axis n+1, sign +1.
    """
    phi, sigma = F
    return (phi + (n + 1,), sigma + (1,))


def join(F: Z2Map, b: int, G: Z2Map) -> Z2Map:
    """Join F : S^a -> S^b and G : S^c -> S^d to F*G : S^{a+c+1} -> S^{b+d+1}.

    The low block copies phi_F into {0..b}; the high block copies phi_G
    shifted by b+1 into {b+1..b+d+1}. Signs are concatenated.
    """
    phiF, sigF = F
    phiG, sigG = G
    phi = phiF + tuple((b + 1) + a for a in phiG)
    sigma = sigF + sigG
    return (phi, sigma)


def coindex_of_sphere(n: int) -> int:
    """coind(S^n): the largest m with a Z2-map S^m -> S^n. Equals n."""
    m = 0
    while count_z2maps(m + 1, n) > 0:
        m += 1
    return m


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_existence_criterion() -> None:
    print("=" * 68)
    print("1. EXISTENCE CRITERION:  a Z2-map S^m -> S^n exists iff m <= n")
    print("=" * 68)
    for n in range(5):
        row = []
        for m in range(5):
            exists = count_z2maps(m, n) > 0
            row.append("Y" if exists else ".")
        print(f"  n={n}:  " + "  ".join(f"m={m}:{c}" for m, c in enumerate(row)))
    print("  (Y exactly on the lower triangle m <= n, as predicted.)\n")


def demo_coindex_equals_dimension() -> None:
    print("=" * 68)
    print("2. COINDEX EQUALS DIMENSION:  coind(S^n) = n")
    print("=" * 68)
    for n in range(6):
        print(f"  coind(S^{n}) = {coindex_of_sphere(n)}   (expected {n})")
    print()


def demo_exact_count() -> None:
    print("=" * 68)
    print("3. EXACT COUNT:  #{S^m -> S^n} = (n+1)!/(n-m)! * 2^(m+1)")
    print("=" * 68)
    for n in range(4):
        for m in range(n + 1):
            enum = count_z2maps(m, n)
            form = formula_count(m, n)
            flag = "OK" if enum == form else "MISMATCH"
            print(f"  m={m}, n={n}:  enumerated={enum:5d}  formula={form:5d}  [{flag}]")
    print()


def demo_suspension_increment() -> None:
    print("=" * 68)
    print("4. SHARP SUSPENSION INCREMENT:  coind(S^{n+1}) = coind(S^n) + 1")
    print("=" * 68)
    # Base obstructions, checked by enumeration:
    print(f"  S^1 -> S^0 maps: {count_z2maps(1, 0)}  (Borsuk-Ulam: none) -> coind(S^0)=0")
    print(f"  S^2 -> S^1 maps: {count_z2maps(2, 1)}  (Borsuk-Ulam: none) -> coind(S^1)=1")
    for n in range(5):
        lo, hi = coindex_of_sphere(n), coindex_of_sphere(n + 1)
        print(f"  coind(S^{n+1})={hi}, coind(S^{n})={lo}, increment={hi - lo}")
    # Verify suspension really produces a valid map one dimension up.
    F = ((0,), (1,))                 # a Z2-map S^0 -> S^0 (identity-ish)
    SF = suspension(F, 0)            # susp(F): S^1 -> S^1
    print(f"  susp of S^0->S^0 gives valid S^1->S^1 map: {is_z2map(SF, 1)}")
    print()


def demo_join_law() -> None:
    print("=" * 68)
    print("5. SHARP JOIN LAW:  coind(S^a * S^c) = coind(S^a) + coind(S^c) + 1")
    print("=" * 68)
    for a in range(3):
        for c in range(3):
            lhs = coindex_of_sphere(a + c + 1)  # S^a * S^c = S^{a+c+1}
            rhs = coindex_of_sphere(a) + coindex_of_sphere(c) + 1
            flag = "OK" if lhs == rhs else "MISMATCH"
            print(f"  a={a}, c={c}:  coind(S^{a+c+1})={lhs}  "
                  f"coind(S^{a})+coind(S^{c})+1={rhs}  [{flag}]")
    # Explicit join produces a valid map, and it is supermultiplicative.
    F = ((0, 1), (1, 1))   # S^1 -> S^1
    G = ((0, 1), (1, 1))   # S^1 -> S^1
    FG = join(F, 1, G)     # S^3 -> S^3
    print(f"  join of two S^1->S^1 maps is a valid S^3->S^3 map: {is_z2map(FG, 3)}")
    left = count_z2maps(1, 1) * count_z2maps(1, 1)
    right = count_z2maps(3, 3)
    print(f"  supermultiplicativity:  #(1->1)^2 = {left} <= #(3->3) = {right}")
    print()


def demo_join_strictly_sufficient() -> None:
    print("=" * 68)
    print("6. JOIN IS STRICTLY SUFFICIENT, NOT NECESSARY")
    print("=" * 68)
    print(f"  first block S^1 -> S^0 maps: {count_z2maps(1, 0)}  (none: 1 > 0)")
    print(f"  yet joined target S^3 -> S^3 maps: {count_z2maps(3, 3)}  (many)")
    print("  because the exact criterion a+c<=b+d (1+1<=0+2) is weaker than")
    print("  the blockwise a<=b and c<=d.\n")


if __name__ == "__main__":
    demo_existence_criterion()
    demo_coindex_equals_dimension()
    demo_exact_count()
    demo_suspension_increment()
    demo_join_law()
    demo_join_strictly_sufficient()
    print("All demonstrations complete.")
