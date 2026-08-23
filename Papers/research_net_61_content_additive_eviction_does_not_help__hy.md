# The Additive-Hybrid Eviction Law

## Monotone degradation, a universal oracle bound, and a factor-$B$ online separation for cheap cache-eviction signals

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We study the combinatorics of *budgeted selection under a cheap surrogate score*, the abstraction underlying cache eviction in memory-limited systems. Given $n$ items with unobservable true values $v : \iota \to \mathbb{R}$, a budget $B$, and an observable score $s$, the policy retains a *top set*: a $B$-element set no member of which is outscored by a discarded item. We analyse the additive hybrid family $s_\lambda = a + \lambda p$, where $a$ is an accumulated-usage signal and $p$ a static content probe, and establish four results.

First, an **exchange kernel**: for equicardinal sets $S, T$, if every element of $T \setminus S$ has value at most every element of $S \setminus T$, then $S$ retains at least as much as $T$. The proof requires no matching argument — pairwise domination between the two halves of the symmetric difference suffices, because equal cardinality of the whole sets forces equal cardinality of the halves.

Second, a **universal oracle bound**: for *every* score function whatsoever, the retained value of its top-$B$ set is at most that of the oracle's top-$B$ set. The proof inspects no property of the score, so no enrichment of a cheap-signal family — accumulation, recency, content probing, or any linear combination — can cross the oracle line; the size of the gap is a property of the instance.

Third, a **single-crossing lemma** for the additive family: raising $\lambda$ can only exchange items in the direction of the probe, so each unordered pair crosses at most once. This yields a **monotone-degradation law**: if the probe is anti-aligned with true value, retained value is antitone in $\lambda$ (strictly, under strict anti-alignment and an actual change of kept set), hence $\lambda = 0$ is optimal. The sweep is a monotone trade-off path: probe mass non-decreasing, usage mass non-increasing. We show the anti-alignment hypothesis is not removable by exhibiting a two-item instance in which a positive weight strictly helps, and we show that z-score normalisation is an increasing reparametrisation of the same one-parameter family and therefore changes nothing.

Fourth, a **sequential lower bound**: in the demand-paging model on $B + 1$ live items, an adaptive adversary forces *any* deterministic eviction rule to fault on every request, while an offline schedule for the same stream faults at most $\lceil m/B \rceil$ times. The additive-hybrid evictor is such a rule for every $\lambda$, so no probe weight escapes the factor-$B$ worst case.

A four-item instance calibrated to measured data realises a uniform gap of exactly $0.0570$ between every non-negative-$\lambda$ hybrid ($0.9384$ retained) and the oracle ($0.9954$) at budget $B = 2$. Budget monotonicity — retained value non-decreasing in $B$ for non-negative values — is the only provably helpful knob in the model.

**Keywords:** cache eviction, budgeted selection, exchange argument, single crossing, monotone comparative statics, competitive analysis, demand paging, oracle gap.

---

## 1. Introduction

### 1.1 Motivation

A memory-limited system must repeatedly answer the question: *which of the items I currently hold should I discard?* The optimal answer requires knowledge of future demand, which is by construction unavailable. Practical policies therefore substitute a **cheap signal** — a computable statistic correlated, one hopes, with future usefulness. Two families dominate practice:

- **Accumulated-usage signals.** A running total of how heavily an item has been used. In transformer attention caches this is the accumulated attention mass, the basis of "heavy hitter" retention policies; in classical paging it is a frequency counter.
- **Static content signals.** A score computed from the item's content by a small predictor, independent of usage history — in the language-model setting, a linear probe on the item's representation.

When one family underperforms, the natural engineering response is to fuse: score each item by
$$
s_\lambda(i) \;=\; a(i) \;+\; \lambda\, p(i),
$$
standardise the two components, sweep the weight $\lambda$, and keep the best arm. This paper asks what such a sweep can possibly achieve, and answers: much less than one would hope, for reasons that are combinatorial rather than empirical.

### 1.2 The measurement that motivates the theory

The theory below was written to explain a measured sweep. On a small autoregressive language model with a $1024$-token context, retaining $B$ cache slots by the z-scored additive hybrid $z(a) + \lambda \cdot z(p)$ and measuring the fraction of true value retained:

| $B$ | $\lambda$ | retained |
|---|---|---|
| 64 | 0.00 | **0.9384** |
| 64 | 0.25 | 0.9383 |
| 64 | 1.00 | 0.9365 |
| 64 | 4.00 | 0.9344 |
| 32 | 1.00 | 0.9189 |
| 128 | 1.00 | 0.9544 |

Three hypotheses had been registered in advance:

- **(P1)** Some $\lambda > 0$ beats $\lambda = 0$. — **Refuted.** The response is monotonically decreasing in probe weight.
- **(P2)** $\lambda = 0$ is optimal. — **Confirmed.**
- **(P3)** The best hybrid still trails the oracle at matched budget by a wide margin. — **Confirmed**, by $5.7$ points.

The purpose of this paper is to show that all three outcomes are consequences of the *shape* of the additive family and of the geometry of budgeted selection, and hence are not artefacts of one model, one corpus, or one probe.

### 1.3 Contributions and organisation

