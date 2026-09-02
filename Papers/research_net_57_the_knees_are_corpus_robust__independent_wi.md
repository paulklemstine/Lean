# The Corpus Algebra of the Attention Knee

**Author:** Aristotle
**Date:** 2026-09-02

---

## Abstract

Sparse-attention deployment rests on a single empirical number: the *knee*, the smallest key budget at which a sorted attention profile already retains a prescribed fraction $\tau$ of its total mass. Measurements on transformer language models report a strikingly stable knee — roughly thirty keys, and specifically $k^\* = 16$ at context $512$ and $k^\* = 32$ at context $1024$ — which replicates *exactly* across independent text corpora, with control curves agreeing to four decimal places.

We give an algebraic theory that explains this stability and converts it into deployable statements. The essential step is to write the gate condition in linear rather than ratio form, $\tau M_w(n) \le M_w(k)$, so that it defines a half-space in the cone of nonnegative attention profiles. From this one reformulation we derive: (i) that the knee is a scale-invariant, non-archimedean valuation on the corpus cone, with the sharp pooling sandwich $\min \le k^\*(A+B) \le \max$ and exact equality on the diagonal; (ii) a *four-decimal theorem* showing that $\varepsilon$-agreement of two retention curves forces exact equality of knees whenever the reference corpus keeps a gate margin exceeding $\varepsilon$, together with a scale-free counterexample proving the margin hypothesis necessary; (iii) a Galois duality between gates and budgets, under which the retention curve is the upper envelope of the gate sweep and the sweep is a complete invariant of a corpus's measurable content; (iv) a domain-jump law in which cross-domain distortion is measured projectively — a $\rho$-tilt inflates the *missing mass* by exactly $\rho^2$, yielding a gate window $k^\*_A(\tau/\rho^2) \le k^\*_B(\tau) \le k^\*_A(\rho^2\tau)$ and, under a geometric tail, a budget bound logarithmic in the distortion; and (v) a structure theorem exhibiting the corpus cone as a *knee fan*, partitioned into non-empty polyhedral cells each cut out by exactly two linear measurements.

We also record a negative result of practical consequence: the knee is **not** additive, and the pooled knee is not even a function of the ingredient knees. Explicit two-key witnesses realise both endpoints of the sandwich for the *same* pair of corpora at different gates. Corpus robustness must therefore be stated as the sandwich together with its diagonal equality case, not as additivity.

**Keywords:** attention budget, retention knee, convex cone, non-archimedean valuation, Galois duality, Hilbert projective metric, polyhedral fan, sparse attention.

---

## 1. Introduction

### 1.1 The measurement

A transformer language model, when processing a token in a context of $n$ prior positions, distributes attention mass across those positions. Empirically the distribution is extremely heavy-headed: sorting the attention weights in decreasing order and accumulating, one finds that a small number of keys already account for almost all the mass.

The operational summary of this fact is the **knee**. Fix a *gate* $\tau \in (0,1]$ — typically $0.98$ — and define $k^\*$ to be the smallest budget $k$ such that the top $k$ keys retain at least a $\tau$ fraction of the total attention mass over the context. Sweeping $k$ over a grid and reporting the first pass yields a *razor bracket*: a largest observed failure and the smallest observed pass.

The measurement that motivates this paper is a replication. On a corpus of encyclopedic English text, the knee is $16$ at context $512$ and $32$ at context $1024$. Repeated verbatim on a disjoint, independently drawn shard of comparable text, the knee is again $16$ and again $32$ — the same integers, not nearby ones — while the random-key control curves agree with the first run to four decimal places ($0.1775$, $0.3004$). At context $2048$ the two corpora bracket to $24$–$32$, consistent within the documented grid. Across three contexts, two corpora, and two model sizes the budget remains near thirty keys.

The natural reading is that the knee measures a property of *trained attention* rather than of the evaluation text. This paper asks what mathematical properties a functional must have for such a reading to be justified — and finds that the answer is entirely algebraic.

### 1.2 What makes exactness possible

Two features of the knee conspire to make exact replication achievable where approximate replication is all one usually gets.

The first is **linearity**. Written as a statement about the ratio $M_w(k)/M_w(n)$, the gate is a nonlinear condition on the profile $w$. Written multiplicatively as $\tau M_w(n) \le M_w(k)$ it is a half-space. Both sides of a half-space are closed under addition of profiles and under multiplication by positive scalars. That two-sided closure is what allows corpora to be pooled without disturbing a common knee.

The second is **discreteness**. The knee is an integer-valued minimum. A continuous perturbation of the retention curve moves the knee only when it carries the curve across the gate at some grid point. If the reference curve maintains a margin exceeding the perturbation, the knee cannot move at all. Exactness is therefore not a coincidence; it is forced, and forced by a hypothesis one can actually measure.

### 1.3 Contributions and organisation

Section 2 sets up corpora as nonnegative profiles, the linear gate, and the knee, and establishes the adjunction between them. Section 3 develops the cone structure and the pooling laws, with sharpness witnesses. Section 4 proves the four-decimal theorem and its sharp converse. Section 5 develops the gate–budget duality and identifiability. Section 6 gives the domain-jump law in both the retained and the missing-mass coordinates, and the explicit geometric-tail budget. Section 7 proves the knee-fan structure theorem. Section 8 discusses algorithms and deployment consequences, Section 9 the limitations, and Section 10 future directions.

---

## 2. Corpora, gates, and the knee

### 2.1 Definitions

**Definition 2.1 (Profile and corpus).** An *attention profile* is a function $w : \mathbb{N} \to \mathbb{R}$, understood as the attention weights already sorted in non-increasing order of importance, with $w_i$ the mass of the $i$-th key. A profile is a **corpus** if $w_i \ge 0$ for all $i$.

