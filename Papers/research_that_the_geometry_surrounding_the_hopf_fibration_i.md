# The Fourth Dimension as a Composition-Algebra Playground

## Abstract

The geometry surrounding the Hopf fibration is organized, at every turn, by the
composition (normed division) algebras $\mathbb{R}$, $\mathbb{C}$, $\mathbb{H}$,
$\mathbb{O}$. We develop five interlocking results that make this organizing
principle precise. First, we show that a single algebraic device — the Hermitian
inner product $\lambda = \overline{z}z' + \overline{w}w'$ of two unit vectors in
$\mathbb{C}^2$ — both detects and reconstructs the fibres of the complex Hopf map
$S^3 \to S^2$, via an exact squared-distance identity that simultaneously yields
the Cauchy–Schwarz bound. Second, we prove that multiplication by $i$ on
$\mathbb{C}^n$ is a fixed-point-free isometric complex structure on
$S^{2n-1}$, with the entire fixed-point analysis reducing to the scalar fact
$i - 1 \neq 0$. Third, we establish, uniformly in the dimension $m$, that the
balanced flat torus with all radii equal to $1/\sqrt{m}$ is the unique volume
maximizer among flat $m$-tori in $S^{2m-1}$, with maximal volume factor
$m^{-m/2}$. Fourth, we record the two positive rungs of the composition-identity
ladder — the Brahmagupta–Fibonacci two-square and Euler four-square identities —
together with a determinant obstruction that rules out every odd dimension
greater than one. Fifth, we prove the norm rigidity of quaternion conjugation
$x \mapsto qxq^{-1}$ for *every* nonzero $q$, the computation underlying the
classical double covers $S^3 \to SO(3)$ and $S^3 \times S^3 \to SO(4)$. A common
thread runs through all five: the multiplicativity of a norm, the defining
property of the composition algebras.

**Keywords:** Hopf fibration, composition algebra, quaternions, complex
structure, flat torus, arithmetic–geometric mean, sum-of-squares identity,
double cover.

---

## 1. Introduction

The Hopf fibration $S^3 \to S^2$, discovered by Hopf in 1931, was the first
example showing that higher homotopy groups of spheres can be nontrivial, and it
remains a central object linking topology, geometry, and algebra. Its most
striking feature — that the three-sphere decomposes into a smoothly varying,
pairwise-disjoint family of great circles — is best understood through the
complex numbers: writing $S^3 = \{(z,w) \in \mathbb{C}^2 : |z|^2 + |w|^2 = 1\}$,
the fibres are the orbits of the diagonal circle action $(z,w) \mapsto (\mu z,
\mu w)$, $|\mu| = 1$.

This complex description is one instance of a broader pattern: much of the
geometry *surrounding* the Hopf fibration is controlled by the four composition
algebras. A composition algebra over $\mathbb{R}$ is a (not necessarily
associative) unital algebra $A$ equipped with a nondegenerate quadratic form $N$
satisfying $N(xy) = N(x)N(y)$. By the Hurwitz theorem the finite-dimensional
Euclidean composition algebras are exactly $\mathbb{R}$ (dimension 1),
$\mathbb{C}$ (2), $\mathbb{H}$ (4), and $\mathbb{O}$ (8). The multiplicativity of
$N$ is the single property that recurs, in different disguises, in every result
below.

This paper collects five self-contained results, each isolating an algebraic
core of a geometric phenomenon:

1. **Fibre reconstruction (Section 3).** The Hermitian inner product of two unit
   vectors reconstructs the complex Hopf fibre through them.
2. **Fixed-point-free complex structure (Section 4).** Multiplication by $i$ is a
   fixed-point-free isometry of $S^{2n-1}$.
3. **Balanced tori (Section 5).** The balanced flat torus uniquely maximizes
   volume on every odd sphere.
4. **The composition-identity ladder (Section 6).** The two- and four-square
   identities hold; odd dimensions are obstructed.
5. **Norm rigidity of conjugation (Section 7).** Quaternion conjugation preserves
   the norm for every nonzero $q$.

Each result is stated with a full proof sketch. Section 8 discusses applications
and Section 9 collects open directions, including the conjectural quaternionic and
octonionic analogues of the fibre-reconstruction theorem.

---

## 2. Preliminaries and notation

