# The Agreement Geometry of Layer Transplants and the Capacity of Shared Serving

**Author:** Aristotle

**Date:** 2026-08-23

---

## Abstract

We develop a combinatorial theory of *prediction agreement* for models built by splicing components of two or more fine-tunes of a common architecture, and we apply it to a causal layer-transplant measurement on a pair of sibling language models. Modelling a predictor as a function from a finite set of $N$ evaluation positions to a token alphabet, and writing $\mathrm{agr}(f,g)$ for the fraction of positions on which two predictors coincide, we prove that agreement obeys the Hamming triangle inequality $\mathrm{agr}(f,g)+\mathrm{agr}(g,h)\le 1+\mathrm{agr}(f,h)$, which we call the *portability budget*. From it we derive a **both-parents-collapse certificate**: any hybrid $H$ of parents $A,B$ emits tokens agreeing with neither parent on at least $\mathrm{agr}(A,B)-\min\{\mathrm{agr}(H,A),\mathrm{agr}(H,B)\}$ of the positions. The certificate is sharp, and it converts the measured transplant profile — cross-parent baseline $\beta=0.8327$; hybrid agreements $0.5845$ and $0.5443$ after swapping the final two layers — into the hard conclusion that at least $28.84\%$ of positions carry behaviour belonging to neither parent, and hence that the hybrid is provably *not* a position-wise selector between its parents. The matched-width control swapping two middle layers ($0.9635$ with the host) leaves the certificate vacuous, separating the two swap sites. We further prove: (i) a $1$-Lipschitz dose–response principle, which converts the two measured host agreements into a causal separation of the two hybrids by at least $0.3790$ in normalized Hamming distance — more than the parents' own separation of $0.1673$; (ii) a dissociation between cross-entropy cost and top-1 agreement in both directions, with a reverse-Markov localisation theorem forcing at least $11.63\%$ of windows to individually absorb at least $0.2326$ nats of the measured $0.4652$-nat average degradation; and (iii) a complete theory of *shared serving*. For $k$ fine-tunes pairwise agreeing at most $\beta$, a single shared model has mean agreement at most $(1+\beta)/2$; this pairwise ceiling is attained for $k=2$ by an explicit balanced compromise, up to $1/(2N)$. For $k\ge 3$ a multiplicity (Plotkin-type) count yields $kM^2\le M+(k-1)\beta$, whose exact solution is the **serving-capacity curve** $M^{*}(k)=\big(1+\sqrt{1+4k(k-1)\beta}\big)/(2k)$. The two bounds cross exactly at $k(1-\beta)=2$, a sharp phase transition; $\sqrt{\beta}\le M^{*}(k)\le\sqrt{\beta}+1/k$, so $M^{*}(k)\to\sqrt\beta$. At the measured $\beta$ this caps ceiling-efficient serving at eleven fine-tunes. Finally, a defect identity shows that families attaining the multiplicity bound are rigid and **quantised**, with $M=c/k$ and $\beta=c(c-1)/(k(k-1))$ for an integer $c$, and a complete $c$-design realises every such pair — so the extremal serving values are exactly the quantised ones.

**Keywords:** prediction agreement, Hamming geometry, layer transplantation, model merging, Plotkin bound, shared serving capacity, block designs, phase transition.

---

## 1. Introduction

### 1.1 The engineering question

A pretrained transformer is routinely specialised into several descendants: a chat-tuned variant, a code variant, a domain variant. When these descendants must be served concurrently from limited accelerator memory, one would like to store one copy of the weights they can share, plus a small per-model remainder. The question *which parameters are shareable* is usually settled by heuristics (parameter-norm deltas, gradient sensitivity, low-rank residual sizes). It admits, instead, a direct causal test.

Take two fine-tunes $A$ and $B$ of one architecture. Physically overwrite a contiguous block of $A$'s layers with the corresponding block of $B$'s, leaving all other parameters untouched, and evaluate the resulting hybrid $H$ on held-out text. If that block is generic — shareable — the hybrid should behave like $A$. If the block carries $B$'s identity, the hybrid should drift toward $B$. Anything else is informative in a third way.

### 1.2 The measurement

The experiment was performed on a base/instruct pair from the same pretrained family, over twelve held-out windows at context length $512$, with deterministic forward passes and restore-by-construction between arms. Two matched-width arms were run in both directions: a *tail* swap of the last two layers, and a *bulk* control swapping two mid-stack layers. Cross-entropy is reported as change against the unmodified host; agreement is the fraction of positions on which top-1 next-token predictions coincide.

The parents themselves agree at

$$\beta \;=\; 0.8327 ,$$

the **cross-parent baseline**; equivalently their normalized Hamming distance is $1-\beta = 0.1673$.

| arm | $\Delta\mathrm{CE}$ vs host | agreement with base | agreement with instruct |
|---|---|---|---|
| base $\leftarrow$ instruct, tail (final two layers) | $+0.4652$ | $0.5845$ | $0.5443$ |
| base $\leftarrow$ instruct, bulk (mid-stack pair) | $+0.0043$ | $0.9635$ | $0.8385$ |
| instruct $\leftarrow$ base, tail | $+0.5455$ | $0.5887$ | $0.6289$ |
| instruct $\leftarrow$ base, bulk | $-0.0164$ | $0.8459$ | $0.9495$ |

