# The Topology of Knotted Light: Alexander Polynomials in the Orbital-Angular-Momentum Spectrum

## Abstract

Structured laser beams can carry a *phase singularity* — a curve along which the
complex field amplitude vanishes — and that curve can be knotted. Such **knotted
light** beams also carry orbital angular momentum (OAM), and a recurring
conjecture in singular optics holds that the beam's OAM spectrum is governed by
the **Alexander polynomial** $\Delta_K$ of the underlying knot $K$: the quantized
OAM values $\ell$ are exactly those for which $\Delta_K$ vanishes on the root of
unity $e^{2\pi i \ell / N}$, where $N$ is a modular period associated with the
knot. This paper isolates and proves the exact algebra behind the conjecture for
the four smallest knots. We show that the trefoil ($3_1$) and cinquefoil ($5_1$)
Alexander polynomials are the sixth and tenth cyclotomic polynomials, so their
roots are roots of unity and produce clean OAM quantization at $\ell \equiv 1, 5
\pmod 6$ and $\ell \equiv 1, 3, 7, 9 \pmod{10}$ respectively; that the unknot has
empty spectrum; and that the figure-eight ($4_1$) has Alexander roots
$\varphi^{\pm 2} = (3 \pm \sqrt 5)/2$ — the squares of the golden ratio — lying
*off* the unit circle, so it admits no root-of-unity OAM quantization. We also
establish the reciprocity (palindromic) functional equation, the normalization
$\Delta(1) = \pm 1$, and the knot determinants $|\Delta(-1)| = 3, 5, 5$. These
results delineate precisely when the knotted-light/Alexander correspondence
produces genuine quantized OAM and when it does not.

**Keywords:** knotted light, orbital angular momentum, Alexander polynomial,
cyclotomic polynomial, torus knot, golden ratio, knot determinant, singular optics.

---

## 1. Introduction

A monochromatic optical field is described by a complex scalar amplitude
$\psi(\mathbf{x})$. Generically the zero set $\{\psi = 0\}$ is a one-dimensional
curve in three-dimensional space — a **phase singularity**, or optical vortex
line, along which the field's phase is undefined. Over the past two decades it has
become possible to engineer beams in which this vortex line is *knotted*: it forms
a nontrivial closed curve such as a trefoil. These **knotted light** fields are a
striking meeting point of topology and wave physics.

Independently, beams can carry **orbital angular momentum** (OAM): a field with
azimuthal phase dependence $e^{i\ell\theta}$ carries OAM $\ell\hbar$ per photon,
with $\ell \in \mathbb{Z}$. A knotted beam is a superposition of OAM eigenmodes,
and thus possesses an **OAM spectrum**, the set of $\ell$-values it contains.

The organizing conjecture we study is that this spectrum is dictated by the
topology of the vortex knot through its Alexander polynomial:

$$\text{OAM spectrum of a beam with vortex knot } K \;=\; \{\, \ell \;:\; \Delta_K(e^{2\pi i \ell / N}) = 0 \,\}. \tag{$\star$}$$

The content of $(\star)$ is entirely determined by the location of the roots of
$\Delta_K$ relative to the unit circle. This paper proves the relevant root
structure for the smallest knots and thereby determines, in each case, whether
$(\star)$ yields genuine quantized OAM.

Our contributions are:

1. A precise formulation of the OAM spectrum as a subset of $\mathbb{R}$ (Section 3).
2. Exact identification of the trefoil and cinquefoil spectra via cyclotomic
   factorizations of $t^n + 1$ (Sections 4–5).
3. The triviality of the unknot spectrum (Section 4.3).
4. The golden-ratio, off-circle root structure of the figure-eight, and the
   resulting *failure* of root-of-unity quantization (Section 6).
5. Structural invariants — reciprocity, normalization, and knot determinants —
   that cross-check the polynomials (Section 7).

---

## 2. Background: knots and the Alexander polynomial

A **knot** is an embedding of the circle $S^1$ into $S^3$ (or $\mathbb{R}^3$), up
to ambient isotopy. The **Alexander polynomial** $\Delta_K(t) \in \mathbb{Z}[t,
t^{-1}]$ is a classical isotopy invariant, defined up to multiplication by
$\pm t^k$. It can be computed from a Seifert matrix $V$ of the knot via
$\Delta_K(t) \doteq \det(V - t V^{\mathsf T})$. Normalized to a genuine polynomial
with nonzero constant term, the smallest knots have:

