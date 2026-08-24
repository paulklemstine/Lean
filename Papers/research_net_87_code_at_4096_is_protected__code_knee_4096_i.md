# The Narrowing Domain Factor and the Permanence of Protection in Attention Retention Knees

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study the *retention knee* of an attention profile: the smallest number of
positions one must retain in order to preserve a prescribed fraction of the
attention mass. Sweeping the knee across context lengths for two text domains —
source code and ordinary prose — yields the code chain
$\{12 \text{ at ctx } 512,\; 16 \text{ at ctx } 1024,\; 32 \text{ at ctx } 4096\}$
against a prose knee of $40$ at ctx $4096$, with a code knee of $16$ at ctx $512$.
Two qualitative claims follow from the sweep: an *acceleration* (the value $32$
exceeds every extrapolation from short-context increments, which cap it at $24$)
and a *narrowing* of the code/prose domain factor from $3/4$ to $4/5$.

We give a complete structural theory of both phenomena. First, we characterise
exactly what a coarse fail/pass pair licenses: a fail at $28$ and a pass at $32$
bracket the knee in $[29, 32]$, and we exhibit two nonnegative antitone profiles
with identical retention at every grid point outside $(28,32)$ whose knees are
$29$ and $32$, so the bracket is not improvable without a finer grid. Second, we
prove that domain protection at *every* threshold is equivalent to pointwise
dominance of retention curves. Third, we model each domain by an affine knee law
$K_d(T) = a_d + b_d T$ in a shared phase-transition coordinate and prove: the
domain factor is strictly increasing iff $a_c b_p < a_p b_c$; under that
condition it satisfies $r(T) < b_c/b_p$ for all $T$ with $r(T) \to b_c/b_p$;
the domain gap is affine with slope $b_p - b_c$; and consequently a
*simultaneous* increase of ratio and gap forces $b_c < b_p$ and hence permanent
protection with limiting factor strictly below $1$. We show that two measured
ratios alone cannot determine the limit — exhibiting laws with the same measured
pair $(3/4, 4/5)$ and limits $5/6$ and $1$ — so the gap, not the ratio, is the
discriminating observable. Fourth, we show the acceleration is exactly a failure
of concavity: every knee law with nonincreasing per-doubling increments obeys
$K(j) \le K(0) + j(K(1)-K(0))$, which caps $K(3)$ at $24$.

We then establish a rigidity theorem for the shared-coordinate model — the
normalised increment over three contexts is domain free, and conversely — giving
the parameter-free forecast $K(4096) = K(512) + 5(K(1024) - K(512))$; a
quantitative narrowing rate showing the observed $0.80$ is far from saturation;
and stability of protection under domain-dependent tokenisation. Finally, we
read the whole verdict on attention decay rates via the exact exponential-tail
knee $K = \log(1/\delta)/\lambda$: the domain factor is an inverse rate ratio,
the code chain forces $\lambda_3 = \tfrac38 \lambda_0$ (super-harmonic
degradation), and no generalised harmonic family $\lambda_j = C/(j+c)$ fits the
chain.

**Keywords:** attention retention, knee, domain factor, phase transition, affine
knee law, concavity refutation, cross-ratio invariance, exponential tail.

---

## 1. Introduction

### 1.1 The knee

Let a *profile* be a function $p : \mathbb{N} \to \mathbb{R}$ assigning a
nonnegative weight $p(i)$ to each position $i$, thought of as the attention mass
placed on position $i$ after sorting positions from most- to least-attended (so
$p$ is antitone in the cases of interest). Define the **prefix mass**
$$M_p(k) \;=\; \sum_{i < k} p(i),$$
the mass retained by keeping the top $k$ positions, and, for a retention bar
$\tau$, the **knee**
$$k^{*}_p(\tau) \;=\; \min\{\,k : M_p(k) \ge \tau\,\},$$
the smallest budget clearing the bar. (The knee is well defined whenever some
budget clears the bar.) The knee is a monotone functional in the obvious ways:
raising the bar cannot lower the knee, and increasing the profile pointwise
cannot raise the knee. We use throughout the two basic facts

* **(K1)** if $\tau \le M_p(k)$ then $k^{*}_p(\tau) \le k$, and
* **(K2)** $\tau \le M_p\bigl(k^{*}_p(\tau)\bigr)$ whenever the knee exists,

together with monotonicity of $M_p$ for nonnegative $p$.

### 1.2 The measurement

The experimental input to this paper is a sweep of the knee across context
lengths in two domains, at a fixed retention bar.

| context | code knee | prose knee |
|---:|---:|---:|
| $512$ | $12$ | $16$ |
| $1024$ | $16$ | — |
| $4096$ | $32$ | $40$ |

At ctx $4096$ the code cell was resolved on a coarse grid: a budget of $28$
retained approximately $0.976$, below the bar, and a budget of $32$ retained
$0.986$, above it. The baseline accuracy on source code at ctx $4096$ was
$0.677$ — remarkably high for this context length, indicating that code's
predictability persists at extreme context.

Two qualitative claims were extracted:

* **P2 (acceleration).** The code knee at $4096$, namely $32$, exceeds any value
  extrapolated from the short-context increments, which cap it at $24$.
* **Narrowing.** The code/prose domain factor moves from $12/16 = 0.75$ at short
  contexts to $32/40 = 0.80$ at $4096$: code remains cheaper, but the gap in
  *relative* terms narrows.

### 1.3 What is proved here

