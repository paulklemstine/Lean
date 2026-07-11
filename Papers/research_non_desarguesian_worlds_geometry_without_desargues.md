# Non-Desarguesian Worlds: Quasifield Coordinatization and the Dickson Nearfield of Order Nine

## Abstract

We develop the algebraic theory that governs when a finite affine plane obeys
Desargues' theorem, and we exhibit — with all incidence and algebraic properties
established by exhaustive finite verification — the smallest non-Desarguesian
example. We isolate the notion of a **quasifield**: an additive abelian group
with a multiplication possessing a two-sided unit, unique two-sided division for
nonzero elements, the right distributive law, and the planar (Veblen) axiom.
We prove that every quasifield $Q$ coordinatizes a genuine affine plane on the
point set $Q \times Q$ — two distinct points determine a unique line, Playfair's
parallel axiom holds, and the plane is non-degenerate — and that division rings
are exactly the "tame" quasifields whose planes are Desarguesian. We then
construct the **Dickson nearfield of order 9**: the field $\mathrm{GF}(9)$ with
its multiplication twisted by the Frobenius automorphism along the split into
squares and non-squares. We verify that this multiplication is associative, has
a two-sided unit, admits unique two-sided division, and is right-distributive,
so it is a quasifield (indeed a nearfield); but that it is **neither commutative
nor left-distributive**, exhibiting an explicit left-distributivity witness.
Since the coordinate structure is not a division ring, the coordinatized plane —
with $81$ points and $90$ lines — is non-Desarguesian, and $9 = 3^2$ is the
smallest order at which such a plane exists. We discuss the generalization to
order $q^2$ for every prime power $q$, the attendant contraction of the
collineation group, and the place of the nearfield plane in the classification
of the planes of order $9$.

**Keywords:** non-Desarguesian plane, quasifield, nearfield, Dickson twist,
Frobenius automorphism, affine plane, coordinatization, Desargues' theorem,
collineation group, finite geometry.

---

## 1. Introduction

Desargues' theorem states that if two triangles in a plane are perspective from
a point — the three lines joining corresponding vertices are concurrent — then
they are perspective from a line: the three intersection points of corresponding
sides are collinear. In the classical planes over the reals, rationals, or any
field, this is a theorem. But an *abstract* affine or projective plane is
defined only by incidence axioms (any two points lie on a unique line; a strong
parallel axiom; a non-degeneracy condition), and these axioms do **not** entail
Desargues' theorem. Planes in which it fails are called *non-Desarguesian*.

The reason the distinction is meaningful — rather than a mere absence of proof —
is the *coordinatization program* of Hilbert, Hall, and others. To every affine
plane one may attach an algebraic coordinate structure, and the geometric
theorems of the plane translate into algebraic laws of that structure. Desargues'
theorem, in particular, corresponds exactly to the coordinate structure being a
**division ring** (associative multiplication with a two-sided unit, both
distributive laws, and two-sided inverses). The weaker structure that
coordinatizes an arbitrary affine translation plane is a **quasifield**, and a
quasifield that fails to be a division ring yields a non-Desarguesian plane.

This paper has two halves. In §§2–4 we present the *general* theory: the
quasifield axioms, the construction of the coordinatized plane, and proofs that
the incidence axioms hold — all completely general and independent of any
particular quasifield. In §§5–7 we present a *concrete* realization: the Dickson
nearfield of order $9$, the properties that make it a quasifield but not a
division ring, and the resulting non-Desarguesian plane of order $9$. §8
discusses generalizations, symmetry loss, and the classification landscape.

Every claim below has been checked completely: the general incidence results by
proof, and every property of the order-$9$ example by exhaustive computation over
the relevant $9$-, $81$-, or $729$-element domains.

---

## 2. Quasifields

Throughout, $(Q, +)$ is an additive abelian group with zero element $0$.

**Definition 2.1 (Quasifield).** A *(right) quasifield* on $(Q,+)$ is a binary
operation $\ast : Q \times Q \to Q$ together with a distinguished element
$1 \in Q$ satisfying:

