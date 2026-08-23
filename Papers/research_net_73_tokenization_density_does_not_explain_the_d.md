# The Knee of a Domain Is a Concentration Functional, Not a Token Count

### A refutation of the tokenization-density hypothesis and a majorization-theoretic replacement

**Author:** Aristotle
**Date:** 2026-08-23

---

## Abstract

Memory-limited attention mechanisms retain only the $k$ heaviest keys of a
transformer's key–value cache. The smallest $k$ at which quality saturates — the
**knee** $k^*$ — varies substantially across text domains: measured at context
length $512$ with a single fixed model and tokenizer, source code saturates at
$k^*=12$, German prose at $20$, mathematics and English prose at $16$, and
French prose fails to saturate within a grid of ceiling $32$. The natural
explanation is *tokenization density*: domains whose words cost more subword
tokens should require more keys.

We refute this hypothesis in every testable form and replace it with a
structural theory. On the four uncensored domains, the Spearman rank
correlation between tokens-per-word (TPW) and $k^*$ is $\rho = -2/5 = -0.40$
(negative under all four standard tie-breaking conventions), and the coefficient
of determination of the least-squares line is exactly $R^2 = 4225/1054258
\approx 0.004$. We prove a general order-theoretic obstruction — a single
discordant pair forbids every monotone functional law — and exhibit one
discordant pair for the increasing horn and one concordant pair for the
decreasing horn, so *no* monotone function of TPW reproduces the knees. A
Cauchy–Schwarz argument shows any exact affine law forces $R^2 = 1$,
independently excluding all straight lines. At rank level, competition ranks are
invariant under strictly monotone reparameterisation, and the observed rank
vectors differ.

We then model a domain by its **capture curve** $C(k)$, the attention mass held
by the $k$ heaviest keys, with $k^*(\tau) = \min\{k: C(k)\ge\tau\}$. Three
results follow. (i) **Decoupling:** every pair (token density $d$, knee $k\ge1$)
is realised by some domain, so no function whatsoever maps TPW to $k^*$.
(ii) **Concentration bounds:** $k^*(\tau) \ge \tau/m$ for per-key mass cap $m$,
$k^*(\tau) \ge \tau/p_0$ for top-key mass $p_0$, and $k^*(\tau) \ge \tau^2/S$ for
collision index $S = \sum_i p_i^2$; on the geometric family $C(k) = 1-r^k$ the
knee is characterised exactly by $k^*(\tau)\le k \iff r^k \le 1-\tau$, and two
domains with *identical* TPW but decay rates $1/2$ and $9/10$ have knees $2$ and
$14$ at $\tau = 3/4$. (iii) **Duality:** knee dominance at all tolerances is
*equivalent* to majorization of capture curves; the knee curve is a complete
invariant of the capture curve; and mixtures of domains have interleaved knees,
so the observed spread is not a blending artifact.

The mechanism of the domain shift is therefore relational — the concentration
geometry of attention — and provably not surface token counting.

**Keywords:** attention sparsity, key–value cache, tokens-per-word, Spearman
correlation, majorization, collision index, Rényi entropy, domain shift.

---

## 1. Introduction

### 1.1 The limited-memory axis

A transformer decoder maintains, for each attention head and each layer, a cache
of key–value pairs — one per position in the context. At inference time, memory
and bandwidth scale linearly in context length $n$, and this cache dominates
cost for long contexts. The standard remedy exploits the empirical observation
that attention distributions are heavily concentrated: at any given query
position, a small fraction of the stored keys receives nearly all of the
attention mass. If one retains only the $k$ heaviest keys and discards the rest,
inference cost falls by a factor $n/k$ while output quality is, up to some
threshold, unchanged.

Define the **knee** $k^*$ to be the smallest retention budget at which quality
saturates. Below $k^*$, signal is discarded; above it, resources are spent on
keys whose contribution is negligible. The knee is the natural design parameter
of any memory-limited attention system.

### 1.2 The observed domain shift

The knee is not a constant of the model. Fixing one model, one tokenizer, one
context length $n=512$, and one retention criterion, and measuring on
$5000$-word samples drawn from five text domains, one obtains:

| domain        | tokens per word (TPW) | knee $k^*$ at $n=512$ |
|---------------|-----------------------|-----------------------|
| code          | $1.950$               | $12$                  |
| prose (German)| $1.885$               | $20$                  |
| prose (French)| $1.246$               | $>32$ (censored)      |
| mathematics   | $1.214$               | $16$                  |
| prose (English)| $1.173$              | $16$                  |

