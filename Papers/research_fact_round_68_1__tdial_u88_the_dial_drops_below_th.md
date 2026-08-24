# Channel Dilution, Alphabet Universality, and the Forced Band Miss of a Two-Adic Rank Diagnostic

**Author:** Aristotle
**Date:** 2026-08-24

---

## Abstract

We study the erosion, with growing bit-length $b$, of a rank-correlation diagnostic that scores a two-adic descriptor (the number of trailing binary zeros of an integer) against a downstream response. Empirically the diagnostic reads $\rho = 0.78$ at $b = 44$ and decays monotonically — apart from a single outlier at $b = 52$ — to $\rho = 0.534$ at $b = 88$, the first reading below the acceptance floor $0.55$.

We give an exact, finite-sample explanation of the *shape* of that decay and a proof that the location of the first floor crossing is not an artefact of one measurement.

Our first result is the **channel-dilution law**: if the response is a weighted sum of $b = m+1$ independent channels of which the descriptor is one, carried with weight $a \neq 0$, then the squared Pearson correlation is exactly $\rho^2 = a^2/(a^2+m)$. We prove this over the binary alphabet by an exact moment computation on the Hamming-weight spectrum of the $m$-cube, and then over an arbitrary alphabet $\{0,\dots,q-1\}$: all three determinant-form moments of the $q$-ary sample collapse onto the single scale $V = q^{2m}q^2(q^2-1)/12$, so that $\rho^2 = a^2/(a^2+m)$ **for every $q \ge 2$** — *dilution counts channels, not symbols*. We show the law is not fitted but forced: the reciprocal excess $e = 1/\rho^2 - 1$ is additive in the channel count, and additivity together with the one-channel value determines the law uniquely.

Our second result is the **product law**: crossing a tie profile with an independent $m$-channel noise cube gives $\rho^2 = \rho^2_{\text{tie}} \cdot a^2 S_S/(a^2 S_S + \tfrac14 c^2 n m)$ exactly, with no interaction term — tie attenuation and channel dilution compose multiplicatively.

Applied to the record, these laws separate the two candidate mechanisms. The exact two-adic tie ceiling $\tfrac67(1 + 2^{-b}(2^b+1)^{-1})$ moves by less than $10^{-26}$ across the whole ladder while the diagnostic falls by more than $0.32$ in $\rho^2$; tie granularity is therefore excluded. The channel reading survives in the diluted regime: the invariant $\rho^2 b$ occupies $[25, 28.3]$ on nine of ten rungs, pools to $C = 7446029/281250 = 26.4747\ldots$, and predicts each successive rung out of sample to within $0.03$. The pooled law crosses the squared floor at $b^\star = C/0.55^2 \in (87,88)$ and therefore **retrodicts the first band miss at exactly $b = 88$**.

Adversarially, the literal model fails: for every weight $a \neq 0$, every alphabet $q \ge 2$ and every linear pool growth rate $\kappa > 0$, the model decays too slowly between $b=44$ and $b=88$. On the reciprocal scale the record is strictly super-additive, $e(88)\cdot 43 > e(44)\cdot 87$; the effective pool grows by a factor in $(3.8,4)$ while $b$ merely doubles. A quadratic pool with a constant noise floor, $1/\rho^2 - 1 = \kappa b^2 + c$, fitted to the two extreme rungs, is forced to have $\kappa > 0$ *and* $c > 0$, retrodicts all nine good rungs to within $0.027$, re-flags the $52$-rung, and places the first miss at $88$ — agreeing with the structurally different inverse-bit-length law. A competing odds-scale law $\rho^2/(1-\rho^2) = K/b^2$ fits the trend equally well but places the first miss at $84$, and is falsified by the $84$-rung, which held at $0.56$.

Finally we prove a **Pythagorean transfer**: for every odd $m$, the trailing-zero tie profile of the even leg $2mn$ of the Euclid family, as $n$ ranges over $2^b$ values, is *literally* the dyadic profile of uniform integers, so every ceiling proved here holds verbatim on Pythagorean legs.

**Keywords:** rank correlation; two-adic valuation; channel dilution; tie ceiling; Spearman coefficient; Pythagorean triples; model discrimination.

---

## 1. Introduction

### 1.1 The empirical object

A diagnostic statistic — we will call it the *dial* — reads the rank correlation between a two-adic descriptor of a random $b$-bit integer and an observed downstream rate. The descriptor is $\nu_2(x)$, the number of trailing binary zeros of $x$. The dial is deemed informative when its reading lies in the acceptance band $[0.55, 0.85]$.

Run up a ladder of bit-lengths, the dial reads

$$
\begin{array}{c|cccccccccc}
b & 44 & 52 & 56 & 64 & 68 & 72 & 76 & 80 & 84 & 88\\\hline
\rho(b) & 0.78 & 0.81 & 0.69 & 0.65 & 0.61 & 0.61 & 0.61 & 0.57 & 0.56 & 0.534
\end{array}
$$

with a confidence interval $[0.509,\,0.555]$ at the last rung. Two facts stand out. The series is monotone except for the $52$-rung, which reads *above* its predecessor. And the $88$-rung is the first band miss: $0.534 < 0.55$, with a confidence interval that straddles the floor rather than clearing it.

### 1.2 The two hypotheses

**(H-tie)** The descriptor $\nu_2$ is massively tied: on $b$-bit integers, $2^{b-1}$ values have $\nu_2 = 0$, $2^{b-2}$ have $\nu_2 = 1$, and so on. Rank correlations against a tied predictor are capped below $1$. If the cap fell with $b$, the erosion would be an artefact of the statistic's granularity.

**(H-channel)** The descriptor's contribution to the response is unchanged, but the response is increasingly driven by other, independent influences. The signal is diluted, not degraded.

These hypotheses have different consequences and different remedies, and distinguishing them by more measurement is expensive. We distinguish them by exact computation instead.

### 1.3 Contributions

