# Sharp Two-Sided Summand Asymptotics for the Euler–Mascheroni Constant, with a Certified Enclosure and a Small-Denominator Obstruction

**Author:** Aristotle
**Date:** 2026-08-08

---

## Abstract

We develop a complete, effective two-sided theory of the classical approximants $g_n = H_n - \log(n+1)$ to the Euler–Mascheroni constant $\gamma$, based on a single elementary device: *derivative certificates* for the logarithmic ratio $\Lambda(z) = \log\frac{1+z}{1-z}$ on $[0,1)$, evaluated at $z = \frac{1}{2m+1}$.

Four groups of results follow. First, a purely rational squeeze of every summand of the associated series: writing $t_k = g_{k+1} - g_k$, we prove $\frac{1}{2(k+2)^2} \le \frac{1}{2(k+1)(k+2)} \le t_k \le \frac{1}{2(k+1)^2}$. Second, a sharp two-sided tail estimate, $\frac{1}{2(n+1)} + \frac{1}{14(n+1)^2} \le \gamma - g_n \le \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}$, valid for all $n \ge 0$, together with the clean consequence $0 < \gamma - g_n \le \frac{1}{2n}$ for $n \ge 1$; the corresponding midpoint-corrected sequence $a_n = g_n + \frac{1}{2(n+1)}$ therefore satisfies the *two-sided* inverse-square bound $\frac{1}{14(n+1)^2} \le \gamma - a_n \le \frac{1}{12(n+1)^2}$, so its error is exactly of order $n^{-2}$. Third, evaluating the tail estimate at $n = 15$, where $g_{15} = \frac{1195757}{360360} - 4\log 2$ is rational up to a multiple of $\log 2$, produces the certified enclosure $0.5771692 < \gamma < 0.5772158$ of width $4.66\cdot 10^{-5}$; combined with a finite integer check this yields a small-denominator obstruction: $\gamma \ne p/q$ for every integer $p$ and every $1 \le q \le 148$, with the threshold $148$ optimal for this enclosure since $\frac{86}{149}$ lies inside the interval. Fourth, we record an information-theoretic reading of the whole construction: $t_k$ is the Kullback–Leibler divergence between consecutive exponential laws, the symmetrized divergence satisfies the rational identity $D(a\|b) + D(b\|a) = \frac{(a-b)^2}{ab}$, and this yields an exact summability criterion for chains of positive rates with bounded ratios. Finally, we state the Apéry-style linear-forms criterion for irrationality and prove that the midpoint-accelerated family provably *cannot* satisfy it, since $(n+1)^2(\gamma - a_n) \in [\frac1{14}, \frac1{12}]$ never tends to zero.

**Keywords:** Euler–Mascheroni constant, harmonic numbers, Euler–Maclaurin correction, series acceleration, certified enclosure, irrationality measures, Kullback–Leibler divergence, Jeffreys divergence.

---

## 1. Introduction

The Euler–Mascheroni constant

$$\gamma \;=\; \lim_{n\to\infty}\big(H_n - \log n\big), \qquad H_n = \sum_{k=1}^{n}\frac1k,$$

is arguably the most conspicuous constant of classical analysis whose arithmetic nature is entirely unknown. It is not known to be irrational, let alone transcendental. In contrast to $\pi$ and $e$ — for which irrationality proofs are classical and transcendence proofs are nineteenth century — nothing beyond finitely checkable exclusions is available for $\gamma$.

This state of affairs makes *effective* estimates valuable in a way that purely asymptotic estimates are not. An asymptotic expansion of $\gamma - H_n + \log n$ with unspecified constants tells us nothing about which rationals $\gamma$ can be. An estimate with explicit rational constants, valid for a specific $n$, converts directly into an interval of rationals containing $\gamma$, and thereby into arithmetic exclusions.

The purpose of this paper is to carry out that conversion from first principles, in a way in which every constant is explicit and every inequality is certified by an algebraic identity rather than by an asymptotic argument. The engine is deliberately elementary: all bounds descend from three inequalities for the function $\Lambda(z) = \log\frac{1+z}{1-z}$ on $[0,1)$, each proved by exhibiting the derivative of a difference as a manifestly nonnegative rational function.

### 1.1 Organization

Section 2 fixes notation and gives the information-theoretic reading of the summands. Section 3 develops the derivative certificates and their evaluation at $z = \frac{1}{2m+1}$. Section 4 proves the rational squeeze of the summands. Section 5 sums the squeeze against telescoping comparison series to obtain the two-sided tail estimate, and Section 6 derives the midpoint acceleration and its matching lower bound. Section 7 produces the certified enclosure at $n = 15$ and Section 8 the small-denominator obstruction. Section 9 develops the symmetrized-divergence theory and its summability criterion, and Section 10 states the linear-forms criterion and the concrete obstruction. Section 11 discusses algorithms and numerics; Section 12 discusses limitations and future directions.

---

## 2. Setting and the information-theoretic reading

### 2.1 Approximants and summands

**Definition 2.1 (approximants).** For $n \in \mathbb{N}$ put
$$g_n \;=\; H_n - \log(n+1).$$

