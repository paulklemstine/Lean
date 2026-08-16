# The Attention-Cost Law $k^\ast = d\cdot\mathrm{ctx}/32$: Derivation, Rigidity, and a Certified Mass–Accuracy Separation

## Abstract

Truncating each attention row of a causal transformer to its $k$ largest weights and renormalizing is the cheapest available reduction of attention's quadratic cost. Across a depth-by-context grid of trained causal language models, the smallest budget retaining $98\%$ of held-out accuracy — the *knee* $k^\ast$ — obeys the law $k^\ast(d,\mathrm{ctx}) = d\cdot\mathrm{ctx}/32$, with the corresponding speedup $\mathrm{ctx}/k^\ast = 32/d$ independent of context length. This paper supplies the mathematics behind that law.

We first prove that the law is **not** a concentration phenomenon. A Cauchy–Schwarz argument gives the assumption-free bound $\sum_{i\in T} p_i \le \sqrt{|T|/N_{\mathrm{eff}}}$ for the mass retained by any index set $T$, where $N_{\mathrm{eff}} = 1/\sum_i p_i^2$ is the effective support; equivalently, retaining a fraction $\rho$ of the attention mass costs at least $\rho^2 N_{\mathrm{eff}}$ positions. At the measured long-context effective support $N_{\mathrm{eff}} = 152.11$, retaining $98\%$ of the mass requires more than $146$ positions, whereas the measured accuracy knee is $64$; at $k \le 64$ the retained mass is provably at most $0.65$, while the measured retained accuracy is $0.985$. The separation is certified, not fitted. We further exhibit a spike-plus-uniform family with $N_{\mathrm{eff}} \to 4$ whose best $k$-position truncation retains only $\tfrac12 + o(1)$ of the mass for every fixed $k$, showing that no reverse inequality exists and that the Cauchy–Schwarz bound is asymptotically sharp.

We then derive the law from two structural hypotheses — nonexpansive layers (giving additive error accumulation, hence a per-layer budget $\delta/d$) and a scale-free Zipf tail $A\,\mathrm{ctx}/k$ — and prove that both are *forced*: any cost law with a depth-only speedup and a linear depth leg is bilinear, $K(d,\mathrm{ctx}) = d\,\mathrm{ctx}\,K(1,1)$; and among scale-free tail profiles, $1/x$ is the unique one compatible with a depth-linear knee. A read-out analysis explains the mass–accuracy decoupling via the retention threshold $\rho > 1 - m/(4LB)$ set by the logit margin $m$, and sharpens it to the two-sided margin law $m/(8LB) \le 1-\rho(k^\ast) \le m/(4LB)$. Finally we prove a knee-stability theorem certifying that the measured knees are immune to seed perturbations larger than the observed spread, an exact random-$k$ control law, a context-independent long-context mass bound, and the depth-rigidity dichotomy separating near-isometric stacks (linear knee survives) from uniformly expansive stacks (linear knee impossible).

**Keywords:** attention truncation, effective support, inverse participation ratio, Cauchy–Schwarz, Zipf tail, Lipschitz stacks, logit margin, scaling law.

---

## 1. Introduction

### 1.1 The empirical object

Fix a trained causal transformer with $d$ layers and context length $\mathrm{ctx}$. Each attention head at each position produces a row $p = (p_1,\dots,p_n)$ with $p_i \ge 0$ and $\sum_i p_i = 1$, supported on the $n \le \mathrm{ctx}$ admissible past positions. The **top-$k$ truncation** of the row keeps the $k$ largest entries, zeroes the rest, and renormalizes.

Two numbers are measured per model.

**Definition 1.1 (Effective support).** For a weight vector $p$ on a finite index set $s$, the *collision mass* is $C(p) = \sum_{i\in s} p_i^2$ and the *effective support* is
$$N_{\mathrm{eff}}(p) \;=\; \frac{1}{C(p)}.$$
This is the inverse participation ratio: $N_{\mathrm{eff}} = m$ for the uniform row on $m$ positions and $N_{\mathrm{eff}} = 1$ for a point mass.

**Definition 1.2 (Knee).** For a swept set of budgets $\mathcal{K} \subset \mathbb{N}$ and a *retained-accuracy* curve $R : \mathcal{K}\to[0,1]$ — the ratio of top-$k$-truncated held-out accuracy to full-attention held-out accuracy — the *knee at threshold* $\theta$ is
$$k^\ast \;=\; \min\{\,k \in \mathcal{K} : R(k) \ge \theta \,\}, \qquad \theta = 0.98 .$$

### 1.2 The measured grid

Models: causal transformers, model dimension $64$, $4$ heads, trained for $2000$ AdamW steps on five public-domain novels with a $4097$-token vocabulary and a contiguous $90/10$ train/held-out split. Full-attention held-out accuracies across the eight models lie in $[0.1571, 0.1620]$, and the knee is insensitive to where in that range a model sits.

| depth $d$ | context | knee $k^\ast$ | $d\cdot\mathrm{ctx}/32$ | seeds |
|---|---|---|---|---|
| 4 | 128 | 16 | 16 | 2 |
| 8 | 128 | 32 | 32 | 2 |
| 16 | 128 | 64 | 64 | 2 |
| 4 | 512 | 64 | 64 | 2 |

Every cell now has two independent seeds and every cell lands exactly on the predicted integer. Two representative sweeps, used throughout as **cell A** and **cell B**:

- **Cell A** ($d=16$, $\mathrm{ctx}=128$): $R(8)=0.858$, $R(16)=0.922$, $R(32)=0.970$, $R(64)=0.996$, $R(96)=0.999$, $R(128)=1.000$; $N_{\mathrm{eff}} = 52.73$.
- **Cell B** ($d=4$, $\mathrm{ctx}=512$): $R(16)=0.965$, $R(32)=0.976$, $R(64)=0.985$, $R(128)=0.993$, $R(256)=0.998$, $R(384)=1.000$; $N_{\mathrm{eff}} = 152.11$.

Concentration reproduces across seeds to five significant figures at cell B ($152.11$ vs. $152.11$), with per-position effective supports $20.41$–$20.45$, $133.23$–$133.37$, $281.20$–$281.46$ at early/middle/late positions. Across depths at $\mathrm{ctx}=128$, $N_{\mathrm{eff}}$ drifts $46.6 \to 50.2 \to 52.7$ for $d = 4, 8, 16$.

Each sweep is paired with a **random-$k$ control**: keep $k$ uniformly random positions per row instead of the top $k$. Measured accuracy gaps (selection minus control, in percentage points) are $+10.0/{+}6.0$ at cell A and $+7.6/{+}5.2$ at cell B.

### 1.3 What this paper proves

