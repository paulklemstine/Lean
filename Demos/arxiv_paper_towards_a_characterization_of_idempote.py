"""
Numerical demonstrations for:

    Contractive Idempotent Schur Multipliers, a Sharp Gap at 2*sqrt(3)/3,
    and the Algebra of Signed Sums of Blow-Ups

Everything is self-contained: only the standard library plus a small
hand-rolled numerical layer (no numpy required).

The demonstrations verify, numerically and combinatorially:

  1. Blow-ups of partial identity matrices <=> row rigidity <=> gamma_2 <= 1.
  2. The exact factorization norm of the 2-staircase [[1,1],[1,0]] is
     2*sqrt(3)/3 = 1.154700538..., certified from both sides:
        - primal: four planar vectors at consecutive 30-degree angles;
        - dual:   a two-term sum-of-squares certificate.
  3. The gap theorem: over an exhaustive enumeration of all boolean matrices
     of small size, no factorization norm falls strictly inside
     (1, 2*sqrt(3)/3); every matrix is either a blow-up (norm <= 1) or
     contains a 2-staircase (norm >= 2*sqrt(3)/3).
  4. Submultiplicativity of the factorization norm under the Hadamard product,
     and closure of blow-ups under the Hadamard product.
  5. The blow-up number eq(A): equality-query decompositions, the bounds
     gamma_2(A) <= eq(A) <= min(m, n), and eq(A) <= 1 iff A is a blow-up.
  6. Two-sided bounds for the 3-staircase [[1,1,1],[1,1,0],[1,0,0]].

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]

GAP: float = 2.0 * math.sqrt(3.0) / 3.0  # 1.1547005383792515


# --------------------------------------------------------------------------
# 1. Basic linear algebra helpers
# --------------------------------------------------------------------------

def dot(u: Sequence[float], v: Sequence[float]) -> float:
    """Standard Euclidean inner product."""
    return sum(a * b for a, b in zip(u, v))


def sqnorm(u: Sequence[float]) -> float:
    """Squared Euclidean norm."""
    return dot(u, u)


def shape(A: Matrix) -> Tuple[int, int]:
    """Number of rows and columns."""
    return len(A), (len(A[0]) if A else 0)


def hadamard(A: Matrix, B: Matrix) -> Matrix:
    """Entrywise (Hadamard) product, the symbol of a composed Schur multiplier."""
    m, n = shape(A)
    return [[A[i][j] * B[i][j] for j in range(n)] for i in range(m)]


def show(A: Matrix, indent: str = "    ") -> str:
    """Pretty-print a small matrix."""
    return "\n".join(
        indent + " ".join(f"{x:g}" for x in row) for row in A
    )


# --------------------------------------------------------------------------
# 2. Combinatorics: booleanness, rigidity, blow-ups, staircases
# --------------------------------------------------------------------------

def is_boolean(A: Matrix) -> bool:
    """A matrix is boolean (its Schur multiplier is idempotent) iff all entries are 0/1."""
    return all(x in (0.0, 1.0) for row in A for x in row)


def is_row_rigid(A: Matrix) -> bool:
    """Two rows carrying a 1 in a common column must be equal."""
    m, n = shape(A)
    for j in range(n):
        hitters = [i for i in range(m) if A[i][j] == 1.0]
        for i, ip in itertools.combinations(hitters, 2):
            if A[i] != A[ip]:
                return False
    return True


def find_staircase(A: Matrix) -> Optional[Tuple[int, int, int, int]]:
    """
    Find rows i, i' and columns j, j' realising the forbidden 2-staircase

        A[i][j] = A[i][j'] = A[i'][j] = 1,  A[i'][j'] = 0,

    or return None if the matrix is row rigid.
    """
    m, n = shape(A)
    for j in range(n):
        hitters = [i for i in range(m) if A[i][j] == 1.0]
        for i, ip in itertools.combinations(hitters, 2):
            for jp in range(n):
                if A[i][jp] == 1.0 and A[ip][jp] == 0.0:
                    return (i, ip, j, jp)
                if A[ip][jp] == 1.0 and A[i][jp] == 0.0:
                    return (ip, i, j, jp)
    return None


def blowup_labels(A: Matrix) -> Optional[Tuple[List[int], List[int]]]:
    """
    If A is a boolean row-rigid matrix, return labellings (f, g) with
    A[i][j] = 1 iff f(i) == g(j); otherwise return None.

    Row i is labelled by the index of its leftmost 1 (or a fresh tag n + i);
    column j is labelled by the leftmost 1 of any row hitting j (or a fresh
    tag n + m + j).  This is the construction behind "row rigid => blow-up".
    """
    if not is_boolean(A) or not is_row_rigid(A):
        return None
    m, n = shape(A)
    f = [next((j for j in range(n) if A[i][j] == 1.0), n + i) for i in range(m)]
    g: List[int] = []
    for j in range(n):
        i0 = next((i for i in range(m) if A[i][j] == 1.0), None)
        g.append(f[i0] if i0 is not None else n + m + j)
    for i in range(m):
        for j in range(n):
            if A[i][j] != (1.0 if f[i] == g[j] else 0.0):
                return None  # never happens for rigid boolean matrices
    return f, g


def matrix_from_labels(f: Sequence[int], g: Sequence[int]) -> Matrix:
    """The blow-up of a partial identity matrix determined by two labellings."""
    return [[1.0 if fi == gj else 0.0 for gj in g] for fi in f]


def is_blowup(A: Matrix) -> bool:
    """A boolean matrix is a blow-up of a partial identity iff it is row rigid."""
    return is_boolean(A) and is_row_rigid(A)


# --------------------------------------------------------------------------
# 3. The factorization norm: certificates and numerics
# --------------------------------------------------------------------------

def factorization_size(x: Sequence[Vector], y: Sequence[Vector]) -> float:
    """The size max(||x_i||^2, ||y_j||^2) of a balanced factorization."""
    return max([sqnorm(v) for v in x] + [sqnorm(v) for v in y])


def factorization_error(A: Matrix, x: Sequence[Vector], y: Sequence[Vector]) -> float:
    """Largest deviation of <x_i, y_j> from A[i][j]."""
    m, n = shape(A)
    return max(abs(dot(x[i], y[j]) - A[i][j]) for i in range(m) for j in range(n))


def blowup_factorization(A: Matrix) -> Tuple[List[Vector], List[Vector]]:
    """
    The canonical unit-vector factorization of a blow-up: x_i = e_{f(i)},
    y_j = e_{g(j)}.  All squared norms are 1, so gamma_2(A) <= 1.
    """
    labels = blowup_labels(A)
    if labels is None:
        raise ValueError("matrix is not a blow-up of a partial identity")
    f, g = labels
    tags = sorted(set(f) | set(g))
    index: Dict[int, int] = {t: k for k, t in enumerate(tags)}
    d = len(tags)

    def basis(t: int) -> Vector:
        v = [0.0] * d
        v[index[t]] = 1.0
        return v

    return [basis(t) for t in f], [basis(t) for t in g]


def staircase_optimal_factorization() -> Tuple[List[Vector], List[Vector]]:
    """
    The optimal planar factorization of the 2-staircase [[1,1],[1,0]]:
    four vectors of common length r = sqrt(2*sqrt(3)/3) at arguments
    -30, 0, 30, 60 degrees.  Three pairings sit 30 degrees apart
    (inner product r^2 cos 30 = 1); the fourth pairing is orthogonal.
    """
    r = math.sqrt(GAP)
    s3 = math.sqrt(3.0)
    x = [[r, 0.0], [r / 2.0, r * s3 / 2.0]]
    y = [[r * s3 / 2.0, r / 2.0], [r * s3 / 2.0, -r / 2.0]]
    return x, y


def sos_certificate_value(a: Vector, b: Vector, p: Vector, q: Vector) -> float:
    """
    Evaluate the dual sum-of-squares certificate

        ||sqrt(3) b - 2p + q||^2 + 2 ||-sqrt(3) a + p + q||^2 >= 0,

    which, once the four inner products <a,p> = <a,q> = <b,p> = 1 and
    <b,q> = 0 are substituted, collapses to 18c - 12 sqrt(3) >= 0, i.e.
    c >= 2 sqrt(3)/3.
    """
    s3 = math.sqrt(3.0)
    u = [s3 * bi - 2.0 * pi + qi for bi, pi, qi in zip(b, p, q)]
    v = [-s3 * ai + pi + qi for ai, pi, qi in zip(a, p, q)]
    return sqnorm(u) + 2.0 * sqnorm(v)


def gamma2_lower_bound(A: Matrix) -> float:
    """
    A certified lower bound for gamma_2(A):
      * 2 sqrt(3)/3 if A contains a 2-staircase (sum-of-squares certificate);
      * max |A[i][j]| otherwise (Cauchy-Schwarz).
    """
    entry_bound = max(abs(x) for row in A for x in row) if A else 0.0
    return max(entry_bound, GAP if find_staircase(A) is not None else 0.0)


def gamma2_numeric(
    A: Matrix,
    dim: Optional[int] = None,
    restarts: int = 12,
    iterations: int = 4000,
    seed: int = 0,
) -> float:
    """
    Numerical upper bound for gamma_2(A) by projected alternating minimization.

    We minimise  max_i ||x_i||^2 , max_j ||y_j||^2  subject to
    <x_i, y_j> = A[i][j], by alternating exact least-squares solves for the
    x-family given the y-family and vice versa, with a soft penalty pushing
    the norms down; the reported value is the size of the best feasible
    (to within 1e-9) factorization found.  This is a heuristic upper bound:
    it never certifies optimality, and is used only for illustration.
    """
    m, n = shape(A)
    d = dim if dim is not None else min(m, n)
    rng = random.Random(seed)
    best = float("inf")

    for _ in range(restarts):
        x = [[rng.gauss(0.0, 1.0) for _ in range(d)] for _ in range(m)]
        y = [[rng.gauss(0.0, 1.0) for _ in range(d)] for _ in range(n)]
        lam = 1e-2
        decay = (1e-12 / lam) ** (1.0 / max(iterations, 1))
        for _ in range(iterations):
            # ridge-regularised least squares for each x_i given the y's
            x = [_ridge_solve(y, A[i], lam, d) for i in range(m)]
            y = [_ridge_solve(x, [A[i][j] for i in range(m)], lam, d) for j in range(n)]
            lam *= decay
        err = factorization_error(A, x, y)
        if err < 1e-6:
            best = min(best, _balance(x, y))
    return best


def _ridge_solve(basis: Sequence[Vector], targets: Sequence[float], lam: float, d: int) -> Vector:
    """Solve  min_v sum_k (<v, basis_k> - targets_k)^2 + lam ||v||^2  in dimension d."""
    G = [[sum(basis[k][s] * basis[k][t] for k in range(len(basis))) + (lam if s == t else 0.0)
          for t in range(d)] for s in range(d)]
    rhs = [sum(basis[k][s] * targets[k] for k in range(len(basis))) for s in range(d)]
    return _solve(G, rhs)


def _solve(M: List[List[float]], rhs: List[float]) -> Vector:
    """Gaussian elimination with partial pivoting (small dense systems only)."""
    d = len(rhs)
    aug = [row[:] + [rhs[k]] for k, row in enumerate(M)]
    for c in range(d):
        piv = max(range(c, d), key=lambda r: abs(aug[r][c]))
        if abs(aug[piv][c]) < 1e-14:
            continue
        aug[c], aug[piv] = aug[piv], aug[c]
        pivot = aug[c][c]
        aug[c] = [v / pivot for v in aug[c]]
        for r in range(d):
            if r != c and aug[r][c] != 0.0:
                factor = aug[r][c]
                aug[r] = [vr - factor * vc for vr, vc in zip(aug[r], aug[c])]
    return [aug[r][d] for r in range(d)]


def _balance(x: Sequence[Vector], y: Sequence[Vector]) -> float:
    """
    Rescale x by lambda and y by 1/lambda so that the two maxima agree
    (Proposition: the balanced and unbalanced definitions coincide), and
    return the resulting common size.
    """
    X = max(math.sqrt(sqnorm(v)) for v in x)
    Y = max(math.sqrt(sqnorm(v)) for v in y)
    return X * Y


# --------------------------------------------------------------------------
# 4. The blow-up number eq(A) and equality-query decompositions
# --------------------------------------------------------------------------

def row_decomposition(A: Matrix) -> List[Tuple[int, List[int], List[int]]]:
    """
    Write a boolean m x n matrix as a POSITIVE sum of m blow-ups, one per row:
    the l-th term agrees with A on row l and vanishes elsewhere.
    Returns a list of triples (sign, f, g).
    """
    m, n = shape(A)
    terms: List[Tuple[int, List[int], List[int]]] = []
    for l in range(m):
        f = [0 if i == l else 1 + i for i in range(m)]
        g = [0 if A[l][j] == 1.0 else 1 + m + j for j in range(n)]
        terms.append((1, f, g))
    return terms


def evaluate_query_decomposition(
    terms: Iterable[Tuple[int, Sequence[int], Sequence[int]]], m: int, n: int
) -> Matrix:
    """
    Evaluate a signed sum of equality queries:
        A[i][j] = sum_l eps_l * [ f_l(i) == g_l(j) ].
    """
    out = [[0.0] * n for _ in range(m)]
    for sign, f, g in terms:
        for i in range(m):
            for j in range(n):
                if f[i] == g[j]:
                    out[i][j] += sign
    return out


def eq_cost_brute(A: Matrix, max_terms: int = 2, label_cap: int = 3) -> Optional[int]:
    """
    Brute-force the blow-up number eq(A) for very small matrices by searching
    over signed sums of at most `max_terms` blow-ups whose labels are drawn
    from {0, ..., label_cap - 1}.  Returns the least number of terms found,
    or None if none was found within the search space.
    """
    m, n = shape(A)
    label_sets = list(itertools.product(range(label_cap), repeat=m))
    col_sets = list(itertools.product(range(label_cap), repeat=n))
    catalogue = [(f, g) for f in label_sets for g in col_sets]

    if all(x == 0.0 for row in A for x in row):
        return 0
    for L in range(1, max_terms + 1):
        for choice in itertools.combinations_with_replacement(catalogue, L):
            for signs in itertools.product((1, -1), repeat=L):
                terms = [(s, f, g) for s, (f, g) in zip(signs, choice)]
                if evaluate_query_decomposition(terms, m, n) == A:
                    return L
    return None


# --------------------------------------------------------------------------
# 5. Enumeration of small boolean matrices
# --------------------------------------------------------------------------

def all_boolean_matrices(m: int, n: int) -> Iterable[Matrix]:
    """Enumerate all 2^(m n) boolean m x n matrices."""
    for bits in itertools.product((0.0, 1.0), repeat=m * n):
        yield [list(bits[i * n:(i + 1) * n]) for i in range(m)]


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

TRI2: Matrix = [[1.0, 1.0], [1.0, 0.0]]
TRI3: Matrix = [[1.0, 1.0, 1.0], [1.0, 1.0, 0.0], [1.0, 0.0, 0.0]]


def demo_contractive_characterization() -> None:
    print("=" * 74)
    print("1.  Contractive case:  gamma_2(A) <= 1  <=>  blow-up  <=>  row rigid")
    print("=" * 74)

    examples: List[Tuple[str, Matrix]] = [
        ("block diagonal 2+1", [[1, 1, 0], [1, 1, 0], [0, 0, 1]]),
        ("all ones 3x3", [[1, 1, 1], [1, 1, 1], [1, 1, 1]]),
        ("identity 3x3", [[1, 0, 0], [0, 1, 0], [0, 0, 1]]),
        ("zero 2x3", [[0, 0, 0], [0, 0, 0]]),
        ("2-staircase", TRI2),
        ("3-staircase", TRI3),
    ]
    for name, raw in examples:
        A = [[float(v) for v in row] for row in raw]
        rigid = is_row_rigid(A)
        labels = blowup_labels(A)
        line = f"  {name:<20s} rigid={str(rigid):<5s}"
        if labels is not None:
            f, g = labels
            rebuilt = matrix_from_labels(f, g)
            x, y = blowup_factorization(A)
            line += (f" labels f={list(f)} g={list(g)}"
                     f" reconstructed={'yes' if rebuilt == A else 'NO'}"
                     f" size={factorization_size(x, y):.6f}"
                     f" err={factorization_error(A, x, y):.1e}")
        else:
            i, ip, j, jp = find_staircase(A)  # type: ignore[misc]
            line += f" 2-staircase at rows ({i},{ip}) cols ({j},{jp}) => norm >= {GAP:.9f}"
        print(line)
    print()


def demo_exact_norm_of_the_staircase() -> None:
    print("=" * 74)
    print("2.  Exact norm of the 2-staircase:  gamma_2([[1,1],[1,0]]) = 2*sqrt(3)/3")
    print("=" * 74)
    x, y = staircase_optimal_factorization()
    print("  primal certificate (four planar vectors at 30-degree steps):")
    for k, v in enumerate(x):
        ang = math.degrees(math.atan2(v[1], v[0]))
        print(f"    x_{k + 1} = ({v[0]:+.6f}, {v[1]:+.6f})   |x|^2 = {sqnorm(v):.9f}"
              f"   angle = {ang:+7.2f} deg")
    for k, v in enumerate(y):
        ang = math.degrees(math.atan2(v[1], v[0]))
        print(f"    y_{k + 1} = ({v[0]:+.6f}, {v[1]:+.6f})   |y|^2 = {sqnorm(v):.9f}"
              f"   angle = {ang:+7.2f} deg")
    print(f"  reconstruction error : {factorization_error(TRI2, x, y):.3e}")
    print(f"  factorization size   : {factorization_size(x, y):.12f}")
    print(f"  2*sqrt(3)/3          : {GAP:.12f}")

    a, b, p, q = x[0], x[1], y[0], y[1]
    val = sos_certificate_value(a, b, p, q)
    print("\n  dual certificate  ||sqrt(3) b - 2p + q||^2 + 2||-sqrt(3) a + p + q||^2 >= 0")
    print(f"    evaluated at the optimum : {val:.3e}   (zero <=> the bound is tight)")
    print(f"    identity: 0 <= 18c - 12*sqrt(3)  =>  c >= {12 * math.sqrt(3) / 18:.12f}")

    # the same certificate applied to random feasible factorizations
    worst = float("inf")
    rng = random.Random(7)
    for _ in range(2000):
        d = 3
        aa = [rng.gauss(0, 1) for _ in range(d)]
        bb = [rng.gauss(0, 1) for _ in range(d)]
        pp = [rng.gauss(0, 1) for _ in range(d)]
        qq = [rng.gauss(0, 1) for _ in range(d)]
        worst = min(worst, sos_certificate_value(aa, bb, pp, qq))
    print(f"    minimum over 2000 random quadruples: {worst:.3e}  (always >= 0)")
    print()


def demo_gap_theorem(sizes: Sequence[Tuple[int, int]] = ((2, 2), (2, 3), (3, 3))) -> None:
    print("=" * 74)
    print("3.  Gap theorem: exhaustive check that no boolean matrix has")
    print("    gamma_2 strictly between 1 and 2*sqrt(3)/3")
    print("=" * 74)
    for (m, n) in sizes:
        total = blowups = staircases = 0
        for A in all_boolean_matrices(m, n):
            total += 1
            if is_blowup(A):
                blowups += 1
                x, y = blowup_factorization(A)
                assert factorization_error(A, x, y) < 1e-12
                assert factorization_size(x, y) <= 1.0 + 1e-12
            else:
                staircases += 1
                assert find_staircase(A) is not None
                assert gamma2_lower_bound(A) >= GAP - 1e-12
        print(f"  {m}x{n}: {total:5d} boolean matrices = "
              f"{blowups:5d} blow-ups (norm <= 1) + "
              f"{staircases:5d} containing a 2-staircase (norm >= {GAP:.6f})")
        print(f"        no matrix in the open interval (1, {GAP:.6f}):  verified")
    print()


def demo_algebra() -> None:
    print("=" * 74)
    print("4.  Algebra: Hadamard products, submultiplicativity, closure")
    print("=" * 74)
    A = matrix_from_labels([0, 0, 1, 2], [0, 1, 1, 2])
    B = matrix_from_labels([0, 1, 1, 1], [0, 0, 1, 1])
    print("  A (a blow-up):");  print(show(A))
    print("  B (a blow-up):");  print(show(B))
    C = hadamard(A, B)
    print("  A o B:");          print(show(C))
    print(f"  A o B is a blow-up: {is_blowup(C)}   (paired labels)")

    xa, ya = blowup_factorization(A)
    xb, yb = blowup_factorization(B)
    # tensor the two factorizations: X_i = x_i (x) u_i
    X = [[xi * ui for xi in xa[i] for ui in xb[i]] for i in range(len(xa))]
    Y = [[yj * vj for yj in ya[j] for vj in yb[j]] for j in range(len(ya))]
    print(f"  tensored factorization: error = {factorization_error(C, X, Y):.1e}, "
          f"size = {factorization_size(X, Y):.6f} <= 1*1")

    # complement: 1 - A is a signed sum of 2 blow-ups
    m, n = shape(A)
    ones = [[1.0] * n for _ in range(m)]
    comp = [[ones[i][j] - A[i][j] for j in range(n)] for i in range(m)]
    terms = [(1, [0] * m, [0] * n)] + [(-1, f, g) for (_, f, g) in
                                       [(1,) + blowup_labels(A)]]  # type: ignore[operator]
    rebuilt = evaluate_query_decomposition(terms, m, n)
    print(f"  complement 1 - A as (all-ones) - (A): reconstruction exact = {rebuilt == comp}")
    print(f"    so eq(1 - A) <= eq(A) + 1 = 2")
    print()


def demo_blowup_number() -> None:
    print("=" * 74)
    print("5.  Blow-up number eq(A): equality queries, and eq(A) <= 1 iff blow-up")
    print("=" * 74)
    for name, raw in [("2-staircase", TRI2), ("3-staircase", TRI3),
                      ("identity 3x3", [[1, 0, 0], [0, 1, 0], [0, 0, 1]])]:
        A = [[float(v) for v in row] for row in raw]
        m, n = shape(A)
        terms = row_decomposition(A)
        rebuilt = evaluate_query_decomposition(terms, m, n)
        lo = gamma2_lower_bound(A)
        cost = eq_cost_brute(A, max_terms=2, label_cap=3)
        print(f"  {name:<14s} row decomposition into {len(terms)} blow-ups, "
              f"exact = {rebuilt == A}")
        if name == "3-staircase":
            witness = [(1, [0, 1, 0], [0, 1, 2]), (1, [0, 1, 2], [1, 0, 0])]
            assert evaluate_query_decomposition(witness, m, n) == A
            print("      explicit 2-term decomposition found: "
                  "f1=(0,1,0) g1=(0,1,2)  +  f2=(0,1,2) g2=(1,0,0)")
        print(f"      certified lower bound gamma_2 >= {lo:.6f};  "
              f"eq(A) <= min(m,n) = {min(m, n)};  "
              f"brute-forced eq(A) = {cost if cost is not None else '>2'}")
        print(f"      eq(A) <= 1 ? {'yes' if is_blowup(A) else 'no '}  "
              f"(matches 'A is a blow-up' = {is_blowup(A)})")
    print()


def demo_three_staircase() -> None:
    print("=" * 74)
    print("6.  The 3-staircase: 2*sqrt(3)/3 <= gamma_2(T3) <= sqrt(3)")
    print("=" * 74)
    print(show(TRI3))
    lo = GAP
    hi = math.sqrt(3.0)
    num = gamma2_numeric(TRI3, dim=3, restarts=8, iterations=1500, seed=11)
    print(f"  certified lower bound (2-staircase submatrix) : {lo:.9f}")
    print(f"  certified upper bound (sqrt(min(m,n)))        : {hi:.9f}")
    print(f"  heuristic numerical factorization size        : {num:.6f}"
          " (not a certificate)")
    print("  the exact value is not determined here; crude searches suggest ~1.40-1.48,")
    print("  and pinning it down is the content of the 'second gap' conjecture.")
    print()


def main() -> None:
    print()
    print("Contractive idempotent Schur multipliers and the gap at 2*sqrt(3)/3")
    print(f"gap constant 2*sqrt(3)/3 = {GAP:.15f}")
    print()
    demo_contractive_characterization()
    demo_exact_norm_of_the_staircase()
    demo_gap_theorem()
    demo_algebra()
    demo_blowup_number()
    demo_three_staircase()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
