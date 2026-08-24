# A Selection-Theoretic Account of Content-Based Importance Prediction in Budgeted Key Eviction

**Author:** Aristotle

**Date:** 2026-08-24

---

## Abstract

Budgeted eviction — retaining $B$ out of $n$ stored keys so as to preserve as much future attention mass as possible — is a selection problem, not a regression problem. Yet the standard way to justify a *content probe*, a learned predictor of a key's future importance from the key's own vector, is regression-flavoured: report the coefficient of determination $R^2$ and argue that a more accurate score should evict better. We show that this reasoning is structurally invalid, and we develop the selection theory that replaces it.

Working with a finite key set, a true importance vector $a$, a score $s$, and the notion of a *top set* (a budget-$B$ set no member of which is scored below a non-member), we prove an exchange inequality from which everything else follows: two transfer theorems bounding the retention deficit of an $\varepsilon$-accurate score by $2B\varepsilon$ in $L^\infty$ and by $2\sqrt{B\cdot\mathrm{SSE}}$ in $L^2$, a sharpened form indexed by the number of exchanged keys, and the $R^2$-currency form $2\sqrt{B(1-R^2)\mathrm{SS}_{\mathrm{tot}}}$. We show the $L^\infty$ constant is attained, hence unimprovable.

The central negative result is that these bounds are irreducibly one-sided. For every target $\rho \in (0,1)$ — in particular for the measured $\rho = 0.3185$ — there exists a score with $R^2$ exactly $\rho$ that reproduces the oracle selection at *every* budget. A companion four-key instance exhibits a score with sum of squared errors $150$ retaining one unit of mass while a score with sum of squared errors $1802$ retains nineteen. Prediction accuracy does not order retention, even weakly. We localise the true mechanism: the entire deficit is carried by the mass sitting in a $2\varepsilon$-band around the eviction cut-off, and vanishes identically when that band is empty.

For the mixture score $h + \lambda p$ we prove that selection stability is equivalent to a linear system in $\lambda$, giving an explicit non-degradation threshold $\lambda \le \gamma / D$ (margin over probe oscillation) and showing that the stable set of weights is an interval — the structural reason a harmful mixture can only harm monotonically. Explicit instances show a mixture strictly dominating both parents ($9 < 11 < 19$) with stability interval exactly $[0, 2/5]$, so the helpful weight $\lambda = 1$ lies outside the certifiably safe region: safety and usefulness are in exact quantitative tension.

Finally we bridge to the retention knee. For a sorted profile the length-$k$ prefix is a top set, so the knee is a floor for *every* eviction policy, not a property of top-$k$ eviction; and a probe with error $\varepsilon$ run at budget at least the knee still reaches $\tau - 2B\varepsilon$.

The empirical backdrop, on Python source at $B = 64$: accumulated heavy-hitter $0.9340$, probe-only $0.8149$, hybrid at $\lambda = 1$ $0.9371$, with probe $R^2$ averaging $0.3185$ on code against $0.329$ on prose. The two domains' guarantees differ by less than $0.8\%$, and reading the deficit backwards through the bound forces the importance dispersion $\mathrm{SS}_{\mathrm{tot}} > 8\times 10^{-5}$.

**Keywords:** budgeted selection, key eviction, top sets, exchange inequality, coefficient of determination, retention transfer bounds, mixture stability, attention retention knee.

---

## 1. Introduction

### 1.1 The setting

An autoregressive attention model reading a long context accumulates a store of keys. Memory is finite, so a policy must decide, at each moment, which $B$ keys to retain. The quality of the decision is measured after the fact: how much of the attention mass that future queries actually direct at the store lands on keys the policy chose to keep.

Formally, let $\iota$ be a finite set of keys, and let $a : \iota \to \mathbb{R}$ assign to each key $i$ its **true importance** $a_i$ — the total future attention it receives. A policy outputs a set $S$ with $|S| = B$, and its **retained mass** is

$$\mathcal{A}(S) \;=\; \sum_{i \in S} a_i .$$

The true importances are unavailable at eviction time. A policy is therefore driven by a **score** $s : \iota \to \mathbb{R}$, an observable surrogate. Three families of surrogates are standard:

1. **Accumulated heavy-hitter statistics.** $h_i$ is a running total (possibly decayed) of the attention key $i$ has received so far. This is *relational*: it records how the key has been used.
2. **Content probes.** $p_i = \langle w, k_i \rangle$ for a learned $w$, where $k_i$ is the key's own vector. This is *intrinsic*: it looks only at what the key is.
3. **Mixtures.** $h_i + \lambda p_i$ for a mixing weight $\lambda \ge 0$.

### 1.2 The measurement that motivates this paper

The three arms were run on Python source code at budget $B = 64$, with identical methodology and budgets across arms:

| Arm | Retained mass at $B = 64$ |
|---|---|
| Accumulated heavy-hitter | $0.9340$ |
| Content probe only | $0.8149$ |
| Hybrid, $\lambda = 1$ | $0.9371$ |

The probe's coefficient of determination against true importance was $R^2 = 0.3185$ on average (range $0.1225$–$0.5921$), against $0.329$ on English prose in the matched earlier round.

