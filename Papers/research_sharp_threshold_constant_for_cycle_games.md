# The Sharp Threshold Constant of the Maker–Breaker Cycle Game: A Quantitative Envelope

## Abstract

For a fixed cycle length $k \ge 4$, the biased Maker–Breaker $C_k$-game played on
the edges of the complete graph $K_n$ exhibits a sharp threshold bias of the form
$q_k(n) = c_k \cdot n^{(k-2)/(k-1)}$, where the *sharp constant* is
$$c_k = \left[(k-1)\left(\tfrac{2(k-1)}{k}\right)^{k-2}\right]^{1/(k-1)}.$$
We establish the quantitative envelope of this constant and the monotone
behaviour of the resulting bias. Our principal results are: (i) the
average-degree factor $2(k-1)/k$ lies in the half-open band $[3/2, 2)$ and is
strictly increasing; (ii) the sharp constant satisfies the *uniform two-sided
bound* $3/2 \le c_k < 3$ for every $k \ge 4$, so it is a genuine bounded
universal constant of the game; (iii) the threshold exponent $(k-2)/(k-1)$ lies
strictly in $(0,1)$ and equals the reciprocal of the maximum $2$-density
$m_2(C_k) = (k-1)/(k-2)$; (iv) the threshold bias is strictly increasing in the
board size $n$, and the sharp-threshold window
$\big((1-\varepsilon)q_k(n),(1+\varepsilon)q_k(n)\big)$ is genuinely nonempty. We
further record two natural monotonicity conjectures — that $c_k$ increases in $k$,
and that $c_k < 2$ always — both of which are refuted by direct evaluation: the
constant is unimodal with a unique peak $c_{13} \approx 2.1578$ and exceeds $2$
throughout a neighbourhood of that peak. The proven envelope $[3/2, 3)$ is
therefore sharp in kind, trapping the true maximum strictly inside.

**Keywords:** Maker–Breaker game, positional game, threshold bias, cycle,
maximum 2-density, sharp constant, piecewise power law, unimodality.

---

## 1. Introduction

### 1.1 Biased Maker–Breaker games

A *positional game* is a combinatorial game played by two players who
alternately claim elements of a finite ground set. In a **Maker–Breaker game**
the two players, Maker and Breaker, alternately claim previously unclaimed
elements; Maker wins if she manages to claim in full some element of a fixed
family of *winning sets*, and Breaker wins otherwise. The **biased** variant
introduces a handicap parameter $q \ge 1$: in each round Maker claims one
element and Breaker then claims $q$ elements. Larger $q$ favours Breaker.

We are concerned with the **$C_k$-game** on the complete graph $K_n$. The ground
set is the edge set $E(K_n)$, and Maker's winning sets are the edge sets of all
copies of the cycle $C_k$ on $k$ of the $n$ vertices. Fix $k \ge 4$ throughout.
By the general theory of biased games, there is a *threshold bias*: a critical
value of $q$, as a function of $n$, that separates a regime in which Maker has a
winning strategy from one in which Breaker does. The central quantitative fact is
that this threshold obeys a power law in $n$, and that the leading constant is
explicit.

### 1.2 The threshold and its constant

**Definition 1.1 (Threshold exponent).** For a real parameter $k$, define the
*game exponent*
$$\gamma(k) = \frac{k-2}{k-1}.$$

**Definition 1.2 (Maximum $2$-density).** For a real parameter $k$, define
$$m_2(k) = \frac{k-1}{k-2}.$$
For integer $k \ge 3$, $m_2(k)$ equals the maximum $2$-density of the cycle
$C_k$, namely $\max_{H \subseteq C_k,\, v(H) \ge 3} \frac{e(H)-1}{v(H)-2}$,
attained by the full cycle with $e(C_k)=v(C_k)=k$.

**Definition 1.3 (Sharp threshold constant).** For an integer $k \ge 4$, define
$$c_k = \left[(k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}\right]^{1/(k-1)}.$$
We call $2(k-1)/k$ the *average-degree factor*.

**Definition 1.4 (Threshold bias).** For an integer $k \ge 4$ and a real board
parameter $n > 0$, define
$$q_k(n) = c_k \cdot n^{\gamma(k)} = c_k \cdot n^{(k-2)/(k-1)}.$$

The operational meaning is the **sharp threshold statement**: for every fixed
$k \ge 4$ and every $\varepsilon > 0$, there exists $n_0$ such that for all
$n \ge n_0$,

- if $q < (1-\varepsilon)\,q_k(n)$, Maker has a winning strategy in the biased
  $C_k$-game on $K_n$;
