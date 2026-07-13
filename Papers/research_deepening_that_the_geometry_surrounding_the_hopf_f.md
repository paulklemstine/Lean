# The Quaternionic Hermitian Witness Reconstructs the Fibres of the Hopf Fibration $S^7 \to S^4$

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

The Hopf fibrations are the four exceptional sphere bundles $S^0 \to S^1 \to
S^1$, $S^1 \to S^3 \to S^2$, $S^3 \to S^7 \to S^4$, and $S^7 \to S^{15} \to
S^8$, organised by the four real composition (normed division) algebras
$\mathbb{R}, \mathbb{C}, \mathbb{H}, \mathbb{O}$. We study the third of these,
the quaternionic Hopf fibration, through a single algebraic device: the Hermitian
inner product $\lambda = \bar q\,q' + \bar r\,r'$ of two unit vectors $a =
(q,r)$ and $b = (q',r')$ in $\mathbb{H}^2$. We prove that this *witness* detects,
bounds, and reconstructs the fibre structure exactly. Our central result is an
*unconditional* polynomial identity in eight quaternionic variables which, on the
unit sphere, specialises to the squared-distance identity $\|q' - q\lambda\|^2 +
\|r' - r\lambda\|^2 = 1 - \|\lambda\|^2$. From this single identity we deduce: a
Cauchy–Schwarz bound $\|\lambda\| \le 1$; a forward statement that if $b = a\cdot
\mu$ then $\lambda = \mu$; and a reconstruction statement that if $\|\lambda\| =
1$ then $b = a\cdot\lambda$. Packaging these together shows that the fibre through
a fixed unit vector is a principal homogeneous space (torsor) for the unit
quaternions $S^3$ acting on the right, with right multiplication and the witness
mutually inverse on the sphere. The only structural departure from the complex
case is that noncommutativity forces the connecting phase to act on the right.
The argument uses only two facts — multiplicativity of the quaternionic norm and
the order-reversing property of conjugation — the two axioms of a composition
algebra, which suggests that both the complex and octonionic cases follow from
the same skeleton and that the identity itself is a carrier of the Hurwitz
dimensional obstruction.

## 1. Introduction

The Hopf fibration $S^1 \hookrightarrow S^3 \to S^2$, discovered by Hopf in 1931,
is the prototypical nontrivial fibre bundle and a cornerstone of algebraic
topology, generating $\pi_3(S^2) \cong \mathbb{Z}$. It admits exactly three
higher analogues, one for each of the remaining real composition algebras:
$$
S^1 \to S^3 \to S^2 \ (\mathbb{C}), \qquad
S^3 \to S^7 \to S^4 \ (\mathbb{H}), \qquad
S^7 \to S^{15} \to S^8 \ (\mathbb{O}).
$$
The correspondence between these fibrations and the four normed division algebras
$\mathbb{R}, \mathbb{C}, \mathbb{H}, \mathbb{O}$ of dimensions $1, 2, 4, 8$ is one
of the most striking coincidences in mathematics, tied to Hurwitz's theorem and,
via the Hopf invariant one problem, to Adams's theorem on vector fields on
spheres.

This paper isolates a purely algebraic mechanism, the *Hermitian inner-product
witness*, that recovers the fibre structure of the quaternionic Hopf fibration in
an entirely elementary way. The philosophy is that a single device — the inner
product of two unit vectors — serves simultaneously as (i) a *detector* of fibre
membership, (ii) a *bound* certifying that fibre-mates are the extremal case, and
(iii) a *reconstructor* that returns the exact group element connecting two
fibre-mates. Over $\mathbb{C}$ this is classical and underlies the standard
identification of $S^3/S^1$ with $S^2 = \mathbb{CP}^1$. Our contribution is to
carry the device verbatim to the quaternions, where noncommutativity introduces
exactly one new phenomenon: the connecting phase must act on the *right*.

### 1.1 Contributions

1. An **unconditional polynomial identity** (Theorem 3.1) valid for all
   $q, r, q', r' \in \mathbb{H}$, requiring no normalisation, which is the
   algebraic engine of the entire development.
2. The **squared-distance identity** (Theorem 3.2), a non-definitional geometric
   identity on the unit sphere: $\|q' - q\lambda\|^2 + \|r' - r\lambda\|^2 =
   1 - \|\lambda\|^2$.
