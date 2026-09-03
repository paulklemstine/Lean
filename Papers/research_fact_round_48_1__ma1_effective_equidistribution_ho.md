# Effectivizing an Equidistribution Assumption: Sharp Transfer Constants, Information Prices, and Scale Decay

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

Many results about primes in arithmetic progressions are proved under an idealization: that the counting functions $\pi(x;m,a)$ are exactly equal to their expected value $\mathrm{Li}(x)/\varphi(m)$ across all reduced residue classes $a$ modulo $m$. Downstream consequences — in particular multiplicative caps of the form $\Phi \le \tfrac43\Psi$ relating two summary statistics of the class counts — then inherit an unquantified error. We replace the idealization by a finite, falsifiable *certificate*: the assertion $|N_a - \mu| \le \varepsilon\mu$ for every class, where $N_a$ is the class count and $\mu$ the common target. From the certificate alone we derive, with no further arithmetic input, a complete accounting of what the idealization costs.

Our main results are: (i) a **transfer theorem** showing that any cap between monotone, positively homogeneous readouts degrades from $\tfrac43$ to $C(\varepsilon) = \tfrac43\frac{1+\varepsilon}{1-\varepsilon}$, together with a matching configuration proving this constant optimal in that class; (ii) a **converse dictionary** $\varepsilon \ge (R-1)/(R+1)$ turning an observed ratio into a refutation of certificates, so that the certificate and the observed ratio determine each other exactly; (iii) a **duality** between certificates and mean-zero test correlations, specializing to the bound $|\sum_a \chi(a)N_a| \le \varphi(m)\varepsilon\mu = \varepsilon\,\mathrm{Li}(x)$ on all nontrivial Dirichlet character sums, with a Fourier inversion formula and an exact accounting ($\varphi(m)-1$) of the round-trip loss; (iv) a **structurelessness** theorem bounding the margin achievable by *any* classification criterion by $\varepsilon\mu$; (v) a **stability criterion** for the worst-behaved class, showing that instability certifies a near-tie; (vi) an **asymptotic freeness** theorem: geometric decay of the certificates drives $C(\varepsilon_k) \to \tfrac43$ with an explicit scale index; and (vii) a two-tier **information price**, linear ($D(p\|u) \le 2\varepsilon/(1-\varepsilon)$, exactly $\tfrac34$ the excess of the cap constant) and quadratic ($D(p\|u) \le (2\varepsilon/(1-\varepsilon))^2 \le 16\varepsilon^2$, with matching lower bound $\varepsilon^2/4$ ruling out any cubic improvement), summable across dyadic scales to a single finite constant.

At the recorded measurement $\varepsilon = 0.000446$ (maximal relative deviation over $m \in \{3,4,5,7,8,11,31\}$ at $x = 2^{30}$) the effective cap constant satisfies $1.3345 < C(\varepsilon) < 1.3346$: the ideal constant's three leading significant figures are certified, and four are provably not. The honest relative perturbation is $0.0892\%$, exactly twice the naive $0.0446\%$, because transfer is two-sided.

**Keywords:** equidistribution certificate, primes in arithmetic progressions, Dirichlet characters, transfer constant, Kullback–Leibler divergence, chi-square divergence, effectivization, geometric decay.

---

## 1. Introduction

### 1.1 The gap between a measurement and a theorem

Let $m \ge 2$ be an integer and let $a$ range over the $\varphi(m)$ reduced residue classes modulo $m$. The prime number theorem for arithmetic progressions asserts
$$\pi(x;m,a) \sim \frac{\mathrm{Li}(x)}{\varphi(m)} \qquad (x \to \infty),$$
uniformly in $a$ for fixed $m$. A great deal of downstream mathematics — and essentially all of the applied mathematics that borrows from analytic number theory — proceeds by replacing $\pi(x;m,a)$ with its target $\mu := \mathrm{Li}(x)/\varphi(m)$ and reasoning as though the substitution were exact. Call this idealization **MA-1**: *the counts are perfectly equidistributed*.

MA-1 is false, but only slightly. The question this paper answers is: *how slightly, and what exactly does that buy?* Specifically, one measures, over the moduli $m \in \{3,4,5,7,8,11,31\}$ at $x = 2^{30}$, the maximal relative deviation
$$\varepsilon := \max_{m,a} \frac{|\pi(x;m,a) - \mathrm{Li}(x)/\varphi(m)|}{\mathrm{Li}(x)/\varphi(m)} = 0.000446,$$
and one wishes to conclude that a downstream constant of $\tfrac43$, proved under MA-1, "holds to three significant figures". A measurement is not a theorem. This paper supplies the deductive layer between them.

### 1.2 Strategy: certificates as hypotheses

The organizing device is to promote the measurement to a hypothesis of a fixed logical shape, and then to prove everything downstream from that hypothesis and nothing else. We call the hypothesis an *equidistribution certificate*. It is finite, checkable and falsifiable. All the theorems below are unconditional statements about real vectors carrying a certificate; the arithmetic enters only in the (empirical) act of producing one.

This has three benefits. First, the conditioning is explicit: every constant we quote is traceable to $\varepsilon$ alone. Second, sharpness questions become accessible, since we may exhibit adversarial count vectors satisfying the certificate. Third, the framework applies verbatim to any finite family of counts obeying a uniform two-sided bound around a common target — arithmetic progressions are a leading example rather than the only one.

### 1.3 Summary of contributions

Section 2 sets up certificates and proves the sharp ratio bound. Section 3 proves the transfer theorem and computes the effective cap constant; Section 4 develops conservation and the converse dictionary. Section 5 establishes the duality with test correlations and its Dirichlet-character specialization, including Fourier inversion. Section 6 gives the statistical consequences, including the structurelessness bound. Section 7 resolves the two empirical hypotheses (worst-class stability; shrinking deviations) at the level of theorems. Section 8 develops the information price in its linear and quadratic forms, with matching lower bounds and totals across scales. Section 9 examines which readouts pay linearly and which quadratically, and refutes the natural conjecture. Section 10 gathers the numerical payload; Section 11 discusses limitations and future directions.

