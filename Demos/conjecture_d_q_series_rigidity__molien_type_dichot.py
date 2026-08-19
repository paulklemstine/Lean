"""
Molien-type rigidity for finite group actions: numerical demonstrations.

Setting
-------
A finite group G acts on a finite set X (here: X = {0, 1, ..., N-1}, and G is given
concretely as a list of permutations of X, i.e. tuples p with p[i] = image of i).

Two invariants are attached to the action:

  * the fixed-point q-series   Phi(q) = sum_{g in G} q^{|X^g|},
    equivalently the fibre counts F(v) = #{g : |X^g| = v},
    equivalently the normalised density rho(v) = F(v)/|G|;

  * the orbit counts           N_n = #( X^n / G )  (diagonal action on n-tuples).

Burnside's lemma on n-tuples gives the moment identity

        |G| * N_n = sum_g |X^g|^n        i.e.       N_n = sum_v rho(v) * v^n,

so the orbit counts are exactly the moments of the fixed-point density.  Everything
below is a consequence.

This script demonstrates, in exact rational arithmetic:

  1. the moment identity (Burnside for tuples) and the Molien rational form;
  2. reconstruction of rho from the first |X|+1 orbit counts by inverting the
     Vandermonde/moment matrix -- with universal coefficients depending only on |X|;
  3. the peeling recursion, its explicit geometric error bound ((m-1)/m)^n, and the
     rounding rule that makes the limit an exact terminating computation;
  4. the sharpness statements: normalisation cannot be removed, the number of
     coefficients cannot be reduced, and the invariants cannot distinguish groups
     (Z/4 versus Z/2 x Z/2 acting regularly).

Self-contained: standard library only.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Dict, List, Sequence, Tuple

Perm = Tuple[int, ...]


# ----------------------------------------------------------------------------------
# 1. Basic group / action machinery
# ----------------------------------------------------------------------------------

def compose(p: Perm, q: Perm) -> Perm:
    """Composition (p after q): (p*q)[i] = p[q[i]]."""
    return tuple(p[q[i]] for i in range(len(p)))


def generated_group(gens: Sequence[Perm], degree: int) -> List[Perm]:
    """Closure of `gens` under composition, containing the identity."""
    identity: Perm = tuple(range(degree))
    elements: Dict[Perm, None] = {identity: None}
    frontier: List[Perm] = [identity]
    while frontier:
        new_frontier: List[Perm] = []
        for element in frontier:
            for g in gens:
                candidate = compose(g, element)
                if candidate not in elements:
                    elements[candidate] = None
                    new_frontier.append(candidate)
        frontier = new_frontier
    return sorted(elements)


def fix_count(p: Perm) -> int:
    """Number of points fixed by the permutation p."""
    return sum(1 for i, image in enumerate(p) if image == i)


def fibre_counts(group: Sequence[Perm], degree: int) -> List[int]:
    """F(v) = #{g in G : |X^g| = v} for v = 0..degree."""
    counts = [0] * (degree + 1)
    for p in group:
        counts[fix_count(p)] += 1
    return counts


def density(group: Sequence[Perm], degree: int) -> List[Fraction]:
    """rho(v) = F(v) / |G| for v = 0..degree."""
    order = len(group)
    return [Fraction(f, order) for f in fibre_counts(group, degree)]


def q_series_string(group: Sequence[Perm], degree: int) -> str:
    """Human-readable fixed-point q-series Phi(q) = sum_g q^{|X^g|}."""
    counts = fibre_counts(group, degree)
    terms: List[str] = []
    for v in range(degree, -1, -1):
        c = counts[v]
        if c == 0:
            continue
        coeff = "" if (c == 1 and v > 0) else str(c)
        if v == 0:
            terms.append(str(c))
        elif v == 1:
            terms.append(f"{coeff}q")
        else:
            terms.append(f"{coeff}q^{v}")
    return " + ".join(terms) if terms else "0"


def orbit_count_bruteforce(group: Sequence[Perm], degree: int, n: int) -> int:
    """#(X^n / G), computed by explicit orbit enumeration (small n only)."""
    if n == 0:
        return 1
    seen = set()
    orbits = 0
    for tup in product(range(degree), repeat=n):
        if tup in seen:
            continue
        orbits += 1
        for p in group:
            seen.add(tuple(p[x] for x in tup))
    return orbits


