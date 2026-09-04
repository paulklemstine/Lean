# Exact Asymptotic Constants of the Four Fork Channels

**Author:** Aristotle
**Date:** 2026-09-04

---

## Abstract

We study a family of four scalar "channels" attached to a binary fork with resolution parameter $n \ge 2$, all built from the binary entropy function $H(p) = -p\log_2 p - (1-p)\log_2(1-p)$: the *capacity channel* $X(n) = 1 - H(\tfrac12 + \tfrac1n)$, the *ambiguity channel* $A(n) = \log_2 n / n^2$, the *gap channel* $g(n) = -(1-n^{-2})\log_2(1-n^{-2}) - n^{-2}$, and the *reverse channel* $R(n) = -\tfrac12 \log_2(1 - 4n^{-2})$, together with the *isolation channel* $\mathrm{Is}(n) = A(n) + R(n)$. We prove four exact asymptotic constant laws:

$$g(n)\,n^2 \to \log_2 e - 1 = 0.442695\ldots, \qquad X(n)\,n^2 \to 2\log_2 e = 2.885390\ldots,$$
$$\frac{A(n)\,n^2}{\log_2 n} = 1 \ \text{ identically}, \qquad \bigl(\mathrm{Is}(n) - A(n)\bigr)n^2 \to 2\log_2 e.$$

Each limit comes with an explicit finite-$n$ rate, namely $|g(n)n^2 - (\log_2 e - 1)| \le 1/(n\ln 2)$ for $n\ge2$, $|X(n)n^2 - 2\log_2 e| \le 24/(n\ln 2)$ and $|R(n)n^2 - 2\log_2 e| \le 16/(n\ln 2)$ for $n\ge4$. Consequently the capacity-to-gap ratio satisfies

$$\frac{X(n)}{g(n)} \longrightarrow \frac{2\log_2 e}{\log_2 e - 1} = \frac{2}{1-\ln 2} = 6.5177827\ldots,$$

which formally refutes the pre-data conjecture $X/g \to 2$; and $A(n)/X(n) \to \infty$, so the ambiguity channel eventually dominates the capacity channel. At the small-$n$ end we determine the collapse values $X(2) = 1$, $A(2) = 1/4$, $g(2) = \tfrac54 - \tfrac34\log_2 3 = 0.0612781\ldots$ (the reverse and isolation channels diverge at $n=2$), and we localise the $A$–$X$ crossing exactly to the window $(7,8)$ by reducing it to the integer inequalities $7^{100} < 3^{126}5^{35}$ and $5^{40}3^{24} < 2^{131}$. All estimates are derived from two elementary logarithm windows, with no appeal to asymptotic-expansion machinery.

**Keywords:** binary entropy, asymptotic constants, Kullback–Leibler divergence, Taylor windows, catastrophic cancellation, integer certificates, fork channels.

---

## 1. Introduction

### 1.1 The setting

A great many combinatorial and information-theoretic estimates take the shape "quantity $Q_n$ decays like $c/n^2$", and in practice the interesting content is the constant $c$, not the exponent. Determining $c$ correctly is often harder than it looks, because natural definitions frequently subtract one leading term from another; when they do, the surviving constant is a *difference* of constants and bears no simple relation to the ingredients.

This paper studies four such quantities in a maximally transparent setting. All four are attached to a *fork*: a binary branch point whose asymmetry is governed by a single resolution parameter $n \ge 2$. Two of them measure the information-theoretic distance between a coin of bias $\tfrac12 + \tfrac1n$ and a fair coin (in the two opposite directions); one measures the entropy excess associated with a fork event of probability $1/n^2$; and one is the surprisal of that fork event, scaled.

The four channels look alike: all of them are $\Theta(n^{-2})$ up to logarithms, all are built from $\log_2$, and all vanish. Nevertheless their leading constants are four genuinely different numbers, and their ratios are not the ratios a dimensional argument would suggest.

### 1.2 A refuted prediction

The impetus for this work was a discrepancy. A pre-data heuristic predicted the ratio law $X/g \to 2$: both channels are quadratic in the small parameter, both arise from the same entropy function, and $X$ carries the bias $2/n$ where $g$ carries the fork probability $1/n^2$, so a factor of $2$ seems to fall out.

An exact tabulation of the four channels (computed at high precision, out to $n = 655360$) contradicted this: the ratio settled to $6.51778$, stable to six digits. The corrected constant, derived after the fact and proved here, is

$$\frac{X(n)}{g(n)} \to \frac{2}{1-\ln 2} = 6.5177827\ldots$$

We stress the epistemic status: the constant was obtained *post hoc*, guided by the numerical table, and then confirmed out-of-sample. What we contribute here is the analysis that promotes it from a fit to a theorem, and a mechanism (a near-cancellation inside $g$) that explains why the naive guess had to fail.

### 1.3 Contributions

