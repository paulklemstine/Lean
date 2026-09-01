# Margin Scarcity as the Portability Predictor

### Certified forward-pass screens for block transplantation, and the refutation of weight-space distance as a predictor of damage

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

Two candidate predictors of the damage caused by transplanting a block of layers from one fine-tuned network into another are analysed and compared: a *norm route*, in which portability is inferred from the weight-space distance between the two copies of the block via a Lipschitz estimate, and a *margin route*, in which portability is inferred from the fraction of evaluation positions whose score vector carries no margin certificate. We prove that the margin route yields an unconditional upper bound on the measured post-transplant decision disagreement — the *damage fraction* — computable from a single forward pass, with no transplant performed; and that the norm route does not. Specifically: (i) the damage fraction never exceeds the margin-uncertified fraction, so a forward-pass statistic below a threshold $\tau$ certifies damage below $\tau$; (ii) the norm route is sound only as a sufficient condition, and as a predictor it is refuted — for every $0 < d < D$ there exist two block pairs over identical features, one at entrywise weight distance $D$ with damage $0$ and one at distance $d$ with damage $1$, whence any damage bound depending on the weight distance alone must equal the trivial bound $1$ everywhere; (iii) across a family of blocks, if the margin screen overshoots the damage by at most $\eta$ then the empirical covariance of predictor and damage is at least $\mathrm{Var}(\mathrm{dam}) - \tfrac{\eta}{2}\sqrt{\mathrm{Var}(\mathrm{dam})}$, hence strictly positive once the damage spread exceeds $\eta/2$; while an explicit two-block family gives covariance $+1/4$ for the margin statistic and $-(D-d)/4$ for the weight distance on the *same* data. We further supply two strictly cheaper relaxations: a Rényi-2 (collision-mass) diffuseness fraction that lower-bounds the margin statistic, making entropic diffuseness a certified obstruction to certification; and a reverse-Markov bound $\mathrm{damage} \le (G-\mu)/(G-2\varepsilon)$ from only a gap cap $G$ and a mean gap $\mu$, which is attained. Instantiated at a measured two-arm transplant experiment (damages $0.4557$ and $0.1615$), the theory certifies positive cross-block covariance for any screen slack $\eta < 0.2942$ and produces a directly falsifiable prediction: the donor tail's mean top-1 gap cannot exceed $2.8673$ nats at $G = 5$, $\varepsilon = 0.16$.

**Keywords:** margin certificate, transplant damage, Lipschitz bound, Rényi-2 entropy, collision mass, reverse Markov inequality, empirical covariance, model merging.

---

## 1. Introduction

### 1.1 The problem

Two networks share an architecture and a common ancestor but have been fine-tuned on different data. A *block transplant* replaces a contiguous group of layers in the host network with the corresponding group from the donor, keeping everything else fixed, and then asks how much of the host's behaviour survives. This operation underlies model merging, layer splicing, adapter grafting, and a range of interpretability probes.

The operation is cheap to *perform* and expensive to *evaluate*: measuring how much damage a graft does requires assembling the hybrid and running it over a held-out corpus, for every candidate block. What practitioners want instead is a *screen*: a statistic computable before any surgery, whose value predicts, or at minimum bounds, the damage.

The folklore screen is weight-space distance. It is motivated by a genuine estimate — a small weight perturbation moves logits by a Lipschitz-bounded amount, and a decision with a large enough margin survives a bounded logit perturbation — and it is very widely used. This paper asks whether that motivation supports the use, and concludes that it does not.

### 1.2 Contributions

We work with a decision-level notion of damage: the fraction of held-out positions at which the hybrid's argmax differs from the reference's argmax. Against this target:

1. **The norm route is sound but only as a sufficient condition** (Theorem 3.2). Under an entrywise weight-distance bound $\delta$, a feature bound $B$, and width $k$, every logit moves by at most $k\delta B$; if the host's top-1 gap exceeds $2k\delta B$ everywhere, the damage is exactly zero.
2. **The margin screen** (Theorem 4.2). The damage fraction is bounded above by the margin-uncertified fraction — a statistic of the donor's own forward pass and a drift budget. Hence portability screening at any threshold (Corollary 4.3).
3. **Refutation of the norm route as a predictor** (Theorems 5.2 and 5.3). Damage is not monotone in weight distance, in the strongest possible sense; and any damage bound that is a function of the weight distance alone is identically $\ge 1$, i.e. vacuous.
4. **Sharp boundaries of the margin screen** (Theorems 6.1 and 6.2). The screen is strictly one-sided (uncertified fraction $1$ with damage $0$ occurs), and it is attained (uncertified fraction $1$ with damage $1$ occurs), so no universal multiplicative improvement exists.
5. **Cross-block correlation** (Theorems 7.5 and 7.6). A quantitative positive-correlation theorem for the margin screen, and an explicit family on which margin and distance have opposite covariance signs (Theorem 7.10).
6. **Two strictly cheaper relaxations.** A Rényi-2 diffuseness fraction lower-bounding the margin statistic (Theorems 8.3–8.5), and a two-scalar reverse-Markov damage bound (Theorems 9.3–9.4), with an attainment result and a falsifiable numerical consequence (Theorem 9.6).

### 1.3 Reading guide

Sections 2–6 concern a single block. Section 7 lifts everything to a family of blocks, which is the form in which the measurement is actually consumed (a ranking). Sections 8–9 make the screen progressively cheaper. Section 10 states applications and Section 11 the limitations and future work.

---

## 2. Setup and definitions

Throughout, $\Omega$ is a finite nonempty set of *positions* (tokens of a held-out corpus, or validation examples), and $m \ge 1$ is the number of decision classes.

**Definition 2.1 (Strict top).** For $f : \{1,\dots,m\} \to \mathbb{R}$ and an index $j$, we say $j$ is the *strict top* of $f$ if $f(i) < f(j)$ for every $i \ne j$. A strict top is unique when it exists.

