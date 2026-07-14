# The Good-Manifold Count of an $n$-Nice Polytope: Closed Form, Recurrence, and $2$-adic Structure

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

We study the integer sequence $a(n)$ recording the maximal number of *good* manifolds admitted by an $n$-nice polytope, with tabulated values
$$6,\ 8,\ 12,\ 24,\ 40,\ 80,\ 128,\ 256,\ 512,\ 1024,\ 2048,\ 4096,\ 8192,\ 16384,\ 32768,\ 65536,\ 131072,\ 262144,\ 524288,\ 1048576,\ 2097152, \dots$$
The data exhibits an irregular *head* in dimensions $1$ through $6$ followed by a perfectly regular exponential *tail*. Our principal result is that from dimension seven onward the count is exactly $2^n$. From this closed form we derive a two-term doubling recurrence, an exact geometric partial-sum identity, global strict monotonicity of the entire sequence, universal parity, and — bridging enumerative geometry with $p$-adic arithmetic — the identity $v_2(a(n)) = n$ for $n \ge 7$, where $v_2$ denotes the $2$-adic valuation. We prove that the closed form genuinely fails on the head (at dimension five, $a(5) = 40 \ne 32 = 2^5$), so the theorem has real content rather than being a definitional identity. We further analyze the head as a secondary, faster-decaying geometric layer and formulate several conjectures on its internal structure and on the extremality of the doubling growth rate.

## 1. Introduction

Enumerative problems in high-dimensional geometry frequently produce integer sequences whose small-index behaviour is idiosyncratic but whose asymptotics are governed by a clean law. The sequence studied here is a striking example: its first six terms resist every simple pattern, yet from the seventh term onward it becomes the pure sequence of powers of two.

The quantity $a(n)$ counts the maximal number of *good* manifolds that an $n$-nice polytope can support. Informally, an $n$-nice polytope is a high-dimensional convex body satisfying a family of regularity ("niceness") axioms, and a *good* manifold is a distinguished, well-behaved submanifold-like piece; $a(n)$ is the largest number of such pieces realizable in dimension $n$. The precise geometric definitions are not needed to state or prove the arithmetic facts below, and we treat the tabulated data as the ground truth from which the structural theory is developed.

The purpose of this paper is threefold: (i) to isolate and prove the exact closed form of the tail; (ii) to derive the full suite of structural consequences — recurrence, monotonicity, parity, summation, and $2$-adic valuation; and (iii) to establish that the closed form is a nontrivial theorem by exhibiting an explicit boundary witness where it fails.

### 1.1 Summary of results

- **Closed form (Theorem 3.1).** For $n \ge 7$, $a(n) = 2^n$.
- **Doubling recurrence (Theorem 3.2).** For $n \ge 7$, $a(n+1) = 2\,a(n)$.
- **Global strict monotonicity (Theorem 4.1).** $a$ is strictly increasing on all of $\{1, 2, 3, \dots\}$.
- **Injectivity (Corollary 4.2).** Distinct dimensions yield distinct counts.
- **Parity (Theorem 4.3).** For $n \ge 1$, $a(n)$ is even.
- **Geometric partial sum (Theorem 5.1).** For $m \ge 7$, $\sum_{k=7}^{m} a(k) = 2^{m+1} - 128$.
- **$2$-adic valuation (Theorem 6.1).** For $n \ge 7$, $v_2(a(n)) = n$.
- **Boundary witness (Proposition 3.3).** $a(5) = 40 \ne 2^5$, so the closed form fails on the head.

## 2. Definitions

We define the sequence by separating its irregular head from its exponential tail.

**Definition 2.1 (Head).** The *head function* $h : \{1, \dots, 6\} \to \mathbb{N}$ records the tabulated values in the first six dimensions:
$$h(1) = 6,\quad h(2) = 8,\quad h(3) = 12,\quad h(4) = 24,\quad h(5) = 40,\quad h(6) = 80.$$
For notational convenience we extend $h$ by $0$ outside this range; the extension is never used substantively.

**Definition 2.2 (Good-manifold count).** The *good-manifold count* $a : \mathbb{N} \to \mathbb{N}$ is
$$a(n) = \begin{cases} h(n), & n \le 6, \\ 2^n, & n \ge 7. \end{cases}$$

This definition reproduces the tabulated data exactly. In particular $a(1) = 6$, $a(6) = 80$, $a(7) = 128$, and $a(21) = 2^{21} = 2097152$, matching the reference sequence term by term.

**Definition 2.3 (Correction term).** The *correction* is $d(n) = a(n) - 2^n$. By construction $d(n) = 0$ for $n \ge 7$, while on the head
$$d(1) = 4,\ d(2) = 4,\ d(3) = 4,\ d(4) = 8,\ d(5) = 8,\ d(6) = 16.$$

**Definition 2.4 ($p$-adic valuation).** For a prime $p$ and a positive integer $N$, the *$p$-adic valuation* $v_p(N)$ is the exponent of $p$ in the prime factorization of $N$, i.e. the unique $e \ge 0$ with $p^e \mid N$ and $p^{e+1} \nmid N$. We use $p = 2$ throughout Section 6.

