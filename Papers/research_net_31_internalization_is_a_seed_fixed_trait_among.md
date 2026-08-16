# Gated Readouts and Coprime Boundary Blocks: A Two-Layer Theory of Internalization

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

We develop a two-layer arithmetic theory of *boundary-block internalization*: the
question of whether an answer-producing process, having learned to use a
distinguished marker occupying $k$ exclusive dimensions, still requires that
marker at evaluation time. The first layer is an **additive gate**: a threshold
$\mathrm{thr}$ compared against the aggregate drive $\sum_{i=1}^{k} w_i$ of the
block. In this layer we compute the exact arithmetic of four local
interventions — whole-block zeroing, single-coordinate zeroing, single-coordinate
sign flip, and rescaling — and derive four structural laws. (i) On a uniform
block of $k$ coordinates of size $a$, single-coordinate zeroing survives iff
$\mathrm{thr} \le (k-1)a$ and a sign flip survives iff $\mathrm{thr} \le (k-2)a$;
the vanishing of the exponent $k-2$ at $k = 2$ makes sign sensitivity an *exact*
dependence test at width two and an *uninformative* one at every larger width.
(ii) Modelling a learner by four width-independent parameters $(b, g, d, s)$ —
base drive, per-dimension boundary gain, demand, and a separation requirement —
boundary dependence is the width-free condition $b < d$, hence *width-invariant*,
while curing, $s \le k \wedge d \le b + kg$, is monotone in $k$: **width sets the
probability of a cure, the learner sets internalization.** (iii) Retention
$\rho(k) = b/(b + kg)$ is strictly decreasing in $k$ with $\rho(k) \to 0$ and
$k\rho(k) \to b/g$: dependence deepens with width, but only harmonically, so
$\sum_k \rho(k)$ diverges and geometric collapse is excluded. (iv) The
width-one outcome and the internalization trait are logically independent: all
four combinations are realised, and there exist two learners indistinguishable at
width one, both curing at width two, one dependent at every width and the other
self-sufficient at every width — which *forces* the separation parameter $s$ into
the model.

The second layer is **arithmetic**. Modelling $k$ exclusive dimensions by $k$
pairwise coprime moduli $m_i \ge 2$ and "resolving the answer range $[0,A)$" by
injectivity of the residue map, the Chinese Remainder Theorem becomes an ablation
statement: a block resolves every range below its capacity
$\prod_{i\in S} m_i \ge 2^{k}$; within the single-drop margin $A \le 2^{k-1}$ every single-dimension
ablation is a no-op; and the empty block resolves only ranges with at most one
element. Hence *collective use* is a theorem at the capacity layer as well as at
the gate layer, and it is realised at every width $k \ge 2$ by Fermat blocks
$\{2^{2^i}+1\}$. Two honest boundaries delimit the theory: the single-drop no-op
requires the capacity margin — $(2,3,5)$ resolves $A = 30$ but loses resolution
when the modulus $5$ is dropped — and sign flips are *always* free at the
capacity layer, so observed sign sensitivity cannot be a capacity phenomenon.
Finally we prove identifiability results: the control reading plus the $k$
single-coordinate zeroings determine the block exactly, flip readings are an
exact affine function of the zero readings, and a single positive-width retention
reading determines the entire retention profile.

**Keywords:** gated readout, aggregate drive, ablation battery, Chinese Remainder
Theorem, pairwise coprime moduli, Fermat numbers, width invariance, harmonic
decay, identifiability.

---

## 1. Introduction

### 1.1 The phenomenon

Consider a process that must emit an answer, and which during training has
available a distinguished *boundary marker* — a terminator, a separator, a
signpost — that occupies $k$ dedicated coordinates of its state. Two questions
are then separable, and they are routinely conflated:

1. **Does the process learn the task at all?** (Call this *curing*.)
2. **Once it has learned, does it still need the marker at evaluation time?**
   (Call the negation of this need *internalization*.)

A campaign of controlled interventions distinguishes the two. Hold the learner
fixed and vary only the width $k$ of the boundary block; after training,
intervene at evaluation time only, in four ways:

- $\mathrm{zeroN}$: zero the entire block;
- $\mathrm{zero1}_j$: zero a single coordinate $j$;
- $\mathrm{flip1}_j$: negate a single coordinate $j$;
- $\mathrm{scale}_c$: multiply the whole block by $c$ (e.g. $c = 1/10$).

Five empirical regularities emerge from such a campaign, and they are the target
of this paper:

**(O1) Collective use.** $\mathrm{zero1}$ is a no-op at every width $k \ge 2$,
in every arm, dependent or not.

**(O2) A fixed dependent set.** $\mathrm{zeroN}$ costs a substantial fraction of
accuracy on a fixed subset of learners and nothing on the rest — and *the same
subset* is dependent at width $2$ and at width $3$.

**(O3) Dependence deepens.** On the dependent learners, the cost of
$\mathrm{zeroN}$ grows with $k$.

**(O4) Sign sensitivity is width-two only.** $\mathrm{flip1}$ costs a
substantial fraction in the dependent arms at $k = 2$, and is *exactly free* in
all arms at $k = 3$.

**(O5) No width-one predictor.** The behaviour of a learner at $k = 1$ — fail,
partial, or cure — does not determine whether it will be boundary-dependent at
the widths where it does cure.