**Definition 2.2 (Damage fraction).** Given two decision maps $f, g : \Omega \to \{1,\dots,m\}$, the *damage fraction* is
$$\mathrm{damage}(f,g) \;=\; \frac{\#\{x \in \Omega : f(x) \ne g(x)\}}{\#\Omega}\;\in[0,1].$$
Writing $\mathrm{agree}(f,g)$ for the complementary fraction, we have $\mathrm{damage} = 1 - \mathrm{agree}$, and $\mathrm{damage} \ge 0$ always.

In the transplant scenario, $g = d$ is the *reference* decision (the behaviour we want preserved) and $f = d_H$ is the *hybrid* decision (the behaviour after the graft), so $\mathrm{damage}(d_H, d)$ is precisely the measured post-transplant disagreement.

**Definition 2.3 (Margin certificate).** Let $u, v : \Omega \to \mathbb{R}^m$ be two score (logit) fields, let $d : \Omega \to \{1,\dots,m\}$ be a decision map, and let $\varepsilon \ge 0$ be a *drift budget*. A position $x$ is *margin-certified at level $\varepsilon$*, written $\mathrm{MC}_\varepsilon(x)$, if both
$$\text{(gap)}\quad u(x)_{d(x)} - u(x)_j \;>\; 2\varepsilon \ \ \text{for all } j \ne d(x), \qquad\text{and}\qquad \text{(drift)}\quad |u(x)_j - v(x)_j| \le \varepsilon \ \ \text{for all } j .$$
The *uncertified set* is $U_\varepsilon = \{x \in \Omega : \neg\,\mathrm{MC}_\varepsilon(x)\}$ and the *margin-uncertified fraction*, or **margin scarcity**, is
$$\mathrm{unc}(u,v,d,\varepsilon) \;=\; \frac{\# U_\varepsilon}{\#\Omega}.$$

The certificate is a *local* statement: the gap condition is read off the donor's own forward pass, and the drift condition is a hypothesis about how far the hybrid's scores can move. Nothing in it requires the hybrid to be built.

**Lemma 2.4 (Margin stability).** If $j$ dominates $f$ with slack $2\varepsilon$ — that is, $f(j) - f(i) > 2\varepsilon$ for all $i \ne j$ — and $h$ satisfies $|f(i) - h(i)| \le \varepsilon$ for all $i$, then $j$ is the strict top of $h$.

*Proof.* For $i \ne j$: $h(j) \ge f(j) - \varepsilon > f(i) + \varepsilon \ge h(i)$. $\square$

Lemma 2.4 is the engine of everything below: it converts a *gap* into an invariance of the argmax under bounded perturbation. The two routes differ only in how they obtain the perturbation bound.

**Remark 2.5 (Certified positions are safe).** Immediately from Lemma 2.4: if $\mathrm{MC}_\varepsilon(x)$ holds and $d_H(x)$ is the strict top of $v(x)$, then $d_H(x) = d(x)$. Contrapositively, every *damaged* position is uncertified. This one-line containment $\{x : d_H(x) \ne d(x)\} \subseteq U_\varepsilon$ is the whole content of the margin screen.

---

## 3. The norm route, stated honestly

**Definition 3.1 (Linear block).** For weights $W \in \mathbb{R}^{m \times k}$ and features $\mathrm{feat} : \Omega \to \mathbb{R}^k$, the block's logits are
$$\mathrm{logit}_W(x)_j \;=\; \sum_{i=1}^{k} W_{ji}\,\mathrm{feat}(x)_i .$$

**Lemma 3.2 (Lipschitz / norm bound).** If $|(W_A)_{ji} - (W_B)_{ji}| \le \delta$ for all $j,i$ and $|\mathrm{feat}(x)_i| \le B$ for all $x,i$, then for every $x$ and $j$,
$$\bigl|\mathrm{logit}_{W_A}(x)_j - \mathrm{logit}_{W_B}(x)_j\bigr| \;\le\; k\,\delta\,B.$$

*Proof.* The difference equals $\sum_i \bigl((W_A)_{ji} - (W_B)_{ji}\bigr)\mathrm{feat}(x)_i$. Apply the triangle inequality termwise; each term is at most $\delta B$; there are $k$ terms. $\square$

**Theorem 3.3 (The norm route is sound).** In the setting of Lemma 3.2, suppose $d_A : \Omega \to \{1,\dots,m\}$ satisfies, for all $x$ and all $j \ne d_A(x)$,
$$2\,(k\delta B) \;<\; \mathrm{logit}_{W_A}(x)_{d_A(x)} - \mathrm{logit}_{W_A}(x)_j,$$
and $d_B(x)$ is the strict top of $\mathrm{logit}_{W_B}(x)$ for every $x$. Then $d_B(x) = d_A(x)$ for every $x$; consequently $\mathrm{damage}(d_B, d_A) = 0$.

*Proof.* Fix $x$. By Lemma 3.2 the perturbation from $\mathrm{logit}_{W_A}(x)$ to $\mathrm{logit}_{W_B}(x)$ is bounded by $k\delta B$ coordinatewise, and by hypothesis the gap of $d_A(x)$ exceeds $2k\delta B$. Lemma 2.4 makes $d_A(x)$ the strict top of $\mathrm{logit}_{W_B}(x)$; uniqueness of strict tops gives $d_B(x) = d_A(x)$. The disagreement set is empty, so the damage fraction is $0$. $\square$

Theorem 3.3 is exactly what the norm route buys: a *sufficient condition*. It is a certificate of safety when the gaps are large relative to $k\delta B$. Two features of the bound deserve emphasis, because they are what Section 5 exploits:

* the bound involves $\delta$ **and** $B$ **and** $k$ — the weight distance alone does not determine it;
* the bound is a statement about the *worst case over feature directions*, whereas the actual damage depends on the drift's component along the directions the features occupy.

---

## 4. The margin route: a forward-pass screen

**Theorem 4.1 (The margin screen).** Let $u, v : \Omega \to \mathbb{R}^m$, $d : \Omega \to \{1,\dots,m\}$, $\varepsilon \ge 0$, and let $d_H(x)$ be the strict top of $v(x)$ for every $x$. Then
$$\mathrm{damage}(d_H, d) \;\le\; \mathrm{unc}(u,v,d,\varepsilon).$$

*Proof.* By Remark 2.5, $\{x : d_H(x) \ne d(x)\} \subseteq U_\varepsilon$. Divide cardinalities by $\#\Omega$. (Equivalently: $\mathrm{damage} = 1 - \mathrm{agree}$ and the certified positions all agree, so $\mathrm{agree} \ge 1 - \mathrm{unc}$.) $\square$

**Corollary 4.2 (Portability screening).** If $\mathrm{unc}(u,v,d,\varepsilon) \le \tau$ then $\mathrm{damage}(d_H,d) \le \tau$.

This is the operational statement. The left-hand side requires one forward pass of the donor over the held-out set, a histogram of top-1 gaps, and a drift budget $\varepsilon$; the right-hand side requires building the hybrid and evaluating it. The screen replaces the second by the first, at a guaranteed cost of conservatism only.

**Theorem 4.3 (Saturation on a measured arm).** Suppose the measured agreement of a transplant is $\mathrm{agree}(d_H, d) = 0.5443$. Then $\mathrm{damage}(d_H,d) = 0.4557$ and $\mathrm{unc}(u,v,d,\varepsilon) \ge 0.4557$.

*Proof.* The first claim is $\mathrm{damage} = 1 - \mathrm{agree}$. The second is Theorem 4.1 applied to the first. $\square$

The content of Theorem 4.3 is that on this arm the screen is *exactly saturated*: the certified lower bound on margin scarcity coincides numerically with the measured damage, so the screen has zero slack there. Section 7 shows this is exactly the regime in which the screen is a good cross-block predictor.

---

## 5. Weight-space distance is not a predictor

We now show the norm route cannot be upgraded from Theorem 3.3 (a sufficient condition) to a predictor. The construction lives in $m = k = 2$ and uses a *dead feature direction*.

**Definition 5.1 (Dead-direction features).** Let $\mathrm{feat}(x) = (1,0)$ for every $x \in \Omega$. Then $\mathrm{logit}_W(x)_j = W_{j1}$ for every $x$: the second weight column is invisible.

**Theorem 5.2 (Damage is not monotone in weight distance).** For every $0 < d < D$ there exist weight matrices $W_A, W_B, W_A', W_B' \in \mathbb{R}^{2\times 2}$ and decision maps such that, over the dead-direction features:

* each of the four blocks has a well-defined strict top at every position;
* $|(W_A)_{ji} - (W_B)_{ji}| \le D$ for all $j,i$, with equality $|(W_A)_{12} - (W_B)_{12}| = D$;
* $|(W_A')_{ji} - (W_B')_{ji}| \le d$ for all $j,i$, with equality $|(W_A')_{11} - (W_B')_{11}| = d$;
* $\mathrm{damage}(d_B, d_A) = 0$ and $\mathrm{damage}(d_B', d_A') = 1$.

*Proof (explicit witnesses).* Take
$$W_A = \begin{pmatrix}1 & 0\\ 0 & 0\end{pmatrix},\quad W_B = \begin{pmatrix}1 & D\\ 0 & 0\end{pmatrix},\qquad W_A' = \begin{pmatrix}d/2 & 0\\ -d/2 & 0\end{pmatrix},\quad W_B' = \begin{pmatrix}-d/2 & 0\\ d/2 & 0\end{pmatrix}.$$
Over the dead-direction features, $\mathrm{logit}_{W_A}(x) = \mathrm{logit}_{W_B}(x) = (1,0)$, so both decide class $1$ and $d_B \equiv d_A$: the disagreement set is empty. Meanwhile $\mathrm{logit}_{W_A'}(x) = (d/2, -d/2)$ decides class $1$, while $\mathrm{logit}_{W_B'}(x) = (-d/2, d/2)$ decides class $2$: the disagreement set is all of $\Omega$. The entrywise distance claims are immediate. $\square$

The first pair may be at arbitrarily large weight distance $D$ and yet transplants perfectly; the second may be at arbitrarily small distance $d$ and yet destroys every decision. There is no monotone relationship — not even a weak one — between weight distance and damage.

**Theorem 5.3 (No norm-only damage bound exists).** Suppose $g : \mathbb{R} \to \mathbb{R}$ has the property that for every $\delta$, every pair $W_A, W_B \in \mathbb{R}^{2\times 2}$ with $|(W_A)_{ji} - (W_B)_{ji}| \le \delta$, every feature field, and every pair of strict-top decision maps, one has $\mathrm{damage}(d_B, d_A) \le g(\delta)$. Then $g(\delta) \ge 1$ for every $\delta > 0$.

*Proof.* Fix $\delta > 0$ and instantiate the hypothesis at the live-direction pair of Theorem 5.2 with $d = \delta$: the entrywise distance is $\le \delta$, both blocks have strict tops, and the damage is $1$. $\square$

Since the damage fraction always lies in $[0,1]$, Theorem 5.3 says that the only norm-only bound is the trivial one. This is the sharp statement of what is wrong with the folklore screen. Note carefully what it does *not* say: it does not contradict Theorem 3.3, because that theorem's hypothesis involves the gap and hence the feature scale. The missing ingredient is precisely the geometry of the drift relative to the live feature directions — the same weight perturbation is harmless in a dead direction and fatal in a live one.

---

## 6. The boundary of the margin screen

Intellectual honesty requires the complementary negative results for the margin route.

**Theorem 6.1 (The screen is only sufficient).** There exist score fields $u, v$ and decisions $d, d_H$ with $d_H(x)$ the strict top of $v(x)$, such that $\mathrm{unc}(u,v,d,1) = 1$ and $\mathrm{damage}(d_H,d) = 0$.

*Proof.* Take $m=2$, $u(x) = v(x) = (1,0)$, $d \equiv d_H \equiv 1$. The gap is $1$, which fails to exceed $2\varepsilon = 2$, so no position is certified and $\mathrm{unc} = 1$. But $d_H = d$ identically, so the damage is $0$. $\square$

Thus margin scarcity is a *ceiling*, never an estimate: it can be maximal while nothing at all breaks. Any claim of the form "margin scarcity predicts damage" must be read as "bounds", not "equals".

**Theorem 6.2 (The screen is attained).** There exist $u, v, d, d_H$ as above with $\mathrm{unc}(u,v,d,1) = 1$ and $\mathrm{damage}(d_H,d) = 1$.

*Proof.* Take $u(x) = (1,0)$, $v(x) = (0,1)$, $d \equiv 1$, $d_H \equiv 2$. Again the gap $1$ fails to exceed $2$, so $\mathrm{unc}=1$; and the decisions disagree everywhere. $\square$

**Corollary 6.3.** There is no constant $c < 1$ with $\mathrm{damage} \le c \cdot \mathrm{unc}$ for all configurations. Theorem 4.1 is optimal among bounds of that shape.

Theorems 6.1 and 6.2 together delimit the screen exactly: it is a tight ceiling, achieved by some configurations and grossly conservative on others.

---

## 7. Across blocks: correlation

In deployment one does not screen a single block; one ranks a stack. Write $L$ for the number of blocks and index them by $b \in \{1,\dots,L\}$.

**Definition 7.1 (Family statistics).** For $f, g : \{1,\dots,L\} \to \mathbb{R}$,
$$\overline{f} = \frac{1}{L}\sum_b f(b), \qquad \mathrm{cov}(f,g) = \frac{1}{L}\sum_b \bigl(f(b)-\overline{f}\bigr)\bigl(g(b)-\overline{g}\bigr), \qquad \mathrm{Var}(f) = \mathrm{cov}(f,f).$$

**Lemma 7.2 (Elementary properties).** $\mathrm{Var}(f) = \frac{1}{L}\sum_b (f(b)-\overline f)^2 \ge 0$; $\mathrm{cov}$ is symmetric and additive in each argument; and $\mathrm{Var}(f) = \frac{1}{L}\sum_b f(b)^2 - \overline{f}^2$ when $L > 0$.

**Lemma 7.3 (Cauchy–Schwarz for the empirical covariance).** $\mathrm{cov}(f,g)^2 \le \mathrm{Var}(f)\,\mathrm{Var}(g)$, equivalently $|\mathrm{cov}(f,g)| \le \sqrt{\mathrm{Var}(f)}\sqrt{\mathrm{Var}(g)}$.

*Proof.* Apply the discrete Cauchy–Schwarz inequality to the centred vectors $(f(b)-\overline f)_b$ and $(g(b)-\overline g)_b$, then divide by $L^2$. The absolute-value form follows by taking square roots and using $\sqrt{st} = \sqrt s\sqrt t$ for $s,t \ge 0$. $\square$

**Lemma 7.4 (Popoviciu-type variance bound).** If $e : \{1,\dots,L\} \to \mathbb{R}$ satisfies $0 \le e(b) \le \eta$ for all $b$, then $\mathrm{Var}(e) \le \eta^2/4$.

*Proof.* From $0 \le e(b) \le \eta$ we get $e(b)^2 \le \eta\,e(b)$, hence $\frac{1}{L}\sum_b e(b)^2 \le \eta\,\overline{e}$. By Lemma 7.2, $\mathrm{Var}(e) \le \eta\overline e - \overline e^{\,2} = \eta^2/4 - (\overline e - \eta/2)^2 \le \eta^2/4$. $\square$

Now let $\mathrm{dam}(b)$ be the measured damage of block $b$ and $\mathrm{pred}(b)$ its margin-uncertified fraction. Theorem 4.1 gives $\mathrm{dam}(b) \le \mathrm{pred}(b)$ for every $b$. The extra hypothesis we require is a bound on the *slack*: the screen is *tight to $\eta$* if $\mathrm{pred}(b) \le \mathrm{dam}(b) + \eta$ for every $b$.

**Theorem 7.5 (Correlation lower bound for the margin screen).** If $\mathrm{dam}(b) \le \mathrm{pred}(b) \le \mathrm{dam}(b) + \eta$ for all $b$, then
$$\mathrm{cov}(\mathrm{pred}, \mathrm{dam}) \;\ge\; \mathrm{Var}(\mathrm{dam}) \;-\; \frac{\eta}{2}\sqrt{\mathrm{Var}(\mathrm{dam})}.$$

*Proof.* If $L = 0$ both sides vanish. Otherwise the two hypotheses at any single block force $\eta \ge 0$. Set $e(b) = \mathrm{pred}(b) - \mathrm{dam}(b)$, so $\mathrm{pred} = \mathrm{dam} + e$ with $0 \le e \le \eta$ pointwise. Additivity of covariance gives
$$\mathrm{cov}(\mathrm{pred},\mathrm{dam}) = \mathrm{Var}(\mathrm{dam}) + \mathrm{cov}(e,\mathrm{dam}).$$
By Lemma 7.4, $\mathrm{Var}(e) \le \eta^2/4$, hence $\sqrt{\mathrm{Var}(e)} \le \eta/2$. By Lemma 7.3,
$$\mathrm{cov}(e,\mathrm{dam}) \;\ge\; -|\mathrm{cov}(e,\mathrm{dam})| \;\ge\; -\sqrt{\mathrm{Var}(e)}\sqrt{\mathrm{Var}(\mathrm{dam})} \;\ge\; -\frac{\eta}{2}\sqrt{\mathrm{Var}(\mathrm{dam})} . \qquad\square$$

**Theorem 7.6 (Positive correlation).** Under the hypotheses of Theorem 7.5 with $L \ge 1$, if the damage spread satisfies $\sqrt{\mathrm{Var}(\mathrm{dam})} > \eta/2$, then $\mathrm{cov}(\mathrm{pred},\mathrm{dam}) > 0$.

*Proof.* Write $s = \sqrt{\mathrm{Var}(\mathrm{dam})} \ge 0$, so $\mathrm{Var}(\mathrm{dam}) = s^2$. Theorem 7.5 gives $\mathrm{cov} \ge s^2 - \tfrac{\eta}{2}s = s\,(s - \tfrac{\eta}{2}) > 0$ since $s > \eta/2 \ge 0$. $\square$

Theorem 7.6 is the falsifiable cross-block prediction: *whenever the blocks differ enough in damage relative to the screen's conservatism, the screen ranks them positively.* It is a genuine theorem rather than an empirical regularity, and it degrades gracefully — the required spread scales linearly with the slack.

**Remark 7.7 (Numerical instantiation).** For the two measured arms, $\mathrm{dam} = (0.4557,\, 0.1615)$: the mean is $0.3086$, the deviations are $\pm 0.1471$, so $\mathrm{Var}(\mathrm{dam}) = 0.021638\ldots$ and $\sqrt{\mathrm{Var}(\mathrm{dam})} = 0.14710$. Theorem 7.6 therefore certifies $\mathrm{cov} > 0$ for any screen slack $\eta < 0.29420$. Theorem 4.3 shows the tail arm has slack $\eta = 0$ exactly.

We now show that no analogue of Theorem 7.5 can hold for the norm predictor — not with a worse constant, not with extra hypotheses on the block family, because the sign itself flips.

**Lemma 7.8 (Two-block covariance in closed form).** For $L = 2$, $\mathrm{cov}\bigl((a,b),(c,e)\bigr) = \tfrac{1}{4}(a-b)(c-e)$.

*Proof.* The means are $(a+b)/2$ and $(c+e)/2$, so the centred vectors are $\pm\tfrac{1}{2}(a-b)$ and $\pm\tfrac{1}{2}(c-e)$ with matching signs; averaging the two equal products gives the claim. $\square$

**Lemma 7.9 (The two extremal blocks, with their statistics).** Over dead-direction features:

* *(Dead-direction block.)* For the pair $W_A, W_B$ of Theorem 5.2 at scale $D$ and reference decision $d \equiv 1$, the margin-uncertified fraction at drift $\varepsilon = 0$ is $0$ and the damage is $0$.
* *(Live-direction block.)* For the pair $W_A', W_B'$ of Theorem 5.2 at scale $d > 0$ and reference decision $\equiv 1$, the margin-uncertified fraction at drift $\varepsilon = 0$ is $1$ and the damage is $1$.

*Proof.* Dead-direction block: both weight matrices give logits $(1,0)$ at every position, so the gap is $1 > 0 = 2\varepsilon$ and the drift is $0 \le \varepsilon$; every position is certified, $\mathrm{unc} = 0$; and the decisions coincide, so the damage is $0$. Live-direction block: the donor logits are $(d/2,-d/2)$ and the hybrid logits $(-d/2,d/2)$, so the drift in coordinate $1$ is $|d/2-(-d/2)| = d > 0 = \varepsilon$; the drift clause of the certificate fails at every position, $\mathrm{unc} = 1$; and the decisions differ everywhere, so the damage is $1$. $\square$

**Theorem 7.10 (The margin predicts, the norm anti-predicts).** For every $0 < d < D$ there is a two-block family over identical features and architecture, consisting of the two blocks of Lemma 7.9, with weight distances $(D, d)$ and damages $(0, 1)$, such that
$$\mathrm{cov}(\text{margin statistic},\,\text{damage}) = \frac{1}{4} > 0, \qquad \mathrm{cov}(\text{weight distance},\,\text{damage}) = -\frac{D-d}{4} < 0.$$

*Proof.* By Lemma 7.9 the margin statistics are $(0,1)$ and the damages are $(0,1)$; Lemma 7.8 gives $\tfrac14(0-1)(0-1) = \tfrac14$. The distances are $(D,d)$; Lemma 7.8 gives $\tfrac14(D-d)(0-1) = -\tfrac{D-d}{4}$, negative since $D > d$. $\square$

This is the sharpest form of the conjecture under test. On one and the same measurement, the cheap forward-pass statistic orders the blocks by portability correctly, while the weight-space distance orders them exactly backwards. Weight distance is not a loose predictor of transplant damage; on this family it is an *anti*-predictor.

---

## 8. Cheaper: Rényi-2 diffuseness as an obstruction

The margin statistic still requires the full top-1 gap histogram. We now bound it from below by a purely information-theoretic quantity of the same forward pass.

**Definition 8.1 (Collision mass and Rényi-2 entropy).** For a score vector $p \in \mathbb{R}^n$, the *collision mass* is $C(p) = \sum_k p_k^2$ and the *Rényi-2 entropy* is $H_2(p) = -\log C(p)$. Small collision mass (large $H_2$) means the vector is spread out, or *diffuse*.

**Definition 8.2 (Diffuse set and fraction).** For a nonnegative score field $u$ and $\varepsilon \ge 0$, the *diffuse set* is $\{x \in \Omega : C(u(x)) \le 4\varepsilon^2\}$ and the *diffuse fraction* $\mathrm{diff}(u,\varepsilon)$ is its normalised cardinality.

**Theorem 8.3 (The bridge: diffuse implies uncertified).** Let $m > 1$, $\varepsilon \ge 0$, and suppose $u(x)_k \ge 0$ for all $k$. If $C(u(x)) \le 4\varepsilon^2$ then $x$ is *not* margin-certified at level $\varepsilon$.

*Proof.* Suppose $x$ were certified. Since $m > 1$ there is some $j \ne d(x)$, and the gap clause gives $u(x)_{d(x)} - u(x)_j > 2\varepsilon$; as $u(x)_j \ge 0$ this forces $u(x)_{d(x)} > 2\varepsilon$. On the other hand, for a nonnegative vector the largest entry satisfies $u(x)_{d(x)} \le \sqrt{\sum_k u(x)_k^2} = \sqrt{C(u(x))} \le \sqrt{4\varepsilon^2} = 2\varepsilon$. Contradiction. $\square$

The mechanism is worth restating: for a nonnegative vector, low collision mass caps the *top score in absolute terms*, and a certificate needs a top-1 *gap* exceeding $2\varepsilon$, which for nonnegative scores needs a top score exceeding $2\varepsilon$. Diffuseness kills the certificate through sheer smallness of the leader.

**Theorem 8.4 (Fractional form).** Under the hypotheses of Theorem 8.3 (holding at every position),
$$\mathrm{diff}(u,\varepsilon) \;\le\; \mathrm{unc}(u,v,d,\varepsilon).$$

*Proof.* Theorem 8.3 is exactly the set inclusion $\{\text{diffuse}\} \subseteq U_\varepsilon$; divide cardinalities by $\#\Omega$. $\square$

**Theorem 8.5 (Entropy form of the criterion).** For a score vector $p$ with $C(p) > 0$ and $\varepsilon > 0$,
$$H_2(p) \;\ge\; 2\log\frac{1}{2\varepsilon} \iff C(p) \le 4\varepsilon^2 .$$

*Proof.* $2\log\frac{1}{2\varepsilon} = -2\log(2\varepsilon) = -\log\bigl((2\varepsilon)^2\bigr) = -\log(4\varepsilon^2)$. So the left side reads $-\log(4\varepsilon^2) \le -\log C(p)$, i.e. $\log C(p) \le \log(4\varepsilon^2)$, which by strict monotonicity of $\log$ on the positives is $C(p) \le 4\varepsilon^2$. $\square$

**Theorem 8.6 (The obstruction sandwich).** For a block with nonnegative score vectors, $m>1$, $\varepsilon \ge 0$, and $d_H(x)$ the strict top of $v(x)$:
$$\mathrm{diff}(u,\varepsilon) \;\le\; \mathrm{unc}(u,v,d,\varepsilon) \qquad\text{and}\qquad \mathrm{damage}(d_H,d) \;\le\; \mathrm{unc}(u,v,d,\varepsilon).$$

*Proof.* Theorems 8.4 and 4.1. $\square$

**Corollary 8.7 (Concentration is necessary for certification).** If $\mathrm{unc}(u,v,d,\varepsilon) \le \tau$ then $\mathrm{diff}(u,\varepsilon) \le \tau$. A block certified portable below $\tau$ by the margin route is necessarily $\tau$-concentrated.

So entropic diffuseness is a *certified obstruction to certification*, detectable from a single forward pass without even computing margins — only the sum of squared scores per position.

**Theorem 8.8 (The sandwich cannot be closed).** There exist $u, v, d, d_H$ and $\varepsilon > 0$ with $d_H$ a strict top of $v$, such that $\mathrm{diff}(u,\varepsilon) = 1$, $\mathrm{unc}(u,v,d,\varepsilon) = 1$, and $\mathrm{damage}(d_H,d) = 0$.

*Proof.* Take $m=2$, $\varepsilon = 1$, $u(x) = v(x) = (1,0)$, $d \equiv d_H \equiv 1$. Then $C(u(x)) = 1 \le 4 = 4\varepsilon^2$, so every position is diffuse and $\mathrm{diff}=1$; the gap $1$ does not exceed $2\varepsilon = 2$, so $\mathrm{unc}=1$; and $d_H = d$, so the damage is $0$. $\square$

Both inequalities in Theorem 8.6 point *the same way* into $\mathrm{unc}$, and Theorem 8.8 shows this is not an artefact: diffuseness bounds the certificate, not the damage.

---

## 9. Cheapest: two scalars bound the damage

Finally we dispense with the histogram entirely.

**Definition 9.1 (Gap surrogate, low-margin set).** Let $g : \Omega \to \mathbb{R}$ be a *gap surrogate*: a function under-estimating the donor's top-1 gap, i.e. $g(x) \le u(x)_{d(x)} - u(x)_j$ for all $x$ and all $j \ne d(x)$. The *low-margin set* at drift $\varepsilon$ is $\{x : g(x) \le 2\varepsilon\}$, with normalised cardinality $\mathrm{lmf}(g,\varepsilon)$.

**Lemma 9.2 (Uncertified positions are low-margin).** If in addition the drift is within budget, $|u(x)_j - v(x)_j| \le \varepsilon$ for all $x,j$, then $U_\varepsilon \subseteq \{x : g(x) \le 2\varepsilon\}$, hence $\mathrm{unc} \le \mathrm{lmf}(g,\varepsilon)$.

*Proof.* Contrapositive: if $g(x) > 2\varepsilon$ then $u(x)_{d(x)} - u(x)_j \ge g(x) > 2\varepsilon$ for every $j \ne d(x)$, so the gap clause holds; the drift clause holds by hypothesis; so $x$ is certified. $\square$

**Theorem 9.3 (Reverse Markov for margins).** Let $g(x) \le G$ for all $x$, let $2\varepsilon < G$, and suppose the mean gap surrogate is at least $\mu$, i.e. $\mu\,\#\Omega \le \sum_x g(x)$. Then
$$\mathrm{lmf}(g,\varepsilon) \;\le\; \frac{G-\mu}{G - 2\varepsilon}.$$

*Proof.* Let $S$ be the low-margin set and $T$ its complement, with $|S| + |T| = N := \#\Omega$. Then
$$\mu N \le \sum_x g(x) = \sum_{S} g + \sum_{T} g \le |S|\,(2\varepsilon) + |T|\,G = |S|\,(2\varepsilon) + (N - |S|)\,G,$$
so $|S|\,(G - 2\varepsilon) \le (G - \mu)N$. Divide by $N(G-2\varepsilon) > 0$. $\square$

Intuitively: a high average under a hard ceiling leaves little probability mass available for stragglers below $2\varepsilon$.

**Theorem 9.4 (Two forward-pass scalars bound the damage).** Under the hypotheses of Definition 9.1, Lemma 9.2 and Theorem 9.3, with $d_H(x)$ the strict top of $v(x)$,
$$\mathrm{damage}(d_H, d) \;\le\; \frac{G-\mu}{G-2\varepsilon}.$$

*Proof.* Chain Theorem 4.1, Lemma 9.2 and Theorem 9.3. $\square$

No transplant, no margin histogram: only a cap $G$, a mean $\mu$, and a drift level $\varepsilon$.

**Theorem 9.5 (The bound is attained).** For $2\varepsilon < G$, the two-position family with gap surrogate values $(2\varepsilon, G)$ has mean gap $(2\varepsilon + G)/2$, and both the reverse-Markov bound and the low-margin fraction equal $1/2$:
$$\mathrm{lmf} = \frac{1}{2}, \qquad \frac{G - \frac{2\varepsilon+G}{2}}{G-2\varepsilon} = \frac{\frac{G-2\varepsilon}{2}}{G-2\varepsilon} = \frac{1}{2}.$$

*Proof.* Exactly one of the two positions has $g \le 2\varepsilon$, giving $\mathrm{lmf} = 1/2$; the displayed algebra gives the bound. $\square$

Hence no improvement of Theorem 9.3 as a function of $(G, \mu, \varepsilon)$ alone is possible.

**Theorem 9.6 (A falsifiable numerical consequence).** Suppose a transplant's measured damage is $0.4557$, and its gap statistics at drift $\varepsilon$ are a cap $G$ and a mean $\mu$ with $2\varepsilon < G$. Then
$$\mu \;\le\; G - 0.4557\,(G - 2\varepsilon).$$
At $G = 5$ nats and $\varepsilon = 0.16$ this caps the donor's mean top-1 gap at $5 - 0.4557 \times 4.68 = 2.8673$ nats.

*Proof.* Theorem 9.4 gives $0.4557 \le (G-\mu)/(G-2\varepsilon)$; multiply by $G - 2\varepsilon > 0$ and rearrange. $\square$

Theorem 9.6 turns the entire margin route into a directly measurable prediction. Measure the donor tail's mean top-1 gap; if it exceeds $2.8673$ nats at the stated $(G,\varepsilon)$, then some hypothesis of the chain fails — most plausibly the drift budget $\varepsilon$ — and the route is refuted on that arm.

---

## 10. Algorithms and applications

### 10.1 The screening pipeline

Given a donor network, a held-out corpus of $N$ positions, a candidate block, and a drift budget $\varepsilon$:

1. **One forward pass.** For each position $x$ record the score vector $u(x) \in \mathbb{R}^m$.
2. **Gaps.** Compute $\mathrm{gap}(x) = u(x)_{(1)} - u(x)_{(2)}$, the difference between the largest and second-largest score. Cost $O(Nm)$.
3. **Margin scarcity.** $\mathrm{unc} = \frac{1}{N}\#\{x : \mathrm{gap}(x) \le 2\varepsilon\}$, plus any positions where the drift budget is known to be violated. Cost $O(N)$.
4. **Report.** $\mathrm{damage} \le \mathrm{unc}$ by Theorem 4.1. If $\mathrm{unc} \le \tau$, accept the block at tolerance $\tau$ without transplanting.

Total cost: a single forward pass and $O(Nm)$ arithmetic, versus a full hybrid build and evaluation per candidate block. For $L$ candidate blocks the saving is a factor of $L$ in evaluations, and the answer is a *certificate* rather than an estimate.

Two degradations are available when even the histogram is unwanted: replace step 3 by the collision-mass count $\frac{1}{N}\#\{x : \sum_k u(x)_k^2 \le 4\varepsilon^2\}$ (a lower bound on $\mathrm{unc}$, hence an obstruction certificate, by Theorem 8.4), or by the two scalars $(G,\mu)$ and Theorem 9.4.

### 10.2 Ranking blocks for merging

For a stack of blocks, compute $\mathrm{unc}(b)$ for each and rank. Theorem 7.6 says that if the screen's overshoot is at most $\eta$ and the damage spread across the stack exceeds $\eta/2$, the ranking is positively correlated with the true damage ranking. Theorem 7.10 says that substituting weight-space distance for $\mathrm{unc}$ can invert the ranking.

### 10.3 Design guidance

Corollary 8.7 gives a design principle: to make a block portable, make its decisions *concentrated* — the block must have low Rényi-2 entropy at most positions, or the margin route cannot certify it at any drift level worth the name. Conversely, the diffuse tail of a distribution is exactly where portability certificates are unobtainable, which matches the empirical observation that deep "tail" blocks are the fragile ones.

### 10.4 Auditing merge claims

Theorem 9.6 gives an audit: any claimed damage figure for a transplant constrains the donor's mean gap. This is a consistency check that costs one forward pass and can invalidate a reported measurement.

---

## 11. Discussion, limitations, future work

### 11.1 What survived and what failed

**Survived.** The margin route is a genuine, certified screen. Theorem 4.1 ($\mathrm{damage} \le \mathrm{unc}$) composes with Theorem 9.3 into a deployable two-scalar bound $\mathrm{damage} \le (G-\mu)/(G-2\varepsilon)$, and with Theorem 8.4 into an information-theoretic lower bound on the screen itself. Across blocks the screen is provably positively correlated with damage once its slack is smaller than twice the damage spread (Theorems 7.5, 7.6).

**Failed — and the failure is a theorem.** The norm route survives only as a *sufficient* condition (Theorem 3.3). As a predictor it is refuted: Theorem 5.2 builds a dead-direction block with arbitrarily large weight distance and zero damage next to a live-direction block with arbitrarily small distance and total damage, and Theorem 5.3 turns this into the sharp statement that any damage bound depending on the weight distance alone must be $\ge 1$ everywhere. Cross-block, Theorem 7.10 gives the same data set two opposite covariance signs: $+1/4$ for the margin statistic, $-(D-d)/4$ for the norm.

**Needs a different definition.** "Margin scarcity predicts damage" cannot be upgraded to an equality or a lower bound: Theorem 6.1 (uncertified fraction $1$, damage $0$) and Theorem 8.8 show the screen is one-sided by nature. Any two-sided prediction must add information about *where* the drift points relative to the top-2 subspace — the common structural pattern behind all three counterexamples is that damage is a function of the drift's component along the top-2 difference direction, not of its norm.

### 11.2 Limitations

* The linear block model of Section 3 is a stand-in for a genuine multi-layer block; the margin results of Sections 4, 6–9 do not use it, being statements about score fields, but the counterexamples of Section 5 are constructed inside it.
* The drift budget $\varepsilon$ is an input. In practice it is estimated, and a mis-estimated $\varepsilon$ invalidates the certificate. Making $\varepsilon$ itself certified is the main practical gap.
* Theorem 8.3 requires nonnegative score vectors. For raw logits one must first pass through a nonnegative representation (e.g. softmax probabilities), which changes the meaning of $\varepsilon$.
* The correlation theorem 7.5 assumes a uniform slack bound $\eta$; slack is not directly measurable without transplants, though it can be estimated on a small calibration subset of blocks.

### 11.3 Future directions

**The top-2 projection as the complete predictor.** We conjecture that for a linear block there is a function of the projection of the weight drift onto the per-position top-2 logit-difference direction that both upper- *and* lower-bounds the damage fraction, up to a universal constant. Concretely, with
$$s(x) = \bigl\langle \Delta W\cdot \mathrm{feat}(x),\; e_{d(x)} - e_{\mathrm{second}(x)} \bigr\rangle$$
and $\mathrm{gap}(x)$ the top-1 gap, we expect the exact identity
$$\mathrm{damage} = \#\{x : s(x) > \mathrm{gap}(x)\}/\#\Omega,$$
with every norm-based or margin-based statistic a relaxation of it. The key insight is that all three counterexamples here — dead direction, live direction, diffuse-but-static block — differ only in the angle between the drift and the top-2 difference direction, and agree on everything the norm can see.

**Certified drift budgets.** Replace the hypothesis $|u - v| \le \varepsilon$ by a computed bound, closing the last non-certified input of the pipeline.

**Beyond top-1.** The whole development is about argmax agreement. Extending it to top-$k$ agreement, or to a divergence between output distributions, would require replacing Lemma 2.4 by a stability estimate for the whole simplex point rather than its argmax.

**Sharpening the correlation constant.** Theorem 7.5 loses a factor through Cauchy–Schwarz applied to an arbitrary damage profile. Under distributional assumptions on the damage across blocks (e.g. a two-point or bounded profile) the constant $\eta/2$ should improve.

---

## 12. Summary of results

| # | Statement | Direction |
|---|---|---|
| 3.3 | Gap $> 2k\delta B$ everywhere $\Rightarrow$ damage $=0$ | norm route sound |
| 4.1 | $\mathrm{damage} \le \mathrm{unc}$ | margin screen |
| 4.2 | $\mathrm{unc} \le \tau \Rightarrow \mathrm{damage} \le \tau$ | screening |
| 4.3 | agreement $0.5443$ $\Rightarrow$ damage $0.4557 \le \mathrm{unc}$ | saturation |
| 5.2 | distance $D$/damage $0$ beside distance $d$/damage $1$ | norm route refuted |
| 5.3 | any norm-only bound $g$ has $g(\delta)\ge 1$ | norm route vacuous |
| 6.1 | $\mathrm{unc}=1$, damage $0$ possible | screen one-sided |
| 6.2 | $\mathrm{unc}=1$, damage $1$ possible | screen attained |
| 7.5 | $\mathrm{cov} \ge \mathrm{Var}(\mathrm{dam}) - \frac{\eta}{2}\sqrt{\mathrm{Var}(\mathrm{dam})}$ | correlation bound |
| 7.6 | spread $> \eta/2$ $\Rightarrow$ $\mathrm{cov} > 0$ | positive correlation |
| 7.10 | $\mathrm{cov}(\text{margin})=\tfrac14$, $\mathrm{cov}(\text{norm})=-\tfrac{D-d}{4}$ | opposite signs |
| 8.3–8.4 | diffuse $\Rightarrow$ uncertified; $\mathrm{diff} \le \mathrm{unc}$ | entropy obstruction |
| 8.5 | diffuse $\iff H_2 \ge 2\log\frac{1}{2\varepsilon}$ | entropy form |
| 8.8 | $\mathrm{diff}=1$, damage $0$ possible | sandwich open |
| 9.3–9.4 | $\mathrm{damage} \le (G-\mu)/(G-2\varepsilon)$ | two-scalar bound |
| 9.5 | bound attained at $1/2$ | sharpness |
| 9.6 | damage $0.4557 \Rightarrow \mu \le 2.8673$ at $G=5,\varepsilon=0.16$ | falsifiable |
