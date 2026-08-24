# Phase Transitions in Attention Key-Budget Laws: Convexity, Tropical Corners, and the Feasibility Band

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study the *knee* of an attention profile — the smallest number of key–value entries whose retained attention mass meets a fixed gate — as a function of context length, and we audit a measured chain of four knees $16, 20, 24, 40$ at contexts $512, 1024, 2048, 4096$ for a half-billion-parameter language model. Three doublings of a constant increment $+4$ are followed by a single increment of $+16$.

We prove five families of results. **(i) Refutation and underdetermination.** No affine budget law fits the chain, but three natural laws do — a ramp, the cubic Newton interpolant, and a geometric law — and they predict $56$, $80$ and $92$ keys at the next doubling; the increment is a measurement, its continuation is a choice. Under discrete convexity, however, the single observed jump becomes a permanent obligation: every convex fit satisfies $f(m+3) \ge 40+16m$, so no finite key budget survives unbounded context. **(ii) A tropical description of the transition.** The minimal convex fit is the two-term max-plus polynomial $\max(16+4j,\,16j-8)$, whose unique corner lies at the second doubling, i.e. at a context of exactly $2048$ tokens; and this is an instance of a general *discrete Legendre biconjugation*: every monotone convex budget law equals the max-plus polynomial of its own tangents, $f(J)=\max_{i\le J}\big(f(i)+(J-i)\Delta f(i)\big)$. Kinks in budget laws are tropical corners. **(iii) Grid-honest inference.** The knee was read on a coarse grid; we recover the gate from the retention table as $0.979<\tau\le 0.984$, prove that every consistent profile has true knee in $[33,40]$, and show the bracket sharp by exhibiting two profiles matching the entire table with knees $33$ and $40$. The advertised four-fold acceleration is therefore a bracket $[9/4,\,4]$; the direction of the effect is proved, its magnitude is grid-limited. **(iv) Feasibility.** A cache cannot exceed the context in size; this ceiling refutes the geometric continuation structurally (it exceeds the context from the twelfth doubling on) and traps every physically possible convex fit in the band $40+16m \le f(m+3)\le 512\cdot 2^{m+3}$. Any at-most-polynomial law retains a vanishing fraction of the context, so the transition changes the constant, not the compressibility. **(v) A discriminating transfer experiment.** Two rival readings of the corner — a critical *context length* versus a critical *key budget* of $24$ — agree on all existing data for a threefold larger model and differ by exactly eight keys at $4096$ ($28$ versus $20$), giving a single decisive cell.

**Keywords:** attention budget law, knee threshold, discrete convexity, tropical/max-plus polynomial, Legendre biconjugation, phase transition, key–value cache compression.

---

## 1. Introduction

### 1.1 The object

Let a transformer attention head, at some query position in a context of $N$ tokens, produce a probability vector over the $N$ keys. Sort its entries in non-increasing order and call the resulting sequence the **attention profile** $p = (p_0 \ge p_1 \ge \cdots)$, $p_i \ge 0$. Cache compression asks how many of the largest entries must be kept before the retained mass is acceptably close to one.

**Definition 1.1 (Retention).** For a non-negative profile $p$ and a budget $k \in \mathbb{N}$, the **retention** is
$$R_p(k) \;=\; \sum_{i<k} p_i .$$
$R_p$ is non-decreasing in $k$ whenever $p \ge 0$.

**Definition 1.2 (Knee).** For a gate $\tau$, the **knee** is
$$\kappa_p(\tau) \;=\; \min\{\, k \in \mathbb{N} : R_p(k) \ge \tau \,\},$$
defined whenever some budget passes the gate. It is characterised by two properties: $R_p(\kappa_p(\tau)) \ge \tau$ (attainment), and $R_p(k) < \tau$ for every $k < \kappa_p(\tau)$ (minimality).

Because retention is monotone, the knee is the threshold index of a monotone predicate — the simplest possible kind of threshold, and the reason that everything below is elementary in method even where it is delicate in content.

### 1.2 The measured chain

Index context doublings above a base context of $512$ tokens by $j$, so
$$N_j \;=\; 512 \cdot 2^{\,j}, \qquad N_0,\dots,N_3 \;=\; 512,\ 1024,\ 2048,\ 4096 .$$

For a half-billion-parameter model evaluated on six held-out windows with an exact gate, the measured knees are

| $j$ | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| $N_j$ | 512 | 1024 | 2048 | 4096 |
| $k^*$ | 16 | 20 | 24 | **40** |

with increments $+4, +4, +16$. At $N_3 = 4096$ the underlying retention table over the trial grid $\{16,20,24,28,32,40\}$ is

| $k$ | 16 | 20 | 24 | 28 | 32 | 40 |
|---|---|---|---|---|---|---|
| $R(k)$ | 0.959 | 0.969 | 0.975 | 0.977 | 0.979 | **0.984** |