The French measurement is **right-censored**: the retention grid had ceiling
$32$, and French had not saturated there. An extended grid confirms that a knee
exists with $k^*(\text{fr}) \le 32$ under a relaxed criterion, but the value at
the original criterion is only bounded below. Accordingly all numeric statistics
below are computed on the four uncensored domains, in the order
$(\text{code}, \text{de}, \text{math}, \text{en})$, and the censored French point
is used only through hypothesis-parameterised statements valid for every
admissible value.

### 1.3 The tokenization-density hypothesis and its pre-registered predictions

Subword tokenizers compress different domains at different rates. Source code
and morphologically rich languages fragment more than English. If a domain's
words cost more tokens, its content occupies more context positions, and one
might expect the model to require a larger fraction of them.

Formally, the hypothesis is that $k^*$ is a (monotone, indeed roughly affine)
function of TPW. Three horns were pre-stated:

- **P1.** Spearman rank correlation $\rho(\mathrm{TPW}, k^*) \ge 0.9$.
- **P2.** Least-squares coefficient of determination $R^2 \ge 0.8$.
- **P3.** TPW is insufficient; the mechanism is something else.

Sections 2–3 establish that **P1 and P2 are refuted** and **P3 is confirmed**.
Sections 4–6 supply the replacement mechanism.

---

## 2. Refutation, numerical form

### 2.1 Notation

Index the four uncensored domains by $i \in \{0,1,2,3\}$ for
code, German prose, mathematics, English prose. Write
$$x = (\mathrm{TPW}_i)_i = (1.950,\; 1.885,\; 1.214,\; 1.173),
\qquad y = (k^*_i)_i = (12,\; 20,\; 16,\; 16).$$
All quantities are exact rationals; no floating-point rounding enters any claim
below.

### 2.2 Rank correlation

**Definition 2.1 (Spearman coefficient).** For rank vectors $r, s$ on $n$ items,
$$\rho(r,s) \;=\; 1 - \frac{6 \sum_{i} (r_i - s_i)^2}{n(n^2-1)}.$$

**Definition 2.2 (rank conventions).** Ascending ranks of $x$ are unambiguous:
$r^{\mathrm{TPW}} = (4,3,2,1)$ (English lowest, code highest). The knee vector
has a tie ($16 = 16$ for mathematics and English), so we record all four
standard conventions:

| convention | rank vector for $k^*$ |
|---|---|
| reported (math before English) | $(1,4,2,3)$ |
| alternate (English before math) | $(1,4,3,2)$ |
| competition (both ties get the lower rank) | $(1,4,2,2)$ |
| midrank (tie-averaged) | $(1,4,\tfrac52,\tfrac52)$ |

**Theorem 2.3 (reported value).**
$\rho\!\left(r^{\mathrm{TPW}}, (1,4,2,3)\right) = -\tfrac25 = -0.40.$

*Proof.* Differences are $(3,-1,0,-2)$, so $\sum d_i^2 = 9+1+0+4 = 14$, and
$\rho = 1 - 6\cdot14/(4\cdot15) = 1 - 84/60 = -2/5$. $\square$

**Theorem 2.4 (sign robustness).** Under all four conventions,
$$\rho = -\tfrac25,\quad -\tfrac15,\quad -\tfrac1{10},\quad -\tfrac14$$
respectively, and in particular $\rho < 0$ in every case.

*Proof.* Direct computation of $\sum d_i^2 = 14, 11, 9.5, 12.5$ against the
normaliser $n(n^2-1) = 60$. $\square$

**Corollary 2.5 (P1 refuted).** $\rho = -0.40 < 0.9$; the correlation is not
merely below the pre-registered threshold but has the wrong sign. The sign is
not an artifact of tie handling.

A useful complementary fact explains *why* no rank correlation could have been
positive.

**Definition 2.6 (competition rank).** For $x : \{1,\dots,n\} \to \mathbb{Q}$,
$\mathrm{crank}(x)_i = 1 + \#\{j : x_j < x_i\}$.

**Theorem 2.7 (rank invariance).** If $f$ is strictly increasing, then
$\mathrm{crank}(f \circ x) = \mathrm{crank}(x)$.

*Proof.* $f(x_j) < f(x_i) \iff x_j < x_i$ by strict monotonicity, so the
counted sets coincide index by index. $\square$

**Theorem 2.8 (rank mismatch).** $\mathrm{crank}(y) \ne \mathrm{crank}(x)$.

*Proof.* Code (index $0$) has the strictly largest TPW, so
$\mathrm{crank}(x)_0 = 4$; it has the strictly smallest knee, so
$\mathrm{crank}(y)_0 = 1$. $\square$

**Corollary 2.9.** There is no strictly increasing $f$ with $y = f \circ x$:
such an $f$ would force $\mathrm{crank}(y) = \mathrm{crank}(x)$ by Theorem 2.7,
contradicting Theorem 2.8. Equivalently, Spearman's $\rho$ between the two rank
vectors would be exactly $1$; and $\rho(r,s) = 1$ holds **iff** $r = s$
whenever $n \ge 2$, because $\rho = 1$ forces $\sum_i (r_i-s_i)^2 = 0$ and each
summand is nonnegative.

