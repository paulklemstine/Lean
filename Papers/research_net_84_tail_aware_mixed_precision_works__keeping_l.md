# Tail-Aware Mixed Precision: Sensitivity Profiles, Submodular Damage, and an Optimal Bit-Allocation Law

**Author:** Aristotle
**Date:** 2026-09-01

---

## Abstract

Uniform quantization treats every layer of a deep network as equally deserving of
precision. We develop a three-part theory showing that this is never optimal, identify
exactly which layers must be protected, and derive the precise number of extra bits they
deserve.

First, we build a layer-wise propagation model in which a perturbation injected at depth
$j$ contributes to the end-to-end deviation an amount equal to its magnitude times the
*sensitivity* $s(j) = \prod_{k>j} L_k$, the product of the Lipschitz constants of all
downstream layers. We prove a **dichotomy**: in a non-expansive stack ($L_j \le 1$ for
all $j$) the sensitivity profile is monotone non-decreasing in depth and attains its
maximum value $1$ at the final layer, whereas in an expansive stack ($L_j \ge 1$) the
profile is antitone and the head dominates. "Protect the tail" is therefore a theorem
about the contraction regime, not a universal heuristic.

Second, we model retained accuracy as an agreement rate governed by a family of
disagreement sets $D(S)$ indexed by the set $S$ of quantized layers. Under monotonicity
and coverage we prove a **protection sandwich** $0 \le \mathrm{gain}(T) \le |D(T)|$ and a
budget bound $\mathrm{gain}(T) \le \sum_{i \in T} |D(\{i\})|$; conversely, any
super-additive measurement is a certificate that coverage fails and forces an
**emergent** disagreement set, of relative size at least $(r-1)/r$ when the joint damage
is $r$ times the sum of the parts. We prove that the disagreement-count functional of
any monotone covering family is **submodular**, and deduce the *tail-as-one-unit*
theorem: joint protection of a layer pair dominates the sum of the separate protections,
strictly whenever the pair interaction is positive.

Third, we convert the sensitivity profile into a quantitative allocation law. With
$b$-bit uniform quantizers producing deviations $R_i 2^{-b_i}$, the certified cost is
$\mathrm{cost}(b) = \sum_i c_i 2^{-b_i}$ with $c_i = s(i) R_i$. We prove the sharp lower
bound $\mathrm{cost}(b) \ge n(\prod_i c_i)^{1/n} 2^{-B/n}$ for every allocation of budget
$B$, exhibit the water-filling allocation $b^\star_i = B/n + \log_2 c_i - \frac1n \sum_j
\log_2 c_j$ that attains it, and derive the **logarithmic precision law**: the optimal
bit gap between two blocks is exactly $\log_2(c_i/c_j)$, independent of budget and of all
other blocks. For a geometric profile $s(k) = \lambda^{n-1-k}$ the gap is linear in
depth, $(j-i)\log_2(1/\lambda)$. Flooring to hardware-realizable integer widths stays
within budget and costs at most a factor $2$.

A measured three-arm instance on a 24-layer, half-billion-parameter transformer
instantiates the theory in exact rational arithmetic: retained accuracies $0.9081$
(all layers at 4 bits), $0.9261$ (all but the final pair), $0.9766$ (final pair only);
gain exactly $0.018$; coverage slack exactly $0.0054$; protection efficiency exactly
$10/13$; memory overhead below $6\%$ of the compressed model.

**Keywords:** quantization, mixed precision, Lipschitz sensitivity, submodularity,
water-filling, epistasis, bit allocation.

---

## 1. Introduction

### 1.1 The uniform-precision default

Deploying a trained neural network almost always means compressing it. The dominant
technique is *post-training quantization*: each weight, natively a 32-bit float, is
mapped to the nearest point of a coarse grid with $2^b$ levels, typically $b = 4$ or
$b = 8$. The memory saving is a factor of $32/b$, and modern quantizers keep the model's
behaviour close enough to the original that the trade is worth making.

The default is to use the same $b$ for every layer. This is convenient — a single
knob, uniform kernels, no search — but it is a modelling choice with no justification.
The layers of a deep network are not interchangeable: they sit at different depths, and
depth determines how far a perturbation has to travel before it reaches the output.

*Mixed precision* is the practice of giving different layers different bit widths. It is
widely used and almost entirely empirical: bit widths are chosen by search, by
sensitivity probes, or by rule of thumb. This paper asks — and answers — the two
questions such a practice ought to be built on:

1. **Which** layers deserve extra precision, and under what hypotheses?
2. **How much** extra precision, exactly?

### 1.2 The empirical anchor

The theory below was developed alongside a three-arm measurement on a 24-layer decoder
transformer with approximately $4.94 \times 10^8$ parameters, evaluated by *retained
accuracy* — the fraction of a fixed evaluation set on which the compressed model's
prediction agrees with the full-precision model's prediction — at context length $1024$
with the routing gate held exact.

| Arm | Layers quantized to 4 bits | Retained accuracy |
|---|---|---|
| A | all $24$ | $0.9081$ |
| B | all except the final pair $\{L_{22}, L_{23}\}$ | $0.9261$ |
| C | the final pair only | $0.9766$ |

Two predictions had been registered in advance. **P1**: mixed precision with a protected
tail exceeds uniform 4-bit. **P2**: the tail does *not* benefit from precision
protection. Arm B confirms P1 ($+0.018$, i.e. $+1.8$ points) and refutes P2.

The rest of this paper is the mathematics that makes those numbers unsurprising.

### 1.3 Contributions and organization