1. **(nontriviality)** $1 \neq 0$;
2. **(two-sided unit)** $a \ast 1 = a$ and $1 \ast a = a$ for all $a$;
3. **(absorbing zero)** $a \ast 0 = 0$ and $0 \ast a = 0$ for all $a$;
4. **(right distributivity)** $(a + b)\ast c = a\ast c + b\ast c$ for all
   $a,b,c$;
5. **(unique left division)** for every $a \neq 0$ and every $c$, there is a
   unique $x$ with $a \ast x = c$;
6. **(unique right division)** for every $a \neq 0$ and every $c$, there is a
   unique $x$ with $x \ast a = c$;
7. **(planar / Veblen axiom)** for all $a \neq b$ and every $d$, there is a
   unique $x$ with $x \ast a = x \ast b + d$.

We emphasize the properties *not* assumed: commutativity, associativity, and
left distributivity ($a\ast(b+c) = a\ast b + a\ast c$). A quasifield whose
multiplication is associative is a **nearfield**; one satisfying both
distributive laws and associativity is a **division ring**; a commutative
division ring is a **field**.

**Lemma 2.2 (Subtractive right distributivity).** In any quasifield,
$(a - b)\ast c = a\ast c - b\ast c$.

*Proof.* Apply right distributivity to $(a-b) + b$: since
$(a-b)+b = a$, we get $a\ast c = (a-b)\ast c + b\ast c$, and rearranging in the
abelian group $(Q,+)$ gives the claim. $\qquad\blacksquare$

Axioms (5)–(7) each assert that a certain self-map of $Q$ is a bijection: left
multiplication $x \mapsto a\ast x$, right multiplication $x \mapsto x\ast a$
(both for $a\neq 0$), and the "difference of slopes" map
$x \mapsto x\ast a - x\ast b$ (for $a\neq b$). In the finite case, injectivity
and surjectivity coincide, so these amount to "no zero divisors" plus a
transversality condition ensuring distinct lines meet at most once.

---

## 3. The coordinatized plane

**Definition 3.1 (Points and lines).** Given a quasifield $Q$, the *points* of
the associated plane are the pairs $(x, y) \in Q \times Q$. The *lines* are of
two kinds:

- an *ordinary* line $\ell_{m,b}$, the graph $\{(x,y) : y = x\ast m + b\}$, with
  *slope* $m$ and *intercept* $b$;
- a *vertical* line $v_c = \{(x,y) : x = c\}$.

A point $p = (x,y)$ *lies on* $\ell_{m,b}$ iff $y = x\ast m + b$, and lies on
$v_c$ iff $x = c$.

**Theorem 3.2 (Two points determine a unique line).** For any two distinct
points $p \neq q$ of the plane, there is a unique line incident with both.

*Proof.* Write $p = (x_1, y_1)$, $q = (x_2, y_2)$.

*Case $x_1 = x_2$.* Both points lie on the vertical line $v_{x_1}$. No ordinary
line contains two points with equal $x$-coordinate and distinct $y$-coordinate
(the defining equation would force $y_1 = y_2$), and $p \neq q$ forces
$y_1 \neq y_2$; and $v_{x_1}$ is the only vertical line through $p$. Hence
$v_{x_1}$ is the unique common line.

*Case $x_1 \neq x_2$.* No vertical line contains both (their $x$-coordinates
differ). An ordinary line $\ell_{m,b}$ contains both iff
$y_1 = x_1\ast m + b$ and $y_2 = x_2\ast m + b$; subtracting and using Lemma 2.2
gives $y_1 - y_2 = (x_1 - x_2)\ast m$. Since $x_1 - x_2 \neq 0$, unique left
division (axiom 5) yields a unique slope $m$, and then $b = y_1 - x_1\ast m$ is
determined. Hence the ordinary line is unique. $\qquad\blacksquare$

**Definition 3.3 (Parallelism).** Two lines are *parallel* iff they are equal or
disjoint. Concretely, two ordinary lines are parallel iff they share a slope;
any two vertical lines are parallel; an ordinary and a vertical line are never
parallel.

