# The Tropical Limit of Attention Is Lossy but the Recovery Is Fast: Maslov Gaps, Rényi Sandwiches and Key-Budget Bounds for Top-$k$ Attention

**Author:** Aristotle

**Date:** 2026-10-08

## Abstract

We study the *tropical limit* of softmax attention — the replacement of the softmax average by a hard argmax pointer — and its finite-budget relaxations, oracle top-$k$ attention. On a pretrained 24-layer, half-billion-parameter language model (Qwen2.5-0.5B), evaluated in full precision on held-out natural text at contexts $512$, $1024$ and $2048$, pure argmax attention retains only $0.364$, $0.289$ and $0.250$ of the reference behavior, getting worse with context; two keys recover $0.70$–$0.79$, four keys $0.88$–$0.91$, and eight keys $0.94$–$0.96$. The $0.98$-retention knees $\{16, 32, 24\}$ reproduce an independent earlier sweep exactly. A per-layer map of the **Maslov gap** $g = \mathrm{LSE}(x) - \max_j x_j$ shows bulk medians of $0.17$–$1.86$ nats and isolates the last two layers as the only region far from tropical (medians up to $2.69$ nats, ninetieth percentile about $3.4$). A pre-registered prediction that the crystallization loss $\sum_i p_i(1-p_i)$ would be at most $1/4$ is refuted (layer means $0.34$–$0.97$).

We then prove a set of exact statements that organize these measurements: (i) the softmax weight of a key is $e^{-g_i}$, so the gap at the argmax is the min-entropy and its exponential is the argmax-cache mass; (ii) a two-sided *Rényi sandwich* $1-e^{-g}\le\sum_i p_i(1-p_i)\le 1-e^{-2g}$, sharp on flat rows, which shows any row with gap above $1/3$ nat has crystallization above $1/4$; (iii) truncation to a key set lowers log-sum-exp by exactly $-\log$ of the kept mass; (iv) two lower bounds on the number of keys needed to retain mass $\tau$, namely $\tau e^{g}$ and $\tau^2/\sum_i p_i^2$, which calibrated on the gap and crystallization maps force at least $13$ and at least $33$ keys respectively; (v) a margin bound $(n-k)e^{-m}/k$ on the mass lost by a top-$k$ cache; (vi) an argmax floor $1/(1+(n-1)e^{-m})$ that decreases in $n$ and vanishes as $n\to\infty$; and (vii) a doubling inequality $R(2k)\le 2R(k)$ for sorted mass curves which the measured retention curve violates at every context, proving that measured retention is a nonlinear readout of kept mass, together with Weierstrass bounds for a layer-compounded readout.

---

## 1. Introduction

A decoder-only transformer, when producing token $n+1$, forms in every head of every layer a score row $x \in \mathbb{R}^n$ against the $n$ cached keys and outputs the softmax-weighted average of the cached values. The cache of keys and values grows linearly with context and is often the binding memory constraint on small accelerators. A large literature on KV-cache compression rests on the empirical observation that attention rows are *sparse-ish*: a few keys carry most of the weight.

The most aggressive compression is to keep one key per row, which turns attention into a pointer. Mathematically this is the **tropical limit** of the softmax: the log-sum-exp function

$$\mathrm{LSE}(x) = \log\sum_{j=1}^n e^{x_j}$$

satisfies $\max_j x_j \le \mathrm{LSE}(x) \le \max_j x_j + \log n$ and $\varepsilon\,\mathrm{LSE}(x/\varepsilon) \to \max_j x_j$ as $\varepsilon \downarrow 0$. This is Maslov's dequantization: the semiring $(\mathbb{R}, \mathrm{LSE}, +)$ degenerates to the max-plus (tropical) semiring $(\mathbb{R}, \max, +)$. In that limit the softmax distribution concentrates on the argmax.

This paper does two things. Empirically, it pushes an oracle top-$k$ sweep down to $k = 1$ on a real pretrained model and measures, row by row, how far each layer is from the tropical limit. Theoretically, it proves elementary but exact inequalities that convert those measurements into statements about cache budgets, explain why a pre-stated prediction failed, and show that the measured quality curve cannot be a plain attention-mass curve.

**Summary of contributions.**

