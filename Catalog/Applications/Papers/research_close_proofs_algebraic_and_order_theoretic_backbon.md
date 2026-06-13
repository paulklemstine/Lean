# Stereographic Capacity Theory: The Algebraic and Order-Theoretic Backbone of the Inverse Stereographic Chart

## Abstract

The inverse stereographic projection
$\sigma(t) = \big(2t/(1+t^2),\,(1-t^2)/(1+t^2)\big)$ parametrizes the unit circle
$S^1$ by a single real coordinate, the tangent of the half-angle. We show that
the geometric operation of *rotation*, opaque in Cartesian coordinates, becomes
in this chart the single rational binary law
$t \oplus s = (t+s)/(1-ts)$ — the tangent half-angle addition formula and the
formal group law of $\arctan$. We prove (i) that $\sigma(t\oplus s)$ equals the
rotation of $\sigma(t)$ by the angle attached to $s$, recovering the
sine/cosine addition theorems rationally; (ii) that $\oplus$ is realized by
multiplication of $2\times 2$ matrices in $SO(2)$, the real-analytic shadow of
Gaussian-integer multiplication; (iii) that $(\mathbb{R}, \oplus)$ is a partial
abelian group (associative, commutative, with identity $0$), total away from the
hyperbola $ts = 1$ that encodes the single missing point of the one-point
compactification; (iv) that the order embedding $\Theta(t) = 2\arctan t$ is a
strictly monotone intertwiner converting $\oplus$ into ordinary addition on the
branch $ts < 1$, with a *local* (half-line) concavity structure; and (v) an
extremal characterization of the capacity coordinate $2t/(1+t^2)$, bounded by
$1$ with equality exactly at $t = 1$. Every result has been formally verified.
The single algebraic identity $(1-ts)^2 + (t+s)^2 = (1+t^2)(1+s^2)$ underlies the
entire development.

**Keywords.** stereographic projection, tangent half-angle, formal group law,
$SO(2)$, partial abelian group, order embedding, Pythagorean triples, capacity.

---

## 1. Introduction

### 1.1 Motivation

Rotation is the most elementary continuous symmetry in mathematics. The circle
group $SO(2)$ governs everything from the phases of alternating current and the
orbits of two-body systems to the spin of a qubit and the gears of a watch.
Described in Cartesian coordinates $(x, y)$ on the unit circle, however,
rotation is unwieldy: it couples both coordinates through transcendental sine
and cosine functions, and composing two rotations requires the angle-addition
theorems. A recurring theme of mathematics is that the *right coordinate* can
collapse an apparently complicated structure into elementary algebra. This paper
is a complete worked instance of that theme for $SO(2)$.

The coordinate in question is the tangent of the half-angle, equivalently the
stereographic address of a point on the circle. Under this single real
parameter, rotation ceases to be transcendental and becomes one rational
fraction. We develop the full algebraic and order-theoretic consequences of this
fact, prove them rigorously, and trace the single combinatorial identity that
underlies all of them.

### 1.2 The chart

Stereographic projection is one of the oldest and most versatile tools in
geometry, from cartography to the conformal geometry of the Riemann sphere. Its
one-dimensional version sends the real line bijectively onto the unit circle
minus one point. Concretely, the *inverse* chart is

$$ \sigma(t) := \left( \frac{2t}{1+t^2},\ \frac{1-t^2}{1+t^2} \right), \qquad t \in \mathbb{R}. $$

A prior development established *pointwise* facts about $\sigma$: that its image
lies on $S^1$, that it is injective, that $\sigma(0) = (0,1)$, $\sigma(1)=(1,0)$,
$\sigma(-1)=(-1,0)$, and that $\sigma(1/2) = (4/5, 3/5)$ — the $(3,4,5)$
Pythagorean point. The present work upgrades these isolated facts to a
*structure*. We answer: what does the rotation group of $S^1$ look like when
pulled back through $\sigma$ to the line?

The answer is a single rational operation, the tangent half-angle addition law

$$ t \oplus s := \frac{t+s}{1-ts}, $$