with the gate passing only at $k = 40$.

**Definition 1.3 (Budget law; fitting the chain).** A **budget law** is a function $f : \mathbb{N} \to \mathbb{N}$, interpreted as the key budget required after $j$ context doublings. We say $f$ **fits the chain** if
$$f(0)=16,\quad f(1)=20,\quad f(2)=24,\quad f(3)=40 .$$

The rest of the paper is an audit: what does the chain prove, what does it merely suggest, and what would decide the difference?

---

## 2. Refutation, underdetermination, and what convexity forces

### 2.1 The affine law dies

**Theorem 2.1 (No affine law).** There exist no constants $k_0, d \in \mathbb{N}$ such that $f(j) = k_0 + dj$ fits the chain.

*Proof.* Such a law has constant increment $d$, so $f(1)-f(0)=f(3)-f(2)$ would force $4 = 16$. $\square$

Two corollaries record the two hypotheses the experiment was designed to test. The extrapolated law $f(j) = 16+4j$ predicts $28$ at $j=3$ and hence does not fit: the constant increment does **not** continue. And every law fitting the chain has $f(2) < f(3)$: the budget does **not** saturate. Both refutations are exact, and both are independent of any modelling assumption whatsoever.

### 2.2 Three continuations

**Definition 2.2.** Write $(x)_+ = \max(x,0)$ (in $\mathbb{N}$, truncated subtraction). Define
$$f_{\mathrm{ramp}}(j) = 16 + 4j + 12\,(j-2)_+, \qquad
f_{\mathrm{cub}}(j) = 16 + 4j + 12\binom{j}{3}, \qquad
f_{\mathrm{geo}}(j) = 16 + 4j + 4\big(4^{(j-2)_+}-1\big).$$

The ramp is the minimal piecewise-linear accommodation of the jump: increment $+4$ up to the second doubling, $+16$ afterwards. The cubic is the unique cubic polynomial through the four data points, written in Newton (binomial) form with divided differences $16, 4, 0, 12$. The geometric law is the reading in which the acceleration is *compounding*: the increment itself multiplies by $4$ at every doubling past the transition.

**Theorem 2.3 (Underdetermination).** All three laws fit the chain, and
$$f_{\mathrm{ramp}}(4) = 56, \qquad f_{\mathrm{cub}}(4) = 80, \qquad f_{\mathrm{geo}}(4) = 92 .$$

*Proof.* Direct evaluation at $j = 0,1,2,3,4$; for the cubic use $\binom{3}{3}=1$, $\binom{4}{3}=4$. $\square$

A spread of $56$ to $92$ at the very next doubling, with no data able to adjudicate: the $+16$ increment is a measurement, its continuation is a modelling choice. Any statement about $8192$ tokens must therefore be conditioned on structure, which is the subject of the next subsection.

### 2.3 Convexity turns one jump into a law

**Definition 2.4 (Discrete convexity).** A budget law $f$ is **convex** if its per-doubling increments never decrease:
$$2f(j+1) \;\le\; f(j) + f(j+2) \qquad \text{for all } j .$$

This is the observed shape ($4,4,16$) and the shape of every hinge-type mechanism: attention that becomes progressively harder to compress cannot become easier again as the context grows. Convexity has one consequence, applied repeatedly.

**Lemma 2.5 (Increments persist).** If $f$ is convex and $f(j) + c \le f(j+1)$, then $f(j+1) + c \le f(j+2)$.

*Proof.* Convexity gives $f(j+2) \ge 2f(j+1) - f(j) \ge f(j+1) + c$. $\square$

**Theorem 2.6 (Forced growth).** If $f$ is convex and fits the chain, then
$$f(m+3) \;\ge\; 40 + 16m \qquad \text{for all } m \ge 0 .$$

*Proof.* Induction on $m$. The base case is $f(3) = 40$. The data give $f(2) + 16 \le f(3)$; Lemma 2.5, iterated, propagates the increment $16$ to every later index, so $f(m+3) \ge f(m+2) + 16$, and the bound follows. $\square$

**Corollary 2.7 (Convex prediction at 8192).** Every convex fit needs at least $56$ keys at $j=4$, and the ramp attains the bound: $f_{\mathrm{ramp}}(4)=56$. Thus $56$ is exactly the convex floor.

**Corollary 2.8 (No uniform budget).** For every $B \in \mathbb{N}$ there is a doubling index $j$ with $f(j) > B$: no fixed cache size is safe at all context lengths.

Convexity is doing real work here. From a *single* observed increment it derives a linear-growth obligation valid forever. It is also the weakest hypothesis that does so — without it, the chain is compatible with immediate saturation at $40$.

---

