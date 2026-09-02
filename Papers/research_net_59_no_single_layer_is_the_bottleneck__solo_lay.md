# The Identifiability Theory of Layer Ablation

### Solo profiles, downstream contraction, and an arity hierarchy for ablation experiments in layered stochastic maps

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Layer-wise ablation is the standard instrument for attributing importance to
the layers of a deep stack: break one layer, measure the degradation at the
output, repeat. We develop an exact theory of what this instrument can and
cannot measure, in a finite probabilistic model in which a layer is a Markov
channel on a finite state space and damage is total variation distance. Three
functionals are distinguished: the **point cost** of a layer (the damage it
does to its own output law at the intact upstream state), the **solo cost**
(the damage visible at the output of the stack when that layer alone is
ablated — what the experiment reports), and the **joint cost** (the damage when
the whole stack is ablated — what deployment cares about).

We prove: (i) a *context-shift inequality*
$d_{\mathrm{TV}}(f_*\mu, p_*\mu) \le d_{\mathrm{TV}}(f_*\nu,p_*\nu) + 2\, d_{\mathrm{TV}}(\mu,\nu)$ isolating upstream drift as the sole source of
epistasis, together with a telescoping hybrid bound and a depth-additive
budget valid exactly when per-layer perturbations are small *uniformly over
upstream states*; (ii) **non-identifiability** — two prunings of a single
depth-$24$ stack with identical, identically zero solo profiles whose joint
costs are $0.017$ and $1$, plus a stack whose two solo costs are both maximal
and whose joint cost is $0$, so no inequality relates the solo profile to the
joint cost in either direction; (iii) a **masking theorem** $\mathrm{solo}_j \le \delta^{m_j} \cdot \mathrm{point}_j$ derived from a from-scratch proof of
the finite Dobrushin contraction theorem, attained exactly in an affine
two-state family, so flat solo profiles are *predicted* by contraction rather
than being evidence of uniform importance; (iv) an exact converse —
identifiability at a lossless suffix, in particular unconditionally at the
final layer; (v) a **geometric sub-additivity bound** $\mathrm{joint} \le c \sum_{i<n}\delta^i \le c/(1-\delta)$, independent of depth and attained, which
turns the observed sub-additivity ratio into an estimator of the contraction
coefficient ($\delta = 8/9$, $c = 1/500$ at depth $24$ reproduce the measured
pair $4.8\%$ additive versus $1.69\!-\!1.70\%$ joint); and (vi) an **arity
hierarchy** — for every $m$, a depth-$24$ stack on which every ablation of at
most $m$ layers returns exactly $0$ while a single experiment of arity $m+1$
returns the true damage, so no fixed-arity ablation protocol is sound. A
fractional refinement computes the minimal informative arity in closed form
from the contraction spectrum.

The empirical motivation is a measurement on a 24-layer language model in which
oracle top-$k$ pruning applied to one layer at a time produced a profile of
total spread $0.6$ points, with the final layer the best in the stack, while
pruning all layers jointly cost $1.7\%$ against an additive prediction of
$4.8\%$. Our results show that this pattern — flat profile, faithful tail,
strong sub-additivity — is exactly what a stack with *no* layer hierarchy
produces, and hence that the reported verdict is a statement about the
measurement rather than about the network.

**Keywords:** total variation, Markov channel, Dobrushin contraction,
data processing inequality, layer ablation, identifiability, epistasis,
sub-additivity, ablation arity.

---

## 1. Introduction

### 1.1 The measurement

A 24-layer transformer language model was subjected to the following protocol.
For each layer $j \in \{0,\dots,23\}$ independently, attention in layer $j$ was
restricted to an oracle top-$k$ set of keys ($k = 16$ and $k = 32$) while every
other layer was left fully intact; performance was recorded over held-out
windows at fixed context length. The resulting profile — one number per layer —
was almost perfectly flat:

| statistic | $k=16$ |
|---|---|
| best layer | $1.0013$ (layer 13) |
| worst layer | $0.9953$ (layer 12) |
| total spread | $0.6$ points |
| minimum over all layers | $\ge 0.995$ |
| final layer $L_{23}$ | $1.0008$ — the best in the stack |

At $k = 32$ the profile was flatter still. Two structural hypotheses stated in
advance — that the tail layers are individually critical, and that the map from
layer index to importance is non-uniform — were declared refuted, and the
verdict recorded was that *no single layer is the bottleneck*.

Two facts sit uneasily beside that verdict. First, four independent prior
experiments in the same programme had established the tail layers $L_{22}, L_{23}$ as categorically different from the rest of the stack along several
unrelated axes. Second, joint pruning of *all* layers at $k=16$ cost $1.7\%$,
whereas the sum of the individual solo costs predicts roughly $4.8\%$:
interactions are strongly sub-additive.

### 1.2 The question

Both tensions are about the same thing: what a solo-ablation profile is
evidence *for*. The question admits an exact answer once one fixes a model in
which "layer", "ablation" and "damage" are mathematical objects. We fix the
smallest such model — finite state spaces, Markov channels, total variation —
and answer it completely.

The answer has three parts, and none of them is a statement about transformers
in particular. **Negatively:** the solo profile does not determine the joint
cost, in either direction, even at the measured depth and even when the profile
is *perfectly* flat. **Explanatorily:** flatness is the generic consequence of
downstream contraction, which attenuates a layer's damage geometrically in its
distance from the output; a bottleneck deep in the stack is invisible by
construction. **Constructively:** the exact converse holds at a lossless
suffix, the sub-additivity ratio estimates the contraction coefficient, and the
minimal arity at which a layer's damage becomes visible above a given
resolution is a closed-form function of that coefficient.

### 1.3 Organisation

Section 2 sets up the model. Section 3 proves the core inequalities. Section 4
introduces the three cost functionals and the epistasis budget. Section 5
proves non-identifiability. Section 6 proves the masking theorem via Dobrushin
contraction. Section 7 proves identifiability at a lossless suffix. Section 8
treats sub-additivity and its sharpness. Section 9 develops the arity
hierarchy. Section 10 gives the fractional (resolution-threshold) refinement.
Section 11 states the algorithms. Section 12 discusses consequences for
experimental design, and Section 13 lists open directions.

---

## 2. The model

