# The Thermodynamics of Sorting: Decision-Tree Entropy, Reversible History, and Logical Work

**Aristotle**  
**19 July 2026**

## Abstract

Sorting $n$ distinct objects begins with $n!$ possible input orderings and produces one canonical visible order. This elementary observation supports three related but logically different conclusions. First, a binary comparison tree with enough terminal transcripts to distinguish every input ordering has worst-case height at least $\lceil\log_2(n!)\rceil$. Second, when sorting is treated as a many-to-one visible map from permutations to a single sorted result, it erases exactly $\log_2(n!)$ bits and has Landauer work scale $kT\ln(n!)$. Third, a reversible realization can produce the same visible result with zero information erasure by retaining history, but any realization whose output is a visible sorted state paired with an auxiliary register requires at least $n!$ auxiliary states. We also prove an invariance principle: arbitrary redundant levels may be added to a comparison tree, increasing its worst-case comparison count while leaving the computed sorting map and its Landauer scale unchanged. Consequently, raw comparison count cannot by itself measure thermodynamic work. The factorial $n!$ is the common combinatorial invariant, but decision complexity, logical erasure, and reversible storage are distinct resources.

## 1. Introduction

The thermodynamics of computation is often summarized by the claim that information has a physical cost. Sorting offers an appealing test case. A list of $n$ distinct objects may arrive in any of $n!$ orders, whereas its sorted presentation has only one canonical order. It is then natural to say that sorting removes $\log_2(n!)$ bits of uncertainty and costs energy proportional to that amount.

This conclusion is correct only after the physical and logical boundary of the operation has been specified. If a sorting mechanism outputs only the canonical order and discards every record of the input permutation, it is many-to-one and logically irreversible. If it outputs the sorted result together with sufficient history to reconstruct the original permutation, the total operation is reversible. Both devices look like sorters to an observer who sees only the visible component, but their logical erasure differs.

A second ambiguity concerns comparisons. The classical decision-tree argument also produces $\log_2(n!)$: each binary comparison contributes one branch, and enough branches are needed to distinguish all permutations. The recurrence of the same logarithm can encourage the assertion that each comparison necessarily erases one bit. That assertion is too coarse. Comparisons may be performed reversibly, outcomes may be retained, and redundant comparisons may be inserted without changing the computed function. Thermodynamic work is associated with the eventual destruction of distinctions, not with binary branching by itself.

This paper gives a finite-state account that separates these issues. Its principal results are:

1. the comparison-tree lower bound $h\geq\lceil\log_2(n!)\rceil$;
2. the exact visible erasure $I=\log_2(n!)$;
3. the exact Landauer scale $W=kT\ln(n!)$ for irreversible visible sorting;
4. a reversible realization with zero logical erasure;
5. the sharp auxiliary-state lower bound $|H|\geq n!$ for product-form reversible sorting; and
6. a padding theorem showing that comparison count can rise arbitrarily while logical erasure remains fixed.

The analysis includes $n=0$ and $n=1$, for which $n!=1$ and every logarithmic quantity is zero.

## 2. Finite-state information loss

### 2.1 State spaces and images

Let $X$ and $Y$ be finite sets, and let $f:X\to Y$ be a deterministic map. Only the image

$$
f(X)=\{f(x):x\in X\}
$$

is relevant to the set of reachable outputs. We define the base-two information erased by $f$ to be

$$
I(f)=\log_2|X|-\log_2|f(X)|.
$$

This definition compares the logarithmic size of the input state space with that of the reachable visible output space. It is an unweighted, finite-state quantity: every possible input is counted as a distinguishable logical state, without introducing a probability distribution.

If $f$ is surjective onto $Y$, then $|f(X)|=|Y|$. If $f$ is bijective, $|X|=|Y|$, and hence $I(f)=0$. If $f$ is constant and $X$ is nonempty, then $|f(X)|=1$ and $I(f)=\log_2|X|$.

### 2.2 Landauer scale

Let $k$ denote Boltzmann's constant and $T$ the absolute temperature. Write $kT$ for their product. We assign to an erasure of $b$ bits the Landauer work scale

$$
L(kT,b)=kT\ln 2\,b.
$$

For a finite map $f$, its Landauer gap is therefore

$$
W(f;kT)=kT\ln 2\,I(f).
$$

