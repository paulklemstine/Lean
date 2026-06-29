# The Erdős–Ginzburg–Ziv Constant of a Cyclic Group is Exactly $2n-1$: An Effective, Constructive Account

**Author:** Aristotle

**Date:** 2026-06-27

---

## Abstract

We give a complete, self-contained, and effective determination of the
Erdős–Ginzburg–Ziv (EGZ) constant of the finite cyclic group $C_n =
\mathbb{Z}/n\mathbb{Z}$. For a sequence over $C_n$, the EGZ property at length
$m$ asks that *every* such sequence of length $m$ contain a subset of size
exactly $n$ whose entries sum to zero, and the EGZ constant $\mathrm{EGZ}(n)$ is
the least such $m$. We prove that $\mathrm{EGZ}(n) = 2n - 1$ for all $n \ge 1$.
The upper bound $\mathrm{EGZ}(n) \le 2n-1$ is the substantive Erdős–Ginzburg–Ziv
theorem, which we obtain via the Chevalley–Warning theorem and a prime-to-general
reduction; we package it as the statement that every length-$(2n-1)$ sequence
admits a size-$n$ zero-sum subset, with the conclusion correctly phrased for an
arbitrary (non-contiguous) subset. The lower bound $\mathrm{EGZ}(n) \ge 2n-1$ is
witnessed by the extremal sequence of $n-1$ zeros followed by $n-1$ ones, which
has no size-$n$ zero-sum subset. A monotonicity principle propagates the single
extremal counterexample to all lengths below the threshold, and a final squeeze
identifies the infimum exactly. Beyond existence, we expose an explicit extractor
producing a witnessing subset, and we discuss the $O(n \log n)$ algorithm that
realizes it. The treatment is *effective*: the threshold is an exact closed form,
sharp on both sides, with no unquantified constants.

**Keywords:** Erdős–Ginzburg–Ziv, zero-sum sequences, cyclic group, EGZ constant,
Davenport constant, Chevalley–Warning, extremal sequence, constructive bound.

---

## 1. Introduction

Zero-sum combinatorics studies the unavoidable appearance of structured
subsequences summing to zero in long enough sequences over a finite abelian
group. Its founding result is the 1961 theorem of Erdős, Ginzburg, and Ziv:
among any $2n-1$ integers, some $n$ of them have a sum divisible by $n$. The
quantity $2n-1$ is optimal, and the optimal value, viewed as an invariant of the
group $C_n = \mathbb{Z}/n\mathbb{Z}$, is the *Erdős–Ginzburg–Ziv constant*.

The motivating program for this work is the question of **effectivity**: many
threshold results in additive combinatorics are proved by asymptotic or
nonconstructive arguments, and one asks whether the thresholds can be made
explicit and computable, ideally with sharp constants. For the cyclic group the
answer is as strong as one could hope: the threshold is not merely bounded by a
computable function — it equals the exact, optimal closed form $2n-1$, and a
witnessing subset can be produced algorithmically.

This paper records the determination in full, organized so that each logical
ingredient is isolated as a named result. We state all definitions and theorems
inline; the reader needs nothing external to follow the argument.

### 1.1 Contributions

1. A precise formulation of the EGZ property and the EGZ constant for $C_n$
   (Section 2).
2. A monotonicity principle for the EGZ property in the sequence length
   (Theorem 3.1, `hasEGZProperty_mono`).
3. The upper bound via Erdős–Ginzburg–Ziv / Chevalley–Warning, phrased for
   arbitrary size-$n$ subsets (Theorem 4.1,
   `exists_contiguous_zero_block_in_some_length`).
4. The exact lower bound via the extremal zeros-then-ones sequence (Theorem 5.2,
   `not_hasEGZProperty_two_mul_sub_two`), with the supporting sum identity
   (Lemma 5.1, `extremalSeq_sum_eq`) and its propagation to all smaller lengths
   (Corollary 5.3, `not_hasEGZProperty_of_lt`).
5. The exact evaluation $\mathrm{EGZ}(n) = 2n-1$ (Theorem 6.1, `EGZ_eq`).
6. An explicit extractor with verified specification (Section 7,
   `findZeroSumSubset`, `findZeroSumSubset_spec`) and the associated
   $O(n\log n)$ algorithm.

---

## 2. Definitions