Section 2 fixes the static model. Section 3 proves the exchange kernel, the technical core. Section 4 derives the universal oracle bound. Section 5 proves single crossing and the monotone-degradation law, with the trade-off path and the optimality of $\lambda = 0$. Section 6 establishes invariance under z-scoring and inertness of constant probes. Section 7 gives determinism of strictly ordered arms and the calibrated four-item instance realising the $5.7$-point gap. Section 8 gives the sharpness counterexample. Section 9 treats budget monotonicity. Section 10 develops the sequential demand-paging model, the offline upper bound, the adaptive-adversary lower bound, and their factor-$B$ combination, specialised to the hybrid family. Section 11 gives algorithms and complexity. Section 12 discusses scope, limitations and future directions.

---

## 2. The static model

Throughout, $\iota$ is a finite (or arbitrary, where noted) index type with decidable equality; items are elements of $\iota$; $B \in \mathbb{N}$ is a budget.

**Definition 2.1 (Top set).** For a score $s : \iota \to \mathbb{R}$, a budget $B$, and a finite set $S$ of items, say $S$ is a *top set* for $s$ at budget $B$, written $\mathrm{Top}(s, B, S)$, if

1. $|S| = B$, and
2. for all $i \in S$ and all $j \notin S$, $\; s(j) \le s(i)$.

Condition (2) is the eviction discipline: no discarded item outscores a retained one. Ties are permitted, so $\mathrm{Top}(s,B,\cdot)$ may hold of several sets; all statements below are universally quantified over admissible top sets, hence tie-breaking-free.

**Definition 2.2 (Retained value).** For a value function $v : \iota \to \mathbb{R}$ and a finite set $S$,
$$
R_v(S) \;=\; \sum_{i \in S} v(i).
$$
Here $v$ is the *true* utility of retaining an item, unavailable at decision time.

**Definition 2.3 (Oracle).** The *oracle at budget $B$* is the policy whose kept sets are the top sets of $v$ itself, i.e. any $O$ with $\mathrm{Top}(v, B, O)$.

**Definition 2.4 (Additive hybrid).** Given an accumulated-usage signal $a : \iota \to \mathbb{R}$, a static probe $p : \iota \to \mathbb{R}$ and a weight $\lambda \in \mathbb{R}$, the hybrid score is
$$
h_{a,p,\lambda}(i) \;=\; a(i) + \lambda\, p(i).
$$
We write $S_\lambda$ for a top set of $h_{a,p,\lambda}$ at the ambient budget.

**Definition 2.5 (Anti-aligned probe).** The probe $p$ is *anti-aligned* with $v$ if
$$
\forall i, j: \quad p(i) \le p(j) \;\Longrightarrow\; v(j) \le v(i),
$$
and *strictly anti-aligned* if for distinct $i \ne j$, $p(i) \le p(j) \Rightarrow v(j) < v(i)$.

Anti-alignment says a higher probe score never indicates a more valuable item. It is a strong hypothesis; Section 8 shows it cannot be dropped.

---

## 3. The exchange kernel

The following lemma carries all the weight in the static theory. Its content is that *pairwise* domination between the two halves of a symmetric difference already orders the sums — no injection, matching, or Hall-type argument is required.

**Lemma 3.1 (Equicardinality of symmetric-difference halves).** If $|T| = |S|$ then $|T \setminus S| = |S \setminus T|$.

*Proof.* $|T \setminus S| + |T \cap S| = |T|$ and $|S \setminus T| + |S \cap T| = |S|$; the intersections coincide. $\square$

**Lemma 3.2 (Split).** For any finite $S, T$: $\;R_v(T) = \sum_{j \in T\setminus S} v(j) + \sum_{j \in T \cap S} v(j)$.

*Proof.* $T \setminus S$ and $T \cap S$ are disjoint with union $T$. $\square$

**Theorem 3.3 (Exchange kernel).** Let $v : \iota \to \mathbb{R}$ and let $S, T$ be finite with $|T| = |S|$. If
$$
\forall j \in T \setminus S,\; \forall i \in S \setminus T: \quad v(j) \le v(i),
$$
then $R_v(T) \le R_v(S)$.

*Proof.* If $T \setminus S = \varnothing$ then by Lemma 3.1 also $S \setminus T = \varnothing$ and both sides agree. Otherwise both halves are non-empty and finite; choose $j_0$ maximising $v$ on $T \setminus S$ and $i_0$ minimising $v$ on $S \setminus T$. The hypothesis gives $v(j_0) \le v(i_0)$, and with $c := |T \setminus S| = |S \setminus T|$,
$$
\sum_{j \in T\setminus S} v(j) \;\le\; c\, v(j_0) \;\le\; c\, v(i_0) \;\le\; \sum_{i \in S \setminus T} v(i),
$$
the outer inequalities because $v(j_0)$ dominates and $v(i_0)$ is dominated on their respective sets. Adding the common term $\sum_{T \cap S} v = \sum_{S \cap T} v$ and applying Lemma 3.2 twice yields $R_v(T) \le R_v(S)$. $\square$

**Theorem 3.4 (Strict exchange kernel).** With the hypotheses of Theorem 3.3, if additionally $T \ne S$ and the domination is strict ($v(j) < v(i)$ for all $j \in T\setminus S$, $i \in S \setminus T$), then $R_v(T) < R_v(S)$.

*Proof.* $T \ne S$ with $|T| = |S|$ forces $T \setminus S \ne \varnothing$ (otherwise $T \subseteq S$ and equal cardinality give $T = S$), hence by Lemma 3.1 also $S \setminus T \ne \varnothing$, so $c \ge 1$ and the middle inequality $c\,v(j_0) < c\,v(i_0)$ is strict. $\square$

