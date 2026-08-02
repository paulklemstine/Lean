# Infinitesimal Point Masses on the Finite–Cofinite Algebra

## A normalized surreal-valued probability on arbitrary infinite sample spaces

**Author:** Aristotle  
**Date:** August 2, 2026

## Abstract

We construct a normalized, nonnegative, finitely additive probability with values in the surreal numbers on the finite–cofinite Boolean algebra of any infinite sample space. The construction begins with the explicit Conway cut

$$
\varepsilon=\{0\mid 1,2^{-1},2^{-2},\ldots\},
$$

which is strictly positive and smaller than $2^{-n}$ for every natural number $n$. A finite event $A$ receives mass $|A|\varepsilon$, while a cofinite event receives mass $1-|A^c|\varepsilon$. We prove that every finite multiple of $\varepsilon$ is below $1$, which yields positivity for cofinite events. We then establish normalization, equal positive infinitesimal singleton masses, binary finite additivity, the complement identity, unit-interval bounds, monotonicity, a relative-difference formula, and strict growth by exactly $\varepsilon$ when a new point is adjoined to a finite event. Specializing the sample space to $[0,1]$ gives a precise positive answer to the existence of equal nonzero infinitesimal point probabilities, provided the event domain is the finite–cofinite algebra and additivity is finite. The construction clarifies the distinct roles of the codomain, event algebra, and additivity axiom in non-Archimedean probability.

## 1. Introduction

In a standard atomless probability distribution on the real interval $[0,1]$, each singleton has probability zero. This familiar fact is compatible with total mass one because countable additivity does not express the continuum as a countable disjoint union of singletons. Nevertheless, it motivates a different question: can one formulate a probability in which every point has the same strictly positive mass, that mass is smaller than every ordinary positive dyadic scale, and the whole interval still has probability one?

A non-Archimedean ordered field provides candidate values for such a probability. In particular, the surreal numbers contain positive infinitesimals: positive elements smaller than every positive real number. Merely changing the codomain is not enough, however. The event algebra and the form of additivity must be coordinated with the infinitesimal assignment. Assigning the same mass $\varepsilon>0$ to every singleton suggests that finite sets should have mass $n\varepsilon$. It does not by itself specify the mass of arbitrary infinite sets or the meaning of an infinite sum of copies of $\varepsilon$.

We therefore work on the finite–cofinite algebra. If $\Omega$ is infinite, this algebra consists of subsets that are finite or whose complements are finite. It is the smallest natural Boolean algebra containing all singletons. Its events admit a simple description by finitely many included points or finitely many excluded points, making finite cardinality the only required counting operation.

The resulting probability is

$$
P(A)=
\begin{cases}
|A|\varepsilon, & A\text{ finite},\\
1-|A^c|\varepsilon, & A^c\text{ finite}.
\end{cases}
$$

The construction is elementary once an appropriate infinitesimal is available, but several structural points require proof. First, $n\varepsilon<1$ for every finite $n$, ensuring that cofinite probabilities are nonnegative. Second, finite additivity has mixed finite–cofinite cases whose content is a complement-cardinality identity. Third, standard order properties follow from closure under relative difference.

Our principal specialization is $\Omega=[0,1]$. The outcome is a normalized finitely additive surreal-valued probability for which every point has equal mass $\varepsilon>0$ and $\varepsilon<2^{-n}$ for every $n$. This is not an extension of Lebesgue measure, nor is it a countably additive measure on a sigma-algebra. Its purpose is instead to isolate a coherent setting in which positive infinitesimal point masses coexist with total mass one.

## 2. Surreal preliminaries

### 2.1. Conway cuts

A surreal number may be described recursively by a cut

$$
\{L\mid R\},
$$

where every member of the set $L$ is strictly less than every member of the set $R$. The cut denotes the simplest surreal number lying strictly between all left and right options. We need only the order consequences of this construction.

### Definition 2.1 (The dyadic infinitesimal)

Define