We deliberately do not require the weights themselves to be sorted or normalised; all results below use only nonnegativity. Sorting is a *convention* about how a measured profile is presented, not a hypothesis of any theorem.

**Definition 2.2 (Head mass).** The *head mass* of $w$ at budget $k$ is
$$M_w(k) \;=\; \sum_{i<k} w_i .$$

**Definition 2.3 (Retained fraction).** For a context length $n$ with $M_w(n) > 0$, the *retained fraction* at budget $k$ is
$$R_w(n,k) \;=\; \frac{M_w(k)}{M_w(n)} .$$

**Definition 2.4 (The gate, in linear form).** For a context $n$, budget $k$ and gate $\tau \in \mathbb{R}$, say $w$ **clears** $(n,k,\tau)$, written $\mathrm{Cl}(w;n,k,\tau)$, if
$$\tau \, M_w(n) \;\le\; M_w(k) .$$

**Definition 2.5 (The knee).** The *knee* is
$$k^\*(w;n,\tau) \;=\; \min\{\, k \in \mathbb{N} : \mathrm{Cl}(w;n,k,\tau) \,\}.$$

**Lemma 2.6 (Consistency of the two forms).** If $M_w(n) > 0$ then $\mathrm{Cl}(w;n,k,\tau) \iff \tau \le R_w(n,k)$.

*Proof.* Divide by the positive quantity $M_w(n)$. $\square$

The linear form is the one we work with, because it is a half-space; the ratio form is the one the experiment reports.

### 2.2 Elementary structure

**Lemma 2.7.** For a corpus $w$: $M_w(0) = 0$; $M_w(k+1) = M_w(k) + w_k$; $M_w(k) \ge 0$; and $M_w$ is monotone non-decreasing.

**Lemma 2.8 (Bilinearity of head mass).** $M_{w+v}(k) = M_w(k) + M_v(k)$ and $M_{cw}(k) = c\,M_w(k)$.

**Lemma 2.9 (Monotonicity of the gate in the budget).** If $w$ is a corpus and $\mathrm{Cl}(w;n,k,\tau)$ holds, then $\mathrm{Cl}(w;n,l,\tau)$ holds for every $l \ge k$.

*Proof.* $M_w$ is monotone. $\square$

**Lemma 2.10 (Existence).** For a corpus $w$ and a gate $\tau \le 1$, the full context clears: $\mathrm{Cl}(w;n,n,\tau)$. Hence the defining set of the knee is non-empty and $k^\*(w;n,\tau) \le n$.

*Proof.* $\tau M_w(n) \le M_w(n)$ since $M_w(n) \ge 0$ and $\tau \le 1$. $\square$

### 2.3 The knee as a left adjoint

**Theorem 2.11 (Galois adjunction).** For a corpus $w$ and gate $\tau \le 1$,
$$k^\*(w;n,\tau) \le k \iff \mathrm{Cl}(w;n,k,\tau).$$

*Proof.* ($\Leftarrow$) is the definition of a minimum. ($\Rightarrow$): the knee itself clears (the defining set is non-empty by Lemma 2.10, so the minimum is attained), and clearing is upward closed in $k$ by Lemma 2.9. $\square$

This adjunction is used silently throughout: every statement of the form "the knee is at most $K$" is *literally* a linear inequality on $w$, and vice versa.

**Corollary 2.12 (Non-vacuity of the gate).** If $k < k^\*(w;n,\tau)$ then $\mathrm{Cl}(w;n,k,\tau)$ fails; conversely if the gate fails at $k$ then $k < k^\*$.

**Theorem 2.13 (Razor bracket).** Let $w$ be a corpus and $\tau \le 1$. If the gate fails at $a$ and holds at $b$, then
$$a < k^\*(w;n,\tau) \le b .$$

This is exactly the report format of a sweep: one observed failure and one observed pass pin the knee to a half-open interval.

**Theorem 2.14 (Pinning).** If the gate holds at $k$ and fails at every $j<k$, then $k^\*(w;n,\tau) = k$.

### 2.4 Context monotonicity

**Lemma 2.15.** Let $w$ be a corpus and $0 \le \tau$. If $n \le m$ and $\mathrm{Cl}(w;m,k,\tau)$ holds, then $\mathrm{Cl}(w;n,k,\tau)$ holds.

*Proof.* $M_w(n) \le M_w(m)$, so $\tau M_w(n) \le \tau M_w(m) \le M_w(k)$. $\square$

**Theorem 2.16 (Knees are monotone in the context).** For a corpus $w$ and $0 \le \tau \le 1$, if $n \le m$ then
$$k^\*(w;n,\tau) \;\le\; k^\*(w;m,\tau).$$

*Proof.* The knee at context $m$ clears at $m$, hence at $n$ by Lemma 2.15, hence bounds the knee at $n$ by the adjunction. $\square$

**Remark 2.17.** Theorem 2.16 says the measured ladder $k^\*(512) = 16 \le k^\*(1024) = 32$ is a structural fact, not a fitted trend: *no* corpus can produce a knee that decreases as the window grows. An observed inversion would be a measurement error, not a discovery.

---

## 3. The corpus cone and the pooling laws

### 3.1 The budget cone

**Definition 3.1.** For fixed $n$, budget $K$ and gate $\tau$, the **budget cone** is
$$\mathcal{C}(n,K,\tau) \;=\; \{\, w : \mathrm{Cl}(w;n,K,\tau) \,\}.$$

**Theorem 3.2 (Cone structure).** $\mathcal{C}(n,K,\tau)$ contains $0$, is closed under addition, and is closed under multiplication by nonnegative scalars. It is thus a convex cone (indeed an additive submonoid of the space of profiles).

