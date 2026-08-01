# Infinitesimal Point Masses on the Finite–Cofinite Algebra

**Aristotle**  
**1 August 2026**

## Abstract

We construct a normalized surreal-valued probability on the finite–cofinite algebra of any infinite sample space. The construction begins with the Conway cut

$$
\varepsilon=\left\{0\ \middle|\ 1,2^{-1},2^{-2},\ldots\right\},
$$

which is strictly positive and smaller than $2^{-n}$ for every $n\in\mathbb N$. In particular, every finite multiple $n\varepsilon$ is less than one. For an event $A$ that is finite or cofinite, define

$$
P(A)=|A|\varepsilon
$$

in the finite case and

$$
P(A)=1-|A^c|\varepsilon
$$

in the cofinite case. We prove that this definition is unambiguous on an infinite space, nonnegative, normalized, and additive on disjoint pairs. Every singleton consequently has the same strictly positive infinitesimal probability. Specializing the sample space to $[0,1]$ yields an explicit non-Archimedean probability model with positive point masses and total mass one. The result concerns finite additivity on the finite–cofinite algebra; it makes no claim of countable additivity on a power set or Borel $\sigma$-algebra. We also give an exact symbolic algorithm for calculations, discuss the classical shadow of the construction, and identify the additional summation and event-algebra structures required for extensions.

## 1. Introduction

A familiar feature of continuous probability is that every singleton has probability zero. Under the uniform probability measure on $[0,1]$, one has $P(\{x\})=0$ for every $x$, while $P([0,1])=1$. There is no contradiction: countable additivity does not add an uncountable collection of singleton masses, and ordinary length assigns zero to points.

Nevertheless, the question whether a point can receive a *positive infinitesimal* probability is mathematically natural. Such a value should be greater than zero but smaller than every ordinary positive scale relevant to the construction. The real numbers cannot provide it. Their Archimedean property says that for every real $r>0$, some natural multiple $nr$ exceeds one. A genuinely infinitesimal point mass therefore requires a non-Archimedean ordered field or ordered ring.

Conway’s surreal numbers provide an especially direct setting. They contain the real numbers and admit numbers specified recursively by left and right options. We use the cut with left option zero and right options $1,1/2,1/4,\ldots$. This yields a positive surreal $\varepsilon$ below every reciprocal power of two.

The second design choice is the event domain. Assigning a common infinitesimal to every point does not by itself determine the mass of arbitrary infinite subsets. We therefore work with the finite–cofinite algebra: events are exactly the finite sets and the sets with finite complement. Its geometry is simple enough that pointwise pricing determines every event, yet rich enough to include all singletons, their finite unions, complements, and the entire space.

The resulting theory separates three issues that are sometimes conflated:

- the **value domain**, here the surreal numbers;
- the **event algebra**, here finite and cofinite subsets;
- the **additivity principle**, here finite additivity.

Our main theorem states that on every infinite set $X$, finite events receive mass $|A|\varepsilon$ and cofinite events receive mass $1-|A^c|\varepsilon$. This is a normalized, nonnegative, finitely additive probability, and each singleton has mass $\varepsilon$. The specialization $X=[0,1]$ answers the motivating existence question in a precise restricted sense.

The restrictions are essential. We do not assign masses to all subsets or all Borel sets of $[0,1]$. We do not define infinite sums of surreal values, and hence do not assert $\sigma$-additivity. Rather than hiding these boundaries, we make them explicit and show exactly how far elementary surreal arithmetic and finite cardinality identities carry the theory.

## 2. Surreal preliminaries

### 2.1 Conway cuts

A surreal number may be represented by a cut

$$
\{L\mid R\},
$$

where $L$ and $R$ are collections of previously constructed surreal numbers such that every member of $L$ is strictly less than every member of $R$. The cut denotes the simplest surreal lying above every left option and below every right option. For the present construction, only the order consequences of this description are needed.

**Definition 2.1 (Dyadic surreal infinitesimal).** Define

$$
\varepsilon=\left\{0\ \middle|\ 1,\frac12,\frac14,\frac18,\ldots\right\}
=\left\{0\ \middle|\ 2^{-n}:n\in\mathbb N\right\}.
$$

Here $\mathbb N$ contains zero, so the first right option is $2^0=1$.

The defining options are correctly ordered because $0<2^{-n}$ for every $n$. Thus the cut defines a surreal number.

**Lemma 2.2 (Positivity and dyadic domination).** The number $\varepsilon$ satisfies

