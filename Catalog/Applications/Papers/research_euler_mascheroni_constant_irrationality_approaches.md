# A Positive-Term Series, an Integral Representation, and the Irrationality Engine for the Euler–Mascheroni Constant

## Abstract

The Euler–Mascheroni constant $\gamma = \lim_{n\to\infty}(H_n - \ln n)$, where $H_n = \sum_{k=1}^n 1/k$ is the $n$-th harmonic number, is among the most studied constants in mathematics, yet whether it is rational remains a celebrated open problem. We present a unified, elementary development of $\gamma$ organized around a single positive term,
$$g(k) = \frac{1}{k} - \ln\!\Big(1 + \frac{1}{k}\Big), \qquad k \ge 1.$$
We prove that $g(k) > 0$ for all $k$, that the partial sums telescope exactly to the classical lower approximants $H_n - \ln(n+1)$, and hence that $\sum_{k\ge 1} g(k) = \gamma$ as a convergent series of strictly positive terms. We exhibit each term as a unit-interval integral $g(k) = \int_k^{k+1}(1/k - 1/y)\,dy$ and assemble these into the staircase integral representation $\gamma = \int_1^\infty (1/\lfloor x\rfloor - 1/x)\,dx$. We establish the sharp per-term bound $g(k) < 1/(2k^2)$ and deduce the explicit convergence rate $0 < \gamma - \sum_{k=1}^n g(k) < 1/(2n)$. We locate $\gamma$ as the zeroth member $\gamma_0$ of the Stieltjes family, whose constants are the Laurent coefficients of the Riemann zeta function at $s=1$. Finally we isolate the abstract irrationality engine common to all known proofs of this type: a real number $x$ is irrational if and only if there exist integer sequences $(a_n), (b_n)$ with $a_n + b_n x \neq 0$ for all $n$ and $a_n + b_n x \to 0$. This reduces the irrationality of $\gamma$ to an explicit Diophantine construction and clarifies that the structural obstruction is the additive logarithmic correction, not the harmonic part.

**Keywords.** Euler–Mascheroni constant; harmonic numbers; integral representation; series acceleration; Stieltjes constants; irrationality criterion; Diophantine approximation; Riemann zeta function.

---

## 1. Introduction

The Euler–Mascheroni constant
$$\gamma = \lim_{n\to\infty}\Big(\sum_{k=1}^n \frac{1}{k} - \ln n\Big) = 0.57721566490153286\ldots$$
measures the persistent gap between the harmonic numbers and the natural logarithm. It surfaces throughout analysis and number theory: in the asymptotics of the divisor and totient functions, in the reflection and digamma identities for the Gamma function, in the Laurent expansion of the Riemann zeta function at its pole, and in countless integral and product formulas. Despite this ubiquity, two of the most basic questions about $\gamma$ — is it rational? is it transcendental? — remain unanswered. By contrast, $\pi$ and $e$ were proved transcendental in the nineteenth century.

This paper gives a self-contained treatment of $\gamma$ built from a single elementary building block and arranged to expose precisely where the irrationality question becomes hard. Our contributions are:

1. **A positive-term series** (Section 3). With $g(k) = 1/k - \ln(1+1/k)$ we show $g(k) > 0$, prove the telescoping identity $\sum_{k=1}^n g(k) = H_n - \ln(n+1)$, and conclude $\sum_{k\ge1} g(k) = \gamma$. Strict positivity makes the partial sums a monotone increasing sequence of certified lower bounds.
2. **An integral representation** (Section 4). Each term is the area $g(k) = \int_k^{k+1}(1/k - 1/y)\,dy$ between a step and the hyperbola, yielding the staircase formula $\gamma = \int_1^\infty (1/\lfloor x\rfloor - 1/x)\,dx$.
3. **A sharp convergence rate** (Section 5). We prove $g(k) < 1/(2k^2)$ and hence $0 < \gamma - \sum_{k=1}^n g(k) < 1/(2n)$.
4. **The Stieltjes anchor** (Section 6). We define the Stieltjes sequence and prove $\gamma_0 = \gamma$, situating the constant at the head of the family appearing in $\zeta$'s Laurent expansion.
5. **The irrationality engine** (Section 7). We prove the integer-linear-form criterion and its converse, characterizing irrationality, and apply it to reduce the open problem for $\gamma$ to an explicit construction.

