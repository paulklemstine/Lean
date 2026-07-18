# Dense Asymptotic Invisibility in the Infinite Symmetric Group

## Finite-prefix extension, prime-indexed sequences, and factorial families

**Author:** Aristotle  
**Date:** July 18, 2026

## Abstract

Let $S_\infty$ denote the group of permutations of the nonnegative integers, equipped with the topology of pointwise convergence. Given a real sequence $a=(a_n)_{n\ge 0}$ that is eventually nonzero, call a permutation $\sigma$ ratio-one if

$$
\frac{a_{\sigma(n)}}{a_n}\longrightarrow 1.
$$

We prove that ratio-one permutations are dense in $S_\infty$. The result follows from a finite-extension principle: every prescribed finite prefix of an arbitrary permutation extends to a permutation that is eventually the identity. Such an extension has finite support, so its rearranged-to-original quotient is eventually exactly $1$. The argument is independent of growth, monotonicity, and arithmetic structure. It applies in particular to every prime-valued enumeration, where nonvanishing follows from primality. We also describe a factorial family of distinct finite-support extensions: Lehmer codes for permutations of $k$ elements yield $k!$ distinct infinite permutations, each supported on the first $k$ indices and hence ratio-one for every eventually nonzero sequence. Algorithms for constructing finite-prefix extensions, evaluating ratio profiles, and encoding finite permutations are given with complexity bounds. We clarify the distinction between topological density and probabilistic prevalence and explain why finite random-permutation experiments do not determine the behavior of random infinite permutations.

## 1. Introduction

Hilbert’s Hotel supplies a vivid model of countable infinity: rooms are indexed by $\mathbb N=\{0,1,2,\ldots\}$, and a rearrangement of the occupants is a bijection of $\mathbb N$. If room $n$ initially contains a quantity $a_n$, then a permutation $\sigma$ produces the rearranged value $a_{\sigma(n)}$ in room $n$. Comparing new and old occupants through

$$
r_n(\sigma;a)=\frac{a_{\sigma(n)}}{a_n}
$$

leads to a natural asymptotic question: which permutations become invisible in the sense that $r_n(\sigma;a)\to 1$?

For a prime hotel, $a_n=p_n$ is prime for every $n$. If the primes are listed in increasing order, their asymptotic growth might suggest that a proof must invoke the prime number theorem. It does not. The density result studied here is entirely topological and combinatorial. A finite observer can demand arbitrary behavior on finitely many inputs, after which the partial assignment can be completed within a finite set and all remaining indices can be fixed. The ratio is then exactly $1$ on the tail.

This observation establishes a robust but carefully delimited theorem. In the pointwise topology, every neighborhood of every permutation contains a ratio-one permutation. Density, however, is not a probability statement. It does not imply that all permutations, almost all permutations, or even a nonmeagre set of permutations are ratio-one. Nor does it justify extrapolating from uniformly random finite permutations to an unspecified random infinite permutation.

The contributions are as follows.

1. We formulate prefix density as the cylinder-set form of density in $S_\infty$.
2. We prove that every finite prefix of a permutation extends to an eventually fixed permutation.
3. We deduce dense asymptotic invisibility for every eventually nonzero real sequence.
4. We specialize the theorem to arbitrary prime-valued enumerations.
5. We construct $k!$ distinct finite-support ratio-one permutations from Lehmer codes.
6. We provide explicit algorithms and distinguish exact theorems from heuristic prime-asymptotic questions.

No ordering assumption on $a_n$ is needed. In particular, the prime specialization does not require the enumeration to be increasing.

## 2. The infinite symmetric group and its topology

### 2.1 Permutations and support

A **permutation of $\mathbb N$** is a bijection $\sigma:\mathbb N\to\mathbb N$. The collection of all such permutations is denoted $S_\infty$. Composition gives $S_\infty$ a group structure.

The **support** of $\sigma$ is