The naive readings of these claims are both dangerous. "The knee is $32$" is a
point value extracted from a four-wide bracket. "The ratio narrows, therefore the
domains converge" is a non sequitur. This paper replaces both with theorems.

Section 2 bounds what a coarse sweep licenses, and proves the bound is sharp.
Section 3 characterises protection across all thresholds. Section 4 develops the
affine two-slope law and proves the permanence theorem, together with an explicit
underdetermination result showing why the gap is the right observable. Section 5
identifies the acceleration as a concavity refutation. Section 6 proves the
rigidity of the shared-coordinate model and derives a parameter-free forecast.
Section 7 quantifies how far the measurement is from saturation. Section 8 proves
stability of protection under tokenisation and refutes the purely multiplicative
domain model. Section 9 reads the verdict on attention decay rates. Section 10
records algorithms; Sections 11–12 discuss applications, limitations, and future
work.

---

## 2. What a coarse fail/pass pair licenses

### 2.1 The bracket

**Theorem 2.1 (Knee bracket).** *Let $p$ be a nonnegative profile and $\tau$ a
bar with $M_p(28) < \tau \le M_p(32)$. Then*
$$28 < k^{*}_p(\tau) \le 32 .$$

*Proof sketch.* The upper bound is (K1) applied at $k = 32$. For the lower
bound, suppose $k^{*}_p(\tau) \le 28$. By (K2), $\tau \le M_p(k^{*}_p(\tau))$, and
by monotonicity of the prefix mass for nonnegative profiles,
$M_p(k^{*}_p(\tau)) \le M_p(28)$, so $\tau \le M_p(28)$, contradicting the fail at
$28$. $\square$

So the sweep proves $k^{*} \in \{29, 30, 31, 32\}$. The reported $32$ is the top
of this bracket.

### 2.2 The bracket is sharp

The bracket cannot be narrowed by any argument applied to the coarse grid alone,
because the coarse grid does not determine it.

**Theorem 2.2 (Grid ambiguity; fine grid necessary).** *There exist profiles $p$
and $q$, both nonnegative and antitone, such that*
$$M_p(k) = M_q(k) \text{ for all } k \le 28, \qquad
M_p(k) = M_q(k) \text{ for all } k \ge 32,$$
*yet at the bar $\tau = 29$ their knees are*
$$k^{*}_p(29) = 29, \qquad k^{*}_q(29) = 32 .$$

*Proof sketch.* Take a common "staircase" head: $p(i) = q(i) = 1$ for $i < 28$,
so both retain exactly $28$ at budget $28$. On the gap $28 \le i < 32$ let $p$
place its remaining mass as early as legal — $p(28) = 1$, then a fast decay — so
that $M_p(29) = 29$ already clears the bar. Let $q$ instead spread the same total
across the four gap positions with a flat, small profile, so that $M_q(29) < 29$,
$M_q(30) < 29$, $M_q(31) < 29$, and only $M_q(32) = 29$ clears it. Beyond $32$
both profiles are identical (indeed both may be taken zero). Antitonicity is
preserved because the gap values in each case are chosen nonincreasing and no
larger than the head value; the totals on the gap are equalised so that the
prefix masses agree from $32$ onward. Then $k^{*}_p(29) = 29$ and $k^{*}_q(29) =
32$. $\square$

**Corollary 2.3.** *Reporting $k^{*} = 32$ reports the top of a four-wide
bracket; the fine grid $24$–$32$ is genuinely necessary to resolve the knee.*

This is an epistemic theorem: it delimits which digits of a measurement carry
information.

### 2.3 Realisability

Lest the configuration be vacuous, we record that all four measured knees are
achieved by honest profiles. Let $U_n$ denote the uniform profile, $U_n(i) = 1$
for $i < n$ and $0$ otherwise; it is nonnegative and antitone with
$M_{U_n}(k) = \min(k, n)$, whence $k^{*}_{U_n}(n) = n$.

**Proposition 2.4 (Configuration realisable).** *There are nonnegative antitone
profiles for code and prose at each of two contexts with knees $12, 16$ and
$32, 40$ respectively — namely $U_{12}, U_{16}, U_{32}, U_{40}$. Hence the
narrowing $3/4 \to 4/5$, the gap growth $4 \to 8$, and protection at both
contexts are jointly consistent with genuine attention profiles.*

---

## 3. Protection is exactly head dominance

The verdict "code is protected" was recorded at one retention bar. We show that
protection *robust across all bars* is equivalent to a pointwise statement about
retention curves — so it is a property of the text, not of the threshold.

**Lemma 3.1 (Dominance transfers to knees).** *If $M_q(k) \le M_c(k)$ for all
$k$, and the bar $\tau$ is reachable by $q$, then $k^{*}_c(\tau) \le
k^{*}_q(\tau)$.*

*Proof sketch.* By (K2), $\tau \le M_q(k^{*}_q(\tau)) \le M_c(k^{*}_q(\tau))$, and
(K1) then gives $k^{*}_c(\tau) \le k^{*}_q(\tau)$. $\square$

**Theorem 3.2 (Protection ⟺ head dominance).** *Let $c$ be nonnegative. Then*
$$M_q(k) \le M_c(k) \ \ \forall k
\quad\Longleftrightarrow\quad
\forall \tau \text{ reachable by } q:\ \tau \text{ is reachable by } c
\ \text{and}\ k^{*}_c(\tau) \le k^{*}_q(\tau).$$