1. A finite-sample correlation calculus in determinant form, with Cauchy–Schwarz and the bound $\rho^2 \le 1$ (§2).
2. The channel-dilution law $\rho^2 = a^2/(a^2 + b - 1)$, exactly, over the binary alphabet (§3).
3. Alphabet universality: the same rational function for every alphabet size $q \ge 2$ (§4).
4. A functional-equation characterisation: additivity of the reciprocal excess forces the law (§5).
5. The product law: tie attenuation times channel dilution, with no interaction term (§6).
6. Application to the record: the inverse-bit-length fit, the out-of-sample predictions, and the retrodiction of the first band miss at $b = 88$ (§7).
7. Adversarial review: falsification of the literal fixed-weight model for every weight, every alphabet and every linear pool growth rate; falsification of the odds-scale law by the $84$-rung; the forced positive noise floor of the quadratic pool; model robustness of the $88$-rung (§8).
8. The Pythagorean transfer of the tie ceiling to even legs of the Euclid family (§9).

---

## 2. A finite-sample correlation calculus

We work throughout over $\mathbb{Q}$ with samples given as explicit finite lists, so that every identity below is an identity of rational numbers rather than a limit statement.

**Definition 2.1 (sample and moments).** Let $D = ((x_1,y_1),\dots,(x_n,y_n))$ be a finite paired sample with $n = |D|$. Write $\Sigma f = \sum_i f(x_i,y_i)$. Define the *determinant-form* moments
$$
\operatorname{Cov}_D = n\,\Sigma xy - (\Sigma x)(\Sigma y), \qquad
\operatorname{Var}^X_D = n\,\Sigma x^2 - (\Sigma x)^2, \qquad
\operatorname{Var}^Y_D = n\,\Sigma y^2 - (\Sigma y)^2 .
$$
These are $n$ times the usual central moments; the factor is deliberate, since it makes every quantity a polynomial in the data with no division.

**Definition 2.2 (squared Pearson coefficient).**
$$
\rho^2(D) \;=\; \frac{\operatorname{Cov}_D^2}{\operatorname{Var}^X_D \cdot \operatorname{Var}^Y_D}.
$$

**Lemma 2.3 (centring identities).** With $\tilde{x}_i = n x_i - \Sigma x$ and $\tilde y_i = n y_i - \Sigma y$,
$$\textstyle\sum_i \tilde x_i \tilde y_i = n \operatorname{Cov}_D,\qquad \sum_i \tilde x_i^2 = n\operatorname{Var}^X_D, \qquad \sum_i \tilde y_i^2 = n \operatorname{Var}^Y_D.$$

*Proof sketch.* Expand each product, split the sum into the three monomials $x_iy_i$, $x_i$, $y_i$ and a constant, and use $\sum_i 1 = n$. Each expansion is a polynomial identity. $\square$

**Theorem 2.4 (Cauchy–Schwarz and the unit bound).** For any finite list of pairs $(u_i,v_i)$ of rationals, $\bigl(\sum u_iv_i\bigr)^2 \le \bigl(\sum u_i^2\bigr)\bigl(\sum v_i^2\bigr)$. Consequently, if $n>0$, $\operatorname{Var}^X_D > 0$ and $\operatorname{Var}^Y_D > 0$, then $\rho^2(D) \le 1$.

*Proof sketch.* Cauchy–Schwarz for lists follows by induction from the two-term step
$$(P + u v)^2 \le (A + u^2)(B + v^2) \quad\text{whenever } P^2 \le AB,\ A,B \ge 0,$$
which is the arithmetic–geometric inequality $2|uvP| \le u^2 B + v^2 A$ applied after expansion. Applying the list inequality to the centred vectors of Lemma 2.3 gives $n^2\operatorname{Cov}_D^2 \le n^2 \operatorname{Var}^X_D\operatorname{Var}^Y_D$, hence the bound. $\square$

**Definition 2.5 (centred form and equivalence).** For centring constants $\mu_x,\mu_y$ put
$$
\rho^2_c(D;\mu_x,\mu_y) = \frac{\bigl(\sum_i (x_i-\mu_x)(y_i-\mu_y)\bigr)^2}{\bigl(\sum_i (x_i-\mu_x)^2\bigr)\bigl(\sum_i (y_i-\mu_y)^2\bigr)} .
$$
When $\mu_x,\mu_y$ are the sample means, $\rho^2_c = \rho^2$; the determinant form is exactly $n^2$ times each of numerator and denominator factors, and the scale cancels. We use whichever form is more convenient and appeal to this equivalence when passing between them.

---

## 3. The channel-dilution law

### 3.1 The model

**Definition 3.1 (binary channel sample).** Fix a weight $a \in \mathbb{Q}$ and a competitor count $m \in \mathbb{N}$. Let $W_m$ be the multiset of Hamming weights of $\{0,1\}^m$, i.e. the list containing the value $w$ with multiplicity $\binom{m}{w}$, so $|W_m| = 2^m$. The *channel sample* is the list of $2^{m+1}$ pairs
$$
\mathcal{C}(a,m) \;=\; \bigl\{(0,\,w) : w \in W_m\bigr\} \;\cup\; \bigl\{(1,\,a + w) : w \in W_m\bigr\}.
$$
Interpretation: the predictor is the dial's own binary channel; the response carries that channel with weight $a$ and adds $m$ further independent binary channels. There are $b = m+1$ channels in total, and the sample enumerates all $2^{b}$ equally likely configurations exactly once.

**Lemma 3.2 (moments of the weight spectrum).** $\;2\sum_{w\in W_m} w = m\,2^m$ and $4\sum_{w \in W_m} w^2 = 2^m(m^2+m)$.

*Proof sketch.* $W_{m+1}$ is $W_m$ together with $W_m$ shifted by $1$. Hence $\Sigma_{m+1} = 2\Sigma_m + 2^m$ and $\Sigma^{(2)}_{m+1} = 2\Sigma^{(2)}_m + 2\Sigma_m + 2^m$. Both closed forms follow by induction. $\square$

**Lemma 3.3 (moments of the channel sample).** $\;\operatorname{Var}^X = (2^m)^2$, $\;\operatorname{Cov} = a\,(2^m)^2$, $\;\operatorname{Var}^Y = (a^2+m)(2^m)^2$.