All arguments are elementary, relying only on the inequality $\ln(1+x) < x$, telescoping, comparison of series, basic interval integration, and the impossibility of an integer strictly between $0$ and $1$.

---

## 2. Preliminaries and notation

Throughout, $\ln$ denotes the natural logarithm and $\lfloor x \rfloor$ the floor function. We write $H_n = \sum_{k=1}^n 1/k$ for the harmonic number ($H_0 = 0$). We use two standard monotone approximants to $\gamma$:
$$L_n = H_n - \ln(n+1) \quad (\text{lower}), \qquad U_n = H_n - \ln n \quad (\text{upper, } n \ge 1).$$
It is classical that $L_n \uparrow \gamma$ strictly from below and $U_n \downarrow \gamma$ strictly from above, so that $L_n < \gamma < U_n$ for all $n \ge 1$. These facts are recovered below from the positivity of $g$.

We repeatedly use the **fundamental logarithmic inequality**: for every real $x > 0$,
$$\ln(1+x) < x. \tag{$\star$}$$
Equivalently, $\ln t < t - 1$ for $t > 1$, with equality only at $t = 1$.

---

## 3. A positive-term series for $\gamma$

**Definition 3.1 (series term).** For $k \in \mathbb{N}$, $k \ge 1$, define
$$g(k) = \frac{1}{k} - \ln\!\Big(1 + \frac{1}{k}\Big) = \frac{1}{k} - \big(\ln(k+1) - \ln k\big).$$
(For bookkeeping it is convenient to set $g(0) = 0$, consistent with the convention $1/0 = 0$.)

**Theorem 3.2 (positivity).** For every integer $k \ge 1$, $g(k) > 0$.

*Proof.* Apply $(\star)$ with $x = 1/k > 0$: $\ln(1 + 1/k) < 1/k$. Subtracting gives $g(k) = 1/k - \ln(1+1/k) > 0$. Equivalently, writing $t = (k+1)/k > 1$, the inequality $\ln t < t-1 = 1/k$ is exactly the claim. $\qquad\blacksquare$

**Theorem 3.3 (telescoping partial sum).** For every $n \ge 0$,
$$\sum_{k=1}^{n} g(k) = \Big(\sum_{k=1}^{n}\frac{1}{k}\Big) - \ln(n+1) = H_n - \ln(n+1) = L_n.$$

*Proof.* Split the term: $g(k) = 1/k - (\ln(k+1) - \ln k)$. Summing the first part gives $H_n$. The second part telescopes:
$$\sum_{k=1}^n \big(\ln(k+1) - \ln k\big) = \ln(n+1) - \ln 1 = \ln(n+1).$$
Hence $\sum_{k=1}^n g(k) = H_n - \ln(n+1)$. (By induction: the base case $n=0$ gives $0 = H_0 - \ln 1 = 0$; the step uses $H_{n+1} = H_n + 1/(n+1)$ and $\ln(n+2) - \ln(n+1)$.) $\qquad\blacksquare$

**Theorem 3.4 (series representation).** The series $\sum_{k\ge1} g(k)$ converges and
$$\sum_{k=1}^{\infty} g(k) = \gamma.$$

*Proof.* By Theorem 3.2 all terms are nonnegative, and by Theorem 3.3 the partial sums equal $L_n = H_n - \ln(n+1)$, which are bounded above by $\gamma$ (indeed $L_n < \gamma$). A nonnegative series with partial sums bounded above converges; thus $\sum_k g(k)$ exists. Its value is $\lim_n L_n$. Since $L_n \to \gamma$ (this is the defining limit, after noting $H_n - \ln(n+1) = (H_n - \ln n) - \ln(1+1/n)$ and $\ln(1+1/n) \to 0$), uniqueness of limits gives $\sum_k g(k) = \gamma$. $\qquad\blacksquare$

**Corollary 3.5 (strict monotonicity and increments).** The lower approximants satisfy $L_{n+1} - L_n = g(n+1) > 0$, so $(L_n)$ is strictly increasing and converges to $\gamma$ from below. In particular $L_n < \gamma$ for all $n$.

*Proof.* Immediate from Theorem 3.3, since $L_{n+1} - L_n = \sum_{k=1}^{n+1} g(k) - \sum_{k=1}^{n} g(k) = g(n+1)$, which is positive by Theorem 3.2. $\qquad\blacksquare$