$$
\varepsilon=\{0\mid 1,1/2,1/4,1/8,\ldots\}
=\{0\mid 2^{-n}:n\in\mathbb N\}.
$$

The cut is valid because $0<2^{-n}$ for every $n\in\mathbb N$.

### Proposition 2.2 (Positivity and infinitesimal bounds)

The surreal number $\varepsilon$ satisfies

$$
0<\varepsilon
$$

and, for every $n\in\mathbb N$,

$$
\varepsilon<2^{-n}.
$$

#### Proof sketch

The left option $0$ lies below the number represented by the cut, while each right option $2^{-n}$ lies above it. These are the defining order properties of a numeric Conway cut. Thus $\varepsilon$ is strictly positive and lies below every listed dyadic number. Since every positive real number exceeds some positive dyadic number, $\varepsilon$ is smaller than every positive real number, although only the displayed dyadic inequalities are needed below. ∎

### Lemma 2.3 (Finite multiples remain subunit)

For every $k\in\mathbb N$,

$$
k\varepsilon<1.
$$

#### Proof sketch

The elementary inequality

$$
k\leq 2^k
$$

holds for all natural numbers $k$. It follows by induction: the initial case is immediate, and the induction step uses $2^{k+1}=2\cdot 2^k$ together with $2^k\geq1$. Positivity of $\varepsilon$ gives

$$
k\varepsilon\leq 2^k\varepsilon.
$$

Proposition 2.2 gives $\varepsilon<2^{-k}$; multiplication by the positive integer $2^k$ yields

$$
2^k\varepsilon<2^k2^{-k}=1.
$$

Combining the inequalities proves the claim. ∎

This lemma is the key non-Archimedean estimate. It says that no finite collection of equal point masses reaches certainty.

## 3. The finite–cofinite event algebra

Let $\Omega$ be an infinite set.

### Definition 3.1 (Finite–cofinite event)

A subset $A\subseteq\Omega$ is a finite–cofinite event if either $A$ is finite or its complement

$$
A^c=\Omega\setminus A
$$

is finite. Write $\mathcal F_{\mathrm{fc}}(\Omega)$ for the collection of all such events.

### Proposition 3.2 (Boolean closure)

The collection $\mathcal F_{\mathrm{fc}}(\Omega)$ contains $\varnothing$ and $\Omega$ and is closed under complements, finite unions, finite intersections, and relative differences.

#### Proof sketch

The empty set is finite, while the complement of $\Omega$ is empty. Complementation exchanges the alternatives “finite” and “cofinite.” For a union $A\cup B$, if both sets are finite then their union is finite. If at least one is cofinite, then

$$
(A\cup B)^c=A^c\cap B^c
$$

is a subset of a finite complement and is therefore finite. Intersections follow from De Morgan’s law, and relative difference follows from

$$
A\setminus B=A\cap B^c.
$$

Thus the collection is a Boolean algebra. ∎

### Lemma 3.3 (Exclusivity of the two cases)

If $\Omega$ is infinite, no event $A\subseteq\Omega$ is both finite and cofinite.

#### Proof sketch

If both $A$ and $A^c$ were finite, then

$$
\Omega=A\cup A^c
$$

would be a finite union of finite sets and hence finite, contradicting the hypothesis. ∎

This exclusivity makes the following piecewise definition unambiguous.

## 4. Construction of the probability

### Definition 4.1 (Surreal finite–cofinite probability)

For $A\in\mathcal F_{\mathrm{fc}}(\Omega)$, define

$$
P(A)=
\begin{cases}
|A|\varepsilon, & A\text{ is finite},\\[4pt]
1-|A^c|\varepsilon, & A^c\text{ is finite}.
\end{cases}
$$

Here $|S|$ denotes the finite cardinality of $S$. The first formula assigns one infinitesimal unit to each included point. The second starts from total mass $1$ and deducts one infinitesimal unit for each excluded point.

### Proposition 4.2 (Normalization)

The whole space has probability one:

$$
P(\Omega)=1.
$$

#### Proof sketch

The complement of $\Omega$ is empty, whose cardinality is zero. Therefore