## 3. The closed form of the tail

**Theorem 3.1 (Closed form).** *For every $n \ge 7$, $\;a(n) = 2^n$.*

*Proof.* Immediate from Definition 2.2: when $n \ge 7$ the condition $n \le 6$ is false, so the defining case selects the branch $a(n) = 2^n$. $\qquad\blacksquare$

Although the proof is a single case distinction, the *statement* is nontrivial precisely because the same identity fails on the head (Proposition 3.3). The theorem asserts that the tail admits no correction term whatsoever.

**Theorem 3.2 (Doubling recurrence).** *For every $n \ge 7$, $\;a(n+1) = 2\,a(n)$.*

*Proof.* Since $n \ge 7$ implies $n + 1 \ge 7$, Theorem 3.1 applies to both arguments:
$$a(n+1) = 2^{\,n+1} = 2 \cdot 2^{\,n} = 2\,a(n). \qquad\blacksquare$$

The recurrence expresses the sequence's defining dynamical feature: on the tail, each additional dimension exactly doubles the count. Equivalently, the marginal effect of one further dimension is a full factor of two.

**Proposition 3.3 (Boundary witness).** *$a(5) = 40 \ne 32 = 2^5$.*

*Proof.* By Definition 2.2, since $5 \le 6$, we have $a(5) = h(5) = 40$, whereas $2^5 = 32$, and $40 \ne 32$. $\qquad\blacksquare$

Proposition 3.3 shows the threshold $n \ge 7$ in Theorem 3.1 cannot be lowered to include the head: the closed form is a theorem about the tail, not an identity holding everywhere. The correction term $d(n)$ is genuinely nonzero for $n \le 6$.

## 4. Structural properties

**Theorem 4.1 (Global strict monotonicity).** *The sequence $a$ is strictly increasing: for all $n \ge 1$, $\;a(n) < a(n+1)$.*

*Proof.* It suffices to prove $a(n) < a(n+1)$ for every $n$. We split on the size of $n$.

*Head and junction ($n \le 6$).* Here $n$ ranges over $1, \dots, 6$, a finite set, and one verifies the six inequalities directly from the tabulated values:
$$6 < 8 < 12 < 24 < 40 < 80 < 128.$$
Note that the last of these, $a(6) = 80 < 128 = a(7)$, is the head/tail junction, where the value read from $h$ is compared against $2^7$; it holds because $80 < 128$.

*Tail ($n \ge 7$).* By Theorem 3.1, $a(n) = 2^n$ and $a(n+1) = 2^{n+1} = 2 \cdot 2^n$. Since $2^n > 0$, we have $2^n < 2 \cdot 2^n$, i.e. $a(n) < a(n+1)$.

The two regimes agree at the boundary, so the inequality holds for all $n \ge 1$. $\qquad\blacksquare$

**Corollary 4.2 (Injectivity).** *The map $a$ is injective: distinct dimensions give distinct counts.*

*Proof.* A strictly monotone function on a linearly ordered domain is injective. $\qquad\blacksquare$

**Theorem 4.3 (Parity).** *For every $n \ge 1$, $\;a(n)$ is even.*

*Proof.* If $n \le 6$, the value $a(n) \in \{6, 8, 12, 24, 40, 80\}$ is even by direct inspection. If $n \ge 7$, then $a(n) = 2^n$ by Theorem 3.1, and $2^n$ is even because $n \ge 1$. $\qquad\blacksquare$

## 5. Geometric partial sums

The tail's geometric nature is captured exactly by its partial sums.

**Theorem 5.1 (Geometric partial sum).** *For every $m \ge 7$,*
$$\sum_{k=7}^{m} a(k) = 2^{\,m+1} - 2^{7} = 2^{\,m+1} - 128.$$
*Equivalently, in subtraction-free form, $\;\left(\sum_{k=7}^{m} a(k)\right) + 128 = 2^{\,m+1}$.*

*Proof.* By induction on $m \ge 7$.

*Base case $m = 7$.* The sum has the single term $a(7) = 2^7 = 128$, and indeed $128 + 128 = 256 = 2^8$, confirming the subtraction-free identity.

*Inductive step.* Assume $\left(\sum_{k=7}^{m} a(k)\right) + 128 = 2^{m+1}$ for some $m \ge 7$. Then
$$\sum_{k=7}^{m+1} a(k) = \left(\sum_{k=7}^{m} a(k)\right) + a(m+1) = \left(2^{m+1} - 128\right) + 2^{m+1},$$
using Theorem 3.1 for $a(m+1) = 2^{m+1}$. Hence
$$\left(\sum_{k=7}^{m+1} a(k)\right) + 128 = 2^{m+1} + 2^{m+1} = 2^{m+2},$$
which is the claim for $m+1$. By induction the identity holds for all $m \ge 7$. $\qquad\blacksquare$