Section 2 develops the propagation model and proves the sensitivity dichotomy. Section 3
develops the coverage model of retained accuracy, the protection sandwich, and the
epistasis certificates. Section 4 proves submodularity of the agreement metric and the
tail-as-one-unit theorem. Section 5 proves the water-filling bit-allocation law and its
corollaries, including integer rounding. Section 6 instantiates everything on the
measurement in exact arithmetic and confronts an accounting discrepancy. Section 7 gives
algorithms. Section 8 discusses limitations, the coverage/epistasis incompatibility, and
future work.

---

## 2. The propagation model and the sensitivity dichotomy

### 2.1 Setup

We model a network as an iterated composition of scalar layers; the scalar case carries
all the structure of interest and every statement below lifts verbatim to normed spaces
with $|\cdot|$ replaced by a norm.

**Definition 2.1 (Layer stack and partial run).** Given a family of layers
$f : \mathbb{N} \to \mathbb{R} \to \mathbb{R}$, define the *run* of $k$ consecutive layers
starting at index $i$ by
$$\mathrm{run}_f(i, 0, x) = x, \qquad \mathrm{run}_f(i, k+1, x) = \mathrm{run}_f(i+1, k, f_i(x)).$$

**Definition 2.2 (Block amplification).** For a family of Lipschitz constants
$L : \mathbb{N} \to \mathbb{R}$, set
$$\mathrm{tailProd}(L, m, k) = \prod_{s=0}^{k-1} L_{m+s},$$
the amplification of the block of $k$ layers beginning at index $m$; the empty product is
$1$.

Immediate facts: $\mathrm{tailProd}$ is non-negative when all $L_j \ge 0$; it is bounded
by $1$ when in addition all $L_j \le 1$; and it is at least $1$ when all $L_j \ge 1$. It
satisfies the peeling identity $\mathrm{tailProd}(L,m,k+1) = L_m \cdot
\mathrm{tailProd}(L,m+1,k)$.

**Lemma 2.3 (Composite Lipschitz bound).** If every layer satisfies $|f_j(x) - f_j(y)|
\le L_j |x-y|$ with $L_j \ge 0$, then for all $i,k,x,y$,
$$|\mathrm{run}_f(i,k,x) - \mathrm{run}_f(i,k,y)| \le \mathrm{tailProd}(L,i,k)\,|x-y|.$$

*Proof sketch.* Induction on $k$. The base case is the identity. For the step, apply the
inductive hypothesis to the tail block at input $f_i(x)$ versus $f_i(y)$, then apply the
layer-$i$ Lipschitz hypothesis, and use the peeling identity. ∎

### 2.2 Certified end-to-end error

**Definition 2.4 (Certified error bound).** For per-layer deviation budgets $\delta$,
$$\mathrm{errBound}(\delta, L, i, k) = \sum_{t=0}^{k-1} \delta_{i+t}\cdot
\mathrm{tailProd}(L, i+t+1, k-1-t).$$
Each layer's deviation is weighted by the amplification of the layers *downstream* of it
inside the block.

**Theorem 2.5 (Master propagation theorem).** Let $f$ be a layer stack with Lipschitz
constants $L_j \ge 0$, and let $g$ be a second stack with $|f_j(x) - g_j(x)| \le \delta_j$
for all $j$ and $x$. Then for every $i$, $k$ and input $x$,
$$|\mathrm{run}_f(i,k,x) - \mathrm{run}_g(i,k,x)| \le \mathrm{errBound}(\delta, L, i, k).$$

*Proof sketch.* Induction on $k$, splitting the discrepancy at the first layer by the
triangle inequality:
$$|\mathrm{run}_f(f_i x) - \mathrm{run}_g(g_i x)| \le
|\mathrm{run}_f(f_i x) - \mathrm{run}_f(g_i x)| + |\mathrm{run}_f(g_i x) - \mathrm{run}_g(g_i x)|.$$
The first term is bounded by Lemma 2.3 applied to the tail block, times $\delta_i$; the
second is the inductive hypothesis. The identity
$\mathrm{errBound}(\delta,L,i,k+1) = \mathrm{errBound}(\delta,L,i+1,k) + \delta_i \cdot
\mathrm{tailProd}(L,i+1,k)$ reassembles the two into the claimed bound. ∎

**Proposition 2.6 (Monotonicity in precision).** If $\delta'_j \le \delta_j$ for all $j$
and $L_j \ge 0$, then $\mathrm{errBound}(\delta', L, i, k) \le \mathrm{errBound}(\delta,
L, i, k)$.

This is termwise comparison, but it is exactly the statement that makes an "8-bit tail
instead of a 4-bit tail" follow-up experiment *well posed*: refining a quantizer cannot
increase the certificate, so any measured degradation would falsify the model rather than
the intervention.

### 2.3 The sensitivity profile

**Definition 2.7 (Sensitivity).** For a network of depth $n$, the sensitivity of layer
$m$ is $s_L(n, m) = \mathrm{tailProd}(L, m+1, n-1-m)$: the product of the Lipschitz
constants of all layers strictly after $m$.

Thus $\mathrm{errBound}(\delta, L, 0, n) = \sum_{m<n} \delta_m \, s_L(n,m)$, and $s$ is
precisely the weight with which a perturbation at depth $m$ enters the certified error.

**Theorem 2.8 (Tail dominance in the non-expansive regime).** Suppose $0 \le L_j \le 1$
for every $j$. Then $s_L(n, \cdot)$ is monotone non-decreasing on $\{0,\dots,n-1\}$:
$$m \le m' < n \implies s_L(n,m) \le s_L(n,m').$$
Moreover $s_L(n, n-1) = 1$ and $s_L(n,m) \le 1$ for all $m$, so the last layer is a
maximizer.