3. A **Cauchy–Schwarz bound** (Theorem 3.3): $\|\lambda\| \le 1$.
4. A **forward reconstruction** (Theorem 3.4): $b = a\cdot\mu \Rightarrow
   \lambda = \mu$.
5. A **fibre reconstruction** (Theorem 3.5): $\|\lambda\| = 1 \Rightarrow b =
   a\cdot\lambda$.
6. A **torsor / fibre correspondence** (Theorem 3.7) packaging the forward and
   reconstruction directions into a single principal-homogeneous-space statement.

Throughout, the proofs rely only on the multiplicativity of the norm and the
conjugation antihomomorphism, the two defining axioms of a composition algebra.

## 2. Preliminaries

### 2.1 Quaternions

The **quaternions** $\mathbb{H}$ form the four-dimensional real associative
algebra with basis $1, i, j, k$ and Hamilton's relations
$$
i^2 = j^2 = k^2 = ijk = -1, \qquad ij = k = -ji, \quad jk = i = -kj, \quad ki = j = -ik.
$$
A quaternion is written $q = w + xi + yj + zk$ with $w, x, y, z \in \mathbb{R}$.
The **conjugate** is $\bar q = w - xi - yj - zk$, and the **norm** is defined by
$$
\|q\|^2 = q\bar q = \bar q q = w^2 + x^2 + y^2 + z^2 \in \mathbb{R}_{\ge 0}.
$$
Multiplication is associative but *not* commutative. We record the two properties
that drive every proof.

**Lemma 2.1 (Composition-algebra axioms).** For all $p, q \in \mathbb{H}$:

- (Norm multiplicativity) $\|pq\| = \|p\|\,\|q\|$, equivalently $\|pq\|^2 =
  \|p\|^2\,\|q\|^2$.
- (Conjugation antihomomorphism) $\overline{pq} = \bar q\, \bar p$.

A useful corollary, used repeatedly below, is the collapse
$$
\bar q\,(q\mu) = (\bar q q)\,\mu = \|q\|^2\,\mu, \tag{2.1}
$$
where $\|q\|^2$ denotes the real scalar viewed as a central element of
$\mathbb{H}$. Note that the analogous expression $\bar q\,(\mu q)$ does *not*
simplify, since $\mu$ cannot be moved past $q$; this asymmetry is the source of
the right-handedness of the fibre.

### 2.2 The quaternionic Hopf fibration

The total space is the unit sphere
$$
S^7 = \{ (q, r) \in \mathbb{H}^2 : \|q\|^2 + \|r\|^2 = 1 \}.
$$
The group $S^3 = \{ \mu \in \mathbb{H} : \|\mu\| = 1 \}$ of unit quaternions acts
freely on $S^7$ by **right multiplication**, $(q, r) \cdot \mu = (q\mu, r\mu)$.
This action is well-defined on $S^7$: by norm multiplicativity, $\|q\mu\|^2 +
\|r\mu\|^2 = \|q\|^2\|\mu\|^2 + \|r\|^2\|\mu\|^2 = \|q\|^2 + \|r\|^2 = 1$. The
orbit space $S^7/S^3$ is the quaternionic projective line $\mathbb{HP}^1 \cong
S^4$, and the projection $S^7 \to S^4$ is the quaternionic Hopf fibration with
fibre $S^3$. The **fibre** through a point $a$ is precisely its orbit $\{ a\cdot
\mu : \mu \in S^3 \}$; two points lie on the same fibre iff they are
right-proportional by a unit quaternion.

### 2.3 The witness

**Definition 2.2 (Hermitian witness).** For $a = (q, r)$ and $b = (q', r')$ in
$\mathbb{H}^2$, the **witness** is the quaternion
$$
\lambda(a, b) = \langle a, b \rangle = \bar q\, q' + \bar r\, r' \in \mathbb{H}.
$$
This is the standard $\mathbb{H}$-Hermitian inner product on $\mathbb{H}^2$
(conjugate-linear in the first slot, $\mathbb{H}$-linear on the right in the
second). When $a, b$ are clear from context we write simply $\lambda$.

## 3. Main results

Throughout this section fix $q, r, q', r' \in \mathbb{H}$ and write $\lambda =
\bar q q' + \bar r r'$.