$$
P(\Omega)=1-|\varnothing|\varepsilon=1.
$$

Similarly, $P(\varnothing)=0$. ∎

### Proposition 4.3 (Equal infinitesimal singleton masses)

For every $x\in\Omega$,

$$
P(\{x\})=\varepsilon.
$$

Consequently,

$$
0<P(\{x\})<2^{-n}
$$

for every $n\in\mathbb N$.

#### Proof sketch

A singleton is finite and has cardinality one, so Definition 4.1 gives

$$
P(\{x\})=1\varepsilon=\varepsilon.
$$

The inequalities follow from Proposition 2.2. ∎

### Proposition 4.4 (Nonnegativity)

Every event $A\in\mathcal F_{\mathrm{fc}}(\Omega)$ satisfies

$$
P(A)\geq0.
$$

#### Proof sketch

If $A$ is finite, then $P(A)=|A|\varepsilon$ is nonnegative because $\varepsilon>0$. If $A$ is cofinite, Lemma 2.3 gives $|A^c|\varepsilon<1$, so

$$
P(A)=1-|A^c|\varepsilon>0.
$$

Thus every probability is nonnegative. ∎

## 5. Finite additivity

### Theorem 5.1 (Binary finite additivity)

If $A,B\in\mathcal F_{\mathrm{fc}}(\Omega)$ are disjoint, then

$$
P(A\cup B)=P(A)+P(B).
$$

#### Proof sketch

There are four nominal combinations.

**Both events finite.** Their disjoint union is finite and

$$
|A\cup B|=|A|+|B|.
$$

Hence

$$
P(A\cup B)=(|A|+|B|)\varepsilon
=|A|\varepsilon+|B|\varepsilon
=P(A)+P(B).
$$

**The event $A$ is finite and $B$ is cofinite.** Disjointness implies $A\subseteq B^c$. Decompose the finite set $B^c$ as the disjoint union

$$
B^c=A\sqcup(A^c\cap B^c).
$$

The complement of $A\cup B$ is $A^c\cap B^c$, and cardinalities give

$$
|B^c|=|A|+|(A\cup B)^c|.
$$

Therefore

$$
\begin{aligned}
P(A)+P(B)
&=|A|\varepsilon+1-|B^c|\varepsilon\\
&=1-|(A\cup B)^c|\varepsilon\\
&=P(A\cup B).
\end{aligned}
$$

**The event $A$ is cofinite and $B$ is finite.** This is symmetric to the preceding case.

**Both events cofinite.** This case is impossible. If $A$ and $B$ were disjoint, then $A\cap B=\varnothing$, and De Morgan’s law would give

$$
A^c\cup B^c=\Omega.
$$

The left side would be finite, whereas $\Omega$ is infinite.

The possible cases therefore all satisfy additivity. ∎

### Corollary 5.2 (Probability algebra)

The triple consisting of the infinite sample space $\Omega$, the Boolean algebra $\mathcal F_{\mathrm{fc}}(\Omega)$, and the map $P$ is a normalized, nonnegative, finitely additive surreal-valued probability space.

#### Proof sketch

Boolean closure is Proposition 3.2, normalization is Proposition 4.2, nonnegativity is Proposition 4.4, and finite additivity is Theorem 5.1. ∎

## 6. Structural laws

The basic construction supports the standard order calculus of finitely additive probability.

### Theorem 6.1 (Complement law)

For every $A\in\mathcal F_{\mathrm{fc}}(\Omega)$,

$$
P(A^c)=1-P(A).
$$

#### Proof sketch

The events $A$ and $A^c$ are disjoint and their union is $\Omega$. By finite additivity and normalization,

$$
P(A)+P(A^c)=P(\Omega)=1.
$$

Rearranging in the ordered field of surreal numbers gives the result. ∎

### Corollary 6.2 (Unit bounds)

For every $A\in\mathcal F_{\mathrm{fc}}(\Omega)$,

$$
0\leq P(A)\leq1.
$$

#### Proof sketch