The shift from $\log n$ to $\log(n+1)$ is a convenience: it makes $g_0 = 0$ and makes the sequence increasing, so that $g_n < \gamma$ for all $n$, and $g_n \to \gamma$.

**Definition 2.2 (summands).** For $k \in \mathbb{N}$ put
$$t_k \;=\; \frac{1}{k+1} - \log\frac{k+2}{k+1}.$$

**Lemma 2.3 (telescoping).** $\displaystyle g_n = \sum_{k=0}^{n-1} t_k$ and $\displaystyle \gamma = \sum_{k=0}^{\infty} t_k$, all $t_k > 0$.

*Proof sketch.* $g_{k+1} - g_k = \frac{1}{k+1} - \big(\log(k+2)-\log(k+1)\big) = t_k$, and $g_0 = 0$. Positivity is $\log(1+x) < x$ at $x = \frac{1}{k+1}$. Convergence of $g_n$ to $\gamma$ is the classical definition (the replacement of $\log n$ by $\log(n+1)$ changes nothing in the limit since $\log\frac{n+1}{n}\to0$). $\square$

Consequently, for every $n$,
$$\gamma - g_n \;=\; \sum_{i=0}^{\infty} t_{i+n}. \tag{2.1}$$
This identity — the remainder equals the tail — is the pivot of the entire paper: every bound on $\gamma - g_n$ will be obtained by bounding the tail termwise against a *telescoping* comparison series whose sum is available in closed form.

### 2.2 Divergence between exponential laws

**Definition 2.4.** For $a, b > 0$, the Kullback–Leibler divergence of the exponential law of rate $a$ from that of rate $b$ is
$$D(a\|b) \;=\; \int_0^\infty a e^{-ax}\,\log\frac{a e^{-ax}}{b e^{-bx}}\,dx \;=\; \log\frac{a}{b} + \frac{b}{a} - 1 .$$

The elementary inequality $\log u \le u - 1$ shows $D(a\|b) \ge 0$ with equality iff $a = b$.

**Proposition 2.5 (the summands are divergences).** For every $k \in \mathbb{N}$,
$$t_k \;=\; D(k+1 \,\|\, k+2), \qquad\text{hence}\qquad \gamma \;=\; \sum_{k=0}^{\infty} D\big(\mathrm{Exp}(k+1)\,\big\|\,\mathrm{Exp}(k+2)\big).$$

*Proof.* $D(k+1\|k+2) = \log\frac{k+1}{k+2} + \frac{k+2}{k+1} - 1 = \frac{1}{k+1} - \log\frac{k+2}{k+1} = t_k$. $\square$

Thus $\gamma$ is the total information accumulated along the chain of exponential waiting-time laws with rates $1, 2, 3, \dots$. Beyond its intrinsic appeal, this reading motivates Section 9, where the symmetrized version of the same quantity turns out to be purely rational.

---

## 3. Derivative certificates for the logarithmic ratio

**Definition 3.1.** For $|z| < 1$ set
$$\Lambda(z) \;=\; \log\frac{1+z}{1-z} \;=\; \log(1+z) - \log(1-z) \;=\; 2\operatorname{artanh} z .$$

**Lemma 3.2.** $\Lambda$ is differentiable on $(-1,1)$ with $\Lambda'(z) = \dfrac{2}{1-z^2}$.

*Proof.* $\frac{1}{1+z} + \frac{1}{1-z} = \frac{2}{1-z^2}$. $\square$

The point of Lemma 3.2 is that $\Lambda'$ is *rational*. Hence for any rational candidate $R$ with $R(0) = 0$, the inequality $R \le \Lambda$ (or $\Lambda \le R$) on $[0,1)$ follows from the sign of the rational function $\Lambda' - R'$ (resp. $R' - \Lambda'$), which is a matter of polynomial algebra. We call the explicit nonnegative rational function the *certificate*.

**Theorem 3.3 (three certificates).** For all $0 \le z < 1$:

1. **(Cubic lower bound)** $\quad 2z + \dfrac{2z^3}{3} \;\le\; \Lambda(z)$, with certificate
   $$\Lambda'(z) - \big(2 + 2z^2\big) = \frac{2 - (2+2z^2)(1-z^2)}{1-z^2} = \frac{2z^4}{1-z^2} \;\ge\; 0 .$$
2. **(Crude upper bound)** $\quad \Lambda(z) \;\le\; \dfrac{2z}{1-z^2}$, with certificate
   $$\frac{d}{dz}\!\left(\frac{2z}{1-z^2}\right) - \Lambda'(z) = \frac{2+2z^2}{(1-z^2)^2} - \frac{2}{1-z^2} = \frac{4z^2}{(1-z^2)^2} \;\ge\; 0 .$$
3. **(Padé-type upper bound)** $\quad \Lambda(z) \;\le\; 2z + \dfrac{2z^3}{3} + \dfrac{2z^5}{5(1-z^2)}$, with certificate
   $$\frac{d}{dz}\!\left(2z + \frac{2z^3}{3} + \frac{2z^5}{5(1-z^2)}\right) - \Lambda'(z) = \frac{4z^6}{5(1-z^2)^2} \;\ge\; 0 .$$