Three pre-registered hypotheses were tested. **P1** ("a tail swap pulls the hybrid toward the donor") was *refuted*: the tail hybrids fall far below the cross-parent baseline against *both* parents. **P2** (direction asymmetry) was confirmed ($+0.4652$ versus $+0.5455$). **P3** (hybrids remain functional, within half a nat) was confirmed. The bulk arm transplants at no measurable cost, and in one direction slightly improves the recipient.

### 1.3 What this paper proves

The purpose of this paper is to establish that the qualitative reading of the table — *the tail is load-bearing but unportable* — is a theorem about agreement geometry rather than an impression about small numbers, and to develop the resulting theory of shared serving to a complete classification of extremal configurations.

Section 2 sets up agreement geometry and proves the portability budget and the both-parents-collapse certificate, with sharpness and an exact realisation of the measured profile. Section 3 develops the cost side: the dissociation between cross-entropy and agreement, the margin-certificate audit, and cost localisation. Section 4 proves the Lipschitz dose–response principle and derives the causal separation of the two swap sites. Section 5 treats shared serving: the pairwise ceiling, its attainment by a balanced compromise, the multiplicity bound, the capacity curve, and the phase transition. Section 6 proves rigidity and quantisation of extremal families and their exact realisation by complete designs. Section 7 discusses scope and limitations, and Section 8 lists open directions.

---

## 2. Agreement geometry

### 2.1 Setting

Throughout, $\Omega$ is a finite nonempty set of *evaluation positions* with $N = |\Omega|$, and $\mathcal Y$ is a finite set of tokens. A **predictor** is a function $f : \Omega \to \mathcal Y$; in the application, $f(x)$ is the top-1 next-token choice at position $x$. All statements below are about arbitrary predictors; the measured numbers enter only through explicit hypotheses.

**Definition 2.1 (agreement, disagreement, novelty).** For predictors $f,g$ put
$$\mathrm{Ag}(f,g)=\{x\in\Omega : f(x)=g(x)\},\qquad \mathrm{Dis}(f,g)=\{x : f(x)\ne g(x)\},$$
$$\mathrm{agr}(f,g)=\frac{|\mathrm{Ag}(f,g)|}{N}, \qquad \mathrm{dis}(f,g)=\frac{|\mathrm{Dis}(f,g)|}{N}=1-\mathrm{agr}(f,g).$$
For a hybrid $H$ and parents $A,B$, the **novelty set** is
$$\mathrm{Nov}(H;A,B)=\{x : H(x)\ne A(x)\ \text{and}\ H(x)\ne B(x)\},\qquad \nu(H;A,B)=\frac{|\mathrm{Nov}(H;A,B)|}{N}.$$

Agreement is symmetric, lies in $[0,1]$, and $\mathrm{dis}$ is the normalized Hamming distance. Novelty is symmetric in $A,B$.

### 2.2 The portability budget

**Theorem 2.2 (Portability budget).** *For all predictors $f,g,h$ on $\Omega$,*
$$\mathrm{agr}(f,g)+\mathrm{agr}(g,h)\ \le\ 1+\mathrm{agr}(f,h).$$

*Proof sketch.* If $f(x)\ne h(x)$ then $f(x)\ne g(x)$ or $g(x)\ne h(x)$, so $\mathrm{Dis}(f,h)\subseteq \mathrm{Dis}(f,g)\cup\mathrm{Dis}(g,h)$ and hence $|\mathrm{Dis}(f,h)|\le|\mathrm{Dis}(f,g)|+|\mathrm{Dis}(g,h)|$. Substituting $|\mathrm{Dis}| = N - |\mathrm{Ag}|$ and dividing by $N$ gives the claim. $\square$

Equivalently, $\mathrm{dis}$ satisfies the triangle inequality: agreement geometry *is* Hamming geometry. Applied with $g=H$ the intermediate point, the budget says that a hybrid's two parental agreements sum to at most $1+\mathrm{agr}(A,B)$. We record the *slack* in this budget as a diagnostic.

**Definition 2.3 (sharing gap).** $\ \mathrm{gap}(H;A,B) := 1+\mathrm{agr}(A,B)-\big(\mathrm{agr}(H,A)+\mathrm{agr}(H,B)\big)$.

By Theorem 2.2, $\mathrm{gap}\ge 0$ always, with equality exactly when the hybrid saturates the budget.

### 2.3 The both-parents-collapse certificate

**Theorem 2.4 (Collapse certificate).** *For all $H,A,B$,*
$$\nu(H;A,B)\ \ge\ \mathrm{agr}(A,B) - \min\{\mathrm{agr}(H,A),\ \mathrm{agr}(H,B)\}.$$

*Proof sketch.* Fix the host side. If $A(x)=B(x)$ then either $H(x)=A(x)$, or $H(x)$ differs from $A(x)$ and hence from $B(x)$ too. Thus $\mathrm{Ag}(A,B)\subseteq \mathrm{Nov}(H;A,B)\cup\mathrm{Ag}(H,A)$, so $|\mathrm{Ag}(A,B)|\le|\mathrm{Nov}(H;A,B)|+|\mathrm{Ag}(H,A)|$; divide by $N$. The donor-side bound follows by exchanging $A$ and $B$, using symmetry of $\nu$. Taking the better of the two bounds gives the minimum. $\square$

The certificate is the precise sense in which falling below the cross-parent baseline on *either* side forces genuinely new behaviour: agreement lost against the consensus of the parents has nowhere to go but into novelty.

**Theorem 2.5 (Sharpness).** *The bound of Theorem 2.4 is attained. On a two-position index set with $A=B$ constant and $H$ differing at exactly one position, $\mathrm{agr}(A,B)-\mathrm{agr}(H,A)=\nu(H;A,B)=\tfrac12$.*

