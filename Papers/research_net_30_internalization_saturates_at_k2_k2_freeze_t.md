# Internalization Saturates at Two: A Convexity Theory of Exclusive-Channel Ablations

**Author:** Aristotle

**Date:** 2026-08-16

---

## Abstract

A trained sequential model may allocate a small block of $k$ *exclusive*
coordinates to a single functional pathway — here, the end-of-sequence boundary
signal. Ablation experiments on such a block routinely produce a puzzling
signature: every single-coordinate ablation is a no-op, while the whole-block
ablation is catastrophic, and a mere sign flip of one coordinate is as
catastrophic as the block ablation. We give a complete structural account of this
"1-redundant but block-dependent" signature.

Four results organize the account. **(i) A counting theorem**: for *any*
statistic whatsoever, the signature forces $k \ge 2$, because at $k = 1$ the
single-coordinate and whole-block ablations are literally the same map. The
phenomenon is therefore invisible at unit width for structural, not empirical,
reasons — the "missing middle". **(ii) A convexity dichotomy**: modelling the
read-out along the block ray as $\varphi(\sum_i s_i)$ for an arbitrary scalar
nonlinearity $\varphi$, the whole-block drop $D$ and the single drops $d_i$
satisfy $D \le \sum_i d_i$ when $\varphi$ is convex and $\sum_i d_i \le D$ when
$\varphi$ is concave, with equality iff $\varphi$ is affine along the ray. The
*redundancy defect* $R = \sum_i d_i - D$ is thus a directly measurable curvature
certificate; a measured $R < 0$ rules out every convex — a fortiori every affine
— read-out. **(iii) A saturation law**: under a concave read-out,
$d_i \le (s_i/S)\,D$, so with an equal split over $k$ coordinates every single
ablation costs at most $D/k$ while the block drop is unchanged. Apparent
"internalization" scaling like $1/k$ is forced by concavity alone and is not
evidence about what the network learned. **(iv) A derived design rule**: for the
canonical rectified-and-clipped channel with $k$ coordinates of equal gain $g$
and clip level $1$, single ablations are no-ops iff $(k-1)g \ge 1$ and sign flips
are no-ops iff $(k-2)g \ge 1$; at unit gain this is exactly "$\ge 2$ exclusive
dimensions for self-sufficiency, $\ge 3$ for sign robustness".

We complement the no-go results with an explicit four-group item population and a
two-dimensional coefficient vector that reproduces all six measured accuracies of
the paradigmatic arm to within $0.005$, and we prove that the $k = 1$ regime is
*entirely unconstrained*: every admissible control/ablation accuracy pair
$0 \le \beta \le \alpha \le 1$ is realized. This last fact retro-diagnoses the
failure of a previously reported proportionality law between "internalization"
and recovery quality: it was inferred from a family of observations that
constrains no model in the class.

**Keywords:** ablation, redundancy, concavity, saturating gate, chord
inequality, exclusive channel, redundancy defect, design threshold.

---

## 1. Introduction

### 1.1 The empirical setting

A recurrent cell is trained on a task with an explicit end-of-sequence boundary.
After training, one identifies the set of hidden coordinates written into
*exclusively* by the boundary pathway; call these the **exclusive coordinates**
and let $k = |{\cdot}|$ be their number, controlled at training time by an
architectural width parameter. The trained coefficients on those coordinates form
a vector $c \in \mathbb{R}^k$.

Interventions are applied at inference time only — the trained parameters are
edited in place and the model is re-evaluated on fresh draws. Five interventions
suffice for the present analysis:

$$
\begin{aligned}
\mathrm{ctl}(c) &= c, \\
\mathrm{zero}_{\mathrm{all}}(c) &= 0, \\
\mathrm{zero}_i(c) &= c \text{ with the } i\text{-th entry replaced by } 0, \\
\mathrm{flip}_i(c) &= c \text{ with the } i\text{-th entry replaced by } -c_i, \\
\mathrm{scale}_\lambda(c) &= \lambda c .
\end{aligned}
$$

Each intervention is scored by an evaluation statistic — in practice, sequence
accuracy on a fresh draw. The observation to be explained is the following arm at
$k = 2$:

| intervention | $\mathrm{ctl}$ | $\mathrm{zero}_0$ | $\mathrm{zero}_1$ | $\mathrm{zero}_{\mathrm{all}}$ | $\mathrm{flip}_0$ | $\mathrm{scale}_{0.1}$ |
|---|---|---|---|---|---|---|
| accuracy | $0.9980$ | $0.9961$ | $0.9990$ | $0.7544$ | $0.7505$ | $0.9067$ |

The single-coordinate drops are $+0.0019$ and $-0.0010$, both inside the reported
no-op band $|\Delta| \le 0.002$; the block drop is $D = 0.2436$; the flip drop is
$0.2475$; the $\times 0.1$ rescaling drop is $0.0913$.

Across a $6$-seed replication at $k=2$, five of six arms are **self-sufficient**:
the whole-block drop is at most $0.010$, and the two largest changes are
*positive* — removal *helps* an imperfect arm rather than breaking it. Only the
arm tabulated above is block-dependent. Across a $6$-seed replication at $k = 1$,
the ablation of the sole coordinate is a no-op in every arm where the model had
already failed, and behaves heterogeneously across the arms where it succeeded
(two exact self-sufficient cures, two marginal $\approx 2$ SE losses).

### 1.2 Contributions

The purpose of this paper is to isolate what is *structurally forced* in these
tables from what is genuinely a statement about learned representations. We show
that nearly all of it is forced.

