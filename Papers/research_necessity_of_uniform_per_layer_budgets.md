# Necessity of Uniform Per-Layer Budgets: Soundness, Probe Sets, and Masking Suffixes for Stacked Channels

**Author:** Aristotle (Harmonic)
**Date:** 2026-10-22

---

## Abstract

A deep model can be viewed as a stack of stochastic layers, each a Markov channel on a finite state space. When layers are pruned, quantised, or otherwise perturbed, a natural way to control the total damage is a *per-layer budget*: charge each (intact, perturbed) layer pair a number, and hope that the total-variation distance between the outputs of the two stacks never exceeds the sum of the charges. We give an exact characterisation of when this works. A per-layer budget functional is *sound* (the sum of charges bounds the joint damage, for every pair of stacks of equal depth and every input law) **if and only if** it dominates, layer pair by layer pair, the worst-case perturbation over all upstream states. In particular, the worst-case ("uniform") budget is the least sound budget, and it is depth-additive: $n$ layers that are each $\varepsilon$-close in the worst case do at most $n\varepsilon$ damage.

We then ask what a budget can do if it is only allowed to look at a layer through its responses at a prescribed set $S$ of probe laws. We prove a sharp dichotomy: there exists a sound, calibrated (an unperturbed layer is charged $0$) budget depending only on the probe responses **if and only if** the probe vectors span $\mathbb{Q}^k$, where $k$ is the number of states (or $k=1$). Consequently at least $k$ probes are necessary, and $k$ probes (e.g. the point masses) suffice. When the probes do not span, a *witness interpolation* construction produces, at every depth, a pair of stacks whose total budget is $0$ while the joint damage from some input is $1$; no multiplicative or additive slack $(C,\delta)$ with $\delta<1$ can repair the budget. A *masking suffix* construction shows more: every pruning instance, however damaging, can be made completely invisible to one-layer-at-a-time ("solo") ablation at **every** input, at the cost of two extra layers. On the positive side we show that measurements taken along an input's own intact trajectory are sound for that input, and that they extrapolate to other inputs with amplification equal to the $\ell^1$ norm of the coefficients expressing those inputs in terms of the measured window. This yields an explicit sound *design budget* computed purely from probe measurements, and turns the choice of probes into a concrete optimisation problem.

---

## 1. Introduction

Modern serving pipelines routinely replace a trained model by a cheaper one: weights are pruned, activations are quantised, attention heads are dropped, layers are distilled. Each of these interventions acts locally, on one layer at a time, and it is tempting to control the global effect by local measurements. A per-layer "budget" — say, the measured change of a layer's output on a held-out batch — is summed over depth and reported as a bound on the end-to-end change.

There is a classical argument behind this practice, the *hybrid argument*: replace the intact layers by the perturbed ones one at a time, and bound the end-to-end distance by a telescoping sum of single-layer distances. The hybrid argument is correct, but it comes with a fine print that is easy to miss: the $j$-th term is a perturbation measured at the upstream law produced by a *mixed* stack, a law that is in general not the law on which anybody measured anything. The argument therefore needs a per-layer bound that holds *uniformly over upstream states*.

Is this fine print essential, or is it an artefact of the proof? This paper answers the question completely, in three layers of increasing strength.

1. **Soundness is uniform domination** (Section 3). A per-layer budget functional is sound if and only if it dominates the worst-case perturbation of each layer pair over all upstream states. The proof of necessity is a one-line test: a depth-one stack fed a point-mass input.

2. **Probe-local budgets: a spanning dichotomy** (Sections 4–5). Suppose a budget is allowed to see a layer only through its responses at finitely many (or arbitrarily many) prescribed probe laws — a held-out batch, a calibration set. Then a sound budget of this kind that charges nothing to an unchanged layer exists if and only if the probes span the whole space of signed measures. Below that threshold, every such budget is defeated at every depth by a stack pair with zero total budget and maximal damage.

3. **Solo probing is never enough** (Section 6). Even with arbitrarily many probe inputs, a certificate built from one-layer-at-a-time output-level ablations can be fooled: every pruning instance can be wrapped in two extra layers so that every solo ablation is invisible at every input, while the joint damage is unchanged.

The positive results of Section 7 explain exactly what *can* be done with finite measurements: measurements along the intact trajectory of an input are sound for that input, and they extrapolate through linear combinations with an explicit $\ell^1$ amplification factor. The design question "which probes?" thus becomes a quantitative problem about inscribing the probe set in the probability simplex.

The practical upshot is blunt. *Serving policies must certify worst-case per-layer behaviour; held-out-window measurements can be turned into a sound budget only through a spanning design, and then only with the amplification that design carries.*

---

## 2. Setting and preliminaries

### 2.1 Laws, channels, stacks

Fix a finite set $A$ of states with $k = |A| \ge 1$ elements. A **law** on $A$ is a vector $\mu \in \mathbb{Q}^A$ with $\mu_a \ge 0$ and $\sum_a \mu_a = 1$; we write $\Delta(A)$ for the set of laws. (All probabilities and budgets in this paper are rational numbers, as befits measured quantities; every argument is linear-algebraic.) The **point mass** at $a$ is $\delta_a$.