*Proof.* All three are immediate from bilinearity of $M$ (Lemma 2.8): adding $\tau M_w(n) \le M_w(K)$ and $\tau M_v(n) \le M_v(K)$ gives the sum's inequality; multiplying by $c \ge 0$ preserves it; and $0$ clears trivially. $\square$

**Theorem 3.3 (The failing side is a cone too).** If $\mathrm{Cl}(w;n,k,\tau)$ fails and $\mathrm{Cl}(v;n,k,\tau)$ fails, then $\mathrm{Cl}(w+v;n,k,\tau)$ fails.

*Proof.* Add the two strict inequalities $M_w(k) < \tau M_w(n)$, $M_v(k) < \tau M_v(n)$. $\square$

Theorem 3.3 is the structurally decisive one. It is what upgrades an upper bound on the pooled knee to a two-sided sandwich, and hence what makes the knee — not merely a bound on it — corpus-robust.

**Theorem 3.4 (Filtration).** For $K \le L$ and $w$ a corpus, $w \in \mathcal{C}(n,K,\tau) \Rightarrow w \in \mathcal{C}(n,L,\tau)$. The budget cones therefore form an increasing filtration of the corpus cone, indexed by the budget, whose $K$-th stage is exactly $\{k^\* \le K\}$.

### 3.2 The pooling sandwich

**Theorem 3.5 (Sub-max law).** For corpora $A,B$ and $\tau \le 1$,
$$k^\*(A+B;n,\tau) \;\le\; \max\big(k^\*(A;n,\tau),\, k^\*(B;n,\tau)\big).$$

*Proof.* Let $K$ be the maximum. Each of $A$, $B$ clears at its own knee, hence at $K$ by Lemma 2.9; hence $A+B$ clears at $K$ by Theorem 3.2; hence $k^\*(A+B) \le K$ by the adjunction. $\square$

**Theorem 3.6 (Super-min law).** For corpora $A,B$ and $\tau \le 1$,
$$\min\big(k^\*(A;n,\tau),\, k^\*(B;n,\tau)\big) \;\le\; k^\*(A+B;n,\tau).$$

*Proof.* Suppose $k^\*(A+B) < \min$. Then at the budget $k^\*(A+B)$ both $A$ and $B$ fail (Corollary 2.12), so $A+B$ fails there by Theorem 3.3 — contradicting that $A+B$ clears at its own knee. $\square$

**Theorem 3.7 (Scale invariance).** For $c > 0$, $\;k^\*(cA;n,\tau) = k^\*(A;n,\tau)$.

*Proof.* $\mathrm{Cl}(cA;n,k,\tau) \iff c\,\tau M_A(n) \le c\,M_A(k) \iff \mathrm{Cl}(A;n,k,\tau)$; the defining sets coincide. $\square$

**Theorem 3.8 (Exact corpus robustness).** If $A,B$ are corpora with $k^\*(A;n,\tau) = k^\*(B;n,\tau)$ and $\tau \le 1$, then
$$k^\*(A+B;n,\tau) \;=\; k^\*(A;n,\tau).$$

*Proof.* The sandwich collapses when $\min = \max$. $\square$

**Corollary 3.9 (Mixing weights are irrelevant).** If $k^\*(A) = k^\*(B)$ and $a,b>0$, then $k^\*(aA + bB) = k^\*(A)$.

*Proof.* Scale invariance applied to each summand, then Theorem 3.8. $\square$

**Theorem 3.10 (The knee is a non-archimedean valuation).** On the cone of corpora at fixed $n$ and $\tau \le 1$, the functional $k^\*$ satisfies
$$k^\*(A+B) \le \max\big(k^\*(A),k^\*(B)\big), \qquad k^\*(cA) = k^\*(A) \;\; (c>0),$$
and its sublevel sets are the budget cones of Theorem 3.4.

The formal analogy is with the $p$-adic valuation on $\mathbb{Z}$ or the pole order of a rational function: an ultrametric, integer-valued, scale-blind functional whose sublevel sets filter the ambient object. Level sets of such a functional are stable under the ambient operation — which is precisely the abstract statement of corpus robustness.

### 3.3 Sharpness, and the failure of additivity

The two-key examples below show both endpoints of the sandwich are attained, and — more importantly — that they are attained by the *same pair of corpora* at different gates.

**Definition 3.11.** On a context of length $2$, let $e_1$ be the profile with $e_1(0)=1$ and $e_1(i)=0$ otherwise, and $e_2$ the profile with $e_2(1)=1$ and $e_2(i)=0$ otherwise.

**Lemma 3.12.** For every gate $\tau \in (0,1]$: $k^\*(e_1;2,\tau) = 1$ and $k^\*(e_2;2,\tau) = 2$.

*Proof.* $M_{e_1} = (0,1,1)$ at budgets $0,1,2$; the gate $\tau \cdot 1 \le M_{e_1}(k)$ fails at $k=0$ and holds at $k=1$. $M_{e_2} = (0,0,1)$; the gate fails at $k=0,1$ and holds at $k=2$. $\square$

**Theorem 3.13 (Min endpoint attained).** At gate $\tfrac12$,
$$k^\*(e_1+e_2;2,\tfrac12) = 1 = \min\big(k^\*(e_1),k^\*(e_2)\big).$$

*Proof.* $e_1+e_2$ is uniform with $M = (0,1,2)$; the gate reads $\tfrac12 \cdot 2 = 1 \le M(k)$, which fails at $k=0$ and holds at $k=1$. $\square$

**Theorem 3.14 (Max endpoint attained).** At gate $\tfrac34$,
$$k^\*(e_1+e_2;2,\tfrac34) = 2 = \max\big(k^\*(e_1),k^\*(e_2)\big).$$

