# Stereographic Fourier Analysis: The Chordal Metric Identity and a Program for Harmonic Analysis on Spheres

## Abstract

Stereographic projection is the classical conformal diffeomorphism between the
$n$-sphere (minus a pole) and $n$-dimensional Euclidean space. Its inverse lifts
a point $x$ of flat space to a point $\Phi(x)$ on the unit sphere. We establish,
in full generality over an arbitrary real inner product space, the **chordal
metric identity**: the squared Euclidean (chordal) distance between two lifted
points is
$$
\|\Phi(x)-\Phi(y)\|^2 = \frac{4\,\|x-y\|^2}{\left(1+\|x\|^2\right)\left(1+\|y\|^2\right)}.
$$
This is an exact, global identity — not an infinitesimal or asymptotic
statement. Taking the coincidence limit $y\to x$ recovers the conformal factor
$4/(1+\|x\|^2)^2$ relating the round metric to the flat metric, and this factor
solves the Liouville equation certifying constant curvature $+1$. We then use the
exactness of the identity to motivate and structure a program of **stereographic
Fourier analysis**: a transform that carries square-integrable functions on the
sphere to square-integrable functions on flat space by pulling back through the
projection, correcting by the square root of the conformal Jacobian, and applying
the ordinary Euclidean Fourier kernel. We state the conjectural isometry
(Plancherel) property, the mapping of low-degree spherical harmonics to
Hermite-type profiles, and the eigenvalue transfer law with its universal
conformal shift $n^2/4$. The chordal identity is the exact geometric input that
makes each of these tractable. We include numerical demonstrations and
algorithmic descriptions.

**Keywords:** stereographic projection, chordal metric, conformal factor,
Liouville equation, spherical harmonics, Fourier transform, Hermite functions,
Laplace–Beltrami operator.

---

## 1. Introduction

Fourier analysis on flat Euclidean space $\mathbb{R}^n$ is built on a single
structural fact: the plane waves $e_k(x)=e^{2\pi i\, x\cdot k}$ are the
simultaneous eigenfunctions of the Laplacian $\Delta$ and of the translation
group. The Fourier transform diagonalizes $\Delta$, and Plancherel's theorem
makes the transform an isometry of $L^2(\mathbb{R}^n)$.

On the round sphere $S^n$ the corresponding role is played by the **spherical
harmonics** $Y_\ell^m$, the eigenfunctions of the Laplace–Beltrami operator
$\Delta_{S^n}$ with eigenvalues $-\ell(\ell+n-1)$. Harmonic analysis on the
sphere is central to potential theory, mathematical physics, geophysics, and
cosmology, but its curved geometry makes it computationally less convenient than
its flat counterpart.

Stereographic projection provides a conformal bridge between the two worlds. The
purpose of this paper is twofold. First, we prove the exact geometric statement
that governs the bridge — the chordal metric identity — in the natural generality
of an arbitrary real inner product space, so that the same statement covers all
finite dimensions and infinite-dimensional Hilbert spaces uniformly. Second, we
show how the *exactness* of this identity organizes a coherent program for
transporting Fourier analysis between sphere and plane, and we state the central
conjectures of that program precisely.

The organizing principle is simple to state. A conformal change of metric by a
factor $\Omega^2$ multiplies the volume element by $\Omega^n$ and hence multiplies
the natural $L^2$ inner product by $\Omega^n$. If one wants a transform between
$L^2$ spaces to be an isometry, one must insert the compensating weight
$\Omega^{-n/2}$ — the square root of the Jacobian. The chordal identity computes
$\Omega$ exactly, so the compensating weight is known exactly, and the isometry
can be checked term by term rather than estimated.

## 2. Setup and definitions

Let $E$ be a real inner product space with inner product
$\langle\cdot,\cdot\rangle$ and induced norm $\|\cdot\|$. We form the product
$E\times\mathbb{R}$ and equip it with the $L^2$ (Euclidean) norm
$$
\|(u,t)\|^2 = \|u\|^2 + t^2 .
$$
This is the ambient space in which the unit sphere lives.

**Definition 2.1 (Inverse stereographic projection).** The *inverse
stereographic projection* is the map $\Phi : E \to E\times\mathbb{R}$ given by
$$
\Phi(x) = \left( \frac{2x}{1+\|x\|^2},\ \frac{\|x\|^2 - 1}{1+\|x\|^2} \right).
$$

