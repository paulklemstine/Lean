# Sharper Threshold Certification: Thirteen Certified Decimals of the BB84 Error-Rate Threshold from a Continued-Fraction Anchor

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

The asymptotic one-way secret-key rate of the BB84 quantum key distribution
protocol, expressed in nats per sifted bit, is $r(Q) = \log 2 - 2H_2(Q)$, where
$H_2$ is the binary entropy function. It vanishes at a unique quantum bit error
rate $p_\star \in (0,\tfrac12)$, universally quoted in the literature as
"approximately $11\%$". We develop a complete certification pipeline for this
constant and prove that
$$0.1100278644383 < p_\star < 0.1100278644384,
\qquad\text{i.e.}\qquad
\lfloor 10^{13}\,p_\star\rfloor = 1100278644383,$$
sharpening the elementary bracket $(6.25\%, 12.5\%)$ by more than thirteen orders
of magnitude. Every step is an inequality between explicit rational numbers or
explicit integers; no floating-point evaluation of a transcendental function
enters at any point.

The pipeline has four components. (i) An **exact arithmetic criterion**: for
positive integers $a,c$, the transcendental comparison
$H_2\!\left(\frac{a}{a+c}\right) \lessgtr \frac{\log 2}{2}$ is *equivalent* to
the integer comparison $(a+c)^{2(a+c)} \lessgtr 2^{a+c}a^{2a}c^{2c}$. (ii)
**Padé bounds** $\frac{2(x-1)}{x+1} \le \log x \le \frac{x-x^{-1}}{2}$ for
$x \ge 1$, with cubic error, which convert integer certificates into certified
two-sided numerical values of $r$ at rational points. (iii) A reusable
**mean-value refinement step** converting a certified anchor value plus a
certified derivative bracket into an enclosure of the root, of width quadratic in
the anchor's distance to the root. (iv) The observation, which is the main
methodological contribution, that the anchor should be a **continued-fraction
convergent** of $p_\star$ rather than a decimal. The convergent $79/718$ lies
$9.29\times 10^{-9}$ from the root while requiring only $4102$-digit certificate
integers — twenty times smaller than the $80\,000$-digit certificate needed for a
mere four decimals by brute force.

We also record two by-products. First, $11/100$ is itself a convergent of
$p_\star$, hence the *best rational approximation of the threshold with
denominator at most $308$*; the textbook figure is optimal for its size. Second,
its error is certified: $2.786\times 10^{-5} < |p_\star - 0.11| < 2.787\times
10^{-5}$. Finally, we formulate a **quartic certification law**: for a root whose
sign at rationals is decidable at cost $O(q^2)$, anchoring at convergents yields
certified enclosures of width $\varepsilon$ at cost $O(\varepsilon^{-1/2})$
rather than $O(\varepsilon^{-1})$.

**Keywords:** BB84, quantum key distribution, binary entropy, error-rate
threshold, certified enclosure, continued fractions, Diophantine approximation,
Padé approximation.

---

## 1. Introduction

### 1.1 The constant

In the BB84 protocol, Alice transmits qubits prepared in one of two mutually
unbiased bases and Bob measures in a randomly chosen basis; the parties retain
those rounds in which the bases agree. Errors in the retained (*sifted*) string
are quantified by the **quantum bit error rate** $Q$. The standard asymptotic
security analysis for one-way post-processing gives a secret-key rate per sifted
bit of
$$r(Q) \;=\; \log 2 \;-\; 2\,H_2(Q) \qquad\text{(nats per sifted bit)},$$
in which one factor $H_2(Q)$ is the cost of error reconciliation and the other is
the cost of privacy amplification against a collective attack. In bits, dividing
by $\log 2$, this reads $1 - 2h(Q)$ with $h$ the base-two binary entropy — the
familiar Shor–Preskill form.

The protocol yields positive key exactly when $r(Q) > 0$, i.e. when $Q$ is below
the unique root $p_\star$ of $r$ in $(0,\tfrac12)$. This root is the constant
quoted throughout the field as $\approx 11\%$.

### 1.2 What is and is not known about it

$p_\star$ is the solution of a transcendental equation with no closed form. The
value $0.11$ is folklore: numerically computed, universally repeated, never
accompanied by an error bound. Elementary rigorous arguments give only the coarse
bracket
$$\tfrac{1}{16} \;<\; p_\star \;<\; \tfrac18,
\qquad\text{i.e.}\qquad 6.25\% < p_\star < 12.5\%,$$
which is too weak to distinguish $11\%$ from $10\%$ or $12\%$. The gap between
what is *rigorously known* and what is *routinely quoted* is five orders of
magnitude.

### 1.3 Contribution

We close that gap and go far beyond it. The main theorem is a thirteen-decimal
certified enclosure of $p_\star$, obtained by a pipeline whose every ingredient
is an explicit inequality between explicit rationals. The methodological point is
the role of Diophantine approximation: the *quality of the rational anchor*, not
the *size of the arithmetic*, is the binding resource, and continued-fraction
convergents optimize exactly that quality per unit of arithmetic.

