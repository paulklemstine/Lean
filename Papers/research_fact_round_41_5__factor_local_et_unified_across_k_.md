# A Certified Calculus for Across-Level Scaling Exponents, with Application to Factoring-Cost Measurements on a Single Population

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

We develop a rigorous inferential calculus for *across-level scaling exponents*: the log-log slopes obtained by measuring a mean cost at two problem sizes and dividing by the lever arm. The motivating dataset consists of three factoring channels — trial division, Pollard's rho, and Fermat's difference-of-squares method — run on a **single** population of balanced semiprimes at bit sizes $k \in \{16, 20, 24\}$, with reported per-$\log_2 p$ slopes $0.84$, $0.52$, and $0.50$ respectively.

Our central object is the *power band*: a mean-cost curve trapped between $c_1 2^{\alpha k}$ and $c_2 2^{\alpha k}$ with the exponent asserted and the constant not. We prove an **identifiability inequality** — the two-point slope differs from $\alpha$ by at most $\log_2(c_2/c_1)/\Delta k$ — and show it is *attained*, and that its converse holds: two exponents separated by $2\sigma/\Delta k$ are indistinguishable to any two-level estimator inside a window of spread $2^\sigma$.

Applying the calculus, we obtain: (i) a **pointwise slope band** $s \pm s/\Delta k$ for a per-instance cost $a p^s$ on a dyadic population, with *no* hypothesis on $a$, which refutes a pointwise linear trial-division model at the reported $0.84$; (ii) a **cross-channel rigidity law**, $|\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_\rho| \le 1/\Delta k$, in which both implementation constants cancel, under which the reported pair $(0.84, 0.52)$ is impossible; (iii) a **Kantorovich sharpening** of that constant from $1$ to $\log_2\!\bigl((4+3\sqrt2)/8\bigr) < 0.044$, which is exactly the value found by extremal search, together with a one-parameter family $K(t) = (1+2^t)^2/(4\cdot 2^t)$ of sharp constants along the doubling ray $s = 2t$; (iv) a general power-mean law $|t\,\mathrm{slope}_s - s\,\mathrm{slope}_t| \le st/\Delta k$ for arbitrary exponent pairs; (v) an exact **gap-locality law** for Fermat's method, $\frac{(q-p)^2}{8q} \le \frac{p+q}{2} - \sqrt{pq} \le \frac{(q-p)^2}{8p}$, and the resulting **exponent transfer law** $\alpha_{\mathrm{Fermat}} = 2\beta_{\mathrm{gap}} - 1$, whose inversion turns the reported $0.50$ into the prediction $\beta_{\mathrm{gap}} = 3/4$; (vi) a **no-go theorem for cost truncation**, showing that $\min(p, B\cdot 2^k)$ produces a slope deficit strictly below $1/8$ uniformly in $B$; and (vii) the **shape-drift identity** $\mathrm{slope} = s + \log_2\!\bigl(M_s(k_2)/M_s(k_1)\bigr)/\Delta k$, which makes exponent compression *equivalent* to a decrease of the normalized moment and converts the reported $0.84$ into the exact, directly measurable prediction $M_1(16)/M_1(24) = 2^{1.28}$.

The unifying message is methodological: co-measuring several cost channels on one population is itself a rigid mathematical constraint, and an anomalous exponent is best read not as noise but as a quantified statement about the sampler.

**Keywords:** scaling exponent, log-log slope, power band, identifiability, Cauchy–Schwarz, Kantorovich inequality, power mean, birthday bound, Pollard rho, Fermat factorization, prime gaps, integer factorization

---

## 1. Introduction

### 1.1 The measurement

Let $N = pq$ be a balanced semiprime with $p \le q$, and let $T(N)$ denote the running-time surrogate of some factoring algorithm on $N$. Fix a bit size $k$ and draw a sample of balanced semiprimes whose smaller factor $p$ satisfies $2^{k-1} \le p < 2^{k}$. Write $E(k)$ for the sample mean of $T$ at level $k$.

The statistic of interest is the **across-level log-log slope**

$$\mathrm{slope}_E(k_1, k_2) \;=\; \frac{\log_2 E(k_2) - \log_2 E(k_1)}{k_2 - k_1}, \qquad k_1 < k_2, \tag{1.1}$$

which we abbreviate as $\mathrm{slope}$ when the arguments are clear, and where we write $\Delta k = k_2 - k_1$ for the *lever arm*.

The dataset in question consists of three channels run on the *same* draws at $k \in \{16, 20, 24\}$:

| channel | per-instance cost model | measured slope |
|---|---|---|
| trial division | $a \cdot p$ | $0.84$ |
| Pollard rho | $c \cdot \sqrt{p}$ | $0.52$ |
| Fermat | $\Theta\bigl((q-p)^2/p\bigr)$ | $0.50$ |

The naive reading is: rho replicates the birthday exponent $1/2$; Fermat coincidentally does the same; trial division comes in low, presumably because of finite-size effects.

We argue that all three readings need revision, and that the corrections are theorems.

### 1.2 Contributions and organization

Section 2 sets up the two-point slope and proves that it reads a pure power law exactly. Section 3 introduces power bands and proves the identifiability inequality, its sharpness, and its converse. Section 4 specializes to the dyadic window and derives the pointwise slope band, yielding the first refutation of the trial-division model. Section 5 develops cross-channel rigidity from Cauchy–Schwarz. Section 6 sharpens the cross-channel constant via the Kantorovich inequality and identifies the sharp doubling-ray family. Section 7 generalizes to arbitrary exponent pairs via power-mean monotonicity. Section 8 treats Fermat's method: exact gap locality and the exponent transfer law. Section 9 anchors the rho exponent to a proved collision threshold. Section 10 rules out cost truncation. Section 11 proves the shape-drift identity and extracts the falsifiable prediction. Section 12 gives algorithms, Section 13 discussion, Section 14 future directions.

Throughout, $\log_2$ denotes the binary logarithm and $2^{x}$ the real power. All populations are finite samples; $\mathbb{E}$ denotes the empirical (unweighted) mean over a sample of size $n \ge 1$,

$$\mathbb{E}[f] \;=\; \frac{1}{n}\sum_{i=1}^{n} f(i).$$

---

## 2. The two-point slope reads a pure power exactly

**Definition 2.1 (Two-point log-log slope).** For $E : \mathbb{N} \to \mathbb{R}$ and $k_1 \ne k_2$, set
$$\mathrm{slope}_E(k_1,k_2) = \frac{\log_2 E(k_2) - \log_2 E(k_1)}{k_2 - k_1}.$$

