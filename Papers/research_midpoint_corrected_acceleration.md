# Telescoping Envelopes and Certified Acceleration of the Euler–Mascheroni Sequence

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

Let $H_n = \sum_{k=1}^n 1/k$ denote the $n$-th harmonic number and let
$$s_n = H_n - \log(n+1),$$
a sequence converging to the Euler–Mascheroni constant $\gamma$ at rate $\Theta(n^{-1})$. We develop an elementary, self-contained framework — the *telescoping envelope method* — that yields two-sided, fully explicit error bounds for accelerated variants of $s_n$, valid for **every** index $n \ge 0$ with no asymptotic threshold whatsoever, and with error constants that are provably optimal.

Our first main result concerns the midpoint-corrected sequence $A_1(n) = s_n + \frac{1}{2(n+1)}$. We prove that
$$\frac{1}{12(n+1)^2} - \frac{1}{36(n+1)^3} \;\le\; \gamma - A_1(n) \;\le\; \frac{1}{12(n+1)^2} \qquad (n \ge 0),$$
so in particular $A_1(n) < \gamma$, $|\gamma - A_1(n)| \le \frac{1}{12(n+1)^2}$, and $12(n+1)^2(\gamma - A_1(n)) \to 1$, establishing the sharpness of the constant $1/12$. The upper bound is tight already at $n = 0$, where the true error attains $92.66\%$ of the stated bound.

We then isolate the mechanism as a pair of *envelope transfer theorems*, which reduce every order of acceleration to a single one-variable inequality between $\log(1+x)$ and an explicit rational function. Using this, we prove the fourth-order result $|\gamma - A_2(n)| \le \frac{1}{120(n+1)^4}$ with sharp constant, where $A_2(n) = A_1(n) + \frac{1}{12(n+1)^2}$, together with the certified enclosure
$$A_1(n) < \gamma < A_2(n), \qquad A_2(n) - A_1(n) = \frac{1}{12(n+1)^2},$$
and the sixth-order result $|\gamma - A_3(n)| \le \frac{1}{252(n+1)^6}$ for $A_3(n) = A_2(n) - \frac{1}{120(n+1)^4}$. The constants $\frac12, \frac1{12}, \frac1{120}, \frac1{252}$ are exactly $\frac{|B_{2k}|}{2k}$ for the Bernoulli numbers $B_{2k}$: we recover the Euler–Maclaurin expansion of $\gamma - s_n$, but as a tower of unconditional inequalities rather than an asymptotic series with an unquantified remainder. As an immediate corollary, evaluating the enclosure at $n = 0$ gives $\frac12 < \gamma < \frac{7}{12}$ from pure arithmetic.

**Keywords:** Euler–Mascheroni constant, harmonic numbers, series acceleration, Euler–Maclaurin summation, Bernoulli numbers, Padé approximation, certified error bounds, telescoping.

---

## 1. Introduction

### 1.1 The constant and the problem

The Euler–Mascheroni constant
$$\gamma = \lim_{n\to\infty}\Bigl(\sum_{k=1}^n \frac1k - \log n\Bigr) = 0.57721566490153286060\ldots$$
is, after $\pi$ and $e$, arguably the most frequently encountered constant in analysis and analytic number theory. It governs the mean value of the divisor function, the constant in Mertens' third theorem, the asymptotics of the digamma function ($\psi(1) = -\gamma$), the expected number of records in a random permutation, and the average-case behaviour of numerous algorithms. Its arithmetic nature remains completely open: it is not known to be irrational.

The definition above is also, computationally, a disaster. Working with the convenient shifted variant
$$s_n \;=\; H_n - \log(n+1), \qquad H_n = \sum_{k=1}^n \frac1k, \qquad s_0 = 0,$$
the error $\gamma - s_n$ decays only like $\frac{1}{2n}$. Achieving $d$ correct decimal digits requires on the order of $10^{d}$ summands. Any serious computation of $\gamma$ therefore uses acceleration.

### 1.2 What is proved here

Acceleration of $s_n$ is classical: the Euler–Maclaurin formula produces the asymptotic expansion
$$\gamma - s_n \;\sim\; \frac{1}{2m} + \frac{1}{12m^2} - \frac{1}{120m^4} + \frac{1}{252m^6} - \cdots, \qquad m := n+1, \tag{1.1}$$
whose coefficients are $\frac{|B_{2k}|}{2k}$ with alternating signs. What is *not* classical, and what this paper supplies, is a treatment in which:

1. **every bound is unconditional**, holding for all $n \ge 0$ with no threshold and no unspecified constant;
2. **every leading constant is proved optimal** by a matching lower bound of the same order;
3. **the entire transcendental input** is a finite list of elementary one-variable inequalities for $\log(1+x)$, each provable by a single differentiation;
4. **the infinite-summation step is isolated once** in two reusable transfer theorems, so that each further order of acceleration costs exactly one new inequality.

Point (3) is what distinguishes this from a direct Euler–Maclaurin argument. Euler–Maclaurin remainder terms involve periodic Bernoulli polynomials and integral estimates; controlling them with the sharp constant, uniformly down to $n = 0$, is delicate. Our route never forms an integral remainder and never manipulates an infinite sum after Section 3.

### 1.3 Organisation

Section 2 sets notation and records the telescoping identity. Section 3 states and proves the two envelope transfer theorems. Section 4 develops the required Padé-type inequalities for the logarithm and their uniform proof template. Section 5 proves the second-order (midpoint) results, Section 6 the fourth-order results and the certified enclosure, Section 7 the sixth-order result. Section 8 discusses the algorithmic consequences and gives numerical evidence. Section 9 discusses the Bernoulli structure, and Section 10 lists open problems.