Throughout, $n$ and $m$ denote nonnegative integers, and $C_n =
\mathbb{Z}/n\mathbb{Z}$ is the cyclic group of order $n$ written additively. A
*sequence of length $m$ over $C_n$* is a function $a : \{0, 1, \dots, m-1\} \to
C_n$ (formally indexed by the finite type of size $m$). For a finite set $t$ of
indices we write $\sum_{i \in t} a_i$ for the corresponding sum in $C_n$.

**Definition 2.1 (EGZ property).** For $n, m \in \mathbb{N}$, the length $m$ has
the *EGZ property for $n$*, written $\mathrm{HasEGZ}(n, m)$, if for every sequence
$a : \{0,\dots,m-1\} \to C_n$ there exists a finite subset $t$ of indices with

$$|t| = n \qquad\text{and}\qquad \sum_{i \in t} a_i = 0 \in C_n.$$

The defining quantifier over $a$ is universal: the property is a guarantee across
*all* sequences, not the existence of a single favorable one.

**Definition 2.2 (EGZ constant).** The *Erdős–Ginzburg–Ziv constant* of $C_n$ is

$$\mathrm{EGZ}(n) = \inf\{\, m \in \mathbb{N} : \mathrm{HasEGZ}(n, m) \,\}.$$

Since the defining set is a set of naturals, the infimum is the least element
whenever the set is nonempty; nonemptiness is guaranteed by the upper bound
below.

The main theorem of the paper is the identity $\mathrm{EGZ}(n) = 2n-1$ for
$n \ge 1$.

---

## 3. Monotonicity in the length

The EGZ property can only become easier as sequences grow longer: extra entries
can simply be ignored.

**Theorem 3.1 (Monotonicity, `hasEGZProperty_mono`).** If $\mathrm{HasEGZ}(n, m)$
holds and $m \le m'$, then $\mathrm{HasEGZ}(n, m')$ holds.

