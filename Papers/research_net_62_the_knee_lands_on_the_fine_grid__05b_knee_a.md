# Grid Quantization of Threshold Measurements: Rounding, Resolution, and the Arithmetic of Sweep Design

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

We develop the arithmetic theory of measuring the crossing point ("knee") of a monotone profile by sampling it on a restricted set of budgets. Let $f : \mathbb{N} \to \mathbb{R}$ be nondecreasing, let $\tau$ be a gate met somewhere, and let $k^\ast = \min\{k : f(k) \ge \tau\}$ be the true knee. For an unbounded *sweep grid* $G \subseteq \mathbb{N}$ define the *reading* $\operatorname{read}_G(k) = \min\{g \in G : g \ge k\}$. Our first result, the **Measurement Theorem**, states that the knee obtained by sweeping only over $G$ equals $\operatorname{read}_G(k^\ast)$ exactly: a grid measurement is never an approximation with error, it is a deterministic rounding of the truth. We show $\operatorname{read}_G$ is a closure operator on $\mathbb{N}$ with fixed-point set $G$, and prove a **uniqueness theorem**: any inflationary, monotone, idempotent read-out whose fixed points are the grid *is* $\operatorname{read}_G$. Specialising, the doubling grid reads $k$ as $2^{\lceil \log_2 k\rceil}$ and is exact precisely when the base-two digit sum of $k$ is $1$; the step-$d$ arithmetic grid is exact precisely when $d \mid k$.

We then apply the theory to a concrete five-point measurement table for a top-$k$ attention-budget profile at context length $1024$, gate $0.98$:
$$f(4) = 0.8940,\quad f(8) = 0.9520,\quad f(12) = 0.9662,\quad f(20) = 0.9803,\quad f(24) = 0.9851.$$
We prove that (i) *every* nondecreasing profile matching these five values yields the sweep reading $20$, so the reported verdict is harness-independent; (ii) the same hypotheses force only $12 < k^\ast \le 20$; and (iii) this bracket is **tight** — for each $t \in (12, 20]$ an explicit matching profile has true knee $t$. Because the reported grid omits $16$, the values $k^\ast = 16$ and $k^\ast = 20$ are indistinguishable from the data. Consequently the deployment claim "$20$ keys suffice, $12$ do not" is fully certified, while the sharper claim that the budget chain $16 < 20 < 24$ across contexts $\{512, 1024, 2048\}$ is *strictly* increasing is not.

Finally we quantify sweep design. A step-$d$ sweep resolves $\lfloor N/d\rfloor$ of the budgets in $(0,N]$; a doubling sweep at most $\log_2 N + 1$, and can return at most $\lceil\log_2 N\rceil + 1$ distinct verdicts in total, forcing spurious plateaus in long chains. The arithmetic sweeps resolving $k$ are exactly the divisors of $k$, so resolution power is the divisor function $\tau$, which is non-monotone in the budget. The **GCD design principle** states that a step-$d$ sweep resolves a finite chain $K$ iff $d \mid \gcd K$; for $K = \{16, 20, 24\}$ this makes step $4$ the coarsest adequate sweep. A bridge result shows that the earlier reported misreading $112 \mapsto 128$ and the present $20 \mapsto 32$ are instances of a single theorem about binary staircase numbers $2^b(2^j - 1)$.

**Keywords:** grid rounding, closure operator, monotone threshold, base-two digit sum, divisor function, greatest common divisor, attention budget, experiment design.

---

## 1. Introduction

### 1.1 The empirical situation

A recurring quantity in the deployment of autoregressive sequence models is the *attention budget*: the number of past positions whose key–value pairs must be retained so that a prescribed fraction of attention mass is preserved. Concretely, at a given context length one sorts the attention weights in decreasing order, lets $f(k)$ denote the mass captured by the top $k$ of them, fixes a gate $\tau$ (here $\tau = 0.98$), and asks for
$$k^\ast \;=\; \min\{\, k \in \mathbb{N} : f(k) \ge \tau \,\}.$$
Since $f$ is nondecreasing and tends to $1$, this minimum exists and is the operationally relevant integer: it is the cache size one ships.

A sequence of measurements on a half-billion-parameter model produced an apparent inconsistency. Sweeping budgets over the doubling ladder $4, 8, 16, 32, \ldots$ at context $1024$ returned $32$. A later sweep, on the same model, corpus, gate and harness, over the arithmetic set $\{4, 8, 12, 20, 24\}$, returned $20$. Neighbouring context lengths $512$ and $2048$ returned $16$ and $24$. A second corpus at context $2048$ returned $32$, which had been read as evidence of corpus sensitivity.