This is a lower-bound scale attached to logical irreversibility. It does not include implementation losses, timing constraints, noise margins, friction, resistive heating, or the cost of manipulating retained information. Nor does it assert that the bound is achieved by an arbitrary device.

### 2.3 Equivalences erase no information

**Theorem 2.1 (Zero erasure for reversible maps).** Let $X$ and $Y$ be finite sets and let $e:X\to Y$ be a bijection. Then

$$
I(e)=0
$$

and consequently

$$
W(e;kT)=0
$$

for every value of $kT$.

**Proof sketch.** Surjectivity gives $e(X)=Y$, while bijectivity gives $|X|=|Y|$. Substitution into the definition yields

$$
I(e)=\log_2|X|-\log_2|Y|=0.
$$

Multiplication by $kT\ln 2$ preserves zero. $\square$

The theorem concerns the complete logical state. A visible projection of a reversible transformation may be many-to-one even though the total transformation, including auxiliary data, is one-to-one.

## 3. Sorting as a finite map

### 3.1 The permutation state space

Fix a nonnegative integer $n$. Label the objects by the set $\{0,1,\dots,n-1\}$. An ordering is a permutation of these labels. Let $S_n$ be the set of all such permutations. Its cardinality is

$$
|S_n|=n!.
$$

At the abstraction level considered here, the visible sorted output has one state, denoted $\star$. Define the visible sorting map

$$
s_n:S_n\to\{\star\},\qquad s_n(\sigma)=\star.
$$

The labels are not destroyed physically; rather, the map records only the canonical-order status and suppresses the information specifying which input ordering occurred. This abstraction isolates the permutation information at issue.

### 3.2 Exact erasure

**Theorem 3.1 (Sorting Erasure Theorem).** For every $n\geq0$, the visible sorting map erases exactly

$$
I(s_n)=\log_2(n!)
$$

bits.

**Proof sketch.** The domain $S_n$ has $n!$ elements. Since $s_n$ is constant, its image has one element. Therefore

$$
I(s_n)=\log_2|S_n|-\log_2|s_n(S_n)|
       =\log_2(n!)-\log_2(1)
       =\log_2(n!).
$$

For $n=0$, the empty set has exactly one permutation, so $0!=1$ and the same calculation gives zero. $\square$

### 3.3 Exact Landauer scale

**Theorem 3.2 (Exact Landauer Scale for Visible Sorting).** For every $n\geq0$,

$$
W(s_n;kT)=kT\ln(n!).
$$

**Proof sketch.** By Theorem 3.1 and the change-of-base identity

$$
\log_2 x=\frac{\ln x}{\ln 2},
$$

we have

$$
W(s_n;kT)
 =kT\ln 2\,\log_2(n!)
 =kT\ln 2\,\frac{\ln(n!)}{\ln 2}
 =kT\ln(n!).
$$

The identity also holds when $n!=1$, because both sides vanish. $\square$

This theorem does not say that sorting intrinsically dissipates this work regardless of implementation. It says that the specified many-to-one map has this logical Landauer scale if its lost distinctions are erased.

## 4. Binary comparison trees

### 4.1 Tree model

A binary comparison tree is defined recursively. A leaf is a terminal transcript. A branch consists of a root comparison and two subtrees, one for each outcome. Let $L(t)$ be the number of leaves and $H(t)$ the height:

$$
L(\mathrm{leaf})=1,\qquad H(\mathrm{leaf})=0,
$$

and

$$
L(\mathrm{branch}(u,v))=L(u)+L(v),
$$

$$
H(\mathrm{branch}(u,v))=1+\max\{H(u),H(v)\}.
$$

We say that a tree has sufficient transcript capacity for sorting $n$ distinct objects if

$$
n!\leq L(t).
$$

This is deliberately a capacity condition. It is necessary for a correct deterministic comparison sorter, because distinct input orderings must be distinguishable by suitable transcripts. It does not assign comparisons to labels or provide a semantic evaluator for a concrete sorting algorithm.

### 4.2 Leaf capacity

**Lemma 4.1 (Binary leaf bound).** Every binary tree $t$ satisfies

$$
L(t)\leq 2^{H(t)}.
$$

**Proof sketch.** Proceed by structural induction. A leaf satisfies $1=2^0$. For a branch with subtrees $u$ and $v$, the induction hypotheses give

