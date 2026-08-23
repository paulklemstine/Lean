# Finite-Key Bounds on a Certified Asymptotic Core

## Rational certificates for the BB84 key rate and a two-sided inverse-square law for the break-even block size

**Aristotle**

---

## Abstract

The Shor–Preskill asymptotic key rate for the BB84 quantum key distribution protocol, $r(Q) = 1 - 2h(Q)$, is positive below the threshold $Q^\ast = 0.1100278644\ldots$ determined by $h(Q^\ast) = 1/2$. Deployment decisions are routinely made by comparing a measured quantum bit error rate against this threshold. We show that this criterion is quantitatively misleading, and we quantify the discrepancy exactly.

We develop a certificate calculus that replaces every real-number computation in the key-rate chain by an exact integer comparison. At a rational error rate $Q = a/(a+c)$ the rate satisfies the identity $(a+c)\,r_{\mathrm{nats}}(Q) = \log(N/D)$ with $N = 2^{a+c}a^{2a}c^{2c}$ and $D = (a+c)^{2(a+c)}$ integers. Combining this with the Padé $[1/1]$ lower bound $\log x \ge 2(x-1)/(x+1)$ turns a single integer inequality into an explicit *rational* lower bound on the rate; a dyadic variant and a hybrid of the two complete the calculus. At $Q = 11\%$ an $823$-digit integer comparison certifies $r \ge 1/6000$ bits per sifted bit.

Feeding these rational cores into the standard finite-key accounting $L(n) = n\rho - C\sqrt{n\ln(1/\varepsilon)}$ and a repaired leftover-hash bound, we obtain an end-to-end guarantee: at $Q = 11\%$, with $C = 10$ and $\varepsilon = 2^{-50}$, the extractable $\varepsilon$-secure key length is *non-positive for every block size $n \le 10^{11}$*, while for $n \ge 10^{12}$ it is at least $n/12000 - 101$ bits.

Our main structural result explains this as a law rather than an accident. Writing $n^\ast(Q)$ for the break-even block size, we prove a two-sided estimate

$$\frac{C^2\ln(1/\varepsilon)}{44\,(Q^\ast - Q)^2} \;\le\; n^\ast(Q) \;\le\; \frac{C^2\ln(1/\varepsilon)}{9\,(Q^\ast - Q)^2}$$

for every $Q \in [10\%, Q^\ast)$, so $n^\ast(Q) = \Theta\big((Q^\ast - Q)^{-2}\big)$ with a certified constant ratio $44/9 < 5$. The lower bound holds for *every* valid rational rate certificate; the upper bound is witnessed by an explicit rational certificate. Both halves follow from one-sided Lipschitz bounds for the binary entropy proved by the same monotonicity template. We also record a vacuity audit of a commonly stated form of the leftover-hash lemma, and give a repaired version with the same conclusion and satisfiable hypotheses. A fully certified six-row parameter table concludes the development.

**Keywords:** BB84, finite-key analysis, Shor–Preskill rate, binary entropy, Padé approximant, leftover hashing, privacy amplification, rational certificates.

---

## 1. Introduction

### 1.1 The threshold and its role

In the BB84 protocol Alice prepares single photons in one of four polarization states drawn from two mutually unbiased bases, Bob measures in a randomly chosen basis, and after public basis reconciliation the two parties retain a *sifted* string of $n$ bits. Comparing a random sample reveals the **quantum bit error rate** (QBER)

$$Q = \Pr[\text{Alice's bit} \ne \text{Bob's bit}].$$

Under the standard conservative assumption that all observed noise is adversarial, the Shor–Preskill analysis yields the asymptotic secret-key rate

$$r(Q) = 1 - 2h(Q), \qquad h(Q) = -Q\log_2 Q - (1-Q)\log_2(1-Q),$$

in bits of final key per sifted bit. It is convenient to work also in nats:

$$r_{\mathrm{nats}}(Q) = \log 2 - 2H(Q), \qquad H(Q) = -Q\log Q - (1-Q)\log(1-Q),$$

with $r = r_{\mathrm{nats}}/\log 2$. The rate is positive precisely on $[0, Q^\ast)$, where $Q^\ast$ is the unique solution in $(0,1/2)$ of $h(Q^\ast) = 1/2$:

$$Q^\ast = 0.1100278644\ldots$$

This is the celebrated "eleven percent" threshold. In practice it is used as an acceptance criterion for a physical link.

### 1.2 Two problems with using the threshold as a figure of merit

**Problem one: the certificate problem.** Near $Q^\ast$ the rate $r(Q)$ is a difference of nearly equal quantities. At $Q = 11\%$ one has $h(Q) = 0.49991596\ldots$ and $r(Q) = 1.680837\times 10^{-4}$: the answer is determined by the fourth decimal place of a difference of numbers near $1/2$. A floating-point evaluation of $r(0.11)$ is not a proof of positivity; it is a computation whose reliability rests on the rounding behaviour of the logarithm implementation. If a security claim depends on the sign of $r(Q)$, the sign should be established exactly.

**Problem two: the finiteness problem.** $r(Q)$ is an asymptotic quantity. Any finite protocol pays a statistical correction of order $\sqrt{n}$ for the fluctuation of empirical entropy estimates around their asymptotic values, plus a constant charge for privacy amplification. Whether a positive asymptotic rate translates into a positive *finite* key length at a realistic $n$ is a separate question — and near the threshold the answer is routinely no.

This paper addresses both problems and shows that they interact: the certificate calculus of §3 supplies exactly the rational data that the finite-key analysis of §§4–5 needs, and the resulting break-even estimate obeys a sharp law (§6).

### 1.3 Contributions

1. **A rational certificate calculus** (§3) for the asymptotic rate at rational QBER, in three forms — dyadic, Padé, and hybrid — each reducing a rate lower bound to a single exact integer comparison, with no floating-point arithmetic anywhere.
2. **A vacuity audit and repair of the leftover-hash bound** (§4): a widely used hypothesis form is unsatisfiable exactly in the regime where it is advertised as strong; a repaired hypothesis matching what two-universal hashing delivers is satisfiable and yields the same conclusion.
3. **An end-to-end finite-key extraction theorem** (§5) and its instantiation at $Q = 11\%$: no positive guarantee below $n = 10^{11}$, at least $n/12000 - 101$ bits above $n = 10^{12}$.
4. **A two-sided inverse-square law** for the break-even block size (§6), with certified constants $44$ and $9$, proved from matching one-sided Lipschitz bounds for the binary entropy.
5. **A certified six-row parameter table** (§7) spanning $Q = 1\%$ to $11\%$, in which the required block size varies by eight orders of magnitude while the asymptotic rate varies by only three and a half.