A **channel** (or *layer*) is a map $K : A \to \Delta(A)$, equivalently a row-stochastic $A\times A$ matrix whose $a$-th row is the law $K(a)$. A channel acts on laws by
$$ (\mu K)_b \;=\; \sum_{a\in A} \mu_a\, K(a)_b , $$
and we call $\mu K$ the **push** of $\mu$ through $K$. The same formula defines a linear map $v \mapsto vK$ on all of $\mathbb{Q}^A$. Two special channels will be used repeatedly: the **identity** $\mathrm{id}(a) = \delta_a$, and, for a law $d$, the **forgetful** (constant) channel $\kappa_d(a) = d$ for all $a$, which satisfies $\mu\kappa_d = d$ for every law $\mu$.

A **stack** of depth $n$ is a finite list $F = (f_1,\dots,f_n)$ of channels; it acts on a law by running the layers in order,
$$ F(\mu) \;=\; \mu f_1 f_2 \cdots f_n . $$
The **total variation distance** between laws is $\operatorname{tv}(\mu,\nu) = \tfrac12 \sum_b |\mu_b - \nu_b|$, which lies in $[0,1]$, vanishes exactly when $\mu=\nu$, and equals $1$ for distinct point masses.

An *intact* stack $F=(f_1,\dots,f_n)$ and a *perturbed* (pruned) stack $P = (p_1,\dots,p_n)$ of the same depth are compared through their **joint damage** $\operatorname{tv}(F(\mu), P(\mu))$ from an input law $\mu$.

### 2.2 Four elementary facts

**Lemma 2.1 (Dirac evaluation and linearity).** For every channel $K$ and state $a$, $\delta_a K = K(a)$. For every stack $L$ there is a single channel $\widehat L$, namely $\widehat L(a) = L(\delta_a)$, such that $L(\mu) = \mu\widehat L$ for every law $\mu$. Moreover $\mu K G = \mu (K\!\cdot\! G)$, where $(K\cdot G)(a) = K(a)G$ is the composite channel.

*Proof sketch.* The first identity is the definition of push at a point mass. Composition is associativity of matrix multiplication (an exchange of two finite sums). The stack identity follows by induction on depth: $\widehat{(K :: L)} = K\cdot \widehat L$. $\square$

**Lemma 2.2 (Uniform perturbations are convex-stable).** If $\operatorname{tv}(f(a), p(a)) \le \varepsilon$ for every state $a$, then $\operatorname{tv}(\mu f, \mu p) \le \varepsilon$ for every law $\mu$.

*Proof sketch.* $\mu f - \mu p = \sum_a \mu_a (f(a) - p(a))$; apply the triangle inequality for the $\ell^1$ norm and $\sum_a \mu_a = 1$. $\square$

**Lemma 2.3 (Data processing).** For every stack $L$ and laws $\mu,\nu$, $\operatorname{tv}(L(\mu), L(\nu)) \le \operatorname{tv}(\mu,\nu)$.

*Proof sketch.* A single channel is an $\ell^1$-contraction on vectors of total mass $0$, since each row is a law; iterate. $\square$

**Lemma 2.4 (Hybrid bound).** Define the **hybrid cost** of a pair of stacks recursively along the *perturbed* trajectory:
$$ H\big((f::F),(p::P),\mu\big) = \operatorname{tv}(\mu f, \mu p) + H(F, P, \mu p), \qquad H(\cdot,\cdot,\cdot)=0 \text{ otherwise.} $$
Then for stacks of equal depth, $\operatorname{tv}(F(\mu), P(\mu)) \le H(F,P,\mu)$.

*Proof sketch.* Induction on depth. With $F = f::F'$, $P = p::P'$,
$$\operatorname{tv}(F'(\mu f), P'(\mu p)) \le \operatorname{tv}(F'(\mu f), F'(\mu p)) + \operatorname{tv}(F'(\mu p), P'(\mu p)),$$
bound the first term by Lemma 2.3 and the second by the induction hypothesis at the input $\mu p$. $\square$

The point of Lemma 2.4 is visible in its recursion: the $j$-th layer pair is examined at the law $\mu p_1\cdots p_{j-1}$, an upstream state produced by the *perturbed* prefix. Nobody running the intact model ever sees this law.

---

## 3. Soundness is exactly uniform domination

### 3.1 Budget functionals

**Definition 3.1.** A **per-layer budget functional** is an arbitrary map $B$ assigning a rational number $B(f,p)$ to each pair (intact layer $f$, perturbed layer $p$). For stacks $F=(f_1,\dots,f_n)$ and $P=(p_1,\dots,p_n)$ the **total budget** is
$$ \Sigma_B(F,P) = \sum_{j=1}^n B(f_j, p_j). $$
$B$ is **sound** if for every pair of stacks of equal depth and every input law $\mu$,
$$ \operatorname{tv}(F(\mu), P(\mu)) \;\le\; \Sigma_B(F,P). $$

No regularity is imposed on $B$: it may be computed from any feature of the layers whatsoever.

### 3.2 The characterisation

**Theorem 3.2 (Sufficiency: heterogeneous depth-additivity).** If $B(f,p) \ge \operatorname{tv}(f(a),p(a))$ for every pair of layers $f,p$ and every state $a$, then $B$ is sound.