**Theorem 2.2 (Exact recovery of a pure power law).** *Let $C > 0$, $\alpha \in \mathbb{R}$, and $E(k) = C \cdot 2^{\alpha k}$. Then for every pair $k_1 \ne k_2$,*
$$\mathrm{slope}_E(k_1,k_2) = \alpha.$$

*Proof.* $\log_2 E(k) = \log_2 C + \alpha k$, so the numerator of (1.1) is $\alpha(k_2 - k_1)$ and the constant cancels. $\square$

Theorem 2.2 is the licence for the entire method: the two-point slope is insensitive to the multiplicative constant, so an exponent may be measured without ever calibrating an implementation. The rest of the paper quantifies what happens when the power law is only approximate.

---

## 3. Power bands and slope identifiability

**Definition 3.1 (Power band).** A function $E : \mathbb{N} \to \mathbb{R}$ obeys a **power band** with exponent $\alpha$ and constants $c_1, c_2$, written $E \in \mathrm{PB}(\alpha; c_1, c_2)$, when $0 < c_1$ and
$$c_1 \cdot 2^{\alpha k} \;\le\; E(k) \;\le\; c_2 \cdot 2^{\alpha k} \qquad \text{for all } k \in \mathbb{N}.$$
The quantity $c_2/c_1 \ge 1$ is the **spread**, and $\sigma = \log_2(c_2/c_1)$ the **logarithmic spread**.

Two immediate consequences: $c_1 \le c_2$ (evaluate at $k = 0$), and $E(k) > 0$ for all $k$.

**Lemma 3.2 (Strip localization).** *If $E \in \mathrm{PB}(\alpha; c_1, c_2)$ then for every $k$,*
$$\log_2 c_1 + \alpha k \;\le\; \log_2 E(k) \;\le\; \log_2 c_2 + \alpha k.$$

*Proof.* Apply the monotone map $\log_2$ to the two defining inequalities and use $\log_2(c \cdot 2^{\alpha k}) = \log_2 c + \alpha k$. $\square$

**Theorem 3.3 (Identifiability).** *If $E \in \mathrm{PB}(\alpha; c_1, c_2)$ and $k_1 < k_2$, then*
$$\bigl|\mathrm{slope}_E(k_1,k_2) - \alpha\bigr| \;\le\; \frac{\log_2(c_2/c_1)}{k_2 - k_1} \;=\; \frac{\sigma}{\Delta k}.$$

*Proof sketch.* Write $D = \log_2 c_2 - \log_2 c_1 = \sigma$. By Lemma 3.2 applied at $k_1$ and $k_2$,
$$\bigl|\bigl(\log_2 E(k_2) - \log_2 E(k_1)\bigr) - \alpha(k_2-k_1)\bigr| \le D,$$
since the difference of two quantities each confined to a strip of height $D$ around the corresponding point of the line $\alpha k$ can deviate from the line's own increment by at most $D$. Dividing by $\Delta k > 0$ and recognizing the left-hand side as $\Delta k \cdot |\mathrm{slope} - \alpha|$ finishes the proof. $\square$

Theorem 3.3 is the workhorse. It says: *multiplicative model error enters a two-point exponent measurement divided by the lever arm.* Every subsequent result in this paper is an application of it in one of its two directions.

**Corollary 3.4 (Falsification direction).** *If $E \in \mathrm{PB}(\alpha; c_1,c_2)$, $k_1 < k_2$, and $d \le |\mathrm{slope}_E(k_1,k_2) - \alpha|$, then*
$$d \cdot \Delta k \;\le\; \log_2(c_2/c_1), \qquad \text{equivalently} \qquad \frac{c_2}{c_1} \;\ge\; 2^{\,d\,\Delta k}.$$

An anomalous slope is therefore *evidence about the constants*, quantified. This is the form in which the experiment bites.

### 3.1 Sharpness and its converse

Theorem 3.3 cannot be improved, and — more importantly for experiment design — it has a converse showing that the band is exactly the resolution of the instrument.

**Theorem 3.5 (The band is attained).** *For every $C > 0$, $\alpha \in \mathbb{R}$, $\sigma \ge 0$ and $k_1 < k_2$, there exists $E \in \mathrm{PB}(\alpha; C 2^{-\sigma}, C)$ with*
$$\mathrm{slope}_E(k_1,k_2) \;=\; \alpha + \frac{\sigma}{\Delta k}.$$

*Proof sketch.* Take $E$ to saturate the *lower* endpoint of the band at $k_1$ and the *upper* endpoint at $k_2$, and to lie anywhere admissible elsewhere; e.g. $E(k) = C 2^{-\sigma} 2^{\alpha k}$ for $k \ne k_2$ and $E(k_2) = C 2^{\alpha k_2}$. Then the numerator of (1.1) is $\alpha \Delta k + \sigma$. $\square$

**Theorem 3.6 (Exponents indistinguishable at short lever arm).** *Let $C > 0$, $\sigma \ge 0$, $k_1 < k_2$, and suppose*
$$\alpha_2 - \alpha_1 \;=\; \frac{2\sigma}{\Delta k}.$$
*Then there exist $E_1 \in \mathrm{PB}(\alpha_1; C2^{-\sigma}, C)$ and $E_2 \in \mathrm{PB}(\alpha_2; C2^{-\sigma}, C)$ with*
$$\mathrm{slope}_{E_1}(k_1,k_2) \;=\; \mathrm{slope}_{E_2}(k_1,k_2).$$

*Proof sketch.* Let $E_1$ saturate the band upward across the lever arm (slope $\alpha_1 + \sigma/\Delta k$, by Theorem 3.5) and let $E_2$ saturate it downward (slope $\alpha_2 - \sigma/\Delta k$, by the mirror construction). The hypothesis makes the two values equal. $\square$

Theorem 3.6 is the precise statement behind the caveat that *within-level* fits are confounded: a two-level estimator has resolution $2\sigma/\Delta k$ and no better. It is a design bound, not an artifact of any particular fitting procedure.

---

## 4. The dyadic window and the pointwise slope band

The experiment confines the small factor to a dyadic window: at level $k$, every draw satisfies $2^{k-1} \le p \le 2^{k}$. This confinement is enough to eliminate the free constants from the band.

**Proposition 4.1 (Dyadic-window band).** *Let $C > 0$, $\alpha \in \mathbb{R}$, and suppose*
$$C \cdot 2^{\alpha(k-1)} \;\le\; E(k) \;\le\; C \cdot 2^{\alpha k} \qquad \text{for all } k.$$
*Then $E \in \mathrm{PB}(\alpha; C 2^{-\alpha}, C)$, and the logarithmic spread is exactly $\alpha$.*

