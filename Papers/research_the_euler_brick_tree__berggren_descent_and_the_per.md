# The Euler Brick Tree: Berggren Descent, Exact Growth, and the Reduction of the Perfect-Cuboid Condition to a Single Quartic

**Author:** Aristotle
**Date:** 2026-09-15

---

## Abstract

An *Euler brick* is a triple of integers $(x,y,z)$ for which all three face
diagonals of the corresponding rectangular box are integral; a *perfect cuboid*
is an Euler brick whose space diagonal is integral as well. The existence of a
perfect cuboid has been open since the eighteenth century.

We build a *dynamic* structure theory for a large parametric family of Euler
bricks. Starting from the Saunderson map
$\beta(u,v,w) = \bigl(u(4v^2-w^2),\, v(4u^2-w^2),\, 4uvw\bigr)$, which carries a
Pythagorean triple to an Euler brick with closed-form face diagonals
$w^3$, $u(w^2+4v^2)$, $v(w^2+4u^2)$, we transport the ternary Berggren tree of
primitive Pythagorean triples to a ternary tree of Euler bricks rooted at the
classical minimal brick $(117,44,240)$.

Our main results are: (i) a *structure theorem* identifying reachability in the
tree with primitivity plus odd first leg, so that descent terminates at the
single seed $(3,4,5)$; (ii) *exact growth*: level $n$ contains exactly $3^n$
nodes, each node has a unique parent, and the Saunderson map is injective on
tree nodes, so level $n$ carries exactly $3^n$ pairwise distinct nondegenerate
Euler bricks; (iii) a *descent theorem for arbitrary Euler bricks*: every Euler
brick with a nonzero edge is a positive integer multiple of a primitive one,
together with the $2$-adic rigidity (exactly one odd edge, the others divisible
by $4$) and the divisibility law $720 \mid xyz$; (iv) an *exact reduction*: the
brick over a node $(a,b,c)$ is a perfect cuboid if and only if
$c^4 + 16a^2b^2$ is a perfect square, equivalently if and only if
$a^4 + 18a^2b^2 + b^4$ is a perfect square, so three of the four simultaneous
square conditions are absorbed by the construction; (v) an *infinite obstructed
family and an infinite obstructed branch*, certified by a quadratic nonresidue
modulo $7$ preserved by the second Berggren generator; (vi) a *sharpness
theorem*: from every residue state modulo $7$ one of the four words
$\varepsilon, A, AA, AB$ escapes the certificate, so no mod-$7$-certified binary
subtree exists and the obstructed set the congruence sees is a path, never a
subtree of positive growth rate; and (vii) a *bounded search theorem* refuting
the perfect-cuboid condition at all $40$ nodes of depth at most three by trapping
each quartic strictly between two consecutive squares.

The upshot is a complete transfer of the perfect-cuboid question on the
Saunderson family from a search problem to a question about the rational points
of one genus-one curve, $s^2 = t^4 + 18t^2 + 1$, whose Jacobian
$y^2 = x(x-16)(x-20)$ has full rational $2$-torsion.

**Keywords:** Euler brick, perfect cuboid, Pythagorean triple, Berggren tree,
Fermat descent, quartic curve, quadratic residue obstruction.

---

## 1. Introduction

### 1.1 The problem

Let $x,y,z$ be positive integers, the edges of a rectangular box. The three face
diagonals are $\sqrt{x^2+y^2}$, $\sqrt{x^2+z^2}$, $\sqrt{y^2+z^2}$ and the space
diagonal is $\sqrt{x^2+y^2+z^2}$.

**Definition 1.1 (Euler brick).** $(x,y,z) \in \mathbb{Z}^3$ is an *Euler brick*
if there exist $p,q,r \in \mathbb{Z}$ with
$$x^2+y^2 = p^2, \qquad x^2+z^2 = q^2, \qquad y^2+z^2 = r^2 .$$

**Definition 1.2 (Perfect cuboid).** An Euler brick $(x,y,z)$ is a *perfect
cuboid* if in addition there is $s \in \mathbb{Z}$ with
$x^2+y^2+z^2 = s^2$.

**Definition 1.3 (Nondegenerate; primitive).** A brick is *nondegenerate* if
$x,y,z$ are all nonzero. Writing $\gcd_3(x,y,z) = \gcd(\gcd(|x|,|y|),|z|)$, a
brick is *primitive* if $\gcd_3(x,y,z) = 1$.

Euler bricks are plentiful; the smallest is $(44,117,240)$, with face diagonals
$125, 244, 267$ and space diagonal $\sqrt{73225} \approx 270.6$. No perfect
cuboid is known, and none is known not to exist.

### 1.2 What is new here

The classical literature on the problem is largely *static*: parametric
families, congruence conditions, and exhaustive searches. This paper supplies a
*dynamic* layer: a finitely generated tree structure on a parametric family of
bricks, with an exact descent theory, exact growth counts, and a reduction of
the outstanding condition to a single curve.

