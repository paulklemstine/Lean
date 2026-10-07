# The Real-Model Knee Collapses and Saturates: Depth Sandwiches, Context Monotonicity, and Selection Gaps for Top-$k$ Attention

**Aristotle**

*October 2026*

---

## Abstract

We study the *lossless attention knee*: the smallest number $k^\ast$ of highest-weighted keys per query that a transformer may keep, in every layer, while still retaining at least $98\%$ of its full-attention next-token accuracy. We measured it on a pretrained 24-layer, 0.5-billion-parameter language model with grouped-query attention (two key–value heads), in full precision on held-out encyclopedic text. At context lengths $512$, $1024$ and $2048$ the knee is $k^\ast = 16, 32, 24$. That is $24$, $24$ and $64$ times below the law $k^\ast \approx d\cdot\mathrm{ctx}/32$ (with $d$ the depth) that had described a long series of synthetic toy transformers. Random selection at matched budget loses $68$–$82$ accuracy points, an order of magnitude more than in the toy family. We give a mathematical account of three structural mechanisms behind these observations.

1. **Depth Sandwich.** For per-layer deficits $\delta_l\in[0,1]$ with total $D=\sum_l\delta_l$, the compounded retention satisfies $1-D\le\prod_l(1-\delta_l)\le 1/(1+D)$. The retention gate therefore constrains only the total deficit. From this we derive that the toy knee is linear in depth, and that it *collapses* to a depth-independent bound when only $m$ layers carry a heavy tail.
2. **Context Monotonicity and Saturation.** For a fixed positive sorted attention profile the knee is non-decreasing in the context length, and under geometric decay it is eventually constant. A strictly declining knee certifies a change of profile. The measured fail/pass grid does not certify a decline: it is equally consistent with a flat plateau at $24$.
3. **Selection Gap.** The top-$k$ share of a sorted profile is at least the uniform share $k/n$. For profiles confined to a band $[c,M]$ the excess is at most $k(M-c)/(nc)$. At a knee it is at least $g-k^\ast/n$, which exceeds $0.968$ at the measured operating point.

A Cauchy–Schwarz bound in terms of effective support converts the measured per-layer concentration map into mass statements. Any $24$-key truncation of the most diffuse layer keeps less than $43.3\%$ of its attention mass. A median layer needs at least $12$ keys to keep $98\%$ of its mass.

---

## 1. Introduction

Autoregressive transformers store, for every past position, a key and a value vector in every layer (the *KV cache*). Generating each new token requires reading the whole cache, so at long contexts decoding is dominated by memory traffic. A large body of engineering work — sparse attention, heavy-hitter retention, attention-sink windows, score-based cache compression — exploits the empirical fact that attention is concentrated on few keys. Two quantitative questions remain open:

* *How few keys suffice*, under a fixed and strict notion of "lossless"?
* *How does that number scale* with depth and context?

An earlier programme of 48 controlled experiments on small synthetic transformers measured the knee under a fixed protocol: a $0.98$ accuracy-retention gate, oracle top-$k$ selection from the model's own attention scores, and a held-out evaluation. It found an approximately bilinear law,
$$
k^\ast_{\text{toy}}\;\approx\;\frac{d\cdot\mathrm{ctx}}{32},
$$
which grows both with depth $d$ and with context length $\mathrm{ctx}$. This paper reports what happens under the identical protocol on a real pretrained model. It then develops the mathematics that explains why the toy law fails in exactly the way it does.

### 1.1 Summary of measurements

The model is a 24-layer, 0.5B-parameter pretrained transformer with grouped-query attention (two KV heads) and a vocabulary of about 151k tokens. Evaluation uses the last $10\%$ of the wikitext-103 corpus, which the model never saw during this study (zero training). All computation is in 32-bit floating point. Before any measurement the custom forward pass, which supports top-$k$ masking, was validated against the reference eager implementation, with maximum absolute logit difference $0.0000$. The evaluation is deterministic: an independent re-run reproduced the baseline accuracy $0.4787$ and loss $2.6355$ exactly.