Code was chosen deliberately as the *most favourable* domain for a content probe: identifiers recur, syntax is rigid, and token-level regularity is far higher than in prose. The prediction under test was that content-based importance would work where it had failed on prose. It did not. The probe arm loses $11.91$ points to the accumulated arm, and its $R^2$ is statistically indistinguishable from the prose value. The mixture, by contrast, is *non-degrading* on code ($+0.3$ points), whereas on prose the same mixture harmed monotonically in $\lambda$.

The natural narrative — "the probe loses because $R^2 = 0.32$ is low" — is what this paper refutes.

### 1.3 Contributions

- A minimal selection-theoretic framework (§2) in which the exchange inequality for top sets is the single generative fact.
- Transfer theorems in $L^\infty$, $L^2$ and $R^2$ currency, with a sharpened exchange-indexed form, and a proof that the $L^\infty$ constant is attained (§3, §6).
- The central negative result: $R^2$ does not determine retention, in the strongest possible sense — for every $\rho \in (0,1)$ there is an $R^2 = \rho$ score with perfect retention at every budget (§4).
- A second, order-theoretic negative result: $L^2$ accuracy does not order retention even weakly (§4).
- Localisation of the deficit to a $2\varepsilon$-band around the cut-off, with an exact vanishing criterion (§5).
- A complete stability theory of the mixture: linear-system characterisation, margin threshold, convexity of the stable weight set, and explicit instances of strict dominance and of the safety/usefulness tension (§7).
- A bridge to the retention knee showing it is a floor for all policies (§8).
- Two quantitative readings of the measurements: a dispersion lower bound and a cross-domain guarantee ratio below $0.8\%$ (§9).

---

## 2. The selection framework

### 2.1 Top sets

**Definition 2.1 (Retained mass).** For $a : \iota \to \mathbb{R}$ and $S \subseteq \iota$ finite, $\mathcal{A}(S) = \sum_{i \in S} a_i$.

**Definition 2.2 (Top set).** A finite set $S \subseteq \iota$ is a *top set for the score $s$ at budget $B$*, written $S \in \mathrm{Top}(s, B)$, if

$$|S| = B \quad\text{and}\quad \forall\, i \in S,\ \forall\, j \notin S:\ s_j \le s_i .$$

This is exactly the output of a greedy budget-$B$ evictor driven by $s$. The definition permits ties, so $\mathrm{Top}(s,B)$ can contain more than one set; this non-uniqueness is not a technicality but the locus of the entire phenomenon studied below.

**Lemma 2.3 (Uniqueness under strict separation).** If $|T| = B$ and $s_j < s_i$ for all $i \in T$ and $j \notin T$, then $\mathrm{Top}(s,B) = \{T\}$.

*Proof.* Let $S \in \mathrm{Top}(s,B)$ and suppose some $i \in T \setminus S$. Since $|S| = |T|$, the symmetric difference is balanced and $S \setminus T$ is nonempty; take $j$ in it. Then $s_j < s_i$ by strict separation (as $j \notin T$) while $s_i \le s_j$ by the top-set property of $S$ (as $j \in S$, $i \notin S$) — contradiction. Hence $T \subseteq S$, and equal cardinality gives $S = T$. $\square$

Lemma 2.3 is what makes every numerical instance below unambiguous: whenever a score separates its selection strictly, statements of the form "*every* selection driven by $s$ retains exactly $m$" are meaningful and non-vacuous.

### 2.2 The exchange inequality

**Theorem 2.4 (Exchange inequality).** Let $S \in \mathrm{Top}(s,B)$ and let $|T| = B$. Then

$$\sum_{i \in T \setminus S} s_i \;\le\; \sum_{i \in S \setminus T} s_i .$$

*Proof.* Since $|S| = |T|$, we have $|S \setminus T| = |T \setminus S| =: m$. If $m = 0$ both sides vanish. Otherwise pick $i_0$ minimising $s$ on $S\setminus T$ and $j_0$ maximising $s$ on $T \setminus S$. Since $i_0 \in S$ and $j_0 \notin S$, the top-set property gives $s_{j_0} \le s_{i_0}$. Then

$$\sum_{i \in T\setminus S} s_i \;\le\; m\, s_{j_0} \;\le\; m\, s_{i_0} \;\le\; \sum_{i \in S \setminus T} s_i . \qquad \square$$

**Corollary 2.5 (Top sets maximise score mass).** Under the hypotheses of Theorem 2.4, $\sum_{i \in T} s_i \le \sum_{i \in S} s_i$.

*Proof.* Add $\sum_{i \in S \cap T} s_i$ to both sides of Theorem 2.4 and use the partitions $T = (T\cap S) \sqcup (T \setminus S)$, $S = (S\cap T)\sqcup(S\setminus T)$. $\square$

**Corollary 2.6 (Oracle bound).** If $T \in \mathrm{Top}(a, B)$ and $|S| = B$, then $\mathcal{A}(S) \le \mathcal{A}(T)$.

*Proof.* Corollary 2.5 with $s = a$. $\square$

Corollary 2.6 is the provable content of the experimental clause "probe $\le$ accumulated $\le$ oracle": the oracle inequality is a theorem, the ordering of the two heuristic arms is a measurement.

---

## 3. Transfer theorems: accuracy buys a one-sided guarantee

Write $\mathrm{SSE}(a,s) = \sum_{i} (a_i - s_i)^2$.

**Theorem 3.1 ($L^\infty$ transfer).** Let $S \in \mathrm{Top}(s,B)$, $|T| = B$, and suppose $|a_i - s_i| \le \varepsilon$ for all $i$. Then

