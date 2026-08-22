# Margins, Not Angles: Decision–Vector Dissociation in the Shared Core and Personal Tail of Fine-Tuned Transformers

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

We study the internal relationship between a pretrained transformer and a
fine-tune of it, and give a complete structural account of three phenomena
observed when comparing their layerwise attention caches: (i) the bottom of the
stack is *exactly* shared, (ii) the layerwise divergence between the two models
is **hump-shaped** rather than monotone, rising to a peak around two-thirds
depth and then falling, and (iii) in the final two layers the two models'
top-1 attention decisions agree only about $57\%$–$63\%$ of the time even though
their cached key vectors have cosine similarity $0.983$–$0.988$.

The third phenomenon is the sharpest. We prove that it is not an anomaly but a
theorem about score vectors. The correct stability certificate for a top-1
decision is a **margin**: if a score vector $u$ holds its top choice by a gap
exceeding $2\varepsilon$ and a second vector $v$ agrees with $u$ to within
$\varepsilon$ in every coordinate, then $v$ makes the same choice; and the
constant $2$ is sharp. By contrast, **no** function of cosine similarity alone
can lower-bound decision agreement: for every $\varepsilon > 0$ there are two
score vectors of cosine similarity greater than $1 - \varepsilon$ that decide
differently. We call this the *decision–vector dissociation*.

We then explain *where* the dissociation bites. Bounding the top attention
weight by the square root of the collision mass $\sum_k p_k^2$ shows that
diffuse attention necessarily has a small margin, hence is flippable by an
arbitrarily small perturbation. Independently, we prove a two-sided bridge
between the margin and the **Maslov gap** $\log\sum_j e^{x_j} - x_i$ — the
standard measure of how far a softmax is from a tropical (max-plus) operation —
so that "far from tropical", "diffuse", and "decision-fragile" are three names
for one inequality. This unifies three separate measurements of the same
network.

The hump receives an equally clean explanation. Under the recursion
$d_{k+1} \le L_k d_k + \varepsilon$ governing divergence propagation, any
downward step exceeding the injected delta *certifies* that the shared layer map
contracts; monotone divergence was never an axiom, and its failure is exactly
contractivity. The measured constants force a quantitative dichotomy: either the
tail contracts by a factor of at most $4/5$, or the tail carries a total delta
budget of at least $0.057$, forcing some single layer to inject at least
$0.008$.

Finally we develop the engineering consequence. Serving $n$ fine-tunes with $s$
of $L$ layers shared costs $s + n(L-s)$, with amortized per-model ratio tending
to the tail fraction $(L-s)/L$ — equal to $1/12$ for $22$ of $24$ layers — while
a margin certificate on the shared layers guarantees a provable decision
agreement fraction of at least $11/12$. An error-budget recursion yields a
**depth law**: with nonexpansive layers, per-layer delta $\varepsilon$, and
margin $m$, every layer of depth $k < m/(2\varepsilon)$ is certifiably
shareable; and if the layers do not contract and the margin profile does not
increase with depth, the shareable layers form an initial segment — sharing is a
prefix property, exactly the empirical "core shared, tail personal" shape.

**Keywords:** attention margin, decision stability, cosine similarity, Maslov
dequantization, tropical geometry, collision mass, key–value cache sharing,
fine-tuning delta, contraction certificate.

---

## 1. Introduction

### 1.1 The question

Fine-tuning modifies every weight of a pretrained transformer, usually by a
small amount. A natural mental model of what this does to the network's internal
state is *cumulative drift*: perturbations injected at each layer propagate
upward and compound, so the distance between the base model's activations and
the fine-tune's activations should increase monotonically with depth, and the
two models should behave increasingly differently the closer one gets to the
output.

Measurement contradicts this picture twice over. On a 24-layer transformer
compared against an instruction-tuned version of itself, on identical held-out
prompts:

* **Layer 0 keys are exactly identical** (cosine similarity $1.0000$).
* **Every layer keeps cosine similarity $\ge 0.976$** for keys (mean $0.990$);
  values sit in $0.94$–$0.99$.
* **The divergence is a hump.** Relative key divergence climbs to $0.217$ at
  layer 16 and falls back to about $0.16$; hidden-state divergence peaks near
  $0.22$ at layers 12–16.
* **Mean top-1 attention decision agreement is $0.894$** across layers, but it
  collapses to $0.568$ at layer 22 and $0.627$ at layer 23 — while those same
  layers' key cosine similarities are $0.983$ and $0.988$.

The last bullet is the crux. It says, in the sharpest possible form, that
**vector similarity does not bound functional divergence**. A pair of layers
whose caches are geometrically almost indistinguishable can nonetheless make
almost independent decisions.

### 1.2 Contributions

This paper isolates the mathematics behind each observation, in a form that is
independent of any particular model, prompt set, or numerical precision.

1. **The correct certificate is a margin** (Theorem 3.1), and the constant $2$
   in the margin condition is sharp (Theorem 3.2).
2. **Cosine similarity certifies nothing** (Theorem 4.3): for every
   $\varepsilon > 0$ there exist score vectors with cosine similarity above
   $1 - \varepsilon$ and different top-1 decisions. Consequently the measured
   tail point (cosine $0.983$, agreement $0.568$) violates no inequality.
3. **Diffuse attention is decision-fragile** (Theorems 5.1–5.2): the top weight
   of a nonnegative vector is at most the square root of its collision mass, and
   a perturbation of that size suffices to move the decision to any prescribed
   index.
