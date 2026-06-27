# Explicit Bias and Pure Periodicity for the Cusick Density of the Binary Digit Sum

**Author:** Aristotle

**Date:** 2026-06-27

## Abstract

Let $s_2(n)$ denote the binary sum-of-digits function (the number of ones in the
base-$2$ expansion of $n$). For a fixed shift $t \ge 1$, Cusick's density is the
asymptotic frequency

$$ c_t \;=\; \lim_{N\to\infty} \frac{1}{N}\,\#\bigl\{\,0 \le n < N : s_2(n) \le s_2(n+t)\,\bigr\}. $$

Cusick conjectured, and Drmota–Kauers–Spiegelhofer (2016) proved, that
$c_t \ge \tfrac12 + 2^{-(2 s_2(t)+1)}$ for every $t$. This paper develops a
self-contained, machine-verified theory of the *structural backbone* of this
phenomenon. We establish: (i) the foundational arithmetic of $s_2$ — Legendre's
additive formula $s_2(n) + v_2(n!) = n$, subadditivity $s_2(a+b) \le s_2(a)+s_2(b)$,
and the exact dyadic block average; (ii) the Kummer reformulation expressing the
Cusick inequality as a carry-budget condition $\mathrm{carries}(t,n) \le s_2(t)$;
(iii) a doubling invariance yielding $c_{2^k} = 3/4$ for all $k$; (iv) the exact
values $c_1 = 3/4$ and $c_3 = 11/16$ via residue counting; and (v) the central
*pure periodicity theorem*: for every $t$, the Cusick predicate depends only on
$n \bmod 2^{L + s_2(t)}$ (where $t < 2^L$), forcing $c_t$ to be a dyadic rational
and giving an exact period-scaling identity. From (v) we extract an explicit-bias
*propagation engine*: any finite per-period surplus $d$ over period $P$ propagates
to the uniform bound $c_t \ge 1/2 + d/P$ across all windows. All results have been
formalized and verified in Lean 4 with Mathlib; we present mathematical statements
and proof sketches.

## 1. Introduction

### 1.1 The problem

The binary sum-of-digits function $s_2 : \mathbb{N} \to \mathbb{N}$ counts the
ones in a number's binary expansion. Adding a fixed shift $t$ perturbs this count
in a way governed entirely by carry propagation: a long run of trailing ones can
collapse into a single higher one, sharply decreasing the digit sum, while in the
absence of carries the digit sums simply add.

Thomas Cusick asked: for fixed $t$, what is the density of $n$ for which adding
$t$ does not decrease the digit sum? Writing the **Cusick predicate**

$$ P_t(n) \;:\equiv\; \bigl(s_2(n) \le s_2(n+t)\bigr), $$

the density in question is $c_t = \mathrm{dens}\,\{ n : P_t(n) \}$. The naive
expectation $c_t = 1/2$ — that gains and losses cancel — is *wrong*: the density is
always strictly above $1/2$. Cusick conjectured the explicit lower bound

$$ c_t \;\ge\; \frac12 + 2^{-(2 s_2(t)+1)}, \tag{$\star$} $$

later proved by Drmota, Kauers, and Spiegelhofer using transfer-operator and
automaton methods. The bias term decays with the binary weight $s_2(t)$ but is
never zero.

### 1.2 Contributions

This paper isolates and rigorously establishes the *elementary, structural* layer
beneath ($\star$). The full asymptotic bound for arbitrary $t$ requires deep
analytic machinery, but a great deal can be proved by hand — and we prove all of
it, with complete formal verification:

1. **Foundations (§2).** Legendre's additive identity, subadditivity of $s_2$, and
   the exact dyadic block sum $\sum_{x<2^k} s_2(x) = k\,2^{k-1}$, pinning the mean
   of $s_2$ at $k/2$.

2. **Carry reformulation (§3).** Via Kummer's theorem, $P_t(n)$ is *equivalent* to
   the carry-budget condition $\mathrm{carries}(t,n) \le s_2(t)$, where
   $\mathrm{carries}(t,n) = v_2\binom{n+t}{t}$.

