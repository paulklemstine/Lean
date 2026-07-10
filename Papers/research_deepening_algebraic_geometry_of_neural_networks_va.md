# The Algebraic Geometry of ReLU Decision Boundaries: A Depth-Free Tropical Correspondence and an Explicit Boundary Variety

## Abstract

Feed-forward neural networks with rectified linear (ReLU) activations compute
continuous piecewise-linear functions, and their decision boundaries are
piecewise-linear hypersurfaces. We establish two structural results that place
these boundaries at the confluence of neural network theory, tropical (max-plus)
geometry, and classical algebraic geometry. First, we prove a **depth-free
characterization**: a real-valued function on $\mathbb{R}^d$ is computable by a
feed-forward ReLU network of arbitrary depth and width if and only if it is a
*tropical rational function*, i.e. a difference of two finite maxima of affine
forms. This sharpens the classical one-hidden-layer correspondence to a two-sided
equivalence with no bound on depth, by identifying the generating operations of a
network (affine combination, real scaling, rectification) with the closure
operations of the max-plus difference structure. Second, we prove that the
decision boundary of any tropical rational classifier $f = p - q$ is contained in
the real zero locus of a **single, explicit multivariate polynomial**: the
product over all pairs of affine pieces of $p$ and $q$ of their affine
differences. Thus every rectifier decision boundary lies inside a bona fide
algebraic hypersurface whose defining equation we write down in closed form. We
show the containment is generally strict, characterize the source of the strict
part, and derive corollaries and worked examples. We conclude with algorithms,
numerical demonstrations, and a set of conjectures on minimal algebraic degree,
depth-induced degree compression, and boundary reducibility.

## 1. Introduction

A feed-forward network with rectified linear units alternates affine maps with
the coordinatewise rectifier $\operatorname{ReLU}(t) = \max(t, 0)$. The resulting
function is continuous and piecewise-linear, and for a scalar output the
**decision boundary** — the set where the output vanishes — is a
piecewise-linear hypersurface partitioning input space into decision regions.

Two questions organize this paper.

1. *Which functions can such networks compute, independently of depth?* It is
   classical that a single hidden layer computes a difference of two convex
   piecewise-linear functions, i.e. a tropical rational function. But does depth
   enlarge the *class* of computable functions, or only the efficiency of their
   representation?

2. *What is the algebraic nature of the decision boundary?* A piecewise-linear
   hypersurface is not, a priori, the zero set of a polynomial. Can we
   nevertheless exhibit an explicit algebraic variety that contains it?

We answer both. Section 3 proves the depth-free equivalence between
network-computable functions and tropical rational functions. Section 4 exhibits
an explicit polynomial whose zero locus contains the decision boundary, making
precise the phrase "the algebraic variety of a decision boundary." Throughout,
inputs live in $\mathbb{R}^d$ and classifiers are scalar-valued.

## 2. Definitions

We work over the reals. Fix an input dimension $d \in \mathbb{N}$.

**Definition 2.1 (Affine functional).** An *affine functional* is specified by a
pair $(a, b)$ with $a \in \mathbb{R}^d$ and $b \in \mathbb{R}$, and evaluates as
$$\operatorname{aff}_{(a,b)}(x) = \langle a, x\rangle + b = \sum_{j=1}^{d} a_j x_j + b.$$

**Definition 2.2 (Tropical polynomial).** A function
$p : \mathbb{R}^d \to \mathbb{R}$ is a *tropical polynomial* if there is a finite
nonempty set $S$ of affine functionals with
$$p(x) = \max_{(a,b) \in S} \big(\langle a, x\rangle + b\big) \qquad \text{for all } x.$$
Equivalently, $p$ is the pointwise maximum of finitely many affine forms. Every
tropical polynomial is convex and piecewise-linear. In the max-plus semiring
$(\mathbb{R}, \oplus, \odot)$ with $a \oplus b = \max(a,b)$ and
$a \odot b = a + b$, such a $p$ is literally a polynomial expression.

**Definition 2.3 (Tropical rational function).** A function
$f : \mathbb{R}^d \to \mathbb{R}$ is a *tropical rational function* if there exist
tropical polynomials $p, q$ with $f(x) = p(x) - q(x)$ for all $x$. These functions
are continuous and piecewise-linear but need not be convex.

**Definition 2.4 (Rectifier).** The *rectified linear unit* is
$\operatorname{ReLU}(t) = \max(t, 0)$.

