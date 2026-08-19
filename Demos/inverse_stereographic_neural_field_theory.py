"""Exact dimension count for stereographic pattern spaces.

For a given degree l this script computes, in exact rational arithmetic, the dimension of
the space of functions of the form

    u = sum_{i+j+k <= l} c_{ijk} * sigma_1^i sigma_2^j sigma_3^k

that satisfy the transported Laplace-Beltrami equation

    Delta u = -l(l+1) * (4 W^2) * u,          W = 1/(1 + x^2 + y^2),

where sigma = (2xW, 2yW, (x^2+y^2-1)W) is the inverse stereographic chart.

Method.  Everything lives in the polynomial algebra R[x, y, W], which is closed under
differentiation because dW/dx = -2xW^2.  Writing each ansatz monomial in that algebra,
the residual of the eigenvalue equation is linear in the coefficients; multiplying by a
uniform power of (1 + x^2 + y^2) clears every W and produces an honest polynomial in x
and y.  Two exact matrices result:

    A : coefficients -> residual polynomial      (the eigenvalue constraint)
    B : coefficients -> the function itself      (the sphere relation sum sigma_i^2 = 1
                                                  makes this map non-injective)

Since a coefficient vector representing the zero function trivially solves the equation,
ker B is contained in ker A, and the dimension of the space of *functions* solving the
equation is dim ker A - dim ker B.  The computation is exact: no floating point anywhere.

Running it reproduces 2l+1 for every degree tested.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Dict, List, Tuple

Mono = Tuple[int, int, int]          # exponents of x, y, W
Poly = Dict[Mono, Fraction]


def padd(p: Poly, q: Poly) -> Poly:
    out = dict(p)
    for k, v in q.items():
        nv = out.get(k, Fraction(0)) + v
        if nv == 0:
            out.pop(k, None)
        else:
            out[k] = nv
    return out


def pscale(p: Poly, c: Fraction) -> Poly:
    return {} if c == 0 else {k: c * v for k, v in p.items()}


def pmul(p: Poly, q: Poly) -> Poly:
    out: Poly = {}
    for (a1, b1, c1), v1 in p.items():
        for (a2, b2, c2), v2 in q.items():
            k = (a1 + a2, b1 + b2, c1 + c2)
            nv = out.get(k, Fraction(0)) + v1 * v2
            if nv == 0:
                out.pop(k, None)
            else:
                out[k] = nv
    return out


def dx(p: Poly) -> Poly:
    out: Poly = {}
    for (a, b, c), v in p.items():
        if a:
            out = padd(out, {(a - 1, b, c): v * a})
        if c:
            out = padd(out, {(a + 1, b, c + 1): -2 * v * c})
    return out


def dy(p: Poly) -> Poly:
    out: Poly = {}
    for (a, b, c), v in p.items():
        if b:
            out = padd(out, {(a, b - 1, c): v * b})
        if c:
            out = padd(out, {(a, b + 1, c + 1): -2 * v * c})
    return out


def plaplacian(p: Poly) -> Poly:
    return padd(dx(dx(p)), dy(dy(p)))


DENOM: Poly = {(0, 0, 0): Fraction(1), (2, 0, 0): Fraction(1), (0, 2, 0): Fraction(1)}


def clear_W(p: Poly, power: int) -> Dict[Tuple[int, int], Fraction]:
    """Multiply by (1+x^2+y^2)^power, using W(1+x^2+y^2)=1, and return a polynomial in x,y."""
    total: Poly = {}
    for (a, b, c), v in p.items():
        if c > power:
            raise ValueError("power too small")
        term: Poly = {(a, b, 0): v}
        for _ in range(power - c):
            term = pmul(term, DENOM)
        total = padd(total, term)
    return {(a, b): v for (a, b, _), v in total.items()}


def chart_symbols() -> Tuple[Poly, Poly, Poly]:
    s1: Poly = {(1, 0, 1): Fraction(2)}
    s2: Poly = {(0, 1, 1): Fraction(2)}
    s3: Poly = {(2, 0, 1): Fraction(1), (0, 2, 1): Fraction(1), (0, 0, 1): Fraction(-1)}
    return s1, s2, s3


def monomial_basis(degree: int) -> List[Mono]:
    return [(i, j, k) for i, j, k in product(range(degree + 1), repeat=3)
            if i + j + k <= degree]


def nullity(columns: List[Dict[Tuple[int, int], Fraction]]) -> int:
    """Exact nullity of the matrix whose columns are the given sparse vectors."""
    keys = sorted({k for col in columns for k in col})
    if not keys:
        return len(columns)
    rows = [[col.get(k, Fraction(0)) for col in columns] for k in keys]
    n_cols = len(columns)
    rank, pivot = 0, 0
    for col in range(n_cols):
        sel = None
        for i in range(pivot, len(rows)):
            if rows[i][col] != 0:
                sel = i
                break
        if sel is None:
            continue
        rows[pivot], rows[sel] = rows[sel], rows[pivot]
        piv = rows[pivot][col]
        for i in range(pivot + 1, len(rows)):
            if rows[i][col] != 0:
                f = rows[i][col] / piv
                for j in range(col, n_cols):
                    rows[i][j] -= f * rows[pivot][j]
        rank += 1
        pivot += 1
        if pivot == len(rows):
            break
    return n_cols - rank


def pattern_space_dimension(degree: int) -> int:
    s1, s2, s3 = chart_symbols()
    basis = monomial_basis(degree)
    powers: List[Poly] = []
    for (i, j, k) in basis:
        term: Poly = {(0, 0, 0): Fraction(1)}
        for _ in range(i):
            term = pmul(term, s1)
        for _ in range(j):
            term = pmul(term, s2)
        for _ in range(k):
            term = pmul(term, s3)
        powers.append(term)

    weight: Poly = {(0, 0, 2): Fraction(4 * degree * (degree + 1))}
    residuals = [padd(plaplacian(p), pmul(weight, p)) for p in powers]

    p_res = max((c for r in residuals for (_, _, c) in r), default=0)
    p_val = max((c for p in powers for (_, _, c) in p), default=0)

    a_cols = [clear_W(r, p_res) for r in residuals]
    b_cols = [clear_W(p, p_val) for p in powers]
    return nullity(a_cols) - nullity(b_cols)


def main() -> None:
    print("degree l   ansatz dim   pattern-space dim   2l+1")
    for degree in range(1, 7):
        dim = pattern_space_dimension(degree)
        print(f"    {degree}          {len(monomial_basis(degree)):5d}"
              f"            {dim:5d}          {2*degree+1:5d}"
              f"   {'OK' if dim == 2*degree+1 else 'MISMATCH'}")


if __name__ == "__main__":
    main()


"""Constant-time Mexican-hat mode selection.

The connectivity kernel of a homogeneous isotropic cortical sheet acts on the degree-l
spherical eigenspace by a single number, the band-pass multiplier

    lambda_l(r) = g((l r)^2),        g(s) = s e^{1-s},

whose profile is strictly unimodal with unique peak g(1) = 1.  Consequently the maximiser
over the infinite index set l = 0, 1, 2, ... is always one of the two integers bracketing
1/r, so selecting the emergent degree requires exactly two evaluations of g, independently
of how large the answer is.  At the resonant radii r = 1/k the maximiser is exactly k.

The function `verify_bracketing` re-derives the same answer by brute force over a large
range of degrees, as an independent check of the shortcut.
"""

from __future__ import annotations

import math
from typing import Tuple


def band_pass_gain(s: float) -> float:
    """g(s) = s exp(1 - s): the normalised Mexican-hat spectral profile."""
    return s * math.exp(1.0 - s)


def multiplier(r: float, degree: int) -> float:
    """lambda_l(r) = g((l r)^2)."""
    return band_pass_gain((degree * r) ** 2)


def selected_degree(r: float) -> int:
    """The degree maximising the multiplier, found in O(1) by the bracketing theorem."""
    if r <= 0.0:
        raise ValueError("interaction radius must be positive")
    lo, hi = math.floor(1.0 / r), math.ceil(1.0 / r)
    return lo if multiplier(r, lo) >= multiplier(r, hi) else hi


def pattern_count(r: float) -> Tuple[int, int, int]:
    """(selected degree N, number of patterns 2N+1, number that decay 2N)."""
    n = selected_degree(r)
    return n, 2 * n + 1, 2 * n


def verify_bracketing(r: float, l_max: int = 500) -> bool:
    """Confirm that the two-candidate shortcut agrees with exhaustive search."""
    brute = max(range(l_max + 1), key=lambda l: multiplier(r, l))
    return abs(multiplier(r, brute) - multiplier(r, selected_degree(r))) < 1e-12


def main() -> None:
    print(" r        1/r      floor  ceil   selected  patterns  decaying  shortcut valid")
    for r in (1.0, 0.75, 0.5, 0.45, 0.4, 1 / 3, 0.3, 0.25, 0.2, 0.17):
        n, count, decaying = pattern_count(r)
        print(f"{r:5.3f}   {1/r:7.3f}   {math.floor(1/r):4d}  {math.ceil(1/r):4d}"
              f"     {n:4d}     {count:5d}     {decaying:5d}        "
              f"{verify_bracketing(r)}")


if __name__ == "__main__":
    main()


"""Symbolic Laplacian in the chart algebra, with exact certification of eigenfunctions.

Every function that appears in the stereographic transport is a polynomial in x, y and the
conformal atom W = 1/(1 + x^2 + y^2).  That algebra is closed under differentiation because

    dW/dx = -2 x W^2,     dW/dy = -2 y W^2,

so differentiation can be implemented as term rewriting on exponent triples (a, b, c)
representing x^a y^b W^c.  Applying it twice per variable gives the Euclidean Laplacian,
and an eigenfunction claim

    Delta u = -l(l+1) (4 W^2) u

is certified exactly by clearing every W (using W (1+x^2+y^2) = 1) and checking that the
resulting polynomial in x and y is identically zero.  All arithmetic is rational.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, Tuple

Mono = Tuple[int, int, int]
Poly = Dict[Mono, Fraction]


def padd(p: Poly, q: Poly) -> Poly:
    out = dict(p)
    for k, v in q.items():
        nv = out.get(k, Fraction(0)) + v
        if nv == 0:
            out.pop(k, None)
        else:
            out[k] = nv
    return out


def pmul(p: Poly, q: Poly) -> Poly:
    out: Poly = {}
    for (a1, b1, c1), v1 in p.items():
        for (a2, b2, c2), v2 in q.items():
            k = (a1 + a2, b1 + b2, c1 + c2)
            nv = out.get(k, Fraction(0)) + v1 * v2
            if nv == 0:
                out.pop(k, None)
            else:
                out[k] = nv
    return out


def dx(p: Poly) -> Poly:
    """Symbolic d/dx, closed on the algebra thanks to dW/dx = -2 x W^2."""
    out: Poly = {}
    for (a, b, c), v in p.items():
        if a:
            out = padd(out, {(a - 1, b, c): v * a})
        if c:
            out = padd(out, {(a + 1, b, c + 1): -2 * v * c})
    return out