---

## 2. Preliminaries and notation

Throughout, $\log$ denotes the natural logarithm and $\log_2$ the base-two logarithm. We write

$$H(p) = -p\log p - (1-p)\log(1-p), \qquad h(p) = H(p)/\log 2,$$

with the conventions $H(0) = H(1) = 0$. The function $H$ is continuous on $[0,1]$, differentiable on $(0,1)$ with

$$H'(p) = \log\frac{1-p}{p},$$

which is strictly decreasing, positive on $(0,1/2)$ and zero at $p = 1/2$.

**Definition 2.1 (asymptotic key rate).** The *Shor–Preskill asymptotic key rate* in nats is
$$r_{\mathrm{nats}}(Q) = \log 2 - 2H(Q),$$
and in bits $r(Q) = r_{\mathrm{nats}}(Q)/\log 2 = 1 - 2h(Q)$.

**Definition 2.2 (threshold).** A *threshold* is any $Q^\ast \in [0, 1/2]$ with $r_{\mathrm{nats}}(Q^\ast) = 0$. Since $H$ is strictly increasing on $[0,1/2]$, such a $Q^\ast$ is unique, and it satisfies the certified enclosure

$$0.1100 < Q^\ast < 0.1101.$$

All statements below that mention $Q^\ast$ take as hypothesis only that $Q^\ast$ is a zero of the rate in the appropriate range; no closed form is assumed.

**Definition 2.3 (finite-key length).** For a rational rate certificate $\rho \in \mathbb{Q}_{>0}$ (bits per sifted bit), a rational correction constant $C \in \mathbb{Q}_{\ge 0}$, a block size $n \in \mathbb{N}$ and a security parameter $\varepsilon \in (0,1)$, set

$$L(\rho, C, n, \varepsilon) \;=\; n\rho \;-\; C\sqrt{n \ln(1/\varepsilon)},$$

the *raw finite-key length* in bits, and

$$L_{\mathrm{ext}}(\rho, C, n, \varepsilon) \;=\; L(\rho, C, n, \varepsilon) - 2\log_2(1/\varepsilon),$$

the *extractable length*, which accounts additionally for the privacy-amplification charge.

The parameters $\rho$ and $C$ are deliberately *rational*. The interpretation of $C$ is standard: it aggregates the constants of the entropy-fluctuation (asymptotic equipartition) estimate, and enters the analysis only through the hypothesis that the adversary's min-entropy about the reconciled string is at least $L(\rho, C, n, \varepsilon)$ bits. We never assume this hypothesis silently; it appears as an explicit premise (denoted $\mathsf{AEP}$) in every extraction statement.

---

## 3. A rational certificate calculus for the asymptotic rate

### 3.1 The integer identity at rational QBER

**Lemma 3.1 (rational-QBER identity).** Let $a, c$ be positive integers and $Q = a/(a+c)$. Then

$$(a+c)\, r_{\mathrm{nats}}(Q) \;=\; \log\frac{N}{D}, \qquad N = 2^{a+c}\,a^{2a}\,c^{2c}, \quad D = (a+c)^{2(a+c)}.$$

*Proof.* Write $m = a+c$, so $Q = a/m$ and $1 - Q = c/m$. Then
$$m\, r_{\mathrm{nats}}(Q) = m\log 2 + 2m\big(Q\log Q + (1-Q)\log(1-Q)\big) = m \log 2 + 2a\log\frac{a}{m} + 2c\log\frac{c}{m},$$
and exponentiating the right-hand side gives $2^m a^{2a} c^{2c} / m^{2m} = N/D$. $\square$

Both $N$ and $D$ are integers: at $a+c = 100$ they have roughly $400$ digits. The sign of the rate is now the sign of $N - D$, an exact decision. To convert the sign into a quantitative bound we need rational lower bounds for $\log$.

### 3.2 The Padé $[1/1]$ logarithm bound

**Lemma 3.2 (Padé lower bound).** For all real $x \ge 1$,
$$\log x \;\ge\; \frac{2(x-1)}{x+1}.$$

*Proof sketch.* Let $f(x) = \log x - 2(x-1)/(x+1)$ on $[1,\infty)$. Then $f(1) = 0$ and
$$f'(x) = \frac{1}{x} - \frac{4}{(x+1)^2} = \frac{(x+1)^2 - 4x}{x(x+1)^2} = \frac{(x-1)^2}{x(x+1)^2} \;\ge\; 0.$$
Hence $f$ is nondecreasing on $[1,\infty)$, so $f(x) \ge f(1) = 0$. $\square$

This is the diagonal Padé approximant of $\log$ at $x = 1$; its error is $O((x-1)^3)$, against $O((x-1)^2)$ for the tangent-line bound $\log x \ge 1 - 1/x$. We also need monotonicity of the approximant itself.

**Lemma 3.3 (monotonicity of the Padé functional).** The map $x \mapsto 2(x-1)/(x+1)$ is nondecreasing on $[1,\infty)$.

*Proof.* $2(x-1)/(x+1) = 2 - 4/(x+1)$, manifestly increasing. $\square$

### 3.3 The three certificate schemes

**Theorem 3.4 (Padé certificate).** Let $a, c, \mathrm{num}, \mathrm{den}$ be natural numbers with $a, c, \mathrm{den} > 0$, and suppose the integer inequality

$$(\mathrm{den} + \mathrm{num})\,(a+c)^{2(a+c)} \;\le\; \mathrm{den}\cdot 2^{a+c}\,a^{2a}\,c^{2c}$$

holds. Then

$$r_{\mathrm{nats}}\!\left(\frac{a}{a+c}\right) \;\ge\; \frac{2\,\mathrm{num}}{(a+c)\,(2\,\mathrm{den} + \mathrm{num})}.$$

*Proof sketch.* The hypothesis is exactly $(\mathrm{den}+\mathrm{num})D \le \mathrm{den}\,N$, i.e. $N/D \ge (\mathrm{den}+\mathrm{num})/\mathrm{den} \ge 1$. By Lemma 3.3 followed by Lemma 3.2,
$$\log\frac{N}{D} \;\ge\; \frac{2\big(\frac{\mathrm{den}+\mathrm{num}}{\mathrm{den}} - 1\big)}{\frac{\mathrm{den}+\mathrm{num}}{\mathrm{den}} + 1} \;=\; \frac{2\,\mathrm{num}}{2\,\mathrm{den}+\mathrm{num}},$$
and Lemma 3.1 divides by $a+c$. $\square$