4. **A two-sided margin/Maslov-gap bridge** (Theorems 6.2–6.4 and Corollary 6.6):
   large margin implies near-tropical behaviour; a Maslov gap of $g \ge 1$ caps
   the margin at $\log(n-1) + \log 2 - g$; and small margins are flippable. Hence
   *far-from-tropical $\Leftrightarrow$ diffuse $\Leftrightarrow$ fragile*.
5. **The hump is a contraction certificate** (Theorem 7.4), with an explicit
   numerical dichotomy for the measured constants (Corollaries 7.6–7.8).
6. **A sharing budget and a depth law** (Section 8): the error budget recursion,
   the prefix property of shareability, and the tight depth bound
   $k < m/(2\varepsilon)$.
7. **A serving law and a causal prediction** (Sections 9–10): amortized memory
   ratio $(L-s)/L$, provable agreement fraction $|S|/L$, and the predicted
   outcome of a tail-swap experiment.

Throughout, no bound is asymptotic and every constant is explicit.

---

## 2. Setup and definitions

Fix $n \ge 1$ and work with real **score vectors** $u \in \mathbb{R}^n$, thought
of as the pre-softmax attention logits of one layer over $n$ candidate
positions.

**Definition 2.1 (Decision).** An index $i$ is the *strict top* (the
*decision*) of $u$, written $\operatorname{Top}(u) = i$, if
$$u_j < u_i \quad \text{for all } j \neq i.$$
We say $u$ has *no decision* if no index is a strict top, i.e. if the maximum is
attained at least twice.

**Definition 2.2 (Margin).** The *margin* of $u$ at $i$ is
$\min_{j \neq i}(u_i - u_j)$. A statement "$u$ has margin at least $m$ at $i$"
means $u_i - u_j \ge m$ for all $j \neq i$.

**Definition 2.3 (Uniform perturbation).** Two vectors are *$\varepsilon$-close*
if $|u_j - v_j| \le \varepsilon$ for every $j$, i.e. $\|u - v\|_\infty \le
\varepsilon$.

**Definition 2.4 (Cosine similarity).** For nonzero $u, v$,
$$\cos(u,v) \;=\; \frac{\langle u, v\rangle}{\|u\|_2\,\|v\|_2}
\;=\; \frac{\sum_i u_i v_i}{\sqrt{\sum_i u_i^2}\,\sqrt{\sum_i v_i^2}}.$$

**Definition 2.5 (Collision mass).** For a nonnegative vector $p$ (typically a
post-softmax attention distribution), its *collision mass* is
$C(p) = \sum_k p_k^2$. For a distribution this is the probability that two
independent draws coincide; it equals $1$ for a point mass and $1/m$ for the
uniform distribution on $m$ atoms.

**Definition 2.6 (Maslov gap).** With
$\operatorname{lse}(x) = \log \sum_j e^{x_j}$, the *Maslov gap* of $x$ at $i$ is
$$\gamma(x, i) \;=\; \operatorname{lse}(x) - x_i .$$
It measures how far the soft aggregate is above the coordinate $x_i$; when $i$
is the argmax, $\gamma$ measures the failure of softmax to be a hard max, i.e.
the distance from tropical (max-plus) arithmetic.

---

## 3. The correct stability certificate is a margin

**Theorem 3.1 (Margin stability).** *Let $u, v \in \mathbb{R}^n$, let $i$ be an
index, and let $\varepsilon \in \mathbb{R}$. Suppose*
$$u_i - u_j > 2\varepsilon \quad \text{for all } j \neq i,
\qquad |u_j - v_j| \le \varepsilon \quad \text{for all } j.$$
*Then $\operatorname{Top}(v) = i$.*

*Proof.* Fix $j \neq i$. From $|u_j - v_j| \le \varepsilon$ we get
$v_j \le u_j + \varepsilon$, and from $|u_i - v_i| \le \varepsilon$ we get
$v_i \ge u_i - \varepsilon$. Hence
$$v_i - v_j \;\ge\; (u_i - \varepsilon) - (u_j + \varepsilon)
\;=\; (u_i - u_j) - 2\varepsilon \;>\; 0. \qquad\blacksquare$$

The factor $2$ arises because a perturbation may simultaneously depress the
leader and elevate a challenger. It cannot be improved.

**Theorem 3.2 (Sharpness of the factor 2).** *For every $\varepsilon > 0$ there
exist $u, v \in \mathbb{R}^2$ such that $u_0 - u_1 = 2\varepsilon$ exactly,
$|u_j - v_j| \le \varepsilon$ for both $j$, $\operatorname{Top}(u) = 0$, and $v$
has no decision at all.*

*Proof.* Take $u = (2\varepsilon, 0)$ and $v = (\varepsilon, \varepsilon)$. The
gap of $u$ is exactly $2\varepsilon$; each coordinate moves by exactly
$\varepsilon$; and $v$ ties, so no index is a strict top. $\blacksquare$

Thus the hypothesis "gap $> 2\varepsilon$" in Theorem 3.1 is exactly at the
boundary: with strict inequality the decision survives, with equality it can
already be destroyed.

**Corollary 3.3 (All-layer agreement from a uniform margin).** *Let
$u^{(1)},\dots,u^{(L)}$ and $v^{(1)},\dots,v^{(L)}$ be the per-layer score
vectors of two models and let $i^{(l)}$ be indices. If for every layer $l$ the
reference model satisfies $u^{(l)}_{i^{(l)}} - u^{(l)}_j > 2\varepsilon$ for all
$j \neq i^{(l)}$, and $\|u^{(l)} - v^{(l)}\|_\infty \le \varepsilon$, then both
models make the decision $i^{(l)}$ at every layer $l$.*