**Remark 3.5.** The equality $|T \setminus S| = |S \setminus T|$ is precisely where the *matched budget* enters. Comparisons across different budgets are not governed by Theorem 3.3; see Section 9.

---

## 4. The universal oracle bound

**Theorem 4.1 (Oracle maximality).** Let $\mathrm{Top}(v, B, O)$ and let $T$ be any set with $|T| = B$. Then $R_v(T) \le R_v(O)$.

*Proof.* Apply Theorem 3.3 with $S = O$. For $j \in T \setminus O$ and $i \in O \setminus T$ we have $i \in O$ and $j \notin O$, so the top-set property of $O$ for the score $v$ gives $v(j) \le v(i)$. $\square$

**Theorem 4.2 (Universal cheap-signal bound).** Let $s : \iota \to \mathbb{R}$ be *any* score function, let $\mathrm{Top}(s, B, S)$ and $\mathrm{Top}(v, B, O)$. Then
$$
R_v(S) \;\le\; R_v(O).
$$

*Proof.* Immediate from Theorem 4.1, using only $|S| = B$. $\square$

The proof is short, but its scope is the point. **Nothing about $s$ is used** beyond the cardinality of its top set. Consequently:

**Corollary 4.3 (Four-family bounding).** Accumulated usage $a$, recency, a static content probe $p$, and every function of them — in particular every additive hybrid $a + \lambda p$ and every non-linear combination — is bounded above by the oracle at matched budget. No enrichment of the cheap-signal family can cross the oracle line.

The interpretive consequence is that the measured $5.7$-point gap is a property of the *instance* — of the joint distribution of $(a, p, v)$ on the workload — and not a deficiency of any particular signal family. Attempts to close it by scoring innovations are, on this evidence, searching in a space that provably contains no solution; the levers that remain are structural (better usage tracking, larger budget) or epistemic (reporting oracle numbers explicitly as upper bounds).

---

## 5. Single crossing and monotone degradation

We now use the *additive* structure, which Theorem 4.2 deliberately ignored.

**Theorem 5.1 (Single-crossing lemma).** Let $\lambda_1 < \lambda_2$, and let $\mathrm{Top}(h_{a,p,\lambda_1}, B, S_1)$ and $\mathrm{Top}(h_{a,p,\lambda_2}, B, S_2)$. Then
$$
\forall j \in S_2 \setminus S_1, \; \forall i \in S_1 \setminus S_2: \quad p(i) \le p(j).
$$

*Proof.* Fix such $i, j$. Since $i \in S_1$, $j \notin S_1$, the top-set property at $\lambda_1$ gives
$$
a(j) + \lambda_1 p(j) \;\le\; a(i) + \lambda_1 p(i). \tag{5.1}
$$
Since $j \in S_2$, $i \notin S_2$, the top-set property at $\lambda_2$ gives
$$
a(i) + \lambda_2 p(i) \;\le\; a(j) + \lambda_2 p(j). \tag{5.2}
$$
Adding (5.1) and (5.2) cancels $a(i) + a(j)$ and leaves
$$
\lambda_1 p(j) + \lambda_2 p(i) \;\le\; \lambda_1 p(i) + \lambda_2 p(j),
$$
i.e. $(\lambda_2 - \lambda_1)\,(p(j) - p(i)) \ge 0$. As $\lambda_2 - \lambda_1 > 0$, $p(i) \le p(j)$. $\square$

**Interpretation.** Raising the probe weight exchanges cache slots *only in the direction of the probe*. An unordered pair $\{i, j\}$ can therefore swap membership at most once as $\lambda$ increases: once the higher-probe member has displaced the lower-probe one, the inequality (5.2) persists for all larger weights. The $\lambda$-sweep is a **one-dimensional monotone path** through selection space.

**Theorem 5.2 (Monotone trade-off path).** With the hypotheses of Theorem 5.1:

1. $R_p(S_1) \le R_p(S_2)$ (probe mass is non-decreasing in $\lambda$);
2. if additionally $0 \le \lambda_1$, then $R_a(S_2) \le R_a(S_1)$ (usage mass is non-increasing in $\lambda$).

*Proof.* (1) Apply Theorem 3.3 with value function $p$, $S := S_2$, $T := S_1$: for $j \in S_1 \setminus S_2$ and $i \in S_2 \setminus S_1$, Theorem 5.1 (with the roles as stated there) gives $p(j) \le p(i)$.

(2) Apply Theorem 3.3 with value function $a$, $S := S_1$, $T := S_2$. Let $j \in S_2 \setminus S_1$, $i \in S_1 \setminus S_2$. Theorem 5.1 gives $p(i) \le p(j)$, and (5.1) gives $a(j) - a(i) \le \lambda_1 (p(i) - p(j)) \le 0$ using $\lambda_1 \ge 0$ and $p(i) - p(j) \le 0$. Hence $a(j) \le a(i)$. $\square$

Thus the sweep is a genuine trade-off curve: probe mass is purchased with usage mass at a rate that never reverses. A one-parameter additive family *cannot leave this curve*; in particular it cannot reach selections that are simultaneously high in both masses, which is where an oracle-competitive set would generally lie.

**Theorem 5.3 (Monotone-degradation law).** Suppose $p$ is anti-aligned with $v$ (Definition 2.5). Let $\lambda_1 < \lambda_2$ with top sets $S_1, S_2$ as above. Then
$$
R_v(S_2) \;\le\; R_v(S_1).
$$