## 3. The transition is a tropical corner

### 3.1 The max-plus form of the minimal fit

The **tropical (max-plus) semiring** $\mathbb{T} = (\mathbb{R}\cup\{-\infty\}, \oplus, \odot)$ has $x \oplus y = \max(x,y)$ and $x \odot y = x + y$. A tropical polynomial in one variable is therefore a maximum of finitely many affine functions $a_i + b_i x$ with integer slopes $b_i$; its **tropical hypersurface** (the analogue of its root set) is the locus where the maximum is attained at least twice — the *corners* of the piecewise-linear graph.

**Theorem 3.1 (Two-term tropical form).** For all $j$,
$$f_{\mathrm{ramp}}(j) \;=\; \max\big(16+4j,\; 16j-8\big).$$

*Proof.* For $j\le 2$ we have $16+4j \ge 16j-8$ and $(j-2)_+ = 0$; for $j \ge 2$ the reverse inequality holds and $16+4j+12(j-2) = 16j-8$. $\square$

**Theorem 3.2 (The corner is at 2048 tokens).** Over the reals the two monomials of $f_{\mathrm{ramp}}$ coincide at exactly one point,
$$16 + 4x = 16x - 8 \iff x = 2,$$
and $N_2 = 512\cdot 2^2 = 2048$. Moreover the first monomial carries the law for $j \le 2$ and the second for $j \ge 2$.

Hence the informal claim "attention budgets are context-stable for the first $\sim2000$ tokens and then become sharply more expensive" is not a narrative gloss: *the number $2048$ is the root of a tropical hypersurface* — the unique tropical root of the fitted budget law. This is a definition of "phase transition" that is checkable, coordinate-free with respect to units, and inherited by any piecewise-linear law.

### 3.2 Every convex law is its own tropical envelope

The tropical description is not an accident of the ramp. It is forced by convexity, via a discrete analogue of Legendre biconjugation ($f^{**} = f$ for closed convex $f$).

**Definition 3.3 (Tangent).** For a budget law $f$, the **tangent at $i$** is the affine law
$$T_i(j) \;=\; f(i) + (j-i)_+\,\Delta f(i), \qquad \Delta f(i) = f(i+1)-f(i).$$

**Lemma 3.4 (Tangents lie below).** If $f$ is convex and monotone, then $T_i(j) \le f(j)$ for all $i \le j$.

*Proof.* Monotonicity gives $f(i)+\Delta f(i) \le f(i+1)$, i.e. the increment $c = \Delta f(i)$ is achieved at $i$. By Lemma 2.5 iterated, $f(i+m) + c \le f(i+m+1)$ for every $m$, so telescoping from $i$ to $j=i+m$ yields $f(i) + m\,c \le f(j)$, which is exactly $T_i(j) \le f(j)$. $\square$

**Theorem 3.5 (Discrete Legendre biconjugation / tropical envelope).** Let $f$ be a monotone convex budget law. Then for every $J$,
$$f(J) \;=\; \max_{0\le i \le J} T_i(J).$$
That is, $f$ is the tropical polynomial whose monomials are its own tangents.

*Proof.* "$\le$": the index $i = J$ contributes $T_J(J) = f(J)$. "$\ge$": every term is at most $f(J)$ by Lemma 3.4. $\square$

Three consequences deserve emphasis.

1. **Budget laws are tropical objects.** The class of monotone convex laws coincides with the class of tropical polynomials with non-negative integer slopes evaluated on $\mathbb{N}$, in the strong sense that each law is *canonically* presented by its tangent family.
2. **Phase transitions are corners.** A "regime change" in such a law is precisely a point where the argmax in Theorem 3.5 changes, i.e. a point of the tropical hypersurface. There is no other kind of qualitative change available.
3. **Minimal presentations.** Most tangents are usually redundant. For the ramp, exactly two are not:

**Theorem 3.6 (Two monomials suffice).** For $j \ge 2$, $\;f_{\mathrm{ramp}}(j) = \max\big(T_0(j),\,T_2(j)\big)$, where $T_0$ has slope $4$ and $T_2$ slope $16$. Furthermore $T_0(2) = T_2(2) = 24$, the law equals $T_0$ on $j\le 2$ and $T_2$ on $j\ge 2$, and $T_0(j) \le T_2(j)$ for $j\ge 2$.

The measured phase transition is thus the unique meeting point of the only two surviving monomials of the minimal convex fit — a statement with no free parameters.

---

## 4. Grid-honest inference: the gate, the bracket, and the honest acceleration

The knee at $4096$ was read on the grid $\{16,20,24,28,32,40\}$. The reported value $40$ is therefore a *grid point*, not a measurement of the threshold. This section quantifies exactly how much that costs.