---

## 2. Setup

### 2.1 Notation

Throughout, $n$ denotes a nonnegative integer, and we consistently write
$$m := n + 1 \ge 1.$$
We use $\log$ for the natural logarithm.

**Definition 2.1 (Base sequence).** For $n \in \mathbb{N}$,
$$s_n \;=\; H_n - \log(n+1), \qquad H_n = \sum_{k=1}^{n}\frac1k \quad (H_0 = 0).$$
In particular $s_0 = 0$, and $s_n \to \gamma$.

**Definition 2.2 (Accelerated sequences).** With $m = n+1$,
$$
\begin{aligned}
A_1(n) &= s_n + \frac{1}{2m}, \\[2pt]
A_2(n) &= s_n + \frac{1}{2m} + \frac{1}{12m^2}, \\[2pt]
A_3(n) &= s_n + \frac{1}{2m} + \frac{1}{12m^2} - \frac{1}{120m^4}.
\end{aligned}
$$

We refer to $A_1$ as the *midpoint-corrected*, $A_2$ as the *quartically accelerated*, and $A_3$ as the *sixth-order accelerated* sequence.

### 2.2 The telescoping identity

**Lemma 2.3 (One-step increment).** For every $k \in \mathbb{N}$,
$$s_{k+1} - s_k \;=\; \frac{1}{k+1} - \log\!\left(1 + \frac{1}{k+1}\right).$$

*Proof.* $H_{k+1} - H_k = \frac{1}{k+1}$, while $\log(k+2) - \log(k+1) = \log\frac{k+2}{k+1} = \log\bigl(1 + \frac{1}{k+1}\bigr)$. Subtract. $\square$

Consequently, since $s_n \to \gamma$,
$$\gamma - s_n \;=\; \sum_{m \ge n+1}\left[\frac{1}{m} - \log\!\left(1+\frac1m\right)\right]. \tag{2.1}$$

Geometrically, the $m$-th summand is the area between the rectangle of width $1$ and height $1/m$ over $[m, m+1]$ and the region under the hyperbola $y = 1/x$ over the same interval. Since $1/x$ is convex and decreasing, each summand is positive and of size $\frac{1}{2m^2} + O(m^{-3})$; hence $\gamma - s_n = \frac{1}{2m} + O(m^{-2})$, which explains both the slow convergence and the shape of the leading correction.

We stress that identity (2.1) will be used only as motivation; the proofs below never manipulate an infinite series.

---

## 3. The envelope transfer theorems

The following two theorems are the structural core. They convert a *pointwise, one-step* inequality into a *global, tail* inequality, by telescoping and a single limit.

**Theorem 3.1 (Upper envelope transfer).** Let $H : [1,\infty) \to \mathbb{R}$ satisfy
- (nonnegativity) $H(m) \ge 0$ for all real $m \ge 1$;
- (step domination) $\displaystyle \frac{1}{m} - \log\!\left(1+\frac1m\right) \;\le\; H(m) - H(m+1)$ for all real $m \ge 1$.

Then for every $n \in \mathbb{N}$,
$$\gamma - s_n \;\le\; H(n+1).$$

*Proof.* Fix $n$ and prove by induction on $d \ge 0$ that
$$s_{n+d} \;\le\; s_n + H(n+1) - H(n+d+1).$$
The case $d = 0$ is an identity. For the inductive step, apply step domination at $m = n + d + 1 \ge 1$ together with Lemma 2.3:
$$s_{n+d+1} - s_{n+d} = \frac{1}{n+d+1} - \log\!\Bigl(1+\tfrac{1}{n+d+1}\Bigr) \le H(n+d+1) - H(n+d+2),$$
and add the inductive hypothesis. Now for any $N \ge n$, writing $N = n + d$ and using $H(N+1) \ge 0$,
$$s_N \;\le\; s_n + H(n+1).$$
The right-hand side is a constant independent of $N$; since $s_N \to \gamma$, passing to the limit gives $\gamma \le s_n + H(n+1)$. $\square$

**Theorem 3.2 (Lower envelope transfer).** Let $H : [1,\infty) \to \mathbb{R}$ satisfy
- (smallness) $H(m) \le \frac{1}{m}$ for all real $m \ge 1$;
- (step domination) $\displaystyle H(m) - H(m+1) \;\le\; \frac{1}{m} - \log\!\left(1+\frac1m\right)$ for all real $m \ge 1$.

Then for every $n \in \mathbb{N}$,
$$H(n+1) \;\le\; \gamma - s_n.$$

*Proof.* Dually, induction gives $s_n + H(n+1) - H(n+d+1) \le s_{n+d}$ for all $d \ge 0$. The smallness hypothesis gives $H(N+1) \le \frac{1}{N+1} \to 0$, so
$$s_n + H(n+1) \;\le\; \liminf_{N\to\infty}\bigl(s_N + H(N+1)\bigr) = \gamma. \qquad \square$$

**Remark 3.3.** The smallness hypothesis in Theorem 3.2 is only used to guarantee $H(N+1) \to 0$; any decay condition would do. The stated form $H(m) \le 1/m$ is convenient because all our envelopes are truncations of (1.1) beginning with $\frac{1}{2m}$, for which it is easily checked by clearing denominators.