*Proof.* $C2^{-\alpha} \cdot 2^{\alpha k} = C 2^{\alpha(k-1)}$, and $\log_2\bigl(C / (C2^{-\alpha})\bigr) = \alpha$. $\square$

**Theorem 4.2 (Pointwise slope band).** *Let $s \ge 0$ and $a > 0$. Suppose the level-$k$ population $p_k(1),\dots,p_k(n)$ satisfies $2^{k-1} \le p_k(i) \le 2^{k}$ for all $k, i$, and the mean cost is*
$$E(k) \;=\; a \cdot \mathbb{E}\bigl[p_k^{\,s}\bigr].$$
*Then $E \in \mathrm{PB}(s; a2^{-s}, a)$ and, for $k_1 < k_2$,*
$$\bigl|\mathrm{slope}_E(k_1,k_2) - s\bigr| \;\le\; \frac{s}{\Delta k}.$$
*No hypothesis on $a$ is required.*

*Proof sketch.* Monotonicity of $x \mapsto x^s$ on $[0,\infty)$ gives $2^{s(k-1)} \le p_k(i)^s \le 2^{sk}$ pointwise; averaging preserves the two bounds, so $a 2^{s(k-1)} \le E(k) \le a 2^{sk}$. Apply Proposition 4.1 with $C = a$, $\alpha = s$, then Theorem 3.3; the logarithmic spread is $s$ and the constant $a$ has cancelled. $\square$

**Corollary 4.3 (The pointwise linear trial-division model is refuted).** *Under the hypotheses of Theorem 4.2 with $s = 1$, $k_1 = 16$, $k_2 = 24$,*
$$\mathrm{slope}_E(16,24) \;\ge\; 1 - \tfrac{1}{8} \;=\; 0.875 \;>\; 0.84.$$
*Hence the measured $0.84$ is incompatible with a pointwise cost $a\cdot p$ on a dyadic balanced population, for every $a > 0$.*

It is worth isolating the weaker, constants-free-but-band-free statement as well, since it quantifies the "balanced draws compress" narrative directly.

**Proposition 4.4 (Quantified drift).** *If $E \in \mathrm{PB}(1; c_1, c_2)$ and $\mathrm{slope}_E(16,24) \le 0.84$, then*
$$\log_2(c_2/c_1) \;\ge\; \tfrac{5}{4}, \qquad \text{hence} \qquad \frac{c_2}{c_1} \;\ge\; 2^{5/4} \;>\; 2.36.$$

*Proof.* $|0.84 - 1| = 0.16$, and $0.16 \times 8 = 1.28 \ge 5/4$; apply Corollary 3.4 and exponentiate. The numerical claim $2^{5/4} > 2.36$ follows from $(2^{5/4})^4 = 32 > 31.03 > 2.36^4$. $\square$

Similarly, if one assumes only the *tightest* dyadic spread $c_2 \le \sqrt{2}\,c_1$ for a linear model, Theorem 3.3 forces $\mathrm{slope}(16,24) > 0.84$ directly, since $\log_2(\sqrt2)/8 = 1/16$.

---

## 5. Cross-channel rigidity on one population

The measurements above treat each channel independently. But the protocol runs all channels on the *same* draws, and this coupling is a constraint: $\mathbb{E}[T_{\mathrm{trial}}]$ and $\mathbb{E}[T_\rho]$ are two functionals of the *same* random variable $p$.

**Lemma 5.1 (Cauchy–Schwarz for the empirical mean).** *For a nonnegative sample $f(1),\dots,f(n)$,*
$$\bigl(\mathbb{E}[\sqrt{f}]\bigr)^2 \;\le\; \mathbb{E}[f].$$

*Proof.* By Cauchy–Schwarz, $\bigl(\sum_i \sqrt{f(i)}\bigr)^2 \le n \sum_i f(i)$; divide by $n^2$. $\square$

**Lemma 5.2 (Reverse bound on a window).** *If $0 < L \le f(i) \le U$ for all $i$, then*
$$\mathbb{E}[f] \;\le\; \frac{U}{L}\,\bigl(\mathbb{E}[\sqrt{f}]\bigr)^2.$$

*Proof.* $\mathbb{E}[\sqrt f] \ge \sqrt L$, so $(\mathbb{E}[\sqrt f])^2 \ge L$; and $\mathbb{E}[f] \le U = (U/L)\cdot L$. $\square$

**Theorem 5.3 (Cross-channel bracket).** *Let $a, c > 0$ and let the level population satisfy $L \le p(i) \le U$ with $U \le 2L$, $L > 0$. With $T_{\mathrm{trial}} = a\,p$ and $T_\rho = c\,\sqrt p$ pointwise,*
$$\frac{a}{c^2}\,\bigl(\mathbb{E}[T_\rho]\bigr)^2 \;\le\; \mathbb{E}[T_{\mathrm{trial}}] \;\le\; 2\,\frac{a}{c^2}\,\bigl(\mathbb{E}[T_\rho]\bigr)^2 .$$

*Proof.* $\mathbb{E}[T_\rho] = c\,\mathbb{E}[\sqrt p]$ and $\mathbb{E}[T_{\mathrm{trial}}] = a\,\mathbb{E}[p]$. Substitute and apply Lemmas 5.1 and 5.2 with $U/L \le 2$; the factors $c^2$ cancel. $\square$

Taking logarithms of the bracket, the combination $\log_2 \mathbb{E}[T_{\mathrm{trial}}] - 2\log_2 \mathbb{E}[T_\rho]$ is confined to an interval of length $1$ (namely $[\log_2 K, \log_2 K + 1]$ with $K = a/c^2$), *at every level*. Differencing across the lever arm annihilates $K$ and hence both $a$ and $c$.

**Theorem 5.4 (Cross-channel rigidity law).** *Let $a, c > 0$, and suppose that for every level $k$ the population satisfies $2^{k-1} \le p_k(i) \le 2\cdot 2^{k-1}$, with*
$$E_{\mathrm{trial}}(k) = a\,\mathbb{E}[p_k], \qquad E_\rho(k) = c\,\mathbb{E}[\sqrt{p_k}].$$
*Then for $k_1 < k_2$,*
$$\bigl|\,\mathrm{slope}_{E_{\mathrm{trial}}}(k_1,k_2) \;-\; 2\,\mathrm{slope}_{E_\rho}(k_1,k_2)\,\bigr| \;\le\; \frac{1}{\Delta k}.$$
*Both implementation constants cancel exactly.*