**Definition 4.1 (Matching the table).** A profile $p$ **matches the table** if
$$R_p(16)=0.959,\ R_p(20)=0.969,\ R_p(24)=0.975,\ R_p(28)=0.977,\ R_p(32)=0.979,\ R_p(40)=0.984 .$$

**Theorem 4.2 (Gate recovery).** Let $p$ match the table and let $\tau$ be a gate that some budget passes. If the knee read on the grid is $40$, then
$$0.979 < \tau \le 0.984 .$$

*Proof.* Minimality of the knee applied at $k=32 < 40$ gives $R_p(32) < \tau$, i.e. $0.979 < \tau$. Attainment at the knee gives $\tau \le R_p(40) = 0.984$. $\square$

The gate was never reported; the table determines it to within $0.005$. Everything downstream is stated for an arbitrary $\tau$ in that range, so no unreported quantity is assumed.

**Theorem 4.3 (Bracket).** Let $p \ge 0$ match the table and let $0.979 < \tau \le 0.984$. Then
$$33 \;\le\; \kappa_p(\tau) \;\le\; 40 .$$

*Proof.* Upper bound: $R_p(40)=0.984 \ge \tau$, so the knee is at most $40$. Lower bound: if $\kappa_p(\tau) \le 32$ then by monotonicity $\tau \le R_p(\kappa_p(\tau)) \le R_p(32) = 0.979 < \tau$, a contradiction. $\square$

**Theorem 4.4 (Sharpness).** Both endpoints are realised by explicit profiles matching the entire table. Let
$$p^{\mathrm{lo}}: \; p_0 = 0.959,\ p_{16}=0.010,\ p_{20}=0.006,\ p_{24}=0.002,\ p_{28}=0.002,\ p_{32}=0.005,\ \text{else } 0,$$
$$p^{\mathrm{hi}}: \; p_0 = 0.959,\ p_{16}=0.010,\ p_{20}=0.006,\ p_{24}=0.002,\ p_{28}=0.002,\ p_{39}=0.005,\ \text{else } 0 .$$
Both match the table, and at the admissible gate $\tau = 0.98$,
$$\kappa_{p^{\mathrm{lo}}}(0.98) = 33, \qquad \kappa_{p^{\mathrm{hi}}}(0.98) = 40 .$$

*Proof.* Partial sums up to each grid point agree with the table for both profiles, since the two differ only in the location ($32$ versus $39$) of the final $0.005$, which lies strictly between the grid points $32$ and $40$ in the second case. For $p^{\mathrm{lo}}$, $R(33) = 0.984 \ge 0.98$ while $R(32) = 0.979 < 0.98$, so the knee is $33$. For $p^{\mathrm{hi}}$, $R(39) = 0.979 < 0.98 \le 0.984 = R(40)$, so the knee is $40$. $\square$

Two profiles, identical on every observed quantity, whose true knees differ by seven. The bracket is a property of the grid, not of the proof.

**Theorem 4.5 (Honest acceleration).** Under the hypotheses of Theorem 4.3, the increment at the fourth doubling satisfies
$$9 \;\le\; \kappa_p(\tau) - 24 \;\le\; 16, \qquad \text{and in particular} \quad \kappa_p(\tau)-24 \;>\; 2\cdot 4 .$$
Hence the acceleration factor relative to the previous increment $+4$ lies in $[\,9/4,\ 4\,] = [2.25,\ 4]$.

The claim "the increment accelerates" is proved — the new increment is strictly more than double the old one under every consistent hypothesis. The claim "by a factor of four" is the top of a bracket whose bottom is $2.25$. Distinguishing these two statements costs nothing at the time of the experiment and is irrecoverable afterwards.

### 4.1 The deployment trichotomy

**Theorem 4.6 (Trichotomy).** Let $p \ge 0$ match the table and $0.979 < \tau \le 0.984$.
1. *(Provably unsafe.)* Every budget $B \le 32$ fails: $R_p(B) < \tau$.
2. *(Certified safe.)* Every budget $B \ge 40$ passes: $R_p(B) \ge \tau$.
3. *(Undecided.)* For every $B$ with $33 \le B \le 39$, the profile $p^{\mathrm{lo}}$ passes at $B$ and $p^{\mathrm{hi}}$ fails at $B$ (at $\tau = 0.98$); no budget in this window is decided by the measurement.

*Proof.* (1) and (2) are monotonicity plus the table entries at $32$ and $40$. (3) is monotonicity applied to the profiles of Theorem 4.4: $R_{p^{\mathrm{lo}}}(B) \ge R_{p^{\mathrm{lo}}}(33) = 0.984$ and $R_{p^{\mathrm{hi}}}(B) \le R_{p^{\mathrm{hi}}}(39) = 0.979$. $\square$