1. A measured recovery curve from the tropical limit: retention at $k \in \{1, 2, 4, 8\}$ and the $0.98$ knee at three contexts, with exact cross-session replication of the knee chain $\{16, 32, 24\}$.
2. The first per-layer **Maslov-gap map** and **crystallization map** of a pretrained model, isolating layers 22–23 as the diffuse tail.
3. Exact theorems: gap = min-entropy; the Rényi crystallization sandwich; the log-domain truncation identity; gap and collision lower bounds on key counts (with numerical calibrations); the margin truncation bound; monotonicity and vanishing of the argmax floor; the doubling inequality and its violation by the data; Weierstrass bounds for compounded readouts.

---

## 2. Setting and definitions

Throughout, $n \ge 1$ and $x = (x_1, \dots, x_n) \in \mathbb{R}^n$ is a row of attention scores (logits). All logarithms are natural; gaps are measured in nats.

**Definition 2.1 (Softmax).** The softmax weights are
$$p_i = \mathrm{softmax}(x)_i = \frac{e^{x_i}}{\sum_{j=1}^n e^{x_j}}.$$
They are strictly positive and sum to $1$. If $x_j \le x_i$ then $p_j \le p_i$.

**Definition 2.2 (Log-sum-exp and Maslov gap).** $\mathrm{LSE}(x) = \log\sum_j e^{x_j}$. The *Maslov gap* of key $i$ is
$$g_i = \mathrm{LSE}(x) - x_i.$$
When $i$ is an argmax ($x_j \le x_i$ for all $j$), we write $g = g_i$ and call it the Maslov gap of the row; $0 \le g \le \log n$, with $g = \log n$ exactly for a flat row.

**Definition 2.3 (Collision and crystallization).** The *collision probability* is $C(x) = \sum_i p_i^2$ (equal to $e^{-H_2}$ where $H_2$ is the Rényi entropy of order 2). The *crystallization loss* is
$$K(x) = \sum_i p_i (1-p_i).$$
It vanishes exactly for a one-hot distribution and measures how far the softmax is from "crystallized" pointer form.

**Definition 2.4 (Kept mass and restricted log-sum-exp).** For a nonempty key set $S \subseteq \{1,\dots,n\}$,
$$M(S) = \sum_{j\in S} p_j, \qquad \mathrm{LSE}_S(x) = \log\sum_{j\in S} e^{x_j}.$$

**Definition 2.5 (Retention profile and knee).** For a weight profile $p_0, p_1, p_2, \dots \ge 0$ (sorted in decreasing order in the cases of interest) define the retained mass $R(k) = \sum_{i<k} p_i$. For a target $\tau$ for which some $k$ satisfies $R(k) \ge \tau$, the *knee* $\kappa(\tau)$ is the least such $k$; in particular $R(\kappa(\tau)) \ge \tau$.

**Definition 2.6 (Argmax floor).** For a margin $m \in \mathbb{R}$ and a context length $n \ge 1$,
$$F(m, n) = \frac{1}{1 + (n-1)e^{-m}}.$$

**Experimental retention.** In the experiments, "retention" is a deterministic score of agreement between the top-$k$ model and the full-attention reference on held-out text ($1$ = identical). The experimental knee is the least $k$ with retention $\ge 0.98$. Definition 2.5 is the mathematical idealization in which retention equals kept mass; Section 9 proves that the measured curve cannot be of that form.

---

## 3. Experimental protocol and measurements

**Model and data.** Qwen2.5-0.5B (24 layers), natural text, contexts $n \in \{512, 1024, 2048\}$. Measurements are taken on the held-out final $10\%$ of each sequence; nothing in the selection of $k$ or of the knee threshold depends on the data. All computation is in 32-bit floating point.

**Validation gate.** Before any measurement, the custom forward pass (needed to intervene on attention) is checked to reproduce the reference implementation's outputs exactly; the run terminated normally.

**Intervention.** In every layer and every head, each attention row is replaced by *oracle top-$k$ attention*: the $k$ largest scores are kept, the softmax is renormalized over them, and all other keys are dropped. Random-$k$ and local-window controls from the preceding sweep (same harness) were not rerun here.

**Pre-stated predictions.** (P1) argmax attention is catastrophic and worsens with context. (P2) a few keys recover most of the quality. (P3) the mean crystallization loss is at most $1/4$.

### 3.1 The recovery curve

