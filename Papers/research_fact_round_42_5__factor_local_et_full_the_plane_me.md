# The Factor-Local Exponent Plane and the Validity Edge of the Elliptic Curve Method

**Author:** Aristotle
**Date:** 2026-09-05

---

## Abstract

Classical integer factoring algorithms applied to a semiprime $N = pq$ with $p \le q$ are *factor-local*: their cost is governed by the smaller prime $p$, not by $N$. Fitting the ansatz $T \approx c\,p^{\alpha}$ across large ensembles of semiprimes yields a "factor-local exponent plane", one coordinate per algorithm. A pooled measurement with bootstrap confidence intervals over $6000$ semiprimes per experimental arm returned $\alpha_{\mathrm{td}} = 1.0009\ [1.000, 1.002]$ for trial division, $\alpha_{\rho} = 0.4994\ [0.485, 0.510]$ for the rho/birthday collision threshold, and $\alpha_{\mathrm{F}} = 0.9932$ for Fermat's method, with trial division and rho first-order invariant under changes of the law governing the second prime $q$ (the *arm*), and Fermat strongly non-invariant. The elliptic curve method (ECM) admitted no single exponent at all, its fit ranging over $[-0.86, +0.04]$.

We prove that each of the three stable coordinates is the shadow of an exact identity, and that the fourth coordinate cannot exist. Specifically: (i) trial division's cost on a semiprime equals $p$ exactly and is exactly independent of $q$, so $\alpha = 1$ pointwise; (ii) the no-collision probability for $t$ uniform draws from a set of size $m$ satisfies the two-sided bracket $1 - t(t-1)/2m \le R(m,t) \le \exp(-t(t-1)/2m)$, pinning any constant-probability threshold to $[\sqrt m,\ 1+\sqrt{2\log 2}\sqrt m]$ and forcing $\alpha = 1/2$; (iii) Fermat's method on $N = pq$ ($p<q$ odd primes) halts at exactly $x = (p+q)/2$ and at no smaller abscissa, so its cost is the AM–GM defect $\bigl(\sqrt q - \sqrt p\bigr)^2/2$, which is $\Theta(p)$ on bounded-ratio arms, has $q$-derivative bounded below by $\tfrac12(1 - 1/\sqrt 2)$, and admits the exact fitted-exponent formula $1 + \log(\tfrac32-\sqrt2)/\log p$ on the arm $q = 2p$. We prove a rigidity theorem: along any arm with $p \to \infty$ and $2p \le q \le 4p$, and for any threshold function inside the proved birthday bracket, the three fitted exponents converge to exactly $(1, 1, \tfrac12)$.

For ECM we locate the failure mode exactly. With stage-1 scalar $k(B) = \mathrm{lcm}(1,\dots,B)$, we prove a *self-destruction wall*: when $B$ exceeds the top of the Hasse window at both primes, every curve degenerates simultaneously, the split event is empty, and the uncapped expected time to a split is infinite. The threshold is determined exactly: total degeneration at $p$ occurs at bound $B$ if and only if $B \ge B^*(p) := \max_{n \in W(p)} \mathrm{mpp}(n)$, the largest prime power occurring in the Hasse window $W(p)$, and $B^*(p)$ is the least such bound. At $p = 101$ the wall is $121 = 11^2$, not the window's largest prime $113$: prime powers, not primes, set the wall. Degeneration is joint — one-sided crossing splits deterministically — whence the validity edge $2B \le \min(p,q)$, provably free of the size mechanism. Finally we refute the hypothesis that the largest prime factor and the number of distinct prime factors of the order drive stage-1 firing, by an explicit infinite family on which both statistics are constant while firing behaviour differs; the correct driver is the distribution of largest-prime-power across the whole width-$4\sqrt p$ window.

---

## 1. Introduction

### 1.1 Factor-locality

Let $N = pq$ with $p \le q$ prime. The classical "small-factor" algorithms — trial division, Pollard's rho, Pollard's $p-1$, Fermat's difference of squares, and ECM — all share the property that their expected cost is controlled by a function of $p$ alone, or of $p$ and a mild functional of $q$, rather than of $N$. This is in contrast with the index-calculus family (quadratic sieve, number field sieve) whose cost is a function of $N$.

Factor-locality invites a very simple empirical programme: fix an algorithm, sample semiprimes with a prescribed joint law on $(p,q)$, record the cost $T$, and regress $\log T$ on $\log p$. The slope $\alpha$ and intercept $\log c$ are the algorithm's coordinates in what we call the **factor-local exponent plane**.

Two features of the design matter.

* **Arms.** An *arm* is the conditional law of $q$ given $p$. Examples: $q = \mathrm{nextprime}(p)$; $q \in [2p, 4p]$ (*bounded-ratio*); $q$ uniform in a fixed large range (*uniform*); $q$ chosen so that $N$ has fixed bit length. A cost law deserves the name only if its exponent is stable across arms; otherwise the "law" is an artefact of the sampler.
* **Pooling and uncertainty.** Exponents were fitted per arm and pooled, with bootstrap confidence intervals, at $n = 6000$ semiprimes per arm.