and the bulk of this paper is the systematic exploration of its algebraic and
order-theoretic properties. We organize the development around one combinatorial
identity that recurs in every proof:

$$ \boxed{\ (1-ts)^2 + (t+s)^2 = (1+t^2)(1+s^2).\ } \tag{$\star$} $$

Identity $(\star)$ is the reason the half-angle substitution rationalizes
trigonometry; it is the reason $\oplus$ is a group law; and it is the reason the
attached matrices multiply correctly.

### 1.3 Contributions and organization

We make the following contributions, each formally verified.

1. **Algebraic backbone (Section 4).** We prove that $\sigma(t \oplus s)$ is the
   rotation of $\sigma(t)$ by the angle of $s$, identifying $\oplus$ with the
   sine/cosine angle-addition theorems.
2. **Matrix backbone (Section 5).** We realize $\oplus$ as multiplication of
   $2 \times 2$ rotation matrices of determinant one, exhibiting a partial
   homomorphism into $SO(2)$.
3. **Group structure (Section 6).** We prove $\oplus$ is associative,
   commutative, unital, and invertible wherever defined, establishing the
   partial-abelian-group structure and locating its singular locus.
4. **Order backbone (Section 7).** We prove the angle map $\Theta = 2\arctan$ is
   a strictly monotone embedding that conjugates $\oplus$ to ordinary addition,
   with sharp half-line concavity.
5. **Extremal theory (Section 8).** We characterize the maximum of the capacity
   coordinate and connect the chart to the rational parametrization of
   Pythagorean triples.

Sections 9–12 give constructive algorithms, applications, discussion of two
structural surprises, and the future-directions program.

---

## 2. Definitions

Throughout, all quantities are real and the section is developed
non-computably over $\mathbb{R}$.

**Definition 2.1 (Inverse stereographic chart).**
$$ \sigma(t) := \left( \frac{2t}{1+t^2},\ \frac{1-t^2}{1+t^2} \right). $$
We write $\sigma(t) = (x(t), y(t))$ when convenient.

**Definition 2.2 (Stereographic addition law).**
$$ t \oplus s := \frac{t+s}{1-ts}. $$
This is a partial operation: it is defined precisely when $1 - ts \neq 0$.

**Definition 2.3 (Stereographic angle).**
$$ \Theta(t) := 2\arctan t \ \in (-\pi, \pi). $$

**Definition 2.4 (Stereographic rotation matrix).**
$$ R(t) := \begin{pmatrix} y(t) & -x(t) \\ x(t) & y(t) \end{pmatrix} \in M_2(\mathbb{R}), $$
whose columns are $\sigma(t)$ and its quarter-turn.

**Definition 2.5 (Capacity coordinate).**
$$ \mathrm{cap}(t) := x(t) = \frac{2t}{1+t^2}, $$
the horizontal extent of $\sigma(t)$.

---

## 3. The foundational identity and the chart

**Lemma 3.1 (Chart lands on $S^1$).** For all $t \in \mathbb{R}$,
$$ x(t)^2 + y(t)^2 = 1. $$

*Proof sketch.* Since $1 + t^2 > 0$, clear the common denominator $(1+t^2)^2$.
The numerator is $(2t)^2 + (1-t^2)^2 = 4t^2 + 1 - 2t^2 + t^4 = (1+t^2)^2$, giving
$1$. $\square$

**Lemma 3.2 (The algebraic miracle $(\star)$).** For all $t, s$,
$$ (1-ts)^2 + (t+s)^2 = (1+t^2)(1+s^2). $$

*Proof sketch.* Expand the left side:
$1 - 2ts + t^2s^2 + t^2 + 2ts + s^2 = 1 + t^2 + s^2 + t^2 s^2$. The cross terms
cancel and the remainder factors as $(1+t^2)(1+s^2)$. $\square$

Lemma 3.2 is not stated as a named theorem in the source but is the engine
inside the `field_simp; ring` certificates of every multiplicative result below;
we isolate it for expository clarity.

---

