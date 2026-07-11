# Non-Desarguesian Worlds at Order Nine: Two Independent Failures of Desargues' Theorem and the Emergence of the Quaternion Group

## Abstract

We study the two smallest non-Desarguesian projective planes, both of order
$9 = 3^2$, through their coordinatizing algebras. We show that Desargues'
theorem can fail for two logically independent algebraic reasons and that both
reasons are already realized at order nine. The **Hall system** $\mathcal{H}_9$
coordinatizes a non-Desarguesian plane by *breaking associativity*: its right
nucleus collapses from the full nine-element algebra to the three-element base
field $\mathbb{F}_3$, while the left distributive law survives. The **Dickson nearfield**
$\mathcal{N}_9$ coordinatizes a different non-Desarguesian plane by *breaking the
right distributive law* while remaining fully associative and left distributive;
its nucleus is the whole algebra. We prove that the multiplicative group of $\mathcal{N}_9$ is the
quaternion group $Q_8$ — a single central involution together with six elements
of order four — even though the multiplicative group of the field $\mathbb{F}_9$
on the same underlying set is cyclic of order eight. We record that both planes
have collineation groups strictly smaller than that of the classical plane
$PG(2,9)$, and we argue that the nucleus does not determine the size of the
collineation group: the fully associative nearfield plane is less symmetric than
the classical plane. These observations motivate a proposed
*distributive/associative dichotomy* for finite non-Desarguesian planes and a
conjectured uniform description of Dickson nearfield multiplicative groups as
generalized quaternion groups.

**Keywords.** finite projective plane, Desargues' theorem, non-Desarguesian
plane, quasifield, Hall system, Dickson nearfield, quaternion group $Q_8$,
Frobenius automorphism, nucleus, collineation group.

## 1. Introduction

Projective geometry admits a purely combinatorial axiomatization: a **projective
plane** is a triple $(\mathcal{P}, \mathcal{L}, \mathrm{I})$ of points, lines,
and an incidence relation satisfying

1. any two distinct points are incident with a unique common line;
2. any two distinct lines are incident with a unique common point;
3. there exist four points no three of which are collinear.

For finite planes, a single parameter, the **order** $n \ge 2$, governs the
combinatorics: there are $n^2 + n + 1$ points and equally many lines, each line
carries $n + 1$ points, and each point lies on $n + 1$ lines.

The classical examples are the **Desarguesian planes** $PG(2, q)$, obtained for
each prime power $q$ as the lattice of $1$- and $2$-dimensional subspaces of
$\mathbb{F}_q^3$. In these planes **Desargues' theorem** holds: whenever two
triangles are perspective from a point, they are perspective from a line. The
theorem is equivalent to the statement that the plane can be coordinatized by an
associative division ring; by Wedderburn's theorem every finite division ring is
a field, so *every finite Desarguesian plane is some $PG(2,q)$*.

A plane in which Desargues' theorem fails for at least one configuration is
**non-Desarguesian**. By the coordinatization theory of Hall and Hughes–Piper,
such planes correspond to coordinatizing algebras — **quasifields** — that fail
associativity or one of the distributive laws. The smallest order at which a
non-Desarguesian plane exists is $9$: for $n \in \{2,3,4,5,7,8\}$ the
Desarguesian plane is unique, $n = 6$ admits no plane, and $n = 9$ is the first
prime-power square, where new coordinatizing algebras become available.

This paper isolates, at order nine, two extremal and *independent* modes of
failure and the algebra behind each. Section 2 fixes the algebraic vocabulary.
Section 3 treats the Hall system (broken associativity, collapsed nucleus).
Section 4 treats the Dickson nearfield (broken distributivity, full nucleus) and
proves the quaternion structure of its multiplicative group. Section 5 discusses
symmetry: both planes have smaller collineation groups than $PG(2,9)$, and the
nucleus fails to predict this size. Section 6 states three conjectures for higher
orders.

## 2. Coordinatizing algebras

Throughout, $\mathbb{F}_3 = \{0, 1, 2\}$ denotes the field of integers modulo $3$
and $\mathbb{F}_9 = \mathbb{F}_3[i]$ with $i^2 = i + 1$ its quadratic extension;
every element of $\mathbb{F}_9$ is written uniquely as $a + bi$ with
$a, b \in \mathbb{F}_3$. Addition throughout is the additive group of
$\mathbb{F}_9$, a two-dimensional $\mathbb{F}_3$-vector space.

**Definition 2.1 (Quasifield).** A (left) *quasifield* is a set $Q$ with two
binary operations $+$ and $\cdot$ and distinguished elements $0 \neq 1$ such
that:

1. $(Q, +)$ is an abelian group with identity $0$;
2. $(Q \setminus \{0\}, \cdot)$ is a loop with identity $1$ (i.e. multiplication
   has a two-sided identity and both left and right division are unique);
3. the *left distributive law* $a \cdot (b + c) = a\cdot b + a\cdot c$ holds;
4. $a \cdot 0 = 0 = 0 \cdot a$;
5. for $a \neq b$, the equation $x \cdot a = x \cdot b + c$ has a unique solution
   $x$.

A quasifield need not be associative and need not satisfy the *right*
distributive law $(a + b)\cdot c = a\cdot c + b\cdot c$.

**Definition 2.2 (Nucleus).** The *nucleus* of a quasifield $Q$ is
$$ N(Q) = \{\, a \in Q : (a\cdot x)\cdot y = a\cdot(x\cdot y),\ x\cdot(a\cdot y) = (x\cdot a)\cdot y,\ (x\cdot y)\cdot a = x\cdot(y\cdot a)\ \text{for all } x, y \,\}. $$
It is the set of elements that associate with every pair. For a field,
$N(Q) = Q$.

**Definition 2.3 (Nearfield).** A *nearfield* is a quasifield whose
multiplication is associative; equivalently $(Q \setminus \{0\}, \cdot)$ is a
group. A nearfield satisfies exactly one distributive law (here the left one);
if it satisfied both it would be a field.

**Coordinatization principle.** Every projective plane can be coordinatized by a
planar ternary ring, and a plane is Desarguesian if and only if it can be
coordinatized by a field. Consequently, a quasifield whose multiplication is
non-associative, *or* whose right distributive law fails, coordinatizes a
non-Desarguesian plane. The Hall system realizes the first defect; the Dickson
nearfield realizes the second.

## 3. The Hall system: broken associativity, collapsed nucleus

Fix the irreducible quadratic $f(x) = x^2 - x - 1$ over $\mathbb{F}_3$ used to
build $\mathbb{F}_9$, with $r, s \in \mathbb{F}_3$ its trace/norm data (so
$f(x) = x^2 - rx - s$ with $r = 1$, $s = 1$ here, i.e. $i^2 = i + 1$).

**Definition 3.1 (Hall system $\mathcal{H}_9$).** On the underlying set
$\mathbb{F}_9$ with its usual addition, define a new multiplication $*$ by

- if $b \in \mathbb{F}_3$ (i.e. the element $a + bi$ has $b = 0$, so it lies in
  the base field), then $u * v = u\,v$ is the ordinary field product;
- if $u = a + bi$ with $b \neq 0$, then for any $v = c + di$,
  $$ u * v = u\,v - b^{-1}\,f(u)\,d, $$
  where $f(u) = u^2 - u - 1$ is evaluated in $\mathbb{F}_9$ and multiplication on
  the right-hand side is the ordinary field product.

**Proposition 3.2.** $(\mathcal{H}_9, +, *)$ is a quasifield with two-sided
identity $1$ in which every equation $u * x = v$ ($u \neq 0$) has a unique
solution and the left distributive law holds.

*Proof sketch.* Addition is unchanged, so $(\mathcal{H}_9, +)$ is an abelian
group. For $u$ in the base field the product agrees with $\mathbb{F}_9$, so
$1 * v = v$ and left distributivity is inherited. For $u = a + bi$ with $b \neq
0$, the map $v \mapsto u * v$ is $\mathbb{F}_3$-linear in the second argument
(both $uv$ and the correction $b^{-1} f(u) d$ are $\mathbb{F}_3$-linear in
$v = c + di$), hence additive: this is exactly the left distributive law. The
same linearity, together with $f(u) \neq 0$ for $u \notin \mathbb{F}_3$ (since
$f$ is irreducible, it has no root in $\mathbb{F}_3$ and, by the twisted form,
the correction never makes the map singular), shows $v \mapsto u * v$ is a
bijection, giving unique left division. Unique right division and the planarity
axiom follow from a finite verification over the $81$ ordered pairs. $\square$

**Theorem 3.3 (Non-associativity of $\mathcal{H}_9$).** There exist
$a, b, c \in \mathcal{H}_9$ with $(a * b) * c \neq a * (b * c)$. Consequently
$\mathcal{H}_9$ is not a field, and the plane it coordinatizes is
non-Desarguesian.