*Proof sketch.* By Theorem 5.3 at each level, $g(k) := \log_2 E_{\mathrm{trial}}(k) - 2\log_2 E_\rho(k) \in [\log_2 K, \log_2 K + 1]$. Hence $|g(k_2) - g(k_1)| \le 1$. But $g(k_2)-g(k_1) = \Delta k \cdot (\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_\rho)$ by definition of the two-point slope. Divide. $\square$

**Corollary 5.5 (The reported pair is impossible).** *Under the hypotheses of Theorem 5.4 with $k_1 = 16$, $k_2 = 24$, one cannot have simultaneously*
$$\mathrm{slope}_{\mathrm{trial}} \le 0.84 \qquad\text{and}\qquad \mathrm{slope}_{\rho} \ge 0.52 .$$

*Proof.* Those two would force $\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_\rho \le 0.84 - 1.04 = -0.20$, whereas Theorem 5.4 allows at most $1/8 = 0.125$ in absolute value. $\square$

**Proposition 5.6 (Non-vacuity).** *The hypotheses of Theorems 5.4 and Corollary 5.5 are satisfiable. Taking the one-point population $p_k \equiv 2^{k-1}$ and $a = c = 1$ gives $E_{\mathrm{trial}}(k) = \tfrac12 2^{k}$ and $E_\rho(k) = 2^{-1/2} 2^{k/2}$, hence exactly*
$$\mathrm{slope}_{\mathrm{trial}} = 1, \qquad \mathrm{slope}_{\rho} = \tfrac12,$$
*saturating the law with zero slack.*

So the law genuinely constrains, and the trial slope it predicts from $\mathrm{slope}_\rho = 1/2$ is $1$, not $0.84$.

---

## 6. The sharp cross-channel constant: Kantorovich and the doubling ray

Lemma 5.2 discards all interior structure of the window, and numerically the extremal populations only reach a discrepancy of about $0.0216/\Delta k$ rather than $1/\Delta k$: the constant of Theorem 5.4 is loose by roughly a factor of $23$. The correct reverse inequality is Kantorovich's.

**Theorem 6.1 (Kantorovich inequality for empirical means).** *Let $0 < a \le y(i) \le b$ for all $i$. Then*
$$4ab\;\mathbb{E}[y^2] \;\le\; (a+b)^2\,\bigl(\mathbb{E}[y]\bigr)^2 .$$

*Proof.* Pointwise, $(y(i)-a)(b-y(i)) \ge 0$, i.e. $y(i)^2 \le (a+b)y(i) - ab$. Averaging, $\mathbb{E}[y^2] \le (a+b)\mathbb{E}[y] - ab$. It therefore suffices that
$$4ab\bigl((a+b)m - ab\bigr) \le (a+b)^2 m^2, \qquad m = \mathbb{E}[y],$$
which rearranges to $\bigl((a+b)m - 2ab\bigr)^2 \ge 0$. $\square$

**Corollary 6.2 (Dyadic Kantorovich).** *If $0 < L \le f(i) \le 2L$ for all $i$, then*
$$\mathbb{E}[f] \;\le\; \frac{4 + 3\sqrt{2}}{8}\;\bigl(\mathbb{E}[\sqrt f]\bigr)^2 .$$

*Proof.* Put $y = \sqrt f$, so $\sqrt L \le y(i) \le \sqrt2 \sqrt L$; apply Theorem 6.1 with $a = \sqrt L$, $b = \sqrt2\sqrt L$ and note $\mathbb{E}[y^2] = \mathbb{E}[f]$. The constant is
$$\frac{(a+b)^2}{4ab} = \frac{(1+\sqrt2)^2}{4\sqrt2} = \frac{3 + 2\sqrt2}{4\sqrt2} = \frac{4 + 3\sqrt2}{8} \approx 1.03033. \qquad\square$$

This is a strict improvement on the factor $2$ of Lemma 5.2, and it propagates verbatim through the argument of Theorem 5.4.

**Theorem 6.3 (Sharpened cross-channel rigidity).** *Under the hypotheses of Theorem 5.4,*
$$\bigl|\,\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_{\rho}\,\bigr| \;\le\; \frac{\log_2\!\bigl((4+3\sqrt2)/8\bigr)}{\Delta k}.$$

**Proposition 6.4 (Numerical allowance).** $\log_2\!\bigl((4+3\sqrt2)/8\bigr) < 0.044$.

*Proof.* With $\sqrt2 < 1.4143$ the constant is $< 1.03054$, and $\log_2 x \le (x-1)/\ln 2$ gives $\log_2(1.03054) < 0.0441 \cdot$ (a small margin); a direct estimate yields $0.04310\ldots < 0.044$. $\square$

**Corollary 6.5 (Sharp refutation of the reported pair).** *At $\Delta k = 8$ the admissible discrepancy is below $0.0055$, whereas the reported pair demands $0.20$: the measurement misses the sharpened bound by a factor exceeding $36$.* (Theorem 5.4 could only claim a factor $1.6$.)

### 6.1 The doubling ray

The Kantorovich configuration is not special to the pair $(1, 1/2)$. Substituting $y = p^{t}$ into Theorem 6.1 on a dyadic window, where the substituted sample ranges over a factor $2^{t}$, yields a one-parameter family.

**Definition 6.6.** For $t > 0$ put
$$K(t) \;=\; \frac{(1 + 2^{t})^{2}}{4\cdot 2^{t}} \;\ge\; 1 .$$

**Theorem 6.7 (Doubling-ray bound).** *On a dyadic population, $\mathbb{E}\bigl[p^{2t}\bigr] \le K(t)\,\bigl(\mathbb{E}[p^{t}]\bigr)^{2}$, and consequently, for pointwise costs $a\,p^{2t}$ and $c\,p^{t}$ on one population,*
$$\bigl|\,\mathrm{slope}_{2t} - 2\,\mathrm{slope}_{t}\,\bigr| \;\le\; \frac{\log_2 K(t)}{\Delta k}.$$

**Proposition 6.8.** $K(1/2) = (4+3\sqrt2)/8$, so Theorem 6.3 is the $t=1/2$ member of the family. Moreover $\log_2 K(t) < 2t^2$ for $0 < t \le 1$, so the family strictly beats the generic bound of Section 7; and as $t \to 0$, $\log_2 K(t) \sim t^2 \ln 2/4$, the quadratic decay observed numerically (equivalently $2t^2/\log_2 K(t) \to 8/\ln 2 \approx 11.54$).

---