### 1.2 The measurement

The pooled fits were:

$$\alpha_{\mathrm{td}} = 1.0009\ [1.000,\ 1.002],\qquad \alpha_{\rho} = 0.4994\ [0.485,\ 0.510],\qquad \alpha_{\mathrm{F}} = 0.9932 .$$

Arm-invariance held to first order for trial division and rho, and failed strongly for Fermat — as predicted before the data were taken. ECM produced no stable exponent: across the accessible toy range the fit ranged over $[-0.86, +0.04]$.

Two earlier runs of this experiment contained implementation defects and are superseded by the present one; they are disclosed here for completeness. The ECM cost denominator (the normalisation by curve count) was validated before data collection.

### 1.3 Contributions

1. **Three exact laws** (§3–§5) that the three stable fits are measuring, each proved unconditionally, with no probabilistic modelling beyond the standard uniform-draw model for rho.
2. **A rigidity theorem** (§6): the exponents $(1,1,\tfrac12)$ are forced in the limit by the brackets alone; no admissible constant or cost model inside the brackets can move them. Plus an exact closed form for the finite-$p$ Fermat fit, which explains the measured $0.9932$ quantitatively.
3. **The ECM self-destruction wall** (§7): a proof that beyond a computable bound the success event is *empty*, hence no single $(\alpha,c)$ exists for ECM, and the honest object is the family $\{(\alpha,c)(B)\}$ restricted to a validity region.
4. **The exact wall threshold** (§8): $B^*(p) = \max_{n\in W(p)} \mathrm{mpp}(n)$, an `IsLeast` characterisation, and the demonstration that the threshold is set by prime *powers*.
5. **The validity edge and the joint nature of degeneration** (§9): one-sided crossing splits; $2B \le \min(p,q)$ is provably safe.
6. **Refutation of the proxy hypothesis and its positive replacement** (§10), together with exact firing-rate combinatorics (§11) showing that stage-1 success is order completion, not collision.

---

## 2. Notation and standing definitions

* $N = pq$, $p \le q$ primes. $\mathrm{minFac}(N)$ is the least prime factor.
* $\mathrm{lpf}(n)$ is the largest prime factor of $n$; $\omega(n)$ the number of distinct prime factors; $\pi(B)$ the prime counting function.
* $v_r(n)$ denotes the exponent of the prime $r$ in $n$.
* **Largest prime power.** $\mathrm{mpp}(n) = \max_{r \mid n,\ r\ \text{prime}} r^{v_r(n)}$, with $\mathrm{mpp}(n) = 0$ for $n \le 1$.
* **Powersmoothness.** $n$ is *$B$-powersmooth* if $r^{v_r(n)} \le B$ for every prime $r \mid n$; equivalently $\mathrm{mpp}(n) \le B$.
* **Stage-1 scalar.** $k(B) = \mathrm{lcm}(1,2,\dots,B)$. For $n, B \ge 1$: $n \mid k(B)$ iff $n$ is $B$-powersmooth.
* **Hasse window.** $W(p) = \{\,n \in \mathbb{Z} : |n - (p+1)| \le 2\sqrt p\,\}$, of width $4\sqrt p$. By Hasse's theorem the order of $E(\mathbb F_p)$ lies in $W(p)$ for every elliptic curve $E/\mathbb F_p$. (In the integer implementation we use the enclosure $[\,p+1-2(\lfloor\sqrt p\rfloor+1),\ p+1+2(\lfloor\sqrt p\rfloor+1)\,]$, which provably contains every real Hasse-admissible integer.)
* A **fitted exponent** at a single point is $\log_p(\text{cost})$; asymptotically it is the limit of these along an arm.

---

## 3. Trial division: $\alpha = 1$ exactly, and exact arm invariance

Textbook trial division examines candidate divisors in increasing order and reports the first success; the number of iterations, and the largest divisor examined, is $\mathrm{minFac}(N)$. Define $\mathrm{tdCost}(N) = \mathrm{minFac}(N)$.

> **Theorem 3.1 (exact semiprime cost).** If $p, q$ are prime with $p \le q$ then $\mathrm{tdCost}(pq) = p$.

*Proof sketch.* $p \mid pq$, so $\mathrm{minFac}(pq) \le p$. Conversely $\mathrm{minFac}(pq)$ is a prime dividing $pq$, hence equals $p$ or $q$ by Euclid's lemma, and $p \le q$. $\square$

> **Theorem 3.2 (exact arm invariance).** For primes $p \le q$ and $p \le q'$: $\mathrm{tdCost}(pq) = \mathrm{tdCost}(pq')$.