**Table 1. Measured knees (gate $g=0.98$ on retained accuracy).**

| ctx | full accuracy | $k^\ast$ | certified bracket | toy $d\cdot\mathrm{ctx}/32$ | ratio |
|---|---|---|---|---|---|
| 512 | 0.4460 | 16 | $(8,16]$ | 384 | $1/24$ |
| 1024 | 0.4612 | 32 | $(16,32]$ | 768 | $1/24$ |
| 2048 | 0.4787 | 24 | $(16,24]$ | 1536 | $1/64$ |

**Retained-accuracy sweeps** (fraction of full accuracy):

* ctx 512: $k=8$: $0.9617$ (fail), $k=16$: $0.9834$ (pass, $+0.44$ SE above the gate), …, $k=192$: $0.9997$.
* ctx 1024: $k=16$: $0.9771$ (fail, $-0.55$ SE), $k=32$: $0.9912$ (pass), …, $k=384$: $1.0003$.
* ctx 2048: $k=4$: $0.8762$, $k=8$: $0.9408$, $k=16$: $0.9708$ (fail, $-2.5$ SE), $k=24$: $0.9818$ (pass, $+0.5$ SE), $k=32$: $0.9867$, …, $k=768$: $0.9997$.

Binomial standard errors are $0.17$–$0.35\%$. Loss tracks accuracy at every budget.

**Baselines at matched $k$.** Random-$k$ selection is worse than oracle top-$k$ by $+82.0, +71.8, +81.9, +70.0, +79.9, +68.0$ accuracy points across the tested cells. Over all 48 toy experiments the corresponding gap had ranged over only $+1.7$ to $+11.7$. Local-window selection (the $k$ most recent keys) is worse by $40$–$55$ points. At ctx $2048$ a $256$-key local window retains only $0.598$ of full accuracy, while oracle top-$32$ retains $0.9867$ with $8\times$ fewer keys.

**Depth-resolved concentration.** Define the effective support of an attention distribution $p$ as $N_{\text{eff}}=1/\sum_i p_i^2$. The median layer has $N_{\text{eff}}\approx 10$–$12$ keys, *independent of context* from $512$ to $2048$. (In the toy family the corresponding figure grew from $46$ to $526$.) The minimum is about $2.9$ keys, attained in the 17th layer. Only the last two layers, which we call L22 and L23 (counting from zero), are diffuse. Their effective supports are $51\to83\to128.5$ and $33\to50\to72$ across the three contexts: sub-linear growth. Even L22 at ctx $2048$ is $3.9\times$ less diffuse than the *mean* toy layer.

**Practical reading.** At ctx $2048$ an oracle working set of $24$ rows out of $2048$ means $85\times$ fewer KV reads per query, reported as a $64\times$ reduction in KV bytes per sequence. A deployable method requires a cheap online selector. The oracle-to-policy gap is left to future work.

### 1.2 What needs explaining

The data show three departures from the toy law:

* **(A) Depth-multiplier collapse.** The ratio $1/24 = 1/d$ at the two shorter contexts says that the factor $d$ in the toy law is simply absent.
* **(B) Sub-linear, saturating context dependence.** The knee doubles from $512$ to $1024$ but not from $1024$ to $2048$.
* **(C) Selection inflation.** The importance of choosing *which* keys to keep is an order of magnitude larger than in the toy family.

Sections 3–6 give one structural result for each, plus a bridge from effective support to mass. Section 7 discusses scope and limitations.

---

## 2. Definitions

Throughout, $g\in(0,1)$ denotes a gate (retention threshold); in all applications $g=\tau=0.98$.

**Definition 2.1 (Sorted profile; head mass; retained fraction).** A *profile* is a sequence $w=(w_0,w_1,w_2,\dots)$ of positive reals. It is *sorted* if $w_{i+1}\le w_i$ for all $i$. The *head mass* of length $n$ is $H(n)=\sum_{i<n}w_i$. For a context of length $n\ge1$ and a budget $k\ge0$, the *retained fraction* is
$$
\rho(n,k)\;=\;\frac{H(\min(k,n))}{H(n)}\in[0,1].
$$
When $w$ lists one query's attention weights in decreasing order, $\rho(n,k)$ is the attention mass kept by top-$k$ truncation, renormalised to the first $n$ keys.