*Proof sketch.* In each case both sides vanish at $z = 0$ and the displayed certificate is the derivative of the difference; nonnegativity of the certificate on $[0,1)$ is immediate. The mean value theorem (equivalently, monotonicity of the difference) concludes. $\square$

**Corollary 3.4 (rational sandwich for $\log\frac{m+1}{m}$).** Let $m \ge 1$ be real and put $z = \frac{1}{2m+1} \in (0,1)$, so that $\frac{1+z}{1-z} = \frac{m+1}{m}$ and $1 - z^2 = \frac{4m(m+1)}{(2m+1)^2}$. Then

$$\frac{2}{2m+1} + \frac{2}{3(2m+1)^3} \;\le\; \log\frac{m+1}{m} \;\le\; \frac{2m+1}{2m(m+1)}, \tag{3.1}$$

and moreover the sharper upper bound

$$\log\frac{m+1}{m} \;\le\; \frac{2}{2m+1} + \frac{2}{3(2m+1)^3} + \frac{1}{10\,m(m+1)(2m+1)^3}. \tag{3.2}$$

*Proof.* Substitute $z = \frac{1}{2m+1}$ into Theorem 3.3. For the crude upper bound, $\frac{2z}{1-z^2} = \frac{2}{2m+1}\cdot\frac{(2m+1)^2}{4m(m+1)} = \frac{2m+1}{2m(m+1)}$. For the Padé bound, $\frac{2z^5}{5(1-z^2)} = \frac{2}{5(2m+1)^5}\cdot\frac{(2m+1)^2}{4m(m+1)} = \frac{1}{10\,m(m+1)(2m+1)^3}$. $\square$

Every subsequent estimate is (3.1) or (3.2) inserted into $t_k = \frac1m - \log\frac{m+1}{m}$ with $m = k+1$, followed by an algebraic identity establishing the resulting rational inequality.

---

## 4. A purely rational squeeze of the summands

**Theorem 4.1 (trapezoid lower bound).** For every $k \in \mathbb{N}$,
$$\frac{1}{2(k+1)(k+2)} \;\le\; t_k .$$

*Proof.* Write $m = k+1 \ge 1$, so $t_k = \frac1m - \log\frac{m+1}{m}$. By the upper half of (3.1),
$$t_k \;\ge\; \frac1m - \frac{2m+1}{2m(m+1)} \;=\; \frac{2(m+1) - (2m+1)}{2m(m+1)} \;=\; \frac{1}{2m(m+1)} = \frac{1}{2(k+1)(k+2)}. \qquad\square$$

**Corollary 4.2 (weak rational lower bound).** $\displaystyle \frac{1}{2(k+2)^2} \le t_k$ for every $k$, since $(k+1)(k+2) \le (k+2)^2$.

**Theorem 4.3 (rational upper bound).** For every $k \in \mathbb{N}$,
$$t_k \;\le\; \frac{1}{2(k+1)^2}.$$

*Proof.* With $m = k+1$, the lower half of (3.1) gives
$$t_k \;\le\; \frac1m - \frac{2}{2m+1} - \frac{2}{3(2m+1)^3}.$$
It therefore suffices to verify the rational inequality
$$\frac{1}{2m^2} - \left(\frac1m - \frac{2}{2m+1} - \frac{2}{3(2m+1)^3}\right) = \frac{16m^2 + 12m + 3}{6m^2(2m+1)^3} \;\ge\; 0,$$
which is clear for $m \ge 1$ since numerator and denominator are positive. $\square$

Combining, we obtain the announced squeeze.

**Theorem 4.4 (rational squeeze).** For every $k \in \mathbb{N}$,
$$\frac{1}{2(k+2)^2} \;\le\; \frac{1}{2(k+1)(k+2)} \;\le\; t_k \;\le\; \frac{1}{2(k+1)^2} .$$

Both outer bounds are $\tfrac12 k^{-2}(1+O(k^{-1}))$, so the squeeze is asymptotically tight to first order; the true expansion is $t_k = \frac{1}{2(k+1)^2} - \frac{1}{3(k+1)^3} + O(k^{-4})$.

---

## 5. Telescoping comparison and the two-sided tail estimate

The tail identity (2.1) reduces every remainder estimate to a termwise comparison, provided the comparison series telescopes.

**Lemma 5.1 (telescoping sums).** If $u : \mathbb{N} \to \mathbb{R}$ is nonincreasing with $u_k \to 0$, then $\sum_{i\ge0}(u_i - u_{i+1})$ converges to $u_0$.

**Definition 5.2 (comparison profile).** For $c > 0$ and $m \ge 1$ set
$$F_c(m) \;=\; \frac{1}{2m} + \frac{1}{c\,m^2}.$$