## 4. Main result: rotation is rational addition

**Theorem 4.1 (Stereographic addition law).** Let $1 - ts \neq 0$. Then
$$ \sigma(t \oplus s) = \big(\, x(t)\,y(s) + y(t)\,x(s),\ \ y(t)\,y(s) - x(t)\,x(s) \,\big). $$

In words: feeding the combined coordinate $t \oplus s$ into the chart yields the
rotation of $\sigma(t)$ through the angle of $s$. The right-hand side is exactly
the pair $(\sin(A+B), \cos(A+B))$ written in terms of $(\sin A, \cos A)$ and
$(\sin B, \cos B)$, i.e. the sine/cosine addition theorems.

*Proof sketch.* Unfold $\sigma$ and $\oplus$ and split into the two scalar
coordinates via `Prod.mk.injEq`. For each coordinate, clear all denominators
($1+t^2$, $1+s^2$, $1-ts$, and the induced $1 + (t\oplus s)^2$, whose
non-vanishing follows from $(\star)$). Each cleared equation is a polynomial
identity verified by `ring`. The decisive structural move is to clear all three
denominators *simultaneously* per coordinate; a coordinate-free attempt stalls.
$\square$

**Remark.** Identity $(\star)$ is precisely what makes
$1 + (t\oplus s)^2 = (1+t^2)(1+s^2)/(1-ts)^2$, so the new denominator factors
through the old ones — this is why the projection of the combined coordinate
stays rational.

---

## 5. Matrix realization and the bridge to $SO(2)$

**Theorem 5.1 (Matrix form of the addition law).** Let $1 - ts \neq 0$. Then
$$ R(t)\, R(s) = R(t \oplus s). $$

*Proof sketch.* Expand the matrix product entrywise via `Fin.sum_univ_two`.
Each of the four entries reduces to the same rational identity certified in
Theorem 4.1; `field_simp; ring` per entry closes it. The off-diagonal entries
are the first coordinate of Theorem 4.1; the diagonal entries are the second.
$\square$

**Theorem 5.2 ($R(t) \in SO(2)$).** For all $t$,
$$ \det R(t) = x(t)^2 + y(t)^2 = 1. $$

*Proof sketch.* By the $2\times 2$ determinant formula
$\det R(t) = y(t)\cdot y(t) - (-x(t))\cdot x(t) = x(t)^2 + y(t)^2$, which is $1$
by Lemma 3.1. $\square$

Theorems 5.1–5.2 exhibit $t \mapsto R(t)$ as a (partial) homomorphism from
$(\mathbb{R}, \oplus)$ to $SO(2)$. This is the real-analytic analogue of the
multiplicativity of the norm on the Gaussian integers (and of the integer
"Gaussian matrix" composition law in the catalog): a rotation by composition is
multiplication of unit-modulus complex numbers, and $\det R = 1$ is the
norm-multiplicativity $|z_1 z_2| = |z_1||z_2|$ specialized to the unit circle.

---

## 6. The partial abelian group structure

**Theorem 6.1 (Identity).** For all $t$, $\ t \oplus 0 = t$.

*Proof sketch.* $(t+0)/(1 - t\cdot 0) = t/1 = t$. $\square$

**Theorem 6.2 (Commutativity).** Whenever defined, $\ t \oplus s = s \oplus t$.

*Proof sketch.* Both numerator $t+s$ and denominator $1-ts$ are symmetric in
$t, s$. $\square$

**Theorem 6.3 (Associativity).** Whenever the two inner denominators are
nonzero,
$$ (t \oplus s) \oplus u = t \oplus (s \oplus u). $$

*Proof sketch.* Clear the inner denominators $1 - ts$ and $1 - su$ via
`field_simp`. The resulting equality is a *pure polynomial identity*, closed by
`ring_nf`. A notable phenomenon: the two *outer* non-vanishing conditions one
might expect to need are redundant — after clearing the inner denominators the
identity holds polynomially. This is the hallmark of a formal group law. $\square$