**Definition 2.2 (Knee).** The knee at context $n$ and gate $\tau\le1$ is
$$
k^\ast(n,\tau)\;=\;\min\{k\in\mathbb N:\ \rho(n,k)\ge\tau\}.
$$
It is well defined because $\rho(n,n)=1$.

**Definition 2.3 (Deficits and compounded retention).** A stack of layers indexed by a finite set $S$ has *per-layer deficits* $\delta_l\in[0,1]$. Its *compounded retention* is $R=\prod_{l\in S}(1-\delta_l)$, and its *total deficit* is $D=\sum_{l\in S}\delta_l$. If the deficits depend on the budget, $\delta_l=\delta_l(k)$, the *depth-compounded knee* is $k^\ast_{\text{depth}}=\min\{k:\ R(k)\ge g\}$.

**Definition 2.4 (Toy tail deficit).** For a tail scale $c>0$, the *power-law tail deficit* at budget $k$ is $\delta(k)=c/(c+k)$. It lies in $(0,1]$ and decreases in $k$ like a power law, $\delta(k)\sim c/k$.

**Definition 2.5 (Selection gap).** For a profile $w$, the *selection gap* is $\Gamma(n,k)=\rho(n,k)-k/n$. Here $k/n$ is the expected mass fraction captured by a uniformly random $k$-subset of the first $n$ keys, so $\Gamma$ measures what oracle selection gains over random selection, in mass units.

**Definition 2.6 (Collision mass; effective support).** For a nonnegative vector $p$ on a finite set $S$, its *collision mass* is $C(p)=\sum_{i\in S}p_i^2$. When $C(p)>0$, its *effective support* is $N_{\text{eff}}(p)=1/C(p)$. For a probability vector, $N_{\text{eff}}=|S|$ when $p$ is uniform and $N_{\text{eff}}=1$ when $p$ is a point mass.

---

## 3. Depth: the sandwich, the toy multiplier, and its collapse

### 3.1 The sandwich

**Theorem 3.1 (Weierstrass lower bound).** If $\delta_l\in[0,1]$ for all $l\in S$, then $1-D\le R$.

*Proof sketch.* Induct on $S$. Adding a layer $j$ with deficit $\delta$ to a stack with retention $P\ge 1-\Sigma$ (where $\Sigma\ge0$) gives
$$
(1-\delta)P\;\ge\;(1-\delta)(1-\Sigma)\;=\;1-\delta-\Sigma+\delta\Sigma\;\ge\;1-(\delta+\Sigma).
$$
The first step uses $1-\delta\ge0$; the last uses $\delta\Sigma\ge0$. $\square$

**Lemma 3.2.** Under the same hypotheses, $0\le R\le1$.

**Theorem 3.3 (Upper bound).** If $\delta_l\in[0,1]$ for all $l$, then $R\,(1+D)\le1$.

*Proof sketch.* Induct on $S$. With $P,\Sigma$ for the smaller stack and $\delta$ for the new layer,
$$
(1-\delta)P\,(1+\delta+\Sigma)\;=\;(1-\delta)\,P(1+\Sigma)\;+\;\delta(1-\delta)P.
$$
By induction $P(1+\Sigma)\le1$, so the first term is at most $1-\delta$. By Lemma 3.2 $P\le1$, so the second term is at most $\delta(1-\delta)\le\delta$. The sum is at most $1$. $\square$

**Corollary 3.4 (Depth Sandwich).** For deficits in $[0,1]$,
$$
1-D\;\le\;\prod_{l\in S}(1-\delta_l)\;\le\;\frac1{1+D}.
$$

**Corollary 3.5 (The gate constrains only the total deficit).**
(i) *Sufficiency:* if $D\le1-g$, then $R\ge g$.
(ii) *Necessity:* if $R\ge g$, then $g\,D\le 1-g$.