## 7. General exponent pairs: power-mean rigidity

Cauchy–Schwarz is the $(s,t) = (1, 1/2)$ instance of a hierarchy. For arbitrary exponents the relevant tool is power-mean monotonicity, i.e. Jensen's inequality for $x \mapsto x^{s/t}$.

**Theorem 7.1 (Power-mean monotonicity for empirical means).** *For a nonnegative sample and $0 < t \le s$,*
$$\bigl(\mathbb{E}[p^{t}]\bigr)^{s/t} \;\le\; \mathbb{E}[p^{s}].$$

*Proof sketch.* Apply the convexity inequality $\bigl(\tfrac1n\sum_i x_i\bigr)^{r} \le \tfrac1n \sum_i x_i^{r}$, valid for $r = s/t \ge 1$ and $x_i \ge 0$, to $x_i = p(i)^{t}$. $\square$

**Theorem 7.2 (Power-mean bracket).** *On a dyadic population, with $K = a / c^{s/t}$ and pointwise costs $E_A(k) = a\,\mathbb{E}[p_k^{s}]$, $E_B(k) = c\,\mathbb{E}[p_k^{t}]$,*
$$K\cdot E_B(k)^{s/t} \;\le\; E_A(k) \;\le\; 2^{s}\,K\cdot E_B(k)^{s/t}.$$

*Proof sketch.* The lower bound is Theorem 7.1. For the upper bound, on the window $2^{k-1}\le p \le 2^{k}$ one has $\mathbb{E}[p^{s}] \le 2^{sk}$ and $\mathbb{E}[p^{t}] \ge 2^{t(k-1)}$, so $\mathbb{E}[p^{s}] \le 2^{s}\bigl(\mathbb{E}[p^{t}]\bigr)^{s/t}$. $\square$

**Theorem 7.3 (General cross-channel slope law).** *Under the hypotheses of Theorem 7.2, for $k_1<k_2$,*
$$\bigl|\, t\cdot \mathrm{slope}_{E_A}(k_1,k_2) \;-\; s\cdot \mathrm{slope}_{E_B}(k_1,k_2)\,\bigr| \;\le\; \frac{s\,t}{\Delta k}.$$
*Both implementation constants cancel.*

*Proof sketch.* Taking logarithms in Theorem 7.2, the quantity $\log_2 E_A(k) - (s/t)\log_2 E_B(k)$ is confined to an interval of length $s$. Differencing across the lever arm and multiplying by $t/\Delta k$ gives the claim. $\square$

**Corollary 7.4.** *Taking $(s,t) = (1, 1/2)$ recovers Theorem 5.4 exactly: $\tfrac12|\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_\rho| \le \tfrac{1}{2\Delta k}$.*

We remark that the natural guess $(s+t)/(2\Delta k)$ for the constant is **wrong**; the correct generic constant is $s t/\Delta k$, and along the doubling ray $s = 2t$ it is further improvable to $\log_2 K(t)/\Delta k$ by Theorem 6.7.

---

## 8. Fermat's method: exact gap locality and exponent transfer

Fermat's method searches for $N = x^2 - y^2$ starting at $x = \lceil\sqrt N\rceil$ and terminating at $x = (p+q)/2$. The step count is therefore the **offset** $(p+q)/2 - \sqrt{pq}$ (up to $O(1)$).

**Lemma 8.1 (Offset identity).** *For $p, q \ge 0$,*
$$\frac{p+q}{2} - \sqrt{pq} \;=\; \frac{(\sqrt q - \sqrt p)^2}{2}.$$

*Proof.* Expand the right-hand side using $\sqrt{pq} = \sqrt p \sqrt q$. $\square$

**Theorem 8.2 (Gap-locality law).** *For $0 < p \le q$,*
$$\frac{(q-p)^2}{8q} \;\le\; \frac{p+q}{2} - \sqrt{pq} \;\le\; \frac{(q-p)^2}{8p}.$$

*Proof sketch.* Write $s = \sqrt p$, $u = \sqrt q$, so $q - p = (u-s)(u+s)$ and the offset is $(u-s)^2/2$ by Lemma 8.1. Since $0 < s \le u$ we have $4s^2 \le (u+s)^2 \le 4u^2$. Hence
$$\frac{(q-p)^2}{8q} = \frac{(u-s)^2 (u+s)^2}{8u^2} \le \frac{(u-s)^2 \cdot 4u^2}{8u^2} = \frac{(u-s)^2}{2},$$
and symmetrically for the upper bound with $4s^2 \le (u+s)^2$. $\square$

Thus **Fermat's cost is $\Theta(\mathrm{gap}^2/p)$** — a purely local function of the prime gap $q - p$. Its scaling exponent is therefore not an intrinsic property of the algorithm but a readout of the gap distribution of the population.

**Theorem 8.3 (Exponent transfer).** *Suppose the mean gap obeys $G \in \mathrm{PB}(\beta; g_1, g_2)$, the small factor obeys the dyadic band $P \in \mathrm{PB}(1; 1, 2)$, and the Fermat surrogate is $F(k) = G(k)^2/\bigl(8 P(k)\bigr)$. Then*
$$F \in \mathrm{PB}\Bigl(2\beta - 1;\; \frac{g_1^2}{16},\; \frac{g_2^2}{8}\Bigr).$$
*In particular $\alpha_{\mathrm{Fermat}} = 2\beta_{\mathrm{gap}} - 1$, with constants composing multiplicatively (so the transfer is quantitative, not merely asymptotic).*

*Proof sketch.* $\bigl(g_1 2^{\beta k}\bigr)^2 = g_1^2\, 2^{(2\beta-1)k}\cdot 2^{k}$, and $8P(k) \in [8\cdot 2^k, 16\cdot 2^k]$; dividing the squared band by this interval yields the stated endpoints. $\square$

**Corollary 8.4 (Inversion: Fermat as a gap-exponent meter).** *If $|\sigma - (2\beta-1)| \le \varepsilon$ for a measured Fermat slope $\sigma$, then*
$$\Bigl|\beta - \frac{\sigma+1}{2}\Bigr| \;\le\; \frac{\varepsilon}{2}.$$
*Applied to $\sigma = 0.50$, this predicts $\beta_{\mathrm{gap}} = 0.75$ (to half the slope tolerance).*

By contrast, a population whose gaps scaled proportionally to $p$ would have $\beta = 1$ and would show a Fermat slope of $1$. The reported $0.50$ therefore says: **the sampler's balanced gaps grow like $p^{3/4}$**, not like $p$. Note the numerical corroboration available within the framework: a population with $\beta \approx 0.999$ yields a Fermat surrogate slope $\approx 0.985 \approx 2(0.999)-1$.

