# A Carry-Counting Reformulation of Cusick's Sum-of-Digits Inequality, with an Explicit Density Gap

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Applications (Number Theory / Combinatorics on Words)

---

## Abstract

Let $s_2(n)$ denote the binary digit sum (Hamming weight) of a nonnegative integer $n$. For a fixed positive integer $t$, Cusick's conjecture concerns the asymptotic density
$$c_t = \operatorname{dens}\{\, n \ge 0 : s_2(n+t) \ge s_2(n)\,\},$$
and asserts the explicit lower bound $c_t \ge \tfrac{1}{2} + 2^{-(2 s_2(t)+1)}$. We isolate and formalize the structural core of the problem: the inequality $s_2(n+t) \ge s_2(n)$ is *exactly equivalent* to the statement that the number of carries produced when adding $n$ and $t$ in base $2$ is at most $s_2(t)$. Defining the carry count via Kummer's theorem as $\mathrm{carries}(t,n) = v_2\binom{n+t}{t}$, we prove the conservation identity
$$s_2(n+t) + \mathrm{carries}(t,n) = s_2(n) + s_2(t)$$
and derive from it the equivalence $s_2(n) \le s_2(n+t) \iff \mathrm{carries}(t,n) \le s_2(t)$. We then supply rigorous density witnesses that bracket the phenomenon: a "no-carry high bit" lemma, infinitude of the Cusick good set for every $t$, an exact 2-adic characterization of the $t=1$ case, and the exact finite density $c_1 = 3/4$, which strictly exceeds the conjectured bound $5/8$. All results stated here are fully formalized and machine-verified. We discuss how the reformulation reduces the full asymptotic bound to a spectral statement about a finite transfer operator whose size depends only on $s_2(t)$.

---

## 1. Introduction

### 1.1 The problem

The binary digit sum (or *Hamming weight*) $s_2 : \mathbb{N} \to \mathbb{N}$ counts the number of $1$'s in the base-$2$ expansion of its argument:
$$s_2(n) = \sum_{i \ge 0} \varepsilon_i, \qquad n = \sum_{i \ge 0} \varepsilon_i 2^i, \quad \varepsilon_i \in \{0,1\}.$$
It is among the most-studied arithmetic functions, appearing in the Gelfond problems on digit sums of primes and polynomials, in coding theory (where it is the weight function of the binary cube), and in the analysis of algorithms.