Individually these look like empirical curiosities requiring separate stories.
We show that they are theorems of a two-parameter model of a gated readout,
supplemented by an arithmetic model of what a block of exclusive dimensions can
carry.

### 1.2 Two layers, two jobs

The paper is organised around a deliberate separation of concerns.

The **gate layer** (Sections 2–5) is additive and real-valued. It answers: *when
does damage to the block cross a threshold?* It explains (O1) through the margin
$(k-1)a$, (O2) through width-invariance of a comparison $b < d$, (O3) through
harmonic decay of retention, (O4) through the root of $k-2$ at $k = 2$, and (O5)
through logical independence of resolution and capacity.

The **capacity layer** (Section 6) is arithmetic and integral. It answers: *why
can a block of $k$ exclusive dimensions carry an answer at all, and why does
exclusivity matter?* Its answer is the Chinese Remainder Theorem. It gives a
second, independent derivation of (O1), and — crucially — it *excludes itself*
from explaining (O4), because sign flips are provably free at the capacity layer.

Section 7 gives identifiability results (what the intervention battery can and
cannot recover), Section 8 replays a recorded retention table as an exact
rational computation, and Sections 9–10 discuss scope, falsifiable predictions,
and open problems.

---

## 2. The gated readout

Throughout, drives are rational (all statements are field-theoretic and hold
verbatim over $\mathbb{R}$).

> **Definition 2.1 (Readout).** A *gated readout of width $k$* is a pair
> $R = (\mathrm{thr}, \mathrm{coord})$ with $\mathrm{thr} \in \mathbb{Q}$ and
> $\mathrm{coord} : \{1,\dots,k\} \to \mathbb{Q}$. The number $\mathrm{thr}$ is
> the residual drive the answer path still needs from the boundary block;
> $\mathrm{coord}$ is the block as trained.

> **Definition 2.2 (Drive; survival).** For $w : \{1,\dots,k\} \to \mathbb{Q}$
> put $\mathrm{drive}(w) = \sum_{i=1}^{k} w_i$. The readout $R$ *survives* the
> configuration $w$ when $\mathrm{thr} \le \mathrm{drive}(w)$.

The single modelling commitment here is that the block is read *as an
aggregate*: the answer path sees $\sum_i w_i$ and nothing finer. Observation
(O1) is the empirical warrant for this commitment, and Section 6 supplies an
independent arithmetic warrant.

> **Definition 2.3 (Interventions).** For $w$ as above and $j \in \{1,\dots,k\}$:
> $\mathrm{zeroN}(w) \equiv 0$; $\mathrm{zero1}_j(w)$ agrees with $w$ off $j$ and
> is $0$ at $j$; $\mathrm{flip1}_j(w)$ agrees with $w$ off $j$ and is $-w_j$ at
> $j$; $\mathrm{scale}_c(w)_i = c\,w_i$.

> **Definition 2.4 (Dependence; self-sufficiency).** $R$ is
> *boundary-dependent* if it does **not** survive
> $\mathrm{zeroN}(\mathrm{coord})$, and *self-sufficient* if it does.

> **Lemma 2.5 (Exact intervention arithmetic).** For every block $w$ and index
> $j$:
> $$\mathrm{drive}(\mathrm{zeroN}(w)) = 0, \qquad
> \mathrm{drive}(\mathrm{zero1}_j(w)) = \mathrm{drive}(w) - w_j,$$
> $$\mathrm{drive}(\mathrm{flip1}_j(w)) = \mathrm{drive}(w) - 2w_j, \qquad
> \mathrm{drive}(\mathrm{scale}_c(w)) = c\,\mathrm{drive}(w).$$

*Proof sketch.* Split the sum as $w_j + \sum_{i \ne j} w_i$; the intervention
alters only the isolated term, replacing $w_j$ by $0$ or by $-w_j$, and the
rescaling factors out of the sum by distributivity. $\square$

The asymmetry between deletion and flipping — cost $w_j$ versus cost $2w_j$ — is
not decorative; it is the origin of (O4).

> **Proposition 2.6 (Dependence is a sign condition).** $R$ is
> boundary-dependent iff $\mathrm{thr} > 0$, and self-sufficient iff
> $\mathrm{thr} \le 0$.

*Proof.* $\mathrm{drive}(\mathrm{zeroN}(w)) = 0$, so survival of $\mathrm{zeroN}$
is the statement $\mathrm{thr} \le 0$. $\square$

Proposition 2.6 is trivial and consequential: the criterion for dependence
mentions neither $k$ nor the block. Everything in Section 4 is a corollary of
this absence.

> **Proposition 2.7 (Rescaling).** $R$ fails to survive $\mathrm{scale}_c(w)$
> iff $c\,\mathrm{drive}(w) < \mathrm{thr}$. In particular, if $c \ge 0$ and
> $\mathrm{drive}(w) \ge 0$, a self-sufficient readout survives every rescaling.

*Proof.* Immediate from Lemma 2.5 and Proposition 2.6. $\square$

This is the qualitative account of the $\mathrm{scale}_{0.1}$ arm: a mild,
graded cost on dependent arms — proportional to how much of the margin the
factor $c$ eats — and exactly zero cost on self-sufficient arms.

---