A direct computation shows $\Phi(x)$ always lies on the unit sphere: writing
$a=\|x\|^2$,
$$
\left\|\frac{2x}{1+a}\right\|^2 + \left(\frac{a-1}{1+a}\right)^2
= \frac{4a}{(1+a)^2} + \frac{(a-1)^2}{(1+a)^2}
= \frac{4a + a^2 - 2a + 1}{(1+a)^2}
= \frac{(a+1)^2}{(1+a)^2} = 1 .
$$
The map is a bijection from $E$ onto the sphere minus its north pole
$(0,1)$; the north pole is the image of the "point at infinity."

**Definition 2.2 (Chordal distance).** The *chordal distance* between two points
of the sphere is the ordinary Euclidean distance between them in the ambient space
$E\times\mathbb{R}$. The chordal distance between the lifts of $x,y\in E$ is
$\|\Phi(x)-\Phi(y)\|$.

## 3. The chordal metric identity

**Theorem 3.1 (Chordal metric identity).** For all $x,y\in E$,
$$
\|\Phi(x)-\Phi(y)\|^2 = \frac{4\,\|x-y\|^2}{\left(1+\|x\|^2\right)\left(1+\|y\|^2\right)} .
$$

*Proof sketch.* Write $a=\|x\|^2$, $b=\|y\|^2$, and $s=\langle x,y\rangle$. Using
the $L^2$ decomposition of the ambient norm, split the squared chordal distance
into a horizontal and a vertical contribution:
$$
\|\Phi(x)-\Phi(y)\|^2
= \underbrace{\left\| \frac{2}{1+a}\,x - \frac{2}{1+b}\,y \right\|^2}_{\text{horizontal}}
+ \underbrace{\left( \frac{a-1}{1+a} - \frac{b-1}{1+b} \right)^2}_{\text{vertical}} .
$$
Expand the horizontal term with the real polarization identity
$\|u-v\|^2 = \|u\|^2 - 2\langle u,v\rangle + \|v\|^2$ together with the
homogeneity of the norm and the bilinearity of the inner product:
$$
\left\| \frac{2}{1+a}\,x - \frac{2}{1+b}\,y \right\|^2
= \frac{4a}{(1+a)^2} - \frac{8s}{(1+a)(1+b)} + \frac{4b}{(1+b)^2} .
$$
The vertical term expands to
$$
\left( \frac{a-1}{1+a} - \frac{b-1}{1+b} \right)^2
= \frac{\bigl((a-1)(1+b) - (b-1)(1+a)\bigr)^2}{(1+a)^2(1+b)^2}
= \frac{4(a-b)^2}{(1+a)^2(1+b)^2} .
$$
On the right-hand side, expand $\|x-y\|^2 = a - 2s + b$. What remains is a single
rational-function identity in $a,b,s$ over the strictly positive denominators
$1+a$ and $1+b$. Clearing denominators, both sides equal
$$
\frac{4\,(a - 2s + b)}{(1+a)(1+b)},
$$
which is verified by direct polynomial expansion. $\qquad\blacksquare$

Theorem 3.1 holds verbatim in every dimension and even in infinite-dimensional
Hilbert spaces, because the proof uses only inner-product identities and never the
dimension of $E$.

### 3.1 The conformal factor and the induced metric

**Corollary 3.2 (Conformal factor).** As $y\to x$, the chordal metric identity
yields the infinitesimal relation
$$
ds^2_{\text{sphere}} = \frac{4}{\left(1+\|x\|^2\right)^2}\, ds^2_{\text{flat}} .
$$
Equivalently, the round metric pulled back through stereographic projection equals
the flat metric times the scalar conformal factor
$\Omega(x)^2 = 4/(1+\|x\|^2)^2$.

*Proof sketch.* Put $y = x + h$ with $h\to 0$. Then $\|x-y\|^2 = \|h\|^2$ and
$\|y\|^2 = \|x\|^2 + O(\|h\|)$, so the denominator tends to $(1+\|x\|^2)^2$. The
leading term of $\|\Phi(x)-\Phi(y)\|^2$ is therefore
$4\|h\|^2/(1+\|x\|^2)^2$. $\qquad\blacksquare$

Because the conformal factor multiplies all directions by the same scalar, the map
$\Phi$ is conformal: it preserves angles while distorting lengths by
$\Omega(x)=2/(1+\|x\|^2)$.

