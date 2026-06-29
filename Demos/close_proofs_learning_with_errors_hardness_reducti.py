"""
Numerical demonstrations of the geometric core of the LWE hardness reduction.

This script illustrates, with concrete numbers, the theorems formalized in
`HardnessReduction.lean`:

  * Theorem 1/2 : bounded-distance decoding is unique within lambda_1 / 2
                  (and the asymmetric form: distances summing below lambda_1).
  * Theorem 3   : existence-and-uniqueness of the BDD solution.
  * Theorem 4   : lambda_1/2-balls about distinct lattice points are disjoint
                  (lattice packing).
  * Theorem 5/6 : an LWE secret is uniquely determined by a short error,
                  and decoding of a genuine LWE word is correct.
  * Prop. 7     : GapSVP_gamma YES/NO promises are mutually exclusive.
  * Prop. 8     : the parameter chain alpha * q >= 2 * sqrt(n).
  * Prop. 9     : sharpness -- at the boundary radius lambda_1/2 (Z subset R,
                  target 1/2) uniqueness fails.

Everything is self-contained: only the Python standard library is used.
Run with:  python demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Iterable, List, Optional, Sequence, Tuple

Vector = Tuple[float, ...]


# --------------------------------------------------------------------------- #
# Basic Euclidean utilities
# --------------------------------------------------------------------------- #
def norm(v: Sequence[float]) -> float:
    """Euclidean norm of a vector."""
    return math.sqrt(sum(x * x for x in v))


def sub(v: Sequence[float], w: Sequence[float]) -> Vector:
    """Component-wise difference v - w."""
    return tuple(a - b for a, b in zip(v, w))


def add(v: Sequence[float], w: Sequence[float]) -> Vector:
    """Component-wise sum v + w."""
    return tuple(a + b for a, b in zip(v, w))


def matvec(matrix: Sequence[Sequence[float]], vec: Sequence[float]) -> Vector:
    """Matrix-vector product A * s."""
    return tuple(sum(row[j] * vec[j] for j in range(len(vec))) for row in matrix)


# --------------------------------------------------------------------------- #
# Lattice generation: enumerate the lattice points of a basis within a box
# --------------------------------------------------------------------------- #
def enumerate_lattice(basis: Sequence[Sequence[float]],
                      coeff_range: int) -> List[Vector]:
    """All integer combinations of `basis` with coefficients in
    [-coeff_range, coeff_range]. Returns the resulting lattice points."""
    dim = len(basis)
    points: List[Vector] = []
    grid = range(-coeff_range, coeff_range + 1)
    for coeffs in itertools.product(grid, repeat=dim):
        point = tuple(
            sum(coeffs[i] * basis[i][j] for i in range(dim))
            for j in range(len(basis[0]))
        )
        points.append(point)
    return points


def first_minimum(basis: Sequence[Sequence[float]], coeff_range: int) -> float:
    """Estimate lambda_1: the shortest nonzero lattice vector length, computed
    by brute force over integer combinations within the given coefficient box."""
    best = math.inf
    dim = len(basis)
    grid = range(-coeff_range, coeff_range + 1)
    for coeffs in itertools.product(grid, repeat=dim):
        if all(c == 0 for c in coeffs):
            continue
        vec = tuple(
            sum(coeffs[i] * basis[i][j] for i in range(dim))
            for j in range(len(basis[0]))
        )
        best = min(best, norm(vec))
    return best


# --------------------------------------------------------------------------- #
# Theorem 1/2/3: bounded-distance decoding within lambda_1 / 2
# --------------------------------------------------------------------------- #
def decode_candidates(target: Sequence[float],
                      lattice_points: Iterable[Vector],
                      radius: float) -> List[Vector]:
    """All lattice points strictly within `radius` of `target`."""
    return [p for p in lattice_points if norm(sub(target, p)) < radius]


def demo_unique_decoding() -> None:
    """Theorem 1 & 3: within radius lambda_1/2 there is exactly one solution."""
    print("=" * 70)
    print("Theorem 1 & 3: unique bounded-distance decoding within lambda_1/2")
    print("=" * 70)

    # A 2-D lattice (slightly skewed) and its first minimum.
    basis = [[2.0, 0.0], [0.5, 2.0]]
    coeff_range = 6
    points = enumerate_lattice(basis, coeff_range)
    lam = first_minimum(basis, coeff_range)
    packing = lam / 2.0
    print(f"  lambda_1 (shortest vector)   = {lam:.4f}")
    print(f"  packing radius lambda_1/2    = {packing:.4f}")

    # Pick a lattice point and add a small error of norm < lambda_1/2.
    base_point = (2.0, 0.0)  # = 1 * basis[0]
    error = (0.30, -0.20)
    target = add(base_point, error)
    print(f"  base lattice point           = {base_point}")
    print(f"  error e (||e|| = {norm(error):.4f})  < lambda_1/2 : "
          f"{norm(error) < packing}")

    solutions = decode_candidates(target, points, packing)
    print(f"  lattice points within lambda_1/2 of target: {len(solutions)}")
    print(f"  -> unique solution found     = {solutions[0]}")
    assert len(solutions) == 1, "uniqueness violated!"
    assert solutions[0] == base_point
    print("  PASS: the decoded point is unique and correct.\n")


def demo_asymmetric() -> None:
    """Theorem 2: distances need only SUM to below lambda_1.

    The asymmetric region around the true point v is the set of secondary
    candidates w with ||t-v|| + ||t-w|| < lambda_1, i.e. ||t-w|| < lambda_1 -
    ||t-v||.  When v is very close to t this admissible radius is almost
    lambda_1 -- far larger than lambda_1/2 -- yet uniqueness still holds."""
    print("=" * 70)
    print("Theorem 2: asymmetric uniqueness (||t-v|| + ||t-w|| < lambda_1)")
    print("=" * 70)
    basis = [[2.0, 0.0], [0.5, 2.0]]
    coeff_range = 6
    points = enumerate_lattice(basis, coeff_range)
    lam = first_minimum(basis, coeff_range)

    v = (2.0, 0.0)              # the genuine (true) lattice point
    error = (0.10, 0.05)        # very small error => v is extremely close
    target = add(v, error)
    d_v = norm(sub(target, v))
    asym_radius = lam - d_v     # admissible radius for any second candidate
    print(f"  lambda_1 = {lam:.4f},  lambda_1/2 = {lam/2:.4f}")
    print(f"  ||t - v|| = {d_v:.4f}")
    print(f"  asymmetric radius for a 2nd candidate = lambda_1 - ||t-v|| "
          f"= {asym_radius:.4f}")
    print(f"  (this is much larger than lambda_1/2 = {lam/2:.4f})")

    # Enumerate every lattice point w with ||t-v|| + ||t-w|| < lambda_1.
    admissible = [w for w in points
                  if d_v + norm(sub(target, w)) < lam]
    print(f"  lattice points w with ||t-v||+||t-w|| < lambda_1: "
          f"{len(admissible)} -> {admissible}")
    assert admissible == [v]
    print("  PASS: despite the enlarged radius, v is still the only "
          "candidate.\n")


# --------------------------------------------------------------------------- #
# Theorem 4: lattice packing -- lambda_1/2 balls are disjoint
# --------------------------------------------------------------------------- #
def balls_disjoint(points: Sequence[Vector], radius: float,
                   samples: int = 0) -> bool:
    """Verify pairwise disjointness of open balls of `radius` about `points`
    by checking that every pair of distinct centers is at distance >= 2*radius.
    (Two open balls of radius r are disjoint iff centers are >= 2r apart.)"""
    for i in range(len(points)):
        for j in range(i + 1, len(points)):
            if norm(sub(points[i], points[j])) < 2 * radius:
                return False
    return True


def demo_packing() -> None:
    """Theorem 4: lambda_1/2-balls around distinct lattice points are disjoint."""
    print("=" * 70)
    print("Theorem 4: lattice packing -- lambda_1/2 balls are disjoint")
    print("=" * 70)
    basis = [[2.0, 0.0], [0.5, 2.0]]
    coeff_range = 4
    points = enumerate_lattice(basis, coeff_range)
    lam = first_minimum(basis, coeff_range)
    packing = lam / 2.0
    ok = balls_disjoint(points, packing)
    print(f"  lambda_1 = {lam:.4f}, packing radius = {packing:.4f}")
    print(f"  number of lattice points checked: {len(points)}")
    print(f"  all lambda_1/2-balls pairwise disjoint: {ok}")
    assert ok
    # And show that a radius slightly larger than lambda_1/2 causes overlap.
    overlap_radius = packing * 1.01
    bad = balls_disjoint(points, overlap_radius)
    print(f"  with radius 1.01 * lambda_1/2 disjoint? {bad} (expected False)")
    assert not bad
    print("  PASS: lambda_1/2 is exactly the packing radius.\n")


# --------------------------------------------------------------------------- #
# Theorem 5/6: LWE secret uniqueness and decoding correctness
# --------------------------------------------------------------------------- #
def lwe_decode(matrix: Sequence[Sequence[float]],
               received: Sequence[float],
               secret_space: Iterable[Vector],
               radius: float) -> List[Vector]:
    """Return every secret s whose codeword A*s lies within `radius` of the
    received word.  By Theorem 6 this list has exactly one element when the
    true error has norm < lambda_1/2."""
    out: List[Vector] = []
    for s in secret_space:
        codeword = matvec(matrix, s)
        if norm(sub(received, codeword)) < radius:
            out.append(s)
    return out


def demo_lwe_decoding() -> None:
    """Theorem 5 & 6: a short error determines the LWE secret uniquely."""
    print("=" * 70)
    print("Theorem 5 & 6: LWE secret uniqueness / decoding correctness")
    print("=" * 70)
    # A tiny LWE instance over the reals (geometry is identical to ZZ_q).
    # Encoding enc(s) = A * s; injective because A has full column rank.
    matrix = [[3.0, 1.0],
              [1.0, 3.0],
              [0.0, 2.0]]
    secret_space = [(a, b) for a in range(-3, 4) for b in range(-3, 4)]
    codewords = [matvec(matrix, s) for s in secret_space]

    # Estimate lambda_1 over the codeword lattice (differences of codewords).
    lam = math.inf
    for i in range(len(codewords)):
        for j in range(len(codewords)):
            if i != j:
                lam = min(lam, norm(sub(codewords[i], codewords[j])))
    packing = lam / 2.0
    print(f"  estimated lambda_1 of codeword lattice = {lam:.4f}")
    print(f"  packing radius lambda_1/2              = {packing:.4f}")

    true_secret = (1.0, -2.0)
    error = (0.20, -0.10, 0.15)
    received = add(matvec(matrix, true_secret), error)
    print(f"  true secret      = {true_secret}")
    print(f"  error ||e||      = {norm(error):.4f}  < lambda_1/2 : "
          f"{norm(error) < packing}")

    found = lwe_decode(matrix, received, secret_space, packing)
    print(f"  secrets within lambda_1/2: {len(found)} -> {found}")
    assert len(found) == 1 and found[0] == true_secret
    print("  PASS: the secret is uniquely recovered.\n")


# --------------------------------------------------------------------------- #
# Proposition 7: GapSVP_gamma promise exclusivity
# --------------------------------------------------------------------------- #
def gapsvp_promises_exclusive(gamma: float, lam1: float) -> bool:
    """The YES (lam1 <= 1) and NO (lam1 > gamma) cases never both hold when
    gamma >= 1."""
    yes = lam1 <= 1.0
    no = lam1 > gamma
    return not (yes and no)


def demo_gapsvp() -> None:
    """Proposition 7: the GapSVP_gamma YES/NO promises are exclusive."""
    print("=" * 70)
    print("Proposition 7: GapSVP_gamma promise exclusivity (gamma >= 1)")
    print("=" * 70)
    gamma = 4.0
    for lam1 in [0.5, 1.0, 2.5, 5.0, 8.0]:
        yes = lam1 <= 1.0
        no = lam1 > gamma
        excl = gapsvp_promises_exclusive(gamma, lam1)
        print(f"  lambda_1 = {lam1:>4}:  YES={yes!s:>5}  NO={no!s:>5}  "
              f"exclusive={excl}")
        assert excl
    print("  PASS: no lambda_1 satisfies both promises.\n")


# --------------------------------------------------------------------------- #
# Proposition 8: the parameter chain alpha * q >= 2 * sqrt(n)
# --------------------------------------------------------------------------- #
def feasible_parameters(alpha: float, q: int, n: int) -> bool:
    """Regev's feasibility constraint linking noise rate, modulus, dimension."""
    return alpha * q >= 2.0 * math.sqrt(n)