## 3. Uniform blocks: the $k-1$ and $k-2$ laws

Write $\mathrm{unif}(k, a)$ for the block with every coordinate equal to $a$: the
idealisation of "$k$ equally weighted exclusive dimensions".

> **Lemma 3.1.** $\mathrm{drive}(\mathrm{unif}(k,a)) = ka$;
> $\mathrm{drive}(\mathrm{zero1}_j \mathrm{unif}(k,a)) = (k-1)a$;
> $\mathrm{drive}(\mathrm{flip1}_j \mathrm{unif}(k,a)) = (k-2)a$.

> **Corollary 3.2 (Survival laws).** On the uniform block,
> $\mathrm{zero1}_j$ is survived iff $\mathrm{thr} \le (k-1)a$, and
> $\mathrm{flip1}_j$ is survived iff $\mathrm{thr} \le (k-2)a$.

> **Theorem 3.3 (Collective use, gate version — (O1)).** Let $a > 0$,
> $k \ge 2$, and $\mathrm{thr} \le (k-1)a$. Then for every $j$ the readout
> survives $\mathrm{zero1}_j\mathrm{unif}(k,a)$ and survives the intact block.
> This holds whether or not the readout is boundary-dependent.

*Proof.* The first claim is Corollary 3.2. For the second, $(k-1)a \le ka$ since
$a > 0$, and survival is monotone in the drive. $\square$

Theorem 3.3 is the precise content of "the block is used collectively": a
readout can be destroyed by removing all $k$ coordinates while being untouched
by removing any one of them. There is no contradiction, because the gate is a
comparison against the *sum*.

> **Theorem 3.4 (Sign sensitivity at width two — (O4), first half).** Let
> $R$ be a width-two readout that is boundary-dependent. Then for every $j$ and
> every $a$, $R$ does **not** survive $\mathrm{flip1}_j\mathrm{unif}(2,a)$.

*Proof.* By Corollary 3.2 survival would require $\mathrm{thr} \le (2-2)a = 0$,
contradicting $\mathrm{thr} > 0$ from Proposition 2.6. $\square$

> **Theorem 3.5 (Flip is an exact dependence marker at width two).** For a
> width-two readout, every $a$ and every $j$: $R$ survives
> $\mathrm{flip1}_j\mathrm{unif}(2,a)$ **iff** $R$ is self-sufficient.

*Proof.* Both sides are the condition $\mathrm{thr} \le 0$. $\square$

Note what Theorem 3.5 claims: at width two the flip reading is not a *heuristic*
for dependence, it is *equivalent* to the whole-block reading — no false
positives, no false negatives. The mechanism is visible in the arithmetic: at
$k = 2$ a flip forces sign opposition between the two coordinates and the
aggregate collapses to exactly $0$, the same value $\mathrm{zeroN}$ produces.

> **Theorem 3.6 (Flip freedom at width three — (O4), second half).** Let $R$
> be a width-three readout with $\mathrm{thr} \le a$. Then $R$ survives
> $\mathrm{flip1}_j\mathrm{unif}(3,a)$ for every $j$ — even if $R$ is
> boundary-dependent.

*Proof.* Corollary 3.2 requires $\mathrm{thr} \le (3-2)a = a$. $\square$

> **Theorem 3.7 (The marker is width-two only).** There exist a width-two
> readout $R_2$, a width-three readout $R_3$ and $a > 0$ such that both are
> boundary-dependent, both survive their intact blocks, no flip is survived at
> width two, and every flip is survived at width three.

*Proof.* Take $a = 1$, $\mathrm{thr} = 1$ in both cases, with uniform blocks of
size $1$. Dependence is $\mathrm{thr} = 1 > 0$; intact survival is $1 \le k$ for
$k = 2, 3$; the flip claims are Theorems 3.4 and 3.6. $\square$

So the empirical contrast between "$-7\%$ to $-25\%$ on flips at $k = 2$" and
"exactly $0\%$ on flips at $k = 3$" requires no change of mechanism between the
two widths. It is the single law $\mathrm{thr} \le (k-2)a$ evaluated at the root
of its own coefficient.

> **Theorem 3.8 (Severity staircase).** Let $a \ge 0$, $k \ge 2$, $j$ arbitrary.
> Then: self-sufficiency $\Rightarrow$ survives $\mathrm{flip1}_j$
> $\Rightarrow$ survives $\mathrm{zero1}_j$ $\Rightarrow$ survives the control.

*Proof.* Chain the inequalities $0 \le (k-2)a \le (k-1)a \le ka$, valid for
$a \ge 0$ and $k \ge 2$, against the monotone survival criterion. $\square$

Theorem 3.8 is a falsifiable constraint on any experimental table: an arm in
which a flip hits but whole-block zeroing does not is impossible under the
model. Conversely, an observed staircase is *not* independent evidence for the
model — it is the cheapest thing the model predicts.

---

## 4. Seeds: width sets curing, the learner sets internalization

We now model a learner (a *seed*: one training run under a fixed initialisation)
by width-independent parameters.

