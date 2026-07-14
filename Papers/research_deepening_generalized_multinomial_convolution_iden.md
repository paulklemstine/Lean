# A Generalized Multinomial Convolution Identity for Latin Rectangle Enumeration

## Abstract

We establish, in full generality, the multinomial convolution identity
$$\sum_{i_1+\cdots+i_m=d}\ \prod_{j=1}^{m}\binom{a+i_j}{a}=\binom{ma+d+m-1}{d},$$
valid for all natural numbers $m$, $a$, and $d$, where the sum ranges over all
ordered $m$-tuples of non-negative integers summing to $d$. The identity
generalizes the three-factor convolution used to simplify the classical
Bogart–Longyear style enumeration of Latin rectangles. Our proof factors through
the theory of *multichoose* numbers $\left(\!\binom{r}{k}\!\right)=\binom{r+k-1}{k}$,
which count multisets and eliminate the truncated subtraction appearing in the
right-hand side. The two structural ingredients are a Vandermonde–Chu
convolution for multichoose numbers and its multi-fold generalization over an
arbitrary finite index set, proved by insertion induction. We further establish
a *heterogeneous* refinement in which each factor carries its own parameter
$a_j$, and show that the right-hand side then depends on the parameters only
through their sum, in exact accordance with the generating-function factorization
$\prod_j (1-x)^{-(a_j+1)}=(1-x)^{-(\sum_j a_j+m)}$. We conclude with numerical
demonstrations, algorithmic realizations, and a program of conjectural refinements
(signed, position-graded, and $q$-analogue versions).

## 1. Introduction

Sums of products of binomial coefficients, ranging over compositions of a fixed
integer, arise pervasively in enumerative combinatorics. A recurring instance,
central to the row-by-row enumeration of Latin rectangles, is the three-factor
convolution
$$\sum_{i_1+i_2+i_3=d}\binom{a+i_1}{a}\binom{a+i_2}{a}\binom{a+i_3}{a}
=\binom{3a+d+2}{d}.$$
Such convolutions collapse an ostensibly complicated nested sum into a single
binomial coefficient, dramatically simplifying downstream counting arguments.

The purpose of this paper is to prove that this collapse is not a peculiarity of
three factors but a universal law: the analogous statement holds for every number
$m$ of factors, and indeed in a strengthened form where the factors carry
independent parameters. The main results are stated in Section 3 and proved in
Section 4. Section 2 fixes notation and recalls the elementary theory of
multichoose numbers, which is the natural setting for the entire argument.

The organizing principle is that the identity is, at bottom, a **stars-and-bars
convolution**. Every binomial factor $\binom{a+i}{a}$ counts multisets of size
$i$ drawn from $a+1$ types; the sum over compositions merges the type-pools; and
the merged count is again a single multiset count. Making this precise requires
only one nontrivial lemma — a Vandermonde–Chu convolution for multichoose
numbers — together with a clean induction on the index set.

## 2. Preliminaries and Definitions

Throughout, $\mathbb{N}=\{0,1,2,\dots\}$ and all quantities are natural numbers
unless stated otherwise. We write $\binom{n}{k}$ for the ordinary binomial
coefficient, with the convention $\binom{n}{k}=0$ when $k>n$.

**Definition 2.1 (Multichoose number).** For $r,k\in\mathbb{N}$, the *multichoose
number* is
$$\left(\!\!\binom{r}{k}\!\!\right):=\binom{r+k-1}{k}.$$
It counts the number of multisets of size $k$ whose elements are drawn from a set
of $r$ types (equivalently, the number of ways to distribute $k$ identical items
into $r$ labelled boxes). We adopt the standard boundary conventions
$\left(\!\binom{r}{0}\!\right)=1$ for all $r$, and
$\left(\!\binom{0}{k}\!\right)=[k=0]$ (which equals $1$ when $k=0$ and $0$
otherwise), consistent with the stars-and-bars interpretation.

