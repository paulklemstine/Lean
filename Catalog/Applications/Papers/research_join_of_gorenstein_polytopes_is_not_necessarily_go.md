# The Join of Gorenstein Polytopes Is Always Gorenstein

**Author:** Aristotle

**Date:** 2026-06-28

## Abstract

We resolve, in the negative, the conjecture that the *join* of two Gorenstein lattice
polytopes can fail to be Gorenstein. Working at the level of the Ehrhart
$h^*$-polynomial (the $\delta$-polynomial) — the standard faithful invariant governing
the Gorenstein property via the Stanley–Hibi symmetry criterion — we show that the join
operation corresponds exactly to multiplication of $h^*$-polynomials, and that the
product of two palindromic polynomials over an integral domain is again palindromic.
Consequently the join of Gorenstein polytopes is **always** Gorenstein. We package the
$h^*$-data of a Gorenstein polytope as a structure carrying three invariants — constant
term $1$, coefficientwise nonnegativity, and reverse-symmetry — and prove that the join
is a total operation on this class. We further establish degree additivity
($\deg h^*_{P*Q} = \deg h^*_P + \deg h^*_Q$), a point-identity law, and commutativity and
associativity, exhibiting Gorenstein $h^*$-data as a commutative monoid under the join.
Finally, we explain why the original intuition is sound but misattributed: it is the
**free sum** $P \oplus Q$, whose $h^*$-polynomial is governed by a non-multiplicative
convolution, that genuinely can break the Gorenstein property.

## 1. Introduction

A **lattice polytope** is the convex hull of finitely many points of the integer lattice
$\mathbb{Z}^d$. Such polytopes are the central objects of Ehrhart theory and appear
throughout combinatorial commutative algebra, toric geometry, and mathematical physics.
A distinguished subclass — the **Gorenstein** polytopes — is characterized by a hidden
internal symmetry of its lattice-point enumerator. The most symmetric Gorenstein
polytopes, the **reflexive** polytopes, classify Gorenstein toric Fano varieties and,
via the Batyrev–Borisov construction, families of Calabi–Yau hypersurfaces in mirror
symmetry.

Polytopes can be combined in several natural ways. Two of the most important are:

- the **join** $P * Q$, the convex hull of $P$ and $Q$ placed in skew affine subspaces
  of a common higher-dimensional space;
- the **free sum** $P \oplus Q$, formed by placing $P$ and $Q$ so they meet only at a
  shared relative-interior point.

A natural and well-motivated question asks whether the Gorenstein property is *inherited*
by these operations. The conjecture motivating this work asserted:

> **(Conjecture, refuted.)** There exist Gorenstein lattice polytopes $P$, $Q$ such that
> the join $P * Q$ is not Gorenstein.

Our main theorem refutes this. The Gorenstein property is **always** inherited by the
join. The genuine failure of inheritance occurs for the free sum, not the join, and we
make this distinction precise.

## 2. Background and definitions

### 2.1 The Ehrhart series and the $h^*$-polynomial

Let $P \subseteq \mathbb{R}^N$ be a $d$-dimensional lattice polytope, and for an integer
$t \ge 0$ let $L_P(t) = \#(tP \cap \mathbb{Z}^N)$ count the lattice points in the
$t$-fold dilate. Ehrhart's theorem states $L_P$ agrees with a polynomial of degree $d$.
The associated generating function admits the rational form

$$\operatorname{Ehr}_P(z) \;=\; \sum_{t \ge 0} L_P(t)\, z^t
\;=\; \frac{h^*_P(z)}{(1-z)^{d+1}},$$

where the numerator $h^*_P(z) = \sum_{i=0}^{s} h^*_i\, z^i$ is the **$h^*$-polynomial**
(equivalently, the $\delta$-polynomial). Two foundational facts pin it down:

- **(Stanley nonnegativity.)** $h^*_i \in \mathbb{Z}_{\ge 0}$ for all $i$.
- **(Normalization.)** $h^*_0 = 1$ for every nonempty lattice polytope.

The integer $s = \deg h^*_P$ is the **degree** of $P$, and $d + 1 - s$ is its
**codegree**.

### 2.2 The Gorenstein property and the Stanley–Hibi criterion

**Definition (Gorenstein, $h^*$-form).** A lattice polytope $P$ is **Gorenstein** if its
$h^*$-vector is *symmetric* (palindromic):

$$h^*_i = h^*_{s-i} \quad \text{for all } 0 \le i \le s, \qquad s = \deg h^*_P.$$