> **Definition 4.1 (Seed).** A *seed* is a tuple $s = (b, g, d, \mathrm{sep})$
> with $b, g, d \in \mathbb{Q}$, $g \ge 0$, and $\mathrm{sep} \in \mathbb{N}$:
> $b$ is the *base*, the drive the answer path produces internally; $g$ is the
> *gain* contributed by each exclusive boundary dimension; $d$ is the *demand*;
> and $\mathrm{sep}$ is the number of exclusive dimensions the seed needs in
> order to resolve the boundary at all.

> **Definition 4.2 (Trained readout; curing).** At width $k$ the seed trains
> into the readout $R_k = (d - b,\ \mathrm{unif}(k, g))$. It *cures at width $k$*
> iff
> $$\mathrm{sep} \le k \quad \text{(resolution)} \qquad\text{and}\qquad
> d \le b + kg \quad \text{(capacity)}.$$

The two conjuncts are the theory's two parameters of curing, and their
separateness is the whole content of Section 5.

> **Theorem 4.3 (Curing is width-monotone).** If $s$ cures at $k$ and $k \le m$
> then $s$ cures at $m$.

*Proof.* $\mathrm{sep} \le k \le m$; and $kg \le mg$ since $g \ge 0$, so
$d \le b + kg \le b + mg$. $\square$

> **Theorem 4.4 (Internalization is width-invariant — the headline law).**
> For every seed $s$ and all widths $k, m$: $R_k$ is boundary-dependent iff
> $R_m$ is boundary-dependent. Moreover $R_k$ is boundary-dependent iff
> $b < d$, and self-sufficient iff $d \le b$.

*Proof.* By Proposition 2.6 dependence of $R_k$ is $d - b > 0$, a statement in
which $k$ does not occur. $\square$

> **Corollary 4.5 (The dependent set is width-invariant — (O2)).** For any
> family $(s_i)_{i \in I}$ of seeds and any two widths $k, m$,
> $$\{\, i \in I : R_k(s_i) \text{ boundary-dependent} \,\}
> = \{\, i \in I : R_m(s_i) \text{ boundary-dependent} \,\}$$
> as sets.

Corollary 4.5 is the formal content of the slogan *width sets the probability of
a cure; the seed sets internalization*. Under the model, an experiment that
finds the *same* dependent learners at $k = 2$ and $k = 3$ is not reporting a
coincidence but confirming a rigidity; and an experiment that found different
sets would refute the model outright.

It also disciplines a reporting error that is easy to make. If a first campaign
observes a high internalization rate on one family of learners and a second
campaign a much lower rate on another family, the honest reading is *not* that
internalization changed with the width at which the campaigns were run; it is
that the rate is a property of the *sample of learners*, and the two samples must
be pooled. Under Theorem 4.4 the rate cannot be a width effect at all.

### 4.1 Retention: how deep the dependence runs

> **Definition 4.6 (Retention).** The *retention* of a seed at width $k$ is
> $$\rho_s(k) \;=\; \frac{b}{b + kg},$$
> the share of the required drive that survives whole-block ablation.

> **Theorem 4.7 (Flat retention of a boundary-free seed).** If $b \ne 0$ and
> $g = 0$ then $\rho_s(k) = 1$ for all $k$.

> **Theorem 4.8 (Dependence deepens — (O3)).** If $b > 0$ and $g > 0$ then
> $\rho_s$ is strictly decreasing in $k$, satisfies $\rho_s(k) < 1$ for
> $k \ge 1$, and $\rho_s(k) \to 0$ as $k \to \infty$.

*Proof sketch.* Both denominators are positive; $\rho_s(k) > \rho_s(m)$ for
$k < m$ reduces, after clearing denominators, to $b\,g\,(m-k) > 0$. For the
limit, $b + kg \to \infty$ and the numerator is constant. $\square$

> **Theorem 4.9 (Harmonic law).** If $b > 0$ and $g > 0$ then
> $k\,\rho_s(k) \to b/g$.

*Proof sketch.* Write $k\rho_s(k) = (b/g)\,(1 - \rho_s(k))$, an identity
verifiable by clearing denominators, and apply $\rho_s(k) \to 0$. $\square$

> **Corollary 4.10 (Divergence).** If $b > 0$ and $g > 0$ then
> $\sum_{k} \rho_s(k)$ diverges.

*Proof sketch.* By Theorem 4.9 the terms are asymptotically $ (b/g)\cdot k^{-1}$;
concretely, $\rho_s(k) \ge \frac{b}{b+g}\cdot\frac{1}{k+1}$ for all $k \ge 0$, and
the harmonic series diverges. $\square$

Corollary 4.10 has teeth as a *prohibition*. A mechanism in which the answer
path's residual self-sufficiency collapsed geometrically in the width — say
$\rho(k) \asymp 2^{-k}$ — is incompatible with an additive per-dimension gain.
Observing geometric collapse would therefore falsify the additive gate, not
merely tune it. Empirically the recorded pattern ($-2.8\%, -9\%, -10\%$ on one
learner; $-25\%, -30\%$ on another) is consistent with the slow, saturating decay
the model demands.

---

## 5. Why there is no width-one predictor

Observation (O5) says the $k = 1$ rung carries no information about the trait.
Under a *capacity-only* model — one in which curing at width $k$ meant only
$d \le b + kg$ — this would be impossible: a self-sufficient seed has
$d \le b \le b + g$ and would necessarily cure already at $k = 1$, so "failed at $k = 1$"
would be a perfect predictor of dependence. The observed absence of a predictor
is therefore *evidence for the resolution parameter*.

