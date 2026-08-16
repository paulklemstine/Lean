# Knee Thresholds on Finite Sweep Grids: Robustness Certificates, Seed Fluctuation, and the Collapse of an Exact Product Law into a Two-Seed Bracket

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

Empirical scaling claims in machine-learning systems research are routinely reported as exact equalities read off a finite sweep: "the minimal attention budget that retains $98\%$ of full accuracy is $k^\star = d\cdot\mathrm{ctx}/32$." We give a complete order-theoretic account of what such a claim can and cannot mean, and apply it to a measurement that refutes one.

We define the *knee* of a monotone retained-accuracy curve $c$ on a finite budget grid $G$ against a bar $\mathrm{bar}$ as the least grid point clearing the bar. We prove: (i) the knee is unique when it exists, and any observed passing budget is an upper bound for it — hence a sweep can certify a predicted budget only as an *upper bound*, never as *minimal*; (ii) an exact robustness criterion — the claim $k^\star = k$ survives every monotone perturbation of size $\le \eta$ **iff** $\eta \le c(k) - \mathrm{bar}$ and $\eta < \mathrm{bar} - c(j)$ for every grid point $j < k$, with the asymmetry between $\le$ and $<$ sharp and the necessity direction witnessed by the explicit shifts $c \pm \eta$; (iii) a grid of step $s$ localises the true crossing point only inside a half-open window of width $s$, so one-step knee differences can be manufactured from arbitrarily small changes in the underlying threshold; (iv) the budget certified by an $n$-seed ensemble is exactly $\max_i k^\star_i$, it is the least safe grid budget, it is monotone increasing in the ensemble, and it is precisely the knee of the pointwise-infimum ("worst-case") curve — the knee functional being an order-reversing lattice homomorphism from curves to budgets.

Applying this to a measurement at $(d = 4,\ \mathrm{ctx} = 1024)$: a first seed reports knee $128$, matching $d\cdot\mathrm{ctx}/32$ exactly along a chain of four context doublings; a second seed, with a byte-identical harness, reports knee $96$. The pre-registered prediction $k^\star = 128$ is refuted. We show the first seed's exactness was *seed-lucky*: its margin at $k=96$ is $0.003$, strictly inside the observed inter-seed spread $0.010$, so the robustness criterion already fails on the first seed's own data, and an explicit $0.010$-shift of the seed-1 curve — one reproducing the seed-2 measurements at $64, 96, 128$ to within $0.001$ — has knee $96$. By contrast the seed-1 deficit at $k = 64$ is $0.012 > 0.010$, so the *lower* end is protected. The exact robust content of the two-seed measurement is therefore the bracket $k^\star \in (64, 128]$, which we prove sound and sharp; it converts to a deployable speedup window $[8, 16)$ at $\mathrm{ctx} = 1024$, with the two measured seeds at $8\times$ and $32/3 \approx 10.67\times$. Read through a heavy-tail mechanism in which the least feasible budget is $A\,d\,\mathrm{ctx}/\delta$, the entire effect is a factor $3/4$ in a single fitted tail amplitude, with depth, context and tolerance cancelling.

**Keywords:** knee threshold, sweep grid, robustness certificate, seed variance, order theory, up-sets, lattice homomorphism, attention budget, heavy-tail amplitude, identifiability.

---

## 1. Introduction

### 1.1 The empirical object

Consider a computational system with a tunable resource budget $k \in \mathbb{N}$ and a quality functional that improves with the budget. In the concrete setting motivating this work, the system is a causal transformer whose attention at each position is restricted to the $k$ highest-scoring past positions, and the quality functional is the **retained accuracy**

$$c(k) \;=\; \frac{\text{held-out accuracy at budget } k}{\text{held-out accuracy at full context}},$$

so that $c$ is monotone non-decreasing and reaches $1$ at the full context length. Fix a tolerance in the form of a **bar** $\mathrm{bar} \in (0,1)$ — here $\mathrm{bar} = 0.98$ — and a finite **sweep grid** $G \subset \mathbb{N}$ of budgets that are actually measured.

**The measured object is the knee**: the least grid budget at which the curve reaches the bar. It is the number one deploys, and the number a scaling law predicts.

### 1.2 The claim under test

Across a grid of depths $d$ and context lengths $\mathrm{ctx}$, measured knees had repeatedly landed on the **product law**

$$k^\star \;=\; \frac{d \cdot \mathrm{ctx}}{32}.$$

At $d = 4$ this reads $k^\star = \mathrm{ctx}/8$, and along the context chain $\mathrm{ctx} = 128, 256, 512, 1024$ the measured knees were $16, 32, 64, 128$: four consecutive doublings, exact at every link. The last cell of the chain, $(d = 4, \mathrm{ctx} = 1024)$, had been measured at a single random seed. This work reports and analyses a second seed at that cell, with a pre-registered prediction of $k^\star = 128$.

### 1.3 Contributions

The prediction failed: the second seed's knee is $96$. Our contribution is not the negative datum but the exact theory that surrounds it, all of which is proved rather than estimated:

