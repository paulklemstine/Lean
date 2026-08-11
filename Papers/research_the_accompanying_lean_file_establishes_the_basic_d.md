# Strong Completeness of Sets of Natural Numbers: Ordered Blocks, Congruence Obstructions, and the Analytic Divergence Hypothesis

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

A set $A \subseteq \mathbb{N}$ is *complete* if every sufficiently large integer is a sum of
distinct elements of $A$, and *strongly complete* if $A \setminus F$ is complete for every
finite $F$. We develop a structural theory of strong completeness. First we prove an
*initial-segment criterion*: $A$ is strongly complete if and only if every tail
$A \cap (k, \infty)$ is complete, so that arbitrary finite deletions reduce to a nested
sequence of canonical ones. We then establish an *ordered-block criterion*: if $A$ contains a
sequence of pairwise ordered finite blocks whose subset sums cover intervals
$[\ell_k, h_k]$ satisfying the doubling condition $2\ell_k \le h_k + 1$ and the overlap
condition $\ell_{k+1} \le h_k + 1$, then $A$ is strongly complete. Specialising to dyadic
blocks $A \cap (2^k, 2^{k+1}]$ recovers a scale-based sufficient condition. We then prove a
sharp negative result: *six elements in every large dyadic block do not suffice even for
completeness* — the multiples of $3$ furnish a counterexample — so any purely density-based
dyadic criterion is impossible and an additional hypothesis excluding subgroup obstructions
is mandatory.

On the positive side we prove a *backbone-and-residues criterion*: if $A$ contains a subset
that represents all large multiples of some $d \ge 1$ after any finite deletion, and $A$ meets
every residue class mod $d$ infinitely often, then $A$ is strongly complete. This yields a
*dilation principle* generating strongly complete sets on prescribed scales, and shows that a
set containing all even numbers and infinitely many odd numbers is strongly complete. It also
lets us *refute* the natural parity conjecture: the set $3\mathbb{N} \cup \{1,2\}$ is
complete, contains infinitely many odd elements, and is not strongly complete. We prove the
matching necessary condition — a strongly complete set has infinitely many elements outside
$d\mathbb{Z}$ for every $d \ge 2$ — and finally connect this to the analytic hypothesis
$\sum_{a \in A} \|a\theta\|^2 = \infty$ (for all non-integral $\theta$) of the classical
theory: at every rational test point $\theta = 1/d$ the divergence of the series is
*equivalent* to the infinitude of $\{a \in A : d \nmid a\}$. Consequently the analytic
hypothesis implies the necessary congruence condition, every strongly complete set satisfies
all rational instances of the hypothesis, and each of our counterexamples provably violates
it.

**Keywords:** complete sequences, subset sums, strong completeness, dyadic blocks, residue
classes, distance to the nearest integer, divergence criteria.

---

## 1. Introduction

### 1.1 Completeness and its fragility

Let $\mathbb{N} = \{0,1,2,\dots\}$. A finite set $s \subseteq A$ has the *subset sum*
$\sum_{a \in s} a$; since $s$ is a set, each element is used at most once. The classical
notion, going back to work on representations by distinct summands, is:

> **Definition 1.1 (Subset sum).** For $A \subseteq \mathbb{N}$ and $n \in \mathbb{N}$, say
> $n$ is a *subset sum of $A$*, written $n \in \Sigma(A)$, if there is a finite set
> $s \subseteq A$ with $\sum_{a \in s} a = n$.

> **Definition 1.2 (Complete).** $A \subseteq \mathbb{N}$ is *complete* if there exists
> $N$ such that every $n \ge N$ is a subset sum of $A$.

Classical examples: the powers of two ($\Sigma = \mathbb{N}$ exactly), the squares (every
integer $> 128$), the primes (every integer $> 6$).

The property is delicate. Set
$$E_1 = \{2m : m \in \mathbb{N}\} \cup \{1\}.$$
Every even $n$ is a subset sum ($n$ itself), and every odd $n \ge 3$ is $1 + (n-1)$ with
$n - 1$ even and distinct from $1$. So $E_1$ is complete. But
$E_1 \setminus \{1\} = 2\mathbb{N}$ has only even subset sums, so a single deletion destroys
completeness. This motivates:

> **Definition 1.3 (Strongly complete).** $A \subseteq \mathbb{N}$ is *strongly complete* if
> $A \setminus F$ is complete for every finite $F \subseteq \mathbb{N}$.

Trivially strong completeness implies completeness (take $F = \emptyset$), and $E_1$ shows the
converse fails.

### 1.2 What this paper does

The classical headline theorem in this area asserts, roughly, that if from some point on each
dyadic range $(2^k, 2^{k+1}]$ contains at least six elements of $A$, and if
$\sum_{a \in A}\|a\theta\|^2 = \infty$ for every non-integral real $\theta$ (where $\|x\|$
denotes distance to the nearest integer), then $A$ is strongly complete. Our aim is to
dissect this statement: to isolate the combinatorial engine that drives it, to determine
exactly which of its hypotheses are removable, and to give the analytic hypothesis an
arithmetic interpretation.