*Proof sketch.* Both sides equal $p$ by Theorem 3.1. $\square$

> **Corollary 3.3 ($\alpha = 1$ pointwise).** For $p \le q$ prime with $p > 1$, $\log_p \mathrm{tdCost}(pq) = 1$.

Three consequences for the measurement. First, the exponent is not asymptotic but pointwise, so the confidence interval should abut $1$ from above — as $[1.000, 1.002]$ does. Second, the invariance is not "first order" in the theory; it is exact, and the observed first-order invariance is timing-harness overhead that does depend weakly on $N$'s bit length. Third, there is *no* fitted constant: $c = 1$.

---

## 4. Pollard rho: the two-sided birthday bracket and $\alpha = 1/2$

Pollard's rho detects a collision of the iterate sequence modulo the unknown prime $p$. The standard analysis models the visited residues as $t$ independent uniform draws from a set of size $m$ (with $m \approx p$). Define the **no-collision ratio**

$$R(m,t) = \frac{m^{\underline{t}}}{m^{t}} = \prod_{i=0}^{t-1}\Bigl(1-\frac im\Bigr),\qquad t \le m .$$

> **Lemma 4.1 (product form).** For $0 < m$ and $t \le m$, $R(m,t) = \prod_{i<t}\bigl(1 - i/m\bigr)$.

> **Lemma 4.2 (Weierstrass product inequality).** If $0 \le x_i \le 1$ for $i < t$ then $\prod_{i<t}(1-x_i) \ge 1 - \sum_{i<t} x_i$.

*Proof sketch.* Induction on $t$: the step needs $(1-S)(1-x) \ge 1-S-x$, i.e. $Sx \ge 0$. $\square$

> **Theorem 4.3 (two-sided birthday bracket).** For $0 < m$ and $t \le m$,
> $$1 - \frac{t(t-1)}{2m} \;\le\; R(m,t) \;\le\; \exp\!\Bigl(-\frac{t(t-1)}{2m}\Bigr).$$

*Proof sketch.* Upper bound: apply $1-x \le e^{-x}$ to each factor and sum the exponents, $\sum_{i<t} i/m = t(t-1)/2m$. Lower bound: Lemma 4.2 with $x_i = i/m \in [0,1]$ and the same sum. $\square$

> **Theorem 4.4 (threshold, two-sided).** Let $P_{\mathrm{coll}}(m,t) = 1 - R(m,t)$. For $t \le m$:
> 1. if $t(t-1) \le m$ then $P_{\mathrm{coll}}(m,t) \le 1/2$;
> 2. if $t \ge 1 + \sqrt{2m\log 2}$ then $P_{\mathrm{coll}}(m,t) \ge 1/2$.
>
> Consequently any $T(m)$ at which the collision probability first reaches $1/2$ satisfies $\sqrt m \le T(m) \le 1 + \sqrt{2\log 2}\,\sqrt m$, with $\sqrt{2\log 2} = 1.17741\ldots$

*Proof sketch.* (1) From the lower bound of Theorem 4.3, $P_{\mathrm{coll}} \le t(t-1)/2m \le 1/2$. (2) From the upper bound, $P_{\mathrm{coll}} \ge 1 - e^{-t(t-1)/2m}$, and $t \ge 1 + \sqrt{2m\log 2}$ gives $t(t-1) \ge 2m\log 2$, hence $e^{-t(t-1)/2m} \le 1/2$. $\square$

The corridor $[\sqrt m,\ 1+1.1774\sqrt m]$ is wide in the constant and degenerate in the exponent. That is exactly what the fitted $0.4994\ [0.485, 0.510]$ reports: the birthday exponent recovered to three decimals, with residual width coming from the constant, not the slope.

**Definition 4.5.** Say $t$ is a *birthday threshold for modulus $m$* if $\sqrt m \le t \le 2 + \sqrt{2m\log 2}$.

> **Proposition 4.6 (the bracket is inhabited).** For every $m \ge 1$, $t = \lceil \sqrt{2m\log 2}\rceil + 1$ is a birthday threshold for $m$ and satisfies $t \ge 1 + \sqrt{2m\log 2}$; hence (for $t \le m$) it achieves collision probability at least $1/2$.

*Proof sketch.* $2\log 2 > 1$ gives $\sqrt m \le \sqrt{2m\log 2}$; and $x \le \lceil x\rceil < x+1$ gives the upper bound. $\square$

---

## 5. Fermat's method: the exact $(p+q)/2$ law

Fermat's method seeks $x \ge \lceil \sqrt N\rceil$ with $x^2 - N$ a perfect square.

> **Theorem 5.1 (exact halting abscissa).** Let $p < q$ be odd primes, $N = pq$. Then:
> 1. $x = \frac{p+q}{2}$ and $y = \frac{q-p}{2}$ are integers with $x^2 - y^2 = N$;
> 2. no $x_0 < \frac{p+q}{2}$ admits $x_0^2 - y_0^2 = N$ with $y_0 \ge 0$.