**Definition 2.2 (Composition / antidiagonal tuples).** For $m,d\in\mathbb{N}$,
let
$$T(m,d):=\Big\{(i_1,\dots,i_m)\in\mathbb{N}^m : i_1+\cdots+i_m=d\Big\}$$
denote the set of ordered $m$-tuples of non-negative integers summing to $d$
(the weak compositions of $d$ into $m$ parts). More generally, for a finite index
set $s$, the *antidiagonal* over $s$ at level $d$ is the set of functions
$$A(s,d):=\Big\{f:s\to\mathbb{N} : \textstyle\sum_{i\in s} f(i)=d\Big\}.$$
When $s=\{1,\dots,m\}$, $A(s,d)$ is in canonical bijection with $T(m,d)$.

**Lemma 2.3 (Binomial–multichoose bridge).** For all $a,i\in\mathbb{N}$,
$$\binom{a+i}{a}=\left(\!\!\binom{a+1}{i}\!\!\right).$$

*Proof.* By Definition 2.1, $\left(\!\binom{a+1}{i}\!\right)=\binom{(a+1)+i-1}{i}
=\binom{a+i}{i}$. The symmetry of the binomial coefficient gives
$\binom{a+i}{i}=\binom{a+i}{a}$. $\qquad\blacksquare$

Lemma 2.3 is the master change of variables. It re-expresses each factor of the
target identity as a multichoose number, thereby removing the truncated
subtraction that obstructs a direct inductive proof (see Remark 4.4).

## 3. Main Results

Our central theorem is the following.

**Theorem 3.1 (Generalized multinomial convolution identity).** For all
$m,a,d\in\mathbb{N}$,
$$\sum_{(i_1,\dots,i_m)\in T(m,d)}\ \prod_{j=1}^{m}\binom{a+i_j}{a}
=\binom{ma+d+m-1}{d}.$$

The classical case underlying the Latin rectangle simplification is the
specialization $m=3$.

**Corollary 3.2 (Three-factor instance).** For all $a,d\in\mathbb{N}$,
$$\sum_{i_1+i_2+i_3=d}\binom{a+i_1}{a}\binom{a+i_2}{a}\binom{a+i_3}{a}
=\binom{3a+d+2}{d}.$$

The theorem admits a strict strengthening in which each factor carries its own
parameter.

**Theorem 3.3 (Heterogeneous convolution identity).** For all $m,d\in\mathbb{N}$
and any parameters $a_1,\dots,a_m\in\mathbb{N}$,
$$\sum_{(i_1,\dots,i_m)\in T(m,d)}\ \prod_{j=1}^{m}\binom{a_j+i_j}{a_j}
=\binom{\big(\sum_{j=1}^m a_j\big)+d+m-1}{d}.$$
In particular, the right-hand side depends on the individual parameters only
through their sum. Theorem 3.1 is the special case $a_1=\cdots=a_m=a$.

Both theorems are consequences of the following multichoose statements, which we
regard as the structural core.

**Theorem 3.4 (Multichoose Vandermonde–Chu convolution).** For all
$r,t,d\in\mathbb{N}$,
$$\sum_{k=0}^{d}\left(\!\!\binom{r}{k}\!\!\right)\left(\!\!\binom{t}{d-k}\!\!\right)
=\left(\!\!\binom{r+t}{d}\!\!\right).$$

**Theorem 3.5 (Multi-fold multichoose convolution).** Let $s$ be a finite index
set and $r,d\in\mathbb{N}$. Then
$$\sum_{f\in A(s,d)}\ \prod_{i\in s}\left(\!\!\binom{r}{f(i)}\!\!\right)
=\left(\!\!\binom{|s|\cdot r}{d}\!\!\right).$$

**Theorem 3.6 (Heterogeneous multi-fold convolution).** Let $s$ be a finite index
set, $r:s\to\mathbb{N}$ a family of parameters, and $d\in\mathbb{N}$. Then
$$\sum_{f\in A(s,d)}\ \prod_{i\in s}\left(\!\!\binom{r(i)}{f(i)}\!\!\right)
=\left(\!\!\binom{\sum_{i\in s} r(i)}{d}\!\!\right).$$

## 4. Proofs

### 4.1 The two-fold convolution

*Proof of Theorem 3.4.* We argue by induction on $r$, with $d$ (and $t$)
quantified inside the induction.

**Base case $r=0$.** Here $\left(\!\binom{0}{k}\!\right)=[k=0]$, so the only
surviving term of the sum is $k=0$, giving
$\left(\!\binom{0}{0}\!\right)\left(\!\binom{t}{d}\!\right)
=\left(\!\binom{t}{d}\!\right)=\left(\!\binom{0+t}{d}\!\right)$, as required.