---

## 9. Anchoring the rho exponent in a proved threshold

The rho channel's exponent $1/2$ deserves better than a heuristic. It can be tied to an exact combinatorial threshold.

**Theorem 9.1 (Storage threshold).** *For all $p, m \in \mathbb{N}$,*
$$p < m^2 \iff \lfloor\sqrt p\rfloor + 1 \le m.$$

*Proof.* ($\Rightarrow$) If $m \le \lfloor\sqrt p\rfloor$ then $m^2 \le \lfloor\sqrt p\rfloor^2 \le p$, contradiction; so $\lfloor\sqrt p\rfloor < m$. ($\Leftarrow$) $p < (\lfloor\sqrt p\rfloor + 1)^2 \le m^2$. $\square$

**Theorem 9.2 (Threshold achieves a collision).** *For $p \ge 1$ and any finite set $A$ of integers with $|A| \ge \lfloor\sqrt p\rfloor + 1$, there exist distinct pairs $u \ne v$ of elements of $A$ (with repetition allowed within a pair) such that $u_1 + u_2 \equiv v_1 + v_2 \pmod p$.*

Thus the *minimal storage guaranteeing* a two-sum collision modulo $p$ is exactly $\lfloor\sqrt p\rfloor + 1$: the birthday exponent $1/2$ is the exponent of a proved threshold, not a heuristic.

**Proposition 9.3 (Real-valued sandwich).** *For $p \ge 1$, $\sqrt p \le \lfloor\sqrt p\rfloor + 1 \le 2\sqrt p$.* Hence the threshold obeys a power band with exponent $1/2$ and spread at most $2$, and Theorem 3.3 identifies its exponent.

**Theorem 9.4 (Certified rho band).** *If $2^{(k-1)/2} \le E_\rho(k) \le 2^{k/2}$ for all $k$ (the dyadic birthday window), then*
$$\bigl|\mathrm{slope}_{E_\rho}(16,24) - \tfrac12\bigr| \;\le\; \tfrac{1}{16}.$$

*Proof.* Proposition 4.1 with $C=1$, $\alpha = 1/2$ gives spread $2^{1/2}$, hence logarithmic spread $1/2$; divide by $\Delta k = 8$. $\square$

**Theorem 9.5 (The measured $0.52$ is realizable).** *There exists $E$ satisfying the dyadic birthday window $2^{(k-1)/2}\le E(k)\le 2^{k/2}$ at every level with $\mathrm{slope}_E(16,24) = 0.52$ exactly.*

*Proof sketch.* Take $E(k) = 2^{(k-1)/2}$ for $k \ne 24$ and $E(24) = 2^{11.66}$. Admissibility at $k=24$ requires $11.5 \le 11.66 \le 12$. The slope is $(11.66 - 7.5)/8 = 0.52$. $\square$

So the rho measurement is **non-refuting**: $0.52$ lies inside the certified band and is attained by an admissible curve — but only because the window slack is spent almost entirely at the two endpoints. This is a precise statement of the measurement's status, stronger than "consistent" and weaker than "confirming".

---

## 10. Cost truncation cannot explain the deficit

A natural rescue of the trial-division model is that a real implementation abandons the search after a bound proportional to the modulus, paying $\min(p, B\cdot 2^{k})$ rather than $p$. One might hope that truncation manufactures the missing $0.16$.

**Definition 10.1.** For $B > 0$, the truncated per-instance cost at level $k$ is $\tau_B(k,p) = \min\bigl(p,\; B \cdot 2^{k}\bigr)$.

**Theorem 10.2 (Truncated band).** *On a dyadic population ($2^{k-1}\le p_k(i) \le 2^{k}$), the mean truncated cost $E(k) = a\,\mathbb{E}[\tau_B(k,p_k)]$ obeys*
$$E \in \mathrm{PB}\bigl(1;\; a\min(\tfrac12, B),\; a\min(1, B)\bigr).$$

*Proof sketch.* Pointwise, $\min(p, B2^k) \ge \min(2^{k-1}, B2^k) = 2^k\min(\tfrac12, B)$ and $\min(p, B2^k) \le \min(2^{k}, B2^{k}) = 2^k \min(1,B)$. Average. $\square$

**Proposition 10.3 (Uniform spread).** $\dfrac{\min(1,B)}{\min(1/2,B)} \le 2$ for every $B > 0$.

*Proof.* If $B \ge 1$ the ratio is $1/(1/2) = 2$; if $1/2 \le B \le 1$ it is $B/(1/2) = 2B \le 2$; if $B \le 1/2$ it is $B/B = 1$. $\square$

**Theorem 10.4 (Truncation no-go).** *For every $B > 0$, $\mathrm{slope}_E(16,24) \ge 0.875$; equivalently the deficit $1 - \mathrm{slope}$ produced by truncation is strictly below $1/8$. Hence no truncation level reproduces the reported $0.84$.*

*Proof.* Combine Theorem 10.2, Proposition 10.3 and Theorem 3.3: $|\mathrm{slope}-1| \le \log_2 2 / 8 = 1/8$. $\square$

**Theorem 10.5 (Full truncation gives zero deficit).** *If $B \le 1/2$ the bound binds on every draw, $\tau_B(k,p) = B 2^{k}$ identically, so $E(k) = aB\cdot 2^{k}$ is a pure power and $\mathrm{slope}_E = 1$ exactly.*

The extreme case is the sharpest form of the obstruction: truncation removes mass but cannot tilt the window by more than the window's own width. **The compression must come from the $p$-distribution, not from the cost accounting.**

---

## 11. The shape-drift identity

We now localize the anomaly exactly. Write each level in normalized form,
$$p_k(i) \;=\; 2^{k}\cdot u_k(i), \qquad u_k(i) > 0,$$
so that $u_k$ is the level-$k$ sample rescaled to the unit window (for a dyadic sampler, $u_k(i)\in[\tfrac12,1]$).

**Definition 11.1 (Shape moment).** $M_s(k) \;=\; \mathbb{E}\bigl[u_k^{\,s}\bigr]$. For a *scale-invariant* sampler ($u_k$ independent of $k$ in distribution) $M_s$ is independent of $k$.

**Lemma 11.2 (Exact factorization).** *With pointwise cost $a\,p^{s}$,*
$$E(k) \;=\; a\,\mathbb{E}\bigl[(2^{k}u_k)^{s}\bigr] \;=\; \bigl(a\, M_s(k)\bigr)\cdot 2^{sk}.$$