**Remark 3.4 (Design principle).** To obtain a bound of order $m^{-r}$ one seeks an envelope $H$ of the form
$$H(x) = \frac{1}{2x} + \frac{1}{12x^2} - \frac{1}{120x^4} + \cdots \pm \frac{c}{x^{r}},$$
i.e. a truncation of the Euler–Maclaurin tail (1.1). Substituting $x \mapsto 1/m$ and clearing denominators turns the step-domination hypothesis into an inequality between $\log(1+x)$ and a rational function of $x$, valid for $x \in [0,1]$ — and, as it happens in every case treated here, valid for all $x \ge 0$. This is the subject of the next section.

---

## 4. Padé-type inequalities for the logarithm

### 4.1 The proof template

**Lemma 4.1 (Derivative test).** Let $f : (-1,\infty) \to \mathbb{R}$ be differentiable with $f(0) = 0$ and $f'(x) \ge 0$ for all $x > 0$. Then $f(x) \ge 0$ for all $x \ge 0$.

*Proof.* $f$ is continuous on $[0,\infty)$ and has nonnegative derivative on the interior, hence is monotone nondecreasing there; evaluate at $0$. (The hypothesis on the larger domain $(-1,\infty)$ is what supplies continuity at the endpoint $0$, since our $f$ involve $\log(1+x)$.) $\square$

Every inequality below is an instance: we exhibit $f = \log(1+x) - R(x)$ or $R(x) - \log(1+x)$ for an explicit rational $R$ with $R(0) = 0$, differentiate, and observe that the resulting rational function has a numerator with nonnegative coefficients and a positive denominator.

### 4.2 The second-order pair

**Theorem 4.2 (Lower Padé bound).** For all $x \ge 0$,
$$\frac{12x + 18x^2 + 4x^3 - x^4}{12(1+x)^2} \;\le\; \log(1+x).$$

*Proof sketch.* Set $f(x) = \log(1+x) - \frac{12x + 18x^2 + 4x^3 - x^4}{12(1+x)^2}$. Then $f(0) = 0$, and differentiating (quotient rule, using $\frac{d}{dx}\log(1+x) = \frac{1}{1+x}$) and simplifying yields
$$f'(x) = \frac{x^4}{6(1+x)^3},$$
which is $\ge 0$ for $x \ge 0$. Apply Lemma 4.1. $\square$

**Theorem 4.3 (Upper Padé bound).** For all $x \ge 0$,
$$\log(1+x) \;\le\; \frac{36x + 90x^2 + 66x^3 + 12x^4 + x^6}{36(1+x)^3}.$$

*Proof sketch.* Set $f(x) = \frac{36x + 90x^2 + 66x^3 + 12x^4 + x^6}{36(1+x)^3} - \log(1+x)$. Then $f(0) = 0$ and
$$f'(x) = \frac{x^3\,(12 + 12x + 6x^2 + 3x^3)}{36(1+x)^4} \;\ge\; 0 \quad (x \ge 0).$$
Apply Lemma 4.1. $\square$

Both bounds agree with $\log(1+x)$ to order $x^4$; their two-sided combination pins $\log(1+x)$ to order $x^5$ with error $\pm\frac{x^5}{30} + O(x^6)$.

### 4.3 The fourth- and fifth-order pair

**Theorem 4.4 (Fourth-order upper bound).** For all $x \ge 0$,
$$\log(1+x) \;\le\; \frac{120x + 420x^2 + 520x^3 + 250x^4 + 24x^5 - 4x^6 + 4x^7 + x^8}{120(1+x)^4}.$$

*Proof sketch.* The difference (rational minus logarithm) vanishes at $0$ and has derivative
$$\frac{5x^6 + 5x^7 + x^8}{30(1+x)^5} \;\ge\; 0. \qquad \square$$

**Theorem 4.5 (Fifth-order lower bound).** For all $x \ge 0$,
$$\frac{600x + 2700x^2 + 4700x^3 + 3850x^4 + 1370x^5 + 90x^6 - 20x^7 + 5x^8 - 5x^9 - 2x^{10}}{600(1+x)^5} \;\le\; \log(1+x).$$

*Proof sketch.* The difference (logarithm minus rational) vanishes at $0$ and has derivative
$$\frac{6x^5 + 5x^6 + 3x^8 + 4x^9 + x^{10}}{60(1+x)^6} \;\ge\; 0. \qquad \square$$

### 4.4 The sixth-order bound

It is convenient here to write the approximant in *structured* form, as the second-order Padé approximant plus explicit Bernoulli corrections.

**Theorem 4.6 (Sixth-order lower bound).** For all $x \ge 0$,
$$\frac{12x + 18x^2 + 4x^3 - x^4}{12(1+x)^2} \;+\; \frac{x^4\bigl((1+x)^4 - 1\bigr)}{120(1+x)^4} \;-\; \frac{x^6\bigl((1+x)^6 - 1\bigr)}{252(1+x)^6} \;\le\; \log(1+x).$$

*Proof sketch.* Denote the left side by $R_6(x)$; then $R_6(0) = 0$, and $f = \log(1+x) - R_6(x)$ satisfies
$$f'(x) = \frac{63x^8 + 126x^9 + 98x^{10} + 35x^{11} + 5x^{12}}{210(1+x)^7} \;\ge\; 0 \quad (x \ge 0).$$
Apply Lemma 4.1. $\square$

**Remark 4.7 (The observed pattern).** In all five inequalities the derivative is a rational function whose numerator is a polynomial with **nonnegative coefficients**, with lowest degree $4, 3, 6, 5, 8$ respectively — in each case exactly the order at which the corresponding truncation of (1.1) first fails to match. Positivity is therefore *manifest* rather than the outcome of a case analysis. This is precisely why the method scales to arbitrary order (see Section 10).

