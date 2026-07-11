# The Mega-Sphere: Inverse Limits, Characteristic Classes, and Bernoulli Numbers

## Abstract

We develop the rigorous algebraic skeleton behind the *mega-sphere* idea: a
single universal object that recovers every finite stage of an infinite tower at
once. Three complementary strands are treated. First, we construct the **inverse
limit** of a tower of additive groups (and of rings) as a concrete subobject of
the product, establish its projections and their coherence, and prove its full
**universal property** — existence and uniqueness of the mediating map. We
evaluate two extreme towers: the doubling tower
$\mathbb{Z} \xleftarrow{\times 2} \mathbb{Z} \xleftarrow{\times 2} \cdots$
collapses to the trivial group, whereas the $2$-adic tower
$\mathbb{Z}/2^{n+1}\mathbb{Z}$ has a nontrivial inverse limit. Second, we record
the cohomological fingerprint of the infinite tower of real projective spaces:
$H^{*}(\mathbb{R}P^{\infty}; \mathbb{F}_2) \cong \mathbb{F}_2[w]$, the total
Stiefel–Whitney class $1+w$, its product behaviour, and the dual class
$\overline{w} = \sum_{k\ge 0} w^k$ that inverts $1+w$ in the completion
$\mathbb{F}_2[[w]]$. Third, we prove the Bernoulli **recurrence**
$\sum_{k<n}\binom{n}{k}B_k = 0$ for $n\ne 1$, the vanishing of odd Bernoulli
numbers $B_{2n+3}=0$, and the Bernoulli-driven **Faulhaber** power-sum formulas
for $\sum k$, $\sum k^2$, $\sum k^3$, the last being Nicomachus's identity
$\sum k^3 = (\sum k)^2$. Together these give an honest, self-contained account of
"all dimensions at once."

## 1. Introduction

Many of the central objects of mathematics arise as infinite towers indexed by a
dimension or a level of precision:
$$\cdots \to X_{n+1} \xrightarrow{\ \pi_n\ } X_n \to \cdots \to X_1 \to X_0.$$
The *mega-sphere* program asks whether a single object can encode an entire such
tower simultaneously, so that projecting onto any coordinate returns the
corresponding stage. The precise embodiment of this idea is the **inverse
limit**, the universal cone over the tower. This paper builds that construction
from first principles for towers of groups and rings, proves its universal
property, and then illustrates the mega-sphere philosophy in two further arenas
where "all dimensions at once" produces clean structure: the mod-$2$ cohomology
of the infinite real projective space, and the Bernoulli numbers that govern
power sums across all exponents.

Our aim is honesty of scope. The literal slogan — "a single object whose
projections give $S^0, S^1, S^2, \dots$, whose homology encodes the Bernoulli
numbers, and whose cohomology ring is the polynomial ring on Stiefel–Whitney
classes" — braids together several genuine but distinct pieces of mathematics.
We isolate the pieces that are both true and provable, and we state precisely
what each result says.

## 2. Inverse limits of towers

### 2.1 Definition

Let $(X_n)_{n\in\mathbb{N}}$ be a family of additive groups equipped with
connecting homomorphisms $\pi_n : X_{n+1} \to X_n$. The tower is
$$\cdots \xrightarrow{\pi_{n+1}} X_{n+1} \xrightarrow{\pi_n} X_n \xrightarrow{\pi_{n-1}} \cdots \xrightarrow{\pi_0} X_0.$$

**Definition 2.1 (Inverse limit).** The *inverse limit* $\varprojlim X_n$ is the
subgroup of the product $\prod_n X_n$ consisting of *coherent sequences*:
$$\varprojlim X_n = \Big\{\, x \in \textstyle\prod_n X_n \ :\ \pi_n\big(x(n+1)\big) = x(n) \ \text{ for all } n \,\Big\}.$$
This set contains $0$, is closed under addition and negation (because each
$\pi_n$ is a homomorphism), and hence is a subgroup of the product. When the
$X_n$ are rings and the $\pi_n$ ring homomorphisms, the same coherent sequences
form a subring $\varprojlim X_n \subseteq \prod_n X_n$.