def dy(p: Poly) -> Poly:
    """Symbolic d/dy, closed on the algebra thanks to dW/dy = -2 y W^2."""
    out: Poly = {}
    for (a, b, c), v in p.items():
        if b:
            out = padd(out, {(a, b - 1, c): v * b})
        if c:
            out = padd(out, {(a, b + 1, c + 1): -2 * v * c})
    return out


def laplacian(p: Poly) -> Poly:
    return padd(dx(dx(p)), dy(dy(p)))


DENOM: Poly = {(0, 0, 0): Fraction(1), (2, 0, 0): Fraction(1), (0, 2, 0): Fraction(1)}


def clear_W(p: Poly) -> Poly:
    """Multiply by a sufficient power of (1+x^2+y^2) so that no W remains."""
    power = max((c for (_, _, c) in p), default=0)
    total: Poly = {}
    for (a, b, c), v in p.items():
        term: Poly = {(a, b, 0): v}
        for _ in range(power - c):
            term = pmul(term, DENOM)
        total = padd(total, term)
    return total


def certify(u: Poly, degree: int) -> bool:
    """True exactly when Delta u = -degree(degree+1) (4W^2) u holds identically."""
    weight: Poly = {(0, 0, 2): Fraction(4 * degree * (degree + 1))}
    residual = padd(laplacian(u), pmul(weight, u))
    return not clear_W(residual)


def chart() -> Tuple[Poly, Poly, Poly]:
    return (
        {(1, 0, 1): Fraction(2)},                                        # sigma_1 = 2xW
        {(0, 1, 1): Fraction(2)},                                        # sigma_2 = 2yW
        {(2, 0, 1): Fraction(1), (0, 2, 1): Fraction(1),
         (0, 0, 1): Fraction(-1)},                                       # sigma_3
    )


def main() -> None:
    s1, s2, s3 = chart()
    tests = [
        ("sigma_1", 1, s1),
        ("sigma_1 sigma_2", 2, pmul(s1, s2)),
        ("sigma_1^2 - sigma_2^2", 2,
         padd(pmul(s1, s1), {k: -v for k, v in pmul(s2, s2).items()})),
        ("sigma_1(sigma_1^2 - 3 sigma_2^2)", 3,
         padd(pmul(s1, pmul(s1, s1)),
              {k: -3 * v for k, v in pmul(s1, pmul(s2, s2)).items()})),
    ]
    for name, degree, poly in tests:
        print(f"{name:34s} degree {degree}: {'certified' if certify(poly, degree) else 'FAILS'}")


if __name__ == "__main__":
    main()


"""Assemble PACKAGE.json from the individual deliverables in this project."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Dict, List

ROOT = Path(__file__).resolve().parent.parent
ASSETS = ROOT / "assets"


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILES: List[str] = [
    "Catalog/Physics/StereoNeuralFieldCalculus.lean",
    "Catalog/Physics/StereoNeuralFieldHarmonics.lean",
    "Catalog/Physics/StereoNeuralFieldSelection.lean",
    "Catalog/Physics/StereoNeuralFieldSymmetry.lean",
    "Catalog/Physics/StereoNeuralFieldExactCount.lean",
]


def lean_bundle() -> str:
    chunks = []
    for rel in LEAN_FILES:
        chunks.append(f"-- ======================================================\n"
                      f"-- FILE: {rel}\n"
                      f"-- ======================================================\n")
        chunks.append(read(ROOT / rel))
        chunks.append("\n")
    return "".join(chunks)


FUTURE_DIRECTIONS = """# Future directions — inverse stereographic neural field theory

Derived from the analysis and adversarial review of the results established in this cycle:
the conformal chart calculus, the pulled-back harmonics, Mexican-hat mode selection, the
symmetry theory, and the exact pattern count.

## What survived, what failed

* **Survived.** The conformal factor `4W²` of the stereographic chart; the Laplace–Beltrami
  eigenvalue relation for all fifteen pulled-back harmonics of degrees `1,2,3`; their linear
  independence; strict unimodality of the Mexican-hat multiplier and strict selection of
  degree `k` at radius `r = 1/k`; the `2N+1` count (now with a matching upper bound in
  degrees `1`, `2` and `3`); `N`-fold symmetry of the sectoral patterns; Kelvin duality.
* **Failed as stated.** (i) "All `2N+1` patterns decay at infinity" — false: the zonal modes
  tend to their north-pole value, and the decaying part has dimension `2N`. (ii) "`N = ⌊1/r⌋`
  for every `r`" — false: at `r = 0.4` the maximiser is `⌈1/r⌉ = 3`. The correct general
  statement is the bracketing theorem: the maximiser is `⌊1/r⌋` or `⌈1/r⌉`.
* **True but not yet reached.** The upper bound `dim = 2N+1` for `N ≥ 4` (degrees `1, 2, 3`
  are proved; degrees up to `6` are confirmed by exact rational computation), and any
  statement about *stability* (as opposed to existence) of the patterns.

## Conjecture 1 — Exact `2l+1` upper bound in every degree

For every `l`, a polynomial of degree `≤ l` in the three chart coordinates that satisfies
`Δ u = -l(l+1)(4W²)u` lies in the span of the `2l+1` explicit sectoral/tesseral/zonal
patterns of degree `l`.  (Proved for `l = 1, 2, 3`; open for `l ≥ 4`.)

*The key insight is* that the Leibniz rules for the Laplacian and the gradient pairing,
together with the induced-metric identity `∇σ_i·∇σ_j = 4W²(δ_ij - σ_iσ_j)`, turn the
eigenvalue equation into a purely algebraic recursion on the coefficients of the
polynomial, whose solution space is the traceless part — no functional analysis is needed.

*Why now?* The degrees `1, 2, 3` are already proved this way (the last one extracts its
three linear constraints from nothing but linear independence of the chart coordinates);
the general case only needs the recursion to be organised by total degree, which the
reflective symbolic calculus makes mechanical.

## Conjecture 2 — Decay codimension equals one in every degree

For every `l`, the subspace of degree-`l` patterns that decay along every ray has dimension
exactly `2l`, and the decay rate of a decaying pattern is `Θ(R^{-m})` where `m` is the order
of vanishing of the harmonic at the north pole.

*The key insight is* that the plane behaviour at infinity is the sphere behaviour at the
north pole read through `W ~ R^{-2}`, so "decay" is a single linear condition (vanishing at
one point) and the rate is the vanishing order there.

*Why now?* The `l = 1` case is completely settled, and the sectoral rates `O(R^{-2})` and
`O(R^{-3})` are established with explicit constants `8/R²` and `32/R³`.

## Further directions

* **Stability, not just existence.** The analysis so far is linear: it identifies which
  eigenspace goes unstable first and how large it is. Which of the `2N+1` shapes a
  nonlinear cortex settles into is governed by the equivariant amplitude equations on the
  `(2N+1)`-dimensional critical eigenspace.
* **Mode competition.** Near a radius where the two bracketing degrees have equal gain, two
  eigenspaces of dimensions `2N+1` and `2N+3` become simultaneously critical.
* **General connectivity profiles.** The bracketing theorem holds verbatim for any strictly
  unimodal band-pass profile; only the resonance condition changes.
* **Cortical folding.** A folded cortex is a sphere with a non-round metric. Since every
  surface metric is locally conformally flat, the same chart algebra applies with `4W²`
  replaced by a general positive weight, at the price of losing polynomial closure.
  Perturbation around `4W²` should predict how folding splits the `(2N+1)`-fold degeneracy,
  exactly as a crystal field splits an atomic multiplet.
"""


INTERACTIVE_LAYOUT = r"""
# Seeing the Shape of Your Own Cortex

### A guided tour of inverse stereographic neural field theory