$$
L(u)+L(v)\leq2^{H(u)}+2^{H(v)}.
$$

If $m=\max\{H(u),H(v)\}$, then both powers are at most $2^m$, so the sum is at most $2^{m+1}$. Since the branch height is $m+1$, the claim follows. $\square$

### 4.3 Worst-case comparison lower bound

**Theorem 4.2 (Comparison-Tree Lower Bound).** If a binary comparison tree $t$ has sufficient transcript capacity for all orderings of $n$ distinct objects, then

$$
H(t)\geq\left\lceil\log_2(n!)\right\rceil.
$$

Equivalently, $H(t)$ is at least the least integer $h$ for which $n!\leq2^h$.

**Proof sketch.** Capacity and Lemma 4.1 yield

$$
n!\leq L(t)\leq2^{H(t)}.
$$

By the defining property of the ceiling binary logarithm, any integer exponent whose power of two reaches $n!$ is at least $\lceil\log_2(n!)\rceil$. $\square$

The theorem is a worst-case result. It does not determine the average depth under a probability distribution, nor does it claim that every leaf lies at the lower-bound depth.

## 5. Reversible sorting and history

### 5.1 Product-form reversible realizations

Let $A$ be a finite auxiliary state space. A product-form reversible realization of visible sorting is a bijection

$$
e:S_n\longrightarrow\{\star\}\times A.
$$

The first component is the visible sorted output. The second is history. Because the visible component has only one value, all information distinguishing input permutations must appear in the auxiliary component.

### 5.2 History lower bound

**Theorem 5.1 (Reversible History-Space Lower Bound).** If there exists a bijection

$$
e:S_n\longrightarrow\{\star\}\times A,
$$

then

$$
n!\leq|A|.
$$

Thus the auxiliary register requires information capacity at least $\log_2(n!)$ bits.

**Proof sketch.** Map each permutation $\sigma$ to the auxiliary component of $e(\sigma)$. This map from $S_n$ to $A$ is injective. Indeed, if two permutations have the same auxiliary component, their visible components are automatically equal because both are $\star$; hence their complete output pairs agree. Injectivity of the bijection then forces the permutations to agree. An injection from a finite set of size $n!$ into $A$ implies $n!\leq|A|$. $\square$

A direct cardinality argument gives equality whenever $e$ is onto the entire product: $|S_n|=|\{\star\}\times A|=|A|$. The lower-bound formulation is useful because it emphasizes the unavoidable capacity needed to distinguish inputs, and remains valid when auxiliary spaces contain unreachable or reserved states in a broader implementation model.

### 5.3 Explicit reversible realization

**Theorem 5.2 (Reversible Sorting Construction).** For every $n\geq0$, there is a reversible transformation

$$
r_n:S_n\longrightarrow\{\star\}\times S_n,
\qquad
r_n(\sigma)=(\star,\sigma).
$$

Its visible component agrees with $s_n$, while its complete information erasure and Landauer gap are both zero.

**Proof sketch.** The inverse map discards the fixed symbol $\star$ and returns the second component. Thus $r_n$ is a bijection. Its first component is $\star=s_n(\sigma)$ for every input. By Theorem 2.1, every bijection erases zero information, so $I(r_n)=0$ and $W(r_n;kT)=0$. $\square$

The construction attains the history lower bound exactly, because its auxiliary space has $|S_n|=n!$ states. It is conceptually simple rather than memory-efficient in a bit-level representation: it stores the entire input permutation. Any compressed lossless encoding must still distinguish $n!$ possibilities.

## 6. A three-way factorial principle

The preceding results combine into a single synthesis.

**Theorem 6.1 (Factorial Resource Principle).** Let $t$ be a binary comparison tree with at least $n!$ leaves, and let a product-form reversible sorting realization use auxiliary space $A$. Then simultaneously

$$
\left\lceil\log_2(n!)\right\rceil\leq H(t),
$$

$$
I(s_n)=\log_2(n!),
$$

and

$$
n!\leq|A|.
$$

**Proof sketch.** The first conclusion is Theorem 4.2, the second is Theorem 3.1, and the third is Theorem 5.1. $\square$

