"""Cayley transfer: conjugating a half-plane motion into a motion of the unit disc."""

from __future__ import annotations

from typing import Tuple

CMat = Tuple[complex, complex, complex, complex]

I = 1j
K: CMat = (I, 1, -I, 1)  # Cayley matrix; its Moebius action is (1 + i z)/(1 - i z)


def mat_mul(M: CMat, N: CMat) -> CMat:
    """Product of two 2x2 matrices."""
    a, b, c, d = M
    e, f, g, h = N
    return (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)


def mat_inv(M: CMat) -> CMat:
    """Inverse of an invertible 2x2 matrix."""
    a, b, c, d = M
    det = a * d - b * c
    if det == 0:
        raise ValueError("singular matrix")
    return (d / det, -b / det, -c / det, a / det)


def cayley_transfer(M: CMat) -> CMat:
    """Return K M K^{-1}: the disc-model matrix representing the same motion as M.

    Complexity O(1) (two 2x2 complex products).  Trace, determinant and hence the
    discriminant tr^2 - 4 det are invariant, so the conjugacy type (parabolic /
    elliptic / hyperbolic) is preserved.  On the two distinguished families this
    reproduces the closed forms

        K [[1, t], [0, 1]]  K^{-1} = [[1 + i t/2,  i t/2], [-i t/2, 1 - i t/2]],
        K [[1, a], [-a, 1]] K^{-1} = diag(1 + i a, 1 - i a).
    """
    return mat_mul(mat_mul(K, M), mat_inv(K))


def inverse_cayley_transfer(D: CMat) -> CMat:
    """Return K^{-1} D K: the half-plane matrix representing the disc motion D."""
    return mat_mul(mat_mul(mat_inv(K), D), K)


def cayley(z: complex) -> complex:
    """Cayley transform, the Moebius action of K."""
    return (1 + I * z) / (1 - I * z)


def disc_horo(w: complex) -> float:
    """Disc horocycle function h(w) = (1 - |w|^2)/|w + 1|^2, based at -1.

    Satisfies h(C(z)) = Im z exactly, so the level sets of h are the images of the
    horizontal horocycles of the half-plane.
    """
    return (1.0 - abs(w) ** 2) / (abs(w + 1) ** 2)


if __name__ == "__main__":
    t, a = 1.7, 0.6
    print("K T(t) K^-1 =", tuple(round(x.real, 9) + 1j * round(x.imag, 9)
                                 for x in cayley_transfer((1, t, 0, 1))))
    print("expected     =", (1 + I * t / 2, I * t / 2, -I * t / 2, 1 - I * t / 2))
    print("K S(a) K^-1 =", tuple(round(x.real, 9) + 1j * round(x.imag, 9)
                                 for x in cayley_transfer((1, a, -a, 1))))
    print("expected     =", (1 + I * a, 0, 0, 1 - I * a))
    z = 0.4 + 1.3j
    print("h(C(z)) =", disc_horo(cayley(z)), " Im z =", z.imag)


"""Two-point horocycle-preservation test for determinant-one real matrices."""

from __future__ import annotations

from typing import Optional, Tuple

Mat = Tuple[float, float, float, float]  # (a, b, c, d) for [[a, b], [c, d]]


def mobius_im(M: Mat, z: complex) -> float:
    """Imaginary part of the Moebius image (a z + b)/(c z + d)."""
    a, b, c, d = M
    return ((a * z + b) / (c * z + d)).imag


def horocycle_certificate(M: Mat, tol: float = 1e-12) -> Optional[Tuple[int, float]]:
    """Decide whether M preserves every horocycle Im z = const of the upper half-plane.

    Assumes det M = 1.  Returns None if M does not preserve the foliation; otherwise
    returns the pair (sign, t) with M = sign * [[1, t], [0, 1]] and sign in {+1, -1}.

    Correctness.  By the imaginary-part law, Im(M.z) = det M * Im z / |c z + d|^2, so
    preservation is equivalent to |c z + d|^2 = 1 for all z in the upper half-plane.
    Testing at z = i and z = 2i gives d^2 + c^2 = 1 and d^2 + 4 c^2 = 1, forcing c = 0
    and d^2 = 1; determinant one then gives a = d.  Hence two sample points suffice,
    and the test is exact and O(1).
    """
    a, b, c, d = M
    if abs(mobius_im(M, 1j) - 1.0) > tol:
        return None
    if abs(mobius_im(M, 2j) - 2.0) > tol:
        return None
    # Structure is now guaranteed: c = 0, a = d = +/-1.
    if d > 0:
        return (+1, b)
    return (-1, -b)


def is_parabolic(M: Mat, tol: float = 1e-12) -> bool:
    """Test the trace condition tr(M)^2 = 4 det(M)."""
    a, b, c, d = M
    return abs((a + d) ** 2 - 4 * (a * d - b * c)) <= tol


def fixes_cusp_at_infinity(M: Mat, tol: float = 1e-12) -> bool:
    """Test the guard c = 0, i.e. that M fixes the cusp at infinity."""
    return abs(M[2]) <= tol


if __name__ == "__main__":
    for name, M in [
        ("T(3)", (1.0, 3.0, 0.0, 1.0)),
        ("-T(3)", (-1.0, -3.0, 0.0, -1.0)),
        ("[[1,0],[1,1]] (parabolic at 0)", (1.0, 0.0, 1.0, 1.0)),
        ("diag(2, 1/2) (hyperbolic)", (2.0, 0.0, 0.0, 0.5)),
    ]:
        cert = horocycle_certificate(M)
        print(f"{name:34s} parabolic={is_parabolic(M)!s:5s} "
              f"fixes-infty={fixes_cusp_at_infinity(M)!s:5s} certificate={cert}")


"""Normalising a real parabolic: an explicit conjugation onto a translation."""

from __future__ import annotations

from typing import Tuple

RMat = Tuple[float, float, float, float]
CMat = Tuple[complex, complex, complex, complex]

I = 1j


def mat_mul(M: Tuple, N: Tuple) -> Tuple:
    """Product of two 2x2 matrices (real or complex entries)."""
    a, b, c, d = M
    e, f, g, h = N
    return (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)


def mat_inv(M: Tuple) -> Tuple:
    """Inverse of an invertible 2x2 matrix."""
    a, b, c, d = M
    det = a * d - b * c
    return (d / det, -b / det, -c / det, a / det)


def parabolic_normal_form(M: RMat, tol: float = 1e-12) -> Tuple[RMat, float]:
    """Return (P, s) with det P = 1, s != 0 and M P = P [[1, s], [0, 1]].

    Hypotheses: M is real with det M = 1, tr M = 2, and M is not the identity.

    Method.  Write M = [[a, b], [c, d]] with a + d = 2 and a d - b c = 1; these force
    b c = -(a - 1)^2.  If c = 0 then a = d = 1 and M is already the translation by b,
    so return (identity, b).  Otherwise the basis change

        P = [[-(a - 1)/c, 1], [-1, 0]],   s = -c

    has det P = 1 and satisfies M P = P T(s); the verification is entrywise and uses
    only the relation b c = -(a - 1)^2.  Complexity: O(1).
    """
    a, b, c, d = M
    if abs((a + d) - 2.0) > 1e-9 or abs(a * d - b * c - 1.0) > 1e-9:
        raise ValueError("matrix is not a determinant-one, trace-two matrix")
    if abs(c) <= tol:
        if abs(b) <= tol:
            raise ValueError("matrix is the identity: no nontrivial normal form")
        return ((1.0, 0.0, 0.0, 1.0), b)
    return ((-(a - 1.0) / c, 1.0, -1.0, 0.0), -c)


def parabolic_fixed_point(M: RMat, tol: float = 1e-12) -> float:
    """Unique boundary fixed point of a real parabolic with c != 0, namely (a-d)/(2c).

    (If c = 0 the fixed point is the cusp at infinity and this function raises.)
    """
    a, _b, c, d = M
    if abs(c) <= tol:
        raise ValueError("the fixed point is the cusp at infinity")
    return (a - d) / (2.0 * c)


def disc_normal_form(M: RMat) -> Tuple[CMat, float]:
    """Return (X, s) with X invertible complex and M X = X P(s), where P(s) is the
    standard disc-side horocyclic shear
        P(s) = [[1 + i s/2, i s/2], [-i s/2, 1 - i s/2]].
    One may take X = P K^{-1} with (P, s) the half-plane normal form and
    K = [[i, 1], [-i, 1]] the Cayley matrix; the identity K T(s) = P(s) K does the rest.
    """
    P, s = parabolic_normal_form(M)
    K: CMat = (I, 1, -I, 1)
    X = mat_mul(tuple(complex(x) for x in P), mat_inv(K))
    return X, s  # type: ignore[return-value]


if __name__ == "__main__":
    for M in [(1.0, 3.0, 0.0, 1.0), (1.0, 0.0, 1.0, 1.0), (3.0, -4.0, 1.0, -1.0)]:
        P, s = parabolic_normal_form(M)
        recon = mat_mul(mat_mul(P, (1.0, s, 0.0, 1.0)), mat_inv(P))
        print(f"M = {M}\n  P = {tuple(round(x, 6) for x in P)}, s = {s:+.4f}")
        print("  P T(s) P^-1 =", tuple(round(x, 9) for x in recon))
        if abs(M[2]) > 1e-12:
            print("  fixed point =", round(parabolic_fixed_point(M), 9))
        X, _ = disc_normal_form(M)
        lhs = mat_mul(tuple(complex(x) for x in M), X)
        Ps = (1 + I * s / 2, I * s / 2, -I * s / 2, 1 - I * s / 2)
        rhs = mat_mul(X, Ps)
        print("  disc form residual =",
              max(abs(u - v) for u, v in zip(lhs, rhs)))