This is the "Apéry-like" structure of the representation: the rational engine is the harmonic number $H_n$, and the increments are the explicit positive quantities $g(n+1)$.

---

## 4. An integral representation

We now realize each term as area between a step and the hyperbola $y \mapsto 1/y$.

**Lemma 4.1 (integrand nonnegativity).** For $k \ge 1$ and $x \ge k$, we have $1/k - 1/x \ge 0$.

*Proof.* Since $0 < k \le x$, $1/x \le 1/k$. $\qquad\blacksquare$

**Theorem 4.2 (integral form of a term).** For every $k \ge 1$,
$$g(k) = \int_{k}^{k+1}\Big(\frac{1}{k} - \frac{1}{y}\Big)\,dy.$$

*Proof.* On $[k, k+1]$ the constant $1/k$ integrates to $1/k$, and $1/y$ is integrable (the interval avoids $0$) with $\int_k^{k+1} dy/y = \ln(k+1) - \ln k = \ln(1 + 1/k)$. Subtracting,
$$\int_k^{k+1}\Big(\frac1k - \frac1y\Big)\,dy = \frac1k - \ln\!\Big(1+\frac1k\Big) = g(k). \qquad\blacksquare$$

**Theorem 4.3 (staircase integral representation).** Let $\lfloor x \rfloor$ denote the floor. Then
$$\gamma = \int_{1}^{\infty}\Big(\frac{1}{\lfloor x\rfloor} - \frac{1}{x}\Big)\,dx := \lim_{N\to\infty}\int_1^N\Big(\frac{1}{\lfloor x\rfloor} - \frac{1}{x}\Big)\,dx.$$

*Proof.* On each interval $[k, k+1)$ with $k\ge 1$ we have $\lfloor x\rfloor = k$, so $1/\lfloor x\rfloor - 1/x = 1/k - 1/x$, which by Theorem 4.2 integrates over that interval to $g(k)$. Summing over $1 \le k \le N-1$, additivity of the integral over adjacent intervals gives
$$\int_1^N\Big(\frac{1}{\lfloor x\rfloor} - \frac{1}{x}\Big)\,dx = \sum_{k=1}^{N-1} g(k) = L_{N-1}.$$
Letting $N \to \infty$ and applying Theorem 3.4 yields $\gamma$. By Lemma 4.1 the integrand is nonnegative, so the truncated integrals increase monotonically to $\gamma$. $\qquad\blacksquare$

Geometrically: $1/\lfloor x\rfloor$ is the harmonic staircase descending over the hyperbola $1/x$, and $\gamma$ is the total area trapped between them on $[1,\infty)$ — the accumulated overshoot of discrete counting over continuous growth.

---

## 5. A sharp convergence rate

**Theorem 5.1 (per-term bound).** For every $k \ge 1$,
$$0 < g(k) < \frac{1}{2k^2}.$$

*Proof.* Lower bound is Theorem 3.2. For the upper bound, use the second-order refinement of $(\star)$: for $u > 0$,
$$\ln(1+u) > u - \frac{u^2}{2},$$
which follows from $\frac{d}{du}\big[\ln(1+u) - u + u^2/2\big] = \frac{u^2}{1+u} > 0$ and equality at $u=0$. With $u = 1/k$,
$$g(k) = \frac{1}{k} - \ln\!\Big(1+\frac1k\Big) < \frac1k - \Big(\frac1k - \frac{1}{2k^2}\Big) = \frac{1}{2k^2}. \qquad\blacksquare$$

**Theorem 5.2 (explicit convergence rate).** For every $n \ge 1$,
$$0 < \gamma - L_n = \gamma - \sum_{k=1}^{n} g(k) < \frac{1}{2n}.$$

*Proof.* The lower bound is Corollary 3.5. For the upper bound, by Theorem 3.4 the remainder is $\gamma - L_n = \sum_{k=n+1}^\infty g(k)$. By Theorem 5.1 and the standard tail comparison $\sum_{k=n+1}^\infty 1/k^2 < \int_n^\infty dx/x^2 = 1/n$,
$$\gamma - L_n = \sum_{k=n+1}^{\infty} g(k) < \sum_{k=n+1}^{\infty}\frac{1}{2k^2} < \frac{1}{2}\cdot\frac{1}{n} = \frac{1}{2n}. \qquad\blacksquare$$

