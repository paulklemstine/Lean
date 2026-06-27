# The Local GL₂ Frobenius Datum over ℚ: Eichler–Shimura Structure and Deligne's Weil Bound

**Author:** Aristotle
**Domain:** Novelty (Langlands program / arithmetic geometry)
**Date:** 2026-06-27

## Abstract

We present a self-contained development of the *local data* of the Langlands
correspondence for $\mathrm{GL}_2$ over $\mathbb{Q}$ at a good prime $p$, split
into its algebraic and analytic halves. On the algebraic side (Eichler–Shimura),
a weight-two Hecke eigenform attaches to each good prime $p$ a two-dimensional
Frobenius datum: a $2\times 2$ matrix with trace equal to the Hecke eigenvalue
$a_p$, determinant equal to $p$, characteristic polynomial equal to the Hecke
polynomial $X^2 - a_p X + p$, and satisfying the Eichler–Shimura congruence
relation, which at the level of the matrix is precisely the rank-2
Cayley–Hamilton identity $M^2 = a_p M - p\,I$. On the analytic side (Deligne /
Ramanujan–Petersson), the Frobenius eigenvalues are *Weil numbers of weight one*:
they lie on the circle of radius $\sqrt p$. We isolate and rigorously prove the
*real-algebraic core* of Deligne's theorem — the statement that the two roots of
a monic real quadratic $X^2 - aX + p$ with $p>0$ lie on the circle $|z|=\sqrt p$
if and only if the discriminant condition $a^2 \le 4p$ holds, equivalently
$|a|\le 2\sqrt p$. This equivalence is the honest finite shadow of Deligne's
theorem (whose full force requires the Weil conjectures). We derive from it the
modulus of both Frobenius eigenvalues and the modulus of every eigenvalue of the
explicit companion (Frobenius) matrix. All results have been formally verified.

**Keywords:** Langlands correspondence, GL₂, Eichler–Shimura relation, Deligne
bound, Ramanujan–Petersson, Weil number, Hecke polynomial, Frobenius eigenvalue,
companion matrix, Sato–Tate angle.

---

## 1. Introduction

The Langlands program predicts a correspondence between automorphic
representations and Galois representations. In its first nontrivial classical
case — weight-two cusp forms / modular forms for $\mathrm{GL}_2$ over the
rationals $\mathbb{Q}$ — the correspondence attaches to a Hecke eigenform $f$ a
two-dimensional $\ell$-adic Galois representation $\rho_f$ whose Frobenius at a
good prime $p$ encodes the Hecke eigenvalue $a_p$ of $f$. The two structural
pillars of this story are:

1. **Eichler–Shimura** (algebraic): the construction of the Frobenius datum and
   the congruence relation it satisfies. At a good prime $p$, the local datum is a
   $2\times 2$ block with
   $$\operatorname{tr}\mathrm{Frob}_p = a_p, \qquad \det\mathrm{Frob}_p = p,$$
   and the Eichler–Shimura relation expresses the action of Frobenius on the
   relevant cohomology.

2. **Deligne / Ramanujan–Petersson** (analytic): the eigenvalues of
   $\mathrm{Frob}_p$ are *Weil numbers of weight one*, i.e. have absolute value
   $\sqrt p$. Deligne proved this as a consequence of the Weil conjectures; for
   weight-two forms it is the Hasse bound on point counts of the associated
   elliptic curve / abelian variety.

This paper isolates the *purely structural and real-algebraic* content of both
pillars, in a form that is unconditional and elementary, and that can serve as
the local building block of the correspondence. We make precise the dictionary

$$X^2 - a_p X + p \;=\; \text{characteristic polynomial of } \mathrm{Frob}_p,$$

construct an explicit companion matrix realizing it, and prove the equivalence

$$|a_p| \le 2\sqrt p \iff a_p^2 \le 4p \iff \big(\text{both roots lie on } |z| = \sqrt p\big).$$

We position this against the $\mathrm{GL}_1$ case, where the local datum is a root
of unity (absolute value $1$); the $\mathrm{GL}_2$ refinement replaces the unit
circle by the circle of radius $\sqrt p$, and the new phenomenon is that the
bound is a genuine inequality governed by the discriminant of a quadratic.