*Proof sketch.* ($\Rightarrow$) Reachability transfers because
$\tau \le M_q(k^{*}_q(\tau)) \le M_c(k^{*}_q(\tau))$; the knee inequality is Lemma
3.1. ($\Leftarrow$) Fix $k$ and apply the hypothesis at the bar
$\tau = M_q(k)$, which $q$ reaches at budget $k$. We obtain
$k^{*}_c(M_q(k)) \le k^{*}_q(M_q(k)) \le k$, the last step by (K1). Then by (K2)
and monotonicity of $M_c$ (using nonnegativity of $c$),
$$M_q(k) \;\le\; M_c\bigl(k^{*}_c(M_q(k))\bigr) \;\le\; M_c(k). \qquad\square$$

**Corollary 3.3.** *At ctx $4096$, the reported ordering $32 < 40$ is, whenever
it holds at every bar, the shadow of a domination of the prose retention curve
by the code retention curve at every budget simultaneously.*

Thus a domain ordering that survives every threshold is an ordering of curves,
not a numerical accident of one threshold.

---

## 4. The affine two-slope law and permanent protection

### 4.1 The model

The acceleration suggests that context length is not the natural independent
variable: something is undergoing a transition whose progress, not whose
calendar time, drives the knee. We therefore posit a shared **phase-transition
coordinate** $T \ge 0$ and, for each domain $d$, an affine **knee law**
$$K_d(T) \;=\; a_d + b_d T ,$$
with $a_d$ the structural (domain) baseline and $b_d$ the rate at which the
transition inflates that domain's budget. Write $c$ for code and $p$ for prose,
and define the two observables
$$r(T) = \frac{K_c(T)}{K_p(T)} \quad \text{(domain factor)}, \qquad
G(T) = K_p(T) - K_c(T) \quad \text{(domain gap)} .$$
Throughout we assume $a_p > 0$ and $b_p \ge 0$, so that $K_p(T) > 0$ for
$T \ge 0$.

### 4.2 Narrowing is a sign condition

**Theorem 4.1 (Narrowing criterion).** *Assume $a_p > 0$, $b_p \ge 0$. Then*
$$a_c b_p < a_p b_c
\quad\Longrightarrow\quad
r \text{ is strictly increasing on } [0,\infty),$$
*and conversely, if $r(T_1) < r(T_2)$ for some $0 \le T_1 < T_2$, then
$a_c b_p < a_p b_c$.*

*Proof sketch.* Both denominators are positive, so $r(T_1) < r(T_2)$ is
equivalent to
$$(a_c + b_c T_1)(a_p + b_p T_2) < (a_c + b_c T_2)(a_p + b_p T_1).$$
Expanding, all terms cancel except
$$a_c b_p (T_2 - T_1) < a_p b_c (T_2 - T_1),$$
i.e. $(a_p b_c - a_c b_p)(T_2 - T_1) > 0$. Since $T_2 - T_1 > 0$, this holds iff
$a_c b_p < a_p b_c$. $\square$

Narrowing is therefore *not* a trend that might continue or reverse: it is a
fixed inequality among four constants, holding at all scales or none.

### 4.3 The exact error term and the ceiling

**Theorem 4.2 (Exact error term).** *If $b_p > 0$ and $K_p(T) > 0$ then*
$$r(T) - \frac{b_c}{b_p} \;=\; \frac{a_c b_p - a_p b_c}{b_p\,K_p(T)} .$$

*Proof sketch.* Put both sides of $r(T) - b_c/b_p$ over the common denominator
$b_p (a_p + b_p T)$; the numerator is
$b_p(a_c + b_c T) - b_c(a_p + b_p T) = a_c b_p - a_p b_c$, the $T$-terms
cancelling. $\square$

**Corollary 4.3 (The limit is never attained).** *If $a_p, b_p > 0$ and
$a_c b_p < a_p b_c$, then $r(T) < b_c/b_p$ for every $T \ge 0$.*

**Theorem 4.4 (Convergence).** *If $b_p > 0$ then $r(T) \to b_c/b_p$ as
$T \to \infty$.*

*Proof sketch.* By Theorem 4.2, $r(T) = b_c/b_p + N/(b_p K_p(T))$ with $N$ a
constant. Since $b_p > 0$, $K_p(T) \to \infty$, so the error term tends to $0$.
$\square$

So under narrowing the domain factor climbs strictly toward a ceiling it never
reaches. Whether the ceiling is parity is a question about $b_c$ versus $b_p$,
and — crucially — the ratio's own history cannot settle it.

### 4.4 The gap, and the dichotomy

**Lemma 4.5.** $G(T) = (a_p - a_c) + (b_p - b_c) T$.

**Theorem 4.6 (A growing gap forces distinct slopes).** *If $T_1 < T_2$ and
$G(T_1) < G(T_2)$, then $b_c < b_p$.*

*Proof sketch.* By Lemma 4.5, $G(T_2) - G(T_1) = (b_p - b_c)(T_2 - T_1)$, and
$T_2 - T_1 > 0$. $\square$

**Theorem 4.7 (Dichotomy).** *Let $b_p > 0$ and $b_c \le b_p$. Exactly one of:*

1. $b_c = b_p$, *the gap is constant equal to $a_p - a_c$, and the limiting
   factor is $b_c/b_p = 1$ (eventual parity);*
2. $b_c < b_p$, *the gap is strictly increasing in $T$, and the limiting factor
   is $b_c/b_p < 1$ (permanent protection).*

*Proof sketch.* Case split on $b_c = b_p$ or $b_c < b_p$ and apply Lemma 4.5 and
$b_c/b_p < 1 \iff b_c < b_p$ (using $b_p > 0$). $\square$

### 4.5 The permanence theorem

