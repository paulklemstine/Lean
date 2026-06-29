"""
Numerical demonstration of the combinatorial core of the Yau-Tian-Donaldson
principle for toric Fano varieties.

A toric Fano variety is encoded by its moment polytope, modelled here as a finite
family of weighted rational lattice points (p_i, w_i). The central fact is:

    a Kahler-Einstein metric exists
        <=>  the barycenter of the polytope is the origin
        <=>  the moment vector  M = sum_i w_i * p_i  is zero
        <=>  the Futaki invariant  Fut(xi) = <M, xi>  vanishes for every xi
        <=>  the variety is K-polystable.

Moreover, any linear symmetry of the datum fixes M, so a symmetry whose only
fixed vector is the origin forces M = 0 (the Matsushima-type obstruction).

All arithmetic is exact (fractions.Fraction), so every test is decidable.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Vector = Tuple[Fraction, ...]


# ---------------------------------------------------------------------------
# Core quantities
# ---------------------------------------------------------------------------

def to_vec(xs: Sequence[int | Fraction]) -> Vector:
    """Convert a sequence of integers/fractions into an exact rational vector."""
    return tuple(Fraction(x) for x in xs)


def total_weight(weights: Sequence[Fraction]) -> Fraction:
    """W = sum_i w_i."""
    return sum(weights, Fraction(0))


def moment_vector(points: Sequence[Vector], weights: Sequence[Fraction]) -> Vector:
    """The (unnormalised) moment / Futaki vector  M = sum_i w_i * p_i."""
    d = len(points[0])
    acc = [Fraction(0)] * d
    for p, w in zip(points, weights):
        for j in range(d):
            acc[j] += w * p[j]
    return tuple(acc)


def barycenter(points: Sequence[Vector], weights: Sequence[Fraction]) -> Vector:
    """b = M / W, the centre of mass of the polytope (requires W != 0)."""
    W = total_weight(weights)
    if W == 0:
        raise ZeroDivisionError("degenerate datum: total weight is zero")
    M = moment_vector(points, weights)
    return tuple(m / W for m in M)


def futaki(points: Sequence[Vector], weights: Sequence[Fraction], xi: Vector) -> Fraction:
    """The Futaki invariant  Fut(xi) = sum_i w_i <p_i, xi>."""
    acc = Fraction(0)
    for p, w in zip(points, weights):
        acc += w * sum(p[j] * xi[j] for j in range(len(xi)))
    return acc


def dot(u: Vector, v: Vector) -> Fraction:
    return sum(a * b for a, b in zip(u, v))


# ---------------------------------------------------------------------------
# Decision procedures
# ---------------------------------------------------------------------------

def admits_kahler_einstein(points: Sequence[Vector],
                           weights: Sequence[Fraction]) -> bool:
    """Existence test (Theorem: AdmitsKE <=> M = 0). Returns True iff balanced."""
    M = moment_vector(points, weights)
    return all(m == 0 for m in M)


def destabilizing_direction(points: Sequence[Vector],
                            weights: Sequence[Fraction]) -> Vector | None:
    """If obstructed, return a direction xi with Fut(xi) != 0 (namely xi = M)."""
    M = moment_vector(points, weights)
    if all(m == 0 for m in M):
        return None
    return M  # Fut(M) = <M, M> > 0 when M != 0


# ---------------------------------------------------------------------------
# Symmetry certificate (Matsushima-type obstruction)
# ---------------------------------------------------------------------------

def apply_linear(sigma: List[List[Fraction]], x: Vector) -> Vector:
    """Apply the matrix sigma to the vector x."""
    return tuple(sum(sigma[i][j] * x[j] for j in range(len(x)))
                 for i in range(len(sigma)))


def is_symmetry(points: Sequence[Vector], weights: Sequence[Fraction],
                sigma: List[List[Fraction]], perm: Sequence[int]) -> bool:
    """Check that (sigma, perm) is a symmetry: weights preserved and
    sigma(p_i) = p_{perm(i)} for all i."""
    for i, (p, w) in enumerate(zip(points, weights)):
        if weights[perm[i]] != w:
            return False
        if apply_linear(sigma, p) != points[perm[i]]:
            return False
    return True


def fixed_space_is_trivial(sigma: List[List[Fraction]]) -> bool:
    """Return True iff ker(sigma - I) = {0}, i.e. sigma fixes only the origin.
    Computed by exact Gaussian elimination over the rationals."""
    d = len(sigma)
    # Build A = sigma - I.
    A = [[sigma[i][j] - (Fraction(1) if i == j else Fraction(0))
          for j in range(d)] for i in range(d)]
    rank = 0
    col = 0
    rows = [row[:] for row in A]
    r = 0
    while r < d and col < d:
        pivot = None
        for k in range(r, d):
            if rows[k][col] != 0:
                pivot = k
                break
        if pivot is None:
            col += 1
            continue
        rows[r], rows[pivot] = rows[pivot], rows[r]
        inv = rows[r][col]
        rows[r] = [v / inv for v in rows[r]]
        for k in range(d):
            if k != r and rows[k][col] != 0:
                f = rows[k][col]
                rows[k] = [a - f * b for a, b in zip(rows[k], rows[r])]
        rank += 1
        r += 1
        col += 1
    # ker is trivial iff rank == d.
    return rank == d


def certified_by_symmetry(points: Sequence[Vector], weights: Sequence[Fraction],
                          sigma: List[List[Fraction]],
                          perm: Sequence[int]) -> bool:
    """Existence certified purely from symmetry, WITHOUT computing M."""
    return is_symmetry(points, weights, sigma, perm) and fixed_space_is_trivial(sigma)


# ---------------------------------------------------------------------------
# Worked examples
# ---------------------------------------------------------------------------

def projective_space_datum(n: int) -> Tuple[List[Vector], List[Fraction]]:
    """Moment polytope of P^n: reflexive simplex with vertices
    v_0 = (-1,...,-1) and v_k = e_k, all weight 1."""
    points: List[Vector] = []
    v0 = to_vec([-1] * n)
    points.append(v0)
    for k in range(n):
        ek = [0] * n
        ek[k] = 1
        points.append(to_vec(ek))
    weights = [Fraction(1)] * (n + 1)
    return points, weights


def blowup_p2_datum() -> Tuple[List[Vector], List[Fraction]]:
    """A representative datum for the one-point blow-up of P^2: the cyclic
    symmetry of the triangle is broken, so the moment vector drifts off-origin."""
    # Triangle of P^2 has balanced vertices summing to 0; blowing up one fixed
    # point adds an extra lattice point in one corner, breaking the balance.
    points = [
        to_vec([-1, -1]),
        to_vec([1, 0]),
        to_vec([0, 1]),
        to_vec([1, 1]),   # extra point from the corner cut -> imbalance
    ]
    weights = [Fraction(1)] * 4
    return points, weights


def cyclic_sigma_p2() -> Tuple[List[List[Fraction]], List[int]]:
    """The order-3 cyclic symmetry of the P^2 triangle, realised as a linear
    map on Q^2 cyclically permuting v_0 -> v_1 -> v_2 -> v_0."""
    # v0=(-1,-1), v1=(1,0), v2=(0,1). sigma maps v0->v1, v1->v2, v2->v0.
    # Solve for sigma as a 2x2 matrix.  sigma(v1)=v2 and sigma(v2)=v0 determine it.
    # v1=(1,0)->v2=(0,1): first column = (0,1).
    # v2=(0,1)->v0=(-1,-1): second column = (-1,-1).
    sigma = [[Fraction(0), Fraction(-1)],
             [Fraction(1), Fraction(-1)]]
    perm = [1, 2, 0]  # acting on the three triangle vertices
    return sigma, perm


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def report(name: str, points: Sequence[Vector], weights: Sequence[Fraction]) -> None:
    M = moment_vector(points, weights)
    W = total_weight(weights)
    print(f"\n{name}")
    print(f"  points        : {[tuple(map(str, p)) for p in points]}")
    print(f"  total weight W : {W}")
    print(f"  moment vec  M  : {tuple(map(str, M))}")
    if W != 0:
        b = barycenter(points, weights)
        print(f"  barycenter  b  : {tuple(map(str, b))}")
    if admits_kahler_einstein(points, weights):
        print("  VERDICT        : balanced  ->  K-stable  ->  KE metric EXISTS")
    else:
        xi = destabilizing_direction(points, weights)
        print(f"  VERDICT        : obstructed  ->  NO KE metric")
        print(f"  destabilizing xi = M, with Fut(xi) = {futaki(points, weights, xi)}")


def main() -> None:
    banner("1. Futaki invariant equals the dot product <M, xi>")
    pts, wts = projective_space_datum(3)
    M = moment_vector(pts, wts)
    for xi in [to_vec([1, 0, 0]), to_vec([2, -3, 5]), to_vec([7, 7, 7])]:
        lhs = futaki(pts, wts, xi)
        rhs = dot(M, xi)
        print(f"  xi={tuple(map(str, xi))}:  Fut={lhs}  <M,xi>={rhs}  equal={lhs == rhs}")

    banner("2. Projective space P^n is K-stable for several n")
    for n in (1, 2, 3, 4):
        pts, wts = projective_space_datum(n)
        ok = admits_kahler_einstein(pts, wts)
        print(f"  P^{n}: moment vector = {tuple(map(str, moment_vector(pts, wts)))}"
              f"  ->  KE exists = {ok}")

    banner("3. The one-point blow-up of P^2 is NOT K-stable")
    pts, wts = blowup_p2_datum()
    report("Blow-up of P^2 at one point", pts, wts)

    banner("4. Symmetry certificate for P^2 (Matsushima-type obstruction)")
    pts, wts = projective_space_datum(2)
    sigma, perm = cyclic_sigma_p2()
    print(f"  is_symmetry            : {is_symmetry(pts, wts, sigma, perm)}")
    print(f"  fixed space trivial    : {fixed_space_is_trivial(sigma)}")
    print(f"  certified by symmetry  : {certified_by_symmetry(pts, wts, sigma, perm)}")
    print("  (existence concluded WITHOUT computing the moment vector)")

    banner("5. Comparison table")
    report("P^2  (triangle)", *projective_space_datum(2))
    report("Blow-up of P^2 (quadrilateral)", *blowup_p2_datum())


if __name__ == "__main__":
    main()
