# Information-Theoretic Limits of Finite Derivation Search

**Aristotle**  
**July 19, 2026**

## Abstract

We develop a finite combinatorial model that separates three quantities often conflated in discussions of derivation search: candidate count, logarithmic description information, and worst-case oracle-query cost. A depth-$L$ derivation over an alphabet of size $q$ is modeled as a word, giving exactly $q^L$ candidates and logarithmic information $L\log_2 q$. Consequently, the scale $n\log_2 n$ holds exactly in the explicit model with $n$ choices at each of $n$ positions, but it is not distribution-free or universal: fixed branching gives linear information. We prove a sharp finite incompressibility result by counting all binary descriptions shorter than $n$, whose number is $2^n-1$, and comparing them with the $2^n$ binary objects of length $n$. We also establish an adversarial query boundary: for an unstructured verifier, every proper set of queried candidates is compatible both with no success and with a unique success at an unqueried location. Hence a family of $q^L$ candidates requires as many as $q^L=2^{L\log_2 q}$ deterministic queries in the worst case. Cartesian composition multiplies candidate populations and adds logarithmic information. For fixed branching, logarithmic candidate counts are additive and therefore subadditive, connecting the finite model to asymptotic growth-rate methods. We give exact algorithms, numerical examples, applications, and clear boundaries on what these results imply about concrete search systems.

## 1. Introduction

A verifier and a search procedure solve fundamentally different problems. A verifier receives both a statement and a proposed derivation and determines whether the derivation is valid. A search procedure receives only the statement and must locate a valid derivation, if one exists. Even when individual candidates can be checked efficiently, the candidate space can be enormous.

To study this gap without importing assumptions from a particular logical language, we use the smallest model that exposes the combinatorics. A candidate derivation is a finite sequence of choices. If there are $q$ choices at each of $L$ steps, then the candidates are words of length $L$ over a $q$-symbol alphabet. This model admits exact answers:

$$
\text{candidate count}=q^L,
\qquad
\text{logarithmic information}=\log_2(q^L)=L\log_2q.
$$

These formulas are elementary, but their interpretation requires care. Candidate count describes the size of a finite family. Its logarithm is the number of bits required to index uniformly among its members, up to integer rounding. Query complexity depends on what an attempted candidate reveals. If a verifier is an unstructured membership oracle with a unique hidden success, then negative answers eliminate only the candidates actually queried; in the worst case, every candidate may need to be tested. If the verifier reveals algebraic or semantic structure, the conclusion can change dramatically.

This paper makes four contributions. First, it states and proves exact counting and logarithmic laws for finite derivation words. Second, it derives a finite incompressibility theorem from the strict deficit between $2^n$ objects and $2^n-1$ shorter descriptions. Third, it proves a sharp adversarial lower bound for deterministic unstructured query search. Fourth, it develops composition and subadditivity laws that place these finite identities in a framework suitable for nonuniform and asymptotic generalizations.

The results provide a conditional realization of the often-proposed $n\log n$ information scale. If statement size $n$ induces depth $n$ and effective branching $n$, then the scale is exact. But the same calculation reveals its boundary: if effective branching remains bounded, logarithmic information is only linear. Thus $n\log n$ is a statement about the geometry of the candidate space, not a theorem that follows from statement length alone.

## 2. The finite derivation model

### 2.1 Candidate words

Let $q,L$ be nonnegative integers. Write

$$
[q]=\{0,1,\ldots,q-1\}.
$$

A **candidate derivation of depth $L$ over $q$ symbols** is a function

$$
w:\{0,1,\ldots,L-1\}\to[q].
$$

Equivalently, it is a word $w=(w_1,\ldots,w_L)$ with each $w_i\in[q]$. Denote the family of all such words by $W(q,L)$.

This definition includes the usual boundary cases. There is exactly one empty word when $L=0$, so $|W(q,0)|=1=q^0$. If $q=0$ and $L>0$, there are no words, agreeing with $0^L=0$.

### 2.2 Candidate information

For a nonempty finite family $S$, define its **uniform logarithmic information** by

$$
I(S)=\log_2|S|.
$$

This is an indexing quantity. If candidates are uniformly distributed, each has probability $1/|S|$, and its self-information is

$$
-\log_2\left(\frac1{|S|}\right)=\log_2|S|.
$$

When $|S|$ is not a power of two, a fixed-length binary index requires $\lceil\log_2|S|\rceil$ bits, while $\log_2|S|$ remains the natural real-valued information scale.