*Proof sketch.* By Lemma 2.4 the joint damage is at most the hybrid cost. Each term of the hybrid cost is $\operatorname{tv}(\nu f_j, \nu p_j)$ for some upstream law $\nu$, and by Lemma 2.2 (with $\varepsilon = B(f_j,p_j)$) this is at most $B(f_j,p_j)$. Summing gives $H(F,P,\mu) \le \Sigma_B(F,P)$. $\square$

**Theorem 3.3 (Necessity).** If $B$ is sound, then $B(f,p) \ge \operatorname{tv}(f(a), p(a))$ for every pair of layers and every state $a$.

*Proof sketch.* Apply soundness to the depth-one stacks $(f)$ and $(p)$ with input $\delta_a$. By Lemma 2.1 the joint damage is $\operatorname{tv}(f(a),p(a))$, and the total budget is $B(f,p)$. $\square$

**Corollary 3.4 (Soundness $\Leftrightarrow$ uniform domination).** A per-layer budget functional is sound if and only if it dominates the pointwise channel distance at every state:
$$ B \text{ sound} \iff \forall f,p,\ \forall a \in A:\ \operatorname{tv}(f(a),p(a)) \le B(f,p). $$

### 3.3 The least sound budget

**Definition 3.5.** The **uniform budget** is the worst case over upstream states,
$$ U(f,p) \;=\; \max_{a \in A} \operatorname{tv}(f(a), p(a)). $$

Because $A$ is finite and nonempty the maximum is attained at some state.

**Theorem 3.6 (Uniform budgets are forced).** $U$ is sound, and a budget functional $B$ is sound if and only if $U(f,p) \le B(f,p)$ for every layer pair. In other words, the uniform budget is the least sound budget.

*Proof sketch.* $U$ dominates the pointwise distance by definition, so Theorem 3.2 applies. Conversely, if $B$ is sound, pick a maximising state $a^\ast$ for $U(f,p)$ and apply Theorem 3.3 at $a^\ast$. If $B \ge U$, then $B$ dominates every pointwise distance. $\square$

**Corollary 3.7 (Depth-additivity in closed form).** If every layer pair of two stacks of depth $n$ satisfies $U(f_j,p_j) \le \varepsilon$, then $\Sigma_U(F,P) \le n\varepsilon$, and hence $\operatorname{tv}(F(\mu),P(\mu)) \le n\varepsilon$ for every input law $\mu$.

**Remark 3.8 (Why "uniform" is not a policy choice).** Corollary 3.4 says that "certify worst-case per-layer behaviour" is not one sensible policy among many; it is *literally the definition* of a sound budget. Any number charged to a layer pair that is smaller than its worst-case perturbation at some state is refuted by a one-layer stack.

**Remark 3.9 (Calibration matters).** Since $\operatorname{tv} \le 1$, the constant functional $B \equiv 1$ is sound by Theorem 3.2, and it depends on no information about the layers at all. The interesting question is therefore about budgets that are *calibrated*: they charge nothing to a layer that was not changed. This is the setting of Section 5.

---

## 4. The linear algebra of probing

A budget that "depends only on the behaviour of a layer at prescribed upstream states" sees a channel $K$ only through its probe responses $sK$, $s \in S$. Because push is linear in the input law, what a probe set can see is governed by the linear span of the probe vectors.

**Definition 4.1.** Let $S \subseteq \Delta(A)$ be a set of probe laws (finite or not).
* $S$ **spans** if the vectors $\{s : s\in S\}$ span $\mathbb{Q}^A$.
* Channels $f$ and $p$ **agree on** $S$ if $sf = sp$ for every $s \in S$.
* $S$ **separates** channels if agreement on $S$ forces $f = p$.

**Lemma 4.2 (Spanning probes see everything).** If $S$ spans, then $S$ separates channels.

*Proof sketch.* The linear map $v \mapsto v f - v p$ vanishes on each probe, hence on their span, which is all of $\mathbb{Q}^A$. Evaluating at $\delta_a$ gives $f(a) = p(a)$ (Lemma 2.1). $\square$

The converse is the heart of the matter, and it is constructive.

**Theorem 4.3 (Witness interpolation).** Suppose $S$ does not span and $A$ contains two distinct states $x \ne y$. Then there are channels $g, q$ that agree on every probe in $S$, and a state $a_0$ with $\operatorname{tv}(g(a_0), q(a_0)) = 1$.

*Proof sketch.* Since the span of $S$ is a proper subspace, there is a nonzero linear functional vanishing on it; write it as $v \mapsto \sum_a v_a w_a$ with $w \ne 0$, so $\sum_a s_a w_a = 0$ for each probe $s$. Choose $a_0$ maximising $|w_a|$ and normalise, $u = w/|w_{a_0}|$, so that $|u_a| \le 1$ for all $a$ and $|u_{a_0}| = 1$. Define the state-dependent mixtures
$$ g(a) = \tfrac{1+u_a}{2}\,\delta_x + \tfrac{1-u_a}{2}\,\delta_y, \qquad q(a) = \tfrac{1-u_a}{2}\,\delta_x + \tfrac{1+u_a}{2}\,\delta_y . $$
These are laws because $-1 \le u_a \le 1$. For a probe $s$, the response $sg$ is the mixture of $\delta_x,\delta_y$ with weight $\sum_a s_a \tfrac{1+u_a}{2} = \tfrac12 (1 + \sum_a s_a u_a) = \tfrac12$, and likewise $sq$ has weight $\tfrac12$; hence $sg = sq = \tfrac12\delta_x + \tfrac12\delta_y$. At $a_0$, two mixtures of the same pair of distinct point masses with weights $\theta,\theta'$ are at distance $|\theta-\theta'|$, which here is $|u_{a_0}| = 1$. $\square$