### 2.4 Selectors and the refutation of the transfer hypothesis

**Definition 2.6 (parent selector).** $H$ is a **parent selector** for $(A,B)$ if $H(x)\in\{A(x),B(x)\}$ for every $x$.

A selector is the implicit model behind hypothesis P1: the swap merely decides, position by position, whose behaviour is inherited. Selectors have $\nu=0$, so Theorem 2.4 immediately gives:

**Corollary 2.7.** *If $H$ is a parent selector then $\max\{\mathrm{agr}(H,A),\mathrm{agr}(H,B)\}\ \ge\ \mathrm{agr}(A,B)$.*

That is, a selector must agree with at least one parent at least as often as the parents agree with each other. The measurement violates this decisively.

**Theorem 2.8 (Measured tail arm, base $\leftarrow$ instruct).** *Suppose $\mathrm{agr}(A,B)\ge 0.8327$, $\mathrm{agr}(H,A)\le 0.5845$ and $\mathrm{agr}(H,B)\le 0.5443$. Then*
$$\nu(H;A,B)\ \ge\ 0.2884, \qquad \max\{\mathrm{agr}(H,A),\mathrm{agr}(H,B)\}+0.2482\ \le\ \mathrm{agr}(A,B),$$
*and consequently $H$ is not a parent selector.*

**Theorem 2.9 (Measured tail arm, reverse direction).** *If $\mathrm{agr}(A,B)\ge 0.8327$, $\mathrm{agr}(H,A)\le 0.5887$, $\mathrm{agr}(H,B)\le 0.6289$, then $\nu(H;A,B)\ge 0.2038$ and the better agreement is at least $0.2038$ below the baseline.*

Both follow by substituting the numbers into Theorem 2.4 and Corollary 2.7. The direction asymmetry predicted by earlier work in this line is visible ($0.2884$ versus $0.2038$ of forced novelty) and does not change the verdict.

**Theorem 2.10 (The control does not collapse).** *If $\mathrm{agr}(A,B)\le 0.8327$ and $\mathrm{agr}(H,A)\ge 0.9635$, then $\mathrm{agr}(A,B)-\max\{\mathrm{agr}(H,A),\mathrm{agr}(H,B)\}<0$, so the certificate is vacuous and a selector explanation remains available.*

This is the discriminating fact: the collapse is specific to the swap *site*, not to transplantation as such.

**Theorem 2.11 (The collapse is not arithmetically forced).** *Under the hypotheses of Theorem 2.8, $\mathrm{gap}(H;A,B)\ge 0.7039$.*

The portability budget permitted an agreement sum of $1.8327$; the measurement delivered at most $1.1288$. The tail hybrid leaves more than seventy percent of a unit of budget unused. Had the tail carried portable identity, the numbers had ample room to show it.

### 2.5 Exact realisability of the measured profile

A referee's first question is whether the four measured numbers are jointly realisable, and whether the certificate says more than arithmetic on the realised profile. Both are answered by an explicit construction.

**Theorem 2.12 (Exact realisation).** *Partition $N=10{,}000$ positions into five classes of sizes $5000,\ 3327,\ 845,\ 443,\ 385$ and define three predictors into a three-token alphabet by:*

| class | size | parents | hybrid |
|---|---|---|---|
| 0 | $5000$ | $A=B$ | follows both |
| 1 | $3327$ | $A=B$ | novel |
| 2 | $845$ | $A\ne B$ | follows $A$ |
| 3 | $443$ | $A\ne B$ | follows $B$ |
| 4 | $385$ | $A\ne B$ | novel |

*Then exactly $\mathrm{agr}(A,B)=0.8327$, $\mathrm{agr}(H,A)=0.5845$, $\mathrm{agr}(H,B)=0.5443$, and $\nu(H;A,B)=0.3712$.*

Since $0.3712 > 0.2884 > 0$, the measurement is consistent, the certificate holds with room to spare, and it is non-vacuous on the realised profile.

---

## 3. Cost, agreement, and where damage lives

### 3.1 A margin audit of the transfer prediction

An earlier result in this research line proves a *conditional* transfer statement: if the host and donor prefix representations at a position differ coordinatewise by at most $\varepsilon$, and the donor tail holds its top-1 decision with logit margin greater than $2\varepsilon$, then the spliced model reproduces the donor's decision at that position. Formally, say a position $x$ is **margin-certified** at drift $\varepsilon$ if
$$\forall j\ne d(x):\ u_x(d(x)) - u_x(j) > 2\varepsilon, \qquad \text{and}\qquad \forall j:\ |u_x(j)-v_x(j)|\le\varepsilon,$$
where $u_x$ are the donor tail's scores on its own prefix, $v_x$ its scores on the host prefix, and $d(x)$ the donor's decision.

**Proposition 3.1.** *At a margin-certified position, the hybrid's strict top-1 choice equals the donor's.*

*Proof sketch.* The strict top of $u_x$ leads by more than $2\varepsilon$; a uniform $\varepsilon$-perturbation moves each score by at most $\varepsilon$, hence closes at most $2\varepsilon$ of any gap. So the same index is the strict top of $v_x$, and strict tops are unique. $\square$

Contrapositively, every position at which hybrid and donor disagree is *uncertified*. Lifting to the whole evaluation set:

**Theorem 3.2 (Margin-failure fraction).** *If the hybrid's decisions are strict tops and $\mathrm{agr}(H_{\text{decision}}, d)\le 0.5443$, then the fraction of margin-uncertified positions is at least $0.4557$.*