---

## 2. Certificates and the sharp ratio bound

Throughout, $\iota$ denotes a finite nonempty index set of classes, $n := |\iota|$, and $N : \iota \to \mathbb{R}$ a count vector. Real numbers $\mu$ (the target) and $\varepsilon$ (the tolerance) are fixed.

**Definition 2.1 (Equidistribution certificate).** The vector $N$ carries an *$\varepsilon$-certificate at target $\mu$*, written $\mathrm{EquiCert}(N,\mu,\varepsilon)$, if
$$|N_a - \mu| \le \varepsilon\mu \qquad \text{for every } a \in \iota.$$

In the motivating application $\iota = (\mathbb{Z}/m\mathbb{Z})^\times$, $N_a = \pi(x;m,a)$ and $\mu = \mathrm{Li}(x)/\varphi(m)$.

**Lemma 2.2 (Elementary consequences).** *Assume $\mathrm{EquiCert}(N,\mu,\varepsilon)$. Then for every $a$:*

1. $N_a \le (1+\varepsilon)\mu$ *and* $(1-\varepsilon)\mu \le N_a$;
2. *if $\mu > 0$ and $\varepsilon < 1$ then $N_a > 0$;*
3. *if $\mu > 0$ then $\varepsilon \ge 0$;*
4. *if $\mu \ge 0$ and $\varepsilon \le \varepsilon'$ then $\mathrm{EquiCert}(N,\mu,\varepsilon')$.*

*Proof.* (1) is the two directions of $|N_a-\mu|\le\varepsilon\mu$; (2) follows from the lower bound; (3) since $0 \le |N_a-\mu| \le \varepsilon\mu$ and $\mu>0$; (4) monotonicity of the right-hand side. $\square$

**Theorem 2.3 (Ratio bound).** *If $\mathrm{EquiCert}(N,\mu,\varepsilon)$ with $0 \le \varepsilon < 1$, then for all classes $a, b$,*
$$N_a \le \frac{1+\varepsilon}{1-\varepsilon} \, N_b .$$

*Proof.* By Lemma 2.2(1), $N_a \le (1+\varepsilon)\mu$ and $(1-\varepsilon)\mu \le N_b$, so $\mu \le N_b/(1-\varepsilon)$ since $1-\varepsilon>0$; substitute. $\square$

The factor $\frac{1+\varepsilon}{1-\varepsilon} = 1 + 2\varepsilon + O(\varepsilon^2)$ is the source of the "doubling" phenomenon that recurs throughout: a certificate controls each class relative to the target, but comparisons between classes are two-sided and cost twice as much to first order.

**Theorem 2.4 (Sharpness of the ratio bound).** *For every $0 \le \varepsilon < 1$ and $\mu > 0$ there exists a two-class vector $N : \{0,1\} \to \mathbb{R}$ with $\mathrm{EquiCert}(N,\mu,\varepsilon)$, with total exactly $2\mu$, and with*
$$N_0 = \frac{1+\varepsilon}{1-\varepsilon}\, N_1 .$$

*Proof.* Take $N_0 = (1+\varepsilon)\mu$, $N_1 = (1-\varepsilon)\mu$. Both deviations equal $\varepsilon\mu$ in absolute value; the total is $2\mu$; and the ratio is exact. $\square$

Thus no better transfer constant than $\frac{1+\varepsilon}{1-\varepsilon}$ is available, even if one additionally imposes exact conservation of the total count — a constraint one might hope would help.

**Proposition 2.5 (Additive form and refutation).** *Under $\mathrm{EquiCert}(N,\mu,\varepsilon)$, $|N_a - N_b| \le 2\varepsilon\mu$ for all $a,b$. Consequently an observed gap exceeding $2\varepsilon\mu$ refutes the $\varepsilon$-certificate.*

*Proof.* Triangle inequality on $(N_a-\mu)-(N_b-\mu)$. $\square$

---

## 3. The transfer theorem and the effective cap constant

**Definition 3.1 (Readouts).** A function $\Phi : (\iota \to \mathbb{R}) \to \mathbb{R}$ is
- *monotone* if $f \le g$ pointwise implies $\Phi(f) \le \Phi(g)$;
- *positively homogeneous* if $\Phi(\lambda f) = \lambda\,\Phi(f)$ for all $\lambda \ge 0$.

We abbreviate "monotone and positively homogeneous" to *MPH*. Maxima, minima, totals, nonnegative-weighted sums and quantiles are all MPH. Write $\underline{\mu}$ for the constant vector with all entries $\mu$.

**Lemma 3.2 (One-sided readout bounds).** *Let $\mathrm{EquiCert}(N,\mu,\varepsilon)$ hold with $0 \le \varepsilon \le 1$, and let $\Phi,\Psi$ be MPH. Then*
$$\Phi(N) \le (1+\varepsilon)\,\Phi(\underline{\mu}), \qquad (1-\varepsilon)\,\Psi(\underline{\mu}) \le \Psi(N).$$

*Proof.* Pointwise $N \le (1+\varepsilon)\underline{\mu}$, so monotonicity gives $\Phi(N) \le \Phi((1+\varepsilon)\underline{\mu})$, and homogeneity evaluates the right side. Symmetrically for the lower bound with $(1-\varepsilon)\underline{\mu} \le N$. $\square$

**Definition 3.3 (Effective cap constant).** For $\varepsilon \ne 1$ set
$$C(\varepsilon) := \frac43 \cdot \frac{1+\varepsilon}{1-\varepsilon}.$$
Then $C(0) = \tfrac43$, $C$ is nondecreasing on $[0,1)$, and $C(\varepsilon) \ge 0$ there.

**Theorem 3.4 (Transfer / effectivization).** *Let $\Phi,\Psi$ be MPH readouts satisfying the ideal cap*
$$\Phi(\underline{\mu}) \le \tfrac43\,\Psi(\underline{\mu}).$$
*Then for every $N$ with $\mathrm{EquiCert}(N,\mu,\varepsilon)$, $0 \le \varepsilon < 1$,*
$$\Phi(N) \le C(\varepsilon)\,\Psi(N).$$