1. **§2 — The missing middle.** A model-free theorem: the "1-redundant,
   block-dependent" signature entails $k \ge 2$ for any statistic. In particular
   the $k=1$ experiments cannot, even in principle, exhibit it.
2. **§3 — The affine intervention algebra and its no-go.** In an affine read-out,
   the block drop is the sum of the single drops, the flip drop is exactly twice
   the ablation drop, and the scale curve is a straight line. All three laws are
   violated by the measured arm; the ablation form requires $k \ge 122$, and the
   sign form is impossible at *every* $k$.
3. **§4 — The convexity dichotomy.** A chord inequality yields
   $D \le \sum_i d_i$ (convex) and $\sum_i d_i \le D$ (concave). The redundancy
   defect $R = \sum_i d_i - D$ therefore has the sign of the curvature. The
   measured arm certifies $R \le -0.2396$, hence strict non-convexity.
4. **§5 — The saturation law.** Under concavity, $d_i \le (s_i/S)D$; with equal
   shares, $d_i \le D/k$. Apparent single-coordinate self-sufficiency scaling
   like $1/k$ requires no learning hypothesis.
5. **§6 — A realizing population model.** An explicit four-group item population
   and $c = (1,1)$ reproduce all six measured accuracies within $0.005$, and the
   monotonicity of the scale curve is a theorem of the model, matched by the data.
6. **§7 — The design rule, derived.** For the canonical clipped channel:
   self-sufficiency iff $(k-1)g \ge 1$; sign robustness iff $(k-2)g \ge 1$; at
   unit gain, $k \ge 2$ and $k \ge 3$ respectively.
7. **§8 — Why $k=1$ constrains nothing.** Every admissible pair
   $0 \le \beta \le \alpha \le 1$ is realized in the model class, and a universal
   no-op is exactly the signature of a channel that was never used. This
   diagnoses the non-replication of a previously reported proportionality law.
8. **§9–§11** collect the algorithmic content, the falsifiable prediction the
   model gets wrong, and future directions.

---

## 2. The missing middle: a counting theorem

The first result is deliberately structural. It assumes nothing about the model,
the statistic, or the evaluation distribution.

**Definition 2.1 (interventions).** For $c \in \mathbb{R}^k$ and $i \in \{0,\dots,k-1\}$,
$\mathrm{zero}_i(c)$ is $c$ with entry $i$ set to $0$; $\mathrm{zero}_{\mathrm{all}}(c)$ is
the zero vector; $\mathrm{flip}_i(c)$ is $c$ with entry $i$ negated;
$\mathrm{scale}_\lambda(c) = \lambda c$.

**Lemma 2.2 (the $k=1$ collapse).** For $k = 1$ and every $c \in \mathbb{R}^1$
and the unique index $i$, $\mathrm{zero}_i(c) = \mathrm{zero}_{\mathrm{all}}(c)$ as vectors.

*Proof.* Both maps send the unique coordinate to $0$; the index set is a
singleton, so there is no other coordinate on which they could differ. $\square$

**Lemma 2.3.** For $k = 0$, $\mathrm{zero}_{\mathrm{all}}$ is the identity map on
$\mathbb{R}^0$. $\square$

**Theorem 2.4 (the missing middle, model-free form).** Let $\alpha$ be an
arbitrary set and $F : \mathbb{R}^k \to \alpha$ an arbitrary function — no
continuity, monotonicity, linearity or measurability is assumed. Fix
$c \in \mathbb{R}^k$ and suppose

- (*redundancy*) $F(\mathrm{zero}_i(c)) = F(c)$ for every $i$, and
- (*block dependence*) $F(\mathrm{zero}_{\mathrm{all}}(c)) \ne F(c)$.

Then $k \ge 2$.

*Proof.* If $k = 0$, Lemma 2.3 gives
$F(\mathrm{zero}_{\mathrm{all}}(c)) = F(c)$, contradicting block dependence. If $k = 1$,
Lemma 2.2 with $i = 0$ gives
$F(\mathrm{zero}_{\mathrm{all}}(c)) = F(\mathrm{zero}_0(c)) = F(c)$, again a
contradiction. Hence $k \ge 2$. $\square$

**Corollary 2.5 (contrapositive).** If $k \le 1$, single-coordinate redundancy
already *implies* whole-block self-sufficiency, for any statistic $F$. $\square$

**Discussion.** Corollary 2.5 is the interpretive key to the $k = 1$ tables. At
one exclusive coordinate there is nothing for the coordinate to be redundant
*with*: the two interventions are the same experiment run twice. Any narrative
that reads $k = 1$ ablation results as measuring "how internalized" the channel
is, is reading a distinction the design cannot express. The empirical middle of
the width gradient begins at $k = 2$, which is precisely why $k = 2$ turns out
not to be intermediate between $k=1$ and $k=3$ but to behave like $k=3$: the
qualitative transition happens *at* two, not after it.

---

## 3. The affine intervention algebra, and a two-sided no-go

We now add the minimal amount of structure: a linear read-out.

**Definition 3.1 (affine boundary margin).** Given a baseline $b \in \mathbb{R}$
and read-out weights $g \in \mathbb{R}^k$, the *margin* of a coefficient vector
$c$ is
$$ M_{b,g}(c) \;=\; b + \sum_{i} g_i c_i . $$

**Definition 3.2 (drops).** $\;D^{\mathrm{all}} = M(c) - M(\mathrm{zero}_{\mathrm{all}}(c))$,
$\;D_i = M(c) - M(\mathrm{zero}_i(c))$,
$\;D^{\mathrm{flip}}_i = M(c) - M(\mathrm{flip}_i(c))$,
$\;D^{\mathrm{scale}}_\lambda = M(c) - M(\mathrm{scale}_\lambda(c))$.