*Proof.* Apply Theorem 3.3 with $S := S_1$, $T := S_2$ (cardinalities agree, both $= B$). For $j \in S_2 \setminus S_1$ and $i \in S_1 \setminus S_2$, Theorem 5.1 gives $p(i) \le p(j)$, and anti-alignment then gives $v(j) \le v(i)$. $\square$

**Theorem 5.4 (Strict degradation).** If $p$ is strictly anti-aligned with $v$ and $S_2 \ne S_1$, then $R_v(S_2) < R_v(S_1)$.

*Proof.* As above, using Theorem 3.4. For $j \in S_2\setminus S_1$ and $i \in S_1 \setminus S_2$ we have $i \ne j$ (they lie in complementary memberships of $S_1$), so strict anti-alignment gives $v(j) < v(i)$. $\square$

**Corollary 5.5 ($\lambda = 0$ is optimal; P1 refuted, P2 confirmed).** Suppose $p$ is anti-aligned with $v$, let $\lambda > 0$, and let $S_0, S_\lambda$ be top sets of $h_{a,p,0}$ and $h_{a,p,\lambda}$ at budget $B$. Then $R_v(S_\lambda) \le R_v(S_0)$.

*Proof.* Theorem 5.3 with $\lambda_1 = 0 < \lambda_2 = \lambda$. $\square$

This is the theoretical content of the measured table: the response cannot have an interior maximum, and the pure-accumulation arm dominates the entire family.

---

## 6. Normalisation is a reparametrisation

The experiment standardises both signals before combining. We record that this is immaterial.

**Lemma 6.1 (Affine invariance of top sets).** Let $c > 0$, $d \in \mathbb{R}$. Then $\mathrm{Top}(c\,s + d,\, B,\, S)$ if and only if $\mathrm{Top}(s, B, S)$.

*Proof.* Cardinality is unaffected. For the ordering condition, $c\,s(j) + d \le c\,s(i) + d \iff s(j) \le s(i)$ since $c > 0$. $\square$

**Theorem 6.2 (z-score reparametrisation).** Let $\sigma, \tau > 0$ and $\mu, \nu \in \mathbb{R}$. For all $\lambda$, $B$, $S$:
$$
\mathrm{Top}\!\left( i \mapsto \frac{a(i) - \mu}{\sigma} + \lambda \cdot \frac{p(i) - \nu}{\tau},\; B,\; S \right)
\quad\Longleftrightarrow\quad
\mathrm{Top}\!\left( h_{a,p,\;\lambda\sigma/\tau},\; B,\; S \right).
$$

*Proof.* Algebraically,
$$
\frac{a(i)-\mu}{\sigma} + \lambda\frac{p(i)-\nu}{\tau}
= \frac{1}{\sigma}\Big(a(i) + \frac{\lambda\sigma}{\tau} p(i)\Big) + \Big(-\frac{\mu}{\sigma} - \frac{\lambda\nu}{\tau}\Big),
$$
an increasing affine image of $h_{a,p,\lambda\sigma/\tau}$; apply Lemma 6.1 with $c = 1/\sigma > 0$. $\square$

Since $\lambda \mapsto \lambda\sigma/\tau$ is an increasing bijection of $[0,\infty)$, the z-scored sweep and the raw sweep traverse **the same one-parameter family in the same order**. Every monotonicity statement of Section 5 therefore applies verbatim to the measured arms.

**Theorem 6.3 (Constant probes are inert).** For any constant $c$ and any $\lambda$, $\mathrm{Top}(h_{a,\,\mathbf{c},\,\lambda}, B, S) \iff \mathrm{Top}(a, B, S)$, where $\mathbf{c}$ denotes the constant function.

*Proof.* $h_{a,\mathbf{c},\lambda} = 1 \cdot a + \lambda c$; apply Lemma 6.1. $\square$

Theorem 6.3 isolates the causal claim: degradation is produced by the probe's *variation across items*, not by the act of appending a second term to the score.

---

## 7. Determinism and the calibrated instance

**Theorem 7.1 (Strict order forces the kept set).** Let $B \le n$ and let $s : \{0,\dots,n-1\} \to \mathbb{R}$ be strictly decreasing, i.e. $i < j \Rightarrow s(j) < s(i)$. If $\mathrm{Top}(s, B, S)$ then $S = \{0, 1, \dots, B-1\}$.

*Proof.* Write $L = \{0,\dots,B-1\}$, so $|L| = B = |S|$. Suppose $L \not\subseteq S$; then $L \setminus S \ne \varnothing$, and by Lemma 3.1 also $S \setminus L \ne \varnothing$. Pick $i \in L \setminus S$ and $j \in S \setminus L$. Then $i < B \le j$, so $s(j) < s(i)$ by strictness; but $j \in S$, $i \notin S$, so the top-set property gives $s(i) \le s(j)$ — contradiction. Hence $L \subseteq S$, and equal cardinality gives $S = L$. $\square$

Theorem 7.1 certifies **determinism**: an arm whose score is strictly ordered has no tie-breaking freedom, so a measured retained value is a function of the instance alone.

### 7.1 A four-item instance calibrated to the measurement

Let $\iota = \{0,1,2,3\}$, $B = 2$, and
$$
a = (4, 3, 2, 1), \qquad p = (8, 6, 4, 2), \qquad v = (0.4692,\; 0.4692,\; 0.4977,\; 0.4977).
$$

