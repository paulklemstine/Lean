# The Exact Constrained-Coset Guesswork Exponent at the Symmetric Source

## Abstract

We study the exponential growth rate of the $\rho$-th moment of *constrained
coset guesswork*: the number of trials an optimal adversary needs to identify a
secret noise vector when the search is restricted to a single coset of a rate-$R$
binary linear code. For an i.i.d. Bernoulli($p$) source the unconstrained
guesswork moment grows with the Arıkan–Merhav exponent
$E(\rho,p) = (1+\rho)\log_2\big(p^{1/(1+\rho)} + (1-p)^{1/(1+\rho)}\big)$. We prove,
at the maximal-entropy source $p = \tfrac12$, that constraining to a rate-$R$
coset lowers the exponent by *exactly* $\rho(1-R)$, yielding the closed form
$E_{\text{coset}}(\rho,R,\tfrac12) = \rho R$. In contrast to prior abstract
treatments that *postulate* a moment sequence with the correct unconstrained
rate, we *construct* the guesswork moment from first principles as the exact
average $M(N) = N^{-1}\sum_{k=1}^{N} k^{\rho}$ over $N$ equiprobable candidates
and *derive* the rate. The engine of the proof is an elementary two-sided
estimate $2^{(j-1)(\rho+1)} \le \sum_{k=1}^{2^{j}} k^{\rho} \le 2^{\,j(\rho+1)}$,
whose logarithmic form, combined with a squeeze argument, pins the constrained
rate at $\rho R$ whenever the coset dimension satisfies $k_m/m \to R$. We also
establish $E(\rho,\tfrac12) = \rho$ and thereby express the result as the exact
shift $\rho R = E(\rho,\tfrac12) - \rho(1-R)$, recovering the unconstrained rate
$\rho$ as the special case $R = 1$.

**Keywords:** guesswork, Arıkan–Merhav exponent, coset guessing, binary linear
codes, Rényi entropy, power sums, exponential growth rate.

---

## 1. Introduction

### 1.1 The guessing game

Consider an adversary who must identify an unknown secret $X$ drawn from a finite
set by submitting guesses one at a time, receiving after each a single bit of
feedback ("correct" or "incorrect"). Fixing a deterministic ordering of the
candidate set — the adversary's *strategy* — the **guessing rank** $G(x)$ of the
true value $x$ is its position in that ordering. An optimal adversary orders
candidates by non-increasing probability, so that likely secrets are found early.

Rather than the mean number of guesses, which is dominated by typical cases and
blind to tail risk, one studies the $\rho$-th **moment**
$$
\mathbb{E}\!\left[G(X)^\rho\right] = \sum_x P(x)\, G(x)^\rho, \qquad \rho > 0.
$$
The parameter $\rho$ interpolates between average-case ($\rho \to 0$) and
worst-case ($\rho \to \infty$) sensitivity. Massey and Arıkan initiated the
study of these moments; Arıkan and Merhav determined their exponential growth
rate for i.i.d. sources.

### 1.2 The Arıkan–Merhav exponent

Let the secret be an $n$-bit vector whose coordinates are i.i.d.
Bernoulli($p$). The $\rho$-th guesswork moment grows as $2^{n E(\rho,p) + o(n)}$,
where
$$
E(\rho, p) = (1+\rho)\,\log_2\!\left( p^{\frac{1}{1+\rho}} + (1-p)^{\frac{1}{1+\rho}} \right).
$$
The bracketed term is (an exponentiated form of) the Rényi entropy of order
$\alpha = \frac{1}{1+\rho}$; guessing difficulty is Rényi entropy read through
the risk parameter $\rho$.

### 1.3 Constrained coset guesswork

