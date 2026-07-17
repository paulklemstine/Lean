# Finite Assemblies for Record-Composition Weights of Alternating Permutations

**Aristotle**  
**17 July 2026**

## Abstract

Let $E_m$ be the Euler zigzag number, defined as the number of down-up permutations on $m$ letters. For a composition $\alpha=(\alpha_1,\ldots,\alpha_\ell)$ and partial sums $s_j=\alpha_1+\cdots+\alpha_j$, consider the record-composition weight

$$
W(\alpha)=\prod_{j=1}^{\ell}
\binom{2s_j-1}{2\alpha_j-1}E_{2\alpha_j-1}.
$$

We develop a self-contained finite assembly whose objects are built block by block from a label choice and an odd down-up permutation. The assembly cardinality is exactly $W(\alpha)$. A shifted version $W_s$ exposes the state carried between blocks and yields a concatenation law, a final-block recurrence, and a factorization of assembly cardinalities. We also obtain the singleton identity $W((n))=E_{2n-1}$ and the first multiblock value $W((1,1))=3$. The construction isolates the multiplicative mechanism expected in the enumeration of even alternating permutations by record composition. We distinguish this established finite product mechanism from the additional bijection required to identify assemblies with the original record classes, and we outline the consequent directions toward record partitions and noncommutative symmetric functions.

## 1. Introduction

Alternating permutations are among the classical objects of enumerative combinatorics. A **down-up permutation** of $m$ letters is a permutation $p=p_1p_2\cdots p_m$ satisfying

$$
p_1>p_2<p_3>p_4<\cdots.
$$

Their numbers are the Euler zigzag numbers $E_m$. These numbers admit many descriptions, including generating-function and recurrence formulations, but the permutation interpretation is the one needed here.

For a down-up permutation of even length $2n$, the entries in odd positions,

$$
p_1,p_3,\ldots,p_{2n-1},
$$

form its peak word. An entry of a word is a **left-to-right maximum** if it is larger than every preceding entry. Cutting the peak word immediately before each left-to-right maximum other than the first produces an ordered sequence of nonempty factors. Their lengths sum to $n$ and therefore form a composition of $n$, called the **record composition**.

The order of these factor lengths matters. A composition $(1,2)$ records a different history from $(2,1)$, even though both become the same partition after order is forgotten. This ordered statistic motivates the coefficient

$$
\prod_{j=1}^{\ell}
\binom{2s_j-1}{2\alpha_j-1}E_{2\alpha_j-1},
\qquad
s_j=\alpha_1+\cdots+\alpha_j.
$$

The factor indexed by $j$ consists of a binomial label-selection term and an odd Euler number. The partial sum $s_j$ couples the current factor to all previous factors.

The purpose of this paper is to isolate and prove the exact finite-cardinality mechanism behind this product. We define an assembly in which each block stores precisely two pieces of data: a selection index among subsets of the required size and an internal down-up permutation. The continuation begins with an updated state equal to the previous state plus the current part. This recursive construction has the product formula as its cardinality.

The results established here are:

1. the cardinality of every shifted assembly is the corresponding recursive product;
2. specialization at shift zero gives the record-composition weight;
3. concatenating two compositions factors the weight, with the suffix shifted by the sum of the prefix;
4. appending a final part yields an explicit recurrence;
5. a one-part composition has weight $E_{2n-1}$;
6. $W((1,1))=3$; and
7. the assembly cardinality itself factors across every composition cut.

The construction is self-contained. It does not assume a bijection between these assemblies and alternating permutations of length $2n$ with fixed record composition. Constructing that bijection is the principal next enumerative step. Keeping this boundary explicit clarifies precisely which part of the record-composition formula is settled by the assembly model and which part concerns the encoding of the original permutations.

## 2. Alternating permutations and compositions

### 2.1. Down-up permutations

Let $[m]=\{1,2,\ldots,m\}$. A permutation $p$ of $[m]$ is **down-up** if, for each adjacent pair, the comparison alternates beginning with a descent. Equivalently, for every index $i$ with $1\le i<m$,

$$
p_i>p_{i+1}\quad\text{when $i$ is odd},
$$

and

$$
p_i<p_{i+1}\quad\text{when $i$ is even}.
$$

**Definition 2.1 (Euler zigzag number).** The Euler zigzag number $E_m$ is the cardinality of the set of down-up permutations of $[m]$.

Relabeling any $m$ distinct totally ordered symbols by their ranks gives a canonical correspondence with permutations of $[m]$. Thus $E_m$ also counts down-up orderings of any fixed set of $m$ distinct labels.

For $m=1$, there is one permutation and no adjacent inequality to check, so