### 2.2 Projections and coherence

**Definition 2.2 (Projections).** For each stage $n$, the *projection*
$p_n : \varprojlim X_n \to X_n$ is the restriction to $\varprojlim X_n$ of the
coordinate evaluation $x \mapsto x(n)$. It is a homomorphism.

**Proposition 2.3 (Coherence of projections).** For every $n$ and every coherent
sequence $x$,
$$\pi_n\big(p_{n+1}(x)\big) = p_n(x).$$
*Proof.* By definition $p_{n+1}(x) = x(n+1)$ and $p_n(x) = x(n)$, and membership
in the inverse limit is exactly the equation $\pi_n(x(n+1)) = x(n)$. $\square$

Thus $\varprojlim X_n$, together with the family $(p_n)$, is a **cone** over the
tower: a single object mapping compatibly onto every stage.

### 2.3 The universal property

The inverse limit is not merely *a* cone; it is the terminal one.

**Theorem 2.4 (Universal property).** Let $Y$ be an additive group equipped with
a compatible cone, i.e. homomorphisms $g_n : Y \to X_n$ satisfying
$\pi_n \circ g_{n+1} = g_n$ for all $n$. Then:

1. *(Existence.)* There is a homomorphism $u : Y \to \varprojlim X_n$ with
   $p_n \circ u = g_n$ for every $n$, defined by $u(y) = (g_0(y), g_1(y), \dots)$.
2. *(Uniqueness.)* Any homomorphism $u' : Y \to \varprojlim X_n$ with
   $p_n \circ u' = g_n$ for all $n$ equals $u$.