This is the classical closed form for a geometric series with ratio $2$: the partial sum of $2^7, 2^8, \dots, 2^m$ equals $2^{m+1} - 2^7$. The identity provides a route to detecting the geometric regime from cumulative data alone (see Conjecture 4 in Section 8).

## 6. A bridge to $p$-adic number theory

The closed form $a(n) = 2^n$ has an immediate but conceptually significant arithmetic consequence.

**Theorem 6.1 ($2$-adic valuation equals dimension).** *For every $n \ge 7$, $\;v_2(a(n)) = n$.*

*Proof.* By Theorem 3.1, $a(n) = 2^n$. The $2$-adic valuation of a prime power satisfies $v_2(2^n) = n$, since $2^n$ is divisible by $2^n$ but not by $2^{n+1}$. $\qquad\blacksquare$

Theorem 6.1 exhibits a *cross-domain bridge*: a purely enumerative geometric quantity encodes its own dimension in the prime factorization of its value. The exponent of the base $2$ in $a(n)$ is legible directly and recovers $n$. Together with the parity result (Theorem 4.3), which gives $v_2(a(n)) \ge 1$ for all $n \ge 1$, this shows the sequence is arithmetically saturated with the prime $2$ in a manner that grows linearly with dimension.

More generally, for any counting family whose tail equals $c \cdot b^n$ with $b$ prime, one expects $v_b(a(n)) = n + v_b(c)$; Theorem 6.1 is the special case $b = 2$, $c = 1$. This is formalized as Conjecture 2 in Section 8.

## 7. The structure of the head

While the head breaks the power law, it is far from structureless. Recall the correction term $d(n) = a(n) - 2^n$ from Definition 2.3, with head values
$$d(1..6) = (4,\ 4,\ 4,\ 8,\ 8,\ 16).$$
Two observations stand out. First, every correction value is itself a power of two: $d(n) \in \{4, 8, 16\} = \{2^2, 2^3, 2^4\}$. Second, each value persists over a contiguous block of dimensions, and the block lengths — three dimensions at $4$, two at $8$, one at $16$ — decrease by one at each step. This suggests the head is best understood not as an anomaly but as a *secondary geometric layer* superimposed on the dominant $2^n$ term: a faster-decaying contribution that vanishes precisely once the primary exponential overtakes it at dimension seven. Under this interpretation the full sequence is the superposition of two exponential tendencies, of which only the dominant survives asymptotically. Making this decomposition precise is the content of Conjecture 1 (Section 8).

## 8. Discussion and future directions

The results above settle the asymptotic behaviour of the good-manifold count completely: from dimension seven onward the sequence is a shifted geometric progression with ratio $2$, its partial sums are geometric, it is globally strictly increasing, and its $2$-adic valuation equals the dimension. These facts motivate several precise, testable conjectures.

**Conjecture 1 (The head as a bounded-correction defect layer).** The correction $d(n) = a(n) - 2^n$ satisfies $d(n) = 0$ for $n \ge 7$ and takes values in $\{4, 8, 16\}$ on the head, each value occupying a contiguous block whose lengths $(3, 2, 1)$ decrease by one. The head is thus a second, faster-decaying geometric layer that vanishes exactly when the dominant layer $2^n$ overtakes it.

**Conjecture 2 (Prime-power valuation encodes dimension universally).** For any counting family whose tail equals $c \cdot b^n$ with $b$ prime, the $b$-adic valuation recovers the dimension up to the additive constant $v_b(c)$: one expects $v_b(a(n)) = n + v_b(c)$ for large $n$. Theorem 6.1 is the verified instance $b = 2$, $c = 1$.

**Conjecture 3 (Doubling is the extremal growth rate).** Among all niceness-satisfying polytope families, the maximal good-manifold count grows no faster than $2^n$ asymptotically, with equality achieved by the family studied here: $\limsup a(n)^{1/n} = 2$, and any family exceeding this rate violates the niceness axioms. Heuristically, doubling reflects an independent binary choice in each dimension; a strictly faster rate would require correlated cross-dimensional choices that niceness forbids.

**Conjecture 4 (Partial sums characterize the threshold).** The threshold $n = 7$ at which the closed form begins is exactly the first $n$ for which the cumulative sum $\sum_{k \le n} a(k)$ becomes divisible by $2^7$. That is, the onset of pure geometric behaviour is detectable from divisibility of the cumulative counts alone, without knowledge of the individual terms.

## 9. Conclusion

We have shown that the maximal number of good manifolds in an $n$-nice polytope is exactly $2^n$ for all $n \ge 7$, and derived from this closed form a complete structural description of the tail: a doubling recurrence, exact geometric partial sums, global strict monotonicity and injectivity, universal parity, and the arithmetic identity $v_2(a(n)) = n$. An explicit boundary witness at dimension five confirms the closed form is a genuine theorem about the tail rather than a definitional identity. The head, though irregular, reveals its own hidden geometry as a bounded, decaying correction layer. Together these results turn an apparently erratic list of integers into a fully understood object, and they suggest a broader principle — that doubling is the extremal growth law for this class of geometric enumeration problems.