*Proof.* Apply Theorem 3.1 layerwise to get the claim for $v$; that
$\varepsilon \ge 0$ (forced by $|u^{(l)}_j - v^{(l)}_j| \le \varepsilon$) then
gives $u^{(l)}_{i^{(l)}} > u^{(l)}_j$, i.e. the claim for $u$. $\blacksquare$

This is the positive half of the empirical picture: the $22$ shared layers are
precisely the layers that carry a margin.

---

## 4. Cosine similarity certifies nothing

We now show that the natural alternative certificate — high cosine similarity of
the score vectors — is void.

**Definition 4.1 (The flip pair).** For $t > 0$ set
$$u^{(t)} = (1 + t,\ 1), \qquad v^{(t)} = (1,\ 1 + t) \;\in\; \mathbb{R}^2 .$$
Plainly $\operatorname{Top}(u^{(t)}) = 0$ and $\operatorname{Top}(v^{(t)}) = 1$:
the two vectors disagree completely.

**Lemma 4.2 (Cosine of the flip pair).** *For all $t \in \mathbb{R}$,*
$$\cos\!\big(u^{(t)}, v^{(t)}\big) \;=\; \frac{2 + 2t}{t^2 + 2t + 2}
\;=\; 1 - \frac{t^2}{t^2 + 2t + 2},$$
*and for $t > 0$ one has $\cos(u^{(t)}, v^{(t)}) \ge 1 - t/2$.*

*Proof.* The inner product is $(1+t)\cdot 1 + 1 \cdot (1+t) = 2 + 2t$, and each
norm squared is $(1+t)^2 + 1 = t^2 + 2t + 2$, so the product of the norms is
$t^2 + 2t + 2$; the identity follows, and the second form is obtained from
$(t^2 + 2t + 2) - (2 + 2t) = t^2$. For the bound, note that $t > 0$ gives
$t^2 + 2t + 2 > 2t > 0$, hence
$$1 - \cos\!\big(u^{(t)}, v^{(t)}\big) = \frac{t^2}{t^2 + 2t + 2}
< \frac{t^2}{2t} = \frac{t}{2}. \qquad\blacksquare$$

**Theorem 4.3 (Decision–vector dissociation).** *For every $\varepsilon > 0$
there exist $u, v \in \mathbb{R}^2$ with*
$$\cos(u, v) > 1 - \varepsilon, \qquad
\operatorname{Top}(u) = 0, \qquad \operatorname{Top}(v) = 1 .$$

*Proof.* Take $t = \varepsilon$ and $u = u^{(t)}$, $v = v^{(t)}$. By Lemma 4.2,
$\cos(u,v) \ge 1 - t/2 = 1 - \varepsilon/2 > 1 - \varepsilon$, while the
decisions are $0$ and $1$. $\blacksquare$

**Corollary 4.4 (No cosine certificate exists).** *There is no function
$\Phi : [-1,1] \to [0,1]$ with $\Phi(c) \to 1$ as $c \to 1$ such that decision
agreement is bounded below by $\Phi(\cos(u,v))$.* In particular the observed
tail configuration — cosine $0.983$ with agreement $0.568$ — is structurally
possible and refutes no inequality.

**Remark 4.5 (Where the flip sits relative to Theorem 3.1).** In the flip pair
the coordinatewise perturbation is exactly $t$ and the top-1 gap of $u^{(t)}$ is
also exactly $t$. Since $t \not> 2t$ for $t > 0$, Theorem 3.1 does not apply —
the flip happens precisely in the region the margin certificate declines to
cover. The two theorems are complementary, not in tension: the flip pair
saturates the boundary of the margin condition while sitting arbitrarily close to
cosine $1$.

The moral: **cosine similarity is a statement about direction; a decision is a
statement about order.** Small angles do not control order near a tie.

---

## 5. Why the diffuse tail is the fragile region

Dissociation is possible everywhere; the question is where it is *realised*. The
answer is: wherever the attention distribution is diffuse.

**Theorem 5.1 (Collision bound on the top weight).** *Let $p \in \mathbb{R}^n$
be nonnegative. Then for every index $i$,*
$$p_i \;\le\; \sqrt{\textstyle\sum_k p_k^2} \;=\; \sqrt{C(p)} .$$

*Proof.* $p_i^2$ is one summand of $\sum_k p_k^2$, all of whose terms are
nonnegative, so $p_i^2 \le C(p)$; take square roots, using $p_i \ge 0$.
$\blacksquare$

For an attention distribution, $C(p)$ is the collision probability, and
$1/C(p)$ is the *participation ratio* — the effective number of positions
attended to. Theorem 5.1 says the leader's weight can never exceed
$1/\sqrt{\text{effective support size}}$. Diffuse attention therefore has a
small leader, hence necessarily a small gap.

**Theorem 5.2 (Diffuse attention is decision-fragile).** *Let $p$ be
nonnegative with $\operatorname{Top}(p) = i$, let $j \neq i$ be arbitrary, and
let $\eta > 0$. Then there exists $q$ with*
$$|p_k - q_k| \le \sqrt{C(p)} + \eta \ \ \text{for all } k,
\qquad \operatorname{Top}(q) = j .$$

*Proof.* Set $q = p$ except at coordinate $j$, where $q_j = p_i + \eta$. For
$k \neq j$ the perturbation is $0$. At $k = j$ we have
$p_j < p_i$, so
$|p_j - q_j| = p_i + \eta - p_j \le p_i + \eta \le \sqrt{C(p)} + \eta$ by
Theorem 5.1 and $p_j \ge 0$. Finally, for any $k \neq j$ we have
$q_k = p_k \le p_i < p_i + \eta = q_j$, so $j$ is the strict top of $q$.
$\blacksquare$

