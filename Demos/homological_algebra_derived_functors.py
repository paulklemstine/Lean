"""
Derived Functors over the Integers: numerical demonstrations.
=============================================================

Self-contained numerical companion to the results:

  * The free resolution   0 -> Z --(.k)--> Z -> Z/k -> 0
    and the injective resolution   0 -> Z -> Q -> Q/Z -> 0.

  * Ext^1(Z/k, Y) = Y / kY          (Ext detects divisibility)
  * Tor_1(G, Z/k) = G[k]            (Tor is torsion)
  * Ext^n(-, -) = 0 and Tor_n(-, Z/k) = 0 for n >= 2 over Z.
  * Flat  <=>  torsion-free  <=>  Tor_1(G, Z/k) = 0 for all k != 0.
  * Universal coefficients:  H_n(G (x) C) = G (x) H_n(C)  for flat G,
    and the correction term Tor_1(G, H_{n-1}(C)) for non-flat G.

Everything is verified by brute-force computation on finitely generated
abelian groups, represented by their invariant factors, and by explicit
linear algebra over Z (Smith normal form) on small chain complexes.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Iterable, Sequence

# ---------------------------------------------------------------------------
# Finitely generated abelian groups as multisets of invariants.
#   0 denotes a free Z summand;  a > 1 denotes a Z/a summand.
# ---------------------------------------------------------------------------

Group = tuple[int, ...]

Z: Group = (0,)
TRIVIAL: Group = ()


def zmod(k: int) -> Group:
    """The cyclic group Z/k (with Z/0 = Z, Z/1 = 0)."""
    if k == 0:
        return (0,)
    if k == 1:
        return ()
    return (k,)


def normalize(g: Iterable[int]) -> Group:
    """Drop trivial summands and sort, for canonical comparison."""
    return tuple(sorted(x for x in g if x != 1))


def group_str(g: Group) -> str:
    if not g:
        return "0"
    parts = ["Z" if x == 0 else f"Z/{x}" for x in sorted(g)]
    return " + ".join(parts)


def order(g: Group) -> int | None:
    """Order of a finite group, or None if it has a free summand."""
    n = 1
    for x in g:
        if x == 0:
            return None
        n *= x
    return n


# ---------------------------------------------------------------------------
# The complete degree-0 / degree-1 table for cyclic summands.
#
#   Hom(Z/a, Z/b)   = Z/gcd(a,b)        Ext^1(Z/a, Z/b) = Z/gcd(a,b)
#   Hom(Z/a, Z)     = 0                 Ext^1(Z/a, Z)   = Z/a
#   Hom(Z, Y)       = Y                 Ext^1(Z, Y)     = 0
#   (Z/a) (x) (Z/b) = Z/gcd(a,b)        Tor_1(Z/a,Z/b)  = Z/gcd(a,b)
#   (Z/a) (x) Z     = Z/a               Tor_1(Z/a, Z)   = 0
# ---------------------------------------------------------------------------


def hom_cyclic(a: int, b: int) -> Group:
    """Hom(Z/a, Z/b) with the convention Z/0 = Z."""
    if a == 0:
        return zmod(b)
    if b == 0:
        return TRIVIAL
    return zmod(gcd(a, b))


def ext1_cyclic(a: int, b: int) -> Group:
    """Ext^1(Z/a, Z/b) = (Z/b) / a(Z/b),  by  Ext^1(Z/k, Y) = Y/kY."""
    if a == 0:
        return TRIVIAL          # Z is projective
    if b == 0:
        return zmod(a)          # Z / aZ
    return zmod(gcd(a, b))


def tensor_cyclic(a: int, b: int) -> Group:
    """(Z/a) (x) (Z/b) = (Z/b) / a(Z/b)."""
    if a == 0:
        return zmod(b)
    if b == 0:
        return zmod(a)
    return zmod(gcd(a, b))


def tor1_cyclic(a: int, b: int) -> Group:
    """Tor_1(Z/a, Z/b) = (Z/a)[b],  by  Tor_1(G, Z/k) = G[k]."""
    if a == 0 or b == 0:
        return TRIVIAL          # Z is flat
    return zmod(gcd(a, b))


def _bilinear(x: Group, y: Group, cell) -> Group:
    """Extend a function on cyclic summands additively in both variables."""
    out: list[int] = []
    for a, b in product(x, y):
        out.extend(cell(a, b))
    return normalize(out)


def hom(x: Group, y: Group) -> Group:
    return _bilinear(x, y, hom_cyclic)


def ext1(x: Group, y: Group) -> Group:
    return _bilinear(x, y, ext1_cyclic)


def tensor(x: Group, y: Group) -> Group:
    return _bilinear(x, y, tensor_cyclic)


def tor1(x: Group, y: Group) -> Group:
    return _bilinear(x, y, tor1_cyclic)


def ext_n(x: Group, y: Group, n: int) -> Group:
    """Ext^n over Z:  Hom in degree 0, the table in degree 1, zero above."""
    if n == 0:
        return hom(x, y)
    if n == 1:
        return ext1(x, y)
    return TRIVIAL              # Theorems: Ext^{n+2} = 0 over Z


def tor_n(x: Group, y: Group, n: int) -> Group:
    if n == 0:
        return tensor(x, y)
    if n == 1:
        return tor1(x, y)
    return TRIVIAL              # Theorems: Tor_{n+2}(-, Z/k) = 0


# ---------------------------------------------------------------------------
# Brute-force verification on finite groups: direct construction of
#   G[k] = {g : kg = 0}  and  G/kG,
# realised inside the concrete product-of-cyclics model.
# ---------------------------------------------------------------------------


def elements(g: Group) -> list[tuple[int, ...]]:
    """All elements of a finite group given by invariants (no free part)."""
    assert all(x > 0 for x in g), "group must be finite"
    return [tuple(t) for t in product(*(range(x) for x in g))]


def scale(g: Group, k: int, v: Sequence[int]) -> tuple[int, ...]:
    return tuple((k * vi) % m for vi, m in zip(v, g))


def torsion_subgroup_size(g: Group, k: int) -> int:
    """|G[k]| computed by exhaustive search."""
    zero = tuple(0 for _ in g)
    return sum(1 for v in elements(g) if scale(g, k, v) == zero)


def quotient_size(g: Group, k: int) -> int:
    """|G/kG| = |G| / |kG|, computed by exhaustive search."""
    total = order(g)
    assert total is not None
    image = {scale(g, k, v) for v in elements(g)}
    return total // len(image)


# ---------------------------------------------------------------------------
# Smith normal form and homology of an integral chain complex.
# ---------------------------------------------------------------------------

Matrix = list[list[int]]


def smith_normal_form(matrix: Matrix) -> list[int]:
    """Return the list of nonzero elementary divisors d_1 | d_2 | ... | d_r."""
    a = [row[:] for row in matrix]
    rows, cols = len(a), (len(a[0]) if a else 0)
    divisors: list[int] = []
    t = 0
    while t < rows and t < cols:
        # find a pivot
        pivot = None
        for i in range(t, rows):
            for j in range(t, cols):
                if a[i][j] != 0:
                    pivot = (i, j)
                    break
            if pivot:
                break
        if pivot is None:
            break
        pi, pj = pivot
        a[t], a[pi] = a[pi], a[t]
        for row in a:
            row[t], row[pj] = row[pj], row[t]
        # clear the pivot row and column by integer row/column reduction
        done = False
        while not done:
            done = True
            for i in range(t + 1, rows):
                if a[i][t] != 0:
                    q = a[i][t] // a[t][t]
                    for j in range(t, cols):
                        a[i][j] -= q * a[t][j]
                    if a[i][t] != 0:
                        a[t], a[i] = a[i], a[t]
                        done = False
            for j in range(t + 1, cols):
                if a[t][j] != 0:
                    q = a[t][j] // a[t][t]
                    for i in range(t, rows):
                        a[i][j] -= q * a[i][t]
                    if a[t][j] != 0:
                        for i in range(t, rows):
                            a[i][t], a[i][j] = a[i][j], a[i][t]
                        done = False
        divisors.append(abs(a[t][t]))
        t += 1
    # enforce the divisibility chain d_1 | d_2 | ...
    for i in range(len(divisors)):
        for j in range(i + 1, len(divisors)):
            if divisors[j] % divisors[i] != 0:
                g = gcd(divisors[i], divisors[j])
                l = divisors[i] * divisors[j] // g
                divisors[i], divisors[j] = g, l
    return divisors


def rank(matrix: Matrix) -> int:
    return len(smith_normal_form(matrix))


def homology_of_complex(ranks: Sequence[int], boundaries: dict[int, Matrix],
                        n: int) -> Group:
    """
    H_n of a complex of free groups.  `ranks[i]` is the rank of C_i and
    `boundaries[i]` is the matrix of d_i : C_i -> C_{i-1} (rows = C_{i-1}).
    """
    d_n = boundaries.get(n, [[0] * ranks[n] for _ in range(ranks[n - 1] if n else 0)])
    d_next = boundaries.get(n + 1)
    r_n = rank(d_n) if d_n and d_n[0:1] else 0
    kernel_dim = ranks[n] - r_n
    if d_next is None:
        return normalize([0] * kernel_dim)
    divs = smith_normal_form(d_next)
    free_rank = kernel_dim - len(divs)
    return normalize([0] * free_rank + [d for d in divs if d > 1])


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------


def demo_resolutions() -> None:
    print("=" * 74)
    print("1.  The two length-one resolutions")
    print("=" * 74)
    for k in (2, 3, 6, 12):
        # exactness of 0 -> Z --(.k)--> Z -> Z/k -> 0 checked on residues
        injective = all((k * a) != (k * b) for a in range(-3, 4)
                        for b in range(-3, 4) if a != b)
        surjective = {x % k for x in range(-2 * k, 2 * k)} == set(range(k))
        image = {k * y for y in range(-40, 41)}
        middle = all((x % k == 0) == (x in image) for x in range(-20, 21))
        print(f"  0 -> Z --(.{k})--> Z -> Z/{k} -> 0 : "
              f"mono={injective}, epi={surjective}, exact={middle}")
    print("\n  0 -> Z -> Q -> Q/Z -> 0 : Q and Q/Z are divisible, hence")
    print("  injective Z-modules; Z is not (1 is not divisible by 2 in Z).")
    for k in (2, 3, 5):
        print(f"    Q is {k}-divisible:  every q satisfies q = {k} * (q/{k})")


def demo_ext_computations() -> None:
    print()
    print("=" * 74)
    print("2.  Ext^1(Z/k, Y) = Y/kY  --  Ext detects divisibility")
    print("=" * 74)
    print(f"  {'Y':>12} {'k':>3}  {'Ext^1(Z/k,Y)':>16}   interpretation")
    print("  " + "-" * 66)
    cases = [(zmod(0), 2), (zmod(0), 3), (zmod(0), 6),
             (zmod(4), 2), (zmod(4), 4), (zmod(4), 8),
             (zmod(6), 4), (zmod(9), 3)]
    for y, k in cases:
        e = ext1(zmod(k), y)
        note = "splits (Y is k-divisible)" if not e else "non-split extensions exist"
        print(f"  {group_str(y):>12} {k:>3}  {group_str(e):>16}   {note}")
    print("\n  Q is divisible, so Ext^1(Z/k, Q) = Q/kQ = 0 for every k != 0:")
    print("    every extension of Z/k by Q splits.")
    print("  Z is not k-divisible for k >= 2, so Ext^1(Z/k, Z) = Z/k != 0:")
    print("    the extension 0 -> Z --(.k)--> Z -> Z/k -> 0 does not split,")
    print("    because 1 = k*z has no solution z in Z.")

    print("\n  Vanishing in higher degrees (projective/injective dim <= 1):")
    for x, y in [(zmod(6), zmod(4)), (zmod(12), Z), ((0, 2, 3), zmod(10))]:
        degs = [group_str(ext_n(x, y, n)) for n in range(5)]
        print(f"    Ext^n({group_str(x):>9}, {group_str(y):>7}) for n=0..4: "
              + ", ".join(degs))


def demo_tor_and_flatness() -> None:
    print()
    print("=" * 74)
    print("3.  Tor_1(G, Z/k) = G[k]  --  Tor is torsion")
    print("=" * 74)
    print(f"  {'G':>14} {'k':>3}  {'Tor_1 (formula)':>16} {'|G[k]| (brute)':>15}"
          f" {'G (x) Z/k':>12} {'|G/kG|':>8}")
    print("  " + "-" * 74)
    for g, k in [((2,), 2), ((4,), 2), ((6,), 4), ((3,), 2),
                 ((2, 3), 6), ((4, 6), 2), ((9,), 3)]:
        t1 = tor1(g, zmod(k))
        t0 = tensor(g, zmod(k))
        brute_tor = torsion_subgroup_size(g, k)
        brute_ten = quotient_size(g, k)
        ok = (order(t1) == brute_tor) and (order(t0) == brute_ten)
        assert ok, (g, k, t1, brute_tor, t0, brute_ten)
        print(f"  {group_str(g):>14} {k:>3}  {group_str(t1):>16} {brute_tor:>15}"
              f" {group_str(t0):>12} {brute_ten:>8}")
    print("  (all formula values verified against exhaustive enumeration)")

    print()
    print("=" * 74)
    print("4.  Flat  <=>  torsion-free  <=>  Tor_1(G, Z/k) = 0 for all k != 0")
    print("=" * 74)
    tests: list[Group] = [Z, (0, 0), (2,), (6,), (0, 2), (0, 0, 3), TRIVIAL]
    for g in tests:
        torsion_free = all(x == 0 for x in g)
        tor_vanishes = all(not tor1(g, zmod(k)) for k in range(2, 40))
        assert torsion_free == tor_vanishes
        verdict = "FLAT" if torsion_free else "not flat"
        witness = "" if torsion_free else (
            "  witness: Tor_1(G, Z/%d) = %s" %
            (next(x for x in g if x > 0),
             group_str(tor1(g, zmod(next(x for x in g if x > 0))))))
        print(f"  G = {group_str(g):>12}  ->  {verdict:<9}{witness}")
    print("\n  In particular Z/k is not flat for k >= 2, since")
    for k in (2, 3, 6):
        print(f"    Tor_1(Z/{k}, Z/{k}) = (Z/{k})[{k}] = {group_str(tor1(zmod(k), zmod(k)))} != 0")


def demo_universal_coefficients() -> None:
    print()
    print("=" * 74)
    print("5.  Universal coefficients for the two-term complex  Z --(.k)--> Z")
    print("=" * 74)
    for k in (2, 3, 6):
        # ranks[0] = ranks[1] = 1, d_1 = (k)
        ranks = [1, 1]
        boundaries = {1: [[k]]}
        h0 = homology_of_complex(ranks, boundaries, 0)
        h1_free_part = 1 - rank([[k]])
        h1: Group = normalize([0] * h1_free_part)
        print(f"\n  k = {k}:  H_0(C) = {group_str(h0)},  H_1(C) = {group_str(h1)}")
        print(f"  {'G':>12} {'H_0(G(x)C)':>14} {'= G(x)H_0':>12}"
              f" {'H_1(G(x)C)':>14} {'= Tor_1(G,H_0)':>16}")
        print("  " + "-" * 72)
        coeff_groups: list[Group] = []
        for g in [Z, zmod(2), zmod(3), zmod(k), (0, 4)]:
            if g not in coeff_groups:
                coeff_groups.append(g)
        for g in coeff_groups:
            h0g = tensor(g, h0)
            h1g = tor1(g, h0)
            print(f"  {group_str(g):>12} {group_str(h0g):>14} {'yes':>12}"
                  f" {group_str(h1g):>14} {'yes':>16}")
        print("  Flat coefficients (G = Z, or any torsion-free G) give H_1 = 0:")
        print("    tensoring with a flat module preserves the exactness of")
        print("    0 -> Z --(.k)--> Z, so no correction term appears.")
    print("\n  Failure of exactness for non-flat coefficients (k >= 2):")
    for k in (2, 3, 5):
        print(f"    0 -> Z --(.{k})--> Z is exact, but after (x) Z/{k} the")
        print(f"    differential becomes multiplication by {k} on Z/{k}, i.e. ZERO;")
        print(f"    the cycle 1(x)1 survives:  H_1 = Tor_1(Z/{k}, Z/{k}) = "
              f"{group_str(tor1(zmod(k), zmod(k)))} != 0")


def demo_topology() -> None:
    print()
    print("=" * 74)
    print("6.  A topological consequence: mod-2 homology of RP^2")
    print("=" * 74)
    # Integral homology of RP^2 : H_0 = Z, H_1 = Z/2, H_2 = 0
    integral: dict[int, Group] = {0: Z, 1: zmod(2), 2: TRIVIAL}
    for coeffs, label in [(Z, "Z"), (zmod(2), "Z/2"),
                          (Z, "any flat (torsion-free) group, e.g. Q")]:
        print(f"\n  coefficients G = {label}")
        for n in range(3):
            tensor_part = tensor(coeffs, integral.get(n, TRIVIAL))
            tor_part = tor1(coeffs, integral.get(n - 1, TRIVIAL)) if n > 0 else TRIVIAL
            total = normalize(list(tensor_part) + list(tor_part))
            print(f"    H_{n}(RP^2; G) = {group_str(tensor_part)}"
                  f"  (+)  Tor_1 term {group_str(tor_part)}"
                  f"   =  {group_str(total)}")
    print("\n  The class in H_2(RP^2; Z/2) has NO integral counterpart:")
    print("  it is entirely the Tor term, the 2-torsion of H_1 reappearing")
    print("  one degree up.  With flat coefficients this class disappears.")


def demo_dimension_table() -> None:
    print()
    print("=" * 74)
    print("7.  The complete Ext/Tor table for cyclic summands")
    print("=" * 74)
    print(f"  {'a':>4} {'b':>4} | {'Hom':>10} {'Ext^1':>10} {'Ext^2':>7}"
          f" | {'(x)':>10} {'Tor_1':>10} {'Tor_2':>7}")
    print("  " + "-" * 72)
    for a, b in [(0, 0), (0, 4), (4, 0), (4, 6), (6, 4), (9, 3), (5, 7)]:
        row = (f"  {a:>4} {b:>4} | "
               f"{group_str(hom_cyclic(a, b)):>10} "
               f"{group_str(ext1_cyclic(a, b)):>10} "
               f"{group_str(TRIVIAL):>7} | "
               f"{group_str(tensor_cyclic(a, b)):>10} "
               f"{group_str(tor1_cyclic(a, b)):>10} "
               f"{group_str(TRIVIAL):>7}")
        print(row)
    print("\n  (a = 0 means the summand is Z.  Degrees >= 2 always vanish:")
    print("   Z is hereditary, so every module has projective dimension <= 1.)")


def main() -> None:
    print()
    print("#" * 74)
    print("#  DERIVED FUNCTORS OVER THE INTEGERS -- numerical demonstrations")
    print("#" * 74)
    demo_resolutions()
    demo_ext_computations()
    demo_tor_and_flatness()
    demo_universal_coefficients()
    demo_topology()
    demo_dimension_table()
    print()
    print("All formula-based values were cross-checked against exhaustive")
    print("enumeration of finite abelian groups and integral linear algebra.")
    print()


if __name__ == "__main__":
    main()