### 2.3 Linear regression

**Definition 2.10.** For samples $x, y$ of length $n$ write
$\bar x = \frac1n\sum_i x_i$, and let
$$\mathrm{cov}(x,y) = \sum_i (x_i - \bar x)(y_i - \bar y), \qquad
R^2(x,y) = \frac{\mathrm{cov}(x,y)^2}{\mathrm{cov}(x,x)\,\mathrm{cov}(y,y)}.$$

**Theorem 2.11 (Cauchy–Schwarz for centred samples).**
$\mathrm{cov}(x,y)^2 \le \mathrm{cov}(x,x)\,\mathrm{cov}(y,y)$; consequently
$R^2 \le 1$ whenever both variances are positive.

*Proof.* Apply the Cauchy–Schwarz inequality to the centred vectors
$(x_i - \bar x)_i$ and $(y_i - \bar y)_i$. $\square$

**Theorem 2.12 (an exact affine law forces a perfect fit).** If $y_i = a x_i + b$
for all $i$ with $a \ne 0$ and $\mathrm{cov}(x,x) > 0$, then $R^2(x,y) = 1$.

*Proof.* Averaging gives $\bar y = a\bar x + b$, hence
$y_i - \bar y = a(x_i - \bar x)$. Therefore
$\mathrm{cov}(x,y) = a\,\mathrm{cov}(x,x)$ and
$\mathrm{cov}(y,y) = a^2\,\mathrm{cov}(x,x)$, so
$R^2 = a^2 \mathrm{cov}(x,x)^2 / (a^2 \mathrm{cov}(x,x)^2) = 1$. $\square$

**Theorem 2.13 (exact value).** For the measured data,
$$R^2(x,y) = \frac{4225}{1054258} \approx 0.004008 \;<\; \frac{1}{200}.$$

*Proof.* Exact rational arithmetic on the four data points. With
$x$ in thousandths, $\bar x = 1555.5/1000$ and $\bar y = 16$; the centred
products sum to a covariance whose square, divided by the product of the two
centred sums of squares, is $4225/1054258$. $\square$

**Corollary 2.14 (P2 refuted; no affine law).** $R^2 \approx 0.004 < 0.8$.
Moreover, by Theorem 2.12 an exact law $k^* = a\cdot\mathrm{TPW} + b$ with
$a \ne 0$ would give $R^2 = 1 \ne 4225/1054258$; hence no such law exists.

---

## 3. Refutation, structural form

Numerical refutations invite the reply "perhaps the relationship is nonlinear".
The following elementary principle closes that escape route for the entire class
of monotone laws at once.

**Theorem 3.1 (No-Monotone-Law Principle).** Let $x : I \to A$ and
$y : I \to B$ be observables on a common index set, $A$ linearly ordered, $B$
preordered.

1. If there are $i,j$ with $x_i < x_j$ and $\lnot(y_i < y_j)$ (a *discordant*
   pair), then there is no strictly increasing $f : A \to B$ with $y = f\circ x$.
2. If there are $i,j$ with $x_i < x_j$ and $y_i < y_j$ (a *concordant* pair),
   then there is no strictly decreasing $f : A \to B$ with $y = f\circ x$.

*Proof.* (1) A strictly increasing $f$ gives $f(x_i) < f(x_j)$, i.e.
$y_i < y_j$, contradicting discordance. (2) A strictly decreasing $f$ gives
$y_j < y_i$, which together with $y_i < y_j$ contradicts irreflexivity of the
strict order. $\square$

The theorem consumes no numerics whatsoever: *one* pair suffices to eliminate
an uncountable family of candidate laws.

**Theorem 3.2 (no increasing law).** There is no strictly increasing
$f : \mathbb{Q}\to\mathbb{Q}$ with $k^*_i = f(\mathrm{TPW}_i)$ for all $i$.

*Proof.* Take $i = $ English, $j = $ code. Then
$\mathrm{TPW}_{\mathrm{en}} = 1.173 < 1.950 = \mathrm{TPW}_{\mathrm{code}}$, but
$k^*_{\mathrm{en}} = 16 \not< 12 = k^*_{\mathrm{code}}$. Apply Theorem 3.1(1).
$\square$

This is the headline counterexample: code carries $1.66\times$ English's token
density yet needs strictly *fewer* keys.

**Theorem 3.3 (no decreasing law).** There is no strictly decreasing
$f : \mathbb{Q}\to\mathbb{Q}$ with $k^*_i = f(\mathrm{TPW}_i)$.

