# Boundary-Token Width Is a One-Sided Distribution Shift, Not a Threshold: A Tropical Separation Theory

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

Recurrent sequence models trained on column-wise arithmetic exhibit a
*carry wall*: accuracy that is perfect at the trained unroll depth degrades
smoothly as the depth grows. Appending a learned end-of-sequence boundary token
of width $E$ (zero-padded to the full input width) is a known remedy, and a
sweep over $E$ appears to show a sharp threshold: fragile at $E = 20$, perfect
at every $E \ge 28$. We show this reading is false and replace it with a
provably correct one.

First, a deterministic refutation: a data set containing two runs of *equal*
width with opposite outcomes is incompatible with every threshold model, since a
threshold model makes the outcome a function of the width. The observed twelve
runs at $E = 20$ contain such a pair, so no threshold whatsoever fits.

Second, the correct law. We prove that the accuracy distribution of the
$E \ge 28$ regime stochastically dominates that of the $E = 20$ regime at every
level, strictly at the cure level ($3/12$ versus $20/20$); that a $20/20$ clean
sweep rules out any per-run cure probability $p \le 0.86$ at the one-sided $5\%$
level, since $0.86^{20} < 0.05$; and that the *maximised* likelihood of the
homogeneous null "one cure probability governs both regimes" is below $10^{-5}$
times the two-regime alternative, uniformly in $p$ — a bound we derive from the
exponential form of weighted AM–GM, $a \le c\,e^{a/c-1}$.

Third, a mechanism. Modelling the readout layer in the max-plus (tropical)
semiring, we prove an exact dichotomy: a boundary vector lies in the max-plus
span of the one-hot digit atoms **iff** it has no *exclusive dimension*, i.e.
no coordinate outside the digit block on which it is finite. In the span case,
every readout maps the boundary token to the same fixed max-plus combination of
the digit responses, and the boundary-vs-digit margin is bounded uniformly over
readouts by the boundary's largest coefficient — a bound we show is *sharp*, so
the best achievable margin equals exactly $\max_i c_i$. With one exclusive
dimension the margin is unbounded and stable under bounded weight perturbations.

Fourth, the bridge. Writing the learned block-supported boundary token as a
coefficient vector $c$, separability from all digit atoms holds **iff**
$\max_i c_i > 0$. Since $c$ is seed-dependent, the fragile cure probability is
strictly inside $(0,1)$, while the robust regime cures with probability $1$; and
separability is monotone under coordinatewise domination, hence one-sided in
$E$. Finally, a max-plus layer is monotone and shift-equivariant, so a bounded
boundary-vs-digit gap can never be amplified at any unroll depth — explaining
the *smooth* rather than cliff-like depth degradation. The control variable is
**representational distinctness, not width**.

**Keywords:** tropical semiring; max-plus algebra; boundary token; recurrent
neural networks; stochastic dominance; likelihood ratio; separability.

---

## 1. Introduction

### 1.1 The phenomenon

Consider a recurrent cell trained to perform column-wise addition with carries.
Trained at unroll depth $n = 5$, it is exact. Evaluated at greater depths its
accuracy decays:

$$n = 5:\ 1.0000 \qquad n = 6:\ 0.9556 \qquad n = 7:\ 0.1445 \qquad n = 8:\ 0.0166 .$$

The errors are *column-clustered*: the model loses positional alignment part way
through the sum. We call this the **carry wall**. A standard intervention is to
supply an explicit boundary ("end-of-sequence") token: a learned embedding of
width $E$, zero-padded to the network's input width $N = 384$, appended to the
digit stream. The digit vocabulary occupies the first $D = 20$ coordinates of
the input. In the experiments summarised here every other factor is held
fixed — architecture, task, optimiser, schedule — and only $E$ varies.

### 1.2 The apparent threshold and its refutation

A sweep over $E \in \{20, 28, 64, 96, 128, 192, 256, 384\}$ with two
initialisations each gives: at $E = 20$, accuracies $0.9990$ and $0.0166$; at
every $E \ge 28$, fourteen out of fourteen runs at $1.0000$. Read naively this
says there is a width threshold between $20$ and $28$.

Extending the $E = 20$ arm to twelve runs destroys that reading. The twelve
accuracies, in basis points ($10^{-4}$ units), are

$$9990,\ 9990,\ 9990,\ 7440,\ 1240,\ 580,\ 310,\ 260,\ 170,\ 110,\ 60,\ 50 .$$

Three are clean cures; nine are not; all twelve have width $20$. Since a
threshold model asserts that the outcome is a function of width, and a function
cannot take two values at one input, the model is refuted outright. What the
width controls is a *distribution*, and this paper determines exactly which
event's probability it controls.

### 1.3 Contributions

1. **A deterministic no-threshold theorem** (§3), with a reusable
   equal-width-split obstruction.
2. **A one-sided stochastic-dominance law** for the two accuracy samples, with
   quantified evidence: a confidence bound for the robust regime and a uniform
   likelihood-ratio rejection of the homogeneous null (§4).
3. **An exact tropical dichotomy** — span membership $\iff$ absence of an
   exclusive dimension — with an ambiguity theorem, a uniform margin bound, and
   its sharpness (§5).