1. **Threshold calculus** (§3): uniqueness of the knee; the *upper-bound-only* character of sweep evidence; monotone comparison of seeds.
2. **A sharp robustness criterion** (§4): a necessary and sufficient margin condition for a knee claim to survive perturbations of a given size, with explicit counterexample curves in the necessity direction, plus a one-sided criterion for *lower bracket* claims.
3. **Quantisation** (§5): the grid-knee operator, its one-step overshoot bound, and a construction manufacturing one-step fluctuations from $\varepsilon$-differences — together with the disjoint-window argument showing the *observed* fluctuation is nevertheless genuine.
4. **The measurement** (§6): the two knees, the failed prediction, the safe upper bound, the two-seed bracket and the speedup window.
5. **Seed-luck, made precise** (§7): the constructive demonstration that the seed-1 exactness was unprotected, and that the lower bracket end is protected.
6. **Identifiability of a knee law** (§8): rigidity of doubling chains *given the doubling relation*, underdetermination of the chain's next value *given only data*, non-existence of a single-valued law fitting both seeds, soundness and sharpness of the interval-valued law.
7. **Ensemble epistemics and lattice structure** (§9): the certified budget of an $n$-seed ensemble, its monotonicity, a positive exactness certificate from uniform margins, the negative metatheorem that no seed count can certify the broken value, and the identification of the certified budget with the knee of the worst-case curve via an order-reversing lattice homomorphism.
8. **Mechanistic reading** (§10): the knee ratio equals the tail-amplitude ratio; the observed effect is a $3/4$ amplitude slack; feasibility at the law's budget is monotone in the amplitude.

---

## 2. Definitions

Throughout, $G \subset \mathbb{N}$ is a finite non-empty grid, $\mathrm{bar} \in \mathbb{R}$, and $c : \mathbb{N} \to \mathbb{R}$ is a retained-accuracy curve, always assumed monotone non-decreasing where monotonicity is used.

> **Definition 2.1 (Knee).** $k$ is a *knee* of $c$ on $G$ against $\mathrm{bar}$, written $\mathrm{Knee}(G,\mathrm{bar},c,k)$, if
> $$k \in G, \qquad \mathrm{bar} \le c(k), \qquad \text{and} \qquad \forall j \in G,\ \mathrm{bar} \le c(j) \Rightarrow k \le j.$$

That is: $k$ is on the grid, it passes, and it is the least grid point that passes.

> **Definition 2.2 ($\eta$-robust knee).** A knee claim is *$\eta$-robust* if for every monotone $c'$ with $|c'(j) - c(j)| \le \eta$ for all $j \in G$, the value $k$ is still a knee of $c'$.

$\eta$ is intended to be the empirically observed inter-seed spread of the curve. Robustness thus asks: would the reported knee have been reported by any run whose curve lies within observed variation?

> **Definition 2.3 (Grid knee).** For a step $s > 0$ and a *true* (continuous) crossing point $\kappa \ge 0$, the grid knee is
> $$\mathrm{gk}_s(\kappa) \;=\; s \left\lceil \kappa / s \right\rceil,$$
> the least multiple of $s$ at or above $\kappa$.

> **Definition 2.4 (Certified budget of an ensemble).** For a finite non-empty ensemble of seeds indexed by $\iota$ with knees $K : \iota \to \mathbb{N}$, the certified budget is $\mathrm{CB}(K) = \max_i K(i)$.

> **Definition 2.5 (Speedup).** At context length $\mathrm{ctx}$ and budget $k > 0$, $\mathrm{sp}(\mathrm{ctx}, k) = \mathrm{ctx}/k$.

> **Definition 2.6 (Passing set).** $P(G, \mathrm{bar}, c) = \{\,j \in G : \mathrm{bar} \le c(j)\,\}$.

---

## 3. The threshold calculus

> **Theorem 3.1 (Uniqueness).** If $k$ and $k'$ are both knees of $c$ on $G$ against $\mathrm{bar}$, then $k = k'$.

*Proof.* Each is a lower bound for every passing grid point, and each is itself passing, so $k \le k'$ and $k' \le k$. $\square$

> **Theorem 3.2 (Existence).** If some $j \in G$ satisfies $\mathrm{bar} \le c(j)$, then a knee exists.

*Proof.* The passing set $P(G,\mathrm{bar},c)$ is a non-empty finite subset of $\mathbb{N}$; its minimum is a knee. $\square$

Together, 3.1 and 3.2 make the knee a genuine partial function of the sweep: measured once, defined once.

> **Theorem 3.3 (Sweeps certify only upper bounds).** If $k$ is the knee and $j \in G$ satisfies $\mathrm{bar} \le c(j)$, then $k \le j$.

*Proof.* Immediate from the minimality clause of Definition 2.1. $\square$

Theorem 3.3 is trivial and decisive. It says that observing a predicted budget $\hat k$ pass is logically compatible with the true knee being anything $\le \hat k$. **No sweep can ever certify that a predicted value is minimal**; it can only certify that it is sufficient. Every "exact law" reported from a sweep is, at the level of logic, an upper-bound law plus a failure to observe anything smaller passing.

> **Corollary 3.4 (Failing below).** Every grid point strictly below the knee fails the bar: $j \in G$, $j < k$ $\Rightarrow$ $c(j) < \mathrm{bar}$.

> **Theorem 3.5 (Monotone comparison of seeds).** If $c \le c'$ pointwise on $G$, and $k, k'$ are the knees of $c, c'$, then $k' \le k$.

*Proof.* $c'(k) \ge c(k) \ge \mathrm{bar}$, so $k$ is a passing point for $c'$; apply Theorem 3.3 to $c'$. $\square$

Theorem 3.5 is the structural reason a *uniformly higher* seed curve can only move the knee **down**, never up — which is precisely what is observed in §6.

---

## 4. Robustness certificates

We now characterise exactly when a knee measurement is stable against perturbations of a stated size.