*Proof sketch.* The one-step identity $s_L(n,m) = L_{m+1}\, s_L(n,m+1)$, obtained from the
peeling identity after rewriting $n-1-m = (n-1-(m+1)) + 1$, combined with $0 \le L_{m+1}
\le 1$ and $s_L(n,m+1) \ge 0$, gives $s_L(n,m) \le s_L(n,m+1)$. Induct on $m'$. The
maximum value is $1$ because the last layer's downstream block is empty. ∎

**Theorem 2.9 (Head dominance in the expansive regime).** If $L_j \ge 1$ for every $j$
then $s_L(n, \cdot)$ is antitone: $m \le m' < n \implies s_L(n,m') \le s_L(n,m)$.

*Proof sketch.* The same one-step identity, now with $L_{m+1} \ge 1$ and $s_L(n,m+1) \ge
1$ (a product of numbers $\ge 1$), yields $s_L(n,m) \ge s_L(n,m+1)$. ∎

**Corollary 2.10 (Precision dichotomy).** For a depth-$n$ network with $L_j \ge 0$:
* if all $L_j \le 1$, then $s_L(n,m) \le s_L(n,n-1)$ for all $m<n$ — the *tail* is the
  most sensitive location;
* if all $L_j \ge 1$, then $s_L(n,n-1) \le s_L(n,m)$ for all $m<n$ — the *head* is the
  most sensitive location.

This is the conceptual centre of the paper. Tail-aware mixed precision is *not* a
universal law of deep networks; it is the correct policy exactly in the contractive
regime — which is the regime that normalization layers, residual scaling, and
weight-decayed training conspire to produce. In an expansive network the same
mathematics prescribes the opposite intervention.

**Proposition 2.11 (Uniform-noise bound).** In a non-expansive network with uniform
per-layer deviation $\varepsilon \ge 0$, the certified error over $n$ layers is at most
$\varepsilon n$.

*Proof sketch.* Each of the $n$ summands is $\varepsilon$ times an amplification factor
bounded by $1$. ∎

So even though sensitivity is tail-dominant, it remains summable: the certificate degrades
only linearly in depth, which is what makes uniform quantization viable at all — and what
makes the *marginal* value of protecting a few tail layers, rather than all of them, the
right thing to optimize.

### 2.4 Protection at the level of certificates

Write $\delta^{P}_j = 0$ if $j \in P$ and $\delta_j$ otherwise: the certificate of a
network whose protected block $P$ is exact.

**Proposition 2.12 (Certificate sandwich).** For $L_j \ge 0$, $\delta_j \ge 0$ and any
protected set $P$,
$$\mathrm{errBound}(\delta^P, L, i, k) \;\le\; \mathrm{errBound}(\delta, L, i, k)
\;\le\; \mathrm{errBound}(\delta^{P}, L, i, k) + \mathrm{errBound}(\delta^{\complement P}, L, i, k),$$
where $\delta^{\complement P}$ keeps only the protected coordinates. Protection never
increases the certificate, and the improvement is at most the certified damage of the
protected block alone.

*Proof sketch.* The left inequality is Proposition 2.6. The right is termwise: for each
$t$, exactly one of the two split terms equals $\delta_{i+t}$ and the other is $0$. ∎

This is the propagation-model shadow of the set-theoretic protection sandwich proved in
the next section — the two models, one metric and one combinatorial, agree.

---

## 3. The coverage model of retained accuracy

### 3.1 Disagreement sets

Retained accuracy is an *agreement rate*, not a norm. The natural object is therefore a
set of failures rather than a real number.

**Definition 3.1 (Disagreement family).** Fix a finite evaluation set of prompts. A
*disagreement family* assigns to each finite set $S$ of quantized layers the set $D(S)$
of prompts on which the model with exactly $S$ quantized differs in prediction from the
full-precision model. The *damage* is $\mathrm{qErr}(S) = |D(S)|$.

Two structural hypotheses:

* **(M) Monotonicity.** $A \subseteq B \implies D(A) \subseteq D(B)$.
* **(C) Coverage.** $D(A \cup B) \subseteq D(A) \cup D(B)$.

(M) says quantizing more can only break more. (C) says every joint failure is already a
failure of one of the parts — precisely the assumption that damages do not interact.

**Lemma 3.2.** Under (C), $\mathrm{qErr}$ is subadditive:
$\mathrm{qErr}(A \cup B) \le \mathrm{qErr}(A) + \mathrm{qErr}(B)$.
Under (M) it is monotone: $A \subseteq B \implies \mathrm{qErr}(A) \le \mathrm{qErr}(B)$.

*Proof sketch.* Cardinality is monotone under inclusion, and $|X \cup Y| \le |X| + |Y|$. ∎

### 3.2 The protection sandwich

**Theorem 3.3 (Protection sandwich).** Assume (M) and (C). For any quantized set $U$ and
any protected subset $T$,
$$\mathrm{qErr}(U \setminus T) \le \mathrm{qErr}(U) \le \mathrm{qErr}(U \setminus T) + \mathrm{qErr}(T).$$
Equivalently, with $\mathrm{gain}(T) = \mathrm{qErr}(U) - \mathrm{qErr}(U \setminus T)$,
$$0 \;\le\; \mathrm{gain}(T) \;\le\; \mathrm{qErr}(T).$$

*Proof sketch.* Left: $U \setminus T \subseteq U$ and (M). Right: $U \subseteq (U
\setminus T) \cup T$ — every element of $U$ is either in $T$ or in $U \setminus T$ — so
(M) then Lemma 3.2 give the bound. ∎

In words: **protecting layers never hurts, and never buys back more quality than those
layers destroy when they alone are quantized.** The upper bound is a *ceiling* that can
be measured directly by a single extra experiment (arm C above), which makes the sandwich
falsifiable rather than decorative.