**Theorem 4.4 (Separation dichotomy).** A probe set $S$ separates channels if and only if $k = 1$ or $S$ spans.

*Proof sketch.* On a one-point space there is only one law, so all channels coincide. If $S$ spans, use Lemma 4.2. If $k \ge 2$ and $S$ does not span, Theorem 4.3 produces agreeing channels with $\operatorname{tv}(g(a_0),q(a_0))=1 \neq 0$, so $g \ne q$. $\square$

**Proposition 4.5 (How many probes: exactly $k$).** The $k$ point masses $\{\delta_a\}$ span. Conversely, any spanning family $s_1,\dots,s_m$ of probe laws has $m \ge k$.

*Proof sketch.* Every $v \in \mathbb{Q}^A$ equals $\sum_a v_a \delta_a$. Conversely, the span of $m$ vectors has dimension at most $m$, while $\dim \mathbb{Q}^A = k$. $\square$

---

## 5. The probe-budget dichotomy

### 5.1 Probe-local budgets

**Definition 5.1.** Let $S$ be a probe set and $B$ a budget functional.
* $B$ is **$S$-local** if $B(f,p) = B(f',p')$ whenever $f,f'$ agree on $S$ and $p,p'$ agree on $S$: the budget depends on the layer pair only through the probe responses.
* $B$ is **calibrated** if $B(f,f) = 0$ for every channel $f$.
* $B$ is **$S$-blind** if $B(f,p) = 0$ whenever $f$ and $p$ agree on $S$.

**Lemma 5.2.** An $S$-local calibrated budget is $S$-blind.

*Proof sketch.* If $f, p$ agree on $S$, then by locality $B(f,p) = B(f,f)$ (compare the pair $(f,p)$ with $(f,f)$), and calibration gives $0$. $\square$

### 5.2 The counterexample at every depth

**Theorem 5.3 (Every blind budget is defeated, at every depth).** Suppose $S$ does not span and $k\ge 2$. Let $B$ be any $S$-blind budget functional. Then for every depth $n+1 \ge 1$ there are stacks $F, P$ of depth $n+1$ with
$$ \Sigma_B(F,P) = 0 \qquad\text{and}\qquad \operatorname{tv}(F(\mu), P(\mu)) = 1 \ \text{ for some input law } \mu. $$

*Proof sketch.* Take the blind pair $(g,q)$ and the state $a_0$ of Theorem 4.3, and set $F = (g, \mathrm{id}, \dots, \mathrm{id})$, $P = (q, \mathrm{id},\dots,\mathrm{id})$ with $n$ identity layers. The pair $(g,q)$ agrees on $S$ and each pair $(\mathrm{id},\mathrm{id})$ trivially does, so every term of the total budget vanishes by blindness. With input $\mu = \delta_{a_0}$, the outputs are $g(a_0)$ and $q(a_0)$, at distance $1$. $\square$

**Corollary 5.4 (No slack repairs a blind budget).** Under the hypotheses of Theorem 5.3, there are no constants $C \in \mathbb{Q}$ and $\delta < 1$ such that
$$ \operatorname{tv}(F(\mu),P(\mu)) \;\le\; C\cdot \Sigma_B(F,P) + \delta $$
for all stacks of equal depth and all input laws.

*Proof sketch.* On the depth-one instance of Theorem 5.3 the right-hand side equals $\delta < 1$ while the left-hand side equals $1$. $\square$

### 5.3 The dichotomy

For the positive direction it is convenient to use a budget that requires no choice of maximiser.

**Definition 5.5.** The **Dirac-sum budget** is $D(f,p) = \sum_{a\in A} \operatorname{tv}(f(a), p(a))$.

$D \ge U$ termwise, so $D$ is sound by Theorem 3.6, and clearly $D(f,f)=0$.

**Theorem 5.6 (Probe-budget dichotomy).** For every probe set $S$ (finite or infinite), the following are equivalent:
1. there is a per-layer budget functional that is $S$-local, calibrated and sound;
2. $k = 1$, or the probe vectors of $S$ span $\mathbb{Q}^A$.

*Proof sketch.* (1 ⇒ 2) If $k \ge 2$ and $S$ does not span, the budget is $S$-blind by Lemma 5.2, and Theorem 5.3 (depth one) produces a stack pair with total budget $0$ and damage $1$, contradicting soundness. (2 ⇒ 1) If $k=1$ or $S$ spans, $S$ separates channels (Theorem 4.4). Then agreement on $S$ means equality, so *every* functional is $S$-local; in particular the Dirac-sum budget is $S$-local, calibrated and sound. $\square$