By Lemma 5.1, for each $n$,
$$\sum_{i=0}^{\infty}\Big( F_c(i+n+1) - F_c(i+n+2) \Big) \;=\; F_c(n+1) \;=\; \frac{1}{2(n+1)} + \frac{1}{c(n+1)^2}, \tag{5.1}$$
and similarly $\sum_{i\ge0}\big(\frac{1}{2(i+n+1)} - \frac{1}{2(i+n+2)}\big) = \frac{1}{2(n+1)}$.

The whole game is thus to compare $t_k$ with the increments $F_c(m) - F_c(m+1)$, $m = k+1$.

**Theorem 5.3 (upper increment comparison, $c = 12$).** For every $k \in \mathbb{N}$, with $m = k+1$,
$$t_k \;\le\; F_{12}(m) - F_{12}(m+1) \;=\; \left(\frac{1}{2m}+\frac{1}{12m^2}\right) - \left(\frac{1}{2(m+1)}+\frac{1}{12(m+1)^2}\right).$$

*Proof sketch.* Bound $t_k \le \frac1m - \frac{2}{2m+1} - \frac{2}{3(2m+1)^3}$ using (3.1); then the difference between the right-hand side above and this bound is, after clearing denominators, a rational function with positive denominator $\;m^2(m+1)^2(2m+1)^3\;$ (up to a positive constant) and a numerator that is a polynomial in $m$ with nonnegative value for $m \ge 1$. $\square$

**Theorem 5.4 (lower increment comparison, $c = 14$).** For every $k \in \mathbb{N}$, with $m = k+1$,
$$F_{14}(m) - F_{14}(m+1) \;\le\; t_k .$$

*Proof sketch.* Here the crude upper bound in (3.1) is too weak and the Padé bound (3.2) is required: $t_k \ge \frac1m - \frac{2}{2m+1} - \frac{2}{3(2m+1)^3} - \frac{1}{10m(m+1)(2m+1)^3}$. Subtracting the increment yields the exact identity
$$\text{(difference)} \;=\; \frac{40m^4 + 80m^3 + 4m^2 - 36m - 15}{210\,m^2(m+1)^2(2m+1)^3},$$
whose numerator is nonnegative for $m \ge 1$ (it equals $73$ at $m=1$ and its derivative is positive there onward). $\square$

The choice $c = 14$ in Theorem 5.4 is the largest of the convenient integer denominators for which the numerator stays nonnegative from $m = 1$; the true asymptotic constant is $\frac{1}{12}$, matched exactly by Theorem 5.3.

**Theorem 5.5 (two-sided tail estimate).** For every $n \in \mathbb{N}$,
$$\frac{1}{2(n+1)} + \frac{1}{14(n+1)^2} \;\le\; \gamma - g_n \;\le\; \frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}.$$

*Proof.* Apply (2.1); compare termwise with the telescoping series of Theorems 5.3 and 5.4; sum using (5.1). $\square$

**Corollary 5.6 (positivity and the $\frac{1}{2n}$ bound).** $\gamma - g_n > 0$ for all $n$, and for all $n \ge 1$,
$$0 \;<\; \gamma - g_n \;\le\; \frac{1}{2n}.$$

*Proof.* Positivity is Theorem 5.5 (or Lemma 2.3). For the upper bound it suffices to note the rational identity
$$\frac{1}{2n} - \left(\frac{1}{2(n+1)} + \frac{1}{12(n+1)^2}\right) = \frac{5n+6}{12\,n\,(n+1)^2} \;>\; 0 . \qquad\square$$

---

## 6. Midpoint acceleration and its exact order

**Definition 6.1 (accelerated approximants).**
$$a_n \;=\; g_n + \frac{1}{2(n+1)} \;=\; H_n - \log(n+1) + \frac{1}{2(n+1)} .$$

Theorem 5.5 immediately yields both halves of the following.

**Theorem 6.2 (the acceleration error is exactly $\Theta(n^{-2})$).** For every $n \in \mathbb{N}$,
$$\frac{1}{14(n+1)^2} \;\le\; \gamma - a_n \;\le\; \frac{1}{12(n+1)^2}.$$
In particular $a_n < \gamma$ for every $n$, $\;|\gamma - a_n| \le \frac{1}{12(n+1)^2}$ with no threshold on $n$, and $(n+1)^2(\gamma - a_n) \in [\frac1{14},\frac1{12}]$ for all $n$.

Two remarks. First, the upper constant $\frac1{12}$ is optimal: numerically $(n+1)^2(\gamma - a_n) \to \frac{1}{12} = 0.08333\ldots$, in agreement with the Euler–Maclaurin expansion
$$\gamma - H_n + \log n \;=\; -\frac{1}{2n} + \frac{1}{12n^2} - \frac{1}{120n^4} + \cdots$$
whose first correction coefficient is precisely $\frac{1}{12}$. Second, the *lower* bound is not merely cosmetic: it is what rules out the accelerated family as a source of Apéry-style linear forms (Section 10). A one-sided estimate would leave open the possibility of superpolynomial accuracy along a subsequence; the two-sided estimate closes it.

Numerically, at $n = 1000$: $\gamma - g_n \approx 4.996\cdot10^{-4}$ while $\gamma - a_n \approx 8.32\cdot 10^{-8}$, and $(n+1)^2(\gamma - a_n) = 0.0833333$.

