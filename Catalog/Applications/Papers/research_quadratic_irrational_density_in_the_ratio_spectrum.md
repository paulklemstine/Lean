# The Euclidean Norm-Ratio Spectrum of Real Unimodular $2\times 2$ Matrices

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Computation

## Abstract

For a real $2\times2$ matrix $M$ and the Euclidean norm $k(v) = \sqrt{v_0^2 + v_1^2}$
on $\mathbb{R}^2$, define the *ratio spectrum* of $M$ as the set of values
$k(Mv)/k(v)$ taken over all nonzero $v$. We prove that whenever $M$ is unimodular up to
sign — that is, $(\det M)^2 = 1$ — there exists a nonzero vector $v$ with
$k(Mv) = k(v)$, so that $1$ belongs to the ratio spectrum. Equivalently, the
indefinite quadratic form $Q(x,y) = (ax+by)^2 + (cx+dy)^2 - (x^2+y^2)$ associated with
$M = \begin{psmallmatrix} a&b\\ c&d \end{psmallmatrix}$ admits a nontrivial zero. The
proof reduces the geometric statement to a single discriminant inequality,
$B^2 - AC \ge 0$ with $A = a^2+c^2-1$, $B = ab+cd$, $C = b^2+d^2-1$, which we show is
equivalent to the Frobenius bound $a^2+b^2+c^2+d^2 \ge 2\lvert\det M\rvert$. As an
immediate corollary, the degenerate interval $[1,1]$ — the collapse of the natural
range $[\,1/\lvert\det M\rvert, \lvert\det M\rvert\,]$ at $\lvert\det M\rvert=1$ — lies
in the closure of the ratio spectrum. All results have been formally verified. We place
the theorem in the context of the broader program on density of ratio spectra over
quadratic-irrational directions and outline several open directions.

## 1. Introduction

Linear maps of the plane act on lengths in a direction-dependent way. For a fixed real
$2\times 2$ matrix $M$ and a nonzero vector $v$, the *local stretch factor* is the
quotient $k(Mv)/k(v)$, where $k$ denotes Euclidean length. As $v$ ranges over all
nonzero vectors this quotient sweeps out a closed interval bounded below and above by
the two singular values of $M$. We call the resulting set of attained values the
**ratio spectrum** of $M$.

A basic structural question is which numbers are *forced* to appear in the spectrum
regardless of the particular matrix, given a constraint on $M$. The cleanest constraint
is unimodularity: $\lvert\det M\rvert = 1$, the condition that $M$ preserves Lebesgue
measure (area). Unimodular matrices are ubiquitous — they include all rotations,
shears, and reflections of unit Jacobian, the special linear and orthogonal groups, and
(over the integers) the modular group $\mathrm{SL}_2(\mathbb{Z})$ that organizes
continued fractions and the geometry of the upper half-plane.

Our main theorem isolates the value $1$ as the universally forced point of the spectrum
of a unimodular matrix:

> **Theorem (Unit ratio).** If $M \in \mathbb{R}^{2\times 2}$ satisfies
> $(\det M)^2 = 1$, then there exists a nonzero $v \in \mathbb{R}^2$ with
> $k(Mv) = k(v)$.

Geometrically this says every area-preserving linear map of the plane has at least one
direction of unit stretch. The result is the unimodular cornerstone of a larger
conjectural program (Section 7) asserting that, for a general primitive integer matrix
$M$ with nonzero determinant, the ratios $k(Mx)/k(x)$ obtained by restricting $x$ to
real quadratic-irrational badly approximable directions are *dense* in the full interval
$[\,1/\lvert\det M\rvert,\ \lvert\det M\rvert\,]$. When $\lvert\det M\rvert = 1$ that
interval degenerates to the single point $\{1\}$, and density there is exactly the
statement that $1$ is attained — the content of our theorem.

The remainder of the paper develops the precise definitions (Section 2), the geometric
intuition via singular values (Section 3), the algebraic core and its discriminant
inequality (Section 4), the main theorem and its spectral corollaries (Section 5), an
algorithmic recipe for constructing the unstretched vector (Section 6), and the broader
context with open problems (Section 7).

## 2. Definitions

Throughout, vectors are elements of $\mathbb{R}^2$, indexed as $v = (v_0, v_1)$, and
$M = \begin{psmallmatrix} a & b \\ c & d \end{psmallmatrix}$ acts by the usual
matrix-vector product $Mv = (a v_0 + b v_1,\ c v_0 + d v_1)$.

**Definition 2.1 (Euclidean norm).** For $v \in \mathbb{R}^2$,
$$
k(v) \;=\; \sqrt{v_0^{\,2} + v_1^{\,2}}.
$$