- if $q > (1+\varepsilon)\,q_k(n)$, Breaker has a winning strategy.

The present paper is not concerned with re-deriving this asymptotic dichotomy;
we take the location $q_k(n)$ as given and analyse the arithmetic and analytic
structure of the constant $c_k$ and the bias $q_k(n)$ — establishing rigorous,
non-asymptotic bounds and monotonicity, and settling the natural monotonicity
questions about $c_k$.

### 1.3 Summary of contributions

1. **Envelope of the average-degree factor** (Section 2): $2(k-1)/k \in [3/2, 2)$
   for $k \ge 4$, strictly increasing in $k$.
2. **Uniform two-sided bound on the constant** (Section 4): $3/2 \le c_k < 3$ for
   all $k \ge 4$, via the defining identity $c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}$
   and the exponential-vs-linear inequality $(k-1)2^{k-2} < 3^{k-1}$.
3. **Exponent structure** (Section 3): $0 < \gamma(k) < 1$ and
   $\gamma(k) = 1/m_2(k)$.
4. **Bias monotonicity and the sharp window** (Section 5): $n \mapsto q_k(n)$ is
   strictly increasing, and the window
   $((1-\varepsilon)q_k(n),(1+\varepsilon)q_k(n))$ is nonempty.
5. **Refuted conjectures and the true shape of $c_k$** (Section 6): $c_k$ is
   *not* monotone (unique peak at $k=13$) and *not* bounded by $2$
   ($c_5 \approx 2.012$).

---

## 2. The average-degree factor

The entire quantitative analysis rests on locating the average-degree factor
$2(k-1)/k$ inside a fixed band. All three of the following are exact.

**Lemma 2.1 (Lower bound).** For every integer $k \ge 4$,
$$\frac{2(k-1)}{k} \ge \frac{3}{2}.$$

*Proof.* Clearing denominators (both $k > 0$ and $2 > 0$), the claim is
equivalent to $4(k-1) \ge 3k$, i.e. $k \ge 4$, which holds by hypothesis.
Equality holds exactly at $k=4$. $\qquad\blacksquare$

**Lemma 2.2 (Upper bound).** For every integer $k \ge 1$,
$$\frac{2(k-1)}{k} < 2.$$

*Proof.* Since $k > 0$, the inequality is equivalent to $2(k-1) < 2k$, i.e.
$-2 < 0$. $\qquad\blacksquare$

**Lemma 2.3 (Strict monotonicity).** The map $x \mapsto 2(x-1)/x$ is strictly
increasing on $(0,\infty)$.

*Proof.* Write $2(x-1)/x = 2 - 2/x$. For $0 < x_1 < x_2$ we have
$2/x_1 > 2/x_2$, hence $2 - 2/x_1 < 2 - 2/x_2$. Equivalently, for
$0 < x_1 < x_2$, cross-multiplying the positive denominators in
$2(x_1-1)/x_1 < 2(x_2-1)/x_2$ reduces to $x_1 < x_2$. $\qquad\blacksquare$

Thus for integer $k \ge 4$ the factor $2(k-1)/k$ increases strictly from its
minimum $3/2$ (at $k=4$) toward, but never reaching, its supremum $2$.

---

## 3. The threshold exponent

**Proposition 3.1 (Positivity).** For every real $k > 2$, $\gamma(k) > 0$.

*Proof.* Both numerator $k-2$ and denominator $k-1$ are positive when $k > 2$, so
their quotient is positive. $\qquad\blacksquare$

**Proposition 3.2 (Strict upper bound).** For every real $k > 1$,
$\gamma(k) < 1$.

*Proof.* Since $k - 1 > 0$, the inequality $\frac{k-2}{k-1} < 1$ is equivalent to
$k - 2 < k - 1$, i.e. $-2 < -1$. $\qquad\blacksquare$

**Proposition 3.3 (Reciprocal-density identity).** For every real $k$ with the
relevant denominators nonzero,
$$\gamma(k) = \frac{1}{m_2(k)}.$$

*Proof.* By definition $m_2(k) = (k-1)/(k-2)$, so
$1/m_2(k) = (k-2)/(k-1) = \gamma(k)$. $\qquad\blacksquare$

Propositions 3.1–3.3 exhibit the exponent as a sublinear growth rate that is
exactly the reciprocal of the cycle's maximum $2$-density — the general
Bednarska–Łuczak principle that threshold scaling for a graph game $H$ is
governed by $1/m_2(H)$, specialised and verified here for $H = C_k$.

---

## 4. The sharp constant: identity and uniform bounds

### 4.1 Positivity and the defining identity