### 3.1 The unconditional identity

**Theorem 3.1 (Unconditional algebraic identity).** For all $q, r, q', r' \in
\mathbb{H}$,
$$
\|q' - q\lambda\|^2 + \|r' - r\lambda\|^2
= \big(\|q'\|^2 + \|r'\|^2\big) - 2\|\lambda\|^2 + \big(\|q\|^2 + \|r\|^2\big)\,\|\lambda\|^2 .
$$

*Proof sketch.* Expand each squared norm using $\|u - v\|^2 = \|u\|^2 -
2\,\mathrm{Re}(\bar u v) + \|v\|^2$, valid for the real inner product
$\mathrm{Re}(\bar u v)$ on $\mathbb{H} \cong \mathbb{R}^4$. The cross terms are
$$
-2\,\mathrm{Re}\big(\overline{q'}\,(q\lambda)\big) - 2\,\mathrm{Re}\big(\overline{r'}\,(r\lambda)\big)
= -2\,\mathrm{Re}\big((\overline{q'}q + \overline{r'}r)\lambda\big)
= -2\,\mathrm{Re}(\bar\lambda\,\lambda) = -2\|\lambda\|^2,
$$
where we used $\overline{q'}q + \overline{r'}r = \bar\lambda$ (the conjugate of
$\lambda$) and $\mathrm{Re}(\bar\lambda\lambda) = \|\lambda\|^2$. The quadratic
terms are $\|q\lambda\|^2 + \|r\lambda\|^2 = (\|q\|^2 + \|r\|^2)\|\lambda\|^2$ by
norm multiplicativity. Collecting the three groups gives the stated identity. The
whole computation is a polynomial identity in the sixteen real coordinates and
uses no normalisation. $\square$

The identity is genuinely non-trivial: it is not a definitional rewriting but a
consequence of the interaction between conjugation and multiplication in
$\mathbb{H}$.

### 3.2 The squared-distance identity

**Theorem 3.2 (Squared-distance identity on the sphere).** If $\|q\|^2 + \|r\|^2
= 1$ and $\|q'\|^2 + \|r'\|^2 = 1$, then
$$
\|q' - q\lambda\|^2 + \|r' - r\lambda\|^2 = 1 - \|\lambda\|^2 .
$$

*Proof.* Substitute $\|q'\|^2 + \|r'\|^2 = 1$ and $\|q\|^2 + \|r\|^2 = 1$ into
Theorem 3.1. The right side becomes $1 - 2\|\lambda\|^2 + 1\cdot\|\lambda\|^2 =
1 - \|\lambda\|^2$. $\square$

Geometrically, $a\cdot\lambda = (q\lambda, r\lambda)$ is the orthogonal
projection of $b$ onto the (right) $\mathbb{H}$-line through $a$, and the left side
is the squared distance from $b$ to that projection. The identity says this
squared residual equals the *defect* $1 - \|\lambda\|^2$ of the witness from the
unit sphere.

### 3.3 The Cauchy–Schwarz bound

**Theorem 3.3 (Cauchy–Schwarz).** If $a, b$ are unit vectors, then $\|\lambda\|
\le 1$.

*Proof.* By Theorem 3.2, $1 - \|\lambda\|^2$ equals a sum of two squared norms,
hence is $\ge 0$. Therefore $\|\lambda\|^2 \le 1$, and since $\|\lambda\| \ge 0$
we get $\|\lambda\| \le 1$. $\square$

### 3.4 Forward direction

**Theorem 3.4 (Witness of a proportional pair).** If $\|q\|^2 + \|r\|^2 = 1$ and
$b = a\cdot\mu$, i.e. $q' = q\mu$ and $r' = r\mu$, then $\lambda = \mu$.

*Proof.* Using (2.1),
$$
\lambda = \bar q(q\mu) + \bar r(r\mu) = \|q\|^2\mu + \|r\|^2\mu
= (\|q\|^2 + \|r\|^2)\mu = 1\cdot\mu = \mu. \qquad \square
$$
Note the essential use of *right* placement of $\mu$: the collapse $\bar q(q\mu)
= \|q\|^2\mu$ requires $\mu$ to sit to the right, so that $\bar q q$ can combine.

### 3.5 Fibre reconstruction