**Corollary 5.7 (A finite probe set suffices; and no fewer than $k$ probes do).** The $k$ point masses support a sound, calibrated, probe-local budget. If $k\ge 2$ and a family of $m$ probe laws supports such a budget, then $m \ge k$.

*Proof sketch.* Combine Theorem 5.6 with Proposition 4.5. $\square$

**Remark 5.8 (Relation to the original conjecture).** The motivating conjecture asserted that *every* budget depending only on a layer's behaviour at finitely many prescribed upstream states is defeated by some stack. Theorem 5.6 refines this into a dichotomy and shows exactly where it holds: for calibrated budgets, it holds precisely when the probes fail to span (in particular, whenever there are fewer than $k$ probes, as for a single held-out state), and it fails for spanning probe sets. Calibration cannot be dropped (Remark 3.9).

### 5.4 Held-out windows

The same linear algebra governs the most common empirical practice: checking that a perturbed model agrees with the intact one on a held-out window of inputs.

**Theorem 5.9 (Window dichotomy).** Let $W$ be a set of input laws. The statement

> for all stacks $F,P$: if $F(w) = P(w)$ for every $w \in W$, then $F(\mu) = P(\mu)$ for every law $\mu$

holds if and only if $k=1$ or $W$ spans.

*Proof sketch.* If $W$ separates channels, two stacks agreeing on $W$ have composite channels $\widehat F, \widehat P$ (Lemma 2.1) agreeing on $W$, hence equal, hence $F(\mu) = \mu\widehat F = \mu \widehat P = P(\mu)$. Conversely, applying the statement to depth-one stacks with inputs $\delta_a$ shows that $W$ separates channels; conclude with Theorem 4.4. $\square$

**Theorem 5.10 (Small windows never certify).** Suppose $k \ge 2$ and $w_1,\dots,w_m$ is a window with $m < k$ inputs. Then for every depth $n+1$ there are stacks $F,P$ of depth $n+1$ such that $F(w_i) = P(w_i)$ exactly for every $i$, while $\operatorname{tv}(F(\mu),P(\mu)) = 1$ for some input law $\mu$.

*Proof sketch.* By Proposition 4.5 the window does not span. Take the blind pair of Theorem 4.3, padded by identity layers as in Theorem 5.3. $\square$

---

## 6. Masking suffixes: every pruning hides from solo probing

Sections 4 and 5 are about budgets that look at a layer in isolation. A more sophisticated practitioner ablates layers *in context*: replace one layer of the intact model by its perturbed version, run the whole model, and measure the change in output. We show that even this, at arbitrarily many probe inputs, can be completely blind.

**Definition 6.1 (Solo profile).** For stacks $F,P$ of equal depth $n$, an input law $\mu$ and an index $j$, let $F^{(j)}$ be the stack obtained from $F$ by replacing its $j$-th layer by the $j$-th layer of $P$ (and $F^{(j)} = F$ if $j$ is out of range). The **solo cost** is
$$ \operatorname{solo}_j(F,P;\mu) \;=\; \operatorname{tv}\big(F(\mu),\,F^{(j)}(\mu)\big). $$

**Construction 6.2 (Collapsing prefix and masking suffix).** Given stacks $F,P$ of equal depth and a probe law $d$, define
$$ \widetilde F = \big(\kappa_d,\ F,\ \kappa_{F(d)}\big), \qquad \widetilde P = \big(\kappa_d,\ P,\ \mathrm{id}\big). $$
Both stacks begin with the same *collapsing prefix* $\kappa_d$, which sends every upstream state to $d$. The intact stack ends with the forgetful layer $\kappa_{F(d)}$, which outputs the intact answer regardless of its input; the perturbed stack ends with the transparent layer $\mathrm{id}$.

**Theorem 6.3 (Masking-suffix theorem).** For every pair of stacks $F, P$ of equal depth and every law $d$:
1. $\widetilde F$ and $\widetilde P$ have equal depth (two more layers than $F$);
2. for **every** input law $\mu$, $\operatorname{tv}(\widetilde F(\mu), \widetilde P(\mu)) = \operatorname{tv}(F(d), P(d))$;
3. for **every** input law $\mu$ and every index $j$, $\operatorname{solo}_j(\widetilde F, \widetilde P;\mu) = 0$.

*Proof sketch.* Since $\mu\kappa_d = d$, the intact wrapped stack outputs $F(d)$ from every input (the suffix overwrites whatever arrives with $F(d)$), and the perturbed wrapped stack outputs $P(d)\,\mathrm{id} = P(d)$; this gives (2). For (3), consider the layer being ablated. If it is the prefix, the two stacks share it and nothing changes. If it is an inner layer, the forgetful suffix of $\widetilde F$ masks it and the output is still $F(d)$. If it is the suffix, replacing $\kappa_{F(d)}$ by $\mathrm{id}$ yields $d$ pushed through $F$, which is again $F(d)$. In every case the ablated output equals $\widetilde F(\mu)$. $\square$

**Theorem 6.4 (Generalised witness family).** For any two laws $d, c$ and any depth $n+3$, there are stacks $F,P$ of depth $n+3$ whose solo profile vanishes at every input and every layer while the joint damage equals $\operatorname{tv}(d,c)$ at every input.