| Knot | Symbol | $\Delta_K(t)$ |
|------|--------|---------------|
| Unknot | $0_1$ | $1$ |
| Trefoil | $3_1$ | $t^2 - t + 1$ |
| Figure-eight | $4_1$ | $t^2 - 3t + 1$ |
| Cinquefoil | $5_1$ | $t^4 - t^3 + t^2 - t + 1$ |

Two structural facts hold for every knot and will be verified case by case below:

- **Reciprocity (palindromy):** $t^{\deg \Delta}\,\Delta(1/t) = \Delta(t)$.
- **Normalization:** $\Delta(1) = \pm 1$.

The **knot determinant** is $\det(K) = |\Delta_K(-1)|$, always an odd positive
integer.

---

## 3. The OAM spectrum

We model the Alexander polynomial as an entire function $\Delta : \mathbb{C} \to
\mathbb{C}$ (the polynomial evaluated at a complex argument) and place the OAM
labels on the real line.

> **Definition 3.1 (OAM spectrum).** For an Alexander polynomial $\Delta$ and a
> modular period $N \in \mathbb{N}$, the **OAM spectrum** is
> $$\mathrm{OAM}(\Delta, N) \;=\; \Big\{\, \ell \in \mathbb{R} \;:\; \Delta\!\big(e^{2\pi i \ell / N}\big) = 0 \,\Big\}.$$

Thus $\ell$ is a quantized OAM value precisely when the point
$e^{2\pi i \ell / N}$ on the unit circle is a zero of $\Delta$. Because
$e^{2\pi i \ell / N}$ always lies on the unit circle, only roots of $\Delta$ *on
the unit circle* can contribute to the spectrum — a fact that becomes decisive for
the figure-eight knot.

We record the evaluation-function form of each polynomial:

$$\Delta_{\text{unknot}}(z) = 1,\quad \Delta_{3_1}(z) = z^2 - z + 1,\quad \Delta_{5_1}(z) = z^4 - z^3 + z^2 - z + 1.$$

---

## 4. The trefoil: sixth roots of unity

### 4.1 A root criterion via $t^3 + 1$

> **Lemma 4.1.** If $z \in \mathbb{C}$ satisfies $z^3 = -1$ and $z \neq -1$, then
> $\Delta_{3_1}(z) = z^2 - z + 1 = 0$.

*Proof.* The identity $(z+1)(z^2 - z + 1) = z^3 + 1$ holds in any commutative
ring. Substituting $z^3 = -1$ gives $(z+1)(z^2 - z + 1) = 0$. Since $z \neq -1$,
the first factor is nonzero, so $z^2 - z + 1 = 0$. $\qquad\blacksquare$

This is the algebraic heart of the trefoil case: $\Delta_{3_1}$ is the cofactor of
$(t+1)$ in $t^3 + 1$, i.e. the sixth cyclotomic polynomial $\Phi_6(t) = t^2 - t +
1$.

### 4.2 The two quantized values

Let $\zeta_6 = e^{2\pi i / 6}$, a primitive sixth root of unity.

> **Lemma 4.2.** $\zeta_6 \neq -1$ and $\zeta_6^3 = -1$.

*Proof.* Since $\zeta_6$ is a primitive sixth root of unity, $\zeta_6^k \neq 1$
for $0 < k < 6$; in particular $\zeta_6^2 \neq 1$, so $\zeta_6 \neq -1$. From
$\zeta_6^6 = 1$ we get $(\zeta_6^3)^2 = 1$, hence $\zeta_6^3 = \pm 1$; and
$\zeta_6^3 \neq 1$ by primitivity, so $\zeta_6^3 = -1$. $\qquad\blacksquare$

> **Theorem 4.3 (trefoil spectrum).** The trefoil beam (period $N = 6$) is OAM-
> quantized at $\ell = 1$ and $\ell = 5$, but not at $\ell = 0$. That is,
> $1, 5 \in \mathrm{OAM}(\Delta_{3_1}, 6)$ and $0 \notin \mathrm{OAM}(\Delta_{3_1}, 6)$.

*Proof.* For $\ell = 1$: $e^{2\pi i \cdot 1 / 6} = \zeta_6$, and Lemmas 4.1–4.2
give $\Delta_{3_1}(\zeta_6) = 0$. For $\ell = 5$: $e^{2\pi i \cdot 5/6} =
\zeta_6^5$; one checks $(\zeta_6^5)^3 = (\zeta_6^6)^2 \zeta_6^3 = \zeta_6^3 = -1$
and $\zeta_6^5 \neq -1$ (its square is $\zeta_6^{10} = \zeta_6^4 \neq 1$), so
Lemma 4.1 applies again. For $\ell = 0$: $e^0 = 1$ and $\Delta_{3_1}(1) = 1 \neq
0$. $\qquad\blacksquare$