**Theorem 3.4 (Protection budget).** Assume (C) and $D(\emptyset) = \emptyset$. Then for
every finite set $S$,
$$\mathrm{qErr}(S) \le \sum_{i \in S} \mathrm{qErr}(\{i\}),$$
and consequently $\mathrm{gain}(T) \le \sum_{i \in T} \mathrm{qErr}(\{i\})$ for every
protected $T \subseteq U$.

*Proof sketch.* Induction on $S$ using $\mathrm{insert}(a,S) = \{a\} \cup S$ and Lemma
3.2; combine with Theorem 3.3. ∎

This is the layer-wise sensitivity-probe justification: under coverage, single-layer
probes upper-bound every multi-layer intervention. When they *fail* to, coverage is
false — which is the subject of the next subsection, and the reason single-layer probes
are not the end of the story.

### 3.3 Epistasis certificates

**Theorem 3.5 (Emergent disagreement).** If $\mathrm{qErr}(A) + \mathrm{qErr}(B) <
\mathrm{qErr}(A \cup B)$, then the *emergent set*
$$\mathcal{E}(A,B) = D(A\cup B) \setminus (D(A) \cup D(B))$$
is non-empty: there exist prompts broken by the joint perturbation and by neither part
alone.

*Proof sketch.* If $\mathcal{E}(A,B) = \emptyset$ then $D(A\cup B) \subseteq D(A) \cup
D(B)$, whence $\mathrm{qErr}(A \cup B) \le \mathrm{qErr}(A) + \mathrm{qErr}(B)$,
contradicting the hypothesis. ∎

**Theorem 3.6 (Coverage is globally refuted by one super-additive pair).** A single pair
$A, B$ with $\mathrm{qErr}(A) + \mathrm{qErr}(B) < \mathrm{qErr}(A\cup B)$ implies that
(C) fails: it is *not* the case that $D(X \cup Y) \subseteq D(X) \cup D(Y)$ for all $X,Y$.

**Theorem 3.7 (Quantitative emergence).** In general,
$$\mathrm{qErr}(A\cup B) \le |\mathcal{E}(A,B)| + \mathrm{qErr}(A) + \mathrm{qErr}(B).$$
If moreover the joint damage is an $r$-fold amplification of the separate damages,
$\mathrm{qErr}(A \cup B) = r\,(\mathrm{qErr}(A) + \mathrm{qErr}(B))$ with $r \ge 1$, then
$$r \cdot |\mathcal{E}(A,B)| \;\ge\; (r-1)\cdot \mathrm{qErr}(A\cup B),$$
i.e. at least a fraction $\frac{r-1}{r}$ of all joint failures are emergent.

*Proof sketch.* The first inequality is $|X| \le |X \setminus Y| + |Y|$ applied with
$X = D(A\cup B)$, $Y = D(A) \cup D(B)$, followed by $|D(A) \cup D(B)| \le |D(A)| + |D(B)|$.
For the second, write $\Sigma = \mathrm{qErr}(A) + \mathrm{qErr}(B)$; the first inequality
gives $|\mathcal{E}| \ge r\Sigma - \Sigma = (r-1)\Sigma$, and multiplying by $r$ and
substituting $r\Sigma = \mathrm{qErr}(A\cup B)$ gives the claim. ∎

**Corollary 3.8 (Six-sevenths).** A $7\times$ super-additive joint perturbation of two
layers has at least $\tfrac{6}{7}$ of its failures emergent — caused by neither layer
alone.

This is the quantitative content of the "the tail pair is epistatic" observation: a
$7\times$ super-additivity in joint pruning cost is not a vague statement about
interaction, it is a lower bound of $6/7$ on the emergent share. Any optimizer that
scores layers individually is blind to at least six sevenths of the damage.

---

## 4. Submodularity and the tail-as-one-unit theorem

### 4.1 Exact decomposition of a pair gain

Let $E$ be any real-valued damage functional on finite layer sets.

**Definition 4.1.** For a quantized set $U$ and $S \subseteq U$,
$\mathrm{gain}_E(U,S) = E(U) - E(U \setminus S)$. For $a \neq b$, the *pair interaction*
is
$$I_E(U;a,b) = E(U\setminus\{a\}) + E(U \setminus\{b\}) - E(U) - E(U \setminus \{a,b\}).$$

**Theorem 4.2 (Exact pair decomposition).** For every $E$, $U$, $a$, $b$ — no hypotheses
whatsoever —
$$\mathrm{gain}_E(U, \{a,b\}) = \mathrm{gain}_E(U,\{a\}) + \mathrm{gain}_E(U,\{b\}) + I_E(U;a,b).$$

*Proof.* Expand both sides; every term cancels except by construction. ∎

The identity localizes all non-additivity of protection into a single scalar.

### 4.2 Submodularity forces a non-negative interaction

**Definition 4.3.** $E$ is *submodular* if $E(X \cup Y) + E(X \cap Y) \le E(X) + E(Y)$ for
all $X, Y$.

**Lemma 4.4.** For $a \ne b$: $(U\setminus\{a\}) \cup (U \setminus \{b\}) = U$ and
$(U\setminus\{a\}) \cap (U\setminus\{b\}) = U \setminus \{a,b\}$.

**Theorem 4.5 (Non-negative interaction).** If $E$ is submodular then $I_E(U;a,b) \ge 0$
for all $U$ and all $a \ne b$.

*Proof.* Apply submodularity to $X = U\setminus\{a\}$, $Y = U \setminus\{b\}$ and rewrite
via Lemma 4.4:
$E(U) + E(U\setminus\{a,b\}) \le E(U\setminus\{a\}) + E(U\setminus\{b\})$, which is
$I_E(U;a,b) \ge 0$. ∎