*Proof.* (i) is immediate from Theorem 3.1. For (ii), multiply $g\le R$ by $1+D\ge 0$ and apply Theorem 3.3. $\square$

At $g=0.98$ the window is $D\in[0.0200,\,0.0204]$: the two conditions agree to within $2\%$ of each other. Up to the constant factor $g$, *passing the gate is the same as having total deficit at most $1-g$.* The order of layers, and how the deficit is spread across them, are irrelevant to first order.

### 3.2 The toy depth multiplier

**Theorem 3.6 (Toy knee is linear in depth).** Suppose all $d=|S|$ layers carry the tail deficit $\delta(k)=c/(c+k)$, and $0<g<1$. Then every passing budget $k$ satisfies
$$
\frac{g\,d\,c}{1-g}-c\;\le\;k,
$$
and every $k\ge d c/(1-g)$ passes. Consequently
$$
\frac{g\,d\,c}{1-g}-c\;\le\;k^\ast_{\text{depth}}\;\le\;\Big\lceil\frac{d\,c}{1-g}\Big\rceil.
$$

*Proof sketch.* Here $D(k)=d\,c/(c+k)$. Necessity (Corollary 3.5(ii)) gives $g\,d\,c\le(1-g)(c+k)$, which rearranges to the lower bound. If $k\ge dc/(1-g)$ then $dc\le(1-g)k\le(1-g)(c+k)$, i.e. $D(k)\le1-g$, and sufficiency applies. The set of passing budgets is nonempty, so its minimum obeys both bounds. $\square$

The window has width about $c\,(1+d)$ relative to a center of order $50\,d\,c$ at $g=0.98$, so the knee is pinned to within a few percent. The factor $d$ is the *depth multiplier*. It arises because every layer draws on the single shared deficit budget $1-g$.

### 3.3 Collapse of the depth multiplier

**Theorem 3.7 (Depth-multiplier collapse).** Let $T\subseteq S$ with $|T|=m$. Assume:

* $\delta_l(k)\in[0,1]$ for all $l\in S$ and all $k$;
* $\delta_l(k)\le c/(c+k)$ for $l\in T$ (the tail layers);
* $\delta_l(k)=0$ whenever $l\notin T$ and $k\ge k_0$ (the other layers are lossless beyond $k_0$).

Then
$$
k^\ast_{\text{depth}}\;\le\;\max\Big(k_0,\ \Big\lceil\frac{m\,c}{1-g}\Big\rceil\Big),
$$
**uniformly in the depth $|S|$.**

*Proof sketch.* Let $K$ be the right-hand side. At budget $K$, every layer outside $T$ contributes $0$ to $D$, so $D(K)=\sum_{l\in T}\delta_l(K)\le m\,c/(c+K)$. Since $K\ge mc/(1-g)$, this is at most $1-g$. Corollary 3.5(i) gives $R(K)\ge g$. $\square$

**Interpretation.** The measured concentration map supplies the hypotheses. The median layer has effective support of about $10$–$12$ keys, independent of context (so $k_0$ is of that order, see Section 6). Only $m=2$ layers are diffuse. Theorem 3.7 then replaces the toy multiplier $d=24$ by $m=2$, and the dependence on the full depth disappears. This is the mathematical form of observation (A). If moreover the tail scale $c$ does not grow with context, the bound is context-independent as well. That is consistent with observation (B).

---

## 4. Context: monotonicity, the brackets, and saturation

Fix a positive profile $w$.

**Theorem 4.1 (Retained mass is antitone in context).** If $0<n\le m$, then $\rho(m,k)\le\rho(n,k)$ for every $k$.

*Proof sketch.* If $k\le n$, both fractions have numerator $H(k)$, and the denominators satisfy $H(n)\le H(m)$ because the weights are positive. If $k>n$, then $\rho(n,k)=1\ge\rho(m,k)$. $\square$