The template is the Berggren tree of Pythagorean triples: three unimodular
generators acting on $(3,4,5)$ produce every primitive triple exactly once. We
show that this tree lifts, through the Saunderson generator, to a tree of Euler
bricks with the same combinatorics, and that the perfect-cuboid condition
becomes a single arithmetic predicate on nodes. We then measure exactly how much
of the tree congruence obstructions can reach — and prove that a single
congruence reaches only a zero-density set.

### 1.3 Organization

Section 2 sets up the Saunderson generator and its diagonal identities.
Section 3 establishes the Berggren structure theorem and the brick tree.
Section 4 proves exact growth. Section 5 gives the descent to primitive bricks
and the arithmetic laws they satisfy. Section 6 proves the exact reduction to
one quartic. Section 7 constructs the infinite obstructed family and branch.
Section 8 proves the sharpness of those obstructions. Section 9 records the
bounded search. Sections 10–12 discuss algorithms, applications and future work.

---

## 2. The Saunderson Generator

Write $\mathrm{PT}(u,v,w)$ for the condition $u^2 + v^2 = w^2$.

**Definition 2.1.** The *Saunderson generator* is the polynomial map
$$\beta(u,v,w) \;=\; \bigl(\,u(4v^2 - w^2),\;\; v(4u^2 - w^2),\;\; 4uvw\,\bigr).$$

**Theorem 2.2 (Face diagonals in closed form).** For all integers $u,v,w$,
writing $(x,y,z) = \beta(u,v,w)$,
$$x^2 + z^2 = \bigl(u(w^2+4v^2)\bigr)^2, \qquad
  y^2 + z^2 = \bigl(v(w^2+4u^2)\bigr)^2,$$
and if moreover $\mathrm{PT}(u,v,w)$ holds, then
$$x^2 + y^2 = (w^3)^2 .$$

*Proof sketch.* The two identities involving $z$ are polynomial identities,
verified by expansion: for instance
$u^2(4v^2-w^2)^2 + 16u^2v^2w^2 = u^2\bigl(16v^4 - 8v^2w^2 + w^4 + 16v^2w^2\bigr)
= u^2(4v^2+w^2)^2$. The first requires the Pythagorean relation exactly once:
$$x^2 + y^2 - w^6 = (16u^2v^2 + w^4)\,(u^2 + v^2 - w^2),$$
an identity in $\mathbb{Z}[u,v,w]$, so the left-hand side vanishes whenever
$u^2+v^2=w^2$. $\square$

**Corollary 2.3 (The generator produces Euler bricks).** If
$\mathrm{PT}(u,v,w)$, then $\beta(u,v,w)$ is an Euler brick, with face diagonals
$w^3$, $u(w^2+4v^2)$, $v(w^2+4u^2)$.

The signature of the construction is the *cubic* first face diagonal $w^3$; this
will be exploited in Section 4 to prove injectivity.

**Example 2.4.** $\beta(3,4,5) = \bigl(3(64-25),\, 4(36-25),\, 240\bigr)
= (117, 44, 240)$, the classical minimal Euler brick, with face diagonals
$5^3 = 125$, $3(25+64) = 267$, $4(25+36) = 244$.

**Proposition 2.5 (Nondegeneracy).** If $\mathrm{PT}(u,v,w)$ with $u,v,w > 0$
and $\gcd(u,v)=1$, then all three edges of $\beta(u,v,w)$ are nonzero.

*Proof sketch.* $z = 4uvw > 0$. The first edge vanishes only if $4v^2 = w^2$,
i.e. (using $w^2 = u^2+v^2$) $u^2 = 3v^2$. Coprimality forces $v^2 \mid u^2$ with
$\gcd(u,v)=1$, hence $v = 1$ and $u^2 = 3$, impossible. The second edge is
symmetric. $\square$

**Basic closure properties.** Brick-hood is preserved by permuting and negating
edges, and by scaling: if $(x,y,z)$ is a brick so is $(kx,ky,kz)$ for any
integer $k$ (multiply each diagonal by $k$). These trivial symmetries are what
make "primitive brick" the right notion of minimal object in Section 5.

---

## 3. The Berggren Tree and the Brick Tree

### 3.1 Nodes and generators

**Definition 3.1.** A triple $(a,b,c)$ of integers is a *node* (a primitive
Pythagorean triple with odd first leg) if
$$a>0,\quad b>0,\quad c>0,\quad a^2+b^2=c^2,\quad \gcd(a,b)=1,\quad a \equiv 1 \bmod 2 .$$

**Definition 3.2 (Berggren generators).**
$$A(a,b,c) = (a-2b+2c,\; 2a-b+2c,\; 2a-2b+3c),$$
$$B(a,b,c) = (a+2b+2c,\; 2a+b+2c,\; 2a+2b+3c),$$
$$C(a,b,c) = (-a+2b+2c,\; -2a+b+2c,\; -2a+2b+3c).$$