"""Assemble PACKAGE.json from the individual deliverable files."""

from __future__ import annotations

import json
import pathlib
from typing import Any, Dict

ROOT = pathlib.Path(__file__).resolve().parent.parent
A = ROOT / "assets"


def read(path: pathlib.Path) -> str:
    return path.read_text(encoding="utf-8")


LEAN_FILE = "Catalog/Shared/ModularCayley/MatrixModularAction.lean"

FUTURE_DIRECTIONS = """# Future Directions — Matrix-level modular action

This cycle established:

* translations `T(t) = [[1, t], [0, 1]]` as an explicit determinant-one one-parameter
  group with trace `2` (parabolic);
* the Cayley matrix `K = [[i, 1], [-i, 1]]` and the intertwining identity
  `K * T(t) = P(t) * K`, where `P(t) = [[1 + i t/2, i t/2], [-i t/2, 1 - i t/2]]`
  is the disc-model parabolic;
* the horocycle dictionary `h(C(z)) = Im z` for `h(w) = (1 - |w|^2)/|w + 1|^2`, hence
  `P(t)` preserves the disc horocycle function;
* the sharp bridge: a determinant-one real matrix preserves every horocycle at `∞`
  iff it is `± T(t)`; a *guarded* converse (parabolic trace condition together with
  fixing the cusp `∞`), and the counterexample `[[1, 0], [1, 1]]` showing the guard
  cannot be dropped (trace 2 alone is insufficient);
* the conjugacy statements — every non-identity trace-two determinant-one real matrix
  is conjugate to a nontrivial translation, and in Cayley form to a disc-side
  horocyclic shear — plus the elliptic contrast (the diagonal rotations `R(a)`, the
  linearisation `C(x ⊕ y) = C(x) C(y)`, and the discriminant dichotomy).

The following five directions are the bold, falsifiable continuations.

---

## 1. Ping-pong discreteness for the parabolic–elliptic pair

**Conjecture.** For the group `Γ(t, a) ≤ SL(2, ℝ)` generated by `T(t)` and the
elliptic rotation `S(a)` (Cayley conjugate to `R(a)`), there is an explicit
real-algebraic threshold `T(a)` such that `Γ(t, a)` is discrete and free of rank 2
exactly when `|t| ≥ T(a)`, and `T(a)` is the root of a polynomial whose coefficients
are the entries of `K * S(a) * K⁻¹`.

**The key insight is** that after the Cayley transform both generators act on the unit
disc, where the horocycle function `h` supplies a *single* scalar Lyapunov function:
horocycle height is exactly invariant under the parabolic and strictly monotone under
the elliptic away from the fixed point, so the classical ping-pong sets can be defined
by inequalities on `h` rather than by ad-hoc fundamental domains.

**Why now?** The horocycle dictionary, the invariance of `h` under the disc-side
parabolics, and the fact that the Cayley transform maps the half-plane into the open
disc are all established, which is precisely the analytic input a ping-pong argument
needs; the remaining work is combinatorial bookkeeping rather than new analysis.

---

## 2. Horocycle height as a group cocycle

**Conjecture.** The map `β(g, z) = log (h(g · w) / h(w))` with `w = C(z)` defines a
genuine `ℝ`-valued cocycle on `SL(2, ℝ) × ℍ` whose coboundary class is trivial exactly
on the parabolic subgroup fixing `∞`, i.e. the kernel of the class is precisely the set
`{± T(t)}` identified by the horocycle rigidity theorem.

**The key insight is** that horocycle rigidity is really the statement
`β ≡ 0 ↔ g = ± T(t)`, so the theorem already computes the kernel of a cocycle that has
not yet been named; the cocycle identity `β(gh, z) = β(g, h · z) + β(h, z)` should
follow from the same matrix-level bookkeeping that produced the intertwining identity,
and would connect this circle of ideas to Busemann functions and Patterson–Sullivan
theory.

---

## 3. All three species at once

Extend the guarded converse to hyperbolic and elliptic elements: characterise, for each
conjugacy species, the exact family of foliations it preserves (horocycles at a cusp,
hypercycles about a geodesic, concentric circles about an interior point), and identify
the species-specific guard needed in each case. The expected outcome is a single
statement subsuming the parabolic result, indexed by the sign of `tr² − 4 det`.

---

## 4. Quantitative horocycle displacement

For a general determinant-one real matrix the ratio `Im(M · z) / Im z = |c z + d|⁻²` is
an explicit displacement function. Bounding it uniformly over horocycle segments would
give effective statements about how far a non-parabolic element moves a horocycle, with
applications to effective equidistribution of horocycle orbits.

---

## 5. Higher rank and other symmetric spaces

The Cayley transform generalises to Siegel upper half-spaces and to bounded symmetric
domains. A matrix-level intertwining identity in that setting, together with an
appropriate multi-dimensional analogue of the horocycle function `h`, would extend the
half-plane/disc dictionary beyond rank one.
"""