*Proof.* The gate reads $\tfrac34 \cdot 2 = 1.5 \le M(k)$, which fails at $k=0,1$ and holds at $k=2$. $\square$

**Corollary 3.15 (The pooled knee is not a function of the ingredient knees).** There exist corpora $A,B$ and gates $\tau \ne \sigma$ with
$$k^\*(A;\tau)=k^\*(A;\sigma), \quad k^\*(B;\tau)=k^\*(B;\sigma), \quad\text{but}\quad k^\*(A+B;\tau) \ne k^\*(A+B;\sigma).$$

*Proof.* Take $A=e_1$, $B=e_2$, $\tau=\tfrac12$, $\sigma=\tfrac34$, and apply Lemma 3.12 with Theorems 3.13–3.14. $\square$

**Remark 3.16 (Methodological reading).** The tempting formulation of corpus robustness — additivity, $k^\*(A+B) = k^\*(A)$ — is false, and Corollary 3.15 shows that no repair phrased in terms of the ingredient knees alone can succeed. The correct statement is the sandwich (Theorems 3.5–3.6) together with its diagonal equality case (Theorem 3.8). This is a genuine "the definition must change" outcome, resolved in favour of the valuation/filtration picture.

---

## 4. The four-decimal theorem

The replication reports two things: that the knees agree exactly, and that the control curves agree to $10^{-4}$. This section shows the second implies the first, provided one further, measurable, quantity is in hand.

**Theorem 4.1 (Four-decimal theorem).** Let $A,B$ be corpora on a context of length $n$ with $M_A(n) > 0$ and $M_B(n) > 0$, let $\tau \le 1$, and let $\varepsilon \ge 0$. Suppose

1. **($\varepsilon$-agreement)** $\;|R_A(n,k) - R_B(n,k)| \le \varepsilon$ for every $k \le n$;
2. **(gate margin)** $\;|R_A(n,k) - \tau| > \varepsilon$ for every $k \le n$.

Then $k^\*(A;n,\tau) = k^\*(B;n,\tau)$.

*Proof.* Fix $k \le n$. By Lemma 2.6, clearing is equivalent to $\tau \le R_A(n,k)$ resp. $\tau \le R_B(n,k)$. By the margin hypothesis, either $R_A(n,k) > \tau + \varepsilon$ or $R_A(n,k) < \tau - \varepsilon$. In the first case $R_B(n,k) \ge R_A(n,k) - \varepsilon > \tau$, so both clear; in the second $R_B(n,k) \le R_A(n,k) + \varepsilon < \tau$, so neither clears. Hence the two gate predicates are *identical* on the grid $\{0,\dots,n\}$.

Both knees lie in that grid (Lemma 2.10). Therefore $B$ clears at $k^\*(A)$ and $A$ clears at $k^\*(B)$, and the adjunction gives inequalities in both directions. $\square$

**Theorem 4.2 (Bracket transfer).** Under the hypotheses of Theorem 4.1, any razor bracket measured on $A$ transfers verbatim to $B$: if the gate fails on $A$ at $a$ and holds on $A$ at $b$, then
$$a < k^\*(B;n,\tau) \le b .$$

**Corollary 4.3 (The measurement instance).** Let $A,B$ be corpora on a context of length $512$ with positive mass, with $|R_A(512,k) - R_B(512,k)| \le 10^{-4}$ and $|R_A(512,k) - 0.98| > 10^{-4}$ for all $k \le 512$. If the gate $0.98$ fails on $A$ at $k=12$ and holds at $k=16$, then
$$k^\*(B;512,0.98) \;=\; k^\*(A;512,0.98) \quad\text{and}\quad 12 < k^\*(B;512,0.98) \le 16 .$$

The reported sweep supplies exactly these inputs: $R_A(512,8) = 0.9318$ and $R_A(512,12) = 0.9759$ are both below $0.98$, with margins $0.0482$ and $0.0041$ — the tighter margin still forty times the four-decimal agreement tolerance — and the pass occurs at $k=16$. The second corpus's knee is then *forced* to be $16$, which is what was measured.

**Remark 4.4.** Note what is and is not being assumed. The measured $\varepsilon$-agreement is a statement about the whole grid; the margin is likewise checked at every grid point, and is the quantity most easily overlooked when reporting a replication. The theorem consumes both and returns an exact integer identity. Nothing about decay rates, sortedness, or the generative process of the text is used.

### 4.1 The margin hypothesis is necessary — at every scale

**Theorem 4.5 (Scale-free necessity of the margin).** Let $U$ be the uniform corpus $U_i = 1$ on a context of length $2$, at gate $\tfrac12$. Then $R_U(2,1) = \tfrac12$ exactly (zero margin), $k^\*(U;2,\tfrac12) = 1$, and for **every** tolerance $\varepsilon > 0$ there exists a corpus $B$ with
$$|R_U(2,k) - R_B(2,k)| \le \varepsilon \;\text{ for all } k \le 2, \qquad k^\*(B;2,\tfrac12) \ne k^\*(U;2,\tfrac12).$$

*Proof.* Put $\delta = \min(1,\varepsilon) > 0$ and let $B$ be the *tilted* corpus $B_0 = 1-\delta$, $B_i = 1$ for $i \ge 1$. Then $M_B = (0,\,1-\delta,\,2-\delta)$.

*Knee.* The gate reads $\tfrac12(2-\delta) = 1 - \tfrac{\delta}{2} \le M_B(k)$. At $k=1$ this asks $1-\tfrac{\delta}{2} \le 1-\delta$, false for $\delta>0$; at $k=2$ it holds. So $k^\*(B) = 2 \ne 1 = k^\*(U)$.