**Definition 2.5 (Network-computable functions).** The class of
*network-computable* functions is the smallest class $\mathcal{N}$ of functions
$\mathbb{R}^d \to \mathbb{R}$ such that:
- (affine) every affine functional $\operatorname{aff}_{(a,b)}$ is in $\mathcal{N}$;
- (add) if $f, g \in \mathcal{N}$ then $x \mapsto f(x) + g(x) \in \mathcal{N}$;
- (scale) if $f \in \mathcal{N}$ and $c \in \mathbb{R}$ then $x \mapsto c\,f(x) \in \mathcal{N}$;
- (rectify) if $f \in \mathcal{N}$ then $x \mapsto \operatorname{ReLU}(f(x)) \in \mathcal{N}$.

These four generators are exactly the operations a feed-forward ReLU network
performs: affine pre-activations are affine functionals; hidden units apply
$\operatorname{ReLU}$; and any linear read-out or subsequent layer forms real
linear combinations. Closure under these operations, iterated arbitrarily,
therefore captures networks of *any* finite depth and width.

**Definition 2.6 (Decision boundary).** For $f : \mathbb{R}^d \to \mathbb{R}$,
the *decision boundary* is the zero locus
$$\partial(f) = \{\, x \in \mathbb{R}^d : f(x) = 0 \,\}.$$

## 3. The depth-free characterization

We first record the closure of tropical polynomials under the semiring
operations; these are the technical core of the correspondence.

**Lemma 3.1 (Closure of tropical polynomials).** Let $p, q$ be tropical
polynomials. Then:
1. $x \mapsto \max(p(x), q(x))$ is a tropical polynomial (tropical addition);
2. $x \mapsto p(x) + q(x)$ is a tropical polynomial (tropical multiplication);
3. for $c \ge 0$, $x \mapsto c\,p(x)$ is a tropical polynomial;
4. $x \mapsto \operatorname{ReLU}(p(x))$ is a tropical polynomial;
5. every constant and every affine functional is a tropical polynomial.

*Proof sketch.* For (1), if $p = \max_{S}$ and $q = \max_{T}$ over piece sets
$S, T$, then $\max(p, q) = \max_{S \cup T}$. For (2), the max-plus distributive
law
$$\Big(\max_{s \in S} u(s)\Big) + \Big(\max_{t \in T} v(t)\Big)
   = \max_{(s,t) \in S \times T}\big(u(s) + v(t)\big)$$
shows $p + q = \max_{(a,b)\in S,\,(c,e)\in T}\big(\langle a+c, x\rangle + (b+e)\big)$,
a maximum over the sum-set of pieces. For (3), scaling every piece by $c \ge 0$
preserves the maximum since $c\max_i z_i = \max_i c z_i$. For (4),
$\operatorname{ReLU}(p) = \max(p, 0)$ and $0$ is the constant tropical polynomial,
so (4) follows from (1). Item (5) is immediate: a constant $b$ is the one-piece
maximum of $\operatorname{aff}_{(0,b)}$, and an affine functional is a one-piece
maximum. $\qquad\blacksquare$

**Proposition 3.2 (Tropical rationals are closed under network operations).** The
class of tropical rational functions contains all affine functionals and is
closed under addition, real scalar multiplication, and $\operatorname{ReLU}$.

*Proof sketch.* Write tropical rationals as $p - q$ with $p, q$ tropical
polynomials.
- *Affine and constant:* $\operatorname{aff}_{(a,b)} = \operatorname{aff}_{(a,b)} - 0$.
- *Addition:* $(p_1 - q_1) + (p_2 - q_2) = (p_1 + p_2) - (q_1 + q_2)$, and sums of
  tropical polynomials are tropical polynomials by Lemma 3.1(2).
- *Negation and scaling:* $-(p - q) = q - p$; for $c \ge 0$,
  $c(p - q) = (cp) - (cq)$ by Lemma 3.1(3); for $c < 0$ write $c = -|c|$ and
  combine with negation, giving $c(p-q) = (|c|q) - (|c|p)$.
- *Rectification:* the identity
  $$\operatorname{ReLU}(p - q) = \max(p, q) - q$$
  expresses $\operatorname{ReLU}(p-q)$ as a difference of the tropical polynomials
  $\max(p, q)$ (Lemma 3.1(1)) and $q$. $\qquad\blacksquare$

**Corollary 3.3 (Forward direction).** Every network-computable function is a
tropical rational function.