*Proof sketch.* Apply Theorem 6.3 to $n+1$ identity layers versus $n+1$ copies of $\kappa_c$, with probe $d$: the intact output at $d$ is $d$, the perturbed one is $c$. $\square$

**Example 6.5.** On two states with $d = \delta_0$ and $c = (1-t)\delta_0 + t\delta_1$, $t = 17/1000$, Theorem 6.4 gives a stack pair of every depth $\ge 3$ that does damage exactly $17/1000$ from *every* input, while every single-layer ablation is invisible from every input. (An earlier witness family achieved this only at the single input $\delta_0$.)

**Theorem 6.6 (Solo certificates are unsound at any set of probe inputs).** Let $(s_i)_{i\in I}$ be any family of probe inputs, finite or infinite. Let $\Phi$ be any rule turning the solo profile $\big(\operatorname{solo}_j(F,P;s_i)\big)_{i\in I,\,j\in\mathbb{N}}$ into a number, subject only to $\Phi(0) = 0$ on the identically zero profile. If $k\ge 2$, there are stacks $F,P$ of equal depth with $\Phi(\text{profile}) = 0$ and joint damage $1$ at every input.

*Proof sketch.* Take two distinct states $x\ne y$ and apply Theorem 6.4 with $d=\delta_x$, $c=\delta_y$. The solo profile is identically zero, so $\Phi$ returns $0$; the joint damage is $\operatorname{tv}(\delta_x,\delta_y)=1$. $\square$

**Remark 6.7.** Theorem 6.6 is not in tension with Theorem 5.6. The design budgets of Section 7 do not use output-level solo ablations: they measure each layer *at its own input*, which in the masked stacks would reveal the full damage at the suffix. The lesson is that interventional measurements are informative only when they isolate each layer's local behaviour; measurements filtered through the rest of the network can be masked by downstream layers.

---

## 7. What finite measurements can do: trajectories and designs

### 7.1 Trajectory costs

**Definition 7.1.** The **trajectory cost** of stacks $F,P$ of equal depth at input $\mu$ charges each layer the perturbation of its own output at the *intact* upstream state:
$$ T\big((f::F),(p::P),\mu\big) = \operatorname{tv}(\mu f, \mu p) + T(F, P, \mu f), \qquad T(\cdot,\cdot,\cdot) = 0 \text{ otherwise.} $$

Unlike the hybrid cost, $T$ can be measured by someone who only runs the intact model and, at each layer, also applies the perturbed layer to the intact activations.

**Theorem 7.2 (Trajectory bound).** For stacks of equal depth and every input law $\mu$,
$$ \operatorname{tv}(F(\mu), P(\mu)) \le T(F,P,\mu). $$

*Proof sketch.* Induction on depth, splitting the other way round from Lemma 2.4:
$$\operatorname{tv}(F'(\mu f), P'(\mu p)) \le \operatorname{tv}(F'(\mu f), P'(\mu f)) + \operatorname{tv}(P'(\mu f), P'(\mu p)),$$
bound the first term by induction at input $\mu f$ and the second by data processing (Lemma 2.3). $\square$

So a per-layer measurement taken on an input's own intact trajectory *is* sound for that input. What fails (Theorems 5.3 and 5.10) is reusing it for other inputs. In particular, zero trajectory cost at $\mu$ forces $F(\mu) = P(\mu)$.

**Corollary 7.3 (Trajectory-window dichotomy).** For a window $W$ of inputs, the statement "zero trajectory cost at every $w\in W$ implies $F(\mu) = P(\mu)$ for every law $\mu$" holds for all stacks of equal depth if and only if $k=1$ or $W$ spans.

*Proof sketch.* Zero trajectory cost at $w$ gives $F(w)=P(w)$ (Theorem 7.2), so the window dichotomy (Theorem 5.9) yields sufficiency. For necessity, a depth-one pair agreeing on $W$ has zero trajectory cost on $W$; apply the statement at point masses to obtain separation and use Theorem 4.4. $\square$

### 7.2 Signed combinations of probes

**Lemma 7.4 (Combination inequality).** Let $s_1,\dots,s_m$ be probe laws, $c \in \mathbb{Q}^m$, and $v$ a law with $v = \sum_i c_i s_i$ as vectors. Then for every layer pair,
$$ \operatorname{tv}(v f, v p) \;\le\; \sum_{i=1}^m |c_i|\, \operatorname{tv}(s_i f, s_i p). $$

*Proof sketch.* By linearity, $vf - vp = \sum_i c_i (s_i f - s_i p)$ coordinatewise; take absolute values, apply the triangle inequality, sum over coordinates, and halve. $\square$

### 7.3 Design budgets

**Definition 7.5.** A **probe design** is a family of probe laws $s_1,\dots,s_m$ together with coefficients $c_{a,i}$ ($a\in A$, $1\le i \le m$) such that every point mass is a signed combination of the probes:
$$ \delta_a = \sum_{i=1}^m c_{a,i}\, s_i \qquad (a \in A). $$
Such coefficients exist exactly when the probes span. The **design budget** is
$$ B_{s,c}(f,p) \;=\; \sum_{a\in A}\sum_{i=1}^m |c_{a,i}|\;\operatorname{tv}(s_i f, s_i p). $$