Thus $L_n = H_n - \ln(n+1)$ approximates $\gamma$ from below with error below $1/(2n)$. The convergence is polynomial (order $1/n$); high-precision computation uses faster accelerations, but the transparent $1/(2n)$ envelope is exactly the certified bound suited to analysis.

---

## 6. The Stieltjes anchor

**Definition 6.1 (Stieltjes sequence).** For $m \ge 0$ and $n \ge 1$,
$$S_m(n) = \sum_{k=1}^{n}\frac{(\ln k)^m}{k} - \frac{(\ln n)^{m+1}}{m+1}.$$
The $m$-th **Stieltjes constant** is $\gamma_m = \lim_{n\to\infty} S_m(n)$.

The Stieltjes constants are the Laurent coefficients of the Riemann zeta function at its simple pole $s=1$:
$$\zeta(s) = \frac{1}{s-1} + \sum_{m=0}^{\infty}\frac{(-1)^m}{m!}\,\gamma_m\,(s-1)^m.$$

**Theorem 6.2 ($\gamma_0 = \gamma$).** The zeroth Stieltjes constant equals the Euler–Mascheroni constant: $\lim_{n\to\infty} S_0(n) = \gamma$.

*Proof.* For $m=0$, $(\ln k)^0 = 1$ and the correction term is $(\ln n)^1/1 = \ln n$, so
$$S_0(n) = \sum_{k=1}^n \frac{1}{k} - \ln n = H_n - \ln n = U_n \qquad (n \ge 1).$$
This is exactly the upper approximant, and $U_n \to \gamma$. Hence $\lim_n S_0(n) = \gamma$. $\qquad\blacksquare$

**Corollary 6.3 (two-sided trapping).** For all $n \ge 1$, $L_n < \gamma < U_n = S_0(n)$, with $U_n - L_n = \ln(1+1/n) \to 0$. The Stieltjes sequence at $m=0$ provides the upper trap, the positive series the lower one.

This anchors the entire Stieltjes hierarchy at $\gamma$ and embeds the present development in the local theory of $\zeta$ at $s=1$.

---

## 7. The irrationality engine

We now isolate the abstract mechanism behind irrationality proofs of Apéry type and reduce the open problem for $\gamma$ to a precise construction.

**Theorem 7.1 (integer-linear-form criterion; sufficiency).** Let $x \in \mathbb{R}$. Suppose there exist integer sequences $(a_n), (b_n)$ such that
$$a_n + b_n x \neq 0 \quad \text{for all } n, \qquad \text{and} \qquad a_n + b_n x \to 0.$$
Then $x$ is irrational.

*Proof.* Suppose for contradiction $x = p/q$ with $q \ge 1$ integer. Then
$$a_n + b_n x = \frac{a_n q + b_n p}{q},$$
whose numerator $a_n q + b_n p$ is an integer; it is nonzero because $a_n + b_n x \neq 0$. A nonzero integer has absolute value at least $1$, so
$$|a_n + b_n x| = \frac{|a_n q + b_n p|}{q} \ge \frac{1}{q} > 0 \quad \text{for all } n.$$
This contradicts $a_n + b_n x \to 0$. Hence $x$ is irrational. $\qquad\blacksquare$

The crux is the rigidity principle: *a nonzero integer cannot lie strictly between $0$ and $1$*. A rational of denominator $q$ keeps every nonzero linear form $a_n + b_n x$ at distance at least $1/q$ from $0$.

**Theorem 7.2 (characterization).** A real number $x$ is irrational **if and only if** there exist integer sequences $(a_n), (b_n)$ with $a_n + b_n x \neq 0$ for all $n$ and $a_n + b_n x \to 0$.

*Proof.* ($\Leftarrow$) is Theorem 7.1. For ($\Rightarrow$), let $x$ be irrational. By Dirichlet's theorem on Diophantine approximation, there are infinitely many rationals $p/q$ (in lowest terms) with
$$\Big|x - \frac{p}{q}\Big| < \frac{1}{q^2}.$$
Since these approximations have unbounded denominators (for each $N$ one can choose such a $p/q$ with $q \ge N$), select a sequence $p_n/q_n$ with $q_n \ge n+1$. Put $a_n = -p_n$, $b_n = q_n$. Then
$$|a_n + b_n x| = q_n\Big|x - \frac{p_n}{q_n}\Big| < q_n \cdot \frac{1}{q_n^2} = \frac{1}{q_n} \le \frac{1}{n+1} \to 0,$$
and $a_n + b_n x \neq 0$ because $x$ is irrational (so $x \neq p_n/q_n$). $\qquad\blacksquare$

