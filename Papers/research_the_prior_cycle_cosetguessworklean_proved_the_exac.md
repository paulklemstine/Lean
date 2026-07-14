# The $q$-ary Exact Coset-Guesswork Exponent at the Maximal-Entropy Source

## Abstract

Guesswork quantifies the effort an optimal adversary expends to identify a secret
by sequential guessing, and its exponential growth rate — the *guessing exponent* —
is a fundamental measure of information-theoretic security. We study how a
rate-$R$ coset code alters this exponent for a maximal-entropy (uniform) source
over an alphabet of $q \ge 2$ symbols. Constructing the $\rho$-th guesswork moment
from first principles as the exact average $M_q(k) = q^{-k}\sum_{j=1}^{q^k} j^\rho$
over $q^k$ equiprobable candidates, we prove an elementary two-sided estimate for
the power sum $\sum_{k=1}^{q^j} k^\rho$ in base $q$ and use it, via a squeeze
argument, to determine the exact per-symbol growth rate. The unconstrained
exponent is $\rho$; a rate-$R$ coset code yields exactly $\rho R$; hence the code
lowers the exponent by precisely the redundancy term $\rho(1-R)$, **uniformly in
the alphabet size $q$**. A companion Rényi-entropy computation identifies the
leading $\rho$ as $\rho$ times the (order-independent) Rényi entropy of the uniform
law, showing the exponent is the maximal-entropy Arıkan–Merhav exponent. The result
exhibits the redundancy shift as a pure density phenomenon carried entirely by the
factor $q^{-k}$, independent of both $\rho$'s fine structure and the alphabet size.

**Keywords.** Guesswork, guessing exponent, coset codes, Rényi entropy,
Arıkan–Merhav exponent, power sums, maximal entropy, $q$-ary alphabets.

## 1. Introduction

### 1.1 Guesswork and its moments

Consider an adversary who must identify an unknown value $X$ taking values in a
finite set $\mathcal{X}$, knowing only the distribution of $X$. The adversary asks
questions of the form "is $X = x$?" one at a time, and the *guesswork* $G(x)$ is the
number of questions asked before the correct answer, when the true value is $x$. An
optimal adversary queries values in nonincreasing order of probability, so that
$G$ takes the value $j$ exactly when $x$ is the $j$-th most likely outcome.

Rather than the mean $\mathbb{E}[G]$, the quantities of information-theoretic
interest are the *moments* $\mathbb{E}[G^\rho]$ for $\rho > 0$, and specifically
their exponential growth rate as the block length grows. This growth rate — the
**guessing exponent** — governs, among other things, the large-deviations behavior
of sequential search and the security margin of a secret against brute force.

### 1.2 Maximal-entropy sources and coset codes

We focus on the sharpest and cleanest setting: a **maximal-entropy** (uniform)
source over an alphabet of $q$ symbols. A block of $m$ symbols then has $q^m$
equiprobable candidate values. Because all candidates are equiprobable, an optimal
adversary realizes each guessing rank $1, 2, \ldots, q^m$ exactly once, so

$$
\mathbb{E}[G^\rho] = \frac{1}{q^m}\sum_{j=1}^{q^m} j^\rho.
$$

A **coset code** of rate $R$ imposes a linear constraint that reduces the number of
candidates consistent with the observed side information from $q^m$ to $q^{k_m}$,
where the code dimension $k_m$ satisfies $k_m/m \to R$ as $m \to \infty$. The
constrained guesswork moment is then

$$
M_q(k_m) = q^{-k_m}\sum_{j=1}^{q^{k_m}} j^\rho.
$$

Our aim is to determine the exact per-symbol growth rate of $M_q(k_m)$ and compare
it to the unconstrained rate, thereby quantifying the exponent lost to coding.

### 1.3 Contribution

We prove that, for every alphabet size $q \ge 2$ and every $\rho > 0$:

1. the **unconstrained** guessing exponent (base $q$, per symbol) is exactly
   $\rho$;
2. the **constrained** exponent under a rate-$R$ coset code is exactly $\rho R$;
3. hence the code lowers the exponent by exactly $\rho(1-R)$, **independent of the
   alphabet size $q$**.

The proof is elementary and self-contained: it rests on a two-sided estimate for a
classical power sum, a squeeze argument, and a short Rényi-entropy computation that
identifies the leading $\rho$ with the maximal-entropy Arıkan–Merhav exponent. The
central structural insight is that the redundancy penalty $\rho(1-R)$ arises
*entirely* from the density factor $q^{-k_m}$, whose base-$q$ logarithm is exactly
$-k_m$, and is therefore blind to both the alphabet size and the fine structure of
the power sum.

## 2. Definitions