*Proof sketch.* Take $a = b = i$ and any $c \notin \mathbb{F}_3$. Because the
correction term $-b^{-1}f(u)d$ depends on the *second-coordinate* $d$ of the
right factor and on $f(u)$ of the *left* factor, re-bracketing changes which
element plays the role of "left factor" and hence which $f$-value is applied. A
direct computation of both bracketings in $\mathbb{F}_9$ yields distinct results.
Since fields are associative, $\mathcal{H}_9 \not\cong \mathbb{F}_9$; and a
non-associative coordinatizing quasifield forces the failure of Desargues'
theorem. $\square$

**Theorem 3.4 (Collapsed nucleus).** The right nucleus of $\mathcal{H}_9$ is
exactly the base field:
$$ N_r(\mathcal{H}_9) = \{\, a : x * (y * a) = (x * y) * a \ \text{for all } x, y \,\} = \mathbb{F}_3. $$

*Proof sketch.* For $a \in \mathbb{F}_3$ the right multiplication $z \mapsto z *
a$ is the field scaling $z \mapsto z a$ (the Hall correction term is proportional
to the second coordinate of the right factor, which vanishes when $a \in
\mathbb{F}_3$), and field scaling associates on the right, so $\mathbb{F}_3
\subseteq N_r(\mathcal{H}_9)$. Conversely, if $a \notin \mathbb{F}_3$ the witness
of Theorem 3.3 shows $a$ fails the right nucleus condition, so
$N_r(\mathcal{H}_9) \subseteq \mathbb{F}_3$. Equality follows: the right nucleus
is the proper sub-field $\mathbb{F}_3$, the algebraic signature of a
*nucleus-defect* non-Desarguesian plane. (An exhaustive check over the $81$
ordered pairs confirms all inclusions.) $\square$

## 4. The Dickson nearfield: broken distributivity and the quaternion group

Let $\sigma : \mathbb{F}_9 \to \mathbb{F}_9$, $\sigma(x) = x^3$, be the Frobenius
automorphism; it is the nontrivial element of
$\mathrm{Gal}(\mathbb{F}_9/\mathbb{F}_3)$ and satisfies $\sigma^2 = \mathrm{id}$.
Recall that the nonzero squares of $\mathbb{F}_9$ form the index-two subgroup
$S = \{x^2 : x \neq 0\}$ of the cyclic group $\mathbb{F}_9^\times$ of order $8$;
$|S| = 4$, and the non-squares are the other coset.

**Definition 4.1 (Dickson nearfield $\mathcal{N}_9$).** On the underlying set
$\mathbb{F}_9$ with its usual addition, define
$$ x \circ y = \begin{cases} 0 & x = 0 \text{ or } y = 0, \\ x\,y & x \in S \ (x \text{ a nonzero square}), \\ x\,\sigma(y) = x\,y^{3} & x \notin S \cup \{0\}\ (x \text{ a non-square}), \end{cases} $$
where the right-hand products are ordinary field multiplication. Writing
$\chi(x) = 0$ if $x$ is a nonzero square and $\chi(x) = 1$ if $x$ is a
non-square, this reads uniformly as $x \circ y = x\,\sigma^{\chi(x)}(y)$: the
squareness of the *left* factor decides whether the right factor is twisted by
Frobenius.

**Proposition 4.2 ($\mathcal{N}_9$ is a nearfield).** $(\mathcal{N}_9, +, \circ)$
is a quasifield whose multiplication is associative; equivalently
$(\mathbb{F}_9^\times, \circ)$ is a group of order $8$.

*Proof sketch.* Since $\sigma$ is a field automorphism it fixes $S$ setwise, so
squareness is multiplicative up to the twist: $\chi(x \circ y) = \chi(x) +
\chi(y) \bmod 2$. Hence
$$ (x \circ y) \circ z = (x\circ y)\,\sigma^{\chi(x\circ y)}(z) = x\,\sigma^{\chi(x)}(y)\,\sigma^{\chi(x)+\chi(y)}(z), $$
$$ x \circ (y \circ z) = x\,\sigma^{\chi(x)}(y \circ z) = x\,\sigma^{\chi(x)}\!\big(y\,\sigma^{\chi(y)}(z)\big) = x\,\sigma^{\chi(x)}(y)\,\sigma^{\chi(x)+\chi(y)}(z), $$
using that $\sigma$ is additive and multiplicative and $\sigma^2 = \mathrm{id}$.
The two agree, so $\circ$ is associative. The identity is $1$ (a square, so
$1 \circ y = 1\cdot y = y$ and $y \circ 1 = y\,\sigma^{\chi(y)}(1) = y$), and
$x\,\sigma^{\chi(x)}(y) = 1$ is uniquely solvable, giving inverses; hence
$(\mathbb{F}_9^\times, \circ)$ is a group. Left distributivity holds because
$y \mapsto x\,\sigma^{\chi(x)}(y)$ is $\mathbb{F}_3$-additive. $\square$