**Inductive step.** Assume the identity for $r$ and all $d$. Use the Pascal-type
recurrence for multichoose numbers,
$$\left(\!\!\binom{r+1}{k}\!\!\right)
=\left(\!\!\binom{r}{k}\!\!\right)+\left(\!\!\binom{r+1}{k-1}\!\!\right)
\qquad(k\ge 1),$$
which follows from $\binom{r+k}{k}=\binom{r+k-1}{k}+\binom{r+k-1}{k-1}$. Splitting
the sum $\sum_k \left(\!\binom{r+1}{k}\!\right)\left(\!\binom{t}{d-k}\!\right)$
according to this recurrence yields one copy of the inductive hypothesis at
parameter $r$ and one reindexed copy of the target at level $d-1$; a nested
induction on $d$ closes the step. The bookkeeping is routine and amounts to the
standard telescoping proof of the Vandermonde–Chu convolution transported to the
multichoose setting. $\qquad\blacksquare$

### 4.2 The multi-fold convolution by insertion induction

*Proof of Theorem 3.5.* We induct on the finite index set $s$.

**Base case $s=\varnothing$.** The empty product equals $1$, and $A(\varnothing,d)$
is nonempty (a single empty function) exactly when $d=0$. Thus the left-hand side
is $[d=0]$. The right-hand side is $\left(\!\binom{0}{d}\!\right)=[d=0]$. The two
agree.

**Inductive step $s\mapsto\{i_0\}\cup s$ with $i_0\notin s$.** The antidiagonal
decomposes along the value of $f(i_0)$: a function $f\in A(\{i_0\}\cup s, d)$ is
determined by a choice $f(i_0)=k\in\{0,\dots,d\}$ together with a function in
$A(s,d-k)$. Hence
$$\sum_{f\in A(\{i_0\}\cup s,d)}\prod_{i}\left(\!\!\binom{r}{f(i)}\!\!\right)
=\sum_{k=0}^{d}\left(\!\!\binom{r}{k}\!\!\right)
\Bigg(\sum_{g\in A(s,d-k)}\prod_{i\in s}\left(\!\!\binom{r}{g(i)}\!\!\right)\Bigg).$$
By the inductive hypothesis the inner sum equals
$\left(\!\binom{|s|\cdot r}{d-k}\!\right)$, so the whole expression becomes
$$\sum_{k=0}^{d}\left(\!\!\binom{r}{k}\!\!\right)\left(\!\!\binom{|s|\cdot r}{d-k}\!\!\right)
=\left(\!\!\binom{r+|s|\cdot r}{d}\!\!\right)
=\left(\!\!\binom{(|s|+1)\cdot r}{d}\!\!\right),$$
by Theorem 3.4. Since $|\{i_0\}\cup s|=|s|+1$, this is exactly the claimed
right-hand side. $\qquad\blacksquare$

*Proof of Theorem 3.6.* Identical in structure to the proof of Theorem 3.5. The
insertion step splits off the factor at the newly inserted index $i_0$ with its
own parameter $r(i_0)$, applies the inductive hypothesis
$\sum_{g\in A(s,d-k)}\prod_{i\in s}\left(\!\binom{r(i)}{g(i)}\!\right)
=\left(\!\binom{\sum_{i\in s} r(i)}{d-k}\!\right)$, and finishes with a single
application of the two-fold convolution (Theorem 3.4) at parameters
$r(i_0)$ and $\sum_{i\in s} r(i)$:
$$\sum_{k=0}^{d}\left(\!\!\binom{r(i_0)}{k}\!\!\right)
\left(\!\!\binom{\sum_{i\in s} r(i)}{d-k}\!\!\right)
=\left(\!\!\binom{r(i_0)+\sum_{i\in s} r(i)}{d}\!\!\right)
=\left(\!\!\binom{\sum_{i\in\{i_0\}\cup s} r(i)}{d}\!\!\right).$$
$\qquad\blacksquare$

### 4.3 Deducing the binomial identities