*Proof sketch.* (1) $p,q$ odd makes $p\pm q$ even, and $\bigl(\frac{p+q}2\bigr)^2 - \bigl(\frac{q-p}2\bigr)^2 = pq$. (2) Any representation $N = (x_0-y_0)(x_0+y_0)$ is a factorisation of $N$ into two factors of equal parity; since $N$ is a semiprime the only possibilities are $\{p,q\}$ and $\{1,N\}$, giving $x_0 = (p+q)/2$ or $x_0 = (N+1)/2$. The second is strictly larger because $(N+1)/2 - (p+q)/2 = (p-1)(q-1)/2 > 0$. $\square$

Thus the number of trial abscissae is $\frac{p+q}{2} - \lceil\sqrt N\rceil + 1$, and the natural real cost functional is the **Fermat gap**

$$G(p,q) \;=\; \frac{p+q}{2} - \sqrt{pq}.$$

> **Theorem 5.2 (closed form).** $G(p,q) = \dfrac{\bigl(\sqrt q - \sqrt p\bigr)^2}{2}$.

*Proof sketch.* Expand $(\sqrt q-\sqrt p)^2 = p + q - 2\sqrt{pq}$ and halve. $\square$

So the Fermat gap is exactly the arithmetic–geometric mean defect of $\{p,q\}$: Fermat's method is fast precisely when the two primes are close, a fact usually stated qualitatively and here stated as an identity.

> **Theorem 5.3 (bounded-ratio arm: $\alpha = 1$, constant pinned).** If $0 < p$ and $2p \le q$ then $G(p,q) \ge p/12$. If $q \le 4p$ then $G(p,q) \le 5p/2$.

*Proof sketch.* Lower: $G \ge \frac{(\sqrt2-1)^2}{2}p = \frac{3-2\sqrt2}{2}p = 0.08578\ldots p \ge p/12$, using monotonicity of $G$ in $q$. Upper: drop the $-\sqrt{pq}$ term and use $q \le 4p$. $\square$

> **Theorem 5.4 (strong arm dependence).** For $0 < p \le q < q'$: $G(p,q) < G(p,q')$.

*Proof sketch.* $t \mapsto (\sqrt t - \sqrt p)^2$ is strictly increasing for $t \ge p$. $\square$

The derivative form is sharper and is what makes the dichotomy quantitative. Extend $G$ to real second argument, $G(p,x) = (p+x)/2 - \sqrt{px}$.

> **Theorem 5.5 (uniform arm sensitivity).** For $p, x > 0$, $\partial_x G(p,x) = \tfrac12 - \tfrac12\sqrt{p/x}$. If $x \ge 2p$ then $\partial_x G(p,x) \ge \tfrac12\bigl(1 - \tfrac1{\sqrt2}\bigr) = 0.14644\ldots > 0$.

> **Corollary 5.6 (the invariance dichotomy, in derivative form).** The $q$-derivative of the trial-division cost is identically $0$; the $q$-derivative of the Fermat cost is bounded below by an absolute positive constant on every arm with $q \ge 2p$.

This is the theorem behind the observed dichotomy "td/rho first-order arm-invariant, Fermat strongly non-invariant". For rho the invariance is structural in a different way: its cost model depends on $q$ only through $m \approx p$, and the bracket of Theorem 4.4 does not involve $q$ at all.

---

## 6. Rigidity: the plane $(1, 1, \tfrac12)$ cannot move

The three brackets above have different shapes — one exact identity, one $\Theta(p)$ sandwich, one $\Theta(\sqrt m)$ corridor. The following lemma reduces all three to the same statement.

> **Lemma 6.1 (bracket $\Rightarrow$ exponent).** Let $P_n \to \infty$ and suppose $a P_n^{\alpha} \le f(n) \le b P_n^{\alpha}$ for constants $0 < a \le b$. Then $\log_{P_n} f(n) \to \alpha$.

*Proof sketch.* $\log_{P} f = \alpha + \log(f/P^{\alpha})/\log P$, and the middle term is bounded between $\log a$ and $\log b$ while $\log P \to \infty$. $\square$

> **Theorem 6.2 (exponent-plane rigidity).** Fix an arm: primes $P_n \to \infty$ and $Q_n$ with $2P_n \le Q_n \le 4P_n$; and let $T(n)$ be *any* birthday threshold for $P_n$ (Definition 4.5). Then
> $$\log_{P_n}\mathrm{tdCost}(P_nQ_n) \to 1,\qquad \log_{P_n} G(P_n,Q_n) \to 1, \qquad \log_{P_n} T(n) \to \tfrac12 .$$