$$
\operatorname{supp}(\sigma)=\{n\in\mathbb N:\sigma(n)\ne n\}.
$$

A permutation has **finite support** if this set is finite. Equivalently, $\sigma$ is **eventually fixed** if there is an integer $N$ such that

$$
\sigma(n)=n\qquad\text{for every }n\ge N.
$$

For permutations of $\mathbb N$, finite support and eventual fixation are equivalent: every finite subset of $\mathbb N$ is bounded.

### 2.2 Prefix cylinders

The pointwise topology records agreement on finitely many inputs. Given $\sigma\in S_\infty$ and $k\in\mathbb N$, define the prefix cylinder

$$
U(\sigma,k)=\{\tau\in S_\infty:\tau(n)=\sigma(n)\text{ for all }n<k\}.
$$

These sets form a neighborhood basis. Although a general basic neighborhood may prescribe values on an arbitrary finite set, every finite set is contained in some initial segment $\{0,\ldots,k-1\}$; prefix cylinders therefore suffice for testing density.

**Definition 2.1 (Prefix density).** A set $G\subseteq S_\infty$ is prefix-dense if, for every $\sigma\in S_\infty$ and every $k\in\mathbb N$, the intersection $G\cap U(\sigma,k)$ is nonempty.

Thus prefix density is precisely the finite-observation formulation of density in the pointwise topology.

### 2.3 Ratio-one rearrangements

Let $a:\mathbb N\to\mathbb R$ be a real sequence.

**Definition 2.2 (Asymptotic invisibility).** A permutation $\sigma\in S_\infty$ is **well behaved**, or **asymptotically invisible**, for $a$ if the quotient is eventually defined and

$$
\lim_{n\to\infty}\frac{a_{\sigma(n)}}{a_n}=1.
$$

We write

$$
W(a)=\left\{\sigma\in S_\infty:rac{a_{\sigma(n)}}{a_n}\to 1\right\}.
$$

The natural minimal condition for the argument is eventual nonvanishing:

$$
\exists N_0\ \forall n\ge N_0,
\qquad a_n\ne 0.
$$

Values at finitely many earlier indices cannot affect convergence.

## 3. Completing a finite observation

The main combinatorial ingredient says that arbitrary finite behavior can be confined to a finite region.

**Theorem 3.1 (Finite-Prefix Extension Theorem).** Let $\sigma\in S_\infty$ and let $k\in\mathbb N$. There exists $\tau\in S_\infty$ such that

$$
\tau(n)=\sigma(n)\qquad(0\le n<k)
$$

and $\tau$ is eventually fixed. More explicitly, there is an integer $N$ for which

$$
\tau(n)=n\qquad(n\ge N).
$$

**Proof sketch.** The finite list $\sigma(0),\ldots,\sigma(k-1)$ has a maximum when $k>0$. Choose $N$ larger than $k$ and larger than every value in this list. Let

$$
X=\{0,1,\ldots,k-1\},
\qquad
Y=\{0,1,\ldots,N-1\}.
$$

The restriction $f=\sigma|_X:X\to Y$ is injective because $\sigma$ is a permutation. There are $k$ used targets in $f(X)$, so the complement $Y\setminus f(X)$ has $N-k$ elements. The unused source set $Y\setminus X$ also has $N-k$ elements. Choose any bijection

$$
g:Y\setminus X\longrightarrow Y\setminus f(X).
$$

Define $\rho:Y\to Y$ by $\rho(x)=f(x)$ for $x\in X$ and $\rho(x)=g(x)$ for $x\in Y\setminus X$. The images of the two pieces are disjoint and cover $Y$, so $\rho$ is a bijection. Finally set

$$
\tau(n)=
\begin{cases}
\rho(n),&n<N,\\
n,&n\ge N.
\end{cases}
$$