def orbit_count_burnside(group: Sequence[Perm], n: int) -> int:
    """#(X^n / G) via Burnside: (1/|G|) sum_g |X^g|^n."""
    total = sum(fix_count(p) ** n for p in group)
    assert total % len(group) == 0
    return total // len(group)


# ----------------------------------------------------------------------------------
# 2. Exact linear algebra over Q: Vandermonde inversion
# ----------------------------------------------------------------------------------

def moment_matrix(size: int) -> List[List[Fraction]]:
    """M[n][j] = j^n for 0 <= n, j <= size (transpose of the Vandermonde matrix)."""
    return [[Fraction(j) ** n for j in range(size + 1)] for n in range(size + 1)]


def invert_matrix(matrix: List[List[Fraction]]) -> List[List[Fraction]]:
    """Exact Gauss-Jordan inversion over the rationals."""
    dim = len(matrix)
    work = [row[:] + [Fraction(1 if i == j else 0) for j in range(dim)]
            for i, row in enumerate(matrix)]
    for col in range(dim):
        pivot = next(r for r in range(col, dim) if work[r][col] != 0)
        work[col], work[pivot] = work[pivot], work[col]
        scale = work[col][col]
        work[col] = [entry / scale for entry in work[col]]
        for r in range(dim):
            if r != col and work[r][col] != 0:
                factor = work[r][col]
                work[r] = [a - factor * b for a, b in zip(work[r], work[col])]
    return [row[dim:] for row in work]


def reconstruction_matrix(size: int) -> List[List[Fraction]]:
    """C = M^{-1}: the universal reconstruction coefficients on nodes 0..size."""
    return invert_matrix(moment_matrix(size))


def reconstruct_density(orbit_counts: Sequence[int], size: int) -> List[Fraction]:
    """rho(v) = sum_{n<=size} C[v][n] * N_n, using exactly size+1 orbit counts."""
    coeff = reconstruction_matrix(size)
    return [sum((coeff[v][n] * orbit_counts[n] for n in range(size + 1)), Fraction(0))
            for v in range(size + 1)]


# ----------------------------------------------------------------------------------
# 3. The peeling recursion, with certified rounding
# ----------------------------------------------------------------------------------

def peel_estimate(orbit_counts_at_n: Fraction, known_above: Sequence[Fraction],
                  m: int, size: int, n: int) -> Fraction:
    """P_m(n) = (N_n - sum_{v>m} rho(v) v^n) / m^n, with known_above indexed by v."""
    tail = sum((known_above[v] * Fraction(v) ** n for v in range(m + 1, size + 1)),
               Fraction(0))
    return (orbit_counts_at_n - tail) / Fraction(m) ** n


def peel_stopping_time(m: int, group_order: int) -> int:
    """Least n with ((m-1)/m)^n * 2|G| < 1 (n = 1 when m = 1, where the error is 0)."""
    if m == 1:
        return 1
    ratio = Fraction(m - 1, m)
    n = 1
    while ratio ** n * 2 * group_order >= 1:
        n += 1
    return n


def round_half_up(x: Fraction) -> int:
    """Nearest integer to the rational x."""
    from math import floor
    return floor(x + Fraction(1, 2))


def peel_reconstruct(group: Sequence[Perm], size: int) -> Tuple[List[int], List[int]]:
    """
    Reconstruct the fibre counts F(0..size) purely from orbit counts, top down.

    Returns (fibre counts, the exponent n used at each value m).
    Uses only |G| and an oracle for the orbit counts; never inspects the group's
    fixed-point data directly.
    """
    order = len(group)
    rho: List[Fraction] = [Fraction(0)] * (size + 1)
    fibres: List[int] = [0] * (size + 1)
    exponents: List[int] = [0] * (size + 1)
    for m in range(size, 0, -1):
        n = peel_stopping_time(m, order)
        exponents[m] = n
        n_at = Fraction(orbit_count_burnside(group, n))
        estimate = peel_estimate(n_at, rho, m, size, n)
        fibres[m] = round_half_up(Fraction(order) * estimate)
        rho[m] = Fraction(fibres[m], order)
    fibres[0] = order - sum(fibres[1:])
    return fibres, exponents


# ----------------------------------------------------------------------------------
# 4. Demonstrations
# ----------------------------------------------------------------------------------