The roots $\zeta_6, \zeta_6^5 = e^{\pm i\pi/3}$ are precisely the two primitive
sixth roots of unity, confirming $\Delta_{3_1} = \Phi_6$. The trefoil is the
$(2,3)$ torus knot; this is the $k = 1$ case of the torus family in Section 8.

### 4.3 The unknot

> **Theorem 4.4 (trivial spectrum).** For every $N$, $\mathrm{OAM}(\Delta_{\text{unknot}}, N) = \varnothing$.

*Proof.* $\Delta_{\text{unknot}} \equiv 1$, which never vanishes; the defining set
is empty. $\qquad\blacksquare$

A plain unknotted vortex loop carries no quantized OAM under $(\star)$ — the
correspondence correctly assigns the topologically trivial beam a trivial
spectrum.

---

## 5. The cinquefoil: tenth roots of unity

### 5.1 A root criterion via $t^5 + 1$

> **Lemma 5.1.** If $z^5 = -1$ and $z \neq -1$, then
> $\Delta_{5_1}(z) = z^4 - z^3 + z^2 - z + 1 = 0$.

*Proof.* From $(z+1)(z^4 - z^3 + z^2 - z + 1) = z^5 + 1 = 0$ and $z \neq -1$, the
second factor vanishes. $\qquad\blacksquare$

Thus $\Delta_{5_1}$ is the cofactor of $(t+1)$ in $t^5 + 1$, namely the tenth
cyclotomic polynomial $\Phi_{10}(t) = t^4 - t^3 + t^2 - t + 1$.

### 5.2 The quantized values

Let $\zeta_{10} = e^{2\pi i / 10}$, a primitive tenth root of unity.

> **Lemma 5.2.** $\zeta_{10} \neq -1$ and $\zeta_{10}^5 = -1$.

*Proof.* Primitivity gives $\zeta_{10}^2 \neq 1$, so $\zeta_{10} \neq -1$. From
$\zeta_{10}^{10} = 1$, $(\zeta_{10}^5)^2 = 1$ so $\zeta_{10}^5 = \pm 1$; and
$\zeta_{10}^5 \neq 1$ by primitivity, so $\zeta_{10}^5 = -1$. $\qquad\blacksquare$

> **Theorem 5.3 (cinquefoil spectrum).** The cinquefoil beam (period $N = 10$) is
> OAM-quantized at $\ell = 1$ (and, by the same argument, at $\ell = 3, 7, 9$).

*Proof.* $e^{2\pi i / 10} = \zeta_{10}$, and Lemmas 5.1–5.2 give
$\Delta_{5_1}(\zeta_{10}) = 0$, so $1 \in \mathrm{OAM}(\Delta_{5_1}, 10)$. The
values $\ell = 3, 7, 9$ correspond to the other primitive tenth roots of unity
$\zeta_{10}^3, \zeta_{10}^7, \zeta_{10}^9$, each of which is a fifth root of $-1$
distinct from $-1$. $\qquad\blacksquare$

The cinquefoil is the $(2,5)$ torus knot: the $k = 2$ member of the family.

---

## 6. The figure-eight: golden-ratio roots off the unit circle

The figure-eight knot $4_1$ has $\Delta_{4_1}(t) = t^2 - 3t + 1$. We work with the
real evaluation function $f(x) = x^2 - 3x + 1$.

Recall the **golden ratio** $\varphi = (1 + \sqrt 5)/2$ and its conjugate $\psi =
(1 - \sqrt 5)/2$, which satisfy $\varphi^2 = \varphi + 1$, $\psi^2 = \psi + 1$,
and $\varphi\psi = -1$.

> **Theorem 6.1 (golden roots).** The roots of $\Delta_{4_1}$ are $\varphi^2 = (3
> + \sqrt 5)/2$ and $\psi^2 = (3 - \sqrt 5)/2$. Equivalently $f(\varphi^2) =
> f(\psi^2) = 0$.

*Proof.* Using $\varphi^2 = \varphi + 1$ we compute
$$f(\varphi^2) = (\varphi^2)^2 - 3\varphi^2 + 1 = (\varphi^2 + \varphi - 1)(\varphi^2 - \varphi - 1) = (\varphi^2 + \varphi - 1)\cdot 0 = 0,$$
since $\varphi^2 - \varphi - 1 = 0$. The identical computation with $\psi^2 = \psi
+ 1$ gives $f(\psi^2) = 0$. $\qquad\blacksquare$