3. **Doubling invariance (§4).** $P_t$ is invariant under $(n,t)\mapsto(2n,2t)$ on
   each parity fibre, giving the count self-similarity
   $\mathrm{cusickCount}(2t,2N) = 2\,\mathrm{cusickCount}(t,N)$ and hence
   $c_{2^k} = 3/4$ for every $k$.

4. **Exact small densities (§5).** $c_1 = 3/4$ and $c_3 = 11/16$, each via a
   pointwise residue criterion and an induction-on-windows count (not a finite
   enumeration).

5. **Pure periodicity and rationality (§6).** For every $t \ge 1$ with $t < 2^L$,
   $P_t$ is purely periodic with period $2^{L+s_2(t)}$; consequently $c_t$ is a
   dyadic rational and counts scale exactly across periods.

6. **Propagation engine (§7).** A single finite per-period surplus $d$ propagates
   to the uniform explicit bias $c_t \ge 1/2 + d/P$, separating the finite
   per-shift computation from the universal scaling.

Throughout, $v_2(m)$ denotes the $2$-adic valuation (the exponent of the largest
power of $2$ dividing $m$), and $\mathbb{N} = \{0,1,2,\dots\}$.

## 2. Foundations: the binary digit sum

**Definition 2.1 (Binary digit sum).** For $n \in \mathbb{N}$, define
$s_2(n) = \sum_i d_i$ where $n = \sum_i d_i 2^i$ is the binary expansion
($d_i \in \{0,1\}$). Equivalently $s_2(n)$ is the sum of the base-$2$ digits of
$n$. Immediately $s_2(0) = 0$, $s_2(1) = 1$, and $s_2(n) \le n$.

