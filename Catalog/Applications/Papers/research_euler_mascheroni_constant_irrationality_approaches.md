# A Quadratically-Faster Midpoint Acceleration of the Euler–Mascheroni Constant

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Applications (number-theoretic constants, sequence acceleration)

---

## Abstract

The Euler–Mascheroni constant $\gamma = \lim_{n\to\infty}(H_n - \ln n)$ is
classically bracketed by two sequences with *linear* convergence: the lower
approximant $a_n = H_n - \ln(n+1)$, which increases to $\gamma$ from below, and
the upper approximant $b_n = H_n - \ln n$, which decreases to $\gamma$ from
above; both have error $\Theta(1/n)$. We introduce the **midpoint approximant**

$$m_n = H_n - \ln\!\left(n + \tfrac12\right),$$

obtained by evaluating the logarithm at the midpoint of the unit step rather
than at either endpoint. We prove that $m_n$ is strictly decreasing, converges to
$\gamma$, and bounds $\gamma$ strictly from above: $\gamma < m_n$ for every $n$.
This yields the new two-sided sandwich $a_n < \gamma < m_n$, strictly sharper on
the upper side than the classical bound. The decisive analytic input is the
elementary $\mathrm{artanh}$ inequality $2t < \ln\frac{1+t}{1-t}$ for
$t\in(0,1)$, equivalent to strict convexity of $1/x$ (Hermite–Hadamard).
Numerically the new bound overshoots by $m_n - \gamma \approx 1/(24\,n^2)$,
a quadratic acceleration over the $\Theta(1/n)$ classical endpoints. All
results have been formally verified.

---

## 1. Introduction

### 1.1 The constant and the problem

The harmonic numbers $H_n = \sum_{k=1}^{n} 1/k$ diverge logarithmically. Their
deviation from $\ln n$ converges to the **Euler–Mascheroni constant**

$$\gamma = \lim_{n\to\infty}\bigl(H_n - \ln n\bigr) = 0.5772156649\ldots$$

The constant $\gamma$ pervades analytic number theory (the average order of the
divisor function, the Mertens theorems, the Laurent expansion of the Riemann
zeta function at $s=1$), the analysis of algorithms, and the theory of special
functions: it equals $-\Gamma'(1)$, the value at $1$ of the digamma function
$\psi = \Gamma'/\Gamma$, through the identity $\psi(n+1) = H_n - \gamma$. Its
arithmetic nature remains unknown: whether $\gamma$ is rational or irrational is
a famous open problem. Consequently, sharp and rigorous two-sided numerical
enclosures of $\gamma$ are of standing interest, both as computational tools and
as raw material for irrationality programs of Apéry type.

### 1.2 The classical bracket and its limitation

Two standard sequences enclose $\gamma$:

- $a_n = H_n - \ln(n+1)$ is strictly increasing and converges to $\gamma$ from
  below;
- $b_n = H_n - \ln n$ is strictly decreasing and converges to $\gamma$ from above.

Hence $a_n < \gamma < b_n$ for all $n \ge 1$. The monotonicity of these sequences
is itself a consequence of the convexity of $1/x$: the increment
$a_{n+1} - a_n = \frac{1}{n+1} - \bigl(\ln(n+2) - \ln(n+1)\bigr)$ is positive
because $\frac{1}{n+1}$ overestimates the integral $\int_{n+1}^{n+2}\frac{dx}{x}$
(left-endpoint rule on a decreasing integrand), while $b_{n+1} - b_n =
\frac{1}{n+1} - \bigl(\ln(n+1) - \ln n\bigr)$ is negative because $\frac{1}{n+1}$
underestimates $\int_{n}^{n+1}\frac{dx}{x}$ (right-endpoint rule). Both sequences
converge only *linearly*: $b_n - \gamma \sim 1/(2n)$ and $\gamma - a_n \sim
1/(2n)$. Achieving $d$ correct digits requires $n \sim 10^{d}$ terms — a direct
inheritance of the harmonic sum's notorious sluggishness.

### 1.3 Prior acceleration strategies