$$
E_1=1.
$$

### 2.2. Compositions and partial sums

A **composition** of $n$ is a finite ordered tuple

$$
\alpha=(\alpha_1,\ldots,\alpha_\ell)
$$

of positive integers with sum $n$. We write

$$
|\alpha|=\alpha_1+\cdots+\alpha_\ell
$$

and define its partial sums by

$$
s_j=\alpha_1+\cdots+\alpha_j.
$$

For recursive statements it is convenient to permit finite lists of nonnegative integers as well. All intended record compositions have positive parts. The empty list $\varnothing$ has sum $0$.

If $\alpha$ and $\beta$ are lists, their concatenation is denoted $\alpha\mathbin{\|}\beta$. The singleton list with part $a$ is denoted $(a)$.

### 2.3. Record compositions

Let $p=p_1p_2\cdots p_{2n}$ be down-up. Its **peak word** is

$$
P(p)=p_1p_3\cdots p_{2n-1}.
$$

An entry $x_i$ in a word $x_1x_2\cdots x_n$ is a left-to-right maximum if $x_i>x_k$ for all $k<i$. The first entry is automatically a left-to-right maximum.

**Definition 2.2 (Record composition).** Cut $P(p)$ immediately before every left-to-right maximum other than its first entry. The ordered list of factor lengths is the record composition of $p$.

For instance, a peak word with relative values

$$
5,2,7,4,9,8
$$

has records $5$, $7$, and $9$, hence factors

$$
(5,2)\mid(7,4)\mid(9,8)
$$

and record composition $(2,2,2)$.

This definition provides the motivation for the weights below. The finite assembly developed in Section 3 is an abstract block model for their product structure.

## 3. Shifted record weights and finite assemblies

### 3.1. The shifted product

The state variable $s$ records the sum of parts processed before the current list.

**Definition 3.1 (Shifted record weight).** For $s\ge 0$, define $W_s$ recursively by

$$
W_s(\varnothing)=1,
$$

and, for a list beginning with $a$ and followed by $\alpha$,

$$
W_s((a)\mathbin{\|}\alpha)
=
\binom{2(s+a)-1}{2a-1}E_{2a-1}
W_{s+a}(\alpha).
$$

The unshifted weight is

$$
W(\alpha)=W_0(\alpha).
$$

Iterating the recursion gives the closed expression

$$
W_s(\alpha)=
\prod_{j=1}^{\ell}
\binom{2(s+s_j)-1}{2\alpha_j-1}E_{2\alpha_j-1}.
$$

At $s=0$ this becomes

$$
W(\alpha)=
\prod_{j=1}^{\ell}
\binom{2s_j-1}{2\alpha_j-1}E_{2\alpha_j-1}.
$$

When the parts are positive, every lower binomial argument is between $0$ and its upper argument. The standard convention $\binom{N}{K}=0$ for $K>N$ also extends the formulas to boundary cases.

### 3.2. Assembly objects

We now define a finite family whose cardinality is $W_s(\alpha)$.

**Definition 3.2 (Shifted record assembly).** The family $\mathcal A_s(\alpha)$ is defined recursively.

* For the empty list, $\mathcal A_s(\varnothing)$ contains one empty assembly.
* If $\alpha=(a)\mathbin{\|}\beta$, an element of $\mathcal A_s(\alpha)$ is a triple $(c,q,r)$, where:
  1. $c$ is one of the $\binom{2(s+a)-1}{2a-1}$ possible choices of a $(2a-1)$-element subset of a $(2(s+a)-1)$-element set;
  2. $q$ is a down-up permutation of $2a-1$ letters; and
  3. $r$ is an element of $\mathcal A_{s+a}(\beta)$.

The particular ground set used for $c$ is irrelevant to cardinality; one may use $[2(s+a)-1]$. Once a subset is chosen, its increasing rank order identifies its down-up orderings with down-up permutations of $[2a-1]$.

The definition deliberately separates label allocation from internal order. The first has binomial cardinality, the second has Euler cardinality, and the third contains all future blocks.

## 4. Cardinality theorem

**Theorem 4.1 (Assembly Product Theorem).** For every $s\ge 0$ and every finite list $\alpha$ of nonnegative integers,

$$
|\mathcal A_s(\alpha)|=W_s(\alpha).
$$

Equivalently, if $\alpha=(\alpha_1,\ldots,\alpha_\ell)$ and $s_j=\alpha_1+\cdots+\alpha_j$, then

$$
|\mathcal A_s(\alpha)|
=
\prod_{j=1}^{\ell}
\binom{2(s+s_j)-1}{2\alpha_j-1}E_{2\alpha_j-1}.
$$