### 1.4 Organization

Section 2 fixes definitions and states the existence and uniqueness of the
threshold. Section 3 proves the exact arithmetic criterion and derives a
four-decimal enclosure. Section 4 proves the Padé bounds and the value
certificates. Section 5 states and proves the mean-value refinement step.
Section 6 analyses continued-fraction anchors and computes the derivative
bracket. Section 7 assembles the main theorem. Section 8 gives the algorithms.
Section 9 analyses cost. Section 10 discusses applications and limitations.
Section 11 lists future directions.

---

## 2. Setup

### Definition 2.1 (Binary entropy, natural units)

For $p \in (0,1)$,
$$H_2(p) \;=\; -p \log p - (1-p)\log(1-p),$$
extended by $H_2(0) = H_2(1) = 0$. It is continuous on $[0,1]$, strictly
increasing on $[0,\tfrac12]$, strictly concave, symmetric about $\tfrac12$, and
satisfies $H_2(\tfrac12) = \log 2$. Its derivative on $(0,1)$ is
$$H_2'(x) \;=\; \log(1-x) - \log x \;=\; \log\frac{1-x}{x},$$
strictly decreasing, positive on $(0,\tfrac12)$; its second derivative is
$H_2''(x) = -\frac{1}{x(1-x)}$, which at $x \approx 0.11$ has magnitude
$\approx 10.2$.

### Definition 2.2 (Secret-key rate and threshold)

The **asymptotic one-way BB84 secret-key rate** is
$$r(Q) \;=\; \log 2 - 2H_2(Q), \qquad Q\in[0,\tfrac12].$$
The **threshold** $p_\star$ is the unique $p \in [0,\tfrac12]$ with $r(p) = 0$.

### Proposition 2.3 (Existence and uniqueness)

There is exactly one $p_\star \in [0,\tfrac12]$ with $r(p_\star) = 0$, and it
satisfies $\tfrac{1}{16} < p_\star < \tfrac18$.

*Proof sketch.* $r$ is continuous on $[0,\tfrac12]$ with $r(0) = \log 2 > 0$ and
$r(\tfrac12) = -\log 2 < 0$, so a root exists by the intermediate value theorem.
Since $H_2$ is strictly increasing on $[0,\tfrac12]$, $r$ is strictly decreasing
there, so the root is unique. The bracket follows from evaluating $H_2$ against
$\tfrac12\log 2$ at $\tfrac1{16}$ and $\tfrac18$ using elementary logarithm
bounds. $\square$

Note that $r(p) = 0 \iff H_2(p) = \tfrac12\log 2$, and $r(p) > 0 \iff H_2(p) <
\tfrac12\log 2$; the certification problem is therefore entirely about locating
the level set $\{H_2 = \tfrac12 \log 2\}$.

---

## 3. The exact arithmetic criterion

### Lemma 3.1 (Rational entropy identity)

For positive integers $a, c$,
$$2(a+c)\,H_2\!\left(\frac{a}{a+c}\right)
\;=\; 2(a+c)\log(a+c) \;-\; 2a\log a \;-\; 2c\log c .$$

*Proof sketch.* Put $b = a+c$, so $1 - \frac{a}{b} = \frac{c}{b}$. Expanding the
definition of $H_2$ and using $\log\frac{b}{a} = \log b - \log a$,
$\log\frac{b}{c} = \log b - \log c$ gives
$H_2(a/b) = \frac{a}{b}(\log b - \log a) + \frac{c}{b}(\log b - \log c)$.
Multiply by $2b$ and use $a + c = b$. $\square$

The point of clearing the denominator is that the resulting identity has *integer
coefficients on all logarithms*, so exponentiating it produces a comparison
between integers.

### Theorem 3.2 (Rational Sign Criterion)

For positive integers $a, c$,
$$H_2\!\left(\frac{a}{a+c}\right) < \frac{\log 2}{2}
\iff
(a+c)^{2(a+c)} < 2^{\,a+c}\,a^{2a}\,c^{2c},$$
$$\frac{\log 2}{2} < H_2\!\left(\frac{a}{a+c}\right)
\iff
2^{\,a+c}\,a^{2a}\,c^{2c} < (a+c)^{2(a+c)} .$$
Consequently $r\!\left(\frac{a}{a+c}\right) > 0$ if and only if
$(a+c)^{2(a+c)} < 2^{a+c}a^{2a}c^{2c}$.

*Proof sketch.* Set
$$D = (a+c)^{2(a+c)}, \qquad N = 2^{\,a+c}\,a^{2a}\,c^{2c}.$$
Both are positive integers, and
$$\log D = 2(a+c)\log(a+c), \qquad
\log N = (a+c)\log 2 + 2a\log a + 2c\log c .$$
By strict monotonicity of $\log$ on $(0,\infty)$, $D < N \iff \log D < \log N$,
i.e.
$$2(a+c)\log(a+c) - 2a\log a - 2c\log c \;<\; (a+c)\log 2 .$$
By Lemma 3.1 the left side is $2(a+c)H_2\!\left(\frac{a}{a+c}\right)$, and
dividing by $2(a+c) > 0$ gives exactly $H_2\!\left(\frac{a}{a+c}\right) <
\frac{\log 2}{2}$. The reverse statement is identical with the inequality
flipped. $\square$