**Theorem 4.8 (Permanent protection).** *Assume $a_p > 0$, $b_p > 0$, and let
$0 \le T_1 < T_2$. Suppose that between the two contexts*

* *the domain factor increased: $r(T_1) < r(T_2)$, and*
* *the domain gap increased: $G(T_1) < G(T_2)$.*

*Then $b_c < b_p$, the limiting factor $b_c/b_p$ is strictly less than $1$, and*
$$r(T) < \frac{b_c}{b_p} < 1 \qquad \text{for every } T \ge 0 .$$

*Proof sketch.* The gap increase gives $b_c < b_p$ (Theorem 4.6), hence
$b_c/b_p < 1$. The ratio increase gives the narrowing sign condition
$a_c b_p < a_p b_c$ (Theorem 4.1, converse direction), hence $r(T) < b_c/b_p$
for all $T \ge 0$ (Corollary 4.3). $\square$

This is the structural content of the verdict. Narrowing and permanence are not
in tension: the ratio rises while the gap widens, and the ratio's ceiling is
strictly below parity.

### 4.6 Why the gap, and not the ratio

The following result shows that Theorem 4.8's use of the gap is not a
convenience but a necessity.

**Theorem 4.9 (Two ratios underdetermine the limit).** *Consider*
$$\text{Law A: } K_c = 12 + 20T,\ K_p = 16 + 24T,
\qquad
\text{Law B: } K_c = 12 + 4T,\ K_p = 16 + 4T .$$
*Both satisfy $r(0) = 3/4$ and $r(1) = 4/5$. Their limiting factors are $5/6$
and $1$ respectively, and these limits are genuinely attained in the sense of
Theorem 4.4. Their gaps are $4 \to 8$ and $4 \to 4$.*

*Proof sketch.* Direct evaluation: $12/16 = 3/4$, $32/40 = 4/5$, $12/16 = 3/4$,
$16/20 = 4/5$; limits $20/24 = 5/6$ and $4/4 = 1$; gaps $16-12 = 4$, $40-32 = 8$
and $16-12 = 4$, $20-16 = 4$. $\square$

**Corollary 4.10.** *Extrapolating the ratio sequence $0.75 \to 0.80 \to \cdots
\to 1$ is invalid. Two measured ratios are consistent with permanent protection
and with eventual parity, and the two are separated exactly by the gap.*

### 4.7 The measured fit

**Theorem 4.11 (The measured cell fits an affine pair exactly).** *With*
$$K_{\mathrm{code}}(T) = 12 + 20T, \qquad K_{\mathrm{prose}}(T) = 16 + 24T,$$
*and the coordinate normalised so that $T = 0$ at ctx $512$ and $T = 1$ at ctx
$4096$, one has*
$$K_c(0) = 12,\quad K_p(0) = 16,\quad K_c(1) = 32,\quad K_p(1) = 40,$$
$$r(0) = \tfrac34,\quad r(1) = \tfrac45,\quad G(0) = 4,\quad G(1) = 8,$$
*and $r(T) < 5/6$ for every $T \ge 0$, with $r(T) \to 5/6$.*

All four measured knees, both measured ratios, and both measured gaps are
reproduced with no residual. Since the ratio increased and the gap increased,
Theorem 4.8 applies: **code stays cheaper than prose by at least a sixth,
permanently**.

**Theorem 4.12 (A falsifiable prediction).** *The code knee $16$ at ctx $1024$
pins that context to $T = 1/5$, since $12 + 20 \cdot \tfrac15 = 16$. The same fit
then forces*
$$K_{\mathrm{prose}}(1024) = 16 + 24 \cdot \tfrac15 = \tfrac{104}{5} = 20.8,
\qquad r(\tfrac15) = \tfrac{16}{104/5} = \tfrac{10}{13} \approx 0.769 .$$
*A prose sweep at ctx $1024$ kneeing at $20$ or $21$ corroborates the model; a
knee of $24$ or more falsifies it.*

Nothing was fitted to the prose knee at $1024$; it is a genuine out-of-sample
prediction.

---

## 5. Acceleration is a concavity refutation

Index contexts by doublings from $512$: $j = 0, 1, 2, 3$ for $512, 1024, 2048,
4096$. A knee chain $K : \mathbb{N} \to \mathbb{R}$ has **diminishing returns**
(is *concave in doublings*) if
$$K(j+2) - K(j+1) \;\le\; K(j+1) - K(j) \qquad \text{for all } j .$$

**Lemma 5.1.** *Under diminishing returns, $K(j+1) - K(j) \le K(1) - K(0)$ for
every $j$.*

*Proof sketch.* Induction on $j$: trivial at $j = 0$; the step is the concavity
inequality composed with the inductive hypothesis. $\square$

**Theorem 5.2 (Concave chain bound).** *Under diminishing returns,*
$$K(j) \;\le\; K(0) + j\,\bigl(K(1) - K(0)\bigr) \qquad \text{for all } j .$$

*Proof sketch.* Induction on $j$, adding Lemma 5.1 at each step. $\square$

**Theorem 5.3 (P2, the acceleration, formally).** *No chain with diminishing
returns satisfies $K(0) = 12$, $K(1) = 16$, $K(3) = 32$.*

*Proof sketch.* Theorem 5.2 at $j = 3$ gives $K(3) \le 12 + 3 \cdot 4 = 24 <
32$. $\square$

**Corollary 5.4 (Quantified acceleration).** *For any chain with diminishing
returns and $K(0) = 12$, $K(1) = 16$, one has $K(3) \le 24$; the measured value
$32$ exceeds the concave extrapolation by exactly $8$ keys.*