A binary linear code $\mathcal{C} \subseteq \mathbb{F}_2^n$ of **rate** $R$
partitions $\mathbb{F}_2^n$ into $2^{(1-R)n}$ cosets, each of size $2^{Rn}$. In
channel decoding and in structured cryptanalysis, the adversary often knows the
coset containing the secret noise vector — it is the *syndrome* of the received
word — and need only guess *within* that coset. The candidate set thus shrinks
from $2^n$ to $2^{Rn}$. We call the resulting $\rho$-th moment the **constrained
coset guesswork moment** and denote its exponent $E_{\text{coset}}(\rho, R, p)$.

### 1.4 Contribution

A companion line of work established, *abstractly*, that coset density
compression by the factor $2^{-\rho(1-R)n}$ lowers the exponent by exactly
$\rho(1-R)$ — but it did so by *postulating* an unconstrained moment sequence
with the Arıkan–Merhav rate. The present paper removes that hypothesis at the
maximal-entropy source $p = \tfrac12$. We:

1. **Construct** the guesswork moment from first principles as the exact average
   $M(N) = N^{-1}\sum_{k=1}^{N} k^{\rho}$ over $N$ equiprobable candidates
   (Section 3).
2. **Prove** the two-sided power-sum estimate and its logarithmic form
   (Section 4, Theorems 4.2–4.4).
3. **Derive**, by a squeeze argument, that the constrained coset moment grows at
   rate exactly $\rho R$ whenever the coset dimension satisfies $k_m/m \to R$
   (Section 5, Theorem 5.1).
4. **Identify** $E(\rho, \tfrac12) = \rho$ and hence the exact shift
   $\rho R = E(\rho, \tfrac12) - \rho(1-R)$, with the unconstrained case $R = 1$
   recovered as a corollary (Section 6, Theorems 6.1–6.3).

The entire development is elementary and self-contained: no analytic
number-theory, no unproven asymptotics — only the bracketing of a finite sum
between two powers of two.

---

## 2. Preliminaries and notation

Throughout, $\rho > 0$ is a fixed risk parameter and $\log_2$ denotes the base-2
logarithm. For a real base $b>0$ and real exponent $t$ we use the real power
$b^t := \exp(t \ln b)$, so $(2^a)^b = 2^{ab}$ and $\log_2 (2^t) = t$ hold for all
real $t$. We write $N$ for a candidate-set size and, for asymptotic statements,
$m$ for the block length with $k_m$ the coset dimension.

**Definition 2.1 (Arıkan–Merhav exponent).** For $\rho, p \in \mathbb{R}$ with
$p \in (0,1)$ and $\rho > 0$,
$$
E(\rho, p) \;:=\; (1+\rho)\,\log_2\!\left( p^{\frac{1}{1+\rho}} + (1-p)^{\frac{1}{1+\rho}} \right).
$$

---

## 3. The guesswork moment for an equiprobable candidate set

The symmetric source $p = \tfrac12$ makes every length-$n$ noise vector equally
likely, with probability $2^{-n}$. Consequently, *within any candidate set of
size $N$*, all candidates are equiprobable, and no ordering is better than any
other: an optimal adversary realizes the guessing ranks $1, 2, \dots, N$ exactly.
The $\rho$-th moment is therefore the exact average of $k^\rho$ over these ranks.

**Definition 3.1 (Power sum).** For $\rho \in \mathbb{R}$ and $N \in \mathbb{N}$,
$$
S(\rho, N) \;:=\; \sum_{k=1}^{N} k^{\rho} \;=\; \sum_{k=0}^{N-1} (k+1)^{\rho}.
$$

**Definition 3.2 (Guesswork moment).** For a candidate set of $N = 2^{k}$
equiprobable elements the $\rho$-th guesswork moment is
$$
M(\rho, k) \;:=\; 2^{-k}\, S(\rho, 2^{k}) \;=\; \frac{1}{2^{k}}\sum_{j=1}^{2^{k}} j^{\rho}.
$$
For unconstrained guessing over length-$m$ noise, $k = m$; for coset guessing
over a rate-$R$ code, $k = k_m$ is the coset dimension, with $k_m/m \to R$. We
write $M_{\text{coset}}(\rho, k_m, m) := 2^{-k_m} S(\rho, 2^{k_m})$ for the coset
moment viewed as a function of the block length $m$.