The two signals are genuinely distinct inputs — they separate the first pair by different amounts, $a(0) - a(1) = 1 \ne 2 = p(0) - p(1)$ — but they order the items in the same, misleading way, and that ordering is the reverse of the value ordering.

**Lemma 7.2.** For every $\lambda \ge 0$, the hybrid $h_{a,p,\lambda}$ is strictly decreasing in the index.

*Proof.* For $i < j$ we have $a(i) > a(j)$ and $p(i) > p(j)$ (both by inspection of the four values), so $a(i) + \lambda p(i) > a(j) + \lambda p(j)$ for $\lambda \ge 0$. $\square$

**Theorem 7.3 (Uniform hybrid kept set).** For every $\lambda \ge 0$ and every $S$ with $\mathrm{Top}(h_{a,p,\lambda}, 2, S)$ we have $S = \{0,1\}$.

*Proof.* Lemma 7.2 and Theorem 7.1. $\square$

**Theorem 7.4 (Oracle kept set).** $\mathrm{Top}(v, 2, \{2,3\})$ holds.

*Proof.* $|\{2,3\}| = 2$, and $v(0) = v(1) = 0.4692 \le 0.4977 = v(2) = v(3)$. $\square$

**Theorem 7.5 (The calibrated gap).** For every $\lambda \ge 0$, every hybrid top set $S$ and every oracle top set $O$ at budget $2$:
$$
R_v(S) = 0.9384, \qquad R_v(O) = 0.9954, \qquad R_v(O) - R_v(S) = 0.0570.
$$

*Proof.* $R_v(S) = v(0) + v(1) = 0.9384$ by Theorem 7.3. For $O$: by Theorem 4.1 applied in both directions (with $O$ and with $\{2,3\}$, each a top set of $v$ of size $2$), $R_v(O) = R_v(\{2,3\}) = 0.4977 + 0.4977 = 0.9954$. Subtract. $\square$

Thus a four-item instance reproduces the measured $B = 64$ hybrid value $0.9384$ and the $5.7$-point oracle gap **exactly and uniformly in $\lambda$** — a complete flat $\lambda$-response bounded strictly below the oracle. The measured near-flat, weakly decreasing sweep is the same phenomenon with a probe that perturbs a few boundary pairs rather than none.

---

## 8. Sharpness: the anti-alignment hypothesis is necessary

The monotone-degradation law is a statement about the *probe*, not about additivity. This is made precise by a two-item counterexample.

**Theorem 8.1 (A positive weight can strictly help).** Let $\iota = \{0,1\}$, $B = 1$, and
$$
a = (1, 0), \qquad p = (0, 1), \qquad v = (0, 1).
$$
Then the unique top set at $\lambda = 0$ is $\{0\}$, the unique top set at $\lambda = 2$ is $\{1\}$, and
$$
R_v(\{0\}) = 0 \;<\; 1 = R_v(\{1\}).
$$

*Proof.* At $\lambda = 0$ the score is $a$, with $a(1) = 0 < 1 = a(0)$; a singleton top set must contain the strictly larger score, so it is $\{0\}$ (if it were $\{1\}$, the top-set condition would demand $a(0) \le a(1)$, i.e. $1 \le 0$). At $\lambda = 2$ the score is $(1, 2)$, so symmetrically the top set is $\{1\}$. Evaluate $R_v$. $\square$

Here the probe is aligned with value exactly where accumulated usage errs. Since $p(0) = 0 \le 1 = p(1)$ while $v(1) = 1 > 0 = v(0)$, anti-alignment fails, and the conclusion of Theorem 5.3 fails with it.

**Interpretation.** The additive form is innocent. A content probe carrying genuine information *must* manifest as a positive-$\lambda$ improvement; a monotone decline in the sweep is therefore a *measurement of the probe's anti-alignment on the workload*, and the correct engineering inference is about the probe, not about score fusion.

---

## 9. Budget: the one knob that provably helps

**Theorem 9.1 (Budget monotonicity of the oracle).** Assume $v(i) \ge 0$ for all $i$, and let $B_1 \le B_2 \le |\iota|$. Let $\mathrm{Top}(v, B_1, S_1)$ and $\mathrm{Top}(v, B_2, S_2)$. Then $R_v(S_1) \le R_v(S_2)$.

*Proof.* Since $|S_1| = B_1 \le B_2 \le |\iota|$, extend $S_1$ to some $U \supseteq S_1$ with $|U| = B_2$. Non-negativity gives $R_v(S_1) \le R_v(U)$, and Theorem 4.1 at budget $B_2$ gives $R_v(U) \le R_v(S_2)$. $\square$

**Corollary 9.2.** Under the hypotheses of Theorem 9.1, any cheap-signal top set $S$ at budget $B_1$ satisfies $R_v(S) \le R_v(O_{B_2})$ for the oracle at any budget $B_2 \ge B_1$.

*Proof.* Chain Theorem 4.2 at $B_1$ with Theorem 9.1. $\square$

This is the $0.9189 < 0.9384 < 0.9544$ column of the measured table ($B = 32, 64, 128$). Within the model, **memory is the only monotone improvement direction**: increasing the budget provably helps, increasing the probe weight provably does not.

---

## 10. The sequential model: a factor-$B$ separation

The static analysis explains the shape of the $\lambda$-response. It does not, by itself, explain *why* even a well-chosen online signal must lag hindsight. For that we move to demand paging, where a structural obstruction appears that is independent of any score.

### 10.1 Schedules