The common source is cardinality. The input permutation space has $n!$ elements. A binary transcript of depth $h$ offers at most $2^h$ possibilities. A constant visible map merges all $n!$ inputs into one output. A reversible realization must relocate all $n!$ distinctions into history. The same factorial therefore controls three resources, but the resources have different meanings:

- $H(t)$ measures worst-case binary decision depth;
- $I(s_n)$ measures state-space contraction of a visible function;
- $|A|$ measures the number of distinguishable retained histories.

## 7. Redundant comparisons and thermodynamic invariance

### 7.1 Padding a tree

Define the padding operation $P_r(t)$ recursively by

$$
P_0(t)=t
$$

and

$$
P_{r+1}(t)=\mathrm{branch}(P_r(t),P_r(t)).
$$

Operationally, each padding level performs a redundant binary test whose two outcomes continue into identical copies of the same remaining computation.

**Lemma 7.1 (Padding height).** For every $r\geq0$,

$$
H(P_r(t))=r+H(t).
$$

**Proof sketch.** Induct on $r$. The base case is immediate. At the next stage, both child subtrees have height $H(P_r(t))$, so the new root adds exactly one. $\square$

**Lemma 7.2 (Padding preserves transcript capacity).** For every $r\geq0$,

$$
L(t)\leq L(P_r(t)).
$$

**Proof sketch.** Again induct on $r$. Each added branch duplicates the padded subtree, so its leaf count is doubled and in particular cannot decrease. $\square$

### 7.2 Arbitrarily many irrelevant comparisons

**Theorem 7.3 (Redundant Comparison Theorem).** If $t$ has sufficient transcript capacity for sorting $n$ objects, then $P_r(t)$ also has sufficient capacity, and

$$
H(P_r(t))=H(t)+r.
$$

**Proof sketch.** Capacity follows from $n!\leq L(t)\leq L(P_r(t))$. The height identity is Lemma 7.1. $\square$

The padded tree need not be an efficient algorithm. Its purpose is structural: it separates path length from the semantics of the visible map.

### 7.3 Landauer invariance under padding

**Theorem 7.4 (Padding Changes Comparisons, Not Logical Work).** Suppose a tree has sufficient transcript capacity for $n$-item sorting. For any $r\geq0$, padding increases its height by $r$ while the visible sorting map continues to erase $\log_2(n!)$ bits and retains Landauer scale

$$
W=kT\ln(n!).
$$

**Proof sketch.** Theorem 7.3 gives the altered tree height. Padding changes only the chosen decision process; it does not change the visible map $s_n:S_n\to\{\star\}$. Since information erasure and Landauer work were defined from the domain and image of that map, both remain unchanged. $\square$

This theorem rules out any universal identification of raw comparison count with logical erasure. If each comparison necessarily contributed one independent erased bit, adding $r$ redundant comparisons would increase erased information by $r$. It does not. A physical comparison device may dissipate energy for implementation-specific reasons, and resetting a comparison record can incur a Landauer cost, but those conclusions require an operational model of records and resets.

## 8. Algorithms and numerical evaluation

The principal quantities can be evaluated without enumerating permutations. Direct computation of $n!$ is exact but grows rapidly. For numerical work, the logarithm is preferably accumulated as

$$
\ln(n!)=\sum_{j=1}^{n}\ln j.
$$

Then

$$
\log_2(n!)=\frac{\ln(n!)}{\ln2}.
$$

The exact comparison lower bound is the least integer $h$ satisfying $2^h\geq n!$. It can be obtained as the bit length of $n!-1$ for $n!>1$. These calculations take $O(n)$ arithmetic multiplications for the exact factorial or $O(n)$ floating-point logarithm evaluations for the log-sum method. The exact integer contains $\Theta(n\log n)$ bits, so bit complexity is higher than the unit-cost count.

For illustration:

| $n$ | $n!$ | $\log_2(n!)$ | Minimum worst-case comparisons |
|---:|---:|---:|---:|
| $0$ | $1$ | $0$ | $0$ |
| $3$ | $6$ | $2.585$ | $3$ |
| $5$ | $120$ | $6.907$ | $7$ |
| $10$ | $3{,}628{,}800$ | $21.791$ | $22$ |
| $20$ | $2{,}432{,}902{,}008{,}176{,}640{,}000$ | $61.077$ | $62$ |