**Theorem 3.5 (dyadic certificate).** If $2^m (a+c)^{2(a+c)} \le 2^{a+c} a^{2a} c^{2c}$ then

$$r\!\left(\frac{a}{a+c}\right) \;\ge\; \frac{m}{a+c} \quad \text{bits per sifted bit.}$$

*Proof sketch.* The hypothesis says $N/D \ge 2^m$, so $\log_2(N/D) \ge m$; apply Lemma 3.1 in base two. $\square$

The dyadic scheme has the pleasant feature that the conclusion carries *no logarithm constants at all* — $m$ is literally a certified lower bound for $\log_2(N/D)$ — but it can only resolve the rate to the nearest $1/(a+c)$ bits, and it degenerates entirely near threshold, where the optimal $m$ is $0$. The two schemes are the extreme faces of a common generalization.

**Theorem 3.6 (hybrid dyadic–Padé certificate).** If

$$(\mathrm{den} + \mathrm{num})\cdot 2^m (a+c)^{2(a+c)} \;\le\; \mathrm{den}\cdot 2^{a+c} a^{2a} c^{2c},$$

then

$$r_{\mathrm{nats}}\!\left(\frac{a}{a+c}\right) \;\ge\; \frac{1}{a+c}\left(m\log 2 + \frac{2\,\mathrm{num}}{2\,\mathrm{den}+\mathrm{num}}\right).$$

*Proof sketch.* Write $y = N/(2^m D)$; the hypothesis says $y \ge (\mathrm{den}+\mathrm{num})/\mathrm{den} \ge 1$. Then $\log(N/D) = m\log 2 + \log y$, and Lemmas 3.2–3.3 bound $\log y$ as in Theorem 3.4. $\square$

Setting $\mathrm{num} = 0$ recovers Theorem 3.5; setting $m = 0$ recovers Theorem 3.4. Both degenerate cases are legal and are recorded explicitly, so the hybrid is a genuine generalization rather than a restatement.

### 3.4 The certified rows

**Theorem 3.7 (rate at $Q = 11\%$).** $\displaystyle r_{\mathrm{nats}}(11/100) \ \ge\ \frac{117}{1005850} \approx 1.163199\times 10^{-4}$ nats, and consequently

$$r(11/100) \;\ge\; \frac{1}{6000} \quad \text{bits per sifted bit.}$$

*Proof sketch.* Apply Theorem 3.4 with $a = 11$, $c = 89$, $\mathrm{den} = 10^4$, $\mathrm{num} = 117$. The required inequality $10117\, D \le 10^4 N$ is an exact comparison between $823$-digit integers. The nat-valued conclusion is $2\cdot 117/(100 \cdot 20117) = 117/1005850$. For the bit form, divide by $\log 2$ using the certified bound $\log 2 < 0.6931471808$; one checks $117/1005850 > 0.6931471808/6000$. $\square$

The choice of the Padé bound is essential here rather than cosmetic. With $N/D = 1.0117188056\ldots$:

| bound on $\log x$ | resulting $r_{\mathrm{nats}}(0.11)$ | in bits |
|---|---|---|
| tangent line $1 - 1/x$ | $1.158307\times 10^{-4}$ | $1.671083\times 10^{-4}$ |
| Padé $2(x-1)/(x+1)$ | $1.165054\times 10^{-4}$ | $1.680818\times 10^{-4}$ |
| truth | $1.165067\times 10^{-4}$ | $1.680837\times 10^{-4}$ |