This is important methodologically. The prior prediction is not falsified *as a theorem*; its hypothesis is falsified *as a fact*. At least $45.57\%$ of positions in the tail regime carry no margin certificate at the observed prefix drift — the final layers operate in a diffuse, low-margin decision regime, which is precisely why their decisions do not travel.

### 3.2 Zero cost does not certify agreement

**Theorem 3.3 (Cost/agreement dissociation).** *For every $t\in(0,\tfrac12)$ there exist strictly positive probability vectors $q_1,q_2$ on two tokens with*
$$\mathrm{CE}(p, q_1) = \mathrm{CE}(p, q_2), \qquad p = (\tfrac12,\tfrac12),$$
*whose top-1 choices are $0$ and $1$ respectively, where $\mathrm{CE}(p,q) = -\sum_i p_i\log q_i$.*

*Proof.* Take $q_1=(\tfrac12+t,\ \tfrac12-t)$ and $q_2=(\tfrac12-t,\ \tfrac12+t)$. Their cross-entropies against the uniform truth are both $-\tfrac12\log(\tfrac12+t)-\tfrac12\log(\tfrac12-t)$. $\square$

Hence $\Delta\mathrm{CE}\approx 0$ — the observed signature of the bulk arm — licenses *no* inference about prediction agreement, and the $0.9635$ agreement measured there is independent evidence rather than a corollary of the free cost. The correct converse controls the cost by a *log-ratio*, not by a cost:

**Theorem 3.4.** *If $|\log q_1(i) - \log q_2(i)|\le\kappa$ for all $i$, then for any probability vector $p$, $|\mathrm{CE}(p,q_1)-\mathrm{CE}(p,q_2)|\le\kappa$.*

*Proof sketch.* Write the difference as $\sum_i p_i(\log q_2(i)-\log q_1(i))$, apply the triangle inequality termwise and $\sum_i p_i = 1$. $\square$

### 3.3 Macroscopic cost is locally concentrated

**Theorem 3.5 (Reverse Markov / cost localisation).** *Let $f:\Omega\to\mathbb{R}$ be a per-window excess with $f(x)\le C$ for all $x$, $C>0$, and mean at least $\Delta$. Then*
$$\frac{\big|\{x : f(x)\ge \Delta/2\}\big|}{N}\ \ge\ \frac{\Delta}{2C}.$$

*Proof sketch.* Split the sum over the heavy set $S=\{f\ge\Delta/2\}$ and its complement. The heavy part contributes at most $|S|\,C$; the light part at most $N\Delta/2$. Since the total is at least $N\Delta$, we get $N\Delta/2\le|S|C$. (For $\Delta\le 0$ the claim is trivial.) $\square$

**Corollary 3.6 (Per-window prediction for the tail arm).** *With the measured mean excess $\Delta=0.4652$ nats and a per-window cap $C=2$ nats, at least $11.63\%$ of the held-out windows individually lose at least $0.2326$ nats.*

This is the falsifiable histogram-level consequence of the verdict: tail-swap damage cannot be an evenly spread infinitesimal.

---

## 4. Dose–response and the causal separation of swap sites

The natural follow-up experiment varies the *dose*: one-layer, two-layer, three-layer swaps. Before running it, one wants to know what shapes of dose–response curve are geometrically possible. The answer is that every statistic in the analysis is $1$-Lipschitz in the hybrid.

**Theorem 4.1 (Lipschitz agreement).** *For predictors $H_1,H_2$ and any fixed $A$,*
$$\big|\mathrm{agr}(H_1,A)-\mathrm{agr}(H_2,A)\big|\ \le\ \mathrm{dis}(H_1,H_2).$$

**Theorem 4.2 (Lipschitz novelty).** *For any fixed pair $A,B$,*
$$\big|\nu(H_1;A,B)-\nu(H_2;A,B)\big|\ \le\ \mathrm{dis}(H_1,H_2).$$

*Proof sketch.* In both cases the symmetric difference of the relevant sets is contained in $\mathrm{Dis}(H_1,H_2)$: changing the hybrid at a single position can change membership in $\mathrm{Ag}(\cdot,A)$ or $\mathrm{Nov}(\cdot;A,B)$ only at that position. $\square$

Run backwards on the measurement, Theorem 4.1 becomes a causal separation of the two swap sites that requires no access to weights.

**Theorem 4.3 (Swap-site separation).** *If $\mathrm{agr}(H_{\mathrm{bulk}},A)\ge 0.9635$ and $\mathrm{agr}(H_{\mathrm{tail}},A)\le 0.5845$, then $\mathrm{dis}(H_{\mathrm{bulk}},H_{\mathrm{tail}})\ge 0.3790$.*

**Corollary 4.4.** *Under the additional hypothesis $\mathrm{agr}(A,B)\ge 0.8327$, one has $\mathrm{dis}(A,B) < \mathrm{dis}(H_{\mathrm{bulk}},H_{\mathrm{tail}})$: the two transplants of the same parent pair are further from each other ($\ge 0.3790$) than the two parents are ($0.1673$).*

Transplantation moves a model further, in behaviour space, than the fine-tuning that created the parents did.

---

## 5. Shared serving: ceiling, attainment, and capacity

### 5.1 The pairwise ceiling

The practical claim under test — *share everything except the last two layers* — becomes quantitative once we ask how much agreement any single shared model can retain with a family of fine-tunes.