We work over $\mathbb{R}$. For $v \in \mathbb{C}^n$ we write $\lVert v\rVert^2 =
\sum_{i} |v_i|^2$ for the squared Euclidean norm; the unit sphere
$S^{2n-1} \subset \mathbb{C}^n$ is $\{v : \lVert v\rVert^2 = 1\}$. Complex
conjugation is written $\overline{z}$, and $|z|$ is the modulus.

The quaternions $\mathbb{H} = \{a + bi + cj + dk\}$ carry the norm form
$N(q) = a^2 + b^2 + c^2 + d^2$, which is multiplicative: $N(pq) = N(p)N(q)$. Thus
$N$ is a monoid homomorphism from $(\mathbb{H}, \cdot)$ to $(\mathbb{R}, \cdot)$
that vanishes only at $0$, and every nonzero $q$ has inverse $q^{-1} =
\overline{q}/N(q)$ with $N(q^{-1}) = N(q)^{-1}$.

A **flat $m$-torus** in $S^{2m-1} \subset \mathbb{C}^m$ is the image of
$(\theta_1,\dots,\theta_m) \mapsto (r_1 e^{i\theta_1}, \dots, r_m e^{i\theta_m})$
with fixed radii $r_i \ge 0$ satisfying $\sum_i r_i^2 = 1$. Its induced
Riemannian volume is proportional to the product $\prod_i r_i$ of the circle
circumferences.

---

## 3. The Hermitian inner product reconstructs the complex Hopf fibre

Let $a = (z, w)$ and $b = (z', w')$ be unit vectors in $\mathbb{C}^2$. They lie
on the same Hopf fibre iff $b = \mu a$ for some $\mu$ with $|\mu| = 1$. Define the
**inner-product witness**
$$\lambda = \langle a, b\rangle = \overline{z}\,z' + \overline{w}\,w'.$$

**Theorem 3.1 (Squared-distance identity).** *For unit vectors $(z,w)$ and
$(z',w')$,*
$$\lVert z' - \lambda z\rVert^2 + \lVert w' - \lambda w\rVert^2 = 1 - |\lambda|^2.$$

*Proof sketch.* Expand the left side using $\lVert u - cv\rVert^2 = |u|^2 -
2\,\mathrm{Re}(\overline{c}\,\overline{v}u) + |c|^2|v|^2$ termwise for the two
coordinates. Summing and using $|z'|^2 + |w'|^2 = 1$ and $|z|^2 + |w|^2 = 1$, the
cross terms assemble into $-2\,\mathrm{Re}(\overline{\lambda}\lambda) +
|\lambda|^2 = -|\lambda|^2$, and the leading terms give $1$. The identity is a
direct polynomial computation once the norms are written via
$\lVert \cdot\rVert^2 = \mathrm{normSq}$. $\square$

**Corollary 3.2 (Cauchy–Schwarz).** *$|\lambda| \le 1$ for any two unit
vectors.*

*Proof.* The left-hand side of Theorem 3.1 is a sum of squares, hence
nonnegative; therefore $1 - |\lambda|^2 \ge 0$. $\square$

**Theorem 3.3 (Forward direction).** *If $b = \mu a$, i.e. $(z',w') = (\mu z,
\mu w)$, and $a$ is a unit vector, then $\lambda = \mu$.*

*Proof sketch.* Compute $\lambda = \overline{z}(\mu z) + \overline{w}(\mu w) =
\mu(\overline{z}z + \overline{w}w) = \mu(|z|^2 + |w|^2) = \mu$. No unit
assumption on $\mu$ is needed; when $b$ is a unit vector, $|\mu| = 1$ follows.
$\square$

**Theorem 3.4 (Fibre reconstruction).** *If $|\lambda| = 1$, then $z' = \lambda
z$ and $w' = \lambda w$; the two unit vectors lie on a common Hopf fibre, and
$\lambda$ is the connecting phase.*

*Proof.* By Theorem 3.1, $|\lambda| = 1$ forces $\lVert z' - \lambda z\rVert^2 +
\lVert w' - \lambda w\rVert^2 = 0$. A sum of two nonnegative reals is zero only if
both vanish, so $z' = \lambda z$ and $w' = \lambda w$. $\square$