**Theorem 7.6 (Constructive sufficiency).** Every design budget is probe-local (it depends only on the responses at $s_1,\dots,s_m$), calibrated, and sound.

*Proof sketch.* Locality and calibration are immediate from the formula. For soundness, by Corollary 3.4 it suffices to show $\operatorname{tv}(f(a), p(a)) \le B_{s,c}(f,p)$ for each $a$. By Lemma 2.1, $f(a) = \delta_a f$ and $p(a)=\delta_a p$; Lemma 7.4 bounds this by the $a$-th inner sum, which is at most the full (non-negative) double sum. $\square$

**Proposition 7.7 (The canonical design).** With the point-mass probes $s_a = \delta_a$ and identity coefficients $c_{a,i} = [a = i]$, the design budget equals the Dirac-sum budget $D$.

The quantity $\max_a \sum_i |c_{a,i}|$ is the **amplification** of the design: it measures how much probe-level uncertainty is magnified when certifying the worst state. Point-mass probes have amplification $1$; interior probes, the only kind available in deployment, pay more (Example 7.9).

### 7.4 Extrapolating from a window

**Theorem 7.8 (Window extrapolation).** Let $w_1,\dots,w_m$ be window inputs and $\mu$ an input law with $\mu = \sum_i c_i w_i$ as vectors. Then for all stacks $F,P$ of equal depth,
$$ \operatorname{tv}(F(\mu), P(\mu)) \;\le\; \sum_{i=1}^m |c_i|\; T(F,P,w_i). $$

*Proof sketch.* By Lemma 2.1, $F(\mu) = \mu\widehat F$ and $P(\mu) = \mu\widehat P$. Lemma 7.4 applied to the composite channels gives $\operatorname{tv}(F(\mu),P(\mu)) \le \sum_i |c_i| \operatorname{tv}(F(w_i),P(w_i))$, and Theorem 7.2 bounds each term by $T(F,P,w_i)$. $\square$

The $\ell^1$ size of the coefficients is therefore the exact price of extrapolation.

**Example 7.9 (Two states).** Write $\beta_t = (1-t)\delta_0 + t\delta_1$.
* The single balanced probe $\beta_{1/2}$ does not span. Indeed, the identity and the full flip $\phi(0) = \delta_1$, $\phi(1) = \delta_0$ have identical responses $\beta_{1/2}\mathrm{id} = \beta_{1/2}\phi = \beta_{1/2}$, yet $\operatorname{tv}(\mathrm{id}(0), \phi(0)) = 1$.
* The pair $\{\beta_{1/4}, \beta_{3/4}\}$ spans:
$$ \delta_0 = \tfrac32\,\beta_{1/4} - \tfrac12\,\beta_{3/4}, \qquad \delta_1 = -\tfrac12\,\beta_{1/4} + \tfrac32\,\beta_{3/4}, $$
with amplification $2$. By Theorem 7.8, for every pair of two-state stacks,
$$ \operatorname{tv}(F(\delta_0),P(\delta_0)) \le \tfrac32\,T(F,P,\beta_{1/4}) + \tfrac12\,T(F,P,\beta_{3/4}). $$
* More generally the symmetric design $\{\beta_\eta, \beta_{1-\eta}\}$, $0 \le \eta < 1/2$, has amplification $1/(1-2\eta)$, which blows up as the probes approach the centre of the simplex.

---

## 8. Algorithms

The results above are constructive. We record the three procedures they yield; each runs in exact rational arithmetic.

**Algorithm 1 (Witness interpolation / blind-pair construction).** *Input:* probe laws $s_1,\dots,s_m$ on $k \ge 2$ states; distinct states $x,y$. *Output:* either "spans", or channels $g,q$ agreeing on all probes with $\operatorname{tv}(g(a_0),q(a_0))=1$.
1. Row-reduce the $m\times k$ matrix with rows $s_i$. If its rank is $k$, return "spans".
2. Otherwise read off a nonzero null vector $w$ (with $\sum_a s_{i,a} w_a = 0$ for all $i$) from a free column.
3. Let $a_0 = \arg\max_a |w_a|$ and $u = w / |w_{a_0}|$.
4. Return $g(a) = \frac{1+u_a}2\delta_x + \frac{1-u_a}2\delta_y$, $q(a) = \frac{1-u_a}2\delta_x + \frac{1+u_a}2\delta_y$, and $a_0$.

*Cost:* $O(mk\min(m,k))$ field operations for the elimination plus $O(k^2)$ to write the channels. Padding by identity layers (Theorem 5.3) produces the counterexample at any depth.

**Algorithm 2 (Design budget).** *Input:* $k$ linearly independent probe laws $s_1,\dots,s_k$; a layer pair $(f,p)$. *Output:* a sound upper bound on the worst-case perturbation.
1. Form the matrix $S$ with rows $s_i$ and compute $C = S^{-1}$; row $a$ of $C$ gives the coefficients $c_{a,\cdot}$ with $\delta_a = \sum_i c_{a,i}s_i$.
2. Measure the probe responses $r_i = \operatorname{tv}(s_i f, s_i p)$.
3. Return $\sum_a\sum_i |c_{a,i}| r_i$.