Two remarks are essential. First, Theorem 3.2 is an *equivalence*: it is a
complete decision procedure for the position of any rational relative to the
threshold, not a one-sided sufficient condition. Second, the transcendence of
$\log 2$ has been fully absorbed: it appears in the criterion only through the
integer factor $2^{a+c}$.

### Corollary 3.3 (Four certified decimals)

$$0.1100 \;<\; p_\star \;<\; 0.1101 .$$

*Proof sketch.* At $(a,c) = (11,89)$ the criterion requires
$100^{200} < 2^{100}\cdot 11^{22}\cdot 89^{178}$; this holds (both sides are
$823$-digit integers), so $r(0.11) > 0$ and, by strict monotonicity of $r$,
$p_\star > 0.11$. At $(a,c) = (1101, 8899)$ the criterion requires
$2^{10000}\cdot 1101^{2202}\cdot 8899^{17798} < 10000^{20000}$; this holds
($80\,000$-digit integers), so $r(0.1101) < 0$ and $p_\star < 0.1101$. The
consistency check at $(a,c) = (1100,8900)$, which restates the lower endpoint at
denominator $10^4$, agrees. $\square$

### 3.1 The brute-force wall

The certificate at denominator $b$ involves integers with
$\Theta(b\log b)$ digits. At $b = 10^4$ that is $8\times10^4$ digits; at
$b = 10^7$ it would be $\approx 10^8$ digits, several of them, which is
impractical for exact verification. Each additional certified decimal costs a
factor of $10$ in $b$ and hence roughly a factor of $100$ in work. Brute force
therefore stalls at four to five decimals. Everything that follows is about
escaping this wall by importing *analysis* and *number theory* rather than more
arithmetic.

---

## 4. From sign to value: Padé certificates

### Lemma 4.1 (Exact rational form of the key rate)

For positive integers $a, c$, with $N$ and $D$ as in Theorem 3.2,
$$r\!\left(\frac{a}{a+c}\right) \;=\; \frac{1}{a+c}\,\log\frac{N}{D}.$$

*Proof sketch.* $r(a/(a+c)) = \log 2 - 2H_2(a/(a+c))$; substitute Lemma 3.1 and
regroup, recognizing $\log N - \log D$. $\square$

Thus the key rate at a rational point is *exactly* a scaled logarithm of an
explicit rational number. Certified numerics for $r$ therefore reduce to
certified numerics for $\log$ on an interval near $1$.

### Lemma 4.2 (Padé bounds of order $(1,1)$)

For all real $x \ge 1$,
$$\frac{2(x-1)}{x+1} \;\le\; \log x \;\le\; \frac{x - x^{-1}}{2}.$$

*Proof sketch.* Let $g(x) = \log x - \frac{2(x-1)}{x+1}$ and
$G(x) = \frac{x-x^{-1}}{2} - \log x$. Both vanish at $x = 1$. Differentiating,
$$g'(x) = \frac1x - \frac{4}{(x+1)^2} = \frac{(x-1)^2}{x(x+1)^2} \ge 0,
\qquad
G'(x) = \frac{1 + x^{-2}}{2} - \frac1x = \frac{(x-1)^2}{2x^2} \ge 0 .$$
Hence both are non-decreasing on $[1,\infty)$ and therefore non-negative. $\square$

Both bounds have error $\Theta((x-1)^3)$ as $x \to 1$, in contrast to the
elementary bounds $1 - x^{-1} \le \log x \le x-1$ whose error is
$\Theta((x-1)^2)$. At $x \approx 1.0000279$ the Padé slack is $\approx
7\times 10^{-15}$ relative, which is what makes thirteen decimals reachable.

### Theorem 4.3 (Padé value certificates)

Let $a,c,m,n$ be positive integers, $N$ and $D$ as above.

1. *(Lower certificate.)* If $n \le m$ and $m\,D < n\,N$, then
$$r\!\left(\frac{a}{a+c}\right) \;>\; \frac{1}{a+c}\cdot\frac{2\left(\frac{m}{n}-1\right)}{\frac{m}{n}+1}.$$
2. *(Upper certificate.)* If $D \le N$ and $n\,N < m\,D$, then
$$r\!\left(\frac{a}{a+c}\right) \;<\; \frac{1}{a+c}\cdot\frac{\frac{m}{n} - \frac{n}{m}}{2}.$$