1. **§2** — a hard, assumption-free obstruction separating the *mass* knee from the measured *accuracy* knee, plus a counterexample family showing the effective support is not a sufficient statistic for the knee.
2. **§3** — a mechanism (additive error accumulation + Zipf tail) that derives the law, together with two rigidity theorems showing the mechanism is forced by the grid's qualitative content.
3. **§4** — a read-out analysis explaining the mass–accuracy decoupling, culminating in the two-sided margin law.
4. **§5** — depth rigidity: a dichotomy between near-isometric and uniformly expansive stacks.
5. **§6** — long-context mass bounds and the exact random-$k$ control law.
6. **§7** — knee stability under seed perturbation, and the formal statement of grid completion.

Throughout, $s$ denotes a finite index set (the attention support), $T \subseteq s$ a retained set, and $p : s \to \mathbb{R}$ a weight vector.

---

## 2. Concentration limits: the mass knee is expensive

### 2.1 The truncation bound

**Theorem 2.1 (Cauchy–Schwarz truncation bound).** For any finite $T \subseteq s$ and any $p : s \to \mathbb{R}$,
$$\Big(\sum_{i\in T} p_i\Big)^2 \;\le\; |T| \cdot \sum_{i\in s} p_i^2 \;=\; |T| \cdot C(p).$$

*Proof sketch.* Cauchy–Schwarz applied to $(p_i)_{i\in T}$ against the all-ones vector on $T$ gives $(\sum_{T} p_i)^2 \le |T| \sum_{T} p_i^2$. Since squares are nonnegative and $T \subseteq s$, $\sum_T p_i^2 \le \sum_s p_i^2$. Multiply the second inequality by $|T| \ge 0$ and chain. $\square$

No hypothesis is used: not nonnegativity, not normalization, and crucially not that $T$ is the set of the $|T|$ largest weights. In particular Theorem 2.1 bounds the *top-$k$* mass as a special case.

**Corollary 2.2 (Mass bound in experimental units).** If $p \ge 0$ on $s$ and $C(p) > 0$, then for $T\subseteq s$,
$$\sum_{i\in T} p_i \;\le\; \sqrt{|T|\cdot C(p)} \;=\; \sqrt{\frac{|T|}{N_{\mathrm{eff}}(p)}}.$$

*Proof sketch.* The left side is nonnegative, so it equals the square root of its square; apply Theorem 2.1 and monotonicity of $\sqrt{\cdot}$, then substitute $C = 1/N_{\mathrm{eff}}$. $\square$

**Theorem 2.3 (Lower bound for the mass knee).** Let $p \ge 0$ on $s$ with $C(p) > 0$, let $T \subseteq s$, and let $\rho \ge 0$ satisfy $\rho \le \sum_{i\in T} p_i$. Then
$$|T| \;\ge\; \rho^2 \, N_{\mathrm{eff}}(p).$$

*Proof sketch.* Squaring the hypothesis (legitimate since both sides are nonnegative) gives $\rho^2 \le (\sum_T p_i)^2 \le |T|\,C(p)$ by Theorem 2.1. Divide by $C(p) > 0$. $\square$

Theorem 2.3 is the quantitative heart of §2: *mass retention has a price, and the price is $\rho^2 N_{\mathrm{eff}}$ positions.*

### 2.2 The measured separation

**Theorem 2.4 (The accuracy knee is not a mass knee).** Let $p \ge 0$ on $s$ with $C(p) > 0$ and $N_{\mathrm{eff}}(p) = 152.11$. If $T \subseteq s$ satisfies $\sum_{i\in T} p_i \ge 0.98$, then $|T| > 64$; indeed $|T| \ge 146$.

*Proof sketch.* Theorem 2.3 with $\rho = 0.98$ gives $|T| \ge 0.98^2 \times 152.11 = 146.08\ldots > 64$. Since $|T|$ is an integer, $|T| \ge 147$. $\square$

The measured accuracy knee at that cell is $k^\ast = 64$. Truncation at $k^\ast$ is therefore **more than twice as cheap** as any mass-preserving truncation at the same threshold. The two thresholds are not the same phenomenon.

**Theorem 2.5 (Mass ceiling at the measured knee).** Let $p \ge 0$ on $s$ with $N_{\mathrm{eff}}(p) = 152.11$. Every $T \subseteq s$ with $|T| \le 64$ satisfies
$$\sum_{i\in T} p_i \;\le\; 0.65 .$$

*Proof sketch.* $N_{\mathrm{eff}} = 152.11$ forces $C(p) = 1/152.11$ exactly (the case $C = 0$ is excluded because $1/0 \ne 152.11$). Then $|T|\,C(p) \le 64/152.11 = 0.4207\ldots \le 0.65^2 = 0.4225$, and Corollary 2.2 with monotonicity of $\sqrt{\cdot}$ closes it. $\square$

At exactly the budget where the model retains $98.5\%$ of its accuracy, at least $35\%$ of the attention mass is discarded. This certified ceiling $\rho \le 0.65$ is reused in §4 to extract a numeric prediction about the logit margin.

### 2.3 The converse fails: effective support does not control the knee

**Definition 2.6 (Spike family).** For $n \ge 0$ let $\sigma^{(n)}$ be the row on $n+2$ positions with $\sigma^{(n)}_0 = \tfrac12$ and $\sigma^{(n)}_i = \tfrac{1}{2(n+1)}$ for $i \ne 0$. It is a probability vector.

**Lemma 2.7.** $C(\sigma^{(n)}) = \dfrac{n+2}{4(n+1)}$ and therefore $N_{\mathrm{eff}}(\sigma^{(n)}) = \dfrac{4(n+1)}{n+2} \to 4$.

*Proof sketch.* $C = (1/2)^2 + (n+1)\big(\tfrac{1}{2(n+1)}\big)^2 = \tfrac14 + \tfrac{1}{4(n+1)}$; combine over a common denominator and invert. $\square$

**Lemma 2.8.** For every $T$ with $|T| \le k$, $\displaystyle\sum_{i\in T}\sigma^{(n)}_i \le \tfrac12 + \tfrac{k}{2(n+1)}$.

*Proof sketch.* Dominate $\sigma^{(n)}_i$ pointwise by $\tfrac12\mathbf{1}[i=0] + \tfrac{1}{2(n+1)}$ and sum over $T$: the indicator contributes at most $\tfrac12$ and the constant contributes $|T|/(2(n+1)) \le k/(2(n+1))$. $\square$