> **Theorem 4.1 (Sufficiency).** Let $k \in G$, $\eta \in \mathbb{R}$, and suppose
> $$\eta \le c(k) - \mathrm{bar} \qquad\text{and}\qquad \forall j \in G,\ j < k \Rightarrow \eta < \mathrm{bar} - c(j).$$
> Then the knee claim $k^\star = k$ is $\eta$-robust.

*Proof.* Let $c'$ be monotone with $|c'(j) - c(j)| \le \eta$ on $G$. At $k$: $c'(k) \ge c(k) - \eta \ge \mathrm{bar}$, so $k$ passes. For minimality, suppose $j \in G$ passes for $c'$ but $j < k$. Then $c'(j) \le c(j) + \eta < c(j) + (\mathrm{bar} - c(j)) = \mathrm{bar}$, contradicting $\mathrm{bar} \le c'(j)$. $\square$

> **Theorem 4.2 (Necessity).** Let $c$ be monotone, $\eta \ge 0$, and suppose the knee claim $k^\star = k$ is $\eta$-robust. Then $\eta \le c(k) - \mathrm{bar}$ and $\eta < \mathrm{bar} - c(j)$ for every $j \in G$ with $j < k$.

*Proof.* Both violations are witnessed by explicit uniform shifts, which are monotone and lie exactly at distance $\eta$.
If $\eta > c(k) - \mathrm{bar}$, apply robustness to $c' = c - \eta$: it must have knee $k$, hence $\mathrm{bar} \le c(k) - \eta$, i.e. $\eta \le c(k) - \mathrm{bar}$, a contradiction.
If some $j \in G$ with $j < k$ has $\eta \ge \mathrm{bar} - c(j)$, apply robustness to $c' = c + \eta$: then $c'(j) = c(j) + \eta \ge \mathrm{bar}$, so $j$ passes, so minimality forces $k \le j$, contradicting $j < k$. $\square$

> **Theorem 4.3 (Robustness criterion).** For monotone $c$, $\eta \ge 0$ and $k \in G$:
> $$\text{the claim } k^\star = k \text{ is } \eta\text{-robust} \iff \eta \le c(k) - \mathrm{bar} \ \wedge\ \forall j \in G,\ j<k \Rightarrow \eta < \mathrm{bar} - c(j).$$

The asymmetry between the non-strict inequality at the knee and the strict inequality below it is not a technical artefact: it is forced by the bar being a non-strict threshold ($c(k) \ge \mathrm{bar}$ counts as passing). A curve pushed down to land *exactly* on the bar still passes; a curve pushed up to land exactly on the bar also passes, and that is fatal below the knee.

The criterion has an important practical reading. It expresses stability as an inequality between two quantities that are **both already measured**: the *margin* $c(k) - \mathrm{bar}$ and the *deficits* $\mathrm{bar} - c(j)$ on one hand, and the empirical spread $\eta$ on the other. Knee stability is therefore not a statistical question to be settled by more seeds; it is an arithmetic question settled by the margins of the seeds one already has.

Exact-value claims are two-sided and thus fragile. Bracket claims are one-sided and much more durable:

> **Theorem 4.4 (Robust lower bracket).** Suppose every grid point $j \le b$ misses the bar by more than $\eta$, i.e. $\eta < \mathrm{bar} - c(j)$ for all $j \in G$ with $j \le b$. Then for every $c'$ with $|c'(j) - c(j)| \le \eta$ on $G$ and every knee $k$ of $c'$, we have $b < k$.

*Proof.* If $k \le b$ then $\mathrm{bar} \le c'(k) \le c(k) + \eta < \mathrm{bar}$, a contradiction. $\square$

Note that Theorem 4.4 requires no upper margin at all: the claim "$k^\star > b$" costs strictly less evidence than the claim "$k^\star = k$".

---

## 5. Grid quantisation

A sweep reports multiples of a step $s$. Let $\kappa \ge 0$ be the true crossing point of the underlying continuous curve.

> **Theorem 5.1 (No under-reporting).** For $s > 0$, $\kappa \le \mathrm{gk}_s(\kappa)$.

> **Theorem 5.2 (One-step overshoot).** For $s > 0$ and $\kappa \ge 0$, $\mathrm{gk}_s(\kappa) - \kappa < s$.

*Proof.* $\lceil \kappa/s \rceil < \kappa/s + 1$; multiply by $s > 0$. $\square$

> **Corollary 5.3 (Identification window).** If a step-$s$ sweep reports $q$, then $\kappa \in (q - s,\; q]$.

> **Corollary 5.4 (Resolution limit).** If two true knees produce the same grid knee, they differ by less than $s$. A grid sweep identifies a knee law only up to one step.

Corollary 5.3 has a bracing consequence for reported exactness: a claim "the measured knee equals $d\cdot\mathrm{ctx}/32$ exactly" carries a built-in uncertainty of a full grid step — here $32$, i.e. $25\%$ of the predicted value.

> **Theorem 5.5 (One-step fluctuations can be manufactured).** For every $\varepsilon > 0$ there exist $\kappa_1, \kappa_2 \ge 0$ with $|\kappa_1 - \kappa_2| \le \varepsilon$ such that $\mathrm{gk}_{32}(\kappa_2) = 96$ and $\mathrm{gk}_{32}(\kappa_1) = 128$.

*Proof.* Take $\kappa_2 = 96$ and $\kappa_1 = 96 + \tfrac12\min(\varepsilon, 32)$. Then $\lceil 96/32 \rceil = 3$ gives $96$, while $\lceil \kappa_1/32\rceil = 4$ gives $128$. $\square$