**Proposition 3.3 (Positivity).** For every $\rho \in \mathbb{R}$ and $N \ge 1$,
$S(\rho, N) > 0$.

*Proof.* Each summand $(k+1)^\rho > 0$ and the range is nonempty. $\square$

---

## 4. The power-sum sandwich

The whole asymptotic analysis reduces to controlling how fast $S(\rho, 2^j)$
grows. We bracket it between two powers of two with the *same* growth rate
$\rho+1$.

**Theorem 4.1 (Upper bound).** For $\rho \ge 0$ and $j \in \mathbb{N}$,
$$
S(\rho, 2^{j}) \;\le\; 2^{\,j(\rho+1)}.
$$

*Proof.* Each of the $2^j$ terms of $S(\rho, 2^j) = \sum_{i=0}^{2^j - 1}(i+1)^\rho$
satisfies $i + 1 \le 2^j$, and since $\rho \ge 0$ the map $x \mapsto x^\rho$ is
monotone, so $(i+1)^\rho \le (2^j)^\rho = 2^{j\rho}$. Summing $2^j$ such terms,
$S(\rho, 2^j) \le 2^j \cdot 2^{j\rho} = 2^{j(\rho+1)}$. $\square$

**Theorem 4.2 (Lower bound).** For $\rho \ge 0$ and $j \ge 1$,
$$
2^{\,(j-1)(\rho+1)} \;\le\; S(\rho, 2^{j}).
$$

*Proof.* Restrict the sum to the top block of indices $k \in [2^{j-1}, 2^j)$,
which contains $2^j - 2^{j-1} = 2^{j-1}$ terms, each nonnegative, so discarding
the rest only decreases the sum. For every such $k$ we have $k + 1 > 2^{j-1}$,
hence $(k+1)^\rho \ge (2^{j-1})^\rho = 2^{(j-1)\rho}$. Therefore
$$
S(\rho, 2^j) \;\ge\; \sum_{k=2^{j-1}}^{2^j - 1} (k+1)^\rho
\;\ge\; 2^{j-1}\cdot 2^{(j-1)\rho} \;=\; 2^{(j-1)(\rho+1)}. \qquad \square
$$

**Theorem 4.3 (Logarithmic sandwich).** For $\rho \ge 0$ and $j \ge 1$,
$$
(j-1)(\rho+1) \;\le\; \log_2 S(\rho, 2^{j}) \;\le\; j(\rho+1).
$$

*Proof.* Apply the increasing function $\log_2$ to the inequalities of
Theorems 4.1 and 4.2 (valid since $S(\rho, 2^j) > 0$ by Proposition 3.3) and use
$\log_2(2^t) = t$. $\square$

The crucial feature is that the upper and lower bounds differ by the *constant*
$\rho + 1$, independent of $j$. This constant gap is annihilated by normalization.

---

## 5. The main theorem: exact constrained-coset rate

**Theorem 5.1 (Exact constrained-coset exponent at $p = \tfrac12$).**
Let $\rho > 0$ and $R \in \mathbb{R}$. Let $(k_m)_{m \ge 1}$ be a sequence of
coset dimensions with $k_m \to \infty$ and $k_m/m \to R$. Then
$$
\frac{1}{m}\,\log_2 M_{\text{coset}}(\rho, k_m, m)
= \frac{1}{m}\,\log_2\!\left( 2^{-k_m}\sum_{j=1}^{2^{k_m}} j^{\rho} \right)
\;\xrightarrow[m\to\infty]{}\; \rho R.
$$