---

## 7. A certified enclosure

Theorem 5.5 is effective, but $g_n$ contains a transcendental term $\log(n+1)$. To extract a rational interval one needs an external high-precision enclosure of that logarithm. The clean choice is to take $n+1$ a power of $2$, so that only $\log 2$ is needed.

**Lemma 7.1.** $\;H_{15} = \dfrac{1195757}{360360}$ and $\;\log 16 = 4\log 2$.

*Proof.* Direct computation of the sum of $\frac1k$, $1 \le k \le 15$, over the common denominator $360360 = \mathrm{lcm}(1,\dots,15)$; and $\log 2^4 = 4\log 2$. $\square$

**Proposition 7.2.** $\;g_{15} \;=\; \dfrac{1195757}{360360} - 4\log 2 \;=\; 0.5456402709\ldots$

**Theorem 7.3 (certified enclosure).**
$$0.5771692 \;<\; \gamma \;<\; 0.5772158 .$$

*Proof.* Use the classical decimal bounds $0.6931471803 < \log 2 < 0.6931471808$. From Theorem 5.5 at $n = 15$ (so $n+1 = 16$):
$$\gamma \;\ge\; g_{15} + \frac{1}{32} + \frac{1}{14\cdot 256} \;>\; \frac{1195757}{360360} - 4(0.6931471808) + \frac{1}{32} + \frac{1}{3584} \;=\; 0.577169287\ldots$$
$$\gamma \;\le\; g_{15} + \frac{1}{32} + \frac{1}{12\cdot 256} \;<\; \frac{1195757}{360360} - 4(0.6931471803) + \frac{1}{32} + \frac{1}{3072} \;=\; 0.577215792\ldots$$
Rounding outward gives the stated decimal bounds. $\square$

The interval has width $4.66\cdot 10^{-5}$. Its asymmetry is informative: the true value $\gamma = 0.5772156649\ldots$ lies within $1.4\cdot10^{-7}$ of the upper endpoint but $4.6\cdot 10^{-5}$ above the lower one, reflecting the fact that $\frac{1}{12}$ in the upper tail bound is the exact asymptotic coefficient while $\frac{1}{14}$ in the lower bound is a certified but non-optimal proxy.

**Corollary 7.4.** $0 < \gamma < 1$.

---

## 8. A small-denominator obstruction

Irrationality of $\gamma$ is equivalent to the infinite family of statements "$\gamma \ne p/q$" over all $q \ge 1$. Each such statement is decidable given a sufficiently tight enclosure. Theorem 7.3 decides all $q \le 148$.

**Lemma 8.1 (finite integer certificate).** Write $L = 5771692$, $U = 5772158$, $N = 10^7$. For every integer $q$ with $1 \le q \le 148$,
$$U q \;\le\; N\left(\left\lfloor \frac{Lq}{N}\right\rfloor + 1\right).$$
Equivalently, the open interval $(Lq,\, Uq)$ contains no multiple of $N$.

*Proof.* A finite check over the $148$ values of $q$. Intuitively, the window $(Lq, Uq)$ has length $466q \le 68968 \ll 10^7$, and one verifies that for each $q\le 148$ it fails to straddle a multiple of $10^7$. $\square$

**Theorem 8.2 (small-denominator obstruction).** For every integer $p$ and every integer $q$ with $1 \le q \le 148$,
$$\gamma \;\ne\; \frac{p}{q}.$$

*Proof.* Suppose $\gamma = p/q$ with $q \ge 1$. Theorem 7.3 gives $\frac{L}{N} < \frac pq < \frac UN$, hence, clearing denominators (all positive),
$$L q \;<\; N p \;<\; U q .$$
Since $L, q > 0$ the left inequality forces $p > 0$. Thus $Np$ is a multiple of $N$ lying strictly inside $(Lq, Uq)$, contradicting Lemma 8.1 whenever $q \le 148$. $\square$

**Corollary 8.3 (rational form).** No rational number $r$ with reduced denominator $\operatorname{den}(r) \le 148$ satisfies $r = \gamma$.

*Proof.* Write $r = \operatorname{num}(r)/\operatorname{den}(r)$ and apply Theorem 8.2. $\square$

**Proposition 8.4 (optimality of the threshold).** The threshold $148$ cannot be improved using the enclosure of Theorem 7.3, because
$$\frac{86}{149} = 0.5771812\ldots \in (0.5771692,\; 0.5772158).$$

Thus $q = 149$ is the first denominator that survives; excluding it requires a strictly narrower enclosure. The scaling is easy to predict. The number of fractions with denominator at most $Q$ lying in an interval of width $w$ is on average about $\frac{3}{\pi^2} w Q^2$, so the first survivor should appear near $Q \approx w^{-1/2}$. Here $w = 4.66\cdot10^{-5}$ and $w^{-1/2} = 146.5$, in excellent agreement with the observed threshold $148$. Conversely, distinct fractions with denominators at most $Q$ differ by at least $Q^{-2}$, so an enclosure of width below $Q^{-2}$ can meet at most one such fraction, and a single additional check settles all denominators up to $Q$. By Theorem 5.5, an enclosure of width $\approx Q^{-2}$ requires roughly $n \approx Q$ terms of the harmonic series, together with $\log(n+1)$ known to matching precision.