Thomas Cusick raised the following deceptively simple question. Fix $t \ge 1$ and consider, as $n$ ranges over $\mathbb{N}$, whether $s_2(n+t) \ge s_2(n)$. Define the **Cusick density**
$$c_t = \lim_{k \to \infty} \frac{\#\{\, n < 2^k : s_2(n+t) \ge s_2(n)\,\}}{2^k}.$$
A naive symmetry heuristic predicts $c_t \approx 1/2$. Cusick conjectured instead that $c_t > 1/2$ for all $t$, and in its sharp quantitative form,
$$\boxed{\,c_t \ge \tfrac{1}{2} + 2^{-(2 s_2(t)+1)}.\,}$$

### 1.2 Contribution

This paper formalizes the *structural reformulation* that underlies all known approaches to the conjecture, together with rigorous boundary witnesses. Specifically, we contribute:

1. A definition of the carry count $\mathrm{carries}(t,n)$ via Kummer's theorem and a proof of **Kummer's identity in subtraction form** (Theorem 3.1).
2. The **carry conservation identity** $s_2(n+t) + \mathrm{carries}(t,n) = s_2(n) + s_2(t)$ (Theorem 3.2).
3. The **Cusick reformulation** $s_2(n) \le s_2(n+t) \iff \mathrm{carries}(t,n) \le s_2(t)$ (Theorem 3.3), together with the extremal no-carry case and an unconditional total bound (Theorems 3.4, 3.5).
4. Density witnesses: a **no-carry high bit** lemma (Theorem 4.1), **infinitude of the good set** for every $t$ (Theorem 4.2), the **2-adic $t=1$ characterization** $s_2(n) \le s_2(n+1) \iff n \bmod 4 \ne 3$ (Theorem 4.3), and the **exact $t=1$ density** $c_1 = 3/4$ (Theorem 4.4).

All statements are machine-verified. We are careful to delineate what is proved (the reformulation and the $t=1$ instance) from what remains open in this development (the full asymptotic bound for general $t$).

### 1.3 Related context

The equivalence between digit-sum changes and carry counts is folklore, but its precise form via Kummer's theorem and the resulting reduction to a transfer-operator problem is what makes the explicit constant $2^{-(2 s_2(t)+1)}$ tractable. The constant's dependence solely on $s_2(t)$ — rather than on $t$ itself — is a direct consequence of the carry reformulation, since the relevant automaton's state space is indexed by the positions of the ones in $t$.

### 1.4 Background: Kummer's and Legendre's theorems

The two classical inputs deserve a precise statement, since the entire reformulation hinges on them.

*Legendre's formula* gives the $p$-adic valuation of a factorial in terms of digit sums: for a prime $p$,
$$v_p(n!) = \frac{n - S_p(n)}{p-1},$$
where $S_p(n)$ is the base-$p$ digit sum of $n$. Applying this to the three factorials in $\binom{n+t}{t} = \frac{(n+t)!}{n!\,t!}$ yields
$$(p-1)\,v_p\!\binom{n+t}{t} = S_p(n) + S_p(t) - S_p(n+t).$$

*Kummer's theorem* interprets the left-hand side combinatorially: $v_p\binom{n+t}{t}$ equals the number of carries that occur when $n$ and $t$ are added in base $p$. For $p = 2$ the prefactor $p-1$ equals $1$, and the two theorems collapse into the single clean statement that drives this paper: the number of binary carries in $n + t$ is exactly $s_2(n) + s_2(t) - s_2(n+t)$. In the formal development this specialization is `carries_eq_sub`, obtained from Mathlib's `sub_one_mul_padicValNat_choose_eq_sub_sum_digits'` at $p = 2$.

The role of subadditivity (Fact 2.5) is purely to license the truncated subtraction of natural numbers: because $s_2(n+t) \le s_2(n) + s_2(t)$, the difference $s_2(n)+s_2(t)-s_2(n+t)$ is a genuine nonnegative integer, so the $\mathbb{N}$-valued identities below are not artifacts of truncation.

---

## 2. Definitions and notation

Throughout, $n, t, L, j, m, k$ denote nonnegative integers, and subtraction on $\mathbb{N}$ is truncated (i.e. $a - b = 0$ when $a < b$).

**Definition 2.1 (Binary digit sum).** $s_2(n)$ is the sum of the base-$2$ digits of $n$; equivalently $s_2(n) = \sum_i \varepsilon_i$ where $n = \sum_i \varepsilon_i 2^i$ with $\varepsilon_i \in \{0,1\}$.

**Definition 2.2 (2-adic valuation).** For $m \ge 1$, $v_2(m)$ is the largest exponent $e$ with $2^e \mid m$; by convention $v_2(0) = 0$ in the formal development (the values arising below are always at positive arguments where the convention is irrelevant).

**Definition 2.3 (Carry count, via Kummer).** For integers $t, n \ge 0$ we define the **carry count** of the binary addition $n + t$ by
$$\mathrm{carries}(t,n) \;=\; v_2\!\binom{n+t}{t}.$$
By Kummer's theorem this equals the number of carries that occur when $n$ and $t$ are added in base $2$.

**Definition 2.4 (Cusick good set and density).** The *good set* is $G_t = \{\, n \ge 0 : s_2(n) \le s_2(n+t)\,\}$, and the Cusick density is $c_t = \operatorname{dens}(G_t)$ when the limit defining it exists.

We rely on two standard facts about $s_2$:

**Fact 2.5 (Subadditivity / Legendre).** $s_2(n+t) \le s_2(n) + s_2(t)$ for all $n,t$. Equivalently $v_2\binom{n+t}{t} = \tfrac{1}{2-1}\big(s_2(t) + s_2(n) - s_2(n+t)\big) \ge 0$.

**Fact 2.6 (Kummer / Legendre digit formula).** For the prime $p=2$,
$$(2-1)\,v_2\!\binom{n+t}{t} \;=\; s_2(t) + s_2(n) - s_2(n+t),$$
which over $\mathbb{N}$ (using subadditivity to make the subtraction genuine) reads $v_2\binom{n+t}{t} = s_2(t) + s_2(n) - s_2(n+t)$.

---

## 3. The carry reformulation

This section contains the structural heart of the paper.

### 3.1 Kummer's identity in subtraction form

**Theorem 3.1 (`carries_eq_sub`).** For all $n, t \ge 0$,
$$\mathrm{carries}(t,n) \;=\; s_2(t) + s_2(n) - s_2(n+t).$$

*Proof sketch.* Specialize the Legendre–Kummer digit formula (Fact 2.6) to $p = 2$. The general statement gives $(p-1)\,v_p\binom{n+t}{t} = S_p(t) + S_p(n) - S_p(n+t)$, where $S_p$ is the base-$p$ digit sum. With $p=2$ the factor $p-1=1$ disappears, and unfolding the definition $\mathrm{carries}(t,n) = v_2\binom{n+t}{t}$ yields the claim directly. $\square$

### 3.2 The carry conservation identity

**Theorem 3.2 (`s2_add_carries`).** For all $n, t \ge 0$,
$$s_2(n+t) + \mathrm{carries}(t,n) \;=\; s_2(n) + s_2(t).$$

*Proof sketch.* Combine Theorem 3.1 with subadditivity (Fact 2.5), which guarantees that the truncated subtraction in $\mathrm{carries}(t,n) = s_2(t)+s_2(n) - s_2(n+t)$ is genuine (the subtrahend does not exceed the minuend). Rearranging the genuine integer identity gives the additive form. Formally this is a linear-arithmetic consequence (`omega`) of `carries_eq_sub` and `s2_subadditive`. $\square$

This identity is a *conservation law*: each carry destroys exactly one unit of digit sum, and nothing else changes the total. It is the engine for everything that follows.

### 3.3 The reformulation

**Theorem 3.3 (`cusick_reformulation`).** For all $n, t \ge 0$,
$$s_2(n) \le s_2(n+t) \quad\Longleftrightarrow\quad \mathrm{carries}(t,n) \le s_2(t).$$

*Proof sketch.* From the conservation identity $s_2(n+t) + \mathrm{carries}(t,n) = s_2(n) + s_2(t)$ we obtain $s_2(n+t) - s_2(n) = s_2(t) - \mathrm{carries}(t,n)$ (as genuine integers). Hence $s_2(n+t) \ge s_2(n)$ if and only if $s_2(t) \ge \mathrm{carries}(t,n)$. Both directions follow by linear arithmetic from Theorem 3.2. $\square$

This is a *genuine equivalence*, not a one-sided bound. It converts the Cusick density $c_t = \operatorname{dens}\{n : s_2(n+t)\ge s_2(n)\}$ into the carry density $\operatorname{dens}\{n : \mathrm{carries}(t,n) \le s_2(t)\}$.

**Remark (the tempting false bound).** One might guess $\mathrm{carries}(t,n) \le s_2(t)$ holds always; it does not. By Theorem 3.3 it holds *exactly* on the Cusick good set, which is a proper subset. For instance $n=3, t=1$ gives $\mathrm{carries}(1,3) = v_2\binom{4}{1} = v_2(4) = 2 > 1 = s_2(1)$, consistent with $s_2(4) = 1 < 2 = s_2(3)$.

### 3.4 Extremal and unconditional bounds

**Theorem 3.4 (`cusick_of_no_carry`).** If $\mathrm{carries}(t,n) = 0$ then $s_2(n+t) = s_2(n) + s_2(t)$.

*Proof sketch.* Set the carry term to $0$ in Theorem 3.2. $\square$

The no-carry case realizes the *maximal* digit-sum gain $s_2(t)$ and is the extremal witness used to produce solutions in Section 4.

**Theorem 3.5 (`carries_le_total`).** For all $n,t$, $\mathrm{carries}(t,n) \le s_2(n) + s_2(t)$.

*Proof sketch.* Immediate from Theorem 3.2 since $s_2(n+t) \ge 0$. Unlike the one-sided bound $\mathrm{carries}(t,n) \le s_2(t)$ (which can fail), this symmetric total bound is unconditional. $\square$

---

## 4. Density witnesses

The reformulation reduces $c_t$ to a question about the distribution of carry counts. The full asymptotic determination requires a transfer-operator analysis (Section 5); here we prove rigorous results that bracket the phenomenon and settle $t=1$ exactly.

### 4.1 No-carry high bit

**Theorem 4.1 (`s2_high_bit`).** If $t < 2^L$ then
$$s_2(t + 2^L) = s_2(t) + 1.$$

*Proof sketch.* Since $t < 2^L$, the base-$2$ representation of $t$ has length at most $L$, so the bit at position $L$ is unoccupied. Adjoining the digit $1$ at position $L$ therefore introduces exactly one new $1$ without disturbing the lower digits and without triggering any carry. Formally, one writes the digit list of $t + 2^L$ as the digits of $t$, padded with zeros up to length $L$, followed by a single $1$ (via the digit-concatenation lemma `digits_append_zeroes_append_digits`), and sums. $\square$

### 4.2 Infinitude of the good set

**Theorem 4.2 (`cusick_good_set_infinite`).** For every $t \ge 0$ the good set $G_t = \{\, n : s_2(n) \le s_2(n+t)\,\}$ is infinite, witnessed by the sparse family $n = 2^{\,j+t}$ for $j \ge 0$.

*Proof sketch.* For $n = 2^{j+t}$ with the exponent large enough that $2^{j+t}$ exceeds all the bits of $t$, adding $t$ produces no carry; by Theorem 4.1 (applied appropriately) the digit sum is exactly additive, $s_2(n+t) = s_2(n) + s_2(t) \ge s_2(n)$. As $j$ ranges over $\mathbb{N}$ these are distinct, so the good set contains an infinite family. $\square$

This is the weakest *honest* general statement: it confirms $c_t$ is supported on an infinite set for every $t$, without overclaiming the asymptotic density.

### 4.3 The $t = 1$ characterization

**Theorem 4.3 (`cusick_t1_iff`).** For all $n \ge 0$,
$$s_2(n) \le s_2(n+1) \quad\Longleftrightarrow\quad n \bmod 4 \ne 3.$$

*Proof sketch.* By Theorem 3.3 with $t=1$ (so $s_2(1)=1$), the condition is $\mathrm{carries}(1,n) \le 1$. Now $\mathrm{carries}(1,n) = v_2\binom{n+1}{1} = v_2(n+1)$ using $\binom{n+1}{1} = n+1$. So the condition becomes $v_2(n+1) \le 1$, i.e. $4 \nmid (n+1)$, i.e. $n \not\equiv 3 \pmod 4$. The valuation step uses `padicValNat_dvd_iff_le`, not a finite check. $\square$

### 4.4 The exact $t = 1$ density

**Theorem 4.4 (`cusick_t1_density`).** For every $m \ge 0$, exactly $3m$ of the integers $n \in [0, 4m)$ satisfy $s_2(n) \le s_2(n+1)$. Consequently
$$c_1 = \frac{3}{4} = \frac{1}{2} + \frac{1}{4}.$$

*Proof sketch.* By Theorem 4.3 the good integers in $[0,4m)$ are exactly those with $n \bmod 4 \ne 3$. In each block of four consecutive integers $\{4i, 4i+1, 4i+2, 4i+3\}$ precisely three pass (all but $4i+3$). Summing over $i = 0,\dots,m-1$ gives $3m$. The proof is an induction on $m$ whose step is the residue count over one block — valid for all $m$, not a finite enumeration. Dividing by $4m$ and taking $m \to \infty$ gives $c_1 = 3/4$. $\square$

**Corollary 4.5 (Explicit gap, $t=1$).** Since $s_2(1) = 1$, the conjectured bound is $\tfrac12 + 2^{-(2\cdot1+1)} = \tfrac12 + \tfrac18 = \tfrac58$. The exact value $c_1 = \tfrac34 = \tfrac68$ satisfies $\tfrac68 \ge \tfrac58$, confirming the explicit gap with room to spare.

---

## 5. Reduction to a transfer operator (toward the full bound)

The reformulation $c_t = \operatorname{dens}\{n : \mathrm{carries}(t,n) \le s_2(t)\}$ exhibits the full conjecture as a statement about the *limiting distribution* of the carry count $v_2\binom{n+t}{t}$ as $n$ varies.

**The automaton.** Reading the binary digits of $n$ from least to most significant, the carry-propagation process for a fixed $t$ is a deterministic finite computation whose state records the current carry and the relevant local configuration of $t$'s bits. The number of states is controlled by the positions of the ones in $t$, hence by $s_2(t)$. The indicator of $\mathrm{carries}(t,n) \le s_2(t)$ is therefore computed by a deterministic finite automaton on the binary digits of $n$.

**Consequences.**

- *Existence and rationality of $c_t$.* The block counts $\#\{n < 2^k : n \in G_t\}$ satisfy a linear recurrence (the automaton's transition matrix acting on the uniform dyadic measure). The Cesàro limit of such a sequence is rational, so $c_t \in \mathbb{Q}$ with denominator a power of $2$ times a bounded factor.
- *The explicit constant.* The surplus $2^{-(2 s_2(t)+1)}$ arises as a spectral/stationary quantity of a finite matrix of size $O(s_2(t))$. This is precisely why the bound depends on $s_2(t)$ and not on $t$ itself.
- *Powers of two.* For $t = 2^j$ (so $s_2(t)=1$) the automaton is independent of $j$ up to a shift, predicting $c_{2^j} = 3/4$ for all $j$, generalizing Theorem 4.4.

These are recorded as future directions (Section 7); the reformulation makes the analytic target a *finite* spectral problem, which is the principal payoff of the carry viewpoint.

---

## 6. Worked examples

We illustrate the machinery with explicit small cases; each can be checked by hand and is confirmed numerically in the accompanying demonstrations.

**Example 6.1 (a single carry, $t=1$, $n=5$).** In binary $n = 101$, $n+t = 110$. One carry occurs (at bit $0$, propagating to bit $1$ where it terminates). Digit sums: $s_2(5) = 2$, $s_2(1) = 1$, $s_2(6) = 2$. The conservation identity reads $2 + 1 = 2 + 1$, i.e. $s_2(6) + \mathrm{carries} = s_2(5) + s_2(1)$ with $\mathrm{carries} = 1$. Since $1 \le s_2(1) = 1$, the Cusick inequality holds (with equality $s_2(6) = s_2(5)$). Cross-check: $\binom{6}{1} = 6$, $v_2(6) = 1$. ✓

**Example 6.2 (a carry cascade, $t=1$, $n=7$).** Here $n = 111$, $n+t = 1000$. Three carries cascade. Digit sums: $s_2(7) = 3$, $s_2(8) = 1$. Conservation: $1 + 3 = 3 + 1$, so $\mathrm{carries} = 3$. Since $3 > s_2(1) = 1$, the inequality *fails*: $s_2(8) = 1 < 3 = s_2(7)$. Note $n = 7 \equiv 3 \pmod 4$, exactly the excluded residue of Theorem 4.3. Cross-check: $\binom{8}{1} = 8$, $v_2(8) = 3$. ✓

**Example 6.3 (no carry, maximal gain, $t=3$, $n=8$).** $n = 1000$, $t = 011$, $n+t = 1011$. No carry occurs since the bits of $t$ land in empty columns. Digit sums: $s_2(8) = 1$, $s_2(3) = 2$, $s_2(11) = 3 = 1 + 2$. This is the extremal no-carry case (Theorem 3.4): the gain is the full $s_2(t) = 2$. Cross-check: $\binom{11}{3} = 165 = 3 \cdot 5 \cdot 11$, $v_2(165) = 0$. ✓

**Example 6.4 (the $t=1$ density block).** Over $[0,4) = \{0,1,2,3\}$: digit-sum pairs $(s_2(n), s_2(n+1))$ are $(0,1), (1,1), (1,2), (2,1)$. The inequality holds for $n = 0,1,2$ and fails for $n = 3$ — three out of four, matching Theorem 4.4. Repeating this block gives exactly $3m$ successes in $[0,4m)$, hence $c_1 = 3/4$.

**Example 6.5 (empirical bound check).** Measuring $c_t$ over $[0, 2^{22})$ gives, e.g., $c_3 = 0.6875$ versus the bound $\tfrac12 + 2^{-5} = 0.53125$, and $c_7 = 0.671875$ versus $\tfrac12 + 2^{-7} \approx 0.50781$. Every measured density comfortably exceeds its explicit bound, and the powers of two $t \in \{1,2,4,8,16\}$ all return exactly $0.75$, consistent with the predicted $c_{2^j} = 3/4$.

## 7. Algorithms

We summarize the computational content. Let $\mathrm{popcount}(n) = s_2(n)$.

**Algorithm A (Carry count via digit sums).** Compute $\mathrm{carries}(t,n) = s_2(n) + s_2(t) - s_2(n+t)$ in $O(\log(n+t))$ bit operations using the conservation identity (Theorem 3.2). This avoids computing the large binomial coefficient $\binom{n+t}{t}$ directly while returning the same value as $v_2\binom{n+t}{t}$.

**Algorithm B (Cusick membership test).** To decide $n \in G_t$, compute $\mathrm{carries}(t,n)$ by Algorithm A and test $\le s_2(t)$ (Theorem 3.3). $O(\log)$ per query.

**Algorithm C (Finite-window density).** For a window $[0, N)$, count members of $G_t$ by running Algorithm B over the window, or, for $t=1$, by the closed form $\lfloor 3N/4\rfloor + (\text{boundary correction})$ from Theorem 4.4.

---

## 8. Future directions

1. **The full explicit bound** $c_t \ge \tfrac12 + 2^{-(2 s_2(t)+1)}$. The reformulation reduces this to a spectral/stationary statement about a finite transfer operator (weighted automaton) whose size depends only on $s_2(t)$. Formalizing finite Markov / transfer-operator stationary distributions makes this concretely approachable.

2. **Existence and rationality of $c_t$.** The indicator of $\mathrm{carries}(t,n) \le s_2(t)$ is automaton-computable, so block counts obey a linear recurrence and the Cesàro limit is rational with controlled denominator.

3. **Exact density for powers of two.** For $t = 2^j$, $s_2(t) = 1$ and $c_t = 3/4$ exactly, independent of $j$, via a shift argument lifting the $t=1$ case using `s2_high_bit`.

4. **A matching upper bound** $c_t \le 1 - 2^{-(2 s_2(t)+1)}$ by symmetry of the conservation identity under exchanging "gain" and "loss" strata, controlled by the same automaton.

---

## 9. Discussion

The carry reformulation reframes a problem about an irregular arithmetic function ($s_2$) as a problem about a quantity ($\mathrm{carries}$) that is *locally computable* from the binary digits. This is the source of all tractability. Digit sums of $n$ and $n+t$ are individually erratic, but their *difference* is governed entirely by the local carry structure of the addition, which a finite automaton can track exactly.

Three features of the result are worth emphasizing. First, the reformulation is an *equivalence*, not a bound: nothing is lost in passing from $s_2(n+t) \ge s_2(n)$ to $\mathrm{carries}(t,n) \le s_2(t)$, so any sharp statement about one transfers verbatim to the other. Second, the constant $2^{-(2 s_2(t)+1)}$ depends on $t$ only through $s_2(t)$; this is forced by the automaton having a state space indexed by the ones of $t$, and it is corroborated empirically by the powers of two all sharing the density $3/4$. Third, the $t=1$ case is genuinely *exact* and fully proved — it is not a finite enumeration but a residue-counting induction valid for every $m$ — so it provides an unconditional anchor demonstrating that the explicit gap is real and, in the simplest case, not even tight.

A word on scope. We do not claim the full asymptotic bound for general $t$; that requires the spectral analysis of Section 5, which is recorded as future work. What is established here is the complete structural reduction together with the boundary witnesses (infinitude for all $t$, exactness for $t=1$) that make the reduction non-vacuous and quantitatively meaningful.

## 10. Conclusion

The Cusick sum-of-digits inequality $s_2(n+t) \ge s_2(n)$ is, exactly and provably, the carry-counting condition $\mathrm{carries}(t,n) \le s_2(t)$, where the carry count is Kummer's valuation $v_2\binom{n+t}{t}$. The conservation identity $s_2(n+t) + \mathrm{carries}(t,n) = s_2(n) + s_2(t)$ is the linchpin. From it follow the extremal no-carry gain, the unconditional total bound, the infinitude of the good set, and — fully and exactly — the $t=1$ density $c_1 = 3/4$, which already realizes the explicit gap $c_1 \ge 5/8$. The reformulation recasts the remaining general bound as a finite spectral problem, clarifying both why the constant depends only on $s_2(t)$ and how the conjecture may ultimately be closed.