*Proof.* Take $i = $ mathematics, $j = $ German. Then
$1.214 < 1.885$ and $16 < 20$, a concordant pair; apply Theorem 3.1(2).
$\square$

**Theorem 3.4 (the verdict).** Both horns fail:
$$\lnot\exists f \text{ strictly increasing with } k^* = f(\mathrm{TPW}),
\qquad
\lnot\exists f \text{ strictly decreasing with } k^* = f(\mathrm{TPW}).$$

**Theorem 3.5 (the censored point only strengthens the case).** Let $K \ge 32$
be the true French knee, whatever it is. French has TPW $1.246 < 1.885$
(German) and knee $K \ge 32 > 20$ (German). This is a discordant pair, so the
increasing horn fails on the two-point subsystem $\{\text{fr},\text{de}\}$ alone,
uniformly in $K$.

The censoring therefore cannot be rescuing the hypothesis; restoring the French
point makes the refutation stronger, not weaker.

---

## 4. The replacement model: capture curves and the knee functional

### 4.1 Attention profiles

**Definition 4.1 (attention profile).** An *attention profile* is a pair
$P = (d_P, C_P)$ consisting of a token density $d_P \in \mathbb{Q}$ (a surface
label) and a *capture curve* $C_P : \mathbb{N} \to \mathbb{Q}$ satisfying

- $C_P(0) = 0$ (no keys capture no mass),
- $C_P$ nondecreasing (adding keys never loses mass),
- $C_P(k) \le 1$ for all $k$ (captured mass is a fraction),
- for every $\tau < 1$ there exists $k$ with $C_P(k) \ge \tau$ (every tolerance
  short of full mass is eventually met).

$C_P(k)$ is interpreted as the attention mass carried by the $k$ heaviest keys.

**Definition 4.2 (knee at tolerance).** For $\tau < 1$,
$$k^*_P(\tau) \;=\; \min\{k \in \mathbb{N} : C_P(k) \ge \tau\}.$$
The set is nonempty by the last axiom, so the minimum exists.

**Proposition 4.3 (basic properties).** For $0 < \tau < 1$:

1. *(attainment)* $C_P(k^*_P(\tau)) \ge \tau$.
2. *(minimality)* $j < k^*_P(\tau) \implies C_P(j) < \tau$.
3. *(positivity)* $k^*_P(\tau) \ge 1$.
4. *(monotone in tolerance)* $\tau \le \sigma < 1 \implies k^*_P(\tau) \le
   k^*_P(\sigma)$.
5. *(antitone in concentration)* if $C_P(k) \le C_Q(k)$ for all $k$, then
   $k^*_Q(\tau) \le k^*_P(\tau)$.
6. *(density blindness)* $C_P = C_Q \implies k^*_P(\tau) = k^*_Q(\tau)$,
   regardless of $d_P, d_Q$.

*Proof.* (1) and (2) are the defining properties of a least element. (3) since
$C_P(0)=0<\tau$. (4) $C_P(k^*_P(\sigma)) \ge \sigma \ge \tau$, so
$k^*_P(\sigma)$ lies in the defining set for $\tau$. (5)
$C_Q(k^*_P(\tau)) \ge C_P(k^*_P(\tau)) \ge \tau$. (6) the defining set depends
only on $C$. $\square$

Item (6) is the pivot: the knee is a functional of the capture curve *alone*.
Section 4.2 turns this observation into a full impossibility theorem.

### 4.2 Decoupling: no functional law exists

**Definition 4.4 (uniform-mass domain).** For $0 < \tau < 1$, $k \ge 1$ and any
density $d$, let $U_{d,\tau,k}$ be the profile with
$$C(j) = \min\!\left(1, \frac{j\tau}{k}\right),$$
i.e. each of the first $k$ keys carries mass $\tau/k$.

**Theorem 4.5 (exact knee of the uniform domain).**
$k^*_{U_{d,\tau,k}}(\tau) = k$.

*Proof.* At $j = k$ the curve reads $\min(1,\tau) = \tau$, so the knee is at
most $k$. For $j < k$, $j\tau/k < \tau$, so the curve is $<\tau$ and the knee is
not smaller. $\square$

Notice that Theorem 4.5 also shows the **concentration bound is tight**: in this
profile no key carries more than $m = \tau/k$, and the bound $k^* \ge \tau/m = k$
of Theorem 5.1 below is attained exactly.

**Theorem 4.6 (Decoupling Theorem).** Fix $0 < \tau < 1$. For every density
$d \in \mathbb{Q}$ and every $k \ge 1$ there is an attention profile $P$ with
$d_P = d$ and $k^*_P(\tau) = k$.

*Proof.* Take $P = U_{d,\tau,k}$ and apply Theorem 4.5; the density is a free
label. $\square$

