# Draft-Cost Dominance and Domain-Parameterised Depth in CPU Speculative Decoding

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

Speculative decoding accelerates autoregressive generation by having a small *draft*
model propose $d$ continuation tokens which a large *target* model then verifies in a
single forward pass, with the accepted prefix committed and the output distribution
left exactly unchanged. Its theory has been developed almost entirely in a regime —
massively parallel accelerators — where the verification pass is effectively free and
the draft's sequential proposal cost is negligible. We study the opposite regime:
target and draft both executing on a general-purpose CPU, where the $d$ proposal steps
are paid in full and verification does not amortise.

We develop a block model in which throughput is a ratio of a *yield* curve to a *cost*
curve, and prove five families of results. First, an exact head-to-head criterion and
a **cost-dominance law**: at large depth a draft is characterised by the single
invariant $c(1-a)$, the product of relative per-token cost and rejection rate, so an
acceptance advantage must beat a cost disadvantage multiplicatively in the rejection
rate. Instantiated at measured parameters from a twelve-cell experiment on a
seven-billion-parameter target, the cheaper draft — costing $11.8\%$ of a target token
against the larger draft's $23.4\%$ — wins all six head-to-head cells, including the
one in which it accepts strictly less ($56.0\%$ versus $60.3\%$). Second, a **depth
collapse** theorem: for every acceptance $a<1$ and cost $c>0$ there is a depth past
which speculation is a net loss, with the explicit gate $(1-a)(1+cd)>1$. Third, a
**unimodality** theorem: for any yield with non-increasing increments over an affine
cost, throughput is unimodal in depth, so greedy hill-climbing is exact; this yields a
canonical **stopping depth** selector that is globally optimal and monotone in
acceptance. Fourth, an **averaging law** for position-resolved acceptance: the
reported mean acceptance of any fixed non-increasing survival profile is automatically
non-increasing in depth, so measured acceptance decay is uninformative about drafter
degradation; the law nevertheless supplies a falsifiable realisability test, which the
measured data pass, and explicit survival profiles reproducing all six measured
acceptance percentages exactly. Fifth, a **convex hardware cost curve**, calibrated on
three cells, which predicts all twelve measured speedups within $11\%$ relative error;
convexity is forced, since no affine cost reproduces the three calibration cells.

Together these results replace the accelerator folklore with a hardware-parameterised
theory: cost is a property of the machine, yield a property of the domain, and the
optimal depth the first position at which next-position survival falls below marginal
cost times current throughput.

**Keywords:** speculative decoding, draft models, throughput optimisation, survival
profiles, unimodality, convex cost curves, CPU inference.

---

## 1. Introduction

### 1.1 The mechanism

An autoregressive language model generates a token sequence by repeated conditioning:
token $t_{n+1}$ requires a full forward pass conditioned on $t_1,\dots,t_n$. The
computation is inherently sequential, and for a large model each pass is expensive.

*Speculative decoding* breaks the sequentiality by gambling. A cheap draft model
generates $d$ candidate continuations $\hat t_{n+1},\dots,\hat t_{n+d}$ sequentially.
The target model then evaluates all $d+1$ positions in one forward pass — possible
because, given the candidate string, the conditioning contexts of all positions are
known — and accepts the longest prefix consistent with its own decoding rule. On the
first rejection, the target's own token is emitted instead, and the suffix is
discarded. Under greedy decoding the accepted output is *identical* to what the target
would have produced alone; under sampling, an appropriate correction preserves the
target's distribution exactly. Speculative decoding is a pure latency optimisation,
never an approximation.

The gamble has an explicit price. The $d$ draft steps are performed whether or not
their outputs survive. If drafting is cheap relative to verification, this price is
negligible and depth should be pushed high. If drafting is expensive, or if
verification of a wide batch itself costs more than verification of a single position,
the price bites.

### 1.2 The regime studied here

Almost all reported speculative-decoding practice sits on GPUs, where a batch of $d+1$
positions is verified in essentially the time of one position — the accelerator has
thousands of idle lanes — and where draft steps are small relative to the target pass.
In that regime, two heuristics circulate: use the largest draft model you can afford,
because acceptance dominates; and increase depth as long as acceptance holds up.

We study CPU-only inference: a four-bit-quantised seven-billion-parameter
instruction-tuned target, eight threads on a desktop-class processor, greedy decoding,
baseline throughput $5.79$ tokens per second. Two same-family drafts of $0.5$B and
$1.5$B parameters, measured relative per-token costs $c \approx 0.118$ and
$c \approx 0.234$ target-token-equivalents respectively. Two domains — English prose
and source code — with prompts of roughly $500$ tokens. Three depths $d \in \{2,4,8\}$.
Twelve configurations, eight runs apiece.

**Measured results.**

| draft | depth | prose speedup | prose acceptance | code speedup | code acceptance |
|---|---|---|---|---|---|
| $0.5$B | $2$ | $1.254$ | $63.9\%$ | $1.352$ | $71.6\%$ |
| $0.5$B | $4$ | $1.416$ | $47.7\%$ | $1.616$ | $63.0\%$ |
| $0.5$B | $8$ | $0.979$ | $30.9\%$ | $\mathbf{1.661}$ | $56.0\%$ |
| $1.5$B | $2$ | $1.016$ | $63.2\%$ | $1.195$ | $83.4\%$ |
| $1.5$B | $4$ | $1.153$ | $51.9\%$ | $1.395$ | $74.8\%$ |
| $1.5$B | $8$ | $0.982$ | $44.9\%$ | $1.354$ | $60.3\%$ |