Theorems 3.1–3.4 show that a *single* complex scalar $\lambda$ detects fibre
membership (Corollary 3.2 gives $|\lambda| \le 1$, with equality precisely on a
shared fibre) and reconstructs the second point from the first. This is the
complex ($\mathbb{C}$-linear) base case of a conjectural ladder whose rungs pass
to the quaternionic Hopf map $S^7 \to S^4$ and the octonionic Hopf map
$S^{15} \to S^8$; see Section 9.

---

## 4. Multiplication by $i$ is a fixed-point-free isometric complex structure

Regard $\mathbb{C}^n$ as $\mathbb{R}^{2n}$. Define $J : \mathbb{C}^n \to
\mathbb{C}^n$ by $J(v)_k = i\,v_k$, and let $N(v) = \sum_k |v_k|^2$.

**Theorem 4.1 (Almost-complex structure).** *$J(J(v)) = -v$ for all $v$; that is,
$J^2 = -\mathrm{id}$.*

*Proof.* Coordinatewise, $i(i v_k) = i^2 v_k = -v_k$. $\square$

**Theorem 4.2 (Isometry).** *$N(J(v)) = N(v)$ for all $v$.*

*Proof.* Coordinatewise, $|i v_k| = |i|\,|v_k| = |v_k|$, so
$\sum_k |i v_k|^2 = \sum_k |v_k|^2$. In particular $J$ maps $S^{2n-1}$ to itself.
$\square$

**Theorem 4.3 (Real-linearity).** *$J(v + w) = J(v) + J(w)$ and $J(cv) = cJ(v)$
for real scalars $c$.*

*Proof.* Both are immediate from distributivity and commutativity of
multiplication by $i$; $J(cv)_k = i(cv_k) = c(i v_k) = (cJ(v))_k$. $\square$

**Theorem 4.4 (Fixed-point freeness).** *If $J(v) = v$ then $v = 0$. Consequently
$J$ has no fixed point on $S^{2n-1}$.*

*Proof.* From $J(v) = v$ we get $i v_k = v_k$, i.e. $(i - 1)v_k = 0$ for each $k$.
Since $i - 1 \ne 0$ (its imaginary part is $1 \ne 0$), we may cancel to obtain
$v_k = 0$ for all $k$, hence $v = 0$. If $v$ were a fixed point on the sphere it
would satisfy $N(v) = 1$, contradicting $v = 0$. $\square$

Theorems 4.1–4.4 exhibit $J = {}\cdot i$ as a genuine linear complex structure
that acts freely and isometrically on the odd sphere. The entire fixed-point
analysis is powered by the single scalar inequality $i - 1 \neq 0$: this is the
concrete algebraic reason the "rotation through the fourth dimension" leaves no
axis invariant. It is conjectured (Section 9) that, up to conjugacy, this is the
*only* algebraic complex structure available to a fixed-point-free isometry of
order dividing four.

---

## 5. Balanced flat tori are the unique volume maximizers on odd spheres

Consider flat $m$-tori in $S^{2m-1}$ with radius vector $r = (r_1,\dots,r_m)$,
$r_i \ge 0$, $\sum_i r_i^2 = 1$. The induced volume is proportional to
$\prod_i r_i$.

**Theorem 5.1 (Product bound).** *For nonnegative reals $s_1,\dots,s_m$ with
$\sum_i s_i = 1$,*
$$\prod_{i=1}^m s_i \le \left(\frac{1}{m}\right)^m.$$

*Proof sketch.* This is the (unweighted) arithmetic–geometric mean inequality.
With weights $1/m$, AM–GM gives $\prod_i s_i^{1/m} \le \frac{1}{m}\sum_i s_i =
\frac{1}{m}$. Raising to the $m$-th power yields $\prod_i s_i \le (1/m)^m$.
$\square$

**Theorem 5.2 (Equality / uniqueness).** *Under the hypotheses of Theorem 5.1,
$\prod_i s_i = (1/m)^m$ holds if and only if $s_i = 1/m$ for every $i$.*

*Proof sketch.* The equality case of weighted AM–GM with equal weights holds iff
all $s_i$ are equal; combined with $\sum_i s_i = 1$ this forces $s_i = 1/m$.
Conversely, $s_i = 1/m$ gives $\prod_i s_i = (1/m)^m$. $\square$

**Theorem 5.3 (Squared-radius bound).** *If $r_i \ge 0$ and $\sum_i r_i^2 = 1$
then $\prod_i r_i^2 \le (1/m)^m$.*