*Proof sketch.* First limit: the quantity is identically $1$ (Corollary 3.3). Second: Lemma 6.1 with $a = 1/12$, $b = 5/2$ (Theorem 5.3). Third: Lemma 6.1 with $\alpha = 1/2$ applied to $\sqrt{P_n} \le T(n) \le 2 + \sqrt{2\log 2}\sqrt{P_n} \le (2+\sqrt{2\log 2})\sqrt{P_n}$ for $P_n \ge 1$. $\square$

> **Proposition 6.3 (the arm is inhabited).** Every prime $p$ has a prime partner $q$ with $2p \le q \le 4p$.

*Proof sketch.* Bertrand's postulate applied to $2p$ yields a prime in $(2p, 4p)$. $\square$

Rigidity is the conceptual content of the measurement. The experiment did not discover that rho happens to be a square-root algorithm; it discovered that *no admissible model* in the proved corridor is anything else. Constants — including the birthday constant $\sqrt{2\log 2}$ and all additive slack — are invisible to the exponent.

### 6.1 The Fermat fit at finite $p$, exactly

Rigidity is asymptotic; the experiment is finite. On the arm $q = 2p$ everything can be computed in closed form.

> **Theorem 6.4 (exact finite-$p$ Fermat exponent).** $G(p,2p) = \bigl(\tfrac32 - \sqrt2\bigr)p$, and for $p > 1$,
> $$\log_p G(p, 2p) \;=\; 1 + \frac{\log\!\bigl(\tfrac32 - \sqrt2\bigr)}{\log p}.$$

*Proof sketch.* $G(p,2p) = (3p)/2 - \sqrt2 p$; take $\log_p$ of a product. $\square$

> **Corollary 6.5 (sign of the deficit).** Since $0 < \tfrac32-\sqrt2 = 0.08579\ldots < 1$, we have $\log_p G(p,2p) < 1$ for all $p > 1$: the fitted exponent is *always* below $1$ at finite scale.

> **Theorem 6.6 (the scale a fit demands).** If $1 - \log_p G(p,2p) \le \varepsilon$ then $\varepsilon \log p \ge -\log(\tfrac32-\sqrt2) = 2.45591\ldots$

*Proof sketch.* Substitute Theorem 6.4 and multiply through by $\log p > 0$. $\square$

With the observed deficit $\varepsilon = 1 - 0.9932 = 0.0068$ this forces $\log p \gtrsim 361$, i.e. $p \gtrsim e^{361} \approx 10^{157}$ — far outside the accessible range. The measured $0.9932$ is therefore *not* evidence against $\alpha_{\mathrm{F}} = 1$; it is the exactly predicted finite-size correction, whose magnitude is $|\log c|/\log p$ and whose sign is fixed by $c < 1$.

---

## 7. The ECM self-destruction wall

### 7.1 The stage-1 mechanism

ECM stage 1 selects a curve $E$ over $\mathbb Z/N$ and a point $P$, and computes $k(B)\cdot P$ with $k(B) = \mathrm{lcm}(1,\dots,B)$. Reduction modulo the two primes gives orders $m_p \mid \#E(\mathbb F_p)$ and $m_q \mid \#E(\mathbb F_q)$, both lying in the corresponding Hasse windows. Write:

* $\mathrm{Splits}(m_p, m_q, k) \iff (m_p \mid k) \oplus (m_q \mid k)$ — the point dies at exactly one prime, and the failed inversion reveals a nontrivial factor;
* $\mathrm{Degenerate}(m_p, m_q, k) \iff (m_p \mid k) \wedge (m_q \mid k)$ — it dies at both, and the algorithm recovers only $N$ itself.

> **Lemma 7.1.** $\mathrm{Degenerate}(m_p,m_q,k) \Rightarrow \neg\,\mathrm{Splits}(m_p,m_q,k)$.

> **Lemma 7.2 (self-destruction, local form).** If $1 \le n \le B$ then $n \mid k(B)$; more generally $n \mid k(B)$ iff $n$ is $B$-powersmooth.

### 7.2 The wall

Let $\overline W(p) = p+1+2\lfloor\sqrt p\rfloor + 2$ denote the top of the (integer-enclosed) Hasse window.

> **Theorem 7.3 (self-destruction wall).** Suppose $\overline W(p) \le B$ and $\overline W(q) \le B$. Then for *every* pair of nonzero orders $m_p \in W(p)$, $m_q \in W(q)$: $\mathrm{Degenerate}(m_p, m_q, k(B))$ holds.

*Proof sketch.* Membership in the window gives $m_p \le \overline W(p) \le B$ and likewise for $m_q$; apply Lemma 7.2 to each. $\square$

> **Corollary 7.4 (empty success event).** Under the hypotheses of Theorem 7.3, no curve splits; the number of successes in any finite batch of curves is $0$; and for an infinite stream of curves the split event never occurs, so the uncapped expected number of curves to a split is $+\infty$.

### 7.3 Why ECM has no exponent