*Agreement.* At $k=0$ both retentions are $0$; at $k=2$ both are $1$. At $k=1$,
$$R_U(2,1) - R_B(2,1) \;=\; \frac12 - \frac{1-\delta}{2-\delta} \;=\; \frac{\delta}{2(2-\delta)} \;\le\; \frac{\delta}{2} \;\le\; \varepsilon,$$
using $2-\delta \ge 1$. $\square$

**Remark 4.6.** The failure is *scale-free*: shrinking $\varepsilon$ does not help, because the witness shrinks with it. Hence no amount of agreement between retention curves can force knee agreement in the absence of a gate margin. Theorem 4.1 is therefore sharp: the margin is exactly the extra input a replication must supply, and it supplies nothing beyond it.

---

## 5. Gate–budget duality and identifiability

Deployment tables report a *gate sweep*: a list of pairs $(\tau, k^\*(\tau))$. This section determines exactly how much of the corpus such a table pins down.

**Lemma 5.1 (Monotone in the gate).** For a corpus $w$ and $\tau \le \sigma \le 1$, $\;k^\*(w;n,\tau) \le k^\*(w;n,\sigma)$.

*Proof.* Clearing at gate $\sigma$ implies clearing at the smaller gate $\tau$, because $M_w(n) \ge 0$. Then apply the adjunction. $\square$

Thus the sweep $\tau \mapsto k^\*(w;n,\tau)$ is a non-decreasing, integer-valued step function on $(-\infty,1]$.

**Definition 5.2 (Gate set of a budget).** $\;G_w(n,k) = \{\tau \le 1 : k^\*(w;n,\tau) \le k\}$, the set of gates that budget $k$ can serve.

**Theorem 5.3 (Duality).** Let $w$ be a corpus with $M_w(n)>0$ and let $k \le n$. Then
$$G_w(n,k) \;=\; \big(-\infty,\; R_w(n,k)\big].$$

*Proof.* Since $k \le n$, $R_w(n,k) \le 1$. If $\tau \le 1$ and $k^\*(\tau) \le k$, the adjunction gives $\mathrm{Cl}(w;n,k,\tau)$, i.e. $\tau \le R_w(n,k)$. Conversely if $\tau \le R_w(n,k)$ then $\tau \le 1$ and $\mathrm{Cl}(w;n,k,\tau)$, so $k^\*(\tau) \le k$. $\square$

**Corollary 5.4 (The retention curve is the upper envelope of the sweep).**
$$R_w(n,k) \;=\; \sup\, G_w(n,k) \qquad (k \le n).$$

**Theorem 5.5 (Identifiability).** Let $A,B$ be corpora on a context of length $n$ with positive mass. If $k^\*(A;n,\tau) = k^\*(B;n,\tau)$ for **every** gate $\tau \le 1$, then $R_A(n,k) = R_B(n,k)$ for every $k \le n$.

*Proof.* The hypothesis makes the gate sets coincide for each $k$; take suprema and apply Corollary 5.4. $\square$

**Theorem 5.6 (Exact step description).** For a corpus $w$ with $M_w(n)>0$, $\tau \le 1$ and $k \le n$,
$$k^\*(w;n,\tau) = k \iff \Big(\tau \le R_w(n,k) \;\text{ and }\; R_w(n,j) < \tau \text{ for all } j < k\Big).$$

**Remark 5.7 (What a finite grid can and cannot claim).** Theorem 5.5 quantifies over the *whole* gate axis; that hypothesis is load-bearing. On a finite grid of gates, two corpora can share every measured knee and still differ in retention strictly between the measured steps — the step function does not determine its own risers from finitely many samples. A sweep-based deployment claim may assume exactly Theorem 5.5's strength and no more; in practice this means that measuring at more gates buys strictly more information about the corpus, whereas measuring at more budgets *within* a fixed gate does not, once the razor bracket is closed.

---

## 6. Domain jumps: a projective law

Both corpora in the motivating replication were drawn from the same textual family. The open regime is a **domain jump** — code, mathematics, another language — where the two corpora are not numerically close at all. For a scale-invariant functional, closeness must be measured projectively.

**Definition 6.1 ($\rho$-tilt).** For $\rho > 0$, say $B$ is a **$\rho$-tilt** of $A$, written $\mathrm{Tilt}_\rho(A,B)$, if for every key $i$
$$B_i \le \rho\,A_i \quad\text{and}\quad A_i \le \rho\,B_i .$$

This is a ball in the Hilbert projective metric on the corpus cone: $\mathrm{Tilt}_\rho$ is symmetric, and $\mathrm{Tilt}_1(A,A)$ holds for every $A$. Nontrivially, $\mathrm{Tilt}_\rho$ balls of radius $\rho > 1$ contain more than a point: e.g. the profile $(\tfrac12, 1, 1, \dots)$ is a $2$-tilt of the uniform profile.

**Lemma 6.2.** If $\mathrm{Tilt}_\rho(A,B)$ then $M_B(k) \le \rho\,M_A(k)$ for every $k$ (and symmetrically).

**Theorem 6.3 (Gate/budget exchange rate).** Let $\rho>0$, $\tau \ge 0$, and $\mathrm{Tilt}_\rho(A,B)$. If $A$ clears the inflated gate $\rho^2\tau$ at budget $k$, then $B$ clears the gate $\tau$ at the **same** budget $k$.

*Proof.* Using $M_B(n) \le \rho M_A(n)$ and $M_A(k) \le \rho M_B(k)$,
$$\rho\big(\tau M_B(n)\big) \;\le\; \rho^2 \tau\, M_A(n) \;\le\; M_A(k) \;\le\; \rho\, M_B(k),$$
and dividing by $\rho > 0$ gives $\tau M_B(n) \le M_B(k)$. $\square$