$$\mathcal{A}(T) - 2B\varepsilon \;\le\; \mathcal{A}(S).$$

*Proof.* Decompose $\mathcal{A}(U) = \sum_{i\in U} s_i + \sum_{i \in U}(a_i - s_i)$ for $U \in \{S,T\}$. The score terms satisfy $\sum_T s \le \sum_S s$ by Corollary 2.5. Each error term is bounded in absolute value by $\sum_{i \in U} |a_i - s_i| \le |U|\varepsilon = B\varepsilon$. Combining, $\mathcal{A}(T) \le \sum_S s + B\varepsilon \le \mathcal{A}(S) + 2B\varepsilon$. $\square$

**Theorem 3.2 (Sharpened $L^\infty$ transfer).** Under the same hypotheses,

$$\mathcal{A}(T) - 2\,|S \setminus T|\,\varepsilon \;\le\; \mathcal{A}(S).$$

*Proof.* Apply the same decomposition to the *symmetric-difference blocks* rather than to $S$ and $T$ wholesale. The common part $S \cap T$ cancels; on the blocks, Theorem 2.4 controls the score terms and the error terms are bounded by $|S\setminus T|\varepsilon$ and $|T\setminus S|\varepsilon$, which are equal. $\square$

Since $|S\setminus T| \le B$ this strictly strengthens Theorem 3.1, and it carries an operational message: a score that is inaccurate but *agrees with the rival arm on most keys* is nearly harmless. The number of exchanged keys, not the budget, is the natural scale.

**Lemma 3.3 (Block Cauchy–Schwarz).** For any $U$, $\bigl|\sum_{i \in U}(a_i - s_i)\bigr| \le \sqrt{|U| \cdot \mathrm{SSE}(a,s)}$.

*Proof.* $\bigl(\sum_{U} (a_i-s_i)\bigr)^2 \le |U| \sum_U (a_i-s_i)^2 \le |U|\,\mathrm{SSE}$. $\square$

**Theorem 3.4 ($L^2$ transfer).** Let $S \in \mathrm{Top}(s,B)$ and $|T| = B$. Then

$$\mathcal{A}(T) - 2\sqrt{B\cdot \mathrm{SSE}(a,s)} \;\le\; \mathcal{A}(S).$$

*Proof.* As in Theorem 3.1, replacing the $L^\infty$ error bound by Lemma 3.3. $\square$

### 3.1 The bound in $R^2$ currency

**Definition 3.5.** Let $\bar a = \frac{1}{|\iota|}\sum_i a_i$, $\mathrm{SS}_{\mathrm{tot}}(a) = \sum_i (a_i - \bar a)^2$, and, when $\mathrm{SS}_{\mathrm{tot}} \ne 0$,

$$R^2(a,s) \;=\; 1 - \frac{\mathrm{SSE}(a,s)}{\mathrm{SS}_{\mathrm{tot}}(a)} .$$

**Theorem 3.6 (Retention gap of an $R^2$-accurate probe).** If $S \in \mathrm{Top}(s,B)$, $|T| = B$ and $\mathrm{SS}_{\mathrm{tot}}(a) \ne 0$, then

$$\mathcal{A}(T) - \mathcal{A}(S) \;\le\; 2\sqrt{B\,\bigl(1 - R^2(a,s)\bigr)\,\mathrm{SS}_{\mathrm{tot}}(a)} .$$

*Proof.* Substitute $\mathrm{SSE} = (1-R^2)\mathrm{SS}_{\mathrm{tot}}$ into Theorem 3.4. $\square$

Theorem 3.6 is the only rigorous statement connecting a probe's reported $R^2$ to its retention. It is an *upper* bound on the deficit. Section 4 shows that no lower bound of any comparable form exists.

---

## 4. $R^2$ cannot be the mechanism

### 4.1 An $R^2$-mediocre probe with perfect retention

**Definition 4.1 (Shrinkage probe).** For $c \in \mathbb{R}$ set $\mathrm{sh}_c(a)_i = \bar a + c\,(a_i - \bar a)$.

**Lemma 4.2.** $\mathrm{SSE}\bigl(a, \mathrm{sh}_c(a)\bigr) = (1-c)^2\,\mathrm{SS}_{\mathrm{tot}}(a)$, hence $R^2\bigl(a,\mathrm{sh}_c(a)\bigr) = 1 - (1-c)^2$ whenever $\mathrm{SS}_{\mathrm{tot}} \ne 0$.

*Proof.* Termwise, $a_i - \mathrm{sh}_c(a)_i = (1-c)(a_i - \bar a)$. $\square$

**Lemma 4.3.** For $c > 0$ and every budget $B$ and set $S$: $S \in \mathrm{Top}(\mathrm{sh}_c(a), B) \iff S \in \mathrm{Top}(a, B)$.

*Proof.* $x \mapsto \bar a + c(x - \bar a)$ is strictly increasing, hence order-preserving; the top-set condition is a conjunction of order comparisons. $\square$

**Theorem 4.4 ($R^2$ does not determine retention).** Let $\mathrm{SS}_{\mathrm{tot}}(a) \ne 0$ and let $\rho \in (0,1)$. Then there exists a score $s$ with

$$R^2(a,s) = \rho \quad\text{and}\quad \mathrm{Top}(s,B) = \mathrm{Top}(a,B) \ \text{ for every } B .$$