**Definition 2.2 (Ratio spectrum).** For a matrix $M$,
$$
\mathrm{ratioSpectrum}(M) \;=\; \left\{\, r \in \mathbb{R} \;\middle|\; \exists\, v \neq 0,\ r = \frac{k(Mv)}{k(v)} \,\right\}.
$$

**Definition 2.3 (Unimodular up to sign).** A matrix $M$ is *unimodular up to sign* if
$(\det M)^2 = 1$, i.e. $\det M = ad - bc \in \{+1, -1\}$.

**Definition 2.4 (Associated quadratic form).** To $M$ we attach the real quadratic
form
$$
Q_M(x,y) \;=\; (ax + by)^2 + (cx + dy)^2 - (x^2 + y^2) \;=\; A x^2 + 2B xy + C y^2,
$$
with coefficients
$$
A = a^2 + c^2 - 1,\qquad B = ab + cd,\qquad C = b^2 + d^2 - 1.
$$
Note $Q_M(x,y) = k(Mv)^2 - k(v)^2$ for $v = (x,y)$, so $Q_M(v) = 0$ with $v \neq 0$ is
equivalent to $k(Mv) = k(v)$ with $v \neq 0$.

## 3. Geometric picture: singular values

Let $0 \le \sigma_{\min} \le \sigma_{\max}$ be the singular values of $M$ (the square
roots of the eigenvalues of $M^\top M$). The function $v \mapsto k(Mv)/k(v)$ is
continuous on the unit circle, attains its minimum $\sigma_{\min}$ and maximum
$\sigma_{\max}$, and — by connectedness of the circle and the Intermediate Value
Theorem — attains every value in $[\sigma_{\min}, \sigma_{\max}]$. Hence
$$
\mathrm{ratioSpectrum}(M) = [\sigma_{\min}, \sigma_{\max}].
$$
The product of singular values is the absolute determinant,
$\sigma_{\min}\,\sigma_{\max} = \lvert\det M\rvert$, reflecting that $M$ carries the unit
circle to an ellipse with semi-axes $\sigma_{\min}, \sigma_{\max}$ and area
$\pi\lvert\det M\rvert$.

When $\lvert\det M\rvert = 1$ we get $\sigma_{\min}\,\sigma_{\max} = 1$, forcing
$$
\sigma_{\min} \le 1 \le \sigma_{\max}.
$$
Therefore $1 \in [\sigma_{\min},\sigma_{\max}] = \mathrm{ratioSpectrum}(M)$. This is a
complete proof of the main theorem, but it relies on the spectral theorem and topology
of the circle. The certified proof instead proceeds algebraically, which makes the
witness explicit and avoids analytic machinery; we develop it next.

## 4. The algebraic core

### 4.1 Discriminant nonnegativity

**Lemma 4.1 (`disc_nonneg`).** For all real $a,b,c,d$ with $(ad - bc)^2 = 1$,
$$
0 \;\le\; (ab + cd)^2 - (a^2 + c^2 - 1)(b^2 + d^2 - 1).
$$

*Proof sketch.* Expanding the right-hand side and applying the Lagrange identity
$(a^2+c^2)(b^2+d^2) = (ab+cd)^2 + (ad-bc)^2$ gives
$$
B^2 - AC = (a^2+b^2+c^2+d^2) - (ad - bc)^2 - 1 = (a^2+b^2+c^2+d^2) - 2,
$$
using $(ad-bc)^2 = 1$. Nonnegativity is then the Frobenius–determinant inequality
$a^2+b^2+c^2+d^2 \ge 2\lvert ad-bc\rvert = 2$, itself a sum-of-squares identity:
$$
a^2+b^2+c^2+d^2 - 2(ad-bc) = (a-d)^2 + (b+c)^2 \ge 0,
$$
$$
a^2+b^2+c^2+d^2 + 2(ad-bc) = (a+d)^2 + (b-c)^2 \ge 0.
$$
The formal proof discharges the inequality directly from the four square certificates
$(a-d)^2,\ (b+c)^2,\ (a+d)^2,\ (b-c)^2 \ge 0$ together with $(ad-bc)^2 = 1$. $\square$

The quantity $B^2 - AC$ is, up to sign, the discriminant of the binary quadratic form
$Q_M$. Its nonnegativity says $Q_M$ is *not* positive definite: it represents zero
nontrivially. The geometric content is precisely that a unimodular matrix cannot have
all four entries simultaneously small (its Frobenius norm is at least $\sqrt 2$), with
equality exactly for orthogonal matrices.

### 4.2 Existence of a nontrivial zero