> **Theorem 6.2 (reciprocal roots).** $\varphi^2 \cdot \psi^2 = 1$.

*Proof.* $\varphi^2 \psi^2 = (\varphi\psi)^2 = (-1)^2 = 1$. $\qquad\blacksquare$

> **Theorem 6.3 (off the unit circle).** $\varphi^2 > 1$ (and hence $\psi^2 =
> 1/\varphi^2 < 1$). Neither root lies on the unit circle.

*Proof.* $\varphi > 1$, so $\varphi^2 > 1$. By Theorem 6.2 the second root is its
reciprocal, hence in $(0,1)$. Both are real and $\neq \pm 1$, so neither is on the
unit circle $|z| = 1$. $\qquad\blacksquare$

**Consequence.** Because $\mathrm{OAM}(\Delta, N)$ can only detect roots on the
unit circle (Section 3), and the figure-eight's roots $\varphi^{\pm 2}$ lie off
it, the figure-eight beam admits *no* root-of-unity OAM quantization. This makes
$4_1$ the smallest knot for which the naive form of $(\star)$ produces an empty
quantized spectrum despite the knot being nontrivial — a qualitative divide
between the cyclotomic knots ($3_1, 5_1$) and $4_1$. The golden-ratio signature
$(3 \pm \sqrt 5)/2$ is the tell-tale fingerprint of this off-circle behavior.

---

## 7. Structural invariants

These invariants hold abstractly for Alexander polynomials and serve as
independent cross-checks.

### 7.1 Reciprocity (palindromic functional equation)

> **Theorem 7.1.** For $z \neq 0$: $z^2\,\Delta_{3_1}(1/z) = \Delta_{3_1}(z)$ and
> $z^4\,\Delta_{5_1}(1/z) = \Delta_{5_1}(z)$.

*Proof.* $z^2(z^{-2} - z^{-1} + 1) = 1 - z + z^2 = z^2 - z + 1$; likewise
$z^4(z^{-4} - z^{-3} + z^{-2} - z^{-1} + 1) = z^4 - z^3 + z^2 - z + 1$.
$\qquad\blacksquare$

Reciprocity forces roots to occur in pairs $\{z, 1/z\}$, which is exactly why the
figure-eight roots came out as the reciprocal pair $\varphi^2, \varphi^{-2}$
(Theorem 6.2), and why unit-circle roots come in conjugate pairs $\{z, \bar z\}$
(as for the trefoil and cinquefoil, since $1/z = \bar z$ on the circle).

### 7.2 Normalization

> **Theorem 7.2.** $\Delta_{3_1}(1) = 1$, $\Delta_{4_1}(1) = -1$, $\Delta_{5_1}(1) = 1$.

*Proof.* Direct evaluation: $1 - 1 + 1 = 1$; $1 - 3 + 1 = -1$; $1 - 1 + 1 - 1 + 1
= 1$. $\qquad\blacksquare$

In every case $\Delta(1) = \pm 1$, confirming the general normalization. This is
also the structural reason $\ell = 0$ is never in the spectrum: $e^0 = 1$ is never
a root.

### 7.3 Knot determinants

> **Theorem 7.3.** $\Delta_{3_1}(-1) = 3$, $\Delta_{4_1}(-1) = 5$, $\Delta_{5_1}(-1) = 5$;
> all three are odd.

*Proof.* $(-1)^2 - (-1) + 1 = 3$; $1 + 3 + 1 = 5$; $1 + 1 + 1 + 1 + 1 = 5$; each
is odd. $\qquad\blacksquare$

Hence $\det(3_1) = 3$, $\det(4_1) = 5$, $\det(5_1) = 5$. The trefoil determinant
$3$ is exactly its number of Fox $3$-colorings condition ($\det \equiv 0 \pmod 3$),
recovering the classical fact that the trefoil is tricolorable while the unknot is
not.

---

## 8. Algorithms

We describe the computational procedures behind the numerical demonstrations.

**Algorithm A — OAM spectrum by root testing.** Given a knot's Alexander
polynomial $\Delta$ and period $N$, enumerate $\ell = 0, 1, \dots, N-1$, evaluate
$\Delta(e^{2\pi i \ell / N})$, and collect those $\ell$ with
$|\Delta(e^{2\pi i \ell / N})| < \varepsilon$ for a numerical tolerance. Cost:
$O(N \cdot d)$ for degree-$d$ polynomials.