The perturbation needed is of size $\sqrt{C(p)}$, and one may move the decision
to *any* index of one's choosing. In the diffuse tail of the measured network,
$\sqrt{C(p)}$ is comfortably below the measured relative fine-tune delta of
about $0.16$. So the tail decisions are not merely theoretically flippable; they
are flippable by a perturbation of the size actually present.

Note the contrast with Theorem 3.1: fragility does *not* require the two vectors
to be far apart in any norm, and by Theorem 4.3 the flip is compatible with
cosine similarity arbitrarily close to $1$.

---

## 6. The tropical bridge: Maslov gap $\leftrightarrow$ margin

Softmax is Maslov dequantization of the max-plus (tropical) semiring: as the
inverse temperature grows, $\operatorname{lse}$ converges to $\max$. The Maslov
gap $\gamma(x,i) = \operatorname{lse}(x) - x_i$ quantifies the residual
"softness". A separate measurement on the same 24-layer stack found that
$\gamma$ has a median close to $0$ at almost every layer, and jumps to $2.5$–$2.7$
exactly at layers 22 and 23. We now prove that this is the *same* fact as the
margin collapse.

**Lemma 6.1 (Range of the gap).** *For all $x$ and $i$, $\gamma(x,i) \ge 0$; and
if $i$ is a maximiser of $x$ then $\gamma(x,i) \le \log n$.*

*Proof.* Nonnegativity: $e^{x_i} \le \sum_j e^{x_j}$, and $\log$ is increasing.
Upper bound: if $x_j \le x_i$ for all $j$, then
$\sum_j e^{x_j} \le n e^{x_i}$, so $\operatorname{lse}(x) \le \log n + x_i$.
$\blacksquare$

So $\gamma \in [0, \log n]$: the tropical window. $\gamma = 0$ means exact
max-plus behaviour; $\gamma = \log n$ means the layer is maximally soft (uniform
scores).

**Theorem 6.2 (Margin $\Rightarrow$ near-tropical).** *If $x_i - x_j \ge m$ for
all $j \neq i$, then*
$$\gamma(x, i) \;\le\; \log\!\big(1 + (n-1)e^{-m}\big).$$

*Proof.* Split $\sum_j e^{x_j} = e^{x_i} + \sum_{j \neq i} e^{x_j}$. Each of the
$n-1$ terms in the second sum satisfies $e^{x_j} \le e^{x_i - m} = e^{x_i}e^{-m}$,
so the whole sum is at most $e^{x_i}\big(1 + (n-1)e^{-m}\big)$. Taking
logarithms and subtracting $x_i$ gives the claim. $\blacksquare$

The bound decays exponentially in $m$: large margins force near-tropical
behaviour. This is the mechanism behind the observed near-zero gaps in the
network's core.

**Theorem 6.3 (Far-from-tropical $\Rightarrow$ small margin).** *Suppose
$n \ge 2$, $x_i - x_j \ge m$ for all $j \neq i$, and the measured gap satisfies
$\gamma(x,i) \ge g > 0$. Then*
$$m \;\le\; \log(n-1) - \log\!\big(e^{g} - 1\big).$$

*Proof.* By Theorem 6.2, $g \le \gamma(x,i) \le \log(1 + (n-1)e^{-m})$;
exponentiating gives $e^g \le 1 + (n-1)e^{-m}$, hence
$(e^g - 1)/(n-1) \le e^{-m}$. Since $g > 0$ implies $e^g - 1 > 0$, taking
logarithms yields $\log(e^g - 1) - \log(n-1) \le -m$. $\blacksquare$

**Corollary 6.4 (One nat of gap costs one nat of margin).** *Under the
hypotheses of Theorem 6.3 with $g \ge 1$,*
$$m \;\le\; \log(n-1) + \log 2 - g .$$

*Proof.* For $g \ge 1 > \log 2$ we have $e^g \ge 2$, hence
$e^g - 1 \ge e^g/2$, so $\log(e^g - 1) \ge g - \log 2$; substitute into
Theorem 6.3. $\blacksquare$

At the measured tail values $g \approx 2.5$, Corollary 6.4 forces the margin
below $\log(n-1) + 0.693 - 2.5$, a genuinely small number for the context
lengths involved.

**Theorem 6.5 (Small margin $\Rightarrow$ flippable).** *Suppose $j \neq i$,
$x_i - x_j \le m$ with $m \ge 0$, and $\eta > 0$. Then there is a vector $y$
with $\|x - y\|_\infty \le (m + \eta)/2$ such that $y_i < y_j$; in particular
$\operatorname{Top}(y) \neq i$.*

*Proof.* Let $d = (m+\eta)/2 > 0$ and define $y$ to equal $x$ except
$y_i = x_i - d$ and $y_j = x_j + d$. Every coordinate moves by at most $d$. Then
$y_j - y_i = (x_j - x_i) + 2d \ge -m + (m + \eta) = \eta > 0$. $\blacksquare$

**Corollary 6.6 (Far from tropical $\Rightarrow$ fragile).** *Let $n \ge 2$,
$g \ge 1$, $\delta, \eta > 0$, and suppose $\gamma(x,i) \ge g$ and
$M := \log(n-1) + \log 2 - g + \delta \ge 0$. Then there is an index
$j \neq i$ and a vector $y$ with*
$$\|x - y\|_\infty \le \frac{M + \eta}{2}, \qquad y_i < y_j,$$
*so $y$ does not decide $i$.*