This is precisely the content of "P2 confirmed: the acceleration hits code".
It rules out an entire class of laws, not a particular curve.

### 5.1 Where the acceleration lives

The affine two-slope fit has *constant* increments in $T$ and so is not itself
convex. The two findings are reconciled by observing that the acceleration lives
in the **reparametrisation** $j \mapsto T(j)$ from context doublings to
phase-transition time.

**Proposition 5.5 (The phase coordinate is convex).** *The fit
$K_c(T) = 12 + 20T$ requires $T(0) = 0$, $T(1) = 1/5$, $T(3) = 1$. The
increments are $1/5$ over the first doubling and $(1 - 1/5)/2 = 2/5$ per
doubling thereafter, so $T$ advances with strictly increasing increments.*

The domain does not accelerate; the transition does. The knee responds to the
transition linearly, in every domain, at a domain-specific rate.

---

## 6. Rigidity of the shared coordinate

If all domains ride the same coordinate, the model has a sharp and cheap
falsifier.

**Theorem 6.1 (Increment-ratio invariance).** *For an affine law $K = a + bT$
with $b \ne 0$ and $T_1 \ne T_3$,*
$$\rho \;=\; \frac{K(T_2) - K(T_1)}{K(T_3) - K(T_1)} \;=\; \frac{T_2 - T_1}{T_3 - T_1} .$$
*In particular $\rho$ does not depend on $a$ or on $b$.*

*Proof sketch.* $K(T_i) - K(T_1) = b(T_i - T_1)$; the baseline cancels by
subtraction and the slope by division. $\square$

**Corollary 6.2 (Domain freedom).** *Two domains riding the same coordinate have
equal normalised increments over any three contexts. Testing this requires three
contexts in two domains and no fitting.*

This is the knee analogue of a cross-ratio: invariance under affine
reparametrisation. The converse holds, so the invariant captures the entire
empirical content of the model.

**Theorem 6.3 (Converse: invariance characterises the model).** *Let
$c_1 < c_3$ and $p_1 < p_3$ be knee values at contexts $1$ and $3$ in two
domains, and let $c_2, p_2$ be the values at an intermediate context. If*
$$\frac{c_2 - c_1}{c_3 - c_1} \;=\; \frac{p_2 - p_1}{p_3 - p_1},$$
*then there exist affine laws in a **common** coordinate — with $T_1 = 0$,
$T_3 = 1$, and a single shared $T_2$ — realising all six values, with positive
slopes.*

*Proof sketch.* Take $a_c = c_1$, $b_c = c_3 - c_1 > 0$, $a_p = p_1$,
$b_p = p_3 - p_1 > 0$, and $T_2 = (c_2 - c_1)/(c_3 - c_1)$. Then
$K_c(0) = c_1$, $K_c(1) = c_3$, $K_c(T_2) = c_1 + (c_3 - c_1) T_2 = c_2$ by
construction, and $K_p(T_2) = p_1 + (p_3 - p_1)T_2 = p_2$ using the hypothesis to
rewrite $T_2$ as $(p_2 - p_1)/(p_3 - p_1)$. $\square$

Hence *"one shared phase transition with per-domain slopes"* is neither more nor
less than *"equal normalised increments"*.

### 6.1 The parameter-free forecast

**Theorem 6.4 (Domain-jump forecast).** *If $T_3 - T_1 = 5(T_2 - T_1)$ then for
every affine law,*
$$K(T_3) \;=\; K(T_1) + 5\,\bigl(K(T_2) - K(T_1)\bigr).$$

*Proof sketch.* $K(T_3) - K(T_1) = b(T_3 - T_1) = 5b(T_2 - T_1) = 5(K(T_2) -
K(T_1))$. $\square$

**Theorem 6.5 (The code chain pins the coordinate).** *If an affine law takes the
values $12, 16, 32$ at $T_1, T_2, T_3$, then $T_3 - T_1 = 5(T_2 - T_1)$.*

*Proof sketch.* $b(T_2 - T_1) = 4$ and $b(T_3 - T_1) = 20$; the first forces
$b \ne 0$, and dividing gives the claim. $\square$

**Theorem 6.6 (Prose knee at ctx $1024$ is forced).** *Given the code chain
$12, 16, 32$ and the prose endpoints $16$ at ctx $512$ and $40$ at ctx $4096$,
the shared coordinate leaves no freedom: the prose knee at ctx $1024$ must equal
$104/5 = 20.8$.*

*Proof sketch.* By Theorem 6.5 the coordinate satisfies $T_3 - T_1 = 5(T_2 -
T_1)$. The prose endpoints give $b_p (T_3 - T_1) = 24$, hence
$b_p(T_2 - T_1) = 24/5$, hence $K_p(T_2) = 16 + 24/5 = 104/5$. $\square$

**Corollary 6.7 (Next-cycle targets).** *Under the pinned coordinate, a domain
kneeing at $10$ and $14$ at ctx $512$ and $1024$ must knee at $30$ at ctx $4096$;
one at $14, 20$ must knee at $44$; one at $16, 24$ must knee at $56$. Each is a
single sweep away from falsifying the shared-coordinate model.*

---

## 7. How far from saturation is $0.80$?

**Theorem 7.1 (Quantitative narrowing rate).** *Let $b_p > 0$, $\varepsilon > 0$,
and $K_p(T) > 0$. If*
$$K_p(T) \;\ge\; \frac{|a_c b_p - a_p b_c|}{b_p\,\varepsilon},$$
*then $\bigl|r(T) - b_c/b_p\bigr| \le \varepsilon$.*