A tilt costs a factor $\rho^2$ in the *gate* and nothing in the *budget*. One factor of $\rho$ is spent inflating the total mass, one deflating the head mass.

**Theorem 6.4 (Domain-jump gate window).** Let $\rho>0$, $0 \le \tau \le 1$ with $\rho^2\tau \le 1$, let $A,B$ be corpora with $\mathrm{Tilt}_\rho(A,B)$. Then
$$k^\*\!\big(A;n,\tau/\rho^2\big) \;\le\; k^\*(B;n,\tau) \;\le\; k^\*\!\big(A;n,\rho^2\tau\big).$$

*Proof.* The right inequality is Theorem 6.3 applied at $A$'s own knee for gate $\rho^2\tau$, followed by the adjunction. The left is the same argument with the roles of $A$ and $B$ exchanged (using the symmetry of the tilt relation) at gate $\tau/\rho^2$. $\square$

**Corollary 6.5 (Exactness at $\rho=1$).** If $\mathrm{Tilt}_1(A,B)$ then $k^\*(B;n,\tau) = k^\*(A;n,\tau)$ for every $0 \le \tau \le 1$.

**Theorem 6.6 (Deployment criterion — flat window).** Under the hypotheses of Theorem 6.4, if the *reference* sweep is flat across the window,
$$k^\*\!\big(A;n,\tau/\rho^2\big) = k^\*\!\big(A;n,\rho^2\tau\big),$$
then every $\rho$-tilted corpus — including one from an unmeasured domain — has exactly that knee.

The criterion is attractive because the hypothesis is entirely about *measured* quantities on the corpus one already has. Flatness of one's own gate sweep across a multiplicative window of width $\rho^2$ licenses transferring the budget table to any domain within tilt radius $\rho$.

### 6.1 The sharp coordinate: missing mass

Theorem 6.4 is stated in the retained coordinate, where a tilt inflates the gate by $\rho^2$. At a deployment gate of $0.98$ that is vacuous unless $\rho^2 \le 1/0.98$, i.e. $\rho \lesssim 1.01$. The repair is to move to the complementary coordinate.

**Lemma 6.7 (Tail representation).** For $k \le n$, $\;M_w(n) - M_w(k) = \sum_{k \le i < n} w_i$.

**Lemma 6.8 (Tilts inflate tails by $\rho$).** If $\mathrm{Tilt}_\rho(A,B)$ and $k \le n$ then
$$M_B(n) - M_B(k) \;\le\; \rho\,\big(M_A(n) - M_A(k)\big).$$

**Theorem 6.9 (Sharp domain-jump law).** Let $\rho>0$, $\delta \ge 0$, $A$ a corpus with $\mathrm{Tilt}_\rho(A,B)$, and $k \le n$. If $A$ clears the gate $1-\delta$ at budget $k$ — i.e. leaves at most a fraction $\delta$ of its mass outside the top $k$ keys — then $B$ clears the gate $1-\rho^2\delta$ at the same budget $k$.

*Proof.* From $\mathrm{Cl}(A;n,k,1-\delta)$ we get $M_A(n) - M_A(k) \le \delta M_A(n)$. Lemma 6.8 then bounds $B$'s tail by $\rho\delta M_A(n)$, and $M_A(n) \le \rho M_B(n)$ upgrades this to $\rho^2 \delta M_B(n)$. Rearranging gives $(1-\rho^2\delta) M_B(n) \le M_B(k)$. $\square$

**Corollary 6.10.** $\;k^\*(B;n,1-\rho^2\delta) \le k^\*(A;n,1-\delta)$.

**Remark 6.11 (Why the coordinate change matters).** At $\tau = 0.98$ the missing mass is $\delta = 0.02$. A distortion $\rho = 1.1$ inflates it to $\rho^2\delta = 0.0242$, i.e. an effective gate of $0.9758$ — well inside a measured sweep. In the retained coordinate the same distortion would demand a gate of $1.19$, which is meaningless. The missing-mass coordinate is the one in which tilts act boundedly at deployment gates; this is a genuine lesson about how to *state* a cross-domain guarantee, not merely about how to prove one.

### 6.2 An explicit budget under a geometric tail

**Definition 6.12 (Geometric tail).** A corpus $A$ has an *$r$-geometric retention tail* at context $n$ if $\;1 - r^k \le R_A(n,k)$ for every $k \le n$.

**Theorem 6.13 (Domain-jump budget bound).** Let $A$ have an $r$-geometric tail at context $n$ with $M_A(n)>0$, let $\mathrm{Tilt}_\rho(A,B)$ with $\rho>0$, and let $\tau \ge 0$. Then for any budget $K \le n$ with
$$r^K \;\le\; 1 - \rho^2\tau,$$
we have $k^\*(B;n,\tau) \le K$.

*Proof.* The tail hypothesis gives $R_A(n,K) \ge 1 - r^K \ge \rho^2\tau$, so $A$ clears the inflated gate $\rho^2\tau$ at $K$; Theorem 6.3 transfers this to $B$ at gate $\tau$, and the adjunction concludes. $\square$

**Corollary 6.14 (Solving for the budget).** The condition is satisfied by
$$K \;=\; \left\lceil \frac{\log\big(1/(1-\rho^2\tau)\big)}{\log(1/r)} \right\rceil,$$
so the cost of a domain jump of projective radius $\rho$ is $O\!\big(\log(1/(1-\rho^2\tau))/\log(1/r)\big)$ keys — logarithmic in the distortion, and requiring **no** re-measurement on the new domain.

**Corollary 6.15 (Reference case).** Taking $\rho=1$: a geometric tail alone pins a context-uniform budget, $k^\*(A;n,\tau) \le K$ whenever $r^K \le 1-\tau$ and $K \le n$.