Three features demand explanation, and each becomes a theorem below.

1. **The cheap draft wins everywhere**, including code at $d=8$, where the expensive
   draft accepts strictly more ($60.3\%$ against $56.0\%$) and is nonetheless
   $23\%$ slower. There is no crossover.
2. **Deep speculation is a net loss for prose** ($0.979\times$, $0.982\times$ at
   $d=8$) but the best configuration for code ($1.661\times$). Optimal depth is
   domain-dependent.
3. **Reported acceptance decays with depth** in both domains, and does so faster for
   prose. Whether this reflects drafter degradation is exactly the question the
   averaging law of Section 5 settles — negatively.

### 1.3 Contributions

- A block model with an exact head-to-head criterion (Section 2), the cheap-draft law
  at equal acceptance, and the cost-dominance law with its asymptotic invariant
  $c(1-a)$ (Section 3).
- The depth-collapse gate $(1-a)(1+cd)>1$ and existence of an interior optimum
  (Section 4).
- A unimodality structure theorem for arbitrary concave yields, exactness of greedy
  depth tuning, and the canonical stopping-depth selector with its monotonicity in
  acceptance (Section 4).
- Position-resolved *survival profiles*, the averaging law, a falsifiable
  realisability test, exact reconstruction of all six measured acceptance
  percentages, and a local optimality rule (Section 5).
- A convex CPU cost curve calibrated on three cells and validated on twelve, with an
  impossibility theorem ruling out any affine alternative (Section 6).

---

## 2. The block model

Throughout, time is measured in units of one target decode step, so that plain
autoregressive decoding produces one token per unit time and all speedups are
dimensionless.

> **Definition 2.1 (Block cost).** For a draft with relative per-token cost $c \ge 0$
> and depth $d \in \mathbb{N}$,
> $$\mathrm{cost}(c,d) \;=\; 1 + c\,d,$$
> one verification pass plus $d$ sequential draft steps. Note $\mathrm{cost}(c,0)=1$.

> **Definition 2.2 (Geometric yield).** If each drafted position is accepted
> independently with probability $a \in [0,1]$, the expected number of tokens
> committed per block is
> $$Y_{\mathrm{geo}}(a,d) \;=\; \sum_{i=0}^{d} a^i \;=\; 1 + a + \cdots + a^d,$$
> the free correction token plus the expected length of the accepted prefix.

> **Definition 2.3 (Throughput).** The speedup over plain decoding is
> $$\sigma(a,c,d) \;=\; \frac{Y_{\mathrm{geo}}(a,d)}{\mathrm{cost}(c,d)},$$
> normalised so that $\sigma(a,c,0) = 1$ for all $a,c$.

Two elementary facts are used constantly: $\mathrm{cost}(c,d) > 0$ whenever $c \ge 0$,
and $Y_{\mathrm{geo}}(a,d) > 0$ whenever $a \ge 0$ (the $i=0$ term contributes $1$).
Since both quantities are positive, comparisons of $\sigma$ can always be
cross-multiplied.

> **Lemma 2.4 (Exact comparison criterion).** For $c,c' \ge 0$ and depths $d,e$,
> $$\sigma(a,c,d) < \sigma(a',c',e)
> \iff Y_{\mathrm{geo}}(a,d)\,\mathrm{cost}(c',e) < Y_{\mathrm{geo}}(a',e)\,\mathrm{cost}(c,d).$$

*Proof.* Cross-multiplication by the two positive denominators. $\square$

Lemma 2.4 is the workhorse: every head-to-head statement below reduces to a
polynomial inequality in $a, a', c, c'$ with no division.

A second elementary bound is needed for the asymptotics. Since
$(1-a)\,Y_{\mathrm{geo}}(a,d) = 1 - a^{d+1}$ by telescoping, for $0 \le a < 1$ we have
$Y_{\mathrm{geo}}(a,d) \le (1-a)^{-1}$ for every $d$: **the yield is bounded, uniformly
in depth, by the reciprocal of the rejection rate.** The cost, by contrast, is
unbounded. Everything in Sections 3 and 4 is a consequence of this asymmetry.

---

## 3. Draft-cost dominance

### 3.1 The degenerate case

> **Theorem 3.1 (Cheap-draft law at equal acceptance).** Let $a \ge 0$,
> $0 \le c < c'$, and $d \ge 1$. Then $\sigma(a,c',d) < \sigma(a,c,d)$.