INTERACTIVE_LAYOUT = r"""
# Horocycles, the Cayley Transform, and the Rigidity of Sliding

*A guided tour. Everything below is elementary — modulus of a complex number, and
products of $2\times2$ matrices — but it assembles into a sharp classification theorem
about the symmetries of the hyperbolic plane.*

---

## 1. The stage: a plane where altitude is expensive

Take the set of complex numbers with positive imaginary part,
$$\mathbb{H} = \{z \in \mathbb{C} : \operatorname{Im} z > 0\},$$
and declare that the length of a small step $dz$ at the point $z$ is $|dz| / \operatorname{Im} z$.
Near the real axis, motion is costly; high up, it is cheap. This is the
[hyperbolic upper half-plane](https://en.wikipedia.org/wiki/Poincar%C3%A9_half-plane_model), the
setting for modular forms, Fuchsian groups and hyperbolic dynamics.

Its rigid motions come from $2\times2$ real matrices with determinant $1$, acting by the
**Möbius rule**
$$\begin{pmatrix} a & b \\ c & d\end{pmatrix} \cdot z \;=\; \frac{az+b}{cz+d}.$$

<details>
<summary><b>Why matrices? The two structural laws</b> (click to expand)</summary>

Two identities do all the work in this tour.

**The cocycle law.** Matrix multiplication is composition of motions:
$$(MN)\cdot z = M \cdot (N \cdot z)$$
whenever the denominators are nonzero. Substituting $N\cdot z = (N_{11}z+N_{12})/D$ with
$D = N_{21}z+N_{22}$ into $M\cdot(\;\cdot\;)$ and clearing $D$ reproduces exactly the entries of
the matrix product. So every geometric identity between motions may be verified as an identity
between matrices.

**The imaginary-part law.** For real $a,b,c,d$ and $cz+d\neq0$,
$$\operatorname{Im}\!\left(\frac{az+b}{cz+d}\right) = \frac{(ad-bc)\,\operatorname{Im} z}{|cz+d|^{2}}.$$
Everything in this tour follows from this single formula. In particular, if $\det M = 1$ the
half-plane is preserved, and the *height distortion* of the motion at $z$ is exactly $|cz+d|^{-2}$.

</details>

The horizontal lines $\operatorname{Im} z = c$ are the **horocycles at the cusp $\infty$** — limits of
hyperbolic circles whose centres run off to infinity. The question that organises everything
below is: *which motions slide every horocycle along itself?*

---

## 2. Play first, prove later

The widget below shows the same motion twice: on the half-plane, and on the unit disc after
transferring by the Cayley transform. Drag the blue point, switch families, and watch the height
readout.

{{interactive_demo:0}}

Three things to try:

1. **Translations** $T(t) = \begin{pmatrix}1&t\\0&1\end{pmatrix}$. The height never moves, in either model.
2. **The lower shear** $\begin{pmatrix}1&0\\u&1\end{pmatrix}$. Its trace is $2$ and its determinant is $1$ —
   by every algebraic test it is *parabolic*, the same species as a translation — yet the height
   collapses. Set $u = 1$ and put the point at $z = i$: the height drops to exactly $1/2$.
3. **The elliptic family** $S(a) = \begin{pmatrix}1&a\\-a&1\end{pmatrix}$ (normalised). In the disc it is a
   rigid rotation about the centre; in the half-plane it looks like nothing so simple.

Item 2 is the whole subtlety of the subject, and we will name it precisely in §4.

---

## 3. The rigidity theorem: two sample points are enough

> **Theorem (Horocycle rigidity).** Let $M$ be a real matrix with $\det M = 1$. Then
> $\operatorname{Im}(M\cdot z) = \operatorname{Im} z$ for every $z \in \mathbb{H}$ **if and only if**
> $M = \pm\begin{pmatrix}1&t\\0&1\end{pmatrix}$ for some real $t$.

A three-dimensional group of symmetries collapses to a single line (the sign is harmless: $M$ and
$-M$ define the same Möbius map).

<details>
<summary><b>Click to reveal the proof — it is five lines</b></summary>

Suppose $\operatorname{Im}(M\cdot z) = \operatorname{Im} z$ throughout $\mathbb{H}$. By the imaginary-part law with
$\det M = 1$,
$$\frac{\operatorname{Im} z}{|cz+d|^2} = \operatorname{Im} z \quad\Longrightarrow\quad |cz+d|^2 = 1 \quad\text{for all } z\in\mathbb{H}.$$
Test at $z = iy$, where $|c(iy)+d|^2 = d^2 + c^2y^2$. Taking $y = 1$ and $y = 2$:
$$d^2 + c^2 = 1, \qquad d^2 + 4c^2 = 1 \;\Longrightarrow\; 3c^2 = 0 \;\Longrightarrow\; c = 0,$$
so $d^2 = 1$; determinant one then gives $a = d = \pm1$, i.e. $M = \pm T(\pm b)$. Conversely
$T(t)\cdot z = z+t$ visibly preserves heights.

**An infinite family of constraints was decided by two sample points.** That is worth remembering:
it is also an algorithm.

</details>

An immediate consequence, since $\operatorname{tr} T(t) = 2$ and $\det T(t) = 1$:

> **Corollary.** A determinant-one matrix preserving every horocycle at $\infty$ satisfies the
> **parabolic trace condition** $(\operatorname{tr} M)^2 = 4\det M$.

The quantity $(\operatorname{tr} M)^2 - 4\det M$ is the discriminant of the characteristic polynomial, and it
sorts motions into three species: *hyperbolic* (positive: two boundary fixed points, translation
along a geodesic), *parabolic* (zero: one boundary fixed point, a shear), *elliptic* (negative: an
interior fixed point, a rotation).

The proof of the theorem is literally an algorithm — a two-point test — and here it is:

{{algorithm:0}}

---

## 4. Where the converse fails, and the exact repair

Parabolicity is a statement about the discriminant, and the discriminant is unchanged by
conjugation. Horocycle preservation *at $\infty$*, by contrast, names one specific cusp. A
conjugation-invariant condition can never characterise a non-invariant one, so the converse of the
corollary must fail — and it does, minimally:

> **Theorem (Sharpness).** The matrix $N = \begin{pmatrix}1&0\\1&1\end{pmatrix}$ has $\det N = 1$ and
> $(\operatorname{tr} N)^2 = 4 = 4\det N$, so it is parabolic; yet $\operatorname{Im}(N\cdot i) = \tfrac12$.

Indeed $|c\,i+d|^2 = |1+i|^2 = 2$, so the height is halved. The explanation is that $N$ is parabolic
about the cusp $0$, not $\infty$: it preserves the horocycles tangent to the real axis at the origin.
Add the missing hypothesis and the converse is true:

> **Theorem (Guarded converse).** If $\det M = 1$, $(\operatorname{tr} M)^2 = 4\det M$, **and** $M_{21} = 0$
> (so $M$ fixes the cusp $\infty$), then $M$ preserves every horocycle $\operatorname{Im} z = \text{const}$.

<details>
<summary><b>Proof of the guarded converse</b></summary>

With $c = 0$ and $\det M = 1$ we have $ad = 1$; the trace condition $(a+d)^2 = 4$ with $a = 1/d$ gives
$(d^2+1)^2 = 4d^2$, i.e. $(d^2-1)^2 = 0$, so $d^2 = 1$. Then $|cz+d|^2 = 1$ identically, and the
imaginary-part law finishes the argument.

</details>

Putting the three statements together:
$$\text{preserves every horocycle at }\infty \iff \big[(\operatorname{tr} M)^2 = 4\det M \ \text{ and }\ M_{21} = 0\big] \iff M = \pm T(t).$$

---

## 5. The bridge to the disc

Everyone has seen the second model of the hyperbolic plane: the
[Poincaré disc](https://en.wikipedia.org/wiki/Poincar%C3%A9_disk_model) of Escher's *Circle Limit*
prints. The bridge is the **Cayley transform**
$$C(z) = \frac{1+iz}{1-iz},$$
which maps $\mathbb{H}$ onto the open unit disc (try $z = iy$: the image is $(1-y)/(1+y) \in (-1,1)$),
sends the real line to the unit circle, and sends the cusp $\infty$ to the boundary point $-1$.

Because Möbius maps *are* matrices, so is $C$:
$$K = \begin{pmatrix} i & 1 \\ -i & 1\end{pmatrix}, \qquad K\cdot z = C(z), \qquad \det K = 2i.$$

> **Theorem (Intertwining identity).** For every real $t$, $\;K\,T(t) = P(t)\,K$, where
> $$P(t) = \begin{pmatrix} 1+\tfrac{it}{2} & \tfrac{it}{2}\\[2pt] -\tfrac{it}{2} & 1-\tfrac{it}{2}\end{pmatrix}.$$
> Equivalently, $C(z+t) = P(t)\cdot C(z)$.

The matrices $P(t)$ satisfy $\det P(t) = 1$, $\operatorname{tr} P(t) = 2$ (still parabolic: conjugation cannot
change the discriminant), compose additively $P(s)P(t) = P(s+t)$, obey the
$\mathrm{SU}(1,1)$ symmetry $\overline{P(t)_{11}} = P(t)_{22}$, $\overline{P(t)_{12}} = P(t)_{21}$, and fix
the single boundary point $-1$.

This transfer is again an algorithm — conjugation by $K$ — and it costs two matrix products:

{{algorithm:1}}

---

## 6. Altitude, translated

If translations preserve altitude on the half-plane, what do the $P(t)$ preserve on the disc? Define
$$h(w) = \frac{1-|w|^2}{|w+1|^2}.$$
Its level sets are exactly the circles inside the disc tangent to the boundary at $-1$.

> **Theorem (Horocycle dictionary).** $h(C(z)) = \operatorname{Im} z$ — exactly, for every $z$ in the domain of $C$.

<details>
<summary><b>The one-line reason</b></summary>

Write $A = |1+iz|^2 = (1-y)^2+x^2$ and $B = |1-iz|^2 = (1+y)^2+x^2$, so $1 - |C(z)|^2 = (B-A)/B = 4y/B$.
The crux is the identity
$$C(z)+1 = \frac{1+iz}{1-iz}+1 = \frac{2}{1-iz}, \qquad\text{hence}\qquad |C(z)+1|^2 = \frac4B .$$
Dividing, the two copies of $B$ cancel and $h(C(z)) = y$. No constant survives.

</details>

> **Theorem (Invariance).** $h(P(t)\cdot w) = h(w)$ for every $w$ in the closed unit disc, and $P(t)$
> maps the open disc to itself.

<details>
<summary><b>The twin identities that make it work</b></summary>

Write $\nu = \left(1+\tfrac{it}{2}\right)w + \tfrac{it}{2}$ and $\delta = -\tfrac{it}{2}w + \left(1-\tfrac{it}{2}\right)$
for the numerator and denominator of $P(t)\cdot w$. Then
$$\nu + \delta = w+1 \qquad\text{and}\qquad |\delta|^2 - |\nu|^2 = 1 - |w|^2 .$$
The first is immediate; the second is the $\mathrm{SU}(1,1)$ pseudo-norm identity, which reduces to
$|\alpha|^2 - |\beta|^2 = 1$ for $\alpha = 1+\tfrac{it}{2}$, $\beta = \tfrac{it}{2}$ — that is, to
$\det P(t) = 1$. Now
$$1 - \left|\tfrac{\nu}{\delta}\right|^2 = \frac{1-|w|^2}{|\delta|^2}, \qquad \left|\tfrac{\nu}{\delta}+1\right|^2 = \frac{|w+1|^2}{|\delta|^2},$$
and dividing cancels $|\delta|^{-2}$. The second identity alone gives $|\nu| < |\delta|$ whenever $|w|<1$,
i.e. disc preservation.

</details>

The figure below shows all of it at once: the half-plane horocycles and an orbit riding along one;
the disc horocycles, tangent at $-1$, with the transported orbit; the dictionary plotted as a perfect
identity line; and the discriminants of the two families.

{{visualization:0}}

---

## 7. The elliptic mirror: velocity addition is rotation

The same conjugation, applied to the family
$$S(a) = \begin{pmatrix}1&a\\-a&1\end{pmatrix}, \qquad S(a)\cdot z = \frac{z+a}{1-az},$$
gives something diagonal:
$$K\,S(a) = R(a)\,K, \qquad R(a) = \begin{pmatrix}1+ia & 0\\ 0 & 1-ia\end{pmatrix}, \qquad R(a)\cdot w = C(a)\,w .$$

Hence the nonlinear "velocity addition" $x \oplus y = (x+y)/(1-xy)$ — the tangent addition law, and the
algebraic heart of relativistic velocity composition — becomes multiplication:

> **Theorem.** $C(x\oplus y) = C(x)\,C(y)$ whenever $xy \neq 1$.

The reason is a two-line factorisation: $(1+ix)(1+iy) = (1-xy)+i(x+y)$ and
$(1-ix)(1-iy) = (1-xy)-i(x+y)$, so the quotient is $C\big((x+y)/(1-xy)\big)$.

Explore it here — drag $x$ and $y$ and watch two arcs concatenate:

{{interactive_demo:1}}

Notice what happens as $xy \to 1$: on the real line the sum escapes to infinity, while on the circle the
product placidly reaches $-1$. The Cayley transform is a bijection $\mathbb{R}\to S^1\setminus\{-1\}$, and
the missing point is precisely the cusp.

The two families sit on opposite sides of the parabolic/elliptic divide:
$$(\operatorname{tr} T(t))^2 - 4\det T(t) = 0, \qquad (\operatorname{tr} S(a))^2 - 4\det S(a) = -4a^2 < 0 \;\;(a\neq0).$$

---

## 8. Every parabolic is a translation in disguise

The counterexample $N$ of §4 was not an anomaly — it was a translation viewed from a different cusp.

> **Theorem (Classification).** If $M$ is real with $\det M = 1$, $\operatorname{tr} M = 2$ and $M \neq I$, then
> $M = P\,T(s)\,P^{-1}$ for some real $P$ with $\det P = 1$ and some $s\neq0$. In Cayley form,
> $MX = X\,P(s)$ for an invertible complex $X$.

<details>
<summary><b>The explicit change of basis</b></summary>

Write $M = \begin{pmatrix}a&b\\c&d\end{pmatrix}$ with $a+d = 2$ and $ad-bc = 1$; these force $bc = -(a-1)^2$.
If $c = 0$ then $a = d = 1$ and $M = T(b)$ already. Otherwise take
$$P = \begin{pmatrix} -(a-1)/c & 1\\ -1 & 0\end{pmatrix}, \qquad s = -c,$$
so that $\det P = 1$ and $MP = P\,T(s)$; the check is entrywise and uses only $bc = -(a-1)^2$. For the
Cayley form put $X = PK^{-1}$ and use $K T(s) = P(s)K$.

When $c\neq0$ the unique boundary fixed point of $M$ is $x_0 = (a-d)/(2c)$: from $a+d=2$ one gets
$cx_0+d = 1$, so the Möbius denominator at $x_0$ equals $1$, and $ax_0+b = x_0$ follows from the same relation.

</details>

Here is the normalisation as executable code, together with the fixed point and the disc form:

{{algorithm:2}}

---

## 9. Everything, checked numerically

The script below verifies every statement above to a tolerance of $10^{-9}$: the transformation and
cocycle laws, the one-parameter group structure, two-point rigidity (including a search over two
thousand random determinant-one matrices, none of which passes the test), the sharpness counterexample,
the intertwining identity, the dictionary $h\circ C = \operatorname{Im}$, disc invariance, the twin identities,
the linearisation of $\oplus$, the discriminant dichotomy, and the parabolic normal form.

{{demo:0}}

---

## 10. Where this leads

- **Modular forms.** The relation $T(1)\cdot z = z+1$ is the periodicity behind every
  [modular form](https://en.wikipedia.org/wiki/Modular_form)'s Fourier expansion at the cusp; the rigidity
  theorem identifies exactly which motions respect the cusp's horocycle foliation.
- **Homogeneous dynamics.** The [horocycle flow](https://en.wikipedia.org/wiki/Horocycle) is generated by
  $\{T(t)\}$; the dictionary transfers it to the bounded disc model with no distortion, which is a real
  convenience for numerics.
- **Relativity.** $C(x\oplus y) = C(x)C(y)$ is the reason composing velocities is really adding angles.
- **Geometric group theory.** The normal form of §8 is the input to ping-pong arguments for discreteness,
  and the function $h$ is a ready-made Lyapunov function for them: exactly invariant under the parabolic,
  strictly monotone under the elliptic.

A geometry rich enough to host tilings, flows and number theory, and transparent enough to be read off from
four entries of a matrix.
"""