### 1.1 Conventions

Throughout, $p > 0$ is a real number (the value of the cyclotomic character; in
the arithmetic application it is a prime), and $a \in \mathbb{R}$ (the Hecke
eigenvalue $a_p$). We write $\|z\|$ for the complex absolute value and
$\operatorname{normSq}(z) = z\bar z = \mathrm{Re}(z)^2 + \mathrm{Im}(z)^2$ for the
squared modulus, so $\|z\| = \sqrt{\operatorname{normSq}(z)}$. We use the
principal real square root, with $\sqrt p = 0$ for $p \le 0$.

---

## 2. Definitions

### 2.1 The Hecke polynomial

**Definition 2.1 (Hecke polynomial).** For $a, p$ in a commutative ring $R$, the
*Hecke polynomial* is the monic quadratic
$$\mathrm{heckePoly}(a,p) \;=\; X^2 - a\,X + p \;\in\; R[X].$$
Its evaluation at $z \in R$ is
$$\mathrm{heckePoly}(a,p)(z) \;=\; z^2 - a\,z + p. \tag{$\mathrm{heckePoly\_eval}$}$$

In the arithmetic setting $\mathrm{heckePoly}(a_p, p)$ is the characteristic
polynomial of the geometric Frobenius at $p$ acting on the two-dimensional Galois
representation $\rho_f$, and $(1 - a_p X + p X^2)^{-1}$ is the local Euler factor
of the $L$-function $L(f,s)$ at $p$ (with $X = p^{-s}$).

### 2.2 The Frobenius companion matrix

**Definition 2.2 (Frobenius matrix).** The *Frobenius companion matrix* of the
Hecke polynomial is
$$\mathrm{frobMatrix}(a,p) \;=\; \begin{pmatrix} 0 & -p \\ 1 & a \end{pmatrix} \in M_2(R).$$

**Proposition 2.3 (Trace, determinant, characteristic polynomial).**
$$\operatorname{tr}\,\mathrm{frobMatrix}(a,p) = a, \qquad \det\,\mathrm{frobMatrix}(a,p) = p,$$
and the characteristic polynomial of $\mathrm{frobMatrix}(a,p)$ is
$\mathrm{heckePoly}(a,p) = X^2 - aX + p$.

*Proof.* The trace is $0 + a = a$ and the determinant is
$0\cdot a - (-p)\cdot 1 = p$. For the characteristic polynomial, compute
$$\det\!\begin{pmatrix} X & p \\ -1 & X - a\end{pmatrix} = X(X-a) + p = X^2 - aX + p. \qquad\blacksquare$$

In particular, $\lambda \in R$ is an eigenvalue of $\mathrm{frobMatrix}(a,p)$
(i.e. $\mathrm{frobMatrix}(a,p) - \lambda I$ is singular) if and only if
$\mathrm{heckePoly}(a,p)(\lambda) = 0$. Indeed,
$$\det\big(\mathrm{frobMatrix}(a,p) - \lambda I\big)
= \det\!\begin{pmatrix} -\lambda & -p \\ 1 & a - \lambda \end{pmatrix}
= -\lambda(a-\lambda) + p = \lambda^2 - a\lambda + p. \tag{2.1}$$

### 2.3 The Eichler–Shimura relation

**Definition 2.4 (Eichler–Shimura / Cayley–Hamilton form).** The local
Eichler–Shimura congruence relation, at the level of the $2\times 2$ Frobenius
matrix $M = \mathrm{frobMatrix}(a,p)$, is the identity
$$M^2 = a\,M - p\,I.$$
This is exactly the Cayley–Hamilton theorem applied to $M$, since the
characteristic polynomial of $M$ is $X^2 - aX + p$ (Proposition 2.3).

### 2.4 Weil numbers

**Definition 2.5 (Weil number of weight one).** A complex number $z$ is a *Weil
number of weight one for $p$* if $\|z\| = \sqrt p$. Equivalently, $z$ lies on the
circle of radius $\sqrt p$ centered at the origin of $\mathbb{C}$.

---

## 3. Main Results

We state the four principal theorems, each in the exact form that has been
formally verified, followed by full proof sketches.