**Theorem 4.6 (Tail-as-one-unit).** If $E$ is submodular then for all $a \ne b$,
$$\mathrm{gain}_E(U,\{a\}) + \mathrm{gain}_E(U,\{b\}) \;\le\; \mathrm{gain}_E(U,\{a,b\}).$$
If $I_E(U;a,b) > 0$ the inequality is strict, and then the pair strictly dominates each
singleton individually whenever the singleton gains are non-negative.

*Proof.* Theorem 4.2 plus Theorem 4.5. ∎

Note what the proof does *not* need: the hypotheses "$a \in U$" and "$b \in U$" play no
role. Only $a \ne b$ is used, so the theorem holds in the stronger, hypothesis-free
form.

### 4.3 The agreement metric is submodular

Theorem 4.6 would be an assumption of convenience if submodularity had to be postulated.
It does not.

**Theorem 4.7 (Submodularity of disagreement counts).** Let $D$ be a disagreement family
satisfying (M) and (C). Then $S \mapsto |D(S)|$ is submodular.

*Proof sketch.* By (C), $|D(A\cup B)| \le |D(A) \cup D(B)|$. By (M) applied to the two
inclusions $A \cap B \subseteq A$ and $A \cap B \subseteq B$, we get $D(A\cap B) \subseteq
D(A) \cap D(B)$, so $|D(A\cap B)| \le |D(A) \cap D(B)|$. Adding and using the
inclusion–exclusion identity $|X \cup Y| + |X \cap Y| = |X| + |Y|$ for the sets
$X = D(A)$, $Y = D(B)$ yields
$|D(A\cup B)| + |D(A \cap B)| \le |D(A)| + |D(B)|$. ∎

**Corollary 4.8.** Whenever retained accuracy arises from a monotone covering family of
disagreement sets, joint protection of a layer pair dominates the sum of the separate
protections.

Submodularity of the damage is therefore *structural*: it is forced by the fact that
retained accuracy counts prompts, not by an optimization-theoretic convenience. Combined
with Theorem 4.2, this is the precise content of the prescription **treat the tail pair as
one unit** — in the protection dimension, and by the same argument in any other
optimization dimension whose objective is an agreement rate.

---

## 5. The optimal bit-allocation law

### 5.1 Cost model

A $b$-bit uniform quantizer applied to a weight block with dynamic range $R$ has grid
spacing proportional to $R\,2^{-b}$, so the induced layer deviation obeys $\delta \approx
R\,2^{-b}$. Substituting into the propagation bound of Section 2 with sensitivity weights
$s(i)$ gives the certified end-to-end error of an allocation.

**Definition 5.1 (Certified cost).** For $n$ blocks with coefficients $c_i = s(i) R_i >
0$ and a real-valued bit allocation $b : \{0,\dots,n-1\} \to \mathbb{R}$,
$$\mathrm{cost}(c,b) = \sum_{i} c_i\, 2^{-b_i}.$$
The bit budget constraint is $\sum_i b_i = B$ (a continuous relaxation of the integer
constraint; Section 5.4 restores integrality).

### 5.2 The fundamental lower bound

**Theorem 5.2 (Bit-budget lower bound).** Let $n \ge 1$, $c_i > 0$, and let $b$ be any
allocation with $\sum_i b_i = B$. Then
$$\mathrm{cost}(c,b) \;\ge\; n \left(\prod_{i} c_i\right)^{1/n} 2^{-B/n}.$$

*Proof sketch.* Set $z_i = c_i 2^{-b_i} > 0$ and apply the weighted AM–GM inequality with
uniform weights $1/n$:
$$\prod_i z_i^{1/n} \;\le\; \sum_i \tfrac1n z_i \;=\; \tfrac1n\,\mathrm{cost}(c,b).$$
Because $\prod_i 2^{-b_i} = 2^{-\sum_i b_i} = 2^{-B}$ is determined by the budget alone,
$$\prod_i z_i = \Big(\prod_i c_i\Big)2^{-B}
\quad\Longrightarrow\quad
\prod_i z_i^{1/n} = \Big(\prod_i c_i\Big)^{1/n} 2^{-B/n}.$$
Multiplying through by $n$ gives the claim. ∎

Two readings. First, the *only* aggregate of the sensitivities that obstructs
compression is their **geometric mean**: a single catastrophically sensitive block can be
compensated by many benign ones, but only logarithmically. Second, the budget enters
exclusively through $2^{-B/n}$ — **one additional bit per block halves the achievable
certified error**, regardless of how the sensitivities are distributed.

### 5.3 Water-filling attains the bound

**Definition 5.3 (Water-filling allocation).**
$$b^\star_i \;=\; \frac{B}{n} \;+\; \log_2 c_i \;-\; \frac{1}{n}\sum_{j} \log_2 c_j .$$

**Theorem 5.4 (Budget feasibility).** $\sum_i b^\star_i = B$.

*Proof.* Summing, the $n$ copies of $B/n$ give $B$, and $\sum_i \log_2 c_i$ cancels
against $n \cdot \frac1n \sum_j \log_2 c_j$. ∎

**Theorem 5.5 (Attainment).** For $c_i > 0$,
$$\mathrm{cost}(c, b^\star) = n \Big(\prod_i c_i\Big)^{1/n} 2^{-B/n}.$$

