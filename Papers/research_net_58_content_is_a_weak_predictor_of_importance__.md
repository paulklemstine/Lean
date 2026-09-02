# Content Is a Weak Predictor of Importance: Three Nested Ceilings for Key-Content Cache Eviction

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Attention caches in autoregressive transformers grow without bound, and a large body of engineering practice attempts to bound them by *eviction*: score each stored key, keep the top $B$, discard the rest. A natural family of scores reads the key vector itself, on the hypothesis that importance is written into the representation. We test this hypothesis empirically and then explain the outcome structurally.

Empirically, per-(layer, key-head) ridge probes from the $64$-dimensional post-rotary key to the logarithm of total future attention explain a mean of $R^2 = 0.329$ of the variance (minimum $0.113$, maximum $0.639$, with a front-high/middle-low depth profile), yet the eviction policy they induce closes only $10.26\%$ of the oracle gap at budget $B = 64$ and is *worse than* a usage-accumulation baseline at $B = 32$ (closure $-18.59\%$). More than ten points of retained attention mass separate every content policy from the oracle at every budget tested.

Theoretically, we prove three nested ceilings that account for this, in increasing order of generality.

1. **Dimension blindness.** For every key configuration with key dimension $d$ and context length $n$ satisfying $d + 1 < n$, there is a linear space of importance profiles of dimension at least $n - (d+1)$ on which *every* affine probe achieves $R^2 \le 0$. At $d = 64$, $n = 1024$ this is at least $959$ of $1024$ directions; the visible fraction is $65/1024 < 6.4\%$.
2. **The content (ANOVA) ceiling.** For any content map and *any* function of content — nonlinear, nonparametric, arbitrary — the coefficient of determination is at most $1 - SS_{\text{within}}/SS_{\text{tot}}$, and this supremum is attained by the conditional mean. Nonlinearity buys exactly the distance from the measured value to that ceiling and no more.
3. **The relational ceiling.** Averaged over a family of contexts, every *static* selection retains exactly the mass it carries in the context-averaged importance profile; hence every content-only policy is dominated by the top-$B$ set of that averaged profile, which is in turn dominated by the average of the per-context oracles. The gap between the last two — the **relational deficit** — is a Jensen gap for the max-functional, is nonnegative always, and is strictly positive on an explicit two-context, two-key witness where it equals $(u-v)/2$ for every $u > v$.

We then identify ceilings 2 and 3: pooled over contexts, the best content-measurable predictor of importance *is* the context-averaged profile, and its irreducible error is the context dispersion. A Cauchy–Schwarz step converts one into the other, giving $\text{deficit} \le \sqrt{B \cdot D / |W|}$ with $D$ the dispersion; on the witness the bound is loose by exactly the factor $\sqrt 2$, so the $\sqrt{B \cdot \text{dispersion}}$ shape is correct.

Finally we prove two structural facts about the measured table itself: an explicit four-key instance in which one score strictly beats another at budget $1$ and strictly loses at budget $2$ (so the observed sign flip between $B = 32$ and $B = 64$ is not an artefact and no single-budget policy comparison extrapolates); and a strict concavity result showing that the observed depth heterogeneity in $R^2$ *improves* the model-level guarantee relative to a homogeneous model with the same mean.

The verdict: **importance is relational and positional, not intrinsic to key identity.** The oracle-to-policy gap for content-based eviction is structural, not an engineering shortfall.

---

## 1. Introduction

### 1.1 The setting

An autoregressive transformer generating token $t$ compares a query $q_t$ against the keys $k_1, \dots, k_{t-1}$ of all preceding positions, forms attention weights by a softmax of the scaled inner products, and reads out a convex combination of the corresponding values. The keys and values must therefore be retained: this is the *KV cache*. Its size is linear in context length and, at long contexts, dominates memory and bandwidth.

*Eviction* is the standard remedy. Fix a budget $B \ll n$. A policy observes the stream of arriving tokens and maintains a set of at most $B$ retained positions. Its quality is measured by **retained attention mass**: writing $a_i \ge 0$ for the total attention that position $i$ receives over the remainder of the generation, a policy holding set $S$ at the end retains $\sum_{i \in S} a_i$, normalized by $\sum_i a_i$. The **oracle** knows $a$ in advance and keeps its top $B$ entries.

### 1.2 The hypothesis under test

Two broad families of policies exist.

- **Usage-based (online) policies** track a statistic of the attention already received — cumulative attention, hit counts, recency — and evict the least-used. They are context-adaptive by construction: the same token can be scored differently in different documents.
- **Content-based (static) policies** score each key from its own vector $k_i$, once, at arrival. This is the family suggested by interpretability folklore: certain tokens are said to be intrinsically attention-attracting, and a probe should be able to detect them.

The content family is operationally attractive. It requires no bookkeeping, permits scoring at insertion, and generalizes across documents. The question we address is what it can achieve, at best.

### 1.3 Contributions

The novelty here is not the existence of key-importance probes, which is folklore, but the measurement of their **ceiling as an eviction policy** on a knee-measuring harness, together with the conversion from probe accuracy to retained mass and the structural theorems that explain the ceiling. Specifically:

- a pre-registered three-horn experiment, of which the optimistic horn is refuted;
- three nested ceilings (dimension, content, relational) with matching witnesses that show none of them is vacuous;
- an identification theorem showing the second and third are the same population quantity;
- a sharp-shape dispersion bound converting explained variance into retained mass;
- structural explanations of two secondary features of the data (budget crossing, depth heterogeneity).

---

## 2. Preliminaries and notation

Throughout, $\iota$ indexes a finite set of *keys* (cache slots or, in the pooled setting, key contents), $|\iota| = n$.

**Definition 2.1 (Retained mass).** For an importance profile $a : \iota \to \mathbb{R}$ and a selection $S \subseteq \iota$,
$$\mathrm{ret}(a, S) \;=\; \sum_{i \in S} a_i .$$

**Definition 2.2 (Top set).** For a score $s : \iota \to \mathbb{R}$ and a budget $B$, a set $S$ is a *top-$B$ set for $s$*, written $\mathrm{Top}(s, B, S)$, if $|S| = B$ and $s_j \le s_i$ for all $i \in S$, $j \notin S$. Equivalently, $S$ is the outcome of scoring by $s$ and keeping the $B$ best (ties broken arbitrarily). The oracle at budget $B$ is any top-$B$ set for $a$ itself; it maximizes $\mathrm{ret}(a, \cdot)$ over sets of size $B$.

**Definition 2.3 (Regression quantities).** With $\bar a = \frac1n \sum_i a_i$,
$$SS_{\text{tot}}(a) = \sum_i (a_i - \bar a)^2, \qquad SSE(a, s) = \sum_i (a_i - s_i)^2, \qquad R^2(a, s) = 1 - \frac{SSE(a,s)}{SS_{\text{tot}}(a)} .$$

**Definition 2.4 (Closure fraction).** For a baseline value $\beta$, a policy value $\pi$ and an oracle value $\omega$ with $\beta < \omega$,
$$\mathrm{clo}(\beta, \pi, \omega) = \frac{\pi - \beta}{\omega - \beta} .$$
This is the fraction of the available headroom that the policy captures over the baseline; it is negative when the policy underperforms the baseline.

We will use one standard conversion, whose proof is a single Cauchy–Schwarz step and which we record for completeness.

**Lemma 2.5 (Selection error is controlled by regression error).** *Let $S$ be a top-$B$ set for a score $s$ and let $T$ be any set with $|T| = B$. Then*
$$\mathrm{ret}(a, T) - \mathrm{ret}(a, S) \;\le\; 2\sqrt{B \cdot SSE(a, s)} .$$

*Proof sketch.* Write $\mathrm{ret}(a,T) - \mathrm{ret}(a,S) = [\mathrm{ret}(a,T) - \mathrm{ret}(s,T)] + [\mathrm{ret}(s,T) - \mathrm{ret}(s,S)] + [\mathrm{ret}(s,S) - \mathrm{ret}(a,S)]$. The middle bracket is $\le 0$ because $S$ is top-$B$ for $s$. Each outer bracket is a sum of $B$ residuals $a_i - s_i$, so by Cauchy–Schwarz its absolute value is at most $\sqrt{B \cdot SSE(a,s)}$. $\square$

Combining with Definition 2.3, if $SS_{\text{tot}}(a) \neq 0$ then $SSE = (1 - R^2)\, SS_{\text{tot}}$, so a probe of accuracy $R^2$ satisfies
$$\mathrm{ret}(a, \text{oracle}) - \mathrm{ret}(a, S) \;\le\; 2\sqrt{B\,(1 - R^2)\, SS_{\text{tot}}(a)} . \tag{2.1}$$
This is the $R^2 \to$ retained-mass conversion used throughout. It is a *guarantee*, and in §7 we show that it is also, in aggregated form, what makes the observed depth heterogeneity favourable.

---

## 3. The measurement

### 3.1 Protocol

For each (layer, key-head) cell of a small autoregressive transformer, a ridge regression was fitted from the $64$-dimensional post-rotary key vector to $\log(1 + \text{total future attention received})$, with the fit performed on training-side windows only. Contexts were $1024$ tokens. The fitted score was then deployed as a **streaming eviction rule**: on arrival, a key is scored; when the cache exceeds budget $B$, the lowest-scoring resident is discarded. Retained attention mass on held-out windows is reported, against two references: an accumulated-usage baseline (evicting the least cumulative attention received so far) and the per-window oracle.

The harness, budgets and windows are identical to those used for the accumulation baseline, so the comparison is like-for-like.

### 3.2 Results

| $B$ | accumulated usage | static content probe | oracle |
|---|---|---|---|
| $32$ | $0.8633$ | $0.8395$ | $0.9913$ |
| $64$ | $0.8822$ | $\mathbf{0.8938}$ | $0.9953$ |
| $128$ | $0.9189$ | $\mathbf{0.9284}$ | — |

Probe accuracy: mean $R^2 = 0.329$, minimum $0.113$, maximum $0.639$, with a reproducible depth structure (high near the input, low in the middle layers).

### 3.3 The three pre-registered horns

**P1 (optimistic):** a content probe closes at least $33\%$ of the oracle gap over the accumulation baseline.