*Proof.* Induct on the construction of a network-computable function. The base
case (affine) and the three inductive cases (add, scale, rectify) are exactly the
closure properties of Proposition 3.2. $\qquad\blacksquare$

For the converse we use the single most important identity of the theory.

**Lemma 3.4 (Maximum via rectifier).** For all $a, b \in \mathbb{R}$,
$$\max(a, b) = a + \operatorname{ReLU}(b - a).$$

*Proof.* If $b \ge a$ then $\operatorname{ReLU}(b-a) = b - a$ and the right side is
$b = \max(a,b)$. If $b < a$ then $\operatorname{ReLU}(b-a) = 0$ and the right side
is $a = \max(a,b)$. $\qquad\blacksquare$

**Proposition 3.5 (Maxima of network-computable functions).** If $f, g$ are
network-computable, so is $x \mapsto \max(f(x), g(x))$.

*Proof.* By Lemma 3.4, $\max(f, g) = f + \operatorname{ReLU}(g + (-1)\cdot f)$,
which is built from $f, g$ by scaling, addition, and rectification — all
generators of the class. $\qquad\blacksquare$

**Proposition 3.6 (Tropical polynomials are network-computable).** Every tropical
polynomial is network-computable.

*Proof sketch.* A tropical polynomial is a maximum over a finite nonempty set $S$
of affine functionals. Induct on $S$: the single-piece case is an affine
functional (a generator), and adjoining one more piece is a pairwise maximum,
which preserves network-computability by Proposition 3.5. $\qquad\blacksquare$

**Corollary 3.7 (Converse direction).** Every tropical rational function is
network-computable.

*Proof.* Write $f = p - q = p + (-1)\cdot q$ with $p, q$ tropical polynomials. By
Proposition 3.6 both $p$ and $q$ are network-computable, and the class is closed
under scaling by $-1$ and addition. $\qquad\blacksquare$

Combining Corollaries 3.3 and 3.7 yields the headline theorem.

**Theorem 3.8 (Depth-free characterization).** A function
$f : \mathbb{R}^d \to \mathbb{R}$ is network-computable — i.e. computable by a
feed-forward ReLU network of arbitrary finite depth and width — if and only if it
is a tropical rational function:
$$f \text{ is network-computable} \iff f = p - q \text{ for tropical polynomials } p, q.$$

**Remark 3.9 (Why the equivalence is tight).** No hypothesis on depth or width is
needed. The reason is structural: the four generating operations of a network
coincide exactly with the closure operations of the difference structure of the
max-plus semiring. Depth affects the *size* of the piece sets $S, T$ (composition
of tropical rationals multiplies piece counts), and hence the efficiency of a
representation, but never the *class* of representable functions.

## 4. The decision boundary lies on an algebraic hypersurface

We now realize the piecewise-linear boundary inside a classical algebraic
variety. Fix a tropical rational classifier $f = p - q$ with explicit piece sets
$$p(x) = \max_{(a,b) \in S_p}\big(\langle a, x\rangle + b\big), \qquad
  q(x) = \max_{(c,e) \in S_q}\big(\langle c, x\rangle + e\big),$$
where $S_p, S_q$ are finite and nonempty.

**Definition 4.1 (Affine polynomial).** To each affine functional $(a, b)$
associate the degree-$\le 1$ multivariate polynomial
$$P_{(a,b)} = b + \sum_{j=1}^{d} a_j\, X_j \in \mathbb{R}[X_1, \dots, X_d],$$
so that evaluation recovers the functional:
$P_{(a,b)}(x) = \langle a, x\rangle + b = \operatorname{aff}_{(a,b)}(x)$.

**Definition 4.2 (Boundary polynomial).** The *boundary polynomial* of the pair
$(S_p, S_q)$ is the product of all pairwise affine differences:
$$B_{S_p, S_q} \;=\; \prod_{(a,b) \in S_p}\; \prod_{(c,e) \in S_q}\;
   \big(P_{(a,b)} - P_{(c,e)}\big) \;\in\; \mathbb{R}[X_1, \dots, X_d].$$
It has degree at most $|S_p|\cdot|S_q|$, each factor being an affine (degree
$\le 1$) polynomial cutting out the hyperplane where one piece of $p$ ties one
piece of $q$.

**Lemma 4.3 (Evaluation of the boundary polynomial).** For all
$x \in \mathbb{R}^d$,
$$B_{S_p, S_q}(x) = \prod_{(a,b) \in S_p}\;\prod_{(c,e) \in S_q}
   \Big(\big(\langle a,x\rangle + b\big) - \big(\langle c,x\rangle + e\big)\Big).$$