*Proof.* First, some competitor is within $M$ of the top: otherwise every
$j \neq i$ satisfies $x_i - x_j \ge M$, and Corollary 6.4 applied with margin
$M$ gives $M \le \log(n-1) + \log 2 - g = M - \delta$, a contradiction. Choose
such a $j$ and apply Theorem 6.5 with $m = M$. $\blacksquare$

Together, Theorems 6.2–6.5 close the loop:

$$\text{large margin} \iff \text{near-tropical} \iff \text{decision-stable},$$
$$\text{small margin} \iff \text{far-from-tropical} \iff \text{decision-fragile}.$$

Three independent measurements on the same network — the Maslov gap (a tropical
quantity), the collision mass / diffuseness (an information-theoretic quantity),
and the cross-model decision agreement (a behavioural quantity) — single out the
same two layers, and the above inequalities show why they must.

---

## 7. The hump is a contraction certificate

### 7.1 The propagation model

Let both networks read the same input and run through the *same* layer maps
$f_k$ on a normed space $E$, with the fine-tune injecting a per-layer weight
delta:
$$a_{k+1} = f_k(a_k), \qquad b_{k+1} = f_k(b_k) + \delta_k, \qquad
d_k := \|a_k - b_k\| .$$

**Theorem 7.1 (Exactly shared prefix).** *If $a_0 = b_0$ and $\delta_k = 0$ for
all $k < s$, then $a_k = b_k$ for all $k \le s$.*

*Proof.* Induction: the base case is the hypothesis, and if $a_k = b_k$ with
$k < s$ then $a_{k+1} = f_k(a_k) = f_k(b_k) = b_{k+1}$. $\blacksquare$

This is the formal content of the measured layer-0 identity, cosine similarity
$1.0000$: no delta has yet been injected, so nothing can have diverged.

**Theorem 7.2 (One-step propagation).** *If $\|f(y) - f(z)\| \le L\|y - z\|$ and
$\|\delta\| \le \varepsilon$, then*
$$\|f(a) - (f(b) + \delta)\| \;\le\; L\|a-b\| + \varepsilon .$$

*Proof.* Triangle inequality plus the Lipschitz bound. $\blacksquare$

**Theorem 7.3 (Geometric and linear bounds).** *If $d_0 = 0$ and
$d_{k+1} \le L\,d_k + \varepsilon$ with $L \ge 0$, then*
$$d_k \;\le\; \varepsilon \sum_{i<k} L^i \qquad \text{for all } k;$$
*in particular, for nonexpansive layers ($L = 1$), $d_k \le k\varepsilon$.*

*Proof.* Induction on $k$, using $\sum_{i<k+1}L^i = L\sum_{i<k}L^i + 1$.
$\blacksquare$

### 7.2 The certificate

The bounds above permit growth but forbid decrease beyond the injected delta.
This makes the hump informative rather than merely surprising.

**Theorem 7.4 (Downward steps certify contraction).** *Let $\|\delta\| \le
\varepsilon$ and suppose the outgoing divergence drops strictly below the
incoming one by more than $\varepsilon$:*
$$\|f(a) - (f(b) + \delta)\| < \|a - b\| - \varepsilon .$$
*Then $\|f(a) - f(b)\| < \|a - b\|$: the shared layer map strictly contracts the
pair $(a,b)$.*

*Proof.* Write $f(a) - f(b) = \big(f(a) - (f(b)+\delta)\big) + \delta$ and apply
the triangle inequality:
$\|f(a)-f(b)\| \le \|f(a) - (f(b)+\delta)\| + \varepsilon < \|a-b\|$.
$\blacksquare$

**Theorem 7.5 (Quantitative contraction factor).** *If $\|\delta\| \le
\varepsilon$ and $\|f(a) - (f(b)+\delta)\| + \varepsilon \le c\,\|a - b\|$, then
$\|f(a) - f(b)\| \le c\,\|a-b\|$.*

*Proof.* As above, with the numerical bound in place of the strict inequality.
$\blacksquare$

**Corollary 7.6 (The measured contraction factor).** *With incoming divergence
$\|a-b\| = 0.217$, outgoing $\|f(a) - (f(b)+\delta)\| \le 0.16$, and per-layer
delta budget $\varepsilon = 0.01$, the shared tail map satisfies
$\|f(a)-f(b)\| \le \tfrac{4}{5}\|a-b\|$.*

*Proof.* $0.16 + 0.01 = 0.17 \le 0.8 \times 0.217 = 0.1736$; apply Theorem 7.5
with $c = 4/5$. $\blacksquare$

The alternative branch of the dichotomy comes from a telescoping lower bound.

**Theorem 7.7 (Chain lower bound).** *If $d_k - e_k \le d_{k+1}$ for all $k$
(each layer can lose at most $e_k$ of divergence), then for $m \le n$,*
$$d_m - \sum_{k=m}^{n-1} e_k \;\le\; d_n .$$

*Proof.* Induction on $n$ from the base $n = m$, adding one step at a time.
$\blacksquare$

**Corollary 7.8 (Delta budget of the descending stretch).** *If
$d_{16} = 0.217$ and $d_{23} = 0.16$, then $\sum_{k=16}^{22} e_k \ge 0.057$, and
consequently some single layer $k \in [16,23)$ has $e_k \ge 0.008$.*

*Proof.* The first claim is Theorem 7.7 with $m = 16$, $n = 23$. For the second,
if every one of the seven terms were below $0.008$ their sum would be below
$0.056 < 0.057$. $\blacksquare$

