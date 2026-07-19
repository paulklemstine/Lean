# Signed Lattice-State Models for Alexander Polynomials: Positivity, Universality, Products, and Reciprocity

**Aristotle**  
**19 July 2026**

## Abstract

We determine the precise scope of interpreting Alexander polynomials as area-generating functions of finite lattice-state families. A monotone square-lattice path from $(0,0)$ to $(n,n)$ is encoded by a balanced word with $n$ east and $n$ north steps, and its area is the number of east-before-north pairs. Any forbidden-region model selects a finite subset of these paths. Its unsigned area generating function necessarily has nonnegative coefficients. This elementary positivity constraint refutes the proposed unsigned interpretation for an infinite knot family: for every $k\ge 1$, the normalized Alexander polynomial of the torus knot $T(2,2k+1)$ has coefficient $-1$ in degree $k-1$, and therefore cannot equal any unsigned forbidden-region path generating function, even when “forbidden region” is generalized to an arbitrary predicate on paths.

We then give the exact correction. Every finitely supported integer coefficient function is representable by a finite signed state sum, while the unsigned finite state sums represent precisely the finitely supported nonnegative coefficient functions. Product state spaces realize Cauchy products through additive areas and multiplicative signs, and total signed weight is multiplicative. A sign-preserving, area-negating involution implies Laurent reciprocity. For the family $T(2,2k+1)$ we establish the explicit alternating formula, palindromicity, normalization at $t=1$, the determinant evaluation $|\Delta(-1)|=2k+1$, failure of unsigned representability for every nontrivial member, and signed representability. The analysis isolates cancellation as the exact algebraic ingredient absent from ordinary path counting and separates abstract representability from the more demanding problem of constructing diagram-local path models.

## 1. Introduction

The Alexander polynomial assigns to an oriented knot $K$ an integer Laurent polynomial $\Delta_K(t)$, defined up to multiplication by a unit $\pm t^r$ unless a normalization is fixed. In a symmetric normalization one expects reciprocity, usually written

$$
\Delta_K(t)=\Delta_K(t^{-1}),
$$

and normalization at $t=1$ by $\Delta_K(1)=1$ or, under other conventions, $\pm1$. The coefficients can be negative. This last feature is central.

A natural combinatorial proposal is to associate a knot diagram with $n$ crossings to a region in an $n\times n$ lattice square and to sum $t^{A(p)}$ over monotone paths that avoid the region. Such formulas are attractive because they transform a topological invariant into an enumerative object. They also suggest algorithms, visualizations, and relations with statistical mechanics, where exponents measure energy or area.

The proposal must, however, confront an invariant feature of unsigned enumeration: cardinalities are nonnegative. No selection rule, geometric or otherwise, can make the number of objects of a given area equal to $-1$. The reduced trefoil polynomial $t^{-1}-1+t$ already exposes this problem. More strongly, the same obstruction occurs throughout the infinite family $T(2,2k+1)$.

The appropriate replacement is a signed state sum. Each state contributes an integer weight rather than merely $1$. Negative coefficients then record cancellation. This is consistent with state-sum descriptions of knot polynomials and with many constructions in topology and physics, where observables arise from alternating or phased contributions.

This paper has five aims. First, it defines the path and state-sum models precisely. Second, it characterizes unsigned and signed representability. Third, it proves an infinite-family obstruction to unsigned path counting. Fourth, it identifies product and involution principles that mirror connected-sum multiplicativity and Alexander reciprocity. Fifth, it presents explicit algorithms and numerical examples for the torus-knot family.

## 2. Coefficient functions and finite state sums

A Laurent polynomial with integer coefficients is conveniently represented by its coefficient function $c:\mathbb Z\to\mathbb Z$, where $c(m)$ is the coefficient of $t^m$. The function is **finitely supported** if there is a finite set $B\subset\mathbb Z$ such that $c(m)=0$ whenever $m\notin B$.

A coefficient function $c$ is **nonnegative** if

$$
c(m)\ge 0
$$

for every $m\in\mathbb Z$. It is **palindromic** if

$$
c(m)=c(-m)
$$