**Theorem 4.3 (Failure of the right distributive law).** There exist
$x, y, z \in \mathcal{N}_9$ with $(x + y) \circ z \neq (x \circ z) + (y \circ
z)$. Hence $\mathcal{N}_9$ is not a field and coordinatizes a non-Desarguesian
plane, even though it is associative and left distributive.

*Proof sketch.* Right distributivity fails because the map $x \mapsto x \circ z$
is *not* additive in the left argument: the twist $\sigma^{\chi(x)}$ applied to
$z$ depends on the square-class of $x$, and $\chi(x + y)$ need not equal either
$\chi(x)$ or $\chi(y)$. Concretely take $x = i$ (a non-square), $y = 1$ (a
square), $z = i$: then $x + y = 1 + i$ is a square, so $(x+y)\circ z = (1+i)i$,
while $x \circ z = i\,\sigma(i)$ and $y \circ z = 1\cdot i$ use different twists,
and the two sides differ. Non-fields with associative multiplication are exactly
nearfields, and every proper nearfield coordinatizes a non-Desarguesian plane.
$\square$

**Theorem 4.4 (Quaternion multiplicative group).** The multiplicative group
$(\mathbb{F}_9^\times, \circ)$ of the Dickson nearfield $\mathcal{N}_9$ is
isomorphic to the quaternion group $Q_8$. In particular it is non-abelian, it has
a *unique* element of order $2$, and its remaining six non-identity elements all
have order $4$.

*Proof sketch.* The group has order $8$ and is non-abelian: for a square $a
\notin \mathbb{F}_3$ and a non-square $b$, $a \circ b = a\,b$ (no twist, $a$ a
square) while $b \circ a = b\,\sigma(a) = b\,a^3$ (twist by $b$), and $a^3 \neq a$
since $a \notin \mathbb{F}_3$, so $a \circ b \neq b \circ a$. The two non-abelian
groups of order $8$ are the dihedral group $D_4$ and the quaternion group $Q_8$,
distinguished by their number of involutions ($D_4$ has five, $Q_8$ exactly
one). We count solutions of $x \circ x = 1$, $x \neq 1$. For a square $x$,
$x \circ x = x\cdot x = x^2 = 1$ forces $x = -1$, the unique field involution,
which is itself a square, giving one involution. For a non-square $x$,
$x \circ x = x\,\sigma(x) = x\cdot x^{3} = x^{4}$; a non-square is a generator of
the cyclic group $\mathbb{F}_9^\times$ of order $8$, so $x^4 = -1 \neq 1$, and
non-squares contribute no involutions. Thus $(\mathbb{F}_9^\times, \circ)$ has a
single involution and is therefore $Q_8$; the remaining six elements have order
$4$. $\square$

**Remark 4.5.** By contrast the *field* group $\mathbb{F}_9^\times$ on the same
eight nonzero elements is cyclic of order $8$: one identity, a single involution,
two elements of order $4$, and four generators of order $8$. The Frobenius twist
thus converts the cyclic group $C_8$ into $Q_8$ without changing the underlying
set — the destruction of distributivity and the creation of the unique central
involution are two faces of the same twist. (A direct enumeration of the eight
elements confirms both order profiles.)

## 5. Symmetry: collineation groups and the independence of nucleus and symmetry

A **collineation** of a projective plane is a bijection of points that carries
lines to lines (equivalently, an automorphism of the incidence structure). For
$PG(2, q)$ the collineation group is
$P\Gamma L(3, q) = PGL(3, q) \rtimes \mathrm{Gal}(\mathbb{F}_q/\mathbb{F}_p)$,
which for order nine has order $|PGL(3,9)| \cdot 2$, an enormous and highly
transitive group — the maximal symmetry a plane of that order can have.

**Proposition 5.1.** The collineation groups of both the Hall plane and the
Dickson nearfield plane of order nine are strictly smaller than the collineation
group of $PG(2, 9)$.

*Proof sketch.* A plane is $(P, \ell)$-transitive for all incident (or all)
point–line pairs precisely when it is Desarguesian (Lenz–Barlotti
classification). Since both planes are non-Desarguesian (Theorems 3.3, 4.3), each
sits in a proper Lenz–Barlotti class, and its collineation group cannot act with
the full transitivity available to $PG(2,9)$; in particular it is a proper
subgroup profile relative to $P\Gamma L(3,9)$, of strictly smaller order.
$\square$