---

## 9. Symmetrized divergence: a rational identity and a summability criterion

The information-theoretic reading of Section 2 has a second, independent payoff.

**Definition 9.1.** For $a, b > 0$, the *symmetrized (Jeffreys) divergence* is
$$J(a,b) \;=\; D(a\|b) + D(b\|a).$$

**Theorem 9.2 (symmetrization identity).** For all $a, b > 0$,
$$J(a,b) \;=\; \frac{a}{b} + \frac{b}{a} - 2 \;=\; \frac{(a-b)^2}{ab} \;=\; \frac{(\rho - 1)^2}{\rho}, \qquad \rho = \frac ba .$$

*Proof.* $J(a,b) = \big(\log\frac ab + \frac ba - 1\big) + \big(\log\frac ba + \frac ab - 1\big)$; the logarithms cancel, leaving $\frac ab + \frac ba - 2 = \frac{(a-b)^2}{ab}$. Dividing numerator and denominator by $a^2$ gives the ratio form. $\square$

All transcendence disappears: the symmetrized information between two exponential laws is a rational function of the ratio of their rates. This makes the following criterion sharp and elementary.

**Theorem 9.3 (summability criterion for chains of rates).** Let $(r_n)_{n\ge0}$ be positive reals whose successive ratios $\rho_n = r_{n+1}/r_n$ satisfy $c \le \rho_n \le C$ for constants $0 < c \le C$. Then
$$\sum_{n\ge0} J(r_n, r_{n+1}) < \infty \quad\Longleftrightarrow\quad \sum_{n\ge0} (\rho_n - 1)^2 < \infty .$$

*Proof.* By Theorem 9.2, $J(r_n, r_{n+1}) = \frac{(\rho_n-1)^2}{\rho_n}$. Two elementary comparisons finish the argument: for $0 < \rho \le C$, $(\rho - 1)^2 \le C\cdot\frac{(\rho-1)^2}{\rho}$; and for $\rho \ge c > 0$, $\frac{(\rho-1)^2}{\rho} \le \frac1c (\rho-1)^2$. Each is the statement that a certain nonnegative expression, namely $(C-\rho)(\rho-1)^2/\rho$ resp. $(\rho - c)(\rho-1)^2/(c\rho)$, is nonnegative. Comparison of nonnegative series concludes. $\square$

So the finiteness of accumulated symmetrized information is *exactly* a statement about the rate at which consecutive ratios approach $1$ — nothing else about the chain matters, provided the ratios stay in a fixed band.

**Example 9.4 (arithmetic chain: convergent, sum exactly $1$).** For $r_n = n+1$,
$$\sum_{n\ge0} J(n+1, n+2) \;=\; \sum_{n\ge0}\frac{1}{(n+1)(n+2)} \;=\; \sum_{n\ge0}\left(\frac{1}{n+1}-\frac{1}{n+2}\right) \;=\; 1 .$$

*Proof.* $J(n+1,n+2) = \frac{((n+1)-(n+2))^2}{(n+1)(n+2)} = \frac{1}{(n+1)(n+2)}$; telescope by Lemma 5.1. $\square$

**Example 9.5 (geometric chain: always divergent).** For $r_n = r^n$ with $r > 0$, $r \ne 1$, every term equals the same positive constant:
$$J(r^n, r^{n+1}) \;=\; \frac{(r^n - r^{n+1})^2}{r^n\cdot r^{n+1}} \;=\; \frac{(1-r)^2}{r},$$
so the series diverges for every such $r$.

*Proof.* The displayed computation, plus: a convergent series has terms tending to $0$, forcing $(1-r)^2 = 0$, i.e. $r = 1$. $\square$

The contrast is structural. Additive (arithmetic) chains have ratios $\rho_n = 1 + \frac1n \to 1$ at rate $n^{-1}$, so $\sum (\rho_n-1)^2 < \infty$; multiplicative chains have $\rho_n \equiv r \ne 1$ bounded away from $1$, so the criterion fails at once. Euler's constant, being the accumulated (asymmetric) information of an arithmetic chain, sits precisely on the convergent side, and Example 9.4 is the symmetrized shadow of the identity $\gamma = \sum_k t_k$.

---

## 10. Linear forms: the Apéry-style criterion and a concrete obstruction

**Theorem 10.1 (linear-forms criterion).** Let $x \in \mathbb{R}$. Suppose there exist integer sequences $(A_n), (B_n)$ with
$$A_n + B_n x \ne 0 \ \ \text{for all } n, \qquad \big|A_n + B_n x\big| \longrightarrow 0 .$$
Then $x$ is irrational.