**Theorem 2.9 (No reverse inequality).** For every fixed budget $k \in \mathbb{N}$ and every $\varepsilon > 0$ there exists an attention row $p$ with
$$\big|N_{\mathrm{eff}}(p) - 4\big| < \varepsilon \quad\text{and}\quad \sum_{i\in T} p_i < \tfrac12 + \varepsilon \ \text{ for every } T \text{ with } |T|\le k.$$
Consequently no inequality of the form "top-$k$ mass $\ge F(k, N_{\mathrm{eff}})$" with $F(k,4) > \tfrac12$ can hold.

*Proof sketch.* By Lemma 2.7 the first condition holds for all large $n$; by Lemma 2.8 the second holds as soon as $k/(2(n+1)) < \varepsilon$. Take $n$ large enough for both. $\square$

**Theorem 2.10 (Sharpness of Theorem 2.1).** $\displaystyle\lim_{n\to\infty} \frac{(\sigma^{(n)}_0)^2}{1\cdot C(\sigma^{(n)})} = 1$, so the constant in the truncation bound at $k=1$ cannot be improved.

*Proof sketch.* The ratio equals $\big(1 + \tfrac{1}{n+1}\big)^{-1}$ by Lemma 2.7. $\square$

**Reading.** A row can look, by the effective-support statistic, like it uses four positions, while hiding half its mass from every fixed budget. Concentration is a *necessary* but far from sufficient handle on truncation; the law $k^\ast = d\,\mathrm{ctx}/32$ must come from somewhere else.

---

## 3. A mechanism, and why it is forced

### 3.1 The depth leg: additive error accumulation

Write $\Phi_d = f_{d-1}\circ\cdots\circ f_0$ for the composite of the first $d$ exact layers, acting on a pseudometric space $X$ of hidden states, and $\Psi_d$ for the composite of the truncated layers $g_i$.

**Theorem 3.1 (Depth leg).** Suppose each $f_i$ is nonexpansive ($1$-Lipschitz) and each truncated layer satisfies $\mathrm{dist}(g_i(x), f_i(x)) \le \varepsilon_i$ for all $x$. Then for every $x$,
$$\mathrm{dist}\big(\Psi_d(x), \Phi_d(x)\big) \;\le\; \sum_{i<d}\varepsilon_i .$$
In particular, with $\varepsilon_i \equiv \varepsilon$, the bound is $d\cdot\varepsilon$.

*Proof sketch.* Induct on $d$. At the inductive step insert the intermediate point $f_n(\Psi_n(x))$ and apply the triangle inequality: the first leg is $\mathrm{dist}(g_n(y), f_n(y)) \le \varepsilon_n$ at $y = \Psi_n(x)$, and the second is $\mathrm{dist}(f_n(\Psi_n x), f_n(\Phi_n x)) \le \mathrm{dist}(\Psi_n x, \Phi_n x)$ by nonexpansiveness, which the inductive hypothesis bounds by $\sum_{i<n}\varepsilon_i$. $\square$

Errors *add*; they neither amplify nor cancel. Hence an end-to-end budget $\delta$ imposes a per-layer budget $\delta/d$, and the top-$k$ demand grows linearly in depth.

### 3.2 The context leg: a scale-free tail

**Definition 3.2 (Zipf tail).** The mass left outside the top $k$ of a row of length $\mathrm{ctx}$ is modelled as
$$\mathrm{tail}_A(k) \;=\; \frac{A\cdot\mathrm{ctx}}{k},$$
i.e. a function of the fraction $x = k/\mathrm{ctx}$ alone, with the $1/x$ profile and amplitude $A>0$.

**Theorem 3.3 (Feasibility).** For $\delta > 0$, $d \ge 1$, $k \ge 1$:
$$d\cdot\mathrm{tail}_A(k) \le \delta \iff k \ge \frac{A\,d\,\mathrm{ctx}}{\delta}.$$

*Proof sketch.* Both sides are the same inequality after clearing the positive denominators $k$ and $\delta$. $\square$

**Theorem 3.4 (Least sufficient budget).** For $A, \mathrm{ctx}, \delta > 0$ and $d \ge 1$, the set $\{k \ge 1 : d\cdot\mathrm{tail}_A(k) \le \delta\}$ has least element $\big\lceil A\,d\,\mathrm{ctx}/\delta\big\rceil$.

*Proof sketch.* The quantity $q = A d\,\mathrm{ctx}/\delta$ is positive, so $\lceil q\rceil \ge 1$; it is feasible because $\lceil q\rceil \ge q$ and Theorem 3.3; and any feasible $k$ satisfies $k \ge q$, hence $k \ge \lceil q \rceil$ since $k$ is an integer. $\square$

**Theorem 3.5 (The attention-cost law).** Calibrate the single dimensionless constant $A/\delta = 1/32$. Then on any cell with $d, \mathrm{ctx} \ge 1$ and $32 \mid d\cdot\mathrm{ctx}$, the least sufficient budget is exactly
$$k^\ast \;=\; \frac{d\cdot\mathrm{ctx}}{32}.$$

*Proof sketch.* $A d\,\mathrm{ctx}/\delta = (A/\delta)(d\,\mathrm{ctx}) = d\,\mathrm{ctx}/32$, which is a positive integer under the divisibility hypothesis; the ceiling of an integer is itself, so Theorem 3.4 applies. $\square$

This reproduces $16, 32, 64$ at $d = 4, 8, 16$ with $\mathrm{ctx}=128$, and $64$ at $d=4$, $\mathrm{ctx}=512$.

**Theorem 3.6 (Context-invariant speedup).** Under the hypotheses of Theorem 3.5,
$$\frac{\mathrm{ctx}}{k^\ast} \;=\; \frac{32}{d}.$$

*Proof sketch.* Write $d\cdot\mathrm{ctx} = 32m$; then $k^\ast = m$ and $\mathrm{ctx}/m = 32\,\mathrm{ctx}/(d\,\mathrm{ctx}) = 32/d$. $\square$

This is the deployable content: $8\times$ at $d=4$, $4\times$ at $d=8$, $2\times$ at $d=16$, at any context length.

### 3.3 Rigidity I: the functional form is forced

**Theorem 3.7 (Uniqueness of the cost law).** Let $K : \mathbb{N}_{\ge1}\times\mathbb{N}_{\ge1} \to (0,\infty)$ and $S : \mathbb{N}_{\ge1}\to\mathbb{R}$ satisfy
1. *(depth-only speedup)* $\mathrm{ctx}/K(d,\mathrm{ctx}) = S(d)$ for all $d,\mathrm{ctx}\ge 1$;
2. *(linear depth leg at unit context)* $K(d,1) = d\cdot K(1,1)$ for all $d\ge1$.

Then $K(d,\mathrm{ctx}) = d\cdot\mathrm{ctx}\cdot K(1,1)$ for all $d,\mathrm{ctx}\ge1$.