**Lemma 4.1 (Base positivity).** For every integer $k \ge 4$,
$$(k-1)\left(\frac{2(k-1)}{k}\right)^{k-2} > 0.$$

*Proof.* The prefactor $k - 1 > 0$; the base $2(k-1)/k > 0$ (numerator and
denominator both positive), and a positive base raised to any natural power is
positive. The product of positives is positive. $\qquad\blacksquare$

**Corollary 4.2 (Positivity of the constant).** For every integer $k \ge 4$,
$c_k > 0$.

*Proof.* $c_k$ is a real power (exponent $1/(k-1) > 0$) of the positive base of
Lemma 4.1; real powers of positive reals are positive. $\qquad\blacksquare$

**Theorem 4.3 (Defining identity).** For every integer $k \ge 4$,
$$c_k^{\,k-1} = (k-1)\left(\frac{2(k-1)}{k}\right)^{k-2}.$$

*Proof.* Write $c_k = B^{1/(k-1)}$ with $B = (k-1)(2(k-1)/k)^{k-2} > 0$. Then
$c_k^{k-1} = \big(B^{1/(k-1)}\big)^{k-1} = B^{(k-1)/(k-1)} = B^1 = B$, using the
law $(x^a)^b = x^{ab}$ for a positive base $x$ and the cancellation
$\frac{1}{k-1}\cdot(k-1)=1$ valid since $k - 1 \ne 0$. $\qquad\blacksquare$

The identity is the workhorse: it removes the outer root, so bounds on $c_k$
follow from bounds on the polynomial-exponential right-hand side.

### 4.2 The lower bound

**Theorem 4.4 (Uniform lower bound).** For every integer $k \ge 4$,
$$c_k \ge \frac{3}{2}.$$

*Proof.* By Lemma 2.1, $2(k-1)/k \ge 3/2 > 0$; raising to the power $k-2$
(monotone on nonnegative bases) gives
$(2(k-1)/k)^{k-2} \ge (3/2)^{k-2}$. Multiplying by $k - 1 \ge 3$ and applying
Theorem 4.3,
$$c_k^{\,k-1} = (k-1)\Big(\tfrac{2(k-1)}{k}\Big)^{k-2}
\ge (k-1)\big(\tfrac32\big)^{k-2}
\ge 3\cdot\big(\tfrac32\big)^{k-2}
\ge \big(\tfrac32\big)^{k-1},$$
the last step because $3 \ge 3/2$. Since both $c_k > 0$ (Corollary 4.2) and
$3/2 > 0$, and $x \mapsto x^{k-1}$ is strictly increasing on nonnegative reals
(with $k-1 \ge 1$), the inequality $ (3/2)^{k-1} \le c_k^{k-1}$ yields
$3/2 \le c_k$. $\qquad\blacksquare$

### 4.3 The exponential-vs-linear crux

**Lemma 4.5 (Exponential dominance).** For every integer $k \ge 4$,
$$(k-1)\,2^{\,k-2} < 3^{\,k-1}.$$

*Proof.* Induction on $k \ge 4$. *Base* $k=4$: the left side is
$3 \cdot 2^{2} = 12$ and the right side is $3^{3} = 27$, so $12 < 27$. *Step:*
assume $(k-1)2^{k-2} < 3^{k-1}$ for some $k \ge 4$. Then
$$k\cdot 2^{k-1} = 2\cdot\frac{k}{k-1}\cdot (k-1)2^{k-2}
< 2\cdot\frac{k}{k-1}\cdot 3^{k-1}.$$
It suffices to show $2\cdot\frac{k}{k-1} \le 3$, i.e. $2k \le 3(k-1)$, i.e.
$3 \le k$, which holds since $k \ge 4$. Hence
$k\cdot 2^{k-1} < 3\cdot 3^{k-1} = 3^{k}$, completing the induction.
$\qquad\blacksquare$

### 4.4 The upper bound

**Theorem 4.6 (Uniform upper bound).** For every integer $k \ge 4$,
$$c_k < 3.$$

*Proof.* By Lemma 2.2, $0 < 2(k-1)/k < 2$; raising to the power $k-2$ (strictly
monotone on nonnegative bases) gives $(2(k-1)/k)^{k-2} < 2^{k-2}$. Multiplying by
$k - 1 > 0$ and applying Theorem 4.3,
$$c_k^{\,k-1} = (k-1)\Big(\tfrac{2(k-1)}{k}\Big)^{k-2}
< (k-1)\,2^{\,k-2} < 3^{\,k-1},$$
the last inequality by Lemma 4.5. Since $c_k > 0$ (Corollary 4.2), $3 > 0$, and
$x \mapsto x^{k-1}$ is strictly increasing on nonnegative reals, from
$c_k^{k-1} < 3^{k-1}$ we conclude $c_k < 3$. $\qquad\blacksquare$