$$
0<\varepsilon<2^{-n}
$$

for every $n\in\mathbb N$.

**Proof sketch.** A number represented by a valid cut lies strictly above each left option and strictly below each right option. Zero is the sole left option, while every $2^{-n}$ is a right option. Applying these two order properties gives the claim. $\square$

This is a genuine infinitesimal property. If $r>0$ were real, the Archimedean property would provide an $n$ with $2^{-n}<r$, so no positive real $r$ lies below every $2^{-n}$.

### 2.2 Finite multiples

The probability construction needs not merely $\varepsilon<1$, but $n\varepsilon<1$ for every finite cardinality $n$.

**Lemma 2.3 (Finite-multiple bound).** For every $n\in\mathbb N$,

$$
n\varepsilon<1.
$$

**Proof sketch.** The elementary inequality $n\le 2^n$ holds for every natural number $n$. Since $\varepsilon>0$, multiplication by natural numbers preserves the resulting order, and Lemma 2.2 gives $\varepsilon<2^{-n}$. Therefore

$$
n\varepsilon\le 2^n\varepsilon<2^n2^{-n}=1.
$$

For $n=0$, this reads $0<1$; the same chain remains valid. $\square$

A useful consequence is that both $n\varepsilon$ and $1-n\varepsilon$ are nonnegative for every finite $n$, with the latter in fact strictly positive.

## 3. The finite–cofinite event algebra

Let $X$ be an infinite set. For $A\subseteq X$, write $A^c=X\setminus A$.

**Definition 3.1 (Admissible event).** A subset $A\subseteq X$ is an admissible event if either $A$ is finite or $A^c$ is finite. In the latter case $A$ is called cofinite. Let

$$
\mathcal F_X=\{A\subseteq X:A\text{ is finite or }A^c\text{ is finite}\}.
$$

**Lemma 3.2 (Boolean closure).** The collection $\mathcal F_X$ contains $\varnothing$ and $X$ and is closed under complements and finite unions. Consequently it is a Boolean algebra of subsets of $X$.

**Proof sketch.** The empty set is finite and $X$ is cofinite because $X^c=\varnothing$. Complementation exchanges the alternatives “finite” and “cofinite.” For unions, if both sets are finite, their union is finite. If one set is cofinite, the complement of the union is an intersection contained in the finite complement of that cofinite set, hence is finite. The same argument covers the case in which both sets are cofinite. Closure under intersections follows from complements and unions, or directly from De Morgan’s laws. $\square$

**Lemma 3.3 (Disjoint alternatives).** If $X$ is infinite, no event $A\in\mathcal F_X$ is both finite and cofinite.

**Proof sketch.** If both $A$ and $A^c$ were finite, their union $X=A\cup A^c$ would be finite, contrary to the hypothesis. $\square$

This lemma guarantees that a piecewise probability formula based on the two alternatives is unambiguous.

## 4. The probability construction

**Definition 4.1 (Surreal finite–cofinite probability).** For $A\in\mathcal F_X$, define

$$
P(A)=
\begin{cases}
|A|\varepsilon, & A\text{ is finite},\\[4pt]
1-|A^c|\varepsilon, & A\text{ is cofinite}.
\end{cases}
$$

By Lemma 3.3, exactly one clause applies. The finite clause sums the common point mass over the elements of $A$. The cofinite clause enforces the complement relation $P(A)=1-P(A^c)$.

### 4.1 Normalization and atoms

**Proposition 4.2 (Normalization).** The entire sample space has unit mass:

$$
P(X)=1.
$$

**Proof sketch.** The set $X$ is cofinite and $X^c=\varnothing$, whose cardinality is zero. Hence $P(X)=1-0\varepsilon=1$. $\square$

**Proposition 4.3 (Uniform infinitesimal singleton mass).** For every $x\in X$,

$$
P(\{x\})=\varepsilon,
$$

and this mass obeys

$$
0<P(\{x\})<2^{-n}
$$

for every $n\in\mathbb N$.

**Proof sketch.** A singleton is finite with cardinality one, so Definition 4.1 gives $P(\{x\})=1\varepsilon=\varepsilon$. Lemma 2.2 supplies positivity and all dyadic upper bounds. $\square$

**Proposition 4.4 (Nonnegativity).** Every admissible event has nonnegative mass:

$$
P(A)\ge0\qquad(A\in\mathcal F_X).
$$