**Result: refuted.** At $B = 64$,
$$\mathrm{clo}(0.8822,\ 0.8938,\ 0.9953) = \frac{0.0116}{0.1131} = 0.1026 \;<\; \tfrac13 .$$
The closure is *positive* — the probe does help at this budget — but by a factor of three too small. Worse, at $B = 32$,
$$\mathrm{clo}(0.8633,\ 0.8395,\ 0.9913) = \frac{-0.0238}{0.1280} = -0.1859 \;<\; 0 ,$$
so the probe is *harmful* relative to a policy that uses no content information at all.

**P2 (pessimistic):** at least ten points of retained mass remain between the best content policy and the oracle.

**Result: confirmed.** $0.9953 - 0.8938 = 0.1015 > 0.10$ at $B = 64$; the deficit at $B = 32$ is $0.1518$.

**P3 (structural):** probe accuracy is depth-structured rather than uniform.

**Result: confirmed**, with min $0.113$ and max $0.639$ around a mean of $0.329$. §7 shows this structure is quantitatively favourable to the probe, which strengthens rather than weakens the refutation of P1.

The remainder of the paper explains these outcomes.

---

## 4. Ceiling one: the dimension obstruction

The narrowest ceiling applies to exactly the estimator used: an affine probe.

**Definition 4.1.** Given a key matrix $k : \{1,\dots,n\} \to \mathbb{R}^d$, the *affine probe score* with weights $w \in \mathbb{R}^d$ and intercept $b \in \mathbb{R}$ is
$$s_i \;=\; \sum_{j=1}^{d} w_j\, k_{ij} \;+\; b .$$

**Definition 4.2 (Moment map).** The linear map $M : \mathbb{R}^n \to \mathbb{R}^d \times \mathbb{R}$ given by
$$M(a) \;=\; \Big( \big(\textstyle\sum_i a_i k_{ij}\big)_{j=1}^{d},\ \ \textstyle\sum_i a_i \Big)$$
records everything an affine probe can read off an importance profile: the $d$ key moments and the total mass.

**Lemma 4.3 (Simultaneous orthogonality).** *If $M(a) = 0$ then $\sum_i a_i s_i = 0$ for every affine probe score $s$, simultaneously in $w$ and $b$.*

*Proof.* Expand $\sum_i a_i s_i = \sum_j w_j \sum_i a_i k_{ij} + b\sum_i a_i$; both factors vanish by hypothesis. $\square$

**Theorem 4.4 (Blind profiles are unpredictable).** *If $M(a) = 0$ and $SS_{\text{tot}}(a) > 0$, then $R^2(a, s) \le 0$ for every affine probe $s$.*

*Proof.* From $\sum_i a_i = 0$ we get mean zero, so $SS_{\text{tot}}(a) = \sum_i a_i^2$. Then
$$SSE(a,s) = \sum_i a_i^2 - 2\sum_i a_i s_i + \sum_i s_i^2 = SS_{\text{tot}}(a) + \sum_i s_i^2 \ \ge\ SS_{\text{tot}}(a)$$
using Lemma 4.3, so $SSE / SS_{\text{tot}} \ge 1$ and $R^2 \le 0$. $\square$

**Lemma 4.5 (Nondegeneracy).** *If $M(a) = 0$ and $a \neq 0$ then $SS_{\text{tot}}(a) > 0$.*

*Proof.* Mean zero gives $SS_{\text{tot}}(a) = \sum_i a_i^2 > 0$ for $a \neq 0$. $\square$

This matters: it rules out the objection that Theorem 4.4 is a division-by-zero artefact. The blind profiles genuinely have variance to be explained, and the affine class explains none of it.

**Theorem 4.6 (Dimension obstruction).** *For every key configuration $k$, if $d + 1 < n$ then there exists $a$ with $SS_{\text{tot}}(a) > 0$ such that $R^2(a, s) \le 0$ for every affine probe. Moreover*
$$\dim \ker M \;\ge\; n - (d+1) .$$

*Proof.* $M$ maps into a space of dimension $d+1 < n$, so it cannot be injective and its kernel is nonzero; pick $a \neq 0$ there and apply Lemma 4.5 and Theorem 4.4. The dimension count is rank–nullity: $\dim \ker M = n - \dim \mathrm{im}\, M \ge n - (d+1)$. $\square$

**Corollary 4.7 (Measured geometry).** *With $d = 64$ and $n = 1024$, at least $959$ of the $1024$ importance directions are invisible to every affine probe, and the visible fraction is $65/1024 < 6.4\%$.*

**Interpretation.** The corollary is *not* a claim that the measured probe has $R^2 \le 0$; it plainly does not. The point is comparative. On an unstructured profile the affine class would capture on the order of the visible fraction, under $6.4\%$; the measured probes capture $32.9\%$. They are therefore genuinely exploiting structure in real attention profiles, five times beyond the dimension floor — and the eviction policy still fails. **The failure of P1 is not a fitting failure.** No amount of better regression within the affine class, and (by §5) no amount of nonlinearity, addresses the reason.

---

## 5. Ceiling two: the content (ANOVA) ceiling

We now drop linearity entirely.