*Proof.* Fix $m$ large enough that $k_m \ge 1$. Using
$\log_2(2^{-k_m} S) = -k_m + \log_2 S$ with $S = S(\rho, 2^{k_m})$ and
Theorem 4.3 (with $j = k_m$),
$$
-k_m + (k_m - 1)(\rho+1) \;\le\; \log_2 M_{\text{coset}}
\;\le\; -k_m + k_m(\rho+1).
$$
The right endpoint simplifies to $k_m \rho$ and the left endpoint to
$k_m\rho - (\rho+1)$. Dividing by $m > 0$,
$$
\frac{k_m}{m}\,\rho \;-\; \frac{\rho+1}{m}
\;\le\; \frac{1}{m}\log_2 M_{\text{coset}}
\;\le\; \frac{k_m}{m}\,\rho.
$$
As $m \to \infty$, the hypothesis $k_m/m \to R$ makes both the right-hand bound
$\frac{k_m}{m}\rho \to R\rho$ and the left-hand bound
$\frac{k_m}{m}\rho - \frac{\rho+1}{m} \to R\rho - 0 = R\rho$. By the squeeze
theorem, $\frac1m \log_2 M_{\text{coset}} \to \rho R$. $\square$

Theorem 5.1 is the promised construction-and-derivation: the moment sequence is
built explicitly, and its rate is proved, not assumed.

---

## 6. The exponent shift and its consequences

**Theorem 6.1 (Symmetric-source Arıkan–Merhav exponent).** For $\rho > 0$,
$$
E\!\left(\rho, \tfrac12\right) = \rho.
$$

*Proof.* With $p = 1 - p = \tfrac12$ and $s := \tfrac{1}{1+\rho}$,
$$
p^{s} + (1-p)^{s} = 2\cdot 2^{-s} = 2^{\,1 - s},
$$
so $\log_2\big(2^{1-s}\big) = 1 - s = 1 - \tfrac{1}{1+\rho} = \tfrac{\rho}{1+\rho}$.
Hence $E(\rho,\tfrac12) = (1+\rho)\cdot \tfrac{\rho}{1+\rho} = \rho$. $\square$

**Theorem 6.2 (Unconstrained rate).** Taking $R = 1$ (equivalently $k_m = m$) in
Theorem 5.1, the unconstrained guesswork moment satisfies
$$
\frac{1}{m}\log_2 M(\rho, m) \xrightarrow[m\to\infty]{} \rho = E\!\left(\rho, \tfrac12\right).
$$

*Proof.* Immediate from Theorem 5.1 with $R = 1$, combined with Theorem 6.1. $\square$

**Theorem 6.3 (Exact exponent shift).** For $\rho > 0$ and $R \in [0,1]$, the
constrained coset rate equals the unconstrained rate reduced by exactly
$\rho(1-R)$:
$$
E_{\text{coset}}\!\left(\rho, R, \tfrac12\right)
= \rho R
= E\!\left(\rho, \tfrac12\right) - \rho(1 - R).
$$

*Proof.* By Theorem 5.1 the left side equals $\rho R$; by Theorem 6.1 the
unconstrained exponent is $\rho$, and $\rho - \rho(1-R) = \rho R$. $\square$

**Interpretation.** The redundancy $1 - R$ of the code — the fraction of the
$n$-dimensional freedom removed by the coset constraint — translates into an
exponential discount of $\rho$ per unit. The shift is *purely structural*: it
depends only on the code rate $R$ and the risk parameter $\rho$, not on the
source (which here is the extremal fair coin). Setting $p = \tfrac12$ removes the
source's contribution and exposes the coset-compression mechanism in isolation.

---

## 7. Algorithms

The proof is constructive and translates directly into computation. Two routines
suffice to verify the theorems numerically.

### 7.1 Exact guesswork moment

Compute $M(\rho, k) = 2^{-k}\sum_{j=1}^{2^{k}} j^{\rho}$ directly, and its
empirical rate $\frac1m \log_2 M$. Complexity $O(2^k)$ time, $O(1)$ space (running
sum). This is exact for the symmetric source because ranks are exactly
$1,\dots,2^k$.