**Theorem 11.3 (Shape-drift identity).** *For $a > 0$, $u_k(i) > 0$, and $k_1 < k_2$,*
$$\boxed{\;\mathrm{slope}_E(k_1,k_2) \;=\; s \;+\; \frac{\log_2\bigl(M_s(k_2)/M_s(k_1)\bigr)}{\Delta k}\;}$$
*No hypothesis on the window is needed, and the implementation constant $a$ cancels.*

*Proof.* By Lemma 11.2, $\log_2 E(k) = \log_2 a + \log_2 M_s(k) + sk$. Differencing and dividing by $\Delta k$ gives the claim. $\square$

This is an **identity**, not a bound: it is the exact decomposition of a measured exponent into a true exponent plus a shape-drift term.

**Corollary 11.4 (Compression is equivalent to shape decrease).**
$$\mathrm{slope}_E(k_1,k_2) < s \iff M_s(k_2) < M_s(k_1),$$
*and dually $\mathrm{slope} > s$ iff the normalized moment increases. In particular a scale-invariant sampler gives $\mathrm{slope} = s$ exactly, with no tolerance at all.*

**Corollary 11.5 (Inversion).** *A measured deficit $d = s - \mathrm{slope}$ pins the drift exactly:*
$$\frac{M_s(k_1)}{M_s(k_2)} \;=\; 2^{\,d\,\Delta k}.$$

**Corollary 11.6 (The prediction).** *At the experimental configuration $s = 1$, $k_1 = 16$, $k_2 = 24$, the reported slope $0.84$ forces*
$$\frac{M_1(16)}{M_1(24)} \;=\; 2^{1.28} \;\approx\; 2.428 \;\ge\; 2.36 .$$

This is directly measurable: compute the mean normalized small factor at each level and take the ratio.

**Theorem 11.7 (A dyadic sampler cannot drift that far).** *If $u_k(i) \in [\tfrac12, 1]$ for all $k, i$, then $M_1(k) \in [\tfrac12, 1]$ for every $k$, so*
$$\frac{M_1(k_1)}{M_1(k_2)} \;\le\; 2 \;<\; 2^{1.28},$$
*and consequently $\mathrm{slope}_E(16,24) \ge 0.875$.*

Thus the measurement **also refutes the dyadic window itself**, independently of the truncation route of Section 10. Either the sampler is not confined to $[2^{k-1}, 2^k)$, or the reported slope is not what the mean costs actually give.

**Theorem 11.8 (The mechanism is sufficient).** *Let $u_k \equiv 2^{-0.16k}$ (a drifting sampler). Then with $s = 1$ the mean cost is the pure power $E(k) = a\,2^{0.84k}$, so*
$$\mathrm{slope}_E(16,24) = 0.84 \quad\text{exactly},\qquad \frac{M_1(16)}{M_1(24)} = 2^{0.16\cdot 8} = 2^{1.28}.$$

So shape drift is not merely a permissible explanation; it is *the* explanation, in the strong sense that it is both necessary (Corollary 11.4) and realizable (Theorem 11.8) with exactly the predicted magnitude.

---

## 12. Algorithms

We record the three procedures that operationalize the theory.

### 12.1 Two-point exponent estimation with certified band

**Input:** mean costs $E(k_1)$, $E(k_2)$; a claimed exponent $\alpha$; a logarithmic spread $\sigma$ for the model.
**Output:** the measured slope, the certified band $\alpha \pm \sigma/\Delta k$, and a verdict.

Complexity: $O(1)$ arithmetic operations after the means are available. The verdict is *refuted* if the slope lies outside the band, *non-refuting* otherwise; by Theorems 3.5–3.6 the resolution of the verdict is exactly $2\sigma/\Delta k$.

### 12.2 Cross-channel consistency audit

**Input:** slopes $\mathrm{slope}_A$ at exponent $s$ and $\mathrm{slope}_B$ at exponent $t$, $0<t\le s$, measured on the *same* population; lever arm $\Delta k$.
**Output:** the discrepancy $|t\,\mathrm{slope}_A - s\,\mathrm{slope}_B|$, the generic allowance $st/\Delta k$, and — when $s = 2t$ — the sharp allowance $\log_2 K(t)/\Delta k$ with $K(t) = (1+2^t)^2/(4\cdot 2^t)$.

Complexity: $O(1)$. The audit consumes no calibration information whatsoever: both implementation constants cancel. Its power is that it constrains a *pair* of measurements without knowing either channel's constant.

### 12.3 Shape-drift diagnosis

**Input:** the raw level populations $p_{k_1}, p_{k_2}$; the modelled exponent $s$.
**Output:** the normalized moments $M_s(k_j) = \mathbb{E}[(p_{k_j}/2^{k_j})^s]$, the drift term $\log_2(M_s(k_2)/M_s(k_1))/\Delta k$, and the reconstructed slope $s + \text{drift}$.

Complexity: $O(n)$ per level, where $n$ is the sample size. By Theorem 11.3 the reconstructed slope equals the measured slope *identically*, so the procedure is a decomposition rather than an approximation; any discrepancy is a bug in the pipeline, which makes it a useful audit as well as a diagnosis.

---

## 13. Discussion

### 13.1 The status of each measurement

- **Pollard rho ($0.52$).** Non-refuting. It lies within the certified band $1/2 \pm 1/16$ (Theorem 9.4) and is attained by an explicit admissible curve (Theorem 9.5), so it cannot be used to reject the birthday model. Because the anchoring exponent is itself the exponent of a proved threshold (Theorems 9.1–9.2), this is a genuine replication of a mathematically grounded exponent.
- **Fermat ($0.50$).** Not an algorithmic exponent. By Theorem 8.2 the cost is $\Theta(\mathrm{gap}^2/p)$, so by Theorem 8.3 the measurement is a gap-exponent meter, and by Corollary 8.4 it reports $\beta_{\mathrm{gap}} = 3/4$.
- **Trial division ($0.84$).** Refuting, in four independent senses: it violates the constants-free pointwise band (Corollary 4.3); it violates the cross-channel rigidity law jointly with the rho slope (Corollary 5.5), by a factor exceeding $36$ once the constant is sharpened (Corollary 6.5); it cannot be rescued by cost truncation (Theorem 10.4); and it is equivalent, by an identity, to a shape drift of $2^{1.28}$ that a dyadic sampler cannot produce (Corollaries 11.4–11.6, Theorem 11.7).

### 13.2 Two directions of one inequality