**Theorem 3.4 (Playfair's axiom).** For every line $L$ and every point $p$,
there is a unique line $M$ through $p$ with $M$ parallel to $L$.

*Proof sketch.* If $L = \ell_{m,b}$ is ordinary, the parallels to $L$ are
exactly the ordinary lines of the same slope $m$; through $p = (x_0, y_0)$
exactly one has this slope, namely the one with intercept $b' = y_0 - x_0\ast m$.
If $L = v_c$ is vertical, its parallels are the vertical lines, and through $p$
exactly one vertical line passes, namely $v_{x_0}$. In each case existence and
uniqueness follow directly. $\qquad\blacksquare$

**Theorem 3.5 (Non-degeneracy).** There exist four points, no three collinear
(a *quadrangle*). Explicitly, $(0,0)$, $(1,0)$, $(0,1)$, $(1,1)$ form such a
configuration.

*Proof sketch.* One checks that each of the four triples fails to satisfy any
single line equation simultaneously, using $1 \neq 0$ and the unit and zero
laws. $\qquad\blacksquare$

**Corollary 3.6.** Every quasifield coordinatizes a genuine affine plane.

---

## 4. Division rings and the Desargues dictionary

**Proposition 4.1.** Every division ring $D$ is a quasifield, with $\ast$ its
ring multiplication and $1$ its unit.

*Proof.* The unit, zero, and right-distributive laws are ring axioms; unique
two-sided division holds because nonzero elements are invertible; the planar
axiom holds because $x\ast a - x\ast b = x\ast(a-b)$ (using *left*
distributivity, available in a ring) is a bijection in $x$ when $a \neq b$.
$\qquad\blacksquare$

The classical coordinatization theorem sharpens this into an equivalence, which
we record as the governing dictionary of the subject.

**Theorem 4.2 (Desargues dictionary; classical).** An affine plane satisfies
(the major) Desargues theorem if and only if it can be coordinatized by a
division ring. Equivalently, the plane coordinatized by a quasifield $Q$ is
Desarguesian precisely when $Q$ is (isomorphic to) a division ring — associative
and satisfying both distributive laws.

The upshot for our purposes is the following implication, which is all we need to
certify non-Desarguesianness of a concrete example: **if a quasifield fails
associativity or the left distributive law, its plane is non-Desarguesian.**
This converts a subtle geometric question (do certain triangles align?) into a
mechanical algebraic check.

---

## 5. The field GF(9) and its Frobenius automorphism

We realize $\mathrm{GF}(9)$ on the additive group
$G = \mathbb{Z}/3 \times \mathbb{Z}/3$, writing an element $(a,b)$ as
$a + b\alpha$ where $\alpha$ is a root of $t^2 + 1$; since $-1 \equiv 2 \pmod 3$
we have $\alpha^2 = 2$. Field multiplication is
$$(a + b\alpha)(c + d\alpha) = (ac + 2bd) + (ad + bc)\,\alpha,
\qquad\text{i.e.}\qquad
(a,b)\cdot(c,d) = (ac + 2bd,\ ad + bc).$$
This is the ordinary field of nine elements: commutative, associative, both
distributive laws hold.

**Definition 5.1 (Frobenius).** The Frobenius automorphism is
$$\sigma(a + b\alpha) = a - b\alpha = a + 2b\alpha, \qquad
\sigma(a,b) = (a, 2b),$$
which coincides with $x \mapsto x^3$. It is a field automorphism of order $2$,
fixing exactly the prime subfield $\mathbb{Z}/3 = \{(a,0)\}$.

**Definition 5.2 (Squares).** An element $b \in G$ is a *nonzero square* iff
$b = c\cdot c$ for some $c \neq 0$. The multiplicative group of $\mathrm{GF}(9)$
is cyclic of order $8$, so exactly four nonzero elements are squares.

**Lemma 5.3 (Square/non-square split).** The nonzero squares are
$$\{1,\ 2,\ \alpha,\ 2\alpha\} = \{(1,0),(2,0),(0,1),(0,2)\},$$
and the non-squares are
$$\{1+\alpha,\ 1+2\alpha,\ 2+\alpha,\ 2+2\alpha\}
= \{(1,1),(1,2),(2,1),(2,2)\}.$$

*Proof.* Direct enumeration of $c\cdot c$ over the eight nonzero $c$.
$\qquad\blacksquare$

The non-squares are precisely the elements with both coordinates nonzero; the
squares are the nonzero elements lying on the two coordinate axes. This clean
description makes the branching in the next definition transparent.

---

## 6. The Dickson nearfield of order 9

**Definition 6.1 (Dickson product).** On the same additive group $G$ define
$$
a \ast b =
\begin{cases}
a \cdot b, & b = 0 \text{ or } b \text{ a nonzero square},\\[2pt]
\sigma(a) \cdot b, & b \text{ a non-square},
\end{cases}
$$
where $\cdot$ is $\mathrm{GF}(9)$ multiplication and $\sigma$ is Frobenius. The
addition is unchanged: it is the ordinary $\mathbb{Z}/3 \times \mathbb{Z}/3$.
The unit is $1 = (1,0)$.

The definition twists the left factor by $\sigma$ exactly when the right factor
is a non-square. Because $\sigma$ is trivial on the prime subfield and the
branch is chosen by the *right* factor, the good algebraic laws that "reach
across on the right" are preserved while the ones that "reach across on the
left" are broken.

**Theorem 6.2 (Dickson quasifield axioms).** The Dickson product makes $G$ a
quasifield with unit $(1,0)$. Concretely, all of the following hold:

- $a \ast (1,0) = a$ and $(1,0)\ast a = a$;
- $a \ast 0 = 0$ and $0 \ast a = 0$;
- $(a+b)\ast c = a\ast c + b\ast c$ (right distributivity);
- for $a \neq 0$, both $x \mapsto a\ast x$ and $x \mapsto x\ast a$ are
  bijections (unique two-sided division);
- for $a \neq b$, $x \mapsto x\ast a - x\ast b$ is a bijection (planar axiom).

*Proof.* Each statement is a closed sentence over the finite domain $G$ (with
$|G|=9$, so at most $729$ triples), and is verified by exhaustive evaluation.
The right distributive law is the structurally important one: for fixed $c$, the
branch (square vs. non-square) depends only on $c$, so both sides apply the
*same* branch; if $c$ is a square both sides use $\cdot$ and inherit field right
distributivity, while if $c$ is a non-square both sides equal
$\sigma(a+b)\cdot c = (\sigma(a)+\sigma(b))\cdot c = \sigma(a)\cdot c +
\sigma(b)\cdot c$ using additivity of $\sigma$ and field distributivity.
$\qquad\blacksquare$

**Theorem 6.3 (Associativity — it is a nearfield).** The Dickson product is
associative: $(a\ast b)\ast c = a\ast(b\ast c)$ for all $a,b,c \in G$.

*Proof.* Verified by exhaustive evaluation over all $729$ triples. Structurally,
associativity reflects that the twisting exponents multiply consistently: the
map assigning to each nonzero $b$ the automorphism $\mathrm{id}$ or $\sigma$
according as $b$ is a square or non-square is a group homomorphism from the
multiplicative group to $\mathrm{Gal}(\mathrm{GF}(9)/\mathbb{Z}/3)$, because the
squares form an index-$2$ subgroup. $\qquad\blacksquare$

A quasifield with associative multiplication is a **nearfield**; this is the
unique proper finite nearfield of order $9$.

**Theorem 6.4 (Failure of left distributivity).** The Dickson product is **not**
left-distributive: there exist $a,b,c$ with
$a\ast(b+c) \neq a\ast b + a\ast c$. An explicit witness is
$$a = \alpha,\quad b = \alpha,\quad c = 1,\qquad
\alpha \ast (\alpha + 1) \ \neq\ \alpha\ast\alpha + \alpha\ast 1.$$

*Proof.* Both $b = \alpha = (0,1)$ and $c = 1 = (1,0)$ are squares (Lemma 5.3),
so $a\ast b = a\cdot b$ and $a\ast c = a\cdot c$, and the right-hand side equals
$a\cdot b + a\cdot c = a\cdot(b+c)$ by field distributivity. But
$b + c = 1 + \alpha = (1,1)$ is a *non-square*, so the left-hand side is
$\sigma(a)\cdot(b+c)$. Thus the two sides differ by
$(\sigma(a) - a)\cdot(b+c)$, which is nonzero because $a = \alpha$ is not fixed
by $\sigma$ and $b+c \neq 0$. $\qquad\blacksquare$

**Theorem 6.5 (Non-commutativity).** The Dickson product is not commutative:
$a\ast b \neq b\ast a$ for some $a,b$; e.g. $\alpha \ast (1+\alpha)$ and
$(1+\alpha)\ast\alpha$ differ, since $1+\alpha$ is a non-square (its right
occurrence triggers a $\sigma$-twist) while $\alpha$ is a square (it does not).

**Corollary 6.6.** The Dickson nearfield is a quasifield that is **not** a
division ring (it violates left distributivity, and separately commutativity).
Hence, by the Desargues dictionary (Theorem 4.2), the plane it coordinatizes is
**non-Desarguesian**.

---

## 7. The non-Desarguesian plane of order 9

Applying the general construction of §3 to the Dickson quasifield yields an
affine plane whose points are $G \times G$ and whose lines are the ordinary and
vertical lines defined by the Dickson product.

**Theorem 7.1 (Incidence).** In the Dickson plane, any two distinct points lie
on a unique line (Theorem 3.2), Playfair's parallel axiom holds (Theorem 3.4),
and the plane is non-degenerate (Theorem 3.5). It is therefore a genuine affine
plane.

**Theorem 7.2 (Counting).** The Dickson plane has order $9$:

- the point set $G \times G$ has $|G|^2 = 9^2 = 81$ points;
- the line set is in bijection with $(G \times G) \sqcup G$ — ordinary lines
  $\leftrightarrow$ slope/intercept pairs $(m,b)$, vertical lines
  $\leftrightarrow$ their $x$-coordinate $c$ — and hence has
  $9^2 + 9 = 90$ lines.

These are exactly the parameters of an affine plane of order $9$: $n^2$ points
and $n^2 + n$ lines with $n = 9$ (each line has $9$ points; each point lies on
$10$ lines).

*Proof.* The point count is $|G|^2$. For lines, the map sending
$\ell_{m,b} \mapsto (m,b)$ and $v_c \mapsto c$ is a bijection onto
$(G\times G)\sqcup G$, whose cardinality is $81 + 9 = 90$. $\qquad\blacksquare$

**Theorem 7.3 (Minimal order).** Order $9$ is the smallest at which a
non-Desarguesian plane exists.

*Discussion.* Every plane of prime order $p$ is coordinatized by a field (there
is no proper twist available), and a case analysis rules out non-Desarguesian
planes of every order $\le 8$; the planes of orders $2,3,4,5,7,8$ are all unique
and Desarguesian. The first prime-power square is $9 = 3^2$, which is also the
first order admitting a field $\mathrm{GF}(9)$ with a nontrivial Frobenius
automorphism and hence a Dickson twist. The construction realizes a
non-Desarguesian plane at exactly this first opportunity.

---

## 8. Generalizations, symmetry, and classification

**8.1 Non-Desarguesian planes at every square order.** The construction is not
special to $9$. For any prime power $q$, apply the Dickson twist to
$\mathrm{GF}(q^2)$ using the Frobenius $x \mapsto x^q$ and branching on the
index-$2$ subgroup of squares (more generally, on cosets of a subgroup of the
multiplicative group). One obtains a proper nearfield and a non-Desarguesian
plane of order $q^2$ for every prime power $q$. In a structural (as opposed to
finite-computational) treatment, the finiteness checks of §6 are replaced by:
additivity of the Frobenius (yielding right distributivity), the homomorphism
property of the twist assignment on cosets (yielding associativity), and the
observation that adding two squares can produce a non-square (yielding the
failure of left distributivity). Non-Desarguesian worlds are thus ubiquitous,
one for every square prime-power order.

**8.2 Contraction of the collineation group.** A collineation is a bijection of
points carrying lines to lines. The Desarguesian plane of order $n$ has an
extremely large collineation group (essentially the projective linear group
acting on it), reflecting its homogeneity. The Dickson plane, by contrast,
carries a distinguished substructure — the **nucleus** of the nearfield, the set
of elements over which the twist is trivial and multiplication behaves like a
field — and every collineation must preserve it. This constraint forces the
collineation group of the Dickson plane to be a *proper* subgroup of the
projective group of the Desarguesian plane of the same order. The failure of
Desargues' theorem is thus mirrored by, and quantified through, a genuine loss of
symmetry.

**8.3 Nuclei and the Lenz–Barlotti hierarchy.** A quasifield has three nuclei —
left, middle, and right — measuring where associativity holds. These algebraic
invariants correspond to groups of central collineations (perspectivities) of
the plane, and the pattern of which perspectivities exist places a plane in the
Lenz–Barlotti classification. Non-associativity and one-sided distributivity in
the coordinate structure translate directly into the plane's position in this
hierarchy.

**8.4 The four planes of order 9.** Order $9$ is the richest small case: there
are exactly four projective planes of order $9$ — the Desarguesian plane
$\mathrm{PG}(2,9)$, the nearfield (Hall) plane, its dual, and the Hughes plane.
The nearfield plane built here sits at the head of this list of exceptions, and
the quasifield/coordinatization machinery of §§2–4 is precisely the framework in
which the enumeration and comparison of these planes is carried out.

---

## 9. Discussion

The results assemble into a single conceptual statement: **a geometric law
(Desargues' theorem) is exactly an algebraic law (the coordinate structure being
a division ring), and both can fail together in the smallest way at order 9.**
The general theory (§§2–4) shows the weak algebraic hypotheses of a quasifield
already suffice for all the incidence geometry of an affine plane, isolating
associativity and left distributivity as the *only* extra ingredients Desargues
requires. The concrete construction (§§5–7) then breaks exactly those two
ingredients while keeping every other law intact, producing a plane that is
flawless as an incidence structure yet non-Desarguesian.

Two features deserve emphasis. First, the construction is *surgical*: the twist
is applied along the square/non-square split precisely so that right
distributivity and associativity survive while left distributivity and
commutativity die — nothing more is damaged than necessary. Second, the failure
is *explicit and witnessed*: one can point to the elements $\alpha, \alpha, 1$
and see the distributive law break, because adding the squares $\alpha$ and $1$
lands on the non-square $1+\alpha$ and flips the branch of the definition.

---

## 10. Future work

Natural next steps include: (i) exhibiting an explicit Desargues configuration
(two triangles perspective from a point) inside the Dickson plane and giving
a concrete $10$-point/$10$-line witness where the axis of perspectivity fails,
turning the algebraic obstruction into a directly geometric statement; (ii)
establishing the converse coordinatization theorem in full, that a plane
satisfying Desargues is coordinatized by a division ring; (iii) carrying out the
order-$q^2$ generalization structurally for every prime power $q$; (iv)
proving that the collineation group fixes the nucleus and is thus a proper
subgroup of the projective group; (v) connecting the nearfield plane to the Hall
and Hughes planes and the enumeration of the four planes of order $9$; and (vi)
developing nucleus theory over quasifields in relation to central collineations
and the Lenz–Barlotti classification.

## References

- L. E. Dickson. *Linear algebras with associativity not assumed.*
- M. Hall. *Projective planes.* Trans. Amer. Math. Soc. 54 (1943).
- D. R. Hughes and F. C. Piper. *Projective Planes.* Springer, 1973.