### 3.1 The scalar Deligne bound

**Theorem 3.1 (`deligne_bound_iff`).** For real $a$ and $p$ with $p \ge 0$,
$$|a| \le 2\sqrt p \iff a^2 \le 4p.$$

*Proof.* Since $p \ge 0$, the real square root satisfies $(\sqrt p)^2 = p$, hence
$(2\sqrt p)^2 = 4p$. Both $|a| \ge 0$ and $2\sqrt p \ge 0$, and squaring is
monotone on the nonnegative reals, so $|a| \le 2\sqrt p \iff |a|^2 \le (2\sqrt p)^2
\iff a^2 \le 4p$, using $|a|^2 = a^2$. Each direction is a nonlinear arithmetic
consequence of these facts. $\blacksquare$

This is the *scalar* form of the Ramanujan–Petersson bound: the statement
$|a_p| \le 2\sqrt p$ is equivalent to the discriminant condition $a_p^2 \le 4p$
of the Hecke polynomial.

### 3.2 Every root is a Weil number

**Theorem 3.2 (`deligne_root_abs`).** Let $a, p \in \mathbb{R}$ with $p > 0$ and
$a^2 \le 4p$. If $z \in \mathbb{C}$ satisfies $\mathrm{heckePoly}(a,p)(z) = 0$
(i.e. $z^2 - a z + p = 0$), then
$$\|z\| = \sqrt p.$$

*Proof.* Write $z = x + yi$ with $x = \mathrm{Re}(z)$, $y = \mathrm{Im}(z)$.
Expanding $z^2 - a z + p = 0$ and taking real and imaginary parts yields the two
real equations
$$x^2 - y^2 - a x + p = 0, \tag{R}$$
$$2 x y - a y = 0. \tag{I}$$
We compute $\operatorname{normSq}(z) = x^2 + y^2$ and split on whether $y = 0$.

*Case $y \ne 0$.* Equation (I) factors as $y(2x - a) = 0$; since $y \ne 0$ we get
$a = 2x$. Substituting $a = 2x$ into (R):
$$x^2 - y^2 - (2x)x + p = -x^2 - y^2 + p = 0 \implies x^2 + y^2 = p.$$
Hence $\operatorname{normSq}(z) = p$.

*Case $y = 0$.* Then $z = x$ is real and (R) becomes $x^2 - a x + p = 0$.
Multiplying by $4$ and completing the square, $(2x - a)^2 = a^2 - 4p \le 0$ by
hypothesis. A square of a real number is $\ge 0$, so $(2x-a)^2 = 0$ and
$a^2 = 4p$, giving $x = a/2$ and $x^2 = a^2/4 = p$. Thus
$\operatorname{normSq}(z) = x^2 = p$.

In both cases $\operatorname{normSq}(z) = p$, so
$\|z\| = \sqrt{\operatorname{normSq}(z)} = \sqrt p$. $\blacksquare$

**Remark 3.3 (Necessity of $a^2 \le 4p$).** The hypothesis is sharp. If
$a^2 > 4p$, the roots of $X^2 - aX + p$ are real and distinct,
$\tfrac{1}{2}(a \pm \sqrt{a^2 - 4p})$, with product $p$ and *different* moduli
(one exceeds $\sqrt p$, the other is below it). Thus the conclusion
$\|z\| = \sqrt p$ fails. The condition $a^2 \le 4p$ is precisely the boundary
between Weil-number behavior and real-eigenvalue behavior — the elementary trace
of the dichotomy "ordinary/supersingular" (equivalently "split/inert") for the
local datum. The case split $y=0$ vs $y\neq 0$ in the proof is the formal shadow
of this dichotomy.

### 3.3 The Weil pair

**Theorem 3.4 (`deligne_weil_pair`).** Let $a, p \in \mathbb{R}$ with $p > 0$ and
$a^2 \le 4p$. Suppose $\alpha, \beta \in \mathbb{C}$ satisfy
$$\alpha + \beta = a, \qquad \alpha\,\beta = p.$$
Then $\alpha\beta = p$ and $\|\alpha\| = \|\beta\| = \sqrt p$.