Theorem 5.5 says a one-grid-step knee difference between two runs carries, *a priori*, no information beyond $\varepsilon$-level noise in the underlying threshold. In §8 we show that in the case at hand the difference is nevertheless genuine, because the two identification windows are disjoint.

---

## 6. The measurement

**Harness.** A causal transformer with $d_{\mathrm{model}} = 64$ and $4$ heads, trained for $2000$ optimisation steps on a natural-language corpus with vocabulary $4097$; depth $d = 4$; context $\mathrm{ctx} = 1024$; top-$k$ attention selection at inference with sweep grid
$$G_2 = \{32, 64, 96, 112, 128, 192, 256, 384, 512, 768\},$$
the point $112$ having been added specifically to pin the $(96, 128]$ bracket. The first seed used the same grid without $112$:
$$G_1 = \{32, 64, 96, 128, 192, 256, 384, 512, 768\}.$$
Bar: $\mathrm{bar} = 0.98$ of full retained accuracy. Seed 2: full accuracy $0.1591$ (bar $0.1559$), loss $5.1179$; seed 1: $0.1594$, loss $5.1209$. At $k = 768$ the seed-2 loss reproduces the full-model loss exactly ($5.1179 = 5.1179$) and retained accuracy is $1.000$.

**Data.**

| budget $k$ | 64 | 96 | 112 | 128 | 768 |
|---|---|---|---|---|---|
| retained, seed 1 | 0.968 | 0.977 | (not swept) | 0.986 | 1.000 |
| retained, seed 2 | 0.979 | 0.987 | 0.991 | 0.993 | 1.000 |

Only the swept values enter the theorems; unswept grid points are handled by monotonicity alone. Both records are realisable by explicit monotone step curves, so every statement below has content (it is not vacuously conditioned on impossible data).

> **Theorem 6.1 (Seed-1 knee).** Any monotone $c_1$ with $c_1(64) = 0.968$, $c_1(96) = 0.977$, $c_1(128) = 0.986$ has knee $128$ on $G_1$ against $0.98$.

*Proof.* $c_1(128) = 0.986 \ge 0.98$, so $128$ passes. For minimality: the grid points below $128$ are $32, 64, 96$; monotonicity gives $c_1(32) \le c_1(64) = 0.968$, and $0.968, 0.977 < 0.98$. $\square$

> **Theorem 6.2 (Seed-2 knee).** Any monotone $c_2$ with $c_2(64) = 0.979$, $c_2(96) = 0.987$, $c_2(112) = 0.991$, $c_2(128) = 0.993$ has knee $96$ on $G_2$ against $0.98$.

*Proof.* $0.987 \ge 0.98$; below $96$ the grid points are $32, 64$ with $c_2 \le 0.979 < 0.98$. $\square$

The extra point $112$ matters logically: it passes, and it lies above $96$, so it does not affect the knee — but its presence means the seed-2 measurement *pins* the knee at $96$ rather than leaving a $(96,128]$ ambiguity that a coarser grid would have permitted.

> **Corollary 6.3 (The prediction failed).** No curve satisfying the seed-2 record has knee $128$; by uniqueness (Theorem 3.1) the knee is $96 \ne 128$.

> **Theorem 6.4 (The product law is a proven-safe upper bound).** If $128 \in G$ and $\mathrm{bar} \le c(128)$, then the knee of $c$ is at most $128$.

Both seeds pass at $128$ ($0.986$ and $0.993$), so the law's budget is safe at both. It is simply not minimal at seed 2, where it over-predicts by exactly one quarter of its own value: $96 = 0.75 \cdot 128$ and $128 - 96 = 128/4$.

> **Theorem 6.5 (Two-seed bracket).** Under the two records, both knees lie in the half-open interval $(64, 128]$.

> **Theorem 6.6 (Speedup window).** For any $k \in (64,128]$ and $\mathrm{ctx} = 1024$, $8 \le \mathrm{sp}(1024,k) < 16$. The measured seeds realise $\mathrm{sp}(1024,128) = 8$ and $\mathrm{sp}(1024,96) = 32/3 \approx 10.67$.

*Proof.* $\mathrm{ctx}/k$ is decreasing in $k$; evaluate at the endpoints, noting $k \le 128 \Rightarrow 1024/k \ge 8$ and $k > 64 \Rightarrow 1024/k < 16$. $\square$

The deployable reading: an $8\times$ reduction in attention work is a *guaranteed floor* across seeds; between $8\times$ and $16\times$ is the honest uncertainty window; $10.67\times$ was actually achieved once.

---

## 7. The seed-1 exactness was seed-lucky

Define the **observed inter-seed spread** $\eta = 0.010$, justified by the three swept differences $0.979 - 0.968 = 0.011$, $0.987 - 0.977 = 0.010$, $0.993 - 0.986 = 0.007$.

> **Theorem 7.1 (Seed-1 knee is not robust).** The claim "$k^\star = 128$" for the seed-1 curve is **not** $0.010$-robust.

*Proof.* By Theorem 4.2 (necessity), $0.010$-robustness would require $0.010 < \mathrm{bar} - c_1(96) = 0.98 - 0.977 = 0.003$, which is false. $\square$

The failure is not merely abstract; it is witnessed by a curve that closely matches the actual second seed.