def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def show_action(name: str, group: Sequence[Perm], degree: int,
                max_n: int = 6, verify_bruteforce_upto: int = 4) -> None:
    banner(f"{name}   (|G| = {len(group)}, |X| = {degree})")

    counts = fibre_counts(group, degree)
    rho = density(group, degree)
    print(f"fixed-point q-series  Phi(q) = {q_series_string(group, degree)}")
    print(f"fibre counts F(v)            = {counts}")
    print(f"density rho(v)               = {[str(r) for r in rho]}")
    print(f"total mass                   = {sum(rho, Fraction(0))}")

    burnside = [orbit_count_burnside(group, n) for n in range(max_n + 1)]
    print(f"orbit counts N_0..N_{max_n}        = {burnside}")

    # 1. Burnside for tuples, checked against brute-force orbit enumeration.
    for n in range(verify_bruteforce_upto + 1):
        brute = orbit_count_bruteforce(group, degree, n)
        assert brute == burnside[n], (n, brute, burnside[n])
    print(f"[check] Burnside identity matches brute-force orbit enumeration "
          f"for n <= {verify_bruteforce_upto}.")

    # 2. Moment identity N_n = sum_v rho(v) v^n.
    for n in range(max_n + 1):
        moment = sum((rho[v] * Fraction(v) ** n for v in range(degree + 1)), Fraction(0))
        assert moment == burnside[n]
    print("[check] N_n equals the n-th moment of the fixed-point density.")

    # 3. Linear reconstruction from the first |X|+1 orbit counts.
    recovered = reconstruct_density(burnside, degree)
    assert recovered == rho
    print(f"[check] Vandermonde inversion recovers rho from N_0..N_{degree} exactly:")
    print(f"        recovered rho = {[str(r) for r in recovered]}")

    # 4. Peeling recursion with certified rounding.
    peeled, exponents = peel_reconstruct(group, degree)
    assert peeled == counts
    print("[check] peeling recursion recovers the fibre counts exactly:")
    print(f"        peeled F(v)   = {peeled}")
    print(f"        exponent used at each m (index v) = {exponents}")

    # 5. Error bound and monotone convergence of the top peeling step.
    if degree >= 1:
        print(f"        top step: N_n / |X|^n -> |K|/|G| = {rho[degree]}")
        for n in (1, 2, 4, 8, 16):
            approx = Fraction(orbit_count_burnside(group, n)) / Fraction(degree) ** n
            bound = Fraction(degree - 1, degree) ** n if degree >= 1 else Fraction(0)
            err = approx - rho[degree]
            assert 0 <= err <= bound
            print(f"          n = {n:2d}:  P(n) = {float(approx):.10f}   "
                  f"error = {float(err):.3e}   bound = {float(bound):.3e}")


def demo_universal_coefficients() -> None:
    banner("The reconstruction coefficients are universal: they depend only on |X|")
    for size in (2, 3):
        coeff = reconstruction_matrix(size)
        print(f"\nnodes 0..{size}:   rho(v) = sum_n C[v][n] * N_n   with C =")
        for v, row in enumerate(coeff):
            print(f"    v = {v}: " + "  ".join(f"{str(c):>7}" for c in row))
    print("\nFor |X| = 2 this says, for EVERY action on a 2-element set:")
    print("    rho(2) = (N_2 - N_1)/2,   rho(1) = 2N_1 - N_2,   "
          "rho(0) = N_0 - (3/2)N_1 + N_2/2.")


def demo_normalisation_necessary() -> None:
    banner("Sharpness I: normalisation cannot be removed")
    identity2: Perm = (0, 1)
    trivial_group_order_1 = [identity2]
    # A group of order 2 acting trivially: two distinct elements, both acting as identity.
    # We model this by weighting: the fixed-point multiset is {2, 2}, density delta_2.
    print("Trivial group E acting on a 2-element set:")
    print(f"    Phi(q) = {q_series_string(trivial_group_order_1, 2)}"
          f"      orbit counts = {[orbit_count_burnside(trivial_group_order_1, n) for n in range(6)]}")
    print("Order-2 group C_2 acting trivially on the same 2-element set:")
    print("    Phi(q) = 2q^2      orbit counts = [1, 2, 4, 8, 16, 32]")
    print("Both have density rho = delta_2 (all mass at v = 2) and identical orbit")
    print("counts 2^n in every degree; the q-series differ (q^2 versus 2q^2).")
    print("=> orbit counts are blind to |G|: Burnside divides by it.")