---

## 5. Second-order acceleration: the midpoint correction

Define the second-order envelopes
$$U_2(x) = \frac{1}{2x} + \frac{1}{12x^2}, \qquad L_2(x) = \frac{1}{2x} + \frac{1}{12x^2} - \frac{1}{36x^3}.$$

**Lemma 5.1 (Step inequalities).** For every real $m > 0$,
$$L_2(m) - L_2(m+1) \;\le\; \frac{1}{m} - \log\!\left(1+\frac1m\right) \;\le\; U_2(m) - U_2(m+1).$$

*Proof.* Put $x = 1/m \ge 0$. A direct algebraic identity (clear denominators; both sides are rational in $m$) gives
$$\frac{12x + 18x^2 + 4x^3 - x^4}{12(1+x)^2}\Big|_{x = 1/m} \;=\; \frac{1}{m} - \bigl(U_2(m) - U_2(m+1)\bigr),$$
so Theorem 4.2 is *equivalent* to the right-hand inequality. Similarly
$$\frac{36x + 90x^2 + 66x^3 + 12x^4 + x^6}{36(1+x)^3}\Big|_{x = 1/m} \;=\; \frac{1}{m} - \bigl(L_2(m) - L_2(m+1)\bigr),$$
so Theorem 4.3 is equivalent to the left-hand inequality. $\square$

This equivalence — a Padé bound for $\log$ on one side, a telescoping envelope on the other — is the pivot of the whole paper, and recurs verbatim at every order.

**Theorem 5.2 (Midpoint upper error bound).** For every $n \ge 0$,
$$\gamma - A_1(n) \;\le\; \frac{1}{12(n+1)^2}.$$

*Proof.* $U_2$ is nonnegative on $[1,\infty)$ (indeed on $(0,\infty)$), and Lemma 5.1 supplies the step domination of Theorem 3.1. Hence $\gamma - s_n \le U_2(n+1) = \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}$. Subtract $\frac{1}{2(n+1)}$. $\square$

**Theorem 5.3 (Midpoint lower error bound).** For every $n \ge 0$,
$$\frac{1}{12(n+1)^2} - \frac{1}{36(n+1)^3} \;\le\; \gamma - A_1(n).$$

*Proof.* Apply Theorem 3.2 to $L_2$: the smallness hypothesis $L_2(m) \le \frac1m$ reduces after clearing denominators to $18m^2 - 3m + 1 \ge 0$, true for all real $m$; step domination is the left half of Lemma 5.1. Hence $L_2(n+1) \le \gamma - s_n$, and subtracting $\frac{1}{2(n+1)}$ gives the claim. $\square$

**Corollary 5.4 (Strict lower approximant).** For every $n \ge 0$, $A_1(n) < \gamma$.

*Proof.* With $m = n+1 \ge 1$,
$$\frac{1}{12m^2} - \frac{1}{36m^3} = \frac{3m - 1}{36 m^3} > 0. \qquad \square$$

**Corollary 5.5 (Two-sided bound).** For every $n \ge 0$,
$$\bigl|\gamma - A_1(n)\bigr| \;\le\; \frac{1}{12(n+1)^2}.$$

**Corollary 5.6 (Raw sequence).** For every $n \ge 0$,
$$\frac{1}{2(n+1)} \;<\; \gamma - s_n \;\le\; \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}.$$
Thus the uncorrected sequence has error exactly $\Theta(n^{-1})$ with leading coefficient $\tfrac12$, confirming that the midpoint term removes precisely the leading error.

**Theorem 5.7 (Sharpness of $1/12$).**
$$\lim_{n\to\infty} 12(n+1)^2\bigl(\gamma - A_1(n)\bigr) \;=\; 1.$$

*Proof.* Multiplying Theorems 5.2 and 5.3 by $12(n+1)^2 > 0$ gives
$$1 - \frac{1}{3(n+1)} \;\le\; 12(n+1)^2\bigl(\gamma - A_1(n)\bigr) \;\le\; 1,$$
and squeeze. $\square$

**Theorem 5.8 (Monotone lower approximants).** $A_1$ is strictly increasing; consequently $\bigl(A_1(n)\bigr)_{n\ge0}$ is an increasing sequence of certified lower bounds converging to $\gamma$.

*Proof sketch.* By Lemma 2.3 the increment $A_1(n+1) - A_1(n)$ equals
$$\Bigl[\tfrac{1}{m} - \log\bigl(1+\tfrac1m\bigr)\Bigr] - \Bigl[\tfrac{1}{2m} - \tfrac{1}{2(m+1)}\Bigr], \qquad m = n+1.$$
By the left half of Lemma 5.1 this is at least $L_2(m) - L_2(m+1) - \bigl(\tfrac{1}{2m} - \tfrac{1}{2(m+1)}\bigr)$, i.e. at least
$$\Bigl(\tfrac{1}{12m^2} - \tfrac{1}{36m^3}\Bigr) - \Bigl(\tfrac{1}{12(m+1)^2} - \tfrac{1}{36(m+1)^3}\Bigr),$$
and this quantity equals $\dfrac{6m^3 + 6m^2 - 1}{36\,m^3(m+1)^3} > 0$ for $m \ge 1$. $\square$

**Theorem 5.9 (Relative speed-up).**
$$\frac{\gamma - A_1(n)}{\gamma - s_n} \;\longrightarrow\; 0 \qquad (n\to\infty),$$
at rate $O(n^{-1})$: indeed the ratio is at most $\frac{1}{6(n+1)}$ for all $n$.