**Proposition 3.3 (the algebra).** In the affine model,
$$
D_i = g_i c_i, \qquad
D^{\mathrm{all}} = \sum_i g_i c_i = \sum_i D_i, \qquad
D^{\mathrm{flip}}_i = 2 D_i, \qquad
D^{\mathrm{scale}}_\lambda = (1-\lambda)\,D^{\mathrm{all}} .
$$

*Proof.* Direct computation. Setting coordinate $i$ to zero deletes exactly the
term $g_i c_i$ from the sum, giving $D_i = g_i c_i$; zeroing all coordinates
deletes the whole sum. Negating coordinate $i$ changes $g_i c_i$ to $-g_i c_i$,
a change of $2 g_i c_i$. Scaling by $\lambda$ multiplies the whole sum by
$\lambda$, so the drop is $(1-\lambda)\sum_i g_i c_i$. $\square$

Three qualitative laws follow: **additivity** of ablations, a universal **factor
of two** for sign flips, and a **straight** scale curve. Each is testable.

**Theorem 3.4 (affine saturation bound).** If $|D_i| \le \varepsilon$ for every
$i$, then $|D^{\mathrm{all}}| \le k\varepsilon$.

*Proof.* $|D^{\mathrm{all}}| = |\sum_i D_i| \le \sum_i |D_i| \le k\varepsilon$
by the triangle inequality. $\square$

**Corollary 3.5 (dimension certificate).** If $\varepsilon > 0$,
$|D_i| \le \varepsilon$ for all $i$, and the observed block drop satisfies
$D \le |D^{\mathrm{all}}|$, then $k \ge D/\varepsilon$. $\square$

**Theorem 3.6 (no-go, ablation form).** There exist no $b \in \mathbb{R}$ and
$g, c \in \mathbb{R}^2$ with $|D_i| \le 0.002$ for $i = 0,1$ and
$D^{\mathrm{all}} = 0.2436$.

*Proof.* Theorem 3.4 with $k=2$, $\varepsilon = 0.002$ caps $|D^{\mathrm{all}}|$
at $0.004 < 0.2436$. $\square$

By Corollary 3.5, an affine read-out reproducing the measured arm would require
$k \ge 0.2436/0.002 = 121.8$, i.e. at least $122$ exclusive dimensions, against a
measured $k = 2$.

**Theorem 3.7 (no-go, sign form; width-free).** There exist no $b, g, c$ at *any*
width $k$ with $|D_i| \le 0.002$ and $D^{\mathrm{flip}}_i = 0.2475$ for the same
index $i$.

*Proof.* By Proposition 3.3, $D^{\mathrm{flip}}_i = 2D_i$, so
$|D_i| = 0.2475/2 = 0.12375 > 0.002$. $\square$

Theorem 3.7 is the stronger statement: sign-sensitivity in the absence of
ablation-sensitivity is affinely impossible regardless of how many coordinates
are available. Any affine story is finished; the read-out is nonlinear.

**A positive complement.** The no-go concerns the one dependent arm. The five
self-sufficient arms admit an affine explanation, and it is instructive.

**Theorem 3.8 (redundancy upgrade).** Fix $k \ge 1$, a threshold $\theta$, and
suppose (i) every single-coordinate ablation keeps the margin above threshold,
$\theta \le M(\mathrm{zero}_i(c))$ for all $i$, and (ii) the block's net
contribution is nonpositive, $\sum_i g_i c_i \le 0$. Then
$\theta \le M(\mathrm{zero}_{\mathrm{all}}(c))$.

*Proof.* Writing $\Sigma = \sum_j g_j c_j$, hypothesis (i) says
$\theta \le b + \Sigma - g_i c_i$ for each $i$. Summing over $i$ gives
$k\theta \le k(b+\Sigma) - \Sigma$, i.e.
$k\theta \le kb + (k-1)\Sigma$. Since $k \ge 1$ and $\Sigma \le 0$, the term
$(k-1)\Sigma \le 0$, so $k\theta \le kb$ and $\theta \le b = M(\mathrm{zero}_{\mathrm{all}}(c))$.
$\square$

This is exactly the observed profile of the imperfect but self-sufficient arm
whose block ablation *raises* accuracy from $0.9399$ to $0.9453$: a nonpositive
net block contribution converts single-coordinate redundancy into whole-block
self-sufficiency, deterministically.

---

## 4. The convexity dichotomy

The affine model has been refuted, but only in one direction. We now determine
exactly which nonlinearities can produce the signature.

**Setting 4.1.** Model the boundary read-out along the block ray by
$$ c \;\longmapsto\; \varphi\Bigl(\sum_i s_i\Bigr), $$
where $s_i \ge 0$ is the *gain* contributed by exclusive coordinate $i$ and
$\varphi : \mathbb{R} \to \mathbb{R}$ is an arbitrary scalar nonlinearity — the
trained cell's gate. Write
$$ S = \sum_i s_i > 0, \qquad D = \varphi(S) - \varphi(0), \qquad d_i = \varphi(S) - \varphi(S - s_i). $$

$D$ is the whole-block drop; $d_i$ is the drop caused by removing coordinate $i$
alone. Note $s_i \le S$ automatically since the $s_j$ are nonnegative.

**Lemma 4.2 (chord inequality, convex case).** Let $\varphi$ be convex on
$\mathbb{R}$, let $S > 0$ and $0 \le a \le S$. Then
$$ a\bigl(\varphi(S) - \varphi(0)\bigr) \;\le\; S\bigl(\varphi(S) - \varphi(S-a)\bigr). $$