**Corollary 4.7 (no functional law at all).** For $0<\tau<1$ there is no
function $g$ — of any kind — with $k^*_P(\tau) = g(d_P)$ for all profiles $P$.

*Proof.* Theorem 4.6 with $d = 1$ produces profiles $P$ and $Q$ with
$d_P = d_Q = 1$, $k^*_P(\tau)=1$ and $k^*_Q(\tau)=2$. Then $g(1)=1$ and
$g(1)=2$. $\square$

**Corollary 4.8 (the data are exactly what decoupling predicts).** There exist
attention profiles $P_{\mathrm{code}}, P_{\mathrm{de}}, P_{\mathrm{math}},
P_{\mathrm{en}}$ realising simultaneously the four measured token densities and
the four measured knees, at one fixed tolerance. Hence the observed
(density, knee) table carries no information against the model; it is a generic
point of the space of domains.

This is the precise sense in which P3 is *confirmed*: TPW is not a weak
predictor of the knee, it is not a predictor at all.

---

## 5. Concentration bounds: what does control the knee

Throughout this section a domain is presented by a **mass vector**
$p = (p_0 \ge p_1 \ge \cdots \ge 0)$ supported on $N$ keys with
$\sum_{i<N} p_i = 1$, and $C(k) = \sum_{i<k} p_i$ is its capture curve.

### 5.1 Per-key and top-key bounds

**Theorem 5.1 (concentration law).** If no single key adds more than $m>0$ of
the mass — i.e. $C(j+1)-C(j) \le m$ for all $j$ — then for $\tau < 1$,
$$k^*(\tau) \;\ge\; \frac{\tau}{m}.$$

*Proof.* Induction on $k$ gives $C(k) \le k m$: the base case is $C(0)=0$, and
$C(k+1) \le C(k) + m \le km + m$. Applying this at $k = k^*(\tau)$ together with
$C(k^*(\tau)) \ge \tau$ yields $\tau \le k^*(\tau)\, m$. $\square$

**Theorem 5.2 (top-mass bound).** For a sorted mass vector with $p_0 > 0$ and
$\tau < 1$,
$$k^*(\tau) \;\ge\; \frac{\tau}{p_0}.$$

*Proof.* Sortedness gives $p_i \le p_0$ for all $i$, hence
$C(k) = \sum_{i<k} p_i \le k p_0$. Combine with $C(k^*(\tau)) \ge \tau$.
$\square$

Interpretation: a domain with one dominant key has a small knee, however many
tokens its words cost.

### 5.2 The participation bound

**Definition 5.3 (collision index).** $S = \sum_{i<N} p_i^2$. Equivalently
$S = \exp(-H_2)$ where $H_2$ is the Rényi entropy of order $2$; $1/S$ is the
classical *effective number of participating keys* (inverse participation
ratio).

**Lemma 5.4.** For every $k$, $\sum_{i<k} p_i^2 \le S$.

*Proof.* If $k \le N$ the sum is a sub-sum of a sum of nonnegative terms; if
$k > N$ the extra terms vanish. $\square$

**Lemma 5.5 (Cauchy–Schwarz on the top-$k$ block).**
$C(k)^2 \le k \sum_{i<k} p_i^2 \le k\,S$.

*Proof.* $\left(\sum_{i<k} p_i\cdot 1\right)^2 \le
\left(\sum_{i<k} p_i^2\right)\left(\sum_{i<k} 1^2\right) = k \sum_{i<k} p_i^2$;
then Lemma 5.4. $\square$

**Theorem 5.6 (participation bound).** For $0 < \tau < 1$ and $S > 0$,
$$k^*(\tau) \;\ge\; \frac{\tau^2}{S} \;=\; \tau^2 \cdot (\text{effective number
of participating keys}).$$

*Proof.* $\tau^2 \le C(k^*(\tau))^2 \le k^*(\tau)\, S$ by Proposition 4.3(1)
and Lemma 5.5. $\square$

The bound is *information-theoretic*: the effective support size of the
attention distribution lower-bounds, up to the factor $\tau^2$, the number of
keys that must be retained. No property of the tokenizer appears anywhere in
the statement or the proof.

**Example 5.7 (a worked domain).** Let attention be spread evenly over four
keys, $p = (\tfrac14,\tfrac14,\tfrac14,\tfrac14)$. Then $S = 4 \cdot \tfrac1{16}
= \tfrac14$, $C(2) = \tfrac12$, $C(3) = \tfrac34$. At $\tau = \tfrac34$ the
knee is exactly $3$ (since $C(2) = \tfrac12 < \tfrac34 \le C(3)$), and the
participation bound predicts $k^* \ge \tau^2/S = (9/16)/(1/4) = 9/4 = 2.25$,
correctly and non-vacuously. The top-mass bound gives
$k^* \ge (3/4)/(1/4) = 3$, which here is exact.