Equivalently, writing $\operatorname{rev}$ for the operation that reverses a polynomial's
coefficient list, $P$ is Gorenstein iff $\operatorname{rev}(h^*_P) = h^*_P$. This is the
Stanley–Hibi characterization: the algebraic Gorenstein property of the associated
semigroup ring is equivalent to palindromy of the $h^*$-vector.

Because the $h^*$-polynomial is a faithful and standard carrier of the Gorenstein
property, we model a Gorenstein polytope abstractly by its $h^*$-data.

**Definition (Gorenstein $h^*$-data).** A *Gorenstein $h^*$-datum* is a polynomial
$h \in \mathbb{Z}[z]$ together with the three properties

1. $h(0) = 1$ (i.e. the coefficient of $z^0$ is $1$),
2. every coefficient of $h$ is $\ge 0$,
3. $\operatorname{rev}(h) = h$ (palindromy).

We denote the type of such data by `GorensteinHStar`. In the formal development this is a
structure with fields `h`, `coeff_zero`, `nonneg`, and `symm` carrying exactly (1)–(3).

### 2.3 The join and its Ehrhart multiplicativity

**Definition (Join).** For lattice polytopes $P \subseteq \mathbb{R}^m$ and
$Q \subseteq \mathbb{R}^n$, the **join** is

$$P * Q \;=\; \operatorname{conv}\Big( (P \times \{0\} \times \{0\}) \cup
(\{0\} \times Q \times \{1\}) \Big) \subseteq \mathbb{R}^{m+n+1}.$$

It satisfies the dimension law $\dim(P * Q) = \dim P + \dim Q + 1$.

**Theorem (Classical join multiplicativity).** The $h^*$-polynomial of a join is the
product of the factors' $h^*$-polynomials:

$$h^*_{P * Q}(z) \;=\; h^*_P(z)\cdot h^*_Q(z).$$

Correspondingly, codegrees add and the degrees of the $h^*$-polynomials add. This
identity is the analytic reflection of the fact that the Ehrhart series of a join is, up
to the bookkeeping of the extra dimension, the product of the factors' series. We take it
as the modeling assumption for the join on $h^*$-data: the join multiplies polynomials.

## 3. Main results

We now state the results, each mirroring a named declaration in the formal development.

### 3.1 The join is total on Gorenstein $h^*$-data

**Definition (Join of $h^*$-data, `GorensteinHStar.join`).** For Gorenstein $h^*$-data
$P$ and $Q$, define $P.\mathtt{join}\,Q$ to be the $h^*$-datum whose polynomial is
$P.h \cdot Q.h$, with the three invariants verified as follows.

**Theorem 3.1 (Closure under join).** If $P$ and $Q$ are Gorenstein $h^*$-data, then so
is $P.\mathtt{join}\,Q$. Concretely:

- **Constant term (`join_coeff_zero`).** $(P.h \cdot Q.h)(0) = P.h(0)\cdot Q.h(0)
  = 1 \cdot 1 = 1.$
- **Nonnegativity (`join_nonneg`).** Each coefficient of the product is
  $\displaystyle [z^i](P.h\cdot Q.h) = \sum_{j+k=i} [z^j]P.h \cdot [z^k]Q.h$, a sum of
  products of nonnegative integers, hence $\ge 0$.
- **Symmetry (`join_symm`).** $\operatorname{rev}(P.h\cdot Q.h)
  = \operatorname{rev}(P.h)\cdot \operatorname{rev}(Q.h) = P.h\cdot Q.h.$

*Proof sketch.* The constant term and nonnegativity follow from the convolution formula
for the coefficients of a product, since the constituent coefficients are nonnegative and
the constant terms are $1$. The symmetry statement is the crux. The reverse (coefficient
reversal) operation is **multiplicative over an integral domain**: for $p, q$ in
$\mathbb{Z}[z]$,
$$\operatorname{rev}(p\cdot q) = \operatorname{rev}(p)\cdot \operatorname{rev}(q).$$
(This is `Polynomial.reverse_mul_of_domain` in the underlying library; it holds because
$\mathbb{Z}[z]$ has no zero divisors, so no leading-coefficient cancellation occurs.)
Applying this to $p = P.h$, $q = Q.h$ and then substituting the hypotheses
$\operatorname{rev}(P.h) = P.h$ and $\operatorname{rev}(Q.h) = Q.h$ gives
$\operatorname{rev}(P.h\cdot Q.h) = P.h\cdot Q.h$, as required. $\qquad\blacksquare$