*Cost:* $O(k^3)$ once per design, and $O(k^2)$ per layer pair given the responses. (More than $k$ spanning probes can be used with any coefficient choice; smaller $\ell^1$ norms give tighter budgets.)

**Algorithm 3 (Masking suffix).** *Input:* stacks $F,P$ of equal depth and a probe law $d$. *Output:* stacks $\widetilde F,\widetilde P$ with unchanged joint damage $\operatorname{tv}(F(d),P(d))$ at every input and identically zero solo profile.
1. Compute $F(d)$ by running $F$ on $d$.
2. Return $\widetilde F = (\kappa_d, F, \kappa_{F(d)})$ and $\widetilde P = (\kappa_d, P, \mathrm{id})$.

*Cost:* one forward pass of $F$.

---

## 9. Applications and discussion

**Serving and compression policies.** Corollary 3.4 and Theorem 3.6 convert an informal best practice into a theorem: a compression pipeline that reports the sum of per-layer budgets as an end-to-end guarantee is sound exactly when each budget dominates the worst-case perturbation of its layer over all upstream states. Budgets measured on a held-out batch are, in general, *not* such bounds, and Theorems 5.3 and 5.10 show the failure is total: zero reported budget, maximal damage, at any depth.

**Calibration data.** If the per-layer budget is to be computed from the layer's responses to a fixed calibration set, Theorem 5.6 says the calibration set must span the state space, and Corollary 5.7 says it must contain at least as many laws as there are states. In high-dimensional settings this is a strong requirement, and it explains why calibration-based certificates should be regarded as estimates rather than bounds unless the calibration set is rich enough.

**Ablation studies.** Theorem 6.6 is a caution for interpretability practice: a layer whose solo ablation changes nothing at any input may still be essential in combination with others. The masking-suffix construction is deliberately simple: a collapsing prefix and a forgetful suffix. Its simplicity shows that no amount of solo data, at any number of inputs, can replace joint or local measurements.

**What does work.** Theorem 7.2 legitimises per-input local measurements along the intact trajectory, and Theorems 7.6 and 7.8 turn a spanning set of such measurements into a sound global budget with an explicit amplification constant. The choice of probes is therefore not a matter of taste: it is governed by the $\ell^1$ geometry of expressing the vertices of the simplex in terms of the probes.

**Scope.** All results concern channels on a finite state space and the total-variation distance. Real activations live in continuous spaces; the finite setting isolates the combinatorial and linear-algebraic phenomena, and Section 10 records the conjectured continuous analogue.

---

## 10. Future work

We list the conjectures suggested by the results above. They are open.

**Conjecture 10.1 (Optimal amplification of interior designs).** Let $k = |A|$ and suppose every probe is $\eta$-interior, meaning that every state has probability at least $\eta$, where $0 \le \eta < 1/k$. Then the minimum, over spanning probe families and coefficient choices, of $\max_a \sum_i |c_{a,i}|$ equals
$$ \frac{1 + (k-2)\eta}{1 - k\eta}, $$
attained by the shrunk vertices $(1-k\eta)\delta_a + \eta\mathbf{1}$. For $k=2$ this is $1/(1-2\eta)$, matching Example 7.9. The key insight is that the amplification is the $\ell^1$ norm of the coefficients expressing the vertices of the simplex in terms of the probes, so optimal design is a polytope-inscription problem in the simplex. Deployment probes are always interior — real inputs are never point masses — so this constant is the one quantity left to optimise.

**Conjecture 10.2 (Epistatic factor law along the pruned trajectory).** For stacks of depth $n$, the hybrid cost satisfies $H(F,P,\mu) \le \sum_{j} (2(n-1-j)+1)\, \pi_j$, where $\pi_j$ is the perturbation of layer $j$ measured on the intact trajectory and $j$ ranges over $0,\dots,n-1$; the odd factors are conjectured to be tight. Depth $2$ gives the factor $3$. The intuition is that each upstream perturbation is paid once directly, and then twice more through the context shift at every downstream layer, telescoping into odd weights. Theorem 7.2 shows that intact-trajectory costs bound the joint damage with factor $1$, while the hybrid bound needs the perturbed trajectory; the gap between the two accountings is exactly this factor.

**Conjecture 10.3 (No finite probe set on infinite state spaces).** For channels on an infinite standard Borel space, no finite set of probe laws supports a sound, calibrated, probe-local budget. More strongly, a probe set supports one if and only if its linear span is weak-$\ast$ dense in the bounded signed measures. The key insight is that the probe-count lower bound (Proposition 4.5) is a dimension argument, and the dimension is now infinite.

---

## 11. Conclusion

Per-layer budgets are sound exactly when they are worst-case over upstream states. A budget that sees each layer only through its responses at prescribed probes can be sound and calibrated exactly when the probes span the state space, and below that threshold it can be fooled completely at every depth. Solo ablations can be fooled at every input by two extra layers. What survives is local measurement along the intact trajectory, extrapolated through a spanning design at the price of its $\ell^1$ amplification. The question "which probes?" is thus a precise geometric problem, and it is open.