1. **Four exact constant laws with explicit rates** (Theorems 4.1–4.4), each proved by a squeeze between two elementary logarithm windows.
2. **The ratio law and its consequences** (Theorem 5.1): $X/g \to 2/(1-\ln 2) > 6$, hence a formal refutation of $X/g\to 2$ (Corollary 5.2); and $A/X\to\infty$ (Theorem 5.3).
3. **Exact small-$n$ structure** (Section 6): the collapse values at $n=2$, the divergence of $R$ and $\mathrm{Is}$ there, and the exact localisation of the $A$–$X$ crossing in $(7,8)$ by two integer certificates.
4. **A correction to the informal record** (Section 7.2): the value of $g(2)$ quoted in a preliminary tabulation is inconsistent with the exact value $5/4 - (3/4)\log_2 3$ (though consistent with that table's own $g\cdot n^2$ column).

### 1.4 Notation

Throughout, $\log_2$ is the binary logarithm and $\ln$ the natural logarithm, so $\log_2 x = \ln x/\ln 2$. We write
$$\log_2 e = \frac{1}{\ln 2} = 1.4426950408889634\ldots, \qquad \ln 2 = 0.6931471805599453\ldots$$
The parameter $n$ ranges over reals $\ge 2$ where the channels are defined as functions, and over integers $\ge 2$ when limits along $n\to\infty$ are taken; every estimate below is stated for real $n$ and specialises to integers.

---

## 2. Definitions

**Definition 2.1 (Binary entropy).** For $p\in[0,1]$,
$$H(p) = -p\log_2 p - (1-p)\log_2(1-p),$$
with the convention $0\log_2 0 = 0$. It is maximised at $p = \tfrac12$ with $H(\tfrac12)=1$.

**Definition 2.2 (Capacity channel).** For $n \ge 2$,
$$X(n) = 1 - H\!\left(\frac12 + \frac1n\right).$$
Equivalently $X(n)$ is the Kullback–Leibler divergence $D\bigl(\mathrm{Bern}(\tfrac12+\tfrac1n)\,\|\,\mathrm{Bern}(\tfrac12)\bigr)$ in bits: it is the number of bits per symbol lost by coding the biased source with the fair-coin code.

**Definition 2.3 (Ambiguity channel).** For $n\ge 2$,
$$A(n) = \frac{\log_2 n}{n^2}.$$
This is half the surprisal $2\log_2 n$ of a fork event of probability $n^{-2}$, weighted by that probability.

**Definition 2.4 (Gap channel).** For $n\ge 2$, with $u = n^{-2}$,
$$g(n) = -(1-u)\log_2(1-u) - u.$$
The first term is the entropy contribution of the survival branch of the fork; the second subtracts the fork probability itself. The gap channel measures the excess of the former over the latter.

**Definition 2.5 (Reverse and isolation channels).** For $n > 2$,
$$R(n) = -\frac12 \log_2\!\left(1 - \frac{4}{n^2}\right), \qquad \mathrm{Is}(n) = A(n) + R(n).$$
One checks directly that $R(n) = D\bigl(\mathrm{Bern}(\tfrac12)\,\|\,\mathrm{Bern}(\tfrac12+\tfrac1n)\bigr)$: indeed
$$D\!\left(\tfrac12\,\middle\|\,\tfrac12+\tfrac1n\right) = \tfrac12\log_2\frac{1/2}{\tfrac12+\tfrac1n} + \tfrac12\log_2\frac{1/2}{\tfrac12-\tfrac1n} = -\tfrac12\log_2\!\left(1-\tfrac{4}{n^2}\right).$$
Thus $X$ and $R$ are the two directional divergences between the same pair of coins, and $\mathrm{Is}$ adds the ambiguity term on top of the reverse one. Note that $R$ is undefined at $n=2$, where $1-4/n^2 = 0$.

**Definition 2.6 (Fork function).** For $|x| < 1$,
$$F(x) = (1+x)\ln(1+x) + (1-x)\ln(1-x).$$
$F$ is even, non-negative, and vanishes to second order at $0$.

---

## 3. Two logarithm windows

Every asymptotic statement in this paper is a consequence of the following two elementary estimates. We use no asymptotic-expansion formalism, no $O$-calculus, and no complex analysis: only the classical bound $\ln t \le t - 1$ and the alternating-series estimate for $\ln(1+x)$.

**Lemma 3.1 (First-order window).** For $u < 1$,
$$u \le -\ln(1-u),$$
and for $u \le \tfrac12$,
$$-\ln(1-u) \le u + 2u^2.$$

*Proof.* The lower bound is $\ln(1-u) \le (1-u)-1 = -u$, i.e. $\ln t \le t-1$ at $t = 1-u > 0$. For the upper bound, apply the same inequality to $t = (1-u)^{-1} > 0$:
$$-\ln(1-u) = \ln\frac{1}{1-u} \le \frac{1}{1-u} - 1.$$
It remains to check $\frac{1}{1-u} \le 1 + u + 2u^2$ for $u \le \tfrac12$, which after clearing the positive denominator $1-u$ becomes $1 \le (1+u+2u^2)(1-u) = 1 + u^2 - 2u^3 = 1 + u^2(1-2u)$, true precisely because $u\le\tfrac12$. $\square$

The window is two-sided and *quantitative*: the two bounds differ by $2u^2$, so any quantity trapped between them is determined to relative accuracy $2u$.

**Lemma 3.2 (Quadratic Taylor window).** For $|x| \le \tfrac12$,
$$\bigl|\ln(1+x) - \bigl(x - \tfrac{x^2}{2}\bigr)\bigr| \le 2|x|^3.$$

*Proof.* The standard remainder estimate for the logarithm series gives, for $|x|<1$,
$$\Bigl|\ln(1+x) - \sum_{i=1}^{k}\frac{(-1)^{i+1}x^i}{i}\Bigr| \le \frac{|x|^{k+1}}{1-|x|}.$$
Take $k=2$, so the partial sum is $x - x^2/2$, and note that $|x|\le\tfrac12$ gives $1-|x| \ge \tfrac12$, whence the bound $|x|^3/(1-|x|) \le 2|x|^3$. $\square$

The point of Lemma 3.2 is that it retains the *signed* quadratic term, which is what makes cancellation visible in the next lemma.

**Lemma 3.3 (Cubic window for the fork function).** For $|x| \le \tfrac12$,
$$\bigl|F(x) - x^2\bigr| \le 6|x|^3.$$

*Proof.* Write
$$F(x) - x^2 = (1+x)\Bigl[\ln(1+x) - \bigl(x - \tfrac{x^2}{2}\bigr)\Bigr] + (1-x)\Bigl[\ln(1-x) - \bigl(-x - \tfrac{x^2}{2}\bigr)\Bigr],$$
which one verifies by expanding: the bracketed principal parts contribute
$$(1+x)\bigl(x - \tfrac{x^2}{2}\bigr) + (1-x)\bigl(-x-\tfrac{x^2}{2}\bigr) = x^2,$$
the linear terms cancelling and the quadratic terms combining. Apply Lemma 3.2 to each bracket (the second with $x$ replaced by $-x$, legitimate since $|-x| = |x| \le \tfrac12$), obtaining $2|x|^3$ for each. Since $|x|\le\tfrac12$ implies $|1\pm x| \le \tfrac32$, the triangle inequality gives
$$|F(x)-x^2| \le \tfrac32\cdot 2|x|^3 + \tfrac32\cdot 2|x|^3 = 6|x|^3. \qquad\square$$

This is the crux of the capacity law: $F$ is *even*, so its expansion has no linear or cubic term at all, and the honest bound $6|x|^3$ (which we do not attempt to improve to $O(x^4)$) is already enough to pin the quadratic coefficient.

**Lemma 3.4 (Closed form of the capacity channel).** For $n > 2$,
$$X(n) = \frac{F(2/n)}{2\ln 2}.$$

*Proof.* Put $p = \tfrac12 + \tfrac1n = \frac{1 + 2/n}{2}$, so $1-p = \frac{1-2/n}{2}$, both positive for $n>2$. Then
$$H(p) = -\frac{1+2/n}{2}\cdot\frac{\ln(1+2/n) - \ln 2}{\ln 2} - \frac{1-2/n}{2}\cdot\frac{\ln(1-2/n)-\ln 2}{\ln 2}.$$
The two $-\ln 2$ contributions combine to $+\frac{1}{\ln 2}\cdot\ln 2 \cdot \frac{(1+2/n)+(1-2/n)}{2} = 1$, and the remaining terms are $-F(2/n)/(2\ln2)$. Hence $H(p) = 1 - F(2/n)/(2\ln 2)$ and $X(n) = 1 - H(p) = F(2/n)/(2\ln 2)$. $\square$

Lemma 3.4 is the structural heart of the paper: it says the capacity channel is a *single even analytic germ* evaluated at $2/n$. The evenness is why $X(n)n^2$ converges with error $O(n^{-2})$ rather than $O(n^{-1})$ in reality, even though our crude cubic bound only certifies $O(n^{-1})$.

---

## 4. The four exact constant laws

We now state and prove the four laws, each in a quantitative finite-$n$ form from which the limit is immediate.

### 4.1 The gap channel

**Theorem 4.1 (Gap Law).** For every real $n\ge 2$,
$$\left|\,g(n)\,n^2 - \bigl(\log_2 e - 1\bigr)\,\right| \le \frac{1}{n\ln 2}.$$
Consequently $g(n)\,n^2 \to \log_2 e - 1 = 0.4426950\ldots$ as $n\to\infty$, with **no logarithmic factor**.

*Proof.* Set $u = n^{-2} \in (0, \tfrac14]$ and $L = -\ln(1-u)$. A direct computation from Definition 2.4 gives the identity
$$g(n)\,n^2 - \left(\frac{1}{\ln 2} - 1\right) = \frac{1}{\ln 2}\left[\frac{(1-u)L}{u} - 1\right].$$
(Indeed $g(n) = (1-u)L/\ln 2 - u$, so $g(n)n^2 = (1-u)L/(u\ln 2) - 1$.) It therefore suffices to bound the bracket. By Lemma 3.1, $u \le L \le u + 2u^2$, hence
$$(1-u)L - u \le (1-u)(u+2u^2) - u = u^2(1-2u) \le u^2, \qquad (1-u)L - u \ge (1-u)u - u = -u^2,$$
so $\left|\frac{(1-u)L}{u} - 1\right| = \frac{|(1-u)L-u|}{u} \le u = \frac{1}{n^2}$. Therefore
$$\left|g(n)n^2 - (\log_2 e - 1)\right| \le \frac{1}{n^2\ln 2} \le \frac{1}{n \ln 2}$$
for $n \ge 1$. $\square$

The mechanism deserves emphasis. Since $L = u + \tfrac{u^2}{2} + O(u^3)$,
$$g(n) = \frac{(1-u)L}{\ln 2} - u = \frac{u}{\ln 2} - u + O(u^2) = u\,(\log_2 e - 1) + O(u^2).$$
The entropy term alone would give the constant $\log_2 e = 1.4427$; subtracting the bare probability $u$ removes a full unit, leaving $0.4427$ — a loss of about $69\%$ of the leading coefficient. This *near-cancellation* is the whole reason the gap channel is anomalously small, and, as we shall see, the reason the ratio law has the value it does.

### 4.2 The capacity channel

**Theorem 4.2 (Capacity Law).** For every real $n\ge 4$,
$$\left|\,X(n)\,n^2 - 2\log_2 e\,\right| \le \frac{24}{n\ln 2}.$$
Consequently $X(n)n^2 \to 2\log_2 e = 2.8853900\ldots$.

*Proof.* Put $x = 2/n$, so $|x| \le \tfrac12$ for $n\ge 4$. By Lemma 3.4,
$$X(n)n^2 - \frac{2}{\ln 2} = \frac{n^2\bigl(F(x) - x^2\bigr)}{2\ln 2},$$
because $n^2x^2/(2\ln2) = 4/(2\ln 2) = 2/\ln 2$. By Lemma 3.3, $|F(x)-x^2| \le 6x^3 = 48/n^3$, so
$$\left|X(n)n^2 - 2\log_2 e\right| \le \frac{n^2}{2\ln 2}\cdot\frac{48}{n^3} = \frac{24}{n\ln 2}. \qquad\square$$

Because $F$ is even, the true error is $O(n^{-2})$; numerically $X(n)n^2 - 2\log_2 e \approx \tfrac{4}{3\ln 2}n^{-2}$, matching the observed values ($X(100)\cdot 100^2 = 2.885582$, exceeding the limit by $1.9\times 10^{-4} \approx (4/3\ln 2)\cdot 10^{-4}$).

### 4.3 The ambiguity channel

**Theorem 4.3 (Ambiguity Law).** For every real $n\ge 2$,
$$\frac{A(n)\,n^2}{\log_2 n} = 1$$
*identically* — not merely in the limit.

*Proof.* $A(n)n^2 = (\log_2 n/n^2)\cdot n^2 = \log_2 n$, and $\log_2 n > 0$ for $n \ge 2$, so the quotient is $1$. $\square$

Trivial as it is, this identity is the source of all the qualitative asymmetry in the family. The other three channels satisfy $\,\cdot\,n^2 \to \text{const}$; the ambiguity channel satisfies $A(n)n^2 = \log_2 n \to \infty$. This single logarithm is what makes $A$ eventually dominate (Theorem 5.3) and what forces a crossing at finite $n$ (Section 6.2).

### 4.4 The reverse and isolation channels

**Theorem 4.4 (Isolation Law).** For every real $n\ge 4$,
$$\left|\,R(n)\,n^2 - 2\log_2 e\,\right| \le \frac{16}{n\ln 2},$$
and since $\mathrm{Is}(n) - A(n) = R(n)$ by definition,
$$\bigl(\mathrm{Is}(n) - A(n)\bigr)n^2 \longrightarrow 2\log_2 e = 2.8853900\ldots$$

*Proof.* Set $v = 4/n^2 \in (0,\tfrac14]$ and $L = -\ln(1-v)$. Then $R(n) = L/(2\ln 2)$ and
$$R(n)n^2 - \frac{2}{\ln 2} = \frac{2}{\ln 2}\left[\frac{L}{v} - 1\right],$$
since $n^2 v /(2\ln 2) = 2/\ln 2$. Lemma 3.1 gives $v \le L \le v + 2v^2$, so $|L/v - 1| \le 2v = 8/n^2$, whence
$$\left|R(n)n^2 - 2\log_2 e\right| \le \frac{2}{\ln 2}\cdot\frac{8}{n^2} = \frac{16}{n^2\ln 2} \le \frac{16}{n\ln 2}. \qquad\square$$

**Remark 4.5 (Directional symmetry at leading order).** Theorems 4.2 and 4.4 say that the *forward* divergence $X = D(\mathrm{Bern}(\tfrac12+\tfrac1n)\|\mathrm{Bern}(\tfrac12))$ and the *reverse* divergence $R = D(\mathrm{Bern}(\tfrac12)\|\mathrm{Bern}(\tfrac12+\tfrac1n))$ have the *same* leading constant $2\log_2 e$. This is a manifestation of the general fact that KL divergence is locally symmetric: both directions agree with $\tfrac12\chi^2$-type Fisher-metric distance to second order, and only differ at third order in the perturbation. The numerical table shows the difference plainly: at $n = 100$, $X n^2 = 2.885582$ while $R n^2 = 2.885967$ — agreeing to four digits, differing in the fifth.

---

## 5. Ratio laws

### 5.1 The capacity-to-gap ratio

**Theorem 5.1 (Ratio Law).**
$$\lim_{n\to\infty}\frac{X(n)}{g(n)} = \frac{2\log_2 e}{\log_2 e - 1} = \frac{2}{1-\ln 2} = 6.5177827065\ldots$$

*Proof.* For $n\ge 1$ we may cancel $n^2$:
$$\frac{X(n)}{g(n)} = \frac{X(n)n^2}{g(n)n^2}.$$
By Theorem 4.2 the numerator tends to $2/\ln 2$, and by Theorem 4.1 the denominator tends to $1/\ln 2 - 1$, which is nonzero — indeed positive, since $\ln 2 < 1$ implies $1/\ln 2 > 1$. (That $\ln 2 < 1$ follows from $\ln t < t-1$ for $t\ne1$ at $t=2$.) Hence the quotient converges to
$$\frac{2/\ln 2}{1/\ln2 - 1} = \frac{2/\ln 2}{(1-\ln 2)/\ln 2} = \frac{2}{1-\ln 2}. \qquad\square$$

**Corollary 5.2 (Refutation of the pre-data guess).** $X(n)/g(n)$ does **not** converge to $2$.

*Proof.* Limits in $\mathbb{R}$ are unique. If $X/g \to 2$ then $2 = 2/(1-\ln 2)$, i.e. $1 - \ln 2 = 1$, i.e. $\ln 2 = 0$, contradicting $\ln 2 > 0$. Quantitatively, $\ln 2 < 0.7$ gives $2/(1-\ln 2) > 2/0.3 > 6$. $\square$

**Discussion.** The heuristic behind the prediction $X/g\to 2$ implicitly assumed that both channels retain the "same" leading entropy coefficient $\log_2 e$, up to a combinatorial factor of $2$ coming from the bias $2/n$ versus the probability $1/n^2$. Half of that reasoning is correct: $X(n)n^2 = 2\log_2 e + o(1)$ is exactly $2$ times the natural unit $\log_2 e$. What the heuristic misses is the subtraction in Definition 2.4, which turns $\log_2 e$ into $\log_2 e - 1$. Formally,
$$\frac{2\log_2 e}{\log_2 e} = 2 \quad\text{(the guess)} \qquad\text{vs.}\qquad \frac{2\log_2 e}{\log_2 e - 1} = \frac{2}{1-\ln 2} \quad\text{(the truth)},$$
and the inflation factor is $\log_2 e/(\log_2 e - 1) = 1/(1-\ln 2) = 3.2589$. Whenever a defining formula subtracts a first-order term, the resulting constant is a difference and the naive ratio is wrong by exactly such a factor.

### 5.2 Domination of the ambiguity channel

**Theorem 5.3 (Domination Law).** $\displaystyle \frac{A(n)}{X(n)} \longrightarrow \infty$ as $n\to\infty$.

*Proof.* Write
$$\frac{A(n)}{X(n)} = \frac{A(n)n^2}{X(n)n^2} = \log_2 n \cdot \bigl(X(n)n^2\bigr)^{-1},$$
using Theorem 4.3 for the numerator. By Theorem 4.2, $X(n)n^2 \to 2/\ln 2 \ne 0$, so $(X(n)n^2)^{-1} \to \ln 2/2 > 0$. A quantity tending to $+\infty$ times a quantity tending to a positive limit tends to $+\infty$. $\square$

Thus although $X(2) = 1$ is four times $A(2) = 1/4$, the ordering must eventually reverse. The next section shows exactly where.

---

## 6. Exact small-scale structure

### 6.1 The collapse at $n = 2$

At $n = 2$ the bias is total: $\tfrac12 + \tfrac12 = 1$, the coin is a certainty, and the entropy vanishes.

**Theorem 6.1 (Collapse values).**
$$X(2) = 1, \qquad A(2) = \frac14, \qquad g(2) = \frac54 - \frac34\log_2 3 = 0.06127812\ldots$$

*Proof.* For $X$: $H(1) = -1\log_2 1 - 0\log_2 0 = 0$ under the convention $0\log_2 0 = 0$, so $X(2) = 1 - 0 = 1$. For $A$: $\log_2 2 = 1$, so $A(2) = 1/4$. For $g$: with $u = 1/4$,
$$g(2) = -\tfrac34\log_2\tfrac34 - \tfrac14 = -\tfrac34(\log_2 3 - 2) - \tfrac14 = \tfrac32 - \tfrac34\log_2 3 - \tfrac14 = \tfrac54 - \tfrac34\log_2 3. \qquad\square$$

**Proposition 6.2 (Divergence of $R$ and $\mathrm{Is}$ at $n=2$).** The reverse and isolation channels are undefined at $n=2$: $1 - 4/n^2 = 0$ there, so $-\tfrac12\log_2(1-4/n^2) \to +\infty$ as $n \downarrow 2$.

This is not a technicality but a structural fact. The forward divergence from a certainty to a fair coin is a single bit; the reverse divergence from a fair coin to a certainty is infinite, because the fair coin assigns positive probability to an event the certainty declares impossible. The collapse point $n=2$ therefore separates the family into the two channels that survive it ($X$ and $A$, together with $g$) and the two that do not ($R$ and $\mathrm{Is}$).

Numerically, $g(2)n^2 = 4g(2) = 0.245112$, well below the asymptotic $0.442695$; the gap channel approaches its constant from below, monotonically in the observed range ($0.3594$ at $n=3$, $0.3966$ at $n=4$, $0.4426$ at $n=100$).

### 6.2 The $A$–$X$ crossing lies exactly in $(7,8)$

By Theorem 5.3 the ratio $A/X$ passes from below $1$ to above $1$. The transition is sharply located.

**Theorem 6.3 (Crossing Theorem).**
$$A(7) < X(7) \qquad\text{and}\qquad X(8) < A(8).$$
Hence the sign of $A - X$ changes in the interval $(7,8)$.

*Proof.* Both comparisons reduce, via Lemma 3.4, to inequalities between rational linear combinations of logarithms of small integers, and thence to comparisons of integers.

**At $n = 7$.** Here $A(7) = \log_2 7/49 = \ln 7/(49\ln 2)$ and, by Lemma 3.4,
$$X(7) = \frac{F(2/7)}{2\ln 2}, \qquad F(2/7) = \tfrac97\ln\tfrac97 + \tfrac57\ln\tfrac57 = \tfrac97(2\ln 3 - \ln 7) + \tfrac57(\ln 5 - \ln 7).$$
Clearing the common positive factor $1/\ln 2$ and cross-multiplying by $2\cdot49\cdot 7 > 0$, the inequality $A(7)<X(7)$ becomes
$$100\ln 7 < 126 \ln 3 + 35 \ln 5,$$
i.e. after exponentiating (the exponential being strictly increasing),
$$7^{100} < 3^{126}\cdot 5^{35}.$$
This is a comparison of two explicit integers, the left having $85$ digits and the right $86$; it holds.

**At $n = 8$.** Here $A(8) = \log_2 8/64 = 3/64$ and
$$X(8) = \frac{F(1/4)}{2\ln 2}, \qquad F(1/4) = \tfrac54\ln\tfrac54 + \tfrac34\ln\tfrac34 = \tfrac54(\ln 5 - 2\ln 2) + \tfrac34(\ln 3 - 2\ln 2).$$
The inequality $X(8) < A(8)$, after clearing $\ln 2 > 0$ and multiplying out, becomes
$$40\ln 5 + 24\ln 3 < 131 \ln 2, \qquad\text{i.e.}\qquad 5^{40}\cdot 3^{24} < 2^{131}.$$
Again a comparison of explicit integers ($40$ digits each side), and again it holds. $\square$

**Remark 6.4 (The real crossing point).** Solving $A(n) = X(n)$ numerically by bisection on $[7,8]$ gives the real crossing point
$$n^\ast = 7.5681918\ldots,$$
comfortably inside the certified window and confirming that no integer lies between $7$ and the crossing on one side, or between the crossing and $8$ on the other.

**Remark 6.5 (Why integer certificates).** The margins are genuinely tight: numerically $A(7)/X(7) = 0.9595$ and $A(8)/X(8) = 1.0287$, so a naive floating-point evaluation would be convincing but not conclusive at the level of rigour we want. Reducing to $7^{100} < 3^{126}5^{35}$ removes all analytic content: the truth of the crossing is a fact about two specific integers, checkable by exact arithmetic. This device — clearing logarithms into an integer power comparison — is the standard way to certify inequalities between $\mathbb{Q}$-linear combinations of logarithms of rationals, and the exponents ($100$, $126$, $35$; $40$, $24$, $131$) are simply the least common denominators produced by the rational coefficients.

**Remark 6.6 (Uniqueness of the crossing).** Numerically the function $n \mapsto A(n)/X(n)$ is strictly increasing on $[2,\infty)$ ($0.2500$, $0.5032$, $0.6624$, …, $0.9595$ at $7$, $1.0287$ at $8$, $1.3827$ at $16$, $2.3024$ at $100$), so the crossing found above is the only one. We record this as an observation supported by the values computed here, not as a theorem: proving it requires a monotonicity argument for the ratio, which is the content of one of the open problems in Section 8.

---

## 7. Numerical corroboration and corrections

### 7.1 The table

High-precision evaluation of the four channels over a geometric range of resolutions gives the following (values rounded; computations carried out in extended precision, since ordinary double precision loses accuracy in $g$ beyond $n\approx 10^5$ due to the near-cancellation identified in Section 4.1):

| $n$ | $X n^2$ | $g n^2$ | $A n^2/\log_2 n$ | $R n^2$ | $X/g$ | $A/X$ |
|---:|---:|---:|---:|---:|---:|---:|
| $2$ | $4.000000$ | $0.245112$ | $1$ | $\infty$ | $16.3190$ | $0.2500$ |
| $3$ | $3.149798$ | $0.359400$ | $1$ | $3.815986$ | $8.7640$ | $0.5032$ |
| $4$ | $3.019550$ | $0.396641$ | $1$ | $3.320300$ | $7.6128$ | $0.6624$ |
| $7$ | $2.925988$ | $0.427872$ | $1$ | $3.009990$ | $6.8385$ | $0.9595$ |
| $8$ | $2.916224$ | $0.431365$ | $1$ | $2.979501$ | $6.7605$ | $1.0287$ |
| $17$ | $2.892083$ | $0.440196$ | $1$ | $2.905544$ | $6.5700$ | $1.4133$ |
| $10^2$ | $2.885582$ | $0.442623$ | $1$ | $2.885967$ | $6.5193$ | $2.3024$ |
| $10^3$ | $2.885392$ | $0.442694$ | $1$ | $2.885396$ | $6.5178$ | $3.4539$ |
| $10^5$ | $2.885390$ | $0.442695$ | $1$ | $2.885390$ | $6.5178$ | $5.7565$ |
| limit | $2.885390$ | $0.442695$ | $1$ | $2.885390$ | $6.5178$ | $\infty$ |

Every column agrees with the corresponding theorem, and the residuals are consistent with the second-order behaviour discussed in Remark 4.5 and Section 8. Extending the computation to $n = 655360$ in $50$-digit arithmetic reduces all deviations from the limiting constants to below $3\times 10^{-6}$, in agreement with the proved $O(1/n)$ bounds (which are far from tight) and with the true $O(1/n^2)$ rates.

### 7.2 Two corrections to the informal record

Two features asserted in a preliminary tabulation are **not** reproducible and should be withdrawn.

1. **"All four channels collapse at $n=2$."** They do not: $R$ and $\mathrm{Is}$ diverge at $n=2$, since the argument of the logarithm vanishes there (Proposition 6.2). Only $X$, $A$ and $g$ have values at the collapse point, namely $1$, $1/4$ and $5/4 - (3/4)\log_2 3$.

2. **The quoted numerical value of $g(2)$.** The value $0.311278$ attributed to $g(2)$ (as an "OR cap" shared with $A(2)$) is inconsistent with the definition: the exact value is
$$g(2) = \tfrac54 - \tfrac34\log_2 3 = 0.0612781\ldots,$$
and $A(2) = 1/4 = 0.25 \neq g(2)$. Note that the table's own $g\cdot n^2$ column at $n=2$ reads $0.245112 = 4 \times 0.0612781$, which *does* match the exact value; the discrepancy is therefore confined to the quoted scalar and does not affect any of the asymptotic conclusions.

We flag these explicitly because the value of a refutation-driven programme lies precisely in taking the numbers seriously in both directions: the table refuted the pre-data ratio guess, and the analysis in turn refutes two of the table's ancillary claims.

---

## 8. Discussion and future directions

### 8.1 What the analysis shows, and what it does not

The four constants are theorems, not fits. Each is a squeeze between two elementary logarithm windows, and each squeeze yields an explicit finite-$n$ error bound: $1/(n\ln 2)$ for $g$, $24/(n\ln 2)$ for $X$, $16/(n\ln 2)$ for $R$. These bounds are deliberately crude — the true errors are $O(n^{-2})$, because the underlying germs are even or nearly so — but they are unconditional and sufficient for all the limit statements, including the refutation of $X/g\to 2$.

What the analysis does *not* yet deliver is the second-order coefficients, the uniqueness of the $A$–$X$ crossing, or an intrinsic explanation of why $1/(1-\ln 2)$ should govern the ratio beyond the bookkeeping of Section 5.1.

### 8.2 Second-order expansion of the fork gap

Every one of the four channels is a value of a single analytic germ at $0$, so the "exact constants" are just the first Taylor coefficients, and the *second* coefficients should be equally rigid. Upgrading the two-sided log windows to signed cubic windows costs nothing new conceptually and pins the next coefficient.

**Conjecture 8.1.** $n^2\bigl(g(n)n^2 - (\log_2 e - 1)\bigr) \to -\dfrac{1}{2\ln 2}$ and $n^2\bigl(X(n)n^2 - 2\log_2 e\bigr) \to \dfrac{4}{3\ln 2}$.

The second of these matches the numerical residual at $n=100$ noted after Theorem 4.2.

### 8.3 Ratio rigidity across bias families

The constant $2/(1-\ln 2)$ is not special to the bias $1/n$: it is the ratio of the leading Taylor coefficients of two independent germs, so it should be invariant under any reparametrisation $1/n \mapsto c/n$. The proof of Theorem 5.1 factors through $Xn^2$ and $gn^2$ separately, so replacing $2/n$ by $2c/n$ merely rescales one numerator.

**Conjecture 8.2.** For fixed $c>0$, define $X_c(n) = 1 - H(\tfrac12 + \tfrac cn)$ and $g_c(n) = -(1-c^2/n^2)\log_2(1-c^2/n^2) - c^2/n^2$. Then $X_c(n)/g_c(n) \to 2/(1-\ln 2)$ — the same constant, for every $c$.

### 8.4 Uniqueness of the $A$–$X$ crossing

$A/X$ is eventually increasing to $\infty$ while starting below $1$ at $n = 2$, and its logarithmic derivative appears to be sign-definite, so the crossing verified in $(7,8)$ should be the *only* one. Theorem 5.3 supplies the $\infty$ end; what remains is a monotonicity argument on $[2,\infty)$, most plausibly via the derivative of $\log A - \log X = \log\log_2 n - \log(F(2/n)/(2\ln 2))$.

**Conjecture 8.3.** $n\mapsto A(n)/X(n)$ is strictly increasing on $[2,\infty)$; consequently $A(n) < X(n)$ for $2\le n\le 7$ and $A(n)>X(n)$ for $n\ge 8$, with a unique real crossing point $n^\ast\in(7,8)$.

### 8.5 Further directions

- **Forward–reverse asymmetry.** Theorems 4.2 and 4.4 give the same constant for $X$ and $R$; the difference $R(n) - X(n)$ is $O(n^{-4})$ and its leading coefficient should be computable by the same cubic-window technique, quantifying the local asymmetry of KL divergence at the fair coin.
- **Multi-way forks.** Replacing the binary fork by a $k$-ary one, with the uniform distribution perturbed by $1/n$ in one coordinate, should produce a $k$-parameter family whose leading constants interpolate the ones found here; the substitution $\log_2 e \mapsto \log_k e$ is the natural guess and should be checked, not assumed.
- **Sharpening the certificates.** The exponents $100, 126, 35$ and $40,24,131$ in Theorem 6.3 are the smallest produced by the naive clearing of denominators; a continued-fraction search would likely yield much smaller certificates, which is of independent interest for automated verification of logarithmic inequalities.
- **Cancellation-aware heuristics.** The failure of the guess $X/g\to2$ suggests a general principle worth formalising: for any quantity defined as (entropy term) minus (probability term), the leading constant is $\log_2 e - 1$ rather than $\log_2 e$, so ratios against un-cancelled channels acquire the universal inflation factor $1/(1-\ln 2) = 3.2589$.

---

## 9. Conclusion

Four superficially similar quantities attached to a binary fork have four different exact asymptotic constants:
$$g\cdot n^2 \to \log_2 e - 1, \qquad X\cdot n^2 \to 2\log_2 e, \qquad \frac{A\cdot n^2}{\log_2 n} \equiv 1, \qquad (\mathrm{Is}-A)\cdot n^2 \to 2\log_2 e,$$
with explicit $O(1/n)$ rates, and consequently $X/g \to 2/(1-\ln 2) = 6.5178$ and $A/X\to\infty$. The pre-data prediction $X/g\to 2$ is false, and the reason is a near-cancellation inside the gap channel that removes $69\%$ of its leading coefficient. At the other end of the scale, the channels collapse at $n=2$ to $X(2)=1$, $A(2)=1/4$, $g(2) = 5/4 - (3/4)\log_2 3$ (the reverse channel diverging there), and the crossover between the ambiguity and capacity channels is pinned exactly to the window $(7,8)$ by two integer inequalities.

The methodological content is as simple as the results are clean: two logarithm windows, one algebraic identity turning the capacity channel into an even germ, and two integer certificates. No heavier tool is needed, and the resulting bounds are uniform and explicit at every finite $n$.