Throughout, $q = b \ge 2$ is the alphabet size, $\rho > 0$ is the moment order, and
$\log_b$ denotes the base-$b$ logarithm.

**Definition 1 (Power sum).** For $\rho \in \mathbb{R}$ and $N \in \mathbb{N}$,
define
$$
S_\rho(N) = \sum_{k=1}^{N} k^\rho = \sum_{k=0}^{N-1} (k+1)^\rho .
$$

**Definition 2 ($q$-ary guesswork moment).** For a uniform source guessing over
$q^k$ equiprobable candidates, the $\rho$-th guesswork moment is
$$
M_q(k) = q^{-k}\, S_\rho(q^k) = q^{-k}\sum_{j=1}^{q^k} j^\rho .
$$
For a sequence of code dimensions $k_m$, the *constrained coset moment* at block
length $m$ is $M_q(k_m)$.

**Definition 3 (Rényi entropy).** For a distribution $P$ on $q$ letters and order
$\alpha \ne 1$, measured in base $b$,
$$
H_\alpha^{(b)}(P) = \frac{1}{1-\alpha}\,\log_b \sum_{i=1}^{q} P(i)^\alpha .
$$

**Definition 4 ($q$-ary maximal-entropy Arıkan–Merhav exponent).** The uniform-source
guessing exponent of order $\rho$, in base $b$, is
$$
E_{\mathrm{unif}}^{(b)}(q,\rho) = \rho\, \log_b q ,
$$
equal, as Proposition 2 shows, to $\rho$ times the Rényi entropy of order
$1/(1+\rho)$ of the uniform law on $q$ letters.

## 3. The power-sum estimate

The engine of the entire development is a pair of elementary two-sided bounds on
$S_\rho(q^j)$.

**Lemma 1 (Positivity).** For every $\rho \in \mathbb{R}$ and $N \ge 1$,
$S_\rho(N) > 0$.

*Proof.* Each summand $(k+1)^\rho$ is positive, and the range is nonempty. $\square$

**Lemma 2 (Upper bound).** For $q \ge 2$, $\rho \ge 0$, and $j \in \mathbb{N}$,
$$
S_\rho(q^j) \le q^{\,j(\rho+1)} .
$$

*Proof.* Each of the $q^j$ terms $k^\rho$ with $1 \le k \le q^j$ satisfies
$k^\rho \le (q^j)^\rho$ because $x \mapsto x^\rho$ is nondecreasing for $\rho \ge 0$.
Summing the $q^j$ terms gives
$S_\rho(q^j) \le q^j \cdot (q^j)^\rho = q^{\,j(\rho+1)}$. $\square$

**Lemma 3 (Lower bound).** For $q \ge 2$, $\rho \ge 0$, and $j \ge 1$,
$$
q^{\,(j-1)(\rho+1)} \le S_\rho(q^j) .
$$

*Proof.* Restrict the sum to the top block of indices $k \in [q^{j-1}, q^j)$. Each
such term satisfies $k^\rho \ge (q^{j-1})^\rho$, and the block contains
$q^j - q^{j-1} = q^{j-1}(q-1)$ terms. Since $q \ge 2$ we have $q - 1 \ge 1$, so the
block count is at least $q^{j-1}$. Therefore
$$
S_\rho(q^j) \ge (q^{j-1})^\rho \cdot \big(q^j - q^{j-1}\big)
           \ge (q^{j-1})^\rho \cdot q^{j-1}
           = q^{\,(j-1)(\rho+1)} . \qquad\square
$$

**Lemma 4 (Logarithmic sandwich).** For $q \ge 2$, $\rho \ge 0$, and $j \ge 1$,
$$
(j-1)(\rho+1) \;\le\; \log_q S_\rho(q^j) \;\le\; j(\rho+1).
$$

*Proof.* Take base-$q$ logarithms of Lemmas 2 and 3, using
$\log_q(q^x) = x$ and monotonicity of $\log_q$ (valid since $q > 1$ and
$S_\rho(q^j) > 0$ by Lemma 1). $\square$

The two bounds differ only by the additive constant $\rho + 1$ in the exponent,
which is negligible after normalization by the block length. This is the precise
sense in which the power sum's growth rate is pinned to $\rho + 1$.

## 4. The maximal-entropy exponent via Rényi entropy

**Proposition 1 (Rényi entropy of the uniform law).** For every order
$\alpha \ne 1$ and every $q \ge 1$, the Rényi entropy of the uniform distribution
$P(i) = 1/q$ on $q$ letters is
$$
H_\alpha^{(b)}\!\left(\tfrac{1}{q},\ldots,\tfrac{1}{q}\right) = \log_b q,
$$
independent of $\alpha$.