*Proof.* By Lemma 3.2, $\Phi(N) \le (1+\varepsilon)\Phi(\underline{\mu}) \le (1+\varepsilon)\tfrac43\Psi(\underline{\mu})$. Again by Lemma 3.2, $\Psi(\underline\mu) \le \Psi(N)/(1-\varepsilon)$. Chaining and simplifying $(1+\varepsilon)\tfrac43/(1-\varepsilon) = C(\varepsilon)$ gives the claim. $\square$

**Theorem 3.5 (Attainment; optimality of $C$).** *Let $\max$ and $\min$ denote the largest and smallest coordinate. Both are MPH, and for every $0 \le \varepsilon < 1$, $\mu>0$ there is a two-class $N$ with $\mathrm{EquiCert}(N,\mu,\varepsilon)$ and*
$$\max(N) = \frac{1+\varepsilon}{1-\varepsilon}\,\min(N).$$
*Since $\max(\underline\mu) = \min(\underline\mu) = \mu$ satisfies the ideal cap, the constant $C(\varepsilon)$ in Theorem 3.4 cannot be lowered for the class of MPH readouts.*

*Proof.* Monotonicity and homogeneity of $\max$ and $\min$ are immediate from the corresponding properties of suprema and infima over a finite nonempty index set. The extremal vector of Theorem 2.4 realizes the ratio, its maximum being $N_0$ and its minimum $N_1$. $\square$

**Corollary 3.6 (A concrete non-vacuous instance).** *Under $\mathrm{EquiCert}(N,\mu,\varepsilon)$ with $\mu \ge 0$ and $0 \le \varepsilon < 1$: $\max(N) \le C(\varepsilon)\min(N)$.*

**Proposition 3.7 (Excess of the cap constant).** *For $\varepsilon \ne 1$, $C(\varepsilon) - \tfrac43 = \tfrac83 \cdot \frac{\varepsilon}{1-\varepsilon}$. For $0 \le \varepsilon \le \tfrac12$, $C(\varepsilon) \le \tfrac43 + \tfrac{16}{3}\varepsilon$.*

**Proposition 3.8 (Uniform transfer over a family).** *If $\mathrm{EquiCert}(N,\mu,\varepsilon)$ with $\varepsilon \le \varepsilon' < 1$, $\Psi(N)\ge 0$, and $\Phi,\Psi$ are MPH satisfying the ideal cap, then $\Phi(N) \le C(\varepsilon')\Psi(N)$.*

This is the form in which a per-modulus table of measured deviations yields a *single* constant for the whole family: take $\varepsilon'$ to be the worst entry.

### 3.1 The numerical payload

**Theorem 3.9 (Three significant figures).** *At $\varepsilon = 0.000446$:*
$$1.3345 < C(\varepsilon) < 1.3346, \qquad \left|C(\varepsilon) - \tfrac43\right| < \tfrac43\cdot 10^{-3}.$$
*Consequently, for MPH readouts $\Phi,\Psi$ obeying the ideal cap and any $N$ with $\mathrm{EquiCert}(N,\mu,0.000446)$ and $\Psi(N)\ge0$, one has $\Phi(N) \le 1.3346\,\Psi(N)$.*

**Theorem 3.10 (Four significant figures fail).** *$\left|C(0.000446) - \tfrac43\right| \ge \tfrac43 \cdot 10^{-4}$.*

*Proof of 3.9 and 3.10.* By Proposition 3.7 the excess is $\tfrac83\varepsilon/(1-\varepsilon)$; the relative excess is therefore exactly $2\varepsilon/(1-\varepsilon)$. At $\varepsilon = 0.000446$ this is $8.9240\ldots \times 10^{-4}$, which lies strictly between $10^{-4}$ and $10^{-3}$; multiply through by $\tfrac43$ and add. $\square$

The relative perturbation $2\varepsilon/(1-\varepsilon) = 0.0892\%$ is *twice* the naive reading $\varepsilon = 0.0446\%$ of the measurement. The recorded three-figure claim is therefore true and sharp: three figures survive, four do not.

---

## 4. Conservation and the converse dictionary

**Proposition 4.1 (Deviations sum to zero).** *If $\sum_a N_a = n\mu$ then $\sum_a (N_a - \mu) = 0$.*

**Theorem 4.2 (Half-$\ell^1$ bound).** *Under exact conservation, for every class $a$,*
$$|N_a - \mu| \le \tfrac12 \sum_b |N_b - \mu| .$$

*Proof.* Write $S := \sum_b |N_b - \mu|$. Since the signed deviations sum to zero, $|N_a - \mu| = |\sum_{b \ne a}(N_b-\mu)| \le \sum_{b\ne a}|N_b-\mu| = S - |N_a-\mu|$. $\square$

**Theorem 4.3 (An excess forces a compensating deficit).** *Assume $\sum_a N_a = n\mu$ and $n > 1$. For every class $a$ there is a class $b \ne a$ with*
$$N_b - \mu \le -\frac{N_a - \mu}{n-1}.$$

*Proof.* The deviations over the $n-1$ classes other than $a$ sum to $-(N_a-\mu)$; hence their minimum is at most the average $-(N_a-\mu)/(n-1)$. $\square$

Equidistribution failures are never solitary: a surplus in one class is a debt distributed across the others.

**Theorem 4.4 (Converse dictionary).** *Suppose $\mathrm{EquiCert}(N,\mu,\varepsilon)$ with $\mu>0$, and suppose two classes are observed in ratio at least $R \ge 1$, i.e. $R\,N_b \le N_a$. Then*
$$\varepsilon \ge \frac{R-1}{R+1}.$$

*Proof.* From $R(1-\varepsilon)\mu \le R N_b \le N_a \le (1+\varepsilon)\mu$ and $\mu>0$ we get $R(1-\varepsilon) \le 1+\varepsilon$, i.e. $R-1 \le \varepsilon(R+1)$. $\square$

Theorems 2.3 and 4.4 are exact inverses: $R \le \frac{1+\varepsilon}{1-\varepsilon} \iff \varepsilon \ge \frac{R-1}{R+1}$. The measured ratio and the certifiable tolerance determine each other; neither is a lossy proxy for the other.