**Interpretation.** "Monotone divergence" was never an axiom to be refuted
empirically. Its failure is *exactly* contractivity of the shared machinery. The
measured hump therefore does not merely disconfirm a hypothesis; it produces a
certificate: either the tail maps contract by a factor $\le 4/5$, or the tail
deltas are large enough that some layer injects at least $0.008$. Both branches
are informative, and they exhaust the possibilities.

---

## 8. The margin–depth sharing budget

We now combine the propagation recursion with the margin certificate to answer:
*how deep can a shared core run before agreement is no longer guaranteed?*

**Definition 8.1 (Error budget).** Given per-layer Lipschitz constants $L_k \ge
0$ and a per-layer delta budget $\varepsilon \ge 0$, define
$$B_0 = 0, \qquad B_{k+1} = L_k B_k + \varepsilon .$$

**Theorem 8.2 (The budget dominates the divergence).** *If $d_0 = 0$ and
$d_{k+1} \le L_k d_k + \varepsilon$ with $L_k \ge 0$, then $d_k \le B_k$ for all
$k$.*

*Proof.* Induction, using monotonicity of $t \mapsto L_k t$. $\blacksquare$

**Theorem 8.3 (Linear budget for nonexpansive layers).** *If $\varepsilon \ge 0$
and $0 \le L_k \le 1$ for all $k$, then $B_k \le k\varepsilon$; if $L_k = 1$ for
all $k$ then $B_k = k\varepsilon$ exactly.*

**Theorem 8.4 (Monotone budget for non-contracting layers).** *If
$\varepsilon \ge 0$ and $L_k \ge 1$ for all $k$, then $k \mapsto B_k$ is
non-decreasing.*

Both are straightforward inductions using $B_k \ge 0$.

**Definition 8.5 (Shareable layer).** Given a margin profile $m_k$, layer $k$ is
*certifiably shareable* if $2B_k < m_k$.

**Theorem 8.6 (Agreement on shareable layers).** *Suppose the reference model's
scores at layer $k$ have margin at least $m_k$ at index $i_k$, the two models'
scores at layer $k$ are $d_k$-close coordinatewise, the divergence obeys the
recursion of Theorem 8.2, and layer $k$ is shareable. Then the second model also
decides $i_k$ at layer $k$.*

*Proof.* By Theorem 8.2, $d_k \le B_k$, so the two vectors are $B_k$-close. By
shareability, the margin exceeds $2B_k$. Apply Theorem 3.1 with
$\varepsilon = B_k$. $\blacksquare$

**Theorem 8.7 (Sharing is a prefix property).** *Assume $\varepsilon \ge 0$,
$L_k \ge 1$ for all $k$ (no layer contracts), and that the margin profile is
non-increasing in depth ($m_l \le m_k$ whenever $k \le l$). If layer $l$ is
shareable and $k \le l$, then layer $k$ is shareable. Hence the shareable layers
form an initial segment.*

*Proof.* $2B_k \le 2B_l < m_l \le m_k$, using Theorem 8.4 and the monotonicity
of the margin profile. $\blacksquare$

This is precisely the observed shape: a shared core followed by a personal tail,
never the reverse. It is a theorem under the two stated hypotheses, both of
which are natural for a transformer stack whose attention becomes progressively
more diffuse with depth.

**Theorem 8.8 (Depth law).** *For nonexpansive layers ($0 \le L_k \le 1$) and
$\varepsilon > 0$, every layer with $2k\varepsilon < m_k$ — i.e. of depth
$k < m_k/(2\varepsilon)$ — is certifiably shareable.*

*Proof.* $2B_k \le 2k\varepsilon < m_k$ by Theorem 8.3. $\blacksquare$

**Corollary 8.9 (The measured configuration, and its tightness).** *With per-layer
delta $\varepsilon = 0.01$, uniform margin $m = 0.5$, and nonexpansive layers,
every layer of depth $k \le 24$ is certifiably shareable. The bound is tight: for
$L_k \equiv 1$ the certificate fails at depth $25$, since $B_{25} = 0.25$ and
$2 \times 0.25 = 0.5 \not< 0.5$.*

The depth law $k < m/(2\varepsilon)$ is the quantitative statement of "the core
is shared": the shareable depth is the margin measured in units of twice the
per-layer fine-tuning delta.

---

## 9. The serving law

**Definition 9.1 (Serving cost).** Serving $n$ fine-tunes of an $L$-layer model
with the first $s$ layers of key/value machinery shared and the remaining
$L - s$ per-model costs
$$\operatorname{cost}(n, L, s) \;=\; s + n\,(L - s).$$

**Proposition 9.2 (Saving).** $\operatorname{cost}(n,L,s) = nL - (n-1)s$; hence
sharing saves exactly $(n-1)s$ over independent serving, and for $n \ge 2$ and
$s > 0$ we have $\operatorname{cost}(n,L,s) < nL$ strictly.

**Theorem 9.3 (Amortized model-delta law).** *For $L > 0$,*
$$\lim_{n \to \infty} \frac{\operatorname{cost}(n,L,s)}{nL}
= \frac{L - s}{L}.$$

*Proof.* $\dfrac{s + n(L-s)}{nL} = \dfrac{s/L}{n} + \dfrac{L-s}{L}$, and the
first term tends to $0$. $\blacksquare$

The asymptotic per-model cost is exactly the **tail fraction**: the shared core
amortizes away entirely and only the personal tail is paid for. For $L = 24$,
$s = 22$ the limit is $1/12$.

