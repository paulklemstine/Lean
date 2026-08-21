"""
Codiscrete bicategories of unital magmas and the associativity defect
=====================================================================

Self-contained numerical demonstration of the results of the accompanying paper.

A *pointed magma* is a finite set M = {0, 1, ..., n-1} with an arbitrary binary
operation, represented here as an n x n table `T` with `a * b = T[a][b]`, and a
distinguished element `1` (we always use the index 0).  No axioms are assumed.

Two families of results are demonstrated.

(1) The codiscrete bicategory B(M).  One object; the 1-cells are the elements of
    M with horizontal composition `*` and identity 1-cell `0`; between any two
    1-cells there is exactly one 2-cell.  Coherence (pentagon, triangle,
    naturality) is automatic because the hom-category is thin, and every 2-cell
    is invertible.  B(M) is strict iff M is a monoid; a 1-cell is *strictly*
    invertible iff the element has a two-sided inverse.

(2) The associativity defect D(M) = #{(a,b,c) : (a*b)*c != a*(b*c)}.
    - D(M) equals the number of non-identity associator instances of B(M);
    - A(M) = n^3 - D(M) is multiplicative under products;
    - D is invariant under isomorphism, reversal, and free unitalisation;
    - D is even for commutative magmas;
    - D <= (n-1)^3 for unital magmas, attained by shift magmas;
    - D <= (n-1)^3 - (n-1)^2 for commutative unital magmas, attained by
      negation magmas of 2-torsion-free abelian groups.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Sequence, Tuple

Table = List[List[int]]
Triple = Tuple[int, int, int]

UNIT = 0  # the distinguished element `1` of a pointed magma is always index 0


# ----------------------------------------------------------------------------
# Basic magma utilities
# ----------------------------------------------------------------------------

def order(table: Table) -> int:
    """Number of elements of the magma."""
    return len(table)


def mul(table: Table, a: int, b: int) -> int:
    """The product a * b."""
    return table[a][b]


def defect_set(table: Table) -> List[Triple]:
    """All triples (a,b,c) with (a*b)*c != a*(b*c)."""
    n = order(table)
    return [
        (a, b, c)
        for a in range(n)
        for b in range(n)
        for c in range(n)
        if table[table[a][b]][c] != table[a][table[b][c]]
    ]


def defect(table: Table) -> int:
    """The associativity defect D(M) = |defect_set(M)|.  Cost: Theta(n^3)."""
    n = order(table)
    count = 0
    for a in range(n):
        row_a = table[a]
        for b in range(n):
            ab = row_a[b]
            for c in range(n):
                if table[ab][c] != row_a[table[b][c]]:
                    count += 1
    return count


def assoc_count(table: Table) -> int:
    """A(M) = n^3 - D(M): the number of associative triples."""
    return order(table) ** 3 - defect(table)


def is_commutative(table: Table) -> bool:
    n = order(table)
    return all(table[a][b] == table[b][a] for a in range(n) for b in range(n))


def is_unital(table: Table, unit: int = UNIT) -> bool:
    n = order(table)
    return all(table[unit][a] == a and table[a][unit] == a for a in range(n))


def is_monoid(table: Table, unit: int = UNIT) -> bool:
    return is_unital(table, unit) and defect(table) == 0


# ----------------------------------------------------------------------------
# The codiscrete bicategory B(M)
# ----------------------------------------------------------------------------

def two_cell_count(table: Table) -> int:
    """Number of 2-cells of B(M): exactly one per ordered pair of 1-cells."""
    n = order(table)
    return n * n


def all_two_cells_invertible(table: Table) -> bool:
    """Every 2-cell of a codiscrete hom-category is invertible, unconditionally."""
    return True


def parallel_two_cells_agree(table: Table) -> bool:
    """Any two parallel 2-cells agree: the hom-category is thin."""
    return True


def nonidentity_associators(table: Table) -> List[Triple]:
    """Triples where the associator connects two *distinct* 1-cells.

    By the bridge theorem this list is exactly the defect set.
    """
    return defect_set(table)


def unit_defects(table: Table, unit: int = UNIT) -> Tuple[List[int], List[int]]:
    """Elements where the left / right unitor connects distinct 1-cells."""
    n = order(table)
    left = [a for a in range(n) if table[unit][a] != a]
    right = [a for a in range(n) if table[a][unit] != a]
    return left, right


def is_strict(table: Table, unit: int = UNIT) -> bool:
    """B(M) is strict iff M is a monoid (strictness criterion)."""
    return is_monoid(table, unit)


def strictly_invertible_elements(table: Table, unit: int = UNIT) -> List[int]:
    """Elements a admitting b with a*b = 1 = b*a.

    These name exactly the strictly invertible 1-cells of B(M).
    """
    n = order(table)
    return [
        a
        for a in range(n)
        if any(table[a][b] == unit and table[b][a] == unit for b in range(n))
    ]


def induced_pseudofunctor_is_strict(src: Table, tgt: Table, f: Sequence[int]) -> bool:
    """Any map f : M -> N induces a pseudofunctor B(M) -> B(N).

    It is *strictly* multiplicative on 1-cells iff f is a magma homomorphism.
    """
    n = order(src)
    return all(f[src[a][b]] == tgt[f[a]][f[b]] for a in range(n) for b in range(n))


# ----------------------------------------------------------------------------
# Constructions
# ----------------------------------------------------------------------------

def shift_magma(sigma: Sequence[int]) -> Table:
    """Shift magma of a self-map sigma of S = {1,...,m} (0-indexed internally).

    `sigma` is given as a list of length m with entries in {0,...,m-1}
    describing a self-map of S; the resulting magma has n = m+1 elements with
    index 0 the unit, and  a*b = sigma(b)  for non-units a, b.
    """
    m = len(sigma)
    n = m + 1
    table = [[0] * n for _ in range(n)]
    for a in range(n):
        table[UNIT][a] = a
        table[a][UNIT] = a
    for a in range(1, n):
        for b in range(1, n):
            table[a][b] = sigma[b - 1] + 1
    return table


def cyclic_shift(m: int) -> List[int]:
    """The fixed-point-free cyclic self-map i -> i+1 mod m (needs m >= 2)."""
    return [(i + 1) % m for i in range(m)]


def negation_magma(m: int) -> Table:
    """Negation magma of Z/m: n = m+1 elements, unit 0, a*b = -(a+b) mod m.

    For odd m the group Z/m has no 2-torsion, and the magma is commutative,
    unital, and attains D = m^3 - m^2 = (n-1)^3 - (n-1)^2.
    """
    n = m + 1
    table = [[0] * n for _ in range(n)]
    for a in range(n):
        table[UNIT][a] = a
        table[a][UNIT] = a
    for a in range(1, n):
        for b in range(1, n):
            table[a][b] = ((-((a - 1) + (b - 1))) % m) + 1
    return table


def adjoin_one(table: Table) -> Table:
    """Freely adjoin a two-sided unit; the defect is unchanged."""
    n = order(table)
    out = [[0] * (n + 1) for _ in range(n + 1)]
    for a in range(n + 1):
        out[0][a] = a
        out[a][0] = a
    for a in range(n):
        for b in range(n):
            out[a + 1][b + 1] = table[a][b] + 1
    return out


def product_magma(t1: Table, t2: Table) -> Table:
    """Componentwise product magma, elements indexed by i*|t2| + j."""
    n1, n2 = order(t1), order(t2)
    n = n1 * n2
    out = [[0] * n for _ in range(n)]
    for a1 in range(n1):
        for a2 in range(n2):
            for b1 in range(n1):
                for b2 in range(n2):
                    out[a1 * n2 + a2][b1 * n2 + b2] = t1[a1][b1] * n2 + t2[a2][b2]
    return out


def opposite(table: Table) -> Table:
    """The opposite magma a *^op b = b * a."""
    n = order(table)
    return [[table[b][a] for b in range(n)] for a in range(n)]


def relabel(table: Table, perm: Sequence[int]) -> Table:
    """Transport the table along the bijection perm (an isomorphic copy)."""
    n = order(table)
    out = [[0] * n for _ in range(n)]
    for a in range(n):
        for b in range(n):
            out[perm[a]][perm[b]] = perm[table[a][b]]
    return out


def cyclic_group(m: int) -> Table:
    """The cyclic group Z/m as a monoid table (unit 0): a fully associative magma."""
    return [[(a + b) % m for b in range(m)] for a in range(m)]


def subtraction_magma(m: int) -> Table:
    """a * b = a - b on Z/m: unital on the right only, and highly non-associative."""
    return [[(a - b) % m for b in range(m)] for a in range(m)]


# ----------------------------------------------------------------------------
# Exhaustive enumeration of unital tables
# ----------------------------------------------------------------------------

def enumerate_unital_tables(n: int) -> Iterable[Table]:
    """All n^{(n-1)^2} unital multiplication tables on n labelled elements."""
    m = n - 1
    for vals in product(range(n), repeat=m * m):
        table = [[0] * n for _ in range(n)]
        for a in range(n):
            table[UNIT][a] = a
            table[a][UNIT] = a
        idx = 0
        for a in range(1, n):
            for b in range(1, n):
                table[a][b] = vals[idx]
                idx += 1
        yield table


def defect_distribution(n: int) -> Dict[int, int]:
    """Defect distribution over all unital tables of order n (feasible for n <= 4)."""
    dist: Dict[int, int] = {}
    for table in enumerate_unital_tables(n):
        d = defect(table)
        dist[d] = dist.get(d, 0) + 1
    return dist


def count_extremal(n: int) -> Tuple[int, int, int, int]:
    """(#maximisers, #commutative maximisers, #tables with D=1, #commutative with D=1)."""
    target = (n - 1) ** 3
    n_max = n_max_comm = n_one = n_one_comm = 0
    for table in enumerate_unital_tables(n):
        d = defect(table)
        if d == target:
            n_max += 1
            if is_commutative(table):
                n_max_comm += 1
        if d == 1:
            n_one += 1
            if is_commutative(table):
                n_one_comm += 1
    return n_max, n_max_comm, n_one, n_one_comm


def shift_maximisers(n: int) -> Tuple[int, int]:
    """(# maximisers of shift form a*b = sigma(b), # including mirrors a*b = sigma(a))."""
    m = n - 1
    plain, mirror = set(), set()
    for sig in product(range(n), repeat=m):
        smap = {i + 1: sig[i] for i in range(m)}
        if any(smap[x] == x for x in range(1, n)):
            continue
        plain.add(tuple(smap[b] for _ in range(1, n) for b in range(1, n)))
        mirror.add(tuple(smap[a] for a in range(1, n) for _ in range(1, n)))
    target = (n - 1) ** 3

    def realised(entries: Tuple[int, ...]) -> bool:
        table = [[0] * n for _ in range(n)]
        for a in range(n):
            table[UNIT][a] = a
            table[a][UNIT] = a
        idx = 0
        for a in range(1, n):
            for b in range(1, n):
                table[a][b] = entries[idx]
                idx += 1
        return defect(table) == target

    return (
        sum(1 for e in plain if realised(e)),
        sum(1 for e in plain | mirror if realised(e)),
    )


# ----------------------------------------------------------------------------
# Reporting
# ----------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 76)
    print(title)
    print("=" * 76)


def show_table(table: Table, name: str) -> None:
    n = order(table)
    labels = ["1"] + [chr(ord("a") + i) for i in range(n - 1)]
    print(f"\n{name}   (element 0 written '1' is the distinguished point)")
    print("     " + "  ".join(f"{labels[b]:>2}" for b in range(n)))
    for a in range(n):
        print(f"  {labels[a]:>2} " + "  ".join(f"{labels[table[a][b]]:>2}" for b in range(n)))


def demo_bicategory() -> None:
    banner("1.  The codiscrete bicategory of an arbitrary pointed magma")
    sigma = cyclic_shift(2)
    sh = shift_magma(sigma)
    show_table(sh, "Shift magma Sh(sigma), sigma = (a b) on {a,b}: order 3")
    d = defect(sh)
    print(f"\n  1-cells                        : {order(sh)}")
    print(f"  2-cells (one per ordered pair) : {two_cell_count(sh)}")
    print(f"  every 2-cell invertible        : {all_two_cells_invertible(sh)}")
    print(f"  parallel 2-cells agree         : {parallel_two_cells_agree(sh)}")
    print("  pentagon / triangle            : automatic (thin hom-category)")
    print(f"  unital                         : {is_unital(sh)}")
    print(f"  strict (i.e. M is a monoid)    : {is_strict(sh)}")
    print(f"  defect D(M)                    : {d}   (bound (n-1)^3 = {(order(sh)-1)**3})")
    print(f"  non-identity associators       : {len(nonidentity_associators(sh))}")
    print(f"  strictly invertible 1-cells    : {strictly_invertible_elements(sh)}"
          "   (only the unit: no element has a two-sided inverse)")
    left, right = unit_defects(sh)
    print(f"  left / right unit defects      : {left} / {right}")

    banner("2.  Strictness criterion:  B(M) strict  <=>  M is a monoid")
    z3 = cyclic_group(3)
    show_table(z3, "The cyclic group Z/3 as a monoid")
    print(f"\n  defect                      : {defect(z3)}")
    print(f"  strict                      : {is_strict(z3)}")
    print(f"  strictly invertible 1-cells : {strictly_invertible_elements(z3)}"
          "   (all of them: Z/3 is a group)")
    sub = subtraction_magma(4)
    show_table(sub, "Subtraction magma a*b = a-b on Z/4 (unital on the right only)")
    print(f"\n  defect                      : {defect(sub)} of {order(sub)**3} triples")
    print(f"  unital                      : {is_unital(sub)}")
    print(f"  strict                      : {is_strict(sub)}")
    lf, rt = unit_defects(sub)
    print(f"  left unit defects at        : {lf}")
    print(f"  right unit defects at       : {rt}")
    print("  ...yet B(M) is a perfectly coherent bicategory: all defects are")
    print("     repaired by unique invertible 2-cells.")

    banner("3.  Pseudofunctoriality of ARBITRARY maps")
    src, tgt = shift_magma(cyclic_shift(2)), cyclic_group(3)
    for f in [(0, 1, 2), (0, 0, 0), (1, 2, 0)]:
        strict = induced_pseudofunctor_is_strict(src, tgt, f)
        print(f"  map {f} : always induces a pseudofunctor;"
              f" strictly multiplicative = {strict}")
    print("  (strict multiplicativity holds exactly for magma homomorphisms)")


def demo_defect_theory() -> None:
    banner("4.  Sharp bound for unital magmas:  D <= (n-1)^3, attained by shift magmas")
    print(f"\n   {'n':>3} {'(n-1)^3':>9} {'D(Sh)':>7}  attained")
    for m in range(2, 8):
        sh = shift_magma(cyclic_shift(m))
        n = order(sh)
        print(f"   {n:>3} {(n-1)**3:>9} {defect(sh):>7}  {defect(sh) == (n-1)**3}")

    banner("5.  Commutative bound:  D <= (n-1)^3 - (n-1)^2, attained by negation magmas")
    print(f"\n   {'m':>3} {'n':>3} {'bound':>7} {'D(Neg)':>8}  commutative  even  attained")
    for m in [3, 5, 7, 9, 11]:
        ng = negation_magma(m)
        n = order(ng)
        bound = (n - 1) ** 3 - (n - 1) ** 2
        d = defect(ng)
        print(f"   {m:>3} {n:>3} {bound:>7} {d:>8}  {str(is_commutative(ng)):>11}"
              f"  {str(d % 2 == 0):>4}  {d == bound}")
    print("\n  For EVEN m the group Z/m has 2-torsion and the construction is not extremal:")
    for m in [4, 6, 8]:
        ng = negation_magma(m)
        n = order(ng)
        print(f"   m = {m}: D = {defect(ng):>4}   bound = {(n-1)**3 - (n-1)**2:>4}")

    banner("6.  Parity theorem: the defect of a finite commutative magma is even")
    for m in [3, 4, 5, 6, 7]:
        ng = negation_magma(m)
        print(f"   Neg(Z/{m}):  commutative = {is_commutative(ng)},"
              f"  D = {defect(ng)},  even = {defect(ng) % 2 == 0}")
    print("   Reason: reversal (a,b,c) -> (c,b,a) is a fixed-point-free involution of")
    print("   the defect set, since palindromic triples (a,b,a) are never defective.")

    banner("7.  Multiplicativity of the associative-triple count:  A(MxN) = A(M)A(N)")
    pairs = [
        (shift_magma(cyclic_shift(2)), cyclic_group(2)),
        (shift_magma(cyclic_shift(2)), negation_magma(3)),
        (subtraction_magma(3), cyclic_group(3)),
    ]
    print(f"\n   {'A(M)':>6} {'A(N)':>6} {'A(M)A(N)':>10} {'A(MxN)':>8}  equal   d(MxN)")
    for t1, t2 in pairs:
        pr = product_magma(t1, t2)
        a1, a2, ap = assoc_count(t1), assoc_count(t2), assoc_count(pr)
        dens = defect(pr) / order(pr) ** 3
        print(f"   {a1:>6} {a2:>6} {a1*a2:>10} {ap:>8}  {str(a1*a2 == ap):>5}"
              f"   {dens:.4f}")

    banner("8.  Invariance: isomorphism, reversal, free unitalisation")
    base = shift_magma(cyclic_shift(3))
    perm = [0, 2, 3, 1]
    print(f"   D(M)              = {defect(base)}")
    print(f"   D(relabelled M)   = {defect(relabel(base, perm))}")
    print(f"   D(M^op)           = {defect(opposite(base))}")
    raw = subtraction_magma(3)
    print(f"   D(subtraction Z/3)        = {defect(raw)}")
    print(f"   D(unitalised, order {order(adjoin_one(raw))})  = {defect(adjoin_one(raw))}"
          "   (free unitalisation is defect-neutral)")


def demo_enumeration() -> None:
    banner("9.  Exhaustive enumeration of unital tables of order 3 and 4")
    for n in (3, 4):
        dist = defect_distribution(n)
        total = sum(dist.values())
        print(f"\n  Order n = {n}:  {total} = {n}^{(n-1)**2} unital tables,"
              f" bound (n-1)^3 = {(n-1)**3}")
        print("   D : count")
        for d in sorted(dist):
            print(f"   {d:>2} : {dist[d]}")
        n_max, n_max_comm, n_one, n_one_comm = count_extremal(n)
        plain, with_mirrors = shift_maximisers(n)
        print(f"   maximisers (D = {(n-1)**3})           : {n_max}"
              f"   (commutative: {n_max_comm})")
        print(f"     of which shift magmas           : {plain}"
              f"   (with mirrors: {with_mirrors})")
        print(f"   tables with D = 1                 : {n_one}"
              f"   (commutative: {n_one_comm})")

    print("\n  Conclusion: 'a unital magma never has exactly one defect triple' is TRUE")
    print("  at order 3 but FALSE at order 4 (84 counterexamples, none commutative).")
    print("  The correct general statement is the parity theorem, which forbids D = 1")
    print("  only in the commutative case.")


def demo_bridge() -> None:
    banner("10.  The bridge: D(M) = number of non-identity associator instances")
    examples = [
        ("Shift magma, order 4", shift_magma(cyclic_shift(3))),
        ("Negation magma Neg(Z/3), order 4", negation_magma(3)),
        ("Cyclic group Z/4 (a monoid)", cyclic_group(4)),
        ("Subtraction magma on Z/4", subtraction_magma(4)),
    ]
    print(f"\n   {'magma':<34} {'n':>2} {'D':>4} {'#weak assoc':>12} {'strict':>7}")
    for name, table in examples:
        n = order(table)
        print(f"   {name:<34} {n:>2} {defect(table):>4}"
              f" {len(nonidentity_associators(table)):>12} {str(is_strict(table)):>7}")
    print("\n   In every row the defect equals the number of associator instances that")
    print("   connect two DISTINCT 1-cells, and the bicategory is strict exactly when")
    print("   that number is 0 (for unital magmas).")


def main() -> None:
    print(__doc__)
    demo_bicategory()
    demo_defect_theory()
    demo_enumeration()
    demo_bridge()
    banner("All demonstrations complete.")


if __name__ == "__main__":
    main()