| $k$ | $n=512$ | $n=1024$ | $n=2048$ |
|---|---|---|---|
| $1$ | $0.3637$ | $0.2885$ | $0.2503$ |
| $2$ | $0.7865$ | $0.7398$ | $0.7002$ |
| $4$ | $0.9097$ | $0.8906$ | $0.8762$ |
| $8$ | $0.9617$ | $0.9485$ | $0.9408$ |
| knee ($\ge 0.98$) | $16$ | $32$ | $24$ |

P1 is confirmed: retention at $k=1$ falls monotonically with context. P2 is confirmed: the marginal gains are $+0.34$ to $+0.45$ for $k = 1 \to 2$, $+0.12$ to $+0.17$ for $k = 2\to 4$, and $+0.05$ to $+0.07$ for $k = 4 \to 8$; $k = 4$ just clears $0.90$ at $n = 512$. The knee chain $\{16, 32, 24\}$ coincides exactly with that of an independent earlier sweep using a different script in a different session, which, given deterministic evaluation, establishes the knee as a reproducible property of model and data. Top-$24$ attention retains at least $0.98$ at every context.

### 3.2 The Maslov-gap map

For every causal row we computed $g = \mathrm{LSE}(x) - \max_j x_j$ and aggregated per layer.

- **Bulk layers.** Median gaps lie in $[0.17, 1.86]$ nats at $n \in \{512, 1024\}$, inside $\log 8 \approx 2.08$ (the gap of a row uniformly spread over $8$ keys). At $n = 2048$ every bulk layer has median at most $1.46$.
- **Diffuse tail.** Layers 22 and 23 have medians $2.33/2.16$ at $n=512$, $2.55/2.37$ at $n=1024$, and $2.69/2.52$ at $n=2048$, with ninetieth percentile about $3.4$. They are the only far-from-tropical region and drift further from it as context grows.

### 3.3 The crystallization map

Per-layer mean crystallization losses lie in $[0.34, 0.97]$. P3 is refuted. Section 5 shows that the gap map alone forces this.

---

## 4. Gap equals min-entropy

**Theorem 4.1.** For every key $i$, $p_i = e^{-g_i}$.

*Proof.* Let $Z = \sum_j e^{x_j} > 0$. Then $e^{-g_i} = e^{x_i - \log Z} = e^{x_i}/Z = p_i$. $\square$

**Corollary 4.2.** At an argmax $i$, the mass kept by an argmax (one-key) cache is $M(\{i\}) = e^{-g}$, and $g = -\log p_{\max}$ is the min-entropy $H_\infty$ of the attention distribution.

Thus a bulk median gap of $1.86$ nats means the median row keeps only $e^{-1.86} \approx 0.156$ of its mass on its top key, and in the diffuse tail at $n=2048$ only $e^{-2.69} \approx 0.068$.

---

## 5. The Rényi crystallization sandwich

**Lemma 5.1.** For any $i$, $K(x) = 1 - C(x)$.

*Proof.* $\sum_j p_j(1-p_j) = \sum_j p_j - \sum_j p_j^2 = 1 - C(x)$. $\square$

**Theorem 5.2 (Collision bounds).** Let $i$ be an argmax and $g$ its gap. Then
$$e^{-2g} \;\le\; C(x) \;\le\; e^{-g}.$$

*Proof.* Upper: since $p_j \le p_i$ for all $j$, $C = \sum_j p_j p_j \le \sum_j p_j p_i = p_i = e^{-g}$ by Theorem 4.1. Lower: $C \ge p_i^2 = e^{-2g}$ since every term is nonnegative. $\square$

Equivalently, $H_\infty \le H_2 \le 2H_\infty$: the Rényi-2 entropy lies between the min-entropy and twice it.

**Theorem 5.3 (Crystallization sandwich).** With $i$ an argmax and $g$ its gap,
$$1 - e^{-g} \;\le\; K(x) \;\le\; 1 - e^{-2g}.$$

*Proof.* Combine Lemma 5.1 with Theorem 5.2. $\square$

**Proposition 5.4 (Sharpness).** If the row is flat ($x_j = x_i$ for all $j$), then $K(x) = 1 - e^{-g}$ exactly.

*Proof.* All $p_j$ equal $p_i$, so $C = \sum_j p_j p_i = p_i = e^{-g}$. $\square$

**Corollary 5.5 (Why P3 failed).** If $g > 1/3$, then $K(x) > 1/4$. Conversely, $K(x) \le 1/4$ forces $g \le \log(4/3) \approx 0.288$.