**Theorem 4.2 (The knee is monotone in context).** If $0<n\le m$ and $\tau\le1$, then $k^\ast(n,\tau)\le k^\ast(m,\tau)$.

*Proof sketch.* The knee budget at context $m$ passes at $m$. By Theorem 4.1 it also passes at $n$, so it is at least the minimum passing budget at $n$. $\square$

**Corollary 4.3 (A declining knee forces a change of profile).** If two positive profiles $w,w'$ and contexts $n\le m$ satisfy $k^\ast_{w'}(m,\tau)<k^\ast_w(n,\tau)$, then $w'\ne w$.

So any strict decline of the knee with context is a certificate that the attention profile depends on the context length, not merely that it is extended. That is plausible for a real model, but it is a strong claim, and it needs data that actually certify a decline.

**Proposition 4.4 (The measured brackets).** Let $\mathrm{ret}_1,\mathrm{ret}_2$ be the retained-accuracy curves at contexts $1024$ and $2048$. Assume each is *threshold-monotone*: there are knees $k_1,k_2$ with $\mathrm{ret}_i(k)\ge0.98\iff k\ge k_i$. Then the observed values
$$
\mathrm{ret}_1(16)<0.98\le\mathrm{ret}_1(32),\qquad\mathrm{ret}_2(16)<0.98\le\mathrm{ret}_2(24)
$$
imply $k_1\in(16,32]$ and $k_2\in(16,24]$. These intervals overlap (for instance at $24$).

*Proof.* Each pass gives an upper bound and each fail a strict lower bound, by threshold-monotonicity. $\square$

**Consequence.** The reported step $32\to24$ is *not certified* by the grid. The data are consistent with $k^\ast(1024)=k^\ast(2048)=24$, a flat plateau. The honest reading of observation (B) is therefore "saturation, possibly with a decline", not "decline".

**Theorem 4.5 (Uniform bound under geometric decay).** Suppose $w$ is positive and $w_{i+1}\le r\,w_i$ for some $0<r<1$, and let $\tau<1$. Then there is a $B$ such that $k^\ast(n,\tau)\le B$ for every $n\ge1$.

*Proof sketch.* For $k<n$, the mass outside the top $k$ is $\sum_{k\le i<n}w_i\le w_0\,r^k/(1-r)$, and $H(n)\ge w_0$. Hence $1-\rho(n,k)\le r^k/(1-r)$. Choose $B$ with $r^B/(1-r)\le1-\tau$. For $n\le B$ the budget $B$ passes trivially. $\square$

**Theorem 4.6 (Saturation).** Under the hypotheses of Theorem 4.5, the knee sequence is eventually constant: there are $K$ and $N$ such that $k^\ast(n,\tau)=K$ for all $n\ge N$.

*Proof sketch.* By Theorem 4.2 the sequence $n\mapsto k^\ast(n,\tau)$ is non-decreasing, and by Theorem 4.5 it is bounded. A non-decreasing bounded sequence of natural numbers attains its supremum and then stays there. $\square$

**Contrast with heavy tails.** For a power-law profile $w_i=(i+1)^{-a}$ with $a$ slightly above $1$, the tail beyond $k$ decays only polynomially, and the knee grows without bound in $n$. Numerically, with $a=1.1$ and $\tau=0.98$, the knee is about $422$ at $n=512$, $821$ at $1024$ and $1594$ at $2048$. That is roughly linear growth, as in the toy law. A geometric profile with $r=0.8$ has knee $18$ at every $n\ge64$. Theorem 4.6 thus turns a *qualitative* question about larger models into a test. A knee that fails to saturate refutes geometric decay of the sorted attention profile.

---

## 5. Selection: why oracle choice matters an order of magnitude more

**Lemma 5.1 (Chebyshev prefix inequality).** If $w$ is sorted and nonnegative and $k\le n$, then
$$
k\,H(n)\;\le\;n\,H(k).
$$
Equivalently, the average of the top $k$ weights is at least the average of the top $n$.