*Proof.* Numerator $\le \frac{1}{12(n+1)^2}$ by Theorem 5.2, denominator $> \frac{1}{2(n+1)}$ by Corollary 5.6, and both are positive; divide. $\square$

**Numerical remark 5.10 (Tightness at $n = 0$).** At $n = 0$ we have $s_0 = 0$, $A_1(0) = \tfrac12$, and
$$\gamma - A_1(0) = 0.0772156649\ldots, \qquad \frac{1}{12} = 0.0833333\ldots,$$
a ratio of $0.92659$. The bound is therefore *not* an asymptotic statement dressed up with a threshold; it is genuinely tight at the very first index. This is why we state all results for $n \ge 0$ rather than "for sufficiently large $n$": the stronger unconditional form is available and the weaker thresholded form would be strictly less informative.

---

## 6. Fourth-order acceleration and a certified enclosure

Define the fourth- and fifth-order envelopes
$$U_4(x) = \frac{1}{2x} + \frac{1}{12x^2} - \frac{1}{120x^4}, \qquad L_5(x) = \frac{1}{2x} + \frac{1}{12x^2} - \frac{1}{120x^4} + \frac{1}{300x^5}.$$

Note that $U_4$ now plays the role of a *lower* envelope for the tail (it under-estimates $\gamma - s_n$) and $L_5$ an *upper* one; the alternation of signs in (1.1) reverses the roles at each order.

**Lemma 6.1 (Step inequalities, fourth order).** For every real $m \ge 1$,
$$U_4(m) - U_4(m+1) \;\le\; \frac{1}{m} - \log\!\left(1+\frac1m\right) \;\le\; L_5(m) - L_5(m+1).$$

*Proof.* As in Lemma 5.1: substituting $x = 1/m$ into Theorem 4.4 gives exactly the left inequality, and into Theorem 4.5 exactly the right one, after clearing denominators. $\square$

**Lemma 6.2 (Side conditions).** For $m \ge 1$: $U_4(m) \le \frac1m$, and $L_5(m) \ge 0$.

*Proof.* Putting everything over a common denominator, $U_4(m) = \dfrac{60m^3 + 10m^2 - 1}{120\,m^4}$, so
$$\frac1m - U_4(m) = \frac{60m^3 - 10m^2 + 1}{120\,m^4} \;>\; 0 \qquad (m \ge 1),$$
since $60m^3 \ge 10m^2$. Likewise $L_5(m) = \dfrac{300m^4 + 50m^3 - 5m + 2}{600\,m^5}$, and $5m \le 300m^4$ for $m \ge 1$, so the numerator is positive. $\square$

**Theorem 6.3 (Fourth-order bounds).** For every $n \ge 0$, writing $m = n+1$,
$$\frac{1}{120m^4} - \frac{1}{300m^5} \;\le\; A_2(n) - \gamma \;\le\; \frac{1}{120m^4}.$$

*Proof.* The upper bound is Theorem 3.2 applied to $U_4$ (Lemmas 6.1, 6.2): $U_4(m) \le \gamma - s_n$, i.e.
$$\frac{1}{2m} + \frac{1}{12m^2} - \frac{1}{120m^4} \le \gamma - s_n \;\Longleftrightarrow\; A_2(n) - \gamma \le \frac{1}{120m^4}.$$
The lower bound is Theorem 3.1 applied to $L_5$: $\gamma - s_n \le L_5(m)$, i.e. $A_2(n) - \gamma \ge \frac{1}{120m^4} - \frac{1}{300m^5}$. $\square$

**Corollary 6.4 (Strict upper approximant).** For every $n \ge 0$, $\gamma < A_2(n)$.

*Proof.* $\frac{1}{120m^4} - \frac{1}{300m^5} = \frac{5m - 2}{600 m^5} > 0$ for $m \ge 1$. $\square$

**Corollary 6.5.** For every $n \ge 0$, $\bigl|\gamma - A_2(n)\bigr| \le \dfrac{1}{120(n+1)^4}$.

**Theorem 6.6 (Sharpness of $1/120$).**
$$\lim_{n\to\infty} 120(n+1)^4\bigl(A_2(n) - \gamma\bigr) \;=\; 1.$$

*Proof.* Multiplying Theorem 6.3 by $120m^4$ gives $1 - \frac{2}{5m} \le 120m^4(A_2(n)-\gamma) \le 1$; squeeze. $\square$

**Remark 6.7 (Why the fifth-order envelope was needed).** An upper envelope alone yields only a one-sided bound and cannot certify optimality of the constant. The correction term $+\frac{1}{300m^5}$ in $L_5$ was introduced precisely so that the two envelopes differ by $O(m^{-5})$, forcing the squeeze in Theorem 6.6. Attempting to establish sharpness at fourth order without a fifth-order envelope is not possible from the fourth-order data alone.

**Theorem 6.8 (Certified enclosure).** For every $n \ge 0$,
$$A_1(n) \;<\; \gamma \;<\; A_2(n), \qquad A_2(n) - A_1(n) = \frac{1}{12(n+1)^2}.$$
Moreover $A_1$ is strictly increasing and $A_2$ is nonincreasing, so the intervals $\bigl[A_1(n), A_2(n)\bigr]$ are nested.

*Proof.* The two strict inequalities are Corollary 5.4 and Corollary 6.4; the width is immediate from Definition 2.2. Monotonicity of $A_1$ is Theorem 5.8. For $A_2$, the increment $A_2(n+1) - A_2(n)$ equals
$$\Bigl[\tfrac1m - \log\bigl(1+\tfrac1m\bigr)\Bigr] - \bigl(U_2(m) - U_2(m+1)\bigr) \le 0$$
by the right half of Lemma 5.1, where $m = n+1$. $\square$