*Proof sketch.* Using $\sum_j \log_2 c_j = \log_2 \prod_j c_j$, write
$$-b^\star_i = \frac{-B}{n} + \frac1n \log_2\!\Big(\prod_j c_j\Big) - \log_2 c_i .$$
Exponentiating base $2$ and using $2^{-\log_2 c_i} = c_i^{-1}$ and
$2^{\frac1n \log_2 P} = P^{1/n}$, every term becomes
$c_i \cdot 2^{-B/n} \cdot P^{1/n} \cdot c_i^{-1} = P^{1/n} 2^{-B/n}$ with $P = \prod_j c_j$
— independent of $i$. Summing the $n$ equal terms gives the claim. ∎

**Corollary 5.6 (Optimality).** For every allocation $b$ with $\sum_i b_i = B$,
$\mathrm{cost}(c, b^\star) \le \mathrm{cost}(c, b)$.

Theorem 5.5 also exhibits the equality case of AM–GM concretely: the optimum is precisely
the allocation that **equalizes the per-block contributions to the certified error**. This
is the design principle behind reverse water-filling in rate–distortion theory, here
derived for layer-wise quantization.

### 5.4 The logarithmic precision law

**Theorem 5.7 (Optimal bit gap).** For all $i, j$,
$$b^\star_i - b^\star_j = \log_2 c_i - \log_2 c_j = \log_2\!\frac{c_i}{c_j}.$$

*Proof.* The budget term $B/n$ and the mean term cancel in the difference. ∎

This deserves emphasis. The optimal *difference* in precision between two blocks depends
on **nothing** except their sensitivity ratio: not on the budget, not on the depth of the
network, not on the other blocks' sensitivities. Precision is the logarithm of
robustness.

**Corollary 5.8 (Ratio form).** If block $i$ is $r$ times as sensitive as block $j$
($c_i = r\,c_j$, $r>0$), then $b^\star_i - b^\star_j = \log_2 r$ exactly. A $4\times$ more
sensitive block deserves exactly two additional bits; a $256\times$ more sensitive block
deserves exactly eight.

**Corollary 5.9 (Monotone allocation; tail-aware precision derived).** If $c$ is
non-decreasing in the block index, then $b^\star$ is non-decreasing. In particular, by
Theorem 2.8, in a non-expansive network the optimal bit allocation is non-decreasing in
depth: **the tail must be kept at the highest precision**.

*Proof.* $\log_2$ is monotone on the positives, and $b^\star_i$ differs from $\log_2 c_i$
by a constant independent of $i$. ∎

**Theorem 5.10 (Geometric profile).** Suppose every layer contracts by the same factor,
$c_k = R\,\lambda^{\,n-1-k}$ with $R, \lambda > 0$. Then for $i \le j$,
$$b^\star_j - b^\star_i = (j-i)\,\log_2\!\frac{1}{\lambda}.$$

*Proof sketch.* Expand both $\log_2$'s via $\log_2(R\lambda^{m}) = \log_2 R + m\log_2
\lambda$ and note $(n-1-i) - (n-1-j) = j-i$. ∎

The optimal bit profile is therefore *affine in depth*, with slope $\log_2(1/\lambda)$
bits per layer. For $n=24$ and $\lambda = 0.9$, the final layer deserves
$23\log_2(1/0.9) \approx 3.50$ more bits than the first: a 4-bit body with a 7-to-8-bit
tail. For $\lambda = 0.95$ the total spread is $\approx 1.70$ bits, and for
$\lambda = 0.8$ it is $\approx 7.40$ bits — enough to justify keeping the last layers in
half or even single precision.

### 5.5 Integer bit widths

Hardware implements integer widths. Let $\lfloor b^\star \rfloor$ denote the componentwise
floor.

**Theorem 5.11 (Feasibility of rounding).** $\sum_i \lfloor b^\star_i \rfloor \le B$: the
floored allocation never exceeds the budget.

**Theorem 5.12 (Rounding costs at most a factor two).**
$$\mathrm{cost}(c, \lfloor b^\star \rfloor) \;\le\; 2\, n \Big(\prod_i c_i\Big)^{1/n} 2^{-B/n}
\;=\; 2\,\mathrm{cost}(c, b^\star).$$

*Proof sketch.* Since $\lfloor x \rfloor > x - 1$, monotonicity of $t \mapsto 2^{-t}$
gives $2^{-\lfloor x\rfloor} \le 2^{-(x-1)} = 2\cdot 2^{-x}$. Multiply by $c_i \ge 0$ and
sum. ∎

So the continuous relaxation loses nothing essential: the deployable integer allocation
sits within a factor $2$ — one bit — of an information-theoretic optimum, while remaining
inside the memory budget.

---

## 6. The measurement, in exact arithmetic

We now instantiate the theory on the three-arm measurement. Write $T$ for the final layer
pair and $R$ for the remaining $22$ layers, and let $\mathrm{err}(X) = 1 -
\mathrm{retained}(X)$.

$$\mathrm{err}(T) = 1 - 0.9766 = 0.0234,\quad
\mathrm{err}(R) = 1 - 0.9261 = 0.0739,\quad
\mathrm{err}(T \cup R) = 1 - 0.9081 = 0.0919 .$$

**Result 6.1 (Gain).** $\mathrm{gain}(T) = 0.9261 - 0.9081 = 0.018 = \tfrac{9}{500}$
exactly. Prediction P1 (mixed precision beats uniform 4-bit) is confirmed; prediction P2
(the tail does not benefit from protection) is refuted, since the gain is strictly
positive.

**Result 6.2 (Coverage consistency).** $\mathrm{err}(T\cup R) \le \mathrm{err}(T) +
\mathrm{err}(R)$: indeed $0.0919 \le 0.0973$, with slack exactly
$$\mathrm{err}(T) + \mathrm{err}(R) - \mathrm{err}(T\cup R) = 0.0054 = \tfrac{27}{5000}.$$
This measurement is *subadditive*, hence compatible with hypothesis (C); by Theorem 3.5
its emergent set is not certified to be non-empty.

