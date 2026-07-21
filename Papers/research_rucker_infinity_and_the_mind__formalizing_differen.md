# Cantor, Aleph, Beth, and Hartogs: A Self-Contained Account of Successive Infinite Sizes

**Aristotle**  
**July 21, 2026**

## Abstract

This paper develops a compact account of several fundamental mechanisms for comparing infinite sizes. We begin from cardinal comparison by injections and bijections, prove Cantor’s theorem directly through the diagonal subset, and deduce that every power set has strictly greater cardinality than its underlying set. We then present the initial aleph and beth numbers: $\aleph_0$ is the cardinality of the natural numbers, $\aleph_1$ is its successor cardinal, and every successor step of the beth hierarchy is strict. The first beth number is $2^{\aleph_0}$, the cardinality $\mathfrak c$ of the continuum. This yields the unconditional inequality $\aleph_1\leq\mathfrak c$ and identifies the continuum hypothesis with $\beth_1=\aleph_1$. Finally, we describe a type-theoretic Hartogs successor object $H(X)$ of cardinality $|X|^+$ and prove both that $X$ embeds into $H(X)$ and that $H(X)$ cannot embed into $X$. Algorithms and finite numerical models illustrate diagonalization, power-set growth, successor growth, and the distinction between evidence at finite scales and assertions about infinite cardinals. The resulting picture separates three operations that are often conflated: enumeration, passage to all subsets, and passage to the least strictly larger cardinal.

## 1. Introduction

Cardinality extends finite counting by declaring two collections to have the same size when their elements admit a bijection. This definition is structurally natural: it asks whether the collections can be paired without omission or repetition. Its consequences for infinite sets differ sharply from finite intuition. The natural numbers $\mathbb N$ and their even members have the same cardinality, because $n\mapsto 2n$ is a bijection. Thus containment alone does not imply strict inequality for infinite cardinalities.

Strict growth nevertheless occurs in two robust ways. The first is the power-set operation. For every set $X$, the set $\mathcal P(X)$ of all subsets of $X$ is strictly larger than $X$. The second is successor-cardinal formation: for a cardinal $\kappa$, its successor $\kappa^+$ is, by definition, the least cardinal strictly larger than $\kappa$. These operations generate the beth and aleph viewpoints respectively.

The first point at which they meet is the continuum. The size of the natural numbers is $\aleph_0$. The size of their power set is $2^{\aleph_0}$, also denoted $\beth_1$. This cardinal equals the size $\mathfrak c$ of the real line. Meanwhile $\aleph_1=\aleph_0^+$ is the least uncountable cardinal. Cantor’s theorem ensures $\aleph_1\leq\mathfrak c$, but the assertion of equality is the continuum hypothesis.

A third construction, associated with Hartogs, expresses escape from a given set through well-ordering. In the successor-cardinal presentation used here, a Hartogs successor object $H(X)$ has cardinality $|X|^+$. The strict inequality gives an embedding $X\hookrightarrow H(X)$ and rules out any embedding $H(X)\hookrightarrow X$. This formulation cleanly displays the cardinal consequence. The classical set-theoretic Hartogs theorem additionally emphasizes that an ordinal not injectible into $X$ can be obtained without assuming a global choice principle; that foundational refinement is discussed in Section 9.

The objective is not to resolve the continuum hypothesis or questions of consistency strength. It is to state precisely what follows from diagonalization, cardinal succession, and the definitions of the two hierarchies.

## 2. Cardinal comparison and power sets

### 2.1 Basic definitions

Let $X$ and $Y$ be sets.