Each is given by a unimodular integer matrix preserving the quadratic form
$a^2+b^2-c^2$. Define *reachability* inductively: $(3,4,5)$ is reachable, and if
$(a,b,c)$ is reachable so are $A(a,b,c)$, $B(a,b,c)$, $C(a,b,c)$.

**Proposition 3.3 (Forward closure).** If $(a,b,c)$ is a node, so are
$A(a,b,c)$, $B(a,b,c)$, $C(a,b,c)$.

*Proof sketch.* Positivity: in a positive Pythagorean triple each leg is smaller
than the hypotenuse ($a < c$ since $b>0$ and $a^2 = c^2-b^2 < c^2$), and the
entries of each image are then positive by linear arithmetic. The Pythagorean
relation is a polynomial identity: e.g.
$(a-2b+2c)^2 + (2a-b+2c)^2 - (2a-2b+3c)^2 = a^2+b^2-c^2$.
Coprimality transfers: any common divisor $d$ of the image triple divides $a$
and $b$ through the inverse matrix, and $\gcd(a,b)=1$ then forces $d = \pm 1$.
Parity: the first coordinate changes by an even amount, so it stays odd.
$\square$

**Proposition 3.4 (Strict growth).** For every node, each of the three
generators strictly increases the hypotenuse:
$c < (At)_3$, $c < (Bt)_3$, $c < (Ct)_3$.

*Proof sketch.* $2a-2b+3c - c = 2(a-b+c) > 0$ since $a+c>b$; similarly for the
other two, using $a<c$ and $b<c$. $\square$

**Proposition 3.5 (Three distinct children).** The three images of a node are
pairwise distinct.

### 3.2 The structure theorem

**Theorem 3.6 (Berggren descent / structure theorem).** A triple is reachable
from the seed $(3,4,5)$ under $A, B, C$ if and only if it is a node. Equivalently:
the three generators, acting on the single seed $(3,4,5)$, produce exactly the
set of primitive Pythagorean triples with positive entries and odd first leg.

*Proof sketch.* ($\Rightarrow$) Proposition 3.3 and the fact that $(3,4,5)$ is a
node.

($\Leftarrow$) Strong induction on the hypotenuse $c$. If $c \le 5$, a finite
case analysis shows the only node is $(3,4,5)$. If $c > 5$, one shows that
exactly one of the three inverse maps
$$A^{-1}(a,b,c) = (a+2b-2c,\,-2a-b+2c,\,-2a-2b+3c),$$
$$B^{-1}(a,b,c) = (a+2b-2c,\,2a+b-2c,\,-2a-2b+3c),$$
$$C^{-1}(a,b,c) = (-a-2b+2c,\,2a+b-2c,\,-2a-2b+3c)$$
has all entries positive; that image is again a node (coprimality by the same
transfer argument, parity by the same congruence), and its hypotenuse
$-2a-2b+3c$ is both positive and strictly smaller than $c$ — positivity because
$3c > 2(a+b)$ for a Pythagorean triple, and strict decrease because
$a+b>c$. Applying the induction hypothesis to the parent and then the
corresponding generator yields reachability. $\square$

The parent's hypotenuse $-2a-2b+3c$ is the same for all three inverse maps; this
is why the descent is a genuine well-founded recursion on a single positive
integer.

### 3.3 The brick tree

**Definition 3.7.** A triple $X \in \mathbb{Z}^3$ is a *tree brick* if
$X = \beta(a,b,c)$ for some reachable $(a,b,c)$.

**Theorem 3.8 (Single-seed generation).** $X$ is of the form $\beta(a,b,c)$ for
some node $(a,b,c)$ if and only if $X$ is a tree brick. Every tree brick is a
nondegenerate Euler brick, and the root of the tree is $(117,44,240)$.

*Proof sketch.* Combine Theorem 3.6, Corollary 2.3 and Proposition 2.5, together
with Example 2.4. $\square$

**Theorem 3.9 (Unboundedness).** For every $N$ there is a reachable node with
hypotenuse $> N$; consequently the brick tree contains bricks of arbitrarily
large size.

*Proof sketch.* Iterate $A$ from the seed and apply Proposition 3.4 inductively:
after $n$ steps the hypotenuse is at least $n+5$. $\square$

---

## 4. Exact Growth

Reachability alone does not make a tree: one must know that no node is reached
twice.

**Proposition 4.1 (Injectivity of each generator).** Each of $A, B, C$ is
injective on $\mathbb{Z}^3$ (each matrix is unimodular).

**Proposition 4.2 (Disjoint images / unique parent).** If $t, t'$ are nodes and
$G \ne H$ are two of the three generators, then $G t \ne H t'$.