Cardinality alone does not define a probability distribution. For a specified distribution $p$ on $S$, the self-information of $s\in S$ is $-\log_2 p(s)$ and the Shannon entropy is

$$
H(p)=-\sum_{s\in S}p(s)\log_2p(s).
$$

The exact results below concern cardinality and its logarithm. Probabilistic interpretations are uniform unless another distribution is explicitly supplied.

### 2.3 Short binary descriptions

For $n\ge0$, let $B_{<n}$ be the set of all binary strings whose lengths are strictly less than $n$:

$$
B_{<n}=\bigcup_{k=0}^{n-1}\{0,1\}^k.
$$

The union is disjoint because strings of different lengths are distinct. This family is the target of any scheme that purports to encode every $n$-bit object using fewer than $n$ bits.

### 2.4 Unstructured query search

Let $S$ be a finite candidate family. A success set is a subset $A\subseteq S$, and an oracle answers a query $x\in S$ by returning whether $x\in A$. The lower bound considered here distinguishes two cases:

- the **empty case**, $A=\varnothing$;
- the **unique-success case**, $A=\{s\}$ for an unknown $s\in S$.

The oracle is **unstructured** because the answer to one candidate gives no relation among other candidates. A deterministic algorithm may choose later queries based on earlier answers, but along an all-negative transcript its knowledge consists only of the queried set.

## 3. Exact enumeration and information scaling

### Theorem 1 (Exact candidate count)

For all nonnegative integers $q$ and $L$,

$$
|W(q,L)|=q^L.
$$

**Proof sketch.** At each of the $L$ positions there are $q$ independent choices. The multiplication principle gives a product of $L$ copies of $q$, namely $q^L$. Equivalently, the cardinality of a finite Cartesian product is the product of the cardinalities of its factors. The boundary cases agree with the standard conventions described above. $\square$

### Corollary 2 (Uniform logarithmic information)

For $q>0$,

$$
I(W(q,L))=L\log_2q.
$$

**Proof sketch.** Apply the base-two logarithm to Theorem 1 and use $\log_2(q^L)=L\log_2q$. $\square$

### Theorem 3 (Exact $n\log n$ law under $n$-by-$n$ branching)

For every positive integer $n$, a depth-$n$ derivation model with $n$ symbols available at every position has $n^n$ candidates and uniform logarithmic information

$$
I(W(n,n))=n\log_2n.
$$

**Proof sketch.** Substitute $q=L=n$ into Theorem 1 and Corollary 2. $\square$

The theorem is exact, not asymptotic. It also identifies the assumption responsible for the scale: the effective alphabet grows with $n$. If $q$ is fixed, Corollary 2 instead gives

$$
I(W(q,n))=n\log_2q=\Theta(n).
$$

More generally, if depth is $L(n)$ and branching is $q(n)$, then

$$
I(n)=L(n)\log_2q(n).
$$

If $L(n)=\Theta(n)$ and $q(n)=\Theta(n^\alpha)$ for a constant $\alpha>0$, then

$$
I(n)=\Theta(n\log n),
$$

with leading logarithmic factor governed by $\alpha$. If $q(n)$ is bounded above and below by positive constants greater than one, then $I(n)=\Theta(n)$.

## 4. Finite incompressibility

### Lemma 4 (Count of shorter binary descriptions)

For every nonnegative integer $n$,

$$
|B_{<n}|=2^n-1.
$$

**Proof sketch.** There are $2^k$ binary strings of length $k$. Summing over $0\le k<n$ gives the finite geometric series

$$
|B_{<n}|=\sum_{k=0}^{n-1}2^k=\frac{2^n-1}{2-1}=2^n-1.
$$

For $n=0$, both sides are zero. $\square$

### Theorem 5 (No uniform strict compression)

For every nonnegative integer $n$, there is no injective map from the set of all $n$-bit strings into $B_{<n}$. Equivalently, no lossless binary description scheme assigns every $n$-bit object a code of length strictly less than $n$.

**Proof sketch.** The source contains $2^n$ objects by Theorem 1 with $q=2$ and $L=n$. The target contains only $2^n-1$ descriptions by Lemma 4. An injective map from a larger finite set to a smaller one is impossible by the pigeonhole principle. $\square$

The quantifiers are important. The theorem does not claim that every $n$-bit string is incompressible under every scheme. It claims that for each lossless scheme, at least one $n$-bit object fails to receive a strictly shorter description. Many particular strings can be compressed, provided other strings consume enough of the available code space.