---

## 5. Duality: certificates and test correlations

**Theorem 5.1 (Certificates kill mean-zero correlations).** *Let $f : \iota \to \mathbb{R}$ satisfy $\sum_a f_a = 0$ and $|f_a| \le 1$ for all $a$. If $\mathrm{EquiCert}(N,\mu,\varepsilon)$ then*
$$\Big|\sum_a f_a N_a\Big| \le n\,\varepsilon\mu .$$

*Proof.* Mean-zero test functions annihilate constants, so $\sum_a f_a N_a = \sum_a f_a (N_a - \mu)$. Apply the triangle inequality and bound each term by $1 \cdot \varepsilon\mu$. $\square$

**Theorem 5.2 (Converse).** *Suppose $|\sum_a f_a N_a| \le \delta$ for every $f$ with $\sum_a f_a = 0$ and $\|f\|_\infty \le 1$. Then every class lies within $\delta$ of the empirical mean:*
$$\Big|N_a - \frac{1}{n}\sum_b N_b\Big| \le \delta \quad \text{for all } a.$$

*Proof.* Apply the hypothesis to the admissible test function $f_b = \mathbb{1}[b=a] - 1/n$, which has mean zero and sup-norm at most $1$; the resulting correlation is exactly $N_a - \frac1n\sum_b N_b$. $\square$

Together, Theorems 5.1 and 5.2 say that the certificate and the uniform test-correlation bound are equivalent up to the factor $n$: they carry the same information about the count vector.

**Theorem 5.3 (Complex test functions and character sums).** *Theorem 5.1 holds verbatim for $f : \iota \to \mathbb{C}$ with $\sum_a f_a = 0$ and $\|f_a\| \le 1$. In particular, if $\iota = G$ is a finite abelian group and $\chi : G \to \mathbb{C}^\times$ a nontrivial character, then*
$$\Big|\sum_{a\in G} \chi(a) N_a\Big| \le |G|\,\varepsilon\mu,$$
*since nontrivial characters have unit modulus and sum to zero over $G$.*

**Corollary 5.4 (Dirichlet form).** *For $\iota = (\mathbb{Z}/m\mathbb{Z})^\times$ and $\chi$ a Dirichlet character mod $m$ whose restriction to the units is nontrivial,*
$$\Big|\sum_a \chi(a) N_a \Big| \le \varphi(m)\,\varepsilon\mu = \varepsilon\,\mathrm{Li}(x),$$
*the last equality holding for the arithmetic target $\mu = \mathrm{Li}(x)/\varphi(m)$.*

So an $\varepsilon$-certificate is precisely a bound of size $\varepsilon\,\mathrm{Li}(x)$ on every nontrivial twisted prime count — the shape in which such statements usually appear in analytic number theory.

**Theorem 5.5 (Fourier inversion for class counts).** *Write $S_\chi := \sum_b \chi(b) N_b$. For each class $a$,*
$$\sum_{\chi \bmod m} \overline{\chi(a)}\, S_\chi \;=\; \varphi(m)\, N_a ,$$
*the sum running over all $\varphi(m)$ Dirichlet characters mod $m$. Moreover $S_{\chi_0} = \sum_b N_b$ for the trivial character.*

*Proof.* Expand and exchange the order of summation. The inner sum $\sum_\chi \overline{\chi(a)}\chi(b)$ is the orthogonality relation for characters of $(\mathbb{Z}/m\mathbb{Z})^\times$: it equals $\varphi(m)$ if $a=b$ and $0$ otherwise. $\square$

**Theorem 5.6 (Round-trip loss).** *If $|S_\chi| \le S$ for every nontrivial $\chi$, then each class count is within $(\varphi(m)-1)S$ of $\varphi(m)$ times the empirical mean. Combining with Corollary 5.4, an $\varepsilon$-certificate yields*
$$\Big|\varphi(m) N_a - \sum_b N_b\Big| \le (\varphi(m)-1)\cdot \varphi(m)\,\varepsilon\mu .$$

*Proof.* Isolate the trivial character in Theorem 5.5: $\varphi(m)N_a - \sum_b N_b = \sum_{\chi \ne \chi_0}\overline{\chi(a)}S_\chi$, and there are $\varphi(m)-1$ such terms, each of modulus at most $S$. $\square$

Passing to the dual side and back is therefore lossy by exactly a factor $\varphi(m)-1$: for a fixed modulus the character-sum formulation is strictly weaker than the raw certificate, and the two become equivalent only when $\varphi(m)$ is treated as a constant. This is an honest accounting of a step that is often taken silently.

---

## 6. Statistical consequences

Let $\overline{N} := \frac1n\sum_a N_a$ and let $\mathrm{TSS}(N) := \sum_a (N_a - \overline{N})^2$ be the total sum of squares.

**Lemma 6.1 (Variance minimality).** *For every constant $c$, $\mathrm{TSS}(N) \le \sum_a (N_a - c)^2$.*

**Theorem 6.2 (Certificates cap the energy).** *Under $\mathrm{EquiCert}(N,\mu,\varepsilon)$,*
$$\sum_a (N_a - \mu)^2 \le n(\varepsilon\mu)^2, \qquad \text{hence} \qquad \mathrm{TSS}(N) \le n(\varepsilon\mu)^2 .$$

*Proof.* Each squared deviation is at most $(\varepsilon\mu)^2$; then apply Lemma 6.1 with $c=\mu$. $\square$

**Theorem 6.3 (No criterion finds structure).** *Let $P : \iota \to \mathbb{R}$ be any feature and $t$ any threshold, splitting the classes into $S = \{i : P_i \ge t\}$ of size $n_1$ and its complement of size $n_2$, both nonempty. Suppose the split separates the counts with margin $\delta \ge 0$ around a level $\mu_0$: $N_i \ge \mu_0+\delta$ on $S$ and $N_i \le \mu_0-\delta$ off $S$. If $\mathrm{TSS}(N) > 0$ and $\mathrm{EquiCert}(N,\mu,\varepsilon)$, then*
$$\frac{4\delta^2 n_1 n_2}{n} \le n(\varepsilon\mu)^2 .$$
*For a balanced split this reads $\delta \le \varepsilon\mu$.*