**Theorem 5.1 (Pairwise ceiling).** *Let $A_1,\dots,A_k$ ($k\ge2$) be predictors with $\mathrm{agr}(A_i,A_j)\le\beta$ for all $i\ne j$. Then for any predictor $H$,*
$$\sum_{i=1}^k \mathrm{agr}(H,A_i)\ \le\ \frac{k(1+\beta)}{2}, \qquad\text{i.e.}\qquad M:=\frac1k\sum_{i=1}^k \mathrm{agr}(H,A_i)\ \le\ \frac{1+\beta}{2}.$$

*Proof sketch.* By Theorem 2.2, $\mathrm{agr}(H,A_i)+\mathrm{agr}(H,A_j)\le 1+\beta$ for each ordered pair $i\ne j$. Summing over all $k(k-1)$ ordered pairs, the left side equals $2(k-1)\sum_i \mathrm{agr}(H,A_i)$ and the right equals $k(k-1)(1+\beta)$; divide by $2(k-1)>0$. $\square$

Note the bound is independent of $k$: it is a pure pairwise obstruction.

**Where the measured arms sit.** With $\beta=0.8327$:

**Theorem 5.2.** *If $\mathrm{agr}(H,A)\ge0.9635$ and $\mathrm{agr}(H,B)\ge0.8385$, then $0\le\mathrm{gap}(H;A,B)\le 0.0307$: the bulk transplant is within three percentage points of the geometric optimum for a shared model.*

**Theorem 5.3.** *Combining with Theorem 2.11: on the same held-out set and the same parent pair,*
$$22\cdot \mathrm{gap}(H_{\mathrm{bulk}};A,B)\ \le\ \mathrm{gap}(H_{\mathrm{tail}};A,B).$$

The tail transplant wastes at least twenty-two times as much of the sharing budget as the bulk transplant. This is the quantitative content of the sharing boundary.

### 5.2 The ceiling is attained — by a balanced compromise

A ceiling matters only if attainable, and attainable by something one would want to serve. Serving the host itself attains the *sum* trivially and uselessly. The useful statement is:

**Theorem 5.4 (Balanced attainment).** *For any parents $A,B$ on a nonempty $\Omega$ there exists a shared model $H$ with*
$$\mathrm{agr}(H,A)+\mathrm{agr}(H,B) = 1+\mathrm{agr}(A,B) \qquad\text{and}\qquad \big|\mathrm{agr}(H,A)-\mathrm{agr}(H,B)\big|\le \frac1N .$$

*Proof sketch.* Let $D=\mathrm{Dis}(A,B)$ and choose $S\subseteq D$ with $|S|=\lfloor |D|/2\rfloor$. Define $H = B$ on $S$ and $H=A$ off $S$. Then $\mathrm{Dis}(H,A)=S$ and $\mathrm{Dis}(H,B)=D\setminus S$, so
$$|\mathrm{Ag}(H,A)|+|\mathrm{Ag}(H,B)| = (N-|S|)+(N-|D|+|S|)=N+|\mathrm{Ag}(A,B)|,$$
which is the equality after dividing by $N$. The two agreement counts differ by $|D|-2|S|\in\{0,1\}$, giving the balance bound. $\square$

**Theorem 5.5 (Optimal balanced sharing).** *There exists $H$ with*
$$\min\{\mathrm{agr}(H,A),\mathrm{agr}(H,B)\}\ \ge\ \frac{1+\mathrm{agr}(A,B)}{2}-\frac{1}{2N},$$
*and for every predictor $K$, $\min\{\mathrm{agr}(K,A),\mathrm{agr}(K,B)\}\le \frac{1+\mathrm{agr}(A,B)}{2}$.*

So the worst-case sharing value of a fine-tune pair is exactly $(1+\beta)/2$, to within one position. Perfect sharing is possible only to the extent that the pair itself agrees.

**Theorem 5.6 (What the tail swap forfeits).** *If $\mathrm{agr}(A,B)\ge0.8327$ and the tail hybrid satisfies $\mathrm{agr}(H_{\mathrm{tail}},B)\le0.5443$, then there is a shared model $H$ with*
$$\min\{\mathrm{agr}(H,A),\mathrm{agr}(H,B)\}-\min\{\mathrm{agr}(H_{\mathrm{tail}},A),\mathrm{agr}(H_{\mathrm{tail}},B)\}\ \ge\ 0.372-\frac{1}{2N}.$$

A deliberately balanced shared model holds $0.9163$ with *both* fine-tunes at once; the tail hybrid holds at most $0.5443$ with its donor. The transplant gives away more than $0.37$ of achievable simultaneous agreement. Measured in *mean* agreement across the two parents — half the sharing gap — the bulk transplant reaches $0.9010$, within $0.0154$ of the optimum $0.9163$, whereas the tail transplant reaches only $0.5644$.

### 5.3 More than two fine-tunes: the multiplicity bound

For $k\ge3$ the pairwise ceiling is no longer the whole story. Let $n(x) = \#\{i : H(x)=A_i(x)\}$ be the number of fine-tunes the shared model matches at position $x$. Two fine-tunes matched at a common position necessarily agree there, so the pairwise budget bites on $\sum_x n(x)^2$.

**Theorem 5.7 (Multiplicity / Plotkin-type bound).** *With $s=\sum_i \mathrm{agr}(H,A_i)$ and pairwise agreement at most $\beta$,*
$$s^2\ \le\ s + k(k-1)\beta, \qquad\text{equivalently}\qquad kM^2\ \le\ M+(k-1)\beta .$$