This is a bijection of $\mathbb N$, agrees with $\sigma$ below $k$, and fixes every index at least $N$. The case $k=0$ is immediate, for example by taking the identity. $\square$

Several aspects of the theorem are worth emphasizing. The prescribed images need not lie in the first $k$ positions. The larger finite set $Y$ absorbs all of them. The extension need not agree with $\sigma$ outside the observed prefix; indeed, changing the unobserved portion is what allows the tail to become fixed.

**Corollary 3.2 (Density of finite-support permutations).** The finite-support permutations are prefix-dense in $S_\infty$.

**Proof sketch.** Apply Theorem 3.1 to each pair $(\sigma,k)$. The resulting $\tau$ lies in $U(\sigma,k)$ and has finite support. $\square$

This is the topological core of all subsequent conclusions.

## 4. Eventual fixation implies asymptotic invisibility

The analytical step is elementary but decisive.

**Lemma 4.1 (Tail Identity Lemma).** Let $a:\mathbb N\to\mathbb R$ be eventually nonzero, and let $\tau\in S_\infty$ be eventually fixed. Then $\tau\in W(a)$; that is,

$$
\lim_{n\to\infty}\frac{a_{\tau(n)}}{a_n}=1.
$$

**Proof sketch.** Choose $N_0$ so that $a_n\ne0$ for $n\ge N_0$, and choose $N_1$ so that $\tau(n)=n$ for $n\ge N_1$. For every $n\ge\max(N_0,N_1)$,

$$
\frac{a_{\tau(n)}}{a_n}=rac{a_n}{a_n}=1.
$$

Hence the quotient sequence is eventually constant with value $1$, and therefore converges to $1$. $\square$

No regularity of $a$ is used. The sequence may oscillate, be unbounded, repeat values, or have no limit. Only tail nonvanishing matters.

Combining the extension theorem and the tail identity gives the main result.

**Theorem 4.2 (Dense Asymptotic-Invisibility Theorem).** Let $a:\mathbb N\to\mathbb R$ satisfy $a_n\ne0$ for all sufficiently large $n$. Then $W(a)$ is prefix-dense in $S_\infty$. Equivalently, for every $\sigma\in S_\infty$ and every $k\in\mathbb N$, there exists $\tau\in S_\infty$ such that

$$
\tau(n)=\sigma(n)\qquad(n<k)
$$

and

$$
\lim_{n\to\infty}\frac{a_{\tau(n)}}{a_n}=1.
$$

**Proof sketch.** By Theorem 3.1, extend the prescribed prefix of $\sigma$ to an eventually fixed permutation $\tau$. Lemma 4.1 then implies $\tau\in W(a)$. Since this works in every prefix cylinder, $W(a)$ is prefix-dense. $\square$

**Remark 4.3.** The theorem proves more than mere convergence for the constructed approximants: their quotient sequences are eventually exactly $1$.

**Remark 4.4.** Eventual nonvanishing is the appropriate condition for the literal real quotient. If infinitely many denominators vanish, the displayed quotient need not be defined on a tail. In a more general algebraic setting one would replace nonzero elements by units and division by multiplication with inverses.

## 5. The prime hotel

Let $p:\mathbb N\to\mathbb N$ be any prime-valued sequence, meaning that $p_n$ is prime for every $n$. The values need not be distinct or increasing for the density theorem, although the standard motivating example takes $p_n$ to be the $n$th prime.

Every prime is at least $2$, and in particular $p_n\ne0$. Viewing $p_n$ as a real number permits application of Theorem 4.2.

**Theorem 5.1 (Prime-Hotel Density Theorem).** Let $(p_n)_{n\ge0}$ be any prime-valued sequence. For every permutation $\sigma\in S_\infty$ and every cutoff $k$, there exists a permutation $\tau\in S_\infty$ satisfying

$$
\tau(n)=\sigma(n)
\qquad(0\le n<k)
$$

and

$$
\lim_{n\to\infty}\frac{p_{\tau(n)}}{p_n}=1.
$$