**Definition 5.1.** Fix a *content map* $\kappa : \iota \to K$ into a finite set of content values. A score $s$ is *content-measurable* if $s = f \circ \kappa$ for some $f : K \to \mathbb{R}$. The *fiber* over $y \in K$ is $F_y = \{ i : \kappa(i) = y \}$, and the *conditional mean* is $\bar a_y = \frac{1}{|F_y|}\sum_{i \in F_y} a_i$.

**Definition 5.2 (Within-content dispersion).**
$$SS_{\text{within}}(\kappa, a) \;=\; \sum_{y \in K} \sum_{i \in F_y} \big(a_i - \bar a_y\big)^2 \;\ge\; 0 .$$

The engine of the section is elementary.

**Lemma 5.3 (The mean is the best constant).** *For any finite set $G$, any $g : G \to \mathbb{R}$ and any $c \in \mathbb{R}$,*
$$\sum_{i \in G} \big(g_i - \bar g\big)^2 \;\le\; \sum_{i \in G} (g_i - c)^2, \qquad \bar g = \tfrac{1}{|G|}\textstyle\sum_{j \in G} g_j .$$

*Proof.* $\sum_{i}\big[(g_i - c)^2 - (g_i - \bar g)^2\big] = |G| \,(\bar g - c)^2 \ge 0$, by expanding and using $\sum_i g_i = |G| \bar g$. $\square$

**Theorem 5.4 (ANOVA lower bound on content error).** *For every $f : K \to \mathbb{R}$,*
$$SS_{\text{within}}(\kappa, a) \;\le\; SSE\big(a,\ f \circ \kappa\big) .$$

*Proof.* Partition the index set into fibers. On $F_y$ the score is the constant $f(y)$, so by Lemma 5.3 its within-fiber error is at least the error around $\bar a_y$. Sum over $y$. $\square$

**Theorem 5.5 (Attainment).** $SSE\big(a,\ i \mapsto \bar a_{\kappa(i)}\big) = SS_{\text{within}}(\kappa, a)$.

*Proof.* Same fiberwise decomposition, with equality on each fiber by definition of $\bar a_y$. $\square$

**Corollary 5.6 (The content ceiling).** *If $SS_{\text{tot}}(a) > 0$ then every content-measurable score satisfies*
$$R^2 \;\le\; 1 - \frac{SS_{\text{within}}(\kappa, a)}{SS_{\text{tot}}(a)} ,$$
*and the bound is attained by the conditional-mean predictor. It is therefore the exact supremum of $R^2$ over all functions of content — deep networks, lookup tables, and everything between.*

**Theorem 5.7 (The honest caveat).** *If $\kappa$ is injective then $SS_{\text{within}}(\kappa, a) = 0$ and the ceiling degenerates to $R^2 \le 1$.*

*Proof.* Every fiber is a singleton; the error around a one-point mean is zero. $\square$

Theorem 5.7 is essential to reading Corollary 5.6 correctly. **Inside a single context all key vectors are distinct**, so the ANOVA ceiling applied within one document says nothing at all. The ceiling has content precisely for a *pooled* population in which the same content recurs across contexts — which is exactly the pooled train-window population on which the probe was fitted, and, as the next section shows, is where the real obstruction lives.

---

## 6. Ceiling three: the relational ceiling

### 6.1 Contexts and static policies

**Definition 6.1.** A *context family* is a finite set $W$ of contexts together with importance profiles $a_w : \iota \to \mathbb{R}$ for $w \in W$. The *context-averaged profile* is
$$\bar a(i) \;=\; \frac{1}{|W|}\sum_{w \in W} a_w(i) .$$
A *policy* is a map $S : W \to \{\text{subsets of } \iota\}$; it is *static* if $S(w)$ does not depend on $w$. The *average retained mass* is $\mathrm{avgret}(a, S) = \frac{1}{|W|}\sum_w \mathrm{ret}(a_w, S(w))$.

Any content-only score induces a static policy: the content of a key does not change when the key is placed in a different context, hence neither does its score, hence neither does the selection.

**Theorem 6.2 (A static policy sees only the mean profile).** *For any fixed $S \subseteq \iota$,*
$$\mathrm{avgret}\big(a,\ w \mapsto S\big) \;=\; \mathrm{ret}\big(\bar a,\ S\big) .$$

*Proof.* Exchange the order of summation over $w$ and over $i \in S$, then divide by $|W|$. $\square$

Trivial as a computation, decisive as a statement: **all context-conditional information is annihilated before a static policy acts.** Its performance is a functional of $\bar a$ alone.

### 6.2 The two-step ceiling

**Theorem 6.3 (Step 1: dominance by the mean-profile top set).** *If $|S| = B$ and $T$ is a top-$B$ set for $\bar a$, then $\mathrm{avgret}(a, w \mapsto S) \le \mathrm{ret}(\bar a, T)$.*

*Proof.* Theorem 6.2 plus optimality of a top-$B$ set for the profile $\bar a$. $\square$

**Theorem 6.4 (Step 2: the Jensen gap).** *If $T$ is a top-$B$ set for $\bar a$ and $O(w)$ is a top-$B$ set for $a_w$ for each $w$, then*
$$\mathrm{ret}(\bar a, T) \;\le\; \mathrm{avgret}(a, O) .$$