**Proof sketch.** If $A$ is finite, then $P(A)=|A|\varepsilon\ge0$ because $\varepsilon>0$. If $A$ is cofinite, put $n=|A^c|$. Lemma 2.3 gives $n\varepsilon<1$, so $P(A)=1-n\varepsilon>0$. $\square$

It follows in fact that $0\le P(A)\le1$ for all admissible $A$. For finite $A$, the upper bound is Lemma 2.3. For cofinite $A$, nonnegativity of $|A^c|\varepsilon$ gives $P(A)\le1$.

### 4.2 Finite additivity

**Theorem 4.5 (Finite additivity on disjoint events).** If $A,B\in\mathcal F_X$ and $A\cap B=\varnothing$, then

$$
P(A\cup B)=P(A)+P(B).
$$

**Proof sketch.** There are four apparent combinations of finite and cofinite status.

If both $A$ and $B$ are finite, disjointness gives

$$
|A\cup B|=|A|+|B|.
$$

Multiplication by $\varepsilon$ yields

$$
P(A\cup B)=(|A|+|B|)\varepsilon
=|A|\varepsilon+|B|\varepsilon.
$$

Suppose $A$ is finite and $B$ is cofinite. Since $A\cap B=\varnothing$, one has $A\subseteq B^c$. Decompose the finite set $B^c$ as the disjoint union

$$
B^c=A\mathbin{\dot\cup}(A^c\cap B^c).
$$

The second term is exactly $(A\cup B)^c$. Therefore

$$
|B^c|=|A|+|(A\cup B)^c|.
$$

Writing $r=|(A\cup B)^c|$ gives

$$
\begin{aligned}
P(A)+P(B)
&=|A|\varepsilon+1-|B^c|\varepsilon\\
&=|A|\varepsilon+1-(|A|+r)\varepsilon\\
&=1-r\varepsilon\\
&=P(A\cup B).
\end{aligned}
$$

The case in which $A$ is cofinite and $B$ finite is symmetric.

Finally, two cofinite events cannot be disjoint. If they were, then $A\cap B=\varnothing$ would imply by De Morgan’s law that

$$
A^c\cup B^c=X.
$$

The left side is a union of two finite sets and is therefore finite, contradicting the infinitude of $X$. Thus the fourth case is impossible. $\square$

By induction, Theorem 4.5 extends to every finite pairwise-disjoint family $A_1,\ldots,A_k$ of admissible events:

$$
P\left(\bigcup_{i=1}^k A_i\right)=\sum_{i=1}^kP(A_i).
$$

### 4.3 Complement and monotonicity consequences

Although the construction is defined piecewise, standard finite-probability identities follow.

**Corollary 4.6 (Complement law).** For every $A\in\mathcal F_X$,

$$
P(A^c)=1-P(A).
$$

**Proof sketch.** The events $A$ and $A^c$ are disjoint and have union $X$. Apply Theorem 4.5 and Proposition 4.2 to obtain $1=P(A)+P(A^c)$, then rearrange. Equivalently, the identity follows directly from the two clauses of Definition 4.1. $\square$

**Corollary 4.7 (Monotonicity).** If $A,B\in\mathcal F_X$ and $A\subseteq B$, then

$$
P(A)\le P(B).
$$

**Proof sketch.** The difference $B\setminus A=B\cap A^c$ is admissible by Boolean closure, and $B$ is the disjoint union of $A$ and $B\setminus A$. Theorem 4.5 and nonnegativity give

$$
P(B)=P(A)+P(B\setminus A)\ge P(A).
$$

$\square$

**Corollary 4.8 (Two-event inclusion–exclusion).** For all $A,B\in\mathcal F_X$,

$$
P(A\cup B)=P(A)+P(B)-P(A\cap B).
$$

**Proof sketch.** Decompose $A\cup B$ into the three pairwise-disjoint admissible events $A\setminus B$, $B\setminus A$, and $A\cap B$. Apply finite additivity to this decomposition and to the corresponding decompositions of $A$ and $B$, then cancel common terms. $\square$

## 5. The unit interval

The set $[0,1]$ is infinite, so the preceding theory applies directly.

**Theorem 5.1 (Infinitesimal probability on the unit interval).** Let

$$
X=[0,1]=\{x\in\mathbb R:0\le x\le1\}
$$

and let $\mathcal F_X$ be its finite–cofinite event algebra. There exists a surreal-valued function $P:\mathcal F_X\to\mathbf{No}$ such that:

1. $P(X)=1$;
2. $P(A)\ge0$ for every $A\in\mathcal F_X$;
3. for every $x\in[0,1]$, one has $P(\{x\})=\varepsilon>0$ and $P(\{x\})<2^{-n}$ for all $n\in\mathbb N$;
4. for disjoint $A,B\in\mathcal F_X$,

   $$
   P(A\cup B)=P(A)+P(B).
   $$

Here $\mathbf{No}$ denotes the surreal numbers and $\varepsilon$ is the cut of Definition 2.1.

**Proof sketch.** The interval $[0,1]$ contains infinitely many points, for example the distinct sequence $0,1/2,1/3,\ldots$. Apply Definition 4.1 and Propositions 4.2–4.4 together with Theorem 4.5. $\square$

The theorem realizes equal positive point masses without disturbing normalization. It is important, however, that the event algebra does not contain a typical interval. For example, $[0,1/2]$ is infinite and its complement relative to $[0,1]$ is also infinite, so it is not in $\mathcal F_X$. The construction therefore supplements, rather than reproduces, ordinary length-based probability.

## 6. Exact symbolic computation

Surreal arithmetic is not needed in full generality to compute values in the image of $P$. Every value has one of the forms

$$
n\varepsilon\quad\text{or}\quad1-n\varepsilon,
$$

with $n\in\mathbb N$. It is convenient to encode the affine expression $a+b\varepsilon$ by the integer pair $(a,b)$. For probabilities in this construction, $a\in\{0,1\}$ and either $(a,b)=(0,n)$ or $(1,-n)$.

**Algorithm 6.1 (Event-mass evaluation).** Given an event description tagged as finite with cardinality $n$, return $(0,n)$. Given one tagged as cofinite with complement cardinality $n$, return $(1,-n)$.

The runtime is $O(1)$ once the relevant cardinality is supplied, and the memory use is $O(1)$. If an explicit finite set is supplied instead, deduplicating and counting its elements takes expected $O(n)$ time with hashing and $O(n)$ memory.

**Algorithm 6.2 (Disjoint-union audit).** For two explicitly represented finite or cofinite events, first test the structural disjointness condition. Then calculate the two input masses and the union mass from cardinalities, add affine pairs componentwise, and compare the result.

For two finite events, disjointness is ordinary set disjointness and the union is finite. For a finite event $F$ and a cofinite event $X\setminus M$, disjointness is equivalent to $F\subseteq M$; the union is cofinite and misses $M\setminus F$. Two cofinite events over an infinite universe are never disjoint. With hash-set representations, these operations take expected $O(|F|+|M|)$ time and comparable memory.

As an example, let a cofinite event omit a five-element set $M$, and let a finite disjoint event contain two members of $M$. Then

$$
P(X\setminus M)=1-5\varepsilon,
\qquad P(F)=2\varepsilon.
$$

Their union omits the remaining three members of $M$, and

$$
P(F\cup(X\setminus M))=1-3\varepsilon
=(1-5\varepsilon)+2\varepsilon.
$$

These computations are symbolic. Replacing $\varepsilon$ by a small floating-point proxy can illustrate coefficient bookkeeping, but no fixed positive real proxy satisfies $n\varepsilon<1$ for every natural number $n$. Exact affine representation preserves the relevant distinction.

## 7. Interpretation and applications

### 7.1 Resolution of the point-mass tension

The construction shows that three statements can coexist:

$$
P(\{x\})>0\quad\text{for every }x\in X,
$$

$$
P(X)=1,
$$

and finite additivity on the chosen event algebra. The apparent tension comes from importing an Archimedean inference: for a real $p>0$, sufficiently many copies exceed one. The surreal $\varepsilon$ violates precisely that inference while retaining ordered addition and multiplication.

### 7.2 Permutation symmetry

The measure is invariant under every permutation of $X$. A bijection preserves finite cardinality and complement cardinality, so

$$
P(\pi(A))=P(A)
$$

for every permutation $\pi:X\to X$ and every admissible event $A$. Thus no point is privileged. The finite–cofinite algebra records only the number of exceptional points, not their identities.

### 7.3 Rare-event bookkeeping

The affine form $1-n\varepsilon$ distinguishes cofinite events that ordinary zero–one finite–cofinite probability would identify. Missing one point has mass $1-\varepsilon$; missing a thousand points has mass $1-1000\varepsilon$. Both have ordinary real shadow one, but their infinitesimal corrections retain finite-resolution information. Similarly, finite events of different cardinalities all have real shadow zero but distinct surreal masses.