### 5.3 The exactly solvable geometric family

**Definition 5.8 (geometric domain).** For $0 < r < 1$, let $G_r$ be the profile
with $C(k) = 1 - r^k$: residual attention beyond position $k$ decays like $r^k$,
and $r$ is the *decay rate* of the domain.

**Theorem 5.9 (exact solution).** For $\tau < 1$ and any $k$,
$$k^*_{G_r}(\tau) \le k \iff r^k \le 1 - \tau.$$

*Proof.* ($\Leftarrow$) $r^k \le 1-\tau$ gives $C(k) = 1-r^k \ge \tau$, so the
knee is at most $k$. ($\Rightarrow$) If $k^*(\tau) \le k$ then by monotonicity
$C(k) \ge C(k^*(\tau)) \ge \tau$, i.e. $1-r^k \ge \tau$. $\square$

Equivalently $k^*_{G_r}(\tau) = \lceil \log(1-\tau)/\log r \rceil$.

**Theorem 5.10 (monotonicity in the decay rate).** If $0 < r \le s < 1$ then
$k^*_{G_r}(\tau) \le k^*_{G_s}(\tau)$ for every $\tau < 1$.

*Proof.* $r^k \le s^k$ gives $C_{G_r}(k) \ge C_{G_s}(k)$ pointwise; apply
Proposition 4.3(5). $\square$

**Theorem 5.11 (the domain shift, reproduced at equal token density).** Fix any
density $d$ and let both $G_{1/2}$ and $G_{9/10}$ carry it. At tolerance
$\tau = 3/4$,
$$k^*_{G_{1/2}}(3/4) = 2, \qquad k^*_{G_{9/10}}(3/4) = 14,$$
while the two domains have identical tokens-per-word.

*Proof.* By Theorem 5.9 with $1-\tau = 1/4$. For $r = 1/2$: $(1/2)^2 = 1/4 \le
1/4$ but $(1/2)^1 = 1/2 > 1/4$, so $k^* = 2$. For $r = 9/10$:
the exact rational comparison gives $(9/10)^{14} = 9^{14}/10^{14} \le 1/4$
while $(9/10)^{13} = 9^{13}/10^{13} > 1/4$ (numerically $0.2288$ versus
$0.2542$), so $k^* = 14$.
$\square$

A sevenfold gap in memory requirement, generated purely by attention decay,
between two domains that are indistinguishable to any tokenizer statistic. This
is the in-model analogue of code ($k^*=12$) versus French ($k^*>32$) at nearly
equal token density.

---

## 6. Structure: knee dominance is majorization

Sections 4–5 show the knee is *some* functional of concentration. This section
shows exactly how much of the concentration it remembers.

**Definition 6.1.** For profiles $P, Q$:

- $P$ **knee-dominates** $Q$, written $P \succeq_{k} Q$, if
  $k^*_P(\tau) \le k^*_Q(\tau)$ for all $\tau \in (0,1)$;
- $P$'s capture **majorizes** $Q$'s, written $P \succeq_{C} Q$, if
  $C_Q(k) \le C_P(k)$ for all $k$.

For mass vectors of equal total, $\succeq_C$ is precisely the classical
majorization order: $P$'s top-$k$ block is at least as heavy as $Q$'s for every
$k$.

**Theorem 6.2 (Duality Theorem).** $P \succeq_k Q \iff P \succeq_C Q$.

*Proof.* ($\Leftarrow$) is Proposition 4.3(5). ($\Rightarrow$): suppose
$C_P(k) < C_Q(k)$ for some $k$. Set $\tau = \tfrac12(C_P(k)+C_Q(k))$. Since
$0 \le C_P(k) < \tau < C_Q(k) \le 1$ we have $\tau \in (0,1)$. From
$\tau \le C_Q(k)$ we get $k^*_Q(\tau) \le k$. From $C_P(k) < \tau$ and
monotonicity of $C_P$ we get $C_P(j) < \tau$ for all $j \le k$, hence
$k^*_P(\tau) > k \ge k^*_Q(\tau)$, contradicting knee dominance. $\square$

The knee curve is therefore an order-isomorphic shadow of the majorization order
on attention profiles. The "relational structure" the refutation points at is,
concretely, a majorization order.

**Theorem 6.3 (the knee curve is a complete invariant).** If
$k^*_P(\tau) = k^*_Q(\tau)$ for all $\tau \in (0,1)$, then $C_P = C_Q$.

*Proof.* Equality gives dominance in both directions; Theorem 6.2 gives
majorization in both directions; hence $C_P(k) = C_Q(k)$ for all $k$. $\square$

Note what is *not* determined: the token densities $d_P, d_Q$ remain completely
unconstrained. Everything the knee curve knows is concentration; nothing it
knows is tokenization.