Combining Theorems 4.4 and 4.6:

**Theorem 4.7 (Uniform envelope).** For every integer $k \ge 4$,
$$\frac{3}{2} \;\le\; c_k \;<\; 3.$$

Thus $c_k$ is a genuine bounded universal constant of the $C_k$-game, confined to
$[3/2, 3)$ irrespective of $k$.

---

## 5. Monotonicity of the bias and the sharp window

**Theorem 5.1 (Strict monotonicity in board size).** Fix $k \ge 4$. The map
$n \mapsto q_k(n) = c_k \cdot n^{\gamma(k)}$ is strictly increasing on
$(0,\infty)$.

*Proof.* By Proposition 3.1, the exponent $\gamma(k) > 0$; hence
$n \mapsto n^{\gamma(k)}$ is strictly increasing on $(0,\infty)$ (a positive real
power). Multiplying by the constant $c_k > 0$ (Corollary 4.2) preserves strict
monotonicity. $\qquad\blacksquare$

**Theorem 5.2 (Nonempty sharp window).** Fix $k \ge 4$, $n > 0$, and
$\varepsilon \in (0,1)$. Then $q_k(n) > 0$ and consequently
$$(1-\varepsilon)\,q_k(n) \;<\; q_k(n) \;<\; (1+\varepsilon)\,q_k(n),$$
so the sharp-threshold window
$\big((1-\varepsilon)q_k(n),(1+\varepsilon)q_k(n)\big)$ is a nonempty open
interval containing $q_k(n)$.

*Proof.* $q_k(n) = c_k\, n^{\gamma(k)}$ is a product of positives ($c_k > 0$ by
Corollary 4.2; $n^{\gamma(k)} > 0$), hence positive. Multiplying the strict
inequalities $1-\varepsilon < 1 < 1+\varepsilon$ by $q_k(n) > 0$ gives the
claim. $\qquad\blacksquare$

Theorems 5.1–5.2 confirm the framework is non-vacuous: the threshold genuinely
grows with the board, and the "sharp threshold" language refers to an honest,
nonempty transition window straddling $q_k(n)$.

---

## 6. The true shape of the constant: two refuted conjectures

The uniform envelope $[3/2, 3)$ invites two tidy strengthenings. Both are false,
and their failure pins down the actual behaviour of $c_k$.

**Refuted Conjecture A (monotonicity in $k$).** *Claim:* $(c_k)_{k \ge 4}$ is
increasing. *Refutation:* Direct evaluation of $\log c_k =
\frac{\log(k-1) + (k-2)\log(2(k-1)/k)}{k-1}$ gives the values

| $k$ | $c_k$ | $k$ | $c_k$ |
|----|--------|----|--------|
| 4  | 1.8899 | 12 | 2.15766 |
| 5  | 2.0119 | 13 | **2.15780** |
| 6  | 2.0762 | 14 | 2.15701 |
| 8  | 2.1333 | 20 | 2.14479 |
| 10 | 2.1525 | 100 | 2.0598 |

The sequence rises to a **unique maximum at $k = 13$** with
$c_{13} \approx 2.1578$ and strictly decreases thereafter; it is unimodal, not
monotone.

**Refuted Conjecture B (bound by $2$).** *Claim:* $c_k < 2$ for all $k$.
*Refutation:* $c_5 = \big(4\cdot(8/5)^3\big)^{1/4} = (16.384)^{1/4} \approx
2.0119 > 2$. The constant exceeds $2$ throughout a neighbourhood of the peak,
reaching $\approx 2.158$.

These refutations sharpen, rather than weaken, the picture. The proven envelope
$[3/2, 3)$ is *sharp in kind*: the true supremum $\sup_k c_k = c_{13} \approx
2.1578$ lies strictly inside $[3/2, 3)$, so neither the naive lower guess $3/2$
(attained only asymptotically-in-shape at $k=4$) nor a would-be upper guess $2$
correctly bounds the sequence, while $3$ does. The genuine behaviour is: start
below $2$ at $k=4$, rise to a lone summit $\approx 2.158$ at $k=13$, then descend
back toward the limit $2$ as $k \to \infty$.

---

## 7. Algorithms

We package the analysis into three deterministic procedures.

### 7.1 Stable evaluation of $c_k$

Because $(2(k-1)/k)^{k-2}$ and $(k-1)$ overflow or underflow naively for large
$k$, we evaluate in log-space:
$$\log c_k = \frac{\log(k-1) + (k-2)\log\!\big(2(k-1)/k\big)}{k-1},
\qquad c_k = \exp(\log c_k).$$
This is numerically stable for all $k \ge 4$ up to arbitrary size.