def main() -> None:
    package: Dict[str, Any] = {
        "title": "Matrix-Level Modular Action: Translations, the Cayley Transform, and Horocycle Rigidity",
        "domain": "Shared",
        "description": (
            "A determinant-one real matrix preserves every horocycle at the cusp at infinity exactly when "
            "it is plus or minus a translation matrix, which forces the parabolic trace condition; the "
            "Cayley matrix intertwines translations with an SU(1,1) parabolic one-parameter group on the "
            "unit disc, under which the half-plane height corresponds exactly to the disc horocycle function."
        ),
        "authors": ["Aristotle"],
        "date": "2026-08-25",
        "key_results": [
            "Horocycle rigidity: a real matrix of determinant one preserves the imaginary part of every "
            "point of the upper half-plane if and only if it equals plus or minus the translation matrix "
            "[[1, t], [0, 1]]; two sample points, z = i and z = 2i, already force this.",
            "Horocycle preservation implies the parabolic trace condition (trace squared equals four times "
            "the determinant); the converse holds under the additional guard that the matrix fix the cusp "
            "at infinity, and the matrix [[1, 0], [1, 1]] — parabolic yet halving the height of i — shows "
            "the guard cannot be dropped.",
            "Matrix-level compatibility of the Cayley transform with translations: the Cayley matrix "
            "[[i, 1], [-i, 1]] intertwines the translation [[1, t], [0, 1]] with the disc-model parabolic "
            "[[1 + it/2, it/2], [-it/2, 1 - it/2]], an SU(1,1) one-parameter group fixing the boundary point -1.",
            "Exact horocycle dictionary: the disc function h(w) = (1 - |w|^2)/|w + 1|^2 satisfies "
            "h(C(z)) = Im z, so the disc-side parabolics preserve h and map the open unit disc to itself.",
            "Elliptic contrast and discriminant dichotomy: the Cayley matrix conjugates [[1, a], [-a, 1]] to "
            "the diagonal rotation diag(1 + ia, 1 - ia), linearising velocity addition as "
            "C(x + y over 1 - xy) = C(x)C(y); translations have discriminant zero while these matrices have "
            "discriminant -4a^2, strictly negative for nonzero a.",
            "Conjugacy classification: every non-identity real matrix of determinant one and trace two is "
            "conjugate to a nontrivial translation by an explicit determinant-one change of basis, and in "
            "Cayley form to a disc-side horocyclic shear.",
        ],
        "keywords": [
            "Mobius action",
            "Cayley transform",
            "horocycle",
            "parabolic subgroup",
            "SL(2,R)",
            "SU(1,1)",
            "discriminant trichotomy",
            "velocity addition",
        ],
        "article": read(ROOT / "ARTICLE.md"),
        "research_paper": read(ROOT / "RESEARCH_PAPER.md"),
        "research_paper_tex": read(ROOT / "RESEARCH_PAPER.tex"),
        "demo": read(ROOT / "demo.py"),
        "demos": [
            {
                "name": "End-to-End Numerical Verification of Horocycle Rigidity and the Cayley Dictionary",
                "description": (
                    "A self-contained numerical laboratory for the entire development. It verifies the "
                    "imaginary-part transformation law Im(M.z) = det(M) Im(z)/|cz+d|^2 and the cocycle law "
                    "(MN).z = M.(N.z) on random determinant-one matrices; confirms that the translations form "
                    "a faithful one-parameter group with trace two; demonstrates two-point horocycle rigidity "
                    "by showing that the test at z = i and z = 2i agrees with a 200-sample test for every "
                    "family considered, and that none of two thousand random determinant-one matrices passes "
                    "it; exhibits the sharpness counterexample [[1,0],[1,1]], parabolic yet sending i to "
                    "height 1/2, and confirms the guarded converse; checks the intertwining identity "
                    "K T(t) = P(t) K together with the SU(1,1) symmetry, group law and fixed point of the "
                    "disc-side parabolics; tabulates the exact dictionary h(C(z)) = Im z; verifies invariance "
                    "of h under the disc-side parabolics along with the two algebraic identities that prove "
                    "it; checks the elliptic conjugation, the linearisation C(x+y over 1-xy) = C(x)C(y), the "
                    "tangent interpretation and the boundary round trip; tabulates the discriminant dichotomy; "
                    "computes explicit parabolic normal forms with their fixed points and disc forms; and "
                    "finally follows one orbit through both models to display the constancy of the height."
                ),
                "code": read(ROOT / "demo.py"),
            }
        ],
        "algorithms": [
            {
                "name": "Two-Point Certificate for Horocycle Preservation",
                "description": (
                    "Decides whether a determinant-one real matrix preserves every horocycle Im z = const of "
                    "the upper half-plane, and if so returns the certificate (sign, t) with M = sign * "
                    "[[1, t], [0, 1]]. Mathematical foundation: by the imaginary-part transformation law, "
                    "preservation is equivalent to the normalisation identity |cz + d|^2 = 1 for every z in "
                    "the half-plane. Evaluating at the two purely imaginary points z = i and z = 2i yields "
                    "d^2 + c^2 = 1 and d^2 + 4c^2 = 1, forcing c = 0 and d^2 = 1; determinant one then gives "
                    "a = d, so the matrix is plus or minus a translation. The infinite family of constraints "
                    "therefore reduces to two evaluations, and the test is exact and runs in O(1) arithmetic "
                    "operations with no search and no tolerance beyond floating-point round-off. The companion "
                    "predicates test the parabolic trace condition and the cusp-fixing guard separately, which "
                    "makes visible the fact that the trace condition alone is insufficient: the matrix "
                    "[[1, 0], [1, 1]] passes it but fails the certificate."
                ),
                "pseudocode": (
                    "Input:  real matrix M = [[a, b], [c, d]] with det M = 1; tolerance tol\n"
                    "Output: None if M moves some horocycle at infinity;\n"
                    "        otherwise (sign, t) with M = sign * [[1, t], [0, 1]]\n"
                    "\n"
                    "1.  h1 <- Im((a*i + b) / (c*i + d))            # test point z = i\n"
                    "2.  if |h1 - 1| > tol then return None\n"
                    "3.  h2 <- Im((a*2i + b) / (c*2i + d))          # test point z = 2i\n"
                    "4.  if |h2 - 2| > tol then return None\n"
                    "5.  # steps 2 and 4 force c = 0 and d^2 = 1, hence a = d = +/-1\n"
                    "6.  if d > 0 then return (+1, b) else return (-1, -b)\n"
                    "\n"
                    "Auxiliary predicates:\n"
                    "    is_parabolic(M)            :=  |(a + d)^2 - 4(ad - bc)| <= tol\n"
                    "    fixes_cusp_at_infinity(M)  :=  |c| <= tol\n"
                    "    horocycle_preserving(M)   <=>  is_parabolic(M) and fixes_cusp_at_infinity(M)"
                ),
                "code": read(A / "algo_horocycle_test.py"),
            },
            {
                "name": "Cayley Transfer Between the Half-Plane and Disc Models",
                "description": (
                    "Conjugates a motion of the upper half-plane into the corresponding motion of the unit "
                    "disc, by M -> K M K^{-1} with the Cayley matrix K = [[i, 1], [-i, 1]], whose Mobius "
                    "action is the Cayley transform C(z) = (1 + iz)/(1 - iz). The transfer is exact and costs "
                    "two 2x2 complex matrix products, i.e. O(1) arithmetic. Because conjugation preserves "
                    "trace and determinant it preserves the discriminant, hence the parabolic/elliptic/"
                    "hyperbolic type of the motion. On the two distinguished families it reproduces the closed "
                    "forms proved in the paper: the translation [[1, t], [0, 1]] is carried to the SU(1,1) "
                    "parabolic [[1 + it/2, it/2], [-it/2, 1 - it/2]], and the velocity-addition matrix "
                    "[[1, a], [-a, 1]] is carried to the diagonal rotation diag(1 + ia, 1 - ia). The module "
                    "also supplies the disc horocycle function h(w) = (1 - |w|^2)/|w + 1|^2, which satisfies "
                    "h(C(z)) = Im z exactly, so that heights on the half-plane and horocycle levels on the "
                    "disc are the same number."
                ),
                "pseudocode": (
                    "Constants: K <- [[i, 1], [-i, 1]];  K^{-1} computed by the 2x2 adjugate formula\n"
                    "\n"
                    "function CAYLEY_TRANSFER(M):            # half-plane -> disc\n"
                    "    1. A <- K * M                       # one 2x2 complex product\n"
                    "    2. return A * K^{-1}                # a second 2x2 complex product\n"
                    "\n"
                    "function INVERSE_CAYLEY_TRANSFER(D):    # disc -> half-plane\n"
                    "    1. return K^{-1} * D * K\n"
                    "\n"
                    "Invariants (used as runtime checks):\n"
                    "    trace(K M K^{-1}) = trace(M),   det(K M K^{-1}) = det(M)\n"
                    "    K [[1,t],[0,1]] K^{-1} = [[1 + i t/2, i t/2], [-i t/2, 1 - i t/2]]\n"
                    "    K [[1,a],[-a,1]] K^{-1} = diag(1 + i a, 1 - i a)\n"
                    "    h(C(z)) = Im z   with   h(w) = (1 - |w|^2)/|w + 1|^2"
                ),
                "code": read(A / "algo_cayley_transfer.py"),
            },
            {
                "name": "Explicit Normalisation of a Real Parabolic onto a Translation",
                "description": (
                    "Given a real matrix M with determinant one, trace two and M not the identity, produces a "
                    "determinant-one real matrix P and a nonzero real s with M P = P [[1, s], [0, 1]], i.e. "
                    "realises M as a translation viewed in another basis; and, composing with the Cayley "
                    "transfer, produces an invertible complex X with M X = X P(s) exhibiting M as a "
                    "horocyclic shear of the disc. Mathematical foundation: the hypotheses give a + d = 2 and "
                    "ad - bc = 1, which together force b c = -(a - 1)^2. If c = 0 the matrix is already the "
                    "translation by b. Otherwise the change of basis P = [[-(a-1)/c, 1], [-1, 0]] with "
                    "s = -c has determinant one and satisfies the intertwining relation, as an entrywise "
                    "check using only b c = -(a - 1)^2 confirms. The routine also returns the unique boundary "
                    "fixed point (a - d)/(2c) when c is nonzero. All steps are closed-form: the complexity is "
                    "O(1), with no iteration and no eigenvector computation."
                ),
                "pseudocode": (
                    "Input:  real M = [[a, b], [c, d]] with det M = 1, trace M = 2, M != identity\n"
                    "Output: (P, s) with det P = 1, s != 0 and M P = P [[1, s], [0, 1]]\n"
                    "\n"
                    "1.  assert |a + d - 2| small and |a d - b c - 1| small\n"
                    "2.  if |c| <= tol then                       # M already fixes the cusp at infinity\n"
                    "3.      if |b| <= tol then error 'M is the identity'\n"
                    "4.      return (identity, b)\n"
                    "5.  else                                     # use b c = -(a - 1)^2\n"
                    "6.      P <- [[-(a - 1)/c, 1], [-1, 0]]\n"
                    "7.      s <- -c\n"
                    "8.      return (P, s)\n"
                    "\n"
                    "function FIXED_POINT(M):    # valid when c != 0\n"
                    "    return (a - d) / (2 c)                   # then c*x0 + d = 1 and M.x0 = x0\n"
                    "\n"
                    "function DISC_NORMAL_FORM(M):\n"
                    "    1. (P, s) <- PARABOLIC_NORMAL_FORM(M)\n"
                    "    2. X <- P * K^{-1}                       # K = [[i, 1], [-i, 1]]\n"
                    "    3. return (X, s)                         # then M X = X P(s)"
                ),
                "code": read(A / "algo_parabolic_normalisation.py"),
            },
        ],
        "visualizations": [
            {
                "name": "Horocycles in Two Models, the Exact Dictionary, and the Discriminant Divide",
                "description": (
                    "A four-panel figure. The first panel shows the upper half-plane with its horizontal "
                    "horocycles, an orbit of the translation z -> z + t riding along one of them at constant "
                    "height, and the contrasting orbit of the parabolic [[1, 0], [1, 1]], which plunges "
                    "towards the real axis: parabolicity alone does not protect the horocycles at infinity. "
                    "The second panel shows the same data after the Cayley transform: the horocycles become "
                    "circles tangent to the unit circle at the point -1 (the image of the cusp at infinity, "
                    "marked with a star), and the transported orbit sweeps along one of them under the "
                    "disc-side parabolic. The third panel plots h(C(z)) against Im z along a path through the "
                    "half-plane, producing the identity line and a maximum deviation at the level of machine "
                    "epsilon, which is the content of the horocycle dictionary. The fourth panel plots the "
                    "discriminant tr^2 - 4 det for both families: identically zero for the translations "
                    "(parabolic) and equal to -4a^2 for the velocity-addition matrices (strictly elliptic)."
                ),
                "code": read(A / "visualize_horocycles.py"),
            }
        ],
        "interactive_demos": [
            {
                "title": "Horocycle Explorer: One Motion Seen in Two Models",
                "description": (
                    "A dual-canvas laboratory. On the left is the upper half-plane with its horocycle "
                    "foliation and a draggable base point; on the right is the unit disc with the Cayley "
                    "images of the same horocycles, circles tangent to the boundary at -1. Choose a family "
                    "(translations, the lower shear that is parabolic about the cusp 0, the elliptic "
                    "velocity-addition matrices, or hyperbolic dilations), set the parameter and the orbit "
                    "length, and watch the orbit unfold simultaneously in both pictures. Live readouts give "
                    "the trace, determinant, discriminant and conjugacy type of the matrix, the heights "
                    "Im z and Im(M.z), the height distortion 1/|cz + d|^2, and the disc horocycle values "
                    "h(C(z)) and h(C(M.z)) — which always agree with the corresponding heights, illustrating "
                    "the dictionary. A verdict panel states whether the horocycle foliation is preserved and, "
                    "when it is not, explains whether the failure is due to non-parabolicity or to "
                    "parabolicity about a different cusp. Placing the point near z = i and z = 2i lets the "
                    "reader replay the two-point argument that proves the rigidity theorem."
                ),
                "html": read(A / "widget_dual_model.html"),
            },
            {
                "title": "Velocity Addition Becomes Rotation: the Cayley Circle",
                "description": (
                    "An interactive demonstration that the nonlinear law x + y over 1 - xy is multiplication "
                    "in disguise. Two sliders set the real numbers x and y. The left canvas shows the unit "
                    "circle with the points C(x), C(y) and their product, together with the two arcs whose "
                    "concatenation exhibits the addition of arguments; the right canvas shows the real line "
                    "with x, y and their combined value. Readouts give the arguments in degrees, their sum "
                    "reduced modulo 360, the argument of the image of the combined value, the numerical "
                    "discrepancy between C(x)C(y) and C(x + y over 1 - xy) — which stays at round-off level "
                    "— and the comparison with arctan x + arctan y, exhibiting the tangent addition law. "
                    "Sliding towards xy = 1 makes the real-line value escape to infinity while the circle "
                    "picture passes smoothly through the point -1, the single boundary point that the Cayley "
                    "transform never attains from a real argument and the image of the cusp at infinity."
                ),
                "html": read(A / "widget_circle_addition.html"),
            },
        ],
        "interactive_layout": INTERACTIVE_LAYOUT,
        "lean_proofs": read(ROOT / LEAN_FILE),
        "future_directions": FUTURE_DIRECTIONS,
        "modules": {"demo": read(ROOT / "demo.py")},
        "lean_files": [LEAN_FILE],
    }

    out = ROOT / "PACKAGE.json"
    out.write_text(json.dumps(package, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {out} ({out.stat().st_size} bytes)")


if __name__ == "__main__":
    main()


"""
Visualisation: the horocycle foliation in the half-plane and in the disc.

Four panels are produced.

  (1) Upper half-plane: the horizontal horocycles Im z = c, an orbit of the
      translation z -> z + t riding along one of them, and the *failure* of the
      parabolic N = [[1,0],[1,1]] to preserve them (its orbit drops in height).
  (2) Unit disc: the images of the same horocycles under the Cayley transform
      C(z) = (1+iz)/(1-iz) -- circles tangent to the unit circle at -1 -- with
      the transported orbit of the disc-side parabolic P(t).
  (3) The horocycle dictionary h(C(z)) = Im z verified along a path, plotted as
      the identity line.
  (4) The discriminant tr^2 - 4 det for the two families: identically zero for
      translations T(t) (parabolic), equal to -4a^2 for S(a) (elliptic).

Requires matplotlib and numpy.
"""

from __future__ import annotations

import cmath
from typing import List, Tuple

import matplotlib.pyplot as plt
import numpy as np

I = 1j


def cayley(z: complex) -> complex:
    """Cayley transform: upper half-plane -> open unit disc."""
    return (1 + I * z) / (1 - I * z)


def disc_horo(w: complex) -> float:
    """Disc horocycle function h(w) = (1 - |w|^2)/|w + 1|^2, based at -1."""
    return (1.0 - abs(w) ** 2) / (abs(w + 1) ** 2)


def mobius(M: Tuple[complex, complex, complex, complex], z: complex) -> complex:
    a, b, c, d = M
    return (a * z + b) / (c * z + d)


def T(t: float) -> Tuple[complex, complex, complex, complex]:
    return (1, t, 0, 1)


def P(t: float) -> Tuple[complex, complex, complex, complex]:
    return (1 + I * t / 2, I * t / 2, -I * t / 2, 1 - I * t / 2)


def S(a: float) -> Tuple[complex, complex, complex, complex]:
    return (1, a, -a, 1)


def trace_minus_det(M: Tuple[complex, complex, complex, complex]) -> float:
    a, b, c, d = M
    return ((a + d) ** 2 - 4 * (a * d - b * c)).real


def main() -> None:
    fig, axes = plt.subplots(2, 2, figsize=(13, 11))
    heights: List[float] = [0.4, 0.8, 1.2, 1.8, 2.6, 3.6]
    xs = np.linspace(-6.0, 6.0, 800)

    # ---------------- Panel 1: the half-plane ----------------
    ax = axes[0][0]
    for c in heights:
        ax.plot(xs, [c] * len(xs), color="0.75", lw=1)
    ax.axhline(0, color="k", lw=1.5)

    z0 = -3.0 + 1.2j
    orbit = [mobius(T(t), z0) for t in np.linspace(0.0, 6.0, 13)]
    ax.plot([z.real for z in orbit], [z.imag for z in orbit], "o-",
            color="#1f77b4", ms=5, label=r"orbit of $z\mapsto z+t$  (height fixed)")

    N = (1, 0, 1, 1)
    bad = [z0]
    for _ in range(4):
        bad.append(mobius(N, bad[-1]))
    ax.plot([z.real for z in bad], [z.imag for z in bad], "s--",
            color="#d62728", ms=5, label="orbit of the parabolic $[[1,0],[1,1]]$  (height drops)")

    ax.set_xlim(-6, 6)
    ax.set_ylim(-0.2, 4.2)
    ax.set_title("Upper half-plane: horocycles $\\mathrm{Im}\\,z = c$")
    ax.set_xlabel("Re z")
    ax.set_ylabel("Im z")
    ax.legend(loc="upper right", fontsize=9)

    # ---------------- Panel 2: the disc ----------------
    ax = axes[0][1]
    theta = np.linspace(0, 2 * np.pi, 400)
    ax.plot(np.cos(theta), np.sin(theta), color="k", lw=1.5)
    for c in heights:
        curve = [cayley(x + 1j * c) for x in np.linspace(-60, 60, 3000)]
        ax.plot([w.real for w in curve], [w.imag for w in curve], color="0.75", lw=1)
    w0 = cayley(z0)
    dorbit = [mobius(P(t), w0) for t in np.linspace(0.0, 6.0, 13)]
    ax.plot([w.real for w in dorbit], [w.imag for w in dorbit], "o-",
            color="#1f77b4", ms=5, label=r"orbit of $P(t)$ (same points)")
    ax.plot([-1], [0], "k*", ms=14, label="cusp $-1$ = image of $\\infty$")
    ax.set_aspect("equal")
    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_title("Unit disc: horocycles tangent at $-1$, level sets of $h$")
    ax.legend(loc="lower right", fontsize=9)

    # ---------------- Panel 3: the dictionary ----------------
    ax = axes[1][0]
    sample = [complex(x, y) for x, y in
              zip(np.linspace(-4, 4, 300), np.linspace(0.05, 4.0, 300))]
    ims = [z.imag for z in sample]
    hs = [disc_horo(cayley(z)) for z in sample]
    ax.plot(ims, hs, color="#2ca02c", lw=2, label=r"$h(C(z))$")
    ax.plot(ims, ims, "k--", lw=1, label=r"$\mathrm{Im}\,z$ (identity)")
    ax.set_xlabel(r"$\mathrm{Im}\,z$")
    ax.set_ylabel(r"$h(C(z))$")
    ax.set_title("Horocycle dictionary: $h(C(z)) = \\mathrm{Im}\\,z$ exactly")
    err = max(abs(a - b) for a, b in zip(ims, hs))
    ax.text(0.05, 0.9, f"max deviation = {err:.2e}", transform=ax.transAxes)
    ax.legend(loc="lower right")

    # ---------------- Panel 4: discriminants ----------------
    ax = axes[1][1]
    grid = np.linspace(-3, 3, 400)
    ax.plot(grid, [trace_minus_det(T(t)) for t in grid], color="#1f77b4", lw=2,
            label=r"$T(t)$: $\mathrm{tr}^2-4\det = 0$ (parabolic)")
    ax.plot(grid, [trace_minus_det(S(a)) for a in grid], color="#d62728", lw=2,
            label=r"$S(a)$: $\mathrm{tr}^2-4\det = -4a^2$ (elliptic)")
    ax.axhline(0, color="k", lw=0.8)
    ax.set_xlabel("parameter")
    ax.set_ylabel(r"$\mathrm{tr}^2 - 4\det$")
    ax.set_title("Discriminant dichotomy")
    ax.legend(loc="lower center", fontsize=9)

    fig.suptitle("Horocycles, the Cayley transform, and the parabolic/elliptic divide",
                 fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.97))
    fig.savefig("horocycle_dictionary.png", dpi=150)
    print("wrote horocycle_dictionary.png")


if __name__ == "__main__":
    main()


"""
Matrix-level modular action: translations, the Cayley transform and horocycles.

Numerical demonstrations of the results:

  1. Imaginary-part transformation law   Im(M.z) = det(M) * Im(z) / |cz+d|^2
  2. Cocycle law                         (M N).z = M.(N.z)
  3. Translations                        T(s)T(t) = T(s+t), det = 1, tr = 2
  4. Horocycle rigidity                  det M = 1: Im preserved  <=>  M = +/- T(t)
  5. Sharpness of the guard              [[1,0],[1,1]] is parabolic but halves Im(i)
  6. Intertwining identity               K T(t) = P(t) K
  7. Horocycle dictionary                h(C(z)) = Im z
  8. Disc-side invariance                h(P(t).w) = h(w),  |P(t).w| < 1
  9. Elliptic contrast                   K S(a) = R(a) K,  C(x (+) y) = C(x) C(y)
 10. Discriminant dichotomy              tr^2 - 4 det  =  0  vs  -4 a^2
 11. Parabolic normalisation             M = P T(s) P^{-1}

Pure standard library (cmath / math / random); no third-party dependencies.
"""

from __future__ import annotations

import cmath
import math
import random
from typing import Callable, List, Tuple

Complex = complex
Mat = Tuple[Complex, Complex, Complex, Complex]  # (m11, m12, m21, m22), row-major

TOL: float = 1e-9

# ----------------------------------------------------------------------------
# Basic 2x2 matrix arithmetic over C
# ----------------------------------------------------------------------------


def mat(a: Complex, b: Complex, c: Complex, d: Complex) -> Mat:
    """Build the matrix [[a, b], [c, d]]."""
    return (complex(a), complex(b), complex(c), complex(d))


def mat_mul(M: Mat, N: Mat) -> Mat:
    """Matrix product M N."""
    a, b, c, d = M
    e, f, g, h = N
    return (a * e + b * g, a * f + b * h, c * e + d * g, c * f + d * h)


def mat_det(M: Mat) -> Complex:
    """Determinant of M."""
    a, b, c, d = M
    return a * d - b * c


def mat_trace(M: Mat) -> Complex:
    """Trace of M."""
    a, _, _, d = M
    return a + d


def mat_inv(M: Mat) -> Mat:
    """Inverse of an invertible M."""
    a, b, c, d = M
    det = mat_det(M)
    if abs(det) < TOL:
        raise ValueError("singular matrix")
    return (d / det, -b / det, -c / det, a / det)


def mat_scale(s: Complex, M: Mat) -> Mat:
    """Scalar multiple s * M."""
    return tuple(s * x for x in M)  # type: ignore[return-value]


def mat_close(M: Mat, N: Mat, tol: float = TOL) -> bool:
    """Entrywise comparison."""
    return all(abs(x - y) < tol for x, y in zip(M, N))


def mobius(M: Mat, z: Complex) -> Complex:
    """Moebius action (a z + b) / (c z + d)."""
    a, b, c, d = M
    den = c * z + d
    if abs(den) < TOL:
        raise ZeroDivisionError("Moebius denominator vanishes")
    return (a * z + b) / den


# ----------------------------------------------------------------------------
# The distinguished families
# ----------------------------------------------------------------------------

I: Complex = 1j


def T(t: float) -> Mat:
    """Translation matrix [[1, t], [0, 1]]; Moebius action z -> z + t."""
    return mat(1, t, 0, 1)


def S(a: float) -> Mat:
    """Velocity-addition matrix [[1, a], [-a, 1]]; action z -> (z+a)/(1-a z)."""
    return mat(1, a, -a, 1)


K: Mat = mat(I, 1, -I, 1)
"""Cayley matrix [[i, 1], [-i, 1]]; Moebius action is the Cayley transform."""


def P(t: float) -> Mat:
    """Disc-side parabolic: the Cayley conjugate of T(t), an SU(1,1) element."""
    return mat(1 + I * t / 2, I * t / 2, -I * t / 2, 1 - I * t / 2)


def R(a: float) -> Mat:
    """Disc-side rotation: the Cayley conjugate of S(a), diag(1 + i a, 1 - i a)."""
    return mat(1 + I * a, 0, 0, 1 - I * a)


def cayley(z: Complex) -> Complex:
    """Cayley transform C(z) = (1 + i z) / (1 - i z): upper half-plane -> unit disc."""
    return (1 + I * z) / (1 - I * z)


def disc_horo(w: Complex) -> float:
    """Disc horocycle function h(w) = (1 - |w|^2) / |w + 1|^2, based at -1."""
    return (1.0 - abs(w) ** 2) / (abs(w + 1) ** 2)


def spb(x: float, y: float) -> float:
    """Velocity addition x (+) y = (x + y) / (1 - x y)."""
    return (x + y) / (1 - x * y)


def discriminant(M: Mat) -> Complex:
    """The conjugacy invariant tr(M)^2 - 4 det(M)."""
    return mat_trace(M) ** 2 - 4 * mat_det(M)


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------

_FAILURES: List[str] = []


def check(label: str, condition: bool, detail: str = "") -> None:
    """Print a labelled pass/fail line and record failures."""
    status = "OK  " if condition else "FAIL"
    if not condition:
        _FAILURES.append(label)
    tail = f"   {detail}" if detail else ""
    print(f"  [{status}] {label}{tail}")


def section(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def rand_upper(rng: random.Random) -> Complex:
    """A random point of the upper half-plane."""
    return complex(rng.uniform(-3.0, 3.0), rng.uniform(0.05, 4.0))


def rand_sl2(rng: random.Random) -> Mat:
    """A random real determinant-one matrix."""
    while True:
        a = rng.uniform(-2, 2)
        b = rng.uniform(-2, 2)
        c = rng.uniform(-2, 2)
        if abs(a) > 0.1:
            d = (1 + b * c) / a
            return mat(a, b, c, d)


# ----------------------------------------------------------------------------
# 1. The imaginary-part transformation law and the cocycle law
# ----------------------------------------------------------------------------


def demo_transformation_laws(rng: random.Random) -> None:
    section("1. Imaginary-part law   Im(M.z) = det M * Im z / |c z + d|^2")
    for _ in range(4):
        M = rand_sl2(rng)
        z = rand_upper(rng)
        a, b, c, d = M
        lhs = mobius(M, z).imag
        rhs = (mat_det(M) * z.imag / abs(c * z + d) ** 2).real
        check(
            "imaginary-part law",
            abs(lhs - rhs) < 1e-8,
            f"Im(M.z) = {lhs:+.6f}, formula = {rhs:+.6f}",
        )

    section("2. Cocycle law   (M N).z = M.(N.z)")
    for _ in range(4):
        M, N = rand_sl2(rng), rand_sl2(rng)
        z = rand_upper(rng)
        lhs = mobius(mat_mul(M, N), z)
        rhs = mobius(M, mobius(N, z))
        check("cocycle law", abs(lhs - rhs) < 1e-8, f"|difference| = {abs(lhs - rhs):.2e}")


# ----------------------------------------------------------------------------
# 3. Translations form a one-parameter group
# ----------------------------------------------------------------------------


def demo_translations() -> None:
    section("3. Translations: T(s) T(t) = T(s+t), det = 1, tr = 2, tr^2 = 4 det")
    for s, t in [(0.7, -1.3), (2.0, 2.0), (-0.5, 0.5)]:
        check(
            f"T({s}) T({t}) = T({s + t})",
            mat_close(mat_mul(T(s), T(t)), T(s + t)),
        )
    for t in [-2.0, 0.0, 1.5]:
        det = mat_det(T(t)).real
        tr = mat_trace(T(t)).real
        check(
            f"invariants of T({t})",
            abs(det - 1) < TOL and abs(tr - 2) < TOL and abs(tr**2 - 4 * det) < TOL,
            f"det = {det:.3f}, tr = {tr:.3f}, tr^2 - 4 det = {tr**2 - 4*det:.3e}",
        )
    # Powers translate by multiples.
    Mpow: Mat = mat(1, 0, 0, 1)
    for n in range(1, 6):
        Mpow = mat_mul(Mpow, T(0.4))
        check(f"T(0.4)^{n} = T({0.4 * n:.1f})", mat_close(Mpow, T(0.4 * n)))


# ----------------------------------------------------------------------------
# 4-5. Horocycle rigidity and the sharpness of the cusp-fixing guard
# ----------------------------------------------------------------------------


def preserves_horocycles_numerically(M: Mat, rng: random.Random, samples: int = 200) -> bool:
    """Sample the half-plane and test Im(M.z) == Im(z)."""
    for _ in range(samples):
        z = rand_upper(rng)
        try:
            if abs(mobius(M, z).imag - z.imag) > 1e-7:
                return False
        except ZeroDivisionError:
            return False
    return True


def horocycle_test_two_points(M: Mat) -> bool:
    """The two-point test extracted from the rigidity proof: check z = i and z = 2i."""
    return (
        abs(mobius(M, 1j).imag - 1.0) < 1e-9
        and abs(mobius(M, 2j).imag - 2.0) < 1e-9
    )


def demo_rigidity(rng: random.Random) -> None:
    section("4. Horocycle rigidity: det M = 1 and Im preserved  <=>  M = +/- T(t)")

    print("\n  (a) translations and their negatives preserve every horocycle")
    for t in [-1.7, 0.0, 3.2]:
        check(f"T({t}) preserves Im", preserves_horocycles_numerically(T(t), rng))
        check(f"-T({t}) preserves Im", preserves_horocycles_numerically(mat_scale(-1, T(t)), rng))

    print("\n  (b) two sample points already decide the question")
    print("      (the proof uses only z = i and z = 2i: d^2 + c^2 = 1 and d^2 + 4c^2 = 1)")
    for label, M in [
        ("T(2.5)", T(2.5)),
        ("-T(2.5)", mat_scale(-1, T(2.5))),
        ("diag(2, 1/2)  [hyperbolic]", mat(2, 0, 0, 0.5)),
        ("[[1,0],[1,1]]  [parabolic at 0]", mat(1, 0, 1, 1)),
        ("[[0,-1],[1,0]]  [elliptic]", mat(0, -1, 1, 0)),
    ]:
        full = preserves_horocycles_numerically(M, rng)
        two = horocycle_test_two_points(M)
        check(
            f"two-point test agrees with full test for {label}",
            full == two,
            f"preserves = {full}",
        )

    print("\n  (c) random determinant-one matrices essentially never preserve Im")
    survivors = 0
    for _ in range(2000):
        M = rand_sl2(rng)
        if horocycle_test_two_points(M):
            survivors += 1
    check("no random SL(2,R) matrix passes the test", survivors == 0,
          f"{survivors} survivors out of 2000")

    section("5. Sharpness: N = [[1,0],[1,1]] is parabolic but moves the horocycle Im z = 1")
    N = mat(1, 0, 1, 1)
    det = mat_det(N).real
    tr = mat_trace(N).real
    check("det N = 1", abs(det - 1) < TOL, f"det = {det:.3f}")
    check("N is parabolic: tr^2 = 4 det", abs(tr**2 - 4 * det) < TOL,
          f"tr = {tr:.3f}, tr^2 - 4 det = {tr**2 - 4*det:.3e}")
    height = mobius(N, 1j).imag
    check("Im(N.i) = 1/2", abs(height - 0.5) < TOL, f"Im(N.i) = {height:.6f}")
    check("N fixes the cusp 0, not infinity", abs(mobius(N, 0.0 + 0j)) < TOL,
          f"N.0 = {mobius(N, 0.0 + 0j)}")
    print("      => the trace condition alone does NOT give horocycle preservation;")
    print("         the guard 'M_21 = 0' (fixing the cusp at infinity) is necessary.")

    print("\n  Guarded converse: parabolic AND M_21 = 0 => preserves every horocycle")
    for M, label in [(T(1.1), "T(1.1)"), (mat(-1, 4.0, 0, -1), "[[-1,4],[0,-1]]")]:
        d = mat_det(M).real
        t2 = mat_trace(M).real ** 2
        ok = abs(d - 1) < TOL and abs(t2 - 4 * d) < TOL and abs(M[2]) < TOL
        check(f"{label} satisfies the hypotheses", ok)
        check(f"{label} preserves Im", preserves_horocycles_numerically(M, rng))


# ----------------------------------------------------------------------------
# 6-8. The Cayley transform, the intertwining identity, the horocycle dictionary
# ----------------------------------------------------------------------------


def demo_cayley(rng: random.Random) -> None:
    section("6. Intertwining identity   K T(t) = P(t) K")
    check("det K = 2i", abs(mat_det(K) - 2j) < TOL, f"det K = {mat_det(K)}")
    for t in [-2.0, 0.3, 1.0, 5.0]:
        check(f"K T({t}) = P({t}) K", mat_close(mat_mul(K, T(t)), mat_mul(P(t), K)))
        check(
            f"P({t}) is an SU(1,1) parabolic",
            abs(mat_det(P(t)) - 1) < TOL
            and abs(mat_trace(P(t)) - 2) < TOL
            and abs(P(t)[0].conjugate() - P(t)[3]) < TOL
            and abs(P(t)[1].conjugate() - P(t)[2]) < TOL,
            f"det = {mat_det(P(t)):.3f}, tr = {mat_trace(P(t)):.3f}",
        )
    for s, t in [(0.4, 1.6), (-1.0, 1.0)]:
        check(f"P({s}) P({t}) = P({s + t})", mat_close(mat_mul(P(s), P(t)), P(s + t)))
    check("P(t) fixes the boundary point -1", abs(mobius(P(2.3), -1 + 0j) + 1) < TOL)

    print("\n  Moebius form:  C(z + t) = P(t) . C(z)")
    for _ in range(4):
        z = rand_upper(rng)
        t = rng.uniform(-3, 3)
        lhs = cayley(z + t)
        rhs = mobius(P(t), cayley(z))
        check("C(z+t) = P(t).C(z)", abs(lhs - rhs) < 1e-9,
              f"z = {z:.3f}, t = {t:+.3f}, |difference| = {abs(lhs - rhs):.2e}")

    section("7. Horocycle dictionary   h(C(z)) = Im z   with h(w) = (1-|w|^2)/|w+1|^2")
    print("      z                      Im z        h(C(z))     |C(z)|")
    for z in [1j, 2j, 0.5 + 0.25j, -1.5 + 3.0j, 4.0 + 0.1j]:
        w = cayley(z)
        h = disc_horo(w)
        print(f"   {str(z):>18}   {z.imag:9.6f}   {h:9.6f}   {abs(w):8.6f}")
        check("dictionary exact", abs(h - z.imag) < 1e-9)
    print("      (|C(z)| < 1 confirms that the upper half-plane maps into the open disc)")

    section("8. Disc-side invariance   h(P(t).w) = h(w)  and  |P(t).w| < 1")
    for _ in range(5):
        z = rand_upper(rng)
        w = cayley(z)
        t = rng.uniform(-4, 4)
        w2 = mobius(P(t), w)
        check(
            "h invariant under P(t)",
            abs(disc_horo(w2) - disc_horo(w)) < 1e-9 and abs(w2) < 1,
            f"h = {disc_horo(w):.6f} -> {disc_horo(w2):.6f}, |w'| = {abs(w2):.6f}",
        )
    # The two algebraic identities powering the proof.
    print("\n  The twin identities behind the invariance:")
    for t, w in [(1.4, 0.3 - 0.2j), (-2.0, -0.6 + 0.1j)]:
        alpha, beta = 1 + I * t / 2, I * t / 2
        nu = alpha * w + beta
        delta = beta.conjugate() * w + alpha.conjugate()
        check(
            f"nu + delta = w + 1     (t={t}, w={w})",
            abs((nu + delta) - (w + 1)) < TOL,
        )
        check(
            f"|delta|^2 - |nu|^2 = 1 - |w|^2  (t={t}, w={w})",
            abs((abs(delta) ** 2 - abs(nu) ** 2) - (1 - abs(w) ** 2)) < TOL,
        )


# ----------------------------------------------------------------------------
# 9-10. The elliptic contrast and the discriminant dichotomy
# ----------------------------------------------------------------------------


def demo_elliptic(rng: random.Random) -> None:
    section("9. Elliptic contrast   K S(a) = R(a) K   and   C(x (+) y) = C(x) C(y)")
    for a in [-1.0, 0.25, 2.0]:
        check(f"K S({a}) = R({a}) K", mat_close(mat_mul(K, S(a)), mat_mul(R(a), K)))
        check(
            f"trace and determinant preserved for a = {a}",
            abs(mat_trace(R(a)) - mat_trace(S(a))) < TOL
            and abs(mat_det(R(a)) - mat_det(S(a))) < TOL,
            f"tr = {mat_trace(S(a)).real:.3f}, det = {mat_det(S(a)).real:.3f} = 1 + a^2",
        )
        w = 0.3 + 0.4j
        check(
            f"R({a}) acts as multiplication by the unimodular C({a})",
            abs(mobius(R(a), w) - cayley(complex(a)) * w) < TOL
            and abs(abs(cayley(complex(a))) - 1) < TOL,
        )

    print("\n  Linearisation of velocity addition:")
    print("        x        y      x (+) y     |C(x)C(y) - C(x(+)y)|")
    for x, y in [(0.5, 0.25), (-1.3, 0.4), (2.0, -0.75), (0.1, 0.1)]:
        s = spb(x, y)
        err = abs(cayley(complex(x)) * cayley(complex(y)) - cayley(complex(s)))
        print(f"   {x:8.3f} {y:8.3f} {s:11.5f}      {err:.2e}")
        check("C is a homomorphism", err < 1e-9)

    print("\n  Tangent interpretation: x = tan(alpha), y = tan(beta) => x (+) y = tan(alpha+beta)")
    for alpha, beta in [(0.3, 0.4), (-0.8, 1.0)]:
        lhs = spb(math.tan(alpha), math.tan(beta))
        rhs = math.tan(alpha + beta)
        check(f"tan addition (alpha={alpha}, beta={beta})", abs(lhs - rhs) < 1e-9,
              f"{lhs:.6f} vs {rhs:.6f}")

    print("\n  Boundary parametrisation: C maps R bijectively onto the circle minus {-1}")
    for x in [-4.0, -0.3, 0.0, 1.7]:
        w = cayley(complex(x))
        recovered = (-I * (w - 1) / (w + 1)).real
        check(
            f"round trip at x = {x}",
            abs(abs(w) - 1) < TOL and abs(recovered - x) < 1e-9 and abs(w + 1) > TOL,
            f"|C(x)| = {abs(w):.9f}, recovered x = {recovered:+.6f}",
        )

    section("10. Discriminant dichotomy   tr^2 - 4 det")
    print("        family              tr        det          tr^2 - 4 det   type")
    for t in [0.0, 1.0, -3.5]:
        disc = discriminant(T(t)).real
        print(f"   T({t:>5})           {mat_trace(T(t)).real:6.3f}   {mat_det(T(t)).real:8.4f}"
              f"     {disc:13.3e}   parabolic")
        check(f"T({t}) parabolic", abs(disc) < TOL)
    for a in [0.5, 1.0, 3.0]:
        disc = discriminant(S(a)).real
        print(f"   S({a:>5})           {mat_trace(S(a)).real:6.3f}   {mat_det(S(a)).real:8.4f}"
              f"     {disc:13.4f}   elliptic")
        check(f"S({a}) elliptic, disc = -4a^2", abs(disc + 4 * a * a) < TOL)


# ----------------------------------------------------------------------------
# 11. Parabolic normalisation
# ----------------------------------------------------------------------------


def parabolic_normalisation(M: Mat) -> Tuple[Mat, float]:
    """Given real M with det 1, trace 2, M != I, return (Pconj, s) with M Pconj = Pconj T(s)."""
    a, b, c, _d = (x.real for x in M)
    if abs(c) < TOL:
        return mat(1, 0, 0, 1), b
    return mat(-(a - 1) / c, 1, -1, 0), -c


def demo_normalisation(rng: random.Random) -> None:
    section("11. Parabolic normalisation   M = P T(s) P^{-1},  det P = 1,  s != 0")
    examples: List[Tuple[str, Mat]] = [
        ("[[1,3],[0,1]]  (already a translation)", mat(1, 3, 0, 1)),
        ("[[1,0],[1,1]]  (parabolic at 0)", mat(1, 0, 1, 1)),
        ("[[3,-4],[1,-1]] (parabolic at 2)", mat(3, -4, 1, -1)),
        ("[[-1,4],[-1,3]] (parabolic at 2)", mat(-1, 4, -1, 3)),
    ]
    for label, M in examples:
        det = mat_det(M).real
        tr = mat_trace(M).real
        Pc, s = parabolic_normalisation(M)
        recon = mat_mul(mat_mul(Pc, T(s)), mat_inv(Pc))
        check(
            f"{label}",
            abs(det - 1) < TOL
            and abs(tr - 2) < TOL
            and abs(mat_det(Pc) - 1) < TOL
            and abs(s) > TOL
            and mat_close(recon, M, 1e-8),
            f"s = {s:+.4f}, det P = {mat_det(Pc).real:.3f}",
        )
        # The fixed point predicted by the theory.
        if abs(M[2]) > TOL:
            x0 = ((M[0] - M[3]) / (2 * M[2])).real
            check(
                "   predicted fixed point (a-d)/(2c) is fixed",
                abs(mobius(M, complex(x0)) - x0) < 1e-9,
                f"x0 = {x0:+.4f}",
            )
        # And the disc form M X = X P(s).
        X = mat_mul(Pc, mat_inv(K))
        check(
            "   disc form  M X = X P(s)",
            mat_close(mat_mul(M, X), mat_mul(X, P(s)), 1e-8),
        )


# ----------------------------------------------------------------------------
# A worked orbit: the horocycle flow seen in both models
# ----------------------------------------------------------------------------


def demo_orbit() -> None:
    section("12. A single orbit, seen in both models (t = 0, 1, 2, ..., 5 applied to z = 0.5 + 1.2i)")
    z0 = 0.5 + 1.2j
    print("     t      z = T(t).z0                 C(z)                        h(C(z))   |C(z)|")
    for n in range(6):
        t = float(n)
        z = mobius(T(t), z0)
        w = mobius(P(t), cayley(z0))
        check("half-plane and disc orbits agree", abs(cayley(z) - w) < 1e-9)
        print(f"   {t:4.1f}   {z.real:+7.4f}{z.imag:+7.4f}i     "
              f"{w.real:+8.5f}{w.imag:+8.5f}i     {disc_horo(w):8.5f}  {abs(w):7.5f}")
    print("      The half-plane height Im z and the disc horocycle value h are constant")
    print("      along the orbit, while the point sweeps out a horocycle tangent at -1.")


# ----------------------------------------------------------------------------


def main() -> None:
    rng = random.Random(20260825)
    print("Matrix-level modular action: translations, the Cayley transform, horocycles")
    print("Numerical verification of every result, to 1e-9 tolerance.")

    demos: List[Callable[[], None]] = [
        lambda: demo_transformation_laws(rng),
        demo_translations,
        lambda: demo_rigidity(rng),
        lambda: demo_cayley(rng),
        lambda: demo_elliptic(rng),
        lambda: demo_normalisation(rng),
        demo_orbit,
    ]
    for d in demos:
        d()

    section("SUMMARY")
    if _FAILURES:
        print(f"  {len(_FAILURES)} check(s) FAILED:")
        for f in _FAILURES:
            print(f"    - {f}")
    else:
        print("  All checks passed.")


if __name__ == "__main__":
    main()