def demo_parameters() -> None:
    """Proposition 8: alpha * q >= 2 sqrt(n) -- correctness/hardness balance."""
    print("=" * 70)
    print("Proposition 8: parameter chain alpha * q >= 2 * sqrt(n)")
    print("=" * 70)
    cases = [
        # (alpha, q, n)
        (0.005, 3329, 256),   # Kyber-like modulus
        (0.001, 3329, 256),   # too little noise
        (0.02, 7681, 512),    # comfortably feasible
    ]
    for alpha, q, n in cases:
        lhs = alpha * q
        rhs = 2.0 * math.sqrt(n)
        ok = feasible_parameters(alpha, q, n)
        print(f"  alpha={alpha:<6} q={q:<6} n={n:<4} : "
              f"alpha*q={lhs:7.3f}  2*sqrt(n)={rhs:7.3f}  feasible={ok}")
    print("  Interpretation: alpha*q must clear 2*sqrt(n) for the decoding")
    print("  step to fit inside lambda_1/2 while keeping worst-case hardness.\n")


# --------------------------------------------------------------------------- #
# Proposition 9: sharpness of lambda_1/2 (Z subset R, target 1/2)
# --------------------------------------------------------------------------- #
def demo_sharpness() -> None:
    """Proposition 9: at the boundary radius lambda_1/2, uniqueness fails."""
    print("=" * 70)
    print("Proposition 9: sharpness -- boundary radius lambda_1/2 fails")
    print("=" * 70)
    # Lattice Z in R: lambda_1 = 1, packing radius = 1/2.
    lam = 1.0
    target = 0.5
    candidates = [0.0, 1.0]
    dists = [abs(target - c) for c in candidates]
    print(f"  lattice = Z, lambda_1 = {lam}, lambda_1/2 = {lam/2}")
    print(f"  target t = {target}")
    for c, d in zip(candidates, dists):
        print(f"    distance to {c} = {d}  (== lambda_1/2: {d == lam/2})")
    # Strictly inside (< 1/2) there would be no tie; AT 1/2 both tie.
    n_at_boundary = sum(1 for d in dists if d <= lam / 2)
    n_strict = sum(1 for d in dists if d < lam / 2)
    print(f"  candidates within  < lambda_1/2 : {n_strict} (unique regime)")
    print(f"  candidates within <= lambda_1/2 : {n_at_boundary} (tie!)")
    assert n_strict == 0 and n_at_boundary == 2
    print("  PASS: replacing '<' by '<=' breaks uniqueness -> radius is sharp.\n")


# --------------------------------------------------------------------------- #
def main() -> None:
    print("\nLWE HARDNESS REDUCTION -- GEOMETRIC CORE: NUMERICAL DEMOS\n")
    demo_unique_decoding()
    demo_asymmetric()
    demo_packing()
    demo_lwe_decoding()
    demo_gapsvp()
    demo_parameters()
    demo_sharpness()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