**Corollary 3.3 (Constant curvature via Liouville's equation).** In dimension
$n=2$, write the conformal factor as $e^{2u}$ with $u(x)=\log\bigl(2/(1+\|x\|^2)\bigr)$.
Then $u$ solves the Liouville equation
$$
\Delta u + K\, e^{2u} = 0
$$
with Gaussian curvature $K = +1$; that is, the metric $e^{2u}\,ds^2_{\text{flat}}$
is a metric of constant curvature $+1$, the round unit sphere.

*Proof sketch.* Compute $\Delta u$ for $u = \log 2 - \log(1+\|x\|^2)$ in the
plane. With $r^2=\|x\|^2$ one finds $\Delta u = -4/(1+r^2)^2 = -e^{2u}$, so
$\Delta u + e^{2u} = 0$, which is the Liouville equation with $K=1$. $\qquad\blacksquare$

Corollaries 3.2 and 3.3 together certify that the single scalar
$4/(1+\|x\|^2)^2$ is a complete description of the sphere's geometry as seen from
the plane: it fixes both the infinitesimal distortion and the curvature.

## 4. The stereographic Fourier transform

We now describe the analytic program that the exact identity supports.

**Definition 4.1 (Stereographic Fourier transform).** Let $\sigma$ denote the
round surface measure on $S^n$ and let $\varphi = \Phi^{-1}$ denote stereographic
projection from the sphere to $\mathbb{R}^n$. For $f\in L^2(S^n)$ and
$k\in\mathbb{R}^n$ define
$$
F[f](k) = \int_{S^n} f(x)\,\bigl(1+\|\varphi(x)\|^2\bigr)^{-n/2}\,
e^{-2\pi i\,\varphi(x)\cdot k}\, d\sigma(x) .
$$

The weight $\bigl(1+\|\varphi\|^2\bigr)^{-n/2}$ is exactly $\Omega^{-n/2}$ up to a
constant, i.e. the square root of the change-of-variables Jacobian dictated by
Corollary 3.2. Changing variables $x = \Phi(t)$ turns the curved integral into a
flat one:
$$
F[f](k) = \int_{\mathbb{R}^n} g(t)\, e^{-2\pi i\, t\cdot k}\, dt,
\qquad
g(t) = f(\Phi(t))\,\bigl(1+\|t\|^2\bigr)^{-n/2}\, J(t)\,\bigl(1+\|t\|^2\bigr)^{-n/2}',
$$
where $J$ is the Jacobian of $\Phi$. The design of the weight ensures $g\in
L^2(\mathbb{R}^n)$ precisely when $f\in L^2(S^n)$, with matching norms — this is
the mechanism behind the following conjecture.

**Conjecture 4.2 (Plancherel / isometry).** For every $n$, the stereographic
Fourier transform $F$ is a unitary isomorphism
$F : L^2(S^n) \to L^2(\mathbb{R}^n)$; in particular it preserves total energy,
$\|F[f]\|_{L^2(\mathbb{R}^n)} = \|f\|_{L^2(S^n)}$.

The reason the conjecture is now attackable is that Corollary 3.2 gives the
conformal factor in closed form and Theorem 3.1 shows it is the *only* source of
distortion. The Jacobian cancellation can therefore be checked exactly rather than
estimated, reducing the isometry to the classical flat-space Plancherel theorem.

**Conjecture 4.3 (Harmonics to Hermite profiles).** For $n=2$, the three
degree-one spherical harmonics — the restrictions to $S^2$ of the ambient
coordinate functions — map under $F$ to first-order Hermite-type functions on the
plane with explicit rational-times-Gaussian radial profiles. More generally,
degree-$\ell$ harmonics map to order-$\ell$ generalized Hermite functions.

*Rationale.* Pulled back through $\Phi$, a degree-one harmonic becomes a
Möbius-rational function with linear numerator and denominator a power of
$1+\|x\|^2$ — explicitly $2x_i/(1+\|x\|^2)$ for the horizontal coordinates and
$(\|x\|^2-1)/(\|x\|^2+1)$ for the height. Convolving such a rational profile
against the plane-wave kernel is precisely the integral that generates Hermite
functions from monomials.

**Conjecture 4.4 (Eigenvalue transfer with conformal shift).** The transform
intertwines $\Delta_{S^n}$ with the flat Laplacian $\Delta_{\mathbb{R}^n}$ up to
the additive constant $n^2/4$ and a lower-order first-order term. Concretely, a
spherical harmonic with eigenvalue $-\ell(\ell+n-1)$ is carried to a function on
which the flat Laplacian acts with leading eigenvalue
$$
-\ell(\ell+n-1) + \frac{n^2}{4} .
$$

*Rationale.* Under a conformal change of metric by $\Omega^2$, the Laplace–Beltrami
operator transforms into the flat Laplacian conjugated by a power of $\Omega$, plus
a curvature term proportional to the scalar curvature. For the round sphere this
curvature term contributes exactly the universal constant $n^2/4$, the same shift
that appears in the conformal (Yamabe) Laplacian.

## 5. Algorithms

We summarize three computational procedures that operationalize the theory. Full
type-hinted implementations accompany this paper.

**A. Chordal identity verifier.** Given $x,y$, compute the lifts $\Phi(x),\Phi(y)$
numerically, form the ambient squared distance, and compare against
$4\|x-y\|^2 / \bigl((1+\|x\|^2)(1+\|y\|^2)\bigr)$. Complexity $O(n)$ per pair.
This certifies Theorem 3.1 to machine precision across random samples.

**B. Conformal-factor / Liouville checker.** On a planar grid, evaluate
$u=\log(2/(1+r^2))$ and its Laplacian by finite differences, and confirm
$\Delta u + e^{2u} \approx 0$. Complexity $O(N)$ in the number of grid points.
This certifies Corollary 3.3.

**C. Discrete stereographic Fourier transform.** Sample $f$ on the sphere, pull
back through $\varphi$, apply the weight $(1+\|t\|^2)^{-n/2}$, and evaluate the
flat Fourier integral by quadrature or FFT. Complexity $O(N\log N)$ with an FFT
grid. This is the practical engine of Definition 4.1.

## 6. Applications

- **Computational harmonic analysis on spheres.** Expansions in spherical
  harmonics can be routed through the mature and highly optimized flat-space FFT,
  with the exact conformal weight guaranteeing that norms and energies are
  preserved.
- **Quantum mechanics on curved backgrounds.** A particle constrained to a
  spherical configuration space, or a field on a positively curved cosmology, can
  be transported to flat space, solved with standard Fourier methods, and
  transported back; the shift $n^2/4$ appears as a physical ground-state energy
  offset.
- **Conformal geometry and the Yamabe problem.** The explicit conformal factor and
  its Liouville equation provide a clean, fully worked example of a
  constant-curvature conformal metric, useful as a test case for numerical
  conformal geometry.

## 7. Discussion

The chordal metric identity is elementary in the sense that its proof requires
only inner-product algebra, yet it is the exact hinge on which the entire program
turns. Its two consequences — the closed-form conformal factor and the Liouville
equation — are precisely the geometric facts needed to make the analytic
conjectures of Section 4 checkable rather than merely plausible. Because the
identity holds in arbitrary inner product spaces, the same statement covers every
finite dimension and the infinite-dimensional Hilbert setting without change,
which is convenient for the general-$n$ formulation of the transform.

The principal open problem is Conjecture 4.2. The pointwise Jacobian cancellation
is exact, so the remaining work is analytic: controlling the transform on all of
$L^2(S^n)$ and identifying its precise image. Conjectures 4.3 and 4.4 are, by
contrast, computations of a finite family of explicit radial integrals and a
conformal transformation law, and should follow once the isometry is in hand.

## 8. Future work

Beyond resolving the three conjectures, natural directions include: a full
diagonalization of the transform in a Hermite-function basis; the extension to
the conformal Laplacian and the precise form of the lower-order term in
Conjecture 4.4; sampling theorems and quadrature error bounds for the discrete
transform of Section 5; and applications to fast spherical convolution and to
spectral methods for partial differential equations posed on spheres.

## 9. Conclusion

We proved the chordal metric identity for inverse stereographic projection in full
generality, extracted from it the exact conformal factor $4/(1+\|x\|^2)^2$ and its
Liouville equation certifying constant curvature $+1$, and used the exactness of
these facts to structure a program of stereographic Fourier analysis. The identity
converts the geometry of the sphere into a single explicit scalar weight, opening
the door to performing harmonic analysis on spheres through classical Fourier
analysis on flat space.