*Proof.* Suppose $x = p/q$ with $q \ge 1$. Then $A_n + B_n x = \frac{A_n q + B_n p}{q}$, whose numerator is an integer; it is nonzero by hypothesis, so $|A_n q + B_n p| \ge 1$ and hence $|A_n + B_n x| \ge \frac{1}{q}$ for every $n$. This contradicts convergence to $0$. $\square$

**Corollary 10.2.** If there are integer sequences $(A_n), (B_n)$, a constant $C$, and $0 \le \varrho < 1$ with $A_n + B_n\gamma \ne 0$ and $|A_n + B_n\gamma| \le C\varrho^n$ for all $n$, then $\gamma$ is irrational.

*Proof.* $C\varrho^n \to 0$; squeeze and apply Theorem 10.1. $\square$

Corollary 10.2 is the exact target of an Apéry-style attack, and it makes clear what a candidate family of approximants must deliver: *geometric*, not polynomial, accuracy. The two-sided Theorem 6.2 shows the midpoint-accelerated family fails this test decisively.

**Theorem 10.3 (concrete obstruction).** The sequence $\big((n+1)^2(\gamma - a_n)\big)_{n\ge0}$ does not tend to $0$; it remains in $[\frac1{14}, \frac1{12}]$ for every $n$.

*Proof.* Immediate from Theorem 6.2. If the sequence tended to $0$, some term would be $< \frac{1}{14}$, contradicting the lower bound. $\square$

Consequently no rescaling of the midpoint-accelerated approximants can produce linear forms with subpolynomial — let alone geometric — decay: their error is pinned at order exactly $n^{-2}$. Any successful irrationality proof for $\gamma$ must use approximants of a structurally different nature. This is a negative result, but a precise one: it removes an obvious candidate family from consideration once and for all, and it does so by exhibiting an explicit lower bound rather than by an asymptotic heuristic.

---

## 11. Algorithms and numerics

Three computational procedures are implicit in the results.

**(A) Certified evaluation of $\gamma$ to prescribed accuracy.** Given a target width $w$, choose $n$ with $\frac{1}{12(n+1)^2} - \frac{1}{14(n+1)^2} = \frac{1}{84(n+1)^2} \le w/2$ (so $n \approx \sqrt{1/(42w)}$), compute $H_n$ exactly as a rational, obtain an enclosure of $\log(n+1)$ of width $\le w/2$, and output
$$\Big[\,H_n - \overline{\log(n+1)} + \tfrac{1}{2(n+1)} + \tfrac{1}{14(n+1)^2},\;\; H_n - \underline{\log(n+1)} + \tfrac{1}{2(n+1)} + \tfrac{1}{12(n+1)^2}\,\Big].$$
Cost: $O(n)$ rational additions (or $O(n)$ high-precision floating additions) plus one logarithm. The choice $n+1 = 2^j$ makes the logarithm a multiple of $\log 2$.

**(B) Denominator sieve.** Given a certified enclosure $(L/N, U/N)$, determine the largest $Q$ such that no rational of denominator $\le Q$ lies inside. Loop $q = 1, 2, \dots$; compute $p = \lfloor Lq/N\rfloor + 1$, the least integer with $p > Lq/N$; if $Np < Uq$, the fraction $p/q$ lies inside and $Q = q - 1$. Cost: $O(Q)$ integer operations, exact. For $(L,U,N) = (5771692, 5772158, 10^7)$ this returns $Q = 148$ with witness $86/149$.

**(C) Certificate verification for the logarithmic bounds.** Each inequality of Theorem 3.3 and each increment comparison of Section 5 reduces to: form the difference of two rational functions, place over a common denominator known to be positive on the range, and verify nonnegativity of the resulting polynomial numerator (via Sturm sequences, or by exhibiting it as a positive combination of $(m-1)^i m^j$ with $m \ge 1$). This is what makes the whole development *finitely checkable*, and it is why every constant appearing above is an explicit rational.

Representative numerics (all consistent with the theorems):

| $n$ | $\gamma - g_n$ | $\gamma - a_n$ | $(n+1)^2(\gamma - a_n)$ |
|---|---|---|---|
| $0$ | $0.5772157$ | $7.72\cdot10^{-2}$ | $0.0772157$ |
| $5$ | $0.0856418$ | $2.31\cdot10^{-3}$ | $0.0831048$ |
| $15$ | $0.0315754$ | $3.25\cdot10^{-4}$ | $0.0833008$ |
| $200$ | $0.0024896$ | $2.06\cdot10^{-6}$ | $0.0833331$ |
| $1000$ | $0.0004996$ | $8.32\cdot10^{-8}$ | $0.0833333$ |

The last column visibly approaches $\frac1{12} = 0.0833333$ and never leaves $[\frac1{14},\frac1{12}] = [0.0714286, 0.0833333]$.

---

## 12. Discussion, limitations, and future directions

### 12.1 What the method does and does not give

The strength of the derivative-certificate approach is that it produces inequalities with explicit rational constants that are valid for *every* $n$, with no thresholds and no unspecified $O(\cdot)$ constants. That is exactly what is needed to convert analytic information into arithmetic information (Sections 7–8).