Throughout, $\alpha, \beta$ denote finite non-empty sets and all probability
weights are rational, so that every quantity in this paper is exactly
computable and every numerical claim below is exact rather than approximate.

> **Definition 2.1 (Distribution).** A *distribution* on a finite set $\alpha$
> is a function $\mu : \alpha \to \mathbb{Q}$ with $\mu(a) \ge 0$ for all $a$
> and $\sum_{a} \mu(a) = 1$. Write $\mathrm{Dist}(\alpha)$ for the set of
> these. Immediately $\mu(a) \le 1$ for every $a$.

> **Definition 2.2 (Channel).** A *channel* $K : \alpha \rightsquigarrow \beta$
> is a map $K : \alpha \to \mathrm{Dist}(\beta)$, i.e. a row-stochastic matrix.
> Its *pushforward* action on $\mu \in \mathrm{Dist}(\alpha)$ is
> $$(K_*\mu)(b) = \sum_{a \in \alpha} \mu(a)\,K(a)(b),$$
> which is again a distribution.

> **Definition 2.3 (Total variation).** For $\mu, \nu \in \mathrm{Dist} > (\alpha)$,
> $$d_{\mathrm{TV}}(\mu,\nu) = \tfrac12 \sum_{a\in\alpha} |\mu(a)-\nu(a)|.$$

**Proposition 2.4.** $d_{\mathrm{TV}}$ is a metric on $\mathrm{Dist}(\alpha)$
with values in $[0,1]$: it is non-negative, symmetric, satisfies the triangle
inequality, is bounded by $1$, and vanishes exactly when $\mu = \nu$.

*Proof sketch.* Non-negativity, symmetry and the triangle inequality are
termwise consequences of the corresponding facts for $|\cdot|$ on $\mathbb{Q}$.
For the bound, $|\mu(a)-\nu(a)| \le \mu(a)+\nu(a)$ pointwise by case analysis
on the sign, and summing gives $2$. For the last claim, a sum of non-negative
terms vanishes iff each term does. $\square$

Three distinguished channels recur.

> **Definition 2.5.** For $a \in \alpha$ let $\mathrm{dirac}(a)$ be the point
> mass at $a$. The *identity channel* is $\mathrm{id}(a) = \mathrm{dirac}(a)$;
> the *constant channel* $\mathrm{const}_c$ with law $c \in \mathrm{Dist} > (\beta)$ sends every input to $c$; for a bijection $e : \alpha \to \alpha$
> the *permutation channel* is $\mathrm{perm}_e(a) = \mathrm{dirac}(e(a))$.

One checks $\mathrm{id}_*\mu = \mu$ and $(\mathrm{const}_c)_*\mu = c$ for every
$\mu$. On the two-element state space $\{0,1\}$ we write $\mathrm{Bern}(t)$ for
the law $(1-t, t)$, and record the basic computation
$$d_{\mathrm{TV}}\big(\mathrm{Bern}(s), \mathrm{Bern}(t)\big) = |s-t|. \tag{2.6}$$

> **Definition 2.7 (Stack).** A *stack* is a finite list $F = (f_0,\dots, > f_{n-1})$ of channels $\alpha \rightsquigarrow \alpha$. Its action is
> $$\mathrm{chain}(F,\mu) = (f_{n-1})_* \cdots (f_0)_* \mu,$$
> defined recursively by $\mathrm{chain}((),\mu) = \mu$ and
> $\mathrm{chain}(K :: L, \mu) = \mathrm{chain}(L, K_*\mu)$. Concatenation
> satisfies $\mathrm{chain}(F_1 \frown F_2, \mu) = \mathrm{chain}(F_2, > \mathrm{chain}(F_1,\mu))$.

> **Definition 2.8 (Ablation).** An *ablation* of $F$ at a set $S \subseteq > \{0,\dots,n-1\}$ replaces $f_j$ by a prescribed channel $p_j$ for each $j \in > S$. The *arity* of the experiment is $|S|$. We write $F[j \mapsto p]$ for the
> arity-$1$ case and $F[j\mapsto p, k \mapsto q]$ for the arity-$2$ case.

Note that "ablation" is deliberately generic: pruning attention to a top-$k$
set, quantising, zeroing, or replacing a layer by the identity are all
instances, differing only in which channel $p_j$ is substituted.

---

## 3. Core inequalities

The following three inequalities govern everything that follows.

> **Theorem 3.1 (Data-processing inequality).** For every channel $K : \alpha > \rightsquigarrow \beta$ and all $\mu,\nu \in \mathrm{Dist}(\alpha)$,
> $$d_{\mathrm{TV}}(K_*\mu, K_*\nu) \le d_{\mathrm{TV}}(\mu,\nu).$$

*Proof sketch.* Fix $b$. Since $(K_*\mu)(b)-(K_*\nu)(b) = \sum_a (\mu(a)- \nu(a))K(a)(b)$, the triangle inequality for finite sums and non-negativity of
$K(a)(b)$ give $|(K_*\mu)(b)-(K_*\nu)(b)| \le \sum_a |\mu(a)-\nu(a)| K(a)(b)$.
Summing over $b$ and exchanging the order of summation, the inner sum
$\sum_b K(a)(b)$ equals $1$, leaving $\sum_a|\mu(a)-\nu(a)|$. Halve. $\square$

Applying Theorem 3.1 layer by layer along a stack yields $d_{\mathrm{TV}} (\mathrm{chain}(L,\mu), \mathrm{chain}(L,\nu)) \le d_{\mathrm{TV}}(\mu,\nu)$
for every stack $L$.

> **Theorem 3.2 (Perturbation inequality).** For channels $f,p : \alpha > \rightsquigarrow \beta$ and $\mu \in \mathrm{Dist}(\alpha)$,
> $$d_{\mathrm{TV}}(f_*\mu, p_*\mu) \;\le\; \sum_{a} \mu(a)\,
> d_{\mathrm{TV}}\big(f(a), p(a)\big).$$
> In particular, if $d_{\mathrm{TV}}(f(a),p(a)) \le \varepsilon$ for *every*
> $a$, then $d_{\mathrm{TV}}(f_*\mu, p_*\mu) \le \varepsilon$ for every $\mu$.

*Proof sketch.* Identical bookkeeping to Theorem 3.1, this time factoring
$\mu(a)$ out of the absolute value rather than $K(a)(b)$. The uniform form
follows because $\sum_a \mu(a)\varepsilon = \varepsilon$. $\square$