Several well-known devices speed up the convergence to $\gamma$. The
Euler–Maclaurin correction $H_n - \ln n - \frac{1}{2n} + \frac{1}{12 n^2} - \cdots$
adds explicit Bernoulli-number terms and converges asymptotically but is no
longer a one-sided bound, and it requires evaluating and storing those
correction coefficients. Bessel-function and integral-based representations of
$\gamma$ converge geometrically but abandon the elementary harmonic-sum form
entirely. Sequence-transformation accelerators such as Richardson extrapolation
or the Euler transform improve the rate of a given convergent sequence at the
price of combining several terms and, again, of losing the clean monotone
enclosure that makes the classical bracket so attractive for certified
computation. By contrast, the construction below keeps the exact form
"harmonic sum minus a single logarithm," keeps a rigorous one-sided bound, keeps
strict monotonicity, and *still* gains a full order of convergence. It is, in a
precise sense, the cheapest possible upgrade to the textbook bracket.

### 1.4 Contribution

The two classical approximants differ only in the point at which the logarithm is
sampled — the right endpoint $n+1$ versus the left endpoint $n$ of a unit
interval. One is a left-endpoint quadrature of the decreasing integrand $1/x$,
the other a right-endpoint quadrature; the former overshoots and the latter
undershoots. The natural remedy, familiar from numerical integration, is to
sample at the **midpoint** $n+\tfrac12$. We prove that the resulting sequence
$m_n$ is a strictly decreasing upper approximant to $\gamma$ with the same
per-term cost but quadratically smaller error. The main theorem is $\gamma < m_n$
for all $n$, yielding the strictly improved sandwich $a_n < \gamma < m_n$.

All statements below were formally verified; the headers cite the corresponding
formal names for traceability. The exposition is self-contained: every
definition, lemma, and theorem is stated in full, and each proof sketch contains
the complete argument in outline.

---

## 2. Definitions

**Definition 1 (Harmonic numbers).**
$$H_n = \sum_{k=1}^{n} \frac{1}{k}, \qquad H_0 = 0.$$
We use throughout the recurrence $H_{n+1} = H_n + \frac{1}{n+1}$.

**Definition 2 (Midpoint approximant; `midpointSeq`).**
For $n \in \mathbb{N}$,
$$m_n = H_n - \ln\!\left(n + \tfrac12\right).$$

For comparison we use the two classical sequences
$$a_n = H_n - \ln(n+1), \qquad b_n = H_n - \ln n,$$
and the constant $\gamma = \lim_{n\to\infty} a_n$, with the established facts
$a_n \uparrow \gamma$, $b_n \downarrow \gamma$, and $a_n < \gamma < b_n$.

The three approximants share the same harmonic head $H_n$ and differ only by the
*shift* inside the logarithm: $a_n, m_n, b_n$ subtract $\ln(n+1)$, $\ln(n+\tfrac12)$,
$\ln n$ respectively. This places $m_n$ structurally between $a_n$ and $b_n$, the
key fact behind both the squeeze (Theorem 4) and the improved sandwich (Theorem 7).

---

## 3. The engine inequality

**Lemma 1 (`two_mul_lt_log_div`).**
For every $t \in (0,1)$,
$$2t \;<\; \ln\!\left(\frac{1+t}{1-t}\right).$$

*Proof sketch.* Let $f(x) = \ln(1+x) - \ln(1-x) - 2x$ on $[0,t]$. Then $f(0)=0$.
The function is differentiable on $(-1,1)$, and
$$f'(x) = \frac{1}{1+x} + \frac{1}{1-x} - 2
= \frac{(1-x)+(1+x)}{1-x^2} - 2
= \frac{2}{1-x^2} - 2
= \frac{2x^2}{1-x^2}.$$
For $x \in (0,t) \subset (0,1)$ we have $1 - x^2 > 0$ and $x^2 > 0$, so $f'(x) > 0$.
By the Mean Value Theorem there is $c \in (0,t)$ with
$f(t) - f(0) = f'(c)\,(t-0)$; since $f'(c) > 0$ and $t > 0$, this gives $f(t) > 0$,
which is precisely $2t < \ln(1+t) - \ln(1-t) = \ln\frac{1+t}{1-t}$. $\qquad\blacksquare$

The right-hand side equals $2\,\mathrm{artanh}(t) = 2t + \tfrac23 t^3 + \tfrac25
t^5 + \cdots$; the lemma states the positivity of the cubic-and-higher tail, the
analytic shadow of strict convexity of $x \mapsto 1/x$. The gap
$g(t) = \ln\frac{1+t}{1-t} - 2t = \tfrac23 t^3 + O(t^5)$ is itself $\Theta(t^3)$
near $0$, a fact that will reappear as the $\Theta(1/n^3)$ per-step decrement in
Section 7 and ultimately as the $\Theta(1/n^2)$ error of $m_n$.