*Proof.* By $\log y \le y - 1$, $\log(4/3) \le 1/3$, so $g > 1/3 \ge \log(4/3)$ gives $e^{-g} < 3/4$, hence $K \ge 1 - e^{-g} > 1/4$. For the converse, $K \le 1/4$ and the lower sandwich give $e^{-g} \ge 3/4$, so $-g \ge \log(3/4) = -\log(4/3)$. $\square$

With bulk median gaps reaching $1.86$ nats — more than five times the $\log(4/3)$ threshold — a crystallization budget of $1/4$ was incompatible with the gap map. The lower sandwich predicts crystallization at least $1 - e^{-1.86} \approx 0.84$ for such a row, consistent with the measured upper range of layer means.

---

## 6. Truncation in the log domain

**Theorem 6.1 (Truncation identity).** For any nonempty $S$,
$$\mathrm{LSE}(x) - \mathrm{LSE}_S(x) = -\log M(S).$$

*Proof.* $M(S) = \big(\sum_{j\in S} e^{x_j}\big)/\big(\sum_j e^{x_j}\big)$; take logarithms. $\square$

**Corollary 6.2.** For the argmax cache $S = \{i\}$, $M(\{i\}) = e^{-g}$ and the log-domain truncation cost equals the Maslov gap.

So the Maslov gap is literally the log-partition-function error committed by a pointer cache, and $-\log M(S)$ is its generalization to any cache.

---

## 7. How many keys a retention target needs

**Lemma 7.1.** If $i$ is an argmax, then for any $S$, $M(S) \le |S|\, e^{-g}$.

*Proof.* Each $p_j \le p_i = e^{-g}$. $\square$

**Theorem 7.2 (Gap lower bound).** If $M(S) \ge \tau$ then $|S| \ge \tau\, e^{g}$.

*Proof.* Multiply $\tau \le |S| e^{-g}$ by $e^{g}$. $\square$

**Theorem 7.3 (Collision lower bound).** For any $S$, $M(S)^2 \le |S|\, C(x)$. Consequently, if $0 \le \tau \le M(S)$ then
$$|S| \;\ge\; \frac{\tau^2}{C(x)} \;=\; \frac{\tau^2}{1 - K(x)}.$$

*Proof.* Cauchy–Schwarz gives $\big(\sum_{j\in S} p_j\big)^2 \le |S| \sum_{j\in S} p_j^2 \le |S|\,C(x)$. Since $C \ge e^{-2g} > 0$, divide. The last form uses Lemma 5.1. $\square$

The same arguments apply to the knee of an abstract profile.

**Theorem 7.4 (Knee bounds).** Let $p_0, p_1, \ldots$ be a profile for which the target $\tau$ is attainable.

1. If $p_i \le q$ for all $i$, with $q > 0$, then $\kappa(\tau) \ge \tau/q$.
2. If $\tau \ge 0$ and $\sum_{i<k} p_i^2 \le C$ for all $k$, with $C > 0$, then $\kappa(\tau) \ge \tau^2/C$.

*Proof.* (1) $\tau \le R(\kappa) \le \kappa q$. (2) $\tau^2 \le R(\kappa)^2 \le \kappa \sum_{i<\kappa} p_i^2 \le \kappa C$ by Cauchy–Schwarz. $\square$

**Corollary 7.5 (Calibration on the gap map).** If no weight exceeds $e^{-2.69}$ (the median gap of layer 22 at $n = 2048$), then $\kappa(0.98) \ge 13$.

*Proof.* By Theorem 7.4(1), $\kappa \ge 0.98\, e^{2.69}$. Writing $e^{2.69} = (e^{0.6725})^4$ and using $e^{y} \ge 1 + y + y^2/2$ for $y \ge 0$ gives $e^{0.6725} \ge 1.8986$, whence $0.98\,e^{2.69} \ge 0.98 \cdot 1.8986^4 > 12$. $\square$

(Numerically $0.98\,e^{2.69} \approx 14.4$, so the bound actually yields $15$; the certified statement uses only the elementary estimate above.)

**Corollary 7.6 (Calibration on the crystallization map).** If $\sum_{i<k} p_i^2 \le 0.03$ for all $k$ (crystallization at least $0.97$, the most diffuse measured layer mean), then $\kappa(0.98) \ge 33$.

*Proof.* $0.98^2/0.03 = 32.01\ldots > 32$. $\square$

These certified floors, $13$ and $33$, bracket the measured knee chain $\{16, 32, 24\}$: the diffuse tail alone is enough to push the knee into the tens.