*Proof.* Evaluation is a ring homomorphism, so it commutes with products and
differences; apply Definition 4.1 factorwise. $\qquad\blacksquare$

**Lemma 4.4 (Attained pieces on the boundary).** If $p(x) = q(x)$, then there
exist $(a,b) \in S_p$ and $(c,e) \in S_q$ with
$$\langle a, x\rangle + b = \max(p(x), q(x)) = \langle c, x\rangle + e.$$

*Proof.* Because $S_p$ is finite and nonempty, the maximum defining $p(x)$ is
attained by some piece $(a,b) \in S_p$, so $\langle a,x\rangle + b = p(x)$;
likewise some $(c,e) \in S_q$ attains $\langle c,x\rangle + e = q(x)$. Since
$p(x) = q(x)$, both equal $\max(p(x), q(x))$. $\qquad\blacksquare$

**Theorem 4.5 (Algebraic boundary containment).** With notation as above, the
decision boundary of $f = p - q$ is contained in the real zero locus of the
boundary polynomial:
$$\partial(p - q) = \{\, x : p(x) = q(x) \,\}\;\subseteq\; \{\, x : B_{S_p, S_q}(x) = 0 \,\}.$$
In particular, the piecewise-linear decision boundary lies inside the algebraic
hypersurface defined by the single polynomial $B_{S_p, S_q}$.

*Proof.* Let $x \in \partial(p-q)$, so $p(x) = q(x)$. By Lemma 4.4 there are
pieces $(a,b) \in S_p$ and $(c,e) \in S_q$ with $\langle a,x\rangle + b =
\langle c,x\rangle + e$; hence the corresponding factor
$(\langle a,x\rangle + b) - (\langle c,x\rangle + e)$ vanishes. A product is zero
whenever one factor is zero, so by Lemma 4.3, $B_{S_p, S_q}(x) = 0$. $\qquad\blacksquare$

**Remark 4.6 (Strictness of the containment).** The inclusion in Theorem 4.5 is
generally strict and cannot be improved to equality. The polynomial
$B_{S_p, S_q}$ vanishes on *every* hyperplane $\langle a - c, x\rangle + (b - e) =
0$ where some piece of $p$ ties some piece of $q$, whether or not those pieces are
the *active* (maximizing) pieces at that point. Points where two pieces tie but
neither attains the overall maximum are "phantom crossings": they lie on the
algebraic variety but not on the true decision boundary. The variety is therefore
a faithful *outer approximation* — it contains the boundary exactly, and adds only
lower-dimensional phantom sheets. Removing these inactive factors is the subject
of the conjectures in Section 8.

**Corollary 4.7 (Degree bound).** The decision boundary of a tropical rational
classifier with $m = |S_p|$ and $k = |S_q|$ affine pieces lies on an algebraic
hypersurface of degree at most $m \cdot k$.

## 5. Worked examples

**Example 5.1 (A composed network is tropical rational).** For affine functionals
$(a_1, b_1), (a_2, b_2)$ and scalar $c$, the function
$$x \mapsto c\,\operatorname{ReLU}(\langle a_1, x\rangle + b_1)
   + \operatorname{ReLU}(\langle a_2, x\rangle + b_2)$$
is network-computable (it is a scaled rectified affine unit added to a rectified
affine unit) and therefore, by Theorem 3.8, a tropical rational function.

**Example 5.2 (Absolute value).** The classifier $f(x) = |x_1|$ on $\mathbb{R}^d$
is tropical rational: $|x_1| = \max(x_1, -x_1) = p(x) - q(x)$ with
$p(x) = \max(x_1, -x_1)$ and $q = 0$. Its decision boundary is the hyperplane
$\{x_1 = 0\}$. With $S_p = \{(e_1, 0), (-e_1, 0)\}$ and $S_q = \{(0,0)\}$, the
boundary polynomial is $B(x) = (X_1 - 0)(-X_1 - 0) = -X_1^2$, whose zero locus is
exactly $\{x_1 = 0\}$ — here the containment is an equality.

**Example 5.3 (A strict containment).** Let $d = 1$, $p(x) = \max(x, -x) = |x|$,
$q(x) = \max(2x, -2x, 1) = \max(2|x|, 1)$. The boundary $\{p = q\}$ consists of
the two points where $|x| = \max(2|x|, 1)$, i.e. $|x| = 1$ giving $x = \pm 1$
(there $\max(2, 1) = 2 \ne 1$, so in fact one checks the crossing points
directly). The boundary polynomial multiplies together *all* six pairwise
differences, including factors such as $X - 1$ and $-X - 1$ arising from
tie-hyperplanes that are not attained; its real zero set is a finite set strictly
larger than the true two-point boundary, illustrating Remark 4.6.