*Proof.* By Theorem 6.2 the left side equals the average retained mass of the *static* policy $w \mapsto T$; in each context $T$ has $B$ elements and $O(w)$ is optimal at size $B$, so the pointwise inequality $\mathrm{ret}(a_w, T) \le \mathrm{ret}(a_w, O(w))$ holds and averages. $\square$

**Theorem 6.5 (The relational ceiling).** *Under the hypotheses above,*
$$\underbrace{\mathrm{avgret}(a, w\mapsto S)}_{\text{any content-only policy}} \;\le\; \underbrace{\mathrm{ret}(\bar a, T)}_{\text{ceiling of the family}} \;\le\; \underbrace{\mathrm{avgret}(a, O)}_{\text{oracle}} .$$

The middle term is the *supremum* of the content-only family: no probe, present or future, of any functional form, exceeds it.

**Definition 6.6 (Relational deficit).** $\ \mathrm{def}(a, O, T) = \mathrm{avgret}(a, O) - \mathrm{ret}(\bar a, T) \ \ge 0$ by Theorem 6.4.

**Theorem 6.7 (One bad context suffices).** *For any $w_0 \in W$,*
$$\frac{\mathrm{ret}(a_{w_0}, O(w_0)) - \mathrm{ret}(a_{w_0}, T)}{|W|} \;\le\; \mathrm{def}(a, O, T) .$$

*Proof.* Every summand of $\sum_w [\mathrm{ret}(a_w, O(w)) - \mathrm{ret}(a_w, T)]$ is nonnegative by optimality of $O(w)$, so the sum dominates the $w_0$ term; divide by $|W|$ and apply Theorem 6.2 to identify the average of $\mathrm{ret}(a_w, T)$ with $\mathrm{ret}(\bar a, T)$. $\square$

A single pathological document therefore forces a positive deficit for the entire family.

### 6.3 The swap witness

**Construction 6.8.** Let $W = \{1, 2\}$, $\iota = \{P, Q\}$, budget $B = 1$ and, for $u > v$,
$$a_1 = (u, v), \qquad a_2 = (v, u) .$$
The oracle keeps $P$ in context $1$ and $Q$ in context $2$.

**Theorem 6.9 (Every static score retains the average).** $\bar a \equiv (u+v)/2$, so for *every* singleton $S$,
$$\mathrm{avgret}(a, w \mapsto S) = \frac{u+v}{2},$$
while $\mathrm{avgret}(a, O) = u$.

**Theorem 6.10 (The relational law, exactly).** *For every $u > v$,*
$$\mathrm{avgret}(a, O) - \mathrm{avgret}(a, w\mapsto S) \;=\; \frac{u - v}{2} \;>\; 0 .$$

*Proof.* Immediate from Theorem 6.9. $\square$

**Theorem 6.11 (Static/adaptive separation).** *In the same instance, a policy permitted to re-select per context attains the oracle exactly, while every static policy falls strictly short.*

Three features of this witness deserve emphasis.

- **No score class appears in the argument.** Linear probes, ridge probes, neural probes, an adversary with unlimited compute and perfect knowledge of key geometry: all retain $(u+v)/2$, because the two contents are indistinguishable *on average* and averaging is all a static policy can see (Theorem 6.2).
- **It is parametric, not numerical.** The deficit is $(u-v)/2$ for every $u > v$, so it is not a coincidence of a chosen instance.
- **It degenerates exactly where it should.** At $u = v$ the deficit is zero: if all contexts agree, there is nothing relational to miss. The theory is not vacuously pessimistic.

### 6.4 Identification: ceilings 2 and 3 are one object

**Theorem 6.12 (Pooled optimality of the context average).** *For every $f : \iota \to \mathbb{R}$,*
$$\sum_i \sum_w \big(a_w(i) - \bar a(i)\big)^2 \;\le\; \sum_i \sum_w \big(a_w(i) - f(i)\big)^2 ,$$
*and the left side is the minimum of the right over all $f$; i.e. the context average is the least-squares-optimal content-only predictor and the *context dispersion* $D = \sum_i \sum_w (a_w(i) - \bar a(i))^2$ is its irreducible error.*

*Proof.* Apply Lemma 5.3 with $G = W$ for each fixed $i$, then sum over $i$. Attainment is by construction. $\square$

Theorem 6.12 identifies the ANOVA quantity of §5, computed on the pooled population where fibers are "same content, different context", with the relational structure of §6. **What content cannot know is the context**, and the size of what it cannot know is $D$.

---

## 7. From explained variance to retained mass

### 7.1 The dispersion bound

**Theorem 7.1 (Capstone).** *With $O(w)$ a per-context oracle and $T$ a top-$B$ set for $\bar a$,*
$$\mathrm{def}(a, O, T) \;\le\; \sqrt{\frac{B \cdot D}{|W|}}, \qquad D = \sum_w SSE\big(a_w, \bar a\big) = \sum_i \sum_w \big(a_w(i) - \bar a(i)\big)^2 .$$