*Proof.* Apply Theorem 5.1 with $s_i = r_i^2 \ge 0$. $\square$

**Theorem 5.4 (Volume bound with growth rate).** *If $r_i \ge 0$ and
$\sum_i r_i^2 = 1$ then*
$$\prod_{i=1}^m r_i \le m^{-m/2}.$$

*Proof.* Take square roots in Theorem 5.3: $\prod_i r_i = \sqrt{\prod_i r_i^2}
\le \sqrt{(1/m)^m} = (1/m)^{m/2} = m^{-m/2}$. $\square$

**Theorem 5.5 (The balanced torus attains the bound).** *The choice $r_i^2 = 1/m$
for all $i$ satisfies $\sum_i r_i^2 = 1$ and gives $\prod_i r_i^2 = (1/m)^m$,
hence $\prod_i r_i = m^{-m/2}$.*

*Proof.* Direct computation. $\square$

Together, Theorems 5.1–5.5 prove that the balanced torus $r_i = 1/\sqrt{m}$ is the
*unique* maximizer of the volume functional on every odd sphere simultaneously,
with maximal volume factor $m^{-m/2}$. The result is uniform in $m$: a single
inequality (the $m$-variable AM–GM) plus its equality case settle the extremal
problem in all dimensions at once, exactly as the monotonicity of the volume in
the elementary symmetric product $\prod_i r_i^2$ predicts.

---

## 6. The composition-identity ladder and its odd-dimensional obstruction

A **bilinear sum-of-squares (composition) identity** in dimension $d$ expresses
$(\sum_i a_i^2)(\sum_j b_j^2) = \sum_k c_k^2$, where each $c_k$ is a bilinear form
in the $a$'s and $b$'s. Such identities encode norm-multiplicative bilinear
products on $\mathbb{R}^d$; by Hurwitz's theorem they exist exactly for
$d \in \{1, 2, 4, 8\}$. We record the two positive rungs at the heart of the Hopf
story and the obstruction that eliminates odd dimensions.

**Theorem 6.1 (Two-square identity; Brahmagupta–Fibonacci).**
$$(a_1^2 + a_2^2)(b_1^2 + b_2^2) = (a_1 b_1 - a_2 b_2)^2 + (a_1 b_2 + a_2 b_1)^2.$$

*Proof.* Expand both sides; they agree as polynomials. This is precisely
$|a|^2|b|^2 = |ab|^2$ for complex $a = a_1 + a_2 i$, $b = b_1 + b_2 i$. $\square$

**Theorem 6.2 (Four-square identity; Euler).**
$$
\begin{aligned}
(a_1^2 + a_2^2 + a_3^2 + a_4^2)&(b_1^2 + b_2^2 + b_3^2 + b_4^2) \\
= (a_1 b_1 - a_2 b_2 - a_3 b_3 - a_4 b_4)^2
&+ (a_1 b_2 + a_2 b_1 + a_3 b_4 - a_4 b_3)^2 \\
+ (a_1 b_3 - a_2 b_4 + a_3 b_1 + a_4 b_2)^2
&+ (a_1 b_4 + a_2 b_3 - a_3 b_2 + a_4 b_1)^2.
\end{aligned}
$$

*Proof.* Expand both sides; they agree as polynomials. This is $N(a)N(b) = N(ab)$
for the quaternions, with the four $c_k$ the components of the quaternion product.
$\square$

**Theorem 6.3 (Odd-dimensional obstruction).** *For odd $n$, no real $n \times n$
matrix $J$ satisfies $J^2 = -I$.*

*Proof.* Suppose $J^2 = -I$. Taking determinants, $(\det J)^2 = \det(J^2) =
\det(-I) = (-1)^n$. For odd $n$ this is $-1$, so $(\det J)^2 = -1$, impossible for
a real number. $\square$

**Corollary 6.4 (No three-square identity).** *There is no linear complex
structure on $\mathbb{R}^3$; in particular no real $3 \times 3$ matrix squares to
$-I$.*

*Proof.* Apply Theorem 6.3 with $n = 3$. $\square$