The uniform hypothesis in Theorem 3.2 — closeness at *every* input, not merely
on average against one particular $\mu$ — is the hinge of the whole paper. It
is the difference between a per-layer budget that composes and one that does
not.

> **Theorem 3.3 (Context-shift inequality).** For channels $f,p$ and states
> $\mu,\nu$,
> $$d_{\mathrm{TV}}(f_*\mu, p_*\mu) \;\le\; d_{\mathrm{TV}}(f_*\nu, p_*\nu)
> \;+\; 2\, d_{\mathrm{TV}}(\mu,\nu).$$

*Proof sketch.* Two applications of the triangle inequality route
$f_*\mu \to f_*\nu \to p_*\nu \to p_*\mu$, and Theorem 3.1 bounds the two outer
legs by $d_{\mathrm{TV}}(\mu,\nu)$ each. $\square$

Theorem 3.3 is the exact quantitative form of the epistasis puzzle. A solo
ablation evaluates a layer's damage at the *intact* upstream state; a joint
ablation evaluates it at a *drifted* one. The theorem says the discrepancy is
controlled entirely by the drift, at a price of $2$ per unit. Upstream drift is
the only mechanism by which per-layer damages can fail to compose.

---

## 4. Three cost functionals and the epistasis budget

Fix a stack $F$ of length $n$, an input law $\mu$, and a pruning $P = (p_0, \dots,p_{n-1})$ of the same length.

> **Definition 4.1.** Write $\nu_j = \mathrm{chain}(F_{<j}, \mu)$ for the
> *intact upstream state* at layer $j$, where $F_{<j}$ is the prefix of $F$ of
> length $j$. Then
> - the **point cost** at $j$ is $\;\mathrm{pt}_j = d_{\mathrm{TV}}\big((f_j)_* >   \nu_j, (p_j)_*\nu_j\big)$;
> - the **solo cost** at $j$ is $\;\mathrm{so}_j = d_{\mathrm{TV}}\big( >   \mathrm{chain}(F,\mu), \mathrm{chain}(F[j\mapsto p_j],\mu)\big)$;
> - the **joint cost** is $\;\mathrm{jt} = d_{\mathrm{TV}}\big( >   \mathrm{chain}(F,\mu), \mathrm{chain}(P,\mu)\big)$.

The experiment reports $(\mathrm{so}_j)_j$. Deployment cares about
$\mathrm{jt}$. Mechanistic interpretation wants $(\mathrm{pt}_j)_j$.

> **Theorem 4.2 (Masking, weak form).** $\mathrm{so}_j \le \mathrm{pt}_j$ for
> every $j$.

*Proof sketch.* Both output laws are obtained by pushing $(f_j)_*\nu_j$ and
$(p_j)_*\nu_j$ through the *same* suffix $F_{>j}$; apply data processing along
that suffix. $\square$

So the solo measurement can only under-report. A flat solo profile is
therefore compatible with an arbitrarily uneven point profile, and by itself
provides no lower bound on any layer's true damage.

Next, the telescoping decomposition of joint damage.

> **Definition 4.3 (Hybrid cost).** Define $\mathrm{hyb}(F,P,\mu)$ recursively
> by $\mathrm{hyb}((),P,\mu)=0$ and
> $$\mathrm{hyb}(f::F', p::P', \mu) = d_{\mathrm{TV}}(f_*\mu, p_*\mu)
> + \mathrm{hyb}(F', P', p_*\mu).$$
> Each summand is a **contextual** cost: the damage layer $i$ does *at the
> already-pruned upstream state*, not at the intact one.

> **Theorem 4.4 (Hybrid bound).** If $|F| = |P|$ then $\mathrm{jt} \le > \mathrm{hyb}(F,P,\mu)$.

*Proof sketch.* Induction on the length. For $F = f::F'$, $P = p::P'$ the
triangle inequality gives
$$d_{\mathrm{TV}}(\mathrm{chain}(F',f_*\mu), \mathrm{chain}(P',p_*\mu))
\le d_{\mathrm{TV}}(\mathrm{chain}(F',f_*\mu),\mathrm{chain}(F',p_*\mu))
+ d_{\mathrm{TV}}(\mathrm{chain}(F',p_*\mu),\mathrm{chain}(P',p_*\mu)),$$
the first term is at most $d_{\mathrm{TV}}(f_*\mu,p_*\mu)$ by data processing
along $F'$, and the second is the inductive hypothesis at the state $p_*\mu$.
$\square$

> **Corollary 4.5 (Depth-additive budget).** Suppose that for every index $i$,
> $d_{\mathrm{TV}}(f_i(a), p_i(a)) \le \varepsilon$ for **every** state $a$.
> Then $\mathrm{jt} \le n\varepsilon$, where $n$ is the depth.

*Proof sketch.* Each hybrid summand is bounded by $\varepsilon$ by the uniform
form of Theorem 3.2, whatever upstream state it is evaluated at. $\square$

Corollary 4.5 is the *only* hypothesis under which a per-layer budget genuinely
adds up, and its hypothesis is uniform over upstream states. Solo ablation
measures the perturbation at exactly one state. Section 5 shows that
measurement can be arbitrarily far from the uniform quantity.

Finally, the drift-explicit version of the budget. Combining Theorem 3.3 with
Theorem 4.4 gives, for each layer, $\text{contextual cost} \le \text{point cost} + 2\cdot\text{upstream drift}$, and the drift is itself controlled by the
earlier layers' costs. At depth two this unwinds to the clean statement
$$\mathrm{jt} \;\le\; 3\,\mathrm{pt}_0 + \mathrm{pt}_1, \tag{4.6}$$
exhibiting the asymmetry explicitly: damage created early is charged three
times, because it also displaces the context in which every later layer is
evaluated.

---

## 5. Non-identifiability

We now show that the solo profile determines nothing.

> **Definition 5.1 (Witness family).** For $n \ge 0$ let
> $$F^{(n)} = (\underbrace{\mathrm{id},\dots,\mathrm{id}}_{n},
> \ \mathrm{const}_{\delta_0}),$$
> $n$ transparent layers followed by one totally forgetful layer emitting the
> point mass $\delta_0$ at state $0$. For $t \in [0,1]$ let the pruning
> $P^{(n)}(t)$ replace each transparent layer by $\mathrm{const}_ > {\mathrm{Bern}(t)}$ and the forgetful layer by $\mathrm{id}$.