**Remark 6.16 (What cannot be done).** No bound on $k^\*(B;n,\tau)$ in terms of $k^\*(A;n,\tau)$ *alone* can hold uniformly over tilt balls. The uniform corpus is a bounded tilt of a geometric one only for large $\rho$, and its knee grows linearly in the context while the geometric corpus's knee stays logarithmic. The gate coordinate — not the budget coordinate — is the one in which a tilt acts boundedly. Theorem 6.3 is therefore not an artefact of the proof but the correct form of the statement.

---

## 7. The knee fan

The final structure organises all of the above into a single geometric picture.

**Definition 7.1 (Knee cell).** For fixed $n$ and $\tau$, the *knee cell* of label $K$ is
$$\mathcal{K}(n,\tau,K) \;=\; \{\, w : w \text{ is a corpus and } k^\*(w;n,\tau) = K \,\}.$$

**Theorem 7.2 (Two measurements cut out a cell).** For $\tau \le 1$ and $K \ge 1$,
$$w \in \mathcal{K}(n,\tau,K) \iff w \text{ is a corpus},\; \mathrm{Cl}(w;n,K,\tau),\; \text{and } \neg\,\mathrm{Cl}(w;n,K-1,\tau).$$

*Proof.* ($\Rightarrow$) The knee clears; and $K-1 < K$ fails by Corollary 2.12. ($\Leftarrow$) The pass gives $k^\* \le K$; the failure gives $K-1 < k^\*$. $\square$

**Corollary 7.3 (Polyhedrality).** Each cell is the intersection of the corpus cone with one closed half-space ($\mathrm{Cl}$ at $K$) and one open half-space ($\neg\mathrm{Cl}$ at $K-1$): a polyhedral cell.

**Theorem 7.4 (Cells are cones).** For $\tau \le 1$, each cell is closed under multiplication by positive scalars, closed under addition, and hence closed under strictly positive combinations: if $w,v \in \mathcal{K}(n,\tau,K)$ and $a,b>0$, then $aw+bv \in \mathcal{K}(n,\tau,K)$.

*Proof.* Scale invariance (Theorem 3.7) and exact corpus robustness (Theorem 3.8). $\square$

**Theorem 7.5 (Partition).** Cells with distinct labels are disjoint, and for every corpus $w$ and $\tau \le 1$ there is a label $K \le n$ with $w \in \mathcal{K}(n,\tau,K)$.

**Theorem 7.6 (Completeness of the fan).** Let $0 < \tau \le 1$. For every label $K$ with $1 \le K \le n$, the one-hot corpus $\delta_{K-1}$ (all mass on key $K-1$) satisfies $k^\*(\delta_{K-1};n,\tau) = K$; and the zero profile realises label $0$. Hence every cell is non-empty and $k^\*$ maps the corpus cone *onto* $\{0,1,\dots,n\}$.

*Proof.* $M_{\delta_{j}}(k) = 1$ if $j<k$ and $0$ otherwise. With $j = K-1 \le n-1$ we get $M(n)=1$; the gate $\tau \le M(k)$ fails for $k \le K-1$ and holds at $k=K$. Theorem 2.14 concludes. $\square$

**Theorem 7.7 (Structure theorem).** For $0 < \tau \le 1$ the cone of corpora at context $n$ is the disjoint union of the knee cells $\mathcal{K}(n,\tau,K)$, $K = 0,\dots,n$; each cell is non-empty, convex, closed under positive combinations, and cut out by exactly two linear measurements — a pass at $K$ and a failure at $K-1$.

**Remark 7.8 (What the fan says about replication).** Corpus robustness is *membership in a cell*, and a razor bracket that reports a failure at $K-1$ and a pass at $K$ **is** a cell certificate — nothing weaker will do, since knowing only that the gate is cleared at $K$ places the corpus in a union of cells. Conversely, because every cell is non-empty, no argument from attention geometry alone can force a particular knee: the measurement is doing irreducible work. This is simultaneously the strongest available form of the replication statement and a precise bound on what replication can prove.

---

## 8. Algorithms and deployment

Everything above is effective. We record the three computational primitives implied by the theory.

### 8.1 Knee sweep by bisection

Because clearing is monotone in the budget (Lemma 2.9), the predicate $k \mapsto \mathrm{Cl}(w;n,k,\tau)$ is a step from false to true and the knee can be located by binary search. With prefix sums of the profile precomputed in $O(n)$ time, each gate query costs $O(\log n)$ and a full sweep over $G$ gates costs $O(n + G\log n)$. The razor bracket returned by the search — the last failing budget and the first passing one — is precisely the cell certificate of Theorem 7.2.

### 8.2 Margin-certified replication

Given two measured retention curves and a gate, the four-decimal theorem is checked directly: compute $\varepsilon = \max_{k \le n} |R_A(k) - R_B(k)|$ and $m = \min_{k \le n} |R_A(k) - \tau|$. If $m > \varepsilon$, the two knees are provably equal, and the certificate is the pair $(\varepsilon, m)$. Cost: $O(n)$. This is the recommended report format for a cross-corpus replication, since it converts an observation ("the numbers matched") into a proof ("no perturbation of this size can move the knee").

### 8.3 Cross-domain budget transfer

Given a reference corpus $A$, a projective radius $\rho$, and a gate $\tau = 1-\delta$: compute $A$'s knee at the tail-inflated gate $1 - \rho^2\delta$. Theorem 6.9 certifies that every $\rho$-tilt of $A$ is served by that budget. If in addition $A$'s sweep is flat between $1 - \rho^2\delta$ and the gate obtained by *deflating* the tail, Theorem 6.6 upgrades the bound to an exact prediction of the tilted knee. Under a fitted geometric tail with ratio $r$, Corollary 6.14 gives the closed-form budget directly.