**Result 6.3 (Sandwich).** $0 < 0.018 \le 0.0234$: the measured gain sits strictly inside
the protection sandwich of Theorem 3.3, with the ceiling supplied by arm C. This is an
independent numerical confirmation of the coverage model.

**Result 6.4 (Efficiency).** $13\cdot \mathrm{gain}(T) = 10 \cdot \mathrm{err}(T)$, so
protection realizes exactly
$$\frac{\mathrm{gain}(T)}{\mathrm{err}(T)} = \frac{10}{13} \approx 0.7692$$
of its theoretical ceiling; in particular $\tfrac34\,\mathrm{err}(T) < \mathrm{gain}(T) <
\mathrm{err}(T)$. Tail protection is highly, but not perfectly, effective: about $23\%$
of the tail's standalone damage is not recoverable by protecting the tail inside a
compressed network, because that damage overlaps with damage the body causes anyway.

**Result 6.5 (Interaction).** Realize the arms as a damage functional on the two-block
alphabet $\{T, R\}$:
$$E(\emptyset) = 0,\quad E(\{T\}) = 0.0234,\quad E(\{R\}) = 0.0739,\quad E(\{T,R\}) = 0.0919.$$
Its pair interaction is
$$I = E(\{R\}) + E(\{T\}) - E(\{T,R\}) - E(\emptyset) = 0.0054 > 0,$$
so even in this coverage-consistent regime, Theorem 4.6 applies strictly: **joint
protection of the block pair strictly beats the sum of the separate protections.**

### 6.1 Memory accounting — a discrepancy confronted

The protected tail comprises $2$ layers of $\approx 1.8\times 10^{6}$ parameters, i.e.
$3.6\times10^6$ parameters. At $4$ bits a parameter occupies $\tfrac12$ byte; at $32$-bit
float it occupies $4$ bytes. The incremental cost of protection is therefore
$$3.6\times10^6 \times \big(4 - \tfrac12\big) = 1.26\times10^7\ \text{bytes} \approx 12.6\ \mathrm{MB},$$
against a fully 4-bit model of $4.94\times10^8 \times \tfrac12 = 2.47\times10^8$ bytes
$\approx 247$ MB.

**Result 6.6 (Overhead bound).** The overhead ratio satisfies
$$\frac{1.26\times 10^7}{2.47\times 10^8} \;<\; 6\% .$$

We record explicitly that an overhead figure of $1.4\%$ does *not* follow from these
inputs — it would require either far fewer protected parameters or a much larger base
model — and the defensible, conservative statement is the $<6\%$ bound above. Reporting
the weaker true bound rather than the stronger false one is the point of doing the
arithmetic exactly.

**Result 6.7 (Quality per unit overhead).** $0.29 \times (\text{overhead ratio}) <
\mathrm{gain}(T)$: the intervention returns more than $0.29$ retained points per percent
of extra memory. Even under the conservative $6\%$ accounting, the trade is strongly
favourable — a single-digit percentage of memory for $1.8$ points of behavioural fidelity.

---

## 7. Algorithms

### 7.1 Sensitivity-driven bit allocation

Given per-layer Lipschitz estimates $L_j$ and dynamic ranges $R_j$:

1. Compute the sensitivity profile by a single backward pass:
   $s(n-1) = 1$, and $s(m) = L_{m+1}\, s(m+1)$ for $m = n-2, \dots, 0$. Cost: $O(n)$.
2. Set $c_i = s(i)\,R_i$.
3. Compute $\mu = \frac1n\sum_j \log_2 c_j$ and $b^\star_i = B/n + \log_2 c_i - \mu$.
   Cost: $O(n)$.
4. Clamp to the hardware-supported width set and repair the budget by returning bits from
   the least sensitive blocks first.

Total cost is linear in depth and requires no search over allocations — the analytic
optimum replaces the combinatorial one. The clamping step is where practice re-enters:
the unconstrained $b^\star$ may prescribe non-physical widths (negative, or above 32) and
must be projected onto $\{2,3,4,6,8,16,32\}$ or whatever the kernel supports.

### 7.2 Pair-interaction screening

To decide whether a candidate block should be protected as a unit:

1. Measure $E(U)$, $E(U\setminus\{a\})$, $E(U\setminus\{b\})$, $E(U\setminus\{a,b\})$ —
   four evaluation runs.
2. Compute $I = E(U\setminus\{a\}) + E(U\setminus\{b\}) - E(U) - E(U\setminus\{a,b\})$.
3. If $I > 0$, protect $\{a,b\}$ jointly: Theorem 4.6 guarantees the joint gain strictly
   exceeds the sum of the individual gains.
4. If $I < 0$ the damage functional is not submodular at $(a,b)$, which by Theorem 3.6
   certifies a non-empty emergent set: report it, because it means single-layer probes
   are unreliable in that region of the network.

### 7.3 Emergent-share estimation

Given the joint and separate damages of two interventions with amplification ratio $r$,
report the certified lower bound $(r-1)/r$ on the emergent share (Theorem 3.7). This is a
one-line computation that converts a super-additivity ratio into an interpretable
statement: for $r=7$, at least $85.7\%$ of joint failures are invisible to any per-layer
analysis.

---

## 8. Discussion

### 8.1 What the theory explains

The measurement's three numbers were, before this analysis, three numbers. Afterwards:

* **Why the tail at all.** Theorem 2.8: in a non-expansive stack, sensitivity is monotone
  in depth and maximal (equal to $1$) at the last layer. Perturbations injected at the
  end are not attenuated.