In particular $s$ attains the oracle retention at every budget, with $R^2$ exactly the measured $0.3185$.

*Proof.* Take $s = \mathrm{sh}_c(a)$ with $c = 1 - \sqrt{1-\rho}$. Lemma 4.2 gives $R^2 = 1 - (\sqrt{1-\rho})^2 = \rho$. Since $\rho \in (0,1)$ we have $\sqrt{1-\rho} < 1$, so $c > 0$ and Lemma 4.3 applies. Oracle retention then follows from Corollary 2.6. $\square$

**Discussion.** Theorem 4.4 is the paper's pivot. The $R^2$ statistic measures the *magnitude* of the residual; retention depends on the *direction* of the residual — specifically, on which retained/discarded pairs it reverses. The shrinkage probe has residual $(1-c)(a_i - \bar a)$, which is perfectly aligned with $a - \bar a$ and therefore reverses nothing. Consequently:

> The $11.91$-point probe deficit is **not** deducible from $R^2 = 0.3185$. Any causal account of the deficit must be an account of the residual's *misordering behaviour near the cut-off*, not of its size.

### 4.2 Accuracy does not even order retention

Theorem 4.4 shows that a fixed $R^2$ is compatible with the best possible retention. The following four-key instance shows the stronger, order-theoretic failure: improving accuracy can strictly *worsen* retention.

**Instance 4.5.** Let $\iota = \{0,1,2,3\}$ with

$$a = (10,\,9,\,1,\,0), \qquad h = (1,\,2,\,3,\,4), \qquad p = (40,\,30,\,20,\,10).$$

Then $\mathrm{SSE}(a,h) = 81+49+4+16 = 150$ and $\mathrm{SSE}(a,p) = 900+441+361+100 = 1802$.

**Theorem 4.6 (Accuracy does not order retention).** For Instance 4.5, $\mathrm{SSE}(a,h) < \mathrm{SSE}(a,p)$, yet

$$S \in \mathrm{Top}(h,2) \implies \mathcal{A}(S) = 1, \qquad T \in \mathrm{Top}(p,2) \implies \mathcal{A}(T) = 19 .$$

*Proof.* $h$ separates $\{2,3\}$ strictly from $\{0,1\}$ and $p$ separates $\{0,1\}$ strictly from $\{2,3\}$, so by Lemma 2.3 the two top sets are unique: $\{2,3\}$ and $\{0,1\}$. Their retained masses are $1+0 = 1$ and $10+9 = 19$. $\square$

Thus no implication of the form "smaller $\mathrm{SSE}$ $\Rightarrow$ at least as much retained mass" can hold, even in the weakest monotone sense. Accuracy order and retention order are *incomparable* partial orders on scores. Theorems 4.4 and 4.6 are exact companions: the first says a fixed accuracy is compatible with the best retention, the second says a strictly better accuracy is compatible with strictly worse retention.

---

## 5. Where the deficit lives: the boundary band

If accuracy is the wrong statistic, the theory should say what the right one is. It does, and the answer is *local*.

**Theorem 5.1 (Boundary-band bound).** Let $a_i \ge 0$ for all $i$, let $S \in \mathrm{Top}(s,B)$, $|T| = B$, suppose $|a_i - s_i| \le \varepsilon$ for all $i$, and let $\mu$ satisfy $a_j \le \mu$ for every $j \notin T$. Then

$$\mathcal{A}(T) - \mathcal{A}(S) \;\le\; \sum_{\substack{i \in T \\ a_i \le \mu + 2\varepsilon}} a_i .$$

*Proof.* We show $T \setminus S \subseteq \{ i \in T : a_i \le \mu + 2\varepsilon\}$. Let $i \in T\setminus S$. Balanced cardinality gives some $j \in S \setminus T$. Then $s_i \le s_j$ (top-set property of $S$, as $j \in S$, $i \notin S$), and $a_j \le \mu$ (as $j \notin T$). Hence

$$a_i \le s_i + \varepsilon \le s_j + \varepsilon \le a_j + 2\varepsilon \le \mu + 2\varepsilon .$$

Now $\mathcal{A}(T) - \mathcal{A}(S) = \sum_{T\setminus S} a - \sum_{S \setminus T} a \le \sum_{T\setminus S} a$ by non-negativity, and the inclusion plus non-negativity give the stated bound. $\square$

**Corollary 5.2 (No band, no loss).** If in addition $a_i > \mu + 2\varepsilon$ for every $i \in T$, then $\mathcal{A}(T) \le \mathcal{A}(S)$: the $\varepsilon$-accurate score loses nothing at all.

**Corollary 5.3 (Oracle recovery under a margin).** If $|T| = B$, $a_j + \gamma \le a_i$ for all $i \in T$, $j \notin T$, and $2\varepsilon < \gamma$, then every $S \in \mathrm{Top}(s,B)$ equals $T$.

*Proof.* For $i \in T$, $j \notin T$: $s_j \le a_j + \varepsilon \le a_i - \gamma + \varepsilon < a_i - \varepsilon \le s_i$. Apply Lemma 2.3. $\square$

**Interpretation.** The retention deficit is carried entirely by the keys within $2\varepsilon$ of the eviction cut-off. Keys of $T$ that stand clear of the boundary — the *safe core* — are retained no matter how badly the score behaves elsewhere. The controlling statistic is therefore the **band mass**