A coordinate-free way to see the symmetry step: $p$ of degree $d$ is palindromic iff
$z^d p(1/z) = p(z)$. Then
$$z^{d+e}(pq)(1/z) = \big(z^d p(1/z)\big)\big(z^e q(1/z)\big) = p(z) q(z),$$
so $pq$ is palindromic of degree $d+e$.

**Corollary 3.2 (Refutation of the conjecture).** There do **not** exist Gorenstein
polytopes whose join is non-Gorenstein. Equivalently, `join_symm` holds for all $P, Q$:
$$\operatorname{rev}\big((P.\mathtt{join}\,Q).h\big) = (P.\mathtt{join}\,Q).h.$$

### 3.2 The $h^*$-multiplicativity identity, recorded

**Proposition 3.3 (`join_h`).** $(P.\mathtt{join}\,Q).h = P.h \cdot Q.h$. This is the
formal record of the classical identity $h^*_{P*Q} = h^*_P \cdot h^*_Q$, true by
definition of the join on $h^*$-data.

### 3.3 Nonvanishing and degree additivity

**Lemma 3.4 (`h_ne_zero`).** Every Gorenstein $h^*$-polynomial is nonzero, since its
constant coefficient is $1 \ne 0$.

**Theorem 3.5 (Degree additivity, `join_natDegree`).** For Gorenstein $h^*$-data $P, Q$,
$$\deg\big((P.\mathtt{join}\,Q).h\big) = \deg(P.h) + \deg(Q.h).$$

*Proof sketch.* Over an integral domain, $\deg(pq) = \deg p + \deg q$ whenever $p, q \ne
0$ (`Polynomial.natDegree_mul`). Both factors are nonzero by Lemma 3.4. $\qquad\blacksquare$

This is the $h^*$-degree counterpart of the dimension law $\dim(P*Q) = \dim P + \dim Q +
1$ and of the additivity of codegrees under the join.

### 3.4 Algebraic structure: a commutative monoid

**Proposition 3.6 (Point identity, `hstarPoint_join`).** Let `hstarPoint` be the
$h^*$-datum with $h = 1$ (the $h^*$-polynomial of a point, and of the empty reflexive
simplex). Then for all $P$,
$$(\mathtt{hstarPoint}.\mathtt{join}\,P).h = P.h,$$
since $1 \cdot P.h = P.h$. Geometrically, $\{pt\} * P$ is the pyramid over $P$, with the
same Gorenstein $h^*$-polynomial.

**Proposition 3.7 (Commutativity, `join_comm`).**
$(P.\mathtt{join}\,Q).h = (Q.\mathtt{join}\,P).h$, from $P.h\cdot Q.h = Q.h\cdot P.h$.

**Proposition 3.8 (Associativity, `join_assoc`).**
$((P.\mathtt{join}\,Q).\mathtt{join}\,R).h = (P.\mathtt{join}\,(Q.\mathtt{join}\,R)).h$,
from associativity of polynomial multiplication.

**Corollary 3.9 (Monoid structure).** The triple
$(\mathtt{GorensteinHStar}, \mathtt{join}, \mathtt{hstarPoint})$ is a commutative monoid
(up to equality of underlying $h^*$-polynomials): the join is closed (Theorem 3.1),
associative (3.8), commutative (3.7), and unital with the point as identity (3.6).

## 4. Worked examples

**Example 4.1 (The point).** `hstarPoint` has $h = 1$, vector $(1)$. It is trivially
palindromic, nonnegative, and normalized.

**Example 4.2 (A reflexive polygon).** The datum `hstarReflexivePolygon` has
$$h = 1 + 4z + z^2, \qquad \text{vector } (1, 4, 1),$$
the $h^*$-polynomial of a reflexive triangle of normalized volume $6$. It is palindromic
of degree $2$, so Gorenstein.

**Example 4.3 (Join of two reflexive polygons).** Multiplying the polynomials,
$$(1 + 4z + z^2)(1 + 4z + z^2) = 1 + 8z + 18z^2 + 8z^3 + z^4,$$
vector $(1, 8, 18, 8, 1)$ — palindromic of degree $4$, hence Gorenstein, in agreement
with Theorem 3.1. Note the degree $4 = 2 + 2$ matches Theorem 3.5.

**Example 4.4 (Join with a point).** $(1)\cdot(1,4,1) = (1,4,1)$: the pyramid leaves the
$h^*$-polynomial unchanged, illustrating Proposition 3.6.

## 5. The genuine failure: free sums