* **Why protection helps but not infinitely.** Theorem 3.3: the gain is sandwiched
  between $0$ and the tail's standalone damage. The measured value realizes $10/13$ of
  the ceiling.
* **Why *two* layers rather than one.** Theorems 4.5–4.7: the agreement metric is
  submodular, so the pair interaction is non-negative and joint protection dominates
  separate protection. Empirically $I = 0.0054 > 0$, so the domination is strict.
* **How many bits, quantitatively.** Theorem 5.7 and Corollary 5.9: bits should be
  allocated logarithmically in sensitivity, hence monotonically in depth.

### 8.2 The coverage/epistasis boundary

The theory contains an internal tension that is worth stating plainly rather than
smoothing over. Hypothesis (C) — coverage — and super-additive interaction are logically
incompatible: Theorem 3.6 shows a single super-additive pair refutes coverage globally.
The quantization measurement analysed here is coverage-consistent, with slack $0.0054$.
Companion measurements on the *same* layer pair under pruning are $7\times$
super-additive, hence emphatically not.

The honest reading is that the two experiments probe different regimes. Quantization
noise is a small, roughly independent perturbation of every weight; pruning is a rank-
and support-changing intervention that can destroy a computational pathway outright. The
theory supplies the invariant that measures the gap between the regimes: the cardinality
$|\mathcal{E}(A,B)|$ of the emergent set, which Theorem 3.7 lower-bounds by $(r-1)/r$ of
the joint damage. Zero in one regime, dominant in the other. Rather than a defect, this
is the theory's diagnostic: measure the emergent share and you know which regime you are
in, and hence whether per-layer sensitivity probes can be trusted.

### 8.3 Limitations

* **Worst-case certificates.** The propagation bound of Theorem 2.5 is a worst-case
  Lipschitz certificate; realized errors on natural inputs are typically far smaller. The
  *ordering* it induces on layers — which is all Corollary 5.9 uses — is more robust than
  the magnitudes.
* **Scalar layers.** We prove everything for scalar compositions. The lift to normed
  vector spaces is verbatim (replace $|\cdot|$ by $\|\cdot\|$ and Lipschitz constants by
  operator-norm bounds), but attention layers are only Lipschitz on bounded domains, so
  $L_j$ must be interpreted as a local constant.
* **Quantizer model.** The deviation model $\delta \approx R\,2^{-b}$ describes a uniform
  quantizer. Error-compensating quantizers (which redistribute rounding error across a
  block) produce deviations that shrink faster than $2^{-b}$ in some regimes, which would
  change the constants in Section 5 but not the logarithmic law, since the law only needs
  the deviation to be exponential in the bit width.
* **Single model, single evaluation.** The numerical instance is one $0.5$-billion
  parameter model at one context length. The theory is model-independent; the instance is
  not.

### 8.4 Future work

The most immediate test is the *logarithmic precision law* itself. Theorem 5.8 predicts
that a block $r$ times more sensitive deserves exactly $\log_2 r$ extra bits, and
Theorem 5.10 turns an estimated contraction factor into a predicted bit gap. Running the
tail at $8$ bits rather than at full precision gives exactly the second data point needed
to test whether retained accuracy depends on the allocation only through the certified
cost $\sum_i c_i 2^{-b_i}$ — that is, whether two allocations of equal certified cost
have retained accuracies differing by $o(1)$ as the budget grows.

Beyond that: replication at larger scale, where the geometric-profile prediction of a
$\approx 3.5$-bit spread across $24$ layers should scale with depth; longer contexts,
where the effective Lipschitz constants of attention layers change; and a systematic
measurement of the emergent share across intervention types, to map the boundary between
the coverage regime and the epistatic regime.

---

## 9. Summary of results

1. **Composite Lipschitz bound and master propagation theorem.** Perturbing layer $j$ by
   $\delta_j$ perturbs the output by at most $\sum_j \delta_j \prod_{k>j} L_k$.
2. **Precision dichotomy.** The sensitivity profile $s(m) = \prod_{k>m}L_k$ is monotone
   increasing in depth for non-expansive stacks (maximum $1$ at the last layer) and
   antitone for expansive stacks. Which end to protect is decided by the contraction
   regime.
3. **Protection sandwich and budget bound.** Under monotone coverage,
   $0 \le \mathrm{gain}(T) \le |D(T)| \le \sum_{i\in T}|D(\{i\})|$.
4. **Epistasis certificates.** Super-additivity forces a non-empty emergent set and
   globally refutes coverage; an $r$-fold amplification forces an emergent share of at
   least $(r-1)/r$, i.e. $6/7$ at $r=7$.
5. **Submodularity of the agreement metric, and tail-as-one-unit.** The disagreement
   count of any monotone covering family is submodular; hence protecting a layer pair
   jointly dominates the sum of the separate protections, strictly when the interaction is
   positive.
6. **Bit-budget lower bound and water-filling optimality.** Every allocation of budget $B$
   costs at least $n(\prod_i c_i)^{1/n}2^{-B/n}$, and $b^\star_i = B/n + \log_2 c_i -
   \frac1n\sum_j \log_2 c_j$ attains it while spending exactly $B$.
7. **Logarithmic precision law.** $b^\star_i - b^\star_j = \log_2(c_i/c_j)$; for a
   geometric profile the optimal allocation is affine in depth with slope
   $\log_2(1/\lambda)$; flooring to integers stays within budget at a cost factor of at
   most $2$.
8. **Exact instantiation.** Gain $= 0.018$; coverage slack $= 0.0054$; efficiency
   $= 10/13$; block interaction $= 0.0054 > 0$; memory overhead $< 6\%$ with quality
   return above $0.29$ points per percent.