*Proof sketch.* (1) The hypothesis $mD < nN$ says $\frac{m}{n} < \frac{N}{D}$,
and $n \le m$ gives $1 \le \frac{m}{n}$, hence $1 \le \frac{N}{D}$. Lemma 4.2
applies at $x = N/D$: $\log\frac ND \ge \frac{2(N/D - 1)}{N/D + 1}$. The map
$t \mapsto \frac{2(t-1)}{t+1}$ is strictly increasing on $(-1,\infty)$, so
$\frac{2(m/n-1)}{m/n+1} < \frac{2(N/D-1)}{N/D+1} \le \log\frac ND$. Multiply by
$(a+c)^{-1} > 0$ and apply Lemma 4.1. (2) Dually: $D \le N$ gives
$1 \le \frac ND$, and $nN < mD$ gives $\frac ND < \frac mn$. Lemma 4.2 gives
$\log \frac ND \le \frac{N/D - (N/D)^{-1}}{2}$, and $t \mapsto \frac{t -
t^{-1}}{2}$ is strictly increasing on $(0,\infty)$, so this is
$< \frac{m/n - (m/n)^{-1}}{2}$. $\square$

The hypotheses of Theorem 4.3 are *integer inequalities*. Thus a pair of integer
comparisons certifies a two-sided rational bracket for the key rate at any
rational error rate.

---

## 5. The refinement engine

### Lemma 5.1 (Mean value theorem at an arbitrary anchor)

If $0 < q < p < 1$ then there exists $\xi \in (q,p)$ with
$$\left(\log(1-\xi) - \log \xi\right)(p - q) \;=\; H_2(p) - H_2(q).$$

*Proof sketch.* $H_2$ is continuous on $[q,p] \subset (0,1)$ and differentiable
on $(q,p)$ with derivative $\log(1-x) - \log x$. Apply the mean value theorem and
clear the nonzero factor $p - q$. $\square$

### Theorem 5.2 (Certified refinement step)

Let $p$ satisfy $r(p) = 0$. Suppose $0 < q_0 < p < q_1 < 1$ and that

* $A_1 < \tfrac12\,r(q_0) < A_2$ (certified bracket for the entropy defect at the anchor), and
* $L \le \log(1-x) - \log x \le U$ for all $x \in [q_0,q_1]$, with $L > 0$
  (certified derivative bracket).

Then
$$q_0 + \frac{A_1}{U} \;<\; p \;<\; q_0 + \frac{A_2}{L}.$$

*Proof sketch.* Since $r(p) = 0$, $H_2(p) = \tfrac12 \log 2$. Lemma 5.1 gives
$\xi \in (q_0, p) \subseteq [q_0, q_1]$ with
$$H_2'(\xi)\,(p - q_0) \;=\; H_2(p) - H_2(q_0)
\;=\; \tfrac12\log 2 - H_2(q_0) \;=\; \tfrac12\,r(q_0).$$
Since $\xi \in [q_0,q_1]$, we have $L \le H_2'(\xi) \le U$, and $p - q_0 > 0$.
From $H_2'(\xi)(p-q_0) = \tfrac12 r(q_0) > A_1$ and $H_2'(\xi) \le U$ we get
$U(p - q_0) > A_1$, i.e. $p - q_0 > A_1/U$. From $H_2'(\xi)(p-q_0) < A_2$ and
$H_2'(\xi) \ge L > 0$ we get $L(p-q_0) < A_2$, i.e. $p - q_0 < A_2/L$. $\square$

### Corollary 5.3 (The quadratic law)

