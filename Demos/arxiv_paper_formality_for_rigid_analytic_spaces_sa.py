"""
Purity implies formality: numerical demonstrations.
====================================================

This self-contained script illustrates, over the rational numbers and with exact
arithmetic, the main results about *weight-graded differential graded algebras*:

  * A weight-graded dga is a bigraded algebra  A = (+)_{(n,w)} A^{n,w}  with a
    differential d that raises the cohomological degree n by one, preserves the
    weight w, squares to zero, and satisfies a Leibniz rule
        d(ab) = (da) b + eps(|a|) a (db)          for a bihomogeneous of degree |a|.

  * PURITY along a line w = alpha * n (alpha > 0) means: H^{n,w} = 0 whenever
    w != alpha * n.

  * THEOREM A (purity => strict formality).  Under purity the weight-wise
    canonical truncation
        A'  = (all of A^{n,w} for n < w) + (cocycles of A^{w,w})
        J   = (all of A^{n,w} for n < w) + (coboundaries of A^{w,w})
    gives a strict zig-zag  A  >=  A'  ->>  A'/J  of quasi-isomorphisms with zero
    differential on A'/J, so A'/J is the cohomology algebra of A.

  * THEOREM B (diagonal strict lift).  The span of the diagonal cocycles
    (bidegree (n, alpha n), killed by d) is a unital subalgebra with zero
    differential which surjects onto H(A).

  * THEOREM D (purity kills triple Massey products).  A Massey representative
    eps(p) u z - x v built from diagonal classes has degree p+q+r-1 but weight
    alpha (p+q+r): its WEIGHT EXCESS w - alpha*n is nonzero, so purity makes it
    exact.

  * THEOREM E (contrapositive).  A genuinely non-vanishing triple Massey product
    forbids any pure weight grading.

Four examples are analysed:

  (T) the "torus" algebra Lambda(x, y), zero differential, weights = degrees:
      pure, hence formal;
  (P) a pure algebra WITH a nonzero differential, whose off-diagonal part is an
      acyclic two-step complex: the truncation model is verified against a direct
      cohomology computation;
  (N) the "Heisenberg" algebra Lambda(x, y, z), dz = xy: the classical non-formal
      model.  Its Massey product <x, y, y> is computed and shown nonzero, purity
      is shown to fail, and the two facts are matched against Theorem E;
  (S) the torus with all weights doubled (alpha = 2, a Tate-twist normalisation):
      pure along w = 2n, illustrating that formality is normalisation-independent.

Only the standard library is used.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from typing import Callable, Dict, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------
# Exact linear algebra over Q
# ----------------------------------------------------------------------------

Vector = List[Fraction]
Matrix = List[Vector]


def row_reduce(rows: Matrix) -> Matrix:
    """Return the row echelon form of `rows` (exact Gaussian elimination)."""
    mat: Matrix = [list(r) for r in rows]
    if not mat:
        return mat
    ncols = len(mat[0])
    pivot_row = 0
    for col in range(ncols):
        pivot = None
        for r in range(pivot_row, len(mat)):
            if mat[r][col] != 0:
                pivot = r
                break
        if pivot is None:
            continue
        mat[pivot_row], mat[pivot] = mat[pivot], mat[pivot_row]
        inv = Fraction(1, 1) / mat[pivot_row][col]
        mat[pivot_row] = [inv * v for v in mat[pivot_row]]
        for r in range(len(mat)):
            if r != pivot_row and mat[r][col] != 0:
                factor = mat[r][col]
                mat[r] = [a - factor * b for a, b in zip(mat[r], mat[pivot_row])]
        pivot_row += 1
        if pivot_row == len(mat):
            break
    return [r for r in mat if any(v != 0 for v in r)]


def rank(rows: Matrix) -> int:
    """Rank of the matrix whose rows are `rows`."""
    return len(row_reduce(rows))


def in_span(vectors: Matrix, target: Vector) -> bool:
    """Decide whether `target` lies in the span of `vectors`."""
    if all(v == 0 for v in target):
        return True
    base = rank(vectors)
    return rank(list(vectors) + [list(target)]) == base


def solve(columns: Matrix, target: Vector) -> Optional[Vector]:
    """Solve sum_j c_j * columns[j] = target; return the coefficients or None."""
    if not columns:
        return [] if all(v == 0 for v in target) else None
    nrows = len(target)
    aug: Matrix = [
        [columns[j][i] for j in range(len(columns))] + [target[i]] for i in range(nrows)
    ]
    red = row_reduce(aug)
    ncols = len(columns)
    coeffs: Vector = [Fraction(0)] * ncols
    for row in red:
        pivot = next((j for j in range(ncols + 1) if row[j] != 0), None)
        if pivot is None:
            continue
        if pivot == ncols:  # 0 = 1, inconsistent
            return None
        coeffs[pivot] = row[ncols]
    # verify
    check = [Fraction(0)] * nrows
    for j, c in enumerate(coeffs):
        if c:
            for i in range(nrows):
                check[i] += c * columns[j][i]
    return coeffs if check == list(target) else None


# ----------------------------------------------------------------------------
# Finite-dimensional weight-graded differential graded algebras
# ----------------------------------------------------------------------------

Element = Dict[str, Fraction]  # sparse: basis name -> coefficient


def elt(**terms: object) -> Element:
    """Build an element from keyword coefficients, e.g. elt(x=1, y=-2)."""
    return {k: Fraction(v) for k, v in terms.items() if Fraction(v) != 0}  # type: ignore[arg-type]


def add(a: Element, b: Element) -> Element:
    out = dict(a)
    for k, v in b.items():
        out[k] = out.get(k, Fraction(0)) + v
        if out[k] == 0:
            del out[k]
    return out


def scale(c: Fraction, a: Element) -> Element:
    if c == 0:
        return {}
    return {k: c * v for k, v in a.items()}


def sub(a: Element, b: Element) -> Element:
    return add(a, scale(Fraction(-1), b))


class WeightedDGA:
    """A finite-dimensional bigraded algebra with a weight-preserving differential.

    `bideg[name] = (degree, weight)`; `prod[(u, v)]` is the product of two basis
    elements; `diff[name]` is the differential of a basis element (absent = 0).
    The Koszul sign is eps(n) = (-1)^n.
    """

    def __init__(
        self,
        name: str,
        basis: Sequence[str],
        bideg: Dict[str, Tuple[int, int]],
        prod: Dict[Tuple[str, str], Element],
        diff: Dict[str, Element],
        unit: str = "1",
    ) -> None:
        self.name = name
        self.basis: List[str] = list(basis)
        self.bideg = bideg
        self.prod = prod
        self.diff = diff
        self.unit = unit
        self.index = {b: i for i, b in enumerate(self.basis)}

    # --- basic operations -------------------------------------------------

    def sign(self, n: int) -> Fraction:
        return Fraction(-1) ** n

    def mul(self, a: Element, b: Element) -> Element:
        out: Element = {}
        for u, cu in a.items():
            for v, cv in b.items():
                term = self.prod.get((u, v), {})
                if term:
                    out = add(out, scale(cu * cv, term))
        return out

    def d(self, a: Element) -> Element:
        out: Element = {}
        for u, cu in a.items():
            term = self.diff.get(u, {})
            if term:
                out = add(out, scale(cu, term))
        return out

    def vec(self, a: Element) -> Vector:
        v: Vector = [Fraction(0)] * len(self.basis)
        for k, c in a.items():
            v[self.index[k]] = c
        return v

    def bideg_of(self, a: Element) -> Optional[Tuple[int, int]]:
        """Bidegree of a bihomogeneous element (None if not bihomogeneous)."""
        degs = {self.bideg[k] for k in a}
        if len(degs) == 1:
            return degs.pop()
        return None

    def piece(self, n: int, w: int) -> List[str]:
        return [b for b in self.basis if self.bideg[b] == (n, w)]

    def bidegrees(self) -> List[Tuple[int, int]]:
        return sorted({self.bideg[b] for b in self.basis})

    # --- sanity checks ----------------------------------------------------

    def check_axioms(self) -> List[str]:
        """Verify bigrading, associativity, d^2 = 0 and the Leibniz rule."""
        problems: List[str] = []
        for u in self.basis:
            for v in self.basis:
                p = self.prod.get((u, v), {})
                nu, wu = self.bideg[u]
                nv, wv = self.bideg[v]
                for k in p:
                    if self.bideg[k] != (nu + nv, wu + wv):
                        problems.append(f"grading: {u}*{v} has term {k}")
        for u in self.basis:
            du = self.diff.get(u, {})
            n, w = self.bideg[u]
            for k in du:
                if self.bideg[k] != (n + 1, w):
                    problems.append(f"differential bidegree: d({u}) has term {k}")
            if self.d(du):
                problems.append(f"d^2 != 0 on {u}")
        for u in self.basis:
            for v in self.basis:
                for t in self.basis:
                    lhs = self.mul(self.mul(elt(**{u: 1}), elt(**{v: 1})), elt(**{t: 1}))
                    rhs = self.mul(elt(**{u: 1}), self.mul(elt(**{v: 1}), elt(**{t: 1})))
                    if lhs != rhs:
                        problems.append(f"associativity: ({u}{v}){t}")
        for u in self.basis:
            n, _ = self.bideg[u]
            for v in self.basis:
                a, b = elt(**{u: 1}), elt(**{v: 1})
                lhs = self.d(self.mul(a, b))
                rhs = add(self.mul(self.d(a), b), scale(self.sign(n), self.mul(a, self.d(b))))
                if lhs != rhs:
                    problems.append(f"Leibniz: d({u}*{v})")
        return sorted(set(problems))


# ----------------------------------------------------------------------------
# Exterior-algebra builder (all generators of cohomological degree 1)
# ----------------------------------------------------------------------------


def exterior_dga(
    name: str,
    gens: Sequence[Tuple[str, int]],
    gen_diff: Dict[str, Dict[Tuple[str, ...], Fraction]],
) -> WeightedDGA:
    """Exterior algebra on odd generators of degree 1 with the given weights.

    `gens` is a list of (generator name, weight); `gen_diff` gives the
    differential of a generator as a combination of *monomials* (tuples of
    generator names, in the order given by `gens`).
    """
    names = [g for g, _ in gens]
    weights = {g: w for g, w in gens}
    order = {g: i for i, g in enumerate(names)}

    def mono_name(m: Tuple[str, ...]) -> str:
        return "1" if not m else "".join(m)

    monos: List[Tuple[str, ...]] = []
    for k in range(len(names) + 1):
        for c in combinations(names, k):
            monos.append(tuple(c))
    basis = [mono_name(m) for m in monos]
    bideg = {
        mono_name(m): (len(m), sum(weights[g] for g in m)) for m in monos
    }

    def mono_mul(m1: Tuple[str, ...], m2: Tuple[str, ...]) -> Tuple[Optional[Tuple[str, ...]], int]:
        """Product of two monomials: (sorted monomial, sign) or (None, 0)."""
        if set(m1) & set(m2):
            return None, 0
        merged = list(m1) + list(m2)
        sign = 1
        # bubble sort, all generators odd => each transposition gives -1
        arr = merged[:]
        for i in range(len(arr)):
            for j in range(len(arr) - 1 - i):
                if order[arr[j]] > order[arr[j + 1]]:
                    arr[j], arr[j + 1] = arr[j + 1], arr[j]
                    sign = -sign
        return tuple(arr), sign

    prod: Dict[Tuple[str, str], Element] = {}
    for m1 in monos:
        for m2 in monos:
            m, s = mono_mul(m1, m2)
            if m is not None:
                prod[(mono_name(m1), mono_name(m2))] = {mono_name(m): Fraction(s)}

    def mono_elt(m: Tuple[str, ...], c: Fraction) -> Element:
        return {mono_name(m): c} if c != 0 else {}

    def mul_elements(a: Element, b: Element, table: Dict[Tuple[str, str], Element]) -> Element:
        out: Element = {}
        for u, cu in a.items():
            for v, cv in b.items():
                t = table.get((u, v), {})
                if t:
                    out = add(out, scale(cu * cv, t))
        return out

    diff: Dict[str, Element] = {}
    for m in monos:
        total: Element = {}
        for j, g in enumerate(m):
            dg = gen_diff.get(g, {})
            if not dg:
                continue
            left = m[:j]
            right = m[j + 1 :]
            piece: Element = {}
            for mm, cc in dg.items():
                piece = add(piece, mono_elt(mm, Fraction(cc)))
            term = mul_elements(mono_elt(left, Fraction(1)), piece, prod)
            term = mul_elements(term, mono_elt(right, Fraction(1)), prod)
            # Koszul sign (-1)^{sum of degrees to the left} = (-1)^j
            total = add(total, scale(Fraction(-1) ** j, term))
        if total:
            diff[mono_name(m)] = total
    return WeightedDGA(name, basis, bideg, prod, diff)


# ----------------------------------------------------------------------------
# Cohomology, purity, truncation, diagonal subalgebra
# ----------------------------------------------------------------------------


def cohomology_dims(A: WeightedDGA) -> Dict[Tuple[int, int], int]:
    """dim H^{n,w} for every bidegree occurring in A."""
    dims: Dict[Tuple[int, int], int] = {}
    for (n, w) in A.bidegrees():
        here = A.piece(n, w)
        images_here = [A.vec(A.d(elt(**{b: 1}))) for b in here]
        ker = len(here) - rank(images_here)
        below = A.piece(n - 1, w)
        im = rank([A.vec(A.d(elt(**{b: 1}))) for b in below]) if below else 0
        if ker - im:
            dims[(n, w)] = ker - im
    return dims


def is_pure(A: WeightedDGA, alpha: int = 1) -> Tuple[bool, List[Tuple[int, int]]]:
    """Purity along w = alpha*n, together with the offending bidegrees."""
    bad = [(n, w) for (n, w), dim in cohomology_dims(A).items() if w != alpha * n and dim]
    return (not bad), sorted(bad)


def truncation_report(A: WeightedDGA, alpha: int = 1) -> List[Tuple[int, int, int, int, int]]:
    """Dimensions of the truncation model, bidegree by bidegree.

    Returns tuples (n, w, dim A'_{n,w}, dim J_{n,w}, dim (A'/J)_{n,w}).
    """
    rows: List[Tuple[int, int, int, int, int]] = []
    for (n, w) in A.bidegrees():
        here = A.piece(n, w)
        d_here = [A.vec(A.d(elt(**{b: 1}))) for b in here]
        below = A.piece(n - 1, w)
        d_below = [A.vec(A.d(elt(**{b: 1}))) for b in below]
        if alpha * n < w:
            dim_sub, dim_idl = len(here), len(here)
        elif alpha * n == w:
            dim_sub = len(here) - rank(d_here)          # cocycles
            dim_idl = rank(d_below)                     # coboundaries
        else:
            dim_sub, dim_idl = 0, 0
        rows.append((n, w, dim_sub, dim_idl, dim_sub - dim_idl))
    return rows


def diagonal_subalgebra(A: WeightedDGA, alpha: int = 1) -> List[Element]:
    """A basis of the span of the diagonal cocycles (bidegree (n, alpha n))."""
    out: List[Element] = []
    for (n, w) in A.bidegrees():
        if w != alpha * n:
            continue
        here = A.piece(n, w)
        if not here:
            continue
        # kernel of d restricted to this piece
        cols = [A.vec(A.d(elt(**{b: 1}))) for b in here]
        nrows = len(A.basis)
        # nullspace by row reduction of the transpose system
        mat = [[cols[j][i] for j in range(len(here))] for i in range(nrows)]
        red = row_reduce(mat)
        pivots = []
        for row in red:
            p = next((j for j in range(len(here)) if row[j] != 0), None)
            if p is not None:
                pivots.append(p)
        free = [j for j in range(len(here)) if j not in pivots]
        for f in free:
            coeffs = [Fraction(0)] * len(here)
            coeffs[f] = Fraction(1)
            for row in red:
                p = next((j for j in range(len(here)) if row[j] != 0), None)
                if p is not None and row[f] != 0:
                    coeffs[p] = -row[f]
            vecelt: Element = {}
            for j, c in enumerate(coeffs):
                if c:
                    vecelt = add(vecelt, {here[j]: c})
            if vecelt and not A.d(vecelt):
                out.append(vecelt)
    return out


def diagonal_surjects(A: WeightedDGA, alpha: int = 1) -> bool:
    """Check that every cohomology class has a representative on the diagonal."""
    diag = diagonal_subalgebra(A, alpha)
    boundaries = [A.vec(A.d(elt(**{b: 1}))) for b in A.basis]
    spanning = [A.vec(z) for z in diag] + boundaries
    for (n, w) in A.bidegrees():
        here = A.piece(n, w)
        cols = [A.vec(A.d(elt(**{b: 1}))) for b in here]
        # every cocycle in this piece must lie in span(diagonal cocycles, im d)
        mat = [[cols[j][i] for j in range(len(here))] for i in range(len(A.basis))]
        red = row_reduce(mat)
        pivots = []
        for row in red:
            p = next((j for j in range(len(here)) if row[j] != 0), None)
            if p is not None:
                pivots.append(p)
        free = [j for j in range(len(here)) if j not in pivots]
        for f in free:
            coeffs = [Fraction(0)] * len(here)
            coeffs[f] = Fraction(1)
            for row in red:
                p = next((j for j in range(len(here)) if row[j] != 0), None)
                if p is not None and row[f] != 0:
                    coeffs[p] = -row[f]
            cocycle: Element = {}
            for j, c in enumerate(coeffs):
                if c:
                    cocycle = add(cocycle, {here[j]: c})
            if cocycle and A.d(cocycle) == {}:
                if not in_span(spanning, A.vec(cocycle)):
                    return False
    return True


# ----------------------------------------------------------------------------
# Massey products
# ----------------------------------------------------------------------------


def primitive(A: WeightedDGA, target: Element) -> Optional[Element]:
    """Find u with d u = target, or None."""
    cols = [A.vec(A.d(elt(**{b: 1}))) for b in A.basis]
    coeffs = solve(cols, A.vec(target))
    if coeffs is None:
        return None
    u: Element = {}
    for b, c in zip(A.basis, coeffs):
        if c:
            u = add(u, {b: c})
    return u


def cocycle_basis(A: WeightedDGA, n: int, w: Optional[int] = None) -> List[Element]:
    """A basis of the cocycles of degree n (and weight w, if specified)."""
    here = [b for b in A.basis if A.bideg[b][0] == n and (w is None or A.bideg[b][1] == w)]
    cols = [A.vec(A.d(elt(**{b: 1}))) for b in here]
    mat = [[cols[j][i] for j in range(len(here))] for i in range(len(A.basis))]
    red = row_reduce(mat)
    pivots = []
    for row in red:
        p = next((j for j in range(len(here)) if row[j] != 0), None)
        if p is not None:
            pivots.append(p)
    free = [j for j in range(len(here)) if j not in pivots]
    out: List[Element] = []
    for f in free:
        coeffs = [Fraction(0)] * len(here)
        coeffs[f] = Fraction(1)
        for row in red:
            p = next((j for j in range(len(here)) if row[j] != 0), None)
            if p is not None and row[f] != 0:
                coeffs[p] = -row[f]
        e: Element = {}
        for j, c in enumerate(coeffs):
            if c:
                e = add(e, {here[j]: c})
        if e:
            out.append(e)
    return out


def massey_triple(
    A: WeightedDGA, x: Element, y: Element, z: Element
) -> Dict[str, object]:
    """Compute the triple Massey product <x, y, z> and decide whether it contains 0."""
    dx, dz = A.d(x), A.d(z)
    assert dx == {} and dz == {}, "x and z must be cocycles"
    xy, yz = A.mul(x, y), A.mul(y, z)
    u, v = primitive(A, xy), primitive(A, yz)
    if u is None or v is None:
        return {"defined": False}
    p = A.bideg_of(x)
    assert p is not None
    s = A.sign(p[0])
    m = sub(scale(s, A.mul(u, z)), A.mul(x, v))
    closed = A.d(m) == {}
    boundaries = [A.vec(A.d(elt(**{b: 1}))) for b in A.basis]
    exact = in_span(boundaries, A.vec(m))
    # indeterminacy: {c z} + {x c'} for cocycles c, c' of the right degrees
    degm = A.bideg_of(m)
    deg_x = p[0]
    deg_z = A.bideg_of(z)[0]  # type: ignore[index]
    total_deg = degm[0] if degm is not None else None
    indet: Matrix = []
    if total_deg is not None:
        for c in cocycle_basis(A, total_deg - deg_z):
            indet.append(A.vec(A.mul(c, z)))
        for c in cocycle_basis(A, total_deg - deg_x):
            indet.append(A.vec(A.mul(x, c)))
    contains_zero = in_span(boundaries + indet, A.vec(m))
    return {
        "defined": True,
        "u": u,
        "v": v,
        "representative": m,
        "bidegree": degm,
        "closed": closed,
        "exact_for_this_choice": exact,
        "contains_zero": contains_zero,
    }


# ----------------------------------------------------------------------------
# Pretty printing
# ----------------------------------------------------------------------------


def show(a: Element) -> str:
    if not a:
        return "0"
    parts = []
    for k in sorted(a, key=lambda s: (len(s), s)):
        c = a[k]
        if c == 1:
            parts.append(f"+{k}")
        elif c == -1:
            parts.append(f"-{k}")
        elif c > 0:
            parts.append(f"+{c}*{k}")
        else:
            parts.append(f"-{-c}*{k}")
    out = "".join(parts)
    return out[1:] if out.startswith("+") else out


def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def analyse(A: WeightedDGA, alpha: int = 1) -> None:
    problems = A.check_axioms()
    print(f"algebra: {A.name}   dim = {len(A.basis)}   basis = {A.basis}")
    print(f"axiom check (bigrading, associativity, d^2 = 0, Leibniz): "
          f"{'PASSED' if not problems else 'FAILED: ' + '; '.join(problems[:4])}")
    print("bidegrees (degree, weight):",
          ", ".join(f"{b}:{A.bideg[b]}" for b in A.basis))
    nonzero_d = {b: show(A.diff[b]) for b in A.basis if A.diff.get(b)}
    print("differential:", nonzero_d if nonzero_d else "identically zero")
    H = cohomology_dims(A)
    print(f"cohomology H^(n,w) (alpha = {alpha}):")
    for (n, w) in sorted(H):
        marker = "   <-- ON the line w = alpha*n" if w == alpha * n else \
                 f"   <-- OFF the line (weight excess {w - alpha * n})"
        print(f"    H^({n},{w}) has dimension {H[(n, w)]}{marker}")
    pure, bad = is_pure(A, alpha)
    print(f"purity along w = {alpha}n: {pure}" + ("" if pure else f"   violated at {bad}"))
    print("truncation model  (n, w, dim A', dim J, dim A'/J):")
    total_quot = 0
    for (n, w, s, j, q) in truncation_report(A, alpha):
        if s or j:
            print(f"    ({n:>2},{w:>2})   dim A' = {s}   dim J = {j}   dim A'/J = {q}")
        total_quot += q
    total_H = sum(H.values())
    print(f"    total dim A'/J = {total_quot}    total dim H(A) = {total_H}"
          f"    {'MATCH' if total_quot == total_H else 'MISMATCH (expected iff not pure)'}")
    diag = diagonal_subalgebra(A, alpha)
    print(f"diagonal subalgebra: dimension {len(diag)}, basis "
          f"{[show(z) for z in diag]}")
    print(f"every class represented on the diagonal: {diagonal_surjects(A, alpha)}")


# ----------------------------------------------------------------------------
# The four examples
# ----------------------------------------------------------------------------


def example_torus() -> WeightedDGA:
    """Lambda(x, y), zero differential, weight = degree.  Pure, hence formal."""
    return exterior_dga("T = Lambda(x,y), weights = degrees", [("x", 1), ("y", 1)], {})


def example_scaled_torus() -> WeightedDGA:
    """The same algebra with all weights doubled (a Tate-twist normalisation)."""
    return exterior_dga("S = Lambda(x,y), weights = 2 * degrees", [("x", 2), ("y", 2)], {})


def example_heisenberg() -> WeightedDGA:
    """Lambda(x, y, z) with dz = xy: the classical non-formal model.

    Weight-preservation forces weight(z) = weight(x) + weight(y) = 2, so z sits
    one unit off the diagonal — already a hint that purity is in danger.
    """
    return exterior_dga(
        "N = Lambda(x,y,z),  dz = xy",
        [("x", 1), ("y", 1), ("z", 2)],
        {"z": {("x", "y"): Fraction(1)}},
    )


def example_pure_with_differential() -> WeightedDGA:
    """A PURE algebra with a nonzero differential.

    A = Lambda(t) (x) C, where C = k.1 + k.a + k.b is the square-zero algebra with
    a of bidegree (1,2), b of bidegree (2,2) and d a = b.  The weight-2 strand is
    the acyclic complex a -> b, so all cohomology sits on the diagonal:
    H = k.1 + k.[t].
    """
    basis = ["1", "t", "a", "ta", "b", "tb"]
    bideg = {
        "1": (0, 0),
        "t": (1, 1),
        "a": (1, 2),
        "ta": (2, 3),
        "b": (2, 2),
        "tb": (3, 3),
    }
    prod: Dict[Tuple[str, str], Element] = {}
    for u in basis:
        prod[("1", u)] = {u: Fraction(1)}
        prod[(u, "1")] = {u: Fraction(1)}
    # t is odd of degree 1, a is odd of degree 1, b is even of degree 2
    prod[("t", "a")] = {"ta": Fraction(1)}
    prod[("a", "t")] = {"ta": Fraction(-1)}
    prod[("t", "b")] = {"tb": Fraction(1)}
    prod[("b", "t")] = {"tb": Fraction(1)}
    # all remaining products of positive-degree elements vanish
    for u in basis:
        for v in basis:
            prod.setdefault((u, v), {})
    diff: Dict[str, Element] = {
        "a": {"b": Fraction(1)},
        "ta": {"tb": Fraction(-1)},  # d(t a) = -t (d a) = -t b
    }
    return WeightedDGA("P = Lambda(t) (x) (k + k.a + k.b),  d a = b", basis, bideg, prod, diff)


# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------


def main() -> None:
    banner("EXAMPLE T — a pure algebra with zero differential (weight = degree)")
    T = example_torus()
    analyse(T, alpha=1)
    print(
        "\nInterpretation: everything sits on the diagonal, purity holds, and the\n"
        "truncation model A'/J reproduces the cohomology algebra exactly.  By the\n"
        "formality theorem, T is formal — as it must be, since d = 0."
    )

    banner("EXAMPLE P — a pure algebra WITH a nonzero differential")
    P = example_pure_with_differential()
    analyse(P, alpha=1)
    print(
        "\nInterpretation: the weight-2 strand  a -> b  is an acyclic two-step complex\n"
        "living off the diagonal; purity holds because that strand contributes no\n"
        "cohomology.  The truncation A' keeps the full off-diagonal pieces below the\n"
        "line and only the cocycles on it, J keeps the coboundaries, and dim A'/J\n"
        "matches dim H(A) bidegree by bidegree.  This is Theorem A in action with a\n"
        "genuinely nonzero differential."
    )

    banner("EXAMPLE N — the non-formal Heisenberg model, dz = xy")
    N = example_heisenberg()
    analyse(N, alpha=1)
    x, y = elt(x=1), elt(y=1)
    result = massey_triple(N, x, y, y)
    print("\ntriple Massey product <x, y, y>:")
    print(f"    primitive u with d u = x*y :  u = {show(result['u'])}")
    print(f"    primitive v with d v = y*y :  v = {show(result['v'])}")
    print(f"    representative m = eps(1)*u*y - x*v = {show(result['representative'])}")
    print(f"    bidegree of m = {result['bidegree']}   "
          f"(weight excess {result['bidegree'][1] - result['bidegree'][0]})")
    print(f"    m is a cocycle                     : {result['closed']}")
    print(f"    m is exact for this choice of u, v : {result['exact_for_this_choice']}")
    print(f"    <x,y,y> contains 0                 : {result['contains_zero']}")
    pure, bad = is_pure(N, 1)
    print(
        "\nInterpretation: the Massey product is genuinely non-vanishing, so N is not\n"
        "formal.  Consistently with the obstruction theorem (a non-vanishing triple\n"
        f"Massey product forbids purity), purity does fail here (purity holds = {pure}), with\n"
        f"off-diagonal cohomology in bidegrees {bad}.  Note also the weight-excess\n"
        "count: the representative has degree 2 and weight 3, exactly one unit off\n"
        "the diagonal — precisely the position purity would have annihilated."
    )

    banner("EXAMPLE S — Tate-twist normalisation: purity along w = 2n")
    S = example_scaled_torus()
    analyse(S, alpha=2)
    print(
        "\nInterpretation: with all weights doubled the cohomology sits on the line\n"
        "w = 2n rather than w = n.  Purity along that line still holds and the same\n"
        "truncation construction — now along w = 2n — reproduces the cohomology\n"
        "algebra.  Formality does not depend on the weight normalisation."
    )

    banner("SUMMARY OF THE WEIGHT-EXCESS PRINCIPLE")
    print(
        "For a bihomogeneous element of bidegree (n, w) define its weight excess\n"
        "    e = w - alpha * n.\n"
        "Then:  e(ab) = e(a) + e(b),  and if d u = a with u bihomogeneous then\n"
        "e(u) = e(a) + alpha.  Diagonal cohomology classes have e = 0, so:\n"
        "  * a triple Massey representative uses two primitives and loses one degree,\n"
        "    landing at excess exactly alpha > 0;\n"
        "  * purity annihilates every cocycle of nonzero excess;\n"
        "  * hence purity forces every triple Massey product of diagonal classes to\n"
        "    contain 0, and a non-vanishing Massey product certifies that no pure\n"
        "    weight grading can exist.\n"
        "The excess is a defect counter that primitives can only raise — which is why\n"
        "the vanishing argument is a count rather than an induction."
    )


if __name__ == "__main__":
    main()