4. **An exact separability criterion** for learned block-supported boundary
   tokens, $\max_i c_i > 0$, and the resulting interior/degenerate cure
   probabilities and their monotonicity in $E$ (§6).
5. **Depth-uniform non-amplification**: bounded gaps survive arbitrary unroll
   depth in both directions, explaining the smooth collapse (§7).
6. **Corrections** to two earlier claims, and a diagnostic probe consistent with
   the mechanism (§8, §9).

---

## 2. Setup and notation

### 2.1 The max-plus semiring

Let $\overline{\mathbb{R}} = \mathbb{R} \cup \{-\infty\}$, equipped with

$$a \oplus b := \max(a,b), \qquad a \odot b := a + b,$$

tropical zero $\mathbb{0} = -\infty$ and tropical one $\mathbb{1} = 0$. This is
the **max-plus** or **tropical** semiring. It is the natural algebra of
piecewise-linear, max-taking computation: a layer that computes weighted maxima
of its inputs is a tropical linear map, and the tropical zero $-\infty$ encodes
"this coordinate is not used."

**Definition 2.1 (Tropical vector).** A *tropical vector of width $N$* is a map
$x : \{0, \dots, N-1\} \to \overline{\mathbb{R}}$. We write $x_i$ for its $i$-th
coordinate.

### 2.2 Tokens

Fix an ambient width $N$ and a digit-block width $D \le N$.

**Definition 2.2 (Digit atom).** For $j < D$, the *digit atom* $\delta^{(j)}$ is
the tropical vector with
$$\delta^{(j)}_i = \begin{cases} 0 & i = j \\ -\infty & i \ne j.\end{cases}$$

**Definition 2.3 (Tropical combination and span).** For coefficients
$\lambda_0, \dots, \lambda_{D-1} \in \overline{\mathbb{R}}$, the tropical
combination is
$$\Big(\bigoplus_{j} \lambda_j \odot \delta^{(j)}\Big)_i = \max_{j<D}\big(\lambda_j + \delta^{(j)}_i\big).$$
The *digit span* is the set of all such combinations. We write
$x \in \operatorname{Span}_{\oplus}(\delta)$.

**Definition 2.4 (Exclusive dimension).** A coordinate $p$ is an *exclusive
dimension* of $x$ if $p \ge D$ and $x_p \ne -\infty$. We say $x$ *has no
exclusive dimension* if $x_i = -\infty$ for every $i \ge D$.

**Definition 2.5 (Zero-padded boundary token).** The width-$E$ zero-padded
boundary token is
$$\varepsilon^{(E)}_i = \begin{cases} 0 & i < E \\ -\infty & i \ge E.\end{cases}$$

**Definition 2.6 (Learned block-supported boundary token).** Given real
coefficients $c = (c_0, \dots, c_{D-1})$, set
$$\eta^{(c)}_i = \begin{cases} c_i & i < D \\ -\infty & i \ge D.\end{cases}$$
This models a boundary embedding learned from a random initialisation whose
support lies inside the digit block ($E \le D$).

### 2.3 Readouts and separation

**Definition 2.7 (Max-plus readout).** For weights $w$, the *score* of $x$ is
$$\operatorname{sc}_w(x) := \max_{i<N}\big(w_i + x_i\big) = \bigoplus_i w_i \odot x_i .$$

**Definition 2.8 (Probe).** The readout listening only to coordinate $p$ with
gain $g$ is $\pi^{p,g}_i = g$ if $i = p$ and $-\infty$ otherwise. Directly from
the definition, $\operatorname{sc}_{\pi^{p,g}}(x) = g + x_p$.

**Definition 2.9 (Separability).** A boundary vector $x$ is *separable* if there
exists a readout $w$ with
$$\operatorname{sc}_w(\delta^{(j)}) < \operatorname{sc}_w(x) \quad\text{for every } j < D.$$

Separability is the model-level formalisation of "the network can, in
principle, learn a channel that recognises the boundary as a category of its
own." Note that the readout is quantified *existentially*: separation is a
property of the *learnable* readout, not of a random one. (This is essential;
see §10.1.)

### 2.4 The experimental record

**Fragile sample ($E = 20$, twelve runs, basis points).**
$9990, 9990, 9990, 7440, 1240, 580, 310, 260, 170, 110, 60, 50$.

**Robust sample ($E \ge 28$, twenty runs).** $E \in \{28, 64, 96, 128, 192,
256, 384\}$ at two seeds each, plus $E = 384$ at six further seeds: all
$10000$ basis points.

**Definition 2.10 (Cure).** A run is *cured* if its accuracy is at least
$9000$ basis points ($0.9$). For a sample $L$ and level $t$, $T(L, t)$ denotes
the number of entries of $L$ that are $\ge t$.

---

## 3. There is no sharp width boundary

**Definition 3.1 (Sharp-boundary model).** A collection of runs, each carrying a
width and a cure outcome, satisfies a *sharp-boundary model* if there exists
$E_0$ such that for every run, cured $\iff$ width $\ge E_0$.