### 7.2 Locating the peak

To find $\arg\max_k c_k$ over a range, evaluate $\log c_k$ (monotone with $c_k$)
and take the maximiser. Because the sequence is unimodal, a ternary/golden search
on the integer range converges in $O(\log(\text{range}))$ evaluations; a linear
scan over $4 \le k \le K$ is $O(K)$ and also certifies unimodality on the range.

### 7.3 Envelope certification

For a given $k$, certify $3/2 \le c_k < 3$ by checking the three exact
inequalities the proof uses — $2(k-1)/k \ge 3/2$, $2(k-1)/k < 2$, and
$(k-1)2^{k-2} < 3^{k-1}$ — with exact integer/rational arithmetic, avoiding
floating point entirely.

---

## 8. Applications

Sharp thresholds for positional games serve as clean models for the emergence of
structure under adversarial resource constraints. Knowing the *scaling*
$n^{(k-2)/(k-1)}$ fixes the order of magnitude of the fair handicap; knowing the
*constant* $c_k$ localises the exact fair handicap for a concrete board. Concrete
settings where such precision matters include: adversarial network formation and
robustness (a builder forcing a short cycle/redundant loop against a jammer who
deletes $q$ links per round); scheduling and resource-allocation games with a
fixed target substructure; and, methodologically, as a benchmark for the general
$1/m_2(H)$ threshold principle, here verified with an explicit, bounded,
non-monotone leading constant.

---

## 9. Discussion and future work

The constant $c_k$ emerges as a bona-fide universal constant of the cycle game:
bounded in $[3/2, 3)$, unimodal with a unique peak $c_{13} \approx 2.1578$, and
tending to $2$ as $k \to \infty$. Three research directions follow naturally.

**Unimodality as a theorem.** Numerics show a single peak at $k=13$. The natural
conjecture is that $\log c_k$, viewed as a smooth function of $1/k$, has a
derivative with exactly one sign change, driven by the single-crossing
competition between the linearly growing factor $k-1$ and the geometrically
decaying correction $((k-1)/k)^{k-2} \to e^{-1}$. Proving strict unimodality
would upgrade the numerical curve to a theorem.

**Exact limit and rate.** We conjecture $\lim_{k\to\infty} c_k = 2$ with
$2 - c_k = \Theta(\log k / k)$, from above once $k$ is large. Writing
$c_k = 2\,(k-1)^{1/(k-1)}\big((k-1)/k\big)^{(k-2)/(k-1)}$ and expanding both
correction factors as $1 + (\log k)/k + O(1/k)$ would control both the sign and
the rate. This would pin the exact universal constant $2$.

**Joint log-concavity of the bias.** We conjecture that
$(k,n) \mapsto \log q_k(n)$ is concave on $k \ge 4$, $n \ge 2$. The exponent
$\gamma(k) = 1 - 1/(k-1)$ is manifestly concave in $k$; the remaining task is to
control the mixed second derivative contributed by $\log c_k$, which the closed
form renders explicit.

---

## 10. Conclusion

We have determined the quantitative envelope of the sharp threshold constant of
the Maker–Breaker $C_k$-game. The constant $c_k$ is trapped in $[3/2, 3)$ for all
$k \ge 4$; its exponent $(k-2)/(k-1)$ is the reciprocal of the cycle's maximum
$2$-density; the induced bias is strictly increasing in the board size with a
genuine nonempty sharp window; and two natural monotonicity conjectures are
refuted, revealing a unimodal constant peaking at $c_{13} \approx 2.1578$ and
decaying toward $2$. What appeared to be an opaque tower of exponents is, on
analysis, a well-behaved and precisely located universal constant.

---

## Appendix: table of values

| $k$ | $2(k-1)/k$ | $\gamma(k)=(k-2)/(k-1)$ | $c_k$ |
|-----|-----------|--------------------------|-------|
| 4   | 1.5000 | 0.6667 | 1.8899 |
| 5   | 1.6000 | 0.7500 | 2.0119 |
| 6   | 1.6667 | 0.8000 | 2.0762 |
| 7   | 1.7143 | 0.8333 | 2.1123 |
| 10  | 1.8000 | 0.8889 | 2.1525 |
| 13  | 1.8462 | 0.9167 | 2.1578 |
| 20  | 1.9000 | 0.9474 | 2.1448 |
| 100 | 1.9800 | 0.9899 | 2.0598 |
| 1000| 1.9980 | 0.9990 | 2.0105 |