The result is also independent of computational resources: even an arbitrarily expensive encoder cannot create additional short binary strings. The obstruction is purely cardinal.

## 5. The adversarial query boundary

### Lemma 6 (Unqueried witness)

Let $S$ be a finite set and let $Q\subset S$ be a proper subset. Then there exists $s\in S\setminus Q$ such that every $x\in Q$ satisfies $x\ne s$.

**Proof sketch.** Properness means precisely that $S\setminus Q$ is nonempty. Choose $s$ in the complement. Membership in the complement gives both $s\notin Q$ and $x\ne s$ for every $x\in Q$. $\square$

Though elementary, this lemma is the adversarial core of the search lower bound.

### Theorem 7 (Sharp deterministic oracle lower bound)

Let $S$ be a finite candidate family of size $N$. Any deterministic algorithm that must distinguish the empty success set from every singleton success set using only membership queries has worst-case query complexity $N$. More explicitly, after any transcript containing fewer than $N$ distinct negative queries, there remains a candidate $s$ such that the transcript is consistent both with $A=\varnothing$ and with $A=\{s\}$.

**Proof sketch.** Let $Q$ be the set of candidates queried along an all-negative transcript. If $|Q|<N$, then $Q$ is proper. By Lemma 6, choose $s\notin Q$. In the empty case, every query in $Q$ returns negative. In the singleton case $A=\{s\}$, every query in $Q$ also returns negative because none equals $s$. Thus the transcript cannot distinguish the two cases. To guarantee a decision, an algorithm may have to query all $N$ candidates. Conversely, querying all candidates suffices, so the bound is sharp. $\square$

### Corollary 8 (Exponential boundary for derivation words)

For depth-$L$ words over $q$ symbols, distinguishing no successful derivation from a unique successful derivation may require

$$
q^L
$$

queries in the worst case. If $q>0$ and $I=L\log_2q$, this is

$$
q^L=2^I.
$$

**Proof sketch.** Apply Theorem 7 to $S=W(q,L)$ and substitute the cardinality from Theorem 1. The logarithmic form follows from Corollary 2. $\square$

The theorem concerns deterministic exact search. Randomization changes the form but not the basic scale when the unique secret is uniformly distributed: without structure, a random ordering needs $(N+1)/2$ queries on average to find it, and high-confidence success still requires querying a constant fraction of the space. Such randomized claims are useful extensions but are not needed for the exact deterministic result.

The lower bound does not apply when a query reveals more than membership. A constraint solver may infer that one failure eliminates many candidates; a group-theoretic invariant may divide the space into classes; a compositional verifier may expose a failing subgoal. These are not counterexamples. They are structured search models with richer information channels.

## 6. Composition laws

### Theorem 9 (Multiplicative composition of candidate families)

Let one derivation component have alphabet size $q_1$ and depth $L_1$, and another have alphabet size $q_2$ and depth $L_2$. The family of ordered pairs of component derivations has cardinality

$$
|W(q_1,L_1)\times W(q_2,L_2)|=q_1^{L_1}q_2^{L_2}.
$$

**Proof sketch.** The cardinality of a Cartesian product is the product of the cardinalities of its factors. Apply Theorem 1 to each factor. $\square$

### Theorem 10 (Additive logarithmic information)

If $q_1,q_2>0$, then

$$
\log |W(q_1,L_1)\times W(q_2,L_2)|
=L_1\log q_1+L_2\log q_2,
$$

where the same logarithm base is used throughout.

**Proof sketch.** Use Theorem 9, then apply $\log(ab)=\log a+\log b$ and $\log(q^L)=L\log q$. Positivity ensures the logarithms are defined. $\square$

This is the combinatorial origin of additive information. Independent possibilities compose multiplicatively, while logarithms convert their product into a sum.

## 7. Subadditivity and asymptotic rates

Fix $q\ge0$ and define the natural-logarithmic candidate count

$$
A_q(n)=\log|W(q,n)|=\log(q^n).
$$

For $q>0$, this is simply

$$
A_q(n)=n\log q.
$$

At $q=0$, the expression at positive depth involves the logarithm of zero and should not be interpreted as finite information; asymptotic information statements therefore assume positive branching.

### Theorem 11 (Additivity and subadditivity at fixed branching)

For $q>0$ and all nonnegative integers $n,m$,

$$
A_q(n+m)=A_q(n)+A_q(m).
$$

Consequently,

$$
A_q(n+m)\le A_q(n)+A_q(m),
$$

so $A_q$ is subadditive.