The obstruction explains the odd gaps in the ladder. A norm-multiplicative
bilinear product on $\mathbb{R}^d$ makes $\mathbb{R}^d$ a composition algebra;
left-multiplication by an imaginary unit $u$ (with $u^2 = -1$) is then a real
matrix $J$ with $J^2 = -I$. Theorem 6.3 forbids this whenever $d$ is odd, so no
composition identity exists in odd dimension $> 1$ — ruling out three-, five-, and
seven-square identities. This is the exact analogue, one dimension up, of the
scalar fact $i - 1 \neq 0$ from Section 4. The single remaining even exclusion
($d = 6$) requires the finer Hurwitz–Radon count and is left as an open step
(Section 9).

---

## 7. Norm rigidity of quaternion conjugation

For a nonzero quaternion $q$, define the inner conjugation
$$\mathrm{conj}_q(x) = q\,x\,q^{-1}.$$

**Theorem 7.1 (Norm-square rigidity).** *For every $x$ and every nonzero $q$,
$N(\mathrm{conj}_q(x)) = N(x)$.*

*Proof sketch.* By multiplicativity of $N$ and $N(q^{-1}) = N(q)^{-1}$,
$$N(qxq^{-1}) = N(q)\,N(x)\,N(q^{-1}) = N(q)\,N(x)\,N(q)^{-1} = N(x),$$
using $N(q) \ne 0$. $\square$

**Theorem 7.2 (Norm rigidity).** *For every $x$ and every nonzero $q$,
$\lVert \mathrm{conj}_q(x)\rVert = \lVert x\rVert$.*

*Proof.* Take square roots in Theorem 7.1. $\square$

**Theorem 7.3 (Multiplicativity).** *$\mathrm{conj}_q(xy) = \mathrm{conj}_q(x)\,
\mathrm{conj}_q(y)$; conjugation is an inner algebra automorphism.*

*Proof.* $q(xy)q^{-1} = (qxq^{-1})(qyq^{-1})$ since the interior $q^{-1}q = 1$
telescopes. $\square$

**Theorem 7.4 (Fixes the real axis).** *For real $c$, $\mathrm{conj}_q(c) = c$.*

*Proof.* Scalars commute with all quaternions, so $qcq^{-1} = cqq^{-1} = c$.
$\square$

**Theorem 7.5 (Isometry for unit $q$).** *If $\lVert q\rVert = 1$ then
$\mathrm{conj}_q$ is a norm-preserving map.*

*Proof.* A unit quaternion is nonzero, so Theorem 7.2 applies. $\square$

The crucial feature is that Theorems 7.1–7.4 hold for *every* nonzero $q$, not
only unit ones. Hence $\mathrm{conj}_q = \mathrm{conj}_{cq}$ for any nonzero real
$c$: the action depends only on the class of $q$ in the projective unit group.
This is exactly the mechanism behind the classical two-to-one covers: unit
quaternions act on the imaginary quaternions ($\cong \mathbb{R}^3$) as $SO(3)$,
giving $S^3 \to SO(3)$ with kernel $\{\pm 1\}$; and pairs $(p, q)$ of unit
quaternions act on $\mathbb{H} \cong \mathbb{R}^4$ by $x \mapsto p x q^{-1}$,
giving $S^3 \times S^3 \to SO(4)$ with kernel $\{\pm(1,1)\}$.

---

## 8. Applications

**Quantum state geometry.** The complex Hopf map $S^3 \to S^2$ is the Bloch-sphere
projection: a normalized qubit state $(z,w)$ maps to a point of $S^2$, and states
on the same fibre differ by a global phase — physically indistinguishable. The
inner-product witness $\lambda = \overline{z}z' + \overline{w}w'$ is the quantum
overlap amplitude; $|\lambda|^2$ is the transition probability, and $|\lambda| =
1$ is exactly the condition that two states are physically identical (Theorem
3.4). The Cauchy–Schwarz bound $|\lambda| \le 1$ is the statement that
probabilities do not exceed one.

**Rotations in graphics and robotics.** Unit quaternions are the standard
representation of 3D rotations; Theorems 7.1–7.5 are the algebraic guarantee that
$x \mapsto qxq^{-1}$ is a rotation, and the double cover $S^3 \to SO(3)$ explains
the well-known "double-cover" behavior of quaternion interpolation, where $q$ and
$-q$ encode the same orientation.