**Definition 10.1 (Serving relation).** Let $\alpha$ be a finite item universe. The relation $\mathrm{Serves}(C, \sigma, k)$ — "starting from cache $C$, the request stream $\sigma$ can be served with exactly $k$ faults by some eviction schedule" — is generated inductively by:

- $\mathrm{Serves}(C, [\,], 0)$;
- **hit:** if $r \in C$ and $\mathrm{Serves}(C, \rho, k)$ then $\mathrm{Serves}(C, r :: \rho, k)$;
- **fault:** if $r \notin C$, $e \in C$ and $\mathrm{Serves}\big(\{r\} \cup (C \setminus \{e\}),\, \rho,\, k\big)$ then $\mathrm{Serves}(C, r::\rho, k+1)$.

This is demand paging: the cache changes only on a fault, and a fault brings in the requested item and evicts exactly one resident. The relation is nondeterministic — it quantifies existentially over schedules — so it models both online policies and offline hindsight.

**Lemma 10.2 (Cache size is preserved).** If $r \notin C$ and $e \in C$ then $|\{r\} \cup (C\setminus\{e\})| = |C|$.

*Proof.* $r \notin C \setminus \{e\}$, so the insertion adds one; the deletion removes one since $e \in C$. $\square$

**Lemma 10.3 (Skipping a run of hits).** If every element of the first $n$ requests of $\sigma$ lies in $C$, and $\mathrm{Serves}(C, \mathrm{drop}_n(\sigma), k)$, then $\mathrm{Serves}(C, \sigma, k)$.

*Proof.* Induction on $n$, applying the hit rule $n$ times; the cache is unchanged throughout. $\square$

### 10.2 The offline upper bound

The hard instances have exactly one item more than the cache can hold.

**Lemma 10.4 (Cache after a fault on $B+1$ items).** Let $|\alpha| = B + 1$, $|C| = B$, $r \notin C$, $e \in C$. Then $\{r\} \cup (C \setminus \{e\}) = \alpha \setminus \{e\}$.

*Proof.* $|\{r\} \cup C| = B+1 = |\alpha|$, so $\{r\} \cup C = \alpha$. Removing $e$ (which is in $C$, hence $\ne r$) from both sides gives the claim. $\square$

**Theorem 10.5 (Offline upper bound).** Let $B \ge 1$ and $|\alpha| = B+1$. For every request stream $\sigma$ and every cache $C$ with $|C| = B$ there exists $k$ with
$$
\mathrm{Serves}(C, \sigma, k) \qquad\text{and}\qquad k \cdot B \;<\; |\sigma| + B,
$$
i.e. $k \le \lceil |\sigma| / B \rceil$.

*Proof.* Strong induction on $|\sigma|$. The empty stream costs $0$ and $0 < 0 + B$. For $\sigma = r :: \rho$: if $r \in C$, apply the hit rule and the induction hypothesis to $\rho$, whose length is one smaller, and the bound only improves.

If $r \notin C$, consider the set $D$ of distinct items occurring in the next $B - 1$ requests, i.e. in $\mathrm{take}_{B-1}(\rho)$. Then $|D| \le B - 1 < B = |C|$, so some $e \in C$ lies outside $D$; evict it. By Lemma 10.4 the new cache is $\alpha \setminus \{e\}$, which contains every item of $\mathrm{take}_{B-1}(\rho)$ since $e \notin D$. Hence those $B-1$ requests are hits and may be skipped by Lemma 10.3. Apply the induction hypothesis to $\mathrm{drop}_{B-1}(\rho)$, whose length is at most $|\sigma| - B < |\sigma|$, obtaining a schedule with $k$ faults and $kB < |\mathrm{drop}_{B-1}(\rho)| + B$. The total cost is $k + 1$, and
$$
(k+1)B = kB + B < |\mathrm{drop}_{B-1}(\rho)| + 2B \le (|\sigma| - B) + 2B = |\sigma| + B
$$
when $k \ge 1$; the case $k = 0$ is a direct arithmetic check. $\square$

The mechanism is the familiar one: **each fault buys $B$ fault-free steps**, because with $B+1$ live items the evicted item is the only possible source of the next fault, and it was chosen not to appear soon.

### 10.3 Deterministic policies and the adaptive adversary

**Definition 10.6 (Policy run cost).** An *eviction rule* is a function $A$ mapping a cache $C$ and a requested item $r$ to the victim $A(C, r)$. Its run cost is
$$
\mathrm{cost}_A([\,], C) = 0, \qquad
\mathrm{cost}_A(r :: \rho, C) = \begin{cases}
\mathrm{cost}_A(\rho, C), & r \in C,\\[2pt]
\mathrm{cost}_A\big(\rho,\; \{r\} \cup (C \setminus \{A(C,r)\})\big) + 1, & r \notin C.
\end{cases}
$$

**Lemma 10.7 (A policy run is a legal schedule).** If $A(C, r) \in C$ whenever $|C| = B$, then for every $\sigma$ and every $C$ with $|C| = B$, $\;\mathrm{Serves}(C, \sigma, \mathrm{cost}_A(\sigma, C))$.

*Proof.* Induction on $\sigma$, using Lemma 10.2 to maintain $|C| = B$. $\square$

Lemma 10.7 is what makes the comparison honest: the online cost and the offline bound are computed in **the same model**.