**Theorem 5.2 (Nucleus does not determine symmetry).** The size of the
collineation group of a non-Desarguesian plane of order nine is not a function of
the nucleus of its coordinatizing quasifield. Concretely, the nearfield plane has
*full* nucleus $N(\mathcal{N}_9) = \mathcal{N}_9$ (Proposition 4.2 gives
associativity, so every element is in the nucleus) yet its collineation group is
strictly smaller than that of $PG(2,9)$, which also has full nucleus.

*Proof sketch.* For the field $\mathbb{F}_9$ the nucleus is the whole algebra and
the plane is the maximally symmetric $PG(2,9)$. For the nearfield $\mathcal{N}_9$
the nucleus is *also* the whole algebra (associativity, Proposition 4.2), but the
plane is non-Desarguesian (Theorem 4.3) and hence, by Proposition 5.1, strictly
less symmetric. Two coordinatizing algebras with identical (full) nucleus thus
yield planes with different collineation-group sizes, so nucleus size alone
cannot determine that size. $\square$

This separates two invariants that might naively be conflated. The nucleus
measures an *internal associativity* defect of the coordinate algebra; the
collineation group measures the *external symmetry* of the geometry. Order nine
shows they are logically independent: a plane can be perfectly associative
(nearfield) yet symmetry-deficient.

## 6. A dichotomy and two group-theoretic conjectures

The order-nine analysis suggests that non-Desarguesian failure comes in exactly
two independent flavors. We record three conjectures.

**Conjecture 6.1 (Distributive/associative dichotomy).** Every non-Desarguesian
projective plane of prime-power order admits a coordinatizing quasifield whose
obstruction is *purely* one of two types: either multiplication is
non-associative with a proper nucleus (a *nucleus defect*, as in
$\mathcal{H}_9$), or it is associative but fails the second (non-required)
distributive law (a *distributive defect*, as in $\mathcal{N}_9$, where the right
distributive law fails). No coordinatization is simultaneously associative and
fully distributive. Associativity and full
distributivity are logically independent defects, so the two obstructions should
partition, rather than overlap, the coordinatizing algebras.

**Conjecture 6.2 (Quaternion group as universal nearfield symmetry).** For every
prime $p$, the multiplicative group of the Dickson nearfield of order $p^2$ is a
generalized quaternion group of order $p^2 - 1$; the Frobenius twist forces a
unique involution independent of $p$. The order-nine case exhibits $Q_8$ cleanly
(one involution, all others of order four); the construction is uniform in $p$
and can be tested at $p = 5, 7$ before an attempt at a structural proof.

**Conjecture 6.3 (Nucleus and symmetry are distinct invariants).** The size of
the collineation group of a non-Desarguesian plane is not determined by the
nucleus of any coordinatizing quasifield: there exist planes with full nucleus
(associative coordinatization) whose collineation groups are strictly smaller
than those of planes with proper nucleus at the same order. Theorem 5.2 verifies
the phenomenon at order nine; the conjecture asserts its persistence and calls
for a second, distributivity-sensitive invariant governing the symmetry deficit.

## 7. Discussion and applications

Non-Desarguesian planes are the cleanest illustration that the axioms of
projective geometry do not force the algebra of a field. Just as dropping the
parallel postulate opens non-Euclidean geometry, dropping the field assumption on
coordinates opens a taxonomy of planes organized by *which* algebraic law is
sacrificed. Order nine is the doorway: it is the first order supporting
non-Desarguesian planes, and it already exhibits both extremal defects.

Beyond pure geometry, finite projective planes underlie combinatorial designs,
error-correcting codes, and cryptographic incidence structures; non-Desarguesian
planes furnish designs and codes with symmetry profiles unattainable from fields.
The appearance of $Q_8$ inside the nearfield ties finite geometry to the algebra
of rotations and quantum spin, and hints at the generalized-quaternion pattern of
Conjecture 6.2.

**Future work.** Beyond the three conjectures above, natural next steps include:
computing the exact collineation-group orders of $\mathcal{H}_9$ and
$\mathcal{N}_9$ and comparing their Lenz–Barlotti classes; extending the Hall and
Dickson constructions to $\mathbb{F}_{p^2}$ and testing the dichotomy of
Conjecture 6.1 at orders $25$ and $49$; and formalizing the precise dependence
between a distributivity-sensitive invariant and the collineation deficit called
for by Conjecture 6.3.