*Proof sketch.* The between-group sum of squares of a two-group split with margin $\delta$ is at least $4\delta^2 n_1 n_2 / n$; it is bounded above by the total sum of squares, which Theorem 6.2 caps at $n(\varepsilon\mu)^2$. $\square$

The point is the uniformity in $P$ and $t$: an $\varepsilon$-equidistributed count field is structureless in the strong sense that *no* classification criterion, however ingenious, can separate its classes by more than the certificate's own margin.

---

## 7. Resolving the two empirical hypotheses

### 7.1 H2: stability of the worst-behaved class

Empirically, the class with the largest relative deviation is stable in $x$ for $m \in \{3,4,7,8,11\}$ and unstable for $m \in \{5,31\}$. Let $d_1, d_2 : \iota \to \mathbb{R}$ be the deviation fields at two scales, and suppose the field drifts by at most $\eta$ in sup norm: $|d_1(c) - d_2(c)| \le \eta$ for all $c$.

**Theorem 7.1 (Switching implies a near-tie).** *For all classes $a,b$,*
$$\big(d_1(a)-d_1(b)\big) + \big(d_2(b)-d_2(a)\big) \le 2\eta .$$
*In particular, if $b$ maximizes $d_2$, then $d_1(a)-d_1(b) \le 2\eta$ for every $a$.*

*Proof.* Add $d_1(a)-d_2(a) \le \eta$ and $d_2(b)-d_1(b) \le \eta$. For the addendum, note that $d_2(b)-d_2(a)\ge 0$ when $b$ is the maximizer. $\square$

**Theorem 7.2 (Stability from a gap).** *Suppose at the first scale the class $a$ leads by a gap $g$: $d_1(c) + g \le d_1(a)$ for every $c \ne a$. If $b$ maximizes $d_2$ and $2\eta < g$, then $b = a$.*

*Proof.* If $b \ne a$, Theorem 7.1 applied to the pair $(a,b)$ gives $d_1(a)-d_1(b) \le 2\eta < g$, contradicting the gap hypothesis. $\square$

**Interpretation.** Instability of the worst class *certifies* a top-two gap of at most twice the drift. The observed split among moduli is therefore a statement about the geometry of near-ties in the deviation field, not about arithmetic properties of $5$ and $31$. This settles the natural conjecture that the split reflects some structural distinction between the moduli: at the resolution the data provides, it does not.

### 7.2 H3: shrinking deviations

Empirically, maximal deviations shrink from one scale to the next at $6$ of the $7$ moduli.

**Theorem 7.3 (A shrinking subfamily shrinks the aggregate).** *Let $M$ be a finite family of moduli, $D_1, D_2 : M \to \mathbb{R}$ the maximal relative deviations at two scales, $S \subseteq M$, and $\rho \in \mathbb{R}$. If $D_2(s) \le \rho D_1(s)$ for $s \in S$ and $D_2(s) \le D_1(s)$ for $s \in M \setminus S$, then*
$$\sum_{s\in M} D_2(s) \;\le\; \sum_{s\in M} D_1(s) \;-\; (1-\rho)\sum_{s\in S} D_1(s).$$
*If moreover $\rho < 1$ and $\sum_{s\in S} D_1(s) > 0$, the inequality $\sum_M D_2 < \sum_M D_1$ is strict.*

*Proof.* Split $M$ into $S$ and $M\setminus S$, sum the two hypotheses, and recombine. $\square$

**Theorem 7.4 (Asymptotic freeness).** *Let $(\varepsilon_k)_{k\ge0}$ be nonnegative certificates across dyadic scales with $\varepsilon_{k+1} \le \rho\,\varepsilon_k$, $0 \le \rho < 1$, and $\varepsilon_0 \le \tfrac12$. Then for every $\delta > 0$ there is an explicit index $K$ with*
$$C(\varepsilon_k) - \tfrac43 \le \delta \qquad \text{for all } k \ge K .$$

*Proof.* Induction gives $\varepsilon_k \le \rho^k \varepsilon_0 \le \varepsilon_0 \le \tfrac12$, so Proposition 3.7 applies at every scale: $C(\varepsilon_k) - \tfrac43 \le \tfrac{16}{3}\varepsilon_k \le \tfrac{16}{3}\rho^K\varepsilon_0$ for $k \ge K$. Choose $K$ with $\rho^K < \delta / (\tfrac{16}{3}\varepsilon_0 + 1)$, which exists since $\rho<1$. $\square$

Theorem 7.4 is the theorem-level content of H3: the effectivization is *asymptotically free*, and the observed shrinking is exactly the mechanism that makes the three-figure agreement stable — indeed improving — as $x$ grows.

---

## 8. The information price of the idealization

A second, independent currency for the cost of MA-1 is information. Assume $\mu>0$ and $\varepsilon<1$, so all counts are positive.

**Definition 8.1.** The *empirical class distribution* is $p_a := N_a / \sum_b N_b$. Its divergence from uniform and its Shannon entropy (in nats) are
$$D(p\|u) := \sum_a p_a \log(n\,p_a), \qquad H(p) := -\sum_a p_a \log p_a .$$

**Lemma 8.2 (Basic bounds from a certificate).** *Under $\mathrm{EquiCert}(N,\mu,\varepsilon)$ with $\mu>0$, $\varepsilon<1$: the total satisfies $n(1-\varepsilon)\mu \le \sum_b N_b \le n(1+\varepsilon)\mu$, each $p_a>0$, $\sum_a p_a = 1$, and*
$$\frac{1-\varepsilon}{n(1+\varepsilon)} \;\le\; p_a \;\le\; \frac{1+\varepsilon}{n(1-\varepsilon)} , \qquad \Big|p_a - \frac1n\Big| \le \frac{2\varepsilon}{n(1-\varepsilon)} .$$