Consequently, the set of asymptotically invisible prime rearrangements is dense in the pointwise topology.

**Proof sketch.** Primality implies $p_n\ne0$ for every $n$. Apply Theorem 4.2 to the real sequence $a_n=p_n$. $\square$

The result is invariant under the choice of prime enumeration. This shows exactly how little number theory is involved: primality enters only through nonvanishing. Neither infinitude of primes nor the asymptotic relation $p_n\sim n\log n$ is needed once a prime-valued sequence has been supplied.

### 5.1 What the theorem does not assert

The theorem does not say that every $\sigma$ satisfies the ratio-one limit. A permutation can move infinitely many indices by large relative amounts. Nor does density provide an “exact probability” that a permutation is well behaved. The group $S_\infty$ has no uniform probability measure analogous to the uniform distribution on a finite symmetric group.

Topological density means only this: after any finite behavior has been prescribed, some good infinite continuation remains possible. A dense set may be small in other senses; for instance, dense meagre sets are common.

### 5.2 Adjacent and block rearrangements

As a heuristic illustration, swapping neighboring indices gives $\sigma(2m)=2m+1$ and $\sigma(2m+1)=2m$. For the increasing prime sequence, the prime number theorem suggests—and standard consequences confirm—that consecutive prime ratios tend to $1$. Such a permutation has infinite support yet should remain ratio-one. This lies beyond the finite-support mechanism and uses genuine prime asymptotics.

By contrast, repeatedly moving indices between macroscopically separated regions can prevent convergence or force ratios away from $1$. This motivates the conjectural characterization by relative displacement $\sigma(n)/n\to1$.

## 6. Factorial families and Lehmer codes

Finite-support permutations already form a large, explicitly parameterized family.

For $k\ge0$, let $S_k$ be the permutations of $\{0,1,\ldots,k-1\}$. Extending $\pi\in S_k$ by the identity defines $\widehat\pi\in S_\infty$:

$$
\widehat\pi(n)=
\begin{cases}
\pi(n),&n<k,\\
n,&n\ge k.
\end{cases}
$$

A **Lehmer code** of length $k$ is a tuple $(c_0,\ldots,c_{k-1})$ satisfying

$$
0\le c_i<k-i.
$$

Starting with the ordered list $L=[0,1,\ldots,k-1]$, choose the element of $L$ at position $c_0$, remove it, then choose position $c_1$ from the shorter list, and continue. This decodes the tuple into a unique permutation. Conversely, recording the rank of each successive selected value encodes every permutation uniquely.

The number of codes is

$$
\prod_{i=0}^{k-1}(k-i)=k!.
$$

**Theorem 6.1 (Factorial Family Theorem).** For each $k$, the $k!$ Lehmer codes decode to $k!$ distinct permutations of the first $k$ indices. Extension by the identity yields $k!$ distinct permutations of $\mathbb N$. Every one of these infinite permutations is asymptotically invisible for every eventually nonzero real sequence.

**Proof sketch.** Lehmer decoding is bijective between valid codes and $S_k$. If two finite permutations differ, their identity extensions differ at the same index below $k$, so extension is injective. Each extension fixes every $n\ge k$, and Lemma 4.1 gives asymptotic invisibility. $\square$

This family connects local combinatorial richness with asymptotic triviality. The number of possible lobby rearrangements grows factorially, while every such rearrangement has exactly the same tail ratio.

## 7. Algorithms

### 7.1 Finite-prefix completion

Input consists of distinct prescribed targets $v_0,\ldots,v_{k-1}$, representing $\sigma(i)=v_i$. Choose

$$
N=1+\max\bigl(\{k\}\cup\{v_i:0\le i<k\}\bigr).
$$