**Corollary 4.7 (The 24-key cache fails).** For every profile consistent with the table and every admissible gate, $\kappa_p(\tau) > 24$. A cache sized correctly at $2048$ tokens is unsafe at $4096$.

This is the deployment consequence, and it uses only the *lower* end of the bracket: it is completely independent of the disputed factor. Budget tables built by linear extrapolation from three doublings are wrong at the fourth.

---

## 5. The continuous layer: rates, reciprocity, and calibration

Behind the integer counting is a mechanism. Assume the sorted attention tail decays exponentially with rate $\lambda>0$ and require the mass beyond the knee to fall below a tail budget $\delta$. Then the knee is determined by $e^{-\lambda k} = \delta$, i.e.

**Definition 5.1 (Continuous knee).** $\;\kappa^{\mathrm{cts}}(\lambda,\delta) = \dfrac{\log(1/\delta)}{\lambda}.$

**Proposition 5.2 (Reciprocity).** For $\lambda \ne 0$, $\;\kappa^{\mathrm{cts}}(\lambda,\delta)\cdot\lambda = \log(1/\delta)$: the knee and the decay rate are exact reciprocals at fixed tail budget.

Reciprocity is what makes the chain informative about mechanism *without any fitted parameter*: ratios of knees are inverse ratios of rates, and $\log(1/\delta)$ cancels.

**Theorem 5.3 (Refutation of the harmonic rate family).** There is no pair $(\lambda_0 \ne 0, \delta)$ for which the rate family $\lambda_j = \lambda_0/(j+1)$ reproduces $16,20,24,40$.

*Proof.* Under that family $\kappa^{\mathrm{cts}}(\lambda_j,\delta) = (j+1)\log(1/\delta)/\lambda_0$ is affine in $j$ with constant increment; but the chain has increments $4$ and $16$. $\square$

The family was calibrated on the first three points, where it is exactly right; it is the fourth that kills it. This is the continuous shadow of Theorem 2.1.

**Theorem 5.4 (Model-free rate-collapse acceleration).** Let $\lambda_1,\lambda_2,\lambda_3 > 0$ be any positive rates with $\kappa^{\mathrm{cts}}(\lambda_1,\delta)=20$, $\kappa^{\mathrm{cts}}(\lambda_2,\delta)=24$, $\kappa^{\mathrm{cts}}(\lambda_3,\delta)=40$. Then
$$5\lambda_3 = 3\lambda_2, \qquad 6\lambda_2 = 5\lambda_1, \qquad \frac{\lambda_3}{\lambda_2} < \frac{\lambda_2}{\lambda_1}.$$

*Proof.* Reciprocity gives $20\lambda_1 = 24\lambda_2 = 40\lambda_3 = \log(1/\delta)$, whence the two equalities. Then $\lambda_3/\lambda_2 = 3/5 < 5/6 = \lambda_2/\lambda_1$. $\square$

**Theorem 5.5 (Robustness to the grid gap).** The strict inequality $\lambda_3/\lambda_2 < \lambda_2/\lambda_1$ holds whenever the knee at the fourth doubling is *at least* $33$ — the certified lower end of the bracket — with no upper constraint.

*Proof.* $\lambda_3/\lambda_2 = 24/k_3 \le 24/33 = 8/11 < 5/6 = \lambda_2/\lambda_1$. $\square$

So the qualitative phenomenon — the *relative* collapse of attention sharpness accelerates at the fourth doubling — survives the grid gap intact, even though the factor $4$ does not. This is the precise sense in which the verdict is right and the headline is overstated.

**Definition 5.6 (Crossover rate family).** $\;\lambda_j^{\times}(\lambda_0) = \dfrac{\lambda_0}{4 + j + 3\,(j-2)_+}.$

The inverse rate grows with unit slope before the corner and slope $4$ after it, mirroring the increments $4$ and $16$ scaled by $\log(1/\delta)$.

**Theorem 5.7 (Calibration).** With $\lambda_0 = 1$ and tail budget $\delta = e^{-4}$,
$$\kappa^{\mathrm{cts}}\big(\lambda_j^{\times}(1),\,e^{-4}\big) \;=\; f_{\mathrm{ramp}}(j) \qquad \text{for every } j,$$
and in particular the family reproduces the measured chain exactly: $16, 20, 24, 40$.

*Proof.* By reciprocity the left side equals $4\big(4+j+3(j-2)_+\big) = 16+4j+12(j-2)_+$, which is the real form of the ramp. $\square$

**Corollary 5.8 (Rate profile of the transition).** In the calibrated family, $\lambda_0^\times = 1/4$, $\lambda_1^\times = 1/5$, $\lambda_2^\times = 1/6$, $\lambda_3^\times = 1/10$; the rate falls by a factor $5/6$ at the third doubling and $3/5$ at the fourth, and $3/5 < 5/6$.