The thesis of this paper is that none of these discrepancies requires an empirical explanation. Each is the exact, predictable output of an arithmetic operator applied to an unknown but fixed truth — and once that operator is identified, one can say in advance which claims a given sweep is capable of supporting and which it is not.

### 1.2 Contributions

1. **The Measurement Theorem** (§3): a grid measurement of a monotone threshold is *identically* the grid-rounding of the true knee.
2. **Structure and uniqueness of the read-out** (§2, §3.3): the reading operator is a closure operator with fixed-point set the grid, and is the unique such read-out.
3. **Exactness criteria** (§4): divisibility for arithmetic grids, base-two digit sum for the doubling grid; the explicit overstatement $2^{e+1} - k$; octave collapse.
4. **Analysis of the five-point table** (§5): forced reading $20$; the tight bracket $(12, 20]$; underdetermination at $16$; the two-valued fine-grid rounding.
5. **Resolution counting and design** (§6): $\lfloor N/d\rfloor$ versus $\log_2 N + 1$; the verdict bound; divisor-function resolution power; the GCD design principle.
6. **A unifying bridge** (§7): binary staircase numbers $2^b(2^j-1)$ with $j \ge 2$ are always read by a doubling sweep as $2^{b+j}$, subsuming $20 \mapsto 32$ and $112 \mapsto 128$.

Sections §8–§9 give algorithms, applications and open problems.

---

## 2. Grids and the reading operator

**Definition 2.1 (Sweep grid).** A *sweep grid* is a set $G \subseteq \mathbb{N}$ that is unbounded: for every $n$ there is $m \in G$ with $n \le m$. We write $G_{\ge k} = \{g \in G : g \ge k\}$, which is nonempty by unboundedness.

**Definition 2.2 (Reading).** The *grid reading* of $k \in \mathbb{N}$ is
$$\operatorname{read}_G(k) \;=\; \min\, G_{\ge k} \;=\; \min\{\, g \in G : k \le g \,\}.$$

Two grids concern us throughout.

**Definition 2.3.** For $d \ge 1$, the *arithmetic grid* $A_d = \{n : d \mid n\}$ is the set of multiples of $d$. The *dyadic grid* $D = \{2^e : e \ge 0\}$ is the set of powers of two.

Both are unbounded ($d \cdot n \ge n$; $2^n > n$).

**Proposition 2.4 (Basic properties).** For every grid $G$:

1. *(Membership)* $\operatorname{read}_G(k) \in G$ and $k \le \operatorname{read}_G(k)$ (**inflationary**: a sweep never under-reports).
2. *(Minimality)* If $g \in G$ and $k \le g$ then $\operatorname{read}_G(k) \le g$.
3. *(Fixed points)* $\operatorname{read}_G(k) = k \iff k \in G$.
4. *(Monotonicity)* $k \le k' \implies \operatorname{read}_G(k) \le \operatorname{read}_G(k')$.
5. *(Idempotence)* $\operatorname{read}_G(\operatorname{read}_G(k)) = \operatorname{read}_G(k)$.
6. *(Refinement)* If $H \subseteq G$ (so $H$ is the coarser sweep) then $\operatorname{read}_G(k) \le \operatorname{read}_H(k)$: refining a sweep never increases the reported value.