*Proof sketch.* $n = 2^{m+1}$ and $\Sigma x = 2^m$, $\Sigma x^2 = 2^m$, so $\operatorname{Var}^X = 2^{m+1}2^m - 2^{2m} = 2^{2m}$. For the response, $\Sigma y = 2\sum w + a2^m$ and $\Sigma y^2 = 2\sum w^2 + 2a\sum w + a^2 2^m$; substituting Lemma 3.2 and simplifying gives the stated forms. The essential cancellation is that the $m$-dependent parts of $\Sigma y^2$ and $(\Sigma y)^2$ leave exactly $m\,2^{2m}$ behind. $\square$

### 3.2 The law

> **Theorem 3.4 (Channel-Dilution Law).** For every $a \neq 0$ and every $m \in \mathbb{N}$,
> $$\rho^2\bigl(\mathcal{C}(a,m)\bigr) \;=\; \frac{a^2}{a^2 + m} \;=\; \frac{a^2}{a^2 + b - 1}, \qquad b = m+1.$$

*Proof.* Substitute Lemma 3.3 into Definition 2.2: $\rho^2 = a^2 2^{4m} / \bigl(2^{2m}\cdot(a^2+m)2^{2m}\bigr) = a^2/(a^2+m)$. The denominator is positive since $a^2 > 0$ and $m \ge 0$. $\square$

**Corollary 3.5 (unweighted case).** $\rho^2(\mathcal{C}(1,m)) = 1/(m+1) = 1/b$. *One channel out of $b$ buys exactly one $b$-th of the squared correlation.*

**Corollary 3.6 (strict monotonicity).** For $a \neq 0$ and $m < m'$, $\rho^2(\mathcal{C}(a,m')) < \rho^2(\mathcal{C}(a,m))$.

> **Theorem 3.7 (Inverse-bit-length scaling).** For $a \neq 0$,
> $$b\,\rho^2\bigl(\mathcal{C}(a,b-1)\bigr) - a^2 \;=\; \frac{a^2(1-a^2)}{a^2+b-1} \;\xrightarrow[b\to\infty]{}\; 0 .$$

Hence $b\rho^2(b) \to a^2$: under dilution the *product* $b\rho^2$, not $\rho$, is the stable observable. This single fact organises the whole empirical analysis of §7.

---

## 4. Alphabet universality

The binary model is a modelling choice suggested by the fact that the ladder is indexed by bit-length. A natural objection is that widening the per-coordinate alphabet — bytes, machine limbs, residues modulo $q$ — might change the dilution rate and so explain the excess erosion. It does not.

**Definition 4.1 ($q$-ary alphabet and channel sum).** For $q \ge 2$ let $\mathcal{A}_q = \{0,1,\dots,q-1\}$. Let $\mathrm{Ch}_q(m)$ be the multiset of values of a sum of $m$ i.i.d. uniform draws from $\mathcal{A}_q$, listed with multiplicity, so $|\mathrm{Ch}_q(m)| = q^m$; recursively $\mathrm{Ch}_q(0) = \{0\}$ and $\mathrm{Ch}_q(m+1) = \{ w + d : w \in \mathrm{Ch}_q(m),\, d \in \mathcal{A}_q\}$.

**Lemma 4.2 (alphabet moments).** $\;\sum_{d\in\mathcal A_q} d = \tfrac{q(q-1)}{2}$ and $\sum_{d\in\mathcal A_q} d^2 = \tfrac{q(q-1)(2q-1)}{6}$.

**Lemma 4.3 (channel-sum moments).** For all $q, m$,
$$
\sum_{w \in \mathrm{Ch}_q(m)} w \;=\; q^m\,\frac{m(q-1)}{2}, \qquad
12\sum_{w\in\mathrm{Ch}_q(m)} w^2 \;=\; q^m\bigl(m(q^2-1) + 3m^2(q-1)^2\bigr).
$$

*Proof sketch.* From the recursion, $\Sigma_{m+1} = q\Sigma_m + q^m \sum_d d$ and $\Sigma^{(2)}_{m+1} = q\Sigma^{(2)}_m + 2(\sum_d d)\Sigma_m + q^m\sum_d d^2$. Insert Lemma 4.2 and induct on $m$; both closed forms are polynomial identities at each step. $\square$

**Definition 4.4 ($q$-ary channel sample).** $\;\mathcal{Q}(q,a,m) = \bigl\{ (d,\; a d + w) : d \in \mathcal{A}_q,\ w \in \mathrm{Ch}_q(m) \bigr\}$, a list of $q^{m+1}$ pairs enumerating all equally likely configurations.

**Lemma 4.5 (collapse onto a single scale).** Put $V(q,m) = q^{2m}\cdot \dfrac{q^2(q^2-1)}{12}$. Then
$$
\operatorname{Var}^X\bigl(\mathcal{Q}(q,a,m)\bigr) = V, \qquad
\operatorname{Cov}\bigl(\mathcal{Q}(q,a,m)\bigr) = a\,V, \qquad
\operatorname{Var}^Y\bigl(\mathcal{Q}(q,a,m)\bigr) = (a^2+m)\,V,
$$
and $V(q,m) > 0$ for $q \ge 2$.

*Proof sketch.* Compute the five raw sums $\Sigma x, \Sigma x^2, \Sigma y, \Sigma xy, \Sigma y^2$ of the product sample by summing over $w$ first (using Lemma 4.3) and then over $d$ (using Lemma 4.2); each is an explicit polynomial in $q^m, q, a, m$. Substituting into the determinant forms with $n = q^{m+1}$ produces the three stated products after cancellation. Positivity of $V$ is immediate from $q \ge 2$. $\square$