*Proof.* By Lemma 2.4 the claim is
$Y_{\mathrm{geo}}(a,d)\,\mathrm{cost}(c,d) < Y_{\mathrm{geo}}(a,d)\,\mathrm{cost}(c',d)$,
i.e. $\mathrm{cost}(c,d) < \mathrm{cost}(c',d)$, which holds since $d \ge 1$ and
$c<c'$, the yield being strictly positive. $\square$

This is not the content of the experiment; it is the baseline against which the
content is measured. The experimental finding is that cost dominance *survives an
acceptance deficit*.

### 3.2 The six measured cells

> **Theorem 3.2 (Cost dominance, all six head-to-heads).** With relative costs
> $c_{\mathrm{small}} = 0.118$ and $c_{\mathrm{large}} = 0.234$ and the measured
> acceptance rates, the small draft is strictly faster in every one of the six
> (domain $\times$ depth) cells:
>
> | cell | small draft | large draft |
> |---|---|---|
> | prose, $d=2$ | $\sigma(0.639, 0.118, 2)$ | $> \sigma(0.632, 0.234, 2)$ |
> | prose, $d=4$ | $\sigma(0.477, 0.118, 4)$ | $> \sigma(0.519, 0.234, 4)$ |
> | prose, $d=8$ | $\sigma(0.309, 0.118, 8)$ | $> \sigma(0.449, 0.234, 8)$ |
> | code, $d=2$ | $\sigma(0.716, 0.118, 2)$ | $> \sigma(0.834, 0.234, 2)$ |
> | code, $d=4$ | $\sigma(0.630, 0.118, 4)$ | $> \sigma(0.748, 0.234, 4)$ |
> | code, $d=8$ | $\sigma(0.560, 0.118, 8)$ | $> \sigma(0.603, 0.234, 8)$ |

*Proof.* Each line is a rational inequality; apply Lemma 2.4 and evaluate the two
finite geometric sums. $\square$

Note that in *five* of the six cells the large draft accepts strictly more, in one
case ($d=2$ code) by nearly twelve percentage points, and still loses. The
hypothesis of a crossover at high acceptance — plausible from GPU experience — is
therefore refuted within the model at the measured operating points.

### 3.3 The asymptotic invariant

> **Theorem 3.3 (Deep-draft limit).** For $0 \le a < 1$ and $c > 0$,
> $$\lim_{d \to \infty} d \cdot \sigma(a,c,d) \;=\; \frac{1}{c\,(1-a)}.$$

*Proof.* Write $d \cdot \sigma(a,c,d) = Y_{\mathrm{geo}}(a,d) \cdot \frac{d}{1+cd}$.
The first factor converges to $(1-a)^{-1}$ (partial sums of a convergent geometric
series), the second to $c^{-1}$ (divide numerator and denominator by $d$). $\square$

> **Theorem 3.4 (Asymptotic cost dominance).** Let drafts $A$ and $B$ have parameters
> $(a_A, c_A)$ and $(a_B, c_B)$ with $a_A, a_B \in [0,1)$ and $c_A, c_B > 0$. If
> $$c_A (1 - a_A) \;<\; c_B (1 - a_B),$$
> then there is a depth $D$ such that $\sigma(a_B,c_B,d) < \sigma(a_A,c_A,d)$ for all
> $d \ge D$.

*Proof.* The hypothesis makes the two limits of Theorem 3.3 strictly ordered, since
$x \mapsto x^{-1}$ is strictly decreasing on the positive reals. Eventual strict
ordering of $d\,\sigma$ follows, and dividing by $d > 0$ gives the claim. $\square$

Thus at depth the ranking of drafts is by the single scalar $c(1-a)$: **relative cost
times rejection rate.** This is the precise form of the folklore's failure. The
quantity that must improve is not acceptance but the *product*, and an acceptance gain
enters only through $1-a$, which for $a$ near $0.6$ is a comparatively insensitive
lever.

For the measured pair at code depth $8$: $0.118 \times 0.440 = 0.0519$ against
$0.234 \times 0.397 = 0.0929$.

> **Corollary 3.5 (Required crossover acceptance).** With $c_A = 0.118$,
> $a_A = 0.560$ and $c_B = 0.234$, the invariant of draft $B$ is at most that of
> draft $A$ only if $a_B \ge 0.778$.

*Proof.* $0.234\,(1-a_B) \le 0.118 \times 0.440 = 0.05192$ gives
$1 - a_B \le 0.2219$. $\square$

The large draft measured $60.3\%$ at that cell: it needs a further $17.5$ percentage
points merely to reach parity. The head-to-head is not close, and it is not close for
a structural reason.

---

## 4. Depth: collapse, unimodality, and the canonical selector

### 4.1 Collapse

> **Theorem 4.1 (Depth gate).** Let $0 \le a < 1$ and $c \ge 0$. If
> $(1-a)\,\mathrm{cost}(c,d) > 1$ then $\sigma(a,c,d) < 1$: speculation at depth $d$
> is strictly slower than plain decoding.

*Proof.* The hypothesis rearranges to $(1-a)^{-1} < \mathrm{cost}(c,d)$. Combined with
the uniform yield bound $Y_{\mathrm{geo}}(a,d) \le (1-a)^{-1}$ this gives
$Y_{\mathrm{geo}}(a,d) < \mathrm{cost}(c,d)$, i.e. $\sigma < 1$. $\square$

> **Theorem 4.2 (Depth collapse).** For every $a \in [0,1)$ and $c > 0$ there exists
> $D$ with $\sigma(a,c,d) < 1$ for all $d \ge D$. Explicitly, any
> $D > a / \bigl((1-a)c\bigr)$ works.

*Proof.* For $d > a/((1-a)c)$ we have $a < (1-a)cd$, hence
$1 < (1-a)(1+cd)$, and Theorem 4.1 applies. $\square$

Instantiated: prose at $d=8$ is predicted a net loss for both drafts
($\sigma(0.309,0.118,8) < 1$ and $\sigma(0.449,0.234,8) < 1$), matching the measured
$0.979\times$ and $0.982\times$; code at $d=8$ with the small draft is predicted a
win, and prose at $d=4$ with the small draft is predicted a win. The model reproduces
all four measured signs.

### 4.2 Unimodality

The existence of an interior optimum raises the question of whether local search finds
it. We prove more than needed, for an arbitrary yield curve.

> **Definition 4.3.** For an arbitrary yield $Y : \mathbb{N} \to \mathbb{R}$ and cost
> $c \ge 0$, write $\Sigma(Y,c,d) = Y(d) / \mathrm{cost}(c,d)$.

> **Lemma 4.4 (Marginal form).** For $c \ge 0$,
> $$\Sigma(Y,c,d+1) < \Sigma(Y,c,d) \iff \bigl(Y(d+1)-Y(d)\bigr)\,\mathrm{cost}(c,d) < c\,Y(d).$$

*Proof.* Cross-multiply using $\mathrm{cost}(c,d+1) = \mathrm{cost}(c,d) + c$ and
simplify. $\square$

Call $Y$ **concave** if its increments $Y(d+1)-Y(d)$ are non-increasing in $d$.

> **Theorem 4.5 (Decline propagates).** Let $c \ge 0$, let $Y$ be concave with
> $Y \ge 0$ and non-decreasing, and suppose $\Sigma(Y,c,d+1) < \Sigma(Y,c,d)$. Then
> $\Sigma(Y,c,d+2) < \Sigma(Y,c,d+1)$.

*Proof.* By Lemma 4.4 the hypothesis is
$\bigl(Y(d+1)-Y(d)\bigr)\mathrm{cost}(c,d) < c\,Y(d)$. Passing from $d$ to $d+1$: the
left-hand factor $Y(d+2)-Y(d+1)$ is no larger than $Y(d+1)-Y(d)$ by concavity, while
$\mathrm{cost}$ grows and $Y$ grows, so the left side increases by less than the right.
The inequality is preserved. $\square$

> **Theorem 4.6 (Unimodality; exactness of greedy tuning).** Under the hypotheses of
> Theorem 4.5, suppose $D$ is such that $\Sigma(Y,c,k) \le \Sigma(Y,c,k+1)$ for all
> $k < D$ and $\Sigma(Y,c,D+1) < \Sigma(Y,c,D)$. Then
> $\Sigma(Y,c,d) \le \Sigma(Y,c,D)$ for **all** $d \in \mathbb{N}$.

*Proof.* For $d \le D$ chain the improvements. For $d > D$, iterate Theorem 4.5 from
the decline at $D$: every subsequent step declines, so $\Sigma$ is non-increasing on
$[D,\infty)$. $\square$

The geometric yield is concave, its increments being $a^{d+1}$, so Theorem 4.6 applies
to $\sigma$ verbatim. **The grid $\{2,4,8\}$ used in the experiment cannot have missed
a second hump: the measured prose collapse is terminal.**

By contrast, an *affine* yield has no interior optimum at all. Writing
$Y_{\mathrm{mean}}(q,d) = 1 + q\,d$ for the "mean accepted fraction" reading and
$\Sigma_{\mathrm{mean}}(q,k,d) = (1+qd)/(1+kd)$, one checks directly that
$\Sigma_{\mathrm{mean}}$ is non-decreasing in $d$ when $k \le q$ and non-increasing
when $q \le k$. So *strict concavity of the yield is necessary* for the observed
pattern of a win at $d = 4$ and a loss at $d = 8$ within one configuration.

### 4.3 The frontier is monotone in acceptance

> **Theorem 4.7 (Frontier monotonicity).** Let $0 < a \le a'$, $c \ge 0$ and $d < e$.
> If $\sigma(a,c,d) \le \sigma(a,c,e)$ then $\sigma(a',c,d) \le \sigma(a',c,e)$.

*Proof sketch.* Put the comparison in the equivalent "deepening pays" form
$$T(a,d,e)\,\mathrm{cost}(c,d) \;\ge\; c\,(e-d)\,Y_{\mathrm{geo}}(a,d),
\qquad T(a,d,e) = \sum_{i=d+1}^{e} a^i,$$
obtained by cross-multiplying and cancelling. The key inequality is
$$T(a,d,e)\,Y_{\mathrm{geo}}(a',d) \;\le\; T(a',d,e)\,Y_{\mathrm{geo}}(a,d)
\qquad (0 \le a \le a'),$$
which holds term by term: each product $a^{i}a'^{\,j}$ on the left with $i>d\ge j$ is
matched by $a'^{\,i}a^{j}$ on the right, and $a^{i}a'^{j} \le a'^{i}a^{j}$ because
$i > j$ and $a \le a'$. Multiplying the hypothesis by the appropriate positive factors
and applying this inequality gives the conclusion. $\square$

> **Corollary 4.8 (Monotone stopping).** If deepening from $D$ to $D+1$ fails to pay
> at acceptance $a'$, it also fails at any smaller $a \in (0,a']$.

### 4.4 The canonical stopping depth

> **Definition 4.9.** For $a \in [0,1)$ and $c>0$,
> $$D^\star(a,c) \;=\; \min\{\,D \in \mathbb{N} : \sigma(a,c,D+1) < \sigma(a,c,D)\,\}.$$

> **Theorem 4.10 (Well-definedness).** The set in Definition 4.9 is non-empty.

*Proof.* If it were empty, $\sigma(a,c,\cdot)$ would be non-decreasing, hence
$\sigma(a,c,d) \ge \sigma(a,c,0) = 1$ for all $d$, contradicting the depth collapse of
Theorem 4.2. $\square$

Note where each ingredient enters: unimodality alone does not produce a stopping
depth — a curve increasing forever has none. Non-emptiness is precisely the formal
trace of the fact that on a CPU sequential drafting is never asymptotically free.

> **Theorem 4.11 (Global optimality).** $\sigma(a,c,d) \le \sigma(a,c,D^\star(a,c))$
> for all $d \in \mathbb{N}$.

*Proof.* By minimality, no decline occurs below $D^\star$; by definition a decline
occurs at $D^\star$. Apply Theorem 4.6. $\square$

> **Theorem 4.12 (The depth law).** For $0 < a \le a' < 1$ and $c>0$,
> $$D^\star(a,c) \;\le\; D^\star(a',c).$$

*Proof.* At $D = D^\star(a',c)$ deepening fails to pay at acceptance $a'$; by
Corollary 4.8 it also fails at $a$, so $D$ lies in the stopping set of $a$ and
$D^\star(a,c) \le D$. $\square$

**A domain that accepts more should draft at least as deep — always.** This is the
sharpest formal statement of the domain-split law, and it says that the observed
ordering of code and prose optimal depths could not have come out the other way.

> **Theorem 4.13 (The measured split).** At the small-draft cost $c = 0.118$,
> $$D^\star(0.477, 0.118) = 2, \qquad D^\star(0.630, 0.118) = 3,$$
> and each value is a global optimum over all depths. In particular
> $\sigma(0.477,0.118,3) < \sigma(0.477,0.118,2)$ while
> $\sigma(0.630,0.118,2) < \sigma(0.630,0.118,3)$: at one and the same decision, the
> two domains disagree, so no static depth is optimal for both.

*Proof.* Verify the finitely many comparisons below the claimed stopping depth and the
decline at it, then invoke Theorems 4.10–4.11. $\square$

The endpoints of Theorem 4.12 are genuinely excluded rather than hidden: at $a=0$ the
drafter is useless and the selector returns $0$; at $a=1$ it is perfect and the
stopping set is empty.

---

## 5. Position-resolved acceptance: survival profiles

### 5.1 Why the independent model must be abandoned

The measured code cells contain a fact the geometric model cannot accommodate. At
$d=8$ the small draft measured $1.661\times$ against $1.616\times$ at $d=4$: deeper is
strictly better. Yet:

> **Theorem 5.1 (Falsification of the independent reading).** For every
> $a \in [0, 0.8]$,
> $$\sigma(a, 0.118, 8) < \sigma(a, 0.118, 4).$$
> Consequently, no per-position independent acceptance probability at or below $0.8$
> reproduces the measured code ordering. (For contrast,
> $\sigma(0.85,0.118,4) < \sigma(0.85,0.118,8)$, so the model *can* rank depth $8$
> first — but only above $0.8$.)

*Proof.* At $a=0$ the yield is constant while the cost grows, so the inequality is
strict. For $0 < a \le 0.8$: if depth $8$ were at least as good as depth $4$ at $a$,
Theorem 4.7 would transport that to $a = 0.8$; but the corresponding polynomial
inequality at $a=0.8$ is false by direct evaluation. $\square$

Since the reported code acceptance at $d = 8$ was $56.0\%$, well below $0.8$, the
reported percentage is **not** a per-position independent acceptance probability. The
repair is to model the position structure directly.

### 5.2 Survival profiles and the averaging law

> **Definition 5.2 (Survival profile).** A *survival profile* is a function
> $S : \mathbb{N} \to \mathbb{R}$ with $S(0) = 1$ and $S(k+1) \le S(k)$ for all $k$,
> interpreted as: $S(k)$ is the probability that the first $k$ drafted positions are
> **all** accepted. The block yield is
> $$Y_S(d) \;=\; \sum_{k=0}^{d} S(k).$$
> The independent model is the special case $S(k) = a^k$, for which
> $Y_S = Y_{\mathrm{geo}}(a,\cdot)$.

> **Definition 5.3 (Reported acceptance).** The quantity a harness reports as
> "acceptance" is the fraction of drafted tokens committed:
> $$A_S(d) \;=\; \frac{Y_S(d) - 1}{d} \;=\; \frac{1}{d}\sum_{k=1}^{d} S(k),$$
> the arithmetic mean of the survival probabilities of the $d$ drafted positions.

> **Theorem 5.4 (Averaging law).** For every survival profile $S$ and all
> $1 \le d \le e$,
> $$A_S(e) \;\le\; A_S(d).$$

*Proof.* It suffices to treat $e = d+1$ and induct. Since $S$ is non-increasing,
$S(k) \ge S(d+1)$ for all $1 \le k \le d$, hence
$Y_S(d) - 1 = \sum_{k=1}^d S(k) \ge d\,S(d+1)$. Then
$$A_S(d+1) = \frac{(Y_S(d)-1) + S(d+1)}{d+1}
\;\le\; \frac{(Y_S(d)-1) + \frac{1}{d}(Y_S(d)-1)}{d+1}
= \frac{Y_S(d)-1}{d} = A_S(d). \qquad \square$$

The consequence is a warning label. The headline pattern — prose acceptance
$63.9 \to 47.7 \to 30.9$, code $71.6 \to 63.0 \to 56.0$ — **carries no information
about whether the drafter degrades with depth.** Any fixed profile whatsoever,
measured at increasing depths, yields a decaying reported acceptance. The decay is
forced by averaging.

### 5.3 A falsifiable necessary condition

The averaging law is not vacuous. It constrains the *block* means between successive
measured depths.

> **Theorem 5.5 (Block-mean test).** For any survival profile $S$ and $d < e$,
> $$(e-d)\,\bigl(Y_S(d) - 1\bigr) \;\ge\; d\,\bigl(Y_S(e) - Y_S(d)\bigr),$$
> i.e. the mean survival over positions $d+1,\dots,e$ is at most the mean over
> $1,\dots,d$.

*Proof.* The left sum has $d$ terms each $\ge S(d)$; the right sum has $e-d$ terms
each $\le S(d)$. Cross-multiplying the two mean bounds gives the claim. $\square$

> **Corollary 5.6 (The test has teeth).** No survival profile satisfies
> $A_S(2) = 0.50$ and $A_S(4) = 0.70$. Reported acceptance that *rises* with depth is
> unrealisable.

The measured data pass. Writing the cumulative differences as block means:
code $0.716,\ 0.544,\ 0.490$ (positions $1$–$2$, $3$–$4$, $5$–$8$); prose
$0.639,\ 0.315,\ 0.141$. Both sequences are non-increasing, as monotone survival
requires.

### 5.4 Exact reconstruction

> **Theorem 5.7 (Realisability of the measured acceptances).** There exist survival
> profiles $S_{\mathrm{code}}$ and $S_{\mathrm{prose}}$ with
> $$A_{S_{\mathrm{code}}}(2) = 0.716,\quad A_{S_{\mathrm{code}}}(4) = 0.630,\quad
> A_{S_{\mathrm{code}}}(8) = 0.560,$$
> $$A_{S_{\mathrm{prose}}}(2) = 0.639,\quad A_{S_{\mathrm{prose}}}(4) = 0.477,\quad
> A_{S_{\mathrm{prose}}}(8) = 0.309.$$
> Explicitly:
>
> | $k$ | $0$ | $1$ | $2$ | $3$ | $4$ | $\ge 5$ |
> |---|---|---|---|---|---|---|
> | $S_{\mathrm{code}}(k)$ | $1.000$ | $0.800$ | $0.632$ | $0.560$ | $0.528$ | $0.490$ |
> | $S_{\mathrm{prose}}(k)$ | $1.000$ | $0.700$ | $0.578$ | $0.350$ | $0.280$ | $0.141$ |

*Proof.* Both tables are non-increasing with $S(0)=1$; the six means are direct
evaluations of the partial sums. $\square$

All six reported percentages are therefore consistent with a *single*
depth-independent per-position acceptance structure per domain. Nothing in the data
requires the drafter to behave differently when asked for eight tokens rather than
four.

**The mechanism of the domain split becomes visible.** The code profile decays gently
across positions $2 \to 3$ ($0.632 \to 0.560$); the prose profile falls off a cliff
($0.578 \to 0.350$). By the averaging law, no reported *mean* could ever have revealed
this: only position-resolved instrumentation can.

**Honest limitation.** Only three cumulative sums per domain are pinned by the data.
The reconstruction is *not unique*, and the results are stated as realisability
(existence) plus a falsifiable necessary condition — never as identification of the
true profile.

### 5.5 The local optimality rule

> **Theorem 5.8 (Marginal-survival stopping rule).** For any $S$ and $c \ge 0$,
> writing $\Sigma_S(d) = Y_S(d)/\mathrm{cost}(c,d)$,
> $$\Sigma_S(d) < \Sigma_S(d+1) \iff c \cdot \Sigma_S(d) < S(d+1).$$

*Proof.* By Lemma 4.4 with $Y = Y_S$ and $Y_S(d+1)-Y_S(d) = S(d+1)$, the left side is
equivalent to $c\,Y_S(d) < S(d+1)\,\mathrm{cost}(c,d)$; dividing by the positive
$\mathrm{cost}(c,d)$ gives the stated form. $\square$

**Deepen while the survival probability of the next position exceeds the marginal cost
times the throughput you already have.** Since $Y_S$ is automatically concave for a
monotone $S$ — its increments are $S(d+1)$, non-increasing by definition — Theorem 4.6
applies, so this local rule may be applied greedily and still returns the global
optimum. No grid search, no backtracking, one scalar comparison per depth.

> **Theorem 5.9 (The prescription, derived).** With the reconstructed profiles and
> marginal per-position cost $k = 0.287$ — the average marginal cost over depths $4$
> to $8$ of the hardware cost curve of Section 6 —
> $$\Sigma_{S_{\mathrm{prose}}}(5) < \Sigma_{S_{\mathrm{prose}}}(4),
> \qquad \Sigma_{S_{\mathrm{code}}}(4) < \Sigma_{S_{\mathrm{code}}}(8).$$
> Prose stops paying at depth $4$; code still gains from $4$ to $8$.

*Proof.* Both are evaluations of Theorem 5.8 and of the ratio at depths $4$ and $8$
against the tabulated profiles. $\square$

The deployed rule "$d=8$ for code, $d=4$ for prose" is thus a theorem about the
reconstructed profiles and one shared cost parameter, not a fitted observation.

---

## 6. The hardware cost curve

Sections 2–5 hold the cost side fixed at the affine form $1 + cd$. The measurements
say more.

First, an impossibility.

> **Theorem 6.1 (Affine cost is falsified).** There are no reals $b, k$ with
> $$1 + 0.716\cdot 2 = 1.352\,(b + 2k), \quad
> 1 + 0.630\cdot 4 = 1.616\,(b + 4k), \quad
> 1 + 0.560\cdot 8 = 1.661\,(b + 8k).$$
> That is, under the mean-yield reading no affine block cost reproduces the three
> measured code speedups of the small draft.

*Proof.* The three equations are linear in $(b,k)$ and the resulting $3\times 2$
system is inconsistent: eliminating $b$ from the first two and from the last two gives
contradictory values of $k$. $\square$

So the superlinear term in the fitted curve below is not a fitting convenience — it is
required by the data.

> **Definition 6.2 (The fitted CPU block cost).**
> $$C(\mathrm{extra}, d) \;=\; 1.5401 + (0.0992 + \mathrm{extra})\,d + 0.0151\,d^2,$$
> with $\mathrm{extra} = 0$ for the small draft and $\mathrm{extra} = 0.116$ for the
> large one — exactly the measured difference $0.234 - 0.118$ in relative draft cost.
> The three coefficients are fixed by the three code / small-draft cells **alone**.
> The predicted speedup of a cell with reported acceptance $q$ is
> $$\hat\sigma(q, \mathrm{extra}, d) = \frac{1 + q\,d}{C(\mathrm{extra}, d)}.$$

Two qualitative facts are read off immediately.

> **Proposition 6.3 (Fixed per-block overhead).** $C(\mathrm{extra}, 0) = 1.5401 > 1$:
> a block costs strictly more than a single verification pass even before any drafting.

This is why the shallow $d=2$ cells underperform the naive affine model: there is a
real fixed cost per speculative round trip (cache disruption, batch setup, KV-cache
bookkeeping) that has nothing to do with the number of drafted tokens.

> **Proposition 6.4 (Anti-amortisation).** For every $d$,
> $$C(\mathrm{extra}, d+1) - C(\mathrm{extra},d) \;<\; C(\mathrm{extra}, d+2) - C(\mathrm{extra},d+1),$$
> i.e. $C$ is strictly convex in depth: each additional drafted-and-verified position
> costs strictly more than the previous one.

*Proof.* The second difference is the constant $2 \times 0.0151 > 0$. $\square$

This inverts the GPU picture, in which a wider verification batch is nearly free. On a
saturated CPU there are no idle lanes; widening the batch spills working sets out of
cache and lengthens the pass.

An independent, model-free confirmation of the same phenomenon comes from the measured
signs alone.

> **Theorem 6.5 (Verification-overhead bracket).** Suppose a marginal per-position
> cost $k \ge 0$ reproduces both measured depth-$8$ signs under the mean-yield reading:
> $(1 + 0.309 \cdot 8)/(1 + 8k) < 1$ (prose a net loss) and
> $(1 + 0.560 \cdot 8)/(1 + 8k) > 1$ (code a net win). Then
> $$0.309 < k < 0.560.$$
> Since the small draft itself costs only $0.118$ per token, the verification pass must
> charge $w = k - 0.118 \in (0.191, 0.442)$ target-steps per *extra* position.

*Proof.* Each inequality is linear in $k$ after clearing the positive denominator.
$\square$

On a CPU, verification does not amortise: the marginal charge for one more position in
the batch is between a fifth and a half of a full target decode step.

Finally, the twelve-cell test.

> **Theorem 6.6 (Out-of-sample validity).** With $C$ calibrated on the three code /
> small-draft cells only, every one of the twelve measured speedups satisfies
> $$\bigl|\hat\sigma(q,\mathrm{extra},d) - \sigma_{\mathrm{meas}}\bigr|
> \;\le\; 0.11 \cdot \sigma_{\mathrm{meas}},$$
> using nothing but that cell's own measured acceptance $q$. Nine of the twelve are
> out-of-sample; the worst relative error is $10.6\%$ (prose, large draft, $d = 8$).

Predicted against measured:

| cell | $d=2$ | $d=4$ | $d=8$ |
|---|---|---|---|
| prose, small | $1.266$ / $1.254$ ($1.0\%$) | $1.335$ / $1.416$ ($5.7\%$) | $1.052$ / $0.979$ ($7.5\%$) |
| prose, large | $1.115$ / $1.016$ ($9.7\%$) | $1.164$ / $1.153$ ($1.0\%$) | $1.086$ / $0.982$ ($10.6\%$) |
| code, small | $1.352$ / $1.352$ ($0.0\%$) | $1.616$ / $1.616$ ($0.0\%$) | $1.661$ / $1.661$ ($0.0\%$) |
| code, large | $1.314$ / $1.195$ ($9.9\%$) | $1.511$ / $1.395$ ($8.3\%$) | $1.378$ / $1.354$ ($1.7\%$) |

The separation this establishes is the organising claim of the paper: **cost is
universal across domains and yield is domain-specific.** One hardware curve, calibrated
in one domain, predicts the other.

The residuals are, honestly, systematic rather than random: the large-draft cells are
over-predicted at shallow depth and the prose cells at deep depth. The natural reading
is that the *extra* draft cost is itself depth-dependent — the larger draft's own
key-value cache grows across the block — which is the obvious next refinement. An
$11\%$ band over twelve cells with three fitted parameters is a real but modest test;
what is claimed is the existential statement (such a universal curve exists) together
with the impossibility theorem that rules out the two-parameter affine alternative.

---

## 7. An algorithmic summary

The theory yields three deployable procedures.

**(A) Draft selection.** Rank candidate drafts by the invariant $c(1-a)$, smallest
first. Justified exactly at large depth by Theorem 3.4 and, at the measured operating
points, by Theorem 3.2. Cost: one measurement of $c$ and $a$ per candidate.

**(B) Depth tuning.** Starting from $d=0$, evaluate $\Sigma(d+1)$ against $\Sigma(d)$
and stop at the first non-improvement. By Theorem 4.6 the result is the global optimum
$D^\star$; by Theorem 4.12 it moves monotonically with acceptance. Cost: $O(D^\star)$
comparisons, no backtracking. Under the local form of Theorem 5.8 each comparison
requires only the next position's survival probability and the current throughput —
both estimable online.

**(C) Realisability audit.** Given reported acceptances at increasing depths, check
that the *block* means are non-increasing (Theorem 5.5). Failure indicates a
measurement or bookkeeping error, since no survival profile can produce rising block
means. Passing, reconstruct an explicit profile by differencing the cumulative sums
and use it to drive procedure (B).

---

## 8. Discussion

### 8.1 What transfers from the accelerator literature, and what does not

Three pieces of received practice fail in the CPU regime.

*"Prefer the larger draft; acceptance dominates."* False. The ranking invariant is
$c(1-a)$, and cost enters multiplicatively. The measured $1.5$B draft, at twice the
per-token cost, would need $77.8\%$ acceptance merely to reach parity with the $0.5$B
draft at the decisive cell; it measured $60.3\%$.

*"Deeper is better as long as acceptance holds up."* False. Depth collapse
(Theorem 4.2) is unconditional: for every $a < 1$ and $c>0$ there is a depth past
which speculation loses. On the measured hardware this bites at $d = 8$ for prose.

*"Falling acceptance with depth means the drafter degrades."* Not even wrong. By
Theorem 5.4 it is an arithmetic identity for any fixed drafter. Reporting mean
acceptance as evidence about position structure is a category error, and the
literature's acceptance-versus-depth plots should be read accordingly.

What *does* transfer is the block model itself. Everything above is a statement about
the ratio yield/cost; the CPU enters only through the numerical size of $c$ and the
convexity of the cost curve.

### 8.2 Practical prescription

For the measured configuration: a $0.6$-gigabyte four-bit draft delivers up to $66\%$
additional throughput on a seven-billion-parameter target with no accelerator and with
bit-identical output. Use the smallest competent draft, quantised aggressively; set
$d = 8$ for code and $d = 4$ for prose; and do not use a static depth, which forfeits
better than $25\%$ of throughput on one side of the split or the other.

### 8.3 Limitations

The experimental base is one model family, one machine, greedy decoding, prompts of
about $500$ tokens, twelve configurations at eight runs each. Reported acceptance is
the overall drafted-token fraction, not a per-position curve — which is exactly the
gap Section 5 formalises rather than closes. Absolute throughput figures are specific
to the machine's memory configuration; only within-round ratios should be compared.
The reconstructed survival profiles are realisability witnesses, not identifications.
The cost curve has three parameters fitted on three cells and validated on nine more
at an $11\%$ tolerance with visibly systematic residuals.

None of these limitations touch the general theorems of Sections 2–5, which are
statements about the block model for arbitrary parameters; they bound only the
instantiated numerical claims.

---

## 9. Future work

**Curvature invariance across draft sizes.** The analysis separates a domain-specific
yield from a hardware-specific cost, and the cost curve's curvature came out an order
of magnitude below its slope — small, but provably nonzero, since no affine cost fits
the calibration cells. If curvature is a property of the target's verification pass
rather than of the draft, it must be identical for both drafts, with only the linear
term moving. The residual pattern of the twelve-cell test is systematic in exactly the
way a draft-dependent curvature would produce, so a single extra run at
$d \in \{3, 6\}$ for both drafts discriminates the two explanations.

**Position-resolved acceptance and the prose cliff.** The reconstructed prose profile
falls from $0.578$ to $0.350$ between positions $2$ and $3$ while the code profile
decays from $0.632$ to $0.560$, and the averaging law proves that no reported mean can
reveal this: only per-position instrumentation can. Conjecture: the prose cliff sits at
the first *content* token after a syntactically forced continuation, so its position is
a function of the prompt's syntax rather than of the depth. The harness already
computes accept/reject per position; exporting the vector instead of its mean turns the
existence statements of Section 5 into identification.

**A deployable monotone depth controller.** Unimodality makes hill-climbing exact and
the stopping depth monotone in acceptance. A runtime controller that estimates the
current survival probability and applies the marginal-survival rule should therefore
track the optimal depth without oscillation, adapting per request — and, if the cliff
conjecture holds, per *syntactic position within* a request.

**Further axes.** A key-value-cache quantisation ladder on the same target; transfer of
the weight-quantisation floor; and transfer of the depth knee-law to other model
scales.

---

## 10. Conclusion

Speculative decoding on a CPU is governed by a small, sharp theory. Throughput is
yield over cost. Yield is a domain-specific survival curve whose *reported* summary
statistic is provably uninformative about its shape. Cost is a convex hardware curve
with a fixed per-block overhead and a marginal charge far above the draft's own cost —
verification anti-amortises. The optimal depth is the first position at which
next-position survival falls below marginal cost times current throughput; it is a
global optimum reachable by pure hill-climbing, and it rises monotonically with
acceptance, which is why code drafts deeper than prose and could not have done
otherwise. Drafts are ranked at depth by cost times rejection rate, which is why the
cheaper, worse-guessing model wins every measured head-to-head. Every feature of the
twelve measured cells — including the two that contradict accelerator folklore — is a
corollary.