*Proof sketch.* (1) and (2) are the defining properties of a least element of $G_{\ge k}$. (3): if $\operatorname{read}_G(k) = k$ then $k \in G$ by (1); conversely if $k \in G$, then $k \in G_{\ge k}$, so minimality gives $\operatorname{read}_G(k) \le k$, and (1) gives the reverse. (4): $\operatorname{read}_G(k')$ lies in $G$ and dominates $k' \ge k$, so apply (2). (5) is (3) applied to $\operatorname{read}_G(k) \in G$. (6): $\operatorname{read}_H(k) \in H \subseteq G$ and dominates $k$; apply (2). $\square$

Items (1), (4), (5) say precisely that $\operatorname{read}_G$ is a **closure operator** on the poset $(\mathbb{N}, \le)$, and (3) identifies its closed elements as $G$. This structural fact is the source of everything that follows.

**Proposition 2.5 (Collapse).** If $k \le k'$ and $k' \le \operatorname{read}_G(k)$, then $\operatorname{read}_G(k) = \operatorname{read}_G(k')$.

*Proof.* Monotonicity gives $\le$; and $\operatorname{read}_G(k) \in G$ dominates $k'$, so minimality gives $\ge$. $\square$

In words: two true knees inside a single grid gap are reported identically. The contrapositive is worth isolating.

**Corollary 2.6 (Coarsening never invents separation).** If $\operatorname{read}_G(k) < \operatorname{read}_G(k')$ then $k < k'$.

*Proof.* If $k' \le k$, monotonicity would give $\operatorname{read}_G(k') \le \operatorname{read}_G(k)$. $\square$

Thus a strict increase visible in the readings is always a genuine strict increase of the truths. Resolution is lost by coarsening, never fabricated.

---

## 3. The Measurement Theorem

### 3.1 Statement

**Theorem 3.1 (Measurement Theorem).** Let $(\alpha, \le)$ be a linear order, $f : \mathbb{N} \to \alpha$ nondecreasing, and $\tau \in \alpha$ such that $f(k) \ge \tau$ for some $k$. Put $k^\ast = \min\{k : f(k) \ge \tau\}$. Then for every sweep grid $G$,
$$\min\{\, g \in G : f(g) \ge \tau \,\} \;=\; \operatorname{read}_G(k^\ast).$$

*Proof.* We show the two sets $\{g \in G : f(g) \ge \tau\}$ and $G_{\ge k^\ast}$ coincide; the claim then follows by taking minima. If $g \in G$ and $f(g) \ge \tau$, then $g$ belongs to the set defining $k^\ast$, hence $k^\ast \le g$. Conversely if $g \in G$ and $k^\ast \le g$, monotonicity gives $f(g) \ge f(k^\ast) \ge \tau$. $\square$

The proof is short; the content is conceptual. **A grid measurement carries no independent error term.** It is a function — the same function for every profile — of the true knee alone. Consequently:

**Corollary 3.2 (Exactness).** The swept measurement equals $k^\ast$ if and only if $k^\ast \in G$.

**Corollary 3.3 (Monotone refinement).** If $H \subseteq G$, the $G$-sweep never reports a larger knee than the $H$-sweep. In particular, when a fine sweep and a coarse sweep of the same profile disagree, the fine value is the smaller, and the difference is entirely accounted for by the grid gap.

### 3.2 Instantiation on attention budgets

If $w : \mathbb{N} \to \mathbb{R}_{>0}$ is a positive weight sequence over a window of length $n$, and $\operatorname{retained}(w, n, k)$ denotes the fraction of $\sum_{i<n} w(i)$ carried by the $k$ largest weights, then $k \mapsto \operatorname{retained}(w,n,k)$ is nondecreasing and reaches any gate $\tau \le 1$. Theorem 3.1 therefore applies verbatim: a top-$k$ sweep restricted to a grid $G$ reports $\operatorname{read}_G(k^\ast(w,n,\tau))$. No property of attention beyond monotonicity of the retained mass is used.

### 3.3 Uniqueness of the read-out

Could a smarter analysis of grid data recover more than the rounding? Not without extra hypotheses on $f$.

**Theorem 3.4 (Uniqueness).** Let $G$ be a sweep grid and $M : \mathbb{N} \to \mathbb{N}$ satisfy: (i) $k \le M(k)$ for all $k$; (ii) $M$ monotone; (iii) $M(M(k)) = M(k)$; (iv) $M(k) = k \iff k \in G$. Then $M = \operatorname{read}_G$.

*Proof.* Fix $k$. By (iii), $M(k)$ is a fixed point of $M$, so by (iv) $M(k) \in G$; and by (i) $M(k) \ge k$. Minimality gives $\operatorname{read}_G(k) \le M(k)$. Conversely $\operatorname{read}_G(k) \in G$, so by (iv) $M(\operatorname{read}_G(k)) = \operatorname{read}_G(k)$; monotonicity applied to $k \le \operatorname{read}_G(k)$ then gives $M(k) \le M(\operatorname{read}_G(k)) = \operatorname{read}_G(k)$. $\square$

Any proposed read-out must therefore violate one of the four axioms — for instance by sometimes under-reporting (risking a cache too small), by being non-monotone, by being unstable under re-measurement, or by being inexact at a point that was actually measured. Each of these is a substantive modelling commitment, not a free improvement.

---

## 4. Exactness criteria for the two grid families

### 4.1 Arithmetic grids

**Proposition 4.1.** For $d \ge 1$: $\operatorname{read}_{A_d}(k) = k \iff d \mid k$. Explicitly, $\operatorname{read}_{A_d}(k) = d\lceil k/d\rceil$.

**Corollary 4.2 ($2$-adic form of the step-$4$ criterion).** For $k \ne 0$, the step-$4$ sweep resolves $k$ if and only if $v_2(k) \ge 2$, where $v_2$ is the $2$-adic valuation: $k$ must end in at least two binary zeros.

### 4.2 The dyadic grid

**Theorem 4.3 (Dyadic reading).** $\operatorname{read}_D(k) = 2^{\lceil \log_2 k\rceil}$ for all $k$.

*Proof sketch.* The exponent $\lceil\log_2 k\rceil$ satisfies $k \le 2^{\lceil\log_2 k\rceil}$, so the reading is at most that. Conversely if the reading is $2^j$ then $k \le 2^j$, whence $\lceil \log_2 k\rceil \le j$ and $2^{\lceil\log_2 k\rceil} \le 2^j$. $\square$

**Theorem 4.4 (Digit-sum criterion).** For $k \ne 0$: $\operatorname{read}_D(k) = k$ if and only if the base-two digit sum of $k$ equals $1$, i.e. $k$ is a power of two.

*Proof sketch.* Powers of two have digit sum $1$ (their expansion is $1$ followed by zeros). Conversely, argue by strong induction: if $k$ is even, $k = 2t$ with $t \neq 0$, its binary expansion is that of $t$ with a $0$ appended, so digit sums agree and $t$ is a power of two by induction; if $k$ is odd, the last digit is $1$, so the remaining digits of $\lfloor k/2 \rfloor$ sum to $0$, which for a nonzero number is impossible (its leading digit is nonzero), forcing $\lfloor k/2\rfloor = 0$, i.e. $k = 1 = 2^0$. $\square$

The criterion converts a question about experiment design into one about binary weight. Since $16 = 10000_2$, $20 = 10100_2$, $24 = 11000_2$ have digit sums $1, 2, 2$, a doubling sweep resolves $16$ and *necessarily misreads* $20$ and $24$.

**Theorem 4.5 (Explicit overstatement).** If $2^e < k \le 2^{e+1}$ then $\operatorname{read}_D(k) = 2^{e+1}$, so the doubling sweep overstates the budget by exactly $2^{e+1} - k$.

**Corollary 4.6 (Octave collapse).** If $2^e < k \le k' \le 2^{e+1}$ then $\operatorname{read}_D(k) = \operatorname{read}_D(k')$. No doubling sweep can separate two knees lying in one octave.

Applying these: $\operatorname{read}_D(16) = 16$, $\operatorname{read}_D(20) = 32$, $\operatorname{read}_D(24) = 32$, with overstatements $0$, $12$ and $8$ keys. The dyadic image of the chain $16 < 20 < 24$ is $16, 32, 32$. Both the earlier "context $1024 \mapsto 32$" and the "second corpus at $2048 \mapsto 32$" are the *same rounding event*, and by Corollary 4.6 the collapse is forced, not incidental.

---

## 5. The five-point table: what it determines and what it does not

### 5.1 Setup

**Definition 5.1.** A function $f : \mathbb{N} \to \mathbb{Q}$ is *table-matching* if it is nondecreasing and
$$f(4) = 0.8940,\quad f(8) = 0.9520,\quad f(12) = 0.9662,\quad f(20) = 0.9803,\quad f(24) = 0.9851.$$
The gate is $\tau = 0.98$, the swept set is $S = \{4, 8, 12, 20, 24\}$, the *true knee* is $k^\ast(f) = \min\{k : f(k) \ge \tau\}$ and the *measured knee* is $m(f) = \min\{g \in S : f(g) \ge \tau\}$.

Note $f(12) = 0.9662 < 0.98 \le 0.9803 = f(20)$; these two inequalities carry the whole analysis.

### 5.2 The reading is forced

**Theorem 5.2 (Forced reading).** Every table-matching $f$ satisfies $m(f) = 20$.

*Proof.* $20 \in S$ and $f(20) \ge \tau$, so $m(f)$ exists and $m(f) \le 20$. Being an element of $S$, $m(f) \in \{4,8,12,20,24\}$; the values $0.8940, 0.9520, 0.9662$ all fall below $0.98$, excluding $4, 8, 12$; and $24 > 20 \ge m(f)$ excludes $24$. Hence $m(f) = 20$. $\square$

This is a strong robustness statement: the reported verdict does not depend on the profile at all beyond the five measured values. Any harness that reports the least swept budget clearing the gate returns $20$ — there is no interpolation artifact.

### 5.3 The bracket, and its tightness

**Theorem 5.3 (Bracket).** Every table-matching $f$ satisfies $12 < k^\ast(f) \le 20$.

*Proof.* $f(20) \ge \tau$ gives $k^\ast(f) \le 20$. If $k^\ast(f) \le 12$, monotonicity would give $\tau \le f(k^\ast(f)) \le f(12) = 0.9662 < \tau$, a contradiction. $\square$

**Definition 5.4 (Step witnesses).** For $t \in \mathbb{N}$ define
$$P_t(k) = \begin{cases} 0 & k < 4\\ 0.8940 & 4 \le k < 8\\ 0.9520 & 8 \le k < 12\\ 0.9662 & 12 \le k < t\\ 0.9803 & t \le k < 24\\ 0.9851 & 24 \le k.\end{cases}$$

**Lemma 5.5.** $P_t$ is nondecreasing for every $t$, and is table-matching whenever $12 < t \le 20$.

*Proof sketch.* Monotonicity: the listed values are nondecreasing and the branch conditions are nested intervals, so any $a \le b$ falls into branches in weakly increasing order. Matching: with $12 < t \le 20$, the point $4$ falls in the second branch, $8$ in the third, $12$ in the fourth (since $12 < t$), $20$ in the fifth (since $t \le 20 < 24$), and $24$ in the last. $\square$

**Lemma 5.6.** For $12 < t \le 20$, $k^\ast(P_t) = t$.

*Proof sketch.* $P_t(t) = 0.9803 \ge \tau$, so $k^\ast \le t$. For $k < t$ the value of $P_t(k)$ is at most $0.9662 < \tau$, so no smaller budget clears the gate. $\square$

**Theorem 5.7 (Tightness).** For every integer $t$ with $12 < t \le 20$ there is a table-matching profile whose true knee is exactly $t$ and whose measured knee is $20$.

*Proof.* Take $P_t$, and combine Lemmas 5.5, 5.6 with Theorem 5.2. $\square$

**Corollary 5.8 (Underdetermination).** There exist table-matching profiles $f, g$ with $m(f) = m(g) = 20$ but $k^\ast(f) = 16 \neq 20 = k^\ast(g)$.

The reason is structural, and it is the sharpest observation of the round: **the swept set $S$ contains no point strictly between $12$ and $20$.** In particular it omits $16$, the value reported at the neighbouring context length $512$. Recasting in rounding language:

**Theorem 5.9 (Two-valued fine rounding).** For every table-matching $f$, the step-$4$ rounding of the true knee satisfies
$$\operatorname{read}_{A_4}(k^\ast(f)) \in \{16, 20\},$$
and equals $20$ precisely when $k^\ast(f) > 16$.

*Proof sketch.* By Theorem 5.3, $13 \le k^\ast \le 20$. If $k^\ast \le 16$ then $16$ is a multiple of $4$ dominating $k^\ast$, so the reading is $\le 16$; and being a multiple of $4$ at least $k^\ast \ge 13$ it is $\ge 16$. If $k^\ast > 16$ the same argument with $20$ gives the reading $= 20$. $\square$

### 5.4 What survives, precisely

Three claims must be separated.

- **Certified.** *At context $1024$, a budget of $20$ keys clears the $0.98$ gate, and a budget of $12$ does not.* This is Theorem 5.2 plus the measured values, and it is exactly the deployment-facing statement. It justifies moving the shipped entry for context $1024$ from $32$ keys to $20$.
- **Certified.** *The earlier value $32$ is a rounding of the same truth, not a different truth.* This is Theorem 3.1 with Theorem 4.5: since $16 < k^\ast \le 32$ is compatible with the bracket, the dyadic reading of any admissible $k^\ast \in (16, 20]$ is $32$, and for $k^\ast \in (12,16]$ it is $16$ or $32$ accordingly.
- **Not certified.** *The chain $16 < 20 < 24$ across contexts $\{512, 1024, 2048\}$ is strictly increasing.* By Corollary 5.8 the middle entry may equal $16$. Certifying strict monotonicity requires the single missing measurement at $k = 16$, context $1024$: if $f(16) < 0.98$ then $k^\ast > 16$ and the chain is strict; if $f(16) \ge 0.98$ then $k^\ast \le 16$ and the reported chain has a plateau.

The analysis thus both validates the operational conclusion and identifies, unambiguously and cheaply, the one experiment that would settle the structural one.

---

## 6. How much a sweep can resolve

### 6.1 Counting resolvable budgets

**Definition 6.1.** For a grid $G$ and $N \in \mathbb{N}$, let $R_G(N) = \{k \in (0, N] : \operatorname{read}_G(k) = k\} = (0,N] \cap G$ be the set of budgets in the window that the sweep resolves exactly.

**Theorem 6.2 (Arithmetic count).** $|R_{A_d}(N)| = \lfloor N/d\rfloor$.

*Proof.* $R_{A_d}(N)$ is the set of multiples of $d$ in $(0,N]$. $\square$

**Theorem 6.3 (Dyadic count).** $|R_D(N)| \le \log_2 N + 1$.

*Proof sketch.* $k \mapsto \lfloor\log_2 k\rfloor$ is injective on powers of two and maps $R_D(N)$ into $\{0, 1, \dots, \lfloor\log_2 N\rfloor\}$. $\square$

**Theorem 6.4 (The fine grid wins from $N = 32$).** For $m \ge 5$,
$$|R_D(2^m)| \;<\; |R_{A_4}(2^m)|.$$

*Proof sketch.* Write $m = j+2$ with $j \ge 3$. Then $|R_{A_4}(2^{j+2})| = 2^j$ while $|R_D(2^{j+2})| \le j + 3$, and $j + 3 < 2^j$ for $j \ge 3$ (induction: the base $j=3$ reads $6 < 8$, and doubling outruns adding one). $\square$

So the arithmetic grid resolves a positive proportion $1/d$ of budgets, the doubling grid a vanishing proportion $O(\log N / N)$, and the gap is exponential in the window exponent.

### 6.2 An information bound on coarse sweeps

Counting resolvable budgets understates the problem. The stronger statement bounds the sweep's entire *output alphabet*.

**Theorem 6.5 (Verdict bound).** The image $\{\operatorname{read}_D(k) : 0 < k \le N\}$ has at most $\lceil \log_2 N\rceil + 1$ elements.

*Proof sketch.* By Theorem 4.3 each reading is $2^{\lceil\log_2 k\rceil}$, and $\lceil\log_2 k\rceil \le \lceil\log_2 N\rceil$ for $k \le N$, so the image is contained in $\{2^e : 0 \le e \le \lceil\log_2 N\rceil\}$. $\square$

**Corollary 6.6 (Forced plateaus).** A chain of $r$ true knees in $(0,N]$ reported by a doubling sweep contains at least $r - \lceil\log_2 N\rceil - 1$ repeated values. Apparent flatness in a long coarse chain is a counting artifact, prior to any modelling assumption.

For the regime of interest, $N = 64$ gives at most $7$ possible verdicts: any coarse chain with more than seven cells must repeat.

### 6.3 Resolution power is a divisor count

**Theorem 6.7 (Resolution is divisibility).** For $k \ne 0$ and $d \ge 1$, the step-$d$ sweep resolves $k$ iff $d \in \operatorname{Div}(k)$. Hence the number of arithmetic sweeps resolving $k$ is $\tau(k)$, the divisor-counting function.

Along the reported chain, $\tau(16) = 5$, $\tau(20) = 6$, $\tau(24) = 8$: resolution power happens to increase. But this is an accident of the three numbers, not a trend.

**Proposition 6.8 (Non-monotonicity).** $\tau(28) = 6 < 8 = \tau(24)$ although $24 < 28$. A finer grid does not monotonically buy resolution, and larger budgets are not systematically easier to resolve.

### 6.4 The GCD design principle

**Theorem 6.9 (GCD principle).** Let $K \subseteq \mathbb{N}$ be a finite chain of knees and $d \ge 1$. Then the step-$d$ sweep resolves every element of $K$ if and only if $d \mid \gcd K$.

*Proof.* By Proposition 4.1 the left side says $d \mid k$ for all $k \in K$, which is exactly $d \mid \gcd K$ by the universal property of the gcd. $\square$

**Corollary 6.10 (The step-$4$ grid is forced).** A step-$d$ sweep resolves all of $16, 20, 24$ iff $d \mid 4$. Indeed $\gcd\{16,20,24\} = 4$, so step $4$ is the *coarsest* arithmetic sweep seeing the whole chain, and every coarser arithmetic sweep misreads at least one cell. In particular the doubling ladder's local steps $8, 16, 32$ do not divide $4$.

*Proof of the direct implication without gcd machinery.* If $d \mid 16$ and $d \mid 20$ then $d \mid 20 - 16 = 4$. $\square$

Grid design has thereby become an arithmetic optimisation: given a hypothesised chain, the cheapest arithmetic sweep that can certify it has step $\gcd K$, and its cost over a window $[1,N]$ is $\lfloor N/\gcd K\rfloor$ evaluations.

---

## 7. One mechanism: binary staircase knees

An earlier round in the same programme reported a fine-grid knee of $112$ where a doubling sweep had returned $128$. We show that this and the present $20 \mapsto 32$ are instances of one theorem.

**Definition 7.1 (Binary staircase).** For $b, j \in \mathbb{N}$ set $s(b,j) = 2^b(2^j - 1)$: in binary, $j$ ones followed by $b$ zeros. It satisfies the *complement identity* $s(b,j) + 2^b = 2^{b+j}$.

**Theorem 7.2 (Staircase reading).** For all $b$ and all $j \ge 2$,
$$\operatorname{read}_D\big(s(b,j)\big) \;=\; 2^{b+j}.$$

*Proof sketch.* Write $j = i + 2$. By the complement identity, $s(b,j) = 2^{b+j} - 2^b$. Since $j \ge 2$ we have $2^b < 2^{b+j-1}$, hence
$$2^{b+j-1} \;=\; 2^{b+j} - 2^{b+j-1} \;<\; 2^{b+j} - 2^b \;=\; s(b,j) \;\le\; 2^{b+j}.$$
So $s(b,j)$ lies strictly inside the top octave below $2^{b+j}$, and Theorem 4.5 gives the reading $2^{b+j}$. $\square$

Equivalently: *every binary staircase number with at least two ones is misread by a doubling sweep as its ceiling power of two.* The general digit-sum criterion (Theorem 4.4) already implies such numbers cannot be resolved; Theorem 7.2 says exactly where they go.

**Corollary 7.3.** $112 = 2^4(2^3 - 1) = s(4,3)$, so $\operatorname{read}_D(112) = 2^7 = 128$. Together with $\operatorname{read}_D(20) = 2^{\lceil\log_2 20\rceil} = 32$, the two rounds exhibit a single mechanism: the doubling sweep reports the least power of two above the truth, and the discrepancy equals the distance to it.

---

## 8. Algorithms

Four routines summarise the operational content. Throughout, budgets are positive integers and profiles are nondecreasing.

**Algorithm A (Grid reading).** Given a grid family and $k$, return the least grid point $\ge k$. For $A_d$: $d\lceil k/d\rceil$, in $O(1)$ arithmetic operations. For $D$: $2^{\lceil\log_2 k\rceil}$, computable in $O(\log k)$ bit operations, or with a single leading-zero-count instruction.

**Algorithm B (Sweep and read).** Given a monotone oracle for $f$, a gate $\tau$, and a finite sweep set $S = \{g_1 < \dots < g_r\}$, evaluate $f$ at the $g_i$ in increasing order and return the first that clears $\tau$. This costs $r$ oracle calls in the worst case; binary search over $S$ reduces it to $\lceil\log_2 r\rceil$ calls, exploiting monotonicity, and returns the same value by Theorem 3.1.

**Algorithm C (Bracket certificate).** Given the swept results, return the pair $(g_{i-1}, g_i)$ where $g_i$ is the first passing point and $g_{i-1}$ the last failing one. By Theorem 5.3 this half-open interval $(g_{i-1}, g_i]$ is exactly the set of possible true knees, and by Theorem 5.7 every member of it is realised by a matching profile. The certificate is therefore not merely sound but *complete*: it is the strongest inference the data licenses. Cost: $O(1)$ after the sweep.

**Algorithm D (Chain-resolving grid design).** Given a hypothesised chain $K = \{k_1 < \dots < k_r\}$ and a window $N$, compute $d = \gcd K$ by the Euclidean algorithm in $O(r\log\max K)$ steps and return the sweep $\{d, 2d, \dots\} \cap (0,N]$ of size $\lfloor N/d\rfloor$. By Theorem 6.9 this is the coarsest arithmetic sweep resolving every cell of $K$; any coarser one provably misreads a cell.

A fifth, diagnostic routine is worth naming: given two disagreeing reported knees $a$ (fine) and $b$ (coarse) from nested grids $H \subseteq G$, Corollary 3.3 guarantees $a \le b$, and the discrepancy $b - a$ needs no empirical explanation whatsoever if $b = \operatorname{read}_H(a')$ for some $a'$ in the fine bracket. Checking this is $O(1)$ and should precede any hypothesis of corpus sensitivity or model drift.

---

## 9. Discussion, applications and open problems

### 9.1 Methodological consequences

The results reorganise how a threshold-measurement round should be reported.

1. **Report brackets, not points.** A sweep yields $(g_{i-1}, g_i]$; the point value $g_i$ is a rounding. Reporting the bracket costs nothing and prevents over-claiming.
2. **Check grid holes against the claim.** A chain claim compares cells across conditions; before asserting strictness, verify that each cell's bracket excludes the neighbouring cell's value. Here $16 \in (12, 20]$, and that single containment invalidates the strictness claim while leaving the deployment claim intact.
3. **Disagreements between nested grids are not evidence.** By Corollary 3.3 the finer sweep always reports the smaller value; a coarse–fine discrepancy is the expected behaviour of the operator, not a finding about the system under study.
4. **Design by gcd.** If a chain is hypothesised, the sweep step should divide its gcd. Conversely, the sweep step upper-bounds the granularity of any chain claim one can make.

### 9.2 Applications beyond attention budgets

The hypotheses used are minimal: a nondecreasing profile and a gate. The theory therefore applies unchanged to any *first-crossing* measurement sampled on a restricted set, including:

- **Capacity and sizing thresholds:** minimum cache size, minimum batch size, minimum rank of a low-rank approximation for a target reconstruction error, minimum bit-width for a target accuracy loss.
- **Scaling-law breakpoints:** the least dataset or parameter count at which a benchmark score crosses a fixed bar, when the sweep is over a doubling ladder — the canonical practice, and by Theorem 6.5 one that can emit only $O(\log N)$ distinct verdicts across the whole window.
- **Algorithmic phase transitions:** the least problem size at which an empirically measured success rate crosses a threshold, when sizes are swept geometrically.
- **Dose–response and detection limits:** the least dose or concentration clearing a response criterion, measured on a serial-dilution (geometric) ladder — the classical setting where "titre" values are literally grid readings.

In each case the digit-sum criterion has the same striking form: a geometric sweep of ratio $2$ can only ever be exact at powers of two, so a reported breakpoint that is a power of two conveys strictly less information than one that is not (the latter cannot have come from such a sweep at all).

### 9.3 Limits of the present theory

The theory is deliberately noise-free: it assumes the profile is a fixed nondecreasing function and the oracle returns it exactly. Real measurements average over finitely many windows and carry sampling error, which can make the observed profile non-monotone near the gate. The correct extension replaces the deterministic reading by a random one and asks for the distribution of $\operatorname{read}_G(\hat k^\ast)$; the closure-operator structure suggests that the resulting estimator inherits inflationary bias — a coarse sweep over-reports on average even before noise is considered, and noise can only add to the over-report when the profile is concave near the gate.

Second, the treatment of grids is order-theoretic and ignores cost. A sweep point at a large budget may be more expensive to evaluate than one at a small budget, so the "coarsest resolving grid" of Theorem 6.9 minimises the number of points but not necessarily total cost. A weighted version of the design problem is open.

### 9.4 Open problems

**Problem 1 (Budgeted grid optimality: additive versus multiplicative loss).** Fix a window $[1,N]$ and a budget of $r$ sweep points. We conjecture that the sweep minimising the worst-case *additive* overstatement $\max_k (\operatorname{read}_G(k) - k)$ is the arithmetic grid of step $\lceil N/r\rceil$, while the sweep minimising the worst-case *multiplicative* overstatement $\max_k \operatorname{read}_G(k)/k$ is the geometric grid of ratio $N^{1/r}$ (rounded to integers). If so, the doubling grid is optimal — but for the wrong loss function, which is precisely why it misreports knees by up to a factor $2$ while costing only $\log_2 N$ points. The two grid families in this paper are not "coarse versus fine": they are optima of two different losses, and the choice between them is a decision about which error a harness should minimise. The counting results of §6 already quantify both families; the optimisation should follow from an exchange argument on gap lengths.

**Problem 2 (Octave-collapse bound on certifiable chain length).** If a knee chain $k_1 < \dots < k_r$ lies in $[1,N]$, Theorem 6.5 shows a doubling sweep reports at most $\lceil\log_2 N\rceil + 1$ distinct values, so for $r > \lceil\log_2 N\rceil + 1$ at least $r - \lceil\log_2 N\rceil - 1$ reported plateaus are artifacts. We conjecture the sharper statement that the number of *genuine* strict increases such a sweep can certify equals the number of octaves the chain meets, minus one — converting the qualitative "coarse chains look flat" into an exact combinatorial count.

**Problem 3 (Adaptive sweeps).** All grids here are fixed in advance. An adaptive scheme (binary search over $[1,N]$) locates $k^\ast$ exactly in $\lceil\log_2 N\rceil$ evaluations, beating every fixed grid of comparable size. Why is the fixed grid used at all? Presumably because sweeps are reused across conditions and must be comparable. Formalising the trade-off between *comparability across conditions* and *resolution within a condition* — and finding the optimal partially adaptive scheme — is open.

**Problem 4 (Noisy readings).** Develop the stochastic analogue: with $f$ observed with error, characterise the bias and variance of the grid reading, and determine the grid minimising mean-squared error of the reported knee at fixed evaluation budget.

### 9.5 Conclusion

A measurement made on a grid is the grid-rounding of the truth — exactly, always, and provably. This single identity dissolves an apparent empirical inconsistency between a doubling sweep reporting $32$ and a step-$4$ sweep reporting $20$: they are two readings of one number. It certifies the operational conclusion (twenty keys suffice, twelve do not) while refuting a stronger claim built on top of it (that the cross-context chain is strictly increasing), because the fine grid, for all its refinement, has a hole exactly where the decisive comparison lives. And it converts sweep design from craft into arithmetic: divisibility decides exactness, binary weight decides whether a doubling sweep can ever be right, the divisor function counts how many sweeps can see a budget, and the greatest common divisor of a hypothesised chain names the coarsest sweep that can certify it.

The elementary number theory involved is centuries old. What is new is the observation that it, and not the model under test, is what determines a large part of what a sweep is capable of concluding.