for every $m\in\mathbb Z$.

Let $S$ be a finite set of states and let $a:S\to\mathbb Z$ assign an integer area or grading to each state. The **unsigned area generating function** is

$$
G_{S,a}(t)=\sum_{s\in S}t^{a(s)}.
$$

Equivalently, its coefficient function is

$$
G_{S,a}(m)=\#\{s\in S:a(s)=m\}.
$$

If in addition $\sigma:S\to\mathbb Z$ assigns an integer sign or weight to each state, the **signed state sum** is

$$
F_{S,\sigma,a}(t)=\sum_{s\in S}\sigma(s)t^{a(s)},
$$

with coefficient function

$$
F_{S,\sigma,a}(m)=\sum_{\substack{s\in S\\a(s)=m}}\sigma(s).
$$

Although the term “sign” suggests values in $\{-1,1\}$, allowing arbitrary integer weights is harmless. In fact, the universal construction below uses only $-1$ and $1$.

### Theorem 2.1 (Positivity of unsigned state sums)

For every finite state set $S$ and area map $a:S\to\mathbb Z$, every coefficient of $G_{S,a}(t)$ is a nonnegative integer.

**Proof sketch.** For a fixed degree $m$, the coefficient is the cardinality of the finite fiber $\{s\in S:a(s)=m\}$. A finite cardinality is a nonnegative integer. $\square$

### Lemma 2.2 (Unsigned sums as signed sums)

Every unsigned area generating function is a signed state sum: take $\sigma(s)=1$ for all $s\in S$.

**Proof sketch.** In each degree $m$, summing $1$ over the fiber of $a$ gives exactly the number of states in that fiber. $\square$

The converse requires positivity and finite support.

### Theorem 2.3 (Exact characterization of unsigned representability)

A coefficient function $c:\mathbb Z\to\mathbb Z$ is the coefficient function of an unsigned finite area generating function if and only if $c$ is finitely supported and nonnegative.

**Proof sketch.** Necessity follows from Theorem 2.1 and finiteness of $S$, since only the finitely many values $a(s)$ can occur. For sufficiency, let $B$ be a finite support bound. For each $m\in B$, create exactly $c(m)$ states labeled $(m,j)$ with $0\le j<c(m)$, and assign each such state area $m$. There are no states outside these fibers. The number of states of area $m$ is then exactly $c(m)$. $\square$

Signed sums have no positivity restriction.

### Theorem 2.4 (Universality of finite signed state sums)

A coefficient function $c:\mathbb Z\to\mathbb Z$ is the coefficient function of a finite signed state sum if and only if it is finitely supported. Moreover, the representing weights may all be chosen from $\{-1,1\}$.

**Proof sketch.** Every finite state sum is supported on the finite image of its area map. Conversely, choose a finite set $B$ containing every $m$ with $c(m)\ne0$. For each $m\in B$, create $|c(m)|$ states $(m,j)$, assign them area $m$, and assign all of them weight $\operatorname{sgn}(c(m))$. Their total contribution in degree $m$ is

$$
\operatorname{sgn}(c(m))|c(m)|=c(m).
$$

Taking the union of these finite fibers gives the desired representation. $\square$

Theorems 2.3 and 2.4 give a complete algebraic answer. Passing from unsigned to signed enumeration removes exactly one obstruction: coefficientwise nonnegativity.

## 3. Balanced lattice paths and area

Fix $n\ge0$. A **monotone square path of size $n$** is a path from $(0,0)$ to $(n,n)$ using east steps $E=(1,0)$ and north steps $N=(0,1)$. It is equivalently a word $p_1p_2\cdots p_{2n}$ containing exactly $n$ copies of $E$ and $n$ copies of $N$.

Define the **east-before-north area** by

$$
A(p)=\#\{(i,j):1\le i<j\le2n,\ p_i=E,\ p_j=N\}.
$$

This is an integer between $0$ and $n^2$. It agrees with the number of unit cells on a fixed side of the staircase path. For example, $N^nE^n$ has area $0$, while $E^nN^n$ has area $n^2$.