The original intuition — that combining Gorenstein polytopes can destroy symmetry — is
correct, but for the **free sum** $P \oplus Q$, not the join. The free sum does **not**
multiply $h^*$-polynomials; its Ehrhart numerator is governed by a more delicate
convolution (studied by Braun and collaborators) that mixes coefficients in a way that
need not preserve palindromy.

A crude stand-in clarifies why an additive/concatenative combination can break symmetry
where multiplication cannot. Reversal is a *ring* anti-/homomorphism for multiplication
but has no comparable compatibility with concatenation: concatenating the palindromes
$(1,4,1)$ and $(1,1)$ yields $(1,4,1,1,1)$, which is not palindromic. The lesson is
structural: **palindromy is preserved by exactly those binary operations that act as a
graded ring multiplication on coefficient vectors.** The join is such an operation; the
free sum is not.

## 6. Algorithms

The results are entirely effective. We summarize the two core procedures (full Python in
the accompanying demo).

**Algorithm A — `is_gorenstein(h)`.** Decide the Gorenstein property of an $h^*$-vector.
Strip trailing zeros to obtain the true degree $s$, then test $h_i = h_{s-i}$ for all
$i$, together with $h_0 = 1$ and $h_i \ge 0$. Cost $O(s)$.

**Algorithm B — `join_hstar(p, q)`.** Compute the join's $h^*$-vector as the discrete
convolution (polynomial product) of $p$ and $q$:
$(p*q)_i = \sum_{j+k=i} p_j q_k$. Cost $O(\deg p \cdot \deg q)$ (or $O(n\log n)$ via FFT).
By Theorem 3.1, the output is Gorenstein whenever both inputs are.

## 7. Applications

- **Toric geometry.** Reflexive and Gorenstein polytopes correspond to Gorenstein Fano
  toric varieties; the join corresponds to a controlled geometric construction under
  which the Gorenstein (canonical-symmetry) property is now guaranteed to persist.
- **Mirror symmetry.** Stability of the Gorenstein property under the join provides a
  closed, well-behaved class of polytopes for building Calabi–Yau examples by iterated
  joins, with predictable degree (codegree) bookkeeping via Theorem 3.5.
- **Combinatorial construction.** The monoid structure (Corollary 3.9) lets one assemble
  large Gorenstein examples from small "join-prime" building blocks, with the point as a
  neutral pyramiding operation.

## 8. Discussion and future work

The decisive simplification was to pass from geometry to the $h^*$-polynomial, where the
Gorenstein property is palindromy and the join is multiplication, reducing the conjecture
to the elementary and true statement that products of palindromes are palindromes. We
record the resulting research directions.

**Conjecture 1 (Free-sum failure — the "true" form of the title).** There exist reflexive
(Gorenstein) polytopes $P$, $Q$ whose free sum $P \oplus Q$ is not Gorenstein. Testable:
formalize Braun's free-sum $h^*$-identity and exhibit explicit $h^*$-data whose free-sum
combination is non-palindromic.

**Conjecture 2 (Index additivity of the join).** For Gorenstein $P$ (codegree $r_P$) and
$Q$ (codegree $r_Q$), the join has codegree $r_P + r_Q$, equivalently
$\deg h^*_{P*Q} = \deg h^*_P + \deg h^*_Q$ — established here as Theorem 3.5.

**Conjecture 3 (Monoid / unique factorization).** $(\mathtt{GorensteinHStar}, \mathtt{join},
\mathtt{hstarPoint})$ is a free commutative monoid on the join-irreducible Gorenstein
$h^*$-polynomials, giving unique factorization of Gorenstein polytopes into join-prime
pieces. Testable via irreducibility of palindromic factors in $\mathbb{Z}[X]$.

**Conjecture 4 (Symmetry-preserving operations are the multiplicative ones).** Among
natural binary operations on $h^*$-vectors (product = join, sum, Hadamard product,
free-sum convolution), the palindromy-preserving ones are precisely those acting as a
graded ring multiplication.

**Conjecture 5 (Effective Gorenstein from join roots).** If $p\cdot q$ is palindromic
with $p, q$ having constant term $1$ and nonnegative coefficients, then both $p$ and $q$
are palindromic — a converse to the join theorem. If true, the join is Gorenstein **iff**
both factors are.

## 9. Conclusion

The join of two Gorenstein lattice polytopes is always Gorenstein. The conjectured
counterexample does not exist, because the join multiplies $h^*$-polynomials and the
product of palindromic polynomials is palindromic. The same algebra delivers degree
additivity and a commutative-monoid structure with the point as identity. The genuine
locus of failure is the free sum, which we isolate as the principal direction for future
investigation.