*Proof sketch.* Double counting gives $\sum_{x} n(x) = \sum_i |\mathrm{Ag}(H,A_i)| = sN$ and $\sum_x n(x)^2 = \sum_{i,j}|\mathrm{Ag}(H,A_i)\cap \mathrm{Ag}(H,A_j)|$. The diagonal terms contribute $sN$; each off-diagonal term is at most $|\mathrm{Ag}(A_i,A_j)|\le\beta N$, since a position matched by $H$ for both $i$ and $j$ is a position where $A_i$ and $A_j$ agree. Hence $\sum_x n(x)^2\le sN+k(k-1)\beta N$. Cauchy–Schwarz gives $\big(\sum_x n(x)\big)^2\le N\sum_x n(x)^2$, i.e. $s^2N^2\le N\big(sN+k(k-1)\beta N\big)$. Divide by $N^2$. $\square$

Unlike the ceiling, this bound depends on $k$, and the two interact.

**Theorem 5.8 (Strict decay above threshold).** *If $k(1-\beta)>2$ then every shared model has $M<(1+\beta)/2$ strictly: the pairwise ceiling becomes unreachable.*

**Theorem 5.9 (Capacity bound).** *If a family of $k$ fine-tunes is served at the ceiling, i.e. $M\ge(1+\beta)/2$, then $k(1-\beta)\le 2$, that is, $k\le 2/(1-\beta)$.*

**Theorem 5.10 (Sharpness of the threshold: the hub family).** *For every $k\ge2$ there are $k$ predictors on a $k$-position index set with pairwise agreement exactly $\beta=1-2/k$ — so $k(1-\beta)=2$ — and a shared model whose agreement with each of them equals $(1+\beta)/2 = 1-1/k$ exactly.*

*Construction.* Positions $\{1,\dots,k\}$, tokens $\{0,1\}$; let $A_i$ be the indicator of $\{i\}$ and let $H\equiv 0$. Then $A_i$ and $A_j$ differ at exactly the two positions $i,j$, so $\mathrm{agr}(A_i,A_j)=1-2/k$; and $H$ differs from $A_i$ only at position $i$, so $\mathrm{agr}(H,A_i)=1-1/k$. $\square$

**The measured instance.** At $\beta=0.8327$, $2/(1-\beta)=11.95\ldots$, so:

* at most **eleven** fine-tunes can be served at the pairwise ceiling;
* twelve already break it: any shared model for twelve such fine-tunes has $M<0.91635$;
* a hundred such fine-tunes force $M\le 0.913$.

### 5.4 The serving-capacity curve

Theorem 5.7 is a quadratic inequality, not yet a number. Solving it gives a closed form.

**Definition 5.11.** The **serving-capacity curve** is the positive root of $kx^2-x-(k-1)\beta$:
$$M^{*}(k,\beta)\ :=\ \frac{1+\sqrt{1+4k(k-1)\beta}}{2k}.$$

**Theorem 5.12 (Exact solution).** *For $k\ge2$ and pairwise agreement at most $\beta$, every shared model satisfies $M\le M^{*}(k,\beta)$.*

**Theorem 5.13 (Attainment).** *At the threshold budget $\beta=1-2/k$ one has $M^{*}(k,\beta)=1-1/k=(1+\beta)/2$, and the hub family of Theorem 5.10 realises it exactly. Hence the curve cannot be lowered at the threshold.*

**Theorem 5.14 (Exact crossing / phase transition).** *For $k\ge1$ and $0\le\beta$:*
* *if $k(1-\beta)\ge 2$ then $M^{*}(k,\beta)\le (1+\beta)/2$, with strict inequality when $k(1-\beta)>2$;*
* *if $\beta<1$ and $k(1-\beta)<2$ then $(1+\beta)/2 < M^{*}(k,\beta)$.*

*Proof sketch.* Both cases reduce, after clearing the square root, to the sign of the product $\big(k(1-\beta)\big)\big(k(1-\beta)-2\big)$. $\square$

So the "phase transition" of Section 5.3 is precisely the crossing point of two independent bounds, and each bound is the operative one on its own side of $k(1-\beta)=2$.

**Theorem 5.15 (Sandwich and limit).** *For $k\ge1$ and $0\le\beta\le1$,*
$$\sqrt\beta\ \le\ M^{*}(k,\beta)\ \le\ \sqrt\beta+\frac1k, \qquad\text{hence}\qquad \lim_{k\to\infty}M^{*}(k,\beta)=\sqrt\beta .$$

*Proof sketch.* Both inequalities follow from squaring: with $\sigma=\sqrt\beta$, one checks $\big(2k\sigma-1\big)^2\le 1+4k(k-1)\beta \le \big(2k\sigma+1\big)^2$ using $k\sigma(1-\sigma)\ge0$. $\square$

The asymptotic serving value is the **geometric** mean of the pairwise budget, strictly below the arithmetic ceiling $(1+\beta)/2$ for $\beta<1$ (by AM–GM). At $\beta=0.8327$ the asymptote is $\sqrt\beta = 0.91252\ldots$, and the exact curve gives sharpened numbers: $M\le0.91634$ at $k=12$ and $M\le0.91297$ at $k=100$.

---

## 6. Rigidity, quantisation, and complete designs

### 6.1 The defect identity

The proof of Theorem 5.7 used two inequalities: Cauchy–Schwarz on $n(\cdot)$, and the pairwise budget on off-diagonal overlaps. Both defects can be made exact.