---

## 4. Monotonicity

**Lemma 2 (Per-step decrease; `midpoint_step`).**
For every $n \in \mathbb{N}$,
$$\frac{1}{n+1} \;<\; \ln\!\left(n+\tfrac32\right) - \ln\!\left(n+\tfrac12\right).$$

*Proof sketch.* Set $t = \dfrac{1}{2n+2} \in (0,1)$. A direct computation gives
$$\frac{1+t}{1-t} = \frac{1 + \frac{1}{2n+2}}{1 - \frac{1}{2n+2}}
= \frac{2n+3}{2n+1} = \frac{n+3/2}{n+1/2},$$
so the right side of Lemma 1 is exactly $\ln(n+\tfrac32) - \ln(n+\tfrac12)$,
while its left side $2t = \frac{2}{2n+2} = 1/(n+1)$. Lemma 1 then yields the
claim. $\qquad\blacksquare$

**Geometric reading (Hermite–Hadamard).** The increment of the logarithm term is
the exact area under $1/x$ over $[n+\tfrac12, n+\tfrac32]$:
$$\ln\!\left(n+\tfrac32\right) - \ln\!\left(n+\tfrac12\right)
= \int_{n+1/2}^{n+3/2}\frac{dx}{x}.$$
The interval has width $1$ and midpoint $n+1$. For a strictly convex integrand,
the Hermite–Hadamard inequality states that the integral strictly exceeds the
midpoint rectangle, whose area here is $1 \cdot \frac{1}{n+1}$. Thus the
logarithm grows by strictly more than $1/(n+1)$ per step, which is exactly the
amount the harmonic term grows. Lemma 2 is the analytic certificate of this
geometric fact, with $1/x$ as the convex function.

**Theorem 3 (Strict monotonicity; `strictAnti_midpointSeq`).**
The sequence $(m_n)_{n\in\mathbb{N}}$ is strictly decreasing.

*Proof sketch.* Using $H_{n+1} = H_n + \frac{1}{n+1}$, the increment is
$$m_{n+1} - m_n = \Bigl(H_{n+1} - H_n\Bigr) - \Bigl[\ln\!\left(n+\tfrac32\right) - \ln\!\left(n+\tfrac12\right)\Bigr]
= \frac{1}{n+1} - \Bigl[\ln\!\left(n+\tfrac32\right) - \ln\!\left(n+\tfrac12\right)\Bigr].$$
By Lemma 2 the bracketed term exceeds $1/(n+1)$, so $m_{n+1} - m_n < 0$. Since
this holds for every $n$, the sequence is strictly decreasing. $\qquad\blacksquare$

---

## 5. Convergence and the main bound

**Theorem 4 (Convergence; `tendsto_midpointSeq`).**
$$\lim_{n\to\infty} m_n = \gamma.$$

*Proof sketch.* For $n \ge 1$ the monotonicity of $\ln$ gives
$\ln n \le \ln(n+\tfrac12) \le \ln(n+1)$, hence, subtracting from the common
$H_n$ and reversing,
$$a_n = H_n - \ln(n+1) \;\le\; H_n - \ln(n+\tfrac12) = m_n \;\le\; H_n - \ln n = b_n.$$
Since $a_n \to \gamma$ and $b_n \to \gamma$, the squeeze theorem gives
$m_n \to \gamma$. $\qquad\blacksquare$

**Theorem 5 (Main result — approach from above; `eulerMascheroniConstant_lt_midpointSeq`).**
For every $n \in \mathbb{N}$,
$$\gamma \;<\; m_n.$$

*Proof sketch.* Fix $n$. By Theorem 3, for all $k \ge n+1$ we have
$m_k \le m_{n+1}$. Taking $k \to \infty$ and using Theorem 4, the limit
$\gamma = \lim_k m_k$ inherits the weak inequality $\gamma \le m_{n+1}$. Combining
with the strict step $m_{n+1} < m_n$ (Theorem 3) yields
$\gamma \le m_{n+1} < m_n$, hence $\gamma < m_n$. $\qquad\blacksquare$