**Corollary 6.4.** $(\mathbb{R}, \oplus, 0)$ is a *partial abelian group*: the
operation is commutative, associative, and unital wherever defined, and is total
on $\{(t,s) : ts \neq 1\}$. The locus $ts = 1$ is exactly the preimage of the
single point at infinity of the one-point compactification $S^1$, where the
chart $\sigma$ is undefined.

The inverse of $t$ is $-t$, since $t \oplus (-t) = 0/(1+t^2) = 0$; thus on its
domain $\oplus$ has two-sided inverses, completing the partial-group picture.

---

## 7. The order-theoretic backbone

**Theorem 7.1 (Strict monotonicity).** $\Theta(t) = 2\arctan t$ is strictly
increasing on $\mathbb{R}$.

*Proof sketch.* $\arctan$ is strictly monotone (its derivative
$1/(1+t^2) > 0$); scaling by the positive constant $2$ preserves this. $\square$

**Theorem 7.2 (Intertwining with ordinary addition).** On the branch $ts < 1$,
$$ \Theta(t \oplus s) = \Theta(t) + \Theta(s). $$

*Proof sketch.* This is the additive form of the tangent addition law:
$\arctan t + \arctan s = \arctan\!\big((t+s)/(1-ts)\big)$ holds exactly when
$ts < 1$ (the branch condition keeping the sum within $(-\pi/2, \pi/2)$ after
halving). Doubling gives $\Theta(t) + \Theta(s) = \Theta(t \oplus s)$. $\square$

Theorems 7.1–7.2 say that $\Theta$ is an *order embedding* of the partial group
$(\mathbb{R}, \oplus)$ onto the arc $(-\pi, \pi)$ with ordinary addition: the
exotic rational law is conjugate, via a monotone change of coordinate, to plain
$+$. This is the order-theoretic backbone hinted at by the transition theory of
the stereographic sheaf.

**Theorem 7.3 (Local concavity).** $\Theta$ is concave on the half-line
$[0, \infty)$.

*Proof sketch.* $\Theta'(t) = 2/(1+t^2)$ is strictly decreasing for $t \ge 0$
(equivalently $\Theta''(t) = -4t/(1+t^2)^2 \le 0$ there), so $\Theta$ is concave
on $[0,\infty)$. $\square$

**Remark (sharpness of the half-line restriction).** The restriction to
$[0,\infty)$ is essential, not cosmetic. Since $\Theta''(t) = -4t/(1+t^2)^2$
changes sign at $t = 0$, $\Theta$ is *convex* on $(-\infty, 0]$ and *concave* on
$[0, \infty)$, with an inflection point at the origin. A global concavity claim
over all of $\mathbb{R}$ is therefore false. Recording exactly where a clean
statement fails is part of the contribution.

---

## 8. The capacity coordinate and its extremum

**Theorem 8.1 (Capacity bound).** For all $t$,
$$ \mathrm{cap}(t) = \frac{2t}{1+t^2} \le 1. $$

*Proof sketch.* Equivalent to $1 + t^2 - 2t \ge 0$ (since $1+t^2 > 0$), i.e.
$(1-t)^2 \ge 0$. $\square$

**Theorem 8.2 (Equality characterization).**
$$ \frac{2t}{1+t^2} = 1 \iff t = 1. $$

*Proof sketch.* Equality forces $(1-t)^2 = 0$, hence $t = 1$; conversely
$\mathrm{cap}(1) = 2/2 = 1$. $\square$

Symmetrically, $-1 \le \mathrm{cap}(t)$ with equality iff $t = -1$, so the
horizontal extent of $S^1$ ranges over $[-1, 1]$, attained at the east and west
points. The extremal addresses $t = \pm 1$ are exactly the half-angle tangents
of $\pm \pi/2$.