Thus one obtains, at each index and at essentially no extra cost, a *proved interval* containing $\gamma$, of width $\frac{1}{12(n+1)^2}$, with the sequence of intervals nested and shrinking.

**Corollary 6.9 (Free numerical bounds).** Taking $n = 0$, where $s_0 = 0$:
$$\frac{1}{2} \;<\; \gamma \;<\; \frac{7}{12} = 0.58333\ldots$$

*Proof.* $A_1(0) = \frac12$ and $A_2(0) = \frac12 + \frac{1}{12} = \frac{7}{12}$. $\square$

This costs no summation whatsoever and already improves on the commonly quoted elementary bound $\gamma < \frac23$.

---

## 7. Sixth-order acceleration

Define
$$U_6(x) = \frac{1}{2x} + \frac{1}{12x^2} - \frac{1}{120x^4} + \frac{1}{252x^6}.$$

**Lemma 7.1.** For every real $m \ge 1$:
1. $\dfrac{1}{m} - \log\bigl(1+\tfrac1m\bigr) \le U_6(m) - U_6(m+1)$;
2. $U_6(m) \ge 0$.

*Proof.* (1) Substituting $x = 1/m$ into Theorem 4.6 and clearing denominators yields exactly this inequality; the structured form of $R_6$ in Theorem 4.6 is designed so that the substitution produces the three envelope terms $\frac{1}{12}$, $-\frac{1}{120}$, $\frac{1}{252}$ directly. (2) Clearing denominators,
$$U_6(m) = \frac{1260m^5 + 210m^4 - 21m^2 + 10}{2520\,m^6},$$
and for $m \ge 1$ one has $m^2 \le m^5$, so the numerator is at least $1239m^5 + 210m^4 + 10 > 0$. $\square$

**Theorem 7.2 (Sixth-order bounds).** For every $n \ge 0$,
$$A_3(n) \;\le\; \gamma \qquad\text{and}\qquad \gamma - A_3(n) \;\le\; \frac{1}{252(n+1)^6},$$
hence $\bigl|\gamma - A_3(n)\bigr| \le \frac{1}{252(n+1)^6}$.

*Proof.* The first claim is exactly Theorem 3.2 applied to $U_4$ (Lemmas 6.1, 6.2), which gives $U_4(m) \le \gamma - s_n$, i.e. $A_3(n) \le \gamma$ — note that $A_3(n) = s_n + U_4(m)$. The second is Theorem 3.1 applied to $U_6$ (Lemma 7.1), giving $\gamma - s_n \le U_6(m)$, i.e. $\gamma - A_3(n) \le \frac{1}{252 m^6}$. $\square$

**Theorem 7.3 (Acceleration hierarchy).** For every $n \ge 0$,
$$A_1(n) \;<\; A_3(n) \;\le\; \gamma \;<\; A_2(n).$$

*Proof.* Only the first inequality is new:
$$A_3(n) - A_1(n) = \frac{1}{12m^2} - \frac{1}{120m^4} = \frac{10m^2 - 1}{120 m^4} > 0 \quad (m \ge 1). \qquad \square$$

**Remark 7.4 (Cost of an order).** Theorem 7.2 required exactly one new ingredient beyond Sections 3–6, namely Theorem 4.6. The transfer theorems and all telescoping arguments were reused unchanged. This is the structural payoff of the envelope formulation: **each further order of acceleration costs precisely one single-variable inequality between $\log(1+x)$ and a rational function.**

---

## 8. Algorithms and numerics

### 8.1 The acceleration algorithm

The computational recipe is trivial to implement and its cost is dominated by the harmonic sum.

> **Algorithm (Certified Euler–Mascheroni approximation).**
> *Input:* index $n$, order $K \in \{1,2,3\}$.
> 1. $S \leftarrow 0$; for $k = 1, \ldots, n$: $S \leftarrow S + 1/k$.
> 2. $m \leftarrow n+1$; $\;s \leftarrow S - \log m$.
> 3. $A \leftarrow s + \dfrac{1}{2m}$; if $K \ge 2$: $A \leftarrow A + \dfrac{1}{12m^2}$; if $K \ge 3$: $A \leftarrow A - \dfrac{1}{120m^4}$.
> 4. $E \leftarrow \bigl(\tfrac{1}{12m^2},\ \tfrac{1}{120m^4},\ \tfrac{1}{252m^6}\bigr)_K$.
> *Output:* $A$ and the certificate $|\gamma - A| \le E$.

Step 1 costs $n$ divisions and additions; steps 2–4 cost $O(1)$. The number of terms required for target accuracy $\varepsilon$ is
$$n \approx \tfrac{1}{2\varepsilon} \ \ (\text{no correction}), \qquad
\left(\tfrac{1}{12\varepsilon}\right)^{1/2}, \qquad
\left(\tfrac{1}{120\varepsilon}\right)^{1/4}, \qquad
\left(\tfrac{1}{252\varepsilon}\right)^{1/6}$$
for $K = 0,1,2,3$ respectively. For $\varepsilon = 10^{-12}$ these are $5 \times 10^{11}$, $2.9 \times 10^{5}$, $302$, and $40$. The sixth-order sequence reaches twelve certified digits from forty harmonic terms.

### 8.2 Numerical illustration

Computed in 50-digit arithmetic against $\gamma = 0.5772156649015328606065\ldots$; "ratio" denotes (true error) / (proved bound).