> **Theorem 5.1 (Logical independence of the width-one rung and the trait).**
> For each pair of truth values $(\beta_1, \beta_2)$ there is a seed $s$ that
> cures at width $1$ iff $\beta_1$ holds, is boundary-dependent at width $2$ iff
> $\beta_2$ holds, and cures at width $2$.

*Proof.* Exhibit four seeds $(b, g, d, \mathrm{sep})$:
$(2,1,1,2)$ — fails at $k=1$ for lack of resolution, self-sufficient, cures at
$k=2$;
$(1,1,3,1)$ — fails at $k=1$ for lack of capacity, dependent, cures at $k=2$;
$(2,1,1,1)$ — cures at $k=1$, self-sufficient;
$(1,1,2,1)$ — cures at $k=1$, dependent.
Each claim is a numerical check of $\mathrm{sep} \le k$, $d \le b + kg$, and
$b < d$. $\square$

> **Theorem 5.2 (An indistinguishable pair with opposite traits).** There are
> seeds $s, t$ such that neither cures at width $1$, both cure at width $2$,
> $s$ is boundary-dependent at *every* width, and $t$ is self-sufficient at
> *every* width.

*Proof.* $s = (1,1,3,1)$ and $t = (2,1,1,2)$. Then $s$ fails at $k = 1$ because
$1 + 1 < 3$ and $t$ fails because $\mathrm{sep} = 2 > 1$; both cure at $k = 2$
($1 + 2 \ge 3$; $2 \ge 2$ and $1 \le 2 + 2$); and $b < d$ for $s$ while
$d \le b$ for $t$, at every width by Theorem 4.4. $\square$

Theorem 5.2 is the exact refutation of a width-one predictor: the two learners
produce identical width-one reports and permanently opposite traits. It is also
the reason the two "impossible" observations (O2) and (O5) are not in tension.
(O2) says the trait is constant across widths; (O5) says it is invisible at the
lowest rung. Both follow at once as soon as curing requires *resolution in
addition to capacity*, because resolution failure at $k = 1$ is trait-neutral —
it can happen to a self-sufficient learner and to a dependent one alike.

An engineering consequence: internalization must be measured at a width where
the learner *cures*. The trait exists at all widths as a comparison $b < d$, but
it only *manifests* — becomes observable via an accuracy drop — where the learner
is producing correct answers to begin with.

---

## 6. The capacity layer: exclusive dimensions and the Chinese Remainder Theorem

The gate layer treats the block as a source of scalar drive. It is silent on why
a block of $k$ dimensions can *carry an answer*, and on why the design rule is
stated in terms of **exclusive** dimensions. This section supplies the missing
arithmetic. Exclusivity is modelled as *pairwise coprimality*: distinct
dimensions share no information.

> **Definition 6.1 (Block, resolution).** Let $S$ be a finite set of surviving
> dimensions and $m : S \to \mathbb{Z}$ an assignment of moduli. Say $S$
> *resolves the answer range* $A \in \mathbb{Z}$ if for all integers $x, y$ with
> $0 \le x < A$ and $0 \le y < A$, the condition $m_i \mid x - y$ for all
> $i \in S$ implies $x = y$. The moduli are *pairwise coprime* if $m_i$ and
> $m_j$ are coprime for all $i \ne j$ in $S$.

> **Theorem 6.2 (Capacity; CRT as an ablation statement).** If the moduli on
> $S$ are pairwise coprime and $A \le \prod_{i \in S} m_i$, then $S$ resolves
> $A$.

*Proof.* Suppose $m_i \mid x - y$ for all $i \in S$. Pairwise coprimality lifts
this to $\prod_{i \in S} m_i \mid x-y$. But $0 \le x, y < A$ forces
$|x - y| < A \le \prod_i m_i$, and the only multiple of $\prod_i m_i$ of smaller
absolute value is $0$. Hence $x = y$. $\square$

> **Lemma 6.3 (Width is capacity).** If $m_i \ge 2$ for all $i \in S$ and
> $|S| = k$, then $\prod_{i \in S} m_i \ge 2^k$. Consequently, for any
> $j \in S$, $\prod_{i \in S \setminus \{j\}} m_i \ge 2^{k-1}$.

*Proof.* Compare the product termwise with the constant product
$\prod_{i\in S}2 = 2^{k}$; the second claim applies the first to $S \setminus \{j\}$, whose
cardinality is $k - 1$. $\square$

> **Theorem 6.4 (Single-drop no-op).** Let $|S| = k$, let the moduli be
> pairwise coprime with $m_i \ge 2$, and let the answer range satisfy the
> *single-drop margin* $A \le 2^{k-1}$. Then for every $j \in S$ the ablated
> block $S \setminus \{j\}$ still resolves $A$.

*Proof.* Pairwise coprimality is inherited by subsets; by Lemma 6.3 the
surviving capacity is at least $2^{k-1} \ge A$; apply Theorem 6.2. $\square$

> **Theorem 6.5 (Whole-block ablation is fatal).** The empty block resolves $A$
> if and only if $A \le 1$.

*Proof.* If $A \le 1$ the range contains at most one integer $\ge 0$, so
resolution is vacuous. If $A \ge 2$ then $x = 0$ and $y = 1$ satisfy the
(empty) divisibility hypothesis and are distinct. $\square$