**Corollary 7.3 (reduction of the open problem).** The Euler–Mascheroni constant $\gamma$ is irrational if and only if there exist integer sequences $(a_n), (b_n)$ with $a_n + b_n\gamma \neq 0$ for all $n$ and $a_n + b_n\gamma \to 0$.

*Proof.* Apply Theorem 7.2 with $x = \gamma$. $\qquad\blacksquare$

This is an honest reduction, not a resolution: the existence of such forms for $\gamma$ is unknown.

**Where the difficulty lives.** The representation of Sections 3–4 shows that
$$\gamma = H_n - \ln(n+1) + \big(\gamma - L_n\big), \qquad 0 < \gamma - L_n < \tfrac{1}{2n}.$$
The harmonic part $H_n$ is denominator-friendly: multiplying by $D_n = \mathrm{lcm}(1,2,\ldots,n)$ clears all denominators, and the Prime Number Theorem gives $\ln D_n = n(1+o(1))$, i.e. $D_n = e^{n(1+o(1))}$. So $D_n H_n \in \mathbb{Z}$ with $D_n$ of controlled exponential size. The obstruction is the additive correction $\ln(n+1)$: the logarithm of an integer is itself transcendental and is *not* cleared by any common denominator. Constructing the linear forms of Corollary 7.3 therefore requires integer combinations that simultaneously clear $H_n$ *and* approximate $\ln(n+1)$ to within an error that the exponential denominator $D_n$ can absorb. This is precisely the balance between the size of $\mathrm{lcm}(1,\ldots,n)$ and rational approximations to logarithms.

---

## 8. Algorithms

We summarize the computational content (full implementations accompany this paper).

**Algorithm A (certified lower approximant).** Compute $L_n = H_n - \ln(n+1)$ by accumulating $g(k) = 1/k - \ln(1+1/k)$ for $k = 1,\ldots,n$. Return $L_n$ together with the certified two-sided bracket $L_n < \gamma < L_n + 1/(2n)$ (Theorem 5.2). Cost: $O(n)$ arithmetic/transcendental operations.

**Algorithm B (staircase quadrature).** Approximate $\int_1^N (1/\lfloor x\rfloor - 1/x)\,dx$ exactly term-by-term as $\sum_{k=1}^{N-1} g(k)$, confirming numerically that the staircase-minus-hyperbola area equals $L_{N-1}$ (Theorem 4.3).

**Algorithm C (irrationality-form tester).** Given candidate integer sequences $(a_n),(b_n)$, evaluate $a_n + b_n\,\hat\gamma$ at high precision $\hat\gamma \approx \gamma$ and check the two conditions of Corollary 7.3: nonvanishing and decay to $0$. Useful for empirically probing constructions.

**Algorithm D (Stieltjes evaluation).** Compute $S_m(n) = \sum_{k=1}^n (\ln k)^m/k - (\ln n)^{m+1}/(m+1)$ and verify $S_0(n) = H_n - \ln n \to \gamma$ (Theorem 6.2).

---

## 9. Applications and discussion

The positive-series and integral pictures give a transparent, fully certified handle on $\gamma$ suited to analysis and teaching: monotone lower bounds $L_n$ with a guaranteed $1/(2n)$ error, an evocative area interpretation, and a clean derivation of the standard $L_n < \gamma < U_n$ trapping. The Stieltjes anchor connects the constant to the analytic theory of $\zeta(s)$ near $s=1$, where $\gamma$ is the leading finite coefficient. The irrationality engine reframes the central open problem as a concrete Diophantine construction and pinpoints the logarithmic correction as the sole obstruction, indicating exactly where future work must concentrate.

The chief limitation is the rate: $O(1/n)$ convergence makes the bare series unsuited to extreme-precision digit hunting, for which Bessel-function and Euler–Maclaurin accelerations are vastly superior. Our emphasis is structural transparency and certified bounds rather than raw speed.