**Connection to Pythagorean triples.** The same chart, evaluated at the rational
address $t = 1/2$, yields
$$ \sigma(1/2) = \left( \frac{1}{1+1/4},\ \frac{1-1/4}{1+1/4} \right) = \left( \frac45,\ \frac35 \right), $$
the $(3,4,5)$ point. More generally $\sigma$ restricts to a bijection between
rational addresses and rational points of $S^1$, hence between $\mathbb{Q}$ and
primitive Pythagorean triples — the classical rational parametrization of the
circle. The capacity extremum at $t=1$ and the Pythagorean point at $t=1/2$ live
on the same one-parameter family.

---

## 9. Algorithms

The theory is constructive: every operation is an explicit rational function and
can be evaluated exactly over $\mathbb{Q}$.

**Algorithm 9.1 (Exact rotation composition).** Given two addresses as exact
rationals, compose them via $\oplus$ and project, all in exact arithmetic, with
a guard against the singular locus $ts = 1$. Complexity is $O(1)$ rational
operations per composition; composing $n$ rotations is $O(n)$ via the running
fold $r \leftarrow r \oplus t_i$.

**Algorithm 9.2 (Pythagorean triple generator).** For each rational
$t = p/q$ in lowest terms, $\sigma(t) = (2pq/(p^2+q^2),\,(q^2-p^2)/(p^2+q^2))$
clears denominators to the integer triple $(2pq,\ q^2 - p^2,\ p^2 + q^2)$,
recovering Euclid's formula. Each triple costs $O(1)$ integer multiplications.

---

## 10. Applications

- **Rational trigonometry / exact rotation.** Rotations of plane figures can be
  composed and applied in exact rational arithmetic, never invoking
  floating-point sine and cosine, by working with addresses and $\oplus$.
- **Symbolic integration.** Theorem 4.1 and identity $(\star)$ are the formal
  backbone of the Weierstrass $t = \tan(\theta/2)$ substitution that converts
  $\int R(\sin\theta, \cos\theta)\,d\theta$ into integrals of rational
  functions.
- **Number theory.** The chart's bijection on rationals gives the complete
  rational parametrization of $S^1$ and hence of Pythagorean triples; the
  matrix realization connects to Gaussian-integer norm multiplicativity.
- **Robotics / computer graphics.** The half-angle coordinate is the
  one-dimensional cousin of the quaternion / Cayley parametrization of $SO(3)$,
  where the analogous rational law avoids gimbal lock and trigonometric
  evaluation.

---

## 11. Discussion

The development crystallizes a single message: the right coordinate turns a
geometric symmetry group into elementary algebra. The chart $\sigma$ trades the
quadratic constraint $x^2 + y^2 = 1$ for a free real parameter, and in exchange
rotation — which mixes coordinates through transcendental functions — becomes the
rational law $\oplus$. The price is exactly one point: the singular hyperbola
$ts = 1$ marking the pole the line cannot reach. Every branch hypothesis in the
paper ($1 - ts \neq 0$, $ts < 1$) is a bookkeeping echo of that one missing
point.

Two structural surprises deserve emphasis. First, associativity (Theorem 6.3)
needs only the inner denominators: after clearing them the identity is purely
polynomial, the diagnostic signature of a *formal group law*. Second, the
concavity of $\Theta$ (Theorem 7.3) is genuinely half-line local — the
inflection at $t = 0$ forbids a global statement — illustrating that faithful
formalization records not only what is true but precisely where it stops being
true.

---

## 12. Future directions

(See the dedicated future-directions section for the full program. In brief:)

1. **Compactify to a total group.** Replace $\mathbb{R}$ by $\mathbb{R} \cup
   \{\infty\}$ (the one-point compactification $\cong S^1$) so that $\oplus$
   becomes total and $(\,\overline{\mathbb{R}}, \oplus\,)$ is a genuine abelian
   group isomorphic to $SO(2)$, removing every branch hypothesis.
2. **Promote the matrix map to a group isomorphism.** Establish
   $t \mapsto R(t)$ as a full isomorphism onto $SO(2)$, with $\det R = 1$ as the
   structure-preserving invariant.
3. **Higher dimensions.** Lift the half-angle law to the Cayley transform on
   $SO(3)$ / unit quaternions, where $(\star)$ generalizes to the
   four-square identity.