*Remark.* The strict bound $\gamma < m_n$ does **not** follow from the classical
$\gamma < b_n$. Because $m_n < b_n$ for $n\ge1$ (the right inequality of Theorem 4,
strict), comparison with $b_n$ alone gives only the upper estimate $m_n < b_n$ and
provides no lower bound on $m_n - \gamma$. A naive attempt to "inherit" the
from-above property from $b_n$ therefore fails. The guarantee genuinely requires
the monotone-limit argument: a strictly decreasing sequence converging to a limit
stays strictly above that limit.

---

## 6. The improved sandwich

**Theorem 6 (Improvement over the lower approximant; `eulerMascheroniSeq_lt_midpointSeq`).**
For every $n \in \mathbb{N}$,
$$a_n = H_n - \ln(n+1) \;<\; H_n - \ln\!\left(n+\tfrac12\right) = m_n.$$

*Proof sketch.* Since $n+\tfrac12 < n+1$ and $\ln$ is strictly increasing,
$\ln(n+\tfrac12) < \ln(n+1)$; subtracting both from $H_n$ reverses the
inequality. $\qquad\blacksquare$

**Theorem 7 (New two-sided sandwich; `midpointSeq_sandwich`).**
For every $n \in \mathbb{N}$,
$$a_n \;<\; \gamma \;<\; m_n,
\qquad\text{i.e.}\qquad
H_n - \ln(n+1) \;<\; \gamma \;<\; H_n - \ln\!\left(n+\tfrac12\right).$$

*Proof sketch.* The left inequality is the classical $a_n < \gamma$; the right
inequality is Theorem 5. $\qquad\blacksquare$

The new sandwich is non-vacuous and strictly tighter on the upper side: the upper
edge has moved from $b_n = H_n - \ln n$ down to $m_n = H_n - \ln(n+\tfrac12)$,
while remaining a valid upper bound on $\gamma$. The midpoint $m_n$ is in fact the
best one-logarithm upper bound on $\gamma$ in the shifted family
$s_c(n) = H_n - \ln(n+c)$: as $c$ increases from $0$, $s_c(n)$ decreases, and the
threshold value of $c$ below which $s_c(n)$ remains $\ge \gamma$ for all $n$ is
governed by the first-order coefficient $\tfrac12 - c$ discussed in Section 10.

---

## 7. Quantitative rate (numerical)

The proved results establish *sign and monotonicity*; the *rate* is an empirical
observation, recorded here as a numerical finding rather than a theorem.

### 7.1 The decrement and its sum

Writing $t_n = \frac{1}{2n+2}$, the per-step decrement is
$$d_n = m_n - m_{n+1} = \bigl[\ln(n+\tfrac32) - \ln(n+\tfrac12)\bigr] - \frac{1}{n+1}
= 2\,\mathrm{artanh}(t_n) - 2t_n = \frac{2}{3}t_n^3 + \frac{2}{5}t_n^5 + \cdots,$$
which is positive (Lemma 2) and of order $\Theta(1/n^3)$ since
$t_n \sim 1/(2n)$. Because $(m_n)$ decreases to $\gamma$ (Theorems 3–5), the
overshoot telescopes:
$$m_n - \gamma = \sum_{k\ge n} d_k = \sum_{k \ge n}\Theta\!\left(\frac{1}{k^3}\right)
= \Theta\!\left(\frac{1}{n^2}\right).$$
A more precise accounting via the leading term $d_k \approx \frac{2}{3}t_k^3
\approx \frac{1}{12 k^3}$ and the integral comparison
$\sum_{k\ge n} 1/k^3 \approx 1/(2 n^2)$ gives the leading constant
$$m_n - \gamma \;\sim\; \frac{1}{24\,n^2}.$$
The same constant arises directly from the Euler–Maclaurin expansion
$H_n = \ln n + \gamma + \frac{1}{2n} - \frac{1}{12 n^2} + O(1/n^4)$ together with
$\ln(n+\tfrac12) = \ln n + \frac{1}{2n} - \frac{1}{8 n^2} + O(1/n^3)$, whose
difference yields $m_n - \gamma = \bigl(\tfrac18 - \tfrac{1}{12}\bigr)\frac{1}{n^2}
+ O(1/n^3) = \frac{1}{24 n^2} + O(1/n^3)$; note the $1/n$ terms cancel exactly,
which is the precise reason the midpoint shift is first-order optimal.