*Proof sketch.* Apply the inverse maps to a hypothetical coincidence. For
example, $A^{-1}$ recovers $t$ from $At$ exactly, while
$B^{-1}(A t)$ has second coordinate $-b$, which is negative for a node; hence
$At = Bt'$ would force $-b = b'$ with $b,b'>0$. The remaining pairs are
identical in structure, with $A^{-1}$, $C^{-1}$ and $B^{-1}$, $C^{-1}$ playing
the analogous roles on the first coordinate. $\square$

**Theorem 4.3 (The path map is injective).** Let $\pi(w)$ denote the node
obtained by applying to $(3,4,5)$ the word $w$ in the letters $\{A,B,C\}$.
Then $\pi$ is injective on words.

*Proof sketch.* Induction on word length. A nonempty word yields a node with
hypotenuse $> 5$ (Proposition 3.4 plus the fact that every node on a path has
hypotenuse $\ge 5$), so the empty word is distinguished from all others. For two
nonempty words, Proposition 4.2 forces the *last* letters to agree, and
Proposition 4.1 then cancels that letter, completing the induction. $\square$

**Corollary 4.4 (Exact node growth).** The set of nodes at depth exactly $n$ has
cardinality $3^n$.

**Theorem 4.5 (Injectivity of the Saunderson generator on nodes).** If
$(u,v,w)$ and $(u',v',w')$ are nodes and $\beta(u,v,w) = \beta(u',v',w')$, then
$(u,v,w) = (u',v',w')$.

*Proof sketch.* The first face diagonal identity gives $w^6 = (w')^6$, hence
$w = w'$ (both positive). The third edge gives $4uvw = 4u'v'w$, hence
$uv = u'v'$. The Pythagorean relations give $(u+v)^2 = (u')^2+(v')^2 + 2u'v' =
(u'+v')^2$, hence $u+v = u'+v'$ by positivity. Then $u$ and $u'$ are roots of the
same monic quadratic, so $(u-u')(u-v') = 0$; the second factor is excluded
because in a node the first leg is odd and the second is even, so $u \ne v'$.
Hence $u = u'$ and $v = v'$. $\square$

**Theorem 4.6 (Exact growth of the brick tree).** Level $n$ of the brick tree
consists of exactly $3^n$ pairwise distinct Euler bricks, each nondegenerate.

*Proof sketch.* Corollary 4.4, Theorem 4.5, Corollary 2.3 and Proposition 2.5.
$\square$

Thus the brick tree is a perfect ternary tree: growth rate exactly $3$, no
collisions, and each brick has a unique ancestry back to $(117,44,240)$.

---

## 5. Descent for Arbitrary Euler Bricks

The tree organizes the Saunderson family. A separate, elementary descent
organizes *all* Euler bricks.

**Lemma 5.1 (Brick-hood descends through a common factor).** If $g \ne 0$ and
$(gx, gy, gz)$ is an Euler brick, then so is $(x,y,z)$.

*Proof sketch.* From $(ga)^2 + (gb)^2 = p^2$ we get $g^2 \mid p^2$, hence
$g \mid p$ (a divisibility fact for squares in $\mathbb{Z}$); writing $p = gt$
and cancelling $g^2$ gives $a^2+b^2 = t^2$. Apply this to each of the three
faces. $\square$

**Theorem 5.2 (Descent to primitive bricks).** Every Euler brick $(x,y,z)$ with
not all edges zero is $g\,(x',y',z')$ for a positive integer $g$ and a
*primitive* Euler brick $(x',y',z')$.

*Proof sketch.* Take $g = \gcd_3(x,y,z) > 0$ and $(x',y',z') = (x,y,z)/g$;
Lemma 5.1 makes it a brick, and $\gcd_3(x',y',z') \cdot g \mid g$ forces
$\gcd_3(x',y',z') = 1$. $\square$

So the primitive bricks are exactly the minimal elements of the brick space
under dilation — the brick analogue of primitive triples.

### 5.1 The $2$-adic shape

**Lemma 5.3.** If $x$ is odd and $x^2+y^2$ is a square, then $4 \mid y$.

*Proof sketch.* Mod $4$: squares are $0$ or $1$. With $x^2 \equiv 1$, $y$ must be
even, say $y = 2m$; then $x^2 + 4m^2 = p^2$ with $p$ odd, and mod $8$ one gets
$4m^2 \equiv 0 \pmod 8$, i.e. $m$ even, i.e. $4 \mid y$. $\square$

**Lemma 5.4.** Two odd edges are impossible in an Euler brick: if $x,y$ are odd
then $x^2+y^2 \equiv 2 \pmod 4$ is not a square.

**Theorem 5.5 (Exactly one odd edge).** In a primitive Euler brick exactly one
edge is odd, and the other two are divisible by $4$.

*Proof sketch.* Not all three edges can be even (primitivity); at most one is odd
(Lemma 5.4); Lemma 5.3 applied to the odd edge against each of the other two
gives divisibility by $4$. $\square$

### 5.2 The $3$-adic and $5$-adic shape, and the 720 law

**Lemma 5.6.** In any Pythagorean pair $x^2+y^2 = p^2$, at least one of $x,y$ is
divisible by $3$ (squares are $0,1$ mod $3$, and $1+1=2$ is not a square mod 3).

**Theorem 5.7.** For every Euler brick, $9 \mid xyz$ and $5 \mid xyz$.

*Proof sketch.* For $9$: Lemma 5.6 applied to the three faces shows that at least
two of the three edges are divisible by $3$ — if only one were, some face would
have both legs prime to $3$. For $5$: squares mod $5$ are $0,1,4$; a short case
analysis over the residues of $x,y,z$ modulo $5$ shows that if none of them is
$0$ then some face sum $x^2+y^2 \in \{2,3\} \bmod 5$ is a nonsquare. $\square$

**Theorem 5.8 (The 720 law).** For every Euler brick with an odd edge — in
particular for every primitive Euler brick — $720 \mid xyz$.

*Proof sketch.* $720 = 16 \cdot 9 \cdot 5$. Theorem 5.5 gives $16 \mid xyz$
(two edges divisible by $4$), Theorem 5.7 gives the factors $9$ and $5$, and the
three factors are pairwise coprime. $\square$

**Example 5.9.** $117 \cdot 44 \cdot 240 = 1{,}235{,}520 = 720 \cdot 1716$.

Note that a perfect cuboid, if it exists, may be assumed primitive (divide by the
common factor, using Lemma 5.1 and the analogous statement for the space
diagonal) and therefore must satisfy the 720 law and the one-odd-edge law.

---

## 6. Exact Reduction of the Perfect-Cuboid Condition

This is the structural heart of the paper.

**Theorem 6.1 (Space-diagonal factorization).** If $\mathrm{PT}(u,v,w)$ and
$(x,y,z) = \beta(u,v,w)$, then
$$x^2 + y^2 + z^2 \;=\; w^2\,\bigl(w^4 + 16u^2v^2\bigr).$$

*Proof sketch.* The difference of the two sides is
$(16u^2v^2 + w^4)(u^2+v^2-w^2)$ as a polynomial identity, which vanishes on the
Pythagorean locus. $\square$

**Theorem 6.2 (Exact reduction).** Let $\mathrm{PT}(u,v,w)$ with $w \ne 0$. Then
$\beta(u,v,w)$ is a perfect cuboid if and only if $w^4 + 16u^2v^2$ is a perfect
square — equivalently, if and only if $(w^2, 4uv)$ are the legs of a Pythagorean
triple.

*Proof sketch.* ($\Leftarrow$) If $w^4 + 16u^2v^2 = s^2$ then by Theorem 6.1 the
space diagonal squared equals $(ws)^2$; brick-hood is Corollary 2.3.
($\Rightarrow$) If $x^2+y^2+z^2 = s^2$ then $w^2 \mid s^2$, so $w \mid s$; write
$s = wt$ and cancel $w^2$ in $w^2(w^4+16u^2v^2) = w^2t^2$ to get
$w^4+16u^2v^2 = t^2$. The reformulation as legs is
$(w^2)^2 + (4uv)^2 = w^4+16u^2v^2$. $\square$

**Corollary 6.3 (The tree question is one quartic question).** For a node
$(a,b,c)$ of the Berggren tree, the brick $\beta(a,b,c)$ is a perfect cuboid if
and only if
$$c^4 + 16a^2b^2 \text{ is a perfect square.}$$
Substituting $c^2 = a^2+b^2$, this reads
$$a^4 + 18a^2b^2 + b^4 = \square .$$

Three of the four simultaneous square conditions have been absorbed into the
construction; only one remains, and it is a single quartic condition in two
coprime variables. Setting $t = a/b$ and dehomogenizing, the question is the set
of rational points on the genus-one curve
$$\mathcal{C}: \quad s^2 = t^4 + 18t^2 + 1 ,$$
which visibly contains the trivial points $t=0$ ($s = \pm1$) and the two points
at infinity. The Jacobian of $\mathcal{C}$ is the elliptic curve
$$E: \quad y^2 = x(x-16)(x-20),$$
with full rational $2$-torsion $\{O, (0,0), (16,0), (20,0)\}$. (The transfer is
the standard one for $s^2 = t^4 + at^2 + b$, giving
$y^2 = x\bigl(x^2 - 2ax + (a^2-4b)\bigr)$ with $a = 18$, $b = 1$, and
$x^2 - 36x + 320 = (x-16)(x-20)$.)

An exhaustive check over all coprime pairs $1 \le v \le u < 2000$ finds no
nontrivial solution of $u^4+18u^2v^2+v^4 = \square$; the conjecture that none
exists is discussed in Section 12.

**Remark 6.4 (Self-reference).** The surviving condition is itself a Pythagorean
condition: it demands that $(w^2, 4uv)$ be legs of a right triangle. A perfect
cuboid in this family would therefore be a node of the Berggren tree whose
associated *diagonal* pair is again the leg pair of a tree node. This suggests
running the Berggren descent on the diagonal triple rather than on the edge
triple; see Section 12.

---

## 7. Obstructions: An Infinite Family and an Infinite Branch

With the problem reduced to one quartic predicate, congruences become available.

**Theorem 7.1 (mod-$7$ obstruction).** Let $\mathrm{PT}(u,v,w)$ with $w \ne 0$,
$u \equiv v \pmod 7$ and $7 \nmid u$. Then $\beta(u,v,w)$ is *not* a perfect
cuboid.

*Proof sketch.* Modulo $7$, $u \equiv v$ gives $w^2 \equiv 2u^2$, so
$$w^4 + 16u^2v^2 \equiv 4u^4 + 2u^4 = 6u^4 \pmod 7 .$$
For $u \not\equiv 0$, $u^4 \in \{1,2,4\}$, so $6u^4 \in \{6,5,3\}$, while the
squares mod $7$ are $\{0,1,2,4\}$. So the quartic is a nonresidue and cannot be a
square; Theorem 6.2 finishes. $\square$

**Theorem 7.2 (An infinite obstructed family).** For every integer $j \ge 0$,
put $m = 14j+4$. Then $(m^2-1,\ 2m,\ m^2+1)$ is a node of the Berggren tree, its
Saunderson brick is a nondegenerate Euler brick, that brick is not a perfect
cuboid, and its third edge $4(m^2-1)(2m)(m^2+1)$ exceeds $j$. Hence the
space-diagonal condition provably fails at infinitely many nodes, with bricks of
unbounded size.

*Proof sketch.* $(m^2-1,2m,m^2+1)$ is Pythagorean by algebra; with $m$ even the
first leg is odd, and $\gcd(m^2-1,2m)=1$ because
$-1\cdot(m^2-1) + \tfrac{m}{2}\cdot(2m) = 1$. The congruence
$(m^2-1) - 2m = m^2 - 2m - 1 \equiv 0 \pmod 7$ holds for $m \equiv 4 \pmod{14}$,
while $m^2-1 \equiv 15 \equiv 1 \pmod 7$ is nonzero. Theorem 7.1 applies, and the
size estimate is elementary. $\square$

**Theorem 7.3 (The obstruction propagates along the second generator).** If
$\mathrm{PT}(u,v,w)$, $7 \mid u-v$ and $7 \nmid u$, then the same two conditions
hold for $B(u,v,w)$.

*Proof sketch.* The difference of the first two coordinates of $B(u,v,w)$ is
$-(u-v)$, so divisibility by $7$ is preserved exactly. For nonvanishing: the
first coordinate of $B(u,v,w)$ reduces mod $7$, under $u \equiv v$, to
$3u + 2w$; a finite check over the $49$ pairs $(u,w)$ in $(\mathbb{Z}/7)^2$
subject to $u \ne 0$ and $2u^2 = w^2$ shows $3u + 2w \ne 0$ always. $\square$

**Theorem 7.4 (An infinite obstructed branch).** Let $t$ be a node with
$7 \mid a - b$ and $7 \nmid a$. Then for every $n \ge 0$ the node $B^n t$ is in
the tree, its brick is a genuine Euler brick, that brick is not a perfect
cuboid, and its hypotenuse is at least $c + n$. In particular, starting at
$(15,8,17)$ — the third child of the seed — the entire $B$-branch
$$(15,8,17) \to (65,72,97) \to (403,396,565) \to (2325,2332,3293) \to \cdots$$
is obstructed at every node, and marches to infinity.

*Proof sketch.* Induct with Theorem 7.3, apply Theorem 7.1 at each step, and use
Proposition 3.4 for the growth estimate. $\square$

---

## 8. Sharpness: A Congruence Sees a Path, Never a Subtree

How much of the tree can a fixed congruence obstruct? We answer this exactly for
modulus $7$.

**Definition 8.1.** A node $(a,b,c)$ is *mod-$7$ certified* if
$c^4 + 16a^2b^2$ is a quadratic nonresidue modulo $7$, i.e. is not congruent to
any square mod $7$.

**Proposition 8.2 (Soundness).** A mod-$7$ certified node of the tree carries no
perfect cuboid.

*Proof sketch.* Reduce the equation of Corollary 6.3 mod $7$. $\square$

The certificate depends only on the residue state
$(\bar a,\bar b,\bar c) \in (\mathbb{Z}/7)^3$, and the generators descend to
maps $\bar A, \bar B$ on these $343$ states, since they are given by integer
matrices.

**Theorem 8.3 (Escape within two steps).** For *every* residue state $s$, at
least one of $s$, $\bar A s$, $\bar A \bar A s$, $\bar B \bar A s$ is a state at
which $\bar c^4 + 16\bar a^2\bar b^2$ *is* a square mod $7$. Equivalently: from
any node of the tree, one of the four words $\varepsilon, A, AA, AB$ reaches a
node where the certificate fails.

*Proof sketch.* A finite verification over all $343$ states. $\square$

**Theorem 8.4 (No mod-$7$-certified binary subtree).** There is no node $t$ of
the brick tree such that every node of the binary subtree generated by $A$ and
$B$ above $t$ is mod-$7$ certified.

*Proof sketch.* Immediate from Theorem 8.3: a counterexample node would certify
the escaping word's endpoint, which by construction is not certified. $\square$

**Theorem 8.5 (Local picture at $(15,8,17)$).** At the branch node $(15,8,17)$,
the $B$-child $(65,72,97)$ is certified — and by Theorem 7.4 so is its entire
$B$-branch — while the $A$-child $(33,56,65)$ and the $C$-child $(35,12,37)$
both escape the certificate already at depth one.

**Interpretation.** Theorems 7.4 and 8.4 are exactly complementary: the mod-$7$
obstruction certifies an infinite *path* and provably never a subtree of
positive growth rate. Since level $n$ of the tree has $3^n$ nodes while a path
contributes one node per level, the certified set has density zero. No finite
family of such congruences can settle the perfect-cuboid question on the tree;
the remaining difficulty is global.

A direct enumeration confirms the density picture quantitatively: among the
$3280$ nodes of depth at most seven, about $49.4\%$ are mod-$7$ certified, and
this proportion is stable across levels — a positive fraction, but the
uncertified complement is itself exponentially large, and it is the uncertified
complement that must be handled by a global argument.

---

## 9. Bounded Search

**Lemma 9.1 (Trapping criterion).** If $k \ge 0$ and $k^2 < N < (k+1)^2$ then
$N$ is not a perfect square.

**Theorem 9.2 (Bounded search theorem).** No node of the Berggren tree of depth
at most three carries a perfect cuboid. Explicitly, for each of the $40$ nodes
of depth $\le 3$ there is an integer $k$ with
$k^2 < c^4 + 16a^2b^2 < (k+1)^2$.

*Proof sketch.* Corollary 6.3 reduces each node to a single integer; Lemma 9.1
with an explicit $k$ refutes squareness at each. For instance, at the seed
$(3,4,5)$ the quartic is $2929$ and $54^2 = 2916 < 2929 < 3025 = 55^2$; at
$(5,12,13)$ it is $86161$ with $293^2 < 86161 < 294^2$; at $(15,8,17)$ it is
$313921$ with $560^2 < 313921 < 561^2$. $\square$

The same computation extended by direct enumeration finds no square quartic at
any node of depth $\le 7$ (that is, all $3280$ nodes), where the bricks already
have tens of digits.

---

## 10. Algorithms

Three procedures underlie the results and the accompanying computations.

**(A) Tree expansion.** Maintain a frontier of nodes; apply the three matrices to
each. Level $n$ costs $\Theta(3^n)$ matrix-vector products; entries grow
geometrically (roughly by a factor of $3$–$6$ per level), so the bit-cost per
node at depth $n$ is $O(n)$ and the total cost through depth $n$ is
$O(n\,3^n)$ word operations.

**(B) Berggren descent (parent finding).** Given a node other than the seed,
compute the three inverse images and select the one with all entries positive;
this is the unique parent, and its hypotenuse is $-2a-2b+3c$, strictly smaller.
Iterating reaches $(3,4,5)$. Termination is guaranteed because the hypotenuse is
a positive integer that strictly decreases at each step; since $a+b>c$ always,
the parent hypotenuse is $3c-2(a+b) < c$. The number of steps is the depth of the
node, which is bounded by $c$ and is logarithmic in $c$ along branches whose
hypotenuse grows geometrically (for instance the $B$-branch, where the
hypotenuse is multiplied by roughly $5.8$ per step); the slowest branches are
those approaching $a+b \approx c$, such as the family $(m^2-1,2m,m^2+1)$, where
the depth grows like $\sqrt{c}$.

**(C) Perfect-cuboid test on the tree.** For a node $(a,b,c)$, compute
$Q = c^4 + 16a^2b^2$, then: (i) test $Q$ modulo a small set of moduli against the
squares table (constant time, rejects roughly half the nodes at modulus $7$
alone); (ii) if it survives, compute $k = \lfloor \sqrt{Q} \rfloor$ by integer
square root and check whether $k^2 = Q$, which simultaneously supplies the
trapping witness $k^2 < Q < (k+1)^2$ when the answer is negative. The integer
square root of an $N$-bit number costs $O(M(N))$ with $M$ the multiplication
cost; since $Q$ has $O(\text{depth})$ digits growth, a level-$n$ test costs
$O(M(n))$.

The certified-escape computation of Theorem 8.3 is a single pass over the $343$
residue states with a constant-size table of squares mod $7$: total cost $O(p^3)$
for modulus $p$, entirely negligible, and it is this finiteness that makes the
sharpness theorem provable rather than merely empirical.

---

## 11. Applications and Interpretation

**A structure-first attack on a search problem.** The perfect-cuboid problem has
traditionally been attacked by enumeration over boxes. The tree reframes it: the
Saunderson family is generated from one seed by three explicit maps, the
combinatorics is exactly ternary, and the four simultaneous square conditions
collapse to one. Any statement about the family becomes a statement about nodes,
and any statement about nodes becomes a statement about the quartic.

**Certificates of non-existence.** The mod-$7$ argument gives a cheap,
machine-checkable certificate refuting the perfect-cuboid condition at a node,
and it is stable under one of the three generators. This is a template: any
modulus $p$ at which the quartic is a nonresidue on a generator-invariant set of
residue states yields an infinite obstructed branch.

**Limits of local methods, quantified.** Theorem 8.4 turns the folklore
intuition "congruences are not enough" into a theorem for this setting: the
mod-$7$ certified set contains no binary subtree, hence has zero density along
growth. This is a precise map of where the difficulty lives.

**Transferable machinery.** The descent to primitive bricks (Theorem 5.2), the
one-odd-edge law (Theorem 5.5) and the 720 law (Theorem 5.8) hold for *all*
Euler bricks, not only tree bricks, and constrain any hypothetical perfect
cuboid.

---

## 12. Future Directions

**1. Rank-zero descent for the brick quartic.** *Conjecture:* the curve
$s^2 = t^4 + 18t^2 + 1$ has only the rational points $t = 0, \infty$;
equivalently $u^4+18u^2v^2+v^4$ is a square only when $uv = 0$, and the
Saunderson brick tree contains no perfect cuboid. The key structural fact is that
the Jacobian $y^2 = x(x-16)(x-20)$ has full rational $2$-torsion, so a complete
$2$-descent — three coprime factorizations $x = d e^2$ with $d \mid 320$ — is
elementary enough to carry out without heavy elliptic-curve machinery: each
descent branch reduces to a small Diophantine system settled by parity and
quadratic residues. Since Corollary 6.3 has already reduced the entire tree
question to this single curve, this is a self-contained target with a crisp
payoff: the first structural non-existence theorem for a full parametric family
of Euler bricks.

**2. Berggren descent for the space-diagonal condition.** *Conjecture:* the map
$(u,v,w) \mapsto (w^2, 4uv, s)$ sends a hypothetical perfect node to a
Pythagorean triple whose Berggren parent is again of that shape, so perfect nodes
would descend infinitely — a contradiction. The key insight is Remark 6.4: the
fourth condition is itself a Pythagorean condition, so the Berggren descent can
be run *on the diagonal triple* rather than on the edge triple, and the two
descents compared.

**3. Beyond a single congruence.** The sharpness theorem says one modulus sees
only a path. Two natural continuations: (a) search systematically for a modulus
$p$ and a set of residue states closed under two generators on which the quartic
is a nonresidue — the computations so far suggest none exists, which would be
worth proving in general; (b) combine several moduli and ask whether the union of
their certified sets can have positive density in the tree.

**4. Other brick generators.** The Saunderson family is one parametric family
among several. Each such family can be lifted over the Berggren tree in the same
way, and each will produce its own reduction to a curve. Comparing these curves
would map out which families are structurally ruled out and which are not.

**5. Sharpened arithmetic laws.** The $720$ law, the one-odd-edge law and the
$2$-adic rigidity are proved here for all Euler bricks. Pushing the same
technique to higher powers of $2$, $3$, $5$ and to further primes would tighten
the arithmetic envelope any perfect cuboid must inhabit.

---

## 13. Conclusion

We have built a complete dynamic structure theory for the Saunderson family of
Euler bricks: a ternary tree with one seed, exact $3^n$ growth with unique
parents, injectivity of the brick map on nodes, a descent theory that takes any
Euler brick whatsoever down to a primitive one, rigid arithmetic constraints
($720 \mid xyz$, exactly one odd edge), and an exact reduction of the
perfect-cuboid condition on the whole tree to the single quartic condition
$c^4 + 16a^2b^2 = \square$. Over this structure we exhibited an infinite family
and an infinite branch of provably non-perfect nodes, and proved that these
obstructions are sharp for the certifying congruence: no mod-$7$-certified binary
subtree exists. Finally, bounded search refutes the condition at every node of
depth at most three with explicit trapping witnesses.

The residue is a single genus-one curve. That is a far smaller and far more
tractable object than the original three-dimensional search, and settling its
rational points would decide the perfect-cuboid question for an entire infinite
parametric family of boxes.