Intact, the stack outputs $\delta_0$ regardless of input. Pruned, the last
transparent layer writes $\mathrm{Bern}(t)$ and the (now transparent) final
layer transmits it.

> **Theorem 5.2 (Perfectly flat solo profile).** For every depth $n+1$, every
> $t \in [0,1]$ and every layer $j \le n$, the solo cost of $F^{(n)}$ under
> $P^{(n)}(t)$ at layer $j$ is exactly $0$.

*Proof sketch.* Two cases. If $j < n$, the ablated layer lies before the
forgetful final layer, which resets the state to $\delta_0$ regardless: the
output is unchanged. If $j = n$, the ablation replaces the forgetful layer by
the identity while all upstream layers are intact identities, so the output is
the input $\delta_0$ — again unchanged. $\square$

> **Theorem 5.3 (Joint cost).** The joint cost of $F^{(n)}$ versus
> $P^{(n)}(t)$ is exactly $t$.

*Proof sketch.* The pruned stack outputs $\mathrm{Bern}(t)$ and the intact
stack outputs $\delta_0 = \mathrm{Bern}(0)$; apply (2.6). $\square$

> **Theorem 5.4 (Point profile).** For every non-final layer $j < n$ the point
> cost is exactly $t$. Hence Theorem 4.2 is saturated in the worst possible
> way: the true per-layer damage profile is flat at $t$ while the measured solo
> profile is flat at $0$.

> **Theorem 5.5 (Non-identifiability at the measured depth).** There exist
> stacks $F, P, Q$ of length exactly $24$ such that
> - the solo cost of $F$ under $P$ is $0$ at every one of the $24$ layers;
> - the solo cost of $F$ under $Q$ is $0$ at every one of the $24$ layers;
> - the joint cost of $F$ versus $P$ is exactly $0.017$;
> - the joint cost of $F$ versus $Q$ is exactly $1$.

*Proof sketch.* Take $F = F^{(23)}$, $P = P^{(23)}(0.017)$ and $Q = P^{(23)}(1)$ and apply Theorems 5.2 and 5.3. $\square$

Two prunings of one network with *literally identical* solo profiles, flatter
than any real measurement can be, whose joint costs are the benign figure
actually observed in the laboratory and total destruction of the output law.
No inference from a solo profile to a joint cost is valid.

The failure is two-sided.

> **Theorem 5.6 (Cancellation).** Let $F = (\mathrm{id},\mathrm{id})$ on
> $\{0,1\}$ and let $P = (\mathrm{flip},\mathrm{flip})$, where $\mathrm{flip}$
> is the deterministic state swap. Then both solo costs equal $1$ and the joint
> cost equals $0$.

*Proof sketch.* One flip maps $\delta_0$ to $\delta_1$, at total variation
distance $1$; two flips return to $\delta_0$. $\square$

> **Corollary 5.7 (No two-sided law).** There is no valid inequality of the
> form $\mathrm{jt} \le \sum_j \mathrm{so}_j$, and none of the form
> $\mathrm{jt} \ge \max_j \mathrm{so}_j$. The solo profile bounds the joint
> cost neither above nor below.

In particular, the *observed* sub-additivity of the measurement ($1.7\%$
against $4.8\%$) is a contingent property of the network measured, not a law of
pruning. Section 8 identifies the structural hypothesis that produces it.

---

## 6. Why flat profiles are the generic case: Dobrushin masking

Non-identifiability says a flat profile is *compatible* with anything. The
sharper claim is that a flat profile is what one should *expect*, and it
follows from contraction.

> **Definition 6.1 (Dobrushin coefficient).** A channel $K$ has *Dobrushin
> coefficient at most $\delta$* if $d_{\mathrm{TV}}(K(a), K(b)) \le \delta$ for
> all states $a,b$. The least such $\delta$ is $\delta(K) = \max_{a,b} > d_{\mathrm{TV}}(K(a),K(b)) \in [0,1]$.

$\delta(K) = 0$ characterises constant channels (total forgetting) and
$\delta(\mathrm{perm}_e) = 1$ for permutation channels on at least two states
(no forgetting).

> **Theorem 6.2 (Dobrushin contraction).** If $\delta(K) \le \delta$ then for
> all $\mu,\nu$,
> $$d_{\mathrm{TV}}(K_*\mu, K_*\nu) \le \delta \cdot d_{\mathrm{TV}}(\mu,\nu).$$

*Proof sketch.* Write $\mu - \nu = \sigma^+ - \sigma^-$ for the positive and
negative parts of the signed difference (Hahn decomposition). Both have the
same total mass $r = d_{\mathrm{TV}}(\mu,\nu)$, since $\sum_a (\mu(a)-\nu(a)) = 0$. If $r = 0$ then $\mu = \nu$ and there is nothing to prove. Otherwise
normalise to probability measures $\hat\sigma^\pm = \sigma^\pm/r$, so that
$K_*\mu - K_*\nu = r\,(K_*\hat\sigma^+ - K_*\hat\sigma^-)$. Now $K_* \hat\sigma^+$ and $K_*\hat\sigma^-$ are mixtures of rows of $K$, and total
variation is jointly convex, so their distance is at most $\max_{a,b} d_{\mathrm{TV}}(K(a),K(b)) \le \delta$. Multiplying back by $r$ gives the
claim. $\square$

> **Corollary 6.3 (Contraction along a suffix).** A stack of $m$ layers each
> with Dobrushin coefficient at most $\delta \in [0,1]$ satisfies
> $d_{\mathrm{TV}}(\mathrm{chain}(L,\mu),\mathrm{chain}(L,\nu)) \le \delta^m\, > d_{\mathrm{TV}}(\mu,\nu)$.

> **Theorem 6.4 (Masking theorem).** Let $m_j$ be the number of layers after
> $j$, each with Dobrushin coefficient at most $\delta$. Then
> $$\mathrm{so}_j \;\le\; \delta^{\,m_j}\cdot \mathrm{pt}_j.$$

*Proof sketch.* The two output laws are the images of $(f_j)_*\nu_j$ and
$(p_j)_*\nu_j$ under the suffix; apply Corollary 6.3. $\square$