The findings can be summarised as a slogan: **strong completeness requires two mechanisms,
each stable under finite deletion — a size mechanism and a congruence mechanism — and neither
alone suffices.**

Section 2 develops elementary structure (monotonicity, the initial-segment criterion).
Section 3 proves the ordered-block criterion and its dyadic specialisation. Section 4 gives
the negative result on six elements per dyadic block. Section 5 proves the
backbone-and-residues criterion, the dilation principle, and refutes the parity conjecture.
Section 6 proves the necessary congruence condition and the equivalence between rational
instances of the analytic hypothesis and congruence richness. Section 7 discusses
algorithmic aspects, Section 8 applications, and Section 9 open problems.

---

## 2. Elementary structure

### 2.1 Monotonicity

> **Lemma 2.1.** If $A \subseteq B$ and $n \in \Sigma(A)$ then $n \in \Sigma(B)$.
> Consequently, if $A$ is complete so is $B$, and if $A$ is strongly complete so is $B$.

*Proof.* A witnessing finite $s \subseteq A$ is also a subset of $B$ with the same sum. For
completeness, the same threshold $N$ works. For strong completeness, note that
$A \subseteq B$ implies $A \setminus F \subseteq B \setminus F$ for each finite $F$; apply the
completeness statement. $\square$

Monotonicity means both notions are *upward closed*: they are statements that a set is "large
enough and rich enough", never statements of exact structure.

### 2.2 Reduction to tails

The definition of strong completeness quantifies over all finite subsets of $\mathbb{N}$ — an
uncountable-looking family (in fact countable, but unwieldy). It can be replaced by a single
nested sequence of tests.

> **Theorem 2.2 (Initial-segment criterion).** For $A \subseteq \mathbb{N}$,
> $$A \text{ is strongly complete} \iff \text{for every } k \in \mathbb{N}, \;
> A \cap (k, \infty) \text{ is complete.}$$

*Proof.* ($\Rightarrow$) Apply strong completeness to the finite set $F = [0,k]$ and observe
$A \setminus [0,k] = A \cap (k,\infty)$.

($\Leftarrow$) Let $F$ be finite; it is bounded, say $F \subseteq [0, M]$. Then
$A \cap (M, \infty) \subseteq A \setminus F$: an element $x \in A$ with $x > M$ cannot lie in
$F$. Since $A \cap (M,\infty)$ is complete by hypothesis, Lemma 2.1 makes $A \setminus F$
complete. $\square$

Theorem 2.2 is the workhorse behind every subsequent argument: to prove strong completeness it
suffices to produce, for each $k$, a completeness certificate that only uses elements of $A$
exceeding $k$. Every criterion below is engineered so that its certificate can be pushed
arbitrarily far to the right.

---

## 3. The ordered-block criterion

### 3.1 Statement

> **Definition 3.1 (Ordered block system).** A sequence $(B_k)_{k \ge 0}$ of finite subsets of
> $\mathbb{N}$ is an *ordered block system* if each $B_k$ is nonempty and
> $x < y$ whenever $x \in B_k$ and $y \in B_{k+1}$.

> **Theorem 3.2 (Ordered-block criterion).** Let $A \subseteq \mathbb{N}$ and let
> $(B_k)_{k\ge0}$ be an ordered block system with $B_k \subseteq A$ for all $k$. Suppose there
> are sequences $(\ell_k)$, $(h_k)$ of natural numbers such that
>
> 1. *(coverage)* every $n$ with $\ell_k \le n \le h_k$ is a subset sum of $B_k$;
> 2. *(positivity)* $\ell_k \ge 1$ for all $k$;
> 3. *(monotonicity)* $\ell$ is nondecreasing;
> 4. *(doubling)* $2\ell_k \le h_k + 1$ for all $k$;
> 5. *(overlap)* $\ell_{k+1} \le h_k + 1$ for all $k$.
>
> Then $A$ is strongly complete.

Conditions 4 and 5 have transparent meanings. Overlap says that the covered intervals
$[\ell_k, h_k]$ and $[\ell_{k+1}, h_{k+1}]$ leave no gap between them. Doubling says each
covered interval has length at least $\ell_k - 1$, i.e. is at least as long as its own left
endpoint; this is exactly what allows a target to be split into a piece handled by the past
and a piece handled by the present without either piece falling out of range.

### 3.2 Two order lemmas

> **Lemma 3.3.** In an ordered block system, if $i < k$, $x \in B_i$ and $y \in B_k$, then
> $x < y$.

*Proof.* Induction on $k$. For $k = i+1$ this is the hypothesis. For $k+1 > i+1$, pick
$z \in B_k$ (nonempty); then $x < z$ by the induction hypothesis and $z < y$ by the
hypothesis for consecutive blocks. $\square$

> **Lemma 3.4.** In an ordered block system, every $x \in B_k$ satisfies $x \ge k$.

*Proof.* Induction on $k$; the case $k = 0$ is trivial. If every element of $B_k$ is $\ge k$
and $y \in B_k$, $x \in B_{k+1}$, then $x > y \ge k$, so $x \ge k+1$. $\square$

Lemma 3.4 is what makes the criterion *strong*: blocks of large index consist of large
numbers, hence are untouched by any fixed finite deletion.