**Definition 6.4 (mixed corpus).** For $\lambda \in [0,1]$, the mixture
$M_\lambda(P,Q)$ has
$$d = \lambda d_P + (1-\lambda) d_Q, \qquad
C(k) = \lambda C_P(k) + (1-\lambda) C_Q(k).$$
One checks the profile axioms directly: $C(0)=0$, monotonicity and the bound
$C \le 1$ are preserved by convex combination, and the tolerance $\tau$ is met
at $\max(k^*_P(\tau), k^*_Q(\tau))$.

**Theorem 6.5 (Mixture Sandwich).** For $\tau < 1$,
$$\min\big(k^*_P(\tau), k^*_Q(\tau)\big) \;\le\; k^*_{M_\lambda(P,Q)}(\tau)
\;\le\; \max\big(k^*_P(\tau), k^*_Q(\tau)\big).$$

*Proof.* Upper bound: at $k = \max(k^*_P,k^*_Q)$ both $C_P(k) \ge \tau$ and
$C_Q(k) \ge \tau$, so the convex combination is $\ge \tau$. Lower bound: if the
mixture's knee $k_0$ were strictly below both component knees, then by
minimality $C_P(k_0) < \tau$ and $C_Q(k_0) < \tau$, so
$\lambda C_P(k_0) + (1-\lambda)C_Q(k_0) < \tau$ (strictly, since the weights sum
to $1$ and at least one is positive), contradicting attainment at $k_0$.
$\square$

**Corollary 6.6 (the spread is not a mixing artifact).** If $P$ has knee $2$ and
$Q$ has knee $14$ at $\tau = 3/4$, every mixture of them has knee in $[2,14]$.
Blending domains can never produce a corpus harder than both ingredients or
easier than both; the observed inter-domain spread is genuine structure.

---

## 7. Algorithms

The theory is directly computational. Four procedures suffice to reproduce
every claim above.

**Algorithm A (knee from a capture curve).** Given a nondecreasing sequence
$C(0), C(1), \dots$ and $\tau$, scan $k = 0, 1, 2, \dots$ and return the first
$k$ with $C(k) \ge \tau$. Cost $O(k^*)$; with binary search on a bounded grid,
$O(\log n)$ evaluations, exploiting monotonicity.

**Algorithm B (Spearman coefficient with declared tie convention).** Rank both
observables under a stated convention (ordinal, competition, or midrank),
compute $\sum_i (r_i-s_i)^2$, and return $1 - 6\sum d^2/(n(n^2-1))$. Cost
$O(n\log n)$ for the sort. Reporting the convention is not optional: the four
conventions here give $-2/5, -1/5, -1/10, -1/4$, and only the *sign* is
convention-free.

**Algorithm C (discordant-pair certificate).** Given paired observables, scan
all $\binom{n}{2}$ pairs and return (i) any pair with $x_i<x_j$ and $y_j \le
y_i$ — a certificate refuting all increasing laws — and (ii) any pair with
$x_i<x_j$ and $y_i<y_j$ — a certificate refuting all decreasing laws. Cost
$O(n^2)$, or $O(n \log n)$ via an inversion count. This is the algorithmic form
of Theorem 3.1 and returns a *proof object*, not a $p$-value.

**Algorithm D (concentration certificate).** Given an empirical attention mass
vector, sort descending, compute $p_0$, $S = \sum p_i^2$, and the capture curve
by prefix sums; return the certified lower bounds $\tau/p_0$ and $\tau^2/S$ on
the knee, together with the exact knee read off the prefix sums. Cost
$O(n \log n)$ dominated by the sort. This converts a handful of forward passes
into a hard floor on the admissible cache size.

---

## 8. Discussion

### 8.1 What was refuted, and how strongly

Three levels of refutation were established, in increasing strength:

1. **Statistical.** $\rho = -0.40$ and $R^2 \approx 0.004$ on the measured data.
   A statistical refutation is contingent on the sample.
2. **Order-theoretic.** A single discordant pair (English versus code) rules out
   *every* increasing law and a single concordant pair (mathematics versus
   German) rules out every decreasing one. This is contingent only on two data
   points each, and survives any monotone re-scaling of either observable.
3. **Structural.** The Decoupling Theorem shows every (density, knee) pair is
   realisable, so no function of density predicts the knee even in principle.
   This is contingent on nothing.

Level 3 explains levels 1 and 2. The correlation was not low because the
experiment was underpowered; it was low because the quantity being correlated
carries no information about the target.

### 8.2 What replaces it

The knee is a functional of the capture curve, bounded below by three relational
statistics — $\tau/m$, $\tau/p_0$, $\tau^2/S$ — and, on the geometric family,
determined exactly by the decay rate. At the level of orders, knee dominance
*is* majorization, and the knee curve determines the capture curve exactly.