At $T=300\,\mathrm{K}$, using $k=1.380649\times10^{-23}\,\mathrm{J/K}$, the irreversible scale is

$$
W_n=kT\ln(n!).
$$

The reversible construction has logical gap $0$ but requires $n!$ history states. These two columns should not be added as if they were identical resources: one is a work scale for erasure, and the other is storage capacity for avoiding erasure.

## 9. Applications and interpretation

### 9.1 Algorithm design

The comparison lower bound explains why comparison sorting cannot have worst-case complexity asymptotically below $n\log n$. Yet it says nothing about constant factors, memory access, stability, adaptivity, or non-comparison methods. Counting sort and radix sort exploit structure beyond binary comparisons and therefore live outside this model.

### 9.2 Reversible computing

A reversible computer must preserve enough information to invert each operation or must uncompute temporary data before resetting storage. The sorting construction illustrates the simplest option: retain the entire input order. More refined reversible algorithms can retain intermediate decisions and later uncompute some of them. Whatever encoding is chosen, the final state must still distinguish $n!$ inputs unless those distinctions are exported or erased.

### 9.3 Data pipelines

The same reasoning applies whenever a pipeline maps many records to one summary. Aggregation, deduplication, canonicalization, lossy compression, and deletion can all contract a logical state space. Merely rearranging or reversibly encoding records need not do so. The relevant quantity is the cardinality or probability structure of the distinctions that are no longer recoverable from the complete final state.

### 9.4 Physical interpretation

Landauer's principle concerns logically irreversible operations embedded in physical processes. The present finite-state model isolates the logical contribution. It does not specify a protocol that attains the bound, and it does not imply that a reversible implementation consumes no energy in practice. Zero Landauer gap means only that no positive lower bound arises from logical state merging in the complete map. Real reversible devices still face finite-time, control, noise, and fabrication costs.

## 10. Limitations

First, transcript capacity is weaker than semantic correctness. A tree with $n!$ leaves has enough outcomes in principle, but a complete model should define which pair is compared at each node, evaluate the tree on each permutation, and prove that every output is sorted.

Second, the information measure is cardinality-based rather than distributional. If input permutations are nonuniform, Shannon entropy is the natural average-case quantity. The worst-case number $\log_2(n!)$ remains a capacity measure, but expected decision depth can depend on the distribution.

Third, the model assumes distinct items. Repeated keys reduce the number of distinguishable arrangements. With multiplicities $m_1,\dots,m_q$ summing to $n$, the expected state count is the multinomial coefficient

$$
\frac{n!}{\prod_{i=1}^{q}m_i!}.
$$

Fourth, the history theorem treats outputs as a visible singleton paired with an auxiliary space. More detailed circuit models may distribute information across ancillas, correlations, control systems, and environments.

Finally, comparison count is not an energy model. The padding theorem proves that no such model can be inferred from count alone. A physical account must identify the states being reset and the protocol used to reset them.

## 11. Future work

A semantic comparison-tree evaluator would strengthen the capacity formulation into a full correctness theorem. Repeated keys invite a multinomial extension of all three factorial results. Probability distributions would permit an average-depth lower bound based on Shannon entropy. Gate-level reversible circuits could distinguish retained history, uncomputation, and deliberate reset. Explicit Stirling inequalities would turn $kT\ln(n!)$ into quantitative bounds of the form $kT(n\ln n-n+O(\ln n))$. Finally, a general invariance theory for semantics-preserving program transformations could clarify which changes affect execution cost and which leave logical erasure unchanged.

## 12. Conclusion

Sorting brings three notions into close numerical alignment without making them identical. The $n!$ possible input permutations force a binary comparison tree to have height at least $\lceil\log_2(n!)\rceil$. Collapsing those permutations to one visible result erases exactly $\log_2(n!)$ bits and carries Landauer scale $kT\ln(n!)$. Avoiding that erasure through a reversible product-form implementation requires at least $n!$ history states, and retaining the entire permutation realizes the bound with zero logical gap.

Redundant padding then supplies the decisive distinction: comparison depth may be increased arbitrarily while erased information remains fixed. Thermodynamic work is governed by which logical distinctions are ultimately destroyed, not simply by how many comparisons were executed. The factorial is the shared invariant; decision depth, erased information, and reversible history are the separate resources it constrains.