Form the unused sources $k,k+1,\ldots,N-1$ and unused targets in $\{0,\ldots,N-1\}\setminus\{v_0,\ldots,v_{k-1}\}$. Pair them in increasing order. The resulting array is a permutation of $\{0,\ldots,N-1\}$ and agrees with the prefix. Extend it by the identity.

With a Boolean used-target array, construction takes $O(N+k)$ time and $O(N)$ memory. Sorting is unnecessary because scanning already lists unused targets in increasing order.

### 7.2 Lehmer decoding

Maintain an ordered list of unused symbols. At step $i$, remove the element at index $c_i$. A simple array implementation takes $O(k^2)$ time because each deletion shifts later entries, and $O(k)$ memory. An order-statistic tree reduces decoding to $O(k\log k)$ time.

### 7.3 Ratio-profile evaluation

Given values $a_0,\ldots,a_{M-1}$ and a finite permutation array $\tau$, compute $a_{\tau(n)}/a_n$ for each available nonzero denominator. For an eventually fixed extension, all unlisted indices use $\tau(n)=n$ and hence ratio $1$. Evaluation is $O(M)$ time and $O(M)$ output space, or $O(1)$ additional space if ratios are streamed.

These algorithms demonstrate exact finite consequences. They do not estimate a probability of convergence for “random infinite permutations,” which requires a separately specified probability model.

## 8. Numerical illustrations

Consider the prescribed prefix

$$
(\sigma(0),\sigma(1),\sigma(2))=(3,0,4).
$$

Taking $N=5$, unused sources are $3,4$ and unused targets are $1,2$. Pairing in order gives the finite permutation

$$
\tau=(3,0,4,1,2),
$$

extended by $\tau(n)=n$ for $n\ge5$. For the increasing primes

$$
(2,3,5,7,11,13,17,19,\ldots),
$$

the initial ratio profile is

$$
\left(\frac72,\frac23,\frac{11}{5},\frac37,\frac5{11},1,1,1,\ldots\right).
$$

The early terms need not approximate $1$ at all. Convergence follows because the tail is exactly constant.

As another illustration, any Lehmer code of length $6$ produces one of $6!=720$ permutations supported on the first six indices. All $720$ have prime ratio exactly $1$ from index $6$ onward. Distinctness is visible entirely inside the first six rooms.

## 9. Applications and broader interpretation

### 9.1 Sequence-independent approximation

The extension $\tau$ depends on the target permutation $\sigma$ and cutoff $k$, but not on the sequence $a$. Once constructed, the same $\tau$ is asymptotically invisible simultaneously for every real sequence that is eventually nonzero. This universal feature is stronger than a prime-specific approximation.

### 9.2 Topological groups and units

The argument suggests an abstract version. Let $(x_n)$ lie eventually in the unit group of a topological monoid, and compare $x_{\tau(n)}x_n^{-1}$. An eventually fixed $\tau$ makes this expression eventually equal to the identity element. Thus the central mechanism extends naturally beyond real division.

### 9.3 Data rearrangement

In data analysis, a finite-support permutation models a bounded number of indexing errors or local relabelings. Any tail statistic based on termwise relative ratios is insensitive to such finite disturbances, assuming denominators eventually remain nonzero. The theorem adds a topological statement: these finite disturbances can reproduce any prescribed finite pattern.

### 9.4 Separating topology from arithmetic

For the prime sequence, there are two distinct research layers. The topological layer asks whether good permutations occur in every finite cylinder; finite-prefix extension answers yes. The arithmetic layer asks which infinitely supported permutations are good; there prime growth and index displacement become essential. Keeping these layers separate prevents the density theorem from being overstated.

## 10. Discussion of random permutations

A uniform random permutation exists on $S_M$ for each finite $M$. There is, however, no direct “uniform random permutation of $\mathbb N$” obtained by simply letting $M$ tend to infinity while preserving all desired symmetries. A meaningful infinite experiment must define a model, such as independent finite blocks, regenerative cycles, or a projectively consistent law.