> **Theorem 7.2 (An explicit knee-$96$ perturbation).** There is a monotone $c'$ with $|c'(j) - c_1(j)| \le 0.010$ for all $j$ and with knee $96$ on $G_1$ — namely $c' = c_1 + 0.010$.

*Proof.* $c'$ is monotone and uniformly at distance $0.010$. At $96$: $0.977 + 0.010 = 0.987 \ge 0.98$. Below: $c'(32) \le c'(64) = 0.978 < 0.98$. $\square$

The shifted values $0.978, 0.987, 0.996$ at $64, 96, 128$ reproduce the *actual* seed-2 measurements $0.979, 0.987, 0.993$ to within $0.001$, $0$, and $0.003$ respectively. In other words: the second seed's outcome was, up to a thousandth at two of three points, the generic $\eta$-perturbation of the first seed's curve.

> **Corollary 7.3 (Single-seed data does not determine the knee).** There exist two monotone curves, each within the observed spread of the seed-1 record, with different knees ($128$ and $96$). No inference from a single seed to an exact knee law is valid at this cell.

The mirror statement is the good news:

> **Theorem 7.4 (The lower end of the bracket is robust).** Every monotone $c'$ within $0.010$ of the seed-1 curve on $G_1$ has knee $> 64$.

*Proof.* Apply Theorem 4.4 with $b = 64$: on $G_1$ the points $\le 64$ are $32$ and $64$, and $\mathrm{bar} - c_1(64) = 0.98 - 0.968 = 0.012 > 0.010$, with $c_1(32) \le c_1(64)$. $\square$

The contrast is the substance of the round. Two numbers straddle the spread:

$$\underbrace{0.003}_{\text{margin at } 96} \;<\; \underbrace{0.010}_{\text{spread}} \;<\; \underbrace{0.012}_{\text{deficit at } 64}.$$

The first inequality kills the upper end (the exact value $128$); the second protects the lower end (the claim $k^\star > 64$). Everything about the round's outcome — including that the fluctuation went *down* one step and not two, and that no fluctuation can move it *below* $64$ — is contained in this pair of inequalities, and both were computable from the first seed's data alone, before the second seed was ever run.

---

## 8. Identifiability of a knee law

### 8.1 Doubling chains are rigid, given the relation

> **Theorem 8.1 (Chain rigidity).** If $f : \mathbb{N} \to \mathbb{R}$ satisfies $f(2n) = 2 f(n)$ for all $n$ and $f(128) = 16$, then $f(128 \cdot 2^m) = 16 \cdot 2^m$ for all $m \ge 0$; in particular $f(1024) = 128$.

*Proof.* Induction on $m$: base is the anchor; step uses $128\cdot 2^{m+1} = 2\,(128 \cdot 2^m)$ and the doubling relation. $\square$

This *derives* the pre-registered prediction. But the derivation assumes the relation, and the relation is exactly what was under test.

### 8.2 The data alone determines nothing

> **Theorem 8.2 (Chain extension is underdetermined).** For every $v > 64$ there is a monotone $f$ with $f(128) = 16$, $f(256) = 32$, $f(512) = 64$ and $f(1024) = v$.

*Proof.* Take the step function equal to $16$ on $[0,128]$, $32$ on $(128,256]$, $64$ on $(256,512]$, and $v$ thereafter; monotone since $v > 64$. $\square$

Hence the measured chain — three values plus monotonicity — is consistent with *every* value in the two-seed bracket $(64,128]$ at the last cell, and with much else besides. The elegance of the doubling relation, not the evidence, produced the prediction $128$.

### 8.3 The seeds genuinely differ

> **Theorem 8.3 (Disjoint identification windows).** If a step-$32$ sweep reports $128$ for seed 1 and $96$ for seed 2, then the true crossing points satisfy $\kappa_1 \in (96,128]$, $\kappa_2 \in (64,96]$, and hence $\kappa_2 < \kappa_1$.

*Proof.* Corollary 5.3 twice; the windows $(96,128]$ and $(64,96]$ are disjoint. $\square$

This is what rules out the deflationary reading offered by Theorem 5.5. Quantisation *can* manufacture one-step differences from nothing, but it cannot manufacture *this* one: the reported values place the two true knees in disjoint intervals. The seeds really do have different thresholds, and their union is exactly the announced bracket $(64,128]$.

### 8.4 The correct object is interval-valued

> **Theorem 8.4 (No single-valued exact law).** There is no $L$ that is simultaneously the knee of the seed-1 curve on $G_1$ and of the seed-2 curve on $G_2$.

*Proof.* Uniqueness forces $L = 128$ and $L = 96$. $\square$

> **Theorem 8.5 (Bracket soundness).** Both measured knees satisfy $64 < k \le 128$.

> **Theorem 8.6 (Bracket sharpness).** If a bracket $(\mathrm{lo}, \mathrm{hi}]$ contains both measured knees then $\mathrm{lo} < 96$ and $\mathrm{hi} \ge 128$. Hence, among brackets with endpoints on the sweep grid, $(64,128]$ is the narrowest sound one.

*Proof.* Containment of $96$ forces $\mathrm{lo} < 96$; containment of $128$ forces $\mathrm{hi} \ge 128$; the grid points strictly below $96$ are at most $64$. $\square$

The law, correctly stated, is thus: *at $(d = 4, \mathrm{ctx} = 1024)$ the knee lies in $(64, 128]$, with $d\cdot\mathrm{ctx}/32 = 128$ as a proven-safe upper endpoint.*

---

## 9. Ensembles: what $n$ seeds certify