**Theorem 3.2 (Equal-width split obstruction).** *Let a collection of runs
contain two runs $a$ and $b$ of the same width with $a$ cured and $b$ not cured.
Then no sharp-boundary model holds.*

*Proof.* Suppose $E_0$ witnesses the model. Since $a$ is cured, $E_0 \le
\mathrm{width}(a) = \mathrm{width}(b)$. Applying the equivalence to $b$ in the
other direction gives that $b$ is cured, a contradiction. $\square$

**Theorem 3.3 (No sharp boundary for the observed data).** *The thirty-two-run
data set of §2.4 admits no sharp-boundary model.*

*Proof.* The runs with width $20$ and accuracies $9990$ and $170$ are both
present; the first is cured ($9990 \ge 9000$) and the second is not
($170 < 9000$). Apply Theorem 3.2. $\square$

Theorem 3.3 is deterministic. It uses no distributional assumption and no
significance level; it merely observes that the proposed law has the wrong
*type*. The outcome is not a function of $E$.

---

## 4. The correct law: a one-sided distribution shift

### 4.1 Cure rates

**Proposition 4.1 (Empirical cure rates).** *In the fragile sample,
$T(L_{20}, 9000) = 3$ out of $12$, a rate of $1/4$. In the robust sample,
$T(L_{\ge 28}, 9000) = 20$ out of $20$, a rate of $1$.*

*Proof.* Direct enumeration: exactly the entries $9990, 9990, 9990$ of the
fragile sample meet the threshold, and every entry of the robust sample equals
$10000$. $\square$

**Proposition 4.2 (Fragile median).** *The median of the fragile sample — the
mean of its two central order statistics — is $0.0445$.*

*Proof.* The sorted sample has central entries $310$ and $580$ basis points;
their mean is $445$ basis points. $\square$

Thus the *typical* fragile run is not a near-miss: it is a total failure. The
sample is strongly bimodal, with three near-perfect runs and nine collapses.

### 4.2 Stochastic dominance

**Theorem 4.3 (One-sided distribution shift).** *For every accuracy level $t$,*
$$\frac{T(L_{20}, t)}{12} \ \le\ \frac{T(L_{\ge 28}, t)}{20}.$$
*That is, the robust accuracy distribution stochastically dominates the fragile
one.*

*Proof.* Two cases. If $t \le 10000$, every robust entry equals $10000 \ge t$,
so the right side is $20/20 = 1$, while the left side is at most $12/12 = 1$. If
$t > 10000$, then in particular $t > 9990$, and no fragile entry attains $t$
(the maximum fragile entry is $9990$), so the left side is $0$ while the right
side is nonnegative. $\square$

**Theorem 4.4 (Strictness at the cure level).**
$$\frac{T(L_{20}, 9000)}{12} = \frac{3}{12} \;<\; 1 = \frac{T(L_{\ge 28}, 9000)}{20}.$$

Theorems 4.3 and 4.4 together are the precise content of "the threshold is a
one-sided distribution shift." Widening never decreases any tail fraction, and
strictly increases the one that matters.

### 4.3 How strong is $20/20$?

**Theorem 4.5 (Robust-regime confidence).** *Under an i.i.d. Bernoulli model
with per-run cure probability $p$, if $0 \le p \le 0.86$ then*
$$\Pr[\text{20 cures in 20 runs}] = p^{20} \le 0.86^{20} < 0.05 .$$
*Hence the one-sided $5\%$ test rejects every $p \le 0.86$.*

*Proof.* $t \mapsto t^{20}$ is monotone on $[0,\infty)$, and
$0.86^{20} \approx 0.0456 < 0.05$. $\square$

### 4.4 Rejecting the homogeneous null

The sharpest question is whether a *single* cure probability could govern both
regimes, the observed split being chance. Under that null the likelihood of the
data is $\binom{12}{3} p^{23}(1-p)^9$: twenty-three successes ($3 + 20$) and
nine failures. The two-regime alternative attains
$\binom{12}{3}(1/4)^3(3/4)^9 \cdot 1^{20}$.

We first record the analytic engine.

**Lemma 4.6 (Exponential weighted AM–GM).** *For $a \ge 0$, $c > 0$ and
$n \in \mathbb{N}$,*
$$a^n \le c^n \exp\!\big(n\,(a/c) - n\big).$$

*Proof.* From $1 + u \le e^{u}$ with $u = a/c - 1$ we get
$a/c \le e^{a/c - 1}$, hence $a \le c\,e^{a/c-1}$. Raise to the $n$-th power and
use $\big(e^{a/c-1}\big)^n = e^{n(a/c) - n}$. $\square$

**Theorem 4.7 (Maximum of the pooled binomial kernel).** *For $p \in [0,1]$,*
$$p^{23}(1-p)^9 \ \le\ \left(\tfrac{23}{32}\right)^{23}\left(\tfrac{9}{32}\right)^{9}.$$

*Proof.* Apply Lemma 4.6 twice: to $a = p$ with $c = 23/32$, $n = 23$, giving
$p^{23} \le (23/32)^{23} e^{32p - 23}$; and to $a = 1-p$ with $c = 9/32$,
$n = 9$, giving $(1-p)^9 \le (9/32)^9 e^{32(1-p) - 9}$. Multiplying the two
nonnegative bounds and noting
$$(32p - 23) + \big(32(1-p) - 9\big) = 0,$$
the exponentials cancel to $1$. $\square$