| $n$ | $\gamma - s_n$ | $\gamma - A_1(n)$ | ratio | $A_2(n) - \gamma$ | ratio | $\gamma - A_3(n)$ | ratio |
|---|---|---|---|---|---|---|---|
| $0$ | $5.7722\cdot10^{-1}$ | $7.7216\cdot10^{-2}$ | $0.9266$ | $6.1177\cdot10^{-3}$ | $0.7341$ | $2.2157\cdot10^{-3}$ | $0.5583$ |
| $1$ | $2.7036\cdot10^{-1}$ | $2.0363\cdot10^{-2}$ | $0.9774$ | $4.7049\cdot10^{-4}$ | $0.9033$ | $5.0345\cdot10^{-5}$ | $0.8120$ |
| $4$ | $1.0332\cdot10^{-1}$ | $3.3202\cdot10^{-3}$ | $0.9961$ | $1.3089\cdot10^{-5}$ | $0.9817$ | $2.4400\cdot10^{-7}$ | $0.9608$ |
| $9$ | $5.0833\cdot10^{-2}$ | $8.3250\cdot10^{-4}$ | $0.9990$ | $8.2941\cdot10^{-7}$ | $0.9953$ | $3.9273\cdot10^{-9}$ | $0.9897$ |
| $99$ | $5.0083\cdot10^{-3}$ | $8.3333\cdot10^{-6}$ | $0.99999$ | $8.3329\cdot10^{-11}$ | $0.99995$ | $3.9678\cdot10^{-15}$ | $0.99990$ |
| $999$ | $5.0008\cdot10^{-4}$ | $8.3333\cdot10^{-8}$ | $\approx 1$ | $8.3333\cdot10^{-15}$ | $\approx 1$ | $3.9682\cdot10^{-21}$ | $\approx 1$ |

The corresponding proved bounds are $\frac{1}{12m^2}$, $\frac{1}{120m^4}$, $\frac{1}{252m^6}$ with $m = n+1$; e.g. at $n=9$ they are $8.3333\cdot10^{-4}$, $8.3333\cdot10^{-7}$, $3.9683\cdot10^{-9}$.

Two features are visible. First, every ratio increases monotonically to $1$ from below, as Theorems 5.7 and 6.6 assert, and is already $0.93$ at $n = 0$ for the midpoint correction — the constants are not merely correct but attained. Second, each additional correction term buys two further orders of magnitude per decade of $n$.

### 8.3 Interval arithmetic

Theorem 6.8 makes rigorous interval computation immediate: if $S$ and $\log m$ are computed in interval arithmetic with outward rounding, then
$$\gamma \in \bigl[\,\underline{A_1(n)},\ \overline{A_2(n)}\,\bigr],$$
a genuinely verified enclosure requiring no error analysis beyond the rounding of the inputs. Because the intervals are nested (Theorem 6.8), a computation may be refined incrementally without discarding earlier certificates.

---

## 9. Discussion: where the Bernoulli numbers come from

The constants appearing as sharp error bounds are
$$\frac{1}{2} \ (\text{order } m^{-1}), \qquad \frac{1}{12} \ (m^{-2}), \qquad \frac{1}{120}\ (m^{-4}), \qquad \frac{1}{252}\ (m^{-6}),$$
which are exactly
$$\frac{|B_2|}{2} = \frac{1/6}{2} = \frac{1}{12}, \qquad \frac{|B_4|}{4} = \frac{1/30}{4} = \frac{1}{120}, \qquad \frac{|B_6|}{6} = \frac{1/42}{6} = \frac{1}{252}.$$
That is not coincidence: the Euler–Maclaurin expansion of the digamma function gives
$$\gamma - s_n \;\sim\; \frac{1}{2m} \;+\; \sum_{k\ge1} \frac{(-1)^{k+1}|B_{2k}|}{2k}\, m^{-2k},$$
and our results are the first three truncations of this series, each converted from an asymptotic statement into a two-sided inequality valid at *every* $m \ge 1$.

The conversion mechanism deserves emphasis. In the classical derivation the remainder after $K$ terms is an integral against a periodic Bernoulli polynomial, and bounding it sharply for small $m$ is awkward. In the envelope formulation the remainder never appears. Instead, the statement "the $K$-th truncation is a valid one-sided envelope" is *equivalent*, term by term, to a single inequality
$$\pm\bigl(\log(1+x) - R_K(x)\bigr) \;\ge\; 0 \qquad (x \ge 0)$$
for an explicit rational $R_K$. Empirically — in all five cases established here — the derivative of the difference is
$$\frac{x^{d_K}\,P_K(x)}{c_K\,(1+x)^{d_K + 1}}, \qquad P_K \text{ with nonnegative coefficients},$$
with $d_K$ the order at which $R_K$ first deviates from $\log(1+x)$. The observed numerators were $x^2$, $x^4$, $x^3(12+12x+6x^2+3x^3)$, $5x^6 + 5x^7 + x^8$, and $63x^8 + 126x^9 + 98x^{10} + 35x^{11} + 5x^{12}$.

Two further remarks:

**Odd orders are free.** One might expect the correction $+\frac{1}{12m^2}$ to gain one order, from $m^{-2}$ to $m^{-3}$. It gains two, because the $m^{-3}$ coefficient of the expansion vanishes — a reflection of $B_3 = B_5 = \cdots = 0$. Similarly $A_3$ jumps from $m^{-4}$ to $m^{-6}$. Each Bernoulli correction is therefore "worth double".