Interpretation: attention does not merely flatten as the context grows — the *rate at which it flattens* jumps discontinuously past $2048$ tokens.

---

## 6. Feasibility: what cannot happen, and what that decides

The three-way ambiguity of Theorem 2.3 can be narrowed with no new measurement, by imposing the one constraint the setting cannot violate.

**Definition 6.1 (Feasibility).** A budget law $f$ is **feasible** if it never requests more keys than the context has tokens:
$$f(j) \;\le\; 512\cdot 2^{\,j} \qquad \text{for all } j .$$

**Theorem 6.2 (The ramp is feasible).** $f_{\mathrm{ramp}}(j) \le 512\cdot 2^{\,j}$ for all $j$.

*Proof.* $f_{\mathrm{ramp}}(j) \le 16(j+1)$, and $j+1 \le 2^j$, so $f_{\mathrm{ramp}}(j) \le 16\cdot 2^j \le 512\cdot 2^j$. $\square$

**Theorem 6.3 (The cubic is feasible).** $f_{\mathrm{cub}}(j) \le 512\cdot 2^{\,j}$ for all $j$.

*Proof.* $\binom{j}{3} \le 2^j$ and $j+1 \le 2^j$, so $f_{\mathrm{cub}}(j) = 16+4j+12\binom{j}{3} \le 16\cdot 2^j + 12 \cdot 2^j \le 512\cdot 2^j$. (That the interpolant is genuinely cubic is the elementary bound $6\binom{j}{3} \le j^3$, from $j^{\underline{3}} \le j^3$.) $\square$

**Theorem 6.4 (The geometric continuation is infeasible).** For every $m \ge 0$,
$$512 \cdot 2^{\,m+12} \;<\; f_{\mathrm{geo}}(m+12).$$
Consequently $f_{\mathrm{geo}}$ is not feasible.

*Proof.* For $j = m+12$ we have $f_{\mathrm{geo}}(j) = 16 + 4(m+12) + 4\big(4^{m+10}-1\big) = 4^{m}\cdot 4^{11} + 4m + 60$, while the ceiling is $512\cdot 2^{j} = 2^{m}\cdot 2^{21}$. Since $4^{11} = 4\,194\,304 = 2\cdot 2^{21}$ and $2^m \le 4^m$, the left side is at least twice the right. Explicitly at $m=0$: $4\,194\,364$ keys demanded for a $2\,097\,152$-token context. $\square$

At a context of $2^{21} \approx 2.1$ million tokens the compounding reading demands roughly *twice as many keys as there are tokens*, and the gap widens forever. It is refuted structurally, without data. (Numerically the first crossing occurs one doubling earlier, at $j=11$: $1\,048\,632$ keys for a $1\,048\,576$-token context; the statement above is the clean bound.)

**Theorem 6.5 (Feasibility selects).** Of the three continuations of Theorem 2.3, exactly one is infeasible. The two survivors are separated by a single further measurement:
$$f_{\mathrm{ramp}}(4) = 56 \qquad \text{versus} \qquad f_{\mathrm{cub}}(4) = 80 \quad \text{at } N_4 = 8192 .$$

**Theorem 6.6 (The feasibility band).** Let $f$ be convex, fit the chain, and be feasible. Then for every $m \ge 0$,
$$40 + 16m \;\le\; f(m+3) \;\le\; 512\cdot 2^{\,m+3},$$
and the band is inhabited: $f_{\mathrm{ramp}}$ satisfies both bounds.

*Proof.* Lower bound: Theorem 2.6. Upper bound: feasibility. Inhabitation: $f_{\mathrm{ramp}}(m+3) = 40+16m$ exactly, and Theorem 6.2. $\square$

The band is wide — linear floor against exponential ceiling — but it is the exact envelope of what the measurement plus physics permit, and its lower edge is attained.

### 6.1 Compression survives the transition

**Definition 6.7 (Keep fraction).** $\;\rho_f(j) = \dfrac{f(j)}{512\cdot 2^{\,j}}$, the fraction of the context retained.

**Theorem 6.8 (Polynomial laws are asymptotically free).** If $f(j) \le C\,(j+1)^k$ for constants $C,k$, then $\rho_f(j) \to 0$ as $j \to \infty$.

*Proof sketch.* $\rho_f(j) \le \frac{C}{512}(j+1)^k 2^{-j}$, and $n^k 2^{-n} \to 0$ for every fixed $k$ (polynomial against geometric decay). Squeeze between $0$ and this majorant. $\square$

**Corollary 6.9.** Both surviving laws retain a vanishing fraction of the context: $\rho_{f_{\mathrm{ramp}}} \to 0$ (with $C=16$, $k=1$) and $\rho_{f_{\mathrm{cub}}} \to 0$ (with $C=22$, $k=3$).