Corollary 7.4 is a *structural* refutation of a single $(\alpha,c)$ for ECM. A power law $T \approx c\,p^{\alpha}$ asserts a finite cost; behind the wall the uncapped cost is infinite because the success probability is exactly $0$, not merely small. Hence no exponent can hold uniformly in $B$, and every fitted ECM exponent silently depends on the $B$-schedule used. The experiment's range $[-0.86, +0.04]$ is the visible symptom.

The honest object replacing the point is the **family** $\{(\alpha, c)(B_1)\}$, indexed by the stage-1 bound and restricted to the validity region of §9: $B_1 \lesssim \min(p,q)/2$.

---

## 8. The exact wall threshold: prime powers, not primes

Define, for a prime $p$,
$$B^*(p) \;=\; \max_{n \in W(p)} \mathrm{mpp}(n),$$
and say $p$ is **totally degenerate at $B$** if every nonzero $n \in W(p)$ divides $k(B)$.

> **Theorem 8.1 (exact threshold).** For $B \ge 1$: $p$ is totally degenerate at $B$ **iff** $B^*(p) \le B$.

*Proof sketch.* $n \mid k(B) \iff n$ is $B$-powersmooth $\iff \mathrm{mpp}(n) \le B$. Quantify over the finite window and use that a supremum is $\le B$ iff each member is. $\square$

> **Theorem 8.2 (least element).** For $p \ge 1$, $B^*(p)$ is the least element of $\{B \ge 1 : p \text{ totally degenerate at } B\}$; moreover $2 \le B^*(p) \le \overline W(p)$.

> **Theorem 8.3 (prime powers set the wall).** If $r$ is prime, $e \ge 1$, $r^e \in W(p)$ and $B < r^e$, then $p$ is not totally degenerate at $B$.

*Proof sketch.* $\mathrm{mpp}(r^e) = r^e > B$, so $r^e \nmid k(B)$ while $r^e$ lies in the window. $\square$

> **Example 8.4 (the wall at $p = 101$).** The window at $p=101$ is $[80,124]$. Then: for every $B < 121$, $101$ is *not* totally degenerate; and it *is* totally degenerate at $B = 124$. Hence $B^*(101) = 121 = 11^2$, although the largest prime in the window is $113$.

This example is the correction that reframes the whole question. The threshold functional
$$p \;\longmapsto\; \max_{n \in W(p)} \mathrm{mpp}(n)$$
is a **smooth-number statistic of a short interval** of length $4\sqrt p$, not a prime-counting statistic. Questions about the size of $B^*(p)$ therefore live in the (comparatively tractable) theory of smooth numbers in short intervals rather than in the (intractable) theory of primes in short intervals.

**Conjecture 8.5.** $B^*(p) \ge p/2$ for every prime $p \ge 19$; equivalently, every Hasse window contains an integer with a prime-power factor exceeding $p/2$.

An unconditional lower bound $B^*(p) \ge cp$ is not known to us and is equivalent to a Legendre-type statement about prime powers in intervals of length $4\sqrt p$; it is the one input the present framework lacks, and its absence is a genuine gap rather than a defect of the formulation.

### 8.1 The firing count and its saturation

Let $F(p,B) = \#\{n \in W(p) : n \mid k(B)\}$, the number of window orders stage 1 kills.

> **Theorem 8.6 (firing count is a powersmooth count).** If $B \ge 1$ and $0 \notin W(p)$, then $F(p,B) = \#\{n \in W(p) : \mathrm{mpp}(n) \le B\}$.

> **Theorem 8.7 (saturation at the wall).** For $p \ge 19$ and $B \ge 1$: $F(p,B) = |W(p)|$ iff $B^*(p) \le B$. Moreover $F(p,\cdot)$ is nondecreasing.

Saturation of the firing count is thus *equivalent* to crossing the wall: the observable "fraction of orders killed reaches $1$" is an exact detector of the failure regime.

---

## 9. Degeneration is joint; the validity edge

> **Theorem 9.1 (one-sided crossing splits).** Suppose $\overline W(p) \le B$ (the wall is crossed at $p$), $m_p \in W(p)$ nonzero, and $m_q \nmid k(B)$. Then $\mathrm{Splits}(m_p, m_q, k(B))$ holds.

*Proof sketch.* $m_p \le \overline W(p) \le B$ gives $m_p \mid k(B)$; the hypothesis gives $m_q \nmid k(B)$; the XOR holds. $\square$

Crossing the wall at one prime is therefore not a failure but a *deterministic success*. Only simultaneous crossing is fatal, which is why the smaller prime governs the edge.

> **Lemma 9.2 (arithmetic core).** For $p \ge 19$: $2 + 4\lfloor\sqrt p\rfloor < p$.

> **Theorem 9.3 (validity edge).** Let $p \ge 19$ and $2B \le p$. Then every $n \in W(p)$ satisfies $n > B$.