*Proof sketch.* Fix $w$. Because $T$ is optimal for $\bar a$ at size $B$ and $|O(w)| = B$, we have $\mathrm{ret}(\bar a, O(w)) \le \mathrm{ret}(\bar a, T)$; hence
$$\mathrm{ret}(a_w, O(w)) - \mathrm{ret}(\bar a, T) \;\le\; \sum_{i \in O(w)} \big(a_w(i) - \bar a(i)\big) \;\le\; \sqrt{B \cdot SSE(a_w, \bar a)}$$
by Cauchy–Schwarz on $B$ terms. Average over $w$ and apply Cauchy–Schwarz again in the form $\sum_w \sqrt{x_w} \le \sqrt{|W| \sum_w x_w}$; the two factors of $|W|$ combine to $\sqrt{D/|W|}$. $\square$

The two occurrences of Cauchy–Schwarz have transparent meanings: the $\sqrt B$ is the price of selecting $B$ keys rather than one, and the $1/|W|$ is the averaging over contexts.

**Theorem 7.2 (Sharpness of shape).** *On the swap witness with $B = 1$, $|W| = 2$, the dispersion is $D = (u-v)^2$, so the bound of Theorem 7.1 evaluates to $(u-v)/\sqrt 2$ while the true deficit is $(u-v)/2$. The inequality is therefore loose by exactly the factor $\sqrt 2$, independently of $u$ and $v$.*

**Theorem 7.3 (Tightness at the boundary).** *If $SSE(a_w, \bar a) = 0$ for all $w$ — the contexts agree — then $\mathrm{def}(a,O,T) = 0$.*

*Proof.* The bound gives $\le 0$ and Theorem 6.4 gives $\ge 0$. $\square$

A two-sided bound is impossible in general: dispersion carried by keys that no budget-$B$ policy would ever retain costs nothing in retained mass. Sharpness is therefore correctly stated as an exact constant on a witness plus the boundary converse.

### 7.2 Aggregation across heads

A deployed cache has many (layer, head) cells; the round reports a *mean* $R^2$ across them. The correct aggregate guarantee is not the per-cell bound repeated, but the following.

**Lemma 7.4 (Cauchy–Schwarz for square roots).** *For nonnegative $x_1,\dots,x_H$, $\ \sum_h \sqrt{x_h} \le \sqrt{H \sum_h x_h}$.*

**Theorem 7.5 (Head aggregation).** *If $S(h)$ is a top-$B$ set for the score $s_h$ and $|T(h)| = B$ for each head $h$, then*
$$\sum_h \Big[\mathrm{ret}(a_h, T(h)) - \mathrm{ret}(a_h, S(h))\Big] \;\le\; 2\sqrt{H \cdot B \cdot \textstyle\sum_h SSE(a_h, s_h)} .$$

*Proof.* Lemma 2.5 per head, then Lemma 7.4. $\square$

**Theorem 7.6 (Mean-$R^2$ conversion).** *If additionally every head has the same total dispersion $SS_{\text{tot}}(a_h) = V > 0$, then the average per-head oracle deficit obeys*
$$\frac{1}{H}\sum_h \Big[\mathrm{ret}(a_h, T(h)) - \mathrm{ret}(a_h, S(h))\Big] \;\le\; 2\sqrt{B\,\big(1 - \overline{R^2}\big)\,V}, \qquad \overline{R^2} = \frac1H \sum_h R^2(a_h, s_h).$$

*Proof.* Substitute $SSE_h = (1 - R^2_h)V$ into Theorem 7.5 and simplify; the factor $H$ inside the root becomes $H^2$ and cancels the $1/H$ outside. $\square$

This is the reported mean $R^2 = 0.329$ in the currency of retained mass, at the level of the whole model rather than a single cell. The common-$V$ hypothesis is an explicit and isolated assumption: without it, Theorem 7.5 is the correct statement.

### 7.3 Depth heterogeneity is a bonus (P3 with teeth)

**Lemma 7.7 (Strict two-point concavity).** *For $x \neq y$, both nonnegative, $\ \sqrt x + \sqrt y < 2\sqrt{(x+y)/2}$.*

*Proof.* Squaring, $(\sqrt x + \sqrt y)^2 = x + y + 2\sqrt{xy} < 2(x+y)$ precisely when $(\sqrt x - \sqrt y)^2 > 0$. $\square$

**Theorem 7.8 (Heterogeneity strictly improves the guarantee).** *For $c > 0$ and $x \neq y$ nonnegative, $\ \sqrt{cx} + \sqrt{cy} < 2\sqrt{c\,(x+y)/2}$.*

**Corollary 7.9 (Measured depth structure).** *With the extreme observed cells $R^2 = 0.639$ and $R^2 = 0.113$,*
$$\sqrt{1 - 0.639} + \sqrt{1 - 0.113} = 1.5426 \;<\; 1.5799 \;=\; 2\sqrt{1 - \tfrac{0.639 + 0.113}{2}} .$$

The moral is a warning against a natural misreading. Depth structure in $R^2$ does not make the aggregate guarantee worse; by concavity of the square root it makes it *strictly better* than a homogeneous model with the same mean. Reporting only the mean $0.329$ therefore *understates* the probe — and the probe still fails P1. The refutation survives the most generous accounting available.

### 7.4 The guarantee direction

For completeness, the conversion runs the other way too.