**Theorem 2.2 (Legendre's formula, additive form).** For all $n$,

$$ s_2(n) + v_2(n!) = n. $$

*Proof sketch.* Legendre's classical formula states
$(p-1)\,v_p(n!) = n - s_p(n)$ for the base-$p$ digit sum $s_p$. At $p = 2$ this is
$v_2(n!) = n - s_2(n)$; rearranging and using $s_2(n) \le n$ to keep the
subtraction genuine yields the additive identity. $\square$

**Lemma 2.3 (Monotonicity of $v_2$ under divisibility).** If $m \mid k$ and
$k \ne 0$ then $v_2(m) \le v_2(k)$.

*Proof sketch.* From $2^{v_2(m)} \mid m \mid k$ and the characterization
$2^e \mid k \iff e \le v_2(k)$ for $k \ne 0$. $\square$

**Theorem 2.4 (Subadditivity).** For all $a, b$,

$$ s_2(a+b) \;\le\; s_2(a) + s_2(b). $$

*Proof sketch.* The binomial coefficient $\binom{a+b}{a} = (a+b)!/(a!\,b!)$ is an
integer, so $a!\,b! \mid (a+b)!$. By Lemma 2.3,
$v_2(a!) + v_2(b!) = v_2(a!\,b!) \le v_2((a+b)!)$. Apply Theorem 2.2 three times
(to $a$, $b$, and $a+b$) and eliminate the valuations: the inequality
$v_2((a+b)!) \ge v_2(a!)+v_2(b!)$ becomes $s_2(a+b) \le s_2(a)+s_2(b)$. $\square$

Subadditivity is tight: $a = b = 1$ gives $s_2(2) = 1 = s_2(1)+s_2(1) - 1$, indeed
$s_2(2) = 1 \le 2$. The special case $s_2(n+1) \le s_2(n)+1$ — adding one increases
the weight by at most one — is used repeatedly below.

**Theorem 2.5 (Exact dyadic block average).** For all $k$,

$$ \sum_{x=0}^{2^k - 1} s_2(x) \;=\; k \cdot 2^{\,k-1}. $$

Equivalently the mean of $s_2$ over $[0, 2^k)$ is exactly $k/2$: on average half
the bits are set. This is the quantitative reason $c_t$ sits near $1/2$, with the
entire content of ($\star$) living in the *bias* away from this baseline.

## 3. The carry reformulation (Kummer)

**Definition 3.1 (Carry count).** For shift $t$ and integer $n$, define the
**carry count** of the binary addition $n + t$ by

$$ \mathrm{carries}(t,n) \;=\; v_2\!\binom{n+t}{t}. $$

By Kummer's theorem, this equals the number of carries that occur when adding $n$
and $t$ in base $2$.

**Theorem 3.2 (Kummer, subtraction form).** For all $n, t$,

$$ \mathrm{carries}(t,n) \;=\; s_2(t) + s_2(n) - s_2(n+t). $$

*Proof sketch.* Kummer's theorem for $p = 2$ states
$v_2\binom{n+t}{t} = \bigl(s_2(t) + s_2(n) - s_2(n+t)\bigr)/(2-1)$, i.e. exactly
the right-hand side, the subtraction being genuine by Theorem 2.4. $\square$

**Theorem 3.3 (Additive carry identity).** For all $n, t$,

$$ s_2(n+t) + \mathrm{carries}(t,n) \;=\; s_2(n) + s_2(t). $$

*Proof sketch.* Immediate from Theorem 3.2 together with subadditivity (Theorem
2.4), which guarantees $s_2(n+t) \le s_2(n)+s_2(t)$ so the subtraction in 3.2 does
not truncate. $\square$

**Theorem 3.4 (Cusick inequality as carry counting).** For all $n, t$,

$$ s_2(n) \le s_2(n+t) \quad\Longleftrightarrow\quad \mathrm{carries}(t,n) \le s_2(t). $$

*Proof sketch.* Rearrange the additive identity 3.3: $s_2(n+t) - s_2(n) = s_2(t) -
\mathrm{carries}(t,n)$, so the left side is $\ge 0$ iff $\mathrm{carries}(t,n) \le
s_2(t)$. $\square$

This is the conceptual pivot of the whole subject: a question about digit-sum
*inequalities* becomes a question about *counting carries against a budget* of
$s_2(t)$.

**Corollary 3.5 (No-carry extremal case).** If $\mathrm{carries}(t,n) = 0$ then
$s_2(n+t) = s_2(n) + s_2(t)$ (maximal gain). In particular $P_t(n)$ holds.

**Remark 3.6.** The one-sided bound $\mathrm{carries}(t,n) \le s_2(t)$ can *fail*:
e.g. $n=3, t=1$ gives $\mathrm{carries} = 2 > 1 = s_2(1)$ (and indeed
$s_2(4) = 1 < 2 = s_2(3)$). Only the symmetric total bound
$\mathrm{carries}(t,n) \le s_2(n) + s_2(t)$ is unconditional. Failure of the
one-sided bound is *exactly* the failure of the Cusick inequality, by Theorem 3.4.

## 4. Doubling invariance and the powers of two

The digit sum interacts simply with appending a low bit.

**Lemma 4.1 (Low-bit recursion).** $s_2(2n) = s_2(n)$ and $s_2(2n+1) = s_2(n)+1$.

**Theorem 4.2 (Doubling invariance).** For all $n, t$:

$$ s_2(2n) \le s_2(2n+2t) \iff s_2(n) \le s_2(n+t), $$
$$ s_2(2n+1) \le s_2(2n+1+2t) \iff s_2(n) \le s_2(n+t). $$

*Proof sketch.* Write $2n + 2t = 2(n+t)$ and $2n+1+2t = 2(n+t)+1$ and apply Lemma
4.1 to both sides; both parity fibres collapse to the base predicate at $t$.
$\square$

**Definition 4.3 (Cusick count).** $\mathrm{cusickCount}(t, N) = \#\{\,n < N :
s_2(n) \le s_2(n+t)\,\}$.

**Theorem 4.4 (Count self-similarity).** For all $t, N$,

$$ \mathrm{cusickCount}(2t, 2N) \;=\; 2\,\mathrm{cusickCount}(t, N). $$

*Proof sketch.* Split $[0, 2N)$ into the even fibre $\{2j : j < N\}$ and the odd
fibre $\{2j+1 : j < N\}$. By Theorem 4.2, on each fibre the predicate $P_{2t}$ is
equivalent to $P_t(j)$, so each fibre contributes $\mathrm{cusickCount}(t,N)$.
$\square$

**Theorem 4.5 (Pointwise criterion for powers of two).**

$$ s_2(n) \le s_2(n + 2^k) \quad\Longleftrightarrow\quad (n / 2^k) \bmod 4 \ne 3. $$