> **Theorem 4.6 (Alphabet-Universal Dilution Law).** For every $q \ge 2$, every $a \neq 0$ and every $m$,
> $$\rho^2\bigl(\mathcal{Q}(q,a,m)\bigr) \;=\; \frac{a^2}{a^2+m}.$$
> In particular $\rho^2(\mathcal{Q}(q,a,m)) = \rho^2(\mathcal{Q}(q',a,m))$ for all $q,q' \ge 2$: **the dilution rate is independent of the alphabet size.** Setting $q=2$ recovers Theorem 3.4.

*Proof.* By Lemma 4.5, $\rho^2 = (aV)^2/\bigl(V\cdot(a^2+m)V\bigr) = a^2/(a^2+m)$; the common scale $V \neq 0$ cancels. $\square$

The moral is worth stating plainly: **dilution counts channels, not symbols.** Widening the alphabet increases every variance in the problem by the same factor and therefore leaves the correlation untouched.

---

## 5. The dilution law is forced, not fitted

**Definition 5.1 (reciprocal excess).** For a reading $\rho \neq 0$ put $e(\rho) = 1/\rho^2 - 1$. Under any independent-channel model, $e$ is the size of the competing pool measured in units of the signal's own channel; under Theorem 3.4, $e = m/a^2$.

> **Theorem 5.2 (Additivity).** With $\mathrm{dil}_a(m) = a^2/(a^2+m)$ and $a \neq 0$, for all $m,n \in \mathbb{N}$
> $$\frac{1}{\mathrm{dil}_a(m+n)} - 1 \;=\; \Bigl(\frac{1}{\mathrm{dil}_a(m)}-1\Bigr) + \Bigl(\frac{1}{\mathrm{dil}_a(n)}-1\Bigr).$$

*Proof.* Both sides equal $(m+n)/a^2$. $\square$

> **Theorem 5.3 (Uniqueness).** Let $a \neq 0$ and let $f : \mathbb{N} \to \mathbb{Q}$ satisfy
> (i) $f(0) = 1$; (ii) $f(1) = a^2/(a^2+1)$; (iii) $1/f(m+n) - 1 = (1/f(m)-1) + (1/f(n)-1)$ for all $m,n$.
> Then $f(m) = a^2/(a^2+m)$ for every $m$.

*Proof.* From (ii), $1/f(1) = 1 + 1/a^2$. Applying (iii) with $n=1$ gives $1/f(m+1) = 1/f(m) + 1/a^2$, and (i) gives $1/f(0) = 1$; hence by induction $1/f(m) = 1 + m/a^2$ for all $m$. This is nonzero, so $f(m) = (1 + m/a^2)^{-1} = a^2/(a^2+m)$. $\square$

Theorem 5.3 upgrades the dilution law from "a curve that fits" to "the unique profile compatible with independent channels". It also identifies the correct coordinate for empirical work: on the $e$-scale, adjoining channels is *addition*, so the record should be read as a statement about $e(b)$, not about $\rho(b)$.

---

## 6. The product law: ties times channels

We now bring the competing hypothesis (H-tie) into the same framework.

**Definition 6.1 (tie profile and its correlation ratio).** A *tie profile* is a finite list $L = (\ell_1,\dots,\ell_K)$ of positive block sizes with total mass $n = \sum_j \ell_j$. Assign to the $n$ items the refining ranks $1,\dots,n$ in block order, and to each item of block $j$ the *mid-rank* $\bar r_j$ of its block. With $\bar r = (n+1)/2$ the grand mean, set
$$
S_S(L) \;=\; \sum_{i=1}^{n}(i - \bar r)^2 \;=\; \frac{n^3-n}{12}, \qquad
S_R(L) \;=\; \sum_{j} \ell_j (\bar r_j - \bar r)^2, \qquad
\rho^2_{\mathrm{tie}}(L) \;=\; \frac{S_R(L)}{S_S(L)} .
$$
$\rho^2_{\mathrm{tie}}(L)$ is the maximal squared rank correlation attainable by the tied predictor against a perfectly refining response — the *tie ceiling* of the profile.

**Definition 6.2 (dyadic profile).** $\mathrm{Dy}(b) = (2^{b-1}, 2^{b-2}, \dots, 2, 1, 1)$, of total mass $2^b$. This is precisely the distribution of $\nu_2$ on the $2^b$ residues below $2^b$: exactly $2^{b-1-k}$ of them have $\nu_2 = k$ for $k < b$, and one has $\nu_2 = b$.

**Proposition 6.3 (exact dyadic tie ceiling).** For $b \ge 1$,
$$
\rho^2_{\mathrm{tie}}(\mathrm{Dy}(b)) \;=\; \frac{6}{7}\left(1 + \frac{1}{2^b\,(2^b+1)}\right).
$$
In particular the ceiling is strictly decreasing in $b$, always exceeds $6/7 = 0.857142\ldots$, and converges to $6/7$ geometrically: $\rho^2_{\mathrm{tie}}(\mathrm{Dy}(b)) - 6/7 < 4^{-b}$.

**Definition 6.4 (product sample).** For a tie profile $L$ with mass $n$, weights $a, c$ and channel count $m$, the *product sample* pairs the mid-rank of each item with the response $a\cdot(\text{refining rank}) + c\cdot(\text{channel sum})$, ranging over all $2^m$ configurations of the noise cube. It has $2^m n$ points.

> **Theorem 6.5 (Product Law).** For every tie profile $L$ with mass $n$, all $a, c \in \mathbb{Q}$ and every $m$,
> $$\rho^2 \;=\; \frac{a^2\,S_R(L)}{a^2\,S_S(L) + \tfrac14 c^2 n m},$$
> and consequently, whenever $n \ge 2$,
> $$\rho^2 \;=\; \underbrace{\rho^2_{\mathrm{tie}}(L)}_{\text{tie attenuation}} \cdot \underbrace{\frac{a^2 S_S(L)}{a^2 S_S(L) + \tfrac14 c^2 n m}}_{\text{channel dilution}} .$$

*Proof sketch.* Compute the three centred moments of the product sample at the grand mean $\bar r$ of the predictor and $a\bar r + cm/2$ of the response. Summing over the noise cube first, the mixed terms carry a factor $\sum_{\text{items}} (\text{mid-rank} - \bar r)$, which vanishes because the mid-rank mass of a profile about its grand mean is zero; the noise contributes only through its variance $2^m m/4$ per item. What survives is $2^m a S_R$ in the covariance, $2^m S_R$ in the predictor variance, and $2^m(a^2 S_S + \tfrac14 c^2 n m)$ in the response variance. The factorised form follows from $S_R = \rho^2_{\mathrm{tie}} S_S$. $\square$

**Corollary 6.6 (dyadic evaluation).** At bit-length $b$, noise scale $c = n = 2^b$ and $m$ channels,
$$
\rho^2 \;=\; \rho^2_{\mathrm{tie}}(\mathrm{Dy}(b))\cdot \frac{a^2(n^3-n)}{a^2(n^3-n) + 3n^3 m}, \qquad\text{and}\qquad
\frac{a^2(n^3-n)}{a^2(n^3-n)+3n^3m} \;<\; \frac{a^2}{a^2+3m}
$$
for $b \ge 1$, $a \neq 0$, $m > 0$.

Theorem 6.5 is the structural heart of the analysis: the two candidate mechanisms **do not interact**. Any observed reading factorises into a ceiling term and a dilution term, and the two can be measured, bounded and falsified separately.

---

## 7. Reading the record

### 7.1 Tie granularity is excluded

> **Theorem 7.1 (the ceiling is frozen).** Across the recorded ladder,
> $$0 < \rho^2_{\mathrm{tie}}(\mathrm{Dy}(44)) - \rho^2_{\mathrm{tie}}(\mathrm{Dy}(88)) < 10^{-26},$$
> while the dial itself falls by $\rho(44)^2 - \rho(88)^2 > 0.32$. Moreover $\rho(88)^2 = 0.2852 < \rho^2_{\mathrm{tie}}(\mathrm{Dy}(88))$: the $88$-reading is far below its ceiling.

*Proof sketch.* Proposition 6.3 gives strict monotonicity and the bound $\rho^2_{\mathrm{tie}}(\mathrm{Dy}(44)) - 6/7 < 4^{-44} < 10^{-26}$ together with $\rho^2_{\mathrm{tie}}(\mathrm{Dy}(88)) > 6/7$. The remaining inequalities are arithmetic on the recorded values. $\square$

Hypothesis (H-tie) is therefore dead: a mechanism that moves by $10^{-26}$ cannot explain a fall of $0.32$. Whatever is happening at $88$ bits is a property of the *response*, not of the statistic's granularity.

### 7.2 The ladder is an inverse-bit-length law

**Definition 7.2 (rung invariant).** For a rung $(b,\rho)$ put $I(b) = \rho^2 b$.

> **Theorem 7.3 (constant window).** Every rung of the record except $b=52$ satisfies $I(b) \in [25,\,28.3]$:
> $$
> \begin{array}{c|ccccccccc}
> b & 44 & 56 & 64 & 68 & 72 & 76 & 80 & 84 & 88\\\hline
> I(b) & 26.77 & 26.66 & 27.04 & 25.30 & 26.79 & 28.28 & 25.99 & 26.34 & 25.09
> \end{array}
> $$
> The invariant is constant to within $\pm 6\%$ across a doubling of $b$, while $\rho^2$ itself falls by a factor $2.13$. The $52$-rung has $I(52) = 34.12 > 28.3$ and is the single outlier; it is also the rung that broke monotonicity.

> **Theorem 7.4 (out-of-sample prediction).** For all eight consecutive non-outlier pairs $(b, b')$ of the ladder,
> $$\bigl| I(b)/b' - \rho(b')^2 \bigr| < 0.03 .$$
> Nothing is fitted to the target rung.

**Definition 7.5 (pooled constant).** $C = \tfrac19\sum I(b)$ over the nine non-outlier rungs. Exactly,
$$C \;=\; \frac{7446029}{281250} \;=\; 26.474769\overline{7}\ldots$$

> **Theorem 7.6 (Retrodiction of the first band miss).** With the acceptance floor $\phi = 0.55$,
> $$\phi^2 < \frac{C}{b} \ \ \text{for all } 1 \le b \le 84, \qquad \frac{C}{b} < \phi^2 \ \ \text{for all } b \ge 88 .$$
> Equivalently the crossing bit-length is $b^\star = C/\phi^2$ with $87 < b^\star < 88$; numerically $b^\star = 87.52$. **The first band miss is forced to occur at the $88$-rung.**

*Proof.* $\phi^2 = 121/400$ and $C = 7446029/281250$; the two inequalities reduce to $121 b \le 121\cdot 84 < 400C\cdot(281250/281250)$ and its counterpart, both decidable comparisons of explicit rationals. $\square$

The $88$-rung is therefore not a fluke of one measurement: the shape fitted to the *other* nine readings already schedules a floor crossing between $84$ and $88$ bits, and $88$ is the first rung past it.

**Proposition 7.7 (legal regime).** $C/b < \rho^2_{\mathrm{tie}}(\mathrm{Dy}(b))$ for every $b \ge 31$, and $C/b > \rho^2_{\mathrm{tie}}(\mathrm{Dy}(b))$ for $1 \le b \le 30$. The record begins at $b=44$, safely inside the region where the channel pool, not the tie ceiling, is the binding constraint.

*Proof sketch.* $C/b \le 6/7$ exactly when $b \ge 7C/6 = 30.887\ldots$, and $\rho^2_{\mathrm{tie}} > 6/7$ always; for $b \le 30$ compare $C/b$ against the ceiling using $\rho^2_{\mathrm{tie}} \le 1$ for $b \le 2$ and $\rho^2_{\mathrm{tie}} < 6/7 + 4^{-3}$ for $3 \le b \le 30$. $\square$

---

## 8. Adversarial review: what the record rules out

A model that only ever confirms itself is worthless. We therefore test the channel reading against the record as hard as we can. It survives as a *shape* and fails in its *literal* form — and the failure is informative.

### 8.1 Fixed-weight dilution is excluded, for every alphabet

> **Theorem 8.1.** For every weight $a \neq 0$,
> $$\frac{a^2}{a^2+87}\,\rho(44)^2 \;>\; \frac{a^2}{a^2+43}\,\rho(88)^2 ,$$
> i.e. the exact dilution law decays strictly more slowly between $b = 44$ and $b = 88$ than the record does. By Theorem 4.6 the same holds with $\rho^2(\mathcal{Q}(q,a,\cdot))$ for every alphabet size $q \ge 2$.

*Proof sketch.* Clearing denominators reduces the claim to a quadratic inequality in $a^2$ with the explicit rational coefficients $\rho(44)^2 = 1521/2500$ and $\rho(88)^2 = 71289/250000$, valid for all $a^2>0$. $\square$

Because the alphabet cancels identically (Theorem 4.6), no quantisation width rescues the model. The excess erosion is not a symbol-width effect.

> **Theorem 8.2 (linear pool growth excluded).** For every $a \neq 0$ and every growth rate $\kappa > 0$, the law $\rho^2(b) = a^2/(a^2 + \kappa(b-1))$ satisfies
> $$\frac{a^2}{a^2+87\kappa}\,\rho(44)^2 \;>\; \frac{a^2}{a^2+43\kappa}\,\rho(88)^2 .$$
> The entire two-parameter family decays too slowly.

### 8.2 The record is super-additive on the reciprocal scale

By Theorem 5.2, any genuine fixed-weight independent-channel model requires the reciprocal excess to be *proportional to the channel count*, i.e. $e(88)\cdot 43 = e(44)\cdot 87$ for pools of sizes $43$ and $87$.

> **Theorem 8.3 (super-additivity).** $\;e(\rho(44))\cdot 87 < e(\rho(88))\cdot 43$, numerically $56.0 < 107.8$.

> **Theorem 8.4 (superlinear pool).** Model-independently within the dilution family — the fitted pool size is $a^2(1-\rho^2)/\rho^2$, whose *ratio* between two rungs does not depend on $a$ — the pool grows by a factor in $(3.8,\,4)$ between $b=44$ and $b=88$, while $b$ merely doubles and a linear pool would grow by $87/43 < 2.03$.

This is the quantitative content of "super-dilute": the effective pool grows roughly like $b^2$.

### 8.3 The odds-scale law is falsified by the $84$-rung

**Definition 8.5.** $\mathrm{odds}(\rho) = \rho^2/(1-\rho^2)$; the competing hypothesis is $\mathrm{odds}(\rho(b)) = K/b^2$.

> **Theorem 8.6.** All nine non-outlier rungs satisfy $\mathrm{odds}(\rho(b))\,b^2 \in [2700,\,3450]$, pooling to $K = 3053.6\ldots$ On trend alone the odds-scale law and the $\rho^2$-scale law of §7 are indistinguishable. However, with $\mathrm{odds}(0.55) = 121/279$,
> $$\frac{K}{80^2} > \mathrm{odds}(0.55) > \frac{K}{84^2},$$
> so the odds law places the first band miss at $b = 84$ — and the recorded $84$-rung *held the band*, at $0.56 \ge 0.55$, i.e. $\mathrm{odds}(0.55) \le \mathrm{odds}(0.56)$. **The odds-scale inverse-square law is rejected**, while the $\rho^2$-scale inverse law, whose crossing lies at $87.52$, passes the same test.

The record therefore *discriminates* between two hypotheses that a naive goodness-of-fit comparison would call equally good. The discriminating observable is not the fit residual but the predicted crossing rung.

### 8.4 A quadratic pool with a forced noise floor

The natural repair, given §8.2, is a quadratic pool plus a constant non-channel term:
$$
\frac{1}{\rho^2(b)} - 1 \;=\; \kappa b^2 + c .
$$
Fit $(\kappa,c)$ exactly to the two extreme rungs $44$ and $88$. Using $e(\rho(44)) = 979/1521$ and $e(\rho(88)) = 178711/71289$, this gives
$$
\kappa = \frac{e(88)-e(44)}{88^2-44^2} = 3.2080\times 10^{-4}, \qquad c = e(44) - 44^2\kappa = 0.022590\ldots
$$

> **Theorem 8.7 (the noise floor is forced).** Any pair $(\kappa,c)$ with $\kappa\cdot 44^2 + c = e(\rho(44))$ and $\kappa \cdot 88^2 + c = e(\rho(88))$ satisfies $\kappa > 0$ **and** $c > 0$. The pure quadratic pool $c=0$ is excluded by the record.

*Proof.* Subtracting the equations, $\kappa = (e(88)-e(44))/5808 > 0$ since $e$ is increasing along the record. Then $c = e(44) - 1936\kappa$, and $c > 0$ is equivalent to $4 e(44) > e(88)$, i.e. the record erodes by a factor strictly less than $(88/44)^2 = 4$ on the reciprocal scale — which it does, by $3.895 < 4$. $\square$

> **Theorem 8.8 (pure pairwise interaction over-erodes).** If the competing channels are the $\binom{b}{2}$ unordered pairs of $b$ base channels, then by Theorem 3.4 and $\binom b2 = b(b-1)/2$,
> $$\rho^2 = \frac{2a^2}{2a^2 + b(b-1)} ,$$
> whose reciprocal excess multiplies by $2\cdot 87/43 = 174/43 = 4.047$ between $b=44$ and $b=88$. The record multiplies it by only $3.895$. The observed erosion is super-additive but strictly *slower* than pure pairwise interaction — exactly the gap the positive floor of Theorem 8.7 fills.

> **Theorem 8.9 (retrodiction).** The two-point fit $\rho^2(b) = 1/(1 + \kappa b^2 + c)$ reproduces all nine non-outlier rungs to within $0.027$ in $\rho^2$, including the six rungs it never saw. It misses the $52$-rung by more than $0.08$ — three times the worst deviation elsewhere — independently confirming that rung as the single outlier.

> **Theorem 8.10 (Robustness of the $88$-rung).** The fitted quadratic-pool law satisfies $\rho^2(b) > 0.55^2$ for all $b \le 84$ and $\rho^2(b) < 0.55^2$ for all $b \ge 88$. Together with Theorem 7.6:
> $$
> \frac{C}{84} > 0.3025 > \frac{C}{88}, \qquad \frac{1}{1+\kappa 84^2+c} > 0.3025 > \frac{1}{1+\kappa 88^2 + c} .
> $$
> Two structurally different laws, fitted by different procedures — pooling nine rungs on the $\rho^2 b$ invariant, versus interpolating two rungs on the reciprocal scale — both bracket the band crossing in $(84,88]$. **The first band miss at $88$ is a property of the record, not of a chosen functional form.**

---

## 9. Pythagorean transfer

The two-adic tie ceiling was computed for uniform integers. We show it holds verbatim on the even legs of Pythagorean triples, so that the entire analysis applies unchanged in that arithmetic setting.

**Proposition 9.1 (Euclid).** For all integers $m,n$: $(m^2-n^2)^2 + (2mn)^2 = (m^2+n^2)^2$.

> **Lemma 9.2 (two-adic valuation of the even leg).** Let $m$ be odd. Then for all $k, n \in \mathbb{N}$,
> $$2^{k+1} \mid 2mn \iff 2^k \mid n .$$

*Proof.* $2^{k+1} \mid 2mn \iff 2^k \mid mn$, and $\gcd(2^k, m) = 1$ since $m$ is odd, so $2^k \mid mn \iff 2^k \mid n$. $\square$

> **Theorem 9.3 (block cardinality).** Let $m$ be odd and $k < b$. Exactly $2^{\,b-1-k}$ of the $2^b$ generators $n < 2^b$ produce an even leg $2mn$ with precisely $k+1$ trailing binary zeros.

> **Theorem 9.4 (profile identity).** For every odd $m$ and every $b$, the tie profile of the trailing-zero descriptor on the even legs $\{2mn : n < 2^b\}$ is *literally* the dyadic profile $\mathrm{Dy}(b)$.

*Proof sketch.* By Lemma 9.2 the block of generators whose even leg has valuation exactly $k+1$ coincides with the block of $n$ of valuation exactly $k$; the odd factor $m$ is invisible to the valuation and the factor $2$ merely shifts the index. Counting gives Theorem 9.3, and assembling the blocks in order gives $\mathrm{Dy}(b)$. $\square$

> **Corollary 9.5 (transfer of the ceiling and of the band miss).** For every odd $m$ and every $b \ge 1$, the tie ceiling on Pythagorean even legs is exactly
> $$\frac{6}{7}\left(1 + \frac{1}{2^b(2^b+1)}\right),$$
> and at $b = 88$ this exceeds both $\rho(88)^2 = 0.2852$ and the squared floor $0.3025$. Every ceiling proved for uniform integers therefore holds verbatim on Pythagorean even legs, and the $88$-bit band miss must be charged to the response there too.

---

## 10. Algorithms

The analysis reduces to four exact rational procedures. All arithmetic is over $\mathbb{Q}$; no floating point is required, and every quantity below is an exact rational.

**Algorithm A — Exact squared Pearson coefficient in determinant form.**
Input: a list of $n$ rational pairs. Accumulate $\Sigma x, \Sigma y, \Sigma x^2, \Sigma y^2, \Sigma xy$ in one pass, then form $\rho^2 = (n\Sigma xy - \Sigma x\Sigma y)^2/\bigl((n\Sigma x^2 - (\Sigma x)^2)(n\Sigma y^2-(\Sigma y)^2)\bigr)$. Cost: $O(n)$ rational operations, no division until the final step.

**Algorithm B — Brute-force verification of the dilution law.**
Enumerate all $q^{m+1}$ configurations of the $q$-ary channel sample, apply Algorithm A, and compare with $a^2/(a^2+m)$. Cost: $O(q^{m+1})$; feasible for $q \le 6$, $m \le 8$. This is a *verification*, not a proof — the proof is Theorem 4.6 — but it is a decisive check on the moment algebra, and it is where alphabet universality becomes visible: the same rational number appears for every $q$.

**Algorithm C — Pooled inverse-bit-length fit and crossing search.**
Given rungs $(b_i,\rho_i)$, compute $I_i = \rho_i^2 b_i$, discard rungs outside the acceptance window $[25,28.3]$ (which isolates exactly the $52$-rung), pool $C = \operatorname{mean}(I_i)$, and return the crossing $b^\star = C/\phi^2$. The predicted first-miss rung is the least ladder rung exceeding $b^\star$. Cost: $O(N)$ for $N$ rungs.

**Algorithm D — Two-point reciprocal-scale fit with a noise floor.**
Given two anchor rungs $(b_0,\rho_0)$, $(b_1,\rho_1)$, compute $e_i = 1/\rho_i^2-1$, solve the linear system $\kappa b_i^2 + c = e_i$ exactly, and report $(\kappa, c)$ together with the retrodicted profile $\rho^2(b) = 1/(1+\kappa b^2+c)$ and the crossing $b^\star = \sqrt{(1/\phi^2 - 1 - c)/\kappa}$. The sign test $c > 0$ is Theorem 8.7. Cost: $O(1)$.

---

## 11. Applications

**Diagnostic triage.** A fading correlation invites two opposite responses: repair the statistic, or accept that the environment has changed. The product law (Theorem 6.5) turns that into a decidable question, because the two mechanisms factor. Compute the tie ceiling of the predictor's value distribution; if it is numerically frozen across the range of interest, the erosion is dilution and the statistic itself is fine.

**Counting the competition.** Reading the dilution law backwards makes the reciprocal excess $e = 1/\rho^2 - 1$ a *measurement of the environment*: the number of independent competing influences, in units of the signal's own channel. Theorems 5.2 and 5.3 justify this reading — $e$ is the unique additive coordinate for independent channels. Tracking $e(b)$ rather than $\rho(b)$ converts a curved decay into a straight line whose curvature, when present, is a first-order signal of a change in the growth exponent of the pool.

**Scheduling band exits.** For any monitored diagnostic with an acceptance floor, the pooled invariant fit (Algorithm C) predicts *when* the floor will be crossed, before it is crossed. Here the fit made on rungs $44$–$84$ already places the crossing at $87.5$, so the $88$-rung miss was scheduled rather than surprising. The practical value is scheduling: an instrument whose exit rung is known in advance can be re-designed before it fails.

**Alphabet-independent design.** Theorem 4.6 says that widening the per-coordinate alphabet buys no correlation. A designer trying to recover a fading signal by moving from bits to bytes is wasting effort; the only levers are the weight $a$ and the number $m$ of competitors.

**Arithmetic transfer.** Corollary 9.5 shows the ceilings hold on structured arithmetic families — the even legs of the Euclid parametrisation — not just on uniform integers. Diagnostics calibrated on random integers can be deployed on Pythagorean data without recalibrating the tie ceiling.

---

## 12. Discussion

Three points deserve emphasis.

**Exactness.** Every identity in §§2–6 is an identity between rational numbers on an explicitly enumerated finite sample. There is no appeal to asymptotic normality, no simulation, and no estimation error inside the model. The empirical inputs enter only as the ten recorded readings, which are exact rationals with two or three decimal digits; every downstream inequality is a comparison of explicit rationals.

**The literal model is false, and that is the finding.** The fixed-weight, linearly-growing channel pool is excluded for every weight, every alphabet and every growth rate (Theorems 8.1, 8.2). What survives is the *shape*: dilution as a mechanism, the reciprocal excess as the additive coordinate, and inverse-bit-length behaviour as an approximation good to $\pm 6\%$ over a doubling of $b$. The residual — the fact that the pool grows like $b^2$ rather than $b$, with a small positive non-channel floor — is a genuine empirical discovery about the environment, made visible only because the exact law was available to subtract.

**Robustness is the argument.** The claim "the first band miss occurs at $88$" would be weak if it depended on the functional form. It does not. A nine-rung pooled fit on the $\rho^2$ scale and a two-rung interpolation on the reciprocal scale, with different parameter counts and different fitting procedures, both place the crossing in $(84,88]$ (Theorem 8.10). Meanwhile the one competing hypothesis that also fits the trend — the odds-scale inverse-square law — makes a *different* crossing prediction and is falsified by the rung that held (Theorem 8.6). The $88$-rung is thus supported by agreement between models and by the elimination of the nearest alternative.

**Limitations.** The record has ten rungs, one of which is an outlier; the $88$-reading's confidence interval straddles the floor, so the empirical verdict is properly "inconclusive" rather than "rejected". The $52$-rung anomaly is flagged by two independent methods but not explained. The models tested are the natural low-parameter families; a cubic pool has not been excluded, and §13 makes that the first target.

---

## 13. Future work

1. **Cubic pool transition.** The effective pool $e(b) = 1/\rho^2(b)-1$ may not be globally quadratic. The signs of the two-point quadratic fit's residuals walking up the ladder from $56$ to $84$ read $+,+,+,0,-,0,-$ — a monotone drift of exactly the shape a slightly super-quadratic pool would produce. Since the reciprocal excess, not the correlation, is the additive observable, a change of growth exponent appears as curvature in $e(b)$: a first-order effect on a scale where raw readings differ by $0.01$. The rungs $96$, $112$, $128$ separate $b^2$ from $b^3$ by more than the seed noise of $\pm 0.03$.
2. **Universality of the noise floor.** Is the constant $c > 0$ forced by Theorem 8.7 an invariant of the *estimator* rather than of the sampled population? The conjecture is that the same $c$ appears in every ladder run with the same sample size and tie-handling, including non-uniform ladders, and that it scales like $1/N$ in the sample size — which is what finite-sample attenuation of a rank statistic would produce.
3. **Explaining the $52$-rung.** Two independent methods flag it; neither explains it. A structural cause (a coincidence in the tie profile at that width, or an artefact of the sampling grid) would be worth isolating.
4. **Interaction-free composition beyond ties.** Theorem 6.5 has no interaction term because the mid-rank mass of a profile about its grand mean vanishes. Characterising exactly which predictor transformations preserve interaction-freeness would extend the product law well beyond rank statistics.
5. **Non-uniform arithmetic families.** Corollary 9.5 transfers the ceiling to Euclid even legs. The same argument should transfer it to any family whose two-adic valuation is a shift of a uniform valuation; identifying the general condition would cover Pell solutions and prime-gap ladders in one statement.

---

## 14. Summary of results

| Result | Statement |
|---|---|
| Channel-dilution law | $\rho^2 = a^2/(a^2+b-1)$, exactly, for $b$ binary channels |
| Unweighted case | $\rho^2 = 1/b$ |
| Inverse-bit-length scaling | $b\rho^2 - a^2 = a^2(1-a^2)/(a^2+b-1) \to 0$ |
| Alphabet universality | same $\rho^2 = a^2/(a^2+m)$ for every alphabet size $q \ge 2$ |
| Additivity | $1/\rho^2 - 1$ is additive in the channel count |
| Uniqueness | additivity plus the one-channel value forces the dilution law |
| Product law | $\rho^2 = \rho^2_{\text{tie}}\cdot a^2S_S/(a^2S_S+\tfrac14c^2nm)$, no interaction term |
| Dyadic tie ceiling | $\tfrac67\bigl(1+2^{-b}(2^b+1)^{-1}\bigr)$ |
| Tie granularity excluded | ceiling moves $<10^{-26}$; dial moves $>0.32$ |
| Pooled invariant | $C = 7446029/281250 = 26.4747\ldots$, nine rungs in $[25,28.3]$ |
| Retrodiction | crossing at $b^\star = 87.52 \in (87,88)$; first miss forced at $88$ |
| Fixed-weight model excluded | for every $a\neq0$, every $q\ge2$, every $\kappa>0$ |
| Super-additivity | $e(88)\cdot43 > e(44)\cdot87$; pool factor in $(3.8,4)$ |
| Odds-scale law falsified | predicts first miss at $84$; the $84$-rung held |
| Noise floor forced | any two-point quadratic fit has $\kappa>0$ and $c>0$ |
| Pairwise pool over-erodes | factor $174/43 = 4.047 > 3.895$ |
| Model robustness | both laws bracket the crossing in $(84,88]$ |
| Pythagorean transfer | even-leg tie profile is literally the dyadic profile |