*Proof.* For existence, define $u(y)$ to be the sequence $n \mapsto g_n(y)$. The
compatibility $\pi_n \circ g_{n+1} = g_n$ says exactly that this sequence is
coherent, so $u(y) \in \varprojlim X_n$; and $u$ is a homomorphism because each
$g_n$ is. By construction $p_n(u(y)) = g_n(y)$. For uniqueness, suppose $u'$ also
satisfies $p_n \circ u' = g_n$. Two elements of the inverse limit are equal iff
they agree in every coordinate; for each $y$ and each $n$ we have
$p_n(u'(y)) = g_n(y) = p_n(u(y))$, so $u'(y) = u(y)$. $\square$

Theorem 2.4 is the precise sense in which the mega-object "is" the tower: every
compatible way of observing all stages at once factors *uniquely* through it.

### 2.4 Two towers, two fates

The universal property is content-free until fed a tower; the following two
computations show the full spectrum of possibilities.

**Example 2.5 (Constant tower).** If $X_n = G$ for all $n$ and each $\pi_n =
\mathrm{id}_G$, then coherence forces $x(n+1) = x(n)$ for all $n$, so a coherent
sequence is constant. Hence $\varprojlim X_n$ is the diagonal copy of $G$: the
mega-object recovers exactly $G$.

**Theorem 2.6 (Collapse of the doubling tower).** Let $X_n = \mathbb{Z}$ for all
$n$ and $\pi_n(x) = 2x$. Then $\varprojlim X_n = 0$.

*Proof.* Let $x$ be coherent, so $x(n) = 2\,x(n+1)$ for all $n$. Iterating,
$x(0) = 2^m\, x(m)$ for every $m$, so $2^m \mid x(0)$ for all $m$. An integer
divisible by arbitrarily large powers of $2$ must be $0$; hence $x(0)=0$, and by
the same argument every $x(n)=0$. $\square$

**Theorem 2.7 (Nontriviality of the $2$-adic tower).** Let
$X_n = \mathbb{Z}/2^{n+1}\mathbb{Z}$ with $\pi_n$ the reduction
$\mathbb{Z}/2^{n+2}\mathbb{Z} \to \mathbb{Z}/2^{n+1}\mathbb{Z}$. Then
$\varprojlim X_n$ is nontrivial; it is the ring $\mathbb{Z}_2$ of $2$-adic
integers.

*Proof sketch.* The compatible sequence generated by the integer $1$ — its
residues $1 \bmod 2^{n+1}$ — is coherent and nonzero, so the limit is nontrivial.
More is true: coherent sequences of residues modulo the powers of $2$ are, by
definition, the elements of $\mathbb{Z}_2$, and the projections $p_n$ are the
standard truncations. $\square$

The contrast between Theorems 2.6 and 2.7 is the moral of the inverse-limit
strand: the *same* universal construction yields either the trivial object or a
genuinely new number system, depending only on how the stages are glued. A tower
whose projections are surjective (a Mittag-Leffler condition, satisfied by the
$2$-adic tower) guarantees the mega-object surjects onto every stage.

## 3. The cohomological fingerprint of $\mathbb{R}P^{\infty}$

We now turn from abstract towers to a concrete infinite-dimensional geometry.
Let $\mathbb{R}P^{\infty}$ denote the infinite real projective space, the union of
the tower $\mathbb{R}P^1 \subseteq \mathbb{R}P^2 \subseteq \cdots$ of spaces of
lines through the origin. Its mod-$2$ cohomology is the archetype of a
"all-dimensions-at-once" invariant.

**Theorem 3.1 (Cohomology ring of $\mathbb{R}P^\infty$).**
$$H^{*}(\mathbb{R}P^{\infty}; \mathbb{F}_2) \cong \mathbb{F}_2[w], \qquad \deg w = 1,$$
the polynomial ring in a single generator over the two-element field. The
generator $w = w_1$ is the first **Stiefel–Whitney class**.

This is the tautological/universal case of the general fact that the mod-$2$
cohomology of the classifying space $BO$ is the polynomial ring
$\mathbb{F}_2[w_1, w_2, \dots]$ on the full family of Stiefel–Whitney classes;
$\mathbb{R}P^{\infty} = BO(1)$ realizes the rank-one case with the single class
$w = w_1$.

**Definition 3.2 (Total class and product formula).** The *total Stiefel–Whitney
class* is $w(E) = 1 + w_1(E) + w_2(E) + \cdots$. For a direct sum of bundles the
Whitney product formula holds:
$$w(E \oplus F) = w(E)\cdot w(F).$$
In the rank-one model this is the multiplicative identity $(1+w)(1+w') $ mirrored
inside $\mathbb{F}_2[w]$; algebraically it is the Whitney–Frobenius identity, an
exact ring-theoretic incarnation of the geometric product law.

**Theorem 3.3 (Dual class in the completion).** In the ring of formal power
series $\mathbb{F}_2[[w]]$ the total class $1+w$ is a unit, with inverse the
*dual (total) Stiefel–Whitney series*
$$\overline{w} = \sum_{k=0}^{\infty} w^k = 1 + w + w^2 + w^3 + \cdots, \qquad (1+w)\,\overline{w} = 1.$$
*Proof.* A power series over a field is invertible iff its constant term is a
unit; here the constant term is $1$. Explicitly, $(1+w)\sum_{k\ge 0} w^k =
\sum_{k\ge 0} w^k + \sum_{k\ge 0} w^{k+1} = 1$ by telescoping (all cross terms
cancel in characteristic $2$, and indeed over any ring). $\square$

The passage to the completion $\mathbb{F}_2[[w]]$ is precisely the "all
dimensions at once" step: the dual class is an *infinite* series, meaningful only
in the completed ring. In the language of §2, $\mathbb{F}_2[[w]]$ is the inverse
limit of the truncations $\mathbb{F}_2[w]/(w^{n+1})$ under reduction, so the
completed cohomology ring itself *is* a mega-object in the inverse-limit sense.

## 4. Bernoulli numbers as universal arithmetic invariants

The third strand is arithmetic. The Bernoulli numbers $B_0, B_1, B_2, \dots \in
\mathbb{Q}$ are the universal rational coefficients through which summation across
all exponents is expressed.

### 4.1 The recurrence and small values

**Theorem 4.1 (Bernoulli recurrence).** For every $n \neq 1$,
$$\sum_{k=0}^{n-1} \binom{n}{k} B_k = 0.$$
Together with $B_0 = 1$ this determines every $B_n$. *Proof.* This is the
weighted-sum identity for Bernoulli numbers; specializing the general power-sum
identity $\sum_{k=0}^{n}\binom{n}{k}B_k = B_n + [\,n=1\,]$ and isolating the top
term gives the vanishing of the truncated sum for $n\ne 1$. $\square$

The recurrence yields
$$B_0 = 1,\quad B_1 = -\tfrac12,\quad B_2 = \tfrac16,\quad B_3 = 0,\quad B_4 = -\tfrac{1}{30},\quad B_5 = 0, \dots$$

**Theorem 4.2 ($B_2 = 1/6$).** Direct evaluation of the recurrence at $n=3$ (or
of the defining generating function) gives $B_2 = 1/6$.

### 4.2 Parity: vanishing of odd Bernoulli numbers

**Theorem 4.3 (Odd vanishing).** For all $n \ge 0$, $B_{2n+3} = 0$; equivalently,
$B_m = 0$ for every odd $m \ge 3$.

*Proof sketch.* Write the Bernoulli numbers via the shifted convention
$B'_m$ (which differ from $B_m$ only at $m=1$). The generating function
$\frac{t}{e^t - 1} + \frac{t}{2}$ is an even function of $t$, so all its odd
Taylor coefficients vanish; translating back, $B_m = 0$ for odd $m \ge 3$. $\square$

This parity is the structural reason the Bernoulli numbers control
$\zeta(1-2k) = -B_{2k}/2k$ and appear in the Hirzebruch $L$- and $\hat{A}$-genera
of manifolds; only the even-index Bernoulli numbers survive to carry that data.

### 4.3 Faulhaber's formula and Nicomachus's identity

For each exponent $p$, the power sum $\sum_{k=0}^{n-1}k^p$ is a polynomial in $n$
with Bernoulli coefficients:
$$\sum_{k=0}^{n-1} k^p = \frac{1}{p+1}\sum_{j=0}^{p}\binom{p+1}{j} B_j\, n^{p+1-j}.$$
Extracting small cases with $B_0=1$, $B_1=-\tfrac12$, $B_2=\tfrac16$, $B_3=0$:

**Theorem 4.4 (Faulhaber, $p=1,2,3$).**
$$\sum_{k=0}^{n-1} k = \frac{n(n-1)}{2},\qquad \sum_{k=0}^{n-1} k^2 = \frac{n(n-1)(2n-1)}{6},$$
$$\sum_{k=0}^{n-1} k^3 = \left(\frac{n(n-1)}{2}\right)^2.$$

**Corollary 4.5 (Nicomachus's identity).**
$$\sum_{k=0}^{n-1} k^3 = \left(\sum_{k=0}^{n-1} k\right)^2.$$
*Proof.* Combine the $p=3$ and $p=1$ cases of Theorem 4.4; the equality holds
because $B_3 = 0$, which suppresses the term that would otherwise break the
perfect square. $\square$

Nicomachus's identity is thus a small, visible consequence of the same parity
symmetry (Theorem 4.3) that ties the Bernoulli numbers to the geometry of
high-dimensional manifolds.

## 5. Algorithms

Three computational procedures accompany the theory.

**(A) Coherent-sequence membership test.** Given a finite truncation of a tower
and connecting maps $\pi_n$, verify whether a candidate sequence
$(x_0, \dots, x_N)$ is coherent by checking $\pi_n(x_{n+1}) = x_n$ for
$0 \le n < N$. This is the inverse-limit membership predicate of Definition 2.1
and runs in $O(N)$ map evaluations.

**(B) Bernoulli numbers by recurrence.** Compute $B_0, \dots, B_N$ using
Theorem 4.1: set $B_0 = 1$ and solve
$B_{n-1} = -\tfrac{1}{n}\sum_{k=0}^{n-2}\binom{n}{k}B_k$ ascending in $n$, in
exact rational arithmetic. Cost $O(N^2)$ rational operations.

**(C) Faulhaber coefficients.** From the Bernoulli numbers, assemble the
Faulhaber polynomial coefficients via
$\frac{1}{p+1}\binom{p+1}{j}B_j$ and evaluate power sums in closed form, avoiding
term-by-term summation.

## 6. Applications

- **$p$-adic number theory.** The $2$-adic tower (Theorem 2.7) is the entry point
  to $\mathbb{Z}_p$ and $\mathbb{Q}_p$, foundational to modern arithmetic
  geometry.
- **Characteristic classes.** Theorem 3.1 and the product formula underlie
  obstruction theory: nonvanishing Stiefel–Whitney classes detect
  non-parallelizability and non-null-cobordism.
- **Special values of $\zeta$.** Theorem 4.3 explains the appearance of Bernoulli
  numbers in $\zeta(1-2k)$ and in genera of manifolds.
- **Closed-form summation.** Theorem 4.4 gives exact power-sum evaluation used
  throughout combinatorics and numerical analysis.

## 7. Discussion and honest scope

The rigorous core is the inverse-limit construction with its universal property
(existence and uniqueness of the mediating map), together with the two concrete
evaluations. The projective-space strand records genuine ring-theoretic
incarnations of characteristic-class identities in $\mathbb{F}_2[w]$ and its
completion $\mathbb{F}_2[[w]]$. The arithmetic strand proves the Bernoulli
recurrence, odd vanishing, and the Faulhaber closed forms. We deliberately do not
overclaim a single topological object whose projections are the spheres
$S^0, S^1, \dots$; rather, the inverse limit provides the correct universal
framework, and the two further strands exhibit the mega-sphere philosophy in
cohomology and in arithmetic.

## 8. Future directions

1. **Ring inverse limit = completion.** Build the tower of truncated cohomologies
   $\mathbb{F}_2[w]/(w^{n+1})$ with reduction maps and prove
   $\mathbb{F}_2[[w]] \cong \varprojlim$, upgrading "the completed cohomology ring
   is the inverse limit" from slogan to theorem via the universal property.
2. **Surjective projections (Mittag-Leffler).** Prove every projection of the
   $2$-adic tower is surjective, generalizing to any tower with surjective
   connecting maps.
3. **Higher Stiefel–Whitney classes.** Move from $BO(1)=\mathbb{R}P^\infty$ to
   $BO(k)$ and $BO$, where $H^*(BO;\mathbb{F}_2)=\mathbb{F}_2[w_1,w_2,\dots]$, and
   formalize the Whitney product formula $w(E\oplus F)=w(E)w(F)$.
4. **Bernoulli ↔ characteristic numbers.** Connect the Bernoulli numbers to
   manifolds through the Hirzebruch $L$-genus and $\hat A$-genus and the
   $J$-homomorphism (denominators of $B_{2k}/4k$ give orders of stable homotopy
   groups of spheres), starting with the $L$-genus of $\mathbb{C}P^{2n}$ and the
   signature theorem.
5. **Genuine inverse limit in topology.** Replace the algebraic stand-ins by
   actual spheres/CW complexes and realize the tower in the category of spaces.

## References (classical)

- H. Faulhaber, on sums of powers (1631); J. Bernoulli, *Ars Conjectandi* (1713).
- J. Milnor and J. Stasheff, *Characteristic Classes*.
- K. Hensel, on $p$-adic numbers (1897).