**Proof sketch.** Proceed by induction on the number of parts. The empty assembly family is a singleton, agreeing with the empty product $1$. Suppose $\alpha=(a)\mathbin{\|}\beta$. By Definition 3.2, its assembly family is a Cartesian product of a set with

$$
\binom{2(s+a)-1}{2a-1}
$$

elements, the set of down-up permutations on $2a-1$ letters with $E_{2a-1}$ elements, and $\mathcal A_{s+a}(\beta)$. Therefore

$$
|\mathcal A_s((a)\mathbin{\|}\beta)|
=
\binom{2(s+a)-1}{2a-1}E_{2a-1}
|\mathcal A_{s+a}(\beta)|.
$$

Apply the induction hypothesis to the final factor. The result is exactly the defining recursion for $W_s$. Iteration gives the closed product. $\square$

**Corollary 4.2 (Unshifted Product Formula).** For every finite list $\alpha$,

$$
|\mathcal A_0(\alpha)|=W(\alpha)
=
\prod_{j=1}^{\ell}
\binom{2s_j-1}{2\alpha_j-1}E_{2\alpha_j-1}.
$$

**Proof sketch.** Set $s=0$ in Theorem 4.1. $\square$

Theorem 4.1 explains each factor independently. The binomial coefficient chooses the labels assigned to a block, while the Euler number chooses its alternating internal order. The shift is the only information transmitted to the remaining blocks.

## 5. Factorization across composition cuts

### 5.1. Shifted concatenation

**Theorem 5.1 (Concatenation Factorization).** For all $s\ge 0$ and all finite lists $\alpha$ and $\beta$,

$$
W_s(\alpha\mathbin{\|}\beta)
=
W_s(\alpha)W_{s+|\alpha|}(\beta).
$$

**Proof sketch.** Induct on $\alpha$. If $\alpha$ is empty, then $W_s(\alpha)=1$, $|\alpha|=0$, and the assertion is immediate. For $\alpha=(a)\mathbin{\|}\gamma$, unfold the first block:

$$
W_s((a)\mathbin{\|}\gamma\mathbin{\|}\beta)
=
\binom{2(s+a)-1}{2a-1}E_{2a-1}
W_{s+a}(\gamma\mathbin{\|}\beta).
$$

Apply the induction hypothesis to the remaining concatenation. Since

$$
(s+a)+|\gamma|=s+|(a)\mathbin{\|}\gamma|,
$$

the continuation has the required shift. Regrouping the first factors gives the theorem. $\square$

**Corollary 5.2 (Unshifted Concatenation).** For all $\alpha$ and $\beta$,

$$
W(\alpha\mathbin{\|}\beta)
=
W(\alpha)W_{|\alpha|}(\beta).
$$

The shift prevents ordinary multiplicativity. In general, $W(\alpha\mathbin{\|}\beta)$ is not $W(\alpha)W(\beta)$ because the available pool at the beginning of $\beta$ depends on the size of $\alpha$.

### 5.2. Cardinality factorization

**Theorem 5.3 (Assembly Cut Theorem).** For all finite lists $\alpha$ and $\beta$,

$$
|\mathcal A_0(\alpha\mathbin{\|}\beta)|
=
|\mathcal A_0(\alpha)|W_{|\alpha|}(\beta).
$$

**Proof sketch.** Apply Corollary 4.2 to the concatenated list, use Corollary 5.2 to split its weight, and apply Corollary 4.2 again to the prefix. $\square$

The theorem gives a precise stateful factorization: after the prefix has been assembled, only its total size is needed to count suffix completions.

### 5.3. Final-block recurrence

**Theorem 5.4 (Last-Block Recurrence).** For every list $\alpha$ and every $a\ge 0$,

$$
W(\alpha\mathbin{\|}(a))
=
W(\alpha)
\binom{2(|\alpha|+a)-1}{2a-1}E_{2a-1}.
$$

**Proof sketch.** Apply Corollary 5.2 with $\beta=(a)$. The shifted weight of the singleton has one block and hence is exactly the displayed binomial-Euler factor. $\square$

This recurrence is useful computationally. If $W(\alpha)$ and $|\alpha|$ are known, appending a part requires one binomial evaluation, one Euler-number lookup, and two multiplications.

## 6. Consequences and examples

**Theorem 6.1 (Singleton Reduction).** For every $n\ge 0$,

$$
W((n))=E_{2n-1},
$$

with the natural binomial convention at the boundary. In particular, for every positive $n$ the statement has its ordinary combinatorial meaning.

**Proof sketch.** The product has one factor, and