*Proof sketch.* Take absolute values in the exact error term (Theorem 4.2):
$|r(T) - b_c/b_p| = |a_c b_p - a_p b_c| / (b_p K_p(T))$, and substitute the
hypothesis on $K_p(T)$. $\square$

**Corollary 7.2 (The measured $0.80$ is early).** *For the fit $12 + 20T$ versus
$16 + 24T$, the numerator is $|12 \cdot 24 - 16 \cdot 20| = |288 - 320| = 32$, so
the factor is within $1/100$ of $5/6$ only once the prose knee exceeds
$32/(24/100) = 400/3 \approx 133.3$ keys (a prose knee of $288$ certainly
suffices). No context yet swept approaches this. The observed narrowing
$0.75 \to 0.80$ is therefore early in the approach to its limit, with most of
the remaining range ahead — and none of it crossing $5/6$.*

---

## 8. Stability under tokenisation, and the failure of a multiplicative model

### 8.1 Tokenisation

Domain-dependent tokenisation is the most natural confound: perhaps code appears
cheaper only because a tokenizer splits code and prose at different granularity.
Model this by a **dilution** operation: given $r \in \mathbb{N}_{>0}$, the
diluted profile $D_r p$ replaces each unit of $p$ by $r$ tokens sharing its mass.
Dilution satisfies two elementary bounds, for a bar $\tau$ reachable by $p$ with
knee $k^{*}_p(\tau) > 0$:
$$k^{*}_{D_r p}(\tau) \;\le\; r \cdot k^{*}_p(\tau),
\qquad
k^{*}_{D_r p}(\tau) \;>\; r\,\bigl(k^{*}_p(\tau) - 1\bigr).$$

**Theorem 8.1 (Protection survives dilution).** *Let $r_c, r_p > 0$, let $\tau$
be reachable by both the code and prose profiles, and suppose the budget
inequality*
$$r_c \cdot k^{*}_{\mathrm{code}}(\tau)
\;\le\; r_p \cdot \bigl(k^{*}_{\mathrm{prose}}(\tau) - 1\bigr)$$
*holds. Then $k^{*}_{D_{r_c}\mathrm{code}}(\tau) < k^{*}_{D_{r_p}\mathrm{prose}}(\tau)$.*

*Proof sketch.* Chain the upper bound for the diluted code knee, the budget
inequality, and the strict lower bound for the diluted prose knee. $\square$

**Corollary 8.2 (The measured cell).** *With $k^{*}_{\mathrm{code}} = 32$ and
$k^{*}_{\mathrm{prose}} = 40$, protection survives whenever $r_c \le r_p$ — in
particular for every tokenizer no coarser on code than on prose.*

*Proof sketch.* $r_c \cdot 32 \le r_p \cdot 32 \le r_p \cdot 39$. $\square$

**Theorem 8.3 (Sharpness).** *The budget inequality cannot simply be dropped:
with $k^{*}_{\mathrm{code}} = 32$, $k^{*}_{\mathrm{prose}} = 40$, $r_c = 8$ and
$r_p = 1$, the diluted prose knee is strictly below the diluted code knee.*

*Proof sketch.* The diluted prose knee is at most $1 \cdot 40 = 40$, while the
diluted code knee strictly exceeds $8(32 - 1) = 248$. $\square$

So protection is a genuine (and mild) constraint on the tokenizer rather than a
theorem about profiles alone — and every realistic tokenizer satisfies it.

### 8.2 The multiplicative model is refuted

**Theorem 8.4 (No constant domain factor).** *If the prose law is nonvanishing at
two contexts $T_1, T_2$ and $r(T_1) \ne r(T_2)$, then there is no constant
$\rho$ with $K_c(T) = \rho\,K_p(T)$ for all $T$.*

*Proof sketch.* Such a $\rho$ would give $r(T) = \rho K_p(T)/K_p(T) = \rho$ at
every $T$ where $K_p(T) \ne 0$, contradicting $r(T_1) \ne r(T_2)$. $\square$

**Corollary 8.5.** *No constant domain factor reproduces both $3/4$ at ctx $512$
and $4/5$ at ctx $4096$. A purely multiplicative domain mechanism (a pure
tokenisation account) is therefore refuted by the measured narrowing; an
**additive** structural component $a_d$ on top of the shared transition is
required.*

---

## 9. Reading the verdict on attention decay rates

We now push the verdict down to the attention weights themselves, using the
exact tail calculus for exponential attention. If the attention tail beyond
budget $K$ is $e^{-\lambda K}$ and one demands it fall below $\delta$, the exact
knee is
$$K(\lambda, \delta) \;=\; \frac{\log(1/\delta)}{\lambda} .$$

### 9.1 The domain factor is an inverse rate ratio

**Theorem 9.1.** *For $\lambda_c, \lambda_p \ne 0$ at a common tolerance,*
$$\frac{K(\lambda_c, \delta)}{K(\lambda_p, \delta)} \;=\; \frac{\lambda_p}{\lambda_c} .$$

*Proof sketch.* Both knees share the numerator $\log(1/\delta)$, which cancels.
$\square$

**Interpretation.** "Code is protected" says exactly that *code attention is more
peaked than prose attention*: $\lambda_c > \lambda_p$.

**Corollary 9.2 (The peakedness advantage is shrinking).** *At ctx $512$ the
factor $12/16$ gives $\lambda_c/\lambda_p = 4/3$; at ctx $4096$ the factor
$32/40$ gives $\lambda_c/\lambda_p = 5/4 < 4/3$. The peakedness advantage of code
is eroding — this is the narrowing domain factor, read on the rates.*