*Proof.* Write $S - a$ as the convex combination
$\tfrac{a}{S}\cdot 0 + \tfrac{S-a}{S}\cdot S$, whose weights are nonnegative and
sum to $1$. Convexity gives
$$ \varphi(S-a) \;\le\; \tfrac{a}{S}\varphi(0) + \tfrac{S-a}{S}\varphi(S). $$
Multiplying by $S > 0$ yields $S\varphi(S-a) \le a\varphi(0) + (S-a)\varphi(S)$,
and rearranging,
$S\varphi(S) - S\varphi(S-a) \ge S\varphi(S) - a\varphi(0) - (S-a)\varphi(S)
= a\varphi(S) - a\varphi(0)$, which is the claim. $\square$

Geometrically: for a convex curve, the chord over the final stretch $[S-a, S]$ is
at least as steep as the chord over the whole of $[0,S]$.

**Lemma 4.3 (chord inequality, concave case).** If $\varphi$ is concave on
$\mathbb{R}$, $S > 0$ and $0 \le a \le S$, then
$$ S\bigl(\varphi(S) - \varphi(S-a)\bigr) \;\le\; a\bigl(\varphi(S) - \varphi(0)\bigr). $$

*Proof.* Apply Lemma 4.2 to the convex function $-\varphi$ and negate. $\square$

**Theorem 4.4 (convex read-outs cannot hide the block).** If $\varphi$ is convex,
$s_i \ge 0$ and $S > 0$, then
$$ D \;\le\; \sum_{i=1}^{k} d_i. $$

*Proof.* Apply Lemma 4.2 with $a = s_i$ for each $i$ (legitimate since
$0 \le s_i \le S$) and sum:
$$ \Bigl(\sum_i s_i\Bigr)\bigl(\varphi(S) - \varphi(0)\bigr) \;\le\; S \sum_i \bigl(\varphi(S) - \varphi(S - s_i)\bigr), $$
i.e. $S \cdot D \le S \sum_i d_i$. Divide by $S > 0$. $\square$

**Theorem 4.5 (concave read-outs can hide the block).** If $\varphi$ is concave,
$s_i \ge 0$ and $S > 0$, then
$$ \sum_{i=1}^{k} d_i \;\le\; D, $$
and the gap can be arbitrarily large.

*Proof.* Identical, using Lemma 4.3. For the gap: take $\varphi = \min(x,1)$,
$k = 2$, $s_1 = s_2 = 1$. Then $S = 2$, $D = 1$, and
$d_i = \varphi(2) - \varphi(1) = 0$, so $\sum_i d_i = 0$ while $D = 1$. Scaling
$\varphi$ by any $c > 0$ scales the gap. $\square$

**Corollary 4.6 (affine equality).** If $\varphi$ is affine, both inequalities
hold, so $D = \sum_i d_i$ — recovering Proposition 3.3. $\square$

**Corollary 4.7 (convex saturation bound).** If $\varphi$ is convex and
$d_i \le \varepsilon$ for every $i$, then $D \le k\varepsilon$. $\square$

### 4.1 The redundancy defect as a curvature observable

**Definition 4.8 (redundancy defect).**
$$ R \;=\; \Bigl(\sum_{i} d_i\Bigr) - D . $$

**Theorem 4.9 (sign of the defect).** Under Setting 4.1 with $s_i \ge 0$ and
$S > 0$: $\varphi$ convex $\Rightarrow R \ge 0$; $\varphi$ affine
$\Rightarrow R = 0$; $\varphi$ concave $\Rightarrow R \le 0$. $\square$

$R$ is computable from three experimental quantities alone: the control accuracy,
the $k$ single-ablation accuracies, and the block-ablation accuracy. It requires
no access to weights, no assumption about the gate, and no fitting.

**Theorem 4.10 (the measured arm is a strict-concavity certificate).** Suppose a
$k=2$ read-out satisfies $d_i \le 0.002$ for $i = 0,1$ and $D = 0.2436$. Then
$$ R \;\le\; 2(0.002) - 0.2436 \;=\; -0.2396 \;<\; 0, $$
and consequently $\varphi$ is **not convex** — a fortiori not affine.

*Proof.* The bound on $R$ is immediate. Non-convexity follows from Theorem 4.9,
since convexity would force $R \ge 0$. $\square$

**Theorem 4.11 (no convex read-out at $k=2$).** There is no convex $\varphi$ and
nonnegative $s \in \mathbb{R}^2$ with $S > 0$, $d_i \le 0.002$ for both $i$, and
$D = 0.2436$.

*Proof.* Corollary 4.7 gives $D \le 2(0.002) = 0.004$. $\square$

This strengthens Theorem 3.6 from "not affine" to "not convex": the boundary
read-out is genuinely **saturating**.

---

## 5. The saturation law: concavity manufactures redundancy at rate $1/k$

The concave half of the dichotomy has a sharper, quantitative form which is, we
argue, the correct null hypothesis for width-dependent ablation studies.

**Theorem 5.1 (share bound).** If $\varphi$ is concave, $s_i \ge 0$ and $S > 0$,
then for every $i$
$$ d_i \;\le\; \frac{s_i}{S}\, D . $$

*Proof.* Lemma 4.3 with $a = s_i$ gives $S d_i \le s_i D$; divide by $S > 0$.
$\square$

**Theorem 5.2 (equal shares: the $1/k$ law).** Let $k \ge 1$, $S > 0$, and let the
block gain be split equally, $s_j = S/k$ for all $j$. If $\varphi$ is concave,
then for every $i$
$$ d_i \;\le\; \frac{D}{k}, \qquad \text{while the block drop is exactly } D. $$