### 3.3 The covering induction

The combinatorial heart is the following.

> **Proposition 3.5 (Block covering).** Under the hypotheses of Theorem 3.2, fix $m$. For
> every $j \ge 0$, every integer $n$ with
> $$\ell_m \le n \le H_j := \sum_{i=0}^{j} h_{m+i}$$
> is a subset sum of $B_m \cup B_{m+1} \cup \cdots \cup B_{m+j}$.

*Proof.* Induction on $j$.

*Base $j = 0$.* Here $H_0 = h_m$ and $\ell_m \le n \le h_m$, so coverage of $B_m$ applies.

*Step.* Assume the claim for $j$, and let $\ell_m \le n \le H_{j+1} = H_j + h_k$ where
$k := m + j + 1$.

*Case A: $n \le H_j$.* The induction hypothesis gives a representation inside the earlier
blocks, which is in particular a subset of the enlarged union.

*Case B: $n > H_j$ and $n \le h_k$.* The overlap condition applied at index $m+j$ gives
$\ell_k \le h_{m+j} + 1 \le H_j + 1 \le n$ (using $h_{m+j} \le H_j$, valid since the $h$'s are
nonnegative). Hence $\ell_k \le n \le h_k$ and coverage of the single block $B_k$ suffices.

*Case C: $n > H_j$ and $n > h_k$.* We produce a decomposition $n = u + v$ with
$\ell_m \le u \le H_j$ and $\ell_k \le v \le h_k$. Two sub-cases:

* If $n \ge \ell_m + h_k$, take $v = h_k$ and $u = n - h_k$. Then $u \ge \ell_m$, and
  $u \le H_j$ because $n \le H_j + h_k$. Also $\ell_k \le v$: from doubling at $k$ we get
  $2\ell_k \le h_k + 1$, and $\ell_k \ge 1$, whence $\ell_k \le h_k$.
* If $n < \ell_m + h_k$, take $u = \ell_m$ and $v = n - \ell_m$. Then $v \le h_k$ is immediate
  and $v \ge \ell_k$ follows because $n > h_k \ge 2\ell_k - 1 \ge \ell_k + \ell_m - 1$: here we
  use doubling at $k$ together with $\ell_m \le \ell_k$ (monotonicity, $m \le k$). Finally
  $u = \ell_m \le H_j$ because $h_m \le H_j$ and $2\ell_m \le h_m + 1$ gives $\ell_m \le h_m$.

Apply the induction hypothesis to $u$ (a set $s_u$ inside the earlier blocks) and coverage to
$v$ (a set $s_v \subseteq B_k$). By Lemma 3.3 every element of $s_u$ lies in some $B_{m+i}$
with $m+i < k$, hence is strictly smaller than every element of $B_k$; so $s_u$ and $s_v$ are
disjoint and $\sum_{a \in s_u \cup s_v} a = u + v = n$. $\square$

### 3.4 Proof of Theorem 3.2

Let $F$ be finite, say $F \subseteq [0,M]$, and set $m = M+1$. By Lemma 3.4 every element of
$B_k$ with $k \ge m$ satisfies $x \ge k \ge M+1 > M$, so $B_k \cap F = \emptyset$: blocks of
index at least $m$ are untouched by the deletion.

From doubling and positivity, $h_k \ge 2\ell_k - 1 \ge 1$ for every $k$. Hence for any $n$,
$$\sum_{i=0}^{n} h_{m+i} \; \ge \; \sum_{i=0}^{n} 1 \;=\; n+1 \; > \; n,$$
so the hypothesis $n \le H_n$ of Proposition 3.5 is automatically satisfied with $j = n$.
Therefore every $n \ge \ell_m$ is a subset sum of $\bigcup_{i\le n} B_{m+i} \subseteq
A \setminus F$. Thus $A \setminus F$ is complete with threshold $\ell_m$. As $F$ was
arbitrary, $A$ is strongly complete. $\square$

> **Corollary 3.6.** Under the hypotheses of Theorem 3.2, $A$ is complete.

### 3.5 Dyadic specialisation

> **Definition 3.7 (Dyadic block).** For $A \subseteq \mathbb{N}$ and $k \ge 0$, the $k$-th
> *dyadic block* is $D_k(A) := A \cap (2^k, 2^{k+1}]$.

> **Lemma 3.8.** Every $n \ge 2$ satisfies $2^k < n \le 2^{k+1}$ for exactly one $k$.
> Hence the dyadic blocks partition $A \cap [2,\infty)$.

*Proof.* Take $k$ maximal with $2^k < n$; such $k$ exists since $2^0 = 1 < n$ and powers of
two are unbounded, and maximality gives $n \le 2^{k+1}$. Uniqueness is immediate from
strict monotonicity of $k \mapsto 2^k$. $\square$

> **Theorem 3.9 (Full dyadic ranges).** If there is $K$ such that for every $k \ge K$ the
> entire interval $(2^k, 2^{k+1}]$ is contained in $A$, then $A$ is strongly complete.