*Proof.* Sum the bounds of Lemma 2.2(1) for the total; divide. The two-sided deviation bound follows since both $\frac{1+\varepsilon}{n(1-\varepsilon)} - \frac1n$ and $\frac1n - \frac{1-\varepsilon}{n(1+\varepsilon)}$ are at most $\frac{2\varepsilon}{n(1-\varepsilon)}$. $\square$

**Theorem 8.3 (Linear price).** *Under the hypotheses of Lemma 8.2 with $\varepsilon \ge 0$,*
$$D(p\|u) \le \frac{2\varepsilon}{1-\varepsilon}.$$

*Proof.* $D(p\|u) = \sum_a p_a \log(np_a) \le \log \big(n\max_a p_a\big) \le \log\frac{1+\varepsilon}{1-\varepsilon} \le \frac{1+\varepsilon}{1-\varepsilon} - 1 = \frac{2\varepsilon}{1-\varepsilon}$, using $\log t \le t-1$. $\square$

**Theorem 8.4 (Entropy form).** *$D(p\|u) = \log n - H(p)$ for any positive probability vector; hence under a certificate $\log n - H(p) \le 2\varepsilon/(1-\varepsilon)$: the class entropy is within $2\varepsilon/(1-\varepsilon)$ of its maximum $\log\varphi(m)$.*

**Theorem 8.5 (Unification of the two currencies).** *Under a certificate,*
$$D(p\|u) \le \tfrac34\left(C(\varepsilon) - \tfrac43\right).$$
*The information price and the excess of the effective cap constant are, up to the factor $\tfrac34$, the same number.*

*Proof.* By Proposition 3.7 the excess is $\tfrac83\varepsilon/(1-\varepsilon)$; three quarters of it is $2\varepsilon/(1-\varepsilon)$, which is Theorem 8.3. $\square$

### 8.1 The quadratic refinement

The linear bound is far from tight, because it discards the cancellation between classes above and below the target.

**Lemma 8.6 (Kullback–Leibler is dominated by chi-square).** *For a positive probability vector $p$ on $n$ classes,*
$$D(p\|u) \le n \sum_a \Big(p_a - \frac1n\Big)^2 .$$

*Proof sketch.* Using $\log t \le t - 1$ on each term of $D(p\|u) = \sum_a p_a \log\frac{p_a}{1/n}$ gives $D(p\|u) \le \sum_a p_a\frac{p_a - 1/n}{1/n} = n\sum_a p_a(p_a - 1/n)$, and since $\sum_a (p_a - 1/n) = 0$ this equals $n\sum_a (p_a-1/n)^2$. $\square$

**Theorem 8.7 (Quadratic price).** *Under $\mathrm{EquiCert}(N,\mu,\varepsilon)$ with $\mu>0$, $\varepsilon<1$,*
$$D(p\|u) \le \left(\frac{2\varepsilon}{1-\varepsilon}\right)^2 ,$$
*and for $\varepsilon \le \tfrac12$ simply $D(p\|u) \le 16\varepsilon^2$.*

*Proof.* Combine Lemma 8.6 with the pointwise bound $|p_a - 1/n| \le 2\varepsilon/(n(1-\varepsilon))$ of Lemma 8.2: the sum of squares is at most $n\cdot(2\varepsilon/(n(1-\varepsilon)))^2$, and multiplying by $n$ yields $(2\varepsilon/(1-\varepsilon))^2$. For $\varepsilon \le \tfrac12$, $(1-\varepsilon)^2 \ge \tfrac14$. $\square$

**Theorem 8.8 (The exponent is exact).** *For every $0 < \varepsilon \le \tfrac14$ and $\mu>0$ there is a two-class vector with $\mathrm{EquiCert}(N,\mu,\varepsilon)$ and*
$$D(p\|u) \ge \frac{\varepsilon^2}{4}.$$

*Proof sketch.* Take the saturated vector $N = ((1+\varepsilon)\mu, (1-\varepsilon)\mu)$, whose class distribution is $p = (\frac{1+\varepsilon}{2}, \frac{1-\varepsilon}{2})$. Then $D(p\|u) = \frac{1+\varepsilon}{2}\log(1+\varepsilon) + \frac{1-\varepsilon}{2}\log(1-\varepsilon)$, and the elementary inequality $1 - 1/y \le \log y$ applied to both logarithms bounds this below by $\varepsilon^2/4$ on $[0,\tfrac14]$. $\square$

**Corollary 8.9 (No cubic improvement).** *For every constant $C$ there exist $\varepsilon>0$ and a count vector satisfying an $\varepsilon$-certificate with $D(p\|u) > C\varepsilon^3$.*

*Proof.* Take $\varepsilon = \min(\tfrac14, \tfrac{1}{8(|C|+1)})$ and the saturated vector of Theorem 8.8, for which $D \ge \varepsilon^2/4 > |C|\varepsilon^3 \ge C\varepsilon^3$. $\square$

Thus the price of a saturated certificate is pinned between $\varepsilon^2/4$ and $16\varepsilon^2$: quadratic, exactly.

### 8.2 The total price across all scales