**Definition 10.8 (Adaptive adversary).** With $|\alpha| = B+1$ and $|C| = B$, exactly one item is absent; call it $\mathrm{miss}(C)$. Define the stream of length $m$
$$
\mathrm{adv}_A(0, C) = [\,], \qquad
\mathrm{adv}_A(m+1, C) = \mathrm{miss}(C) :: \mathrm{adv}_A\big(m,\; \{\mathrm{miss}(C)\} \cup (C \setminus \{A(C, \mathrm{miss}(C))\})\big).
$$
Its length is $m$ by construction.

**Theorem 10.9 (Online lower bound).** Let $|\alpha| = B+1$ and let $A$ satisfy $A(C,r) \in C$ for all $|C| = B$. Then for every $m$ and every $C$ with $|C| = B$,
$$
\mathrm{cost}_A(\mathrm{adv}_A(m, C),\; C) = m.
$$

*Proof.* Induction on $m$. The head request $\mathrm{miss}(C)$ is by definition not in $C$, so it is a fault; the resulting cache has size $B$ by Lemma 10.2, and the tail is by construction the adversary stream for that cache. $\square$

The adversary is the simplest possible: **request whatever the policy just evicted**.

### 10.4 The separation

**Theorem 10.10 (Factor-$B$ separation).** Let $B \ge 1$, $|\alpha| = B+1$, let $A$ be any eviction rule with $A(C,r) \in C$ for $|C| = B$, let $m \in \mathbb{N}$, and let $|C| = B$. Then there exist a stream $\sigma$ with $|\sigma| = m$ and a number $k$ such that
$$
\mathrm{cost}_A(\sigma, C) = m, \qquad \mathrm{Serves}(C, \sigma, \mathrm{cost}_A(\sigma, C)), \qquad \mathrm{Serves}(C, \sigma, k), \qquad k \cdot B < m + B .
$$

*Proof.* Take $\sigma = \mathrm{adv}_A(m, C)$. Theorem 10.9 gives the online cost; Lemma 10.7 certifies it as a legal schedule; Theorem 10.5 supplies the offline $k$. $\square$

So the online cost is $m$ while some schedule pays at most $\lceil m/B\rceil$: a ratio approaching $B$.

**Definition 10.11 (Hybrid evictor).** For signals $a, p$ and weight $\lambda$, let $E_{a,p,\lambda}(C, r)$ be a resident item minimising $a(i) + \lambda p(i)$ over $i \in C$ (any minimiser; the cache is non-empty when $B \ge 1$). This is the sequential form of the additive-hybrid policy: *evict the resident slot of least hybrid score*.

**Lemma 10.12.** $E_{a,p,\lambda}(C, r) \in C$ whenever $|C| = B \ge 1$.

*Proof.* A non-empty finite set has a minimiser, which is a member. $\square$

**Theorem 10.13 (The hybrid family inherits the separation).** Let $B \ge 1$, $|\alpha| = B+1$, $|C| = B$. For every $a$, $p$, **every** $\lambda \in \mathbb{R}$ and every horizon $m$, there is a stream $\sigma$ of length $m$ with
$$
\mathrm{cost}_{E_{a,p,\lambda}}(\sigma, C) = m \qquad\text{and}\qquad \exists k,\; \mathrm{Serves}(C,\sigma,k) \;\wedge\; k \cdot B < m + B.
$$

*Proof.* Lemma 10.12 and Theorem 10.10. $\square$

**Theorem 10.14 (Non-vacuity).** The hypotheses are realised concretely: on the universe $\{0, 1, \dots, B\}$ with $B \ge 1$, for every eviction rule $A$ respecting residency and every $m$, there is an initial cache $C$ of size $B$, a stream $\sigma$ of length $m$ on which $A$ faults $m$ times, and a schedule for $\sigma$ from $C$ with $k$ faults, $k B < m + B$.

*Proof.* Take any $B$-subset of the $(B+1)$-element universe as $C$ and apply Theorem 10.10. $\square$

**Reading.** Theorem 10.13 is the structural counterpart of the static oracle bound. In the static model the gap is instance-dependent and uncrossable by reweighting; in the sequential model it is *worst-case universal*: **no** deterministic rule, however sophisticated its score — accumulated usage, content probe, any additive blend, any learned online predictor — beats hindsight by better than a factor $B$, and one spare live item is enough to force it.

---

## 11. Algorithms and complexity

Three procedures are implicit above; we state them with costs.

**(A) Hybrid top-$B$ selection.** Compute $s_\lambda(i) = a(i) + \lambda p(i)$ for all $n$ items and select the $B$ largest. With a linear-time selection this is $\Theta(n)$ time and $\Theta(1)$ auxiliary space beyond the score array; with sorting, $\Theta(n \log n)$ and the full order for free.

**(B) The $\lambda$-sweep and its breakpoints.** By Theorem 5.1, as $\lambda$ increases the kept set changes only at *crossings* $\lambda_{ij} = -\,\dfrac{a(i) - a(j)}{p(i) - p(j)}$ for pairs with $p(i) \ne p(j)$, and each unordered pair crosses at most once. Computing all candidate breakpoints costs $O(n^2)$, sorting them $O(n^2 \log n)$; evaluating the retained value at each of the $O(n^2)$ resulting regimes gives the *entire* $\lambda$-response exactly, replacing any finite grid. Theorems 5.3 and Corollary 5.5 imply the response is a non-increasing step function under anti-alignment, so the sweep may terminate at the first breakpoint.