*Proof sketch.* Induct on $n\ge k$; the base case $n=k$ is trivial. Since $w_i\ge w_n$ for all $i<k\le n$, we have $k\,w_n\le H(k)$. Then $k\,H(n+1)=k\,H(n)+k\,w_n\le n\,H(k)+H(k)=(n+1)H(k)$. $\square$

**Theorem 5.2 (Top-$k$ beats uniform).** If $w$ is positive and sorted and $0\le k\le n$, $n\ge1$, then $\rho(n,k)\ge k/n$. Equivalently, $\Gamma(n,k)\ge0$.

**Theorem 5.3 (Gapless profiles have vanishing selection gap).** If $c\le w_i\le M$ for all $i$, with $c>0$, then for $k\le n$
$$
\Gamma(n,k)\;\le\;\frac{k\,(M-c)}{n\,c}.
$$

*Proof sketch.* $H(n)\ge nc$ and $H(k)\le kM$, so $\rho(n,k)\le kM/(nc)$. Subtracting $k/n=kc/(nc)$ gives the bound. $\square$

**Theorem 5.4 (Selection gap at a knee).** For any positive profile and $\tau\le1$,
$$
\Gamma\big(n,k^\ast(n,\tau)\big)\;\ge\;\tau-\frac{k^\ast(n,\tau)}{n}.
$$

*Proof.* By definition $\rho(n,k^\ast)\ge\tau$. Subtract $k^\ast/n$. $\square$

**Corollary 5.5 (The measured operating point).** If a positive profile has $k^\ast(2048,0.98)=24$, then
$$
\Gamma(2048,24)\;>\;0.968.
$$
By contrast, every positive profile with $c\le w_i\le M\le 2c$ has $\Gamma(2048,24)<0.012$.

*Proof.* $0.98-24/2048=0.968281\ldots>0.968$. For the band case, Theorem 5.3 gives $\Gamma\le 24(M-c)/(2048c)\le24/2048=0.01171\ldots<0.012$. $\square$

**Interpretation.** These statements are about attention *mass*. The measured gaps are about *accuracy*, so the correspondence is one of shape, not of identity. The shape matches observation (C). A small knee at long context *is* a large selection gap, and a profile flat enough to make random selection competitive *cannot* have a small knee. The toy family's moderate selection gaps ($\le 11.7$ points) and its large knees are two views of the same diffuse attention. The real model's $70$–$82$ point gaps and its knee of $24$ out of $2048$ are two views of the same concentrated attention.

---

## 6. The depth map in mass units

The following inequality is Cauchy–Schwarz applied to the indicator of $T$.

**Lemma 6.1 (Subset mass versus collision mass).** For $p\ge0$ on $S$ and $T\subseteq S$,
$$
\Big(\sum_{i\in T}p_i\Big)^2\;\le\;|T|\cdot C(p).
$$

**Theorem 6.2 (Mass bound from effective support).** If $N_{\text{eff}}(p)=N>0$ and $|T|\le k$, then
$$
\Big(\sum_{i\in T}p_i\Big)^2\;\le\;\frac{k}{N}.
$$

**Corollary 6.3 (The most diffuse layer at the knee).** In a layer with $N_{\text{eff}}=128.5$ (the measured value for L22 at ctx $2048$), any set of at most $24$ keys carries less than $43.3\%$ of the layer's attention mass.

*Proof.* $\sqrt{24/128.5}=0.43217\ldots<0.433$. $\square$

**Corollary 6.4 (The median-layer mass knee).** In a layer with $N_{\text{eff}}=12$, any key set carrying at least $98\%$ of the mass has at least $12$ elements.

*Proof.* By Lemma 6.1, $|T|\ge(0.98)^2\cdot12=11.52\ldots$, so $|T|\ge12$. $\square$

**Interpretation.** Corollary 6.4 says the mass knee of a typical layer is at least $12$ and does not depend on context. That is the same order as the measured accuracy knees $16$–$32$. Corollary 6.3 says that at the accuracy knee the diffuse layer L22 is losing *more than half* of its attention mass, yet the model stays within $2\%$ of full accuracy. So *mass knees and accuracy knees separate* in the tail layers. Either the dropped mass carries little decision-relevant signal, or the downstream logit margin absorbs it. This motivates the per-layer ablation proposed in Section 8.