*Proof.* Apply Theorem 3.2 with the *paired* blocks
$$B_j := \big(2^{K+2j},\, 2^{K+2j+2}\big] \cap \mathbb{Z}, \qquad
\ell_j := 2^{K+2j}+1, \qquad h_j := 2^{K+2j+2}.$$
Each $B_j$ is a union of the two consecutive full dyadic ranges of indices $K+2j$ and
$K+2j+1$, hence contained in $A$; it is nonempty (it contains $2^{K+2j+2}$); and blocks are
ordered since $\max B_j = 2^{K+2j+2} = \min B_{j+1} - 1 < \min B_{j+1}$. Coverage holds
trivially by singletons: every $n$ with $\ell_j \le n \le h_j$ *is* an element of $B_j$.
Positivity and monotonicity are clear. Doubling reads
$2(2^{K+2j}+1) = 2^{K+2j+1} + 2 \le 2^{K+2j+2}+1$, true since
$2^{K+2j+2} = 2\cdot 2^{K+2j+1} \ge 2^{K+2j+1}+2$. Overlap is an equality:
$\ell_{j+1} = 2^{K+2j+2}+1 = h_j + 1$. $\square$

The use of *paired* dyadic ranges is not cosmetic: a single range $(2^k, 2^{k+1}]$, covered by
singletons, has $\ell = 2^k+1$, $h = 2^{k+1}$ and fails doubling by exactly one
($2\ell = 2^{k+1}+2 > h+1$). Pairing buys the extra factor of two.

---

## 4. Density is not enough: six elements per dyadic block

Theorem 3.9 needs full dyadic ranges — an extremely strong hypothesis. It is natural to hope
that a much weaker density hypothesis, such as "at least six elements in every sufficiently
large dyadic block", already gives completeness. It does not, and the failure is decisive.

> **Definition 4.1.** $M_3 := \{n \in \mathbb{N} : 3 \mid n\}$.

> **Lemma 4.2.** For every $k \ge 5$, the dyadic block $D_k(M_3)$ contains at least six
> elements.

*Proof.* Since $k \ge 5$ we have $2^k \ge 32$. Let $c := 3\big(\lfloor 2^k/3\rfloor + 1\big)$,
the least multiple of $3$ strictly exceeding $2^k$; then $2^k < c \le 2^k + 3$. The six
numbers $c, c+3, c+6, c+9, c+12, c+15$ are distinct multiples of $3$, all exceed $2^k$, and
the largest satisfies
$$c + 15 \le 2^k + 18 \le 2^k + 2^k = 2^{k+1},$$
using $18 \le 32 \le 2^k$. Hence all six lie in $(2^k, 2^{k+1}] \cap M_3 = D_k(M_3)$.
$\square$

> **Lemma 4.3.** $M_3$ is not complete.

*Proof.* Every subset sum of multiples of $3$ is a multiple of $3$. Given any candidate
threshold $N$, the integer $3N+1 \ge N$ is not a multiple of $3$, so it is not a subset sum.
$\square$

> **Theorem 4.4 (Six elements per dyadic block are insufficient).** There exists
> $A \subseteq \mathbb{N}$ such that $D_k(A)$ has at least six elements for every $k \ge 5$,
> and yet $A$ is not complete (a fortiori not strongly complete).

*Proof.* Take $A = M_3$ and combine Lemmas 4.2 and 4.3. $\square$

Theorem 4.4 is a *sharpness* statement about the classical theory. It shows the following.

* No purely cardinality-based dyadic criterion — "at least $c$ elements in every large dyadic
  block" — can imply completeness, for any constant $c$: replacing $3$ by a large modulus $d$
  and the constant $6$ by any $c$, the set $d\mathbb{N}$ has at least $c$ elements in every
  dyadic block of index $k$ with $2^k \ge cd$, and is still not complete.
* Therefore the auxiliary hypothesis in the classical theorem is not a technical artefact. It
  must, at minimum, exclude subgroup obstructions.

Section 6 shows that the analytic divergence hypothesis does exactly this — no more, no less,
at the rational test points.

---

## 5. Backbones, residues, and the death of the parity conjecture

### 5.1 The criterion

> **Definition 5.1.** Let $d \ge 1$. A set $B \subseteq \mathbb{N}$ is *complete mod $d$* if
> there is $N$ with $dq \in \Sigma(B)$ for all $q \ge N$; it is a *$d$-backbone* (strongly
> complete mod $d$) if $B \setminus F$ is complete mod $d$ for every finite $F$.

> **Theorem 5.2 (Backbone-and-residues criterion).** Let $d \ge 1$ and $A \subseteq \mathbb{N}$.
> Suppose
>
> 1. there is $B \subseteq A$ which is a $d$-backbone, and
> 2. for every $r < d$ the set $\{a \in A : a \equiv r \pmod d\}$ is infinite.
>
> Then $A$ is strongly complete.

*Proof.* Let $F$ be finite, $F \subseteq [0,M]$.

*Choice of residue representatives.* For each $r$ pick $g(r) \in A$ with
$g(r) \equiv r \pmod d$ and $g(r) > M$; hypothesis 2 supplies infinitely many candidates, so
one exceeds $M$. Let $P := \max_{r<d} g(r)$, a finite number.