> **Theorem 6.6 (Collective use, capacity version — (O1) again).** Let
> $|S| = k$ with pairwise coprime moduli $m_i \ge 2$, and let
> $2 \le A \le 2^{k-1}$ (possible exactly when $k \ge 2$). Then:
> (i) $S$ resolves $A$; (ii) for every $j \in S$, $S \setminus \{j\}$ resolves
> $A$; (iii) the empty block does not resolve $A$.

*Proof.* (i) $A \le 2^{k-1} \le 2^k \le \prod_i m_i$ and Theorem 6.2; (ii)
Theorem 6.4; (iii) Theorem 6.5 with $A \ge 2$. $\square$

Thus "used collectively" holds twice over, for two entirely different reasons: an
additive margin at the gate, an arithmetic margin at the capacity layer. Both
predict *single-point damage free, total damage fatal*, which is why observation
(O1) is robust and why it is weak evidence for either layer individually.

### 6.1 The configuration exists at every width: Fermat blocks

One might worry that the hypotheses of Theorem 6.6 describe a lucky
configuration. They do not.

> **Theorem 6.7 (Realisation at every width).** For every $k \ge 2$ there exist
> a $k$-element block with pairwise coprime moduli, all at least $2$, and an
> answer range $A \ge 2$, satisfying all three conclusions of Theorem 6.6.

*Proof.* Take the *Fermat block* $m_i = F_i = 2^{2^i} + 1$ for
$i = 0, \dots, k-1$, i.e. $3, 5, 17, 257, 65537, \dots$. Each $F_i \ge 3 \ge 2$,
and distinct Fermat numbers are coprime — a classical fact, provable from the
telescoping identity $F_0F_1\cdots F_{n-1} = F_n - 2$, which shows any common
divisor of $F_i$ and $F_j$ ($i<j$) divides $2$ while all $F_i$ are odd. Take
$A = 2^{k-1} \ge 2$ and apply Theorem 6.6. $\square$

The mechanism is therefore generic in the width, not an artefact of a convenient
modulus choice. Note also the accounting: an ideal $k$-dimensional exclusive
block carries $\log_2 \prod_i m_i \ge k$ bits, of which the design deliberately
uses at most $k-1$, spending one bit's worth of capacity on single-point
redundancy.

### 6.2 Two honest boundaries

The two theorems below delimit what the capacity layer may be used to claim.

> **Theorem 6.8 (The single-drop no-op requires the margin).** There is a
> pairwise coprime block, an index $j$ and a range $A$ such that the block
> resolves $A$ but the ablated block $S \setminus \{j\}$ does not.

*Proof.* Take moduli $(2, 3, 5)$ and $A = 30 = 2\cdot3\cdot5$. Theorem 6.2 gives
resolution. Drop the modulus $5$: then $x = 0$ and $y = 6$ lie in $[0,30)$, are
congruent mod $2$ and mod $3$, and are distinct. $\square$

Hence a design rule of the form "*three exclusive dimensions in a final-step
boundary token and you are safe*" is only correct *relative to the answer range*:
the free deletion is bought by the margin $A \le 2^{k-1}$, and a block run at its
capacity limit $A = \prod_i m_i$ has no redundancy whatsoever. This is the exact
mathematical content of the caution that internalization should be verified per
instance rather than assumed from the width.

> **Theorem 6.9 (Sign flips are free at the capacity layer).** For any subset
> $T$ of the dimensions, the block with moduli $m_i$ replaced by $-m_i$ for
> $i \in T$ resolves exactly the same ranges as the original block.

*Proof.* $m \mid n$ iff $-m \mid n$; resolution is defined purely in terms of
divisibility. $\square$

Theorem 6.9 is a *negative* result of real methodological value: the sign
sensitivity observed at width two cannot be a capacity phenomenon. Combined with
Theorems 3.4–3.6, it localises (O4) unambiguously in the additive gate. The two
layers do not compete for the same observations; each excludes itself from the
other's domain.

---

## 7. Identifiability: what the intervention battery recovers

Two natural methodological questions have crisp answers.

> **Theorem 7.1 (The zero battery identifies the block).** If two blocks
> $w, v$ of width $k$ satisfy $\mathrm{drive}(w) = \mathrm{drive}(v)$ and
> $\mathrm{drive}(\mathrm{zero1}_j w) = \mathrm{drive}(\mathrm{zero1}_j v)$ for
> every $j$, then $w = v$.

*Proof.* By Lemma 2.5, $\mathrm{drive}(w) - w_j = \mathrm{drive}(v) - v_j$;
subtract the control equality to get $w_j = v_j$ for each $j$. $\square$

> **Theorem 7.2 (Flip readings are redundant at the block level).** For every
> $w$ and $j$,
> $$\mathrm{drive}(\mathrm{flip1}_j w) = 2\,\mathrm{drive}(\mathrm{zero1}_j w) - \mathrm{drive}(w).$$

*Proof.* Both sides equal $\mathrm{drive}(w) - 2w_j$ by Lemma 2.5. $\square$