## 6. Algorithms

We summarize the constructive content as three algorithms; full implementations
appear in the accompanying code.

**Algorithm A (Boundary polynomial construction).** Given piece sets $S_p, S_q$,
return the coefficient list of $B_{S_p, S_q}$ by forming, for each pair of
pieces, the affine difference polynomial and multiplying all of them. Complexity:
$O(mk)$ affine factors, each of size $O(d)$; the expanded product has degree
$mk$.

**Algorithm B (Boundary membership test).** Given a point $x$, decide whether
$x \in \partial(p-q)$ by evaluating $p(x)$ and $q(x)$ (each $O(md)$ and $O(kd)$)
and testing equality; and separately evaluate $B_{S_p,S_q}(x)$ as a product of
$mk$ affine evaluations to confirm $x$ lies on the variety.

**Algorithm C (Max-to-ReLU compilation).** Given a tropical polynomial as a list
of affine pieces, emit an equivalent ReLU network by repeatedly applying
$\max(a,b) = a + \operatorname{ReLU}(b - a)$, realizing the depth-free converse
constructively.

## 7. Applications and discussion

**Expressivity.** Theorem 3.8 gives a clean semantic identity for ReLU networks:
they compute exactly the tropical rational functions. This reframes questions
about network expressivity as questions about representing differences of convex
piecewise-linear functions.

**Complexity of boundaries.** Corollary 4.7 supplies a computable complexity
measure — the degree $m \cdot k$ of the boundary polynomial — for the geometric
intricacy of a classifier, linking the number of linear pieces to algebraic
degree.

**A three-way bridge.** Together the results connect neural computation, max-plus
geometry, and classical algebraic geometry: a network is a tropical rational
function, and its decision surface embeds in an algebraic hypersurface with an
explicit defining polynomial. Tools from each field (piece counting, tropical
hypersurfaces, algebraic degree and factorization) become mutually available.

## 8. Future directions

**Conjecture 1 — Minimal algebraic degree equals essential piece count.** For a
tropical rational classifier presented with $m$ and $k$ affine pieces, the
boundary polynomial has degree $m \cdot k$, but the *minimal* degree of an
algebraic hypersurface containing the decision boundary equals the number of
pieces that are actually active on the boundary, which can be far smaller. Only
the pieces attaining the shared maximum contribute crossings, so inactive factors
are removable and the true algebraic complexity is governed by an *activation
pattern* rather than the raw architecture. The explicit product form of the
boundary polynomial makes "removable factor" a precise, checkable notion,
turning a qualitative folklore observation into a computable degree bound.

**Conjecture 2 — Depth compresses algebraic degree exponentially.** There exist
target hypersurfaces whose boundary polynomial, when realized by a shallow
network, has degree exponential in the input dimension, yet which are realized by
a deep network whose boundary polynomial has only polynomial degree. Composition
of tropical rational functions multiplies piece counts, so depth trades a wide
max-of-affines (high degree at one layer) for an iterated composition (low degree
per layer), mirroring known depth–width separations for counting linear regions.
The depth-free characterization guarantees both realizations compute the same
function, so the comparison of algebraic degrees is well posed and isolates depth
as the sole variable.

**Conjecture 3 — The boundary variety is reducible exactly at shared pieces.** The
algebraic hypersurface carrying the decision boundary factors into irreducible
affine hyperplanes, and two classifiers are boundary-equivalent (identical
decision sets) if and only if their essential (active) hyperplane factors
coincide as sets. Reducibility of the boundary variety would then read off
directly from the shared-piece structure of the two tropical polynomials.

## 9. Conclusion

We proved that ReLU networks of arbitrary depth compute exactly the tropical
rational functions, and that the decision boundary of any such classifier lies
inside an explicit algebraic hypersurface cut out by the product of pairwise
affine differences of its pieces. The first result removes depth as a variable in
the qualitative expressivity question; the second turns a piecewise-linear
boundary into an object of classical algebraic geometry with a written-down
equation. The interplay — tight equivalence on the one hand, honest one-sided
containment on the other — outlines a precise research program at the meeting
point of deep learning, tropical geometry, and algebraic geometry.