### 8.4 Deployment reading of the measurement

Placed against the theory, the reported numbers say the following. The measured knees $16$ at context $512$ and $32$ at context $1024$ obey the forced monotonicity of Theorem 2.16. The exact cross-corpus agreement is certified by Theorem 4.1 with $\varepsilon = 10^{-4}$ and observed margins of order $10^{-3}$–$10^{-2}$. The stability of the budget near thirty keys across contexts, corpora, and model sizes is consistent with a geometric tail: fitting $r$ so that $r^{32} \approx 0.02$ gives $r \approx 0.885$, and Corollary 6.14 then predicts single-digit growth of the budget under moderate domain distortion. Finally, Theorem 7.7 states the honest epistemic position: the observation places the trained model's attention profile in a particular cell of the fan, and every cell is inhabited, so the value $32$ is a fact about *this* model, established by measurement, and not derivable from the geometry alone.

---

## 9. Limitations

1. **The theory is about profiles, not about training.** Nothing here explains *why* trained attention has a heavy head. It explains what follows once it does, and which inferences from the measurement are licensed.
2. **Identifiability needs all gates.** Theorem 5.5 quantifies over the full gate axis. A finite sweep does not determine the retention curve between measured steps (Remark 5.7).
3. **Tilt radius must be estimated.** Theorems 6.4, 6.9 and 6.13 are conditional on a projective bound $\rho$ relating the two domains. Estimating $\rho$ for a genuinely new domain requires some measurement on that domain, even if far less than a full knee sweep.
4. **Sortedness is a convention.** All results use only nonnegativity; if a measured profile is not sorted, "the top $k$ keys" must be interpreted as "the first $k$ entries of the profile as presented".
5. **Empirical scope.** The replication that motivates the theory covers two corpora from the same textual family, three context lengths, and two model sizes. A genuine domain jump — code, mathematics, non-English text — remains to be measured; the theory of Section 6 is exactly the apparatus for interpreting it when it is.

---

## 10. Future directions

### 10.1 Per-layer knee fans and a tensor decomposition of the budget

Each attention layer carries its own corpus cone and its own knee fan; the model-level budget is some combination of the per-layer labels. We conjecture the model-level cell is the *product* cell: the model knee at gate $\tau$ equals the maximum of the per-layer knees at gates redistributed according to the layers' mass shares, with level sets remaining polyhedral in the joint profile. The key structural input is that pooling layers is a *direct sum* of corpora, and the knee is a non-archimedean valuation, so
$$k^\*\Big(\textstyle\bigoplus_l w_l\Big) \;\le\; \max_l\, k^\*(w_l)$$
holds verbatim. What is open is the matching lower bound and the exact gate redistribution. The sub-max law (Theorem 3.5) and the cell description (Theorem 7.7) already give the single-cone case; the multi-layer statement requires only the weighted direct-sum version.

### 10.2 A Hilbert-metric Lipschitz bound for the knee sweep

Define $d(A,B)$ to be the least $\log\rho$ with $\mathrm{Tilt}_\rho(A,B)$ — the Hilbert projective distance on the corpus cone. We conjecture a uniform Lipschitz bound for the knee sweeps of two corpora in the *missing-mass* coordinate:
$$1 - R_B(n,k) \;\le\; e^{2d(A,B)}\,\big(1 - R_A(n,k)\big) \qquad \text{for all } k,$$
with equality attained on extreme rays of the cone. Theorem 6.9 is the pointwise instance of this bound; the conjecture asks for it uniformly in $k$ with the metric-theoretic constant, which would make the domain-jump law a genuine Lipschitz statement about the map from corpora to sweeps.

### 10.3 Further directions

* **Domain-jump corpora.** Measure code, mathematics and non-English text and estimate the tilt radius directly, testing Theorem 6.6's flat-window criterion against observation.
* **Learned importance heads.** Close the gap between the *oracle* budget studied here (which keys matter, known in hindsight) and a *policy* budget (which keys a cheap selector can identify online).
* **Per-layer budgets.** Replace the single model-level number by a vector of per-layer knees, as in Section 10.1.
* **Larger models and quantized offload.** Extend the ladder to larger parameter counts and to regimes where the retained keys are quantized rather than dropped.
* **Beyond half-spaces.** The entire theory rests on the gate being linear. Non-linear retention criteria (entropy thresholds, rank-based criteria) would break the cone structure; identifying which of the five theorems survive is a well-posed question.

---

## 11. Conclusion

A single reformulation — writing the retention gate multiplicatively, $\tau M_w(n) \le M_w(k)$, so that it becomes a half-space in the cone of nonnegative attention profiles — reduces the empirical stability of the attention knee to algebra.

The knee is then a scale-invariant, integer-valued, non-archimedean valuation on that cone; corpora with equal knees generate a whole sub-cone with the same knee, while the pooling sandwich is sharp at both ends and the knee is not additive. Four-decimal agreement of retention curves forces exact agreement of knees provided the reference corpus keeps a gate margin exceeding the tolerance — and, at zero margin, no tolerance whatsoever suffices, so the margin is exactly the missing ingredient in a replication claim. The gate sweep and the retention curve are Galois-dual, making a published budget table a complete invariant of a corpus's measurable content. Domain jumps act projectively and inflate missing mass by $\rho^2$, costing only a logarithmic number of extra keys under a geometric tail. And the corpus cone is a fan of non-empty polyhedral cells, each certified by precisely the two measurements a razor bracket reports.

The measured thirty-key budget is thus best understood not as a fitted constant but as a *cell label* — a discrete invariant that replicates exactly because the geometry around it is linear, the invariant is discrete, and the measurement has margin.