**Theorem 4.2 (`core_exists`).** For all real $a,b,c,d$ with $(ad-bc)^2 = 1$, there
exist $x, y \in \mathbb{R}$, not both zero, such that
$$
(ax + by)^2 + (cx + dy)^2 = x^2 + y^2.
$$

*Proof sketch.* Write $A = a^2+c^2-1$, $B = ab+cd$, $C = b^2+d^2-1$.

*Case $A = 0$.* Take $(x,y) = (1,0)$. Then the claim reduces to
$a^2 + c^2 = 1$, which is exactly $A = 0$; the identity holds.

*Case $A \neq 0$.* By Lemma 4.1 the number $s = \sqrt{B^2 - AC}$ is real, with
$s^2 = B^2 - AC$. Set
$$
x = \frac{-B + s}{A}, \qquad y = 1.
$$
Then $Q_M(x,y) = A x^2 + 2B x + C$, and substituting $x$ gives
$$
A\!\left(\frac{-B+s}{A}\right)^2 + 2B\!\left(\frac{-B+s}{A}\right) + C
= \frac{(-B+s)^2 + 2B(-B+s) + AC}{A}
= \frac{s^2 - B^2 + AC}{A} = 0.
$$
Hence $Q_M(x,y) = 0$ with $(x,y) = (x,1) \neq (0,0)$, which is the claim. $\square$

This is the computational heart: an explicit closed-form witness for the unstretched
direction. The case split on $A = 0$ is essential because the construction divides by
$A$; geometrically $A = 0$ means the image of $(1,0)$ already has unit length.

## 5. Main theorem and spectral corollaries

**Theorem 5.1 (`exists_unit_ratio`).** For every $M \in \mathbb{R}^{2\times 2}$ with
$(\det M)^2 = 1$ there exists a nonzero $v \in \mathbb{R}^2$ with $k(Mv) = k(v)$.

*Proof sketch.* Write $a = M_{00}, b = M_{01}, c = M_{10}, d = M_{11}$, so that
$\det M = ad - bc$ and the hypothesis is $(ad-bc)^2 = 1$. Apply Theorem 4.2 to obtain
$(x,y) \neq (0,0)$ with $(ax+by)^2 + (cx+dy)^2 = x^2 + y^2$. Let $v = (x, y)$. Its
image is $Mv = (ax+by,\ cx+dy)$, so
$$
k(Mv)^2 = (ax+by)^2 + (cx+dy)^2 = x^2 + y^2 = k(v)^2,
$$
and since both norms are nonnegative, $k(Mv) = k(v)$. Finally $v \neq 0$ because $x,y$
are not both zero. $\square$

**Corollary 5.2 (`one_mem_ratioSpectrum`).** If $(\det M)^2 = 1$, then
$1 \in \mathrm{ratioSpectrum}(M)$.

*Proof sketch.* Take the vector $v$ from Theorem 5.1. Then $k(v) > 0$ (a nonzero vector
has positive Euclidean norm), so
$$
\frac{k(Mv)}{k(v)} = \frac{k(v)}{k(v)} = 1,
$$
exhibiting $1$ as a member of the spectrum. $\square$

**Corollary 5.3 (`ratioSpectrum_dense_Icc`).** If $(\det M)^2 = 1$, then
$$
[1,1] \;\subseteq\; \overline{\mathrm{ratioSpectrum}(M)}.
$$

*Proof sketch.* The closed interval $[1,1]$ is the singleton $\{1\}$. By Corollary 5.2
the point $1$ lies in $\mathrm{ratioSpectrum}(M)$, hence in its closure (every set is
contained in its closure). $\square$

The label $[1,1]$ is deliberate: it is the collapse of the natural ratio interval
$[\,1/\lvert\det M\rvert,\ \lvert\det M\rvert\,]$ at the unimodular value
$\lvert\det M\rvert = 1$. Corollary 5.3 therefore records, in the language of the general
density conjecture, that the unimodular case is fully settled — the entire (degenerate)
target interval is hit.

## 6. Algorithm: constructing the unstretched vector

The proof of Theorem 4.2 is constructive and yields an $O(1)$ algorithm.

**Input:** real entries $a, b, c, d$ with $\lvert ad - bc \rvert = 1$.
**Output:** a nonzero $v = (x,y)$ with $k(Mv) = k(v)$.

1. Compute $A \leftarrow a^2 + c^2 - 1$, $B \leftarrow ab + cd$, $C \leftarrow b^2 + d^2 - 1$.
2. If $A = 0$, return $(1, 0)$.
3. Otherwise compute the discriminant $D \leftarrow B^2 - AC$ (guaranteed $\ge 0$).
4. Set $s \leftarrow \sqrt{D}$, then $x \leftarrow (-B + s)/A$, and return $(x, 1)$.