def demo_coefficient_bound_sharp() -> None:
    banner("Sharpness II: the number of coefficients cannot be reduced")
    weight = {0: Fraction(1), 1: Fraction(-3), 2: Fraction(3), 3: Fraction(-1)}
    for n in range(4):
        value = sum((weight[v] * Fraction(v) ** n for v in weight), Fraction(0))
        verdict = "vanishes" if value == 0 else f"= {value}  <-- first nonzero"
        print(f"    power sum with exponent n = {n}: {verdict}")
    print("The signed weight (1, -3, 3, -1) on the four nodes {0,1,2,3} kills the")
    print("first three power sums.  So k-1 moments never suffice on k nodes: the")
    print("range n = 0..k-1 in the rigidity theorem is exactly right.")


def demo_group_structure_invisible() -> None:
    banner("Sharpness III: the invariants cannot see the group -- Z/4 versus Z/2 x Z/2")

    # Regular action of Z/4 on itself: generated by the 4-cycle.
    c4 = generated_group([(1, 2, 3, 0)], 4)
    # Regular action of Z/2 x Z/2 on itself: two commuting fixed-point-free involutions.
    v4 = generated_group([(1, 0, 3, 2), (2, 3, 0, 1)], 4)

    for name, group in (("Z/4 (regular)", c4), ("Z/2 x Z/2 (regular)", v4)):
        counts = [orbit_count_burnside(group, n) for n in range(6)]
        print(f"{name:22s} |G| = {len(group)}   "
              f"Phi(q) = {q_series_string(group, 4)}   N_0..N_5 = {counts}")

    same_q = fibre_counts(c4, 4) == fibre_counts(v4, 4)
    same_counts = all(orbit_count_burnside(c4, n) == orbit_count_burnside(v4, n)
                      for n in range(40))
    print(f"\nidentical fixed-point q-series?  {same_q}")
    print(f"identical orbit counts (n < 40)? {same_counts}")
    print("Z/4 is cyclic and Z/2 x Z/2 is not, so the groups are NOT isomorphic.")
    print("=> the rigidity theorem determines the fixed-point distribution and")
    print("   provably nothing more.")


def demo_molien_rational_form() -> None:
    banner("The Molien closed form:  |G| * N(t) = sum_g 1/(1 - |X^g| t)")
    group = generated_group([(1, 0, 2), (0, 2, 1)], 3)      # Sym(3) on 3 points
    order = len(group)
    print(f"Sym(3) on 3 points, |G| = {order}, fixed-point multiset = "
          f"{sorted(fix_count(p) for p in group)}")
    print("\n  n :  |G|*N_n   sum_g |X^g|^n   1/(1-3t)+3/(1-t)+2  coefficient")
    for n in range(7):
        lhs = order * orbit_count_burnside(group, n)
        rhs = sum(fix_count(p) ** n for p in group)
        closed = 3 ** n + 3 * 1 ** n + (2 if n == 0 else 0)
        assert lhs == rhs == closed
        print(f"  {n} :  {lhs:8d}   {rhs:12d}   {closed:18d}      ok")
    print("\nSo N(t) = (1/6)[ 1/(1-3t) + 3/(1-t) + 2 ]: a rational function whose poles")
    print("1/3 and 1 are the reciprocals of the realised fixed-point counts, with")
    print("residues proportional to how many group elements realise them.")


def main() -> None:
    print(__doc__)

    # Sym(2) acting on 2 points.
    sym2 = generated_group([(1, 0)], 2)
    show_action("Sym(2) acting on {0,1}", sym2, 2)

    # Sym(3) acting on 3 points.
    sym3 = generated_group([(1, 0, 2), (0, 2, 1)], 3)
    show_action("Sym(3) acting on {0,1,2}", sym3, 3)

    # Cyclic group of order 4 acting on 4 points (rotations of a square's vertices).
    c4_on_4 = generated_group([(1, 2, 3, 0)], 4)
    show_action("Z/4 rotating 4 points", c4_on_4, 4)

    # Dihedral group of order 8 acting on the 4 vertices of a square.
    d4 = generated_group([(1, 2, 3, 0), (0, 3, 2, 1)], 4)
    show_action("Dihedral group of order 8 on the square's vertices", d4, 4)

    # Sym(4) on 4 points: the largest example here, |G| = 24.
    sym4 = generated_group([(1, 0, 2, 3), (1, 2, 3, 0)], 4)
    show_action("Sym(4) acting on {0,1,2,3}", sym4, 4)

    demo_universal_coefficients()
    demo_molien_rational_form()
    demo_normalisation_necessary()
    demo_coefficient_bound_sharp()
    demo_group_structure_invisible()

    banner("All checks passed.")


if __name__ == "__main__":
    main()