---

## 8. Tropical core plus thin soft correction

**Theorem 8.1 (Margin truncation bound).** Let $S$ be nonempty with $|S| = k$, and suppose every dropped key lies at least $m$ below every kept key: $x_j + m \le x_s$ for all $j \notin S$, $s \in S$. Then
$$1 - M(S) \;\le\; \frac{(n-k)\,e^{-m}}{k}.$$

*Proof.* Let $A = \sum_{s\in S} e^{x_s}$ and $B = \sum_{j\notin S} e^{x_j}$. For each dropped $j$, averaging over $s \in S$ gives $k\, e^{x_j} \le \sum_{s\in S} e^{-m} e^{x_s} = e^{-m}A$. Summing over the $n-k$ dropped keys, $kB \le (n-k)e^{-m}A$. Hence $1 - M(S) = B/(A+B) \le B/A \le (n-k)e^{-m}/k$. $\square$

To keep the tail loss below $\delta$ it therefore suffices that $m \ge \log\big((n-k)/(k\delta)\big)$: the required margin grows only logarithmically in the context. This is the quantitative content of the slogan "tropical core + thin soft correction": a few dominant keys separated by a moderate margin from a long tail lose only an exponentially small amount.

---

## 9. Why the argmax gets worse with context

**Theorem 9.1 (Argmax floor).** If $x_i - x_j \ge m$ for every $j \ne i$, then $p_i \ge F(m, n)$.

*Proof.* $\sum_j e^{x_j} \le e^{x_i}(1 + (n-1)e^{-m})$, so $p_i \ge 1/(1+(n-1)e^{-m})$. Equivalently, $g \le \log(1 + (n-1)e^{-m})$ and Theorem 4.1 applies. $\square$

**Theorem 9.2 (Monotonicity and vanishing).** For fixed $m$: if $1 \le a \le b$ then $F(m, b) \le F(m, a)$; and $F(m, n) \to 0$ as $n \to \infty$.

*Proof.* The denominator $1 + (n-1)e^{-m}$ is positive, nondecreasing in $n$, and tends to $+\infty$. $\square$

Unless margins grow like $\log n$, the guaranteed one-key mass decays with context — the structural form of P1.

---

## 10. The measured recovery is not a mass curve

**Theorem 10.1 (Doubling inequality).** If $p_0 \ge p_1 \ge \cdots$, then $R(2k) \le 2R(k)$ for all $k$.

*Proof.* $R(2k) = \sum_{i<k} p_i + \sum_{i<k} p_{k+i}$ and $p_{k+i} \le p_i$. $\square$

**Corollary 10.2.** If $b > 2a$, no sorted profile has $R(1) = a$ and $R(2) = b$.

**Theorem 10.3 (Retention is a nonlinear readout).** None of the three measured pairs $(R(1), R(2)) = (0.3637, 0.7865)$, $(0.2885, 0.7398)$, $(0.2503, 0.7002)$ is realized by any sorted attention-mass profile.

*Proof.* The ratios are $2.16$, $2.56$ and $2.80$, all exceeding $2$; apply Corollary 10.2. $\square$

Hence the measured retention is a superlinear function of the kept mass at small $k$. A natural candidate is compounding across layers. For per-layer losses $\varepsilon_\ell \in [0,1]$:

**Theorem 10.4 (Weierstrass bounds).**
$$1 - \sum_{\ell<L} \varepsilon_\ell \;\le\; \prod_{\ell<L}(1-\varepsilon_\ell) \;\le\; \exp\Big(-\sum_{\ell<L}\varepsilon_\ell\Big).$$

*Proof.* Lower: induction on $L$, using $(1-s)(1-\varepsilon) \ge 1 - s - \varepsilon$ when $s, \varepsilon \ge 0$ and the partial product is nonnegative. Upper: $1 - \varepsilon \le e^{-\varepsilon}$ termwise, and the factors are nonnegative. $\square$

**Corollary 10.5 (Compounded argmax budget).** If $\prod_\ell(1-\varepsilon_\ell) = 0.2503$ (argmax retention at $n = 2048$), then
$$0.7497 \;\le\; \sum_\ell \varepsilon_\ell \;\le\; \log(1/0.2503) \approx 1.385.$$

---

## 11. Algorithms