The consequence for the experiment is stark.

> **Corollary 6.5 (Contraction masks maximal damage).** Suppose $\delta = > 1/2$ and layer $j$ has at least $11$ layers after it. Then even if $j$
> destroys its own output law completely — point cost $1$, the maximum
> possible — its solo cost is at most $2^{-11} < 0.0005$, an order of magnitude
> below the $0.006$ total spread reported by the measurement.

A stack of depth $24$ with an ordinary amount of per-layer forgetting will
therefore return a flat solo profile *whether or not* it contains a
bottleneck. The measurement is a statement about the contraction of the stack,
not about the importance of its layers. Section 10 shows the bound of Theorem
6.4 is attained exactly, so this is not an artefact of a loose estimate.

---

## 7. When the measurement *is* faithful

The converse of masking is exact.

> **Definition 7.1.** A layer is *lossless* if it is a permutation channel
> $\mathrm{perm}_e$ for some bijection $e$.

> **Lemma 7.2.** $d_{\mathrm{TV}}((\mathrm{perm}_e)_*\mu,(\mathrm{perm}_e)_* > \nu) = d_{\mathrm{TV}}(\mu,\nu)$; a stack of lossless layers is a total
> variation isometry.

*Proof sketch.* $(\mathrm{perm}_e)_*\mu = \mu \circ e^{-1}$, and the defining
sum is invariant under relabelling the index. $\square$

> **Theorem 7.3 (Identifiability at a lossless suffix).** If every layer after
> $j$ is lossless, then $\mathrm{so}_j = \mathrm{pt}_j$ exactly.

> **Corollary 7.4 (The final layer is always faithful).** For $j$ the last
> index, $\mathrm{so}_j = \mathrm{pt}_j$, unconditionally.

> **Theorem 7.5 (Interpolation).** If the suffix after $j$ contracts total
> variation by a factor $c$ — that is, $d_{\mathrm{TV}}(\mathrm{chain} > (F_{>j},\mu),\mathrm{chain}(F_{>j},\nu)) \le c\, d_{\mathrm{TV}}(\mu,\nu)$
> for all $\mu,\nu$ — then $\mathrm{so}_j \le c \cdot \mathrm{pt}_j$. The
> endpoint $c=1$ is attained by a lossless suffix (Theorem 7.3) and the
> endpoint $c=0$ is attained by the witness family of Section 5, whose suffix
> contains a constant channel.

So the entire range from "the solo profile measures everything" to "the solo
profile measures nothing" is parameterised by a single number — the contraction
coefficient of the downstream suffix — with no reference whatsoever to which
layer is important. This is the theoretical core of the paper: *layer
importance and solo measurability are independent quantities*.

**Interpretation of the empirical result.** The measurement reported its
smallest damage at the final layer $L_{23}$, which by Corollary 7.4 is exactly
the one layer where solo cost equals point cost with no loss. That number is
therefore trustworthy: the tail's own perturbation under top-$k$ pruning
genuinely is small. It is entirely consistent with the tail being
indispensable, because the tail's established specialness may reside in the
*interaction* between it and the upstream representations — a quantity that
lives in the drift term of Theorem 3.3 and is invisible to arity-$1$
measurement by construction.

---

## 8. Sub-additivity and its sharp constant

The measured joint cost of $1.7\%$ against an additive prediction of $4.8\%$
requires explanation, since Corollary 5.7 shows sub-additivity is not a law.
The explanation is again contraction — this time of the *intact* layers.

> **Theorem 8.1 (Geometric budget).** Let $F$ be a stack of depth $n$ in which
> every intact layer has Dobrushin coefficient at most $\delta \in [0,1]$, and
> let $P$ be a pruning with $d_{\mathrm{TV}}(f_i(a),p_i(a)) \le c$ for every
> layer $i$ and every state $a$. Then
> $$\mathrm{jt} \;\le\; c \sum_{i<n} \delta^{\,i} \;\le\; \frac{c}{1-\delta}
> \quad (\delta<1),$$
> a bound **independent of the depth**.

*Proof sketch.* Refine the telescoping argument of Theorem 4.4: the damage
created at layer $i$ is at most $c$ by uniform perturbation, but it must then
traverse the intact layers $i+1,\dots,n-1$, which damp it by $\delta^{\,n-1-i}$
by Corollary 6.3. Summing over $i$ re-indexes to the stated geometric series.
$\square$

> **Corollary 8.2.** At $\delta = 1/2$ and any depth, $\mathrm{jt} \le 2c$,
> against the additive prediction $nc$. At the measured depth $24$ this is a
> genuine factor-$12$ gain whenever $c > 0$.

Sub-additivity of exactly the observed kind is thus *forced* by contraction,
with no reference to which layer matters. The hypothesis cannot be dropped: the
witness family of Section 5 has all solo costs $0$ and joint cost $1$, and it
violates the contraction hypothesis in the only way available — its forgetful
layer has $\delta = 0$ but its transparent layers have $\delta = 1$.

An upper bound alone, however, cannot convert the measured ratio into a
statement about the network: a loose bound is compatible with any $\delta$. The
bound is in fact attained.

> **Definition 8.3 (Affine two-state layer).** For $\delta, s \ge 0$ with
> $s + \delta \le 1$, let $A_{\delta,s}$ be the channel on $\{0,1\}$ with rows
> $A_{\delta,s}(x) = \mathrm{Bern}(s + \delta x)$.