$$\mathrm{Band}_{2\varepsilon} \;=\; \sum_{i \in T,\ a_i \le \mu + 2\varepsilon} a_i,$$

a *local* quantity. Unlike $R^2$, which is a global variance ratio, band mass is free to differ substantially between two domains whose fits are numerically identical. This is the theory's concrete prediction about the code/prose asymmetry, and it is directly measurable from an attention trace.

---

## 6. The transfer constant is sharp

**Instance 6.1.** Let $\iota = \{0,1,2,3\}$ with $a = (1,1,-1,-1)$ and the flat score $s \equiv 0$.

**Theorem 6.2 (Sharpness of $2B\varepsilon$).** For Instance 6.1: $|a_i - s_i| \le 1$ for all $i$; $\{2,3\} \in \mathrm{Top}(s,2)$; $|\{0,1\}| = 2$; and

$$\mathcal{A}(\{2,3\}) \;=\; \mathcal{A}(\{0,1\}) - 2\cdot 2\cdot 1 .$$

*Proof.* $|a_i| = 1$ everywhere gives $\varepsilon = 1$. Every key is scored $0$, so *every* pair is a top set for $s$; in particular $\{2,3\}$ is. Retained masses are $-2$ and $2$, and $-2 = 2 - 4$. $\square$

Hence no inequality $\mathcal{A}(T) - cB\varepsilon \le \mathcal{A}(S)$ holds with $c < 2$: Theorem 3.1 is exactly tight. The pessimism of the transfer theorems is a fact about the problem, not an artefact of the proof. Together with Theorem 4.4 this delimits the situation precisely: $L^\infty$/$L^2$ accuracy determines retention only up to the full worst case, and the worst case is attained by a maximally tied score. Ties, again, are the mechanism.

---

## 7. The mixture: stability, thresholds, and the safety/usefulness tension

Define the **hybrid score** at mixing weight $\lambda$:

$$\mathrm{hyb}(h,p,\lambda)_i \;=\; h_i + \lambda\, p_i, \qquad \mathrm{hyb}(h,p,0) = h .$$

### 7.1 A linear characterisation of stability

**Theorem 7.1 (Stability is a linear system).** For any $h,p$, budget $B$, set $S$ and weight $\lambda$:

$$S \in \mathrm{Top}(\mathrm{hyb}(h,p,\lambda), B) \iff |S| = B \ \text{ and }\ \forall\, i \in S,\ j \notin S:\ \lambda\,(p_j - p_i) \le h_i - h_j .$$

*Proof.* The top-set condition reads $h_j + \lambda p_j \le h_i + \lambda p_i$, which rearranges to the displayed inequality. $\square$

So the selection $S$ survives the mixture exactly on the solution set of $|S|\cdot(|\iota|-|S|)$ linear inequalities in the single variable $\lambda$. Everything about the mixture's behaviour is a fact about this one-dimensional polyhedron.

### 7.2 The non-degradation threshold

**Theorem 7.2 (Margin threshold).** Suppose $|S| = B$, the accumulated score separates $S$ by a margin $\gamma$, i.e. $h_j + \gamma \le h_i$ for all $i \in S$, $j \notin S$, and the probe has oscillation at most $D$, i.e. $p_i - p_j \le D$ for all $i,j$. Then for every $\lambda \ge 0$ with $\lambda D \le \gamma$,

$$S \in \mathrm{Top}(\mathrm{hyb}(h,p,\lambda), B).$$

*Proof.* For $i \in S$, $j \notin S$: $\lambda(p_j - p_i) \le \lambda D \le \gamma \le h_i - h_j$. Apply Theorem 7.1. $\square$