**Theorem 3.5 (Reconstruction).** If $a, b$ are unit vectors and $\|\lambda\| =
1$, then $b = a\cdot\lambda$; that is, $q' = q\lambda$ and $r' = r\lambda$.

*Proof.* By Theorem 3.2, $\|q' - q\lambda\|^2 + \|r' - r\lambda\|^2 = 1 -
\|\lambda\|^2 = 0$. A sum of two non-negative reals is zero only if each is zero,
so $\|q' - q\lambda\| = 0$ and $\|r' - r\lambda\| = 0$, hence $q' = q\lambda$ and
$r' = r\lambda$. $\square$

Combining Theorems 3.3–3.5 gives the sharp dichotomy: for unit vectors,
$\|\lambda\| \le 1$ always, with equality iff $a$ and $b$ lie on a common fibre,
in which case $\lambda$ is exactly the connecting right phase.

### 3.6 Invariance of the sphere

**Theorem 3.6 (Right action preserves the sphere).** If $\|q\|^2 + \|r\|^2 = 1$
and $\|\mu\| = 1$, then $\|q\mu\|^2 + \|r\mu\|^2 = 1$.

*Proof.* By norm multiplicativity, $\|q\mu\|^2 + \|r\mu\|^2 = \|q\|^2\|\mu\|^2 +
\|r\|^2\|\mu\|^2 = \|q\|^2 + \|r\|^2 = 1$. $\square$

### 3.7 The fibre correspondence

**Theorem 3.7 (Fibre correspondence / torsor structure).** Fix a unit vector $a =
(q, r)$. Then:

1. (Going out) For every unit quaternion $\mu$, the point $a\cdot\mu$ is a unit
   vector and $\lambda(a, a\cdot\mu) = \mu$.
2. (Coming back) For every unit vector $b = (q', r')$ with $\|\lambda(a, b)\| =
   1$, we have $b = a\cdot\lambda(a, b)$.

Consequently, the maps $\mu \mapsto a\cdot\mu$ and $b \mapsto \lambda(a, b)$ are
mutually inverse bijections between $S^3$ and the fibre through $a$. In
particular, the fibre through $a$ is a principal homogeneous space (torsor) for
$S^3$ acting on the right.

*Proof.* Part 1 combines Theorem 3.6 (the image is a unit vector) with Theorem
3.4 (the witness equals $\mu$). Part 2 is Theorem 3.5. That the two maps are
mutually inverse is immediate: starting from $\mu$, going out then coming back
returns $\lambda(a, a\cdot\mu) = \mu$ by Part 1; starting from a fibre point $b$,
coming back then going out returns $a\cdot\lambda(a,b) = b$ by Part 2. Freeness of
the action (equivalently injectivity of $\mu \mapsto a\cdot\mu$) follows because
$a\cdot\mu = a\cdot\mu'$ forces $\mu = \lambda(a, a\cdot\mu) = \lambda(a, a\cdot
\mu') = \mu'$. Hence the fibre is a right $S^3$-torsor. $\square$

## 4. The role of noncommutativity

The complex analogue of this development (for the fibration $S^1 \to S^3 \to
S^2$) is classical and identical in form, with the witness $\lambda = \bar z z' +
\bar w w' \in \mathbb{C}$. Because $\mathbb{C}$ is commutative, the connecting
phase may be written on either side and the distinction is invisible. Over
$\mathbb{H}$ the distinction becomes essential and is the *only* structural change.

The decisive step is the collapse (2.1): $\bar q(q\mu) = \|q\|^2\mu$ holds because
the real scalar $\bar q q$ commutes with everything, but $\mu$ must be on the
right so that $\bar q$ meets $q$. Were the action on the left, $b = \mu\cdot a =
(\mu q, \mu r)$, the witness would produce $\bar q(\mu q) + \bar r(\mu r)$, which
does not simplify because $\mu$ is trapped between $\bar q$ and $q$. Thus the
composition-algebra machinery forces the fibre to be a *right* $\mathbb{H}$-line
and the witness to return the right-hand phase. Noncommutativity manifests purely
as a choice of side, not as an obstruction to the method.

## 5. Algorithms

The results yield exact, division-free algorithms operating on unit vectors in
$\mathbb{H}^2$.