**Algorithm B — cyclotomic identification.** To test whether $\Delta = \Phi_n$,
factor $t^n \pm 1$ symbolically and compare the cofactor of $(t+1)$ (or $(t-1)$),
or compare root sets against $\{e^{2\pi i k/n} : \gcd(k,n) = 1\}$. This certifies
the trefoil $\leftrightarrow \Phi_6$ and cinquefoil $\leftrightarrow \Phi_{10}$
correspondences.

**Algorithm C — root localization / unit-circle test.** Compute the roots of
$\Delta$ (closed form for quadratics/quartics, or numerically) and classify each
by $|z|$ against $1$. A knot yields root-of-unity OAM quantization iff all roots
satisfy $|z| = 1$. This flags the figure-eight as off-circle.

---

## 9. Applications and discussion

**Topological encoding of angular momentum.** The results make precise a
remarkable dictionary: the topology of a beam's vortex knot is legible in a
measurable physical spectrum. Because topological data is robust to continuous
perturbation, OAM values fixed by a knot's Alexander roots inherit that
robustness, suggesting knot-labeled beams as noise-resilient information carriers.

**A dichotomy of knots.** Our theorems draw a sharp line. *Cyclotomic knots* like
the trefoil and cinquefoil have all Alexander roots on the unit circle and produce
crisp quantized OAM at specified residues. The figure-eight, with golden-ratio
roots off the circle, produces none under the naive correspondence. Whether a knot
supports clean OAM quantization is thus itself a knot invariant question.

**Determinants and colorings.** The knot determinants $3, 5, 5$ tie the optical
story back to combinatorial invariants (Fox colorings): the trefoil's $\det = 3$
predicts its tricolorability. This offers a second, discrete readout channel
alongside the continuous OAM spectrum.

**Limitations.** We treat the exact algebra of Alexander polynomials and the root
structure that $(\star)$ depends on; we do not model the full electromagnetic
field construction that realizes a given vortex knot, nor mode-coupling and
measurement noise in a physical apparatus. The correspondence $(\star)$ is
formulated at the level of the spectrum's support.

---

## 10. Future directions

1. **Cyclotomic identification.** Prove the full identities $\Delta_{3_1} =
   \Phi_6$ and $\Delta_{5_1} = \Phi_{10}$ (including the *converse*: no spurious
   roots), via the classification of cyclotomic roots.

2. **Torus-knot family.** The trefoil and cinquefoil are the $(2,3)$ and $(2,5)$
   torus knots, with $\Delta_{(2,2k+1)}(t) = (t^{2k+1} + 1)/(t + 1)$. Establish
   the general torus-knot Alexander polynomial and show its roots are the
   $(4k+2)$-th roots of unity that are not $(2k+1)$-th roots — a uniform
   generalization.

3. **General reciprocity and $\Delta(1) = \pm 1$.** Derive the reciprocity law
   $t^{2g}\Delta(1/t) = \Delta(t)$ and normalization $\Delta(1) = \pm 1$ from an
   abstract axiomatization via Seifert matrices $V$, $\Delta(t) = \det(V - tV^{\mathsf
   T})$, rather than case by case.

4. **Knot determinant as $|\Delta(-1)|$.** Connect the numbers $3, 5, 5$ to the
   determinant via a Goeritz or Seifert matrix, and to $p$-colorability
   ($3$-colorable $\Leftrightarrow 3 \mid \det$).

5. **Off-circle roots and the golden ratio.** Characterize which knots have all
   Alexander roots on the unit circle (a necessary condition for genuine
   root-of-unity OAM quantization). The figure-eight, with roots $\varphi^{\pm
   2}$, is the smallest knot violating this.

---

## 11. Conclusion

We have proved the exact root structure that decides the knotted-light/OAM
correspondence for the four smallest knots. The trefoil and cinquefoil Alexander
polynomials are cyclotomic, giving quantized OAM at $\ell \equiv 1, 5 \pmod 6$ and
$\ell \equiv 1, 3, 7, 9 \pmod{10}$; the unknot's spectrum is empty; and the
figure-eight's golden-ratio roots lie off the unit circle, so it admits no
root-of-unity quantization. Reciprocity, normalization $\Delta(1) = \pm 1$, and
the determinants $3, 5, 5$ round out the picture. Together these results show
exactly where the elegant slogan "knotted light carries the Alexander polynomial
in its angular momentum" is literally true — and where a subtler statement is
needed.