The tangent-line bound loses $6.8\times 10^{-7}$ nats; the Padé bound loses $1.3\times 10^{-9}$, i.e. it removes better than $99\%$ of the deficit. The target rational $1/6000 = 1.666667\times 10^{-4}$ bits is cleared by $0.85\%$ under Padé but by only $0.27\%$ under the tangent line, which is too tight to be robust to the certified rounding of $\log 2$. (The rounding to $\mathrm{num} = 117$ costs a further $1.9\times 10^{-7}$ nats, so the certificate's bit value is $1.678136\times 10^{-4}$, still comfortably above $1/6000$.)

**Theorem 3.8 (dyadic rows).** With $a + c = 100$ the dyadic certificates hold with $m = 83, 71, 42, 19, 6$ at $Q = 1\%, 2\%, 5\%, 8\%, 10\%$ respectively, giving

$$r(0.01) \ge 0.83, \quad r(0.02) \ge 0.71, \quad r(0.05) \ge 0.42, \quad r(0.08) \ge 0.19, \quad r(0.10) \ge 0.06.$$

Each of these is sharp for the scheme: $m+1$ fails in every case, since $100\,r$ equals $83.841$, $71.712$, $42.721$, $19.564$, $6.201$ respectively.

**Theorem 3.9 (hybrid row at $Q = 10\%$).** $r(1/10) \ge 62/1000 = 0.0620$ bits per sifted bit.

*Proof sketch.* Apply Theorem 3.6 with $a = 10$, $c = 90$, $m = 6$, $\mathrm{den} = 10^4$, $\mathrm{num} = 1493$. Here $y = N/(2^6 D) = 1.1494002612\ldots$, and $y \ge 11493/10000$ is an exact integer comparison. $\square$

The improvement over the dyadic row is substantial. The raw hybrid bound with $\mathrm{num} = 1493$ is $0.06200432$ against a true value of $0.06200881$, reducing the certificate's error from the dyadic $2.0\times 10^{-3}$ to $4.5\times 10^{-6}$, a $450$-fold reduction; rounding down to the clean rational $62/1000$ still leaves an error of only $8.8\times 10^{-6}$. (With the optimal numerator $\mathrm{num} = 1494$ the hybrid attains $0.06200557$, an error of $3.2\times 10^{-6}$.) The residual error of the hybrid is $O((y-1)^3)$, which explains its uniform sharpness once a dyadic step brings $y$ close to $1$.

---

## 4. Privacy amplification: a vacuity audit and a repair

### 4.1 The Cauchy–Schwarz core

Let $p : \{0,1\}^\ell \to \mathbb{R}$ be a probability-normalized vector, $\sum_i p_i = 1$. The statistical distance of $p$ from uniform is controlled by its collision probability via Cauchy–Schwarz:

$$\sum_i \left| p_i - 2^{-\ell} \right| \;\le\; \sqrt{2^\ell \sum_i p_i^2 - 1}. \tag{4.1}$$

This is the analytic core of the leftover-hash lemma and is not in dispute.

### 4.2 A vacuous hypothesis

A commonly stated form of the privacy-amplification bound takes as hypothesis $\sum_i p_i^2 \le 2^{-k}$, where $k$ is the min-entropy of the source, and concludes closeness to uniform when $\ell < k$. We record that this hypothesis has no instances in precisely that regime.

**Proposition 4.1 (collision probability is at least uniform).** Every $p : \{0,1\}^\ell \to \mathbb{R}$ with $\sum_i p_i = 1$ satisfies $\sum_i p_i^2 \ge 2^{-\ell}$. (Nonnegativity of $p$ is not required.)

*Proof.* By Cauchy–Schwarz, $1 = \big(\sum_i 1\cdot p_i\big)^2 \le 2^\ell \sum_i p_i^2$. $\square$

**Corollary 4.2 (vacuity).** If $\ell < k$, there is no normalized $p$ on $\{0,1\}^\ell$ with $\sum_i p_i^2 \le 2^{-k}$.

*Proof.* Combine Proposition 4.1 with $2^{-k} < 2^{-\ell}$. $\square$

Thus a theorem of the shape "if $\sum p^2 \le 2^{-k}$ and $\ell < k$ then the output is secure" is true but has no instances: it establishes nothing about any protocol.

### 4.3 The repair

Two-universal hashing does not deliver $\sum p^2 \le 2^{-k}$; it delivers $\sum p^2 \le 2^{-\ell} + 2^{-k}$. This is the hypothesis to use.

**Theorem 4.3 ($\varepsilon$-security of privacy amplification).** Let $p$ be normalized on $\{0,1\}^\ell$ with
$$\sum_i p_i^2 \;\le\; 2^{-\ell} + 2^{-k},$$
let $\varepsilon > 0$, and suppose the leftover-hash budget
$$\ell + 2\log_2(1/\varepsilon) \;\le\; k$$
is met. Then $\sum_i |p_i - 2^{-\ell}| \le \varepsilon$.

*Proof sketch.* The key algebraic collapse is exact:
$$2^\ell\big(2^{-\ell} + 2^{-k}\big) - 1 \;=\; 2^{\ell - k}.$$
Substituting into (4.1) gives $\sum_i |p_i - 2^{-\ell}| \le 2^{(\ell-k)/2}$. The budget hypothesis rearranges to $\ell - k \le -2\log_2(1/\varepsilon) = 2\log_2\varepsilon$, whence $2^{(\ell-k)/2} \le 2^{\log_2 \varepsilon} = \varepsilon$. $\square$

**Proposition 4.4 (satisfiability).** For all $\ell, k$ the uniform distribution on $\{0,1\}^\ell$ satisfies both hypotheses of Theorem 4.3: it is normalized and has $\sum_i p_i^2 = 2^{-\ell} \le 2^{-\ell} + 2^{-k}$.

So the repaired statement has instances for every parameter choice, gives the same conclusion, and — pleasingly — the budget $\ell + 2\log_2(1/\varepsilon) \le k$ emerges from the algebra rather than being imposed. At $\varepsilon = 2^{-50}$ the privacy-amplification charge is exactly $100$ bits.

---

## 5. Finite-key extraction

### 5.1 The sign of the finite-key length

**Lemma 5.1 (sign criterion).** Let $\rho > 0$, $C \ge 0$ be rational and $n \ge 1$. Then

$$L(\rho, C, n, \varepsilon) < 0 \iff n\rho^2 < C^2 \ln(1/\varepsilon).$$

*Proof sketch.* Both directions reduce, after moving the square root to one side, to comparing $C^2 \cdot n\ln(1/\varepsilon)$ with $(n\rho)^2 = n \cdot n\rho^2$ and dividing by $n > 0$; the elementary facts $C\sqrt{x} \le y \Leftarrow C^2 x \le y^2$ (for $C, y \ge 0$) and its strict converse do the rest. $\square$

**Definition 5.2 (break-even block size).**
$$n^\ast(\rho, C, \varepsilon) \;=\; \frac{C^2 \ln(1/\varepsilon)}{\rho^2}.$$

By Lemma 5.1 this is the exact sign change of the raw finite-key length: $L < 0$ strictly below it and $L > 0$ strictly above.

**Lemma 5.3 (half-rate regime).** If $4C^2\ln(1/\varepsilon) \le n\rho^2$ — that is, $n \ge 4n^\ast$ — then $L(\rho, C, n, \varepsilon) \ge n\rho/2$.

*Proof sketch.* The hypothesis gives $C^2 \cdot n\ln(1/\varepsilon) \le (n\rho/2)^2$, hence $C\sqrt{n\ln(1/\varepsilon)} \le n\rho/2$, and subtracting from $n\rho$ leaves at least $n\rho/2$. $\square$

So above four times break-even, at least half the asymptotic budget survives — a convenient clean regime for tabulation.

### 5.2 The extraction theorem

**Theorem 5.4 (finite-key extraction).** Let $\rho, C$ be rational, $n, k \in \mathbb{N}$, $\varepsilon > 0$. Assume

* ($\mathsf{AEP}$) the adversary's min-entropy about the reconciled raw key is at least $L(\rho, C, n, \varepsilon)$ bits, i.e. $L(\rho, C, n, \varepsilon) \le k$;
* the budget is nonnegative: $L_{\mathrm{ext}}(\rho, C, n, \varepsilon) \ge 0$.

Then there exists an output length $\ell \in \mathbb{N}$ with

$$\ell \;\ge\; L_{\mathrm{ext}}(\rho, C, n, \varepsilon) - 1 \;=\; n\rho - C\sqrt{n\ln(1/\varepsilon)} - 2\log_2(1/\varepsilon) - 1$$

such that every distribution $p$ on the $\ell$-bit output with $\sum_i p_i^2 \le 2^{-\ell} + 2^{-k}$ is $\varepsilon$-close to uniform in statistical distance.

*Proof sketch.* Take $\ell = \lfloor L_{\mathrm{ext}} \rfloor$. Then $\ell > L_{\mathrm{ext}} - 1$, giving the length claim. For security, $\ell \le L_{\mathrm{ext}} = L - 2\log_2(1/\varepsilon) \le k - 2\log_2(1/\varepsilon)$ by $\mathsf{AEP}$, which is exactly the leftover-hash budget of Theorem 4.3. $\square$

Note that the physical input — the min-entropy hypothesis $\mathsf{AEP}$ — is carried explicitly. The theorem is a statement about *accounting*, and it is honest about which part is assumed.

### 5.3 The certified instance at $Q = 11\%$

Combining Theorems 3.7 and 5.4 with $\rho = 1/6000$:

**Theorem 5.5 (finite-key BB84 at $Q = 11\%$).** At a measured QBER of exactly $11\%$, with correction constant $C \ge 0$ and security parameter $\varepsilon \in (0,1)$, any min-entropy budget $k$ compatible with $\mathsf{AEP}$ yields an $\varepsilon$-secure extractable key of length at least

$$\frac{n}{6000} \;-\; C\sqrt{n\ln(1/\varepsilon)} \;-\; 2\log_2(1/\varepsilon) \;-\; 1 \quad \text{bits}.$$

Moreover the certified length never exceeds the true asymptotic budget $n\,r(0.11)$, so nothing has been over-claimed: $1/6000$ genuinely under-estimates the asymptotic rate.

Now specialize the standard parameters $C = 10$, $\varepsilon = 2^{-50}$, so $\ln(1/\varepsilon) = 50\log 2 \approx 34.657$ and $\log_2(1/\varepsilon) = 50$.

**Theorem 5.6 (the guarantee is empty below $10^{11}$).** For every $n \le 10^{11}$,
$$L(1/6000,\, 10,\, n,\, 2^{-50}) \;\le\; 0.$$

*Proof sketch.* By Lemma 5.1 it suffices that $n (1/6000)^2 < 100 \cdot 50\log 2$. The left side is at most $10^{11}/(3.6\times 10^7) = 2777.8$, while the right side exceeds $5000 \cdot 0.693 = 3465$. $\square$

**Theorem 5.7 (recovery above $10^{12}$).** For every $n \ge 10^{12}$,
$$L(1/6000,\, 10,\, n,\, 2^{-50}) \;\ge\; \frac{n}{12000}.$$

*Proof sketch.* It suffices that $10\sqrt{n \cdot 50\log 2} \le n/12000$, i.e. $100 \cdot 50 \log 2 \cdot n \le n^2/1.44\times 10^{8}$, which follows from $\log 2 < 0.694$ and $n \ge 10^{12}$. $\square$

**Theorem 5.8 (parameter row at $Q = 11\%$).** For every $n \ge 10^{12}$ and every $k$ satisfying $\mathsf{AEP}$, there is an $\varepsilon$-secure extractable key of length at least

$$\frac{n}{12000} - 101 \quad \text{bits}, \qquad \varepsilon = 2^{-50}.$$

For instance $n = 10^{12}$ gives at least $83\,333\,232$ bits and $n = 10^{14}$ at least $8\,333\,333\,232$ bits.

The exact break-even is $n^\ast = 100 \cdot 50\log 2 \cdot 6000^2 = 1.2477\times 10^{11}$. The two theorems bracket it from below and above by factors of about $1.25$ and $8$ respectively; the gap is the price of clean round constants.

**The deployment moral.** At $Q = 11\%$ the asymptotic theory reports a positive rate and declares the link secure. The finite-key accounting reports *nothing at all* for any block below $10^{11}$ sifted bits — several years of continuous operation at megahertz sifted rates. The threshold and the deliverable disagree by many orders of magnitude.

---

## 6. The two-sided inverse-square law

Section 5 concerns one QBER. We now show the phenomenon is structural, and that the inverse-square shape is exact rather than an artifact.

### 6.1 One-sided Lipschitz bounds for the binary entropy

Both halves come from the same template: for a constant $K$, study monotonicity of $p \mapsto H(p) - Kp$, whose derivative is $\log\frac{1-p}{p} - K$.

**Lemma 6.1 (upper Lipschitz bound).** For $1/10 \le x \le y \le 1/2$,
$$H(y) - H(x) \;\le\; \log 9 \cdot (y - x).$$

*Proof sketch.* Consider $g(p) = \log 9 \cdot p - H(p)$ on $[1/10, 1/2]$. Its derivative is $\log 9 - \log\frac{1-p}{p}$, which is nonnegative there because $\frac{1-p}{p} \le 9$ for $p \ge 1/10$. Hence $g$ is monotone nondecreasing, and $g(x) \le g(y)$ rearranges to the claim. $\square$

**Lemma 6.2 (lower Lipschitz bound).** For $0 < x \le y \le 1/2$,
$$\log\frac{1-y}{y}\cdot(y-x) \;\le\; H(y) - H(x).$$

*Proof sketch.* Set $K = \log\frac{1-y}{y}$ and consider $g(p) = H(p) - Kp$ on $[x,y]$. Its derivative is $\log\frac{1-p}{p} - K$, nonnegative on $[x,y]$ because $\log\frac{1-p}{p}$ is decreasing and $p \le y$. So $g$ is monotone nondecreasing and $g(x) \le g(y)$. $\square$

The two lemmas differ only in whether the constant $K$ sits above or below the range of $H'$ on the interval — a pleasant symmetry that explains why both bounds are available at the same cost.

### 6.2 Linear vanishing of the rate at threshold

**Theorem 6.3 (at most linear vanishing).** Let $Q^\ast \le 1/2$ be a threshold and $1/10 \le Q \le Q^\ast$. Then
$$r_{\mathrm{nats}}(Q) \;\le\; 2\log 9 \cdot (Q^\ast - Q).$$

*Proof.* $r_{\mathrm{nats}}(Q) = r_{\mathrm{nats}}(Q) - r_{\mathrm{nats}}(Q^\ast) = 2\big(H(Q^\ast) - H(Q)\big) \le 2\log 9 (Q^\ast - Q)$ by Lemma 6.1. $\square$

**Theorem 6.4 (at least linear vanishing).** Let $Q^\ast \le 1/5$ be a threshold and $0 < Q \le Q^\ast$. Then
$$r_{\mathrm{nats}}(Q) \;\ge\; 4\log 2 \cdot (Q^\ast - Q), \qquad \text{i.e.} \qquad r(Q) \ge 4(Q^\ast - Q) \ \text{bits}.$$

*Proof.* As above, $r_{\mathrm{nats}}(Q) = 2(H(Q^\ast) - H(Q)) \ge 2\log\frac{1-Q^\ast}{Q^\ast}(Q^\ast - Q)$ by Lemma 6.2. Since $Q^\ast \le 1/5$ we have $\frac{1-Q^\ast}{Q^\ast} \ge 4$, so $\log\frac{1-Q^\ast}{Q^\ast} \ge \log 4 = 2\log 2$. $\square$

The hypothesis $Q^\ast \le 1/5$ is satisfied by the certified enclosure $Q^\ast < 0.1101$. The constant is conservative: at $Q^\ast = 0.110028$ the true slope is $2\log\frac{1-Q^\ast}{Q^\ast} = 4.1809$ nats per unit QBER, against the certified $4\log 2 = 2.7726$, a factor of $1.5$.

### 6.3 The break-even law from below

**Theorem 6.5 (break-even from below).** Let $C > 0$ be rational, let $Q^\ast \le 1/2$ be a threshold, let $Q \in [1/10, Q^\ast]$, and let $\rho > 0$ be *any* rational rate certificate valid at $Q$, i.e. $\rho \le r(Q)$ in bits. Then every $n$ with $L(\rho, C, n, \varepsilon) > 0$ satisfies

$$n \;\ge\; \frac{C^2\ln(1/\varepsilon)}{44\,(Q^\ast - Q)^2}.$$

*Proof sketch.* Positivity of $L$ and Lemma 5.1 force $C^2\ln(1/\varepsilon) \le n\rho^2$. By Theorem 6.3 and the certified bounds $\log 9 \le 2.2726$, $\log 2 > 0.693$,
$$\rho \;\le\; \frac{2\log 9}{\log 2}(Q^\ast - Q) \;\le\; 6.6\,(Q^\ast - Q),$$
whence $\rho^2 \le 44 (Q^\ast - Q)^2$. Substituting gives the claim. $\square$

The universal quantifier over $\rho$ is the point: no improvement in certificate technology can lower the required block size, because the *rate itself* is small near threshold. (The certified constant $44$ over-estimates the true $(2\log 9/\log 2)^2 = 40.2$ by $9\%$.)

**Corollary 6.6 (instance at $Q = 11\%$).** With $C = 10$ and $\varepsilon = 2^{-50}$, since the certified enclosure gives $Q^\ast - 0.11 < 10^{-4}$, no rational rate certificate at $Q = 11\%$ can produce a positive finite-key length below

$$n = 7\times 10^{9} \quad \text{sifted bits.}$$

(The certificate-specific bound $10^{11}$ of Theorem 5.6 is sharper for the particular certificate $\rho = 1/6000$; Corollary 6.6 is weaker but universal.)

### 6.4 The break-even law from above

**Theorem 6.7 (break-even from above).** Let $C > 0$ be rational, $\varepsilon$ with $\ln(1/\varepsilon) \ge 0$, and let $Q^\ast \le 1/5$ be a threshold with $0 < Q < Q^\ast$. Then there exists an *explicit positive rational* $\rho$ with

* validity: $\rho \le r(Q)$ in bits per sifted bit, and
* break-even at most $\dfrac{C^2\ln(1/\varepsilon)}{9\,(Q^\ast - Q)^2}$:

for every $n \ge 1$ with $n \ge C^2\ln(1/\varepsilon)/\big(9(Q^\ast-Q)^2\big)$, one has $L(\rho, C, n, \varepsilon) > 0$.

*Proof sketch.* Put $\delta = Q^\ast - Q > 0$. By Theorem 6.4, $r(Q) \ge 4\delta$ bits. Choose any rational $\rho$ strictly between $3\delta$ and $4\delta$ — such a rational exists by density of $\mathbb{Q}$ — so $\rho$ is valid and $\rho^2 > 9\delta^2$. If $n \ge C^2\ln(1/\varepsilon)/(9\delta^2)$ then $C^2\ln(1/\varepsilon) \le 9 n \delta^2 < n\rho^2$, and Lemma 5.1 (in its strict positive form) gives $L > 0$. $\square$

The construction is entirely rational: no irrational data — not even the value of $Q^\ast$ — is needed beyond the enclosure, since one only needs a rational in an interval of positive length.

### 6.5 The law

**Theorem 6.8 (two-sided inverse-square law).** Let $C > 0$ be rational, $\ln(1/\varepsilon) \ge 0$, let $Q^\ast \le 1/5$ be a threshold, and let $Q \in [1/10, Q^\ast)$. Then:

* **(lower)** *every* valid rational certificate $\rho$ at $Q$ has break-even block size at least $\dfrac{C^2\ln(1/\varepsilon)}{44\,(Q^\ast-Q)^2}$;
* **(upper)** *some* valid rational certificate $\rho$ has break-even block size at most $\dfrac{C^2\ln(1/\varepsilon)}{9\,(Q^\ast-Q)^2}$.

Consequently, writing $n^\ast(Q)$ for the optimal break-even block size at $Q$,

$$n^\ast(Q) \;=\; \Theta\big((Q^\ast - Q)^{-2}\big),$$

with certified constants differing by the factor $44/9 < 5$.

*Proof.* Theorems 6.5 and 6.7. $\square$

**Discussion.** The exponent $2$ is exact and is forced by the $\sqrt{n}$ shape of the statistical correction alone: the break-even condition $n\rho = C\sqrt{n\ln(1/\varepsilon)}$ gives $n \propto \rho^{-2}$ for *any* rate function, and the entropy enters only through the linear vanishing $\rho \asymp \delta$. This separation is why the law is protocol-independent — changing the details of the entropy estimation changes $C$, not the exponent.

The certified ratio $44/9 \approx 4.9$ is a bound on the residual uncertainty. Both constants are conservative: the lower constant $44$ over-estimates $(2\log 9/\log 2)^2 = 40.2$, and the upper constant $9$ under-estimates the achievable $(2\log\frac{1-Q^\ast}{Q^\ast}/\log 2)^2 \approx 36$ near $Q^\ast = 0.11$ by a factor of four (the losses being the conservative slope $4\log 2$ instead of $4.1809$, and the $3\delta/4\delta$ rational-approximation step). With the sharp constants $40.19$ and $36.38$ the ratio would be only $1.10$, so essentially all of the certified factor $4.9$ is recoverable slack rather than genuine uncertainty about $n^\ast$.

**Corollary 6.9 (explicit two-sided instance at $Q = 10\%$).** With $C = 10$, $\varepsilon = 2^{-50}$, and the certified enclosure $Q^\ast > 0.1100$ giving $\delta > 1/100$, the upper half produces an explicit positive rational certificate whose break-even block size is below $4\times 10^{6}$ sifted bits. No irrational or floating-point data enter the construction.

---

## 7. The certified parameter table

Assembling §§3–6 gives a table in which every entry traces back to an exact integer comparison. Throughout $C = 10$ and $\varepsilon = 2^{-50}$, so $\ln(1/\varepsilon) = 50\log 2$ and the privacy-amplification charge is $100$ bits.

**Theorem 7.1 (table row).** Let $\rho \in (0,1]$ be rational and $n, k \in \mathbb{N}$ with $n\rho^2 \ge 13864$ and $\mathsf{AEP}$ satisfied. Then there is an $\varepsilon$-secure extractable key of length at least

$$\frac{n\rho}{2} - 101 \quad \text{bits}.$$

*Proof sketch.* The rational threshold $13864$ exceeds $4C^2\ln(1/\varepsilon) = 20000\log 2 = 13862.9\ldots$, so Lemma 5.3 gives $L \ge n\rho/2$. Since $\rho \le 1$ we also get $n\rho \ge 13864$, hence $L \ge 6932 \ge 2\log_2(1/\varepsilon) = 100$, so the extractable budget is nonnegative and Theorem 5.4 applies. The final $-101$ is the $100$-bit privacy-amplification charge plus one bit of integer rounding. $\square$

| QBER $Q$ | certificate scheme | certified $\rho$ (bits) | true $r(Q)$ | break-even $n^\ast$ | tabulated $n$ | extractable bits |
|---|---|---|---|---|---|---|
| $1\%$ | dyadic, $m = 83$ | $0.83$ | $0.83841$ | $5.0\times 10^{3}$ | $2.5\times 10^{4}$ | $\ge 0.415\,n - 101$ |
| $2\%$ | dyadic, $m = 71$ | $0.71$ | $0.71712$ | $6.9\times 10^{3}$ | $2.8\times 10^{4}$ | $\ge 0.355\,n - 101$ |
| $5\%$ | dyadic, $m = 42$ | $0.42$ | $0.42721$ | $2.0\times 10^{4}$ | $7.9\times 10^{4}$ | $\ge 0.21\,n - 101$ |
| $8\%$ | dyadic, $m = 19$ | $0.19$ | $0.19564$ | $9.6\times 10^{4}$ | $3.9\times 10^{5}$ | $\ge 0.095\,n - 101$ |
| $10\%$ | hybrid, $m=6$, $\mathrm{num}=1493$ | $0.0620$ | $0.0620088$ | $9.0\times 10^{5}$ | $3.7\times 10^{6}$ | $\ge 0.031\,n - 101$ |
| $11\%$ | Padé, $\mathrm{num} = 117$ | $1/6000$ | $0.00016808$ | $1.25\times 10^{11}$ | $10^{12}$ | $\ge n/12000 - 101$ |

The tabulated $n$ is $4n^\ast$ rounded up, the threshold above which Theorem 7.1 applies.

Two observations. First, the certificates are uniformly tight: at every rational $Q$ tried, the certified rate is within $1\%$ of the truth, and at $Q = 10\%$ within $0.015\%$. Second, and more importantly, **the spread of the last two columns is far larger than the spread of the rate column**. From $1\%$ to $11\%$ the asymptotic rate falls by a factor of $5\times 10^3$; the required block size rises by a factor of $4\times 10^7$ — the square, as the inverse-square law predicts. The threshold is a poor proxy for the deliverable because the map from rate to block size is quadratic in the wrong direction.

Comparing rows $5$ and $6$ also shows the value of a sharper certificate. Improving the $10\%$ row from the dyadic $0.0600$ to the hybrid $0.0620$ — an increase of $3.3\%$ in the rate — lowers the required block size from $4.0\times 10^6$ to $3.7\times 10^6$, a $6\%$ reduction, exactly the quadratic amplification again, now working in the engineer's favour.

---

## 8. Algorithms

The whole pipeline is algorithmic. We record the three procedures explicitly.

**Algorithm 1 (rate certificate search).** *Input:* coprime-scaled integers $a, c > 0$; a denominator budget $\mathrm{den}$. *Output:* a certified rational lower bound for $r(a/(a+c))$.

1. Form the exact integers $N = 2^{a+c}a^{2a}c^{2c}$ and $D = (a+c)^{2(a+c)}$.
2. Compute the largest $m$ with $2^m D \le N$ by doubling — this is $m = \lfloor (a+c) r \rfloor$.
3. Set $y = N/(2^m D)$ as an exact rational, and take $\mathrm{num} = \lfloor \mathrm{den}\,(y - 1)\rfloor$.
4. Verify the single integer inequality $(\mathrm{den} + \mathrm{num})\,2^m D \le \mathrm{den}\, N$.
5. Return $\big(m \log 2 + 2\,\mathrm{num}/(2\,\mathrm{den} + \mathrm{num})\big)/(a+c)$ nats.

Cost is dominated by forming $N$ and $D$, i.e. $O\big((a+c)\log(a+c)\big)$-bit integers and a handful of big-integer multiplications; all comparisons are exact.

**Algorithm 2 (break-even and table row).** *Input:* rational $\rho \in (0,1]$, rational $C$, security parameter $\varepsilon$. *Output:* the break-even block size and the guaranteed extractable length as a function of $n$.

1. $n^\ast \leftarrow C^2\ln(1/\varepsilon)/\rho^2$.
2. For $n < n^\ast$ report "no guarantee" (Lemma 5.1 shows the length is genuinely negative, not merely unproven).
3. For $n \ge 4n^\ast$ report the guarantee $n\rho/2 - 2\log_2(1/\varepsilon) - 1$ (Lemma 5.3, Theorem 5.4).
4. In the intermediate band $n^\ast \le n < 4n^\ast$ report the exact $n\rho - C\sqrt{n\ln(1/\varepsilon)} - 2\log_2(1/\varepsilon) - 1$.

**Algorithm 3 (two-sided bracket).** *Input:* a QBER $Q \in [1/10, Q^\ast)$, parameters $C, \varepsilon$; a rational enclosure $[\underline{Q}, \overline{Q}] \ni Q^\ast$. *Output:* a certified interval containing the optimal break-even block size.

1. $\delta_{\min} \leftarrow \underline{Q} - Q$, $\delta_{\max} \leftarrow \overline{Q} - Q$.
2. Lower bound: $C^2\ln(1/\varepsilon)/(44\,\delta_{\max}^2)$ (Theorem 6.5, using the largest possible gap).
3. Upper bound: $C^2\ln(1/\varepsilon)/(9\,\delta_{\min}^2)$ (Theorem 6.7, using the smallest possible gap).
4. Optionally exhibit the witness certificate: any rational in $(3\delta_{\min}, 4\delta_{\min}]$.

---

## 9. Discussion

### 9.1 Why exact arithmetic

The insistence on rational data is not fastidiousness. Near a threshold, the quantity of interest is a difference of large nearly-equal quantities, and this is exactly where floating-point evaluation is least trustworthy. At $Q = 11\%$ the rate is $1.68\times 10^{-4}$, obtained as $1 - 2\times 0.49991596$: four significant digits of cancellation. A security claim resting on such a computation rests on the last bits of a `double`.

Replacing it with integer comparisons costs a little sharpness — the certified $1/6000$ against the true $1/5949$, a loss of $0.8\%$ — and buys unconditional confidence. The loss is quantifiable and, via the hybrid scheme, systematically reducible: the residual of the hybrid bound is $O((y-1)^3)$ in the post-dyadic ratio $y$, so a single dyadic step already brings the certificate within a few parts in $10^5$ of the truth.

### 9.2 The right figure of merit

The practical recommendation is to replace the acceptance criterion "$Q < Q^\ast$" by a break-even computation. Given the security parameter $\varepsilon$ actually required and a correction constant $C$ actually justified by the entropy estimation in use, compute

$$n^\ast = \frac{C^2\ln(1/\varepsilon)}{\rho^2}$$

from a certificate $\rho$ one is prepared to defend, and compare it to the block size the hardware can deliver in the operational time window. Theorem 6.8 gives the order of magnitude without any computation: within a factor of five, $n^\ast$ is $C^2\ln(1/\varepsilon)$ divided by roughly $20(Q^\ast - Q)^2$.

### 9.3 Limitations and scope

Several restrictions deserve emphasis.

* The correction term $C\sqrt{n\ln(1/\varepsilon)}$ is a *model* of the finite-size statistical penalty, not a derivation from a specific entropy-estimation argument. What is proved here is the accounting: given that model and the min-entropy hypothesis $\mathsf{AEP}$, the extractable length and its break-even behave exactly as stated. Different estimation techniques change $C$; none change the exponent in Theorem 6.8.
* The lower half of the two-sided law is stated for $Q \ge 1/10$, because the Lipschitz constant $\log\frac{1-p}{p}$ diverges as $p \to 0$. That is precisely the regime where the rate is large and finite-key corrections are irrelevant, so nothing of interest is lost. The upper half needs only $Q > 0$ and $Q^\ast \le 1/5$.
* The threshold hypothesis is used only in the form "$Q^\ast$ is a zero of the rate in the stated range". No closed form is assumed, and the numerical enclosure $0.1100 < Q^\ast < 0.1101$ enters only in the explicit instances.
* The $\rho \le 1$ hypothesis in Theorem 7.1 is harmless: no BB84 rate exceeds one bit per sifted bit.

### 9.4 Related phenomena

The quadratic amplification observed here — a $3.3\%$ improvement in the certified rate buying a $6\%$ reduction in required block size — is the benign face of the same law that makes near-threshold operation hopeless. It suggests that in the near-threshold regime, effort spent sharpening rate certificates pays a squared dividend in block-size requirements, which is an unusual return on investment in cryptographic engineering.

---

## 10. Future directions

**1. Geometric convergence of iterated root certificates.** The hybrid bound $\log(N/D) \ge m\log 2 + 2(y-1)/(y+1)$ has residual error $O((y-1)^3)$, and $\log y = 2^k \log\big(y^{1/2^k}\big)$. Applying the Padé step at the $k$-th square root should shrink the certificate error like $4^{-k}$, while each step remains a *single integer comparison* on $N^{2^k}$ against a dyadic multiple of $D^{2^k}$. The conjecture is that $k$ steps certify the rate to relative accuracy $4^{-k}$ at a certificate bit-cost linear in $2^k$. The $k = 0$ case is Theorem 3.6, and the observed residual at $Q = 10\%$ ($4.5\times 10^{-6}$ bits per sifted bit, against the dyadic $2.0\times 10^{-3}$) already matches the predicted cubic law to one digit.

**2. Optimal rational approximation of the threshold.** The enclosure $Q^\ast \in (0.1100, 0.1101)$ is produced by integer comparisons whose bit-length grows like $(a+c)\log(a+c)$. The number of correct decimal digits obtained per unit of certificate size should obey an exact yield law, making certificate cost predictable rather than empirical.

**3. Sharpening the two-sided constants.** The certified ratio $44/9$ has two identifiable sources of slack: the conservative slope $4\log 2 = 2.7726$ in place of the true $2\log\frac{1-Q^\ast}{Q^\ast} = 4.1809$, and the $3\delta$ versus $4\delta$ rational-approximation step. Replacing the first by a certified lower bound on the true slope at the enclosed $Q^\ast$, and the second by an adaptive rational search, should bring the ratio below $44/36 \approx 1.2$, at which point the two bounds essentially determine $n^\ast$.

**4. Protocol variants.** The separation argument of §6.5 — exponent from the $\sqrt{n}$ correction, constant from the entropy — suggests that the same two-sided law holds verbatim for decoy-state BB84, six-state, and entanglement-based protocols, with $Q^\ast$ and the Lipschitz constants replaced by the corresponding protocol data. Establishing this uniformly would turn the law into a general design principle for finite-key quantum cryptography.

**5. Second-order finite-key models.** Refined finite-key analyses replace $C\sqrt{n\ln(1/\varepsilon)}$ by an expansion with a $\log n$ term. Since the break-even exponent is driven purely by the shape of the correction, it would be valuable to determine how a $\sqrt{n\ln(1/\varepsilon)} + O(\log n)$ correction perturbs the two-sided law — the expectation being that the exponent survives and only the constants move.

---

## 11. Conclusion

The eleven-percent threshold of BB84 is a correct asymptotic statement and a poor engineering criterion. We have made this precise in two complementary ways. Quantitatively: at a measured QBER of exactly $11\%$, with standard parameters, the certified extractable key length is non-positive for every block size up to $10^{11}$ sifted bits, and only recovers half the asymptotic budget past $10^{12}$. Structurally: the break-even block size obeys a two-sided inverse-square law $n^\ast(Q) = \Theta\big((Q^\ast-Q)^{-2}\big)$, with certified constants $44$ and $9$, so the divergence is a genuine feature of finite-key accounting and not an artifact of any particular estimate.

Underlying both is a certificate calculus in which every rate bound is an exact integer comparison — dyadic, Padé, or hybrid — so that the entire chain from a $400$-digit integer to a parameter table contains no floating-point arithmetic. Along the way, a commonly stated form of the privacy-amplification bound was found to have unsatisfiable hypotheses in its advertised regime, and was replaced by a version with the same conclusion, satisfiable hypotheses, and an exact algebraic derivation of the leftover-hash budget.

The recommendation to practitioners is simple: report break-even block sizes, not threshold margins.