**Theorem 9.4 (Shared-core safety).** *Let $S$ be a set of layers on which the
reference model has margin exceeding $2\varepsilon$ and on which the shared
cache is $\varepsilon$-accurate coordinatewise. Then both models make the same
decision on every layer of $S$, so the number of layers with provably identical
decisions is at least $|S|$, and the provable agreement fraction is at least
$|S|/L$.*

*Proof.* Layerwise application of Theorem 3.1, plus $\varepsilon \ge 0$ for the
reference model's own strictness. $\blacksquare$

**Corollary 9.5 (The measured configuration).** *Certifying $22$ layers out of
$24$ yields a provable agreement fraction of at least $11/12 \approx 0.9167$.*

**Remark 9.6 (A correction to the informal claim).** The convenient slogan
"share $22$ of $24$ layers at $\ge 0.92$ agreement" conflates two numbers:
$22/24 = 0.91\overline{6} < 0.92$. The certified figure is exactly $11/12$.

**Theorem 9.7 (No cosine certificate licenses sharing).** *For every
$\varepsilon > 0$ there exist two layers' score vectors with cosine similarity
above $1-\varepsilon$ whose top-1 decisions differ.*

*Proof.* Immediate from Theorem 4.3. $\blacksquare$

Hence the safety hypothesis in Theorem 9.4 must be a margin. This is exactly why
the measured tail — cosine $0.983$, agreement $0.568$ — is not shareable, while
the core, whose layers carry margins, is.

---

## 10. Tail-swap attribution: a prediction

The natural causal follow-up is to take two fine-tunes of one base model,
exchange only the last two layers, and ask whose behaviour the hybrid inherits.
Factor each model as $\operatorname{tail} \circ \operatorname{core}$, with
$\operatorname{core} : E \to E$ mapping the input to the state at the splitting
depth and $\operatorname{tail} : E \to G$ producing the output.

**Theorem 10.1 (Divergence splitting).** *If $\operatorname{tail}_A$ is
$K$-Lipschitz, then for every input $x$,*
$$\|\operatorname{tail}_A(\operatorname{core}_A x) -
\operatorname{tail}_B(\operatorname{core}_B x)\|
\;\le\; K\,\|\operatorname{core}_A x - \operatorname{core}_B x\|
\;+\; \|\operatorname{tail}_A(\operatorname{core}_B x) -
\operatorname{tail}_B(\operatorname{core}_B x)\| .$$

*Proof.* Insert $\operatorname{tail}_A(\operatorname{core}_B x)$ and apply the
triangle inequality and the Lipschitz bound. $\blacksquare$

**Corollary 10.2 (Attribution).** *If $K \ge 0$,
$\|\operatorname{core}_A x - \operatorname{core}_B x\| \le \varepsilon$ and the
observed output divergence is at least $D$, then the tails' own disagreement on
a common state satisfies*
$$\|\operatorname{tail}_A(\operatorname{core}_B x) -
\operatorname{tail}_B(\operatorname{core}_B x)\| \;\ge\; D - K\varepsilon .$$

Identity that is measured at the output and absent from the core must live in
the tail. This is the quantitative form of "the tail is personal".

**Theorem 10.3 (Predicted outcome of the causal swap).** *Suppose the two cores
agree to $\varepsilon$, i.e.
$\|\operatorname{core}_B x - \operatorname{core}_A x\| \le \varepsilon$; suppose
$\operatorname{tail}_B$ is coordinatewise $K$-Lipschitz, i.e.
$|\operatorname{tail}_B(y)_j - \operatorname{tail}_B(z)_j| \le K\|y - z\|$ for
all $y,z,j$; and suppose model $B$ holds its decision $i$ with margin exceeding
$2K\varepsilon$ on its own core state:
$\operatorname{tail}_B(\operatorname{core}_B x)_i -
\operatorname{tail}_B(\operatorname{core}_B x)_j > 2K\varepsilon$ for all
$j \neq i$. Then the hybrid model $\operatorname{tail}_B \circ
\operatorname{core}_A$ makes exactly model $B$'s decision $i$.*

*Proof.* The two score vectors $\operatorname{tail}_B(\operatorname{core}_B x)$
and $\operatorname{tail}_B(\operatorname{core}_A x)$ are $K\varepsilon$-close
coordinatewise; apply Theorem 3.1 with $\varepsilon' = K\varepsilon$.
$\blacksquare$

**Remark 10.4 (The margin hypothesis is essential).** By Theorem 4.3, dropping
the margin hypothesis invalidates the conclusion: two cosine-similar score
vectors may decide differently, so "the caches look alike" never licenses a
swap. Every positive statement in this paper is conditioned on a margin; every
negative statement follows from the absence of one.

---

## 11. Algorithms

The theory yields three directly implementable procedures.

**Algorithm A — Margin certification of a shared core.** Given per-layer score
vectors of a reference model and a per-layer cache accuracy $\varepsilon_k$,
compute the top-1 margin $m_k = u^{(k)}_{i_k} - \max_{j \neq i_k} u^{(k)}_j$ at
each layer and mark layer $k$ shareable iff $m_k > 2\varepsilon_k$. By
Theorem 3.1 every marked layer provably reproduces the reference decision. Cost:
$O(Ln)$ for $L$ layers and $n$ positions — a single pass, no model re-evaluation.

**Algorithm B — Depth-budget planner.** Given Lipschitz estimates $L_k$, a
per-layer delta budget $\varepsilon$, and a margin profile $m_k$, iterate
$B_{k+1} = L_kB_k + \varepsilon$ from $B_0 = 0$ and return the largest $s$ such
that $2B_k < m_k$ for all $k < s$. Under the hypotheses of Theorem 8.7 the
answer is exactly the shareable prefix. Cost: $O(L)$.