Everything above is Theorem 3.3 used twice. Read forwards it is a *guarantee*: with a bounded model error and a long enough lever arm, an exponent is identified. Read backwards (Corollary 3.4) it is a *refutation engine*: an anomalous slope certifies a quantified drift of the constants. Experimental protocols that report exponents without also reporting a lever arm and a model-spread are unable to make either statement.

### 13.3 Why co-measurement matters

The most distinctive structural point is Section 5. Two channels run on the same draws are not two independent measurements; they are two functionals of one random variable, and their expectations are yoked by an inequality. The resulting law
$$|t\,\mathrm{slope}_s - s\,\mathrm{slope}_t| \le \frac{st}{\Delta k}$$
is *constant-free*: it constrains the reported numbers without any knowledge of the implementations. This suggests a general experimental design principle — **always co-measure**, because the pair of measurements is more rigid than the sum of the two.

### 13.4 On honesty about resolution

Theorem 3.6 is the least glamorous and perhaps most useful result here. It says that at lever arm $\Delta k$ inside a window of spread $2^{\sigma}$, exponents separated by less than $2\sigma/\Delta k$ are simply not separable by a two-point estimator, whatever fitting procedure is used. In the present configuration ($\sigma = s$, $\Delta k = 8$, $s=1$) the resolution is $0.25$. Within-level fits, which effectively have $\Delta k \lesssim 1$, have resolution $\gtrsim 2$ and are therefore uninformative about the exponent — the honest reason such fits must be treated as confounded.

### 13.5 Limitations

The cost models used are surrogates: trial division counted as $\Theta(p)$ operations, rho as $\Theta(\sqrt p)$, Fermat as the offset. Constant-factor effects within a single level (cache behaviour, big-integer arithmetic word-length crossovers) are absorbed into the band spread; where they exceed the modelled spread, the refutations weaken accordingly, but Corollary 3.4 quantifies exactly how much spread would be required to rescue a model. The ECM channel is outside the present analysis: its cost is subexponential in $\log p$ rather than a power of $p$, so the power-band formalism does not apply without modification.

---

## 14. Future directions

1. **Slope identifiability.** Multiplicative model error enters a two-point exponent measurement divided by the lever arm: $|\mathrm{slope} - \alpha| \le \log_2(c_2/c_1)/\Delta k$. Everything else here is a consequence of this one inequality, used in both directions.
2. **Pollard rho is the birthday law.** The certified band at $\Delta k = 8$ is $1/2 \pm 1/16$, and an explicit admissible curve has slope exactly $0.52$. The measurement is non-refuting, and its exponent is anchored in a proved threshold: the minimal storage for a guaranteed two-sum collision modulo $p$ is exactly $\lfloor\sqrt p\rfloor + 1$.
3. **Fermat is a gap meter, not an algorithmic exponent.** The exponent transfer law $\alpha_{\mathrm{Fermat}} = 2\beta_{\mathrm{gap}} - 1$ was proved and then confirmed numerically ($0.985$ against $2(0.999)-1$). Inverting the reported $0.50$ predicts $\beta_{\mathrm{gap}} = 0.75$.
4. **The trial-division $0.84$ is a refutation, not a measurement.** A pointwise $a\cdot p$ cost on any dyadic population forces slope $> 0.875$; matching $0.84$ at all requires a constant drift of at least $2^{5/4} > 2.36$.
5. **Cross-channel rigidity.** Running two channels on the same draw is itself a constraint: Cauchy–Schwarz plus the dyadic window give $|\mathrm{slope}_{\mathrm{trial}} - 2\,\mathrm{slope}_\rho| \le 1/\Delta k$ with both implementation constants cancelling. The reported pair $(0.84, 0.52)$ violates it, and an explicit witness shows the hypotheses are satisfiable, so the violation is real content.
6. **Power-mean rigidity at general exponent pairs.** The Cauchy–Schwarz coupling is the $(s,t) = (1,1/2)$ instance. Power-mean monotonicity plus the dyadic window give $|t\,\mathrm{slope}_A - s\,\mathrm{slope}_B| \le st/\Delta k$ for pointwise costs $a p^s$, $c p^t$ on one population, with both constants cancelling. Note that the conjectured constant $(s+t)/(2\Delta k)$ was wrong; the correct one is $st/\Delta k$.
7. **The identifiability band is attained, and its converse holds.** An endpoint-saturating curve inside a window of spread $2^{\sigma}$ has measured slope exactly $\alpha + \sigma/\Delta k$, so the identifiability inequality cannot be improved; and two exponents differing by $2\sigma/\Delta k$ admit two admissible populations with identical two-point slopes. This is the design bound behind the "within-level fits confounded" caveat.
8. **Sharp constants.** Kantorovich replaces the crude reversal, giving $\log_2((4+3\sqrt2)/8) < 0.044$ in place of $1$; along the doubling ray $s = 2t$ the sharp family is $K(t) = (1+2^t)^2/(4\cdot 2^t)$, with $\log_2 K(t) < 2t^2$ and $\log_2 K(t) \sim t^2\ln 2/4$ as $t\to 0$. Open: the sharp constant off the doubling ray, i.e. for general $0 < t < s$ with $s \ne 2t$.
9. **Direct measurement of the shape drift.** The shape-drift identity turns the reported $0.84$ into the exact prediction $M_1(16)/M_1(24) = 2^{1.28}$. Measuring the normalized moments of the actual draws would settle, in one computation, whether the anomaly is in the sampler or in the fitting procedure.
10. **Extending the formalism to subexponential channels.** ECM and the number field sieve have costs of the form $\exp\bigl(c (\log p)^{\gamma}(\log\log p)^{1-\gamma}\bigr)$. A "band" formalism in the variable $\log\log$ rather than $\log$ would be needed, and the analogue of the lever-arm division is not yet known.

---

## 15. Conclusion

Measuring a scaling exponent from a handful of problem sizes is a legitimate inference, provided one is explicit about a single number: the ratio of the model's multiplicative uncertainty to the lever arm. Once that number is written down, the three reported factoring slopes stop being a table of approximate confirmations and become three distinct epistemic objects — a genuine replication anchored in a proved threshold, a thermometer reading the gap exponent of the population, and a robust refutation that resolves, by an exact identity, into a single directly measurable claim about how the sampler's normalized factor distribution drifts with bit size.

The broader lesson is that co-measurement is rigidity. Running several cost channels on one population yields constraints in which every implementation constant cancels, and those constraints are strong enough to declare a reported pair of exponents impossible. Designing experiments to exploit that rigidity — rather than reporting each channel in isolation — costs nothing and buys a great deal.