Let a finite non-empty ensemble of seeds have monotone curves $c_i$ with knees $K(i)$, and recall $\mathrm{CB}(K) = \max_i K(i)$.

> **Theorem 9.1 (The certified budget is safe).** For every seed $i$, $\mathrm{bar} \le c_i(\mathrm{CB}(K))$.

*Proof.* $K(i) \le \mathrm{CB}(K)$ and $c_i$ is monotone, so $c_i(\mathrm{CB}(K)) \ge c_i(K(i)) \ge \mathrm{bar}$. $\square$

> **Theorem 9.2 (And it is the least safe grid budget).** If $b \in G$ and every seed clears the bar at $b$, then $\mathrm{CB}(K) \le b$.

*Proof.* $\mathrm{CB}(K) = K(i_0)$ for some $i_0$; that seed's knee is a lower bound for any of its passing grid points, in particular $b$. $\square$

So the ensemble maximum is *exactly* the deployment point: no sharper guarantee is extractable from the same data. This is the abstract form of "the product law remains a proven-safe upper bound".

> **Theorem 9.3 (Evidence degrades guarantees).** If an ensemble $K$ embeds into a larger ensemble $K'$ (i.e. $K = K' \circ f$ for some $f$), then $\mathrm{CB}(K) \le \mathrm{CB}(K')$.

Adding seeds can only push the certified budget up. A law fitted at one seed is therefore the most optimistic reading a sweep can ever produce — a structural, not psychological, selection effect.

> **Theorem 9.4 (Positive certificate: uniform margins imply exactness).** Let $r$ be a monotone reference curve with knee $k$ whose graph avoids the open $\eta$-collar around the bar at every grid point — i.e. at every $j \in G$ either $r(j) \ge \mathrm{bar} + \eta$ or $r(j) < \mathrm{bar} - \eta$ in the appropriate one-sided sense of Theorem 4.3. Then every seed within $\eta$ of $r$ has the same knee $k$.

*Proof.* This is Theorem 4.1 applied to each seed. $\square$

Exactness of a knee law is therefore *not* intrinsically a luck statement: it is a margin statement, and it is certifiable — when the margins are there.

> **Theorem 9.5 (Disagreement exposes a small margin).** If two curves within $\eta$ of a reference $r$ have different knees, then some grid point below the larger knee has $\mathrm{bar} - r(j) \le \eta$.

*Proof.* Contrapositive of Theorem 9.4. $\square$

Applied to the round: the observed seed-to-seed disagreement is *predicted*, not merely accommodated, by the seed-1 margin $0.003 \le 0.010$.

> **Theorem 9.6 (Negative metatheorem).** If the reference curve misses the bar by at most $\eta$ at some grid point $g$ strictly below its knee $k$, then no ensemble with spread $\eta$ can certify $k^\star = k$: the admissible curve $r + \eta$ has knee at most $g < k$.

> **Corollary 9.7.** No seed count certifies $k^\star = 128$ at $(d = 4, \mathrm{ctx} = 1024)$ at spread $0.010$.

### 9.1 The knee as an order-reversing lattice homomorphism

The certified budget is not a convention; it has an algebraic identity.

> **Theorem 9.8 (Up-set structure).** For monotone $c$, the passing set $P(G,\mathrm{bar},c)$ is an up-set of $G$ (closed upward within $G$), and $k$ is the knee iff $P$ is non-empty with minimum $k$.

A sweep therefore carries exactly the information of an up-set of $G$, and nothing more — a sharp statement of the informational content of a knee measurement.

> **Theorem 9.9 (Homomorphism).** Let $c_1, c_2$ be monotone with knees $k_1, k_2$. Then the pointwise minimum $c_1 \wedge c_2$ has knee $\max(k_1,k_2)$, and the pointwise maximum $c_1 \vee c_2$ has knee $\min(k_1,k_2)$.

*Proof.* $P(c_1 \wedge c_2) = P(c_1) \cap P(c_2)$ and $P(c_1 \vee c_2) = P(c_1) \cup P(c_2)$; the minimum of an intersection of up-sets in a chain is the max of the minima, and of a union is the min of the minima. $\square$

Thus the knee is an order-**reversing** lattice homomorphism $(\text{curves}, \wedge, \vee) \to (\mathbb{N}, \max, \min)$.

> **Theorem 9.10 (Worst case).** For a finite ensemble, the pointwise-infimum curve $\bigwedge_i c_i$ has knee exactly $\mathrm{CB}(K) = \max_i K(i)$; dually the pointwise-supremum curve has knee $\min_i K(i)$.

The budget one certifies *is* the knee of the worst-case curve. At the measured cell the worst-case knee is $128$ and the best-case knee is $96$; the gap is one grid step, and the deployment cost of insisting on the worst case is the over-provisioning ratio

$$\frac{128}{96} = \frac{4}{3}.$$

---

## 10. Mechanistic reading: the knee ratio is an amplitude ratio

A standard model for why a knee exists at all: attention weights at a given position have a heavy (Zipf-like) tail, so the probability mass discarded by keeping only the top $k$ positions is approximately $A \cdot T(\mathrm{ctx}, k)$ for a tail functional $T$ and a fitted **amplitude** $A$; a budget is *feasible* when the total discarded mass across $d$ layers stays under a tolerance $\delta$, i.e. $d \cdot A\, T(\mathrm{ctx},k) \le \delta$. For the relevant tail this makes the least feasible budget

$$\kappa \;=\; \frac{A \, d \, \mathrm{ctx}}{\delta},$$

linear in depth and in context — exactly the shape of the product law, with $1/32$ absorbing $A/\delta$.

> **Theorem 10.1 (Knee ratio = amplitude ratio).** If $\kappa_1 = A_1 d\,\mathrm{ctx}/\delta$ and $\kappa_2 = A_2 d\,\mathrm{ctx}/\delta$ with $\delta, d, \mathrm{ctx}, A_1 > 0$, then $\kappa_2/\kappa_1 = A_2/A_1$.

Depth, context and tolerance cancel identically. The inter-seed fluctuation is therefore a statement about one scalar.

> **Corollary 10.2 (The observed effect is a $3/4$ amplitude slack).** If $128 = A_1 d\,\mathrm{ctx}/\delta$ and $96 = A_2 d\,\mathrm{ctx}/\delta$ then $A_2/A_1 = 3/4$.

The mechanism is intact; only its single fitted constant fluctuated by a quarter.

> **Theorem 10.3 (Feasibility is monotone in the amplitude).** If $A \le A_0$ and the law's budget $k$ satisfies $A_0 d\,\mathrm{ctx}/\delta \le k$, then $d \cdot A\,T(\mathrm{ctx},k) \le \delta$: the budget remains feasible.

This is the mechanistic counterpart of Theorem 6.4: an upper-bound law calibrated at the largest plausible amplitude survives any downward amplitude fluctuation, while an equality law does not survive any fluctuation at all.

---

## 11. Auxiliary empirical results

Two further reproducibility checks accompany the measurement and should be recorded, since they delimit what the round does *not* overturn.

**Selection importance reproduces.** Against a control in which $k$ past positions are chosen uniformly at random rather than by attention score, the accuracy gaps are $+6.2$ points at $k = 64$ and $+4.8$ at $k = 128$ for seed 2, versus $+5.9$ and $+4.6$ for seed 1 — reproducing to about $0.3$ points. Selection, not merely budget, is what makes the knee small; both seeds agree on this by a wide margin relative to the disagreement about the knee's exact location.

**Concentration reproduces; no bounded working set.** The effective number of attended positions is $294.97$ (seed 2) versus $291.16$ (seed 1), a $1.3\%$ discrepancy. Crucially this quantity does *not* saturate at a context-independent constant: there is no bounded working set, and the knee's growth with context is genuine, not an artefact of a fixed small support.

---

## 12. Algorithms

The theory yields three small algorithms which we state for completeness; each is elementary but is exactly what the theorems license.

**A. Knee extraction.** Given a sorted grid $G$ and measurements $c$, return the least $j \in G$ with $c(j) \ge \mathrm{bar}$, or $\bot$. Cost $O(|G|)$ by linear scan; $O(\log|G|)$ by binary search when $c$ is known monotone (justified by Theorem 9.8: the passing set is an up-set, so the predicate is monotone in $j$).

**B. Robustness audit.** Given the extracted knee $k$, compute $m^{+} = c(k) - \mathrm{bar}$ and $m^{-} = \min_{j \in G, j<k} (\mathrm{bar} - c(j))$. The claim is $\eta$-robust exactly for $\eta \le \min(m^{+}, m^{-})$ with the boundary case at $m^{-}$ excluded; equivalently the *robustness radius* is $\min(m^{+}, m^{-})$, attained non-strictly above and strictly below. Report it next to the knee. Cost $O(|G|)$.

**C. Bracket synthesis from an ensemble.** Given knees $k_1,\dots,k_n$ and spread $\eta$: the certified budget is $\max_i k_i$ (Theorems 9.1–9.2); the robust lower bound is the largest grid point $b$ such that every $j \le b$ satisfies $\mathrm{bar} - c_{\mathrm{ref}}(j) > \eta$ (Theorem 4.4); output the bracket $(b, \max_i k_i]$ and the speedup window $[\mathrm{ctx}/\max_i k_i, \mathrm{ctx}/b)$. Cost $O(n|G|)$.

Applied to the data: $\max = 128$, $b = 64$, bracket $(64,128]$, window $[8,16)$.

---

## 13. Discussion

### 13.1 Report the collar, not the point

The central methodological consequence is a one-line change to how knee-type results should be reported. Alongside every reported knee $k^\star$, report its **robustness radius** $\min\big(c(k^\star) - \mathrm{bar},\ \min_{j<k^\star}(\mathrm{bar} - c(j))\big)$ and the empirical spread $\eta$. If the radius is below $\eta$, the exact value is not a result; only the bracket is. Both numbers are already produced by every sweep that exists. In the present case the radius was $0.003$ against a spread of $0.010$ — a factor of three the wrong way — and the fragility was visible before the confirming run.

### 13.2 Why "exact along a chain" is weaker than it looks

Four exact links in a doubling chain feels like overwhelming evidence, but Theorem 8.2 shows that the *data* of the chain (values plus monotonicity) constrains the next cell not at all beyond a lower bound. What did the work was the doubling relation, an assumption. Combined with Theorem 3.3 — sweeps certify only upper bounds — the epistemic position of an "exact chain law" is much weaker than its presentation: each link is an upper-bound observation plus a non-observation of anything smaller passing, and each non-observation is only as strong as its margin.

### 13.3 The asymmetry of brackets

Theorems 4.3 and 4.4 explain why bracket claims are the durable currency. An exact-value claim requires a two-sided margin condition, one side of which (the deficits below the knee) must hold *strictly* and at *every* earlier grid point; a lower-bracket claim requires only the deficits, and an upper-bracket claim requires only a single passing observation. It is no accident that the two surviving claims here — $k^\star > 64$ and $k^\star \le 128$ — are precisely the two one-sided ones.

### 13.4 Practical consequence

Nothing in this round harms deployment. The guaranteed speedup at $(d = 4, \mathrm{ctx} = 1024)$ remains $8\times$; the observed range across seeds is $8\times$ to $10.67\times$; the honest window implied by the bracket is $[8\times, 16\times)$. What changes is the claim's shape: from "the minimal budget is $d\,\mathrm{ctx}/32$" to "$d\,\mathrm{ctx}/32$ is a certified-safe budget, and the minimal budget lies in $(d\,\mathrm{ctx}/64,\ d\,\mathrm{ctx}/32]$". The second statement is weaker, true, and testable.

### 13.5 Scope and limitations

The measurement is at a single small scale ($d_{\mathrm{model}} = 64$, $4$ heads, $2000$ steps, one corpus) and two seeds. Nothing here establishes the product law's behaviour at production scale; what it establishes is a *ceiling on the strength of the inference* that any sweep of this kind can support, and that ceiling is scale-free — it is an order-theoretic fact about thresholds on finite grids. Likewise, the spread $\eta = 0.010$ is itself estimated from two seeds and should be regarded as a lower bound on the true inter-seed variation; a larger $\eta$ only strengthens the negative conclusions and weakens Theorem 7.4's protection of the lower end.

---

## 14. Future work

Several precise, falsifiable questions follow directly.

**The margin–fluctuation law.** Conjecture: across cells of the (depth $\times$ context) grid, the empirical probability that a knee moves by one grid step between seeds is a monotone function of $\eta/m$ alone, where $m = \mathrm{bar} - c(k^{\star-})$ is the deficit at the grid point below the knee, with a sharp transition at $\eta/m = 1$. Theorem 4.3 makes stability an exact inequality between two independently measurable quantities, so knee fluctuation is not noise to be averaged away but a deterministic consequence of a measured collar around the bar. Both quantities are recorded by existing sweeps ($0.003$ and $0.010$ at the broken cell, $0.012 > 0.010$ at the protected one); no new instrumentation is required.

**Adaptive grids collapse the bracket.** Conjecture: replacing the fixed step-$32$ sweep by bisection on the bar crossing yields, for the same compute, a two-seed bracket of width $\le 8$ at this cell, with fine-grained knee ratio $k^\star_2/k^\star_1 \in [0.70, 0.80]$ rather than the coarse $0.75$ forced by the grid. Theorem 5.5 with Corollary 5.3 shows a step-$s$ grid identifies a knee only within a window of width $s$; Theorem 8.3 shows the windows here are disjoint, so the seeds do differ — what is unknown is by how much, and bisection answers it.

**Ensembles and the certified budget's asymptotics.** Theorem 9.3 says $\mathrm{CB}$ is non-decreasing in the ensemble. How fast does it saturate? If the per-seed knee is a quantised sample of a continuous threshold with spread $\eta$, the certified budget should be the grid point just above the upper tail of that distribution, so $\mathrm{CB}$ should stabilise within a few seeds and then jump only when a rare seed crosses a grid boundary. A ten-seed run at this cell would distinguish "stabilises at $128$" from "creeps to $192$".

**Two-axis fluctuation family.** The one-grid-step knee fluctuation has now been observed on both axes — in depth (at a fixed large context) and in context (at fixed depth $4$). Conjecture: the fluctuation probability depends on the cell only through $\eta/m$ (the first conjecture above) and not through which axis was varied.

**Amplitude-first measurement.** Theorem 10.1 reduces the whole inter-seed effect to the ratio of tail amplitudes. Measuring $A$ directly from the attention-weight spectra — a cheap forward-pass statistic requiring no sweep at all — should predict the knee to within a grid step, and predict its seed-to-seed movement without running the sweep twice.

---

## 15. Conclusion

A knee is the least grid point clearing a bar, and everything one can honestly claim about it follows from that definition. A sweep certifies upper bounds, never minimality. An exact knee claim is stable exactly when its margin at the knee is at least the perturbation size and its deficits below the knee strictly exceed it. A grid of step $s$ resolves the true crossing point only to a window of width $s$. An $n$-seed ensemble certifies exactly the maximum of its knees, which is the knee of its worst-case curve, and which can only rise as evidence accumulates.

Against this, the measurement at $(d = 4,\ \mathrm{ctx} = 1024)$: seed 1 gives $128$, matching $d\,\mathrm{ctx}/32$ exactly; seed 2 gives $96$. The first seed's margin at $96$ was $0.003$ against a spread of $0.010$, so its exactness was unprotected, and the generic perturbation of its curve — one that reproduces the second seed's measurements to a thousandth — already moves the knee. Its deficit at $64$ was $0.012$, so the lower end was protected. The result is the bracket $k^\star \in (64,128]$, sound and sharp, worth a deployable speedup window of $[8\times, 16\times)$ with an $8\times$ floor; the product law survives as a proven-safe upper bound that over-predicts by a quarter at the second seed; and the mechanism behind it survives untouched, with the whole effect being a factor $3/4$ in one fitted tail amplitude.

The general lesson is stated in a single inequality: an exact threshold claim is worth precisely as much as $\min(\text{margin}, \text{deficits})$ minus the spread — and that quantity should be printed next to the threshold, every time.