> **Lemma 8.4.** $(A_{\delta,s})_*\mathrm{Bern}(q) = \mathrm{Bern}(s+\delta q)$,
> $\delta(A_{\delta,s}) = \delta$, and $d_{\mathrm{TV}}(A_{\delta,s}(a), > A_{\delta,s'}(a)) = |s-s'|$ for every $a$. Consequently the $n$-fold iterate
> acts on the Bernoulli parameter by $q \mapsto \delta^n q + s\sum_{i<n} > \delta^{\,i}$.

> **Theorem 8.5 (Sharpness).** For every $\delta, c \ge 0$ with $c+\delta \le > 1$ and every depth $n$, the stack of $n$ copies of $A_{\delta,0}$, pruned to
> $n$ copies of $A_{\delta,c}$, has intact contraction exactly $\delta$,
> uniform per-layer budget exactly $c$, and joint damage exactly
> $c \sum_{i<n}\delta^{\,i}$. Hence no constant smaller than $1$ can be
> inserted in Theorem 8.1: the bound is not improvable.

*Proof sketch.* Each layer injects a fresh $c$ into the Bernoulli parameter and
damps the accumulated gap by $\delta$; by Lemma 8.4 the parameter after $n$
layers is $0$ for the intact stack and $c\sum_{i<n}\delta^i$ for the pruned
one, and (2.6) converts the parameter gap into total variation. $\square$

Because the bound is attained, the sub-additivity ratio becomes an
**estimator**. Writing $R = (\text{additive prediction})/(\text{joint cost})$,
Theorem 8.5 gives the exact relation
$$R \;=\; \frac{n\,c}{c\sum_{i<n}\delta^{\,i}} \;=\; \frac{n(1-\delta)}
{1-\delta^{\,n}}. \tag{8.6}$$

> **Theorem 8.7 (The measured pair, reproduced).** At depth $24$, intact-layer
> contraction $\delta = 8/9$ and uniform per-layer budget $c = 1/500$ give
> - additive prediction $24 \cdot (1/500) = 4.8\%$, exactly the reported
>   figure;
> - joint pruning damage strictly between $1.69\%$ and $1.70\%$, exactly the
>   reported $1.7\%$;
> and the underlying stack has **no distinguished layer** — all $24$ layers are
> identical.

*Proof sketch.* Instantiate Theorem 8.5 and evaluate $\sum_{i<24}(8/9)^i$,
which lies in $[8.4, 8.5]$ (its value is $\approx 8.4674$), so the joint damage
$c\sum \approx 1.693\%$. $\square$

Exact values at depth $24$:

| quantity | value |
|---|---|
| intact-layer contraction $\delta$ | $8/9 \approx 0.8889$ |
| uniform per-layer budget $c$ | $1/500 = 0.2\%$ |
| $\sum_{i<24}(8/9)^i$ | $\approx 8.4674$, proved within $[8.4,8.5]$ |
| additive prediction $24c$ | $4.8\%$ (exact) |
| joint damage $c\sum$ | $\approx 1.693\%$, proved within $(1.69\%,1.70\%)$ |
| sub-additivity factor $24/\sum$ | $\approx 2.835$ |
| measured factor $4.8/1.7$ | $\approx 2.82$ |

A naive reading of the measured factor $2.8$ as $\delta \approx 1 - 1/2.8 \approx 0.64$ inverts $c/(1-\delta)$ against $c$ rather than against the
additive prediction $nc$; the correct relation is (8.6), which at $n=24$ gives
$\delta \approx 0.89$. Both readings agree qualitatively — a generic, mild
amount of forgetting suffices to produce the observed sub-additivity — but only
(8.6) is an estimator.

---

## 9. The arity hierarchy

If arity $1$ is blind, the natural remedy is to raise the arity. This section
determines exactly how far that remedy goes.

### 9.1 Arity two suffices when one layer does the masking

> **Definition 9.1 (Differential pair cost).** For $j < k$, the *differential
> pair cost* at $j$ relative to $k$ is
> $$d_{\mathrm{TV}}\big(\mathrm{chain}(F[k\mapsto q],\mu),\
> \mathrm{chain}(F[j\mapsto p, k\mapsto q],\mu)\big),$$
> i.e. the extra damage from ablating $j$ on top of an already-ablated $k$.

> **Theorem 9.2 (Pair identifiability).** If ablating layer $k$ makes the
> suffix after $j$ lossless, then the differential pair cost at $j$ relative to
> $k$ equals the point cost $\mathrm{pt}_j$ exactly.

*Proof sketch.* Ablating a layer strictly after $j$ leaves the upstream state
$\nu_j$ unchanged, so both runs agree up to layer $j$; Theorem 7.3 applies to
the modified suffix. $\square$

> **Theorem 9.3 (Arity $2$ separates what arity $1$ cannot).** At depth $24$
> there is an intact stack $F$ and two prunings $p, q$ of the transparent
> layers such that every solo cost of either pruning is $0$, while for *every*
> transparent layer $j < 23$ the differential pair costs with the tail layer
> $23$ are $0.017$ and $1$ respectively — a separation of $0.983$ where arity
> $1$ achieves $0$.

Hence for that family the minimal informative arity is exactly $2$, and moving
to pairwise ablation is not a refinement of the protocol but the minimal
protocol with any resolving power at all.

### 9.2 Arity two is not enough in general

> **Definition 9.4 (Two-masker stack).** Let $T^{(n)}$ consist of $n$
> transparent layers followed by **two** totally forgetful layers emitting
> $\delta_0$. Ablation replaces a transparent layer by $\mathrm{const}_ > {\mathrm{Bern}(t)}$ and a forgetful layer by $\mathrm{id}$.

> **Theorem 9.5.** For every $n$ and every $t \in [0,1]$:
> 1. every ablation of a *single* layer of $T^{(n)}$ costs exactly $0$;
> 2. every ablation of a *pair* of layers costs exactly $0$;
> 3. ablating a transparent layer together with **both** forgetful layers
>    (arity $3$) costs exactly $t$.

*Proof sketch.* (1) and (2): among the two forgetful layers, an ablation of
size at most $2$ either leaves one of them intact — and a surviving forgetful
layer resets the state to $\delta_0$, erasing everything upstream — or ablates
both, in which case no transparent layer was touched and the stack is a chain
of identities on input $\delta_0$. (3) With both maskers turned into
identities, the ablated transparent layer's output $\mathrm{Bern}(t)$ is
transmitted to the output; apply (2.6). $\square$

> **Corollary 9.6.** At depth $24$ there are two prunings of one stack agreeing
> at $0$ on *every* ablation of arity $\le 2$ whose arity-$3$ costs are $0.017$
> and $1$.

### 9.3 The general hierarchy

> **Theorem 9.7 (No fixed arity is sound).** Fix $m \ge 1$ and let the stack
> consist of $n$ transparent layers followed by $m$ forgetful layers. Then
> 1. **Blindness.** For *every* ablation set $S$ with $|S| \le m$, the output
>    law is exactly unchanged: the measured cost is $0$.
> 2. **Recovery.** Ablating all $m$ maskers together with one transparent layer
>    $j$ (arity $m+1$) returns exactly the pruning strength $t$.
>
> In particular, for every $m$ with $n+m=24$ there are two prunings of a
> depth-$24$ stack that agree at $0$ on all experiments of arity $\le m$ and
> differ by $0.983$ at arity $m+1$.

*Proof sketch.* The content of (1) is a pigeonhole. Either some masker survives
the ablation, in which case that surviving constant layer resets the state to
$\delta_0$ and every layer after it is either an identity or another constant
$\delta_0$ layer, so the output is $\delta_0$ regardless of anything upstream;
or all $m$ maskers are ablated, and since $|S| \le m$ the set $S$ is exactly
the set of maskers, so no transparent layer was modified and the stack is a
chain of identities on $\delta_0$. Either way the output equals $\delta_0$, the
intact value. For (2), all maskers become identities and the single modified
transparent layer writes $\mathrm{Bern}(t)$, which is transmitted unchanged.
$\square$

Since $m$ is arbitrary, raising the arity of an ablation protocol by any fixed
amount does not make it sound. **The minimal informative ablation arity is not
a universal constant; it grows with the number of layers over which downstream
forgetting is spread.**

---

## 10. Fractional masking and the resolution threshold

Theorem 9.7 is the $\delta = 0$ extreme. The generic case interpolates, and
does so exactly.

> **Definition 10.1 (Probe stack).** Fix $\delta \in [0,1]$, $c \ge 0$ with
> $c+\delta \le 1$, and integers $k \le m$. The probe stack consists of the
> layer under study — $A_{\delta,s}$ with $s=0$ for the intact run and $s=c$
> for the pruned run, so its point cost is exactly $c$ — followed by $m-k$
> intact masking layers (copies of $A_{\delta,0}$, each with Dobrushin
> coefficient $\delta$) and $k$ ablated ones (replaced by the identity, which
> is lossless). The experiment thus has arity $k+1$.

> **Theorem 10.2 (Exact probe cost).** The measured cost of the arity-$(k+1)$
> experiment is exactly
> $$\delta^{\,m-k}\cdot c.$$

*Proof sketch.* Each surviving masking layer multiplies the Bernoulli parameter
gap by exactly $\delta$ (Lemma 8.4 with $s=0$), and each ablated layer
transmits it unchanged. $\square$

> **Corollary 10.3.** (i) At $k = 0$, the solo cost is exactly $\delta^m$ times
> the point cost, so the masking bound of Theorem 6.4 is attained. (ii) The
> measured cost is monotone in the arity: each additional ablated masking layer
> multiplies the measurement by $1/\delta$. (iii) At $k=m$ the measurement
> equals the point cost exactly.

The design consequence is a closed-form threshold. If the experiment can
resolve damage $\varepsilon$, layer $j$ has point cost $\mathrm{pt}$ and is
masked by $m$ layers of coefficient $\delta$, then the smallest arity at which
its damage is visible is
$$1 + m - \left\lceil \log_\delta\!\big(\varepsilon/\mathrm{pt}\big)
\right\rceil. \tag{10.4}$$

> **Theorem 10.5 (Resolution threshold at the measured resolution).** Take
> $\delta = 1/2$, $m = 11$ masking layers, point cost $1/2$, and resolution
> $\varepsilon = 0.006$ (the reported spread of the experiment). Then every
> experiment of arity at most $5$ reports a cost strictly below $\varepsilon$,
> and the arity-$6$ experiment reports a cost strictly above it.

Exact values in this instance ($\text{cost} = 2^{-(11-k)}/2$):

| masking layers ablated $k$ | arity $k+1$ | measured cost | visible? |
|---|---|---|---|
| 0 (solo) | 1 | $1/4096 \approx 0.000244$ | no |
| 1 | 2 | $0.000488$ | no |
| 2 | 3 | $0.000977$ | no |
| 3 | 4 | $0.001953$ | no |
| 4 | 5 | $0.003906$ | no |
| 5 | 6 | $0.007813$ | **yes** |
| 11 (all) | 12 | $0.5$ = point cost | yes |

The solo measurement in this instance is three orders of magnitude below the
damage it is meant to detect. The transition is sharp and is a property of the
contraction coefficient alone: halving $\delta$ moves the threshold by one
layer, and $\delta = 0$ pushes it past every finite arity, recovering Theorem
9.7.

---

## 11. Algorithms

Three procedures follow directly from the theory and are what an experimenter
should run.

**A. Exact damage propagation.** Given a stack of $n$ channels on $|\alpha|$
states, an input law, and a pruning, compute the point, solo and joint costs
exactly. Running the stack costs $O(n|\alpha|^2)$ arithmetic operations; the
full solo profile costs $O(n^2|\alpha|^2)$ naively, or $O(n|\alpha|^2)$ with
prefix/suffix caching (precompute all prefixes forward, then for each $j$ push
the perturbed law through the cached suffix). Exactness is available because
all weights are rational.

**B. Contraction estimation from the sub-additivity ratio.** Given the
additive prediction $A = \sum_j \mathrm{so}_j$ and the measured joint cost $J$,
solve (8.6), $A/J = n(1-\delta)/(1-\delta^n)$, for $\delta \in [0,1)$ by
bisection: the right-hand side is continuous and strictly decreasing in
$\delta$ on $[0,1)$ from $n$ (at $\delta = 0$) to $1$ (as $\delta \to 1$), so
the root is unique whenever $1 < A/J < n$, and bisection converges in
$O(\log(1/\text{tol}))$ evaluations, each $O(\log n)$ with fast exponentiation.

**C. Minimal informative arity.** Given a contraction estimate $\delta$, a
masking depth $m$, a hypothesised point cost, and an experimental resolution
$\varepsilon$, return the smallest $k+1$ with $\delta^{m-k}\mathrm{pt} > \varepsilon$ — formula (10.4), or a linear scan over $k \in \{0,\dots,m\}$ in
$O(m)$ steps. If no $k \le m$ qualifies, no experiment confined to that suffix
can detect the layer at that resolution.

---

## 12. Discussion

### 12.1 What the empirical verdict actually establishes

The reported verdict — no single layer is the bottleneck — is *true as stated
about the measurement*, and Theorem 5.5 shows that as a statement about the
network it is unsupported: two networks that differ maximally in joint pruning
behaviour produce identical, perfectly flat solo profiles. Meanwhile Theorem
6.4 and Corollary 6.5 show that flatness is the default expectation for any
contracting stack of depth $24$, so observing it transmits little information.
The hypothesis that layer importance is non-uniform was not refuted; it was
tested with an instrument that, provably, returns a flat reading either way.

The one component of the measurement that *is* faithful is the tail. By
Corollary 7.4 the final layer's solo cost equals its point cost exactly, so its
reported value of $1.0008$ — best in the stack — is a genuine statement about
that layer's own perturbation. It is fully compatible with the tail being
functionally indispensable, since indispensability of the kind established by
the neighbouring experiments (idiosyncratic weights, non-portability,
divergent decisions) lives in the interaction between the tail and upstream
representations, which is precisely the drift term of Theorem 3.3.

### 12.2 What the sub-additivity establishes

The gap between $4.8\%$ additive and $1.7\%$ joint is genuine information — but
about a global property, not a per-layer one. By Theorems 8.5 and 8.7 it is
reproduced exactly by a stack of $24$ *identical* layers with contraction
$8/9$ and uniform budget $1/500$. Sub-additivity is therefore a measurement of
how much the network forgets, and the correct conversion is (8.6).

### 12.3 Design implications

1. **Report contraction alongside the profile.** The ratio $A/J$ is an
   estimator of $\delta$ (Algorithm B), and $\delta$ determines how much of the
   point profile the solo profile could possibly have seen (Theorem 6.4,
   attained by Corollary 10.3).
2. **Compute the resolution threshold before running the experiment.** Formula
   (10.4) says in advance whether a hypothesised bottleneck at depth $m$ from
   the output is detectable at your resolution. Running below the threshold
   guarantees a flat chart independently of the truth.
3. **Fixed-arity protocols cannot be made sound by increasing the arity.**
   Theorem 9.7 defeats any budget fixed in advance. Sound protocols must be
   adaptive — choosing which layers to co-ablate on the basis of estimated
   contraction, as in Theorem 9.2, where co-ablating the masker converts an
   uninformative measurement into an exact one.
4. **Uniform-in-context budgets are the only composable ones.** Corollary 4.5
   is the sole hypothesis under which per-layer damage budgets add up across
   depth. A budget certified at one upstream state — which is what solo
   ablation certifies — is not enough; Theorem 5.4 shows the discrepancy can be
   the whole of the damage.
5. **The negative conclusion about mixed-precision serving survives, but for a
   different reason.** There is indeed no per-layer budget hierarchy to
   exploit at this scale, but that follows from the separately measured joint
   cost of $1.7\%$, not from the flat profile. Absent the joint measurement, the
   same profile would be equally consistent with catastrophic joint behaviour.

### 12.4 Scope and limitations

The model is finite-state, Markov, and measures damage in total variation.
Real layers are deterministic maps on continuous representations; the
Markov-channel abstraction captures composition and information loss but not
geometry, and total variation is a coarser functional than task loss. What
transfers is the structure of the argument: data processing, contraction, and
the identity of the three cost functionals hold for any composition of
information-losing maps under any monotone divergence. What does not transfer
automatically is the numerical calibration of Section 8, which fits a
one-parameter contraction model to a two-number summary and should be read as
an order-of-magnitude estimator. The witnesses are extremal by design — that
is what makes them proofs of impossibility — and no claim is made that a
trained network resembles them; the claim is that a measurement which cannot
distinguish them is not evidence about which of them one is holding.

---

## 13. Future directions

The most immediate open questions are structural rather than numerical.

**Adaptive protocols with proven guarantees.** Theorem 9.2 shows that
co-ablating the masking layer recovers the point cost exactly. A protocol that
estimates the contraction profile first and then chooses ablation sets to
maximise expected information would be sound where fixed-arity protocols
provably are not. What is the optimal adaptive strategy under a fixed budget of
forward passes?

**Beyond total variation.** The masking theorem holds for any $f$-divergence
with a contraction coefficient; the sharpness results use the two-state affine
family, which has an exact Bernoulli calculus. Which of the sharp constants
survive for KL divergence or for task loss?

**Interaction-aware importance measures.** The drift term in Theorem 3.3 is
what the solo measurement discards. A functional that estimates drift directly
— for example the sensitivity of layer $j$'s point cost to perturbations of its
upstream state — would target the quantity in which the tail's specialness
appears to live.

**Pairwise and joint tail ablations at scale.** Theorem 9.3 predicts that a
pair ablation including the tail should separate hypotheses that solo ablation
cannot. This is directly testable.

**Deeper stacks and the depth-independence of the geometric bound.** Theorem
8.1 gives a depth-independent budget $c/(1-\delta)$. If the estimator (8.6)
returns similar $\delta$ at larger depths, joint pruning damage should saturate
rather than grow with depth — a strong, falsifiable prediction.

**Non-uniform contraction spectra.** All quantitative statements here use a
single $\delta$ bounding every layer. Layerwise coefficients $\delta_i$ replace
$\delta^{m}$ by $\prod_{i>j}\delta_i$ throughout, which would make the
resolution threshold (10.4) layer-specific and the masking profile
non-uniform even when the solo profile is flat — arguably the most realistic
model of a trained stack, and the one most worth measuring.

---

## 14. Conclusion

Layer ablation is a low-pass filter on depth. It reports faithfully at the
output end of a stack — exactly and unconditionally at the final layer — and
attenuates geometrically as one moves upstream, at a rate set by the network's
contraction coefficient and by nothing else. A flat solo profile is therefore
consistent with any joint behaviour whatsoever: at the measured depth of $24$
there are two prunings of a single stack with identical, identically zero solo
profiles whose joint costs are $1.7\%$ and total destruction. Conversely, solo
costs can both be maximal while the joint cost vanishes. The observed
sub-additivity is real information, but about how much the network forgets, not
about which layer matters; a stack of $24$ identical layers reproduces the
measured pair exactly. And the natural remedy of raising the ablation arity
fails in general: for every $m$ there is a depth-$24$ stack on which every
experiment of arity $\le m$ returns exactly $0$ while a single experiment of
arity $m+1$ returns the true damage in full.

The instrument is not broken. It is simply measuring the contraction of the
stack, and its resolution as an importance probe is computable in advance from
that same quantity.