$$
\binom{2n-1}{2n-1}=1.
$$

Thus the label-selection step is forced and only the internal down-up permutation remains. $\square$

**Lemma 6.2 (One-Letter Zigzag).**

$$
E_1=1.
$$

**Proof sketch.** The sole permutation of one letter has no adjacent pair and therefore satisfies the alternating inequalities vacuously. $\square$

**Theorem 6.3 (First Multiblock Value).**

$$
W((1,1))=3.
$$

**Proof sketch.** The partial sums are $1$ and $2$. Using Lemma 6.2,

$$
W((1,1))
=
\binom{1}{1}E_1
\binom{3}{1}E_1
=1\cdot1\cdot3\cdot1=3.
$$

$\square$

The order dependence appears at total size $3$. Since $E_3=2$,

$$
W((1,2))
=
\binom{1}{1}E_1
\binom{5}{3}E_3
=20,
$$

while

$$
W((2,1))
=
\binom{3}{3}E_3
\binom{5}{1}E_1
=10.
$$

Thus the weight is genuinely indexed by compositions, not merely by their underlying partitions.

For another illustration,

$$
W((3))=E_5=16.
$$

The composition $(1,1,1)$ gives

$$
W((1,1,1))
=
\binom{1}{1}\binom{3}{1}\binom{5}{1}=15,
$$

because every Euler factor is $E_1=1$. These values can be generated without listing assemblies explicitly.

## 7. Algorithms

### 7.1. Computing Euler zigzag numbers

For numerical work, Euler zigzag numbers may be computed through the Entringer triangle. Define $T(0,0)=1$. If row $n-1$ is known, form row $n$ by setting $T(n,0)=0$ and

$$
T(n,k)=T(n,k-1)+T(n-1,n-k)
$$

for $1\le k\le n$. Then

$$
E_n=T(n,n).
$$

Computing all values through $E_m$ takes $O(m^2)$ integer additions and $O(m)$ memory if only the previous row is retained. The integers grow quickly, so bit complexity also depends on output size.

### 7.2. Computing a shifted weight

Given $s$ and $\alpha=(\alpha_1,\ldots,\alpha_\ell)$, initialize $r=1$ and $u=s$. For each part $a$ in order, update

$$
r\leftarrow r
\binom{2(u+a)-1}{2a-1}E_{2a-1},
\qquad
u\leftarrow u+a.
$$

At termination, $r=W_s(\alpha)$. With precomputed Euler values and a standard multiplicative binomial routine, the algorithm uses $\ell$ block updates. Its arithmetic operation count is linear in the number of parts apart from binomial evaluation; exact bit complexity scales with the large output integers.

### 7.3. Enumerating compositions

All compositions of $n$ can be generated recursively: either append a new part $1$ to a composition of $n-1$, or increase its final part by $1$. There are $2^{n-1}$ compositions for $n\ge1$, so exhaustive tabulation necessarily has exponential output size. The final-block recurrence allows each child weight to be derived from its parent with one local factor.

## 8. Relation to record enumeration

The finite assembly theorem establishes an exact combinatorial interpretation of the product $W(\alpha)$. To turn it into an enumeration theorem for alternating permutations with record composition $\alpha$, one must construct a bijection

$$
\left\{
\begin{array}{c}
\text{down-up permutations of $[2n]$}\\
\text{with record composition $\alpha$}
\end{array}
\right\}
\longleftrightarrow
\mathcal A_0(\alpha).
$$

Such a map must extract each record block from the odd-position word, identify the appropriate $2\alpha_j-1$ labels at stage $j$, and produce an internal odd down-up permutation. Its inverse must reconstruct the full even-length alternating permutation while preserving the record cuts. The product theorem proves that the proposed target family has the required cardinality; it does not by itself provide this extraction and reconstruction.

The distinction matters because the assembly’s local zigzags have lengths $2\alpha_j-1$, whereas the source permutation has length $2n$. A bijection must explain how the valleys and boundary data are distributed among blocks and why the record condition is exactly equivalent to the staged label constraints.

Once this bridge is built, one may forget the order of parts. If $\lambda$ is a partition of $n$, then its record-partition class should be obtained by summing $W(\alpha)$ over distinct rearrangements $\alpha$ of the parts of $\lambda$:

$$
W_{\mathrm{part}}(\lambda)
=
\sum_{\operatorname{sort}(\alpha)=\lambda}W(\alpha).
$$

The examples $W((1,2))=20$ and $W((2,1))=10$ show why this summation is nontrivial.

## 9. Noncommutative perspective

Compositions naturally index bases in noncommutative symmetric-function theory. Unlike partitions, compositions preserve order, and the factor