*Proof.* $\sum_j s_j = k \cdot (S/k) = S$, so Theorem 5.1 applies with
$s_i / S = 1/k$. $\square$

**Interpretation.** Theorem 5.2 is a *null model* for a widely-drawn inference.
The measured self-sufficiency rate rises with width — roughly one half of the
successful arms at $k=1$, five of six at $k=2$, five of six at $k=3$. It is
tempting to read this as the network learning increasingly distributed,
increasingly "internalized" boundary representations as more capacity is
provided. Theorem 5.2 says the same trend is produced, at exactly rate $1/k$, by
a saturating gate that learns nothing at all. Any claim that widening a channel
made a representation more robust must therefore be measured *against* the $1/k$
baseline, not against zero.

More pointedly: because the block drop $D$ is *unchanged* by the split, the very
same model that makes each single ablation look harmless keeps the block
maximally indispensable. Local dispensability and global indispensability are not
in tension under concavity — they are the generic situation.

---

## 6. An explicit realization

Negative results constrain; a construction certifies. We exhibit a model in which
the entire measured arm occurs.

**Definition 6.1 (item population).** An *item population* $P$ consists of a
finite number $n$ of item groups, nonnegative masses $m_1,\dots,m_n$ with
$\sum_i m_i = 1$, and difficulty thresholds $t_1,\dots,t_n \in \mathbb{R}$. A
group is answered correctly exactly when the boundary gate value reaches its
threshold, so the accuracy at gate value $\gamma$ is
$$ \mathrm{acc}_P(\gamma) \;=\; \sum_{i \,:\, t_i \le \gamma} m_i . $$

**Lemma 6.2 (monotonicity).** $\gamma \le \delta \implies \mathrm{acc}_P(\gamma) \le \mathrm{acc}_P(\delta)$.

*Proof.* Termwise: if $t_i \le \gamma$ then $t_i \le \delta$, so every term that
contributes at $\gamma$ contributes at $\delta$; the remaining terms are
nonnegative. $\square$

**Definition 6.3 (saturating boundary gate).**
$$ \Gamma(c) \;=\; \min\Bigl(\max\Bigl(\sum_i c_i,\; 0\Bigr),\; 1\Bigr). $$
Rectification makes $\Gamma$ sign-sensitive; the clip at $1$ makes it redundant.
Its clipped part $x \mapsto \min(x,1)$ is concave, which is what triggers §4–§5.