---

## 10. Future directions

This cycle isolated the abstract engine of every "good rational approximation implies irrationality" argument — a nonzero integer linear form $b_n x - a_n$ that shrinks to zero cannot survive if $x$ is rational, because a rational of denominator $q$ keeps all nonzero such forms at distance at least $1/q$. Applying this to the harmonic numbers exposed a sharp tension: their denominators are cleanly cleared by $n!$ (indeed by $\mathrm{lcm}(1,\ldots,n)$), yet the analytic correction $\ln$ that turns $H_n$ into $\gamma$ destroys integrality. The conjectures below grow directly out of that tension.

**Conjecture 1 (a logarithmic common denominator exists).** There is a sequence of positive integers $b_n$, growing no faster than exponentially, and integers $a_n$, such that $b_n\gamma - a_n$ is never zero yet tends to zero; consequently $\gamma$ is irrational. The key insight is that the obstruction is not the harmonic part — whose denominators are already tamed by $\mathrm{lcm}(1,\ldots,n)$ — but the logarithm, so the search should target integer combinations that simultaneously clear $H_n$ and approximate $\ln(n+1)$ to within a factor that the exponential denominator can absorb. Sharp effective bounds on $\mathrm{lcm}(1,\ldots,n)$ and on rational approximations to logarithms have matured to the point where the two error budgets can, for the first time, be compared on the same scale.

**Conjecture 2 (denominator growth controls the irrationality measure).** If such linear forms exist with $b_n$ of exponential size $e^{cn}$ and error $|b_n\gamma - a_n|$ of size $e^{-c'n}$, then $\gamma$ has finite irrationality measure bounded explicitly by $1 + c/c'$. The universal gap $1/q$ for rationals upgrades, for a fixed construction, into a two-sided squeeze whose exponents $c$ and $c'$ are read straight off the growth of $\mathrm{lcm}(1,\ldots,n)$ and the convergence rate of the bracket. The Prime Number Theorem pins $\mathrm{lcm}(1,\ldots,n)$ to $e^{n(1+o(1))}$, fixing the numerator side precisely, so the only free parameter left to estimate is the analytic decay.

**Conjecture 3 (the Stieltjes family is generically irrational).** Among the Stieltjes constants $\gamma_0 = \gamma, \gamma_1, \gamma_2, \ldots$ (the Laurent coefficients of the Riemann zeta function at its pole), all but finitely many are irrational; in fact no two satisfy a nontrivial linear relation with rational coefficients. Each $\gamma_m$ arises from the same harmonic-type clearing mechanism but weighted by $(\ln k)^m$, so the denominators interleave in a way that makes simultaneous rationality a far more rigid — and thus far less plausible — coincidence than rationality of a single constant. High-precision values reveal no algebraic relations to thousands of digits, and the structural link to $\zeta$'s Laurent expansion provides a uniform framework in which a joint statement can finally be attacked.

**Conjecture 4 (no elementary integral certificate).** No elementary integral representation of $\gamma$ — of the schematic shape used above — can simultaneously be reduced to integer linear forms of subexponential denominator and decay, suggesting that any irrationality proof must import genuinely transcendental input beyond the harmonic/logarithmic dichotomy.

---

## 11. Conclusion

Built entirely from the single positive term $g(k) = 1/k - \ln(1+1/k)$, the Euler–Mascheroni constant admits a convergent positive-term series $\gamma = \sum_{k\ge1} g(k)$ with monotone lower approximants $L_n = H_n - \ln(n+1)$, a staircase integral representation $\gamma = \int_1^\infty(1/\lfloor x\rfloor - 1/x)\,dx$, and a certified convergence rate $\gamma - L_n < 1/(2n)$ stemming from the sharp bound $g(k) < 1/(2k^2)$. The constant heads the Stieltjes family with $\gamma_0 = \gamma$, tying it to the Laurent expansion of $\zeta$. The irrationality criterion — a real number is irrational exactly when nonzero integer linear forms in it tend to zero — reduces the open problem to an explicit construction and locates the difficulty in the transcendental logarithmic correction rather than the integer-friendly harmonic part. The path forward is to balance the exponential growth of $\mathrm{lcm}(1,\ldots,n)$ against rational approximations to logarithms.