This is the correct reassurance. **The phase transition changes the constant in the budget table; it does not change the asymptotic compressibility of the cache.** A jump from $+4$ to $+16$ per doubling is a jump in a linear coefficient against an exponentially growing context.

---

## 7. Where does the corner come from? A discriminating transfer experiment

Everything so far concerns one model. The corner at $j=2$ admits two readings, and one measurement separates them.

**Definition 7.1 (Crossing index).** For a budget law $f$ and a critical budget $K$,
$$\mathrm{cross}(f,K) \;=\; \min\{\, j : f(j) \ge K \,\}.$$

Write $f_{\mathrm{small}}(j) = 16+4j$ for the pre-transition law of the half-billion model, and let $f_{\mathrm{large}}$ be the measured law of a threefold larger model, whose observed knees are $16, 16, 18$ at $j = 0,1,2$ and which continues with increment $+2$ per doubling: $f_{\mathrm{large}}(j) = 16 + 2(j-1)_+$.

**The two hypotheses.**

- **(CTX)** The corner is a property of the **context length**: attention becomes sharply more expensive past $\sim 2000$ tokens, for every model. The larger model then kinks at $j=2$ as well, with post-corner increment half of $16$, giving $f_{\mathrm{CTX}}(j) = f_{\mathrm{large}}(j) + 8(j-2)_+$.
- **(BUD)** The corner is a property of the **key budget**: a curve kinks when its knee crosses a model-independent critical budget of $K^* = 24$ keys. This gives $f_{\mathrm{BUD}}(j) = f_{\mathrm{large}}(j) + 8\,(j-\mathrm{cross}(f_{\mathrm{large}},24))_+$.

**Theorem 7.2 (The budget reading retrodicts the observed corner).**
$$\mathrm{cross}(f_{\mathrm{small}}, 24) = 2, \qquad \mathrm{cross}(f_{\mathrm{large}}, 24) = 5 .$$

*Proof.* $16+4j \ge 24 \iff j \ge 2$; $16 + 2(j-1) \ge 24 \iff j \ge 5$. $\square$

This is what makes (BUD) a hypothesis rather than a re-description: for the smaller model the critical-budget crossing lands exactly on the observed corner $j=2$, so the budget reading *predicts* the corner it was not fitted to. The context reading merely coincides with it once.

**Theorem 7.3 (The discriminating experiment).** The two transfer laws agree on every measured point of the larger model,
$$f_{\mathrm{CTX}}(j) = f_{\mathrm{BUD}}(j) = f_{\mathrm{large}}(j) \quad \text{for } j \le 2 \quad (16, 16, 18),$$
and differ by exactly eight keys at the first unmeasured one:
$$f_{\mathrm{CTX}}(3) = 28, \qquad f_{\mathrm{BUD}}(3) = 20, \qquad f_{\mathrm{CTX}}(3) = f_{\mathrm{BUD}}(3) + 8 .$$

**Theorem 7.4 (Delay of the transition).** Under the budget reading the larger model's transition context is $512\cdot 2^5 = 16384$ tokens rather than $512\cdot 2^2 = 2048$: an eightfold delay.

**Theorem 7.5 (The test is fair).** Both $f_{\mathrm{CTX}}$ and $f_{\mathrm{BUD}}$ are convex, monotone and feasible; neither is excluded by any structural result of this paper. Moreover both satisfy $f(3) < 40$: the larger model needs strictly fewer keys at $4096$ tokens than the smaller one, under either hypothesis, so the scale advantage survives the transition.

One cell — the larger model at $4096$ tokens — returns either $28$ or $20$ and decides whether the phase transition belongs to the page or to the cache. This is the cleanest experimental design the audit produces, and it is a direct product of having made "phase transition" precise in Section 3.

---

## 8. Algorithms

Three procedures encapsulate the constructive content.

**(A) Knee extraction with certified bracket.** Given a retention table on a grid $g_1 < \cdots < g_n$ and the observation that the gate first passes at $g_m$: return the gate bracket $(R(g_{m-1}), R(g_m)]$ and the knee bracket $[g_{m-1}+1,\; g_m]$. Correctness is Theorems 4.2 and 4.3; sharpness (Theorem 4.4) shows no better bracket is extractable. Cost $O(n)$.

**(B) Convex-envelope evaluation.** Given the values of a convex law on $\{0,\dots,J\}$, evaluate its tropical envelope $\max_{i\le J} T_i(J)$ and return the *active* monomials (those attaining the max) together with the corners. By Theorem 3.5 the envelope reproduces $f$; the corners are the phase transitions. Cost $O(J)$ per evaluation, $O(J^2)$ to tabulate, reducible to $O(J)$ by a monotone-argmax scan since the slopes $\Delta f(i)$ are non-decreasing.