*Proof sketch.* Write $n = 2^k q + r$ with $r < 2^k$; by digit concatenation
(Theorem 5.1 below) the predicate reduces to $P_1(q)$, then apply the $t=1$
criterion (Theorem 5.3). $\square$

**Theorem 4.6 (Density of power-of-two shifts).** For all $k, m$,

$$ \mathrm{cusickCount}(2^k,\; 2^{k+2} m) \;=\; 3\cdot 2^k\, m, $$

equivalently $c_{2^k} = 3/4$, with explicit bias $1/4$ above $1/2$.

*Proof sketch.* Induction on $k$. The base case $k = 0$ is $c_1 = 3/4$ (Theorem
5.4). The inductive step applies Theorem 4.4 with the doubled shift and window.
$\square$

**Theorem 4.7 (Full orbit invariance).** For all $k, t, N$,
$\mathrm{cusickCount}(2^k t, 2^k N) = 2^k\,\mathrm{cusickCount}(t, N)$. Hence $c_t$
depends only on the odd part of $t$; the density is constant along the doubling
orbit $\{t, 2t, 4t, \dots\}$.

## 5. Exact small densities

**Theorem 5.1 (Digit concatenation).** For $a < 2^M$,

$$ s_2(2^M b + a) \;=\; s_2(b) + s_2(a). $$

*Proof sketch.* Induction on $M$ using the low-bit recursion (Lemma 4.1): a block
$a$ of fewer than $M$ bits sits strictly below $b$, so the two digit strings
concatenate without interaction. $\square$

This lemma underlies the periodicity arguments: it lets any $n$ be split into a
low window $n \bmod 2^M$ (carrying the finite carry analysis) and an arbitrary
high part $n / 2^M$.

### 5.1 The shift $t = 1$

**Theorem 5.3 ($t=1$ criterion).**

$$ s_2(n) \le s_2(n+1) \quad\Longleftrightarrow\quad n \bmod 4 \ne 3. $$

*Proof sketch.* By Theorem 3.4 the condition is $\mathrm{carries}(1,n) \le s_2(1) =
1$. Since $\binom{n+1}{1} = n+1$, $\mathrm{carries}(1,n) = v_2(n+1)$. Thus the
condition is $v_2(n+1) \le 1$, i.e. $4 \nmid (n+1)$, i.e. $n \bmod 4 \ne 3$. $\square$

**Theorem 5.4 (Exact density $c_1 = 3/4$).** For all $m$,

$$ \#\{\,n < 4m : s_2(n) \le s_2(n+1)\,\} \;=\; 3m. $$

*Proof sketch.* By Theorem 5.3 the good $n$ are precisely those with $n \bmod 4 \ne
3$. Exactly $3$ of every $4$ residues qualify; a one-step induction on $m$ over the
block $[0,4m)$ gives $3m$. Hence $c_1 = 3/4 = 1/2 + 1/4$, exceeding the ($\star$)
floor $1/2 + 1/8 = 5/8$. $\square$

**Theorem 5.5 (Infinitude of the good set).** For every $t$, the set
$\{ n : s_2(n) \le s_2(n+t)\}$ is infinite.

*Proof sketch.* The sparse family $n = 2^{j+t}$ works: by the no-carry high-bit
lemma $s_2(t + 2^L) = s_2(t)+1$ for $t < 2^L$, one gets $s_2(2^{j+t}) = 1 \le s_2(t)
+ 1 = s_2(2^{j+t} + t)$ for all $j$, and $j \mapsto 2^{j+t}$ is injective. $\square$

### 5.2 The shift $t = 3$

**Theorem 5.6 ($t=3$ criterion).**

$$ s_2(n) \le s_2(n+3) \quad\Longleftrightarrow\quad n \bmod 16 \notin \{5,7,13,14,15\}. $$

*Proof sketch.* Split $n = 16b + a$, $a = n \bmod 16$; by concatenation (Theorem
5.1) $s_2(n) = s_2(b) + s_2(a)$. For the low residues $a \le 12$ the predicate
depends only on $a$ and is checked directly. For the overflow residues
$a \in \{13,14,15\}$, adding $3$ overflows the $16$-block; subadditivity
($s_2(b+1) \le s_2(b)+1$) shows the high part cannot recover the bits lost, so the
predicate fails for *every* $b$. The five bad residues are exactly $\{5,7,13,14,15\}$.
$\square$