**Proof sketch.** From $A_q(k)=k\log q$,

$$
A_q(n+m)=(n+m)\log q=n\log q+m\log q.
$$

Equality immediately implies the subadditive inequality. $\square$

### Corollary 12 (Doubled-depth information bound)

For $q>0$ and every nonnegative integer $n$,

$$
A_q(2n)\le2A_q(n).
$$

In the word model, equality holds.

**Proof sketch.** Apply Theorem 11 with $m=n$. $\square$

The importance of subadditivity is broader than this exact model. Suppose a sequence of candidate families $S_n$ satisfies a submultiplicative estimate

$$
|S_{n+m}|\le|S_n||S_m|.
$$

Taking logarithms gives

$$
\log|S_{n+m}|\le\log|S_n|+\log|S_m|.
$$

Thus logarithmic counts are subadditive even when exact factorization fails. Standard subadditive arguments can then identify a limiting exponential growth rate through normalized quantities such as $\log|S_n|/n$, provided the relevant finiteness conditions hold. The exact word model is the sharp additive baseline for that broader analysis.

## 8. Algorithms and computational examples

The principal quantities can be computed exactly with integer arithmetic before taking logarithms.

### Algorithm 1: uniform candidate analysis

Given $q$ and $L$:

1. Validate that $q,L\ge0$.
2. Compute $N=q^L$ by integer exponentiation.
3. If $N>0$, compute $I=\log_2N$; otherwise report that finite logarithmic information is undefined.
4. Report $N$ as the sharp deterministic oracle-query boundary.

Exponentiation by squaring uses $O(\log L)$ integer multiplications. Because the output $q^L$ has $\Theta(L\log q)$ bits for $q\ge2$, bit complexity necessarily depends on output size.

### Algorithm 2: shorter-description enumeration

Given $n\ge0$:

1. Compute the object count $2^n$.
2. Compute the number of shorter descriptions as $2^n-1$.
3. Compare the counts; the deficit is exactly one.
4. Conclude that an injection from all $n$-bit objects into shorter descriptions is impossible.

Again, the arithmetic uses exponentiation by squaring and subtraction. The conceptual certificate is the strict inequality $2^n-1<2^n$.

### Algorithm 3: variable-branching analysis

For branching factors $b_1,\ldots,b_L$:

1. Initialize $N=1$ and $I=0$.
2. For each level $i$, multiply $N$ by $b_i$.
3. If every $b_i>0$, add $\log_2b_i$ to $I$.
4. Return

$$
N=\prod_{i=1}^L b_i,
\qquad
I=\sum_{i=1}^L\log_2b_i=\log_2N.
$$

This generalization exposes the additive geometry of nonuniform trees. Its running time is linear in the number of levels, apart from the growing cost of big-integer multiplication.

### Numerical checks

Several small cases illustrate all three mechanisms:

- $|W(2,5)|=2^5=32$.
- $|W(4,3)|=4^3=64$.
- $|W(3,3)|=3^3=27$.
- $|B_{<5}|=2^5-1=31$, so $32$ five-bit objects cannot all receive distinct descriptions shorter than five bits.
- Combining $W(2,5)$ and $W(4,3)$ gives $32\cdot64=2048$ candidates and information $5+6=11$ bits.
- In the $n$-by-$n$ model with $n=10$, there are $10^{10}$ candidates and information $10\log_2 10\approx33.219$ bits.

## 9. Applications

### 9.1 Certificate and derivation search

Whenever a certificate consists of a bounded sequence of discrete choices, the word model gives a first candidate-count estimate. If each of $L$ stages admits at most $q$ options, then $q^L$ is an upper bound on the naïve search space. When all choices are genuinely independent and admissible, it is exact. The oracle lower bound then describes the worst case if validation provides no information beyond acceptance or rejection.

### 9.2 Passwords and exhaustive key search

A length-$L$ password over an alphabet of size $q$ has $q^L$ possibilities and $L\log_2q$ bits of uniform search information. A checker that reveals only exact equality realizes the same hidden-singleton model. Rate limits and side channels affect practical search, but the finite combinatorics are identical.

### 9.3 Test generation and configuration spaces

A system with $L$ independent parameters, each taking $q$ values, has $q^L$ complete configurations. Exhaustive testing can therefore be exponential in the number of parameters even when a single test is cheap. Structure-aware methods such as covering arrays escape exhaustive enumeration by changing the objective: they guarantee selected interaction coverage rather than identification of an arbitrary unique failing configuration.