*Backbone with margin.* Apply the $d$-backbone property to the finite set
$F \cup [0,P]$: there is $N_1$ such that every $dq$ with $q \ge N_1$ is a subset sum of
$B \setminus (F \cup [0,P])$ — that is, a subset sum using only elements of $B$ that avoid
$F$ and exceed $P$.

*Representation.* Let $n \ge P + dN_1 + 1$. Put $r := n \bmod d$ and $a := g(r)$. Then
$a \le P < n$ and $a \equiv n \pmod d$, so $n - a = dq$ for some $q \ge 0$. Moreover
$dq = n - a \ge n - P \ge dN_1 + 1 > dN_1$, whence $q \ge N_1$ (if $q < N_1$ then
$dq \le d N_1$). Choose $s \subseteq B \setminus (F \cup [0,P])$ with $\sum_{x\in s} x = dq$.
Every element of $s$ exceeds $P \ge a$, so $a \notin s$ and $\{a\} \cup s$ is a set of
distinct elements of $A \setminus F$ with sum $a + dq = n$.

Thus $A \setminus F$ is complete with threshold $P + dN_1 + 1$. $\square$

The proof exhibits the two mechanisms in their purest form. The *congruence mechanism* is the
single element $a$, whose only job is to fix the residue of the target; the residue hypothesis
is used precisely to place $a$ beyond the reach of the adversary. The *size mechanism* is the
backbone, which then handles a target that has been reduced to a multiple of $d$. Both
mechanisms are deletion-stable by hypothesis, which is why the conclusion is strong
completeness and not merely completeness.

### 5.2 Consequences

> **Corollary 5.3 (Multiples and residues).** Let $d \ge 1$. If $A$ contains $dm$ for every
> $m \ge K$, and every residue class mod $d$ meets $A$ infinitely often, then $A$ is strongly
> complete.

*Proof.* Take $B := \{dm : m \ge K\}$. For finite $F \subseteq [0,M]$ and
$q \ge \max(K, M+1)$, the singleton $\{dq\}$ lies in $B \setminus F$ (as $dq \ge q > M$) and
sums to $dq$; so $B$ is a $d$-backbone. Apply Theorem 5.2. $\square$

> **Theorem 5.4 (Whole numbers).** $\mathbb{N}$ is strongly complete.

*Proof.* For finite $F \subseteq [0,M]$ and $n \ge M+1$, the singleton $\{n\}$ works. $\square$

> **Theorem 5.5 (Dilation principle).** Let $d \ge 1$ and let $A$ be strongly complete. Then
> $d \cdot A := \{da : a \in A\}$ is a $d$-backbone. Consequently, for any $C \subseteq
> \mathbb{N}$ such that $(d\cdot A) \cup C$ meets every residue class mod $d$ infinitely
> often, the set $(d \cdot A) \cup C$ is strongly complete.

*Proof.* Let $F$ be finite. The map $a \mapsto da$ is injective (for $d \ge 1$), so the
preimage $F' := \{a : da \in F\}$ is finite. By strong completeness of $A$ there is $N$ with
every $q \ge N$ a subset sum of $A \setminus F'$, say $q = \sum_{a\in s} a$. Then
$d\cdot s := \{da : a \in s\}$ is a set of distinct elements of $(d\cdot A) \setminus F$ with
$\sum_{x \in d\cdot s} x = d\sum_{a\in s} a = dq$. Hence $d\cdot A$ is complete mod $d$ after
any finite deletion. The second claim is Theorem 5.2 with $B = d\cdot A$. $\square$

The dilation principle is a *generator*: starting from any strongly complete set — for
instance $\mathbb{N}$ itself — one obtains strongly complete sets concentrated on the
multiples of $d$, plus an arbitrarily sparse residue-repair set $C$. In particular strongly
complete sets can have density as small as one wishes on the residue-repair part.

> **Corollary 5.6 (Evens plus infinitely many odds).** If $A$ contains every even number and
> infinitely many odd numbers, then $A$ is strongly complete.

*Proof.* Corollary 5.3 with $d=2$, $K=0$: the class $0 \bmod 2$ meets $A$ infinitely often
(all evens), the class $1 \bmod 2$ by hypothesis. $\square$

Contrast Corollary 5.6 with $E_1 = 2\mathbb{N}\cup\{1\}$ of §1.1, which contains all evens and
*one* odd number and is complete but not strongly complete. The dividing line between fragile
and robust is precisely finiteness versus infinitude of the residue-repair stock.

### 5.3 Refutation of the parity conjecture

Corollary 5.6 makes the following conjecture attractive: *if $A$ is complete and contains
infinitely many odd elements, then $A$ is strongly complete.* It is false.

> **Definition 5.7.** $T := \{n \in \mathbb{N} : 3 \mid n\} \cup \{1,2\}$.

> **Lemma 5.8.** $T$ is complete, with threshold $3$.

*Proof.* Let $n \ge 3$. If $n \equiv 0 \pmod 3$, then $\{n\} \subseteq T$ sums to $n$. If
$n \equiv 1$, then $n-1 \ge 2$ is a multiple of $3$ and $n - 1 \ne 1$, so $\{1, n-1\}$ is a
two-element subset of $T$ summing to $n$. If $n \equiv 2$, then $n-2$ is a multiple of $3$ with
$n - 2 \ne 2$, so $\{2, n-2\} \subseteq T$ sums to $n$. $\square$

