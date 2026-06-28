# Obstructions, Equivalences, and a Borel–Cantelli Heuristic for Brocard's Problem

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Number Theory)

## Abstract

Brocard's problem asks for all pairs of natural numbers $(n, m)$ satisfying the Diophantine equation $n! + 1 = m^2$. The only known solutions are $n = 4, 5, 7$, the so-called *Brown numbers*, and it is a famous open conjecture, due independently to Brocard (1876) and Ramanujan (1913), that no others exist. This paper assembles a multi-perspective, fully formalized treatment of the surrounding theory. We prove a sharp non-square result for factorials themselves — $n!$ is a perfect square iff $n \le 1$ — via Bertrand's postulate; we derive structural obstructions on any solution (oddness of the root, the factorization $(m-1)(m+1) = n!$, and a Wilson-theorem divisibility constraint forcing $m \ge p$ when $n = p-1$ is prime); we establish an exact geometric equivalence between Brown numbers and triangular factorial-eighths through the identity $8T_y + 1 = (2y+1)^2$; and we make the standard probabilistic finiteness heuristic rigorous by proving convergence of $\sum_n 1/\sqrt{n!}$ and deriving an abstract Borel–Cantelli theorem stating that, under the Brocard density model, only finitely many factorial-plus-one values are squares almost surely. We complement these structural results with an exhaustive, machine-checked verification that no Brown numbers other than $4, 5, 7$ occur below $1000$. All results are formally verified.

## 1. Introduction

### 1.1 The problem

For $n \in \mathbb{N}$ write $n! = \prod_{k=1}^{n} k$ for the factorial. **Brocard's problem** is the determination of all solutions $(n, m) \in \mathbb{N}^2$ of

$$n! + 1 = m^2. \tag{B}$$

Direct computation reveals three solutions:

$$4! + 1 = 25 = 5^2, \qquad 5! + 1 = 121 = 11^2, \qquad 7! + 1 = 5041 = 71^2.$$

The corresponding values $n = 4, 5, 7$ are the **Brown numbers**. The conjecture of Brocard and Ramanujan asserts these are the *only* solutions; it remains open despite extensive effort and verification past $n = 10^9$.

### 1.2 Contributions

This paper does not resolve the conjecture — no elementary obstruction is known — but provides a structured body of rigorous, formally verified results that illuminate it from four angles:

1. **A factorial non-square theorem** (Section 3). $n!$ is a perfect square iff $n \le 1$, with an analogous result for simultaneously square-and-triangular factorials.
2. **Structural obstructions** (Section 4). Any solution of (B) has odd $m$; satisfies $(m-1)(m+1) = n!$; and, when $n = p-1$ for a prime $p$, satisfies $p \mid m$, hence $m \ge p$ (Wilson's theorem).
3. **A geometric equivalence** (Section 5). For $n \ge 2$, $n!/8$ is triangular iff $n! + 1$ is square, with explicit triangular indices for the three Brown numbers.
4. **A rigorous probabilistic heuristic** (Section 6). The Brocard density series $\sum_n 1/\sqrt{n!}$ converges, and an abstract Borel–Cantelli theorem makes the standard finiteness heuristic precise as a measure-theoretic statement.

A finite, exhaustive computational verification (Section 7) confirms the absence of solutions below $1000$.

## 2. Preliminaries and Definitions

Throughout, $\mathbb{N} = \{0, 1, 2, \dots\}$ and $n!$ denotes the factorial.

**Definition 2.1 (Perfect square).** A natural number $m$ is a *perfect square* if there exists $k \in \mathbb{N}$ with $m = k^2$. We denote this predicate $\mathrm{IsSquare}(m)$.

**Definition 2.2 (Triangular number).** A natural number $m$ is *triangular* if $m = t(t+1)/2$ for some $t \in \mathbb{N}$. The $y$-th triangular number is $T_y := y(y+1)/2$.

**Definition 2.3 (Brown number).** A natural number $n$ is a *Brown number* if there exists $m$ with $n! + 1 = m^2$.

**Definition 2.4 (Brocard density and detection predicate).** The *Brocard density* of $n$ is the quantity $1/\sqrt{n!}$, the heuristic probability that a number of magnitude $n!$ is a perfect square. The boolean detection predicate used for exhaustive search is $\mathrm{isPerfectSquareB}(N) := (\lfloor\sqrt{N}\rfloor^2 = N)$, where $\lfloor\sqrt{\cdot}\rfloor$ is the integer square root.

We use three classical inputs without reproving them: **Bertrand's postulate** (for $k \ge 1$ there is a prime $p$ with $k < p \le 2k$), **Legendre's formula** for the $p$-adic valuation of $n!$, and **Wilson's theorem** ($(p-1)! \equiv -1 \pmod p$ for $p$ prime).

## 3. Factorials Are Almost Never Squares

We first dispose of the unshifted question, which has a clean and complete answer.

**Lemma 3.1 (Single-prime obstruction).** If $p$ is prime, $p \mid m$, and $p^2 \nmid m$, then $m$ is not a perfect square.

*Proof.* If $m = k^2$ then $p \mid k^2$, so by primality $p \mid k$, whence $p^2 \mid k^2 = m$, contradicting $p^2 \nmid m$. $\square$

**Lemma 3.2 (A prime dividing $n!$ exactly once).** If $p$ is prime with $p \le n < 2p$, then $p^2 \nmid n!$.

*Proof.* By Legendre's formula the exponent of $p$ in $n!$ is $\sum_{i \ge 1} \lfloor n/p^i \rfloor$. Since $n < 2p \le p^2$, all terms with $i \ge 2$ vanish, and $\lfloor n/p \rfloor = 1$ because $p \le n < 2p$. Thus the exponent is exactly $1 < 2$, so $p^2 \nmid n!$. $\square$

**Theorem 3.3 (`factorial_not_square_of_two_le`).** For $n \ge 2$, $n!$ is not a perfect square.

*Proof.* Apply Bertrand's postulate to $k = \lfloor n/2 \rfloor \ge 1$: there is a prime $p$ with $\lfloor n/2\rfloor < p \le 2\lfloor n/2\rfloor \le n$. Then $p \le n$, so $p \mid n!$ (Definition: $p$ is among the factors), and $n < 2p$, so by Lemma 3.2 $p^2 \nmid n!$. By Lemma 3.1, $n!$ is not a square. $\square$

**Theorem 3.4 (`factorial_square_iff_le_one`).** $n!$ is a perfect square iff $n \le 1$.

*Proof.* If $n \le 1$ then $n! = 1 = 1^2$. Conversely, if $n \ge 2$, Theorem 3.3 forbids it. $\square$

**Theorem 3.5 (`factorial_square_triangular_iff_le_one`).** $n!$ is simultaneously a perfect square and a triangular number iff $n \le 1$.

*Proof.* The forward direction follows from Theorem 3.4 applied to the square component. For $n \le 1$, $n! = 1 = 1^2 = T_1$, which is both. $\square$

The contrast with Brocard's problem is instructive: the $+1$ shift in (B) destroys precisely the single-prime parity obstruction that powers Theorem 3.3, which is why (B) admits sporadic solutions and resists an analogous argument.

## 4. Structural Obstructions on Solutions of (B)

We now record constraints that any solution of (B) must satisfy. These do not bound $n$ but sharply restrict the shape of $(n, m)$.

**Theorem 4.1 (`brocard_m_odd`).** If $n \ge 2$ and $n! + 1 = m^2$, then $m$ is odd.

*Proof.* For $n \ge 2$, $2 \mid n!$, so $n! + 1$ is odd; hence $m^2$ is odd, forcing $m$ odd. (Formally one reduces modulo $4$: $n!$ is divisible by $4$ for $n \ge 4$, and the small cases $n = 2, 3$ are checked directly, so $m^2 \equiv 1 \pmod 4$, which requires $m$ odd.) $\square$

**Theorem 4.2 (`brocard_factor`).** If $m \ge 1$ and $n! + 1 = m^2$, then $(m-1)(m+1) = n!$.

*Proof.* From $n! = m^2 - 1$ and the identity $m^2 - 1 = (m-1)(m+1)$ (valid in $\mathbb{N}$ for $m \ge 1$). $\square$

Theorem 4.2 recasts (B) as a factorization constraint: $n!$ must split as a product of two integers differing by exactly $2$. As $n$ grows, the prime factorization of $n!$ becomes increasingly rigid, and such near-equal factorizations become correspondingly rare — a structural intuition for finiteness.

**Theorem 4.3 (Wilson obstruction, `brocard_wilson_dvd`).** If $p$ is prime and $(p-1)! + 1 = m^2$, then $p \mid m$.

*Proof.* By Wilson's theorem, $(p-1)! \equiv -1 \pmod p$, so $p \mid (p-1)! + 1 = m^2$. Since $p$ is prime, $p \mid m^2 \Rightarrow p \mid m$. $\square$

**Corollary 4.4 (`brocard_wilson_ge`).** Under the hypotheses of Theorem 4.3, $m \ge p$.

*Proof.* By Theorem 4.3, $p \mid m$, and $m > 0$ (since $m^2 = (p-1)! + 1 \ge 2$), so $m$ is a positive multiple of $p$, giving $m \ge p$. $\square$

These obstructions are consistent with the known solutions and fire exactly when their hypotheses hold. For $n = 4 = 5 - 1$ with $5$ prime, Corollary 4.4 predicts $5 \mid m$; indeed $m = 5$. For $n = 7$, since $8$ is composite, Wilson does not apply, and indeed $m = 71$ is not divisible by $8$.

## 5. The Geometric Equivalence via Triangular Numbers

We reformulate (B) through figurate numbers. Recall $T_y = y(y+1)/2$.

**Lemma 5.1 (`two_mul_triangular`).** $2 T_y = y(y+1)$ for all $y$. *Proof.* $y(y+1)$ is even (consecutive integers), so the natural-number division in $T_y$ is exact. $\square$

**Lemma 5.2 (Octahedral identity, `eight_triangular_succ`).** $8 T_y + 1 = (2y+1)^2$ for all $y$.

*Proof.* Using Lemma 5.1, $8T_y = 4 \cdot 2T_y = 4y(y+1) = 4y^2 + 4y$, so $8T_y + 1 = 4y^2 + 4y + 1 = (2y+1)^2$. $\square$

**Theorem 5.3 (Geometric equivalence, `factorial_eq_eight_triangular_iff_brown`).** For $n \ge 2$, $n!/8$ is a triangular number if and only if $n! + 1$ is a perfect square. Moreover, in any solution the square root is the odd number $m = 2y + 1$, where $y$ is the triangular index.

*Proof.* ($\Rightarrow$) If $n!/8 = T_y$, then since $8 \mid n!$ for $n \ge 4$ we have $n! = 8T_y$, so $n! + 1 = 8T_y + 1 = (2y+1)^2$ by Lemma 5.2. ($\Leftarrow$) If $n! + 1 = m^2$ then $m$ is odd (Theorem 4.1), say $m = 2y+1$; then $n! = m^2 - 1 = (2y+1)^2 - 1 = 8T_y$ by Lemma 5.2, so $n!/8 = T_y$ is triangular. $\square$

**Theorem 5.4 (Explicit indices, `triangular_indices`).** The Brown numbers correspond to triangular indices $y = 2, 5, 35$:

$$\tfrac{4!}{8} = 3 = T_2,\quad \tfrac{5!}{8} = 15 = T_5,\quad \tfrac{7!}{8} = 630 = T_{35},$$

with square roots $m = 5, 11, 71$ recovered as $2y+1$.

**Proposition 5.5 (`no_triangular_witness_8_to_50`).** For $8 \le n \le 50$, $n!/8$ is not triangular (equivalently, $n$ is not a Brown number). *Proof.* Finite verification. $\square$

Theorem 5.3 establishes a faithful dictionary: Brown numbers are exactly the factorials whose eighth part is a perfect triangular array, under the index map $y \mapsto 2y+1$. The full classification ("only $y$ giving $2, 5, 35$") is precisely the open Brocard conjecture and is not claimed.

## 6. A Rigorous Borel–Cantelli Heuristic

The standard reason to *expect* finiteness is probabilistic. The perfect squares near $N$ are spaced $\approx 2\sqrt{N}$ apart, so a "random" integer of size $N = n!$ is a square with probability of order $1/\sqrt{N} = 1/\sqrt{n!}$. If these probabilities are summable, the Borel–Cantelli lemma predicts only finitely many hits. We make both halves rigorous.

**Theorem 6.1 (Convergence of the density series, `summable_inv_sqrt_factorial`).** The series $\displaystyle \sum_{n=0}^{\infty} \frac{1}{\sqrt{n!}}$ converges.

*Proof.* By the ratio test. The ratio of consecutive terms is

$$\frac{1/\sqrt{(n+1)!}}{1/\sqrt{n!}} = \frac{1}{\sqrt{n+1}} \to 0,$$

so for all sufficiently large $n$ (e.g. $n \ge 8$) the ratio is at most $2/3 < 1$, and the series converges. (Equivalently, $n! \ge 2^{n-1}$ gives the geometric domination $1/\sqrt{n!} \le \sqrt{2}\,(\sqrt 2)^{-n}$.) $\square$

**Corollary 6.2 (`summable_const_div_sqrt_factorial`).** For any constant $C \in \mathbb{R}$, $\sum_n C/\sqrt{n!}$ converges. *Proof.* Scalar multiple of a convergent series. $\square$

**Lemma 6.3 (Finite total mass, `tsum_ofReal_heuristic_ne_top`).** For $C \ge 0$, $\sum_{n} \mathrm{ofReal}\!\big(C/\sqrt{n!}\big) \ne \infty$ in the extended nonnegative reals $[0, \infty]$. *Proof.* The nonnegative real-valued series of Corollary 6.2 is summable, and the embedding $\mathbb{R}_{\ge 0} \to [0,\infty]$ preserves the (finite) sum. $\square$

We now state the central probabilistic theorem in full generality, over an arbitrary outer-measure / probability space, exposing the *only* non-rigorous modeling assumption — the density bound — as an explicit hypothesis.

**Theorem 6.4 (Brocard–Borel–Cantelli, `brocard_heuristic_finite`).** Let $\mu$ be an outer measure on a space $\alpha$, and let $(E_n)_{n \in \mathbb{N}}$ be a family of measurable sets modeling the events "$n! + 1$ is a perfect square." Suppose the Brocard density bound holds: there is $C \ge 0$ with

$$\mu(E_n) \le \mathrm{ofReal}\!\Big(\frac{C}{\sqrt{n!}}\Big) \quad \text{for all } n.$$

Then the set of points lying in infinitely many $E_n$ is $\mu$-null:

$$\mu\big(\{x : x \in E_n \text{ for infinitely many } n\}\big) = 0.$$

*Proof.* The classical Borel–Cantelli lemma states that if $\sum_n \mu(E_n) < \infty$ then $\mu(\limsup_n E_n) = 0$. By the density bound and monotonicity, $\sum_n \mu(E_n) \le \sum_n \mathrm{ofReal}(C/\sqrt{n!})$, which is finite by Lemma 6.3. Hence the hypothesis of Borel–Cantelli is met and the conclusion follows. $\square$

**Theorem 6.5 (Almost-sure finiteness, `brocard_heuristic_ae_finite`).** Under the hypotheses of Theorem 6.4, for $\mu$-almost every $x$ the set $\{n : x \in E_n\}$ is finite.

*Proof.* Finiteness of $\sum_n \mu(E_n)$ (as in Theorem 6.4) implies, by the measure-theoretic Borel–Cantelli, that almost every point belongs to only finitely many $E_n$. $\square$

Theorems 6.4–6.5 are *unconditional* as abstract measure statements. They do not prove Brocard's conjecture, because the modeling assumption $\mu(E_n) \lesssim 1/\sqrt{n!}$ — treating $n! + 1$ as random — is heuristic, not a theorem about the deterministic sequence $n!$. What they do establish rigorously is that the probabilistic intuition is internally consistent: *if* the events behave randomly with the natural density, finiteness is certain.

## 7. Exhaustive Computational Verification

While no finite search can settle (B), a complete verification over an initial range is a genuine theorem and a useful sanity check.

**Theorem 7.1 (`brocard_no_others_below_1000`).** The only Brown numbers $n < 1000$ are $4, 5, 7$. Equivalently, filtering $\{0, 1, \dots, 999\}$ by the predicate $\mathrm{isPerfectSquareB}(n! + 1)$ yields exactly $[4, 5, 7]$.

*Proof.* Exhaustive evaluation of a decidable predicate. The integer square root $\lfloor\sqrt{N}\rfloor$ is computable in time logarithmic in the number of bignum multiplications, so the test scales to $n!$ with thousands of digits ($999!$ has over $2500$ decimal digits). $\square$

This complements the structural results: Theorems 4.1–4.4 and 5.3 constrain *what a solution must look like*, while Theorem 7.1 certifies *that none exist* in an explicit range.

## 8. Discussion

The four perspectives reinforce one another. The factorial non-square theorem (Section 3) isolates exactly which mechanism the $+1$ shift breaks. The structural obstructions (Section 4) and the geometric equivalence (Section 5) translate (B) into factorization and figurate-number language, each making the rarity of solutions intuitively vivid without bounding $n$. The Borel–Cantelli analysis (Section 6) explains, rigorously at the level of the underlying analysis, *why* the community expects finiteness. And the computational verification (Section 7) grounds the whole picture in fact.

The persistent gap is that none of these tools bounds $n$. Every obstruction is a *necessary* condition that infinitely many candidates could in principle satisfy; the heuristic is *probabilistic*, not deterministic; and the search is *finite*. This is characteristic of Brocard's problem and of a broader family of factorial Diophantine equations where elementary methods richly describe solutions without enabling a classification.

## 9. Future Directions

Several concrete, falsifiable extensions emerge naturally.

- **General consecutive-factorial squares.** For fixed $d \ge 1$, classify when $n!\,(n+d)!$ is a perfect square; conjecturally this reduces to whether $\prod_{i=1}^{d}(n+i)$ is square. The case $d = 2$ (product never square) is the square case of the Erdős–Selfridge theorem.
- **Erdős–Selfridge for short blocks.** Prove for small fixed $k$ that $a(a+1)\cdots(a+k-1)$ is never a perfect square; the case $k = 2$ is elementary, with $k = 3, 4$ as targets.
- **Strengthened residue sieve.** Combine the Wilson-type and modular constraints across all primes $p \le n$ via the Chinese Remainder Theorem to quantify how few residues for $m$ survive, aiming at an unconditional finite candidate range.
- **Power variant.** Investigate $n! + 1 = m^k$ for $k \ge 3$, where odd $k$ yields a sharper sieve $m \equiv 1 \pmod p$ for primes $p \le n$.
- **The $n!\,m!$ locus.** Characterize all $(n, m)$ with $n \le m$ such that $n!\,m!$ is a perfect square, conjecturally governed by the squarefree part of the falling factorial $(n+d)!/n!$.

## 10. Conclusion

We have presented a coherent, formally verified body of theory surrounding Brocard's problem: a complete solution of the factorial non-square question, a suite of structural obstructions on hypothetical solutions, an exact geometric equivalence with triangular numbers, a rigorous probabilistic finiteness heuristic, and an exhaustive verification below $1000$. Together they delineate sharply both what is provable and where the genuine difficulty resides. The three Brown numbers $4, 5, 7$ remain, conjecturally, alone — and the gap between our rich partial understanding and a full proof is itself the most eloquent description of why Brocard's problem endures.