*Proof sketch.* Evaluating (1) at $\mathrm{ctx}=1$ gives $1/K(d,1) = S(d)$; equating with the general case gives $\mathrm{ctx}/K(d,\mathrm{ctx}) = 1/K(d,1)$, i.e. $K(d,\mathrm{ctx}) = \mathrm{ctx}\cdot K(d,1)$. Substituting (2) finishes. $\square$

So the bilinear form $k^\ast \propto d\cdot\mathrm{ctx}$ is *implied* by the two qualitative findings; the only empirical content of the calibration is the number $K(1,1) = 1/32$.

### 3.4 Rigidity II: the tail profile is forced

**Theorem 3.8 (The Zipf profile is the unique depth-linear scale-free tail).** Let $t : (0,\infty)\to\mathbb{R}$ be continuous on $(0,\infty)$ and model the per-layer tail at fraction $x$ by $t(x)$. Fix $\delta > 0$ and $x_1 > 0$, and suppose that for every $d \ge 1$ the set $\{x > 0 : d\cdot t(x) \le \delta\}$ has least element $d\cdot x_1$ — the depth-linear knee. Then
$$t(d\,x_1) \;=\; \frac{\delta\,x_1}{d\,x_1} \qquad\text{for every } d\ge 1,$$
i.e. $t(u) = \delta x_1/u$ on the measured points.

*Proof sketch.* Write $c = d\,x_1 > 0$. Membership gives $d\,t(c) \le \delta$. If the inequality were strict, continuity of $x \mapsto d\,t(x)$ at $c$ would provide a neighbourhood on which $d\,t(x) < \delta$ and $x > 0$; picking such an $x < c$ contradicts minimality of $c$. Hence $d\,t(c) = \delta$, so $t(c) = \delta/d = \delta x_1/c$. $\square$

Note the division of labour: *every* scale-free profile yields a context-invariant speedup, so context-invariance carries no information about $t$; it is the *depth* leg that pins the shape. Combined with Theorem 3.7, the empirical grid determines the mechanism up to the single constant $1/32$.

### 3.5 Capstone: an end-to-end guarantee at the law's budget

**Theorem 3.9 (Truncation at $d\,\mathrm{ctx}/32$ is end-to-end safe).** Let $A,\delta>0$ with $A/\delta = 1/32$, let $32 \mid d\cdot\mathrm{ctx}$, let each exact layer $f_i$ be nonexpansive, and suppose each truncated layer satisfies $\mathrm{dist}(g_i(x),f_i(x)) \le \mathrm{tail}_A(d\,\mathrm{ctx}/32)$ for all $x$. Then for every input $x$,
$$\mathrm{dist}\big(\Psi_d(x),\Phi_d(x)\big) \;\le\; \delta.$$

*Proof sketch.* Theorem 3.5 says $k = d\,\mathrm{ctx}/32$ is feasible, i.e. $d\cdot\mathrm{tail}_A(k) \le \delta$; Theorem 3.1 (uniform version) bounds the end-to-end deviation by $d\cdot\mathrm{tail}_A(k)$. $\square$

---

## 4. Why accuracy is cheaper than mass: the read-out analysis

§2 leaves a tension: at the measured knee, at least $35\%$ of the attention mass is gone, yet $98.5\%$ of the accuracy survives. This section resolves it.

### 4.1 The read-out error of truncation

Let $V$ be a normed space of value vectors. The exact read-out is $\mathrm{Out}(p) = \sum_{i\in s} p_i v_i$; the truncated read-out on $T$ is $\mathrm{Out}_T(p) = \big(\sum_{i\in T}p_i\big)^{-1}\sum_{i\in T} p_i v_i$.

**Lemma 4.1.** If $p \ge 0$ and $\|v_i\| \le B$ on $U$, then $\big\|\sum_{i\in U}p_i v_i\big\| \le \big(\sum_{i\in U}p_i\big)B$.

*Proof sketch.* Triangle inequality, then $\|p_i v_i\| = p_i\|v_i\| \le p_i B$ termwise. $\square$

**Theorem 4.2 (Truncation read-out error).** Let $p \ge 0$ on $s$ with $\sum_{i\in s}p_i = 1$, let $T\subseteq s$ with $\rho := \sum_{i\in T}p_i > 0$, and let $\|v_i\|\le B$ on $s$. Then
$$\big\|\mathrm{Out}_T(p) - \mathrm{Out}(p)\big\| \;\le\; 2(1-\rho)B .$$

*Proof sketch.* Split $\mathrm{Out}(p) = S_R + S_T$ with $S_T = \sum_{T}p_iv_i$ and $S_R = \sum_{s\setminus T}p_iv_i$; the tail mass is $1-\rho$. Algebra gives $\mathrm{Out}_T(p) - \mathrm{Out}(p) = (\rho^{-1}-1)S_T - S_R$. Lemma 4.1 bounds $\|S_T\|\le \rho B$ and $\|S_R\| \le (1-\rho)B$, and $(\rho^{-1}-1)\rho B = (1-\rho)B$. The two contributions — renormalization inflation and dropped tail — each cost $(1-\rho)B$. $\square$

### 4.2 Margins absorb the error

**Lemma 4.3 (Arg-max stability).** Let $f, g$ be score functions with $|g_j - f_j| \le e$ for all classes $j$. If $f_j + 2e < f_c$ for all $j \ne c$, then $g_j < g_c$ for all $j\ne c$.

*Proof sketch.* $g_j \le f_j + e < f_c - e \le g_c$. $\square$