> **Lemma 5.9.** $T$ contains infinitely many odd numbers.

*Proof.* For every $k$, $6k+3 = 3(2k+1)$ is an odd multiple of $3$, hence lies in $T$; the map
$k \mapsto 6k+3$ is injective. $\square$

> **Lemma 5.10.** $T$ is not strongly complete.

*Proof.* Delete the finite set $\{1,2\}$. The remainder is $T \setminus \{1,2\} = M_3$, whose
subset sums are multiples of $3$; by Lemma 4.3 it is not complete. $\square$

> **Theorem 5.11 (Parity conjecture is false).** There exists $A \subseteq \mathbb{N}$ that is
> complete, contains infinitely many odd elements, and is not strongly complete.

*Proof.* $A = T$, by Lemmas 5.8–5.10. $\square$

The diagnosis: parity is only the instance $d = 2$ of a family of obstructions indexed by all
moduli $d \ge 2$. A set may be complete solely because of finitely many elements escaping the
subgroup $d\mathbb{Z}$ for some particular $d$, and testing odd elements does not detect this
when $d \ne 2$. The correct hypothesis must range over all moduli, which is exactly what the
next section formalises.

---

## 6. Congruence necessity and the analytic hypothesis

### 6.1 A necessary condition

> **Theorem 6.1 (Congruence necessity).** If $A$ is strongly complete, then for every
> $d \ge 2$ the set $A_d^{\times} := \{a \in A : d \nmid a\}$ is infinite.

*Proof.* Suppose $A_d^\times$ is finite. Delete it: $A \setminus A_d^\times \subseteq
d\mathbb{Z}$, so all its subset sums are divisible by $d$. Given any threshold $N$ produced by
completeness of $A\setminus A_d^\times$, the integer $dN+1 \ge N$ is not divisible by $d$ and
so is not a subset sum. Hence $A \setminus A_d^\times$ is not complete, contradicting strong
completeness. $\square$

Theorem 6.1 explains all our counterexamples uniformly: $M_3$ has $A_3^\times = \emptyset$,
and $T$ has $A_3^\times = \{1,2\}$ — finite in both cases.

### 6.2 Distance to the nearest integer

> **Definition 6.2.** For $x \in \mathbb{R}$, let $\{x\}$ denote its fractional part and
> $$\|x\| := \min\big(\{x\},\, 1 - \{x\}\big),$$
> the distance from $x$ to the nearest integer. Then $0 \le \|x\| \le 1/2$, and
> $\|x\| = 0$ iff $x \in \mathbb{Z}$.

> **Lemma 6.3.** Let $d \ge 2$ and $a \in \mathbb{N}$ with $d \nmid a$. Then
> $\|a/d\| \ge 1/d$.

*Proof.* Write $a = qd + r$ with $1 \le r \le d-1$ (the case $r=0$ is excluded). Then
$\{a/d\} = r/d$, so $\{a/d\} \ge 1/d$ and $1 - \{a/d\} = (d-r)/d \ge 1/d$. The minimum of the
two is therefore $\ge 1/d$. $\square$

> **Definition 6.4 (Analytic divergence hypothesis).** $A$ satisfies the *divergence
> hypothesis* if
> $$\sum_{a \in A} \|a\theta\|^2 = \infty \qquad \text{for every } \theta \in \mathbb{R}
> \setminus \mathbb{Z}.$$
> (All terms are nonnegative, so the sum is unambiguous as an element of $[0,\infty]$
> irrespective of the order of summation.)

### 6.3 The rational dictionary

> **Theorem 6.5 (Rational divergence dictionary).** Let $A \subseteq \mathbb{N}$ and
> $d \ge 2$. Then
> $$\sum_{a \in A} \left\|\frac{a}{d}\right\|^2 = \infty \iff
> \{a \in A : d \nmid a\} \text{ is infinite.}$$

*Proof.* ($\Leftarrow$) By Lemma 6.3 each $a \in A$ with $d\nmid a$ contributes a term at
least $1/d^2 > 0$. If there are infinitely many such $a$, the sum dominates an infinite sum of
the positive constant $1/d^2$, hence is infinite.

($\Rightarrow$) Contrapositive. Suppose $S := \{a \in A : d \nmid a\}$ is finite. For
$a \in A \setminus S$ we have $d \mid a$, so $a/d \in \mathbb{Z}$ and $\|a/d\| = 0$. Hence
every term of the sum outside the finite set $S$ vanishes, and the sum equals the finite sum
$\sum_{a \in S}\|a/d\|^2 \le |S|/4 < \infty$. $\square$

Theorem 6.5 is the conceptual bridge of the paper: **at the rational test points, the analytic
hypothesis is precisely a congruence hypothesis.** The distance-to-integer functional
$\|\cdot\|$, evaluated along the arithmetic progression $\theta = 1/d$, does nothing more or
less than count the elements of $A$ that escape the subgroup $d\mathbb{Z}$.