Theorems 7.1 and 7.2 together say: the control plus the $k$ zeroings is a
*complete* battery for the block, and the flip arms add nothing about the block.
Whatever information flip arms carry is carried through the *gate* — through
whether a threshold happens to be crossed — which is exactly why flip
informativeness is width-dependent (Theorems 3.5, 3.6) while the zero battery is
not.

> **Theorem 7.3 (One reading determines the retention profile).** Let $s, t$ be
> seeds with $b_s, b_t > 0$. If $\rho_s(k) = \rho_t(k)$ for a single $k \ge 1$,
> then $\rho_s(m) = \rho_t(m)$ for every $m$.

*Proof sketch.* Clearing denominators in $\rho_s(k) = \rho_t(k)$ and cancelling
the factor $k > 0$ yields $b_s g_t = b_t g_s$: a single positive-width reading
pins the ratio $g/b$. Since $\rho(m) = 1/(1 + m\,(g/b))$ depends on the seed only
through that ratio, the profiles agree at every $m$. $\square$

Theorem 7.3 is the model's sharpest falsifiable prediction about a width-swept
design: **two learners that agree on retention at one width and disagree at
another falsify the additive gate.** It also has a positive use: a single
retention reading, together with the smallest width at which a learner cures
(which yields $\mathrm{sep}$), calibrates all four seed parameters up to scale,
after which every other width is predicted with no free parameters.

---

## 8. A recorded table, checked exactly

To connect the theory to a concrete measurement, consider a campaign covering a
family of twelve learners indexed $8$–$19$, trained at widths $2$ and $3$ with
everything but the width held fixed, and evaluated after whole-block ablation.
Retentions (control-normalised accuracy after ablation) recorded as exact
rationals:

| learner | $k = 2$ | $k = 3$ |
|---------|---------|---------|
| 13 | $0.7544$ | $0.7041$ |
| 14 | $0.9141$ | $0.9014$ |
| 15 | $0.8037$ | $0.7104$ |
| 17 | $0.9067$ | $0.7437$ |
| all others | $1$ (within noise) | $1$ (within noise) |

Fixing a dependence cut at retention $\le 0.95$, three claims about this table
are finite decidable statements and hold exactly:

1. **Width-invariance of the dependent set (an instance of Corollary 4.5).**
   For every learner in the family, retention at $k = 2$ is below the cut iff
   retention at $k = 3$ is.
2. **Identification of the set.** That common set is exactly
   $\{13, 14, 15, 17\}$, so eight of the twelve learners read as self-sufficient
   at both widths (a pooled internalization rate of $8/12$; excluding one
   marginal arm as the campaign does gives $7/12$).
3. **Deepening (an instance of Theorem 4.8).** For every dependent learner,
   retention at $k = 3$ is strictly below retention at $k = 2$.

Claim 2 deserves emphasis for a methodological reason. If one sub-family of six
learners shows five self-sufficient and another sub-family of six shows three
dependent, the correct summary is the pooled rate, *not* a claim that
internalization changed. Under Theorem 4.4 it cannot have changed with the
width; the difference between the sub-families is a difference between samples of
learners. Reporting the higher sub-family rate as the campaign's headline number
would be a sampling artefact — the theory says so, independently of any
statistics.

---

## 9. Discussion

### 9.1 What is explained, and by which layer

| Observation | Explained by | Statement |
|---|---|---|
| (O1) single-coordinate ablation is free | both layers | Theorems 3.3 and 6.6 |
| (O2) same dependent set at every width | gate layer | Theorem 4.4, Corollary 4.5 |
| (O3) dependence deepens with width | gate layer | Theorem 4.8; rate law 4.9 |
| (O4) sign sensitivity only at width two | gate layer only | Theorems 3.4–3.7; *excluded* from capacity layer by 6.9 |
| (O5) no width-one predictor | gate layer, two-parameter | Theorems 5.1, 5.2 |

The most informative row is (O4). A single negative theorem (6.9) removes an
entire candidate explanation, and the surviving explanation is quantitative and
sharp: the flip threshold is $(k-2)a$, which degenerates to the whole-block
threshold precisely at $k = 2$.

### 9.2 Scope and idealisations

The model is deliberately minimal, and its idealisations should be stated.

*Uniformity.* Theorems 3.3–3.8 assume equal coordinates. Non-uniform blocks
replace $(k-1)a$ by $\mathrm{drive}(w) - w_j$ and $(k-2)a$ by
$\mathrm{drive}(w) - 2w_j$ (Lemma 2.5), so the qualitative laws persist with $a$ replaced by the
relevant coordinate; only the clean numerology of the exponents is uniform-block
specific. An immediate consequence worth recording: a *dominant* coordinate,
$w_j > \frac{1}{2}\mathrm{drive}(w)$, makes a flip fatal at any width, so the
observation "no flip effect at $k = 3$" is also weak evidence that trained blocks
are roughly balanced.

*Linearity of the gate.* The readout is a single threshold on a linear
functional. This is the minimal hypothesis that makes the ablation battery
analysable; the empirical warrant is (O1) plus the observed graded response to
rescaling.

*Additivity of gain.* Retention $b/(b+kg)$ presupposes that each dimension
contributes the same drive independently. Corollary 4.10 shows this assumption
is falsifiable: geometric collapse of retention would refute it.