**Theorem 5.7 (Exact density $c_3 = 11/16$).** For all $m$,

$$ \mathrm{cusickCount}(3, 16m) \;=\; 11m, $$

so $c_3 = 11/16$. The explicit bound holds with margin: $32\cdot
\mathrm{cusickCount}(3,16m) \ge 17\cdot 16m$, i.e. $c_3 = 11/16 = 22/32 \ge 17/32 =
1/2 + 2^{-(2 s_2(3)+1)}$, clearing the floor by $5/32$.

*Proof sketch.* By Theorem 5.6 the good $n$ avoid five residues mod $16$, leaving
$11$ of every $16$; induction on $m$ gives $11m$. $\square$

**Theorem 5.8 (Orbit density for $t=3$).** For all $k, m$,
$\mathrm{cusickCount}(2^k\cdot 3,\; 2^k\cdot 16m) = 2^k\cdot 11m$, so $c_{3\cdot
2^k} = 11/16$ for all $k$.

**Remark 5.9 (Density is not a function of $s_2(t)$).** We have $c_1 = 12/16$ and
$c_3 = 11/16$ with $s_2(1) = 1 \ne 2 = s_2(3)$; more strikingly, the catalog shows
two shifts of equal weight can have distinct densities. The density is sensitive to
the *gap structure* of the binary expansion, not merely the number of ones.

## 6. Pure periodicity and rationality

This section establishes the structural reason all Cusick densities are dyadic
rationals.

**Lemma 6.1 (All-ones digit sum).** $s_2(2^s - 1) = s$ (the $s$-bit all-ones
number has $s$ ones).

**Lemma 6.2 (Strict subadditivity on overflow).** If $a, t < 2^L$ and the
$L$-block overflows, $2^L \le a + t$, then there is at least one carry and

$$ s_2(a+t) \;<\; s_2(a) + s_2(t). $$

*Proof sketch.* The overflow $2^L \le a+t$ forces a carry out of the low $L$ bits,
so $\mathrm{carries}(t,a) \ge 1$; by the additive identity (Theorem 3.3) the digit
sum strictly drops. $\square$

**Lemma 6.3 (Overflow forces the predicate false).** Let $M = L + s_2(t)$ with
$t < 2^L$, $t \ge 1$. If the low $M$-bit window $a < 2^M$ overflows, $2^M \le a+t$,
then for *every* high part $b$,

$$ s_2(2^M b + a + t) \;<\; s_2(2^M b + a). $$

*Proof sketch.* Write $a = 2^L q + a_0$ with $a_0 < 2^L$, $q < 2^{s_2(t)}$. The
overflow $2^M = 2^L\cdot 2^{s_2(t)} \le a + t$ forces $q = 2^{s_2(t)} - 1$ (the
high block of the window is all ones) and $2^L \le a_0 + t$. By concatenation
(Theorem 5.1) and Lemma 6.1,

$$ s_2(2^M b + a) = s_2(b) + s_2(t) + s_2(a_0), $$

while adding $t$ carries through all $s_2(t)$ top ones of the window into the high
part:

$$ s_2(2^M b + a + t) = s_2(b+1) + s_2(r), \qquad r = a_0 + t - 2^L. $$

Strict subadditivity (Lemma 6.2) gives $s_2(a_0+t) < s_2(a_0)+s_2(t)$, and
$s_2(b+1) \le s_2(b)+1$ (subadditivity) bounds the high gain. Combining, the
"$+t$" side is strictly smaller for every $b$. $\square$

**Theorem 6.4 (Pure periodicity).** For every $t \ge 1$ and every $L$ with
$t < 2^L$, writing $P = 2^{L + s_2(t)}$,

$$ s_2(n) \le s_2(n+t) \quad\Longleftrightarrow\quad s_2(n \bmod P) \le s_2((n \bmod P) + t). $$

That is, the Cusick predicate $P_t$ depends only on $n \bmod P$.