A **forbidden rule** is any predicate on the finite set of size-$n$ paths. The allowed family $L$ consists of those paths for which the predicate is false. This deliberately generalizes geometric avoidance: any collection of forbidden cells induces such a predicate, but an arbitrary predicate may exclude paths for nongeometric reasons as well.

The corresponding **unsigned lattice-path area generating function** is

$$
P_L(t)=\sum_{p\in L}t^{A(p)}.
$$

### Corollary 3.1 (Positivity for arbitrary forbidden rules)

For every $n$ and every forbidden rule on monotone paths from $(0,0)$ to $(n,n)$, all coefficients of $P_L(t)$ are nonnegative integers.

**Proof sketch.** This is Theorem 2.1 applied to the allowed path set with area map $A$. The coefficient in degree $m$ counts allowed paths having area $m$. $\square$

The generality of the forbidden rule matters. Any impossibility proved from Corollary 3.1 automatically applies to ordinary forbidden-region models, independently of how crossing data might determine the region.

For comparison, when all paths are allowed, the area distribution is the Gaussian binomial coefficient

$$
\binom{2n}{n}_t,
$$

under the east-before-north convention. This familiar positive polynomial illustrates both the appeal and the limitation of unsigned path enumeration.

## 4. The torus-knot obstruction

For $k\ge0$, consider the symmetrically normalized Alexander polynomial of the torus knot $T(2,2k+1)$:

$$
\Delta_k(t)=\sum_{i=-k}^{k}(-1)^{i+k}t^i.
$$

Its coefficient function is therefore

$$
c_k(i)=
\begin{cases}
(-1)^{i+k},&-k\le i\le k,\\
0,&\text{otherwise}.
\end{cases}
$$

For $k=0$ this gives $1$. For $k=1$ it gives the reduced trefoil polynomial

$$
\Delta_1(t)=t^{-1}-1+t.
$$

### Lemma 4.1 (Negative coefficient)

For every integer $k\ge1$, the coefficient of $t^{k-1}$ in $\Delta_k(t)$ equals $-1$.

**Proof sketch.** The exponent $k-1$ lies in $[-k,k]$, and

$$
(k-1)+k=2k-1
$$

is odd. Hence $(-1)^{(k-1)+k}=-1$. $\square$

### Theorem 4.2 (Infinite-family obstruction to unsigned state counting)

For every $k\ge1$, the polynomial $\Delta_k(t)$ is not the unsigned area generating function of any finite state family, regardless of the chosen integer area map.

**Proof sketch.** By Lemma 4.1, $\Delta_k(t)$ has a coefficient equal to $-1$. By Theorem 2.1, every coefficient of an unsigned finite state generating function is nonnegative. Equality is impossible. $\square$

### Theorem 4.3 (Infinite-family obstruction to forbidden-region path counting)

For every $k\ge1$, every square size $n$, and every forbidden rule on monotone paths from $(0,0)$ to $(n,n)$, the resulting unsigned path generating function differs from $\Delta_k(t)$. In particular, the trefoil polynomial $t^{-1}-1+t$ cannot be obtained in this way.

**Proof sketch.** Corollary 3.1 gives coefficientwise nonnegativity for every allowed path family, including families selected by arbitrary predicates. Lemma 4.1 provides a negative coefficient of $\Delta_k(t)$. The trefoil is the case $k=1$. $\square$

This result is stronger than a failure of one proposed geometric encoding. Because arbitrary deletion of balanced paths is permitted, no crossing-dependent choice of an unsigned allowed set can overcome the obstruction.

### Theorem 4.4 (Signed representability of the torus family)

For every $k\ge0$, the polynomial $\Delta_k(t)$ is a finite signed state sum.

**Proof sketch.** The polynomial has finite support $[-k,k]$, so Theorem 2.4 applies. More explicitly, use one state of area $i$ and sign $(-1)^{i+k}$ for each integer $i$ between $-k$ and $k$. $\square$

## 5. Structural identities for signed models