*Separation as an integer threshold.* $\mathrm{sep} \le k$ is the crudest
possible resolution condition. The capacity layer suggests a refinement:
resolution should compare the answer range $A$ against $\prod_i m_i$, so
$\mathrm{sep}$ is naturally $\lceil \log_2 A \rceil$, or
$\lceil \log_2 A\rceil + 1$ if single-point redundancy is demanded. This ties the two layers together
quantitatively and is the first thing to test.

### 9.3 Falsifiable predictions

The theory makes several predictions that a width-swept, learner-fixed design can
check directly:

**P1.** No flip effect at any width $k \ge 3$, for any learner (Theorem 3.6 with
$\mathrm{thr} \le a$; more precisely, a flip effect at $k \ge 3$ requires
$\mathrm{thr} > (k-2)a$, i.e. residual demand exceeding $k-2$ coordinates).

**P2.** At $k = 2$, flip and whole-block readings agree arm by arm, with no false
positives or negatives (Theorem 3.5).

**P3.** The dependent set is identical at every width at which the learners cure
(Corollary 4.5).

**P4.** Retention profiles never cross: two learners agreeing at one width agree
at all widths (Theorem 7.3).

**P5.** Retention decays harmonically, $k\rho(k) \to b/g$; in particular
$\rho(k)$ must not fall off geometrically (Theorem 4.9, Corollary 4.10).

**P6.** No staircase violations: a flip hit without a whole-block hit is
impossible (Theorem 3.8).

**P7.** Under the refined resolution condition of §9.2, the width at which a
learner first cures should track $\log_2$ of the answer-range size, not the
learner's drive parameters.

### 9.4 Design consequences

Three practical statements follow.

1. **Width buys success, not independence.** Increasing $k$ monotonically
   improves the chance that a learner cures (Theorem 4.3) and *strictly worsens*
   the retention of a dependent learner (Theorem 4.8). Widening the boundary
   block is therefore the right lever for reliability and the wrong lever for
   internalization.
2. **Redundancy has an explicit budget.** Single-point robustness holds up to the
   margin $A \le 2^{k-1}$ at the capacity layer and $\mathrm{thr} \le (k-1)a$ at
   the gate layer, and fails outside them (Theorem 6.8). "At least three
   exclusive dimensions" is a rule with a side condition.
3. **Verify per instance, at a curing width.** Because the trait is invisible
   below the curing width (Section 5) and no cheap proxy exists, the only sound
   procedure is to run the whole-block ablation at a width where the learner is
   already correct, and to keep re-serving the boundary marker for learners that
   read as dependent.

---

## 10. Future work

**A two-parameter rigidity programme.** Conjecture: for every learner there are
width-independent reals $(b, g, d)$ and an integer $\mathrm{sep}$ such that the
learner cures at width $k$ iff $\mathrm{sep} \le k$ and $d \le b + kg$, and is
boundary-dependent at every curing width iff $b < d$. The two apparently
paradoxical observations — a width-invariant dependent set and no width-one
predictor — are then jointly forced (Theorems 4.4 and 5.2). A learner-fixed,
width-swept design identifies $\mathrm{sep}$ from the smallest curing width and
$g/b$ from a single retention reading, after which every other width is
predicted with no free parameters (Theorem 7.3).

**Sign sensitivity at $k = 4, 5$.** The theory forbids any flip effect at
$k \ge 3$ for balanced blocks and predicts exact agreement between flip and
whole-block readings at $k = 2$. Extending the width sweep is the cleanest
available test, and a flip effect at $k \ge 3$ would immediately imply a dominant
coordinate (§9.2).

**Coupling the layers.** Replace the integer $\mathrm{sep}$ by the capacity
condition $A \le \prod_i m_i$ of Section 6, obtaining a single model in which
resolution and drive are both derived from the block, and test the resulting
prediction $\mathrm{sep} \approx \lceil \log_2 A \rceil$.

**Non-uniform and non-linear gates.** Extend Theorems 3.3–3.8 to arbitrary
blocks (partly immediate from Lemma 2.5) and to monotone non-linear readouts,
where the severity staircase should survive but the exact $k-2$ numerology should
not.

**Why dependence grows.** Theorem 4.8 derives deepening from a *constant*
per-dimension gain $g$. It is worth asking whether the observed deepening is
better fitted by a gain that itself grows with $k$ — which would predict
faster-than-harmonic decay and, by Corollary 4.10, refute pure additivity.

---

## 11. Conclusion

A single comparison, $b < d$, in which the width does not appear, explains why a
learner's dependence on a boundary marker is a trait of the learner rather than
of the marker's width; a single monotone pair of conditions,
$\mathrm{sep} \le k$ and $d \le b + kg$, explains why width nonetheless governs
whether the learner succeeds; the gap between the exponents $k-1$ and $k-2$
explains why the most striking diagnostic in the data — sign sensitivity — is an
accident of width two; the Chinese Remainder Theorem explains why a block of
exclusive dimensions can carry an answer at all, and why single-point damage to
it is free; and two negative results — that sign flips are free at the capacity
layer, and that single-point redundancy fails outside an explicit margin — keep
the two layers honest about their respective jurisdictions.

The methodological moral generalises past the specific setting. When a
diagnostic is cheap, it is worth knowing at which widths it is *exact*, at which
it is *uninformative*, and at which it is *impossible* — and those three
questions can have completely elementary answers.