### 7.2 Empirical data

Computed in double precision (see `demo.py`):

| $n$ | $m_n - \gamma$ | $n^2 (m_n-\gamma)$ | classical $b_n - \gamma$ | $2n(b_n-\gamma)$ |
|----:|---------------:|-------------------:|-------------------------:|-----------------:|
|   1 | 0.01731923 | 0.017319 | 0.422784 | 0.845569 |
|   2 | 0.00649360 | 0.025974 | 0.229637 | 0.918549 |
|   5 | 0.00136958 | 0.034239 | 0.096680 | 0.966798 |
|  10 | 0.00037733 | 0.037733 | 0.049167 | 0.983350 |
|  20 | 0.00009911 | 0.039642 | 0.024792 | 0.991669 |
|  50 | 0.00001634 | 0.040843 | 0.009967 | 0.996667 |
| 100 | 0.00000413 | 0.041252 | 0.004992 | 0.998333 |
| 200 | 0.00000104 | 0.041459 | 0.002498 | 0.999167 |
|1000 | 0.00000004 | 0.041625 | 0.000500 | 0.999833 |

The column $n^2(m_n-\gamma)$ converges to $1/24 = 0.0416\overline{6}$, confirming
the quadratic law and its constant, while $2n(b_n-\gamma) \to 1$ confirms the
classical linear rate $b_n - \gamma \sim 1/(2n)$. At $n = 100$ the classical bound
is still wrong in the third decimal place while the midpoint bound is correct to
roughly six — a hundredfold accuracy gain at identical cost.

---

## 8. Algorithms

### 8.1 Rigorous enclosure of $\gamma$ (`MidpointGammaEnclosure`)

Given a target half-width $\varepsilon$, compute the smallest $n$ with
$m_n - a_n < \varepsilon$ and return the interval $[a_n, m_n]$, which provably
contains $\gamma$ (Theorem 7).

```
INPUT  epsilon > 0
n <- 1; H <- 1.0
loop:
    a <- H - ln(n+1)            # lower approximant a_n
    m <- H - ln(n + 0.5)        # midpoint approximant m_n
    if (m - a) < epsilon: return [a, m]   # a < gamma < m, width < epsilon
    n <- n + 1; H <- H + 1/n
```

The certified width $m_n - a_n = \ln(n+1) - \ln(n+\tfrac12) = \Theta(1/n)$, so the
loop terminates in $O(1/\varepsilon)$ iterations; the *midpoint estimate itself*
already attains accuracy $O(1/n^2)$, so the midpoint of the returned interval is
considerably more accurate than its half-width suggests.

### 8.2 Quadratic point estimate (`MidpointGammaEstimate`)

To estimate $\gamma$ to a tolerance $\tau$ using the quadratic rate, choose
$n \approx \sqrt{1/(24\,\tau)}$ and return $m_n$. Because $m_n - \gamma \approx
1/(24 n^2)$, this requires only $O(1/\sqrt{\tau})$ harmonic terms, versus
$O(1/\tau)$ for the classical $b_n$ — a quadratic reduction in work. For example,
$\tau = 10^{-8}$ needs $n \approx 2042$ midpoint terms rather than the
$\sim 5\times 10^{7}$ terms a linear approximant would demand.

---

## 9. Applications

- **Computational enclosure.** Theorem 7 provides a certified interval for
  $\gamma$ from a single harmonic sum and two logarithms, with a strictly tighter
  upper edge than the textbook bound. This is directly usable in interval
  arithmetic and verified-computation libraries.
- **Building block for accelerators.** The clean residual $1/(24 n^2)$ is the
  natural seed for Richardson-style extrapolation (Section 10), which can cancel
  successive even-order terms.
- **Digamma and harmonic asymptotics.** Through $\psi(n+1) = H_n - \gamma$, the
  midpoint shift corresponds to the classical asymptotic
  $\psi(x) \approx \ln(x - \tfrac12)$, the most accurate one-logarithm
  approximation of the digamma function; Theorem 5 is its rigorous, monotone,
  one-sided counterpart on the integers.
- **Pedagogy.** The result is a vivid, fully rigorous instance of the
  midpoint/symmetrization principle: sampling a convex integrand at the center of
  an interval cancels the leading (odd) error term, converting $\Theta(1/n)$ into
  $\Theta(1/n^2)$ — the same idea behind the midpoint and Simpson quadrature
  rules and centered finite differences.