Its limitation is equally clear. The accuracy of the $j$-th such scheme is polynomial: truncating the $\operatorname{artanh}$ series after $2j+1$ terms gives an error of order $n^{-(2j+1)}$ in the summand bounds and $n^{-2j}$ in the corrected approximants. Enclosures of width $w$ then cost $n \approx w^{-1/(2j)}$ terms — better and better, but never geometric. By Theorem 10.3 and its evident generalization, no member of this hierarchy can feed Corollary 10.2.

### 12.2 Future directions

**Conjecture 1 (full Euler–Maclaurin ladder with rational certificates).** For every $j \in \mathbb{N}$ there are explicit rationals $c_1, \dots, c_j$ — the Euler–Maclaurin coefficients $\frac12, \frac1{12}, 0, -\frac1{120}, \dots$ — and explicit rational constants $a_j < b_j$ such that, for all $n$,
$$\frac{a_j}{(n+1)^{j+1}} \;\le\; (-1)^j\left(\gamma - g_n - \sum_{i \le j}\frac{c_i}{(n+1)^i}\right) \;\le\; \frac{b_j}{(n+1)^{j+1}},$$
and the entire ladder is certifiable by the scheme used here: a $(2j+1)$-term $\operatorname{artanh}$ truncation, a telescoping profile $F(m) = \sum_i c_i m^{-i}$, and a single polynomial-nonnegativity check per level. The cases $j = 0$ (Corollary 5.6) and $j = 1$ (Theorem 6.2) are established above.

**Direction 2 (narrowing the enclosure and raising the threshold).** Evaluate the $j = 2$ or $j = 3$ level of the ladder at $n + 1 = 2^{10}$ or $n+1 = 2^{16}$, using only $\log 2$ to high precision. Each additional level of the ladder reduces the exponent, and the small-denominator threshold should grow roughly like the reciprocal square root of the enclosure width. A target: exclude all denominators $q \le 10^6$ with a fully rational certificate.

**Direction 3 (symmetrized information tails for general chains).** Theorem 9.3 assumes bounded ratios. Determine the exact behaviour when $\rho_n \to \infty$ or $\rho_n \to 0$, and characterize summability for chains interpolating between arithmetic and geometric growth, e.g. $r_n = \exp(n^\alpha)$ for $0 < \alpha < 1$, where $\rho_n - 1 \sim \alpha n^{\alpha - 1}$ and the criterion predicts convergence exactly for $\alpha < \frac12$.

**Direction 4 (structurally different approximants).** In view of Theorem 10.3, search for approximants to $\gamma$ with geometric accuracy. Natural candidates include Bessel-function representations, the Ramanujan-type series for $\gamma$, and hypergeometric constructions of the Apéry–Beukers type; the criterion in Corollary 10.2 states precisely what such a family must achieve, and each candidate family admits a falsifiable test — either an exponential bound or an explicit lower bound on the rescaled error, as in Theorem 10.3.

**Direction 5 (the divergence viewpoint as a source of identities).** Since $\gamma$ is the accumulated Kullback–Leibler divergence of an arithmetic chain of exponential laws, natural variants — other one-parameter exponential families, other chains of parameters — should produce further constants of the same flavour, each with the same certificate machinery available. Identifying which classical constants arise this way, and whether any of them admits geometrically accurate approximants, would be an informative test of the whole framework.

---

## 13. Summary of results

- **Rational squeeze:** $\dfrac{1}{2(k+2)^2} \le \dfrac{1}{2(k+1)(k+2)} \le t_k \le \dfrac{1}{2(k+1)^2}$ for all $k$, where $t_k = \frac{1}{k+1} - \log\frac{k+2}{k+1}$.
- **Interpretation:** $t_k = D(\mathrm{Exp}(k+1)\|\mathrm{Exp}(k+2))$ and $\gamma = \sum_k t_k$.
- **Two-sided tail:** $\dfrac{1}{2(n+1)} + \dfrac{1}{14(n+1)^2} \le \gamma - g_n \le \dfrac{1}{2(n+1)} + \dfrac{1}{12(n+1)^2}$; hence $0 < \gamma - g_n \le \frac{1}{2n}$ for $n \ge 1$.
- **Exact acceleration order:** $\dfrac{1}{14(n+1)^2} \le \gamma - a_n \le \dfrac{1}{12(n+1)^2}$ for $a_n = g_n + \frac{1}{2(n+1)}$.
- **Certified enclosure:** $g_{15} = \frac{1195757}{360360} - 4\log 2$ gives $0.5771692 < \gamma < 0.5772158$.
- **Arithmetic consequence:** $\gamma \ne p/q$ for all $1 \le q \le 148$; the threshold is optimal for this enclosure because $\frac{86}{149}$ lies inside.
- **Symmetrized divergence:** $D(a\|b) + D(b\|a) = \frac{(a-b)^2}{ab}$, with an exact summability criterion for chains of bounded ratios, sum exactly $1$ for arithmetic chains, and divergence for every nontrivial geometric chain.
- **Irrationality machinery:** the linear-forms criterion, and a proof that the midpoint-accelerated family cannot satisfy it.