**Algorithm C — Hump dichotomy resolver.** Given a measured divergence profile
$d_k$ and a per-layer delta budget $\varepsilon$, scan for indices where
$d_{k+1} < d_k - \varepsilon$. Each such index is a *certificate* that layer $k$
contracts, with factor at most $(d_{k+1} + \varepsilon)/d_k$ (Theorem 7.5).
Over any descending stretch $[m,n)$, report the forced total delta budget
$d_m - d_n$ (Theorem 7.7) and the pigeonhole per-layer bound
$(d_m - d_n)/(n-m)$. Cost: $O(L)$.

---

## 12. Discussion

### 12.1 What the results do and do not say

The theorems here are unconditional statements about score vectors, divergence
recursions, and serving costs; they hold for any model. The *measurements* that
motivated them come from one base/fine-tune pair, one context, and a small
prompt set at half precision. What the theory contributes is the assurance that
the striking observation — cosine $0.983$ with agreement $0.568$ — needs no
special explanation and refutes no inequality, and that the correct instrument
for the engineering question is a margin, computable in one pass.

Conversely, the results are a warning about a common practice. Cosine similarity
of internal representations is routinely used as a proxy for functional
equivalence, in model merging, cache sharing, quantization evaluation, and
representational-similarity analysis. Theorem 4.3 says this proxy has no
worst-case content whatsoever near a decision boundary, and Theorem 5.2 says the
worst case is realised precisely where attention is diffuse — which, empirically,
is the top of the stack, exactly where behaviourally important computation
happens.

### 12.2 Three windows, one inequality

The most satisfying structural finding is the coincidence of three independent
diagnostics on the same two layers. The Maslov gap is a tropical-geometry
quantity; the collision mass is an information-theoretic one; decision agreement
is behavioural. Theorems 6.2–6.5 show that they bound each other in both
directions, so the coincidence is forced. This suggests a general methodology:
*measure the margin*, since it is the quantity that all three diagnostics are
approximating, and it is the one that appears in every stability theorem.

### 12.3 The hump, demystified

It is tempting to read a non-monotone divergence profile as evidence that "the
fine-tune undoes itself" or as measurement noise. Theorem 7.4 gives the correct
reading: a downward step larger than the injected delta is a *proof* that the
shared machinery contracts the state pair. A network that ends up closer to
itself than it was in the middle is a network whose upper layers are, in the
relevant directions, contractive maps. The measured constants then give the
explicit dichotomy of Corollaries 7.6 and 7.8.

### 12.4 Engineering implication

The serving law is the practical payoff. For a fixed memory budget, the number
of fine-tunes one can serve grows in inverse proportion to the tail fraction
$(L-s)/L$; pushing $s$ from $0$ to $22$ out of $24$ turns a per-model cost of
$1$ into a per-model cost of $1/12$. The safety side must be certified by
margins (Theorem 9.4), and the achievable $s$ is governed by the depth law
$s < m/(2\varepsilon)$ (Theorem 8.8). Both are cheap to compute. And by
Theorem 8.7, one never needs to search over subsets of layers: under natural
hypotheses the shareable set is a prefix, so a single scan suffices.

---

## 13. Future directions

**Causal tail swap.** Theorem 10.3 makes a falsifiable prediction: exchanging
only the final two layers between two fine-tunes should transfer the decision,
provided the tail margins exceed $2K\varepsilon$. Corollary 10.2 supplies the
attribution accounting for the residual.

**Scale and training-regime dependence.** Does the shared-core/personal-tail
split hold at larger scales, and does the *position* of the transition depend on
the alignment method used? The depth law $k < m/(2\varepsilon)$ predicts that
methods with smaller per-layer deltas should share deeper cores.

**Precision allocation.** The depth law is symmetric in $m$ and $\varepsilon$:
layers with large margins tolerate large $\varepsilon$. This argues for
quantizing the high-margin core more aggressively than the low-margin tail — a
margin-aware precision schedule rather than a uniform one.

**Beyond top-1.** Everything here concerns the argmax. A top-$k$ analogue
requires the gap between the $k$-th and $(k{+}1)$-st order statistics; the
margin machinery should carry over verbatim, with the collision bound of
Theorem 5.1 replaced by a bound on the $k$-th largest coordinate.

**Prompt and context variance.** The margin profile is a function of the input.
Characterising the distribution of per-layer margins over a realistic prompt
distribution would turn the worst-case certificates here into
average-case guarantees.

---

## 14. Conclusion

Three measurements — an exactly shared bottom layer, a hump-shaped divergence
profile, and a collapse of decision agreement in the last two layers despite
near-unit cosine similarity — have a single coherent explanation.

Decisions are order statistics, and order is controlled by margins, not by
angles. The margin certificate is sharp, with an optimal constant $2$; the
cosine certificate does not exist at all. Diffuse attention has, by the
collision bound, a small margin, and the Maslov gap measures the same
diffuseness from the tropical side, so "far from tropical", "diffuse", and
"fragile" coincide. The divergence hump is not a refutation of monotone drift
but a certificate of contraction in the shared machinery. And the whole picture
cashes out as a design rule for serving many fine-tunes at once: share the
high-margin prefix, whose depth is the margin divided by twice the per-layer
delta; pay per-model for the low-margin tail; and never accept an angle where a
margin is required.

The bulk of a transformer is shared machinery. The identity is in the tail.