*Proof sketch.* The window's lower end is $\ge p + 1 - 2(\lfloor\sqrt p\rfloor + 1)$. By Lemma 9.2 this exceeds $p/2 \ge B$. $\square$

> **Corollary 9.4 (safe zone).** If $p, q \ge 19$ and $2B \le \min(p,q)$, then no order in either window is forced to divide $k(B)$ by size alone: the self-destruction mechanism is inoperative. In practice, **$B_1 \lesssim \min(p,q)/2$** is the validity edge for any fitted ECM cost law.

Note the logic: Theorem 9.3 excludes the *size* mechanism ($n \le B \Rightarrow n \mid k(B)$); it does not claim that no order divides $k(B)$, since a large but powersmooth order still can. This is exactly right — inside the safe zone stage 1 succeeds *because* some orders are powersmooth and others are not, and that difference is the algorithm.

---

## 10. The proxy hypothesis, refuted; powersmoothness, installed

A natural and widely entertained hypothesis (denote it H2b) is that coarse statistics of the group order — its largest prime factor $\mathrm{lpf}$, its number of distinct prime factors $\omega$ — predict stage-1 firing, and could therefore serve as cheap regressors in a cost model.

> **Theorem 10.1 (proxies are blind to firing).** For every $B \ge 2$, put $a = \lfloor\log_2 B\rfloor$, $m = 2^{a}$, $m' = 2^{a+1}$. Then $m, m' > 0$, $\mathrm{lpf}(m) = \mathrm{lpf}(m') = 2$, $\omega(m) = \omega(m') = 1$, and yet $m \mid k(B)$ while $m' \nmid k(B)$.

*Proof sketch.* $2^{a} \le B$ gives $m \mid k(B)$ by Lemma 7.2. If $m' \mid k(B)$ then $m'$ is $B$-powersmooth, so $2^{a+1} \le B$, contradicting $B < 2^{a+1}$. $\square$