**Corollary 7.3 (The hybrid can always match the accumulated arm).** Under the hypotheses of Theorem 7.2, there exists $S'$ with $S' \in \mathrm{Top}(\mathrm{hyb}(h,p,\lambda),B)$ and $\mathcal{A}(S') = \mathcal{A}(S)$ — namely $S' = S$.

**Interpretation.** Non-degradation is a property of the *accumulated* score's margin relative to the *probe's dynamic range*. It is not a property of the probe's accuracy. Two domains with identical probe $R^2$ can differ completely in whether their mixtures degrade, purely because their accumulated scores separate with different margins. This makes the measured code/prose asymmetry — neutral on code, harmful on prose — predictable from margin statistics alone, with no reference to predictive quality.

### 7.3 The stable weight set is an interval

**Theorem 7.4 (Convexity).** If $S \in \mathrm{Top}(\mathrm{hyb}(h,p,\lambda_1),B)$ and $S \in \mathrm{Top}(\mathrm{hyb}(h,p,\lambda_2),B)$, then for every $t \in [0,1]$,

$$S \in \mathrm{Top}\bigl(\mathrm{hyb}(h,p,(1-t)\lambda_1 + t\lambda_2), B\bigr).$$

*Proof.* Fix $i \in S$, $j \notin S$ and write $\delta = p_j - p_i$, $\eta = h_i - h_j$. By Theorem 7.1, $\lambda_1 \delta \le \eta$ and $\lambda_2\delta \le \eta$. Multiplying by $1-t \ge 0$ and $t \ge 0$ and adding yields $((1-t)\lambda_1 + t\lambda_2)\delta \le \eta$. $\square$

**Corollary 7.5 (Order-connectedness).** If $S$ is stable at $\lambda_1$ and at $\lambda_2$ and $\lambda_1 \le \lambda \le \lambda_2$, then $S$ is stable at $\lambda$.

*Proof.* Take $t = (\lambda - \lambda_1)/(\lambda_2 - \lambda_1) \in [0,1]$ when $\lambda_1 < \lambda_2$, and note the degenerate case is trivial. $\square$

**Consequence.** The set of mixing weights preserving a given selection is an interval. Therefore, once $\lambda$ leaves the stability interval of the accumulated selection, it never re-enters. A domain in which the mixture harms can only harm **monotonically** in $\lambda$. The monotone degradation observed on prose is not an empirical accident; it is a structural consequence of linearity in $\lambda$.

### 7.4 A mixture can strictly dominate both parents

**Instance 7.6.** With $a = (10,9,1,0)$ as before, let

$$h = (6,\,2,\,4,\,0), \qquad p = (2,\,7,\,2,\,5), \qquad \mathrm{hyb}(h,p,1) = (8,\,9,\,6,\,5).$$

**Theorem 7.7 (Strict dominance).** At budget $2$ for Instance 7.6:

$$S \in \mathrm{Top}(h,2) \Rightarrow \mathcal{A}(S) = 11, \quad S \in \mathrm{Top}(p,2) \Rightarrow \mathcal{A}(S) = 9, \quad S \in \mathrm{Top}(\mathrm{hyb}(h,p,1),2) \Rightarrow \mathcal{A}(S) = 19 .$$

Explicitly the three selections are $\{0,2\}$, $\{1,3\}$ and $\{0,1\}$, with $9 < 11 < 19$.

*Proof.* Each score separates its top pair strictly ($h$: $4 > 2$; $p$: $5 > 2$; hybrid: $8 > 6$), so Lemma 2.3 makes each top set unique. The masses are $10+1 = 11$, $9+0 = 9$ and $10+9 = 19$. $\square$

The mechanism is transparent: $h$ misranks the pair $(1,2)$ — it prefers key $2$ (importance $1$) to key $1$ (importance $9$) — while $p$ misranks the pair $(0,3)$ — it prefers key $3$ (importance $0$) to key $0$ (importance $10$). Their sum repairs both misrankings simultaneously. Strict dominance over both parents is therefore a *structurally available* effect for mixtures of scores with disjoint error patterns, not a rounding artefact. The measured $+0.3$-point gain on code sits in exactly this régime.

### 7.5 Safety and usefulness are in exact tension

**Theorem 7.8 (Exact stability interval).** For Instance 7.6 and every $\lambda \in \mathbb{R}$:

$$\{0,2\} \in \mathrm{Top}(\mathrm{hyb}(h,p,\lambda), 2) \iff \lambda \le \tfrac{2}{5}.$$

*Proof.* By Theorem 7.1 the condition is the conjunction over $i \in \{0,2\}$, $j \in \{1,3\}$ of $\lambda(p_j - p_i) \le h_i - h_j$. The four constraints are
$\lambda(7-2) \le 6-2$, i.e. $\lambda \le 4/5$;
$\lambda(5-2) \le 6-0$, i.e. $\lambda \le 2$;
$\lambda(7-2) \le 4-2$, i.e. $\lambda \le 2/5$;
$\lambda(5-2) \le 4-0$, i.e. $\lambda \le 4/3$.
The binding constraint is $\lambda \le 2/5$, and it implies the other three. $\square$

Combining Theorems 7.7 and 7.8: the accumulated selection is provably preserved exactly for $\lambda \in [0, 2/5]$, while the weight that *helps* is $\lambda = 1$, outside that interval. This is the deployment corollary:

> Choosing $\lambda$ below the margin ratio $\gamma/D$ guarantees safety — and guarantees that the hybrid learns nothing from the probe. Any $\lambda$ small enough to be certifiably harmless is by construction too small to alter a single selection. A hybrid that provably cannot hurt is a hybrid that provably does nothing.

Non-degradation as measured is therefore *not* the same phenomenon as non-degradation as certified. The measured $+0.3$ on code is an instance of the mixture operating *outside* its certified-safe region and happening to land well — which the theory says is possible (Theorem 7.7), and equally says is not guaranteed.

---

## 8. The knee is a floor for every policy

A companion strand of the work studies the **retention knee** of a sorted attention profile. Let $p : \mathbb{N} \to \mathbb{R}$ be an antitone (non-increasing) profile with retention curve $\mathcal{R}(k) = \sum_{i<k} p_i$, and define

$$\mathrm{knee}(p,\tau) \;=\; \inf\{\,k : \tau \le \mathcal{R}(k)\,\},$$

the smallest budget at which the top-$k$ policy reaches the drift-assert threshold $\tau$. On code this came out at $12$ of $16$ heads, fewer than for prose.

The bridge to the present framework is one observation.

**Lemma 8.1 (Prefixes are top sets).** Let $p$ be antitone, $k \le n$, and give the $n$-key context the importance vector $a_i = p_i$ ($i \in \{0,\dots,n-1\}$). Then the prefix $P_k = \{0,\dots,k-1\}$ satisfies $P_k \in \mathrm{Top}(a,k)$.

*Proof.* $|P_k| = k$; and for $i \in P_k$, $j \notin P_k$ we have $i < k \le j$, so $a_j = p_j \le p_i = a_i$ by antitonicity. $\square$

**Theorem 8.2 (The retention curve is the envelope of all policies).** For antitone $p$, $k \le n$ and any $|S| = k$: $\mathcal{A}(S) \le \mathcal{R}(k)$.

*Proof.* Lemma 8.1 and Corollary 2.6. $\square$

**Theorem 8.3 (Below the knee, every policy fails).** If $B \le n$ and $B < \mathrm{knee}(p,\tau)$, then every $|S| = B$ has $\mathcal{A}(S) < \tau$.

*Proof.* $\mathcal{A}(S) \le \mathcal{R}(B) < \tau$, the last inequality by definition of the infimum. $\square$

**Corollary 8.4 (Experimental contrapositive).** If a policy at budget $B$ satisfies $\tau \le \mathcal{A}(S)$, then $\mathrm{knee}(p,\tau) \le B$: passing the drift assert certifies a knee bound.

Thus the reported "$12$ of $16$" is not a statement about the top-$k$ heuristic. It is an information-theoretic floor: no scoring rule beats it.

**Theorem 8.5 (Price of content-blindness at the knee).** Let $p_i \ge 0$, let $B \ge \mathrm{knee}(p,\tau)$ with $B \le n$, assume $\tau$ is reachable, let $S \in \mathrm{Top}(s,B)$ and $|a_i - s_i| \le \varepsilon$. Then

$$\tau - 2B\varepsilon \;\le\; \mathcal{A}(S).$$

*Proof.* Monotonicity of $\mathcal{R}$ under non-negativity plus $B \ge \mathrm{knee}$ gives $\tau \le \mathcal{R}(B) = \mathcal{A}(P_B)$. Apply Theorem 3.1 with $T = P_B$. $\square$

With Theorem 6.2 (which attains $2B\varepsilon$) this pins the cost of content-blindness exactly: linear in budget and error, and no better. Notably, sortedness is not needed for Theorem 8.5 — only the threshold reachability the knee supplies.

---

## 9. Reading the measurements through the theory

### 9.1 A dispersion lower bound from the observed deficit

**Theorem 9.1 (Consistency law).** Let $S \in \mathrm{Top}(s,64)$, $|T| = 64$, $\mathrm{SS}_{\mathrm{tot}}(a) \ne 0$, $R^2(a,s) = 0.3185$, and suppose the observed deficit satisfies $0.1191 \le \mathcal{A}(T) - \mathcal{A}(S)$. Then

$$\mathrm{SS}_{\mathrm{tot}}(a) \;>\; 8 \times 10^{-5}.$$

*Proof.* Theorem 3.6 gives $0.1191 \le 2\sqrt{64 \cdot 0.6815 \cdot \mathrm{SS}_{\mathrm{tot}}}$, hence $(0.05955)^2 \le 43.616\,\mathrm{SS}_{\mathrm{tot}}$, i.e. $\mathrm{SS}_{\mathrm{tot}} \ge 3.546\times 10^{-3}/43.616 > 8\times 10^{-5}$. $\square$

The measured numbers are therefore *not independent*. A probe deficit of $11.91$ points at $R^2 = 0.3185$ and $B = 64$ is simultaneously a measurement of the probe and a lower bound on the dispersion of the key population. Any report of the first is implicitly a report of the second.

### 9.2 Domain-universality, quantitatively

**Theorem 9.2 (Guarantee ratio).**

$$\frac{\sqrt{1 - 0.3185}}{\sqrt{1 - 0.329}} \;=\; \frac{\sqrt{0.6815}}{\sqrt{0.671}} \;<\; 1.008 .$$

*Proof.* $1.008^2 \cdot 0.671 = 0.68178\ldots > 0.6815$; take square roots, using monotonicity of $\sqrt{\cdot}$ and $\sqrt{1.008^2 \cdot 0.671} = 1.008\sqrt{0.671}$. $\square$

Since the transfer bound of Theorem 3.6 is proportional to $\sqrt{1-R^2}$ at fixed $B$ and $\mathrm{SS}_{\mathrm{tot}}$, the worst-case guarantees licensed by the code and prose rounds differ by under $0.8\%$. "Domain-universal" is thereby upgraded from a qualitative impression to a quantitative statement: at the level of the guarantee, the two rounds are the same experiment.

---

## 10. Algorithms

The theory yields three directly implementable procedures.

**(A) Greedy budget-$B$ selection.** Sort keys by score descending, take the first $B$. Cost $O(n \log n)$, or $O(n \log B)$ with a size-$B$ min-heap. Its output is a top set (Definition 2.2), so Corollary 2.5 and all transfer theorems apply verbatim.

**(B) Stability-interval computation.** Given $h$, $p$ and a selection $S$, the set of safe mixing weights is $\{\lambda : \lambda(p_j - p_i) \le h_i - h_j \ \forall i \in S, j \notin S\}$ by Theorem 7.1. Each pair with $p_j > p_i$ imposes an upper bound $(h_i-h_j)/(p_j-p_i)$; each pair with $p_j < p_i$ a lower bound; pairs with $p_j = p_i$ are either vacuous or infeasible. Taking the min of upper bounds and max of lower bounds yields the exact interval in $O(|S|\,(n - |S|))$ time — for $B = 64$ and $n = 1024$ that is about $6\times 10^4$ comparisons, negligible relative to a forward pass. This is the deployable safety check: compute the interval, then decide whether the desired $\lambda$ lies inside it.

**(C) Band-mass diagnostic.** Given the rival selection $T$, the cut-off $\mu = \max_{j \notin T} a_j$ and the score error $\varepsilon = \max_i |a_i - s_i|$, compute $\sum_{i \in T,\, a_i \le \mu + 2\varepsilon} a_i$. By Theorem 5.1 this upper-bounds the deficit, and by Corollary 5.2 a zero value certifies zero loss. Cost $O(n)$. This is the statistic the theory recommends in place of $R^2$.

---

## 11. Discussion

### 11.1 What the theory does and does not license

The transfer theorems are *guarantees*, not *explanations*. They say a sufficiently accurate score cannot lose much; they do not say an inaccurate score must lose much, and Theorems 4.4, 4.6 and 6.2 show, in three independent ways, that no such converse can be added:

- a fixed $R^2$ is compatible with perfect retention at every budget (4.4);
- a strictly better $\mathrm{SSE}$ is compatible with strictly worse retention (4.6);
- the guarantee's constant is attained, so the gap between guarantee and best case is the full worst case (6.2).

Three natural informal claims are therefore false as stated:

1. *"Low $R^2$ explains the 12-point probe deficit."* False; the right statistic is a tie-weighted misordering rate near the cut-off, not a variance ratio. Theorem 5.1 supplies the correct — and local — surrogate.
2. *"Hybrid non-degradation is a property of the probe."* False; Theorem 7.2 makes it a property of the accumulated score's margin relative to the probe's oscillation.
3. *"An $L^2$-better score is a better evictor."* False; the two orders are incomparable (Theorem 4.6).

### 11.2 The law

The results support one substantive principle, which the code round extends across domains:

> **Importance is relational, not intrinsic.** Even where identifiers repeat and syntax is rigid — the most favourable possible terrain for a content-based predictor — a key's own vector carries almost no information about its future reception. The observable that matters is how the key has already been used, not what it contains.

The domain difference sits entirely in the *interaction* term: content is neutral on code and harmful on prose. Combined with the knee analysis (fewer keys needed on code: $12$ of $16$), the code-domain picture closes: fewer keys are needed, content is useless for choosing them, and recency plus accumulation remains the deployable pair.

### 11.3 Scope and limitations

The empirical anchor is a single language and repository at a single budget with a single model scale; the theory is domain-agnostic, but the measured constants are not. The theory assumes a fixed true importance vector, i.e. it treats importance as determined once the future queries are fixed; online settings in which eviction changes the future distribution are outside scope. Non-negativity of $a$ is used only in Theorem 5.1 and Corollary 5.2 (it is automatic for attention masses). All statements are worst-case over the rival selection $T$; average-case retention under a distribution over key populations is untouched.

---

## 12. Future directions

**1. Band mass, not $R^2$, is the domain-discriminating statistic.** The qualitative half is settled: Theorem 5.1 proves the loss is at most the mass of the $2\varepsilon$-band around the cut-off. What remains is the empirical claim. The key insight is that band mass is a *local* quantity, so unlike $R^2$ it is free to differ between code and prose even when the fits are numerically identical. The bound is established and the band is directly measurable from an attention trace, so the prediction — code and prose have equal $R^2$ but unequal band mass at $B = 64$ — is testable with the existing harness and no new modelling.

**2. The margin ratio predicts the sign of the hybrid interaction.** Theorem 7.2 makes non-degradation a function of $\gamma/D$: the accumulated score's separation margin divided by the probe's oscillation. The conjecture is that measuring $\gamma$ and $D$ per domain predicts the observed sign of the interaction — neutral on code, harmful on prose — with no reference to $R^2$ at all.

**3. A tie-weighted misordering rate.** Theorems 4.4 and 6.2 jointly show the residual's *size* is the wrong summary. The proposed replacement is a statistic weighting each misordered retained/discarded pair by the attention mass at stake and by the closeness of the tie. Establishing a two-sided bound in terms of such a statistic would complete the theory.

**4. Extension of the empirical programme.** Mathematical and non-English natural-language domains; learned online predictors rather than a fixed linear probe; increments at budget $4096$; and a $7$B-parameter cell to test scale-dependence of the margin statistics.

---

## 13. Conclusion

The claim that a content probe underperforms *because* its $R^2$ is low is not merely unproven; it is unprovable, and three independent constructions show why. Retention is a selection functional, sensitive only to the ordering a score induces near the eviction cut-off, while $R^2$ is a magnitude summary blind to ordering. The correct localisation replaces the global variance ratio by the mass sitting in a $2\varepsilon$-band around the cut-off — a local statistic, and therefore one that can distinguish domains that produce numerically identical fits.

For mixtures the picture is equally clean and rather less comfortable. Selection stability is a linear system in the mixing weight, so the safe region is an interval, harm is necessarily monotone once that interval is left, and safety is certified precisely by the condition $\lambda \le \gamma/D$ that also guarantees the probe contributes nothing. A mixture *can* strictly dominate both parents — the explicit instance retains $19$ against $11$ and $9$ — but only by operating outside its certified region.

And beneath all of it lies a floor no policy escapes: the retention knee bounds every scoring rule, not just top-$k$ eviction. What a key is turns out to be nearly irrelevant to what it will be needed for; what it has already been used for is the signal that survives.