**Theorem 8.10 (Summability and totals).** *Let $(N^{(k)}, \mu_k, \varepsilon_k)_{k \ge 0}$ be certificates at the dyadic scales with $\mu_k>0$, $\varepsilon_{k+1}\le\rho\varepsilon_k$ for some $0\le\rho<1$, and $\varepsilon_0 \le \tfrac12$. Then the per-scale prices $D_k := D(p^{(k)}\|u)$ are nonnegative (Gibbs' inequality), summable, and*
$$\sum_{k\ge0} D_k \;\le\; \frac{4\varepsilon_0}{1-\rho} \qquad \text{(linear envelope)},$$
$$\sum_{k\ge0} D_k \;\le\; \frac{16\varepsilon_0^2}{1-\rho^2} \qquad \text{(quadratic envelope)}.$$

*Proof.* Geometric decay gives $\varepsilon_k \le \rho^k\varepsilon_0 \le \tfrac12$ at every scale, so Theorem 8.3 in the form $D_k \le 4\varepsilon_k$ and Theorem 8.7 in the form $D_k \le 16\varepsilon_k^2$ both apply. Comparison with the geometric series of ratio $\rho$, respectively $\rho^2$, gives summability and the two totals. $\square$

The total is *the entire future cost of the idealization*: one finite constant bounding the information ever lost to MA-1, over all scales, for all time.

---

## 9. Which readouts pay linearly, and which quadratically?

The MPH readouts of Section 3 pay the sharp linear price $\frac{1+\varepsilon}{1-\varepsilon}$. Some readouts do better.

**Definition 9.1.** A readout $\Phi$ is a *deviation-energy readout with constant $L$* if for every $f$ and every constant $c$,
$$|\Phi(f)| \le L \sum_a (f_a - c)^2 .$$

**Theorem 9.2 (Quadratic transfer).** *If $\Phi$ is a deviation-energy readout with constant $L \ge 0$ and $\mathrm{EquiCert}(N,\mu,\varepsilon)$ holds, then*
$$|\Phi(N)| \le L\, n (\varepsilon\mu)^2 .$$

*Proof.* Apply Definition 9.1 with $c=\mu$ and Theorem 6.2. $\square$

**Proposition 9.3.** *The total sum of squares $\mathrm{TSS}$ is a deviation-energy readout with $L = 1$ (Lemma 6.1). Hence under a certificate, $\mathrm{TSS}(N) \le \varepsilon^2\, n\mu^2$.*

**Proposition 9.4 (Deviation-energy readouts annihilate constants).** *If $\Phi$ is a deviation-energy readout then $\Phi(\underline{c}) = 0$ for every constant $c$.*

*Proof.* Take $f = \underline{c}$ and the same $c$ in Definition 9.1: the right-hand side vanishes. $\square$

It is natural to conjecture the converse — that annihilating constants is what makes a readout quadratic. It is false.

**Theorem 9.5 (Refutation of the vanishing-order dichotomy).** *Let $a \ne b$ and let $\Phi(f) := f_a - f_b$. Then $\Phi$ annihilates every constant field, but $\Phi$ is not a deviation-energy readout for any constant $L$; moreover on certificates it attains the linear cost: for every $\varepsilon \ge 0$, $\mu>0$ there is $N$ with $\mathrm{EquiCert}(N,\mu,\varepsilon)$ and*
$$\Phi(N) = 2\varepsilon\mu .$$

*Proof.* Annihilation is immediate. For the sharpness, take $N_a = (1+\varepsilon)\mu$, $N_b = (1-\varepsilon)\mu$ and $N_c=\mu$ elsewhere: the certificate holds and $\Phi(N) = 2\varepsilon\mu$, which for small $\varepsilon$ exceeds any bound of the form $L n(\varepsilon\mu)^2$. Failure of Definition 9.1 follows by scaling the same configuration. $\square$

So the dichotomy is genuine but is drawn by the *norm* controlling the readout, not by its null space: control by the deviation energy — a quadratic quantity — is what buys the quadratic rate; merely vanishing on constants does not.

---

## 10. The numerical payload at $\varepsilon = 0.000446$

All of the following are instances of the theorems above at the recorded measurement. Write $\varepsilon_0 = 0.000446$.

| Quantity | Bound | Theorem |
|---|---|---|
| Pairwise ratio of class counts | $\le 1.001$ | 2.3 |
| Effective cap constant $C(\varepsilon_0)$ | $1.3345 < C < 1.3346$ | 3.9 |
| Relative perturbation of the cap | $0.0892\% < 0.1\%$ | 3.9 |
| Four significant figures | fail | 3.10 |
| Nontrivial character sums | $\le \varphi(m)\varepsilon_0\mu = \varepsilon_0\,\mathrm{Li}(x)$ | 5.4 |
| Divergence from uniform (linear) | $\le 9\times10^{-4}$ nats | 8.3 |
| Divergence from uniform (quadratic) | $\le 8\times10^{-7}$ nats | 8.7 |
| Total sum of squares | $\le 2\times10^{-7}\, n\mu^2$ | 9.3 |
| Total information price, all scales (linear) | $\le 3.57\times10^{-3}$ nats | 8.10 |
| Total information price, all scales (quadratic) | $\le 4.3\times10^{-6}$ nats | 8.10 |

The last two rows assume certificates that at worst halve from one dyadic scale to the next ($\rho = \tfrac12$).

**Theorem 10.1 (The package).** *Let $m$ be a modulus and $N : (\mathbb{Z}/m\mathbb{Z})^\times \to \mathbb{R}$ carry $\mathrm{EquiCert}(N,\mu,0.000446)$ with $\mu>0$. Then simultaneously:*

1. *(order)* $N_a \le 1.001\, N_b$ *for all classes* $a,b$;
2. *(cap)* $\max(N) \le 1.3346\, \min(N)$;
3. *(harmonic analysis)* $\big|\sum_a \chi(a) N_a\big| \le \varphi(m)\cdot 0.000446\,\mu$ *for every Dirichlet character* $\chi$ *mod* $m$ *nontrivial on the units;*
4. *(information)* $D(p\|u) \le 9\times10^{-4}$ *nats, and in the sharper form* $\le 8\times10^{-7}$ *nats.*

*Proof.* Items 1–4 are Theorems 2.3, 3.9 with Corollary 3.6, Corollary 5.4, and Theorems 8.3 and 8.7 respectively, each evaluated at $\varepsilon = 0.000446$. $\square$

The content of Theorem 10.1 is that these hold *simultaneously*, from a single measured number, with no further arithmetic input.

---

## 11. Discussion

### 11.1 What is and is not proved

Every theorem above is an unconditional statement about real vectors carrying a certificate. What is *not* proved here is the certificate itself: that $\pi(x;m,a)$ obeys $|\pi(x;m,a) - \mathrm{Li}(x)/\varphi(m)| \le 0.000446\cdot \mathrm{Li}(x)/\varphi(m)$ at $x = 2^{30}$ for the seven listed moduli is a computation, not a theorem, and the results are conditional on it in the same explicit way that a numerical-analysis error bound is conditional on its input data. The value of separating the two layers is that the deduction is exact: no constant below hides an unquantified step.

Nor do we claim the certificate persists for all $x$: Theorem 7.4 is conditional on geometric decay of the measured deviations, which the data suggests over the observed range but which is not established here. Unconditionally, the Generalized Riemann Hypothesis would give $\varepsilon \ll x^{-1/2}\log^2 x \cdot \varphi(m)$, far stronger than what is needed; what is available unconditionally and uniformly in $m$ is much weaker. This is precisely why the certificate formulation is useful: it lets one carry whatever quality of input is actually available and read off the exact downstream consequence.

### 11.2 The doubling phenomenon

The single most transferable lesson is the factor of two. A measured one-sided relative deviation $\varepsilon$ produces a two-sided comparison error $2\varepsilon/(1-\varepsilon)$, and it is this — not $\varepsilon$ — that appears in every multiplicative conclusion. Reporting $\varepsilon = 0.0446\%$ and concluding "the constants are good to $0.045\%$" is off by a factor of two. The correct figure, $0.0892\%$, still supports the three-figure claim, but only just: had the measurement been three times worse, three figures would have failed too.

### 11.3 Two currencies, one number

Theorem 8.5 is perhaps the most conceptually satisfying result here: the information-theoretic price of the idealization is exactly three quarters of the excess of the effective cap constant. The order-theoretic and entropic accountings, which come from entirely different considerations (monotone readouts on one side, Gibbs' inequality on the other), produce the same number in disguise. The quadratic refinement (Theorem 8.7) then breaks the tie in favour of information: on the entropic side the idealization is three orders of magnitude cheaper than the linear estimate suggests, and the exponent is exact.

### 11.4 Sharpness as a design principle

Almost every upper bound above is accompanied by a configuration attaining it: the ratio bound (Theorem 2.4), the cap constant (Theorem 3.5), the quadratic exponent (Theorem 8.8), and the failure of the natural dichotomy (Theorem 9.5). This matters because effectivization has a characteristic failure mode: constants inflate through a chain of pessimistic steps until the conclusion is vacuous. Insisting on a matching example at each stage is what keeps the final constant honest — and it is what lets us say, of the recorded three-figure claim, not merely that it is true but that it is the best claim of its kind.

---

## 12. Future directions

**Effectivity of the certificate itself.** The deduction layer is complete; the input layer is empirical. Establishing unconditional certificates of comparable quality, uniformly over a range of moduli, at explicit $x$, is the natural next target, as is a careful comparison with what explicit zero-free regions currently yield.

**Beyond monotone homogeneous readouts.** Sections 3 and 9 identify two regimes — linear for MPH readouts, quadratic for deviation-energy readouts — and Theorem 9.5 shows the classification is not by null space. A complete characterization of the readouts paying $O(\varepsilon^k)$ for each $k$, presumably in terms of the order of vanishing of $\Phi$ along the constant direction *in a suitable norm*, remains open.

**Non-uniform certificates.** Definition 2.1 imposes a single tolerance across all classes. In practice deviations are class-dependent, and a weighted certificate $|N_a - \mu| \le \varepsilon_a \mu$ would presumably yield transfer constants governed by $\max_a \varepsilon_a$ for MPH readouts but by $\ell^2$-type averages for quadratic ones — a strictly finer accounting.

**The dual side, quantitatively.** Theorem 5.6 quantifies the round-trip loss as exactly $\varphi(m)-1$. Whether this is an artefact of the crude triangle inequality over characters or genuinely attained (say, by a configuration concentrated on one class) would sharpen the dictionary between certificates and character sums.

**Multi-modulus aggregation.** Proposition 3.8 handles a family of moduli by taking the worst tolerance. Theorem 7.3 suggests that aggregate quantities behave better than worst-case ones; a transfer theorem calibrated to the *average* rather than the maximal deviation across a family would be closer to what the data supports.

---

## Appendix: future research programme

The following directions were identified in the course of this work and are recorded verbatim.

*What this cycle settled.* The recorded claim "the $4/3$ cap's constants hold to three significant figures" is now a theorem conditional on the measured input, and the conditioning is explicit. The measured input is the equidistribution certificate; everything downstream is exact real algebra.

- The cost of the idealization for any monotone, positively homogeneous readout is exactly the factor $(1+\varepsilon)/(1-\varepsilon)$, and it is attained, so the effective constant $C(\varepsilon) = (4/3)(1+\varepsilon)/(1-\varepsilon)$ cannot be improved in that class.
- At $\varepsilon = 0.000446$ the constant is pinned: $1.3345 < C(\varepsilon) < 1.3346$. Three significant figures survive; four provably do not. The honest relative perturbation is $0.0892\%$, twice the naive $0.0446\%$: the transfer is two-sided.
- The hypothesis that the worst class is stable for some moduli and unstable for others is not an arithmetic phenomenon at the level the data can see: switching happens exactly at near-ties.
- The hypothesis that deviations shrink upgrades to a dynamical statement: geometric decay makes the effectivization asymptotically free, with an explicit scale index.
- Fourier inversion for the class counts is proved, so the certificate and the Dirichlet character sums determine each other, with an explicit round-trip loss.
- Gibbs' inequality for the class distribution makes the per-scale prices nonnegative; under geometric decay they are summable and the total information ever lost across all dyadic scales is at most $4\varepsilon_0/(1-\rho)$ nats, below $0.00357$ at the recorded input with halving certificates. The linear cost is a feature of monotonicity alone: deviation-energy readouts pay only $O(\varepsilon^2)$, which for the empirical variance is $2\times10^{-7}$ relative at the recorded $\varepsilon$.
- Kullback–Leibler divergence is dominated by the chi-square divergence from uniform, and a certificate pins each class probability to within $2\varepsilon/(n(1-\varepsilon))$ of $1/n$, so the per-scale price is quadratic: $D(p\|u) \le (2\varepsilon/(1-\varepsilon))^2$, below $8\times10^{-7}$ nats at the recorded input. Summed over all dyadic scales with geometrically decaying certificates the total is at most $16\varepsilon_0^2/(1-\rho^2)$, below $4.3\times10^{-6}$ nats with halving certificates.