### 6.4 Consequences

> **Corollary 6.6 (Divergence excludes congruence obstructions).** If $A$ satisfies the
> divergence hypothesis, then for every $d \ge 2$ the set $\{a \in A : d \nmid a\}$ is
> infinite; i.e. $A$ automatically satisfies the necessary condition of Theorem 6.1.

*Proof.* For $d \ge 2$ we have $0 < 1/d < 1$, so $\theta = 1/d \notin \mathbb{Z}$ and the
divergence hypothesis applies. Conclude by Theorem 6.5. $\square$

> **Corollary 6.7.** $M_3$ does not satisfy the divergence hypothesis; neither does
> $T = M_3 \cup \{1,2\}$.

*Proof.* Otherwise Corollary 6.6 with $d = 3$ would give infinitely many elements not
divisible by $3$; but $M_3$ has none, and $T$ has exactly two. $\square$

Corollary 6.7 is the consistency check the whole development was aiming at. The two
counterexamples of Sections 4 and 5 do not contradict the classical theorem, *because they
fail its analytic hypothesis* — and they fail it for exactly the reason the hypothesis exists.

> **Corollary 6.8 (Strong completeness forces rational divergence).** If $A$ is strongly
> complete, then $\sum_{a\in A}\|a/d\|^2 = \infty$ for every $d \ge 2$.

*Proof.* Theorem 6.1 followed by Theorem 6.5. $\square$

Corollary 6.8 shows that the rational part of the divergence hypothesis is not a proof
artefact: it is a *consequence* of the conclusion it is used to derive. The full hypothesis —
quantified over irrational $\theta$ as well — is a genuine strengthening, ruling out
equidistribution failures not visible modulo any single integer; whether that strengthening is
also necessary is open (§9).

---

## 7. Algorithms

The theory above suggests three effective procedures, all elementary but worth stating
precisely.

### 7.1 Reachability by dynamic programming

To test completeness empirically one computes the *reachable set*
$R_N(A) := \Sigma(A \cap [0,N]) \cap [0,N]$, using the classical distinct-summand knapsack
recursion: start from the bit-set $\{0\}$ and, for each $a \in A$ with $a \le N$ in increasing
order, replace $R$ by $R \cup (R + a)$, truncated at $N$. With a bitmask representation the
cost is $O(|A \cap [0,N]| \cdot N / w)$ word operations, $w$ the machine word size.

A *completeness certificate up to $N$* is the largest $n \le N$ not in $R_N(A)$; the set is
consistent with completeness at threshold $n+1$. This never *proves* completeness but reliably
detects failure, and it makes the counterexamples of Sections 4 and 5 visible instantly.

### 7.2 Greedy block representation

Proposition 3.5 is constructive and yields a representation algorithm. Given a target $n$ and
an ordered block system with covering intervals $[\ell_k, h_k]$:

1. Locate the largest index $k$ with $\ell_k \le n$; if $n \le h_k$ return the single-block
   representation of $n$ inside $B_k$.
2. Otherwise set $v := h_k$ (or $v := n - \ell_m$ if $n < \ell_m + h_k$), emit the
   representation of $v$ inside $B_k$, and recurse on $n - v$ using blocks of index $< k$.

Each recursion step decreases the block index, so the algorithm terminates in at most $k$
steps, and correctness is exactly the case analysis of Proposition 3.5. The output is a set of
*distinct* elements because different blocks are disjoint and ordered.

### 7.3 Deletion-robust representation via backbone and residues

Theorem 5.2 also constructivises. Given $d$, a residue-representative function $g$, a backbone
$B$, a finite deletion set $F$ with $\max F \le M$, and a large target $n$:

1. Compute $r := n \bmod d$ and pick $a := g(r)$, the least element of $A$ in class $r$
   exceeding $M$.
2. Compute $q := (n-a)/d$ and obtain a backbone representation of $dq$ using only backbone
   elements exceeding $\max_{r<d} g(r)$.
3. Return $\{a\} \cup s$.

The cost is dominated by step 2; for the standard backbone $d\mathbb{N}$ it is a single
singleton lookup, giving an $O(1)$ representation of every large $n$ as $a + dq$ with two
summands.

---

## 8. Applications and interpretation

**Coin systems and robust payment.** Interpreting $A$ as available coin denominations, each
usable once, completeness says all large amounts are exactly payable, and strong completeness
says this survives the loss of any finite part of the stock. Corollary 5.6 gives a design
principle: a denomination system built on a dense arithmetic backbone must supply an
*inexhaustible* stock of residue-repair coins in every class, not merely one of each.

**Sharpness of density heuristics.** Theorem 4.4 is a caution against density heuristics in
additive combinatorics generally. The multiples of $3$ have positive density and abundant
representation within every scale, yet represent nothing outside a subgroup. Any criterion for
representability by distinct summands must include a non-degeneracy condition of an
arithmetic (or Fourier-analytic) type.