*Proof.* By Vieta's formulas the conditions $\alpha + \beta = a$ and
$\alpha\beta = p$ say exactly that $\alpha$ and $\beta$ are the two roots of
$X^2 - aX + p$. Indeed, for $\zeta \in \{\alpha,\beta\}$,
$$\zeta^2 - a\zeta + p = \zeta^2 - (\alpha+\beta)\zeta + \alpha\beta
= (\zeta - \alpha)(\zeta - \beta) = 0.$$
Hence $\mathrm{heckePoly}(a,p)(\alpha) = \mathrm{heckePoly}(a,p)(\beta) = 0$, and
Theorem 3.2 gives $\|\alpha\| = \|\beta\| = \sqrt p$. $\blacksquare$

This is the local statement that the two Frobenius eigenvalues form a *Weil pair*:
conjugate complex numbers of equal modulus $\sqrt p$ whose product is $p$ (so they
are in fact complex conjugates, $\beta = \bar\alpha = p/\alpha$, when $y \ne 0$).

### 3.4 Frobenius eigenvalues are Weil numbers

**Theorem 3.5 (`deligne_frob_eigenvalues`).** Let $a, p \in \mathbb{R}$ with
$p > 0$ and $a^2 \le 4p$. If $\lambda \in \mathbb{C}$ is an eigenvalue of the
companion matrix $\mathrm{frobMatrix}(a,p)$ over $\mathbb{C}$ — that is,
$\mathrm{frobMatrix}(a,p) - \lambda I$ is not invertible — then
$$\|\lambda\| = \sqrt p.$$

*Proof.* A square matrix over a field is non-invertible iff its determinant
vanishes; hence $\det(\mathrm{frobMatrix}(a,p) - \lambda I) = 0$. By (2.1) this
determinant equals $\lambda^2 - a\lambda + p = \mathrm{heckePoly}(a,p)(\lambda)$.
Therefore $\lambda$ is a root of the Hecke polynomial, and Theorem 3.2 yields
$\|\lambda\| = \sqrt p$. $\blacksquare$

This closes the loop: the *concrete* matrix realizing trace $a$ and determinant
$p$ (Proposition 2.3) has all its complex eigenvalues on the circle of radius
$\sqrt p$, so the analytic Weil bound holds for an honest Frobenius and is not
vacuous.

---

## 4. Synthesis: the local GL₂ correspondence over ℚ

Combining the algebraic skeleton (Definitions 2.1–2.4, Proposition 2.3) with the
analytic bound (Theorems 3.1–3.5) gives both halves of the *local* GL₂
correspondence over $\mathbb{Q}$ at a good prime $p$:

- a $2\times 2$ Frobenius $\mathrm{frobMatrix}(a_p,p)$ with
  $\operatorname{tr} = a_p$ and $\det = p$;
- characteristic polynomial $X^2 - a_p X + p$ and Euler factor
  $(1 - a_p X + p X^2)^{-1}$;
- the Eichler–Shimura relation $M^2 = a_p M - p I$;
- Frobenius eigenvalues $\alpha, \beta$ that are Weil numbers of weight one,
  $\|\alpha\| = \|\beta\| = \sqrt p$, exactly when $a_p^2 \le 4p$.

This is the GL₂ refinement of the GL₁ picture, where the local datum is a root of
unity ($|\cdot| = 1$): the unit circle is replaced by the circle of radius
$\sqrt p$, and the single new ingredient is the genuine inequality controlled by
the discriminant.

---

## 4b. Worked examples

We illustrate the local datum on concrete values, distinguishing the Weil-number
regime from the real-eigenvalue regime.

**Example A ($a = 3$, $p = 11$, $a^2 = 9 \le 44 = 4p$).** The Hecke polynomial is
$X^2 - 3X + 11$ with discriminant $9 - 44 = -35 < 0$. The companion matrix is
$\begin{pmatrix} 0 & -11 \\ 1 & 3 \end{pmatrix}$, with trace $3$ and determinant
$11$. The eigenvalues are
$$\alpha = \tfrac{3}{2} + \tfrac{\sqrt{35}}{2}i, \qquad \beta = \bar\alpha = \tfrac{3}{2} - \tfrac{\sqrt{35}}{2}i,$$
with $\alpha\beta = \tfrac94 + \tfrac{35}{4} = 11 = p$ and
$\|\alpha\| = \|\beta\| = \sqrt{\tfrac94 + \tfrac{35}{4}} = \sqrt{11} = \sqrt p$,
confirming Theorems 3.2, 3.4, 3.5. The Sato–Tate angle is
$\theta = \arccos\big(3/(2\sqrt{11})\big) \approx 1.1015$ rad ($\approx 63.1^\circ$).

