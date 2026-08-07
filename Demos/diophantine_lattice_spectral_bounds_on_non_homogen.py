#!/usr/bin/env python3
"""
Spectral Bounds on Non-Homogeneous Quadratic Forms over Lattices
================================================================

Exact rational numerical demonstrations of the results of the accompanying paper.

Setting.  B is a symmetric n x n rational matrix, Q(x) = x^T B x is a positive
definite quadratic form on Q^n, and L = Z^n is the lattice.  Two invariants:

    lambda_1  =  min { Q(m) : m in L, m != 0 }        (minimal lattice energy)
    mu(t)     =  min { Q(t - m) : m in L }            (spectral gap at shift t)

mu(t) is the exact threshold below which  Q(x - t) = c  has no integral solution.

Demonstrations included
-----------------------
 1. Torsion gap and its sharpness:   mu(v/r) = lambda_1 / r^2.
 2. Rigidity: equality at v/r holds exactly for v realising lambda_1.
 3. Sharpened Diophantine unsolvability versus the classical archimedean test.
 4. The law modulo 8: characteristic vectors and the "gap two" value spectrum.
 5. The deep-hole spectrum of Z^n:  values lie in n/4 + 2 Z_{>=0}.
 6. Gap spectrum of Z^n and the weighted Hamming weight of diagonal forms.
 7. Parity of shifted theta coefficients, and the rank-two counterexample
    t = (1/2, 1/3) to the naive converse.
 8. GL_n(Z)-invariance of every quantity above.

All arithmetic is exact (fractions.Fraction); no floating point is used.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product, combinations
from typing import Dict, Iterable, List, Optional, Sequence, Set, Tuple

Rat = Fraction
Vec = Tuple[Rat, ...]
IVec = Tuple[int, ...]
Mat = Tuple[Tuple[Rat, ...], ...]


# ---------------------------------------------------------------------------
# Core linear algebra over the rationals
# ---------------------------------------------------------------------------

def mat(rows: Sequence[Sequence[int | Fraction]]) -> Mat:
    """Build an exact rational matrix from a nested sequence."""
    return tuple(tuple(Fraction(entry) for entry in row) for row in rows)


def identity(n: int) -> Mat:
    """The n x n identity matrix."""
    return mat([[1 if i == j else 0 for j in range(n)] for i in range(n)])


def diagonal(coeffs: Sequence[int | Fraction]) -> Mat:
    """The diagonal Gram matrix of the form sum_i a_i x_i^2."""
    n = len(coeffs)
    return mat([[coeffs[i] if i == j else 0 for j in range(n)] for i in range(n)])


def bil(B: Mat, x: Sequence[Rat], y: Sequence[Rat]) -> Rat:
    """The bilinear form Bil(x, y) = x^T B y."""
    total = Fraction(0)
    for i, row in enumerate(B):
        for j, bij in enumerate(row):
            if bij:
                total += bij * x[i] * y[j]
    return total


def form(B: Mat, x: Sequence[Rat]) -> Rat:
    """The quadratic form Q(x) = x^T B x."""
    return bil(B, x, x)


def transpose(M: Mat) -> Mat:
    """Matrix transpose."""
    return tuple(tuple(M[i][j] for i in range(len(M))) for j in range(len(M[0])))


def matmul(A: Mat, C: Mat) -> Mat:
    """Matrix product A * C."""
    n, k, m = len(A), len(C), len(C[0])
    return tuple(
        tuple(sum((A[i][p] * C[p][j] for p in range(k)), Fraction(0)) for j in range(m))
        for i in range(n)
    )


def congruent(B: Mat, U: Mat) -> Mat:
    """The congruent Gram matrix U^T B U (change of lattice basis by U)."""
    return matmul(transpose(U), matmul(B, U))


def apply_mat(U: Mat, x: Sequence[Rat]) -> Vec:
    """Matrix-vector product U x."""
    return tuple(sum((U[i][j] * x[j] for j in range(len(x))), Fraction(0))
                 for i in range(len(U)))


# ---------------------------------------------------------------------------
# Lattice invariants by exact bounded enumeration
# ---------------------------------------------------------------------------

def lattice_points(n: int, radius: int) -> Iterable[IVec]:
    """All integer vectors in the box {-radius,...,radius}^n."""
    return product(range(-radius, radius + 1), repeat=n)


def minimal_lattice_energy(B: Mat, radius: int = 3) -> Rat:
    """lambda_1 = min over nonzero lattice vectors of Q(m), by bounded search."""
    n = len(B)
    best: Optional[Rat] = None
    for m in lattice_points(n, radius):
        if all(c == 0 for c in m):
            continue
        value = form(B, tuple(Fraction(c) for c in m))
        if best is None or value < best:
            best = value
    assert best is not None
    return best


def spectral_gap(B: Mat, t: Sequence[Rat], radius: int = 3) -> Rat:
    """mu(t) = min over lattice points m of Q(t - m), by bounded search."""
    n = len(B)
    best: Optional[Rat] = None
    for m in lattice_points(n, radius):
        value = form(B, tuple(t[i] - m[i] for i in range(n)))
        if best is None or value < best:
            best = value
    assert best is not None
    return best


def value_spectrum(B: Mat, t: Sequence[Rat], radius: int = 3) -> List[Rat]:
    """The sorted set of values Q(t - m) attained for m in a bounded box."""
    n = len(B)
    values: Set[Rat] = set()
    for m in lattice_points(n, radius):
        values.add(form(B, tuple(t[i] - m[i] for i in range(n))))
    return sorted(values)


def theta_coefficients(B: Mat, t: Sequence[Rat], cutoff: Rat,
                       radius: int = 8) -> Dict[Rat, int]:
    """
    The shifted theta coefficients r_t(c) = #{m in L : Q(t-m) = c} for all
    c <= cutoff.

    The enumeration box must be large enough that every lattice point with
    Q(t-m) <= cutoff lies inside it; otherwise truncation would corrupt the
    counts.  For a diagonal form with entries a_i >= 1 and |t_i| <= 2 a radius
    of 8 is safe for cutoff <= 16, since a_i (t_i - m_i)^2 <= cutoff forces
    |m_i| <= |t_i| + sqrt(cutoff / a_i).
    """
    n = len(B)
    counts: Dict[Rat, int] = {}
    for m in lattice_points(n, radius):
        value = form(B, tuple(t[i] - m[i] for i in range(n)))
        if value <= cutoff:
            counts[value] = counts.get(value, 0) + 1
    return dict(sorted(counts.items()))


# ---------------------------------------------------------------------------
# Characteristic vectors
# ---------------------------------------------------------------------------

def is_characteristic(B: Mat, v: Sequence[int]) -> bool:
    """
    Test the O(n^2) criterion  (Bv)_i = B_ii  (mod 2)  for all i, which is
    equivalent to  u -> Bil(v,u) + Q(u)  being everywhere even.
    """
    n = len(B)
    for i in range(n):
        row_dot = sum(int(B[i][j]) * v[j] for j in range(n))
        if (row_dot - int(B[i][i])) % 2 != 0:
            return False
    return True


def is_characteristic_bruteforce(B: Mat, v: Sequence[int], radius: int = 2) -> bool:
    """Direct test of the definition on a box of lattice vectors u."""
    n = len(B)
    for u in lattice_points(n, radius):
        uq = tuple(Fraction(c) for c in u)
        vq = tuple(Fraction(c) for c in v)
        if (bil(B, vq, uq) + form(B, uq)) % 2 != 0:
            return False
    return True


def mod8_defect(B: Mat, v: Sequence[int], radius: int = 2) -> Set[int]:
    """The set of residues  (Q(v + 2u) - Q(v)) mod 8  over a box of u."""
    n = len(B)
    vq = tuple(Fraction(c) for c in v)
    qv = form(B, vq)
    residues: Set[int] = set()
    for u in lattice_points(n, radius):
        shifted = tuple(vq[i] + 2 * u[i] for i in range(n))
        residues.add(int(form(B, shifted) - qv) % 8)
    return residues


# ---------------------------------------------------------------------------
# Combinatorial predictions
# ---------------------------------------------------------------------------

def step_shift(n: int, support: Sequence[int]) -> Vec:
    """The 0 / 1-2 representative of a 2-torsion class supported on `support`."""
    s = set(support)
    return tuple(Fraction(1, 2) if i in s else Fraction(0) for i in range(n))


def predicted_diagonal_gap(coeffs: Sequence[Rat], support: Sequence[int]) -> Rat:
    """Weighted Hamming weight prediction  (sum_{i in s} a_i) / 4."""
    return sum((Fraction(coeffs[i]) for i in support), Fraction(0)) / 4


def diagonal_gap_spectrum(coeffs: Sequence[Rat]) -> List[Rat]:
    """The full 2-torsion gap spectrum of a positive diagonal form."""
    n = len(coeffs)
    spectrum: Set[Rat] = set()
    for size in range(1, n + 1):
        for support in combinations(range(n), size):
            spectrum.add(predicted_diagonal_gap(coeffs, support))
    return sorted(spectrum)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_torsion_gap() -> None:
    banner("1. Torsion gap:  mu(v/r) = lambda_1 / r^2  (and its sharpness)")
    forms: List[Tuple[str, Mat]] = [
        ("Z^2 standard  x^2 + y^2", identity(2)),
        ("hexagonal     x^2 + xy + y^2", mat([[1, Fraction(1, 2)], [Fraction(1, 2), 1]])),
        ("2x^2 + 2xy + 3y^2", mat([[2, 1], [1, 3]])),
        ("x^2 + 5y^2", diagonal([1, 5])),
        ("3x^2 + 4xy + 7y^2", mat([[3, 2], [2, 7]])),
        ("5x^2 + 8xy + 9y^2", mat([[5, 4], [4, 9]])),
        ("Z^3 standard", identity(3)),
    ]
    print(f"{'form':<28}{'lambda_1':>10}{'r':>4}{'mu(v/r)':>12}{'lam/r^2':>12}  ok")
    for name, B in forms:
        n = len(B)
        lam = minimal_lattice_energy(B, radius=3)
        # a shortest vector, found by the same bounded search
        shortest = next(m for m in lattice_points(n, 3)
                        if any(m) and form(B, tuple(Fraction(c) for c in m)) == lam)
        for r in (2, 3):
            t = tuple(Fraction(c, r) for c in shortest)
            mu = spectral_gap(B, t, radius=4)
            predicted = lam / (r * r)
            flag = "yes" if mu == predicted else "NO"
            print(f"{name:<28}{str(lam):>10}{r:>4}{str(mu):>12}{str(predicted):>12}  {flag}")
    print()
    print("The naive guess mu >= lambda_1 fails in every row: mu is exactly")
    print("lambda_1 / r^2, a factor r^2 smaller.  The constant cannot be improved.")


def demo_rigidity() -> None:
    banner("2. Rigidity: mu(t) = lambda_1/4 exactly on the extremal 2-torsion classes")
    B = diagonal([1, 5])           # Q(x,y) = x^2 + 5 y^2,  lambda_1 = 1
    lam = minimal_lattice_energy(B, radius=3)
    print(f"Q(x,y) = x^2 + 5 y^2,  lambda_1 = {lam}")
    print(f"{'2-torsion class t':<22}{'mu(t)':>10}{'lam/4':>10}  extremal?")
    for support in [(0,), (1,), (0, 1)]:
        t = step_shift(2, support)
        mu = spectral_gap(B, t, radius=3)
        extremal = "yes" if mu == lam / 4 else "no"
        pretty = "(" + ", ".join(str(c) for c in t) + ")"
        print(f"{pretty:<22}{str(mu):>10}{str(lam / 4):>10}  {extremal}")
    print()
    print("Only the class of (1/2, 0) -- i.e. half of the shortest vector (1,0) --")
    print("attains lambda_1/4.  The other classes sit strictly higher, and the")
    print("second-gap theorem explains the jump: the next value uses lambda_2 = 5.")


def demo_unsolvability() -> None:
    banner("3. Sharpened Diophantine unsolvability")
    n = 3
    print("Equation:   x1^2 + x2^2 + x3^2 - x1 - x2 - x3 + c = 0")
    print("Completing the square gives  sum_i (x_i - 1/2)^2 + c - 3/4 = 0.")
    print()
    print("Here the completing shift is s = -(1,1,1)/2, so Q(s) = 3/4, and the")
    print("spectral gap at -s = (1/2,1/2,1/2) is mu = 3/4 as well (the deep hole).")
    print()
    print("classical archimedean test : unsolvable when c > Q(s)         = 3/4")
    print("lattice-refined test       : unsolvable when c > Q(s) - mu(-s) = 0")
    print("improvement                : exactly the spectral gap mu(-s)   = 3/4")
    print()
    print(f"{'c':>6}{'exists x with F(x)=0?':>26}{'archimedean rejects?':>24}")
    for c in range(-4, 4):
        found = any(
            sum(xi * xi - xi for xi in x) + c == 0
            for x in lattice_points(n, 3)
        )
        rejects = "yes" if Fraction(c) > Fraction(3, 4) else "no"
        print(f"{c:>6}{('YES' if found else 'no'):>26}{rejects:>24}")
    print()
    print("Solutions exist only for c in {0, -2, -4, ...}: the lattice test rules out")
    print("every c > 0, and the mod-8 law additionally rules out every odd c.")


def demo_characteristic() -> None:
    banner("4. Characteristic vectors and the law modulo 8")
    tests: List[Tuple[str, Mat, IVec]] = [
        ("Z^3, v = (1,1,1)", identity(3), (1, 1, 1)),
        ("Z^3, v = (1,1,0)", identity(3), (1, 1, 0)),
        ("Z^3, v = (3,1,1)", identity(3), (3, 1, 1)),
        ("Z^2, v = (1,1)", identity(2), (1, 1)),
        ("Z^2, v = (0,0)", identity(2), (0, 0)),
        ("[[2,1],[1,2]], v = (0,0)", mat([[2, 1], [1, 2]]), (0, 0)),
        ("[[2,1],[1,2]], v = (1,0)", mat([[2, 1], [1, 2]]), (1, 0)),
    ]
    print(f"{'case':<28}{'char? (O(n^2))':>16}{'char? (brute)':>15}"
          f"{'residues of Q(v+2u)-Q(v) mod 8':>34}")
    for name, B, v in tests:
        fast = is_characteristic(B, v)
        slow = is_characteristic_bruteforce(B, v, radius=2)
        residues = sorted(mod8_defect(B, v, radius=2))
        assert fast == slow, "the O(n^2) criterion must agree with the definition"
        print(f"{name:<28}{str(fast):>16}{str(slow):>15}{str(residues):>34}")
    print()
    print("Reading: v is characteristic  <=>  the residue set is exactly {0}.")
    print("A non-characteristic v always produces the residue 4, which halves the")
    print("gap in the value spectrum from 2 down to 1.")


def demo_deep_hole() -> None:
    banner("5. The deep-hole spectrum of Z^n lies in n/4 + 2 Z_{>=0}")
    for n in (1, 2, 3, 4):
        B = identity(n)
        t = tuple(Fraction(1, 2) for _ in range(n))
        spectrum = value_spectrum(B, t, radius=2)
        residues = sorted({int(4 * value - n) % 8 for value in spectrum})
        gaps = sorted({spectrum[i + 1] - spectrum[i] for i in range(len(spectrum) - 1)})
        print(f"n = {n}:  values = {[str(s) for s in spectrum[:5]]} ...")
        print(f"         (4*value - n) mod 8 = {residues}   "
              f"consecutive gaps = {[str(g) for g in gaps]}")
    print()
    print("Every gap is an even integer, hence at least 2 (not 1/4): a sum of n odd")
    print("squares is congruent to n mod 8, because (2k-1)^2 = 8*C(k,2) + 1.")
    print("Equivalently, the all-ones vector is characteristic for the standard form.")


def demo_weight_enumerator() -> None:
    banner("6. Gap spectrum: Hamming weight (standard) and weighted weight (diagonal)")
    print("Standard form on Z^n:  mu at a 2-torsion class = (Hamming weight)/4")
    for n in (2, 3, 4):
        B = identity(n)
        observed: Set[Rat] = set()
        agree = True
        for size in range(1, n + 1):
            for support in combinations(range(n), size):
                t = step_shift(n, support)
                mu = spectral_gap(B, t, radius=2)
                observed.add(mu)
                if mu != Fraction(size, 4):
                    agree = False
        predicted = [Fraction(k, 4) for k in range(1, n + 1)]
        print(f"  n = {n}: spectrum = {[str(x) for x in sorted(observed)]}"
              f"   predicted {{k/4}} = {[str(x) for x in predicted]}"
              f"   match: {sorted(observed) == predicted and agree}")
    print()
    print("Diagonal form Q(x) = sum a_i x_i^2:  mu = (sum_{i in s} a_i)/4")
    for coeffs in ([1, 2], [1, 3, 5], [2, 2, 7]):
        B = diagonal(coeffs)
        n = len(coeffs)
        ok = True
        for size in range(1, n + 1):
            for support in combinations(range(n), size):
                t = step_shift(n, support)
                mu = spectral_gap(B, t, radius=3)
                if mu != predicted_diagonal_gap([Fraction(c) for c in coeffs], support):
                    ok = False
        spectrum = diagonal_gap_spectrum([Fraction(c) for c in coeffs])
        lam = minimal_lattice_energy(B, radius=3)
        print(f"  a = {coeffs}: spectrum = {[str(x) for x in spectrum]}"
              f"   all classes match: {ok}")
        print(f"      min = {spectrum[0]} = lambda_1/4 = {lam / 4}"
              f"   |   max = {spectrum[-1]} = (sum a_i)/4"
              f" = {sum(Fraction(c) for c in coeffs) / 4}")
    print()
    print("A single formula interpolates between the packing invariant lambda_1/4")
    print("(weight one) and the covering invariant (sum a_i)/4 (full weight).")


def demo_parity() -> None:
    banner("7. Parity of shifted theta coefficients, and the rank-two counterexample")
    print("(a) 2-torsion shift of Z^2: every coefficient is even")
    B = identity(2)
    t_torsion = (Fraction(1, 2), Fraction(1, 2))
    coeffs = theta_coefficients(B, t_torsion, cutoff=Fraction(16), radius=8)
    shown = list(coeffs.items())[:6]
    print("    t = (1/2, 1/2):  " +
          ",  ".join(f"r_t({c}) = {k}" for c, k in shown) + ", ...")
    print(f"    all even: {all(k % 2 == 0 for k in coeffs.values())}")
    print()
    print("(b) rank one, non-half-integral shift: the bottom coefficient is 1")
    B1 = identity(1)
    coeffs1 = theta_coefficients(B1, (Fraction(1, 3),), cutoff=Fraction(16), radius=8)
    bottom = min(coeffs1)
    print(f"    t = 1/3:  bottom value {bottom} has multiplicity {coeffs1[bottom]} (odd)")
    print()
    print("(c) THE COUNTEREXAMPLE: t = (1/2, 1/3) in Z^2")
    t_bad = (Fraction(1, 2), Fraction(1, 3))
    coeffs_bad = theta_coefficients(B, t_bad, cutoff=Fraction(16), radius=8)
    all_even = all(k % 2 == 0 for k in coeffs_bad.values())
    two_t_integral = all((2 * c).denominator == 1 for c in t_bad)
    print(f"    all coefficients even : {all_even}")
    print(f"    2t = (1, 2/3) in Z^2  : {two_t_integral}")
    print("    So 'all coefficients even => 2t in L' is FALSE in rank two.")
    print("    The witness is the partial reflection (m1, m2) -> (1 - m1, m2):")
    print("    fixed-point free, and it preserves the form since the first")
    print("    coordinate of t is half-integral.")
    print()
    print("(d) the corrected criterion (diagonal forms):")
    print("    all coefficients even  <=>  some single coordinate t_i is half-integral")
    cases: List[Tuple[Vec, Sequence[int]]] = [
        ((Fraction(1, 2), Fraction(1, 3)), [1, 1]),
        ((Fraction(1, 3), Fraction(1, 4)), [1, 1]),
        ((Fraction(1, 3), Fraction(3, 2)), [1, 5]),
        ((Fraction(1, 5), Fraction(2, 5)), [1, 5]),
    ]
    print(f"    {'t':<24}{'a':<12}{'all even':>10}{'some t_i half-integral':>26}")
    for t, coeff_list in cases:
        Bd = diagonal(coeff_list)
        table = theta_coefficients(Bd, t, cutoff=Fraction(16), radius=8)
        even = all(k % 2 == 0 for k in table.values())
        half = any((c - Fraction(1, 2)).denominator == 1 for c in t)
        pretty = "(" + ", ".join(str(c) for c in t) + ")"
        assert even == half, "criterion must hold"
        print(f"    {pretty:<24}{str(coeff_list):<12}{str(even):>10}{str(half):>26}")


def demo_invariance() -> None:
    banner("8. GL_n(Z)-invariance: reduction does not change any invariant")
    B = mat([[2, 1], [1, 3]])
    U = mat([[1, 2], [0, 1]])          # unimodular, det = 1
    BU = congruent(B, U)
    lam_B = minimal_lattice_energy(B, radius=4)
    lam_BU = minimal_lattice_energy(BU, radius=4)
    print(f"B      = {[[str(x) for x in row] for row in B]},  lambda_1 = {lam_B}")
    print(f"U^T B U= {[[str(x) for x in row] for row in BU]},  lambda_1 = {lam_BU}")
    print(f"minimal lattice energy preserved: {lam_B == lam_BU}")
    print()
    print(f"{'t':<18}{'mu_{U^T B U}(t)':>18}{'mu_B(U t)':>14}  equal?")
    shifts: List[Vec] = [
        (Fraction(1, 2), Fraction(0)),
        (Fraction(0), Fraction(1, 2)),
        (Fraction(1, 2), Fraction(1, 2)),
        (Fraction(1, 3), Fraction(2, 3)),
    ]
    for t in shifts:
        left = spectral_gap(BU, t, radius=5)
        right = spectral_gap(B, apply_mat(U, t), radius=5)
        pretty = "(" + ", ".join(str(c) for c in t) + ")"
        print(f"{pretty:<18}{str(left):>18}{str(right):>14}  {left == right}")
    print()
    print("Every quantity in the theory is an invariant of the pair (lattice, form),")
    print("not of a chosen basis -- which is what licenses lattice reduction.")


def main() -> None:
    print(__doc__)
    demo_torsion_gap()
    demo_rigidity()
    demo_unsolvability()
    demo_characteristic()
    demo_deep_hole()
    demo_weight_enumerator()
    demo_parity()
    demo_invariance()
    banner("All demonstrations completed with exact rational arithmetic.")


if __name__ == "__main__":
    main()