*Proof.* With $P(i) = q^{-1}$ we have
$\sum_{i=1}^{q} P(i)^\alpha = q \cdot q^{-\alpha} = q^{1-\alpha}$. Hence
$$
H_\alpha^{(b)} = \frac{1}{1-\alpha}\log_b q^{1-\alpha}
             = \frac{1}{1-\alpha}\,(1-\alpha)\log_b q = \log_b q,
$$
using $\alpha \ne 1$ to divide. $\square$

**Proposition 2 (Exponent as a Rényi entropy).** For $\rho > 0$ and $q \ge 1$,
$$
E_{\mathrm{unif}}^{(b)}(q,\rho) = \rho\, H_{1/(1+\rho)}^{(b)}\!\left(\tfrac{1}{q},\ldots,\tfrac{1}{q}\right).
$$

*Proof.* The order $\alpha = 1/(1+\rho)$ is never $1$ (since $\rho > 0$), so
Proposition 1 gives the inner Rényi entropy $\log_b q$, and multiplying by $\rho$
recovers $\rho \log_b q = E_{\mathrm{unif}}^{(b)}(q,\rho)$. $\square$

**Proposition 3 (Self-base normalization).** For $q \ge 2$ and any $\rho$,
$$
E_{\mathrm{unif}}^{(q)}(q,\rho) = \rho .
$$

*Proof.* $E_{\mathrm{unif}}^{(q)}(q,\rho) = \rho \log_q q = \rho \cdot 1 = \rho$,
since $\log_q q = 1$ for $q > 1$. $\square$

Proposition 3 says that when information is measured in the source's own natural
units (one unit per symbol at maximal entropy), the uniform guessing exponent
saturates at $\rho$. This is the leading term against which the coding penalty will
be measured.

## 5. The exact coset exponent

**Theorem 1 (Exact constrained $q$-ary coset exponent).** Let $q \ge 2$,
$\rho > 0$, and let $(k_m)_{m}$ be a sequence of code dimensions with
$k_m \to \infty$ and $k_m/m \to R$. Then the constrained $q$-ary coset guesswork
moment has base-$q$ per-symbol growth rate exactly $\rho R$:
$$
\frac{1}{m}\,\log_q M_q(k_m) \;\longrightarrow\; \rho R
\qquad (m \to \infty).
$$

*Proof.* Expand the logarithm of the moment. By Definition 2 and the multiplicativity
of the logarithm,
$$
\log_q M_q(k_m) = -k_m + \log_q S_\rho(q^{k_m}).
$$
Applying the logarithmic sandwich (Lemma 4) with $j = k_m \ge 1$ gives
$$
(k_m - 1)(\rho+1) \;\le\; \log_q S_\rho(q^{k_m}) \;\le\; k_m(\rho+1).
$$
Adding $-k_m$ throughout,
$$
k_m\rho - (\rho+1) \;\le\; \log_q M_q(k_m) \;\le\; k_m\rho .
$$
Dividing by $m$,
$$
\frac{k_m}{m}\,\rho - \frac{\rho+1}{m}
\;\le\; \frac{1}{m}\log_q M_q(k_m)
\;\le\; \frac{k_m}{m}\,\rho .
$$
As $m \to \infty$, both the lower bound (since $k_m/m \to R$ and
$(\rho+1)/m \to 0$) and the upper bound converge to $\rho R$. By the squeeze
theorem, the middle term converges to $\rho R$. $\square$

**Corollary 1 (Unconstrained rate).** Taking $k_m = m$ (so $R = 1$), the
unconstrained $q$-ary guesswork moment has per-symbol growth rate exactly $\rho$:
$$
\frac{1}{m}\,\log_q M_q(m) \;\longrightarrow\; \rho .
$$

*Proof.* Apply Theorem 1 with $k_m = m$, so $k_m/m = 1 \to R = 1$ and $k_m \to
\infty$, giving the limit $\rho \cdot 1 = \rho$. $\square$

**Theorem 2 (Exact redundancy shift).** Under the hypotheses of Theorem 1, and
using the self-base normalization of Proposition 3,
$$
\lim_{m\to\infty} \frac{1}{m}\log_q M_q(k_m)
= E_{\mathrm{unif}}^{(q)}(q,\rho) - \rho(1-R).
$$
Consequently the unconstrained exponent $\rho$ and the constrained exponent
$\rho R$ differ by exactly
$$
\rho - \rho R = \rho(1-R),
$$
independent of the alphabet size $q$.

*Proof.* By Theorem 1 the constrained limit is $\rho R$. By Proposition 3,
$E_{\mathrm{unif}}^{(q)}(q,\rho) = \rho$, so
$E_{\mathrm{unif}}^{(q)}(q,\rho) - \rho(1-R) = \rho - \rho(1-R) = \rho R$, matching
the limit. The final identity $\rho - \rho R = \rho(1-R)$ is algebraic and holds
for all real $\rho, R$. $\square$