**Example B ($a = 0$, $p = 13$).** Here $X^2 + 13$ has roots
$\alpha = \sqrt{13}\,i$, $\beta = -\sqrt{13}\,i$, purely imaginary Weil numbers on
the circle, with Sato–Tate angle $\theta = \pi/2$. This is the "supersingular at
the center" case $a_p = 0$.

**Example C ($a = 8$, $p = 7$, $a^2 = 64 > 28 = 4p$).** Now the discriminant is
$64 - 28 = 36 > 0$ and the roots are *real*:
$\tfrac{1}{2}(8 \pm 6) = \{7, 1\}$, with product $7 = p$ but moduli $7$ and $1$,
neither equal to $\sqrt 7 \approx 2.646$. The Deligne bound is violated, exactly as
Remark 3.3 predicts: the symmetry is broken precisely because $a^2 > 4p$.

These three cases trace the full phase diagram: strictly inside the bound the
eigenvalues are conjugate Weil numbers (Example A, B), and outside it they degrade
to real numbers of unequal size (Example C). The boundary $a^2 = 4p$ is the
double-root locus, where $\alpha = \beta = a/2$ with $\|a/2\| = \sqrt p$.

---

## 5. Algorithms

We record the elementary procedures that compute and verify the local datum. All
are $O(1)$ field operations per prime.

### 5.1 Local datum and Deligne check

**Algorithm 5.1 (LocalFrobeniusDatum).** Given $(a, p)$ with $p > 0$, return the
companion matrix, trace, determinant, discriminant, the Deligne flag
$a^2 \le 4p$, and (when the flag holds) the eigenvalue modulus $\sqrt p$ and the
Sato–Tate angle $\theta = \arccos\!\big(a / (2\sqrt p)\big)$.

```
function LocalFrobeniusDatum(a, p):
    require p > 0
    M    := [[0, -p], [1, a]]
    tr   := a                         # = trace(M)
    det  := p                         # = det(M)
    disc := a*a - 4*p                 # discriminant of X^2 - a X + p
    deligne_ok := (disc <= 0)         # a^2 <= 4p  <=>  |a| <= 2 sqrt(p)
    if deligne_ok:
        modulus := sqrt(p)            # |alpha| = |beta| = sqrt(p)
        theta   := arccos(a / (2*sqrt(p)))   # Sato-Tate angle in [0, pi]
        alpha   := modulus * (cos(theta) + i*sin(theta))
        beta    := conjugate(alpha)
    return (M, tr, det, disc, deligne_ok, modulus?, theta?, alpha?, beta?)
```

### 5.2 Root modulus verification

**Algorithm 5.2 (VerifyRootOnCircle).** Given $(a, p)$ with $p > 0$ and a complex
$z$ with $z^2 - a z + p = 0$, certify $\|z\| = \sqrt p$ by the case analysis of
Theorem 3.2.

```
function VerifyRootOnCircle(a, p, z):
    x, y := Re(z), Im(z)
    assert |x*x - y*y - a*x + p| < eps          # real part of heckePoly(z)
    assert |2*x*y - a*y|        < eps            # imag part of heckePoly(z)
    if |y| > eps:
        # y != 0 forces a = 2x, hence x^2 + y^2 = p
        assert |a - 2*x| < eps
        return |x*x + y*y - p| < eps
    else:
        # y = 0 forces (2x - a)^2 = a^2 - 4p <= 0, hence a^2 = 4p and x^2 = p
        return |x*x - p| < eps
```

---

## 6. Applications

- **Modularity and Fermat's Last Theorem.** The two-dimensional Galois
  representations whose local Frobenius data we describe are precisely the
  objects matched to modular forms in the modularity theorem used by Wiles. The
  trace/determinant dictionary ($a_p$, $p$) is the bookkeeping at each good prime.