### 7.2 Sandwich verifier

For given $\rho, j$, evaluate the three quantities $2^{(j-1)(\rho+1)}$,
$S(\rho, 2^j)$, $2^{j(\rho+1)}$ and confirm the ordering of Theorems 4.1–4.2.
Complexity $O(2^j)$ time. Confirms the bracketing that drives the limit.

### 7.3 Rate estimator with convergence rate

For a rate-$R$ code family with $k_m = \lfloor R m\rfloor$, compute
$\frac1m \log_2 M_{\text{coset}}$ for increasing $m$ and observe convergence to
$\rho R$ at the predicted $O((\rho+1)/m)$ speed. This is the first-order
correction implied by the constant gap in the sandwich.

---

## 8. Applications

- **Channel decoding effort.** For a syndrome-decoding adversary who has
  localized the noise to a coset, the exponent $\rho R$ quantifies the tail-aware
  cost of exhaustive within-coset search, sharpening resource estimates.
- **Cryptographic security margins.** For code-based schemes, the shift
  $\rho(1-R)$ measures precisely how much structural redundancy erodes the
  guessing hardness of a secret, informing rate selection under a chosen risk
  parameter $\rho$.
- **Benchmark and sanity check.** Any general-$p$ coset-guesswork formula must
  reduce to $\rho R$ at $p = \tfrac12$; Theorem 6.3 is the rigorous benchmark
  against which such formulas are validated.

---

## 9. Discussion and future work

The maximal-entropy case is the sharp special case where the candidate set is
genuinely equiprobable and ranks are exactly $1, \dots, N$; this is what lets an
elementary power-sum sandwich carry the entire argument. The following directions
extend the result.

1. **General $p \ne \tfrac12$.** Replace the uniform source by a genuine
   Bernoulli($p$) noise distribution. Candidates are then no longer equiprobable;
   one orders noise vectors by decreasing probability and groups them by Hamming
   weight (Arıkan's tilting/type-class enumeration) to prove
   $\frac1n \log_2 \sum_e P(e)\,\mathrm{rank}(e)^\rho \to E(\rho, p)$. The Rényi
   closed form for $E(\rho, p)$ supplies the target.

2. **Averaging over random linear codes.** Let $k_m$ and the coset genuinely
   arise from a random $[n, Rn]$ generator matrix, and establish the density
   factor $2^{-(1-R)n}$ in expectation via a first-moment method, tying the coset
   moment to the coset-invariance of within-ball counts.

3. **Concentration and converse.** Upgrade the expectation to an almost-sure or
   high-probability exponent, and prove a matching lower bound, establishing the
   exponent as a genuine limit rather than a two-sided bound.

4. **$q$-ary alphabets.** The power-sum machinery is alphabet-agnostic; replacing
   base $2$ by base $q$ yields the $q$-ary coset exponent
   $\rho\, H^{(q)}_{1/(1+\rho)}(p) - \rho(1-R)$.

5. **Sharper asymptotics.** The present proof gives $O((\rho+1)/m)$ convergence;
   an Euler–Maclaurin analysis of $\sum_{k} k^\rho$ would yield the constant and
   the finite-$n$ correction to the exponent.

---

## 10. Conclusion

We have proved, from first principles and without hypotheses on the moment
sequence, that constrained coset guesswork at the symmetric source has
exponential growth rate exactly $\rho R$, an exact downward shift of $\rho(1-R)$
from the unconstrained Arıkan–Merhav exponent $\rho$. The proof rests on a single
elementary inequality — the bracketing of $\sum_{k=1}^{2^j} k^\rho$ between
$2^{(j-1)(\rho+1)}$ and $2^{j(\rho+1)}$ — whose constant gap vanishes under
normalization. The result is a rigorous benchmark and a template for the general
biased-source theory.