*Proof sketch.* Write $n = P b + a$, $a = n \bmod P$. If the window overflows
($a + t \ge P$), Lemma 6.3 makes the predicate false for both $b$ and $b = 0$, so
the two sides agree (both false). If not ($a + t < P$), concatenation (Theorem 5.1)
gives $s_2(n) = s_2(b) + s_2(a)$ and $s_2(n+t) = s_2(b) + s_2(a+t)$, so the
predicate is $s_2(a) \le s_2(a+t)$, manifestly independent of $b$. $\square$

**Theorem 6.5 (Period scaling).** For all $t \ge 1$ with $t < 2^L$ and all $m$,

$$ \mathrm{cusickCount}(t,\; P\cdot m) \;=\; m \cdot \mathrm{cusickCount}(t,\; P), \qquad P = 2^{L+s_2(t)}. $$

Consequently $c_t = \mathrm{cusickCount}(t, P)/P$ is a **dyadic rational**.

*Proof sketch.* Induction on $m$. Each block $[Pm, P(m+1))$ contributes, by
periodicity (Theorem 6.4) applied residue-by-residue, the same count as the base
block $[0, P)$. $\square$

## 7. The explicit-bias propagation engine

The period-scaling identity converts a single finite computation into a uniform
asymptotic bound.

**Theorem 7.1 (Bias propagation).** Let $t \ge 1$, $t < 2^L$, $P = 2^{L+s_2(t)}$.
Suppose the one-period count beats half by $d$:

$$ 2\,\mathrm{cusickCount}(t, P) \;\ge\; P + 2d. $$

Then for every window count $m$,

$$ 2\,\mathrm{cusickCount}(t,\; P m) \;\ge\; P m + 2 d m, $$

equivalently $c_t \ge \tfrac12 + d/P$.

*Proof sketch.* Multiply the hypothesis by $m$ and substitute the period-scaling
identity (Theorem 6.5): $2\,\mathrm{cusickCount}(t,Pm) = 2m\,\mathrm{cusickCount}(t,P)
\ge m(P + 2d) = Pm + 2dm$. $\square$

This cleanly separates the two ingredients of an explicit Cusick bias bound: a
*finite* per-period computation producing the surplus $d$, and the *uniform*
propagation in $m$ (proved once, for all $t$). Instantiating:

- **$t = 1$:** $d = 1$, $P = 4$; $2\,\mathrm{cusickCount}(1,4m) \ge 4m + 2m$, i.e.
  $c_1 \ge 1/2 + 1/4$ (in fact equality).
- **$t = 3$:** $d = 3$, $P = 16$; $2\,\mathrm{cusickCount}(3,16m) \ge 16m + 6m$,
  i.e. $c_3 \ge 1/2 + 3/16$ (in fact equality, $c_3 = 11/16$).

The engine does *not* by itself prove $d > 0$ for general $t$ — that is the hard
Drmota–Kauers–Spiegelhofer content. It *propagates* any established per-period
bias, which is exactly the reusable infrastructure separating the finite checks
from the universal scaling.

## 8. Algorithms

We summarize the constructive content as algorithms; each is directly backed by a
theorem above. (Full type-hinted implementations accompany this paper.)

**Algorithm A (Digit sum).** Compute $s_2(n)$ by repeated division by $2$,
summing remainders. $O(\log n)$ operations.

**Algorithm B (Carry count via Kummer).** Compute $\mathrm{carries}(t,n) = s_2(t) +
s_2(n) - s_2(n+t)$ directly from three digit sums (Theorem 3.2), avoiding factorial
arithmetic. $O(\log(n+t))$.

**Algorithm C (Exact density via one period).** Given $t$, set $L = \lceil \log_2(t+1)
\rceil$ and $P = 2^{L + s_2(t)}$; count the good residues in $[0, P)$ and return the
exact rational $\mathrm{cusickCount}(t,P)/P$. Correct by pure periodicity (Theorem
6.4) and period scaling (Theorem 6.5). $O(P \log P)$.

**Algorithm D (Bias propagation).** Given a period surplus $d$, return the certified
window bound $2\,\mathrm{cusickCount}(t, Pm) \ge Pm + 2dm$ for all $m$ (Theorem 7.1).
$O(1)$ beyond the one-period count.

## 9. Applications and discussion