**Theorem 7.10 ($R^2 \Rightarrow$ closure).** *Let $S$ be a top-$B$ set for a probe $s$, let $O$ be a size-$B$ oracle set and let $T$ be a rival arm with $\mathrm{ret}(a,T) < \mathrm{ret}(a,O)$. Then*
$$\mathrm{clo}\big(\mathrm{ret}(a,T),\ \mathrm{ret}(a,S),\ \mathrm{ret}(a,O)\big) \;\ge\; 1 - \frac{2\sqrt{B\,(1-R^2)\,SS_{\text{tot}}(a)}}{\mathrm{ret}(a,O) - \mathrm{ret}(a,T)} .$$

*Proof.* Rearrange (2.1) and divide by the positive gap. $\square$

Read backwards, this says that a *measured* closure of $10.26\%$ is a joint statement about the probe *and* the key population — never about the probe alone. That is exactly why the refutation of P1 required the structural theorems of §§4–6 rather than an appeal to the size of $1 - R^2$: an $R^2$ of $0.329$ is, in the abstract, perfectly compatible with a perfect eviction policy, since a score can be badly calibrated yet correctly ordered.

---

## 8. Budget crossing: no policy dominance is portable

The observed sign flip — probe worse at $B = 32$, better at $B = 64$ and $B = 128$ — invites the suspicion of noise. It is instead a structural feature of top-$B$ selection.

**Construction 8.1.** Four keys with true future attention $v = (5, 1, 9, 0)$. Score $\alpha$ (accumulation-like) ranks them $0 \succ 1 \succ 2 \succ 3$; score $\pi$ (probe-like) ranks them $1 \succ 2 \succ 0 \succ 3$.

**Theorem 8.2 (Crossing).**
- At $B = 1$: $\alpha$ keeps $\{0\}$ and retains $5$; $\pi$ keeps $\{1\}$ and retains $1$. So $\alpha$ strictly wins.
- At $B = 2$: $\alpha$ keeps $\{0,1\}$ and retains $6$; $\pi$ keeps $\{1,2\}$ and retains $10$. So $\pi$ strictly wins.

**Corollary 8.3 (No uniform budget ordering).** *There exist an importance profile and two scores such that the first strictly dominates the second at one budget and is strictly dominated at another. Hence a comparison of two eviction policies at a single budget carries no information about any other budget.*

**Theorem 8.4 (P2 inside the crossing).** *At $B = 2$ the oracle keeps $\{0,2\}$ and retains $14$; both arms ($6$ and $10$) are strictly below it. The crossing changes the ranking of the arms, never their distance from the oracle.*

Two methodological consequences follow. First, the pre-registered horn P1 had to be evaluated at a *fixed* budget, which is how it was evaluated. Second, published claims of eviction-policy superiority that report a single operating point should be read as claims about that operating point only.

We note the honest limitation of the construction: it uses small integers rather than the measured fractions, because no four-key instance can realize the measured retained *levels* — two policies each retaining about $0.86$ of largely disjoint mass is arithmetically impossible. The instance therefore certifies the *phenomenon*; the measured levels are handled directly by the closure-fraction arithmetic of §3.3.

---

## 9. Algorithms

Three procedures are implicit in the above and worth stating explicitly.

**A. Streaming top-$B$ eviction by a static score.** Maintain a min-heap of resident (score, index) pairs. On arrival of key $i$, compute $s_i$; if the cache holds fewer than $B$ items, insert; otherwise compare with the heap minimum and replace if larger. Cost: $O(n \log B)$ time, $O(B)$ memory beyond the cache itself. This is the policy under test, and its output is a top-$B$ set for $s$ in the sense of Definition 2.2 whenever $s$ is fixed in advance.

**B. Relational-deficit estimator.** Given a matrix $A \in \mathbb{R}^{|W| \times n}$ of per-context importance profiles and a budget $B$: compute $\bar a$ as the column mean; compute $\mathrm{ret}(\bar a, T)$ for $T$ the top-$B$ indices of $\bar a$; compute, for each row, the top-$B$ sum, and average. The difference is the exact deficit. Cost $O(|W| \cdot n)$ using selection rather than sorting. Because the deficit is the exact ceiling for the entire content-only family, this procedure returns — from data alone, without training or running any policy — an upper bound on what any content probe can ever achieve.

**C. Certified dispersion bound.** Compute $D = \sum_i \sum_w (a_w(i) - \bar a(i))^2$ and return $\sqrt{B D / |W|}$. Cost $O(|W|\cdot n)$, one pass. This is the cheap surrogate for B, valid without any selection computation, and by Theorem 7.2 its shape is exact.

---

## 10. Discussion

### 10.1 What the law says

**Importance is relational and positional, not intrinsic to key identity.** A key vector describes what a token *is*; the attention it will receive is a fact about what the surrounding context will need. The three ceilings say this at three levels of generality: a $64$-dimensional linear read-out sees a $65$-dimensional shadow of a $1024$-dimensional profile; an arbitrary function of content sees at most the conditional mean over its fibers; and any policy that cannot re-select per context sees only the context-averaged profile, which sits below the oracle by the relational deficit.

Crucially, these are properties of the *hypothesis class and the evaluation*, not of the fit. That is what converts "the probe underperformed" from an engineering complaint into a law.