This is the maximum-likelihood value: $p = 23/32$ is exactly the pooled success
frequency $23/(23+9)$, as it must be.

**Theorem 4.8 (Uniform rejection of the homogeneous null).** *For every
$p \in [0,1]$,*
$$10^{5}\cdot p^{23}(1-p)^{9} \ \le\ \left(\tfrac14\right)^{3}\left(\tfrac34\right)^{9}\cdot 1^{20}.$$
*Equivalently, the maximised null likelihood is below $10^{-5}$ times the
alternative's likelihood, uniformly in $p$.*

*Proof.* By Theorem 4.7 it suffices to check the numerical inequality
$10^{5}\,(23/32)^{23}(9/32)^{9} \le (1/4)^{3}(3/4)^{9}$, which holds: the left
side is approximately $1.4 \times 10^{-4}$ and the right side approximately
$1.2 \times 10^{-3}$. (The binomial coefficient $\binom{12}{3}$ appears on both
sides and cancels.) $\square$

So the two regimes are genuinely different distributions — while, by Theorem
3.3, neither is a deterministic function of the width. Both halves of the
correction are needed: the threshold reading is too strong, and the "it's all
noise" reading is too weak.

---

## 5. The mechanism: tropical separation theory

We now explain *why* the two regimes differ, and identify the true control
variable.

### 5.1 The span dichotomy

**Theorem 5.1 (Span dichotomy).** *Let $D \le N$ and let $x$ be a tropical
vector of width $N$. Then*
$$x \in \operatorname{Span}_{\oplus}(\delta^{(0)}, \dots, \delta^{(D-1)}) \iff x \text{ has no exclusive dimension.}$$

*Proof.* ($\Rightarrow$) If $x = \bigoplus_j \lambda_j \odot \delta^{(j)}$ and
$i \ge D$, then every term $\lambda_j + \delta^{(j)}_i$ equals $-\infty$ because
$\delta^{(j)}_i = -\infty$ for $j < D \le i$; the maximum of an all-$(-\infty)$
family is $-\infty$.

($\Leftarrow$) Take $\lambda_j := x_j$ for $j < D$. For $i < D$, the family
$\{\lambda_j + \delta^{(j)}_i\}_j$ is $-\infty$ except at $j = i$, where it is
$x_i + 0 = x_i$; so the combination has $i$-th coordinate $x_i$. For $i \ge D$
the combination is $-\infty$, which equals $x_i$ by hypothesis. $\square$

**Corollary 5.2.** *A boundary vector with an exclusive dimension is not a
tropical combination of digit atoms.*

**Corollary 5.3 (Zero-padded tokens).** *For $D < N$,
$\varepsilon^{(E)} \in \operatorname{Span}_{\oplus}(\delta) \iff E \le D$.*

*Proof.* If $E \le D$ then $\varepsilon^{(E)}_i = -\infty$ for $i \ge D$, so
Theorem 5.1 applies. If $E > D$ then coordinate $D$ (which exists since
$D < N$) satisfies $\varepsilon^{(E)}_D = 0 \ne -\infty$, an exclusive
dimension. $\square$

**Theorem 5.4 (Width is not the control variable).** *For $0 < D < N$ there
exist two tropical vectors, each with tropical support of size one, one of which
lies in the digit span and one of which does not.*

*Proof.* Take $\delta^{(0)}$, which lies in the span, and the probe vector
$\pi^{D,0}$ (finite value $0$ at coordinate $D$ only), which has an exclusive
dimension at $D$. $\square$

Theorem 5.4 is the conceptual pivot of the paper: two tokens of *identical*
size sit on opposite sides of the dichotomy. Size is not what matters; *where*
the mass sits is.

### 5.2 Readouts cannot see a span member

**Theorem 5.5 (Ambiguity theorem).** *Let $x$ have no exclusive dimension. Then
for every readout $w$,*
$$\operatorname{sc}_w(x) \;=\; \max_{j<D}\Big( x_j \;+\; \operatorname{sc}_w(\delta^{(j)}) \Big) .$$

*Proof.* First, $\operatorname{sc}_w(\delta^{(j)}) = w_j$: in the maximum
$\max_i (w_i + \delta^{(j)}_i)$ every term is $-\infty$ except $i = j$, which
gives $w_j$. So the right side equals $\max_{j<D}(w_j + x_j)$. The left side is
$\max_{i<N}(w_i + x_i)$. Terms with $i \ge D$ contribute $w_i + (-\infty) =
-\infty$ and can be dropped; the remaining terms are exactly those of the right
side. $\square$

The interpretation is the heart of the matter: the response of any readout to a
boundary token *inside* the digit block is a fixed tropical combination of its
responses to the digits, with coefficients determined by the token alone. No
readout has a channel that hears the boundary but no digit.

**Theorem 5.6 (Uniform margin bound).** *Let $x$ have no exclusive dimension.
Then for every readout $w$,*
$$\operatorname{sc}_w(x) \ \le\ \Big(\max_{j<D} x_j\Big) \;+\; \max_{j<D} \operatorname{sc}_w(\delta^{(j)}).$$