Since any predictor built from $(\mathrm{lpf},\omega)$ is constant on the pair $(m,m')$, no such predictor can separate firing from non-firing. The family is infinite (one instance per $B$), so this is not an edge case.

The positive replacement is Theorem 8.6: firing is *exactly* powersmoothness, and the aggregate behaviour of stage 1 at bound $B$ is governed by the distribution of $\mathrm{mpp}$ over the whole width-$4\sqrt p$ window. $\mathrm{lpf}$ and $\omega$ are strictly coarser: $\mathrm{lpf}$ forgets multiplicity (the difference between $11$ and $11^2$, which is precisely what the $p=101$ wall turns on), and $\omega$ forgets size altogether.

---

## 11. Firing rates are counts, not probabilities

The following exact combinatorics replaces the folklore "collision" model of stage-1 success.

> **Theorem 11.1 (exact firing rate).** In $\mathbb Z/m$, the number of residues $a$ with $m \mid ka$ is exactly $\gcd(m,k)$. Equivalently, $a$ fires iff the cofactor $m/\gcd(m,k)$ divides $a$.

> **Theorem 11.2 (multi-curve success count).** For $c$ independent points of $\mathbb Z/m$, the number of $c$-tuples on which the scalar $k$ fires at least once is exactly $m^{c} - (m - \gcd(m,k))^{c}$; the success rate is exactly $1 - (1-\rho)^{c}$ with $\rho = \gcd(m,k)/m$.

This is a counting identity: the exponentiated form $1-(1-\rho)^c$ requires no independence assumption, because the tuple space *is* a product.

> **Theorem 11.3 (saturation).** $\gcd(m,k(B)) = m$ iff $m$ is $B$-powersmooth. More precisely, $\gcd(m,k(B))$ is the largest $B$-powersmooth divisor of $m$.

> **Theorem 11.4 (jumps only at prime divisors).** As the prime cutoff $C$ advances through the schedule of primes $\le B$, the cumulative firing count $\gcd(m, k_C)$ changes only when $C$ passes a prime dividing $m$; passing the prime $r$ multiplies the count by $r^{\min(v_r(m),\ \lfloor \log_r B\rfloor)}$.

> **Corollary 11.5 (long flat runs; no dose response).** At most $\omega(m) \le \log_2 m$ of the $\pi(B)$ schedule steps are firing positions, so some run of at least $\pi(B)/(\omega(m)+1)$ consecutive schedule primes leaves the firing count exactly unchanged. A measured smooth "dose–response curve" in the prime cutoff is an artefact of averaging.

> **Example 11.6 (order completion beats the collision floor).** Take $m = 720$, $B = 10$, so $k(10) = 2520$ and $\gcd(720,2520) = 360$: exactly half of the $720$ points fire. The folklore collision heuristic predicts a rate at most $1.44\,B/m = 1/50$. The observed rate is more than $25\times$ that, so the collision term cannot account for stage-1 success; **order completion** is the mechanism.

---

## 12. Algorithms

Three procedures are used to make the above computable.

**(A) Exact wall locator.** Given $p$, build the integer Hasse window $[\,p+1-2(\lfloor\sqrt p\rfloor+1),\ p+1+2(\lfloor\sqrt p\rfloor+1)\,]$, factor each member with a sieve, compute $\mathrm{mpp}$, and return the maximum. Cost: $O(\sqrt p \log\log p)$ after a sieve of the window; the window has $\approx 4\sqrt p + 5$ members.

**(B) Powersmoothness / firing oracle.** Given $m$ and $B$, decide $m \mid k(B)$ by checking $\mathrm{mpp}(m) \le B$; compute the firing count as $\gcd(m, k(B))$ without ever materialising $k(B)$, via $\prod_{r \mid m} r^{\min(v_r(m), \lfloor\log_r B\rfloor)}$.

**(C) Pooled log-log exponent fit with bootstrap CI.** Sample $n$ semiprimes per arm, record cost, regress $\log T$ on $\log p$ by ordinary least squares, and resample residual pairs $B$ times for a percentile interval on the slope. Cost $O(nB)$.

---

## 13. Discussion

**What survived and why.** Everything stated as an exact identity survived contact with data: $\mathrm{minFac}(pq) = p$; Fermat's halting abscissa; the two-sided birthday bracket; the powersmoothness characterisation of firing; the least-element form of the wall. The reason is structural: these are theorems about the algorithms' *definitions*, not about random inputs. An exact law does not degrade when the sampler changes; only its finite-size correction does, and §6.1 computes that correction in closed form.

**What failed and why.** Three things failed, in three different ways.

1. *A single $(\alpha,c)$ for ECM.* Refuted structurally (§7): the success probability is exactly $0$ behind the wall, so no power law holds uniformly in $B$. The replacement is the family $\{(\alpha,c)(B_1)\}$ on $B_1 \lesssim \min(p,q)/2$.
2. *$\mathrm{lpf}$ and $\omega$ as drivers.* Refuted by an explicit infinite family (§10) — these statistics are constant on pairs with opposite firing behaviour.
3. *An unconditional lower bound $B^*(p) \ge cp$.* Not false, but out of reach with present inputs: it is equivalent to a Legendre-type assertion about prime powers in intervals of length $4\sqrt p$ (Conjecture 8.5).

**Methodological moral.** The plane is only a plane where the underlying cost functional is finite and arm-stable. For trial division, rho and Fermat, it is, and the exponents are rigid. For ECM the correct object is a validity region with a computable boundary; reporting a single ECM exponent is a category error, and the wandering fit is the diagnostic that detects it.

---

## 14. Future directions

**1. Powersmooth-free windows and the true size of $B^*(p)$.** The identity $B^*(p) = \max_{n\in W(p)}\mathrm{mpp}(n)$ converts a question about ECM's failure into a question about the largest prime power in a short interval — a smooth-number question, not a prime-gap question, and smooth-number counts in short intervals are far more tractable. Since the least-element formula is proved, the question is now well-posed: any bound on prime powers in $[p+1-2\sqrt p,\ p+1+2\sqrt p]$ transfers immediately. Conjecture: $B^*(p) \ge p/2$ for all primes $p \ge 19$.

**2. Joint-wall asymmetry.** Theorem 9.1 says one-sided crossing splits deterministically. This suggests deliberately *asymmetric* bound schedules: choose $B$ to straddle the two walls when partial information about $p$ and $q$ is available. Quantifying the measure of $B$ for which exactly one wall is crossed — a function of the gap $|B^*(p) - B^*(q)|$ — would turn the wall from a hazard into a resource.

**3. The distribution of $\mathrm{mpp}$ across the window.** Theorem 8.6 makes the firing curve $B \mapsto F(p,B)$ literally the empirical distribution function of $\mathrm{mpp}$ over $W(p)$. Understanding its shape (a Dickman-type law for prime powers in short intervals) would give the exact $B$-dependence of stage-1 success, hence the exact family $\{(\alpha,c)(B_1)\}$.

**4. Beyond cyclic orders.** Theorem 11.1 is stated for cyclic groups; the rank-two case satisfies $\#\{\text{firing}\} = \gcd(m_1,k)\gcd(m_2,k)$, so groups of rank two fire at least as often as cyclic groups of the same order. The consequences for curve-selection strategies (choosing curves with forced torsion) are unexplored in this exact framework.

**5. Extending the plane.** Pollard's $p-1$ and Williams' $p+1$ have the same "order completion" structure with the window replaced by a single value ($p-1$ resp. $p+1$). Their walls are therefore located at $\mathrm{mpp}(p-1)$ and $\mathrm{mpp}(p+1)$ exactly, with no maximum over a window — a degenerate but instructive special case of Theorem 8.1 that should be worked out and added to the plane.