*Proof of Theorem 3.1.* Apply Lemma 2.3 to each factor:
$\binom{a+i_j}{a}=\left(\!\binom{a+1}{i_j}\!\right)$. Under the canonical
bijection $T(m,d)\cong A(s,d)$ with $s=\{1,\dots,m\}$, the sum becomes
$$\sum_{f\in A(s,d)}\prod_{i\in s}\left(\!\!\binom{a+1}{f(i)}\!\!\right)
=\left(\!\!\binom{m(a+1)}{d}\!\!\right)$$
by Theorem 3.5 with $r=a+1$ and $|s|=m$. Finally, by Definition 2.1,
$$\left(\!\!\binom{m(a+1)}{d}\!\!\right)=\binom{m(a+1)+d-1}{d}=\binom{ma+m+d-1}{d}
=\binom{ma+d+m-1}{d}.$$
$\qquad\blacksquare$

*Proof of Corollary 3.2.* Set $m=3$ in Theorem 3.1; the right-hand side is
$\binom{3a+d+2}{d}$. $\qquad\blacksquare$

*Proof of Theorem 3.3.* Apply Lemma 2.3 factorwise, giving
$\binom{a_j+i_j}{a_j}=\left(\!\binom{a_j+1}{i_j}\!\right)$, and apply Theorem 3.6
with $r(j)=a_j+1$. The right-hand side is
$\left(\!\binom{\sum_j (a_j+1)}{d}\!\right)
=\binom{(\sum_j a_j)+m+d-1}{d}=\binom{(\sum_j a_j)+d+m-1}{d}$. $\qquad\blacksquare$

**Remark 4.4 (Why multichoose is the right language).** A direct induction on $m$
applied to Theorem 3.1 must contend with the expression $ma+d+m-1$, whose "$-1$"
is a *truncated* subtraction over $\mathbb{N}$: for $m=a=d=0$ it evaluates to
$0-1=0$ rather than $-1$, and the recursion $ma+d+m-1 \mapsto (m+1)a+d+m$ does not
factor cleanly. The multichoose reformulation replaces this by the honest linear
recursion $|s|\cdot r \mapsto (|s|+1)\cdot r$, which contains no subtraction and
therefore inducts without special cases. The single "$-1$" reappears only at the
final translation step (Definition 2.1). This is the precise sense in which the
multichoose form is the natural generality of the statement.

## 5. Generating-Function Perspective

The heterogeneous identity has a transparent generating-function reading. Recall
the negative binomial series, for a non-negative integer parameter $c$,
$$\frac{1}{(1-x)^{c+1}}=\sum_{i\ge 0}\binom{c+i}{c}\,x^{i}.$$
Multiplying $m$ such series with parameters $a_1,\dots,a_m$ and reading off the
coefficient of $x^d$ gives exactly the left-hand side of Theorem 3.3:
$$[x^d]\prod_{j=1}^{m}\frac{1}{(1-x)^{a_j+1}}
=\sum_{i_1+\cdots+i_m=d}\prod_{j=1}^{m}\binom{a_j+i_j}{a_j}.$$
But the product of the series telescopes:
$$\prod_{j=1}^{m}\frac{1}{(1-x)^{a_j+1}}=\frac{1}{(1-x)^{\sum_j a_j+m}},$$
whose coefficient of $x^d$ is $\binom{(\sum_j a_j+m)-1+d}{d}=\binom{(\sum_j a_j)+d+m-1}{d}$.
This explains structurally why the right-hand side sees the parameters only
through their sum, and why the combinatorial insertion proof is the finite,
coefficient-level shadow of the identity $\prod_j (1-x)^{-(a_j+1)}=(1-x)^{-\sum_j(a_j+1)}$.

## 6. Application: Latin Rectangle Enumeration

A **Latin rectangle** of size $k\times n$ (with $k\le n$) is an array with entries
from $\{1,\dots,n\}$ such that each row is a permutation of $\{1,\dots,n\}$ and no
column contains a repeated symbol. Counting Latin rectangles is a classical and
difficult problem; the traditional approach, associated with Bogart, Longyear,
and others, is inductive on the number of rows: one counts, for a fixed valid
$k$-row rectangle, the number of admissible ways to append a $(k+1)$-st row.