**Definition 6.1.** With $n(x)$ as above, set
$$\mathrm{spread}\ :=\ \tfrac12\sum_{x\in\Omega}\sum_{y\in\Omega}\big(n(x)-n(y)\big)^2, \qquad \mathrm{pairOverlap}\ :=\ \sum_{i\ne j}\big|\mathrm{Ag}(H,A_i)\cap \mathrm{Ag}(H,A_j)\big| .$$

**Theorem 6.2 (Defect identity).** *For all $H$, $(A_i)$, and $\beta$,*
$$N^2\Big(s^2-s-k(k-1)\beta\Big)\ =\ -\,\mathrm{spread}\ -\ N\Big(k(k-1)\beta N-\mathrm{pairOverlap}\Big).$$

Both subtracted terms are nonnegative — the first by the elementary identity behind Cauchy–Schwarz, the second by the pairwise budget — which reproves Theorem 5.7 and shows that equality holds **iff both vanish**.

**Definition 6.3.** A pair $(H,(A_i))$ **saturates** at budget $\beta$ if $s^2 = s + k(k-1)\beta$.

### 6.2 Hub rigidity

**Theorem 6.4 (Constant multiplicity).** *If $(H,(A_i))$ saturates, then $n(x)=n(y)$ for all positions $x,y$: the shared model matches exactly the same number of fine-tunes everywhere.*

**Theorem 6.5 (Pairwise tightness).** *If $(H,(A_i))$ saturates, then for every $i\ne j$,*
$$\mathrm{agr}(A_i,A_j)=\beta \qquad\text{and}\qquad \mathrm{Ag}(H,A_i)\cap \mathrm{Ag}(H,A_j)=\mathrm{Ag}(A_i,A_j).$$

The second condition says that two fine-tunes agree *only* where the shared model matches both. Together these are the hub geometry: the shared model is the consensus, and the fine-tunes' deviations from it overlap as little as the budget allows.

### 6.3 Quantisation

**Theorem 6.6 (Quantisation of extremal values).** *If $(H,(A_i))$ saturates at budget $\beta$ with $k\ge2$, then there is an integer $c\le k$ with*
$$M=\frac{c}{k}, \qquad \beta=\frac{c(c-1)}{k(k-1)} .$$

*Proof sketch.* By Theorem 6.4 the matched count is a constant $c$; double counting $\sum_x n(x)=sN$ gives $s=c$, hence $M=c/k$. Substituting $s=c$ into the saturation equation $s^2=s+k(k-1)\beta$ yields $\beta = c(c-1)/(k(k-1))$. Clearly $c\le k$. $\square$

Extremal shared-serving values are therefore *quantised*: only a finite ladder of $(\beta,M)$ pairs can be extremal for a given $k$. The hub family of Theorem 5.10 is exactly the case $c=k-1$, since $(k-1)(k-2)/(k(k-1)) = 1-2/k$ and $(k-1)/k = 1-1/k$.

**Corollary 6.7 (No irrational extremal budget).** *If $\beta$ is irrational, no family of $k\ge2$ fine-tunes with pairwise agreement at most $\beta$ saturates at $\beta$.*

**Corollary 6.8 (The measured budget is not extremal at twelve).** *No family of twelve fine-tunes saturates at $\beta=0.8327$: the required $c$ would have to satisfy $c(c-1)/132 = 0.8327$, which has no integer solution.*

### 6.4 The converse: complete designs realise every quantised pair

Theorem 6.6 is a necessary condition. It is also sufficient — the classification is exact.

**Theorem 6.9 (Complete $c$-designs).** *Let $2\le c\le k$. Take the position set to be the family of all $c$-element subsets $S\subseteq\{1,\dots,k\}$, so $N=\binom{k}{c}$. Let fine-tune $i$ predict a neutral token $0$ at position $S$ when $i\in S$, and its own private token $i+1$ otherwise; let the shared model predict the neutral token everywhere. Then*
$$\mathrm{agr}(H,A_i)=\frac{\binom{k-1}{c-1}}{\binom{k}{c}}=\frac{c}{k}, \qquad \mathrm{agr}(A_i,A_j)=\frac{\binom{k-2}{c-2}}{\binom{k}{c}}=\frac{c(c-1)}{k(k-1)} \quad (i\ne j),$$
*and the family saturates at $\beta=c(c-1)/(k(k-1))$ with $M=c/k$.*

*Proof sketch.* The shared model matches fine-tune $i$ exactly at the blocks containing $i$, of which there are $\binom{k-1}{c-1}$; two distinct fine-tunes both predict the neutral token exactly at the blocks containing both, of which there are $\binom{k-2}{c-2}$, and they never agree elsewhere because their private tokens are distinct. Substituting into $s^2 = s + k(k-1)\beta$ with $s=c$ verifies saturation. $\square$

**Theorem 6.10 (Exact classification).** *For $k\ge2$, a pair $(\beta,M)$ is realised by a family attaining the multiplicity bound if and only if $(\beta,M)=\big(c(c-1)/(k(k-1)),\ c/k\big)$ for some integer $2\le c\le k$.*

**Theorem 6.11 (Designs sit on the capacity curve).** *At a quantised budget the capacity curve takes the quantised value:*
$$M^{*}\Big(k,\ \frac{c(c-1)}{k(k-1)}\Big) = \frac{c}{k},$$
*and the complete $c$-design attains it.*

*Proof sketch.* The discriminant becomes $1+4k(k-1)\cdot\frac{c(c-1)}{k(k-1)} = (2c-1)^2$, a perfect square; the root is $(1+(2c-1))/(2k)=c/k$. $\square$