The lower bound is Proposition 4.4. Applying nonnegativity to $A^c$ and using Theorem 6.1 gives

$$
0\leq P(A^c)=1-P(A),
$$

which is equivalent to $P(A)\leq1$. ∎

### Theorem 6.3 (Monotonicity)

If $A,B\in\mathcal F_{\mathrm{fc}}(\Omega)$ and $A\subseteq B$, then

$$
P(A)\leq P(B).
$$

#### Proof sketch

The relative difference $B\setminus A$ is finite–cofinite by Proposition 3.2. Moreover,

$$
B=A\sqcup(B\setminus A).
$$

Finite additivity gives

$$
P(B)=P(A)+P(B\setminus A).
$$

The second summand is nonnegative, proving the inequality. ∎

### Theorem 6.4 (Relative-difference formula)

If $A,B\in\mathcal F_{\mathrm{fc}}(\Omega)$ and $B\subseteq A$, then

$$
P(A\setminus B)=P(A)-P(B).
$$

#### Proof sketch

The decomposition

$$
A=B\sqcup(A\setminus B)
$$

and finite additivity yield

$$
P(A)=P(B)+P(A\setminus B).
$$

Rearrangement gives the formula. ∎

### Theorem 6.5 (Strict increment for a new point)

Let $A\in\mathcal F_{\mathrm{fc}}(\Omega)$ be finite, and let $x\in\Omega\setminus A$. Then

$$
P(A\cup\{x\})=P(A)+\varepsilon
$$

and therefore

$$
P(A)<P(A\cup\{x\}).
$$

#### Proof sketch

Because $x\notin A$,

$$
|A\cup\{x\}|=|A|+1.
$$

Both events are finite, so

$$
P(A\cup\{x\})=(|A|+1)\varepsilon
=|A|\varepsilon+\varepsilon
=P(A)+\varepsilon.
$$

Strictness follows from $\varepsilon>0$. ∎

This theorem shows that the probability retains finite-cardinality information that an atomless real-valued measure erases. Every newly adjoined point creates a detectable positive increment.

## 7. Specialization to the unit interval

### Theorem 7.1 (Infinitesimal point probability on $[0,1]$)

Let

$$
\Omega=[0,1]=\{x\in\mathbb R:0\leq x\leq1\}.
$$

There exists a surreal-valued probability $P$ on the finite–cofinite Boolean algebra of $[0,1]$ such that:

1. $P([0,1])=1$;
2. for every $x\in[0,1]$,
   $$
   P(\{x\})=\varepsilon>0;
   $$
3. for every $x\in[0,1]$ and every $n\in\mathbb N$,
   $$
   P(\{x\})<2^{-n};
   $$
4. for disjoint finite–cofinite events $A$ and $B$,
   $$
   P(A\cup B)=P(A)+P(B);
   $$
5. every event satisfies
   $$
   0\leq P(A)\leq1;
   $$
6. if $A\subseteq B$, then
   $$
   P(A)\leq P(B).
   $$

#### Proof sketch

The interval $[0,1]$ is infinite. Apply Definition 4.1 and the results of Sections 4–6 to this sample space. The singleton statement follows from Proposition 4.3, finite additivity from Theorem 5.1, the bounds from Corollary 6.2, and monotonicity from Theorem 6.3. ∎

The theorem answers the motivating existence question under explicit structural conditions. The event algebra is not the Borel sigma-algebra and does not contain nontrivial subintervals such as $[0,1/2]$. The additivity asserted is finite, not countable. These are substantive features, not technical omissions.

## 8. Algorithms and finite representations

Although $\Omega$ may be uncountable, each event in the finite–cofinite algebra has a finite description. Represent an event by a mode and a finite set $S$:

- mode “finite” represents $S$;
- mode “cofinite” represents $\Omega\setminus S$.

Its probability can then be stored symbolically as an affine expression

$$
a+b\varepsilon,
$$

with integer coefficients. A finite event with $m$ stored points has pair $(a,b)=(0,m)$; a cofinite event omitting $m$ points has $(a,b)=(1,-m)$.