## 6. Discussion

### 6.1 The shift is a pure density effect

The proof of Theorem 1 makes the source of the redundancy penalty transparent. The
logarithm of the moment splits cleanly into a **density term** $-k_m$ and a
**power-sum term** $\log_q S_\rho(q^{k_m}) \approx k_m(\rho+1)$. The power-sum term,
after dividing by $m$, contributes $R(\rho+1)$; the density term contributes $-R$;
their sum is $R\rho$. Every trace of the code appears through $-k_m$, whose base-$q$
logarithm is exactly $-k_m$ regardless of $\rho$ or $q$. This is why the shift
$\rho(1-R)$ is universal across alphabets: it is a counting effect, not a spectral
one.

### 6.2 The role of the block-count factor

The only structural difference from the binary case is that the lower-bound block
$[q^{j-1}, q^j)$ contains $q^{j-1}(q-1)$ terms rather than $q^{j-1}$. Because
$q - 1 \ge 1$, this extra factor only strengthens the lower bound; it contributes at
most an additive $\log_q(q-1)$ to the logarithm, which vanishes after division by
$m$. The growth rate $\rho + 1$ of the power sum is therefore alphabet-independent,
and so is the resulting exponent.

### 6.3 Source term versus code term

Propositions 1–3 and Theorem 2 together exhibit the exponent as a sum of two
decoupled contributions: a **source term** (here $\rho$, from the maximal-entropy
Rényi entropy) and a **code term** ($-\rho(1-R)$). This separation is the conceptual
template for generalization: changing the source moves only the first term, while
changing the code rate moves only the second.

### 6.4 Non-vacuity

The hypotheses are genuinely used. Positivity $\rho > 0$ ensures the order
$\alpha = 1/(1+\rho) \ne 1$ in the Rényi computation and the strict monotonicity in
the power-sum bounds; $q \ge 2$ ensures the base of the logarithm exceeds $1$ (so
$\log_q q = 1$ and the sandwich is meaningful) and that the top block is nonempty.
The rate theorems are genuine limits established by a squeeze, not definitional
identities.

## 7. Applications

- **Security margins.** For a maximal-entropy secret protected by a rate-$R$ coset
  code, the guessing exponent of every moment order $\rho$ is $\rho R$. This gives an
  exact, closed-form security exponent as a function of the coding rate.
- **Alphabet-agnostic design.** Because the shift $\rho(1-R)$ is independent of $q$,
  design rules calibrated for bits transfer verbatim to bytes, DNA, or any $q$-ary
  channel once information is measured in base $q$.
- **Rate–exponent tradeoff.** The linear law $E(\rho, R) = \rho R$ makes the
  tradeoff between coding rate and guessing hardness fully explicit, aiding the
  selection of $R$ to meet a target exponent.

## 8. Future work

1. **Non-uniform $q$-ary sources.** Replace the uniform source by a genuine
   per-symbol law $P$. Ordering noise vectors by decreasing probability and grouping
   by type should yield the exponent $\rho\, H_{1/(1+\rho)}(P) - \rho(1-R)$, with the
   Rényi entropy in place of $\log_q q$; the code term should survive unchanged.
2. **Matching converse.** Upgrade the two-sided estimate to a genuine two-sided
   exponent (a limit for every subsequence of code dimensions), closing the constant
   gap $q^{\rho+1}$ via a second-order (Euler–Maclaurin) expansion of the power sum.
3. **Random linear codes.** Let $k_m$ and the coset arise from a random $[n, Rn]$
   generator matrix; prove the density factor $q^{-(1-R)n}$ in expectation by a
   first-moment argument, then upgrade to high probability.
4. **Sharper asymptotics.** A second-order analysis of $\sum k^\rho$ would yield the
   exact constant and the finite-block correction to the exponent.

## 9. Conclusion

For every alphabet size $q \ge 2$ and moment order $\rho > 0$, the maximal-entropy
$q$-ary source has unconstrained guessing exponent $\rho$ and constrained (rate-$R$
coset) exponent $\rho R$; a code therefore lowers the exponent by exactly the
redundancy $\rho(1-R)$, uniformly in $q$. The argument isolates the shift as a pure
density effect carried by the factor $q^{-k_m}$ and identifies the leading $\rho$ as
the maximal-entropy Arıkan–Merhav exponent through an order-independent Rényi-entropy
computation. The result removes the binary restriction of prior work and reveals the
coding penalty as an alphabet-agnostic, exactly linear function of the rate.