**Design of symmetric structures.** The balanced-torus result identifies the
maximal-volume flat torus on each odd sphere and, more broadly, the optimal
distribution of "budget" $\sum r_i^2 = 1$ across independent circular modes — a
template for equal-energy resource allocation problems.

**Existence of nowhere-zero vector fields.** The fixed-point-free isometry of
Section 4 provides an explicit nowhere-zero tangent vector field $v \mapsto J(v)$
on every odd sphere, the constructive counterpart to the hairy-ball theorem's
prohibition on even spheres.

---

## 9. Discussion and future work

The five results share one engine — the multiplicativity of a norm — and they
suggest a coordinated program of generalizations, formulated here as conjectures.

**Conjecture A (Octonionic fibre witness).** For the octonionic Hopf map
$S^{15} \to S^8$, the $S^7$ fibres are recoverable from a single inner-product
witness analogous to $\lambda = \overline{z}z' + \overline{w}w'$, evaluated in a
fixed associative subalgebra of the octonions. The phase ambiguity of a unit
vector is always a principal homogeneous space for the unit group of the
underlying composition algebra; octonionic non-associativity only obstructs the
global group structure, not the local reconstruction of the fibre from two points.
The complex reconstruction (Section 3) reduces to two bilinear identities and one
norm-multiplicativity step, each with quaternionic and octonionic analogues via
the two- and four-square identities, so the same proof skeleton should transport
dimension by dimension.

**Conjecture B (Isoperimetric flat tori, all $m$).** Among all flat $m$-tori in
$S^{2m-1}$ with $\sum r_i^2 = 1$, the balanced torus uniquely maximizes volume,
with growth $m^{-m/2}$. Section 5 establishes this in full; the remaining program
is to extend the monotonicity-plus-AM–GM template to weighted and constrained
variants (e.g. tori with prescribed homology class).

**Conjecture C (Classification of order-4 fixed-point-free isometries).** Every
fixed-point-free linear isometry of $S^{2n-1}$ of order dividing four is conjugate
to multiplication by $i$ on $\mathbb{C}^n$; equivalently, "rotation through the
fourth dimension" is, up to a change of coordinates, the only algebraic complex
structure available. Fixed-point freeness is equivalent to the absence of the
eigenvalue $1$; for an order-4 isometry this forces the $\pm i$ eigenspaces to
pair the coordinates exactly as a complex structure does. Section 4 makes the
obstruction concrete; turning necessity into a classification is the natural next
step.

**Conjecture D (Termination of the ladder).** There is no bilinear identity
expressing a product of two sums of three (respectively five, six, seven) squares
as a sum of the same number of squares; the ladder terminates at four before
leaping to eight. Section 6 proves the odd cases via the determinant obstruction;
the even case $d = 6$ needs the Hurwitz–Radon count.

**Conjecture E (Conjugation rigidity characterizes the rotation group).** The
isometries of $S^3$ of the form $x \mapsto qxq^{-1}$, together with left/right
translations, generate $SO(4)$, and the kernel of the double cover is exactly
$\{\pm 1\}$. Section 7 supplies the norm-preservation core for every nonzero $q$;
assembling the generation and covering statements is a group-theoretic
continuation of the same computation.

The overarching thesis is that the fourth dimension — and, more generally, the
dimensions $1, 2, 4, 8$ — form a composition-algebra playground whose geometry is
governed by a very small number of sharp algebraic facts. Learning the algebra of
length gives the geometry.

---

## Appendix: summary of results

| Result | Statement | Key mechanism |
|--------|-----------|---------------|
| Thm 3.1–3.4 | Inner product reconstructs the complex Hopf fibre | $\lVert z'-\lambda z\rVert^2 + \lVert w'-\lambda w\rVert^2 = 1-|\lambda|^2$ |
| Thm 4.1–4.4 | $\cdot i$ is a fixed-point-free isometry of $S^{2n-1}$ | $i - 1 \ne 0$ |
| Thm 5.1–5.5 | Balanced torus uniquely maximizes volume ($m^{-m/2}$) | $m$-variable AM–GM + equality case |
| Thm 6.1–6.4 | Two- and four-square identities; odd dimensions obstructed | $(\det J)^2 = (-1)^n$ |
| Thm 7.1–7.5 | $x \mapsto qxq^{-1}$ preserves the norm for all nonzero $q$ | multiplicativity of $N$ |