### Algorithm 8.1 (Symbolic probability evaluation)

Given a finite–cofinite event represented by its mode and a finite exception set $S$, return

$$
(0,|S|)
$$

in finite mode and

$$
(1,-|S|)
$$

in cofinite mode. The pair denotes $a+b\varepsilon$.

If $S$ is represented by a hash set, counting takes $O(|S|)$ time to construct the set from input and $O(1)$ time to read a stored size; memory usage is $O(|S|)$. Equality and addition of the symbolic affine values use constant time after cardinalities are known.

### Algorithm 8.2 (Disjoint-union audit)

For finite representations, disjointness and additivity can be checked without approximating $\varepsilon$.

- Two finite events are disjoint exactly when their stored sets have empty intersection.
- A finite event $S$ and a cofinite event $\Omega\setminus T$ are disjoint exactly when $S\subseteq T$.
- Two cofinite events cannot be disjoint when $\Omega$ is infinite.

Once disjointness is established, compute the symbolic masses and compare the coefficient pairs for

$$
P(A\cup B)
$$

and

$$
P(A)+P(B).
$$

With hash sets, intersection and subset checks take expected time $O(\min(|S|,|T|))$ or $O(|S|)$ as appropriate, and the finite representation of the union can be produced in expected $O(|S|+|T|)$ time.

Numerical floating-point approximation is not suitable for representing $\varepsilon$: every positive floating-point value is an ordinary real number and therefore fails the defining inequality at sufficiently fine dyadic scales. A demo may use a truncation parameter $N$ and the proxy $2^{-(N+1)}$ to illustrate finitely many inequalities, but the symbolic pair $a+b\varepsilon$ is the mathematically faithful computational representation.

## 9. Interpretation and limitations

Three ingredients are responsible for the construction.

First, the surreal codomain contains a positive element below every positive dyadic real. This permits a singleton to have positive mass without having any positive real lower bound.

Second, the finite–cofinite algebra makes every event depend on finitely many points. The probability therefore requires only finite multiplication and subtraction. It avoids assigning values to sets whose structure cannot be reduced to finitely many exceptions.

Third, finite additivity governs every finite disjoint decomposition but places no convergence requirement on a countably infinite family. In particular, the expression

$$
\sum_{n=0}^{\infty}\varepsilon
$$

has not been assigned a meaning here. Any theorem about countable additivity would need a specified convergence or summation structure for surreal-valued series.

The construction should not be conflated with uniform Lebesgue probability. Under Lebesgue probability, a subinterval of length $t$ has mass $t$, while every point has mass zero. Under the present probability, a typical nontrivial subinterval is not an event at all. The two theories answer different observational questions.

Nor does the theorem assert a probability on the full power set of $[0,1]$. Extending the domain would require assigning masses to many infinite coinfinite subsets while preserving positivity and additivity. Such extensions are a separate problem.

Within its proper scope, the construction is robust. It works on every infinite sample space, independent of cardinality or geometry. It distinguishes finite sets by cardinality, distinguishes cofinite sets by the cardinality of their complements, and preserves the standard order laws of probability.

## 10. Applications and conceptual connections

The model provides a clean test case for non-Archimedean probability. It separates assertions often bundled together in classical probability: normalization, positivity, finite additivity, countable additivity, and richness of the event domain. Equal positive point masses are compatible with the first three on an infinite space; stronger conclusions depend on the latter two.

It also offers a symbolic semantics for “negligible but nonzero.” Suppose two finite failure modes differ by one exceptional state. A real-valued atomless model assigns both mass zero, whereas the surreal model records a difference of $\varepsilon$. For a cofinite success event, excluding one additional point lowers probability by exactly $\varepsilon$. Thus first-order infinitesimal changes are retained rather than collapsed.

The affine representation $a+b\varepsilon$ resembles perturbative bookkeeping. Finite events occupy the infinitesimal neighborhood of zero, while cofinite events occupy the infinitesimal neighborhood of one. Complementation maps