Write $\delta = p_\star - q_0 > 0$ and suppose the derivative bracket is taken
over an interval of length $O(\delta)$ containing $[q_0, p_\star]$. Then
$U - L = O(|H_2''|\,\delta)$ and the width of the enclosure of Theorem 5.2 is
$$\frac{A_2}{L} - \frac{A_1}{U}
\;\approx\; A\left(\frac1L - \frac1U\right)
\;\approx\; \delta\cdot\frac{U-L}{L}
\;\approx\; \frac{|H_2''(p_\star)|}{H_2'(p_\star)}\,\delta^2
\;\approx\; 4.9\,\delta^2 ,$$
using $H_2'(p_\star) = 2.0904565\ldots$ and $|H_2''(p_\star)| = 10.216\ldots$ at
$p_\star \approx 0.1100279$.

This is the governing law of the whole development. It converts the certification
problem into a problem of *finding a good rational anchor*.

---

## 6. Diophantine anchors

### 6.1 The failure of decimal anchors

Anchoring at $q_0 = 11/100$ gives $\delta = 2.7864\times10^{-5}$ and, by
Corollary 5.3, an enclosure of width $\approx 4\times 10^{-9}$: eight decimals.
(Executed carefully, with Padé value certificates at denominator $10^{8}$ and a
derivative bracket on $[0.110000, 0.110029]$, this yields exactly
$0.11002786 < p_\star < 0.11002787$, i.e. $\lfloor 10^8 p_\star\rfloor =
11002786$.) To improve, one needs $\delta \approx 10^{-7}$, hence a decimal
anchor with denominator $10^7$, hence certificates with $10^8$-digit integers.
That route is closed.

### 6.2 Continued fractions

The continued fraction expansion of $p_\star$ begins
$$p_\star = [\,0;\,9,\,11,\,3,\,2,\,208,\,2,\,12,\,1,\ldots\,],$$
with convergents and signed errors $p_k/q_k - p_\star$:

| $k$ | convergent $p_k/q_k$ | decimal | error |
|---|---|---|---|
| 0 | $0/1$ | $0$ | $-1.100\times 10^{-1}$ |
| 1 | $1/9$ | $0.111111\ldots$ | $+1.083\times10^{-3}$ |
| 2 | $11/100$ | $0.11$ | $-2.786\times 10^{-5}$ |
| 3 | $34/309$ | $0.1100323\ldots$ | $+4.498\times 10^{-6}$ |
| 4 | $79/718$ | $0.1100278551\ldots$ | $-9.285\times 10^{-9}$ |
| 5 | $16466/149653$ | $0.11002786446\ldots$ | $+2.142\times 10^{-11}$ |
| 6 | $33011/300024$ | $0.110027864437\ldots$ | $-8.479\times 10^{-13}$ |

By the classical best-approximation theorem, each convergent $p_k/q_k$ is closer
to $p_\star$ than any fraction with denominator $\le q_k$; the errors satisfy
$|p_\star - p_k/q_k| < 1/(q_kq_{k+1})$.

### Observation 6.1 (Optimality of the textbook value)

$11/100$ is the convergent $k=2$, and $q_3 = 309$. Hence **$11/100$ is the best
rational approximation of $p_\star$ among all fractions with denominator at most
$308$**. The universally quoted figure $11\%$ is not a naive rounding but the
optimal fraction of its size. Its error is certified:
$$2.786\times 10^{-5} \;<\; |p_\star - \tfrac{11}{100}| \;<\; 2.787\times 10^{-5},$$
which follows immediately from the eight-decimal enclosure since
$p_\star > 11/100$.

### 6.3 The chosen anchor

Take $q_0 = 79/718$, the convergent $k=4$. Then $a = 79$, $c = 639$, $a + c =
718$, and
$$D = 718^{1436},\qquad N = 2^{718}\cdot 79^{158}\cdot 639^{1278},$$
both $4102$-digit integers. Compare: the four-decimal certificate of Corollary
3.3 used $80\,000$-digit integers. The anchor $79/718$ is $3000\times$ closer to
the root than $11/100$ while requiring a certificate twenty times smaller.

### Proposition 6.2 (Anchor certificates)

$$D < N, \qquad\text{and}\qquad
100002787345813950188\,D \;<\; 10^{20}\,N \;<\; 100002787345813950189\,D,$$
i.e. $\frac ND = 1.00002787345813950188\ldots$ The first inequality places the
anchor strictly below threshold.

### Corollary 6.3 (Certified key rate at the anchor)

$$3.882043130930\times 10^{-8} \;<\; r\!\left(\tfrac{79}{718}\right) \;<\; 3.882043131686\times 10^{-8},$$
hence, with $A_1 = 1.941021565465\times10^{-8}$ and
$A_2 = 1.941021565843\times 10^{-8}$,
$$A_1 \;<\; \tfrac12\,r\!\left(\tfrac{79}{718}\right) \;<\; A_2 .$$

*Proof sketch.* Apply Theorem 4.3(1) with $(m,n) = (100002787345813950188,\,
10^{20})$ and Theorem 4.3(2) with $(m,n) = (100002787345813950189,\, 10^{20})$,
using Proposition 6.2, and divide by $718$. $\square$

(The exact value is $r(79/718) = 3.88204313118\ldots\times 10^{-8}$; the
certified bracket has relative width $2\times10^{-10}$, entirely due to the
twenty-digit truncation of $N/D$, not to the Padé slack.)

### 6.4 The derivative bracket

### Lemma 6.4 (Two certified logarithms)

$$\log\frac{639}{79} \;\le\; 2.0904568254,
\qquad
2.0904563381 \;\le\; \log\frac{88997213}{11002787}.$$

*Proof sketch.* Both ratios are close to $8$, so write
$\frac{639}{79} = 8\cdot\frac{639}{632}$ and
$\frac{88997213}{11002787} = 8\cdot\frac{88997213}{88022296}$, and use
$\log 8 = 3\log 2$ with a nine-digit two-sided bound on $\log 2$
($0.6931471803 < \log 2 < 0.6931471808$). The residual factors are both within
about $1.11\times10^{-2}$ of $1$, so the Padé bounds of Lemma
4.2 apply with ample accuracy: explicitly
$\log\frac{639}{632} \le \frac{1}{2}\left(\frac{639}{632} - \frac{632}{639}\right)
= \frac{8897}{807696}$ and
$\log\frac{88997213}{88022296} \ge \frac{2\cdot 974917}{177019509}$.
Adding gives the two stated bounds. $\square$

### Theorem 6.5 (Derivative bracket at the anchor scale)

For all $x \in \left[\frac{79}{718},\; 0.11002787\right]$,
$$2.0904563381 \;\le\; \log(1-x) - \log x \;\le\; 2.0904568254 .$$
The bracket has width $4.873\times 10^{-7}$.

*Proof sketch.* $x \mapsto \log(1-x) - \log x$ is strictly decreasing, so the
maximum is at the left endpoint and the minimum at the right endpoint. At the
left endpoint the value is $\log\frac{639/718}{79/718} = \log\frac{639}{79}$; at
the right endpoint it is $\log\frac{0.88997213}{0.11002787} =
\log\frac{88997213}{11002787}$. Apply Lemma 6.4. Formally one argues by
monotonicity of $\log$ on each of the two terms separately, which avoids needing
the endpoints to be attained. $\square$

The right endpoint $0.11002787$ is legitimate input: it is the certified upper
bound from the eight-decimal enclosure of §6.1, so the hypothesis
$p_\star < q_1$ of Theorem 5.2 is already proved.

---

## 7. Main results

### Theorem 7.1 (Thirteen certified decimals)

Every $p \in [0,\tfrac12]$ with $r(p) = 0$ satisfies
$$0.1100278644383 \;<\; p \;<\; 0.1100278644384 .$$

*Proof sketch.* Apply Theorem 5.2 with
$$q_0 = \frac{79}{718},\quad q_1 = 0.11002787,\quad
A_1 = 1.941021565465\times10^{-8},\quad A_2 = 1.941021565843\times 10^{-8},$$
$$L = 2.0904563381,\quad U = 2.0904568254 .$$
The hypothesis $q_0 < p$ holds because $79/718 = 0.1100278551\ldots$ is below the
certified lower bound $0.11002786$ of the eight-decimal enclosure; the hypothesis
$p < q_1$ is that enclosure's upper bound. The value bracket is Corollary 6.3;
the derivative bracket is Theorem 6.5. The conclusion gives
$$\frac{79}{718} + \frac{A_1}{U} \;<\; p \;<\; \frac{79}{718} + \frac{A_2}{L},$$
and evaluating the two rational endpoints exactly,
$$0.110027864438358347\ldots \;<\; p \;<\; 0.110027864438360514\ldots,$$
an interval of width $2.166\times 10^{-15}$, which is contained in
$(0.1100278644383,\ 0.1100278644384)$. $\square$

### Corollary 7.2 (Thirteen decimal digits)

$$\lfloor 10^{13}\, p_\star \rfloor \;=\; 1100278644383 .$$

### Theorem 7.3 (Certified constant, unique)

There is exactly one real $p$ with
$$p \in [0,\tfrac12], \qquad r(p) = 0, \qquad \lfloor 10^{13} p\rfloor = 1100278644383 .$$

*Proof sketch.* Existence and uniqueness of the root is Proposition 2.3;
Corollary 7.2 supplies the third condition for that root, and any $p$ satisfying
the first two conditions equals it. $\square$

### Theorem 7.4 (Certified error of the textbook value)

$$2.786\times10^{-5} \;<\; \left|p_\star - \tfrac{11}{100}\right| \;<\; 2.787\times 10^{-5} .$$
In particular $p_\star > 11/100$: quoting $11\%$ *understates* the tolerable
error rate, by $2.7864438\ldots\times 10^{-5}$ in absolute error rate, i.e. by a
relative $2.53\times10^{-4}$.

*Proof sketch.* From the eight-decimal enclosure $0.11002786 < p_\star <
0.11002787$, the difference $p_\star - 0.11$ is positive, so the absolute value
may be dropped, and the two bounds follow by subtraction. $\square$

### Summary of the refinement chain

| Stage | Method | Enclosure | Certified decimals |
|---|---|---|---|
| Baseline | elementary bounds | $(0.0625,\ 0.125)$ | 0 |
| 1 | integer certificates at $b = 10^4$ | $(0.1100,\ 0.1101)$ | 4 |
| 2 | mean value step, anchor $11/100$, crude $\log$ bounds | $(0.110027,\ 0.110029)$ | 6 |
| 3 | mean value step, anchor $11/100$, Padé bounds | $(0.11002786,\ 0.11002787)$ | 8 |
| 4 | mean value step, anchor $79/718$, Padé bounds | width $2.17\times10^{-15}$ | 13 |

---

## 8. Algorithms

### 8.1 Sign decision at a rational

**Input:** positive integers $a, c$. **Output:** the sign of $r(a/(a+c))$.

Compute $D = (a+c)^{2(a+c)}$ and $N = 2^{a+c}a^{2a}c^{2c}$ as exact integers and
compare. Correctness is Theorem 3.2. With binary powering and fast
multiplication the cost is $\tilde O(b \log b)$ bit operations for $b = a+c$; with
naive repeated multiplication it is $\Theta(b^2)$, which is the practical
bottleneck in exact-verification settings.

### 8.2 Value bracket at a rational (Padé certificate)

**Input:** positive integers $a, c$ and a precision parameter $n = 10^{s}$.
**Output:** rationals $v_-, v_+$ with $v_- < r(a/(a+c)) < v_+$.

Compute $N, D$; set $m_- = \lfloor n N / D\rfloor$ and $m_+ = m_- + 1$, so that
$m_- D < nN < m_+ D$ (assuming $D \nmid nN$). Then Theorem 4.3 gives
$$v_- = \frac{1}{a+c}\cdot\frac{2(m_-/n - 1)}{m_-/n + 1},
\qquad
v_+ = \frac{1}{a+c}\cdot\frac{m_+/n - n/m_+}{2}.$$
The width of $[v_-, v_+]$ is $O\!\left(\frac{1}{(a+c)\,n}\right)$ plus the Padé
slack $O((N/D - 1)^3)$; with $s \approx 20$ the first term dominates and the
bracket is tight to twenty significant figures.

### 8.3 Continued-fraction anchor selection

**Input:** a high-precision approximation of $p_\star$ and a denominator budget
$Q_{\max}$. **Output:** the best anchor.

Run the Euclidean/Gauss map: $x_0 = p_\star$, $a_k = \lfloor x_k\rfloor$,
$x_{k+1} = (x_k - a_k)^{-1}$, accumulating convergents by the recurrences
$p_k = a_kp_{k-1} + p_{k-2}$, $q_k = a_kq_{k-1} + q_{k-2}$. Return the convergent
of largest $q_k \le Q_{\max}$. Cost $O(\log Q_{\max})$ steps. (The approximation
used here need not be trusted: it only *selects* the anchor, whose position is
subsequently certified by §8.1–8.2.)

### 8.4 The full certification pipeline

1. Select an anchor $q_0 = a/(a+c)$ from §8.3 within the arithmetic budget.
2. Certify $q_0 < p_\star$ by §8.1, and obtain $q_1 > p_\star$ from the previous
   stage's enclosure.
3. Certify $A_1 < \tfrac12 r(q_0) < A_2$ by §8.2.
4. Certify $L \le H_2' \le U$ on $[q_0,q_1]$: by monotonicity this is two
   logarithms of explicit rationals; split off the nearest power of $2$ and apply
   Lemma 4.2 to the residue.
5. Output $\left(q_0 + \frac{A_1}{U},\ q_0 + \frac{A_2}{L}\right)$ by Theorem 5.2.

Every arrow in this pipeline is an implication between proved inequalities; the
only numerical inputs are exact integers and a two-sided rational bound on
$\log 2$.

---

## 9. Cost analysis: the quartic law

Let $q$ denote the denominator of the anchor.

* **Cost.** The certificate integers have $\Theta(q\log q)$ digits. Under exact
  integer arithmetic with schoolbook or kernel-level multiplication the
  comparison costs $\Theta(q^2)$ up to logarithmic factors.
* **Precision.** A convergent of denominator $q$ satisfies
  $\frac{1}{q_k(q_{k+1}+q_k)} < \delta = |p_\star - p_k/q_k| < \frac{1}{q_kq_{k+1}}$,
  so $\delta \asymp q^{-2}$ whenever the partial quotients are bounded. By
  Corollary 5.3 one mean-value step then yields an
  enclosure of width $\varepsilon \approx 4.9\,\delta^2 \approx q^{-4}$.

Eliminating $q$: $q \approx \varepsilon^{-1/4}$, so the cost to reach width
$\varepsilon$ is $\approx \varepsilon^{-1/2}$. By contrast, the pure arithmetic
scheme of §3, which certifies decimals directly, needs $q \approx
\varepsilon^{-1}$ and hence cost $\varepsilon^{-2}$; and a decimal-anchored
mean-value scheme needs $q \approx \varepsilon^{-1/2}$ and cost
$\varepsilon^{-1}$. **The Diophantine anchor halves the cost exponent twice.**

Concretely, our numbers: the four-decimal stage used $80\,000$-digit integers to
reach $\varepsilon = 10^{-4}$; the thirteen-decimal stage used $4102$-digit
integers to reach $\varepsilon = 2\times10^{-15}$. Extrapolating with the next
convergent $16466/149653$ ($\delta \approx 2.1\times 10^{-11}$, certificate
integers of $\approx 1.6\times 10^{6}$ digits) would give
$\varepsilon \approx 2\times 10^{-21}$: twenty-one certified decimals.

A secondary limit eventually binds. The derivative bracket inherits the accuracy
of the input bound on $\log 2$; with nine certified digits of $\log 2$ the
contribution to the final width is below $10^{-17}$, so it is invisible at
thirteen decimals but becomes the leading term somewhere around eighteen. Beyond
that, a sharper certified $\log 2$ must be supplied.

---

## 10. Discussion

### 10.1 What is actually certified

Every statement in §7 is a chain of implications from: (a) the definition of
$H_2$; (b) exact integer comparisons; (c) the Padé inequalities of Lemma 4.2,
proved from the sign of an explicit derivative; (d) the mean value theorem;
(e) a two-sided rational bound on $\log 2$. There is no interval arithmetic over
floating point, no numerically evaluated transcendental, and no step in which an
approximation is silently treated as exact. In particular, the high-precision
value of $p_\star$ used to *choose* the anchor plays no logical role: had it been
wrong, the anchor certificates of Proposition 6.2 would simply have failed.

### 10.2 Why the anchor need not be assumed close

A frequent worry about Newton-type enclosures is circularity: one seems to need
to know where the root is in order to place the anchor. Theorem 5.2 has no such
hypothesis. It requires only $q_0 < p < q_1$ and the two brackets, all of which
are certified independently. A badly chosen anchor produces a valid but wide
enclosure; it never produces a false one.

### 10.3 Interpretation for quantum key distribution

The threshold governs the qualitative feasibility of one-way BB84
post-processing, and the certified statement clarifies three things.

1. **The classical figure is safe but conservative.** $11\%$ lies strictly below
   $p_\star$, so any device certified at $Q \le 11\%$ genuinely produces key. The
   unused margin is $2.7864438\ldots\times 10^{-5}$.
2. **The rate at $11\%$ is now known quantitatively.** $r(0.11) =
   1.16506723\ldots\times 10^{-4}$ nats per sifted bit, with certified bounds
   $10^{-4} < r(0.11) < 1.2\times10^{-4}$ available from the crudest stage and
   ten-significant-figure bounds from the Padé stage. A device operating exactly
   at $11\%$ retains roughly one secret bit per $6000$ sifted bits.
3. **Downstream error propagation is quantified.** Finite-key and decoy-state
   analyses that insert "$0.11$" for the threshold now carry a known, rather than
   unknown, systematic offset.

### 10.4 Limitations

The rate function analysed here is the standard asymptotic one-way
collective-attack expression $\log 2 - 2H_2(Q)$. Two-way post-processing,
advantage distillation, finite-key corrections, imperfect sources, and
device-independent settings all have different rate functions and hence different
thresholds; the *method* transfers but the constant does not. Additionally, the
pipeline as stated exploits the special structure of $H_2$ at rational arguments
— namely that $\exp(2(a+c)H_2(a/(a+c)))$ is rational — which is what makes the
sign criterion an exact integer comparison. Functions without this structure need
a substitute for §3, though §§4–6 apply unchanged once one has *any* certified
value bracket.

---

## 11. Future directions

### Conjecture 11.1 (Quartic certification law)

Let $f$ be real-analytic with a simple root $p_\star$ in an interval on which
$f'$ is bounded away from $0$, and suppose the sign of $f$ at any rational $a/b$
is decidable by an integer comparison of size $O(b\log b)$. Then a certified
enclosure of $p_\star$ of width $\varepsilon$ is obtainable at arithmetic cost
$O(\varepsilon^{-1/2})$, rather than $O(\varepsilon^{-1})$, by anchoring at
continued-fraction convergents of $p_\star$.

The mechanism is exactly Corollary 5.3 combined with the best-approximation
property: a mean-value step converts an anchor of quality $\delta$ into an
enclosure of width $\Theta(\delta^2)$, while convergents deliver
$\delta \asymp q^{-2}$ at cost $q^2$. All ingredients are in place; what remains
is the abstraction over $f$.

### Conjecture 11.2 (Binary-powering certificates break the $b^2$ wall)

Replacing linearly-unfolded exponentiation by a verified binary-powering routine
makes the certificate at denominator $b = 10^6$ feasible, after which the *pure
arithmetic* scheme of §3 alone — with no analysis at all — certifies $p_\star$ to
twelve decimals. The obstruction to more decimals by brute force is a property of
the evaluator, not of the threshold.

### Further directions

* **Iterating the anchor.** Apply the pipeline recursively: use the
  thirteen-decimal enclosure to select the convergent $16466/149653$, certify it,
  and take one more mean-value step, reaching $\approx 10^{-21}$.
* **Second-order steps.** Replace the mean value theorem by a Taylor step with a
  certified bound on $H_2''$ on the bracket; this would make the width cubic in
  $\delta$, giving $\varepsilon \approx q^{-6}$ and cost exponent $1/3$.
* **A catalogue of certified information-theoretic constants.** The same pipeline
  applies to the six-state protocol threshold, to two-way post-processing
  thresholds, to Rényi-entropy level sets, and to the fixed points of capacity
  equations. Each is currently known only as a floating-point number.
* **Certified $\log 2$ to arbitrary precision.** Beyond eighteen decimals, the
  input bound on $\log 2$ becomes the binding constraint; supplying it from a
  certified series with explicit tail bound removes the last soft spot.
* **Optimality of anchors.** Is the convergent always the best anchor for a given
  arithmetic budget, or can intermediate fractions (semiconvergents) do better
  once the cost of the certificate, not just the denominator, is the metric?

---

## 12. Conclusion

The BB84 error-rate threshold is
$$p_\star \;=\; 0.1100278644383\ldots,$$
certified to thirteen decimals with an interval of width $2.17\times 10^{-15}$.
The certification rests on an exact reduction of a transcendental comparison to
an integer comparison, cubic-accuracy Padé bounds for the logarithm, and a single
mean-value step from a well-chosen anchor. The decisive idea is that the anchor
should be a continued-fraction convergent of the threshold rather than a decimal:
approximation quality, not arithmetic size, is the resource that buys precision,
and the two scale with different exponents. As a by-product, the textbook value
$11\%$ is revealed to be the best rational approximation of the threshold with
denominator below $309$ — a coincidence which, on reflection, is no coincidence
at all: it is why the value entered the literature in that form.