$$
\binom{2s_j-1}{2\alpha_j-1}
$$

depends on the position of $\alpha_j$ through the partial sum $s_j$. Consequently, permuting parts generally changes the coefficient.

The concatenation identity is compatible with this ordered viewpoint. It says that a coefficient attached to a word of parts factors when the word is cut, but the right factor is evaluated in a state shifted by the degree of the left word. This resembles a graded or state-dependent product more closely than ordinary commutative multiplicativity.

A complete algebraic development would introduce the relevant noncommutative power-sum basis and a lift of the sprout symmetric function associated with seed $\sec(\sqrt t)$. One would then prove that the coefficient indexed by $\alpha$ is $W(\alpha)$. The present assembly theorem supplies the candidate coefficient and its structural recurrences, but not that basis expansion.

## 10. Discussion

The main advantage of the assembly model is conceptual separation. Three ingredients play distinct roles:

1. **Local shape:** $E_{2a-1}$ counts alternating order within a block of size parameter $a$.
2. **Label allocation:** the binomial coefficient chooses which labels enter that block.
3. **State propagation:** the partial sum records how much has already been processed and determines the next pool size.

This separation makes the formula algorithmic and explains its factorization properties. It also makes order sensitivity unavoidable: changing the order of parts changes the successive states.

The model is finite at every stage and gives an explicit Cartesian-product decomposition. It therefore supports direct sampling as well as counting. To sample an assembly uniformly, independently choose a uniformly random subset index, a uniformly random down-up permutation for each block, and then continue recursively. Uniform sampling of the source record class would follow from a bijection preserving uniformity.

The shifted formulation is preferable to stating only the final product. Without $W_s$, the concatenation law appears to contain an awkward correction. With $W_s$, the correction is simply the correct initial state of the suffix. This is a standard dynamic-programming principle: a subproblem is reusable only when its boundary state is part of its definition.

## 11. Future work

The principal next step is to connect the finite assembly to the original permutation statistic. This requires defining alternating permutations on $2n$ symbols, extracting the odd-position word and its left-to-right maxima, and proving that the resulting record composition has positive parts summing to $n$.

The central combinatorial objective is a bijection between permutations with fixed positive composition $\alpha$ and $\mathcal A_0(\alpha)$. Such a bijection would transfer the established assembly product directly to the desired record-composition enumeration.

Further directions are:

1. prove the positivity and sum constraints of extracted record compositions;
2. construct the forgetful map from record compositions to record partitions and derive partition counts by summing over rearrangements;
3. develop the required fragment of noncommutative symmetric functions and identify $W(\alpha)$ as the coefficient of the lifted sprout symmetric function in an appropriate power-sum basis;
4. connect the permutation definition of $E_n$ with analytic and recurrence-based definitions, including the generating function for secant and tangent numbers; and
5. study efficient generation and random sampling of assemblies and, after a bijection is available, of alternating permutations conditioned on record composition.

## 12. Limitations of the present model

The assembly definition is designed to capture a cardinality mechanism, not yet the full geometry of a record decomposition. Its label-choice coordinate remembers how many labels are available and how many enter a block, while its alternating coordinate remembers only the relative order internal to that block. It does not presently specify how the even-position valleys of a length-$2n$ permutation are shared across adjacent peak blocks. That information must be supplied by the future bijection.

For the same reason, none of the product identities alone establishes a generating-function identity. A generating function requires a choice of grading, normalization, and algebraic basis, followed by a coefficient comparison. The order sensitivity shown above is evidence for a composition-indexed noncommutative basis, but it is not a substitute for that construction.

Finally, exhaustive numerical tables should be interpreted as illustrations of the proved product, not as proofs of a correspondence with the source permutation classes. The assembly theorem is exact for its stated finite family. Transferring it to another family requires a cardinality-preserving map or an independent enumeration argument.

## 13. Conclusion

The record-composition product has a direct finite architecture. A block of size parameter $a$ contributes

$$
\binom{2(s+a)-1}{2a-1}E_{2a-1},
$$

where $s$ is the sum of preceding parts. Multiplication over blocks gives the cardinality of a recursively defined assembly. The same recursion yields concatenation factorization, the last-block recurrence, singleton reduction, and concrete small values.

The product mechanism is therefore completely explained at the assembly level: labels are selected, odd zigzags are chosen, and the cumulative size is passed forward. The remaining challenge is structural rather than numerical—to prove that the record blocks of an even alternating permutation encode exactly these assembly data. That bridge would place the finite product, record partitions, and noncommutative symmetric functions into a single enumerative theory.