**Algorithm A (Fibre-membership test).** *Input:* unit vectors $a, b \in S^7$.
*Output:* whether $a, b$ share a fibre, and if so the connecting phase.
Compute $\lambda = \bar q q' + \bar r r'$; compute $\|\lambda\|^2 = \lambda
\bar\lambda$; if $\|\lambda\|^2 = 1$ report "same fibre, phase $= \lambda$", else
report "distinct fibres". Cost: $O(1)$ quaternion operations (a fixed number of
real multiplications and additions), with no square roots or divisions required
for the test itself.

**Algorithm B (Phase reconstruction).** *Input:* unit vectors $a, b$ known to be
fibre-mates. *Output:* the unique $\mu \in S^3$ with $b = a\cdot\mu$. Return
$\mu = \bar q q' + \bar r r'$. Correctness is Theorem 3.4/3.5.

**Algorithm C (Geodesic defect / interpolation weight).** *Input:* unit vectors
$a, b$. *Output:* the fibre-projection residual $1 - \|\lambda\|^2 \ge 0$, a
similarity score that is $0$ iff the points are fibre-mates. Correctness is
Theorem 3.2. This is directly usable as a distance-like quantity on the base
$S^4 = \mathbb{HP}^1$.

## 6. Applications

**Orientation and state comparison.** Unit quaternions model 3D rotations, and
unit vectors in $\mathbb{H}^2$ model states in a two-quaternion register. The
witness gives an immediate, division-free test for whether two such states differ
only by a global right phase, together with the exact phase — useful in robotics,
attitude control, and computer graphics where quaternion representations are
ubiquitous.

**Projective coordinates on $\mathbb{HP}^1 = S^4$.** The residual $1 -
\|\lambda\|^2$ descends to a well-defined function on pairs of points of the base
$S^4$ and provides an elementary, coordinate-free chordal-type quantity, avoiding
explicit charts.

**A template for the composition-algebra family.** Because the proofs use only
the two composition-algebra axioms, the same statements and proof skeleton apply
to the complex fibration $S^1 \to S^3 \to S^2$ verbatim, and are conjectured to
apply to the octonionic fibration $S^7 \to S^{15} \to S^8$ with a fixed
bracketing of the projection.

## 7. Discussion

The witness identity concentrates the geometry of a nontrivial principal bundle
into a single polynomial equation. Three classically distinct facts — a metric
inequality (Cauchy–Schwarz), a topological membership condition (same fibre), and
a group-theoretic reconstruction (the connecting element) — are revealed as three
readings of the identity $\|q' - q\lambda\|^2 + \|r' - r\lambda\|^2 = 1 -
\|\lambda\|^2$. Since the only hypotheses are norm multiplicativity and the
conjugation antihomomorphism, the identity is, in effect, a *certificate that its
ambient algebra is a composition algebra*. This is suggestive: the Hurwitz
classification restricts composition algebras to dimensions $1, 2, 4, 8$, so the
existence of a norm-nonincreasing witness reconstruction becomes a dimensional
obstruction of algebraic rather than topological origin.

## 8. Future work

- **Octonionic witness.** Extend the identity to $\mathbb{O}^2$ and the fibration
  $S^7 \to S^{15} \to S^8$; the non-associativity requires a fixed bracketing
  $q(\lambda)$ of the projection but should not affect the norm-based cancellation.
- **Hopf-invariant-one obstruction from the witness.** Formalise the sense in
  which the defect identity forces the ambient algebra to be a composition
  algebra, recovering the $1, 2, 4, 8$ dimensional restriction from the identity
  itself.
- **Transition cocycles.** Promote the pointwise torsor structure to a global
  statement: express the transition functions of the quaternionic Hopf bundle
  over a cover of $S^4$ as witnesses evaluated on chart overlaps, and identify
  their homotopy class with the generator of $\pi_3(S^3)$.

## 9. Conclusion

A single quaternion — the Hermitian inner product of two unit vectors in
$\mathbb{H}^2$ — simultaneously bounds, detects, and reconstructs the fibres of
the quaternionic Hopf fibration $S^7 \to S^4$. The mechanism is an unconditional
algebraic identity that rests solely on the composition-algebra axioms, so it
transfers unchanged across the normed division algebras, with noncommutativity
appearing only as the side on which the connecting phase acts. The fibre through
any unit vector is thereby exhibited as a right $S^3$-torsor whose exact ruler is
the inner product.