*Proof.* Bound each term of the maximum in Theorem 5.5 by replacing $x_j$ with
$\max_{j'} x_{j'}$ and $\operatorname{sc}_w(\delta^{(j)})$ with
$\max_{j'} \operatorname{sc}_w(\delta^{(j')})$. $\square$

In additive terms: *the boundary token can outscore the best digit by at most
its own largest coefficient, uniformly over all readouts.*

**Theorem 5.7 (Sharpness of the margin bound).** *Let $\eta^{(c)}$ be a learned
block-supported token with $D \ge 1$. Then there exists a readout $w$ attaining
equality in Theorem 5.6:*
$$\operatorname{sc}_w(\eta^{(c)}) = \Big(\max_{j<D} c_j\Big) + \max_{j<D} \operatorname{sc}_w(\delta^{(j)}).$$
*Consequently the best achievable boundary-vs-digit margin is exactly
$\max_j c_j$.*

*Proof.* Let $i$ maximise $c$. Take $w = \pi^{i,0}$, the unit-gain probe on
coordinate $i$. Then $\operatorname{sc}_w(\eta^{(c)}) = 0 + c_i = \max_j c_j$.
Also $\operatorname{sc}_w(\delta^{(j)}) = \delta^{(j)}_i$, which is $0$ if
$j = i$ and $-\infty$ otherwise; so the maximum over $j$ is $0$. Both sides
equal $\max_j c_j$. $\square$

### 5.3 One exclusive dimension buys everything

**Theorem 5.8 (Unbounded margin).** *Let $x$ have an exclusive dimension at $p$,
say $x_p = v \in \mathbb{R}$. Then for every target $M$ there is a readout $w$
with $\operatorname{sc}_w(x) \ge M$ and $\operatorname{sc}_w(\delta^{(j)}) =
-\infty$ for every $j < D$.*

*Proof.* Take $w = \pi^{p,\,M-v}$. Then $\operatorname{sc}_w(x) = (M - v) + v =
M$, while $\operatorname{sc}_w(\delta^{(j)}) = (M - v) + \delta^{(j)}_p =
-\infty$ since $p \ge D > j$. $\square$

**Theorem 5.9 (Robustness of the separation).** *In the setting of Theorem 5.8,
if the probe gain is perturbed to $(M - v) + e$ with $|e| \le r$, then
$\operatorname{sc}_w(x) \ge M - r$ while every digit still scores $-\infty$.*

*Proof.* $\operatorname{sc}_w(x) = (M - v) + e + v = M + e \ge M - r$. The digit
scores are unchanged at $-\infty$ regardless of the gain. $\square$

So the two regimes are qualitatively, not quantitatively, different: without an
exclusive dimension the achievable margin is capped at a single learned scalar;
with one, the margin is unbounded *and* stable to weight perturbation.

---

## 6. From mechanism to cure probability

### 6.1 The exact separability criterion

**Theorem 6.1 (Separability criterion).** *Let $0 < D \le N$ and let
$\eta^{(c)}$ be a learned block-supported boundary token. Then $\eta^{(c)}$ is
separable if and only if $c_i > 0$ for some $i < D$.*

*Proof.* ($\Leftarrow$) Take $w = \pi^{i,0}$. Then
$\operatorname{sc}_w(\eta^{(c)}) = c_i > 0$, while
$\operatorname{sc}_w(\delta^{(j)}) = \delta^{(j)}_i$, which is $0$ when $j = i$
and $-\infty$ otherwise. In both cases it is $< c_i$.

($\Rightarrow$) Suppose $c_j \le 0$ for all $j$ but some $w$ separates. By
Theorem 5.6,
$$\operatorname{sc}_w(\eta^{(c)}) \le \Big(\max_j c_j\Big) + \max_j \operatorname{sc}_w(\delta^{(j)}) \le 0 + \max_j \operatorname{sc}_w(\delta^{(j)}).$$
But separation says $\operatorname{sc}_w(\delta^{(j)}) <
\operatorname{sc}_w(\eta^{(c)})$ for every $j$, and the boundary score is
$> -\infty$, so the maximum over the finitely many $j$ is strictly less than
$\operatorname{sc}_w(\eta^{(c)})$ — contradicting the displayed inequality.
$\square$

Theorem 6.1 converts a question about learnable readouts into a question about
the *sign of a maximum of learned coefficients*. This is the pivot from geometry
to probability: the seed decides the signs.

**Theorem 6.2 (Robust regime is deterministic).** *Any boundary token with an
exclusive dimension is separable. In particular, for $D < N$ and $E > D$, the
zero-padded token $\varepsilon^{(E)}$ is separable.*

*Proof.* Apply Theorem 5.8 with $M = 0$: the boundary scores $\ge 0 > -\infty$,
which is the score of every digit. For $\varepsilon^{(E)}$ with $E > D$,
coordinate $D$ is exclusive by Corollary 5.3. $\square$

### 6.2 One-sidedness

**Theorem 6.3 (Monotonicity of separability).** *If $x_i \le y_i$ for every $i$
and $x$ is separable, then $y$ is separable.*