### 9.4 Compression and representation design

The incompressibility theorem constrains universal promises. Domain-specific encodings succeed by assigning short descriptions to common or structured objects, not by shortening every object. To discuss expected compression, one must add a source distribution; to discuss prefix-free variable-length codes, one must add Kraft-type constraints. The finite theorem is the distribution-free endpoint from which those refinements begin.

### 9.5 Modular problem solving

The composition theorem quantifies the cost of independent subproblems. If two modules have information scales $I_1$ and $I_2$, their Cartesian combination has $I_1+I_2$. This supports modular accounting, but not automatically modular search: an algorithm benefits only if it can solve or constrain the components separately rather than enumerate their full product.

## 10. Scope and limitations

The results are intentionally exact and conditional. Several stronger-sounding claims do not follow from them alone.

**No distribution-free self-information.** An expression such as $-\log_2p(P)$ requires a specified probability $p(P)$. Cardinality supplies a uniform model but does not privilege it for empirical derivations.

**No universal $n\log n$ theorem.** The exact scale follows from $n$ choices at each of $n$ positions. Statement length by itself does not determine depth, branching, admissibility constraints, or redundancy.

**No automatic complexity-class lower bound.** Establishing hardness for a concrete search problem requires a formal input encoding and reductions from a known hard problem. The oracle theorem is a black-box query lower bound, not a time-complexity classification for a structured derivation system.

**No average-case theorem for random statements.** Average-case analysis requires a distribution over statements and a policy for handling instances with no derivation. The fact that many syntactic strings may fail to express solvable tasks does not itself determine the conditional cost of finding derivations for solvable instances.

**Structure can defeat enumeration.** Algebraic constraints, dynamic programming, symmetry reduction, semantic guidance, and learned ranking may collapse the effective search space. Their success should be measured by the information each operation reveals or by the reduction in effective branching.

**Verification cost remains separate.** If one verification takes time $V(n)$, exhaustive worst-case running time is approximately $q^L V(n)$, not merely $q^L$. The present analysis isolates the number of candidate queries.

These limitations sharpen rather than weaken the contribution. They identify exactly which assumptions must be justified before finite counting can support a claim about practical proof or certificate search.

## 11. Future research

A natural first extension replaces uniform branching by a sequence $b_1,b_2,\ldots$. The candidate count becomes $\prod_i b_i$ and logarithmic information becomes $\sum_i\log_2b_i$. If the Cesàro mean of $\log_2b_i$ converges, normalized information should converge to the same rate.

A second direction develops quantitative prefix-free incompressibility. For a uniform family of size $N$, counting and Kraft's inequality suggest that, for every $c\ge0$, all but at most a fraction $2^{-c}$ of objects require descriptions of length at least approximately $\log_2N-c$. Weighted versions should replace cardinality with source entropy and uniform mass with a specified distribution.

A third direction seeks explicit structure-sensitive separations: natural finite derivation systems in which candidate verification is efficient, black-box search is exponential, yet a semantic invariant supports polynomial-time construction. Such examples would quantify precisely what the oracle model omits.

A fourth direction classifies $n\log n$ behavior by effective branching. Linear depth and geometric-mean branching asymptotic to $n^\alpha$ should yield $\alpha n\log_2n$ at leading order, while bounded geometric-mean branching yields linear information.

Finally, entropy must be paired with a search policy. Two candidate families can have equal cardinality and equal uniform information while possessing radically different algorithms. A mature theory should therefore combine source information, query informativeness, computational structure, and the cost of verification.

## 12. Conclusion

Finite derivation search has a simple exact baseline. Depth-$L$ words over $q$ symbols form a family of size $q^L$ and carry $L\log_2q$ bits of uniform indexing information. The $n\log_2n$ scale is exact when depth and branching are both $n$, but fixed branching gives only linear information. There are exactly $2^n-1$ binary descriptions shorter than $n$, so no lossless code strictly compresses every $n$-bit object. An unstructured verifier can hide a unique success at any unqueried candidate, forcing $q^L=2^I$ deterministic queries in the worst case. Independent candidate spaces multiply, their logarithmic information adds, and fixed-branching logarithmic counts are additive and hence subadditive.

Together these results explain the fundamental gap between checking a chosen candidate and locating one without guidance. They also locate the boundary of the argument: cardinality is not probability, oracle search is not structured computation, and $n\log n$ reflects growing branching rather than a universal property of statements. Any practical theory of derivation search must begin with these counts and then measure the structure that allows algorithms to do better.