If a sampled permutation of the first $M$ indices is extended by the identity, then the associated infinite permutation is automatically ratio-one: every ratio after $M$ equals $1$. Measuring only the first $M$ ratios may show broad dispersion, but it cannot contradict tail convergence.

Alternatively, if one draws a new permutation for every growing $M$, the observed triangular array does not describe one fixed infinite permutation unless a coupling is specified. Claims that “most ratios converge” therefore conflate finite concentration with infinite almost-sure convergence.

A rigorous probabilistic theory should ask how cycle-block lengths control displacement. Finite-mean local blocks plausibly force relative displacement to vanish, whereas heavy-tailed blocks may create infinitely many macroscopic moves. These are future questions, not consequences of topological density.

## 11. Future work

Several directions follow naturally.

First, the Baire-category size of $W(p)$ remains to be determined. Finite-support permutations prove density, while cylinder refinements that force alternating expansions and contractions may show meagreness.

Second, one may seek permutations realizing every positive limiting ratio $c$:

$$
\frac{p_{\sigma(n)}}{p_n}\longrightarrow c.
$$

The heuristic $p_n\sim n\log n$ reduces this to constructing a bijection with approximate scale $\sigma(n)\sim cn$, corrected sparsely to maintain global bijectivity.

Third, an abstract universal criterion should replace nonzero real terms by eventual units in a topological algebraic structure.

Fourth, for the increasing prime sequence, one expects a close equivalence between

$$
\frac{\sigma(n)}n\to1
\qquad\text{and}\qquad
\frac{p_{\sigma(n)}}{p_n}\to1.
$$

Establishing both directions for nonmonotone permutations would characterize the full ratio-one class through combinatorial displacement.

Finally, explicit random infinite permutation models may exhibit phase transitions governed by the tail of cycle-block lengths.

## 12. Structural consequences

The argument yields a useful simultaneous form of approximation. Fix a permutation $\sigma$ and cutoff $k$, and construct $\tau$ by finite completion. Because $\tau$ is eventually fixed independently of any sequence, the same $\tau$ belongs to $W(a)$ for every eventually nonzero real sequence $a$. Thus one may prescribe a finite rearrangement once and obtain asymptotic invisibility across an arbitrary family of eligible sequences, even an uncountable family. No diagonal selection is needed.

There is also a stability consequence under enlarging the finite lobby. If an extension fixes all indices from $N$ onward, it may be composed with any permutation supported in a later finite interval $\{N,\ldots,M-1\}$. The composition still has finite support and still preserves the original prescribed prefix. Hence each prefix cylinder contains not just one ratio-one extension but infinitely many of them. Indeed, allowing all permutations of successively larger unused finite blocks produces families of unbounded factorial size.

Finally, the proof identifies the precise division of labor among the assumptions. Injectivity of the observed assignments permits finite matching; countability and the order on $\mathbb N$ let a finite set be enclosed by a cutoff; eventual nonvanishing makes tail division meaningful; and eventual fixation forces the limit. Primality itself contributes only the last condition automatically, through the elementary fact that primes are nonzero.

## 13. Conclusion

Every finite observation of an arbitrary permutation of $\mathbb N$ can be completed by an eventually fixed permutation. This finite-prefix extension principle makes finite-support permutations dense in the pointwise topology. Because eventual fixation forces rearranged-to-original ratios to become exactly $1$, asymptotically invisible rearrangements are dense for every eventually nonzero real sequence and, in particular, for every prime-valued enumeration.

Lehmer codes sharpen the picture by furnishing $k!$ distinct harmless rearrangements supported in the first $k$ rooms. The resulting theory is not a statement that arbitrary or random rearrangements preserve prime asymptotics. It is a precise topological theorem: no finite window can exclude asymptotic invisibility. Any obstruction to a ratio-one limit must be generated by behavior occurring infinitely often and arbitrarily far along the sequence.