*Proof.* Scores are monotone: $\operatorname{sc}_w(x) \le
\operatorname{sc}_w(y)$, since each term $w_i + x_i \le w_i + y_i$ is dominated
by the corresponding term of the second maximum. A readout separating $x$ then
satisfies $\operatorname{sc}_w(\delta^{(j)}) < \operatorname{sc}_w(x) \le
\operatorname{sc}_w(y)$. $\square$

**Corollary 6.4 (One-sidedness in width).** *Zero-padded tokens are monotone in
width: $E \le E'$ implies $\varepsilon^{(E)}_i \le \varepsilon^{(E')}_i$ for
every $i$. Hence if $\varepsilon^{(E)}$ is separable, so is
$\varepsilon^{(E')}$: widening the boundary token can never destroy the cure.*

*Proof.* If $i < E$ then $i < E'$ and both coordinates equal $0$; otherwise the
left coordinate is $-\infty$. Apply Theorem 6.3. $\square$

This is the formal content of "one-sided": the intervention is monotone in the
knob, so any observed non-monotonicity in a finite sample is sampling noise, not
signal.

### 6.3 The cure probability

Model the seed as an element $\omega$ of a finite probability space $\Omega$
with the uniform measure, and let $c(\omega)$ be the learned coefficient vector.
Define the *fragile cure set* as the set of seeds for which $\eta^{(c(\omega))}$
is separable, and the *cure probability* as its normalised cardinality. By
Theorem 6.1, $\omega$ lies in the cure set iff $\max_i c(\omega)_i > 0$.

**Theorem 6.5 (Fragile probability is interior).**
*(i) If some seed yields $c(\omega)_i \le 0$ for all $i$, then the fragile cure
probability is $< 1$.
(ii) If some seed yields $c(\omega)_i > 0$ for some $i$, then it is $> 0$.*

*Proof.* (i) That seed is outside the cure set by Theorem 6.1, so the cure set
is a proper subset of $\Omega$ and its cardinality is strictly smaller. (ii)
That seed is in the cure set, so the cardinality is positive. $\square$

**Theorem 6.6 (Robust probability is one).** *For $D < N$ and $E > D$, every
seed cures: the cure set is all of $\Omega$ and the cure probability is $1$.*

*Proof.* Immediate from Theorem 6.2, since the conclusion does not depend on the
seed. $\square$

**Theorem 6.7 (EOS-Width Distribution Shift).** *Let $0 < D < N$, $E > D$, and
suppose the seed distribution can produce both an all-nonpositive coefficient
vector and a vector with a positive entry. Then*
$$0 \;<\; \Pr[\text{cure} \mid \text{fragile } (E \le D)] \;<\; \Pr[\text{cure} \mid \text{robust } (E > D)] \;=\; 1 .$$

*Proof.* Combine Theorems 6.5(ii), 6.5(i) and 6.6. $\square$

Theorem 6.7 is the model-level statement of the law: a *shift*, strict in both
directions, and never a deterministic boundary in either regime — except that
the robust regime is degenerate at $1$.

**Example 6.8 (A two-seed sign model).** Take $D = 1$ and $\Omega = \{0,1\}$
with $c(0) = (+1)$ and $c(1) = (-1)$. Then the cure set is $\{0\}$ and the
fragile cure probability is exactly $1/2$ — strictly interior, exactly as the
empirical $3/12$ is.

---

## 7. Depth propagation: why the collapse is smooth

The observed failure is a *smooth* slide with unroll depth, not a cliff. The
max-plus model forces exactly this shape.

**Definition 7.1 (Max-plus layer and its unrolling).** For a matrix $A$ over
$\overline{\mathbb{R}}$, one layer acts by $(A \odot x)_k = \max_i (A_{ki} +
x_i)$. Its $n$-fold unrolling $A^{\odot n} \odot x$ is defined by iteration,
with the $0$-fold case the identity.

**Lemma 7.2 (Monotonicity).** *If $x_i \le y_i$ for all $i$ then
$(A \odot x)_k \le (A \odot y)_k$ for all $k$.*

**Theorem 7.3 (No amplification).** *Let $c \in \mathbb{R}$ and suppose
$x_i \le c + y_i$ for all $i$. Then $(A \odot x)_k \le c + (A \odot y)_k$ for
all $k$.*

*Proof.* For each $i$, $A_{ki} + x_i \le A_{ki} + c + y_i = c + (A_{ki} + y_i)
\le c + \max_{i'}(A_{ki'} + y_{i'})$. Take the maximum over $i$. $\square$

Equivalently: a max-plus layer is *shift-equivariant*, commuting with tropical
scalars. A gap of $c$ before the layer is a gap of $c$ after it — never more.

**Corollary 7.4 (Depth-uniform non-amplification).** *Under the hypothesis of
Theorem 7.3, $(A^{\odot n} \odot x)_k \le c + (A^{\odot n} \odot y)_k$ for every
depth $n$ and every $k$.*

*Proof.* Induction on $n$; the base case is the hypothesis and the step is
Theorem 7.3. $\square$

**Lemma 7.5 (Domination of a block-supported token).** *If $c_j \le v$ for all
$j < D$, then $\eta^{(c)}_i \le v + \varepsilon^{(D)}_i$ for every $i$.*

*Proof.* For $i < D$ both sides are finite and the inequality reads
$c_i \le v + 0$. For $i \ge D$ the left side is $-\infty$. $\square$

**Theorem 7.6 (Depth-uniform ambiguity).** *For every max-plus recurrence $A$,
every depth $n$ and every coordinate $k$,*
$$\big(A^{\odot n} \odot \eta^{(c)}\big)_k \ \le\ \Big(\max_j c_j\Big) + \big(A^{\odot n} \odot \varepsilon^{(D)}\big)_k .$$
*Thus in the fragile regime the boundary trajectory stays within $\max_j c_j$ of
the all-digit trajectory at every unroll depth: no depth exists at which a
block-supported boundary token becomes distinguishable by a large margin.*

*Proof.* Combine Lemma 7.5 with Corollary 7.4, taking $v = \max_j c_j$.
$\square$

**Theorem 7.7 (Persistence of an exclusive dimension).** *Under the identity
recurrence, if $x$ has an exclusive dimension at $p$ then so does
$A^{\odot n} \odot x$ for every $n$; the unbounded separation of Theorem 5.8
remains available at every depth.*

*Proof.* The identity max-plus matrix acts as the identity on vectors: in
$\max_i(\mathrm{id}_{ki} + x_i)$ all terms but $i = k$ are $-\infty$. Iterating
leaves $x$ unchanged. $\square$

Theorems 7.6 and 7.7 explain the *shape* of the empirical decay. The fragile
gap is bounded uniformly in depth, so nothing catastrophic happens at any single
depth; what accumulates with depth is the number of opportunities for the
ambiguity to be resolved wrongly, giving a smooth monotone slide rather than a
cliff. In the robust regime the separating channel is depth-invariant, so
accuracy does not decay at all.

---

## 8. Algorithms

Three algorithms follow directly from the theory and are used in the
accompanying computations.

**A. Exclusive-dimension classifier.** Given a token $x$ of width $N$ and digit
width $D$, scan coordinates $D, \dots, N-1$ and report the first finite one.
Returning "none" certifies span membership by Theorem 5.1, and hence the fragile
regime; returning $p$ certifies robust separability by Theorem 6.2. Cost
$O(N - D)$, single pass, no arithmetic.

**B. Optimal-margin readout synthesis.** Given a block-supported token with
coefficients $c$, compute $i^\star = \arg\max_i c_i$ and return the unit-gain
probe on $i^\star$. By Theorem 5.7 this readout attains the exact optimum
$\max_i c_i$, so no search is required: the optimisation over an
infinite-dimensional weight space collapses to an $\arg\max$ over $D$ numbers.
Cost $O(D)$. Separability holds iff the returned margin is positive
(Theorem 6.1).

**C. Uniform likelihood-ratio test for regime homogeneity.** Given success/trial
counts $(s_1, n_1)$ and $(s_2, n_2)$ in the two regimes, compute the pooled MLE
$\hat p = (s_1 + s_2)/(n_1 + n_2)$ and the split MLEs $\hat p_k = s_k/n_k$, and
report the ratio of maximised likelihoods. Theorem 4.7 shows the pooled maximum
is attained at $\hat p$ with no numerical optimisation, via the exponential
AM–GM bound; the resulting ratio is a certificate valid uniformly in $p$, not
merely at the maximiser. Cost $O(1)$.

---

## 9. Diagnostics and corrections

### 9.1 A discriminating probe

The mechanism predicts that the difference between cured and failed runs is
visible in the internal state, not only in the output. It is. In cured runs the
hidden-state norm is flat across the unroll (drift $< 0.2$) and the maximum
output confidence is $1.000$. In failed runs the norm drifts by $+2.2$ and the
maximum confidence dips into the band $0.945$–$0.984$. This is the signature of
a hidden state leaving its training distribution — precisely the pathology a
distinct boundary channel prevents, and precisely what a token confined to the
digit subspace cannot prevent.

### 9.2 Two corrections

**Correction 1: "width $28$ fails."** An earlier reading recorded a failure at
boundary width $28$. That observation came from a *different* cell architecture.
On the shared $384$-dimensional cell used throughout the present study, width
$28$ cures in both of its runs; the earlier figure is an architecture artifact
and not a property of the width.

**Correction 2: "width $20$ fails, $0$ out of $2$."** Two failures at $E = 20$
were read as a deterministic failure. Under the estimated cure probability
$\approx 1/4$, two failures in two draws has probability $\approx (3/4)^2 =
9/16$ — an entirely typical outcome, carrying essentially no evidence.

**A control that was invalid but immaterial.** An earlier control claimed that
two configurations shared identical initial weights; in fact they drew different
random-number streams, so the "identical-weights" control was invalid. The
invalidity is immaterial: a direct construction-order check reproduced the
accuracy $0.9990$ byte-identically both before and after reseeding, showing that
construction order does not affect the outcome. Determinism of the pipeline was
independently confirmed by exact reproduction of the same run twice.

**What survived.** The underlying mechanistic claim — a dense, distinct boundary
input keeps the hidden state in-distribution at depth — survives, and on much
stronger evidence than it was originally asserted with: $20/20$ against $3/12$,
with the tropical dichotomy of §5 supplying the reason.

---

## 10. Discussion

### 10.1 A definition that had to change

A first attempt to formalise the law read: "the probability that a *random*
readout separates the boundary from the digits jumps at $E = D$." This is false,
and instructively so. A random max-plus readout separates essentially nothing in
either regime, because separation in the robust regime requires a readout that
*listens to the exclusive dimension* — a measure-zero coincidence for a random
$w$. Separation is a property of the **learned** readout.

The fix is to quantify existentially over readouts (Definition 2.9) and move the
randomness to the learned *embedding coefficients*. With that change the
criterion becomes exact (Theorem 6.1) and the probability statement becomes
provable (Theorem 6.7). The episode is a reminder that in this kind of analysis
the choice of what to randomise is the whole modelling decision.

### 10.2 What the control variable really is

The paper's title claim is that width is a proxy. The evidence:

- Width $20$ and width $28$ differ *not* by eight units of capacity but by the
  presence or absence of coordinates outside the digit block (Corollary 5.3).
- Two tokens of the same support size can lie on opposite sides of the
  dichotomy (Theorem 5.4).
- A full-input-width boundary token that nonetheless has no exclusive
  dimension behaves like the fragile regime, consistent with the theory and
  inconsistent with a capacity reading.

The control variable is **representational distinctness**. Width matters only
because zero-padding past $D$ is an easy way to buy it.

### 10.3 Practical consequences

For a practitioner the recommendation is concrete and cheap: reserve at least
one input dimension that no content token can occupy, and place the boundary
marker there. This costs one coordinate and converts a $25\%$ chance of a cure
into a certainty in the model, and into a $20/20$ observed sweep in practice.
The same reasoning applies to any special token — padding, separators, class
markers, task prefixes — whose job is to be recognised as *not* content. If it
shares its subspace with content, its ability to be recognised is a lottery on
the initialisation.

### 10.4 Limitations

The mechanism is proved in a max-plus model of the readout, which captures
max-taking piecewise-linear computation but not the full smooth dynamics of a
gated recurrent cell. The probability statements at model level establish that
the fragile probability lies strictly inside $(0,1)$; they do not by themselves
predict the value $1/4$, which is empirical. And the empirical samples, while
sufficient for the dominance and likelihood conclusions stated, are twelve and
twenty runs on one task at one scale.

---

## 11. Future work

**The shape of the shift.** We conjecture that the fragile cure probability is
strictly increasing in $E$ on $0 < E \le D$ and equals $\Pr[\max_{i \le E} c_i >
0]$. For i.i.d. symmetric coefficients this gives $\Pr[\text{cure} \mid E] =
1 - 2^{-E}$ for $E \le D$ and $1$ for $E > D$, so no width in the fragile range
has probability exactly $0$ or $1$. The key insight is that Theorem 6.1 makes
the cure event a *maximum-of-coefficients* event, and maxima of independent
coordinates are monotone in the number of coordinates: the shift is a
max-stability phenomenon, not a capacity phenomenon. Only product-measure
bookkeeping stands between the present results and this statement, and the
untested arm $E = 24$ is a direct empirical test of the predicted strict
monotonicity.

**Depth amplification.** The model half is settled (Theorems 7.6, 7.7). The open
conjecture is quantitative transfer: in a trained gated cell the accuracy at
unroll depth $n$ in the fragile regime should decay smoothly and monotonically
in $n$, with no depth at which it recovers. The reason is Theorem 7.3: a
max-plus layer is monotone and commutes with tropical scalars, so a gap bounded
at depth one can never be amplified — which is exactly the observed smooth
progressive-unroll collapse.

**Real-scale transfer.** Whether reserving an exclusive boundary dimension
removes analogous positional pathologies at production scale is untested, and is
the natural next experiment.

---

## 12. Conclusion

The boundary-width "threshold" is not a threshold. Two runs of the same width
with opposite outcomes refute every threshold model outright. What the data show
instead is a one-sided distribution shift: the robust accuracy distribution
stochastically dominates the fragile one at every level, strictly at the cure
level, with the homogeneous-probability null rejected by more than five orders
of magnitude in maximised likelihood, uniformly in the nuisance parameter.

Underneath the statistics lies an exact piece of tropical geometry. A boundary
token lies in the max-plus span of the digit atoms precisely when it owns no
dimension outside the digit block; in that case every readout responds to it as
a fixed combination of its digit responses, and the best achievable
boundary-versus-digit margin is *exactly* the token's largest learned
coefficient. Separability is therefore the sign event $\max_i c_i > 0$ — a
coin flip decided by the initialisation. One exclusive dimension replaces that
coin flip with an unbounded, perturbation-stable margin, giving cure probability
one; and because separability is monotone under coordinatewise domination, the
effect of widening is one-sided by construction. Finally, because a max-plus
layer cannot amplify a bounded gap at any depth, the fragile regime's failure is
forced to be a smooth slide rather than a cliff.

The control variable is representational distinctness, not width.