**(C) Continuation filter.** Given a set of candidate laws fitting the chain, discard any that violate feasibility $f(j) \le 512\cdot 2^j$ (checking up to the doubling at which the ceiling provably dominates for polynomial candidates, or by closed form for exponential ones), then report the pairwise disagreements at the first unmeasured index — the discriminating experiments. Applied to $\{f_{\mathrm{ramp}}, f_{\mathrm{cub}}, f_{\mathrm{geo}}\}$ this yields Theorem 6.5.

---

## 9. Discussion

**What the audit changed.** The input claim was: *the knee at $4096$ is $40$, a four-fold acceleration over the $+4$ per doubling that held through three doublings; this is a phase transition in context-sensitivity.* After the audit:

- **Survives, proved.** No affine law fits the chain. The increment at the fourth doubling is at least $9$ and at most $16$. Every convex fit needs $40+16m$ keys $m$ octaves later, and no finite budget is universally safe. A $24$-key cache fails at $4096$ tokens for *every* consistent profile. Model-free, for any exponential-tail explanation, $\lambda_3/\lambda_2 < \lambda_2/\lambda_1$.
- **Fails as stated, corrected.** The factor $4$ is not a measurement. The six-point grid leaves the true knee anywhere in $[33,40]$, both endpoints realised by explicit profiles reproducing the whole table. The honest statement is an acceleration factor in $[9/4, 4]$.
- **Needed a different definition.** "Phase transition" was made precise as the *tropical corner* of the fitted law: the minimal convex fit is $\max(16+4j,\,16j-8)$, whose unique corner is at $j=2$, i.e. $2048$ tokens. The informal "$\sim2000$ tokens" is the root of a tropical hypersurface, and every monotone convex budget law is the max-plus polynomial of its own tangents.

**A methodological reading.** The pattern generalises well beyond attention caches. (1) Prove refutations, not replacements. (2) Quantify the underdetermination by exhibiting rival continuations and their disagreement. (3) Extract what the weakest structural hypothesis forces — here convexity, from one jump to a permanent linear obligation. (4) Confront the measurement grid: a threshold read on a grid is a bracket, and sharpness examples show whether the bracket can be shrunk by argument or only by more probes. (5) Use impossibility (feasibility) as free data. (6) Find the language in which the phenomenon is a *definition* rather than a description — here, tropical geometry.

**Limitations.** The chain is four points from one model; the retention table is six windows at one context. Discrete convexity is an assumption, empirically supported but not proved; without it, saturation at $40$ is formally consistent with the data (though refuted by no mechanism we know). The exponential-tail model of Section 5 is a modelling choice, but reciprocity makes its ratio consequences parameter-free. Finally, the transfer analysis of Section 7 assumes the larger model's pre-corner law continues with increment $+2$, which is itself an extrapolation of three points.

---

## 10. Future directions

1. **Budget-threshold universality of the corner.** *Conjecture:* for every model, the corner of the knee curve sits at the first context doubling at which the knee crosses a model-independent critical budget $K^* = 24$ keys — not at a model-independent context length. The key insight is that the smaller model's corner at $j=2$ is exactly the crossing index of $24$ keys for the law $16+4j$, so the budget reading retrodicts the observed corner while the context reading merely coincides with it once. The two readings agree on all existing data for the larger model and differ by $8$ keys at $4096$; a single cell decides between $28$ (context threshold) and $20$ (budget threshold).

2. **Closing the grid gap by design, not by luck.** *Conjecture:* three further probes at $k = 34, 36, 38$ collapse the certified bracket $[33,40]$ to a single value, and no adaptive strategy can do it with fewer than $\lceil \log_2 8\rceil = 3$ probes. The knee is the threshold of a monotone predicate, so probe design is exactly binary search on a bracket; the sharpness theorem shows the bracket is an artefact of the grid rather than of the proof. Formalising the adaptive lower bound turns experiment design into a theorem instead of a habit.

3. **Feasibility as a theory of admissible laws.** The ceiling $f(j)\le 512\cdot 2^j$ eliminated one continuation for free. What is the full class of feasible, convex, chain-fitting laws — is it a tropical polytope, and can its extreme rays be characterised? The floor $40+16m$ and the exponential ceiling bound a band; a sharper physical ceiling (memory rather than token count) would narrow it further.

4. **Corners beyond the first.** Does the knee curve have a *second* corner? Convexity permits it; the ramp assumes none. A measurement at $8192$ distinguishing $56$ from $80$ is simultaneously a test for a second tropical root.

5. **Sharpness of the tropical presentation.** For which convex budget laws is the tangent envelope minimal with two monomials, and can the number of essential monomials be read off the measured increments directly? This would give a "number of phase transitions" statistic computable from a knee table.