Abstract representability alone is weak: one can reconstruct a state set from a finished coefficient list. A meaningful bridge to knot theory should also reproduce multiplication, normalization, and reciprocity. These properties emerge naturally from finite signed state sums.

### 5.1 Product state spaces and convolution

Let $S$ and $T$ be finite state sets. Give states in $S$ signs $\sigma_S$ and areas $a_S$, and states in $T$ signs $\sigma_T$ and areas $a_T$. On $S\times T$, define

$$
\sigma(s,u)=\sigma_S(s)\sigma_T(u),
\qquad
a(s,u)=a_S(s)+a_T(u).
$$

### Theorem 5.1 (Product-convolution theorem)

The signed generating function of the product state space is the product of the two signed generating functions:

$$
F_{S\times T}(t)=F_S(t)F_T(t).
$$

Equivalently, for every $m\in\mathbb Z$,

$$
F_{S\times T}(m)
=
\sum_{s\in S}\sigma_S(s)
F_T\bigl(m-a_S(s)\bigr).
$$

Grouping states of $S$ by area yields the usual Cauchy convolution

$$
F_{S\times T}(m)=\sum_{r\in\mathbb Z}F_S(r)F_T(m-r),
$$

where only finitely many terms are nonzero.

**Proof sketch.** Expand the sum over pairs $(s,u)$. A pair contributes to degree $m$ exactly when $a_S(s)+a_T(u)=m$, or equivalently when $a_T(u)=m-a_S(s)$. Factoring out $\sigma_S(s)$ gives the first coefficient formula. Grouping the outer sum by $r=a_S(s)$ gives convolution, which is precisely coefficient extraction from $F_S(t)F_T(t)$. $\square$

This is the combinatorial form expected for connected sum, since Alexander polynomials satisfy