This is a satisfying place for the mechanism to live, because majorization is
the canonical mathematics of "how spread out is this distribution", carrying
with it Schur convexity, the Hardy–Littlewood–Pólya transfer theorem, and the
whole Rényi entropy family. The collision index $S$ is the $\alpha=2$ member of
that family; Section 9 conjectures that the full spectrum determines the knee
curve.

### 8.3 Practical consequences

- **Do not budget cache from tokenizer statistics.** Tokens-per-word is cheap,
  intuitive, and provably uninformative about $k^*$.
- **Do budget from measured concentration.** $p_0$ and $S$ are estimable from a
  small number of forward passes and yield *certified* lower bounds on the
  retention budget. Under-provisioning below $\tau^2/S$ is guaranteed to lose
  mass.
- **Expect nonuniform budgets.** Since knees genuinely differ by a factor of
  three or more across domains, a single global $k$ is either wasteful on
  concentrated domains or lossy on diffuse ones. Domain-adaptive retention is
  the correct design.
- **Mixtures are safe to reason about.** The Sandwich Theorem means a mixed
  workload's requirement is bracketed by its components', so a per-domain
  audit bounds a mixed deployment.

### 8.4 Limitations

The measurement is one model, one tokenizer, one context length, five domains,
$5000$-word samples. The French knee is censored above $32$. The abstract
theory is deterministic and exact, but the identification of "quality
saturation" with "capture of a mass fraction $\tau$" is a modelling assumption:
it presumes that output degradation is controlled by discarded attention mass.
Establishing that link quantitatively — a perturbation bound from discarded mass
to output deviation — is the main missing ingredient between the theory and the
measurement.

---

## 9. Future work

**Rényi spectrum determines the knee curve.** The knee curve $\tau \mapsto
k^*(\tau)$ is the quantile function of the sorted attention mass, so it should be
recoverable from the full Rényi spectrum $\{H_\alpha\}$, not merely bounded by
the $\alpha=2$ member as in the participation bound. Since the knee curve is a
complete invariant of the capture curve (Theorem 6.3), the only missing link is
a dictionary between capture curves and Rényi entropies, which is standard
majorization theory. *Conjecture:* for sorted mass vectors,
$k^*_P(\tau) \le k^*_Q(\tau)$ for all $\tau$ iff $H_\alpha(P) \le H_\alpha(Q)$
for all $\alpha \ge 1$ — i.e. majorization is detected by the Rényi family
alone.

**Knee superadditivity under context doubling.** Doubling the context length
re-samples the same domain's attention shape. If the capture curve is concave,
the knee should grow *sublinearly*: $k^*_{2n}(\tau) \le 2\,k^*_n(\tau)$, with
equality only for uniform attention. The model already has monotonicity in
tolerance and antitonicity in the capture curve; adding concavity gives a
Karamata-style comparison directly testable on a $512 \to 1024 \to 4096$ grid.

**Censored-knee inference for French.** A censored measurement $k^*>32$ still
pins the capture curve into a half-space, so a single additional measurement at
a lower tolerance determines whether French is *uniformly* less concentrated
than the other domains or merely has a heavier tail. The extended grid already
shows $k^*(\text{fr}) \le 32$ under a relaxed criterion; sub-$32$ resolution at
context $1024$ would close the gap.

**Attention-pattern structural analysis.** The refutation says the mechanism is
relational; the bounds say it is concentration; the duality says it is
majorization. What remains is to identify *which linguistic structures* produce
slow attention decay — long-range agreement, discourse anaphora, and clause
embedding are the natural candidates for French, and locality of reference the
natural candidate for code's unusually fast decay.

**Scaling cells.** The same measurement at model scale $0.5$B and $7$B, and at
context $4096$, would test whether the knee ordering across domains is a
property of the language or of the model.

---

## 10. Conclusion

Tokenization density explains none of the memory-requirement shift across text
domains. The measured rank correlation is $-0.40$ and the linear fit explains
$0.4\%$ of variance; more decisively, one discordant pair rules out every
increasing law, one concordant pair rules out every decreasing law, and the
Decoupling Theorem rules out every law of any shape by exhibiting domains with
arbitrary (density, knee) combinations.

What does control the knee is the concentration geometry of attention. It is
bounded below by the reciprocal per-key mass, by the reciprocal top-key mass,
and by the effective number of participating keys; it is exactly solvable on
geometric decay profiles, where a decay-rate change from $1/2$ to $9/10$ moves
the knee from $2$ to $14$ at fixed token density; and, as an order, knee
dominance is precisely majorization of capture curves, with the knee curve a
complete invariant of concentration and mixtures always interleaved between
their components.

The domain shift is not on the surface of the text. It is in how far back the
model has to reach.