The binary digit sum is a hub connecting several areas. It defines the
**Thue–Morse sequence** $t_n = s_2(n) \bmod 2$, a paradigm of deterministic
pseudorandomness; the bias studied here is a quantitative manifestation of the
correlations that make Thue–Morse simultaneously balanced and structured. It
appears in **Gelfond-type** equidistribution of digit sums in arithmetic
progressions, and recent work on **primes with prescribed digit sums** builds on
the same transfer-operator technology behind ($\star$). The carry reformulation
(§3) connects directly to the analysis of **binary adder circuits**, where carry
chains determine latency, so carry statistics have algorithmic value.

Two methodological points deserve emphasis. First, the **carry reformulation** is
the conceptual fulcrum: it converts a digit-sum inequality into a countable
carry-budget condition, after which everything is combinatorics. Second, **pure
periodicity** is what makes the densities tractable and rational; it reduces an
asymptotic question to a single finite block, and the propagation engine packages
that reduction uniformly.

## 10. Future directions

The development proves the structural backbone and the exact densities $c_1 = 3/4$,
$c_3 = 11/16$, $c_{2^k} = 3/4$, plus pure periodicity and the propagation engine.
Several precise conjectures emerge for follow-up work; we record them below.

**Conjecture 1 (Bit-reversal symmetry).** For odd $t$ with binary digit string
$(t_{L-1}\cdots t_1 t_0)$ ($t_0 = t_{L-1} = 1$), let $\mathrm{rev}(t)$ reverse the
string. Then $c_t = c_{\mathrm{rev}(t)}$. Evidence: $c_{11} = c_{13} = 19/32$
($1011 \leftrightarrow 1101$), $c_{19} = c_{25} = 41/64$. A formalization path is a
measure-preserving bijection on residues mod $2^{L+s_2(t)}$ carrying $P_t$ to
$P_{\mathrm{rev}(t)}$, likely via the carry/Kummer reformulation.

**Conjecture 2 (Gap structure, not weight).** $c_t$ is a function of the multiset
of gaps between consecutive $1$-bits of the odd part of $t$, not of $s_2(t)$ alone.
Evidence: $c_3 \ne c_5$ (proved separately in the catalog); several weight-$3$
shifts are mutually distinct.

**Conjecture 3 (Gap-separation decoupling).** If $t = 2^a + 2^b$ with $a < b$ then
$c_t$ depends only on $b - a$, and $c_{2^a + 2^b} = 11/16$ as soon as $b - a \ge 3$.
More generally, when all gaps between $1$-bits of $t$ are $\ge G$, the bits
decouple and a product formula $c_t = 1 - (1 - c_{\text{single bit}})^{s_2(t)}$
holds.

**Conjecture 4 (All-ones is extremal at fixed weight).** Among all $t$ with
$s_2(t) = s$, the all-ones shift $t = 2^s - 1$ maximizes $c_t$. Evidence:
$c_7 = 43/64$ is the largest among weight-$3$ shifts sampled.

**Conjecture 5 (Closed form for the all-ones family).** Writing $c_{2^s-1} = 1/2 +
a_s/4^s$, the proved values give $a_1 = 1$, $a_2 = 3$, $a_3 = 11$, $a_4 = 43$ (from
$c_1 = 3/4$, $c_3 = 11/16$, $c_7 = 43/64$, $c_{15} = 171/256$), matching the
recurrence $a_{s+1} = 4 a_s - 1$. Equivalently the per-period counts
$3, 11, 43, 171$ over periods $4, 16, 64, 256$ each satisfy $\text{next} = 4\cdot
\text{prev} - 1$.

## 11. Conclusion

The Cusick density problem looks like a question about a coin flip, but the coin is
permanently loaded toward growth. We have given a complete, machine-verified
account of the elementary skeleton driving this bias: Legendre's factorial formula
and subadditivity of $s_2$; Kummer's carry reformulation turning the inequality
into a carry budget; a doubling symmetry that propagates $c_1 = 3/4$ to all powers
of two; exact densities $c_1 = 3/4$ and $c_3 = 11/16$; and the central pure
periodicity theorem forcing every $c_t$ to be a dyadic rational, packaged as a
finite-input, uniform-output bias-propagation engine. The deep asymptotic content
of ($\star$) for arbitrary $t$ remains the province of transfer-operator methods,
but its rational, periodic backbone is now fully and rigorously in hand.