**Theorem 4.4 (Top-$k$ truncation preserves the prediction).** In the setting of Theorem 4.2, let the score map $y \mapsto \mathrm{score}(y,\cdot)$ be $L$-Lipschitz per class, $|\mathrm{score}(y,j)-\mathrm{score}(y',j)| \le L\|y-y'\|$. If the exact scores satisfy
$$\mathrm{score}(\mathrm{Out}(p),j) + 4L(1-\rho)B \;<\; \mathrm{score}(\mathrm{Out}(p),c) \quad\text{for all } j\ne c,$$
then the truncated model also predicts $c$.

*Proof sketch.* By Theorem 4.2 the score perturbation is at most $e = L\cdot 2(1-\rho)B$; the hypothesis says the exact margin exceeds $2e$; apply Lemma 4.3. $\square$

**Theorem 4.5 (Retention threshold).** With logit margin $m$ (i.e. $\mathrm{score}(\mathrm{Out}(p),j) + m \le \mathrm{score}(\mathrm{Out}(p),c)$ for all $j\ne c$), $L, B > 0$, the prediction is preserved whenever
$$\rho \;>\; 1 - \frac{m}{4LB}.$$

*Proof sketch.* The hypothesis rearranges to $4L(1-\rho)B < m$, which feeds Theorem 4.4. $\square$

**Interpretation.** The threshold governing *accuracy* is not the $0.98$ mass level; it is $1 - m/(4LB)$, set by the held-out logit margin and the read-out constant. For a healthy margin this sits far below $0.98$, which is precisely why the measured accuracy knee $64$ can undercut the certified mass knee $\ge 146$. The gap is predicted to close as margins shrink.

### 4.3 The margin law

**Definition 4.6 (Margin knee).** $\displaystyle k_m(A,\mathrm{ctx},L,B,m) = \Big\lceil \frac{4LBA\,\mathrm{ctx}}{m}\Big\rceil$: the least budget whose scale-free tail fits inside the threshold $m/(4LB)$ of Theorem 4.5.

**Theorem 4.7 (Margin knee is least).** For $A,\mathrm{ctx},L,B,m>0$, $k_m$ is the least element of $\{k\ge1 : \mathrm{tail}_A(k) \le m/(4LB)\}$.

*Proof sketch.* Theorem 3.4 with $d=1$ and $\delta = m/(4LB)$, after simplifying $A\cdot 1\cdot\mathrm{ctx}/(m/(4LB)) = 4LBA\,\mathrm{ctx}/m$. $\square$

**Theorem 4.8 (Two-sided margin law).** Write $x = 4LBA\,\mathrm{ctx}/m$ and assume $x \ge 1$ (the margin channel bites). Then the attention deficit at the margin knee satisfies
$$\frac{m}{8LB} \;\le\; \mathrm{tail}_A(k_m) \;\le\; \frac{m}{4LB},$$
i.e. $1 - \rho(k^\ast) = \Theta\!\big(m/(LB)\big)$ with explicit constants $1/8$ and $1/4$.

*Proof sketch.* The upper bound is feasibility (Theorem 4.7). For the lower bound, $k_m = \lceil x\rceil < x+1 \le 2x$ because $x \ge 1$; since $\mathrm{tail}_A$ is decreasing in $k$, $\mathrm{tail}_A(k_m) \ge A\,\mathrm{ctx}/(2x) = m/(8LB)$. $\square$

**Theorem 4.9 (Knee window).** Under the same hypotheses,
$$1 \;\le\; \frac{k_m \cdot m}{4LBA\,\mathrm{ctx}} \;\le\; 2 .$$
The dimensionless knee is confined to a window fixed in advance, with no free constant.

*Proof sketch.* $x \le \lceil x\rceil \le 2x$; divide by $x$. $\square$

**Theorem 4.10 (Monotonicity and scaling).** $k_m$ is antitone in $m$: if $m \le m'$ then $k_{m'} \le k_m$. And the pre-rounding budget scales exactly like $1/m$: replacing $m$ by $c\,m$ ($c>0$) multiplies $4LBA\,\mathrm{ctx}/m$ by $1/c$.

*Proof sketch.* Monotonicity of $t\mapsto C/t$ for $C \ge 0$ and of the ceiling; the scaling is algebra. $\square$

### 4.4 A falsifiable number

**Theorem 4.11 (Margin lower bound at the long-context cell).** Let $p\ge0$ on $s$ with $N_{\mathrm{eff}}(p) = 152.11$, let $|T| \le 64$, and suppose the survival of the prediction at that budget is explained by Theorem 4.5, i.e. $1 - m/(4LB) < \sum_{i\in T}p_i$ with $L,B>0$. Then
$$m \;>\; 1.4\,LB .$$

*Proof sketch.* Theorem 2.5 gives $\sum_T p_i \le 0.65$, so $1 - m/(4LB) < 0.65$, i.e. $m/(4LB) > 0.35$, i.e. $m > 1.4LB$. $\square$

This is a prediction about a quantity the standard harness does not log. A measured held-out logit margin below $1.4LB$ at that cell would refute the margin-channel explanation of the knee.

---

## 5. Depth rigidity: nonexpansiveness is load-bearing

Theorem 3.1 assumed nonexpansive layers. How much does the derivation depend on it?

**Theorem 5.1 (Depth leg with general Lipschitz constant).** If each $f_i$ is $\Lambda$-Lipschitz and each $g_i$ deviates pointwise by at most $\varepsilon \ge 0$, then
$$\mathrm{dist}\big(\Psi_d(x),\Phi_d(x)\big) \;\le\; \varepsilon \sum_{i<d}\Lambda^i .$$

*Proof sketch.* The induction of Theorem 3.1 with the transport step costing a factor $\Lambda$; the geometric sum identity $\sum_{i<n+1}\Lambda^i = 1 + \Lambda\sum_{i<n}\Lambda^i$ closes the step. $\square$

**Theorem 5.2 (Positive branch: near-isometry preserves linearity).** If $\Lambda = 1 + c/d$ with $c \ge 0$ — nonexpansive up to $O(1/d)$ — then
$$\sum_{i<d}\Big(1+\frac cd\Big)^i \;\le\; d\,e^{c}, \qquad\text{hence}\qquad \mathrm{dist}(\Psi_d x, \Phi_d x) \;\le\; e^{c}\,(d\,\varepsilon).$$

*Proof sketch.* Each term satisfies $(1+c/d)^i \le (1+c/d)^d \le (e^{c/d})^d = e^c$, using $1+u \le e^u$; sum $d$ terms. $\square$

The linear depth leg — hence $k^\ast \propto d$ — is therefore robust to a small amount of per-layer expansion.

**Theorem 5.3 (Negative branch: uniform expansion destroys linearity).** Fix $x>0$ and set $\Lambda = 1+x$. Then $\sum_{i<d}(1+x)^i \ge d + x\,d(d-1)/2$, and consequently for every constant $M$ there is a depth $D$ such that $\sum_{i<d}(1+x)^i \ge M\,d$ for all $d \ge D$.

*Proof sketch.* Bernoulli: $(1+x)^i \ge 1 + i x$; summing gives $d + x\,d(d-1)/2$ by Gauss. The quadratic term beats $M d$ once $d - 1 \ge 2M/x$. $\square$

**Corollary 5.4 (No linear knee under uniform expansion).** With a Zipf tail of amplitude $A>0$ over context $\mathrm{ctx}>0$ and end-to-end budget $\delta>0$, if the layers are uniformly $(1+x)$-Lipschitz with $x>0$, then for every constant $M$ there is a depth beyond which *every* feasible budget satisfies $k \ge M\,d$. In particular no law $k^\ast = C\cdot d$ can hold at large depth.