A function $f:X\to Y$ is **injective** if $f(x)=f(x')$ implies $x=x'$. It is **surjective** if every $y\in Y$ equals $f(x)$ for some $x\in X$. It is **bijective** if it is both injective and surjective.

The sets $X$ and $Y$ are **equinumerous**, written $|X|=|Y|$, if there is a bijection $X\to Y$. We write $|X|\leq|Y|$ if there is an injection $X\to Y$, and $|X|<|Y|$ if $|X|\leq|Y|$ but $|X|\neq|Y|$.

The **power set** of $X$ is

$$
\mathcal P(X)=\{A:A\subseteq X\}.
$$

A subset $A\subseteq X$ may be identified with its characteristic function $\chi_A:X\to\{0,1\}$. Accordingly, if $|X|=\kappa$, then

$$
|\mathcal P(X)|=2^\kappa.
$$

For a finite set with $n$ elements, this recovers $|\mathcal P(X)|=2^n$.

### 2.2 The diagonal obstruction

The central proof is best stated as a theorem about arbitrary attempted enumerations.

> **Theorem 2.1 (Cantor’s diagonal theorem).** Let $X$ be any set and let $f:X\to\mathcal P(X)$. Then $f$ is not surjective.

**Proof sketch.** Define the diagonal subset

$$
D_f=\{x\in X:x\notin f(x)\}.
$$

If $f$ were surjective, there would be $a\in X$ with $f(a)=D_f$. Evaluating membership at $a$ would give

$$
a\in D_f\iff a\notin f(a)\iff a\notin D_f,
$$

which is impossible. Therefore $D_f$ is not in the range of $f$. $\square$

The proof uses no finiteness assumption and no cardinal calculation. It explicitly constructs an omitted subset from the proposed list.

> **Corollary 2.2 (No equivalence with a power set).** For every set $X$, no bijection $X\to\mathcal P(X)$ exists.

**Proof sketch.** A bijection would in particular be a surjection, contradicting Theorem 2.1. $\square$

> **Theorem 2.3 (Strict power-set growth).** For every set $X$,
>
> $$
> |X|<|\mathcal P(X)|.
> $$

**Proof sketch.** The map $x\mapsto\{x\}$ injects $X$ into $\mathcal P(X)$, proving $|X|\leq|\mathcal P(X)|$. Corollary 2.2 excludes equality. $\square$

The same statement applies to a set regarded inside any ambient universe: if $S$ is a set, its family of subsets has strictly greater cardinality than $S$ itself.

> **Corollary 2.4 (No largest cardinal).** For every cardinal $\kappa$, there is a cardinal strictly greater than $\kappa$.

**Proof sketch.** Choose a set $X$ of cardinality $\kappa$ and use $|\mathcal P(X)|=2^\kappa>\kappa$. $\square$

## 3. Countability and the first alephs

A set $X$ is **countably infinite** if it is equinumerous with $\mathbb N$. The cardinality of $\mathbb N$ is denoted

$$
\aleph_0=|\mathbb N|.
$$

A cardinal $\lambda$ is a **successor cardinal** of $\kappa$, written $\kappa^+$, when $\lambda$ is the least cardinal strictly larger than $\kappa$. The aleph hierarchy enumerates infinite well-ordered cardinalities. Its initial terms satisfy

$$
\aleph_0=|\mathbb N|,
\qquad
\aleph_1=\aleph_0^+.
$$

> **Theorem 3.1 (Initial aleph growth).** The first two alephs satisfy
>
> $$
> \aleph_0<\aleph_1.
> $$

**Proof sketch.** By definition, $\aleph_1$ is the successor cardinal of $\aleph_0$, and every cardinal is strictly below its successor. $\square$

> **Theorem 3.2 (Successor characterization of $\aleph_1$).**
>
> $$
> \aleph_1=\aleph_0^+.
> $$

**Proof sketch.** The aleph hierarchy advances at a successor ordinal by taking the successor cardinal. Applying this at the successor of the initial ordinal gives the identity. $\square$

This characterization implies that whenever $\lambda$ is a cardinal with $\aleph_0<\lambda$, one has $\aleph_1\leq\lambda$. In ordinary set-theoretic language, $\aleph_1$ is the least uncountable cardinal.

### 3.1 Why familiar enlargements remain countable

Several examples clarify why a dedicated successor cardinal is needed. The integers remain countable: one may list them in the order $0,1,-1,2,-2,\ldots$. The rational numbers also remain countable. For example, arrange fractions by increasing $|p|+q$, where $p\in\mathbb Z$ and $q\in\mathbb N$ is positive, and skip repetitions caused by unreduced representations. Every rational eventually appears in this traversal.

Finite strings over a finite or countable alphabet form another countable set. For a finite alphabet, strings can be ordered first by length and then lexicographically; each length contributes only finitely many strings. For a countable alphabet, encode a finite string as a finite tuple of natural numbers, and encode such tuples by repeated pairing. Consequently, adding finite descriptions, finite tuples, or countably many countable layers does not automatically pass beyond $\aleph_0$.

By contrast, all infinite binary sequences are uncountable. They correspond bijectively to subsets of $\mathbb N$: the sequence $(b_n)$ represents the set $\{n:b_n=1\}$. Cantor’s theorem therefore gives

$$
\aleph_0<2^{\aleph_0}.
$$

This comparison isolates the source of the jump. Permitting arbitrary finite constructions over countable data often preserves countability; permitting an independent binary choice at every natural-number position creates the full power set and forces a larger cardinality. The least possible larger cardinal is $\aleph_1$, while the actual size of the binary-sequence space is $\beth_1=\mathfrak c$. The distinction between these two sizes is precisely where the continuum question enters.

## 4. The beth hierarchy and strict successor steps

The beth hierarchy measures repeated power-set growth. At its initial and successor stages it is defined by

$$
\beth_0=\aleph_0,
\qquad
\beth_{\alpha+1}=2^{\beth_\alpha}.
$$

At limit ordinals one takes the appropriate supremum of earlier values, though no limit-stage theorem is needed for the results below.

> **Theorem 4.1 (Strict beth successor step).** For every ordinal $\alpha$,
>
> $$
> \beth_\alpha<\beth_{\alpha+1}.
> $$

**Proof sketch.** By definition, $\beth_{\alpha+1}=2^{\beth_\alpha}$. Choose a set $X$ of cardinality $\beth_\alpha$. Then $2^{\beth_\alpha}=|\mathcal P(X)|$, which is strictly larger than $|X|=\beth_\alpha$ by Theorem 2.3. $\square$

> **Theorem 4.2 (The first beth number).**
>
> $$
> \beth_1=2^{\aleph_0}.
> $$

**Proof sketch.** Substitute $\alpha=0$ into the successor definition and use $\beth_0=\aleph_0$. $\square$

The theorem records an important distinction. The aleph successor $\aleph_1$ is the least next cardinal. The beth successor $\beth_1$ is obtained by a specified operation, exponentiation by $2$. Cantor guarantees that the latter is at least the former, but does not identify them.

## 5. The continuum and the continuum hypothesis

The **continuum cardinal** $\mathfrak c$ is the cardinality of $\mathbb R$. It is standard that

$$
\mathfrak c=2^{\aleph_0}.
$$

One route to this identity compares real numbers with infinite binary sequences. Every subset of $\mathbb N$ determines a binary sequence. Binary sequences can be encoded as points in a Cantor-type subset of $[0,1]$, giving one cardinal inequality. Conversely, real numbers admit countable descriptions through rational intervals or digit sequences, giving the reverse inequality. The possible double expansions of certain reals do not affect the cardinal comparison.

Combining this identity with Theorem 4.2 yields

$$
\mathfrak c=\beth_1.
$$

> **Theorem 5.1 (Unconditional lower bound for the continuum).**
>
> $$
> \aleph_1\leq\mathfrak c.
> $$

**Proof sketch.** Cantor’s theorem gives $\aleph_0<2^{\aleph_0}=\mathfrak c$. Since $\aleph_1$ is the least cardinal strictly larger than $\aleph_0$, it follows that $\aleph_1\leq\mathfrak c$. $\square$

The **continuum hypothesis**, abbreviated CH, is the statement

$$
\mathfrak c=\aleph_1.
$$

> **Theorem 5.2 (Beth formulation of CH).** The continuum hypothesis holds if and only if
>
> $$
> \beth_1=\aleph_1.
> $$

**Proof sketch.** The identity $\mathfrak c=\beth_1$ permits direct substitution in the definition of CH. $\square$

Theorem 5.1 is unconditional; Theorem 5.2 is an equivalence of formulations, not a proof of either side. The conceptual content of CH is that the first power-set jump from $\aleph_0$ lands on the immediate cardinal successor. Without CH, the established relation remains $\aleph_1\leq\beth_1$.

## 6. A Hartogs successor object

We now present a construction that associates a strictly larger well-ordered size to any set.

> **Definition 6.1 (Hartogs successor object).** For a set $X$, a Hartogs successor object $H(X)$ is a well-ordered set whose cardinality is the successor cardinal of $|X|$:
>
> $$
> |H(X)|=|X|^+.
> $$

The terminology highlights the characteristic Hartogs conclusion—non-embeddability back into $X$—while making the chosen cardinal representative explicit.

> **Theorem 6.2 (Cardinality of the Hartogs successor object).** For every set $X$,
>
> $$
> |H(X)|=|X|^+.
> $$

**Proof sketch.** This is the defining choice of $H(X)$: select the canonical well-ordered representative of the successor cardinal $|X|^+$. $\square$

> **Theorem 6.3 (Hartogs non-embedding).** There is no injection
>
> $$
> H(X)\hookrightarrow X.
> $$

**Proof sketch.** If such an injection existed, cardinal comparison would give $|H(X)|\leq|X|$. By Theorem 6.2, this says $|X|^+\leq|X|$, contradicting $|X|<|X|^+$. $\square$

> **Theorem 6.4 (Forward embedding).** There exists an injection
>
> $$
> X\hookrightarrow H(X).
> $$

**Proof sketch.** Since $|X|<|X|^+=|H(X)|$, the definition of cardinal comparison supplies an injection from $X$ into $H(X)$. $\square$

> **Corollary 6.5 (Strict Hartogs growth).** For every set $X$,
>
> $$
> |X|<|H(X)|.
> $$

Thus $H(X)$ and $\mathcal P(X)$ both exceed $X$, but they encode different targets. The former has exactly the next cardinality, while the latter has cardinality $2^{|X|}$ and may be larger than the successor.

### 6.1 Relation to the classical Hartogs theorem

Classically, Hartogs’ theorem states that for every set $X$ there exists an ordinal $h(X)$ for which no injection $h(X)\to X$ exists. One constructs $h(X)$ from order types of well-orderings of subsets of $X$. This route does not require a global assertion that every set can be well-ordered. The successor-cardinal object above provides the same non-embedding pattern in a cardinal framework where the relevant successor and its well-ordered representative are available. A fully explicit axiomatic-set-theoretic construction would distinguish carefully between these foundational settings.

## 7. Algorithms and finite models

Finite computation cannot establish claims about all infinite cardinalities, but it can make the mechanisms visible.

### 7.1 Diagonal escape algorithm

Given an $n\times n$ Boolean matrix $M$, interpret row $i$ as the characteristic vector of the subset $f(i)$. Define a vector $d$ by

$$
d_i=1-M_{ii}.
$$

Then $d$ differs from row $i$ at coordinate $i$, so it is unequal to every row.

**Algorithm.** Read the diagonal entries, negate each, and return the resulting vector.

**Correctness.** For every row index $i$, $d_i\neq M_{ii}$; hence $d\neq M_i$.

**Complexity.** The algorithm performs $n$ Boolean negations, uses $O(n)$ output space, and runs in $O(n)$ time. It need not inspect the off-diagonal entries.

This finite matrix argument is the exact combinatorial pattern of Cantor’s proof. The infinite theorem replaces $n$ coordinates by all elements of an arbitrary set.

### 7.2 Power-set enumeration

For $X=\{0,\ldots,n-1\}$, identify each subset with an $n$-bit mask. Enumerating masks from $0$ through $2^n-1$ lists all subsets.

**Correctness.** Binary expansion gives a bijection between masks and membership choices.

**Complexity.** Producing all subsets requires $\Theta(n2^n)$ total bit output in a direct representation and $O(2^n)$ subset records. This is output-optimal up to representation constants.

### 7.3 Finite successor witness

For $X_n=\{0,\ldots,n-1\}$, let $H_n=\{0,\ldots,n\}$. Inclusion embeds $X_n$ into $H_n$. No injection $H_n\to X_n$ exists by the pigeonhole principle.

This model illustrates the directionality of Theorems 6.3 and 6.4. It should not be confused with constructing infinite successor cardinals by adding one element: for infinite $X$, the set $X\cup\{*\}$ has the same cardinality as $X$.

## 8. Applications and conceptual bridges

### 8.1 Spaces of predicates and classifiers

Every subset $A\subseteq X$ determines a Boolean predicate $x\mapsto[x\in A]$, and every Boolean predicate determines a subset. Therefore the class of all binary classifiers on $X$ has cardinality

$$
2^{|X|}>|X|.
$$

This does not by itself make a statistical claim: practical hypothesis classes are restricted and learnability depends on capacity measures, distributions, and sample access. It does establish a structural fact. The unrestricted space of labels is strictly larger than the input domain, so no indexing by inputs can enumerate all possible classifiers.

### 8.2 Languages and infinite bit streams

A formal language over a countable alphabet is a subset of the countable set of finite words. Consequently, the collection of all languages has cardinality $2^{\aleph_0}=\mathfrak c$. Most such languages cannot be captured by any countable list of finite descriptions. The same counting pattern applies to infinite binary streams, subsets of integers, and arbitrary yes-or-no properties of natural numbers.

### 8.3 Diagonalization as adversarial construction

The diagonal subset is defined relative to the proposed enumeration. It is not merely an object known to exist by counting; it is an explicit adversary that changes the answer at index $x$ from the answer made by $f(x)$. This self-reference underlies many impossibility arguments. The decisive discipline is to keep the types distinct: $x$ is an element of $X$, $f(x)$ is a subset of $X$, and membership $x\in f(x)$ is a proposition that can be negated.

### 8.4 Aleph versus beth

The aleph and beth hierarchies answer different questions:

1. $\aleph_{\alpha+1}$ asks for the least cardinal above $\aleph_\alpha$.
2. $\beth_{\alpha+1}$ asks for the size of all subsets of a set of size $\beth_\alpha$.

Cantor guarantees that every beth successor is a genuine increase. It does not guarantee that it is an immediate increase. At the first stage, CH is precisely the assertion that these two notions of “next” coincide.

## 9. Scope, limitations, and foundational distinctions

The results proved here should be separated from stronger claims.

First, the continuum hypothesis has been defined and reformulated, not established. The unconditional result is $\aleph_1\leq\mathfrak c$. Any document that derives equality solely from Cantor’s theorem has silently replaced “strictly larger” by “immediate successor,” which is invalid.

Second, successor-stage strictness for the beth hierarchy follows directly from Cantor. A full transfinite study also requires definitions and comparison theorems at limit ordinals. At a limit $\lambda$, one usually sets $\beth_\lambda=\sup_{\alpha<\lambda}\beth_\alpha$; its behavior involves cofinality and cannot be reduced to one diagonal step.

Third, Hartogs’ theorem has a foundational role beyond the successor-object presentation. The classical construction of a non-embeddable ordinal can be carried out for a set $X$ without assuming that $X$ itself is well-orderable. By contrast, speaking globally of the cardinal $|X|$ as an aleph and selecting successor representatives can encode background assumptions about cardinal comparison and choice. The non-embedding proof is valid once $H(X)$ is specified with cardinality $|X|^+$, but an explicit choice-free metatheory should build the Hartogs ordinal from well-ordered subsets.

Fourth, large-cardinal notions such as inaccessible, measurable, strongly compact, and supercompact cardinals require much more structure. Their definitions involve closure properties, filters or ultrafilters, elementary embeddings, and careful universe management. Relative consistency results are metamathematical theorems about models and theories; they do not follow from merely writing down the definitions.

## 10. Future work

Several developments would extend this account.

1. Construct Hartogs’ ordinal directly in an explicit axiomatic set theory and prove its non-embedding property without a global choice principle.
2. Derive the least-uncountable characterization of $\aleph_1$ using countability predicates on sets and relate it systematically to $\aleph_0^+$.
3. Develop equivalent forms of CH, including the claim that every infinite subset of $\mathbb R$ is countable or equinumerous with $\mathbb R$, and the claim that no cardinal lies strictly between $\aleph_0$ and $\mathfrak c$.
4. Extend the beth hierarchy through limit stages and compare the full aleph and beth hierarchies.
5. Build the infrastructure for large cardinals and state relative consistency results only within an explicit metatheory of models of set theory.

## 11. Conclusion

Three constructions organize the results. Diagonalization turns any proposed enumeration $X\to\mathcal P(X)$ into a subset it misses, proving $|X|<2^{|X|}$. Successor-cardinal formation identifies $\aleph_1$ as $\aleph_0^+$ and supplies a Hartogs successor object $H(X)$ with $X\hookrightarrow H(X)$ but no injection in reverse. The beth hierarchy iterates power-set growth, yielding $\beth_1=2^{\aleph_0}=\mathfrak c$ and strict growth at every successor stage.

Together these facts imply

$$
\aleph_0<\aleph_1\leq\mathfrak c=\beth_1,
$$

while CH is exactly the assertion that the middle inequality is equality. This chain captures both the strength and the limit of elementary cardinal arguments: they prove that the continuum lies beyond countability and at or beyond the first uncountable cardinal, but they do not determine the precise size of the gap. The hierarchy of infinity is therefore generated by explicit operations, constrained by rigorous inequalities, and punctuated by questions that require additional set-theoretic analysis.