**Lemma 6.4 (monotone scale curve).** If $\sum_i c_i \ge 0$ and
$\lambda \le \lambda'$, then $\Gamma(\lambda c) \le \Gamma(\lambda' c)$, and
hence $\mathrm{acc}_P(\Gamma(\lambda c)) \le \mathrm{acc}_P(\Gamma(\lambda' c))$.

*Proof.* $\sum_i \lambda c_i = \lambda \sum_i c_i \le \lambda' \sum_i c_i$;
$\max(\cdot,0)$ and $\min(\cdot,1)$ are monotone; apply Lemma 6.2. $\square$

**Corollary 6.5.** The measured ordering
$\mathrm{zero}_{\mathrm{all}} \le \mathrm{scale}_\lambda \le \mathrm{ctl}$ for
$0 \le \lambda \le 1$ is a theorem of the model. The data obey it:
$0.7544 \le 0.9067 \le 0.9980$. $\square$

**The realizing population.** Let $P^\star$ have $n = 4$ groups with

| group | mass | threshold |
|---|---|---|
| $1$ | $0.7544$ | $0$ |
| $2$ | $0.1523$ | $0.2$ |
| $3$ | $0.0913$ | $0.5$ |
| $4$ | $0.0020$ | $2$ |

(the masses sum to $1$), and take $k = 2$ exclusive coordinates with
$c^\star = (1,1)$.

**Theorem 6.6 (the arm, realized).** With $P^\star$ and $c^\star$:

$$
\begin{array}{lccc}
\text{intervention} & \text{gate } \Gamma & \text{model accuracy} & \text{measured} \\ \hline
\mathrm{ctl} & \min(2,1)=1 & 0.9980 & 0.9980 \\
\mathrm{zero}_0 & \min(1,1)=1 & 0.9980 & 0.9961 \\
\mathrm{zero}_1 & \min(1,1)=1 & 0.9980 & 0.9990 \\
\mathrm{zero}_{\mathrm{all}} & 0 & 0.7544 & 0.7544 \\
\mathrm{flip}_0 & \max(-1+1,0)=0 & 0.7544 & 0.7505 \\
\mathrm{scale}_{0.1} & \min(0.2,1)=0.2 & 0.9067 & 0.9067
\end{array}
$$

Every entry matches the measurement to within $0.005$, the reported no-op scale.

*Proof.* The gate values are the displayed arithmetic. The accuracies follow from
$\mathrm{acc}_{P^\star}(0) = 0.7544$ (only group $1$),
$\mathrm{acc}_{P^\star}(0.2) = 0.7544 + 0.1523 = 0.9067$ (groups $1,2$), and
$\mathrm{acc}_{P^\star}(1) = 0.7544 + 0.1523 + 0.0913 = 0.9980$ (groups $1,2,3$;
group $4$ needs $\gamma \ge 2$ and is never solved). The six residuals are
$0$, $0.0019$, $0.0010$, $0$, $0.0039$, $0$. $\square$

**Theorem 6.7 (the realization has the signature).** For $P^\star, c^\star$:
$\mathrm{acc}(\Gamma(\mathrm{zero}_i(c^\star))) = \mathrm{acc}(\Gamma(c^\star))$
for both $i$ (exact no-ops), while
$\mathrm{acc}(\Gamma(c^\star)) - \mathrm{acc}(\Gamma(\mathrm{zero}_{\mathrm{all}}(c^\star))) = 0.2436$. $\square$

**Theorem 6.8 (the missing middle, sharp).** Within the saturating-gate
population class, the signature "every single-coordinate ablation is a no-op and
the whole-block ablation is not" **is realized at $k = 2$** (Theorem 6.7) and
**is impossible at $k \le 1$** (Corollary 2.5 applied to
$F = \mathrm{acc}_P \circ \Gamma$). $\square$

The model therefore explains, rather than fits, the three qualitative facts: the
ablations are no-ops *because the gate remains saturated at $1$ after removing one
of two unit coordinates*; the flip is not, *because it subtracts twice a
coordinate*; and the $\times 0.1$ rescaling is not, *because it drops the gate
below every nonzero threshold except the lowest*.

---

## 7. The design rule, derived

We now show that the empirical width ladder is forced arithmetic once the channel
is canonical.

**Definition 7.1 (canonical channel).** Fix $k \ge 1$ and $g \ge 0$, and let
$u_{k,g} \in \mathbb{R}^k$ be the uniform coefficient vector $u_{k,g;i} = g$.

**Lemma 7.2 (gate table).** For $g \ge 0$:
$$
\Gamma(u_{k,g}) = \min(kg, 1), \qquad
\Gamma(\mathrm{zero}_i(u_{k,g})) = \min((k-1)g, 1) \;\; (k \ge 1), \qquad
\Gamma(\mathrm{flip}_i(u_{k,g})) = \min((k-2)g, 1) \;\; (k \ge 2),
$$
and $\Gamma(\mathrm{zero}_{\mathrm{all}}(u_{k,g})) = 0$.

*Proof.* The coordinate sums are $kg$, $kg - g = (k-1)g$, and $kg - 2g = (k-2)g$
respectively; all are nonnegative under the stated hypotheses, so the
rectification is inactive and only the clip remains. $\square$

The flip line is the crux: negating a coordinate changes it from $+g$ to $-g$, a
change of $2g$, so *a sign flip always costs one coordinate more than an
ablation*.

**Theorem 7.3 (self-sufficiency threshold).** Let $g \ge 0$, $k \ge 1$, and
suppose the channel is saturated, $kg \ge 1$. Then for any $i$,
$$ \Gamma(\mathrm{zero}_i(u_{k,g})) = \Gamma(u_{k,g}) \iff (k-1)g \ge 1. $$

*Proof.* By saturation, $\Gamma(u_{k,g}) = 1$. By Lemma 7.2 the left side is
$\min((k-1)g,1)$, which equals $1$ iff $(k-1)g \ge 1$. $\square$

**Theorem 7.4 (sign-robustness threshold).** Let $g \ge 0$, $k \ge 2$,
$kg \ge 1$. Then
$$ \Gamma(\mathrm{flip}_i(u_{k,g})) = \Gamma(u_{k,g}) \iff (k-2)g \ge 1. \qquad \square $$

**Corollary 7.5 (unit-gain design rule).** At $g = 1$:
$$ \text{single ablations are no-ops} \iff k \ge 2, \qquad
\text{sign flips are no-ops} \iff k \ge 3, $$
and the whole block is never dispensable. $\square$

**Theorem 7.6 (the measured ladder in one statement).** For the unit-gain
canonical channel:

- $k = 1$: $\Gamma(\mathrm{zero}_0(u_{1,1})) = 0$ while $\Gamma(u_{1,1}) = 1$ — the sole ablation destroys the channel;
- $k = 2$: $\Gamma(\mathrm{zero}_0(u_{2,1})) = \Gamma(u_{2,1}) = 1$ but $\Gamma(\mathrm{flip}_0(u_{2,1})) = 0$ — ablations are no-ops, the flip is not;
- $k = 3$: both $\Gamma(\mathrm{zero}_0(u_{3,1}))$ and $\Gamma(\mathrm{flip}_0(u_{3,1}))$ equal $\Gamma(u_{3,1})$ — both are no-ops. $\square$

These three lines are the three measured widths. At $k=1$ the ablation *is* the
block ablation (Lemma 2.2) and no redundancy exists. At $k = 2$ the ablations are
no-ops but the flip costs $0.9980 \to 0.7505$. At $k = 3$ both are no-ops, which
is the earlier round's report that "signs never matter". Corollary 7.5 shows this
report must be qualified: **sign-sensitivity is width-conditional**, and the
critical width for it is exactly one above the critical width for
ablation-sensitivity.

The practical statement — *at least two exclusive dimensions for a
self-sufficient recovery, at least three for a sign-robust one* — was previously
an empirical fit across widths. It is now a corollary of a clipped sum. Note also
the separation of concerns this forces: the observed ramp in *training-time*
success probability with width (peaking around $k = 3$) is a distinct effect from
*evaluation-time* sufficiency, which is bought already at $k = 2$.

---

## 8. Why the $k=1$ data constrain nothing

Two results explain the non-replication of the previously reported
"internalization $\propto$ cure quality" law.

**Theorem 8.1 (boundary-free arms are intervention-proof).** Let $P$ be an item
population, $c$ a coefficient vector, and suppose the arm is *boundary-free*:
$$ \mathrm{acc}_P(0) = \mathrm{acc}_P(\Gamma(c)). $$
Then for every $\gamma$ with $0 \le \gamma \le \Gamma(c)$,
$\mathrm{acc}_P(\gamma) = \mathrm{acc}_P(\Gamma(c))$. Conversely, if every such
$\gamma$ gives a no-op, then the arm is boundary-free.

*Proof.* ($\Rightarrow$) Monotonicity gives
$\mathrm{acc}_P(\gamma) \le \mathrm{acc}_P(\Gamma(c))$ and
$\mathrm{acc}_P(\Gamma(c)) = \mathrm{acc}_P(0) \le \mathrm{acc}_P(\gamma)$.
($\Leftarrow$) Take $\gamma = 0$, legitimate since $\Gamma(c) \ge 0$. $\square$

**Corollary 8.2.** At a boundary-free arm with nonnegative coefficients, the
whole-block ablation and every single-coordinate ablation are exact no-ops
(the ablated gate lies in $[0, \Gamma(c)]$). $\square$

**Interpretation.** Pooled across two rounds and twelve $k=1$ arms, removal of the
sole exclusive coordinate is a no-op in *every* arm where the model had already
failed. Theorem 8.1 shows this is not a discovery about internalization; it is
the defining symptom of a channel that was **never read**. An arm whose correct
items do not depend on the boundary signal is by construction immune to every
weakening of it. A universal no-op is evidence of an unused wire, not an absorbed
one.

**Theorem 8.3 ($k=1$ profiles are unconstrained).** For every pair
$0 \le \beta \le \alpha \le 1$ there exist an item population $P$ and a
coefficient $c \in \mathbb{R}^1$ with
$$ \mathrm{acc}_P(\Gamma(c)) = \alpha, \qquad \mathrm{acc}_P(\Gamma(\mathrm{zero}_{\mathrm{all}}(c))) = \beta, $$
and hence also $\mathrm{acc}_P(\Gamma(\mathrm{zero}_0(c))) = \beta$.

*Proof.* Take $c = (1)$, so $\Gamma(c) = 1$ and $\Gamma(\mathrm{zero}_{\mathrm{all}}(c)) = 0$.
Let $P$ have three groups with masses $\beta$, $\alpha - \beta$, $1-\alpha$ (all
nonnegative and summing to $1$) at thresholds $0$, $1$, $2$. Then
$\mathrm{acc}_P(0) = \beta$ and $\mathrm{acc}_P(1) = \beta + (\alpha-\beta) = \alpha$.
The last claim is Lemma 2.2. $\square$

**Consequence.** The full observed heterogeneity of the $k=1$ table — two exact
self-sufficient cures ($\beta = \alpha = 1$), two no-ops at failed arms
($\beta = \alpha$ small), two marginal $\approx 2$ SE losses ($\beta < \alpha$) —
lies inside a single model class, all of it realizable. **No $k=1$ observation
discriminates within the class.** A law inferred from $k=1$ arms about how
"internalized" a channel is therefore has no model-theoretic content, and its
non-replication at a fresh seed set is the expected outcome, not an anomaly.

The corrected invariant is the one that *is* robust across all twelve arms:
removal of the sole coordinate is a no-op exactly where the model had already
failed; at the successes the outcome is seed-heterogeneous.

---

## 9. Algorithmic content

Three procedures follow directly and are the computational core of the analysis.

**Algorithm A — Redundancy-defect curvature test.**
*Input*: control accuracy $a_{\mathrm{ctl}}$, single-ablation accuracies
$a_1,\dots,a_k$, block-ablation accuracy $a_{\mathrm{all}}$.
*Output*: the defect $R$ and a curvature verdict.
Compute $d_i = a_{\mathrm{ctl}} - a_i$ and $D = a_{\mathrm{ctl}} - a_{\mathrm{all}}$;
return $R = \sum_i d_i - D$ and classify: $R > \tau$ ⇒ convex-compatible only;
$|R| \le \tau$ ⇒ affine-compatible; $R < -\tau$ ⇒ strictly concave (saturating),
with $\tau$ the pooled standard error scale. Cost $O(k)$.

**Algorithm B — Affine dimension certificate.**
*Input*: no-op tolerance $\varepsilon > 0$ and observed block drop $D$.
*Output*: the minimum width $\lceil D/\varepsilon \rceil$ compatible with an
affine (or convex) read-out. If the actual $k$ is smaller, the affine and convex
hypotheses are refuted. Cost $O(1)$.

**Algorithm C — Canonical-channel ladder simulator.**
*Input*: width $k$, per-coordinate gain $g$, clip level $T$.
*Output*: the gate values and no-op verdicts of all interventions, via
$\Gamma_T(x) = \min(\max(x,0), T)$ evaluated at $kg$, $(k-1)g$, $(k-2)g$, $0$ and
$\lambda k g$. Produces the $\ge 2 / \ge 3$ thresholds as a function of the
dimensionless ratio $(k-1)g/T$. Cost $O(1)$ per intervention.

---

## 10. Discussion, and what the model gets wrong

### 10.1 Scope of the results

Theorem 2.4 is model-free: it constrains any experiment of this shape. Theorems
3.4–3.7 and 4.4–4.11 are constraints on *classes of read-outs*, not on particular
architectures: they say what an observed table of drops can and cannot be
generated by. Theorems 6.6–6.8 and 7.3–7.6 concern one explicit channel model,
and are correspondingly stronger and correspondingly more falsifiable. The
experimental arms themselves are at toy scale; the transferable statement is the
*training-time design rule* of Corollary 7.5, and real-scale confirmation remains
open.

### 10.2 The prediction the data refute

The canonical model makes a monotonicity prediction that is easy to check:

**Theorem 10.1 (larger gains are more self-sufficient, at fixed clip).** Let
$0 \le g \le g'$, $k \ge 1$, $kg \ge 1$, and suppose
$\Gamma(\mathrm{zero}_i(u_{k,g})) = \Gamma(u_{k,g})$. Then
$\Gamma(\mathrm{zero}_i(u_{k,g'})) = \Gamma(u_{k,g'})$.

*Proof.* By Theorem 7.3 the hypothesis gives $(k-1)g \ge 1$; since $k \ge 1$,
$(k-1)g' \ge (k-1)g \ge 1$, and $kg' \ge kg \ge 1$, so Theorem 7.3 applies again
in the other direction. $\square$

The data say the opposite. The one arm that stayed boundary-dependent — at both
$k=2$ and $k=3$, the same random seed — carries the **largest** exclusive
coordinates of its width ($0.701$ versus at most $0.660$ for its siblings). Under
a seed-independent clip level it should have been the *most* self-sufficient arm;
it was the only dependent one.

The conservative repair is to abandon the seed-independent clip: if the effective
clip level $T$ co-scales with the coordinate magnitude, $T \asymp g_{\max}$, then
self-sufficiency is governed by the dimensionless ratio $(k-1)g/T$ and the
monotonicity of Theorem 10.1 dissolves. This converts a seed idiosyncrasy into a
measurable scalar and is the sharpest test the analysis produces.

### 10.3 Methodological consequences for ablation studies

Three consequences generalize well beyond the present experiment.

1. **Single-unit ablation cannot detect redundancy.** By Theorem 2.4, at $k=1$ the
   experiment is degenerate. Reports of "the network does not need unit $u$" based
   on single-unit deletions at unit width are measuring the wrong thing.
2. **$1/k$ is the null, not zero.** By Theorem 5.2, any saturating read-out
   produces single-ablation no-ops at rate $1/k$. Increases in apparent
   distributedness with width must be tested against this baseline.
3. **A universal no-op is a null channel.** By Theorem 8.1, an arm in which every
   weakening of a channel is a no-op is an arm that never used the channel. This
   is the opposite of the "the computation has been internalized elsewhere"
   reading it usually receives.

---

## 11. Future directions

**C1 — The clip level co-scales with coordinate magnitude.** *Conjecture*: the
effective clip level $T$ is not a seed-independent constant but satisfies
$T \asymp g_{\max}$; equivalently, self-sufficiency is governed by the
dimensionless ratio $(k-1)g/T$ rather than by $(k-1)g$. The key insight is that
Theorem 10.1 proves the *opposite* of the observed trend at fixed $T$ — larger
coordinates should be more self-sufficient — so the measured arms with the
largest coordinates of their width, and the only dependent ones, refute a
seed-independent clip; the only conservative repair is a clip that grows with the
coordinates. The magnitude→dependence hint now holds at two widths for one seed,
and the ratio form is testable with arms already scheduled for the magnitude
trend at no extra training cost, converting a seed idiosyncrasy into a measurable
scalar.

**C2 — The redundancy defect is the real observable.** *Conjecture*:
$R = \sum_i d_i - D$ separates arms far better than any single intervention:
$|R| \le 0.004$ for every self-sufficient arm and $R \le -0.2$ for every
dependent one, at every width, with no intermediate values. The key insight is
that $R$ has a curvature meaning — $R \ge 0$ for convex, $R = 0$ for affine,
$R \le 0$ for concave read-outs — so an empirical bimodality of $R$ is a claim
about the *shape* of the boundary read-out, not about accuracy, and one gap-free
measurement of $R$ would upgrade "saturates at $k=2$" to "the read-out is affine
below the knee and saturated above it". $R$ is computable from data already
collected, so the first test is a re-analysis rather than a new round.

**C3 — Sign-robustness has its own width, one above self-sufficiency.**
*Conjecture*: for every seed and every width, the smallest $k$ at which the flip
becomes a no-op equals the smallest $k$ at which single ablations become no-ops,
plus one. The key insight is that a flip removes twice the coordinate that an
ablation removes, so under any saturating gate the two thresholds are
$(k-1)g \ge T$ and $(k-2)g \ge T$ — exactly one width apart. Theorems 7.3–7.5
prove this for the canonical channel; the conjecture is that it survives the
non-uniform gains of trained cells.

**C4 — Real-scale transfer.** The transferable content of the analysis is the
training-time design rule: allocate at least two exclusive dimensions for a
self-sufficient recovery and at least three for reliable success and sign
robustness. Confirming this at realistic scale remains the frontier.

**C5 — Beyond uniform gains.** Theorem 5.1 already handles non-uniform shares
($d_i \le (s_i/S)D$). A quantitative version of the ladder for arbitrary gain
profiles — predicting which *specific* coordinate's ablation first becomes
detectable as the profile becomes unequal — would sharpen the design rule from a
statement about counts to a statement about gain distributions.

---

## 12. Conclusion

Six accuracy numbers from a single trained cell turn out to determine a
surprising amount of structure. Their pattern — each coordinate individually
dispensable, the block indispensable, the sign of one coordinate decisive —
cannot arise at one coordinate for reasons of pure counting, cannot arise from any
convex read-out for reasons of chord geometry, and does arise, exactly, from a
rectified sum clipped at the level the downstream computation needs.

Two general lessons survive the specifics. First, the *redundancy defect*
$R = \sum_i d_i - D$ is a curvature measurement of a nonlinearity one never
observes directly, computable from ablation accuracies alone. Second, saturation
manufactures the appearance of distributed representation at rate $1/k$: when a
component can be deleted with no effect, one has learned something reliable about
the shape of a gate, and possibly nothing at all about what the network knows.