$$
b\varepsilon\longmapsto1-b\varepsilon,
$$

and adjoining or deleting a point shifts the coefficient of $\varepsilon$ by one. This creates a two-scale probability calculus: a macroscopic certainty coefficient and a microscopic finite-cardinality correction.

## 11. Future work

Several extensions arise naturally.

1. **Finite partition formula.** Binary finite additivity should extend by induction to every finite pairwise-disjoint family:
   $$
   P\left(\bigcup_{i=1}^m A_i\right)=\sum_{i=1}^m P(A_i).
   $$

2. **Strict monotonicity classification.** For finite–cofinite events $A\subseteq B$, one expects
   $$
   P(A)<P(B)\quad\Longleftrightarrow\quad A\neq B.
   $$
   The strict finite-insertion theorem proves an important special case.

3. **Inclusion–exclusion.** For all finite–cofinite $A$ and $B$, the anticipated identity is
   $$
   P(A\cup B)+P(A\cap B)=P(A)+P(B).
   $$

4. **Obstructions to countably additive extension.** A precise convergence theory for surreal-valued series could be used to formulate and prove that an extension cannot assign the same positive $\varepsilon$ to every singleton in a countably infinite subset while preserving total mass one and an appropriate countable-additivity axiom.

5. **Larger Boolean algebras.** One may seek a proper Boolean algebra extending the finite–cofinite algebra on $[0,1]$ together with an extension of $P$ preserving normalization, positivity, finite additivity, and singleton mass $\varepsilon$. Alternatively, one may identify natural candidate algebras for which such an extension is impossible.

## 12. Further structural perspective

The image of $P$ has a particularly simple form. Every measurable probability is either

$$
n\varepsilon
$$

for a natural number $n$, or

$$
1-n\varepsilon
$$

for a natural number $n$. Lemma 2.3 places the first family in the infinitesimal neighborhood of $0$ and the second in the infinitesimal neighborhood of $1$. Thus this probability does not fill the entire surreal unit interval. Instead, it resolves finite differences at the two classical extremes.

This restricted image is a faithful reflection of the event algebra. A finite–cofinite event carries exactly one finite statistic: the cardinality of the finite side. No geometric or topological information enters the definition. Consequently, any bijection of the sample space preserves probability. If $f:\Omega\to\Omega$ is a bijection, then finite sets and their complements retain their cardinalities under $f$, and hence

$$
P(f(A))=P(A)
$$

for every finite–cofinite event $A$. The model is uniform in the strong sense of permutation invariance on its domain.

The price of that symmetry is limited resolution away from $0$ and $1$. On the unit interval, neither a half-interval nor a nontrivial open interval is finite or cofinite, so neither is assigned a value. An enlarged theory would have to introduce additional principles determining macroscopic probabilities while remaining compatible with infinitesimal point corrections. The present construction supplies boundary conditions for such an extension: finite sets must have masses $n\varepsilon$, cofinite sets must have masses $1-n\varepsilon$, and every proposed larger algebra must preserve these values under Boolean operations.

## 13. Conclusion

For every infinite set $\Omega$, the finite–cofinite algebra supports a normalized, nonnegative, finitely additive probability valued in the surreal numbers that gives every point the same strictly positive infinitesimal mass. The construction uses the explicit cut

$$
\varepsilon=\{0\mid 1,1/2,1/4,\ldots\},
$$

assigns $|A|\varepsilon$ to finite events and $1-|A^c|\varepsilon$ to cofinite events, and satisfies the complement law, unit bounds, monotonicity, relative-difference subtraction, and strict growth under finite point insertion.

On $[0,1]$, every singleton therefore has a nonzero chance smaller than every reciprocal dyadic scale, while the entire interval retains probability one. The result demonstrates that zero singleton mass is not forced by normalization and finite additivity alone. It emerges only when those axioms are combined with additional choices about admissible events and infinite summation. The finite–cofinite surreal model makes those choices visible and supplies a rigorous baseline for broader non-Archimedean probability theories.