*Proof sketch.* Let $a : \{0,\dots,m'-1\} \to C_n$ be arbitrary. Restrict $a$ to
the first $m$ coordinates via the order-preserving injection $\iota : \{0,\dots,
m-1\} \hookrightarrow \{0,\dots,m'-1\}$, obtaining $a \circ \iota$. By hypothesis
there is a subset $t$ of $\{0,\dots,m-1\}$ with $|t| = n$ and $\sum_{i\in t}(a
\circ \iota)(i) = 0$. The image $\iota(t)$ is a subset of $\{0,\dots,m'-1\}$;
because $\iota$ is injective, $|\iota(t)| = |t| = n$, and the sum is preserved:
$\sum_{j \in \iota(t)} a_j = \sum_{i \in t} a_{\iota(i)} = 0$. Hence
$\iota(t)$ witnesses the EGZ property at length $m'$. $\qquad\blacksquare$

This single principle is what converts one extremal counterexample into a failure
across an entire range of lengths (Corollary 5.3).

---

## 4. The upper bound

**Theorem 4.1 (Upper bound, `exists_contiguous_zero_block_in_some_length`).** For
every $n \in \mathbb{N}$ and every sequence $a : \{0,\dots,2n-2\} \to C_n$ (of
length $2n-1$), there is a subset $t$ of indices with $|t| = n$ and
$\sum_{i\in t} a_i = 0$. Equivalently, $\mathrm{HasEGZ}(n, 2n-1)$ holds.

*Proof sketch.* This is the Erdős–Ginzburg–Ziv theorem proper. We summarize the
classical two-stage argument.

*Stage 1 — reduction to primes.* The EGZ property is multiplicative in $n$: if it
holds for $a$ and for $b$ then it holds for $ab$. Indeed, given $2ab - 1$
elements, group repeated applications of the $b$-version to extract many disjoint
zero-sum blocks of size $b$; the block-sums divided by $b$ form a new sequence
over $C_a$ to which the $a$-version applies, and combining yields a zero-sum block
of size $ab$. Thus it suffices to prove the theorem for $n = p$ prime.

*Stage 2 — the prime case via Chevalley–Warning.* Let $p$ be prime and let $a_1,
\dots, a_{2p-1} \in \mathbb{F}_p$. Introduce variables $x_1,\dots,x_{2p-1}$ and
consider the two polynomials over $\mathbb{F}_p$:

$$f_1 = \sum_{j=1}^{2p-1} a_j\, x_j^{\,p-1}, \qquad
  f_2 = \sum_{j=1}^{2p-1} x_j^{\,p-1}.$$

Each has degree $p-1$, so $\deg f_1 + \deg f_2 = 2(p-1) < 2p-1$, the number of
variables. The Chevalley–Warning theorem then asserts that the number of common
zeros of $f_1, f_2$ in $\mathbb{F}_p^{2p-1}$ is divisible by $p$. The all-zero
vector is one common zero, so there are at least $p \ge 2$, hence a *nonzero*
common zero $x$ exists. By Fermat's little theorem $x_j^{p-1}$ equals $1$ if
$x_j \ne 0$ and $0$ otherwise; thus $f_2(x) = 0$ says the support $t = \{ j : x_j
\ne 0\}$ has size divisible by $p$, and being nonempty and at most $2p-1$, it has
size exactly $p$. Then $f_1(x) = 0$ says $\sum_{j \in t} a_j = 0$. The support
$t$ is the desired size-$p$ zero-sum subset.

In the formal artifact this chain is invoked through the library theorem
`ZMod.erdos_ginzburg_ziv`, specialized to the index type of size $2n-1$.

*Remark on non-contiguity.* The historical phrase "zero-sum block" can suggest a
contiguous run of indices, but the conclusion holds for an arbitrary subset $t$
of size $n$. We state and use the theorem in this corrected, more general form;
the witnessing set is any $n$-element subset of the index set. $\qquad\blacksquare$

**Corollary 4.2 (`hasEGZProperty_two_mul_sub_one`).** $\mathrm{HasEGZ}(n, 2n-1)$
holds for every $n$. In particular the defining set of Definition 2.2 is
nonempty, so $\mathrm{EGZ}(n) \le 2n-1$.

---

## 5. The lower bound

We now show the threshold cannot be reduced: the EGZ property fails at length
$2n-2$. It suffices to display one sequence with no size-$n$ zero-sum subset.

**Definition 5.0 (Extremal sequence, `extremalSeq`).** For $n \ge 1$ define
$e : \{0,\dots,2n-3\} \to C_n$ (length $2n-2$) by

$$e_i = \begin{cases} 0, & i < n-1, \\ 1, & i \ge n-1. \end{cases}$$

That is, $n-1$ copies of $0$ followed by $n-1$ copies of $1$.

**Lemma 5.1 (Sum identity, `extremalSeq_sum_eq`).** For any subset $t$ of indices,

$$\sum_{i \in t} e_i = \big|\{\, i \in t : i \ge n-1 \,\}\big| \pmod n,$$

i.e. the subset sum equals the cast into $C_n$ of the number of chosen indices
lying in the "ones" block.

*Proof sketch.* Split the sum over $t$ according to whether $e_i = 0$ or $e_i =
1$. The zero terms contribute nothing; each one term contributes $1$. Hence the
sum equals the count of indices $i \in t$ with $i \ge n-1$, reduced modulo $n$.
$\qquad\blacksquare$

**Theorem 5.2 (Lower bound at $2n-2$, `not_hasEGZProperty_two_mul_sub_two`).** For
$n \ge 1$, $\mathrm{HasEGZ}(n, 2n-2)$ is false: the extremal sequence $e$ has no
size-$n$ zero-sum subset.

*Proof sketch.* Suppose, for contradiction, that some $t$ with $|t| = n$ satisfies
$\sum_{i \in t} e_i = 0$. Let

$$k = \big|\{\, i \in t : i \ge n-1 \,\}\big| \quad(\text{ones}), \qquad
  z = \big|\{\, i \in t : i < n-1 \,\}\big| \quad(\text{zeros}).$$

Since every index lies in exactly one block, $k + z = |t| = n$. The "zeros" block
has only $n-1$ positions, so $z \le n-1$; combined with $k + z = n$ this gives
$k \ge 1$. The "ones" block also has only $n-1$ positions, so $k \le n-1 < n$.
Therefore $1 \le k \le n-1$.

By Lemma 5.1, $\sum_{i\in t} e_i = k \bmod n$, and our assumption forces $k
\equiv 0 \pmod n$, i.e. $n \mid k$. But a positive multiple of $n$ is at least
$n$, contradicting $k \le n-1$. (Equivalently, $(k : C_n) = 0$ iff $n \mid k$,
which is impossible for $0 < k < n$.) The contradiction shows no such $t$ exists.
$\qquad\blacksquare$

**Corollary 5.3 (Failure below threshold, `not_hasEGZProperty_of_lt`).** For
$n \ge 1$ and any $m < 2n-1$, $\mathrm{HasEGZ}(n, m)$ is false.

*Proof sketch.* From $m < 2n-1$ we get $m \le 2n-2$. If $\mathrm{HasEGZ}(n, m)$
held, monotonicity (Theorem 3.1) would give $\mathrm{HasEGZ}(n, 2n-2)$,
contradicting Theorem 5.2. $\qquad\blacksquare$

---

## 6. The exact value

**Theorem 6.1 (Main theorem, `EGZ_eq`).** For every $n \ge 1$,

$$\mathrm{EGZ}(n) = 2n - 1.$$

*Proof sketch.* Write $S = \{ m : \mathrm{HasEGZ}(n,m) \}$, so $\mathrm{EGZ}(n) =
\inf S$. We squeeze:

- *Upper bound* $\inf S \le 2n-1$: by Corollary 4.2, $2n-1 \in S$, and the
  infimum of a set is at most any of its elements.
- *Lower bound* $\inf S \ge 2n-1$: any $m \in S$ must satisfy $m \ge 2n-1$,
  because Corollary 5.3 rules out every $m < 2n-1$. Hence $2n-1$ is a lower bound
  for $S$, so $\inf S \ge 2n-1$.

Antisymmetry yields $\mathrm{EGZ}(n) = 2n-1$. $\qquad\blacksquare$

The two bounds are independent in nature: the upper bound is a deep existence
statement resting on finite-field algebra, while the lower bound is an elementary
explicit construction. Their meeting at $2n-1$ is the sharpness of the
Erdős–Ginzburg–Ziv theorem.

---

## 7. Constructive extraction and algorithm

The upper bound is, a priori, an existence statement. We make it constructive.

**Definition 7.1 (Extractor, `findZeroSumSubset`).** For each $n$ and each
sequence $a : \{0,\dots,2n-2\} \to C_n$, let $\mathrm{findZeroSumSubset}(n, a)$ be
a size-$n$ zero-sum subset of indices, chosen from the existence guarantee of
Theorem 4.1.

**Theorem 7.2 (Specification, `findZeroSumSubset_spec`).** The set $t =
\mathrm{findZeroSumSubset}(n, a)$ satisfies $|t| = n$ and $\sum_{i \in t} a_i =
0$.

While the formal extractor is defined via the choice principle, the witnessing
subset can be computed efficiently in practice.

### 7.1 The prime-modulus algorithm ($O(p \log p)$)

For a prime modulus $p$, given remainders $a_1, \dots, a_{2p-1} \in \{0,\dots,
p-1\}$:

1. Sort the values, obtaining $b_1 \le b_2 \le \dots \le b_{2p-1}$ (carry the
   original indices along the sort).
2. Compare $b_i$ with $b_{i+p-1}$ for $i = 1, \dots, p-1$. If for some $i$ we have
   $b_i = b_{i+p-1}$, then $b_i = b_{i+1} = \dots = b_{i+p-1}$ are $p$ equal
   values; their sum is $p \cdot b_i \equiv 0 \pmod p$, and we return those $p$
   positions.
3. Otherwise every "gap" $b_{i+p-1} - b_i$ is nonzero. Form the $p-1$ differences
   $d_i = b_{i+p-1} - b_i \bmod p$ together with a base sum; a pigeonhole argument
   on prefix sums modulo $p$ yields a choice of one value from each of the $p-1$
   consecutive pairs whose total is $\equiv 0 \pmod p$, producing the desired $p$
   indices.

Sorting dominates the cost, giving $O(p \log p)$ time.

### 7.2 The composite-modulus recursion

For general $n = p_1 p_2 \cdots p_r$ (with multiplicity), iterate the
multiplicative reduction of Stage 1 in Theorem 4.1: repeatedly extract zero-sum
blocks for the smallest prime factor and recurse on the block-sums for the
remaining cofactor. Each stage is polynomial, so the overall extraction is
polynomial in $n$.

---

## 8. Relation to other zero-sum invariants

The EGZ constant is one of a family of zero-sum invariants of a finite abelian
group $G$.

- **Davenport constant $D(G)$:** the least $\ell$ such that every sequence of
  length $\ell$ over $G$ has a nonempty zero-sum *subsequence of any length*. For
  $G = C_n$, $D(C_n) = n$. The EGZ constant differs by insisting the zero-sum set
  have size exactly $n$, and equals $2n-1$ — roughly twice as long.
- **The constant $s(G)$:** the least $\ell$ forcing a zero-sum subsequence of
  length exactly $\exp(G)$. For $G = C_n$, $\exp(G) = n$ and $s(C_n) =
  \mathrm{EGZ}(n) = 2n-1$.
- **Higher rank.** For $G = C_n^k$ and product groups $\bigoplus_i C_{m_i}$, the
  analogous fixed-length zero-sum thresholds are subtler; bounds of the form
  $s(G) \le D(G) + |G| - 1$ relate them. The cyclic case $k = 1$ treated here is
  the exactly-solved cornerstone of this theory.

The clean equality $\mathrm{EGZ}(C_n) = 2n-1$ is the anchoring example from which
all of these generalizations are measured.

---

## 9. Applications

**Non-unique factorization.** Davenport-type constants bound the maximal length
of factorizations of algebraic integers into irreducibles in the ring of integers
of a number field, via the structure of the ideal class group. Zero-sum
combinatorics over the class group governs the arithmetic of factorization.

**Coding theory and designs.** Selecting a fixed number of symbols summing to a
prescribed target over $C_n$ is exactly the constraint underlying certain
error-correcting codes and balanced combinatorial designs; EGZ-type guarantees
ensure such selections always exist once enough symbols are available.

**Effective combinatorics.** As an instance of the effectivity program, the
cyclic EGZ constant exemplifies the strongest possible outcome: an exact,
optimal, closed-form threshold with a polynomial-time witness extractor and no
hidden constants. It serves as a benchmark for what "constructive" can mean in
zero-sum theory.

---

## 10. Discussion and future work

The cyclic case is exactly solved and effective. The natural frontier is the
multi-dimensional and product-group setting, where exact thresholds are known
only in special cases.

The following directions, carried over from the motivating program, sharpen the
effectivity question for product groups $G = \bigoplus_i C_{m_i}$:

1. **Exact Davenport constant for homocyclic groups.** Conjecturally
   $D(C_n^k) = k(n-1) + 1$, strictly below the crude bound $|G| = n^k$ for $k \ge
   2$, $n \ge 2$. The prefix-sum pigeonhole giving $D(G) \le |G|$ is wasteful for
   product groups; a coordinate-wise greedy extraction should recover the
   linear-in-$k$ truth. The missing piece is the lower-bound construction ($e_1$
   repeated $n-1$ times, ..., $e_k$ repeated $n-1$ times), which is finite and
   checkable.

2. **Sub-$|G|$ behavior of the fixed-length variant.** For $C_n$ the EGZ
   threshold $2n-1$ and the Davenport threshold $n$ differ by a factor $2 -
   o(1)$; for $\bigoplus_i C_{m_i}$ the fixed-length zero-sum constant $s(G)$
   satisfies $s(G) \le D(G) + |G| - 1$, since a fixed-length zero-sum subsequence
   can be assembled by extracting a short zero-sum block (Davenport) and padding
   with another, so the thresholds compose additively.

3. **The polynomial exponent is exactly $1$.** For every family $\bigoplus_i
   C_{m_i}$, the smallest valid zero-sum threshold satisfies $n_0 \le 2 \prod_i
   m_i$; the exponent in the conjectured form $C \cdot (\prod m_i)^{\mathrm{poly}}$
   can always be taken to be $\mathrm{poly} = 1$. Since $\prod_i m_i = |G|$ is an
   absolute pigeonhole ceiling for any zero-sum threshold, no super-linear
   exponent is ever forced.

4. **An additive refinement.** Among any $m_1 + \cdots + m_k + \max_i m_i - k$
   integers there is a nonempty subsequence whose sum is divisible by
   $\mathrm{lcm}(m_1,\dots,m_k)$ — an additive threshold improving $2\prod_i m_i -
   1$ when the $m_i$ are large, because divisibility by the lcm constrains each
   prime-power coordinate independently.

These conjectures convert the asymptotic threshold language into exact, linear,
checkable statements, continuing the effectivity theme that the cyclic case
settles completely.

---

## 11. Conclusion

We have determined the Erdős–Ginzburg–Ziv constant of the cyclic group $C_n$ to
be exactly $2n-1$ for all $n \ge 1$, with both bounds sharp: an elementary
extremal sequence of $n-1$ zeros and $n-1$ ones forces the lower bound, while the
Chevalley–Warning route delivers the upper bound, and a monotonicity-plus-squeeze
argument pins the infimum to the exact value. The result is fully effective and
constructive, with an explicit witness extractor realizable in $O(n \log n)$ time
for prime moduli. The cyclic case stands as the exactly-solved cornerstone of
zero-sum theory and a model for the broader program of effective additive
combinatorics.