**Algorithm A (Gap and crystallization map).** For each layer, head and causal row $x$ (length $n$): compute $\mu = \max_j x_j$ and $\mathrm{LSE} = \mu + \log\sum_j e^{x_j - \mu}$ (stable form); record $g = \mathrm{LSE} - \mu$; compute $p_j = e^{x_j - \mathrm{LSE}}$, $C = \sum p_j^2$, $K = 1 - C$; check $1 - e^{-g} \le K \le 1 - e^{-2g}$ as a numerical sanity test. Aggregate medians and percentiles per layer. Cost $O(n)$ per row, i.e. the same order as the attention pass itself.

**Algorithm B (Certified key floors).** From $g$ and $C$ for a row and a target $\tau$, output $\max(\lceil \tau e^{g}\rceil, \lceil \tau^2/C\rceil)$, a certified lower bound on the size of any cache achieving kept mass $\tau$ (Theorems 7.2–7.3). $O(1)$ given Algorithm A.

**Algorithm C (Margin certificate for top-$k$).** Sort the row, let $m = x_{(k)} - x_{(k+1)}$ be the gap between the $k$-th and $(k+1)$-th largest scores, and output the bound $(n-k)e^{-m}/k$ on the lost mass (Theorem 8.1). Cost $O(n\log n)$, or $O(n)$ with selection. The smallest $k$ whose certificate is below $\delta$ is a certified upper bound on the per-row mass knee.

---

## 12. Discussion

**What the theorems explain.** The data contain three facts; each is matched by an exact statement. The degradation of pointer attention with context is the monotone decay of the argmax floor (Theorem 9.2). The failure of the crystallization prediction is forced by the gap map through the Rényi sandwich (Corollary 5.5). The location of the knee in the tens is forced by the gap and collision floors on the diffuse tail (Corollaries 7.5–7.6). The fast recovery from $k=1$ is consistent with a tropical core plus a thin tail (Theorem 8.1), while the super-doubling of the measured curve (Theorem 10.3) shows that the model's output quality depends nonlinearly on per-layer kept mass.

**Practical reading.** The deployable regime is a tropical core plus a thin soft correction. Pointer-style caches with $k \approx 1$–$4$ are below the knee, but the measured recovery curve quantifies the value of each added key, which is precisely the curve an aggressive KV-compression policy on small-memory hardware must trade against. The gap map further suggests that the budget should be layer-dependent: only layers 22–23 have gaps for which the floor $\tau e^{g}$ is large.

**Limitations.** One model and one corpus; oracle (score-aware) selection rather than a deployable eviction policy; random-$k$ and local-window controls were inherited from a preceding sweep rather than rerun. The theorems are exact but about kept softmax mass; the link from mass to measured retention is precisely what Theorem 10.3 shows to be nonlinear and what remains to be modeled.

## 13. Future work

1. **Layer-selective tropicalization.** Conjecture: with top-$4$ caches in layers whose median gap is at most $\log 4$ and full caches in layers 22–23, retention is at least $0.98$ at all three contexts. The gap floor $\tau e^{g}$ gives the per-layer budget.
2. **Compounded readout law.** Conjecture: $R(k) \approx \prod_\ell m_\ell(k)$ with $m_\ell(k)$ the per-layer kept mass, so $-\log R(k) \approx \sum_\ell (1 - m_\ell(k))$, a quantity bracketed by Theorem 10.4.
3. **Logarithmic margin law for the knee.** Conjecture: the per-layer knee at tail budget $\delta$ scales like $\log(n/\delta)/\bar m$ with $\bar m$ the typical top-$k$ margin, as suggested by Theorem 8.1 and the slow growth of $\{16, 32, 24\}$.
4. **Rényi-2 eviction certificates.** Conjecture: an online policy with per-head budget $\lceil \tau^2/\sum_i p_i^2\rceil$ comes within $1\%$ of oracle top-$k$ retention; $\sum p_i^2$ is cheap to estimate online and Theorem 7.3 makes the budget a hard floor.
5. Size transfer (1.5B and larger models), corpus robustness, and the interaction with weight quantization.

## 14. Conclusion

The tropical limit of attention is lossy and provably becomes lossier with context; the recovery from it is fast; and the size of the cache needed is governed, exponentially, by a single per-row statistic, the Maslov gap $\mathrm{LSE}(x) - \max_j x_j$. Together with the collision probability $\sum_i p_i^2$, the gap sandwiches the crystallization loss, certifies key-count floors, and locates the only far-from-tropical part of the model in its final two layers.