**Theorem 9.3 (The advantage never closes).** *Under the measured fit, for every
$T \ge 0$,*
$$\frac{K_{\mathrm{prose}}(T)}{K_{\mathrm{code}}(T)} \;>\; \frac{6}{5},$$
*i.e. code attention stays at least $6/5$ times as peaked as prose attention at
every context.*

*Proof sketch.* This is the reciprocal of $r(T) < 5/6$ (Theorem 4.11), both
knees being positive. $\square$

### 9.2 The chain pins the rates

**Theorem 9.4 (Rates from the code chain).** *Let $\lambda_j$ be the decay rate
at doubling $j$, all nonzero, with knees $12, 16, 32$ at $j = 0, 1, 3$ at a
common $\delta$. Then*
$$4\lambda_1 = 3\lambda_0, \qquad 8\lambda_3 = 3\lambda_0 .$$

*Proof sketch.* Each knee gives $\log(1/\delta) = K_j \lambda_j$; equating
$12\lambda_0 = 16\lambda_1$ and $12\lambda_0 = 32\lambda_3$ yields the two
identities. $\square$

**Corollary 9.5 (Super-harmonic degradation).** *Hence
$\lambda_3 = \tfrac38 \lambda_0 < \tfrac12\lambda_0$. An affine knee law would
put the ctx-$4096$ rate at $\lambda_0/2$ (knee $24 = 2 \times 12$); the measured
knee $32$ forces the rate strictly below that. The acceleration is
super-harmonic rate degradation.*

### 9.3 No harmonic rate family fits

The class of rate laws equivalent to "each doubling costs a fixed number of extra
keys" is the generalised harmonic family $\lambda_j = C/(j + c)$.

**Theorem 9.6.** *No generalised harmonic family reproduces the code chain
$12, 16, 32$ at $j = 0, 1, 3$, for any $C$ and any offset $c$.*

*Proof sketch.* Write $L = \log(1/\delta)$. Nonvanishing of the rates forces
$C \ne 0$ and $j + c \ne 0$ for the relevant $j$. Each knee equation
$L = K_j \lambda_j$ becomes $L (j + c) = K_j C$. At $j = 0, 1, 3$:
$$Lc = 12C, \qquad L(1+c) = 16C, \qquad L(3+c) = 32C .$$
Subtracting the first from the second gives $L = 4C$; subtracting the second
from the third gives $2L = 16C$, i.e. $L = 8C$. Hence $4C = 8C$, so $C = 0$, a
contradiction. $\square$

The acceleration is thus a statement about the *shape* of rate degradation, not
about its scale: no reparametrisation or renormalisation of a harmonic law can
absorb it.

---

## 10. Algorithms

Three computational procedures organise the analysis.

### 10.1 Knee sweep with bracket certification

Given a profile and a bar, locate the knee and — when only a coarse grid is
available — return the certified bracket rather than a point value.

```
Input: sorted profile p, bar tau, grid G (increasing)
1. total <- 0; masses <- []
2. for k in G: masses[k] <- sum of p[0..k-1]
3. find the largest g_lo in G with masses[g_lo] < tau
4. find the smallest g_hi in G with masses[g_hi] >= tau
5. return bracket (g_lo + 1, g_hi)         // knee lies in this closed interval
6. if g_hi = g_lo + 1: the knee is exactly g_hi
```

Complexity: $O(\max G)$ for the prefix sums plus $O(|G|)$ for the scan. The step
5 output is the honest report; step 6 is the only circumstance under which a
point value is licensed.

### 10.2 Two-slope fit and permanence test

Given knees for two domains at two contexts, fit the affine two-slope law,
compute the ratio and gap trajectories, and decide permanence.

```
Input: (Kc1, Kp1) at T1, (Kc2, Kp2) at T2, with T1 < T2
1. bc <- (Kc2 - Kc1)/(T2 - T1);  ac <- Kc1 - bc*T1
2. bp <- (Kp2 - Kp1)/(T2 - T1);  ap <- Kp1 - bp*T1
3. r1 <- Kc1/Kp1; r2 <- Kc2/Kp2; G1 <- Kp1 - Kc1; G2 <- Kp2 - Kc2
4. narrowing <- (r1 < r2)           // equivalently ac*bp < ap*bc
5. gap_growth <- (G1 < G2)          // equivalently bc < bp
6. if narrowing and gap_growth:
       return PERMANENT, limit = bc/bp   (< 1, never attained)
   else if narrowing and not gap_growth:
       return PARITY-COMPATIBLE, limit = bc/bp
   else: return NOT-NARROWING
```

Complexity: $O(1)$. The essential point is step 5: the *gap*, not the ratio, is
the discriminating observable, per Theorem 4.9.

### 10.3 Concavity refutation certificate

Given a knee chain indexed by doublings, decide whether any diminishing-returns
law can produce it, and quantify the excess.

```
Input: chain K[0..n] (some entries may be missing)
1. delta1 <- K[1] - K[0]
2. for each observed index j >= 2:
       cap[j] <- K[0] + j*delta1
       if K[j] > cap[j]: report REFUTES-CONCAVITY at j, excess = K[j] - cap[j]
3. if no violation: report CONSISTENT-WITH-CONCAVITY
```

Complexity: $O(n)$. On the code chain $K[0]=12$, $K[1]=16$, $K[3]=32$: the cap
at $j=3$ is $24$ and the excess is $8$.