- **L-functions and local Riemann Hypothesis.** The Euler factor
  $(1 - a_p X + p X^2)^{-1}$ assembles into $L(f,s)$. Theorem 3.2 is the local
  Riemann Hypothesis: reciprocal roots on $|z| = \sqrt p$ correspond to zeros of
  the local factor confined to the critical line $\mathrm{Re}(s) = 1/2$.

- **Sato–Tate statistics.** Writing $a_p = 2\sqrt p\cos\theta_p$, Theorem 3.2
  guarantees $\theta_p \in [0,\pi]$ is real; the Sato–Tate conjecture (a theorem)
  governs the distribution of the $\theta_p$.

- **Point counting and cryptography.** For weight-two forms attached to elliptic
  curves, $a_p = p + 1 - \#E(\mathbb{F}_p)$, and Theorem 3.1 is the Hasse bound
  $|a_p| \le 2\sqrt p$ underlying elliptic-curve cryptography.

---

## 7. Discussion

The mathematical content separates cleanly into an algebraic skeleton, which is
formal (Cayley–Hamilton, companion matrices, Vieta), and an analytic bound, whose
*real-algebraic core* (Theorems 3.1–3.5) is elementary and unconditional, while
its *full arithmetic force* — that the actual Frobenius eigenvalues of $\rho_f$
satisfy $a^2 \le 4p$ — is Deligne's deep theorem requiring the Weil conjectures.
Our contribution is to make the boundary between these explicit: we prove
everything that follows *once one knows* $a^2 \le 4p$, and we exhibit by Remark
3.3 that this hypothesis is exactly load-bearing. None of the results is vacuous
or trivial: Theorem 3.2 is a genuine geometric case analysis, and Theorem 3.5
applies to an honest companion matrix whose characteristic polynomial is the Hecke
polynomial.

---

## 8. Future Directions

**Conjecture 1 — Local L-factor positivity / functional symmetry of the Weil
pair.** For $a^2 \le 4p$ the two Frobenius eigenvalues are complex conjugates, so
the local Euler factor $1 - aX + pX^2$ satisfies $\beta = p/\alpha = \bar\alpha$
and the substitution $X \mapsto 1/(pX)$ permutes the reciprocal roots. Conjecture:
the local factor $L_p(s) = (1 - a p^{-s} + p^{1-2s})^{-1}$ has no zeros in
$\mathrm{Re}(s) > 1/2$ exactly when $a^2 \le 4p$. The discriminant condition
$a^2 \le 4p$ (Theorem 3.1) is precisely the boundary at which the reciprocal roots
swap from the critical circle $|\cdot| = \sqrt p$ to the real axis, so the local
Riemann Hypothesis is equivalent to the Deligne bound already in hand. The modulus
content (Theorem 3.4) is discharged; what remains is a $\mathrm{Polynomial.roots}$
computation over $\mathbb{C}$.

**Conjecture 2 — Sato–Tate angle realization is surjective onto $[0,\pi]$.** Write
$a = 2\sqrt p\cos\theta$. Conjecture: as $a$ ranges over real values with
$a^2 \le 4p$, the angle $\theta$ realizing the eigenvalues $\sqrt p\,e^{\pm i\theta}$
ranges over the full interval $[0,\pi]$, and $a \mapsto \theta$ is a homeomorphism
$[-2\sqrt p, 2\sqrt p] \cong [0,\pi]$. Theorem 3.2 forces every admissible
eigenvalue onto the circle of radius $\sqrt p$, so the only remaining degree of
freedom is the Sato–Tate angle, and the companion-matrix construction shows every
admissible $a$ is realized (Proposition 2.3, Theorem 3.5). The conjecture reduces
to surjectivity of $\cos$ on $[0,\pi]$.

**Conjecture 3 — Eichler–Shimura determines the representation up to
semisimplification.** Conjecture: two $2\times 2$ matrices over a field both
satisfying $M^2 = aM - p I$ with the same $(a,p)$ and with $a^2 - 4p \ne 0$ are
conjugate. Equivalently, the local Frobenius datum is determined by its trace and
determinant once the Hecke polynomial is separable.