The whole extremal set of the shared-serving problem is thereby pinned down: the capacity curve is attained precisely at the quantised budgets, and precisely by complete-design geometry. A question about accelerator memory has become a question about block designs.

---

## 7. Discussion

### 7.1 What the measurement establishes

The transplant table is not merely a set of low numbers. Three independent things are established.

1. **A refutation with a certificate.** The hypothesis that a transplanted tail imports donor behaviour is not just unsupported; the measured agreements force at least $28.84\%$ of positions to carry behaviour that belongs to neither parent, and rule out any position-wise selector explanation. The tail carries no portable identity — it is entangled with upstream statistics.

2. **A control that separates sites.** The matched-width bulk arm is consistent with a selector, sits within $0.0307$ of the shared-serving optimum, and transplants at essentially zero cost (one direction slightly improves the recipient). The tail arm wastes at least $22\times$ as much of the sharing budget. The sharing boundary is thereby causally established rather than inferred from parameter statistics.

3. **A dose–response geometry.** Because all statistics are $1$-Lipschitz, the measured agreements bound how far apart the two hybrids must be: at least $0.3790$, exceeding the parents' own separation $0.1673$.

### 7.2 Practical guidance

For multi-fine-tune serving on constrained memory: **share everything except the last two layers; re-run the tail per model; do not approximate or borrow it.** Additionally:

* Do not infer agreement from cost. The two are dissociable in both directions (Theorems 3.3–3.4).
* Expect localised, not diffuse, damage from a bad splice (Corollary 3.6).
* Budget capacity in advance: with fine-tunes as similar as this pair, one shared model serves at most eleven at the pairwise ceiling, and thereafter the mean agreement decays along $M^{*}(k,\beta)$ toward $\sqrt\beta$.

### 7.3 Scope and limitations

The geometric results are unconditional statements about functions on a finite index set and hold for any predictors whatsoever; they do not depend on architecture. The *empirical* inputs are narrower and should be described as such: a single fine-tune pair; twelve held-out windows at context length $512$; half-precision forwards; layer-pair granularity. The chunked cross-entropy accounting matches the evaluation harness semantics, forwards are deterministic, and each arm restores the host by construction before running. No training is involved, so no optimisation confounds arise. The direction asymmetry ($+0.4652$ versus $+0.5455$) is consistent with a mid-stack sensitivity profile identified in earlier work in this line, but a single pair cannot establish that profile.

The distinctive contribution relative to the layer-amputation and model-merging literature is the *fine-tune-pair portability asymmetry at matched architecture*, together with the **both-parents-collapse signature** and its certificate: a transplant can fail not by reverting to the host and not by converting to the donor, but by leaving the segment joining them.

### 7.4 Relation to coding theory

Theorem 5.7 is a Plotkin-type bound: it says that $k$ codewords with pairwise distance at least $1-\beta$ cannot all be simultaneously close to a common centre, and the proof is the classical second-moment argument. What is new here is the *exact* solution of the resulting quadratic (Theorem 5.12), the identification of the crossing with the triangle-inequality bound as a genuine phase transition (Theorem 5.14), the defect identity (Theorem 6.2) and the resulting rigidity, and the exact classification of extremal configurations by complete designs (Theorem 6.10). The appearance of $\binom{k}{c}$-block designs as the unique extremal geometry is the combinatorial heart of the shared-serving problem.

---

## 8. Future directions

* **Dose–response.** One-layer and three-layer swaps, to trace the curve whose Lipschitz envelope Section 4 supplies. The prediction: agreement collapse should be superlinear in the number of tail layers moved, and the Lipschitz bound gives the maximal admissible slope.
* **Swap plus recalibration.** How much of the tail's damage survives a cheap post-splice recalibration? This measures *entanglement depth*, i.e. how far upstream the tail's dependence reaches.
* **Scale.** A $1.5$B parameter pair, to test whether the boundary stays at exactly two layers or scales with depth.
* **Quantised tails.** Does a compensated $4$-bit tail remain personal, or does quantisation destroy the very statistics that make it unportable?
* **Below the threshold.** Theorem 5.14 shows the pairwise ceiling is the operative bound for $k(1-\beta)<2$, but attainability there is only known at the endpoint. Which $(\beta,M)$ below the threshold are achievable?
* **Approximate rigidity.** Theorems 6.4–6.5 are exact-equality statements. A stability version — near-saturation forces near-constant multiplicity — would make the quantisation usable on measured, noisy data.
* **Designs beyond completeness.** Theorem 6.9 uses complete $c$-designs, with $N=\binom{k}{c}$ positions. Which incomplete designs (e.g. balanced incomplete block designs) also saturate, and what is the minimum $N$ realising a given quantised pair?

---

## 9. Conclusion

Prediction agreement between models is Hamming geometry, and Hamming geometry is unforgiving. A hybrid cannot be near two distant parents; agreement lost against the parents' consensus must reappear as novelty; and a shared model serving many fine-tunes is limited first by a triangle-inequality ceiling and then, past a sharp threshold, by a multiplicity bound whose exact solution decays to the geometric mean of the pairwise budget. Against this backdrop the transplant measurement reads cleanly: the middle of the stack is common property, transplantable at no measurable cost and within three percentage points of the theoretical optimum for shared serving; the last two layers are load-bearing, and moving them produces a model that is a stranger to both parents on more than a quarter of its predictions. The tail is where a fine-tune's identity lives, and identity is precisely the part that cannot be lent.