---

## 11. Applications and discussion

**Cache budgeting.** The knee is directly the size of a retained key–value cache
under a fixed fidelity target. Theorem 4.8 says that if a system observes both a
rising domain factor and a widening gap between two context lengths, it may
budget on the permanence of the domain discount: the discount will not
evaporate at longer contexts. Under the measured fit, a code-serving path can
be provisioned at $5/6$ of a prose-serving path indefinitely.

**Reporting discipline.** Theorem 2.2 changes what a knee sweep should report.
A fail/pass pair certifies a bracket; the bracket is not improvable without
measurement inside it. Systems that publish point knees from coarse grids are
publishing the top of a bracket, and downstream fits inherit that width.

**Model selection.** Theorem 8.4 removes an entire class of explanations. A pure
tokenisation mechanism predicts a constant domain factor; the observed change of
the factor refutes it for every constant. Any adequate account must carry an
additive structural term.

**Cheap falsification.** Theorem 6.1 gives a test that needs no fitting: measure
three contexts in two domains and compare normalised increments. The pinned
value $\rho = 1/5$ turns into the one-line forecast
$K(4096) = K(512) + 5(K(1024) - K(512))$, and Theorem 6.6 turns into the concrete
target $20.8$ for prose at ctx $1024$.

**A caution about trends.** The most transferable lesson is Corollary 4.10.
A monotone trend in a ratio, however clean, does not determine the ratio's limit,
and two measured values are consistent with qualitatively opposite futures. The
remedy is not more precision on the same observable but a *second* observable
whose behaviour separates the hypotheses. Here the gap does it in one step, and
the reason is structural: the ratio is invariant under a common rescaling of both
laws, while the gap is not.

### 11.1 Limitations

* The affine law is a model. It is exactly consistent with the four measured
  knees and with the increment-ratio invariant, but four points do not compel
  affineness; Theorem 6.3 shows only that *one* shared normalised increment is
  equivalent to affine realisability in a common coordinate.
* The coordinate $T$ is defined only up to affine reparametrisation, which is
  precisely why the invariant of Theorem 6.1 is the right observable. Statements
  about "the value of $T$" at a context are meaningful only after normalisation.
* The knee at ctx $4096$ for code is certified as a bracket $[29, 32]$; all
  numerical fits above use the top of the bracket. A resolved value of $29$ or
  $30$ would shift $b_c$ and hence the limiting factor, though not the sign
  conclusions of Theorems 4.6 and 5.3, both of which have slack.
* The rate analysis of Section 9 assumes an exponential tail. It is an exact
  calculus under that assumption and a heuristic otherwise.

---

## 12. Future work

1. **Increment-ratio invariance across domains.** The normalised increment
   $(K(T_2) - K(T_1))/(K(T_3) - K(T_1))$ is domain free, exactly as a cross-ratio
   is invariant under affine reparametrisation. The thread has three-context
   chains for code and two for prose, so the invariant can be tested with one
   extra sweep and no fitting. Conjecture: every domain riding the same
   transition has normalised increment $1/5$ over $(512, 1024, 4096)$.

2. **Deriving the two-slope law from attention profiles.** The affine knee law
   should be a *theorem* about a family of attention profiles whose decay rate
   degrades with context, not a modelling assumption. A fixed profile gives a
   context-independent knee, and a rate $\lambda_j = \lambda_0/(j+1)$ gives an
   affine chain; Theorem 9.6 shows the measured chain lies outside that class, so
   what is needed is an explicit rate family that fits both the code and prose
   chains simultaneously.

3. **Resolving the bracket.** A fine sweep of budgets $24$–$32$ at ctx $4096$
   for code, converting the certified bracket $[29, 32]$ into a point value and
   sharpening every downstream constant.

4. **The domain-jump forecast at ctx $4096$.** Sweep mathematics, German, and
   French at $512$, $1024$, and $4096$ and check them against
   $K(4096) = K(512) + 5(K(1024) - K(512))$. This is the strongest falsifier the
   framework currently offers.

5. **Scale.** Repeat the two-domain cell at larger model scale to test whether
   the slopes $b_c, b_p$ — and hence the limiting factor $5/6$ — are scale
   invariant or themselves drift.

---

## 13. Conclusion

The verdict is that at a context of $4096$ tokens source code is protected: its
retention knee is $32$ against prose's $40$. We have shown that this survives
scrutiny in a strong form. The reported knee is honestly a bracket $[29, 32]$,
and provably not narrower on the available grid. Protection across all
thresholds is exactly dominance of retention curves. The narrowing of the domain
factor from $3/4$ to $4/5$ is a sign condition on four constants, and — together
with the doubling of the domain gap from $4$ to $8$ — it *forces* a limiting
factor strictly below $1$: the discount is permanent, and the ratio approaches
its ceiling $5/6$ strictly from below, never reaching it. The tempting inference
from the ratio trend alone to eventual parity is not merely unproved but
unprovable from that data, as two explicit laws with the same measured ratios and
different limits show. The acceleration, meanwhile, is an exact refutation of
every diminishing-returns law: concavity caps the code knee at ctx $4096$ at
$24$, and the measurement is $32$. Read on attention rates, the same facts say
that code's peakedness advantage is eroding from $4/3$ toward a floor of $6/5$
while the absolute decay rate degrades super-harmonically to three eighths of its
short-context value — outside the reach of any generalised harmonic law.

The gap grows while the ratio narrows. Both are true, neither implies parity, and
the sixth by which code is protected never closes.