**Fourier interpretation.** The quantity $\|a\theta\|$ measures how far the exponential
$e^{2\pi i a\theta}$ is from $1$; divergence of $\sum_a \|a\theta\|^2$ is a statement that the
"characters" of $A$ never concentrate at any single non-trivial frequency. Theorem 6.5 shows
that at rational frequencies this is exactly the statement that $A$ is not asymptotically
contained in a proper subgroup. The analytic hypothesis is thus best read as *uniform
non-degeneracy across all frequencies*, of which the congruence conditions are the rational
shadow.

**Design of generators.** Theorem 5.5 gives a recipe: pick any strongly complete $A$
(e.g. $\mathbb{N}$, or the squares, or the primes), dilate by $d$, and adjoin a sparse set $C$
hitting every class mod $d$ infinitely often. The result is strongly complete and can be made
to grow along any prescribed scale, giving a flexible supply of examples for testing
conjectures.

---

## 9. Open problems and future directions

**P1 (Residue-rich completeness).** *If $A$ is complete and, for every $m \ge 2$ and every
residue $r$, the class $r \bmod m$ contains infinitely many elements of $A$, is $A$ strongly
complete?* Theorem 5.2 settles this whenever $A$ carries a backbone, and Theorem 6.1 shows the
residue hypothesis is of the right type. What remains is the backbone-free case: one must
extract a deletion-stable size mechanism from ordinary completeness itself. A natural route is
to replace "multiples of $d$" by "subset sums of a tail of $A$"; a natural refutation attempt
is to build a complete, residue-rich set whose completeness hinges on a single small element.

**P2 (Quantitative divergence upgrade).** Can the block-size constant in the dyadic criterion
be lowered from six to five (or lower) if the divergence hypothesis is strengthened
quantitatively, e.g. by requiring
$\sum_{a \in A, a \le x} \|a\theta\|^2 \gg (\log x)^{1+\varepsilon}$ uniformly in $\theta$?
Theorem 4.4 shows *some* hypothesis is needed at every block size, so the trade-off between
block size and analytic strength is the right question.

**P3 (Necessity of irrational frequencies).** Corollary 6.8 shows the rational instances of
the divergence hypothesis are necessary for strong completeness. Are the irrational instances
necessary too? Equivalently: is there a strongly complete $A$ and an irrational $\theta$ with
$\sum_{a\in A}\|a\theta\|^2 < \infty$? A convergent series forces $A$ to be very close to a
Beatty-type structure, which suggests a construction may be possible.

**P4 (Full ordered-block equivalence).** Theorem 3.2 is sufficient but not necessary. Is there
a block-based characterisation — necessary *and* sufficient — of strong completeness? The
initial-segment criterion (Theorem 2.2) suggests one should look for a criterion phrased on
tails, with a uniform block system extractable from every strongly complete set.

**P5 (Optimality of the doubling constant).** In Theorem 3.2 the doubling condition
$2\ell_k \le h_k + 1$ can plausibly be relaxed to $c\,\ell_k \le h_k + 1$ for some
$1 < c < 2$ at the price of a stronger overlap condition. Determining the exact admissible
region in the $(\text{doubling}, \text{overlap})$ parameter plane would sharpen the criterion
into a genuine threshold theorem.

**P6 (Effective thresholds).** All completeness thresholds above are explicit in terms of the
deleted set: the backbone criterion yields threshold $P + dN_1 + 1$ where $P$ is the largest
residue representative. Determining the optimal threshold as a function of $\max F$ — is it
linear in $\max F$? — would turn the qualitative theory into a quantitative one.

---

## 10. Summary of results

| Result | Statement |
|---|---|
| Monotonicity | Supersets of complete (resp. strongly complete) sets are complete (resp. strongly complete). |
| Initial-segment criterion | $A$ strongly complete $\iff$ every tail $A \cap (k,\infty)$ is complete. |
| Ordered-block criterion | Ordered blocks covering intervals with $2\ell_k \le h_k+1$ and $\ell_{k+1}\le h_k+1$ force strong completeness. |
| Dyadic specialisation | Containing all of $(2^k,2^{k+1}]$ for large $k$ forces strong completeness. |
| Six-per-block insufficiency | The multiples of $3$ have $\ge 6$ elements in every dyadic block of index $\ge 5$ and are not complete. |
| Backbone-and-residues | A $d$-backbone plus infinitely many elements in every class mod $d$ forces strong completeness. |
| Dilation principle | $d\cdot A$ is a $d$-backbone whenever $A$ is strongly complete. |
| Evens plus odds | All evens plus infinitely many odds $\Rightarrow$ strongly complete. |
| Parity conjecture refuted | $3\mathbb{N}\cup\{1,2\}$ is complete with infinitely many odd elements, but not strongly complete. |
| Congruence necessity | Strongly complete $\Rightarrow$ infinitely many elements outside $d\mathbb{Z}$ for all $d\ge2$. |
| Rational dictionary | $\sum_{a\in A}\|a/d\|^2 = \infty \iff \{a \in A: d\nmid a\}$ infinite. |
| Divergence $\Rightarrow$ non-degeneracy | The divergence hypothesis implies the necessary congruence condition; both counterexamples violate it. |
| Necessity of rational divergence | Strongly complete $\Rightarrow$ divergence at every $\theta=1/d$, $d \ge 2$. |