**Alternation gives enclosure for free.** Because the signs alternate, consecutive truncations lie on opposite sides of $\gamma$. This is why $A_1 < \gamma < A_2$ and $A_1 < A_3 \le \gamma < A_2$: the enclosure of Theorem 6.8 is not an extra construction but a direct consequence of the alternating structure, made rigorous by the pair of envelope transfer theorems.

**Relation to other accelerations.** The scheme above is a "correction-term" acceleration: it exploits known structure in the error. It is complementary to *extrapolation* methods (Richardson, Romberg, Levin transforms), which infer the structure from data, and to *integral-representation* methods for $\gamma$ (e.g. via Bessel functions) which achieve exponential convergence at higher per-term cost. The distinguishing feature here is not raw speed but *certification*: every claim comes with a two-sided rational bound valid from index zero, and each leading constant is proved optimal.

---

## 10. Open problems and future directions

**Problem 10.1 (Bernoulli envelope tower).** For every $K \ge 1$ define
$$A^{(K)}(n) \;=\; s_n + \frac{1}{2m} + \sum_{k=1}^{K}\frac{(-1)^{k+1}|B_{2k}|}{2k}\,m^{-2k}, \qquad m = n+1.$$
*Conjecture:* for every $K \ge 1$ and every $n \ge 0$,
$$\bigl|\gamma - A^{(K)}(n)\bigr| \;\le\; \frac{|B_{2K+2}|}{(2K+2)\,m^{2K+2}},$$
with the constant attained asymptotically, and with the sign of the error alternating in $K$.

The cases $K = 1, 2, 3$ are Theorems 5.2/5.3, 6.3, 7.2 above. A proof of the general case would follow from the following purely algebraic statement, which is the real content:

**Problem 10.2 (Manifest positivity of the Padé derivatives).** For each $K$, let $R_K(x)$ be the rational function obtained from the $K$-th envelope by the substitution $x = 1/m$. Show that
$$\frac{d}{dx}\Bigl[(-1)^{K}\bigl(\log(1+x) - R_K(x)\bigr)\Bigr] \;=\; \frac{x^{2K+2}\,P_K(x)}{c_K (1+x)^{2K+3}}$$
with $P_K$ a polynomial with **nonnegative** coefficients and $c_K > 0$. Verified for $K \le 3$ (five inequalities in all). A uniform proof would establish the entire tower at once, and would give an Euler–Maclaurin theory for this problem with no integral remainder anywhere.

**Problem 10.3 (Optimal truncation).** Since the expansion (1.1) is divergent, for each fixed $m$ there is an optimal $K = K^\ast(m)$ minimising the bound $\frac{|B_{2K+2}|}{(2K+2)m^{2K+2}}$. Using $|B_{2k}| \sim \frac{2(2k)!}{(2\pi)^{2k}}$ one predicts $K^\ast(m) \approx \pi m$ and a minimal error of size $e^{-2\pi m}$. Making this precise *within the envelope framework* — i.e. with unconditional inequalities rather than asymptotics — would yield a certified exponentially convergent algorithm for $\gamma$.

**Problem 10.4 (Other constants).** The method uses nothing specific to $1/x$: it needs a monotone convex summand, the telescoping identity, and a family of rational one-sided approximants to the associated transcendental function. Natural targets are the Stieltjes constants $\gamma_k$ (replace $1/m$ by $\frac{\log^k m}{m}$), the Glaisher–Kinkelin constant, and the constants in Mertens' theorems.

**Problem 10.5 (Automatic envelope synthesis).** Given a target order $r$, the envelope is determined; the remaining task is to certify a rational inequality. Since the certifying object is always "numerator polynomial has nonnegative coefficients", the search is a linear-programming / sum-of-squares problem over a finite-dimensional space. An automated pipeline producing, for any $r$, both the envelope and its positivity certificate seems within reach and would make the whole tower effective.

**Problem 10.6 (Two-sided towers).** At each order we used an upper envelope of order $r$ and a lower envelope of order $r+1$ to certify sharpness. Is there a canonical *pair* of envelopes of the same order $r$ whose gap is $O(m^{-(r+1)})$, avoiding the ad hoc correction terms $-\frac{1}{36m^3}$ and $+\frac{1}{300m^5}$?

---

## 11. Conclusion

The distance from the harmonic staircase to the logarithm is a sum of slivers whose total is $\gamma - s_n$. Approximating each sliver by a rectangle costs a bias of order $m^{-1}$; correcting for the bias by a half-step reduces it to order $m^{-2}$; and every subsequent Bernoulli correction reduces it by two further orders.

The contribution of this work is to make each of these statements an unconditional, two-sided, sharply-constanted inequality holding from index zero, and to isolate the mechanism so that the analytic content of every order is a single elementary inequality for $\log(1+x)$. Concretely:

- $\displaystyle \frac{1}{12m^2} - \frac{1}{36m^3} \le \gamma - A_1(n) \le \frac{1}{12m^2}$, sharp;
- $\displaystyle \frac{1}{120m^4} - \frac{1}{300m^5} \le A_2(n) - \gamma \le \frac{1}{120m^4}$, sharp;
- $\displaystyle 0 \le \gamma - A_3(n) \le \frac{1}{252m^6}$;
- $A_1(n) < A_3(n) \le \gamma < A_2(n)$, with $A_2(n) - A_1(n) = \frac{1}{12m^2}$, $A_1$ increasing, $A_2$ decreasing;
- $\frac12 < \gamma < \frac{7}{12}$ from the case $n = 0$ alone.

The framework is order-agnostic. Its natural completion is the full Bernoulli envelope tower of Problem 10.1, whose only obstacle is a uniform positivity statement about a family of explicit polynomials.