---

## 10. Discussion and future work

The midpoint approximant exploits a structural symmetry: the linear error of the
one-sided approximants is *odd* about the midpoint of the unit step and therefore
cancels, exposing the smaller even term $1/(24 n^2)$. This invites three
sharpenings, stated as conjectures.

**Conjecture 1 (Explicit quadratic bound).** For all $n \ge 1$,
$m_n - \gamma \le 1/(12 n^2)$, with sharp asymptotic constant $1/24$. The route:
dominate each decrement $d_k = 2\,\mathrm{artanh}(t_k) - 2t_k$ by a telescoping
difference $d_k \le \tfrac{1}{12}\bigl(1/k^2 - 1/(k+1)^2\bigr)$, whose tail sums
exactly to $1/(12 n^2)$. The single remaining per-term transcendental inequality
is of the same convexity/$\mathrm{artanh}$ type as Lemma 1, and is empirically
verified for all $k \le 100$.

**Conjecture 2 (Optimal shift uniqueness).** For the shifted family
$s_c(n) = H_n - \ln(n+c)$, one has $n\,(s_c(n) - \gamma) \to (\tfrac12 - c)$, so
$s_c(n) - \gamma = o(1/n)$ **iff** $c = \tfrac12$. This follows from the harmonic
asymptotic $H_n = \ln n + \gamma + \tfrac{1}{2n} + O(1/n^2)$ together with
$\ln(n+c) = \ln n + c/n + O(1/n^2)$, giving $s_c(n) - \gamma = (\tfrac12 - c)/n +
O(1/n^2)$. The midpoint $c = \tfrac12$ is the unique first-order-optimal shift —
the *only* one-logarithm shift achieving the quadratic rate.

**Conjecture 3 (Quartic accelerator).** The doubly-shifted sequence
$H_n - \ln\!\left(n + \tfrac12 + \tfrac{1}{24 n}\right)$ converges to $\gamma$
with error $O(1/n^4)$: absorbing the residual $1/(24 n^2)$ into the logarithm's
argument cancels the quadratic term, and the cubic term is absent by the parity
of the $\mathrm{artanh}$ expansion, pushing the first surviving error to order
$1/n^4$.

Beyond these, the midpoint enclosure can feed Apéry-style rational-approximation
machinery, and the same Hermite–Hadamard mechanism extends to the Stieltjes
constants (the higher coefficients $\gamma_k$ in the Laurent expansion
$\zeta(s) = \frac{1}{s-1} + \sum_{k\ge0} \frac{(-1)^k}{k!}\gamma_k (s-1)^k$ at
$s=1$, with $\gamma_0 = \gamma$).

---

## 11. Conclusion

By the single expedient of sampling the logarithm at the midpoint of the unit
step, the approximant $m_n = H_n - \ln(n+\tfrac12)$ becomes a strictly
decreasing, provably-from-above estimate of the Euler–Mascheroni constant,
$\gamma < m_n$, with the improved sandwich $H_n - \ln(n+1) < \gamma < H_n -
\ln(n+\tfrac12)$. The cost is identical to the classical bound, yet the error
falls from $\Theta(1/n)$ to $\Theta(1/n^2)$ with leading constant $1/24$. The
proof rests on one elementary inequality, $2t < \ln\frac{1+t}{1-t}$, the analytic
face of the convexity of $1/x$ — a small change of aim with an outsized payoff.

---

## Appendix: Formal result index

| Formal name | Statement |
|---|---|
| `midpointSeq` | $m_n = H_n - \ln(n+\tfrac12)$ |
| `two_mul_lt_log_div` | $t\in(0,1) \Rightarrow 2t < \ln\frac{1+t}{1-t}$ |
| `midpoint_step` | $\frac{1}{n+1} < \ln(n+\tfrac32) - \ln(n+\tfrac12)$ |
| `strictAnti_midpointSeq` | $(m_n)$ strictly decreasing |
| `tendsto_midpointSeq` | $m_n \to \gamma$ |
| `eulerMascheroniConstant_lt_midpointSeq` | $\gamma < m_n$ |
| `eulerMascheroniSeq_lt_midpointSeq` | $a_n < m_n$ |
| `midpointSeq_sandwich` | $a_n < \gamma < m_n$ |