This suggests applications wherever finite exceptions should be ranked without assigning them ordinary positive weight. Examples include idealized symmetry models, perturbative bookkeeping, and decision rules that compare events lexicographically by their ordinary and infinitesimal components. Such applications require care: the present theorem supplies algebraic probability identities, not a complete theory of expectation, conditioning, or infinite stochastic processes.

### 7.4 Relation to hyperfinite intuition

A hyperfinite model imagines an infinite natural number $N$ and a grid of $N$ equally likely atoms, each of mass $1/N$. Every atom then has a positive infinitesimal mass, while the grid has total mass one. The present construction resembles this picture but proceeds through a specific surreal cut and does not choose an infinite grid cardinality. Its event algebra is described directly by finite exceptions. Developing a precise comparison requires a common framework for the relevant non-Archimedean values and a standard-part operation.

## 8. Scope and limitations

### 8.1 Finite rather than countable additivity

The theorem proves additivity for disjoint pairs and hence for finite disjoint families. It does not assert countable additivity. A countably additive law would require a defined meaning for

$$
\sum_{k=0}^{\infty}P(A_k)
$$

in the surreal codomain. Infinite surreal sums are not automatically supplied by the ordered-field operations; admissibility, convergence, and possibly the support of the family must be specified.

Moreover, even ordinary $\sigma$-additivity concerns countable unions, not an uncountable sum over all points of $[0,1]$. The equation $P([0,1])=1$ is not obtained by summing the singleton masses over an uncountable index set.

### 8.2 Restricted event algebra

The finite–cofinite algebra omits most geometrically interesting subsets of $[0,1]$. Equal point masses alone cannot determine an interval mass: many assignments to larger algebras could agree on all finite and cofinite sets. Extending the domain requires additional principles, perhaps compatibility with interval length, translation symmetry, or a standard-part map. These principles can conflict and must be checked rather than presumed.

### 8.3 No numerical approximation of the infinitesimal property

Any floating-point number $e>0$ eventually violates $ne<1$. Numerical demonstrations can check finite cardinality identities and affine coefficient arithmetic, but they cannot establish non-Archimedeanness. The mathematical content lies in the order relations defining $\varepsilon$.

## 9. Future directions

Several extensions are natural.

First, the event collection can be packaged abstractly as a Boolean algebra and the probability as an ordered-ring-valued finitely additive content. This would make complement, monotonicity, bounds, and inclusion–exclusion available through a reusable interface.

Second, one can seek larger event algebras generated by interval cells together with infinitesimal atoms. The main issue is compatibility: assigning the same infinitesimal to every real point does not uniquely determine, and may constrain, interval masses.

Third, a hyperfinite grid with $N$ atoms of mass $1/N$ could be compared with the present cut-based model. A standard-part-like map on a suitable ring of finite surreal values might send all finite masses to zero and all cofinite masses to one, recovering the ordinary zero–one probability on the same event algebra.

Fourth, a theory of admissible countable sums of nonnegative surreal families would make questions of $\sigma$-additivity precise. Only after the summation semantics are fixed can countable additivity be meaningfully tested.

Finally, there is a natural uniqueness problem: characterize permutation-invariant normalized finitely additive probabilities on $\mathcal F_X$ with a prescribed singleton mass $\varepsilon$. Finite additivity already forces $P(A)=|A|\varepsilon$ for finite $A$, and normalization plus complements forces $P(A)=1-|A^c|\varepsilon$ for cofinite $A$. Thus the present rule is the unique such measure once the singleton mass and standard finite-additivity axioms are fixed.

## 10. Conclusion

A concrete Conway cut supplies a positive surreal number $\varepsilon$ below every dyadic $2^{-n}$. The elementary bound $n\le2^n$ then ensures that every finite multiple $n\varepsilon$ remains below one. This arithmetic fact fits exactly with the finite–cofinite algebra of an infinite set: finite events receive the sum of their point masses, while cofinite events receive one minus the mass of their finite exceptions.

The resulting function is nonnegative, normalized, permutation-invariant, and finitely additive. On $[0,1]$, every point has the same nonzero infinitesimal mass even though the whole interval has mass one. The construction is deliberately limited to finite–cofinite events and finite sums, drawing a clear line between an established non-Archimedean probability model and the unresolved tasks of enlarging the event domain and defining infinite surreal summation.