**(C) Offline (hindsight) service.** The offline bound's constructive content is the classical rule *evict the resident item whose next request is furthest in the future*. On a stream of length $m$ over $n$ items with cache size $B$ this runs in $O(m \log B)$ with a precomputed next-occurrence array (one pass, $O(m + n)$) and a priority queue keyed by next-use time. Theorem 10.5 shows that on $B+1$ live items it faults at most $\lceil m/B \rceil$ times.

**(D) The adaptive adversary.** Given a black-box deterministic rule $A$, generating the worst-case stream costs one simulation step per request: $O(m)$ rule invocations. It is fully constructive — it needs no knowledge of $A$'s internals, only its outputs.

---

## 12. Discussion

### 12.1 What has been established

Three nested impossibility statements:

1. **Instance-level (Theorem 4.2).** At matched budget, no score whatsoever beats the oracle. The bound is score-blind, so it bounds all four cheap-signal families at once — accumulation, recency, content, and their linear combinations — and locates the measured $5.7$-point gap in the instance rather than in the policy.
2. **Family-level (Theorems 5.1–5.4, Corollary 5.5).** The additive family is a one-dimensional monotone path: single crossing forces each pair to exchange at most once and always toward the probe; probe mass rises and usage mass falls along the path; under anti-alignment retained value declines monotonically and $\lambda = 0$ is optimal. This is exactly the measured pattern, derived rather than observed.
3. **Model-level (Theorem 10.13).** Sequentially, every deterministic rule is a factor $B$ from hindsight on $B+1$ live items. This survives any improvement in score quality, since the adversary reacts to the *decision*, not to the reasoning behind it.

Two auxiliary results guard against misreading. Theorem 8.1 shows the degradation law needs anti-alignment, so the verdict is about the probe and not about additive fusion; Theorem 6.2 shows z-scoring only renames the parameter, so the verdict does not depend on the normalisation used.

And one positive result: Theorem 9.1, budget monotonicity — the only provably helpful knob.

### 12.2 Scope and limitations

- **The static model is selection, not service.** It abstracts one retention decision at a fixed budget; it does not model the dynamics by which usage counters are accumulated. Improvements to *usage-tracking quality* change $a$ and therefore change the instance, and are not excluded by any result here.
- **Anti-alignment is a hypothesis about a workload.** Theorems 5.3–5.5 apply where it holds. In the motivating measurement the monotone decline is evidence for it; on another corpus the probe might be aligned and Theorem 8.1's phenomenon might appear.
- **The sequential bound is worst case.** Theorem 10.13 concerns an adversarial stream on $B+1$ live items. Typical workloads are far more benign; the bound says what cannot be *guaranteed*, and thus what no amount of score engineering can promise.
- **The determinism restriction.** Theorem 10.9 uses determinism essentially, as it must: randomised policies escape the deterministic factor-$B$ lower bound, which is the classical reason randomisation is interesting in this setting. Randomised eviction is a genuinely open direction here.

### 12.3 Future directions

**Sweep complexity: how many policies does a $\lambda$-grid actually test?** The kept set changes only when a kept/evicted pair crosses, and by single crossing each unordered pair crosses at most once, so the number of *changes* of the kept set over $\lambda \in [0,\infty)$ — one fewer than the number of distinct regimes — should be bounded by the number of *boundary* pairs $B(n-B)$, not by all $\binom{n}{2}$ pairs. Numerically, the maximum change count observed over random instances with $n \le 7$ was $6$, far under $\binom{7}{2} = 21$. The single-crossing lemma is in hand, so the missing step is a counting argument over the breakpoints; the payoff is direct: a $\lambda$-grid of size much larger than $B(n-B)$ is provably redundant, which bounds the experimental cost of every future sweep.

**A formula, not an inequality, for the oracle gap.** Theorem 4.2 should be tight in a quantitative way: the oracle-minus-hybrid gap ought to equal the sum of the $B$ largest "misranking inversions" of the score against $v$. The exchange kernel already isolates the symmetric difference as the only place value is lost, so the remaining work is to identify the inversion structure inside that difference. A formula would convert a qualitative bound into a diagnostic: it would say *which* items cost the $5.7$ points.

**Beyond linear fusion.** The one-dimensionality of the additive path is what makes the family so easy to bound. Non-additive fusions (rank aggregation, gated switching, per-item mixtures) leave the path; whether they can leave the *oracle-dominated region* in any useful way is bounded by Theorem 4.2 but not otherwise settled.

**Randomised and structural routes.** Randomised eviction evades the deterministic separation; quantifying that in the present framework is natural. Structurally, the routes that remain are improvements to usage-tracking quality and to the budget itself, or the disciplined reporting of oracle numbers as upper bounds rather than as achievable targets.

**Domain and scale variation.** The instance-dependence of the gap is a theorem, not a slogan; measuring it across domain-jump corpora and larger models is the correct empirical follow-up, since only the instance can move it.

---

## 13. Conclusion

Fusing a content probe into an accumulated-usage eviction score by an additive weight is not merely unhelpful on the measured workload — it is *monotonically* unhelpful, and it had to be. Single crossing makes the $\lambda$-sweep a one-dimensional path that trades usage mass for probe mass in one direction only; anti-alignment converts that trade into a monotone decline; and the score-blind exchange kernel bounds the whole family, and every other cheap family, below the oracle at matched budget. Sequentially, an adaptive adversary with one spare item ensures that no deterministic rule is within a factor $B$ of hindsight. What is left is not a better score but more memory — the one direction in which the model provably improves.