### 10.2 Deployment consequences

1. **Track usage online.** The accumulation baseline's edge at $B = 32$ is not superior prediction; it is context-adaptivity — exactly the right that the swap witness prices at $(u-v)/2$.
2. **Keep recency.** Position is a form of context, and it remains the dominant cheap signal.
3. **Budget expectations honestly.** At aggressive budgets, on the order of ten points of retained attention mass are structurally out of reach of content scoring. This is a constant of the population, not a target.
4. **Do not extrapolate single-budget comparisons.** Corollary 8.3.
5. **A probe is still worth roughly one point** at moderate budgets, and it is free at inference time. It is a legitimate tiebreaker; it is not a strategy.

### 10.3 Limitations

- **Class.** The dimension obstruction of §4 concerns affine probes only. §5 covers arbitrary content functions but only through the ANOVA ceiling, whose numerical value on real data we do not estimate here; §6 covers all static policies unconditionally.
- **Scope of measurement.** One model scale, one context length, one attention-mass metric. The theorems are scale-free; the numbers are not.
- **Common-dispersion assumption.** Theorem 7.6 assumes an equal $SS_{\text{tot}}$ across heads. Theorem 7.5, which does not, is proved first and used to derive it, so the assumption is isolated and explicit.
- **Instance vs. levels.** As noted in §8, the crossing instance certifies a phenomenon and not the measured magnitudes.
- **Vacuity checks.** Both ceilings would be empty in degenerate regimes, and in both cases we prove the degeneracy rather than waving at it: the ANOVA ceiling collapses under an injective content map (Theorem 5.7), and the relational deficit vanishes exactly when contexts agree (Theorems 6.10 at $u=v$ and 7.3).

### 10.4 Relation to the measured accuracy

It is tempting to explain the failure of P1 by the size of $1 - R^2 = 0.671$. That explanation is wrong, and the error is instructive. Retained mass depends on the *ordering* a score induces, not on its calibration: a score with modest $R^2$ can induce the exact oracle ordering, and a score with high $R^2$ can misrank the top of the distribution. What actually explains the failure is Theorem 6.5: a static score is evaluated against a *distribution* of contexts, and the maximum of an average is below the average of the maxima. "True but hard" for a better probe becomes "false" for the whole family.

---

## 11. Future directions

**D1. The relational deficit as a spectral quantity.** The upper half is done: $\mathrm{def} \le \sqrt{B \cdot D / |W|}$, with the constant off by exactly $\sqrt 2$ on the swap witness. Conjecturally the deficit is bounded above *and below* by explicit multiples of the top-$B$ singular mass of the centred context matrix $A - \mathbf{1}\otimes \bar a$, strictly sharpening the Frobenius bound, and vanishes exactly when that matrix has rank zero restricted to the top-$B$ selection cone. The key insight is that the Jensen gap of the max-functional over a polytope is controlled by the dispersion of the argmax *vertices*, and the vertex set of the budget-$B$ selection polytope is exactly the hypersimplex, whose diameter is a rank quantity. If true, the ten-point gap becomes a spectral statistic of the attention tensor, computable without running any policy; if false, the deficit is not a second-order statistic and only a combinatorial description can capture it.

**D2. Online advantage grows with dispersion.** Conjecture: for an accumulated-usage policy $A$ and the best static policy $S$, $A - S \ge c \cdot \mathrm{def}$ for a universal $c > 0$ on streams whose per-context oracle sets are pairwise disjoint, while $A - S \to 0$ as the contexts converge. This would turn the deployment advice of §10.2 into a theorem with a rate.

**D3. Probe-plus-recency hybrids.** Since the probe contributes about one point and recency is the dominant cheap signal, the natural next policy is a convex blend, with the blend weight chosen per layer according to the measured depth profile of $R^2$. The aggregation results of §7.2 predict where the gain should be largest.

**D4. Per-layer load-bearingness.** Which layers' attention actually matters downstream? An ablation would rescale the whole analysis: the ceilings are stated per head, and a load-bearingness weighting would replace the uniform head average of Theorem 7.6 with a weighted one.

**D5. Scale.** The theorems are scale-free but the constants are not. Repeating the measurement at larger model scales, and mapping the tail behaviour of the per-head $R^2$ distribution, would test whether the relational deficit shrinks, grows, or is invariant with capacity.

---

## 12. Conclusion

A content probe with a real signal — a third of the variance in future attention explained — buys about one point of retained cache mass at moderate budgets and *loses* ground at aggressive ones, leaving more than ten points to the oracle. We have shown that this is not a shortfall of engineering but the consequence of three nested structural ceilings: the rank of what a $64$-dimensional linear read-out can see, the within-fiber dispersion that no function of content can explain, and, most fundamentally, the fact that a policy which cannot re-select per context is evaluated against the context-*averaged* importance profile, whose top-$B$ mass falls below the average of the per-context optima by a strictly positive Jensen gap.

The witness that makes this concrete is two contexts in which two keys exchange roles: identical as content, opposite as function, and worth exactly $(u-v)/2$ to any policy allowed to notice the difference. Content-based caches are not allowed to notice. That is the whole story, and it is a theorem, not a benchmark.