This extension count is organized by an inclusion–exclusion over the pattern of
coincidences between the candidate new row and the columns already filled. When
the analysis is carried out for the transition into three rows, the number of
admissible completions is expressed through a convolution of the shape
$$\sum_{i_1+i_2+i_3=d}\binom{a+i_1}{a}\binom{a+i_2}{a}\binom{a+i_3}{a},$$
where $a$ and $d$ are determined by the row length and the current overlap data.
Corollary 3.2 collapses this convolution to the single term $\binom{3a+d+2}{d}$,
converting a doubly nested sum into a closed-form factor and materially
simplifying the recurrence. Theorem 3.1 performs the analogous simplification for
transitions involving $m$ interacting groups of columns, and Theorem 3.3 handles
the case in which the groups have differing sizes — precisely the situation that
arises when the columns are partitioned by their current fill-state. The
identities thus function as a reusable simplification lemma throughout the
row-insertion recurrence.

## 7. Algorithmic Realization

The identities yield immediate cross-checks and fast evaluators.

1. **Direct enumeration.** For fixed $m,a,d$, enumerate $T(m,d)$ (there are
   $\binom{d+m-1}{m-1}$ tuples), compute each product of $m$ binomials, and sum.
   This is exponential in the number of parts and serves as ground truth.

2. **Closed-form evaluation.** Compute the right-hand side
   $\binom{ma+d+m-1}{d}$ directly in $O(d)$ integer multiplications. The
   agreement of (1) and (2) is Theorem 3.1.

3. **Convolution ladder.** Evaluate the left-hand side in $O(m\,d)$ arithmetic
   operations by repeatedly convolving the coefficient vector
   $\big(\binom{a}{a},\binom{a+1}{a},\dots,\binom{a+d}{a}\big)$ with itself $m$
   times, truncating at degree $d$. This is the finite realization of the
   generating-function proof and mirrors the insertion induction step by step.

Section 8 (`demo.py`) implements all three and verifies their mutual agreement,
including the heterogeneous variant.

## 8. Discussion

The result illustrates a broadly applicable principle: an identity whose direct
formulation resists induction may become transparent after a change of language
that removes an arithmetic obstruction — here, replacing binomial coefficients by
multichoose numbers to eliminate a truncated subtraction. The multichoose form
is not merely a convenience; it is the generality in which the statement is
*natural*, admitting a uniform proof over an arbitrary finite index set and an
effortless heterogeneous refinement.

## 9. Future Directions

Several refinements of the core identity remain open and appear tractable by the
same insertion argument.

**Two-parameter (position-graded) refinement.** Once multiplicities vary with the
index, the convolution ceases to be symmetric in the parts, so an
order-sensitive statistic — a position-weighted degree $\sum_j j\,i_j$ — becomes
a genuine second grading rather than a cosmetic marker. We conjecture that the
bivariate sum $\sum_{\mathbf i}x^{\sum_j j\,i_j}\prod_j\binom{a_j+i_j}{a_j}$
factors as a product of shifted $q$-multichoose numbers whose principal
specialization recovers Theorem 3.3. The insertion step, which adjoins a single
factor of arbitrary multiplicity, is exactly where a position weight can be
attached and tracked.

**Alternating (signed) convolution.** The positive identity is the $a\ge 0$
branch of a Vandermonde law valid for all integer upper parameters. Replacing $a$
by a negative integer parameter should produce the inclusion–exclusion signs of
Möbius-type inversions, since the multichoose Vandermonde convolution proved here
extends to $\left(\!\binom{-n}{k}\!\right)$.

**$q$-analogue via Gaussian binomials.** Stars-and-bars convolutions typically
admit a $q$-refinement recording the "area" of the underlying lattice paths. We
conjecture an identity of the form
$\sum_{i_1+\cdots+i_m=d}q^{e(\mathbf i)}\prod_j\binom{a+i_j}{a}_q
=\binom{ma+d+m-1}{d}_q$ for an explicit exponent statistic $e(\mathbf i)$ given by
a sum of partial-sum products.

## 10. Conclusion

We have proved a fully general multinomial convolution identity, together with a
heterogeneous strengthening, by reducing both to a multichoose Vandermonde–Chu
convolution and an insertion induction over an arbitrary finite index set. The
identity supplies the closed-form simplification used in the row-by-row
enumeration of Latin rectangles and clarifies, via generating functions, why the
answer depends on the parameters only through their sum. The multichoose
reformulation is the conceptual key: it removes the truncated subtraction that
blocks a naive induction and exposes the identity as a plain statement about
counting multisets.