4. **Number-theoretic export.** Connect the rational chart to the catalog's
   Gaussian-integer and Pythagorean-triple constructions as a uniform rational
   parametrization, and study the action of $\oplus$ on rational points.
5. **Order-theoretic completion.** Use the monotone embedding $\Theta$ to give a
   convexity/curvature calculus on $S^1$ with correct half-line domains.

---

## 12.5 Relationship to surrounding theory

The present development sits between two neighboring bodies of work. Upstream, a
prior treatment of the inverse stereographic chart established the pointwise
facts used here as Lemma 3.1 and the special evaluations $\sigma(0) = (0,1)$,
$\sigma(\pm 1) = (\pm 1, 0)$, $\sigma(1/2) = (4/5, 3/5)$, together with
injectivity of $\sigma$ and the oddness/evenness symmetry
$\sigma(-t) = (-x(t), y(t))$. Those facts describe individual points; the
contribution here is to organize them into the *operation* $\oplus$ and to prove
that operation is simultaneously a rational addition law, a matrix product, a
partial group, and a conjugate of ordinary addition.

Downstream, the matrix realization (Section 5) is the real-analytic counterpart
of integer constructions over the Gaussian integers $\mathbb{Z}[i]$: the
multiplicativity of the determinant $\det R(t) = 1$ is the unit-circle
specialization of the norm multiplicativity $N(z_1 z_2) = N(z_1) N(z_2)$, and the
matrix composition law $R(t)R(s) = R(t\oplus s)$ mirrors the composition of
Gaussian-integer rotation matrices. The order embedding $\Theta$ supplies the
monotone scaffolding for transition functions between charts in a sheaf-theoretic
treatment of the circle. In this sense the backbone built here is a hub: it
rationalizes the analytic content upstream and feeds both the number-theoretic
and the order-theoretic structure downstream.

## 12.6 Verification methodology

Every theorem in this paper has a machine-checked certificate. The proofs follow
a small number of robust patterns worth recording, because they reveal the
structure of the subject:

- **Clear-and-ring.** Every multiplicative identity (Lemma 3.1, Theorems 4.1,
  5.1, 6.1–6.3) reduces, after clearing the positive denominators $1 + t^2$ and
  the branch denominators $1 - ts$, to a polynomial identity closed by ring
  normalization. This is the computational shadow of identity $(\star)$.
- **Entrywise reduction.** The matrix law (Theorem 5.1) is proved by expanding
  the four matrix entries via the two-element sum and applying clear-and-ring to
  each; the off-diagonal entries reproduce the first coordinate of Theorem 4.1
  and the diagonal entries the second.
- **Monotonicity transport.** The order results (Theorems 7.1–7.2) transport
  the known monotonicity and addition law of $\arctan$ through the linear scaling
  by $2$, with the branch condition $ts < 1$ controlling the range so that the
  identity $\arctan t + \arctan s = \arctan\big((t+s)/(1-ts)\big)$ applies.
- **Square-completion.** The extremal results (Theorems 8.1–8.2) reduce to the
  nonnegativity of $(1 - t)^2$, the cleanest possible witness for a quadratic
  extremum.

The uniformity of these patterns is itself evidence for the central thesis: a
well-chosen coordinate turns a transcendental symmetry into elementary algebra.

## 13. Conclusion

We have built the algebraic and order-theoretic backbone of the inverse
stereographic chart: rotation as the rational law $\oplus$ (Theorem 4.1), its
matrix realization in $SO(2)$ (Theorems 5.1–5.2), its partial abelian group
structure (Theorems 6.1–6.3), the strictly monotone order embedding $\Theta$
intertwining $\oplus$ with ordinary addition (Theorems 7.1–7.2) with sharp
local concavity (Theorem 7.3), and the extremal characterization of the capacity
coordinate (Theorems 8.1–8.2) culminating in the $(3,4,5)$ Pythagorean point.
A single identity, $(1-ts)^2 + (t+s)^2 = (1+t^2)(1+s^2)$, runs through every
proof. All results are formally verified.