$$
\Delta_{K_1\#K_2}(t)=\Delta_{K_1}(t)\Delta_{K_2}(t)
$$

under compatible normalization.

### Corollary 5.2 (Multiplicativity of total signed weight)

The sum of all signs in the product state space equals the product of the total signed weights:

$$
\sum_{(s,u)\in S\times T}\sigma_S(s)\sigma_T(u)
=
\left(\sum_{s\in S}\sigma_S(s)\right)
\left(\sum_{u\in T}\sigma_T(u)\right).
$$

Equivalently, $F_{S\times T}(1)=F_S(1)F_T(1)$.

**Proof sketch.** Distribute the finite double sum, or specialize Theorem 5.1 at $t=1$. $\square$

### 5.2 Reciprocity from an involution

Let $S$ be a finite signed state set. An **area-negating, sign-preserving involution** is a map $\phi:S\to S$ satisfying

$$
\phi(\phi(s))=s,
\qquad
a(\phi(s))=-a(s),
\qquad
\sigma(\phi(s))=\sigma(s)
$$

for every $s\in S$.

### Theorem 5.3 (Involution criterion for reciprocity)

If a finite signed state family admits an area-negating, sign-preserving involution, then its coefficient function is palindromic:

$$
F(m)=F(-m)
$$

for every integer $m$. Equivalently,

$$
F(t)=F(t^{-1}).
$$

**Proof sketch.** The involution bijects the states of area $m$ with the states of area $-m$. Since it preserves each sign, the signed sums over the two fibers are equal. $\square$

A shifted form is often useful. If reflection sends area $a$ to $C-a$, then the generating function satisfies a reciprocal identity up to the monomial factor $t^C$. Centering the grading by subtracting $C/2$ recovers the area-negating formulation whenever the grading permits it.

## 6. Explicit identities for $T(2,2k+1)$

The torus family illustrates all of the preceding phenomena in closed form.

### Theorem 6.1 (Palindromicity)

For every $k\ge0$ and every integer $i$, the coefficient of $t^i$ in $\Delta_k(t)$ equals the coefficient of $t^{-i}$. Hence

$$
\Delta_k(t)=\Delta_k(t^{-1}).
$$

**Proof sketch.** The support interval $[-k,k]$ is invariant under $i\mapsto-i$. Within this interval, $i+k$ and $-i+k$ have the same parity because their difference is $2i$. Thus $(-1)^{i+k}=(-1)^{-i+k}$. Outside the interval both coefficients vanish. $\square$

### Theorem 6.2 (Normalization at one)

For every $k\ge0$,

$$
\Delta_k(1)=1.
$$

**Proof sketch.** There are $2k+1$ consecutive alternating coefficients, beginning and ending with $+1$. Pair adjacent terms $1-1$; one unpaired $+1$ remains. $\square$

### Theorem 6.3 (Evaluation at minus one and determinant)

For every $k\ge0$,

$$
\Delta_k(-1)=(-1)^k(2k+1),
$$

so in particular

$$
|\Delta_k(-1)|=2k+1.
$$

**Proof sketch.** The term of degree $i$ contributes

$$
(-1)^{i+k}(-1)^i=(-1)^{2i+k}=(-1)^k.
$$

There are $2k+1$ exponents in $[-k,k]$, so their sum is $(-1)^k(2k+1)$. $\square$

These identities show why signs are not disposable decoration. At $t=1$ they cancel almost completely, leaving $1$. At $t=-1$ the evaluation factor aligns them, making all $2k+1$ contributions reinforce.

## 7. Algorithms

### 7.1 Enumerating monotone path areas

To compute the unsigned area distribution for all paths of size $n$, enumerate the $\binom{2n}{n}$ choices of positions occupied by north steps. For each balanced word, scan from left to right. Maintain the number $e$ of east steps already seen; whenever a north step occurs, add $e$ to the area. Increment a dictionary entry indexed by that area.

The scan costs $O(n)$ per path, so direct enumeration costs

$$
O\!\left(n\binom{2n}{n}\right)
$$

time and at most $O(n^2)$ dictionary space, excluding the output paths. A forbidden predicate can be evaluated before counting. Dynamic programming can reduce computation when the predicate is geometric and local, but arbitrary predicates admit no such general compression.

### 7.2 Constructing a universal signed model

Given a finitely supported coefficient map $c$, create $|c(m)|$ states at each nonzero degree $m$, all with sign $\operatorname{sgn}(c(m))$. If

$$
N=\sum_m|c(m)|,
$$

then construction takes $O(N)$ time and $O(N)$ output space. This representation is minimal among models restricted to unit signs, because degree $m$ requires at least $|c(m)|$ contributions of magnitude $1$ to achieve coefficient $c(m)$.

### 7.3 Cauchy convolution

For coefficient maps supported on finite sets of sizes $r$ and $s$, multiply by iterating over all occupied degree pairs. Add $c(i)d(j)$ to degree $i+j$. The sparse method costs $O(rs)$ time and at most $O(rs)$ intermediate space. This is equivalent to forming the Cartesian product of compressed weighted fibers; explicitly materializing unit-sign states may be much larger.

### 7.4 Testing palindromicity and torus identities

A finite coefficient dictionary is palindromic if $c(i)=c(-i)$ for every degree in the union of its support and reflected support. This takes linear expected time with hash-table access. For the torus family, direct generation of $2k+1$ coefficients and evaluation at $t=\pm1$ both take $O(k)$ time.

## 8. Numerical examples

For $k=1$, the torus formula gives

$$
\Delta_1(t)=t^{-1}-1+t,
$$

with coefficient list $[1,-1,1]$ on degrees $[-1,0,1]$. Its sum is $1$, and its value at $-1$ is $-3$, whose absolute value is $3$.

For $k=2$,

$$
\Delta_2(t)=t^{-2}-t^{-1}+1-t+t^2.
$$

The coefficient sum is $1$, while $\Delta_2(-1)=5$. The negative coefficients at degrees $-1$ and $1$ rule out unsigned representation.

For $k=3$,

$$
\Delta_3(t)=t^{-3}-t^{-2}+t^{-1}-1+t-t^2+t^3.
$$

Again the coefficient sum is $1$, and $\Delta_3(-1)=-7$. Reflection of exponents preserves coefficients in every case.

As an unsigned comparison, all monotone paths of size $2$ have area distribution

$$
1+t+2t^2+t^3+t^4.
$$

Every coefficient is nonnegative. Arbitrary deletion of paths can lower these coefficients independently only to other nonnegative integers; it can never produce the alternating torus polynomial.

For a product example, square the trefoil polynomial:

$$
(t^{-1}-1+t)^2=t^{-2}-2t^{-1}+3-2t+t^2.
$$

The coefficients arise by Cauchy convolution, or equivalently from the nine ordered pairs of the trefoil’s three signed states. Areas add and signs multiply.

## 9. Applications and interpretation

The positivity obstruction is useful as a model-selection principle. Whenever a proposed interpretation assigns one unweighted object to each contribution, negative coefficients refute the model immediately. This applies beyond lattice paths to any finite unsigned enumeration.

In statistical mechanics, an unsigned generating function resembles a partition function with positive degeneracies indexed by energy. A signed state sum resembles a graded trace or index, where bosonic and fermionic sectors can cancel. The Alexander polynomial’s alternating coefficients are therefore more naturally compared with an index than with a population count.

In computation, signed models allow local cancellation rules. A diagram-level construction could pair states that cancel under Reidemeister moves, leaving an invariant residual sum. Product compatibility suggests modular computation: compute state ensembles for components and combine them through convolution.

In combinatorics, the absolute values of coefficients remain plausible counting targets, especially for alternating knots with controlled sign patterns. The obstruction does not say that lattice paths are irrelevant. It says that unsigned paths cannot carry the complete invariant without an additional character, parity, or sign.

## 10. Limitations

The universal signed construction is existential and coefficient-driven. It does not derive states from crossings, does not provide a canonical forbidden region, and does not by itself explain invariance under Reidemeister moves. Thus it proves expressive completeness, not a diagrammatic theory.

Likewise, the product theorem states what happens if product state spaces are used; it does not prove that a particular diagram-local construction sends connected sum to Cartesian product. The involution theorem gives a sufficient mechanism for reciprocity, but a knot-specific model must still construct the involution from diagram data.

The path obstruction is intentionally broad but one-sided. It refutes unsigned equality with the Alexander polynomial. It does not refute path models for coefficient magnitudes, models with signed or complex weights, shifted gradings, or more elaborate higher-dimensional state spaces.

## 11. Future research

The primary open problem is a diagram-local signed path model. Each crossing should contribute local data determining admissibility, area, and sign, while Reidemeister moves should induce explicit weight-preserving bijections or cancellations.

For reduced alternating diagrams, one may instead seek an unsigned model for the coefficientwise absolute value of the normalized Alexander polynomial, after a grading shift. Such a result would recover a substantial positive fragment of the original proposal.

A third objective is to realize reciprocity geometrically. A path reflection sending area $a$ to $C-a$ and preserving sign would explain palindromicity through Theorem 5.3 after recentering.

A fourth objective is compatibility with connected sum. Concatenation or Cartesian product of path ensembles should add areas and multiply signs, making Theorem 5.1 a direct diagrammatic statement rather than an abstract algebraic analogy.

Finally, related signed path constructions may be sought for the Jones and HOMFLY polynomials, possibly using larger step alphabets or higher-dimensional gradings. In each case, positivity tests should be applied first to determine whether unsigned enumeration is possible.

## 12. Conclusion

Unsigned finite area-generating functions are exactly the finitely supported Laurent polynomials with nonnegative integer coefficients. Signed finite state sums are exactly all finitely supported integer Laurent polynomials. This sharp characterization resolves the basic representability question.

The Alexander polynomials of $T(2,2k+1)$ make the distinction unavoidable. Every nontrivial member has a coefficient $-1$ and therefore cannot be an unsigned path count, even when the allowed paths may be selected arbitrarily. Nevertheless, every member has a finite signed model, is palindromic, evaluates to $1$ at $t=1$, and has determinant $2k+1$ from evaluation at $t=-1$.

Signed models also carry the right structural operations: Cartesian products yield Cauchy products, total signed weights multiply, and area-reversing sign-preserving involutions yield reciprocity. The corrected bridge between knots and lattices is therefore not ordinary counting but counting with cancellation.