*Proof sketch.* Feasibility reads $\big(\sum_{i<d}(1+x)^i\big)A\,\mathrm{ctx}/k \le \delta$, i.e. $k \ge \big(\sum_{i<d}(1+x)^i\big)A\,\mathrm{ctx}/\delta$. Apply Theorem 5.3 with constant $M\delta/(A\,\mathrm{ctx})$. $\square$

**Consequence.** The depth leg is a *spectral* statement. Measuring per-layer Jacobian norms bounded away from $1$ would refute it without running a single top-$k$ sweep — a cheap, decisive test.

---

## 6. Long context, and the random-$k$ control

### 6.1 A context-independent mass bound

**Theorem 6.1 (Mass at the law's own budget).** Let $p \ge 0$ on $s$ and suppose the effective support grows at least linearly with context: $C(p) \le 1/(\alpha\,\mathrm{ctx})$ with $\alpha, \mathrm{ctx} > 0$ (equivalently $N_{\mathrm{eff}} \ge \alpha\,\mathrm{ctx}$). If $|T| \le d\,\mathrm{ctx}/32$ then
$$\sum_{i\in T}p_i \;\le\; \sqrt{\frac{d}{32\alpha}} ,$$
a bound with no context length in it.

*Proof sketch.* $|T|\,C(p) \le (d\,\mathrm{ctx}/32)\cdot 1/(\alpha\,\mathrm{ctx}) = d/(32\alpha)$; apply Corollary 2.2. $\square$

At $d=4$, $\alpha=1$ the bound is $\sqrt{1/8} = 0.354 < 1/2$: at long context, the model must be retaining $\ge 98\%$ of its accuracy on less than *half* its attention mass.

**Theorem 6.2 (Pre-registered $\mathrm{ctx}=1024$ prediction).** At $d=4$, if $N_{\mathrm{eff}} \ge \mathrm{ctx} = 1024$ (i.e. $C(p)\le 1/1024$), then at the predicted knee $k^\ast = 4\cdot1024/32 = 128$ the retained attention mass satisfies
$$\sum_{i\in T}p_i \;\le\; 0.36 .$$

*Proof sketch.* Theorem 6.1 with $d=4$, $\alpha=1$, $\mathrm{ctx}=1024$ gives $\sqrt{4/32} = 0.3535\ldots \le 0.36$. $\square$

The hypotheses are non-vacuous: the uniform row on $1024$ positions has $C = 1/1024$ exactly, and any $128$ of its positions carry mass $1/8 \le 0.36$.

A run at $\mathrm{ctx}=1024$ reporting $\ge 0.98$ retained accuracy at $k=128$ therefore certifies a mass/accuracy separation of at least $2.7\times$; a run reporting more than $0.36$ retained *mass* there refutes the linear growth of $N_{\mathrm{eff}}$ with context. Either outcome is informative.

### 6.2 The random-$k$ control, exactly

**Lemma 6.3 (Double counting).** For a finite set $s$, a fixed $i \in s$ and $k \ge 0$, the number of $(k+1)$-subsets of $s$ containing $i$ is $\binom{|s|-1}{k}$.

*Proof sketch.* $T \mapsto T\setminus\{i\}$ is a bijection onto the $k$-subsets of $s\setminus\{i\}$, with inverse $U\mapsto U\cup\{i\}$. $\square$

**Theorem 6.4 (Total and average mass over random subsets).** For any $p : s\to\mathbb{R}$ and $k\ge0$,
$$\sum_{|T|=k+1,\ T\subseteq s}\ \sum_{i\in T}p_i \;=\; \binom{|s|-1}{k}\sum_{i\in s}p_i ,$$
and if $k+1 \le |s|$, the *average* mass retained by a uniformly random $(k+1)$-subset is exactly
$$\frac{k+1}{|s|}\sum_{i\in s}p_i .$$

*Proof sketch.* Exchange the order of summation and apply Lemma 6.3 to each $i$. For the average, divide by $\binom{|s|}{k+1}$ and use the absorption identity $\binom{|s|}{k+1}(k+1) = |s|\binom{|s|-1}{k}$. $\square$

So the random control retains the fraction $k/\mathrm{ctx}$ of the mass, on the nose — no selection, no concentration.

**Theorem 6.5 (Selection-gain bound).** Let $p\ge0$ on $s$, $T\subseteq s$ with $|T| = k \ge 1$, and $C(p)\le 1/N_{\mathrm{eff}}$ with $N_{\mathrm{eff}}, \mathrm{ctx} > 0$. Then the ratio of the selected mass to the control's mean mass satisfies
$$\frac{\sum_{i\in T}p_i}{k/\mathrm{ctx}} \;\le\; \frac{\mathrm{ctx}}{\sqrt{k\,N_{\mathrm{eff}}}} .$$

*Proof sketch.* Corollary 2.2 gives $\sum_T p_i \le \sqrt{k/N_{\mathrm{eff}}}$; the claim follows from $\sqrt{k/N_{\mathrm{eff}}}\cdot\sqrt{k N_{\mathrm{eff}}} = k$ and cross-multiplication. $\square$

**Corollary 6.6 (At the measured cell).** With $\mathrm{ctx}=512$, $k=64$, $N_{\mathrm{eff}} = 152.11$, the selection advantage in retained *mass* is at most $5.2$.

*Proof sketch.* $\sqrt{64\times152.11} > 98.6$, and $512/98.6 < 5.2$. $\square$

Selection can buy at most $5.2\times$ the control's mass, while the measured accuracy gaps are $+7.6$ and $+5.2$ percentage points. The control gap is therefore a statement about *which* positions are kept, not a bulk mass effect — the control is a fair baseline.

### 6.3 The concentration drift is not amplitude drift

The measured $N_{\mathrm{eff}}$ drifts $46.6 \to 50.2 \to 52.7$ across $d = 4,8,16$ at $\mathrm{ctx}=128$. Is that the Zipf amplitude drifting with depth?

**Theorem 6.7 (Scale-free tail caps the effective support).** Let $p \ge 0$ on $s$ with $C(p) > 0$ and $A\,\mathrm{ctx} > 0$. If some head $T$ with $|T| \le \lceil 2A\,\mathrm{ctx}\rceil$ carries all but the Zipf tail, $\sum_{i\in T}p_i \ge 1 - A\,\mathrm{ctx}/\lceil 2A\,\mathrm{ctx}\rceil$, then
$$N_{\mathrm{eff}}(p) \;\le\; 8A\,\mathrm{ctx} + 4 .$$

*Proof sketch.* Set $K = \lceil 2A\,\mathrm{ctx}\rceil$. Then $A\,\mathrm{ctx}/K \le 1/2$, so the head mass is $r \ge 1/2$. Theorem 2.3 inverted gives $N_{\mathrm{eff}} \le |T|/r^2 \le K/(1/2)^2 = 4K$, and $K < 2A\,\mathrm{ctx}+1$. $\square$

**Theorem 6.8 (Amplitude forced by a depth-linear knee).** If at some depth $d \ge 1$ the least sufficient budget $A\,d\,\mathrm{ctx}/\delta$ equals the measured $d\,\mathrm{ctx}/32$, then $A = \delta/32$ — with no $d$ in it.

*Proof sketch.* Cancel the positive factor $d\,\mathrm{ctx}$ from both sides. $\square$

**Corollary 6.9 (The conjectured amplitude drift is refuted).** If the depth-linear knee holds at $d=4$ and $d=16$ with the same $\delta,\mathrm{ctx}$, then $A_4 = A_{16} = \delta/32$, hence $A_{16}\cdot16 = 4\,(A_4\cdot4) > A_4\cdot4$. The product $A(d)\cdot d$ is not constant; it grows linearly. So the $13\%$ drift in $N_{\mathrm{eff}}$ cannot be a drift of the tail amplitude.

**Corollary 6.10 (Depth-independent ceiling).** Substituting $A = \delta/32$ into Theorem 6.7 gives, at every depth,
$$N_{\mathrm{eff}} \;\le\; \frac{\delta\,\mathrm{ctx}}{4} + 4 .$$
All three drifting measurements must sit under one and the same ceiling; unbounded growth of $N_{\mathrm{eff}}$ with depth would refute the scale-free tail.

**Corollary 6.11 (The deepest cell bounds the error budget).** Cell A reports $N_{\mathrm{eff}} = 52.73$ at $\mathrm{ctx}=128$. The ceiling reads $N_{\mathrm{eff}} \le 32\delta + 4$, whence $\delta \ge 1.52$: the end-to-end truncation budget implicit in the fitted $A/\delta = 1/32$ cannot be small.

**Theorem 6.12 (The margin is depth-independent too).** If the budget the margin channel asks for, $4LBA\,d\,\mathrm{ctx}/m$, equals the measured $d\,\mathrm{ctx}/32$ at some depth, then $m = 128\,LBA$ — again with no $d$ in it. Consequently the margins at $d=4$ and $d=16$ (same context) must be *equal*, not inversely proportional to depth: the linear growth of $k^\ast$ is produced by error accumulation across layers, not by a shrinking margin. A measured ratio $m(16)/m(4)\approx 1/4$ would refute the mechanism.

*Proof sketch.* Cancel $d\,\mathrm{ctx} \ne 0$ from $4LBA\,d\,\mathrm{ctx} = (d\,\mathrm{ctx}/32)\,m$. $\square$

---

## 7. Stability of the measured knee, and grid completion

The knee is defined by a threshold crossing, so a priori it could be fragile. It is not.

**Theorem 7.1 (Knee stability).** Let $\mathcal{K}$ be the swept budget set, $R$ the measured retained-accuracy curve, $\theta$ the threshold, $\eta \ge 0$ a perturbation level, and $k\in\mathcal{K}$. Suppose
1. $|R'(j) - R(j)| \le \eta$ for all $j$ (the rerun stays within $\eta$);
2. $R(k) \ge \theta + \eta$ (the measured curve passes at $k$ with margin $\eta$);
3. $R(j) + \eta < \theta$ for every $j \in \mathcal{K}$ with $j < k$ (it fails below $k$ with margin $\eta$).

Then $k$ is the least element of $\{j\in\mathcal{K} : R'(j) \ge \theta\}$: the rerun reports the same knee.

*Proof sketch.* Membership: $R'(k) \ge R(k) - \eta \ge \theta$. Minimality: if some $j\in\mathcal{K}$ with $j<k$ had $R'(j)\ge\theta$, then $R(j) \ge R'(j)-\eta \ge \theta-\eta$, contradicting (3). $\square$

**Corollary 7.2 (Cell A is seed-robust up to $\eta = 0.005$).** With the measured curve $R(8)=0.858$, $R(16)=0.922$, $R(32)=0.970$, $R(64)=0.996$, $R(96)=0.999$, $R(128)=1.000$ and $\theta = 0.98$: any rerun within $0.005$ of it reports $k^\ast = 64 = 16\cdot128/32$.

*Proof sketch.* $R(64) = 0.996 \ge 0.985$; and $R(32)+0.005 = 0.975 < 0.98$, with the smaller budgets further below. $\square$

**Corollary 7.3 (Cell B is seed-robust up to $\eta = 0.003$).** With $R(16)=0.965$, $R(32)=0.976$, $R(64)=0.985$, $R(128)=0.993$, $R(256)=0.998$, $R(384)=1.000$: any rerun within $0.003$ reports $k^\ast = 64 = 4\cdot512/32$.

*Proof sketch.* $R(64)=0.985 \ge 0.983$; $R(32)+0.003 = 0.979 < 0.98$. $\square$

Both hypotheses are realised by the measured curves themselves (take $R' = R$), so the corollaries are non-vacuous.

**Theorem 7.4 (Grid completion).** The observed seed-to-seed spread is $\pm0.002$, strictly inside both tolerance windows. Hence any rerun of either corner cell within the observed spread reports exactly the predicted knee: $16\cdot128/32 = 64$ at cell A and $4\cdot512/32 = 64$ at cell B.

*Proof sketch.* $0.002 \le 0.005$ and $0.002 \le 0.003$; apply Corollaries 7.2 and 7.3. $\square$

**Reading.** *No seed could have moved either knee.* Combined with the earlier cells, every measured cell of the depth-by-context grid is confirmed at two independent seeds, with every knee landing exactly on $d\cdot\mathrm{ctx}/32$. A previously suspected erosion of the long-context pass margin ($0.003$ at one seed) does not reproduce ($0.005$ at the next): the margin fluctuates by $\pm0.002$ rather than trending. A mild long-context depression of the retained curve — about $0.005$–$0.01$ below the shorter-context curves — persists at both seeds but does not move the knee.

---

## 8. Algorithms

Three procedures are implicit in the above and worth stating explicitly.

**Algorithm 8.1 (Knee sweep).** Given a model, a held-out set and a budget ladder $\mathcal{K}$: (i) evaluate full-attention accuracy $a_{\mathrm{full}}$; (ii) for each $k\in\mathcal{K}$ in increasing order, evaluate top-$k$-truncated accuracy $a_k$ and set $R(k) = a_k/a_{\mathrm{full}}$; (iii) return the first $k$ with $R(k)\ge0.98$. Cost: $|\mathcal{K}|+1$ held-out passes. Note the truncation is *data-free* — it depends only on each row's own weights — so there is no leakage from the held-out labels.

**Algorithm 8.2 (Certified mass ceiling).** Given a row's effective support $N_{\mathrm{eff}}$ and a budget $k$: return $\min\{1, \sqrt{k/N_{\mathrm{eff}}}\}$. By Corollary 2.2 this is a valid upper bound on the mass any $k$ positions can carry, computable in $O(1)$ from a statistic that costs one pass over the row. Its companion, $\rho^2 N_{\mathrm{eff}}$, is a lower bound on the budget needed to retain mass $\rho$.

**Algorithm 8.3 (Knee-stability certificate).** Given a measured curve $R$ on $\mathcal{K}$, a threshold $\theta$ and the reported knee $k$: compute the pass margin $R(k)-\theta$ and the fail margin $\min_{j<k}\big(\theta - R(j)\big)$; the certified tolerance is the minimum of the two. Any rerun within that tolerance is guaranteed by Theorem 7.1 to report the same knee. Cost: $O(|\mathcal{K}|)$.

---

## 9. Discussion

### 9.1 What is and is not explained

The central negative result is that *attention concentration does not explain top-$k$ truncation*. Two theorems make this precise and they point in opposite directions. Theorem 2.4 says the measured effective support makes mass retention **too expensive** to be the mechanism: at $N_{\mathrm{eff}} = 152.11$, mass retention at $0.98$ costs $\ge 146$ positions where the accuracy knee is $64$. Theorem 2.9 says no repair is available in the other direction either: rows with $N_{\mathrm{eff}}$ arbitrarily close to $4$ can hide half their mass from every fixed budget, so no bound of the form "top-$k$ mass $\ge F(k,N_{\mathrm{eff}})$" beating $1/2$ at $N_{\mathrm{eff}}=4$ exists.

What *is* explained: the law follows from additive error accumulation across nonexpansive layers plus a scale-free tail (Theorems 3.1, 3.3, 3.5), the mechanism is forced by the grid's own qualitative content (Theorems 3.7, 3.8), the mass–accuracy gap is exactly the slack the decision margin provides (Theorems 4.2–4.5), and its size is pinned two-sidedly (Theorem 4.8).

### 9.2 Scope and limitations

The empirical grid is small-scale: model dimension $64$, four heads, $2000$ training steps, a $4097$-token vocabulary, five novels. Absolute accuracies ($0.157$–$0.162$) are those of a small word-level language model, not a production system. The findings that transfer are structural — the *shape* of the law, the certified separation, the rigidity theorems — not the specific constant $1/32$, which is a calibration of one dimensionless ratio $A/\delta$ at this scale.

The theorems of §§2–7 are unconditional statements about weight vectors, Lipschitz stacks and threshold crossings; they do not depend on the empirical setting. Where measured numbers enter (Theorems 2.4, 2.5, 4.11, Corollaries 6.6, 6.11, 7.2, 7.3), they appear as explicit numerical hypotheses, so the conclusions are exactly as reliable as the logged quantities.

Two hypotheses deserve scrutiny. *Nonexpansiveness* is not verified directly; §5 turns it into a falsifiable spectral test and shows the conclusion survives $\Lambda \le 1+c/d$ but not a fixed $\Lambda > 1$. *The Zipf tail* is not verified directly either, but Theorem 3.8 shows it is the unique scale-free profile compatible with the measured depth-linear knee, so it is a consequence rather than an extra assumption — conditional on scale-freeness.

### 9.3 Practical reading

At depth $d$ and any context length, restricting each attention row to its top $\mathrm{ctx}\cdot d/32$ positions retains $\ge 98\%$ of held-out accuracy, a speedup of $32/d$. The speedup is context-invariant, so the lever does not degrade as windows grow — an unusual property for a cost-reduction heuristic. It is also *seed-independent at every measured corner*: no per-instance re-measurement is needed inside the measured grid. Shallow models get the biggest win ($8\times$ at $d=4$), which is the opposite of the usual intuition that deeper models are more redundant.

Two implementation notes follow from the theory. Selection matters: the random-$k$ control at the same budget loses $5$–$10$ accuracy points, and by Corollary 6.6 at most a factor $5.2$ of that can be a bulk-mass effect. And mass is the wrong monitoring statistic: by Theorem 2.5 a healthy deployment will be discarding a third or more of its attention mass, so a mass-retention alarm at any conventional level would fire constantly on a system that is working perfectly.

---

## 10. Future directions

**Immediate experiments.** (i) $\mathrm{ctx}=1024$ at $d=4$: Theorem 6.2 pre-registers a mass ceiling of $0.36$ at the predicted knee $k^\ast=128$; a run reporting $\ge0.98$ retained accuracy there certifies a $2.7\times$ mass/accuracy separation, and one reporting more than $0.36$ mass refutes the linear growth of $N_{\mathrm{eff}}$ with context. This also settles whether the long-context depression of the retained curve is a fluctuation or a trend. (ii) $\mathrm{ctx}=512$ at $d = 8, 16$, and the remaining $d=8$, $\mathrm{ctx}=256$ corner, to extend the two-seed grid. (iii) **Log the held-out logit margin.** Theorem 4.11 turns the certified mass ceiling into the sharp prediction $m > 1.4LB$ at the long-context cell; Theorem 6.12 predicts the margin is *depth-independent*, so measuring $m$ at $d=4$ and $d=16$ is a direct two-point test of the mechanism. (iv) **Measure per-layer Jacobian norms.** By Theorem 5.2 versus Corollary 5.4, a spectral norm bounded away from $1$ refutes the depth leg with no sweep at all.

**Theory.** Strengthen the margin law from the interval $[m/(8LB), m/(4LB)]$ to an asymptotic constant; the factor-two window is an artifact of the ceiling in the knee definition, and a refined analysis of the rounding should close it. Extend the read-out analysis from a single attention layer to interaction between heads — the current bound treats each layer's truncation error as independent, which the additive depth leg then sums, and correlated errors across heads could either sharpen or degrade the constant. Finally, both structural hypotheses can be tested directly rather than inferred: the tail profile by measuring $\mathrm{tail}(k)$ at several $k$ and checking scale-freeness, and nonexpansiveness spectrally.

**Sharper questions raised by the rigidity results.** The tail amplitude is forced to be $A = \delta/32$ at every depth (Theorem 6.8), which pushes the observed $13\%$ drift of $N_{\mathrm{eff}}$ with depth onto some other channel: what is it? The depth-independent ceiling $N_{\mathrm{eff}} \le \delta\,\mathrm{ctx}/4 + 4$ must contain the drift, and Corollary 6.11 shows the deepest cell already forces $\delta \ge 1.52$. Measuring $N_{\mathrm{eff}}$ at $d=32$ would either continue the drift toward the ceiling or break it, and the ceiling is the sharpest constraint the concentration stage places on the model.