---

## 7. Discussion

### 7.1 What is structural and what is empirical

The results above are deliberately structural. They say which features of the measurement are *forced* by simple hypotheses and which are not.

* The sandwich (Corollary 3.4) is unconditional. It makes the gate a constraint on a sum, so *any* model whose per-layer deficits are concentrated in a few layers will have a depth-independent knee (Theorem 3.7). The toy law's factor $d$ is the special case in which every layer has a heavy tail.
* Monotonicity (Theorem 4.2) is unconditional for a fixed profile. Saturation (Theorem 4.6) follows from geometric decay. A strict decline requires the profile itself to change with context, and the present data do not certify one (Proposition 4.4).
* The selection gap theorems (Section 5) connect knee size and random-selection loss with no model-specific input.

The empirical content is that a real pretrained model actually satisfies the concentrated-majority hypothesis. That is the depth map: a median effective support of about $10$–$12$ keys, independent of context, with only two diffuse layers.

### 7.2 Relation to existing practice

Keeping heavy-hitter keys, keeping attention sinks plus a recent window, and compressing caches by observed scores are all established techniques. What is new here is the set of measured laws under a fixed, strict retention protocol: the depth-multiplier collapse, the plateau shape at roughly $\mathrm{ctx}/32$ and below, the tenfold inflation of the selection gap relative to synthetic models, and the depth-resolved concentration map. The mathematics shows how these laws fit together.

### 7.3 Limitations

* **One model, one size, one corpus.** A second corpus was planned but was unavailable during the run, and wikitext-103 was used instead.
* **Razor-thin knees.** The passes at ctx $512$ and $2048$ clear the gate by about $0.44$ and $0.5$ standard errors.
* **Unpinned bracket.** $k^\ast(1024)\in(16,32]$ was not resolved at $24$. The apparent decline may be a plateau.
* **Oracle, not policy.** Top-$k$ is chosen from the model's own current scores. A deployable selector must predict these, and its gap from the oracle is unmeasured.
* **Mass versus accuracy.** The selection-gap and depth-map theorems are stated in attention-mass units. They explain the *shape* of the accuracy measurements, not their exact values.

---

## 8. Future work

1. **Two-layer tail additivity.** Corollary 3.5 says the gate sees only $\sum_l\delta_l$. Pruning only L22 and L23 (all other layers dense) should therefore give a joint knee within one grid step of the full-model knee. If it does not, deficits interact non-additively.
2. **Accuracy–mass separation in diffuse layers.** Corollary 6.3 shows L22 loses over half its mass at the knee. Measuring per-token logit margins would test whether the margin exceeds the perturbation caused by the dropped tail, and so explain the separation.
3. **Size-invariant saturation plateau.** For larger models in the same family (1.5B, 7B), test whether $k^\ast(\mathrm{ctx})$ becomes constant at a plateau of at most about $32$ by ctx $2048$. By Theorem 4.6, a non-saturating knee would refute geometric decay of the sorted attention profile.
4. **Oracle-to-policy gap.** Compare online accumulated-score eviction with the oracle upper bound under the same gate.
5. **Corpus robustness and quantization.** Repeat on other corpora, and combine top-$k$ attention with weight quantization on the same harness to map joint memory floors.

---

## 9. Conclusion

On a real pretrained transformer the lossless attention knee is tiny ($16$–$32$ keys) and roughly flat in context. It lies $24$–$64$ times below a law extrapolated from synthetic models. Three elementary results explain the departure:

* a product of per-layer retentions is sandwiched by the total deficit, so depth enters only through *how many* layers have heavy tails;
* a fixed attention profile can only produce a non-decreasing knee, and geometric decay forces it to saturate;
* a small knee and a large selection gap are the same phenomenon.

The measured concentration map, with about a dozen keys in a typical layer and only two diffuse layers, supplies exactly the hypotheses these results need.