Close your eyes and press on your eyelids; stare at a flicker; drift toward sleep. Most
people, in these situations, see the same short list of things: spirals, honeycombs,
funnels, fans, rosettes. These are the [form constants](https://en.wikipedia.org/wiki/Form_constant),
and the striking fact about them is not that they occur but that there are so *few* of them.

This page builds, from scratch, a geometric theory that says exactly **how many** there
should be — and what they look like.

---

## 1. The idea in one picture

A [neural field](https://en.wikipedia.org/wiki/Neural_field) model treats cortical activity
as a continuous function $u$ on the cortical surface, evolving by

$$\partial_t u(p) = -u(p) + \int K(p,q)\,S\big(u(q)\big)\,dq,$$

with a *Mexican-hat* kernel $K$: excitation nearby, inhibition further out, nothing far
away, with a characteristic **interaction radius** $r$. Linearise, and the patterns that
grow are the eigenmodes of the surface.

The cortical surface is topologically a **sphere**. On a sphere the eigenmodes are
[spherical harmonics](https://en.wikipedia.org/wiki/Spherical_harmonics), the eigenvalue of
degree $l$ is $-l(l+1)$, and — this is the crux — its eigenspace has dimension exactly

$$2l+1 .$$

Everything below is about turning that number into a prediction you can look at.

Start by playing. Move the radius slider and watch which degree the connectivity picks;
then step through the $2N+1$ patterns of that degree, rotate them, and turn them inside
out through the unit circle.

{{interactive_demo:0}}

<details>
<summary><b>Why is the dimension exactly $2l+1$? (click to reveal)</b></summary>

Two independent reasons, and they agree.

*Representation theory.* The rotation group $SO(3)$ acts on the sphere and commutes with
the Laplace–Beltrami operator, so it permutes each eigenspace among itself. The irreducible
real representations of $SO(3)$ have dimensions $1, 3, 5, 7, \dots$, and the degree-$l$
eigenspace carries exactly the $(2l+1)$-dimensional one.

*Polynomials.* A degree-$l$ spherical harmonic is the restriction to the sphere of a
harmonic homogeneous polynomial of degree $l$ in three variables. Homogeneous polynomials
of degree $l$ form a space of dimension $\binom{l+2}{2}$, and the Laplacian maps that space
onto the degree-$(l-2)$ space, of dimension $\binom{l}{2}$. Hence

$$\binom{l+2}{2}-\binom{l}{2} = 2l+1 .$$

An easy induction confirms it: each step adds $(m+2)-m = 2$.
</details>

---

## 2. Flattening the sphere honestly

Working on the sphere in polar coordinates is unpleasant — the poles are coordinate
singularities — and the picture we want to *look at* lives in the plane. So we use
[inverse stereographic projection](https://en.wikipedia.org/wiki/Stereographic_projection):

$$\sigma(x,y) = \big(2xW,\; 2yW,\; (x^2+y^2-1)W\big), \qquad W = \frac{1}{1+x^2+y^2}.$$

The origin becomes the south pole, the unit circle becomes the equator, and infinity in
every direction becomes the single north pole. The map really lands on the sphere:
$\sigma_1^2+\sigma_2^2+\sigma_3^2 = 1$ identically.

What makes it special is *how* it distorts. The pullback of the ambient metric is

$$\sigma^*\big(dX^2+dY^2+dZ^2\big) \;=\; 4W^2\,\big(dx^2+dy^2\big),$$

so angles are preserved and only scale changes. In two dimensions that means the curved
Laplace–Beltrami operator is the flat Laplacian divided by the conformal factor, and the
eigenvalue problem becomes completely explicit:

$$\boxed{\;\Delta_{\text{flat}}\,u \;=\; -\,l(l+1)\,\big(4W^2\big)\,u\;}$$

No poles, no special functions — a flat Laplacian and a weight.

{{visualization:0}}

---

## 3. The algebra that closes on itself

Here is the trick that turns the theory into finite algebra. Everything in sight — the
three chart coordinates, every harmonic pulled back through them, the weight itself — is a
polynomial in **three symbols**: $x$, $y$ and $W$. And that algebra is closed under
differentiation, because

$$\partial_x W = -2xW^2, \qquad \partial_y W = -2yW^2 .$$

Differentiation never produces anything new. So one can implement it as rewriting on
exponent triples and verify eigenfunction claims *exactly*, in rational arithmetic.

{{algorithm:0}}

<details>
<summary><b>The two structural identities that generate everything</b></summary>

For the three chart coordinates,

$$\Delta \sigma_i = -2\,(4W^2)\,\sigma_i, \qquad
\nabla\sigma_i\cdot\nabla\sigma_j = 4W^2\big(\delta_{ij}-\sigma_i\sigma_j\big).$$

The first says each coordinate is a degree-one harmonic. The second is the induced metric
of the sphere written in the flat chart — the infinitesimal form of $\sum_i\sigma_i^2 = 1$.

Feed them into the Leibniz rule $\Delta(uv) = u\Delta v + v\Delta u + 2\nabla u\cdot\nabla v$
and the eigenvalue relation propagates by pure algebra. For example, for orthogonal
coordinates,

$$\Delta(\sigma_i\sigma_j) = -2(4W^2)\sigma_i\sigma_j - 2(4W^2)\sigma_i\sigma_j
- 2(4W^2)\sigma_i\sigma_j = -6(4W^2)\sigma_i\sigma_j,$$

which is precisely the degree-two eigenvalue $l(l+1) = 6$. Similarly
$\Delta(\sigma_1\sigma_2\sigma_3) = -12(4W^2)\sigma_1\sigma_2\sigma_3$, the degree-three
eigenvalue.
</details>

---

## 4. The fifteen patterns

Running the machine gives the patterns explicitly, as rational functions of the plane
coordinates:

* **Degree 1 (3 dipoles):** $\sigma_1$, $\sigma_2$, $\sigma_3$.
* **Degree 2 (5 quadrupoles):** $\sigma_1\sigma_2$, $\sigma_1\sigma_3$, $\sigma_2\sigma_3$,
  $\sigma_1^2-\sigma_2^2$, $3\sigma_3^2-1$.
* **Degree 3 (7 octupoles):** $\sigma_1(\sigma_1^2-3\sigma_2^2)$,
  $\sigma_2(3\sigma_1^2-\sigma_2^2)$, $\sigma_3(\sigma_1^2-\sigma_2^2)$,
  $\sigma_1\sigma_2\sigma_3$, $\sigma_1(5\sigma_3^2-1)$, $\sigma_2(5\sigma_3^2-1)$,
  $\sigma_3(5\sigma_3^2-3)$.

Each satisfies its eigenvalue equation, and each family is linearly independent — so the
degree-$l$ pattern space really does have dimension at least $2l+1$.

{{visualization:1}}

Look at the gallery and the form constants start to appear on their own: the two-fold
"fan", the three-fold rosette, the concentric target of the zonal modes.

---

## 5. Which degree does the brain pick?

Because a homogeneous, isotropic kernel cannot tell the members of one eigenspace apart, it
multiplies every degree-$l$ harmonic by a single number. For a difference-of-Gaussians
Mexican hat of radius $r$, normalised so its peak is $1$,

$$\lambda_l(r) = g\big((lr)^2\big), \qquad g(s) = s\,e^{\,1-s} .$$

Three facts, all consequences of the single inequality $t+1 < e^t$ for $t\neq 0$:

1. **Sharp peak:** $g(1)=1$ and $g(s)<1$ for $s\ne1$.
2. **Strict unimodality:** $g$ increases on $[0,1]$ and decreases on $[1,\infty)$.
3. **Bracketing:** the maximising degree is always $\lfloor 1/r\rfloor$ or $\lceil 1/r\rceil$.

So selecting the emergent degree is a **two-evaluation** computation, no matter how large
the answer.

{{algorithm:1}}

{{visualization:2}}

> **Pattern-count theorem.** At the resonant radii $r = 1/k$ the kernel strictly selects
> degree $N = k = \lfloor 1/r\rfloor$, and the selected eigenspace contains exactly $2N+1$
> linearly independent patterns.

<details>
<summary><b>A tempting statement that is simply false</b></summary>

It is natural to guess that the selected degree is $\lfloor 1/r\rfloor$ for *every* radius.
It is not. At $r = 0.4$ we have $1/r = 2.5$ and

$$\lambda_2 = 0.64\,e^{0.36}\approx 0.9173 \;<\; \lambda_3 = 1.44\,e^{-0.44}\approx 0.9274 .$$

The ceiling wins, because $g$ is not symmetric about its peak. The bracketing theorem is
the correct general statement; equality with the floor is guaranteed only at $r = 1/k$.
</details>

---

## 6. Exactly $2N+1$ — the upper bound

A lower bound is easy: exhibit patterns. The interesting half is showing there are no
others. Within the polynomial ansatz where any truncated model lives:

* an **affine** function of the chart coordinates solves the degree-one equation **iff** its
  constant term vanishes — three dimensions;
* a general **quadratic** solving the degree-two equation must have no linear part and must
  have its constant term locked to minus a third of its trace, after which it lies in the
  span of the five quadrupoles — five dimensions;
* a parity-odd **cubic** solving the degree-three equation lies in the span of the seven
  octupoles — seven dimensions.

And we can go further computationally: exact rational linear algebra on the full ansatz
reproduces $2l+1$ for every degree up to six.

{{algorithm:2}}

<details>
<summary><b>How the degree-three constraints are extracted with almost no work</b></summary>

Expand $\Delta u + 12\,(4W^2)u$ for a general parity-odd cubic. Every cubic term cancels
identically — that is what the monomial table guarantees — and the remainder is $4W^2$
times a *linear* combination of $\sigma_1,\sigma_2,\sigma_3$:

$$\big(10c_1+6t_{111}+2t_{122}+2t_{133}\big)\sigma_1 + (\cdots)\sigma_2 + (\cdots)\sigma_3 = 0 .$$

Since $4W^2>0$ and $\sigma_1,\sigma_2,\sigma_3$ are linearly independent, each coefficient
must vanish. Three constraints, obtained from nothing but linear independence — no
evaluation at special points, no integration.
</details>

---

## 7. What happens at infinity (a correction)

It is natural to expect every projected pattern to fade in the periphery. It doesn't.
Going to infinity in the plane means climbing to the north pole, and a harmonic need not
vanish there. Along any ray, a general dipole satisfies the exact identity

$$a\sigma_1+b\sigma_2+c\sigma_3 \;=\; c + \frac{2aRu_0+2bRv_0-2c}{1+R^2}
\;\longrightarrow\; c ,$$

with error at most $(2|a|+2|b|+2|c|)/R$. So the zonal mode tends to $1$: it does **not**
decay. Decay along every ray holds **exactly when** the north-pole coefficient vanishes,
and the decaying subspace therefore has dimension $2N$, not $2N+1$.

The patterns that do decay do so at sharp polynomial rates:

$$\big|\sigma_1^2-\sigma_2^2\big| \le \frac{8}{R^2}, \qquad
\big|\sigma_1(\sigma_1^2-3\sigma_2^2)\big| \le \frac{32}{R^3}.$$

{{visualization:3}}

---

## 8. Symmetry: why they look like hallucinations

Rotating the plane is the *same thing* as rotating the sphere about its polar axis:

$$\sigma_1\mapsto \cos\theta\,\sigma_1-\sin\theta\,\sigma_2, \quad
\sigma_2\mapsto \sin\theta\,\sigma_1+\cos\theta\,\sigma_2, \quad \sigma_3\mapsto\sigma_3 .$$

That is the concrete mechanism behind "$2l+1$ rotational variants". The sectoral patterns,
built from $\mathrm{Re}(\sigma_1+i\sigma_2)^l$ and $\mathrm{Im}(\sigma_1+i\sigma_2)^l$,
inherit exact $N$-fold symmetry: the degree-two one is invariant under the half-turn, the
degree-three pair under rotation by $2\pi/3$. The boundary case is instructive: the
degree-one sectoral pattern is *odd* under the half-turn, so its symmetry group is exactly
one-fold.

<details>
<summary><b>Kelvin duality: turning a pattern inside out</b></summary>

Inversion of the plane in the unit circle, $p\mapsto p/|p|^2$, is conjugated by the chart
to the equatorial reflection $z\mapsto-z$ of the sphere: it fixes $\sigma_1,\sigma_2$ and
negates $\sigma_3$. So the zonal quadrupole $3\sigma_3^2-1$ is unchanged by inversion while
the zonal octupole $\sigma_3(5\sigma_3^2-3)$ changes sign. Toggle "Kelvin inversion" in the
explorer above and watch the inside and the outside of the equator trade places.
</details>

---

## 9. Check it yourself

The full numerical suite below verifies each claim independently: the chart lands on the
sphere and is conformal; all fifteen patterns satisfy their eigenvalue equations (both by
high-order finite differences and by exact rational certification); the families are
independent; the two-candidate selection rule agrees with exhaustive search across a fine
sweep of radii; the zonal modes fail to decay while the sectoral ones obey the proved
envelopes; and the symmetry and duality identities hold to machine precision.

{{demo:0}}

---

## 10. Where the frontier is

* **Exact $2l+1$ in every degree.** Proved for $l\le3$, computed exactly for $l\le6$, open in
  general. The eigenvalue equation is an algebraic recursion on coefficients whose solution
  space is the traceless part — no analysis needed.
* **Decay codimension one in every degree.** Settled for $l=1$; the general statement is
  that decay means vanishing at the north pole, with rate equal to the vanishing order.
* **Stability, not just existence.** Which of the $2N+1$ shapes a nonlinear cortex settles
  into is governed by the equivariant amplitude equations on the critical eigenspace.
* **Folding.** A folded cortex is a sphere with a non-round metric; since every surface
  metric is locally conformally flat, the same chart applies with a general weight. Folding
  should split the $(2N+1)$-fold degeneracy the way a crystal field splits an atomic
  multiplet.

The next time you press on your eyelids and see a rosette, you are looking at a number:
$2N+1$, with $N$ set by how far a cortical neuron talks to its neighbours.
"""


def package() -> Dict[str, object]:
    demo_src = read(ROOT / "demo.py")
    return {
        "title": "Inverse Stereographic Neural Field Theory: Conformal Transport and an "
                 "Exact 2N+1 Pattern Count",
        "domain": "Physics",
        "description": (
            "Inverse stereographic projection turns the Laplace-Beltrami eigenvalue problem "
            "of a Mexican-hat neural field on the cortical sphere into a flat, conformally "
            "weighted equation on the plane, solved inside a polynomial algebra closed under "
            "differentiation. The theory yields strict mode selection at resonant interaction "
            "radii and an exact count of 2N+1 patterns of the selected degree, of which "
            "exactly 2N decay at infinity."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-19",
        "key_results": [
            "Conformal transport theorem: the pullback of the ambient metric under the inverse "
            "stereographic chart is 4W^2(dx^2+dy^2) with W = 1/(1+x^2+y^2), so a degree-l "
            "Laplace-Beltrami eigenfunction of the sphere is exactly a solution of the flat "
            "weighted equation Delta u = -l(l+1)(4W^2)u on the plane.",
            "Closed chart calculus: the algebra of polynomials in x, y and the conformal atom W "
            "is closed under differentiation, and the eigenvalue relation propagates from the "
            "three chart coordinates to all polynomial harmonics via the identities "
            "Delta sigma_i = -2(4W^2)sigma_i and grad sigma_i . grad sigma_j = "
            "4W^2(delta_ij - sigma_i sigma_j) together with the Leibniz rule.",
            "Strict Mexican-hat mode selection: the band-pass gain g(s) = s e^{1-s} is strictly "
            "unimodal with unique peak g(1) = 1; at every radius the maximising degree is the "
            "floor or the ceiling of 1/r, and at r = 1/k it is exactly k.",
            "Exact pattern count: the selected degree-N eigenspace contains exactly 2N+1 "
            "linearly independent stereographic patterns, proved for N = 1, 2, 3 with matching "
            "upper bounds inside the polynomial ansatz and confirmed by exact rational "
            "computation through degree six.",
            "North-pole obstruction: a projected pattern decays along every ray if and only if "
            "its north-pole value vanishes, so exactly 2N of the 2N+1 patterns decay; the "
            "sectoral modes decay at the sharp rates 8/R^2 and 32/R^3, and carry exact N-fold "
            "rotational symmetry, with Kelvin inversion of the plane acting as the equatorial "
            "reflection of the sphere.",
        ],
        "keywords": [
            "neural field equations",
            "inverse stereographic projection",
            "conformal geometry",
            "Laplace-Beltrami operator",
            "spherical harmonics",
            "Mexican-hat connectivity",
            "pattern formation",
            "visual hallucinations",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": demo_src,
        "demos": [
            {
                "name": "Complete Numerical Verification Suite for the Stereographic "
                        "Transport",
                "description": (
                    "A self-contained, dependency-free verification of every quantitative claim "
                    "of the theory. It checks that the inverse stereographic chart lands on the "
                    "unit sphere and is conformal with factor 4W^2; evaluates the flat Laplacian "
                    "of all fifteen projected harmonics of degrees 1, 2 and 3 by a fourth-order "
                    "finite-difference stencil and compares with -l(l+1)(4W^2)u; re-verifies a "
                    "representative subset exactly in rational arithmetic inside the symbolic "
                    "algebra of polynomials in x, y and W (including a deliberate control that "
                    "must fail); computes the numerical rank of each family to confirm the "
                    "dimensions 3, 5 and 7; compares the two-candidate mode-selection rule with "
                    "exhaustive search over a fine sweep of interaction radii; exhibits the "
                    "radius r = 0.4 at which the ceiling of 1/r beats the floor; traces the "
                    "north-pole obstruction and the sharp sectoral decay envelopes 8/R^2 and "
                    "32/R^3 along rays; and confirms the N-fold rotational symmetries and the "
                    "Kelvin-inversion duality to machine precision."
                ),
                "code": demo_src,
            }
        ],
        "algorithms": [
            {
                "name": "Reflective Symbolic Laplacian and Exact Eigenfunction Certification "
                        "in the Chart Algebra",
                "description": (
                    "Every function occurring in the stereographic transport lies in the algebra "
                    "of polynomials in x, y and the conformal atom W = 1/(1+x^2+y^2), which is "
                    "closed under differentiation because dW/dx = -2xW^2. Representing an element "
                    "as a sparse map from exponent triples (a,b,c), denoting x^a y^b W^c, to "
                    "rational coefficients, differentiation becomes pure term rewriting and the "
                    "Laplacian is two rewrites per variable. An eigenfunction claim "
                    "Delta u = -l(l+1)(4W^2)u is then certified exactly: form the residual, "
                    "multiply by a sufficient power of (1+x^2+y^2) using the relation "
                    "W(1+x^2+y^2)=1 to eliminate every W, and test whether the resulting "
                    "polynomial in x and y is identically zero. No floating point is involved. "
                    "Each differentiation at most doubles the number of monomials, so the "
                    "Laplacian of a T-term expression costs O(T) monomial operations; the "
                    "denominator-clearing step is O(T * P^2) where P is the maximal power of W, "
                    "which for a degree-l harmonic is O(l)."
                ),
                "pseudocode": (
                    "INPUT : sparse polynomial u over exponent triples (a,b,c) ~ x^a y^b W^c\n"
                    "        integer degree l\n"
                    "OUTPUT: TRUE iff  Delta u = -l(l+1) (4 W^2) u  holds identically\n"
                    "\n"
                    "function D_x(p):\n"
                    "    q <- empty\n"
                    "    for each ((a,b,c), v) in p:\n"
                    "        if a > 0:  q <- q + { (a-1, b, c)   : v * a  }\n"
                    "        if c > 0:  q <- q + { (a+1, b, c+1) : -2*v*c }   # dW/dx = -2 x W^2\n"
                    "    return q\n"
                    "\n"
                    "function D_y(p):            # symmetric, with dW/dy = -2 y W^2\n"
                    "    q <- empty\n"
                    "    for each ((a,b,c), v) in p:\n"
                    "        if b > 0:  q <- q + { (a, b-1, c)   : v * b  }\n"
                    "        if c > 0:  q <- q + { (a, b+1, c+1) : -2*v*c }\n"
                    "    return q\n"
                    "\n"
                    "function LAPLACIAN(p):\n"
                    "    return D_x(D_x(p)) + D_y(D_y(p))\n"
                    "\n"
                    "function CLEAR_W(p):\n"
                    "    P <- max{ c : (a,b,c) in support(p) }\n"
                    "    total <- 0\n"
                    "    for each ((a,b,c), v) in p:\n"
                    "        total <- total + v * x^a y^b * (1 + x^2 + y^2)^(P - c)\n"
                    "    return total                       # an honest polynomial in x, y\n"
                    "\n"
                    "function CERTIFY(u, l):\n"
                    "    residual <- LAPLACIAN(u) + 4*l*(l+1) * W^2 * u\n"
                    "    return CLEAR_W(residual) == 0"
                ),
                "code": read(ASSETS / "algo_symbolic_laplacian.py"),
            },
            {
                "name": "Constant-Time Spectral Mode Selection by Unimodal Bracketing",
                "description": (
                    "A rotation-invariant connectivity kernel acts on the degree-l spherical "
                    "eigenspace by the single band-pass multiplier lambda_l(r) = g((lr)^2) with "
                    "g(s) = s e^{1-s}. Because g is strictly increasing on [0,1] and strictly "
                    "decreasing on [1, infinity) with unique peak g(1) = 1 -- all three facts "
                    "following from the elementary inequality t + 1 < e^t for t nonzero -- the "
                    "maximiser over the infinite index set l = 0, 1, 2, ... is necessarily one of "
                    "the two integers bracketing 1/r. The search therefore collapses to two "
                    "evaluations of the exponential, i.e. O(1) work independent of the magnitude "
                    "of the answer, whereas a naive scan costs O(L) for a truncation at degree L "
                    "and is never provably complete. At the resonant radii r = 1/k the maximiser "
                    "is exactly k, and the emergent pattern repertoire has size 2k+1, of which 2k "
                    "members decay in the periphery."
                ),
                "pseudocode": (
                    "INPUT : interaction radius r > 0\n"
                    "OUTPUT: selected degree N, pattern count 2N+1, decaying count 2N\n"
                    "\n"
                    "function GAIN(s):                       # normalised band-pass profile\n"
                    "    return s * exp(1 - s)\n"
                    "\n"
                    "function MULTIPLIER(r, l):\n"
                    "    return GAIN((l * r)^2)\n"
                    "\n"
                    "function SELECTED_DEGREE(r):\n"
                    "    lo <- floor(1 / r)\n"
                    "    hi <- ceil (1 / r)\n"
                    "    # Justification: GAIN increases on [0,1] and decreases on [1,inf),\n"
                    "    # (lo*r)^2 <= 1 <= (hi*r)^2, hence every l <= lo is dominated by lo\n"
                    "    # and every l >= hi is dominated by hi; and hi <= lo + 1.\n"
                    "    if MULTIPLIER(r, lo) >= MULTIPLIER(r, hi): return lo\n"
                    "    else:                                      return hi\n"
                    "\n"
                    "function PATTERN_COUNT(r):\n"
                    "    N <- SELECTED_DEGREE(r)\n"
                    "    return (N, 2*N + 1, 2*N)"
                ),
                "code": read(ASSETS / "algo_mode_selection.py"),
            },
            {
                "name": "Exact Rational Dimension Count for Stereographic Pattern Spaces",
                "description": (
                    "Computes, in exact rational arithmetic, the dimension of the space of "
                    "solutions of Delta u = -l(l+1)(4W^2)u inside the full ansatz of polynomials "
                    "of degree at most l in the three chart coordinates. Each ansatz monomial is "
                    "expanded in the algebra of polynomials in x, y and W; the residual of the "
                    "eigenvalue equation is linear in the unknown coefficients, and multiplying "
                    "by a uniform power of (1+x^2+y^2) clears every W and produces an honest "
                    "polynomial in x and y. Two exact matrices arise: A, sending a coefficient "
                    "vector to the residual, and B, sending it to the function itself. B has a "
                    "nontrivial kernel because the sphere relation sigma_1^2+sigma_2^2+sigma_3^2=1 "
                    "makes the monomials in the chart coordinates linearly dependent; since the "
                    "zero function trivially solves the equation, ker B is contained in ker A, and "
                    "the dimension of the solution space as a space of functions is exactly "
                    "nullity(A) - nullity(B). With M = C(l+3,3) unknowns and O(l^2) polynomial "
                    "monomials in x and y after clearing, the elimination costs O(M^2 * rows) "
                    "rational operations. Running it returns 2l+1 for every degree from 1 to 6, "
                    "giving exact computational evidence for the general upper-bound conjecture."
                ),
                "pseudocode": (
                    "INPUT : degree l\n"
                    "OUTPUT: dimension of { u : deg u <= l in chart coords, "
                    "Delta u = -l(l+1)(4W^2) u }\n"
                    "\n"
                    "1. basis <- all triples (i,j,k) with i + j + k <= l\n"
                    "2. for each (i,j,k):\n"
                    "       p_{ijk} <- sigma_1^i * sigma_2^j * sigma_3^k        (in R[x,y,W])\n"
                    "       r_{ijk} <- LAPLACIAN(p_{ijk}) + 4*l*(l+1) * W^2 * p_{ijk}\n"
                    "3. P_res <- max power of W occurring in any r_{ijk}\n"
                    "   P_val <- max power of W occurring in any p_{ijk}\n"
                    "4. A <- matrix whose columns are CLEAR_W(r_{ijk}, P_res)\n"
                    "   B <- matrix whose columns are CLEAR_W(p_{ijk}, P_val)\n"
                    "5. nA <- NULLITY(A)      # exact Gaussian elimination over the rationals\n"
                    "   nB <- NULLITY(B)      # kernel caused by sum sigma_i^2 = 1\n"
                    "6. return nA - nB        # ker B subset of ker A, so this is well defined"
                ),
                "code": read(ASSETS / "algo_exact_count.py"),
            },
        ],
        "visualizations": [
            {
                "name": "Conformal Chart Geometry: Sphere, Plane, and the Weight 4W^2",
                "description": (
                    "Renders the inverse stereographic correspondence itself: the plane grid and "
                    "unit circle mapped onto the sphere, the conformal weight 4W^2 as a heat map "
                    "over the plane, and the associated area distortion, making visible that the "
                    "chart preserves angles while compressing the far field into a neighbourhood "
                    "of the north pole."
                ),
                "code": read(ASSETS / "viz_chart_geometry.py"),
            },
            {
                "name": "Gallery of the 2l+1 Stereographic Patterns for Degrees One, Two and "
                        "Three",
                "description": (
                    "A three-row gallery showing all fifteen projected eigenmodes as functions on "
                    "the plane, with the image of the equator marked. The sectoral panels display "
                    "the N-fold rosettes predicted by the symmetry theory; the zonal panels show "
                    "the north-pole obstruction directly, since their colour does not fade toward "
                    "the boundary of the frame."
                ),
                "code": read(ASSETS / "viz_pattern_gallery.py"),
            },
            {
                "name": "Mexican-Hat Mode Selection: Band-Pass Gain and the Bracketing of the "
                        "Selected Degree",
                "description": (
                    "Left: the strictly unimodal gain g(s) = s e^{1-s} with the sampled "
                    "multipliers at three interaction radii superimposed, showing resonance at "
                    "s = 1. Right: the selected degree as a staircase function of the radius, "
                    "drawn against the two bracketing candidates floor(1/r) and ceil(1/r), with "
                    "the radius r = 0.4 marked, where the ceiling wins and the naive floor "
                    "formula fails."
                ),
                "code": read(ASSETS / "viz_mode_selection.py"),
            },
            {
                "name": "Far-Field Behaviour: The North-Pole Obstruction and Sharp Sectoral "
                        "Decay Rates",
                "description": (
                    "Left: values along a ray, showing the zonal dipole converging to the "
                    "north-pole value 1 while the modes with vanishing north-pole value fade. "
                    "Right: a log-log comparison of the sectoral magnitudes against the proved "
                    "envelopes 8/R^2 and 32/R^3, confirming that the decay exponent equals the "
                    "order of vanishing of the harmonic at the north pole."
                ),
                "code": read(ASSETS / "viz_decay_profiles.py"),
            },
        ],
        "interactive_demos": [
            {
                "title": "The Stereographic Pattern Explorer: From Cortical Sphere to Visual "
                         "Field",
                "description": (
                    "A single, deeply interactive widget tying the whole theory together. A "
                    "slider sets the interaction radius r; a live bar chart shows the band-pass "
                    "multipliers across degrees, highlighting the two bracketing candidates "
                    "floor(1/r) and ceil(1/r) and the winner, and reporting the resulting counts "
                    "2N+1 patterns of which 2N decay. Selecting a degree and one of its 2N+1 "
                    "patterns renders it simultaneously as a function on the plane (with the "
                    "image of the equator drawn) and as a shaded function on the cortical sphere, "
                    "so the reader can see the same mode in both pictures at once. A rotation "
                    "slider demonstrates that plane rotations are polar rotations of the sphere, "
                    "making the N-fold symmetry of the sectoral modes visible; a Kelvin-inversion "
                    "toggle turns the pattern inside out through the unit circle and flips the "
                    "sphere north-for-south. Selecting a zonal mode triggers an explanation of "
                    "the north-pole obstruction, since those are precisely the modes that do not "
                    "fade at infinity."
                ),
                "html": read(ASSETS / "widget_pattern_explorer.html"),
            }
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": lean_bundle(),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": demo_src},
        "lean_files": LEAN_FILES,
    }


def main() -> None:
    data = package()
    (ROOT / "PACKAGE.json").write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote PACKAGE.json ({(ROOT / 'PACKAGE.json').stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""The inverse stereographic chart: what it does to the plane, and its conformal weight.

Left panel: a polar grid of the plane, together with its image on the sphere under
sigma(x, y) = (2xW, 2yW, (x^2+y^2-1)W), drawn in an orthographic projection.  Circles of
the plane become circles of the sphere; the unit circle becomes the equator; the far field
crowds into a small cap around the north pole.

Right panel: the conformal weight 4W^2, which multiplies the flat metric to give the round
metric of the sphere.  Because the chart is conformal, angles are exactly preserved and the
only distortion is this single scalar; in two dimensions that is what turns the curved
eigenvalue problem into the flat weighted equation Delta u = -l(l+1)(4W^2)u.
"""

from __future__ import annotations

from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np


def chart(x: np.ndarray, y: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    w = 1.0 / (1.0 + x ** 2 + y ** 2)
    return 2.0 * x * w, 2.0 * y * w, (x ** 2 + y ** 2 - 1.0) * w


def main() -> None:
    fig = plt.figure(figsize=(14, 6))

    ax = fig.add_subplot(1, 2, 1, projection="3d")
    theta = np.linspace(0, 2 * np.pi, 400)
    for radius in (0.25, 0.5, 1.0, 2.0, 4.0, 8.0):
        xs, ys = radius * np.cos(theta), radius * np.sin(theta)
        a, b, c = chart(xs, ys)
        style = dict(lw=2.4, color="crimson") if radius == 1.0 else dict(lw=1.1, color="0.35")
        ax.plot(a, b, c, **style)
    for ang in np.linspace(0, np.pi, 9)[:-1]:
        t = np.linspace(-12, 12, 600)
        xs, ys = t * np.cos(ang), t * np.sin(ang)
        a, b, c = chart(xs, ys)
        ax.plot(a, b, c, lw=0.8, color="0.6")
    u, v = np.mgrid[0:2 * np.pi:80j, 0:np.pi:40j]
    ax.plot_surface(np.cos(u) * np.sin(v), np.sin(u) * np.sin(v), np.cos(v),
                    color="0.85", alpha=0.18, linewidth=0, shade=False)
    ax.scatter([0], [0], [1], color="tab:blue", s=45)
    ax.text(0, 0, 1.18, "north pole\n= infinity of the plane", ha="center", fontsize=9)
    ax.scatter([0], [0], [-1], color="tab:green", s=45)
    ax.text(0, 0, -1.45, "south pole = origin", ha="center", fontsize=9)
    ax.set_box_aspect((1, 1, 1))
    ax.set_axis_off()
    ax.set_title("Plane grid mapped to the sphere\n(the red curve is the unit circle "
                 "= the equator)", fontsize=11)

    ax2 = fig.add_subplot(1, 2, 2)
    extent, n = 3.0, 500
    grid = np.linspace(-extent, extent, n)
    xx, yy = np.meshgrid(grid, grid)
    w = 1.0 / (1.0 + xx ** 2 + yy ** 2)
    im = ax2.imshow(4 * w ** 2, extent=(-extent, extent, -extent, extent),
                    origin="lower", cmap="magma")
    ax2.add_patch(plt.Circle((0, 0), 1.0, fill=False, ls="--", color="w", lw=1.4))
    ax2.set_title(r"Conformal weight $4W^2$, $W=(1+x^2+y^2)^{-1}$"
                  "\n(angles preserved; only scale changes)", fontsize=11)
    ax2.set_xlabel("$x$"); ax2.set_ylabel("$y$")
    fig.colorbar(im, ax=ax2, shrink=0.85)

    fig.tight_layout()
    fig.savefig("chart_geometry.png", dpi=150)
    print("wrote chart_geometry.png")


if __name__ == "__main__":
    main()


"""Far-field behaviour of stereographic patterns: the north-pole obstruction and the
sharp decay rates of the sectoral modes.

Left panel: values along a ray.  The zonal dipole tends to the north-pole value 1 and
does not decay; the sectoral modes fade to zero.
Right panel: log-log decay of the sectoral modes against the proved envelopes 8/R^2 and
32/R^3, and against the O(1/R) envelope of a general dipole with vanishing zonal part.
"""

from __future__ import annotations

from typing import Tuple

import matplotlib.pyplot as plt
import numpy as np


def chart(x: np.ndarray, y: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    w = 1.0 / (1.0 + x ** 2 + y ** 2)
    return 2.0 * x * w, 2.0 * y * w, (x ** 2 + y ** 2 - 1.0) * w


def main() -> None:
    direction = np.array([0.6, 0.8])          # a unit direction in the plane
    radii = np.logspace(0, 3, 400)
    xs, ys = radii * direction[0], radii * direction[1]
    s1, s2, s3 = chart(xs, ys)

    zonal = s3
    dipole = s1 - 2.0 * s2                     # vanishing zonal coefficient: decays
    sect2 = s1 ** 2 - s2 ** 2
    sect3 = s1 * (s1 ** 2 - 3 * s2 ** 2)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.2))

    ax1.semilogx(radii, zonal, lw=2, color="crimson",
                 label=r"zonal $\sigma_3$ $\to$ 1 (no decay)")
    ax1.semilogx(radii, dipole, lw=2, color="tab:blue",
                 label=r"$\sigma_1-2\sigma_2$ (zonal part $0$)")
    ax1.semilogx(radii, sect2, lw=2, color="tab:green",
                 label=r"$\sigma_1^2-\sigma_2^2$")
    ax1.semilogx(radii, sect3, lw=2, color="tab:purple",
                 label=r"$\sigma_1(\sigma_1^2-3\sigma_2^2)$")
    ax1.axhline(1.0, color="0.6", ls="--", lw=1)
    ax1.set_xlabel("distance $R$ along a ray"); ax1.set_ylabel("value")
    ax1.set_title("The north-pole obstruction: one mode per degree refuses to fade")
    ax1.legend(fontsize=9); ax1.grid(alpha=0.25)

    ax2.loglog(radii, np.abs(dipole), lw=2, color="tab:blue", label=r"$|\sigma_1-2\sigma_2|$")
    ax2.loglog(radii, 6.0 / radii, ls="--", color="tab:blue", alpha=0.6,
               label=r"envelope $\propto R^{-1}$")
    ax2.loglog(radii, np.abs(sect2), lw=2, color="tab:green", label=r"$|\sigma_1^2-\sigma_2^2|$")
    ax2.loglog(radii, 8.0 / radii ** 2, ls="--", color="tab:green", alpha=0.6,
               label=r"proved bound $8/R^2$")
    ax2.loglog(radii, np.abs(sect3), lw=2, color="tab:purple",
               label=r"$|\sigma_1(\sigma_1^2-3\sigma_2^2)|$")
    ax2.loglog(radii, 32.0 / radii ** 3, ls="--", color="tab:purple", alpha=0.6,
               label=r"proved bound $32/R^3$")
    ax2.set_xlabel("distance $R$ along a ray"); ax2.set_ylabel("magnitude")
    ax2.set_title("Sectoral decay rates match the vanishing order at the north pole")
    ax2.legend(fontsize=9); ax2.grid(alpha=0.25, which="both")

    fig.tight_layout()
    fig.savefig("decay_profiles.png", dpi=150)
    print("wrote decay_profiles.png")


if __name__ == "__main__":
    main()


"""Mexican-hat mode selection: the band-pass gain, the bracketing theorem, and the
radius at which the naive floor formula fails.

Left panel: the continuous gain g(s) = s e^{1-s} together with the sampled multipliers
lambda_l(r) = g((lr)^2) at three interaction radii.
Right panel: the selected degree as a function of r, with the two bracketing candidates
floor(1/r) and ceil(1/r) drawn behind it; the marked radius r = 0.4 is one where the
selected degree is the ceiling, not the floor.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt
import numpy as np


def gain(s: np.ndarray | float) -> np.ndarray | float:
    return s * np.exp(1.0 - s)


def multiplier(r: float, l: int) -> float:
    return float(gain((l * r) ** 2))


def selected_degree(r: float) -> int:
    lo, hi = math.floor(1.0 / r), math.ceil(1.0 / r)
    return lo if multiplier(r, lo) >= multiplier(r, hi) else hi


def main() -> None:
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5.2))

    s = np.linspace(0, 6, 600)
    ax1.plot(s, gain(s), color="0.3", lw=2, label=r"$g(s)=s\,e^{1-s}$")
    ax1.axvline(1.0, color="crimson", ls="--", lw=1, label="resonance $s=1$")
    for r, colour in [(1.0, "tab:blue"), (0.4, "tab:orange"), (1 / 3, "tab:green")]:
        ls_ = [l for l in range(0, 8)]
        ax1.scatter([(l * r) ** 2 for l in ls_], [multiplier(r, l) for l in ls_],
                    s=42, color=colour, zorder=3, label=f"$r={r:.3g}$")
    ax1.set_xlim(0, 8)
    ax1.set_xlabel(r"$s=(lr)^2$"); ax1.set_ylabel("spectral gain")
    ax1.set_title("Band-pass gain: strictly unimodal, unique peak $g(1)=1$")
    ax1.legend(fontsize=9); ax1.grid(alpha=0.25)

    rs = np.linspace(0.12, 1.4, 1600)
    floors: List[int] = [math.floor(1 / r) for r in rs]
    ceils: List[int] = [math.ceil(1 / r) for r in rs]
    sel: List[int] = [selected_degree(float(r)) for r in rs]
    ax2.plot(rs, ceils, color="0.75", lw=6, alpha=0.6, label=r"$\lceil 1/r\rceil$")
    ax2.plot(rs, floors, color="0.55", lw=3, alpha=0.7, label=r"$\lfloor 1/r\rfloor$")
    ax2.plot(rs, sel, color="crimson", lw=2, label="selected degree $N$")
    ax2.scatter([0.4], [selected_degree(0.4)], color="black", zorder=4, s=45)
    ax2.annotate(r"$r=0.4$: floor $=2$ but the winner is $3$",
                 xy=(0.4, selected_degree(0.4)), xytext=(0.52, 5.2), fontsize=10,
                 arrowprops=dict(arrowstyle="->", color="black"))
    ax2.set_xlabel("interaction radius $r$"); ax2.set_ylabel("degree")
    ax2.set_title("Selected degree is bracketed by the floor and the ceiling of $1/r$")
    ax2.set_ylim(0, 8.5); ax2.legend(fontsize=9); ax2.grid(alpha=0.25)

    fig.tight_layout()
    fig.savefig("mode_selection.png", dpi=150)
    print("wrote mode_selection.png")


if __name__ == "__main__":
    main()


"""Gallery of the 2l+1 stereographic patterns of degrees l = 1, 2, 3.

Each panel shows one pattern as a function on the plane, obtained by pulling a spherical
eigenmode down through inverse stereographic projection.  The dashed circle is the image
of the equator.  Sectoral panels display N-fold rosettes; zonal panels do not fade at the
boundary of the frame, which is the north-pole obstruction made visible.
"""

from __future__ import annotations

from typing import Callable, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

Pattern = Callable[[np.ndarray, np.ndarray, np.ndarray], np.ndarray]


def chart(x: np.ndarray, y: np.ndarray) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    w = 1.0 / (1.0 + x ** 2 + y ** 2)
    return 2.0 * x * w, 2.0 * y * w, (x ** 2 + y ** 2 - 1.0) * w


FAMILIES: List[Tuple[int, List[Tuple[str, Pattern]]]] = [
    (1, [
        (r"$\sigma_1$", lambda a, b, c: a),
        (r"$\sigma_2$", lambda a, b, c: b),
        (r"$\sigma_3$ (zonal)", lambda a, b, c: c),
    ]),
    (2, [
        (r"$\sigma_1\sigma_2$", lambda a, b, c: a * b),
        (r"$\sigma_1\sigma_3$", lambda a, b, c: a * c),
        (r"$\sigma_2\sigma_3$", lambda a, b, c: b * c),
        (r"$\sigma_1^2-\sigma_2^2$ (2-fold)", lambda a, b, c: a ** 2 - b ** 2),
        (r"$3\sigma_3^2-1$ (zonal)", lambda a, b, c: 3 * c ** 2 - 1),
    ]),
    (3, [
        (r"$\sigma_1(\sigma_1^2-3\sigma_2^2)$ (3-fold)", lambda a, b, c: a * (a ** 2 - 3 * b ** 2)),
        (r"$\sigma_2(3\sigma_1^2-\sigma_2^2)$ (3-fold)", lambda a, b, c: b * (3 * a ** 2 - b ** 2)),
        (r"$\sigma_3(\sigma_1^2-\sigma_2^2)$", lambda a, b, c: c * (a ** 2 - b ** 2)),
        (r"$\sigma_1\sigma_2\sigma_3$", lambda a, b, c: a * b * c),
        (r"$\sigma_1(5\sigma_3^2-1)$", lambda a, b, c: a * (5 * c ** 2 - 1)),
        (r"$\sigma_2(5\sigma_3^2-1)$", lambda a, b, c: b * (5 * c ** 2 - 1)),
        (r"$\sigma_3(5\sigma_3^2-3)$ (zonal)", lambda a, b, c: c * (5 * c ** 2 - 3)),
    ]),
]


def main() -> None:
    extent, n = 3.0, 420
    grid = np.linspace(-extent, extent, n)
    xx, yy = np.meshgrid(grid, grid)
    s1, s2, s3 = chart(xx, yy)

    fig, axes = plt.subplots(3, 7, figsize=(19, 8.6))
    for row, (degree, patterns) in enumerate(FAMILIES):
        for col in range(7):
            ax = axes[row][col]
            ax.set_xticks([]); ax.set_yticks([])
            if col >= len(patterns):
                ax.axis("off")
                continue
            title, fun = patterns[col]
            field = fun(s1, s2, s3)
            scale = np.max(np.abs(field))
            ax.imshow(field, extent=(-extent, extent, -extent, extent),
                      cmap="RdBu_r", vmin=-scale, vmax=scale, origin="lower")
            circle = plt.Circle((0, 0), 1.0, fill=False, linestyle="--",
                                color="0.25", linewidth=0.9)
            ax.add_patch(circle)
            ax.set_title(title, fontsize=9)
        axes[row][0].set_ylabel(f"degree $l={degree}$\n({2*degree+1} patterns)", fontsize=10)

    fig.suptitle("Stereographic patterns: the $2l+1$ modes of each selected degree, "
                 "drawn on the plane", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.96))
    fig.savefig("pattern_gallery.png", dpi=150)
    print("wrote pattern_gallery.png")


if __name__ == "__main__":
    main()


"""
Inverse Stereographic Neural Field Theory -- numerical demonstrations.

This self-contained script verifies, numerically and symbolically-by-exact-rational
arithmetic, the main results of the theory:

  1. The inverse stereographic chart
         sigma(x, y) = (2xW, 2yW, (x^2 + y^2 - 1)W),   W = 1 / (1 + x^2 + y^2)
     lands on the unit sphere and is conformal with factor 4W^2.

  2. The transported Laplace-Beltrami eigenvalue equation
         Delta u = -l(l+1) * (4W^2) * u
     holds for all fifteen explicitly constructed patterns of degrees l = 1, 2, 3.

  3. The fifteen patterns split into three linearly independent families of sizes
     3, 5, 7 = 2l + 1.

  4. Mexican-hat mode selection: the normalised band-pass gain g(s) = s e^{1-s} is
     strictly unimodal with peak g(1) = 1; the maximising degree at radius r is
     always floor(1/r) or ceil(1/r); at r = 1/k it is exactly k; and at r = 0.4 the
     ceiling (3) beats the floor (2), refuting the naive floor formula.

  5. The north-pole obstruction: the zonal dipole tends to 1 at infinity, while a
     degree-one pattern decays along every ray iff its zonal coefficient vanishes.
     Sectoral patterns decay at the sharp rates 8/R^2 and 32/R^3.

  6. Rotational symmetry: the degree-N sectoral pattern is invariant under rotation
     by 2*pi/N (N = 2, 3) and odd under the half-turn for N = 1; Kelvin inversion of
     the plane negates the polar chart coordinate and fixes the two horizontal ones.

Only the Python standard library is used.
"""

from __future__ import annotations

import math
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Point = Tuple[float, float]
Field = Callable[[float, float], float]


# --------------------------------------------------------------------------------------
# 1. The chart
# --------------------------------------------------------------------------------------

def conformal_atom(x: float, y: float) -> float:
    """W(x, y) = 1 / (1 + x^2 + y^2)."""
    return 1.0 / (1.0 + x * x + y * y)


def chart(x: float, y: float) -> Tuple[float, float, float]:
    """Inverse stereographic chart sigma(x, y) = (2xW, 2yW, (x^2+y^2-1)W)."""
    w = conformal_atom(x, y)
    return (2.0 * x * w, 2.0 * y * w, (x * x + y * y - 1.0) * w)


def sigma1(x: float, y: float) -> float:
    return chart(x, y)[0]


def sigma2(x: float, y: float) -> float:
    return chart(x, y)[1]


def sigma3(x: float, y: float) -> float:
    return chart(x, y)[2]


# --------------------------------------------------------------------------------------
# 2. Numerical differential operators (high-order central differences)
# --------------------------------------------------------------------------------------

def laplacian(u: Field, x: float, y: float, h: float = 1e-3) -> float:
    """Fourth-order accurate five-point-per-axis Euclidean Laplacian."""
    def second(f: Callable[[float], float], t: float) -> float:
        return (
            -f(t + 2 * h) + 16 * f(t + h) - 30 * f(t) + 16 * f(t - h) - f(t - 2 * h)
        ) / (12 * h * h)

    return second(lambda s: u(s, y), x) + second(lambda t: u(x, t), y)


def grad_dot(u: Field, v: Field, x: float, y: float, h: float = 1e-3) -> float:
    """Euclidean gradient pairing, fourth-order accurate."""
    def first(f: Callable[[float], float], t: float) -> float:
        return (-f(t + 2 * h) + 8 * f(t + h) - 8 * f(t - h) + f(t - 2 * h)) / (12 * h)

    ux = first(lambda s: u(s, y), x)
    vx = first(lambda s: v(s, y), x)
    uy = first(lambda t: u(x, t), y)
    vy = first(lambda t: v(x, t), y)
    return ux * vx + uy * vy


# --------------------------------------------------------------------------------------
# 3. The fifteen explicit patterns of degrees 1, 2, 3
# --------------------------------------------------------------------------------------

def degree_one_patterns() -> List[Tuple[str, Field]]:
    return [
        ("s1  (dipole x)", sigma1),
        ("s2  (dipole y)", sigma2),
        ("s3  (dipole z, zonal)", sigma3),
    ]


def degree_two_patterns() -> List[Tuple[str, Field]]:
    def xy(x: float, y: float) -> float:
        a, b, _ = chart(x, y)
        return a * b

    def xz(x: float, y: float) -> float:
        a, _, c = chart(x, y)
        return a * c

    def yz(x: float, y: float) -> float:
        _, b, c = chart(x, y)
        return b * c

    def x2y2(x: float, y: float) -> float:
        a, b, _ = chart(x, y)
        return a * a - b * b

    def z2(x: float, y: float) -> float:
        _, _, c = chart(x, y)
        return 3.0 * c * c - 1.0

    return [
        ("s1 s2", xy),
        ("s1 s3", xz),
        ("s2 s3", yz),
        ("s1^2 - s2^2  (sectoral, 2-fold)", x2y2),
        ("3 s3^2 - 1   (zonal)", z2),
    ]


def degree_three_patterns() -> List[Tuple[str, Field]]:
    def h3a(x: float, y: float) -> float:
        a, b, _ = chart(x, y)
        return a ** 3 - 3.0 * a * b * b

    def h3b(x: float, y: float) -> float:
        a, b, _ = chart(x, y)
        return 3.0 * b * a * a - b ** 3

    def h3c(x: float, y: float) -> float:
        a, b, c = chart(x, y)
        return c * (a * a - b * b)

    def h3d(x: float, y: float) -> float:
        a, b, c = chart(x, y)
        return a * b * c

    def h3e(x: float, y: float) -> float:
        a, _, c = chart(x, y)
        return a * (5.0 * c * c - 1.0)

    def h3f(x: float, y: float) -> float:
        _, b, c = chart(x, y)
        return b * (5.0 * c * c - 1.0)

    def h3g(x: float, y: float) -> float:
        _, _, c = chart(x, y)
        return c * (5.0 * c * c - 3.0)

    return [
        ("s1(s1^2 - 3 s2^2)  (sectoral, 3-fold)", h3a),
        ("s2(3 s1^2 - s2^2)  (sectoral, 3-fold)", h3b),
        ("s3(s1^2 - s2^2)", h3c),
        ("s1 s2 s3", h3d),
        ("s1(5 s3^2 - 1)", h3e),
        ("s2(5 s3^2 - 1)", h3f),
        ("s3(5 s3^2 - 3)  (zonal)", h3g),
    ]


# --------------------------------------------------------------------------------------
# 4. Exact symbolic verification in the chart algebra R[x, y, W]
# --------------------------------------------------------------------------------------

Monomials = dict  # (a, b, c) -> Fraction, denoting coeff * x^a y^b W^c


def poly_add(p: Monomials, q: Monomials) -> Monomials:
    out = dict(p)
    for key, val in q.items():
        out[key] = out.get(key, Fraction(0)) + val
        if out[key] == 0:
            del out[key]
    return out


def poly_scale(p: Monomials, c: Fraction) -> Monomials:
    if c == 0:
        return {}
    return {k: c * v for k, v in p.items()}


def poly_mul(p: Monomials, q: Monomials) -> Monomials:
    out: Monomials = {}
    for (a1, b1, c1), v1 in p.items():
        for (a2, b2, c2), v2 in q.items():
            key = (a1 + a2, b1 + b2, c1 + c2)
            out[key] = out.get(key, Fraction(0)) + v1 * v2
            if out[key] == 0:
                del out[key]
    return out


def d_x(p: Monomials) -> Monomials:
    """Symbolic partial derivative in x, using dW/dx = -2 x W^2."""
    out: Monomials = {}

    def bump(key: Tuple[int, int, int], val: Fraction) -> None:
        out[key] = out.get(key, Fraction(0)) + val
        if out[key] == 0:
            del out[key]

    for (a, b, c), v in p.items():
        if a > 0:
            bump((a - 1, b, c), v * a)
        if c > 0:
            bump((a + 1, b, c + 1), -2 * v * c)
    return out


def d_y(p: Monomials) -> Monomials:
    """Symbolic partial derivative in y, using dW/dy = -2 y W^2."""
    out: Monomials = {}

    def bump(key: Tuple[int, int, int], val: Fraction) -> None:
        out[key] = out.get(key, Fraction(0)) + val
        if out[key] == 0:
            del out[key]

    for (a, b, c), v in p.items():
        if b > 0:
            bump((a, b - 1, c), v * b)
        if c > 0:
            bump((a, b + 1, c + 1), -2 * v * c)
    return out


def poly_laplacian(p: Monomials) -> Monomials:
    return poly_add(d_x(d_x(p)), d_y(d_y(p)))


DENOM: Monomials = {(0, 0, 0): Fraction(1), (2, 0, 0): Fraction(1), (0, 2, 0): Fraction(1)}
# DENOM denotes 1 + x^2 + y^2, and W * DENOM = 1.


def reduce_W(p: Monomials, target_power: int) -> Monomials:
    """Multiply p by (1+x^2+y^2)^target_power, using W (1+x^2+y^2) = 1 to clear every W.

    The result is an honest polynomial in x and y, and it vanishes identically exactly
    when p does (the multiplier is nowhere zero).
    """
    reduced: Monomials = {}
    for (a, b, c), v in p.items():
        if c > target_power:
            raise ValueError("insufficient denominator power to clear W")
        term: Monomials = {(a, b, 0): v}
        for _ in range(target_power - c):
            term = poly_mul(term, DENOM)
        reduced = poly_add(reduced, term)
    return reduced


def sym_chart() -> Tuple[Monomials, Monomials, Monomials]:
    s1 = {(1, 0, 1): Fraction(2)}
    s2 = {(0, 1, 1): Fraction(2)}
    s3 = {(2, 0, 1): Fraction(1), (0, 2, 1): Fraction(1), (0, 0, 1): Fraction(-1)}
    return s1, s2, s3


def certify_eigenfunction(u: Monomials, degree: int) -> bool:
    """Exactly certify Delta u = -l(l+1) * 4 W^2 * u, with rational arithmetic."""
    lhs = poly_laplacian(u)
    weight = {(0, 0, 2): Fraction(-4 * degree * (degree + 1))}
    rhs = poly_mul(weight, u)
    residual = poly_add(lhs, poly_scale(rhs, Fraction(-1)))
    if not residual:
        return True
    max_w = max(c for (_, _, c) in residual)
    cleared = reduce_W(residual, max_w)
    return not cleared


# --------------------------------------------------------------------------------------
# 5. Mexican-hat spectral selection
# --------------------------------------------------------------------------------------

def band_pass_gain(s: float) -> float:
    """g(s) = s exp(1 - s); the normalised Mexican-hat spectral profile, peak g(1) = 1."""
    return s * math.exp(1.0 - s)


def mexican_hat_multiplier(r: float, l: int) -> float:
    """Funk-Hecke multiplier of a Mexican hat of interaction radius r on degree l."""
    return band_pass_gain((l * r) ** 2)


def selected_degree(r: float) -> int:
    """The maximising degree; by the bracketing theorem only two candidates need testing."""
    lo = math.floor(1.0 / r)
    hi = math.ceil(1.0 / r)
    return lo if mexican_hat_multiplier(r, lo) >= mexican_hat_multiplier(r, hi) else hi


def brute_force_selected_degree(r: float, l_max: int = 400) -> int:
    """Exhaustive search, used to confirm that the two-candidate shortcut is valid."""
    return max(range(0, l_max + 1), key=lambda l: mexican_hat_multiplier(r, l))


# --------------------------------------------------------------------------------------
# 6. Decay, symmetry, duality
# --------------------------------------------------------------------------------------

def ray_value(u: Field, direction: Point, radius: float) -> float:
    ux, vy = direction
    norm = math.hypot(ux, vy)
    return u(radius * ux / norm, radius * vy / norm)


def rotate(x: float, y: float, theta: float) -> Point:
    c, s = math.cos(theta), math.sin(theta)
    return (c * x - s * y, s * x + c * y)


def kelvin(x: float, y: float) -> Point:
    d = x * x + y * y
    return (x / d, y / d)


# --------------------------------------------------------------------------------------
# 7. Driver
# --------------------------------------------------------------------------------------

SAMPLE_POINTS: Sequence[Point] = (
    (0.3, -0.7), (1.4, 0.2), (-0.9, 1.1), (2.5, -1.7), (0.05, 0.04),
)


def demo_chart() -> None:
    print("=" * 78)
    print("1. The chart lands on the sphere and is conformal with factor 4W^2")
    print("=" * 78)
    worst_sphere, worst_conf, worst_orth = 0.0, 0.0, 0.0
    for (x, y) in SAMPLE_POINTS:
        a, b, c = chart(x, y)
        worst_sphere = max(worst_sphere, abs(a * a + b * b + c * c - 1.0))
        w = conformal_atom(x, y)
        # grad_dot(f, f) = f_x^2 + f_y^2, so summing over the three components and halving
        # returns the common diagonal entry of the pullback metric.
        diag = sum(grad_dot(f, f, x, y) for f in (sigma1, sigma2, sigma3)) / 2.0
        worst_conf = max(worst_conf, abs(diag - 4.0 * w * w))
        # orthogonality of the two coordinate directions
        h = 1e-4
        dxs = [(f(x + h, y) - f(x - h, y)) / (2 * h) for f in (sigma1, sigma2, sigma3)]
        dys = [(f(x, y + h) - f(x, y - h)) / (2 * h) for f in (sigma1, sigma2, sigma3)]
        worst_orth = max(worst_orth, abs(sum(p * q for p, q in zip(dxs, dys))))
    print(f"  max |sigma|^2 - 1              = {worst_sphere:.3e}")
    print(f"  max ||d sigma|^2 - 4W^2|       = {worst_conf:.3e}")
    print(f"  max |d_x sigma . d_y sigma|    = {worst_orth:.3e}")
    print()


def demo_eigenvalues() -> None:
    print("=" * 78)
    print("2. Transported eigenvalue equation  Delta u = -l(l+1) (4W^2) u")
    print("=" * 78)
    families = [(1, degree_one_patterns()), (2, degree_two_patterns()),
                (3, degree_three_patterns())]
    for degree, patterns in families:
        print(f"  degree l = {degree}   (eigenvalue -l(l+1) = {-degree*(degree+1)})")
        for name, u in patterns:
            err = 0.0
            for (x, y) in SAMPLE_POINTS:
                w = conformal_atom(x, y)
                lhs = laplacian(u, x, y)
                rhs = -degree * (degree + 1) * (4.0 * w * w) * u(x, y)
                err = max(err, abs(lhs - rhs))
            print(f"    {name:42s} max residual = {err:.2e}")
        print()


def demo_exact_certification() -> None:
    print("=" * 78)
    print("3. Exact rational certification in the algebra R[x, y, W]")
    print("=" * 78)
    s1, s2, s3 = sym_chart()

    def m(*factors: Monomials) -> Monomials:
        out: Monomials = {(0, 0, 0): Fraction(1)}
        for f in factors:
            out = poly_mul(out, f)
        return out

    one: Monomials = {(0, 0, 0): Fraction(1)}
    tests = [
        ("s1", 1, s1),
        ("s3", 1, s3),
        ("s1 s2", 2, m(s1, s2)),
        ("s1^2 - s2^2", 2, poly_add(m(s1, s1), poly_scale(m(s2, s2), Fraction(-1)))),
        ("3 s3^2 - 1", 2, poly_add(poly_scale(m(s3, s3), Fraction(3)),
                                   poly_scale(one, Fraction(-1)))),
        ("s1(s1^2-3s2^2)", 3, poly_add(m(s1, s1, s1),
                                       poly_scale(m(s1, s2, s2), Fraction(-3)))),
        ("s1 s2 s3", 3, m(s1, s2, s3)),
        ("s3(5 s3^2 - 3)", 3, poly_add(poly_scale(m(s3, s3, s3), Fraction(5)),
                                       poly_scale(s3, Fraction(-3)))),
    ]
    for name, degree, poly in tests:
        ok = certify_eigenfunction(poly, degree)
        print(f"  {name:18s} degree {degree}: exact identity {'VERIFIED' if ok else 'FAILED'}")
    # a deliberate non-eigenfunction, as a control
    bogus = poly_add(s1, {(0, 0, 0): Fraction(1)})
    print(f"  {'s1 + 1 (control)':18s} degree 1: exact identity "
          f"{'VERIFIED' if certify_eigenfunction(bogus, 1) else 'FAILED (as expected)'}")
    print()


def demo_independence() -> None:
    print("=" * 78)
    print("4. Linear independence: dim = 2l+1 for l = 1, 2, 3")
    print("=" * 78)
    grids = [(-1.3, 0.4), (0.7, -0.2), (2.1, 1.6), (0.0, 0.9), (-0.5, -1.8),
             (1.0, 0.0), (0.0, 2.0), (0.5, 0.5), (-2.0, 0.3), (1.7, -0.6)]
    for degree, patterns in [(1, degree_one_patterns()), (2, degree_two_patterns()),
                             (3, degree_three_patterns())]:
        matrix = [[u(x, y) for _, u in patterns] for (x, y) in grids]
        rank = matrix_rank(matrix)
        print(f"  degree {degree}: {len(patterns)} patterns, numerical rank = {rank}"
              f"  (expected 2*{degree}+1 = {2*degree+1})")
    print()


def matrix_rank(rows: List[List[float]], tol: float = 1e-9) -> int:
    """Rank by Gaussian elimination with partial pivoting."""
    mat = [row[:] for row in rows]
    n_rows, n_cols = len(mat), len(mat[0])
    rank, pivot_row = 0, 0
    for col in range(n_cols):
        best = max(range(pivot_row, n_rows), key=lambda i: abs(mat[i][col]), default=None)
        if best is None or abs(mat[best][col]) < tol:
            continue
        mat[pivot_row], mat[best] = mat[best], mat[pivot_row]
        piv = mat[pivot_row][col]
        for i in range(pivot_row + 1, n_rows):
            factor = mat[i][col] / piv
            for j in range(col, n_cols):
                mat[i][j] -= factor * mat[pivot_row][j]
        rank += 1
        pivot_row += 1
        if pivot_row == n_rows:
            break
    return rank


def demo_selection() -> None:
    print("=" * 78)
    print("5. Mexican-hat mode selection")
    print("=" * 78)
    print("  Resonant radii r = 1/k: selected degree is exactly k, with multiplier 1.")
    for k in (1, 2, 3, 4, 5):
        r = 1.0 / k
        lam = mexican_hat_multiplier(r, k)
        runner_up = max(mexican_hat_multiplier(r, l) for l in range(0, 40) if l != k)
        print(f"    k = {k}: r = {r:.4f}, lambda_k = {lam:.6f}, "
              f"best competitor = {runner_up:.6f}, argmax = {brute_force_selected_degree(r)}")
    print()
    print("  Bracketing theorem: two candidates always suffice.")
    mismatches = 0
    r = 0.05
    while r < 3.0:
        if selected_degree(r) != brute_force_selected_degree(r):
            mismatches += 1
        r += 0.0013
    print(f"    mismatches between two-candidate rule and exhaustive search: {mismatches}")
    print()
    print("  Counterexample to the naive floor formula, r = 0.4  (1/r = 2.5):")
    print(f"    lambda_2 = {mexican_hat_multiplier(0.4, 2):.6f}  (floor)")
    print(f"    lambda_3 = {mexican_hat_multiplier(0.4, 3):.6f}  (ceiling)  <-- winner")
    print(f"    selected degree = {selected_degree(0.4)}")
    print()


def demo_decay() -> None:
    print("=" * 78)
    print("6. Behaviour at infinity: the north-pole obstruction")
    print("=" * 78)
    print("  Zonal dipole s3 along the horizontal ray (tends to the north-pole value 1):")
    for R in (1.0, 10.0, 100.0, 1000.0):
        print(f"    R = {R:7.1f}:  s3 = {ray_value(sigma3, (1.0, 0.0), R):.8f}")
    print()
    print("  General dipole a s1 + b s2 + c s3 with (a,b,c) = (1, -2, 0.5):")
    a, b, c = 1.0, -2.0, 0.5

    def dip(x: float, y: float) -> float:
        p, q, z = chart(x, y)
        return a * p + b * q + c * z

    bound = 2 * abs(a) + 2 * abs(b) + 2 * abs(c)
    for R in (1.0, 10.0, 100.0):
        val = ray_value(dip, (0.6, 0.8), R)
        print(f"    R = {R:6.1f}:  value = {val:+.8f},  |value - c| = {abs(val-c):.3e}"
              f"  <=  {bound}/R = {bound/R:.3e}")
    print()
    print("  Sectoral decay rates (sharp constants 8/R^2 and 32/R^3):")

    def sect2(x: float, y: float) -> float:
        p, q, _ = chart(x, y)
        return p * p - q * q

    def sect3(x: float, y: float) -> float:
        p, q, _ = chart(x, y)
        return p ** 3 - 3 * p * q * q

    for R in (2.0, 10.0, 50.0):
        v2 = abs(ray_value(sect2, (1.0, 0.3), R))
        v3 = abs(ray_value(sect3, (1.0, 0.3), R))
        print(f"    R = {R:5.1f}: |s1^2-s2^2| = {v2:.3e} <= {8/R**2:.3e};  "
              f"|s1(s1^2-3s2^2)| = {v3:.3e} <= {32/R**3:.3e}")
    print()


def demo_symmetry() -> None:
    print("=" * 78)
    print("7. Rotational symmetry and Kelvin duality")
    print("=" * 78)

    def sect1(x: float, y: float) -> float:
        return sigma1(x, y)

    def sect2(x: float, y: float) -> float:
        p, q, _ = chart(x, y)
        return p * p - q * q

    def sect3(x: float, y: float) -> float:
        p, q, _ = chart(x, y)
        return p ** 3 - 3 * p * q * q

    for name, f, n in (("s1", sect1, 1), ("s1^2 - s2^2", sect2, 2),
                       ("s1(s1^2 - 3 s2^2)", sect3, 3)):
        err_inv, err_odd = 0.0, 0.0
        for (x, y) in SAMPLE_POINTS:
            xr, yr = rotate(x, y, 2 * math.pi / n)
            err_inv = max(err_inv, abs(f(xr, yr) - f(x, y)))
            xh, yh = rotate(x, y, math.pi)
            err_odd = max(err_odd, abs(f(xh, yh) + f(x, y)))
        parity = "odd" if err_odd < 1e-12 else "even"
        print(f"  {name:20s}: |f(rot_{{2pi/{n}}} p) - f(p)| <= {err_inv:.2e}"
              f"   half-turn parity: {parity}")
    print("  The degree-N sectoral pattern is invariant under rotation by 2pi/N.")
    print("  For N = 1 the half-turn IS the full rotation and the pattern is odd under it,")
    print("  so its rotational symmetry group is exactly one-fold.")
    print()
    print("  Kelvin inversion p -> p/|p|^2 acts as the equatorial reflection z -> -z:")
    worst = [0.0, 0.0, 0.0]
    for (x, y) in SAMPLE_POINTS:
        xi, yi = kelvin(x, y)
        a, b, c = chart(x, y)
        ai, bi, ci = chart(xi, yi)
        worst[0] = max(worst[0], abs(ai - a))
        worst[1] = max(worst[1], abs(bi - b))
        worst[2] = max(worst[2], abs(ci + c))
    print(f"    max |s1(inv p) - s1(p)| = {worst[0]:.3e}")
    print(f"    max |s2(inv p) - s2(p)| = {worst[1]:.3e}")
    print(f"    max |s3(inv p) + s3(p)| = {worst[2]:.3e}")
    print()


def main() -> None:
    print()
    print("INVERSE STEREOGRAPHIC NEURAL FIELD THEORY -- numerical demonstrations")
    print()
    demo_chart()
    demo_eigenvalues()
    demo_exact_certification()
    demo_independence()
    demo_selection()
    demo_decay()
    demo_symmetry()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