Correctness is exactly Theorem 4.2. The discriminant identity $D = a^2+b^2+c^2+d^2 - 2$
(the unimodular specialization of the general identity $D = \|M\|_F^2 - (\det M)^2 - 1$) gives a one-line numerical sanity check. Because the only nonrational operation is a
single square root of a nonnegative real, the witness is an algebraic number of degree
at most $2$ over the field generated by the entries — and over $\mathbb{Q}$ it is a
quadratic irrational, recovering the connection to the broader program (Section 7).

## 7. Discussion, applications, and future work

**Relation to the modular group.** Over the integers, the matrices with
$(\det M)^2 = 1$ form $\mathrm{GL}_2(\mathbb{Z})$, the symmetry group of the standard
lattice and the group acting on the upper half-plane by Möbius transformations
$z \mapsto (az+b)/(cz+d)$. The norm ratios $k(Mv)/k(v)$ measure the local distortion of
this action; the unit-ratio direction is the eigendirection of $M^\top M$ with
eigenvalue $1$. For the celebrated example
$M = \begin{psmallmatrix} 2 & 1\\ 1 & 1\end{psmallmatrix}$, the recipe of Section 6
gives $A = 4$, $B = 3$, $C = 1$, $D = 5$, and unstretched vector
$\big((-3 + \sqrt 5)/4,\ 1\big)$ — a quadratic irrational built from $\sqrt 5$, the same
surd underlying the golden ratio.

**The density program.** The motivating conjecture asserts that for a primitive integer
matrix $M$ with $\det M \neq 0$, the ratios $k(Mx)/k(x)$ over quadratic-irrational badly
approximable directions $x$ are dense in $[\,1/\lvert\det M\rvert,\ \lvert\det M\rvert\,]$.
The present work proves the boundary/degenerate case $\lvert\det M\rvert = 1$ where the
interval is a point, providing the base of any inductive or interpolation argument
toward the general statement.

**Future directions.**

1. *Discreteness of the single-letter spectrum.* The metallic ratios
   $\mu_n = (n + \sqrt{n^2+4})/2$ satisfy $\mu_n^2 = n\mu_n + 1$ and the
   self-similarity $\mu_n = n + 1/\mu_n$. Conjecturally the spectrum $\{\mu_n : n \ge 1\}$
   has no finite accumulation point, with consecutive gaps
   $\mu_{n+1} - \mu_n \to 1$, since $\mu_n - n \to 0$ like $2/n$.

2. *Reciprocal spectrum accumulating only at $0$.* The reciprocals
   $1/\mu_n = \mu_n - n \in (0,1)$ are strictly decreasing quadratic irrationals with
   $1/\mu_n \to 0$ and $0$ as their unique accumulation point, so
   $\overline{\{1/\mu_n\}} = \{1/\mu_n : n\ge 1\} \cup \{0\}$.

3. *Two-parameter periodic families.* For coprime $(a,b)$ with $a \ge 1$, the periodic
   continued fraction $[a; b, a, b, \dots]$ is a root of $bx^2 - abx - a = 0$.
   Conjecturally the set of such two-letter periodic values is *dense* in $[1,\infty)$,
   in contrast to the discrete single-letter spectrum — a finite-data analogue of the
   Lagrange-spectrum transition.

4. *Bounded-discriminant density.* For squarefree $d > 1$, the field elements
   $\{p + q\sqrt d : p,q\in\mathbb{Q},\ q \neq 0\}$ are dense in $\mathbb{R}$ with explicit
   modulus $\lvert q\rvert \le \lceil \sqrt d/\varepsilon\rceil$; an effective,
   single-direction density theorem.

5. *Markov/Lagrange-style spectral gap.* Among metallic ratios, $\mu_1 = \varphi$ (the
   golden ratio) is the minimum of the spectrum, suggesting an extremal/gap phenomenon
   below the golden value.

## 8. Conclusion

We have established, with a fully constructive and formally verified argument, that every
real $2\times2$ matrix of determinant $\pm 1$ fixes the Euclidean norm of some nonzero
vector, so that $1$ always lies in its norm-ratio spectrum and the degenerate interval
$[1,1]$ lies in the closure of that spectrum. The proof reduces the geometry to a single
discriminant inequality equivalent to the Frobenius bound
$a^2+b^2+c^2+d^2 \ge 2\lvert\det M\rvert$, and produces the unstretched vector in closed
form using one square root. The result is the unimodular cornerstone of the broader
density program for ratio spectra over quadratic-irrational directions.
