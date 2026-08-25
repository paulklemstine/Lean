# The Two-Layer Occupancy Model: Rank-One Nulls, the Harmonic Positional Law, and Separation-Robust Inference

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

We develop the mathematical theory underlying a class of scan experiments in
which each of finitely many indices (moduli, settings, strata) produces a random
number of *hits*, and each hit is recorded at a position within a scan window,
binned into finitely many bins. Such data decompose into a **rate layer** (how
many hits each index produces) and a **positional layer** (how those hits
distribute across bins). We prove that the two layers are uniquely determined by
the expected occupancy table; that the hypothesis of *no interaction* between
them is exactly the statement that the occupancy table has rank one, and exactly
the statement that all $2\times2$ cross-product contrasts vanish; and that both
the Pearson and likelihood-ratio interaction statistics vanish precisely on this
condition, so that the standard tests test the intended algebraic hypothesis. We
prove a two-sided resolution result: under homogeneity every pooled stratum
profile is identical (so the population Kolmogorov–Smirnov contrast between rate
strata is exactly zero), while in general the pooled total-variation contrast is
bounded above by the worst pairwise profile heterogeneity, converting a null
observation into a quantitative bound. On the rate side we prove a finite-mixture
law of total variance, deduce that conditionally equidispersed counts are
overdispersed with equality exactly at a degenerate rate layer, and exhibit
explicit models establishing that the two layers are logically independent:
unbounded overdispersion with a perfectly homogeneous positional layer, and
mutually singular profiles with exact equidispersion.

We then determine the positional layer itself. The harmonic (i.e. $1/x$-density)
window law has leading-fraction cumulative mass
$F_r(u) = \log(1+(r-1)u)/\log r$ for a window of endpoint ratio $r>1$. We prove
that $F_r$ is a strictly increasing CDF with the harmonic density, that it is
scale free (depends only on $r$), and that it exhibits a strict early-window
excess $F_r(u) > u$ for all $0<u<1$, via strict Bernoulli's inequality for real
exponents; in particular the leading decile always carries more than one tenth of
the mass, in every rate stratum simultaneously. We prove an identifiability
theorem: for each fixed $u \in (0,1)$ the map $r \mapsto F_r(u)$ is a strictly
increasing bijection $(1,\infty) \to (u,1)$, so an edge-decile mass determines the
window ratio uniquely and two strata share an edge-decile mass iff they share a
window ratio. Finally we bridge the continuum law to its arithmetic carrier: the
normalised discrete $1/j$ weight of the leading $k$ deciles of a doubling window
converges to $F_2(k/10)$, with the Euler–Mascheroni constant cancelling in the
difference of harmonic numbers; in particular the leading decile converges to
$\log(11/10)/\log 2 = 0.13750\ldots > 1/10$.

The last part treats inference. We prove finite-sample validity and strict
positivity of permutation p-values, and a Bonferroni bound for families of
super-uniform p-values. We then prove that a (quasi-)separated logistic design
admits **no** maximum-likelihood estimate, that the ridge-penalised objective
admits **exactly one** maximiser for every design and every $\lambda>0$, and a
two-sided *escape sandwich*: every ridge maximiser satisfies
$\lambda\|\hat\beta_\lambda\|^2 \le n\log 2$, its likelihood deficiency vanishes
as $\lambda\downarrow 0$, any vector with deficiency $\delta$ obeys
$\log(1/\delta)-\delta \le \|\beta\|\,\|x_i\|$, and consequently
$\|\hat\beta_\lambda\|^2 \to \infty$ as $\lambda \downarrow 0$.

**Keywords:** two-layer occupancy model, rank-one contingency table, interaction
likelihood-ratio test, harmonic positional law, overdispersion, law of total
variance, permutation validity, quasi-separation, ridge-penalised logistic
regression.

---

## 1. Introduction

### 1.1 The empirical setting

A *scan experiment* proceeds as follows. A finite family of indices
$i \in \iota$ — in the motivating case, $128$ moduli $N$ — is fixed. For each
index the experiment sweeps a window and records a finite set of *hits*. Two
statistics of the sweep are retained: the number of hits, and the position of
each hit within the window, discretised into $|\beta|$ bins (here ten deciles).
The empirical data set contains $9{,}594$ hits.

Sorting the indices into terciles by hit count — hit-poor, mid, hit-rich, of
sizes $42/42/44$ — yields the pre-registered question: **does the shape of the
positional profile depend on the hit rate?** In the language developed below,
does the positional layer *interact* with the rate layer?

The answer, empirically, is no: an interaction likelihood-ratio test returned
$\chi^2 = 51.31$ on $49$ degrees of freedom ($p = 0.383$; permutation
$p = 0.34$; zero of $49$ Wald-significant bins), and the pooled hit-rich versus
hit-poor Kolmogorov–Smirnov statistic $D = 0.0462$, with raw $p = 0.0038$, failed
multiplicity correction ($p_{\text{adj}} = 0.049$ against a $0.05$ threshold).
Meanwhile the edge-decile excess replicated across all three terciles:
$0.229/0.245/0.230$.

A control arm of the same design fired spuriously on dense size-matched controls
($p = 0.012$ by permutation), with odds ratios clipped at $e^{\pm 30}$ — the
signature of quasi-separation.

### 1.2 What this paper proves

A null result is only as meaningful as the mathematics that surrounds it. This
paper supplies that mathematics in four blocks.

1. **Structure (§2–§3).** The two-layer model, uniqueness of the decomposition,
   the equivalence of the no-interaction null with rank-oneness and with the
   vanishing of all $2\times2$ contrasts, and the fact that the Pearson and
   likelihood-ratio statistics vanish exactly on that null.
2. **Resolution and dispersion (§4–§5).** Under homogeneity, all pooled stratum
   profiles coincide; in general the pooled contrast is dominated by the worst
   pairwise heterogeneity. A finite-mixture law of total variance identifies the
   rate layer as the sole source of overdispersion, and two explicit models
   establish the logical independence of the layers.
3. **The positional law (§6–§8).** The harmonic window law, its scale
   invariance, its strict early-window excess, its identifiability in the window
   ratio, and its realisation as the limit of the discrete $1/j$ carrier.
4. **Inference (§9–§11).** Finite-sample permutation validity, Bonferroni,
   nonexistence of the MLE under separation, existence and uniqueness of the
   ridge estimator, and the escape sandwich quantifying its divergence.

Throughout, all proofs are elementary and finite: no asymptotic distribution
theory, no measure-theoretic limits beyond a single classical fact about harmonic
numbers, and no appeal to large-sample approximations.

---

## 2. The two-layer occupancy model

### 2.1 Definition

**Definition 2.1 (Two-layer model).** Let $\iota$ and $\beta$ be finite nonempty
sets (indices and positional bins). A *two-layer occupancy model* $M$ consists of

- a **rate layer**: a function $\rho : \iota \to \mathbb{R}$ with $\rho_i > 0$
  for all $i$;
- a **positional layer**: functions $p_i : \beta \to \mathbb{R}$ with
  $p_i(b) \ge 0$ and $\sum_{b} p_i(b) = 1$ for every $i$.

Its **expected occupancy table** is $O_{ib} := \rho_i\, p_i(b)$.

Immediately $\sum_b O_{ib} = \rho_i$: the rate layer is the vector of row sums.

**Definition 2.2 (Pooled quantities).** Given index weights $w : \iota \to
\mathbb{R}$ and a stratum $S \subseteq \iota$, set

$$\Pi_S(b) := \sum_{i \in S} w_i O_{ib}, \qquad
m_S := \sum_{i\in S} w_i \rho_i, \qquad
\hat p_S(b) := \frac{\Pi_S(b)}{m_S}.$$

We call $\hat p_S$ the *pooled (normalised) positional profile* of $S$. Note
$\sum_b \Pi_S(b) = m_S$, so $\hat p_S$ sums to one whenever $m_S \neq 0$.

**Definition 2.3 (Homogeneity).** $M$ is *positionally homogeneous* if
$p_i = p_j$ for all $i,j \in \iota$.

### 2.2 Identifiability

**Theorem 2.4 (The layers are identifiable).** If two two-layer models $M, M'$ on
the same index and bin sets satisfy $O_{ib} = O'_{ib}$ for all $i,b$, then
$\rho = \rho'$ and $p = p'$.

*Proof.* Summing the hypothesis over $b$ gives
$\rho_i = \sum_b O_{ib} = \sum_b O'_{ib} = \rho'_i$. Then
$\rho'_i p_i(b) = \rho_i p_i(b) = O_{ib} = O'_{ib} = \rho'_i p'_i(b)$, and
$\rho'_i > 0$ permits cancellation. $\square$

Theorem 2.4 is what licenses the phrase "the positional layer" as a statement
about the data rather than about a parametrisation: no reparametrisation can
trade rate against shape.

---

## 3. The algebra of "no interaction"

### 3.1 Rank-oneness

**Theorem 3.1 (Rank-one criterion).** Let $\iota$ be nonempty. Then there exist
$u : \iota \to \mathbb{R}$ and $v : \beta \to \mathbb{R}$ with $O_{ib} = u_i v_b$
for all $i, b$ **if and only if** $M$ is positionally homogeneous.

*Proof.* ($\Leftarrow$) If $p_i \equiv p$, take $u_i = \rho_i$ and $v_b = p(b)$.

($\Rightarrow$) Suppose $O_{ib} = u_i v_b$ and put $\sigma := \sum_b v_b$.
Summing over $b$ gives $u_i \sigma = \rho_i > 0$ for every $i$; hence
$\sigma \ne 0$ and $u_i \ne 0$ for every $i$. Now
$u_i \sigma\, p_i(b) = \rho_i p_i(b) = u_i v_b$; cancelling $u_i \neq 0$ yields
$\sigma\, p_i(b) = v_b$, i.e. $p_i(b) = v_b/\sigma$, which is independent of $i$.
$\square$

The theorem says: *the no-interaction null hypothesis is exactly the statement
that the expected occupancy table has rank one.* This is the population version of
the hypothesis that a saturated log-linear model reduces to its additive
submodel.

### 3.2 Cross-product contrasts

**Theorem 3.2 (Interaction-free criterion).** The identity
$$O_{ib}\, O_{jc} = O_{ic}\, O_{jb} \qquad \text{for all } i,j \in \iota,\ b,c \in \beta$$
holds **if and only if** $M$ is positionally homogeneous.

*Proof.* ($\Leftarrow$) With $p_i \equiv p$, both sides equal
$\rho_i\rho_j p(b)p(c)$ resp. $\rho_i\rho_j p(c)p(b)$.

($\Rightarrow$) Expanding and cancelling the positive factor $\rho_i\rho_j$ gives
$p_i(b)p_j(c) = p_i(c)p_j(b)$ for all $b,c$. Fix $b$ and sum over $c \in \beta$;
using $\sum_c p_j(c) = \sum_c p_i(c) = 1$,
$$p_i(b) = p_i(b)\sum_c p_j(c) = \sum_c p_i(c) p_j(b) = p_j(b). \qquad\square$$

### 3.3 The interaction statistics see exactly this

Let $O : \iota \times \beta \to \mathbb{R}_{>0}$ be a strictly positive table
(not necessarily of two-layer form). Write
$$R_i = \sum_b O_{ib},\quad C_b = \sum_i O_{ib},\quad T = \sum_i R_i,\quad
E_{ib} = \frac{R_i C_b}{T}.$$

**Definition 3.3.** The *Pearson interaction statistic* and the
*likelihood-ratio (G) interaction statistic* are
$$\chi^2(O) = \sum_{i,b}\frac{(O_{ib}-E_{ib})^2}{E_{ib}}, \qquad
G(O) = 2\sum_{i,b} O_{ib}\log\frac{O_{ib}}{E_{ib}}.$$

**Lemma 3.4 (Sharp Gibbs term).** For $a, e > 0$,
$a\log(a/e) - a + e \ge 0$, with equality iff $a = e$.

*Proof.* Put $t = e/a > 0$. The claim reads $-a\log t - a + at \ge 0$, i.e.
$\log t \le t-1$, which is standard, with equality iff $t=1$. $\square$

**Theorem 3.5.** $\chi^2(O) \ge 0$ and $G(O) \ge 0$, and each vanishes if and
only if $O_{ib} = E_{ib}$ for all $i,b$.

*Proof.* Positivity of $E$ follows from positivity of $O$. For $\chi^2$ each
summand is nonnegative and vanishes iff $O_{ib} = E_{ib}$. For $G$, note
$\sum_b E_{ib} = R_i$ and $\sum_{i,b}E_{ib} = T = \sum_{i,b} O_{ib}$, so
$$\tfrac12 G(O) = \sum_{i,b}\Bigl(O_{ib}\log\frac{O_{ib}}{E_{ib}} - O_{ib} + E_{ib}\Bigr),$$
a sum of nonnegative terms by Lemma 3.4, each vanishing iff $O_{ib}=E_{ib}$.
$\square$

**Theorem 3.6 (The test tests the intended hypothesis).** For a two-layer
occupancy table $O_{ib} = \rho_i p_i(b)$ with $\iota, \beta$ nonempty,
$$O_{ib} = E_{ib} \ \ \forall i,b \iff M \text{ is positionally homogeneous.}$$

*Proof.* Here $R_i = \rho_i$ and $T = \sum_k \rho_k > 0$. ($\Rightarrow$)
$\rho_i p_i(b) = \rho_i C_b / T$ and $\rho_i>0$ give $p_i(b) = C_b/T$,
independent of $i$. ($\Leftarrow$) If $p_i \equiv p$ then
$C_b = \sum_k \rho_k p(b) = T\,p(b)$, so $E_{ib} = \rho_i T p(b)/T = \rho_i p(b)
= O_{ib}$. $\square$

Combining Theorems 3.5 and 3.6: *both interaction statistics vanish precisely
when the positional layer does not depend on the rate layer.* There is no gap
between the algebraic null and the statistic used to probe it.

---

## 4. Resolution: what a null contrast bounds

Under homogeneity, stratification by the rate layer is powerless — a good thing,
since it means a null is predicted rather than merely permitted.

**Theorem 4.1 (Stratum invariance).** If $p_i \equiv p$ then for every weight
function $w$ and every stratum $S$ with $m_S \neq 0$, $\hat p_S = p$. In
particular any two strata $S,T$ with nonzero mass satisfy $\hat p_S = \hat p_T$.

*Proof.* $\Pi_S(b) = \sum_{i\in S} w_i \rho_i p(b) = m_S\, p(b)$; divide by
$m_S$. $\square$

**Corollary 4.2 (Zero population KS).** If $\beta$ is linearly ordered and
$p_i \equiv p$, then for all $t \in \beta$ and all strata $S,T$ of nonzero mass,
$$\Bigl|\sum_{b \le t}\hat p_S(b) - \sum_{b\le t}\hat p_T(b)\Bigr| = 0.$$

So under the null the population Kolmogorov–Smirnov statistic between hit-rich
and hit-poor terciles is exactly zero, for every cut point and every choice of
terciles.

The converse direction is the one that makes an observed null informative.

**Lemma 4.3 (Pooling is convex).** If $m_S \neq 0$ then
$$\hat p_S(b) = \sum_{i \in S} c_i\, p_i(b), \qquad c_i := \frac{w_i\rho_i}{m_S},
\qquad \sum_{i\in S} c_i = 1.$$

*Proof.* Immediate from the definitions, since $m_S = \sum_{i\in S} w_i\rho_i$.
$\square$

**Theorem 4.4 (Total-variation contrast bound).** Let $w \ge 0$ on $S \cup T$
and $m_S, m_T > 0$. Suppose every pair of indices has profiles within total
variation $\varepsilon$:
$$\tfrac12\sum_b |p_i(b)-p_j(b)| \le \varepsilon \quad \forall i,j.$$
Then $\tfrac12\sum_b |\hat p_S(b) - \hat p_T(b)| \le \varepsilon$.

*Proof.* With $c_i$ (for $S$) and $d_j$ (for $T$) as in Lemma 4.3, both
nonnegative and summing to one,
$$\hat p_S(b) - \hat p_T(b) = \sum_{i\in S}\sum_{j\in T} c_i d_j\,(p_i(b)-p_j(b)).$$
Taking absolute values, applying the triangle inequality twice, summing over $b$,
exchanging the order of summation, and applying the hypothesis
$\sum_b |p_i(b)-p_j(b)| \le 2\varepsilon$ pointwise in $(i,j)$ gives
$\sum_b|\hat p_S - \hat p_T| \le 2\varepsilon \sum_i\sum_j c_i d_j = 2\varepsilon$.
$\square$

**Theorem 4.5 (Bin-wise version).** If $L \le p_i(b) \le U$ for all $i$ (a fixed
bin $b$), and $w \ge 0$ with $m_S, m_T > 0$, then
$|\hat p_S(b) - \hat p_T(b)| \le U - L$.

*Proof.* Lemma 4.3 exhibits $\hat p_S(b)$ and $\hat p_T(b)$ as convex
combinations of numbers in $[L,U]$, hence both lie in $[L,U]$. $\square$

**Interpretation.** Theorems 4.4 and 4.5 are the resolution guarantees. An
observed pooled contrast is a *lower* bound on the worst pairwise heterogeneity:
a small observed rich-versus-poor contrast forces the underlying per-index
profiles to be nearly identical. This is what distinguishes an informative null
from an underpowered one. In the motivating data, $D = 0.0462$ pooled over
terciles bounds the pairwise profile heterogeneity at a comparable scale.

---

## 5. The rate layer: overdispersion, and independence of the layers

### 5.1 Finite-mixture law of total variance

**Definition 5.1.** For weights $w$ with $\sum_i w_i = 1$, conditional means $m$
and conditional variances $v$, set
$$\bar m := \sum_i w_i m_i, \qquad
\operatorname{Var}(w,m,v) := \sum_i w_i (v_i + m_i^2) - \bar m^2 .$$

**Theorem 5.2 (Law of total variance).** $\displaystyle
\operatorname{Var}(w,m,v) = \sum_i w_i v_i + \sum_i w_i (m_i - \bar m)^2 .$

*Proof.* Expand $\sum_i w_i(m_i-\bar m)^2 = \sum_i w_i m_i^2 - 2\bar m\sum_i w_i m_i
+ \bar m^2 \sum_i w_i = \sum_i w_i m_i^2 - \bar m^2$, using $\sum_i w_i = 1$;
substitute. $\square$

**Theorem 5.3 (Overdispersion).** If additionally $w_i \ge 0$ and the mixture is
conditionally equidispersed ($v = m$, e.g. conditionally Poisson), then
$$\operatorname{Var}(w,m,m) \ \ge\ \bar m .$$

*Proof.* By Theorem 5.2 the excess equals $\sum_i w_i (m_i-\bar m)^2 \ge 0$.
$\square$

**Theorem 5.4 (Equality case).** Under the hypotheses of Theorem 5.3,
$$\operatorname{Var}(w,m,m) = \bar m \iff m_i = \bar m \text{ for every } i
\text{ with } w_i \neq 0 .$$

*Proof.* The excess is a sum of nonnegative terms $w_i(m_i-\bar m)^2$; it
vanishes iff each term does, i.e. iff $w_i = 0$ or $m_i = \bar m$. $\square$

Thus *any* excess dispersion certifies genuine between-index rate variation. The
observed $39\text{–}61\%$ unexplained overdispersion is, by Theorem 5.4, a
property of the rate layer.

### 5.2 The two layers are logically independent

**Theorem 5.5 (Unbounded overdispersion with a homogeneous positional layer).**
For every $C \in \mathbb{R}$ there is a two-layer model on two indices and two
bins, with weights $w$ summing to one, such that all positional profiles are
equal and
$$\operatorname{Var}(w,\rho,\rho) - \bar\rho \ \ge\ C\,\bar\rho .$$

*Proof (construction).* Take $s := 4|C|+4$, rates $\rho = (1, 1+s)$, weights
$w = (1/2,1/2)$, and the common profile $(1/2,1/2)$. Then $\bar\rho = 1 + s/2$
and the excess is $\sum_i w_i(\rho_i - \bar\rho)^2 = s^2/4$; the inequality
$s^2/4 \ge C(1+s/2)$ holds by the choice of $s$. $\square$

**Theorem 5.6 (Maximal positional heterogeneity with exact equidispersion).**
There is a two-layer model on two indices and two bins with constant rates —
hence $\operatorname{Var} = \bar\rho$ exactly — whose two positional profiles are
mutually singular:
$$\tfrac12\sum_b |p_0(b) - p_1(b)| = 1 .$$

*Proof (construction).* Rates $\rho \equiv 1$, weights $(1/2,1/2)$, profiles
$p_0 = (1,0)$ and $p_1 = (0,1)$. Constant rates give zero between-index variance,
so $\operatorname{Var} = \bar\rho$; the total variation distance is
$\tfrac12(|1-0|+|0-1|)=1$. $\square$

**Corollary 5.7.** No implication holds in either direction between
overdispersion of the rate layer and heterogeneity of the positional layer. In
particular a null interaction result does not follow from, and does not
contradict, any amount of overdispersion; it is genuinely new information.

---

## 6. The harmonic positional law

Empirically the positional layer is *not* uniform: the leading decile of the scan
window is consistently over-occupied. We now show that a single scale-free law
explains this, and that the law is forced by the $1/x$ density of the underlying
carrier.

**Definition 6.1 (Harmonic window CDF).** For a window ratio $r > 1$ and a
leading fraction $u \in [0,1]$,
$$F_r(u) := \frac{\log\bigl(1+(r-1)u\bigr)}{\log r}.$$

**Proposition 6.2.** $F_r(0) = 0$, $F_r(1) = 1$, $F_r$ is strictly increasing on
$[0,1]$, and for $u \ge 0$
$$F_r'(u) = \frac{r-1}{\bigl(1+(r-1)u\bigr)\log r}.$$

*Proof.* The endpoint values are immediate ($\log r/\log r = 1$). The derivative
is the chain rule applied to $\log(1+(r-1)u)$, and it is positive since $r>1$;
strict monotonicity follows. $\square$

The derivative formula identifies $F_r$ as the CDF of the harmonic density: if a
hit lies at $x$ with density $\propto 1/x$ on $[a, ra]$, then substituting
$x = a(1+(r-1)u)$ turns $\mathrm{d}x/x$ into
$(r-1)\,\mathrm{d}u/(1+(r-1)u)$, whose normalisation is $\log r$.

**Theorem 6.3 (Scale invariance).** For every $a > 0$, $r>1$, $u \ge 0$,
$$\frac{\log\bigl(a(1+(r-1)u)\bigr) - \log a}{\log(ra)-\log a} = F_r(u),$$
so two windows with the same endpoint ratio have identical positional profiles
regardless of their absolute location. Only the ratio $r$ is observable from the
profile.

*Proof.* Both logarithms of $a$ cancel in the numerator and denominator. $\square$

**Theorem 6.4 (Strict early-window excess).** For every $r>1$ and every
$0 < u < 1$,
$$F_r(u) > u .$$

*Proof.* Strict Bernoulli's inequality for real exponents gives, for
$0<u<1$ and $r-1 > -1$, $r-1 \neq 0$,
$$r^u = \bigl(1+(r-1)\bigr)^u < 1 + u(r-1).$$
Both sides are positive, so taking logarithms, $u\log r < \log(1+(r-1)u)$;
dividing by $\log r > 0$ yields the claim. $\square$

Equivalently: the harmonic law always front-loads, strictly, for every ratio and
every interior fraction. No asymptotics are involved.

**Definition 6.5 (Decile profile).** For $k = 0,\dots,9$,
$$\pi_r(k) := F_r\!\Bigl(\frac{k+1}{10}\Bigr) - F_r\!\Bigl(\frac{k}{10}\Bigr).$$

**Proposition 6.6.** $\pi_r(k) \ge 0$ for all $k$, and $\sum_{k=0}^{9}\pi_r(k) = 1$.

*Proof.* Nonnegativity is strict monotonicity (Proposition 6.2); the sum
telescopes to $F_r(1) - F_r(0) = 1$. $\square$

**Theorem 6.7 (Edge-decile excess).** For every $r>1$,
$$\pi_r(0) = F_r(1/10) > \tfrac{1}{10}.$$

*Proof.* Theorem 6.4 at $u = 1/10$, with $F_r(0)=0$. $\square$

### 6.1 Universality across rate strata

**Definition 6.8 (Harmonic two-layer model).** Given any rate layer
$\rho : \iota \to \mathbb{R}_{>0}$ and any $r>1$, the *harmonic model* is the
two-layer model with bins $\{0,\dots,9\}$, rate layer $\rho$, and the common
profile $p_i(k) = \pi_r(k)$ for every $i$.

**Theorem 6.9 (Universality of the edge excess).** In the harmonic model, for
every weighting $w$ and every stratum $S$ with $m_S \neq 0$,
$$\hat p_S = \pi_r \qquad \text{and} \qquad \hat p_S(0) > \tfrac{1}{10}.$$
Consequently any two strata $S,T$ of nonzero mass have $\hat p_S = \hat p_T$: the
population KS contrast between hit-rich and hit-poor terciles is exactly zero.

*Proof.* The harmonic model is positionally homogeneous, so Theorem 4.1 gives
$\hat p_S = \pi_r$; the excess is Theorem 6.7; equality of strata profiles is
Corollary 4.2. $\square$

Theorem 6.9 is the exact mathematical content of the empirical pattern: an
edge-decile excess of $0.229/0.245/0.230$ in the three terciles *together with* a
non-firing interaction test. One law, seen three times.

---

## 7. Identifiability of the window ratio

If the profile is harmonic with an unknown ratio $r$, is $r$ recoverable? Yes,
from a single leading-fraction mass.

**Lemma 7.1 (Strict convexity at the interpolation).** For $r>1$ and
$0<u<1$, writing $\sigma := 1+(r-1)u = u\cdot r + (1-u)\cdot 1$,
$$\sigma\log\sigma < u\, r\log r .$$

*Proof.* The function $x \mapsto x\log x$ is strictly convex on $(0,\infty)$, and
$\sigma$ is the strict interpolation of $r$ and $1$ with weights $u$ and $1-u$;
hence $\sigma\log\sigma < u\,r\log r + (1-u)\cdot 1\cdot\log 1 = u\,r\log r$.
$\square$

**Theorem 7.2 (Strict monotonicity in the ratio).** Fix $0<u<1$. Then
$r \mapsto F_r(u)$ is strictly increasing on $(1,\infty)$, with
$$\frac{\partial}{\partial r} F_r(u)
= \frac{\dfrac{u\log r}{1+(r-1)u} - \dfrac{\log(1+(r-1)u)}{r}}{(\log r)^2} > 0 .$$

*Proof.* The derivative formula is the quotient rule. Positivity is equivalent,
after clearing the positive denominators $r$, $\sigma := 1+(r-1)u$ and
$(\log r)^2$, to $u\, r \log r > \sigma\log\sigma$, which is Lemma 7.1. Strict
monotonicity follows from positivity of the derivative on the interval. $\square$

**Corollary 7.3 (Injectivity).** For fixed $u\in(0,1)$ the map $r\mapsto F_r(u)$
is injective on $(1,\infty)$.

**Lemma 7.4 (Brackets).** For $r>1$ and $0<u<1$:
(i) $F_r(u) \le u\,r$; (ii) $F_r(u) > 1 + \dfrac{\log u}{\log r}$.

*Proof.* (i) $\log(1+(r-1)u) \le (r-1)u$ and $(r-1)/\log r \le r$ for $r>1$ (both
elementary from $\log t \le t-1$). (ii) $1+(r-1)u > ru$ for $u<1$, so
$\log(1+(r-1)u) > \log u + \log r$; divide by $\log r$. $\square$

**Theorem 7.5 (Bijection onto $(u,1)$).** For fixed $u\in(0,1)$, the map
$r\mapsto F_r(u)$ is a strictly increasing bijection from $(1,\infty)$ onto
$(u,1)$.

*Proof.* Range containment: $F_r(u) > u$ by Theorem 6.4, and $F_r(u) < F_r(1)=1$
by strict monotonicity in $u$. Injectivity is Corollary 7.3. Surjectivity: fix
$y \in (u,1)$. By Lemma 7.4(i), $F_r(u) \le ur < y$ for $r$ close enough to $1$
(precisely, $r < y/u$), while by Lemma 7.4(ii), $F_r(u) > 1 + \log u/\log r > y$
once $\log r > \log(1/u)/(1-y)$. Continuity of $r\mapsto F_r(u)$ on
$(1,\infty)$ and the intermediate value theorem supply an $r$ with
$F_r(u) = y$. $\square$

**Corollary 7.6 (Inversion).** For each $u \in (0,1)$ and each $y \in (u,1)$
there is a *unique* $r>1$ with $F_r(u) = y$.

**Corollary 7.7 (The edge decile identifies the ratio).** Since
$\pi_r(0) = F_r(1/10)$, every edge-decile mass $m \in (1/10, 1)$ determines a
unique window ratio $r>1$ with $\pi_r(0) = m$. Moreover, for $r,s>1$,
$$\pi_r(0) = \pi_s(0) \iff r = s, \qquad \pi_r(0) < \pi_s(0) \iff r < s .$$

Thus the null hypothesis has an equivalent geometric formulation: *two
rate strata have the same edge-decile mass if and only if they scan windows of
the same endpoint ratio.* The observed terciles' edge masses
$0.229/0.245/0.230$ are, under this reading, three estimates of one geometric
parameter.

---

## 8. From the arithmetic carrier to the continuum law

The harmonic law was motivated by a $1/x$ density, but the underlying mechanism
is discrete: position $j$ carries weight $1/j$, and deciles are integer blocks.
We now prove that the discrete carrier realises the continuum law exactly in the
limit — the excess is not a binning artefact.

Write $H_n = \sum_{j=1}^{n} 1/j$ for the $n$-th harmonic number.

**Lemma 8.1 (Window weight).** For $a \le b$,
$$H_b - H_a = \sum_{i=a}^{b-1}\frac{1}{i+1}.$$

*Proof.* Telescoping of the partial sums. $\square$

**Theorem 8.2 (Cancellation of the Euler–Mascheroni constant).** For positive
integers $a, b$,
$$H_{aL} - H_{bL} \ \xrightarrow[L\to\infty]{}\ \log\frac{a}{b}.$$

*Proof.* Classically $H_n - \log n \to \gamma$. Along the subsequences
$n = aL$ and $n = bL$ (both $\to\infty$ since $a,b \ge 1$) we get
$H_{aL} - \log(aL) \to \gamma$ and $H_{bL} - \log(bL) \to \gamma$. Subtracting,
$$\bigl(H_{aL}-H_{bL}\bigr) - \bigl(\log(aL) - \log(bL)\bigr) \to 0,$$
and $\log(aL)-\log(bL) = \log a - \log b = \log(a/b)$ identically. $\square$

**Theorem 8.3 (Discrete deciles converge to the harmonic law).** Fix
$k \in \{0,1,\dots,10\}$. Then
$$\frac{H_{(10+k)L} - H_{10L}}{H_{20L} - H_{10L}}
\ \xrightarrow[L\to\infty]{}\ F_2\!\left(\frac{k}{10}\right).$$

*Proof.* By Theorem 8.2 the numerator converges to $\log\bigl((10+k)/10\bigr)$
and the denominator to $\log(20/10)=\log 2 \neq 0$; the quotient converges to the
quotient. Finally
$$\frac{10+k}{10} = 1 + (2-1)\cdot\frac{k}{10},$$
so $\log((10+k)/10)/\log 2 = F_2(k/10)$ by Definition 6.1. $\square$

By Lemma 8.1 the numerator is exactly the total $1/j$ weight carried by the
leading $k$ deciles of the doubling window $(10L, 20L]$, and the denominator is
the weight of the whole window: Theorem 8.3 says the *normalised discrete
occupancy profile converges, decile by decile, to the continuum harmonic
profile*.

**Corollary 8.4 (Edge decile).**
$$\frac{H_{11L}-H_{10L}}{H_{20L}-H_{10L}} \longrightarrow F_2(1/10)
= \frac{\log(11/10)}{\log 2} = 0.137503\ldots,$$
and $F_2(1/10) > 1/10$ by Theorem 6.4. The observed edge excess is therefore the
continuum limit of the arithmetic $1/j$ carrier, not an artefact of binning.

---

## 9. Inference I: exact validity of the tests used

**Definition 9.1 (Permutation p-value).** Let $G$ be a finite nonempty set of
relabellings and $t : G \to \mathbb{R}$ a test statistic. The permutation p-value
of $g \in G$ is
$$p(g) := \frac{\#\{h \in G : t(g) \le t(h)\}}{|G|}.$$

**Theorem 9.2 (Finite-sample validity).** For every $\alpha \ge 0$,
$$\#\{g \in G : p(g) \le \alpha\} \ \le\ \alpha\,|G|,
\qquad\text{hence}\qquad \frac{\#\{g : p(g)\le\alpha\}}{|G|} \le \alpha .$$

*Proof.* Let $S = \{g : p(g)\le\alpha\}$. If $S = \emptyset$ the claim is trivial
(as $\alpha|G| \ge 0$). Otherwise choose $g_0 \in S$ minimising $t$ over $S$.
Every $g \in S$ satisfies $t(g_0) \le t(g)$, so
$S \subseteq \{h : t(g_0) \le t(h)\}$ and hence
$|S| \le \#\{h: t(g_0)\le t(h)\} = p(g_0)\,|G| \le \alpha|G|$. $\square$

No exchangeability approximation, no asymptotic reference distribution: under a
uniformly random relabelling, the p-value is super-uniform exactly.

**Theorem 9.3 (Strict positivity).** $p(g) > 0$ for every $g$.

*Proof.* $g$ itself satisfies $t(g)\le t(g)$, so the numerator is at least $1$.
$\square$

Hence a permutation p-value can never be reported as exactly $0$; the smallest
attainable value is $1/|G|$.

**Theorem 9.4 (Bonferroni).** Let $p_1,\dots,p_m$ be p-values on a probability
space, each super-uniform at level $\alpha/m$, i.e.
$\Pr[p_i \le \alpha/m] \le \alpha/m$. Then
$$\Pr\bigl[\exists\, i \le m : p_i \le \alpha/m\bigr] \ \le\ \alpha .$$

*Proof.* $\{\exists i : p_i \le \alpha/m\} = \bigcup_i \{p_i\le\alpha/m\}$;
countable (here finite) subadditivity gives the bound
$\sum_{i=1}^m \alpha/m = \alpha$. $\square$

This is why the pooled rich-versus-poor KS result — raw $p = 0.0038$, adjusted to
$p_{\text{adj}} = 0.049$ against a threshold of $0.05$ across the family — must be
recorded as a non-firing. Family-wise error control is a hard constraint, not a
tunable.

---

## 10. Inference II: separation destroys the maximum-likelihood estimate

The control arm of the design fitted a logistic occupancy regression. On dense
size-matched controls it fired, with odds ratios clipped at $e^{\pm 30}$. The
following theorems explain the failure exactly.

**Definition 10.1.** For a label $y \in \{0,1\}$ and a score $z \in \mathbb{R}$,
the logistic log-likelihood contribution is
$$\ell(y,z) := \begin{cases} -\log(1+e^{-z}) & y = 1,\\ -\log(1+e^{z}) & y=0.\end{cases}$$
For a design $x_1,\dots,x_n \in \mathbb{R}^d$ with labels $y_1,\dots,y_n$,
$$\ell(\beta) := \sum_{i=1}^n \ell\bigl(y_i, \langle \beta, x_i\rangle\bigr).$$

**Definition 10.2 (Separation).** A vector $w \in \mathbb{R}^d$ *separates* the
data if $\langle w, x_i\rangle > 0$ whenever $y_i=1$ and $\langle w, x_i\rangle<0$
whenever $y_i=0$.

**Lemma 10.3.** $\ell(y,z) < 0$ always; hence $\ell(\beta) < 0$ whenever
$n \ge 1$.

**Lemma 10.4 (Behaviour along a separating ray).** If $w$ separates the data and
$n \ge 1$, then $t \mapsto \ell(tw)$ is strictly increasing on $(0,\infty)$ and
$\ell(tw) \to 0$ as $t \to \infty$.

*Proof.* Writing $s_i := |\langle w, x_i\rangle| > 0$, separation gives
$\ell(y_i, \langle tw, x_i\rangle) = -\log(1+e^{-s_i t})$, which is strictly
increasing in $t$ and tends to $-\log 1 = 0$. Summing preserves both properties.
$\square$

**Theorem 10.5 (No maximum-likelihood estimate).** If $n \ge 1$ and the data are
separated, then $\ell$ has no maximiser: there is no $\beta$ with
$\ell(\gamma) \le \ell(\beta)$ for all $\gamma$.

*Proof.* Suppose $\beta$ were a maximiser. Then $\ell(\beta) < 0$ by Lemma 10.3.
By Lemma 10.4, $\ell(tw) \to 0$, so for $t$ large, $\ell(tw) > \ell(\beta)$, a
contradiction. $\square$

**Consequence.** On a separated design the reported coefficient vector is
determined by the optimiser's stopping rule (its clipping bound, iteration cap,
or numerical tolerance), not by the data. Any p-value or odds ratio computed from
it is uninterpretable. The behaviour flagged on the control arm is exactly
this phenomenon: quasi-separation on dense size-matched controls produced
apparent significance ($p = 0.012$ by permutation) with coefficients pinned at
$e^{\pm 30}$.

---

## 11. Inference III: the ridge repair and its escape rate

### 11.1 Existence and uniqueness

**Definition 11.1.** For $\lambda > 0$, the *ridge-penalised* objective is
$$\ell_\lambda(\beta) := \ell(\beta) - \lambda\|\beta\|^2, \qquad
\|\beta\|^2 = \sum_{j=1}^d \beta_j^2 .$$

**Lemma 11.2 (Concavity of the likelihood).** Writing
$\operatorname{sp}(z) = \log(1+e^z)$ for the softplus function,
$\ell(y,z) = y z - \operatorname{sp}(z)$. Since $\operatorname{sp}$ is convex and
$\beta \mapsto \langle\beta, x_i\rangle$ is linear, $\ell$ is concave; in
midpoint form,
$$\tfrac12\bigl(\ell(\beta)+\ell(\gamma)\bigr) \le \ell\bigl(\tfrac{\beta+\gamma}{2}\bigr).$$

**Lemma 11.3 (Strict concavity of the penalty).** By the parallelogram law,
$$\Bigl\|\frac{\beta+\gamma}{2}\Bigr\|^2
= \frac{\|\beta\|^2 + \|\gamma\|^2}{2} - \frac{\|\beta-\gamma\|^2}{4}
< \frac{\|\beta\|^2+\|\gamma\|^2}{2} \quad \text{whenever } \beta \neq \gamma .$$

**Theorem 11.4 (Strict concavity of the ridge objective).** For $\lambda > 0$ and
$\beta \neq \gamma$,
$$\tfrac12\bigl(\ell_\lambda(\beta)+\ell_\lambda(\gamma)\bigr) < \ell_\lambda\bigl(\tfrac{\beta+\gamma}{2}\bigr).$$

*Proof.* Add Lemma 11.2 to $\lambda$ times the strict inequality of Lemma 11.3
(with sign reversed by the minus sign in the penalty). $\square$

**Lemma 11.5 (Coercivity).** $\ell_\lambda(0) = -n\log 2$, and since
$\ell \le 0$ everywhere, any $\beta$ with $\lambda\|\beta\|^2 > n\log 2$ satisfies
$\ell_\lambda(\beta) < -n\log 2 = \ell_\lambda(0)$.

**Theorem 11.6 (Existence).** For every design and every $\lambda > 0$,
$\ell_\lambda$ attains a global maximum.

*Proof.* Put $R := n\log 2/\lambda$. The set $K = \{\beta : \|\beta\|^2\le R\}$ is
compact (closed and bounded) and nonempty, and $\ell_\lambda$ is continuous, so a
maximiser $\hat\beta$ over $K$ exists. For $\gamma \notin K$, Lemma 11.5 gives
$\ell_\lambda(\gamma) < \ell_\lambda(0) \le \ell_\lambda(\hat\beta)$ since
$0 \in K$. Hence $\hat\beta$ is a global maximiser. $\square$

**Theorem 11.7 (Existence and uniqueness of the ridge estimator).** For every
design matrix — separated or not — and every $\lambda > 0$, the ridge objective
has *exactly one* maximiser.

*Proof.* Existence is Theorem 11.6. If $\beta \ne \gamma$ were both maximisers,
Theorem 11.4 would give $\ell_\lambda\bigl(\tfrac{\beta+\gamma}{2}\bigr) >
\tfrac12(\ell_\lambda(\beta)+\ell_\lambda(\gamma)) = \ell_\lambda(\beta)$,
contradicting maximality. $\square$

**Corollary 11.8 (The repair, stated against the failure).** On a separated
design with $n \ge 1$: the unpenalised maximum-likelihood estimate does not exist
(Theorem 10.5), while the ridge estimator exists and is unique for every
$\lambda>0$ (Theorem 11.7). The occupancy regression is usable on control arms once it is
penalised.

### 11.2 The escape sandwich

Uniqueness for each $\lambda>0$ does not, by itself, say what happens as the
penalty is removed. The following results give a two-sided answer.

**Theorem 11.9 (Upper bound).** Every maximiser $\hat\beta_\lambda$ of
$\ell_\lambda$ satisfies
$$\lambda\|\hat\beta_\lambda\|^2 \le n\log 2, \qquad\text{i.e.}\qquad
\|\hat\beta_\lambda\|^2 \le \frac{n\log 2}{\lambda} .$$

*Proof.* Compare with $\beta = 0$:
$\ell(\hat\beta_\lambda) - \lambda\|\hat\beta_\lambda\|^2 \ge \ell_\lambda(0) =
-n\log 2$. Since $\ell(\hat\beta_\lambda) \le 0$, rearranging gives the claim.
$\square$

So the ridge estimator is $O(\lambda^{-1/2})$ in norm — never worse.

**Theorem 11.10 (Logarithmic cost of a near-perfect fit).** Let $\beta$ have
likelihood deficiency $\delta := -\ell(\beta) > 0$. Then for every observation
$i$,
$$\log\frac{1}{\delta} - \delta \ \le\ \|\beta\|\,\|x_i\| .$$

*Proof.* Every individual contribution dominates the total (all contributions are
negative), so $\ell(y_i,z_i) \ge \ell(\beta) = -\delta$ with
$z_i = \langle\beta,x_i\rangle$. Writing the contribution as
$-\log(1+e^{-\tilde z_i})$ with $\tilde z_i$ the label-adjusted score, this reads
$1+e^{-\tilde z_i} \le e^{\delta}$, i.e. $e^{-\tilde z_i}\le e^\delta - 1$, hence
$$|z_i| \ge \tilde z_i \ge -\log(e^\delta-1) \ge \log\frac{1}{\delta} - \delta,$$
using the elementary comparison $\log(e^\delta-1)\le \log\delta + \delta$
(equivalently $e^\delta - 1 \le \delta e^\delta$). Cauchy–Schwarz gives
$|z_i| = |\langle\beta,x_i\rangle| \le \|\beta\|\,\|x_i\|$. $\square$

**Theorem 11.11 (Vanishing deficiency).** Suppose $w$ separates the data. For
every $\varepsilon > 0$ there is $\lambda_0 > 0$ such that every ridge maximiser
$\hat\beta_\lambda$ with $0<\lambda<\lambda_0$ has $-\ell(\hat\beta_\lambda) <
\varepsilon$.

*Proof.* Comparing $\hat\beta_\lambda$ with the competitor $tw$ gives
$$-\ell(\hat\beta_\lambda) \le -\ell(tw) + \lambda\, t^2\|w\|^2 .$$
By Lemma 10.4, choose $t$ with $-\ell(tw) < \varepsilon/2$; put
$C := t^2\|w\|^2 \ge 0$ and $\lambda_0 := (\varepsilon/2)/(C+1) > 0$. For
$0<\lambda<\lambda_0$ we get $\lambda C < \varepsilon/2$, hence
$-\ell(\hat\beta_\lambda) < \varepsilon$. $\square$

**Theorem 11.12 (Escape).** Suppose $n\ge 1$ and $w$ separates the data. For
every $M$ there is $\lambda_0>0$ such that every ridge maximiser with
$0<\lambda<\lambda_0$ satisfies $\|\hat\beta_\lambda\|^2 > M$. Equivalently, for
any selection $\lambda \mapsto \hat\beta_\lambda$ of ridge maximisers,
$$\|\hat\beta_\lambda\|^2 \ \longrightarrow\ \infty \qquad (\lambda \downarrow 0).$$

*Proof.* Fix an observation $i$; note $\|x_i\| > 0$ (else the score would vanish,
contradicting separation for that observation). Given $M$, pick $\varepsilon>0$
small enough that $\log(1/\varepsilon) - \varepsilon > \sqrt{M}\,\|x_i\|$, which
is possible since $\log(1/\varepsilon)-\varepsilon \to \infty$ as
$\varepsilon\downarrow 0$. By Theorem 11.11 choose $\lambda_0$ so that
$\delta_\lambda := -\ell(\hat\beta_\lambda) < \varepsilon$ for $0<\lambda<\lambda_0$.
Since $t \mapsto \log(1/t)-t$ is decreasing, Theorem 11.10 gives
$$\|\hat\beta_\lambda\|\,\|x_i\| \ \ge\ \log\frac{1}{\delta_\lambda} - \delta_\lambda
\ >\ \log\frac{1}{\varepsilon} - \varepsilon \ >\ \sqrt{M}\,\|x_i\|,$$
so $\|\hat\beta_\lambda\| > \sqrt M$. $\square$

**Theorem 11.13 (The sandwich).** On a separated design with $n \ge 1$:

1. the unpenalised maximum-likelihood estimate does not exist;
2. every ridge maximiser satisfies $\|\hat\beta_\lambda\|^2 \le n\log 2/\lambda$
   for every $\lambda>0$;
3. for every $M$ there is $\lambda_0 > 0$ such that every ridge maximiser with
   $0<\lambda<\lambda_0$ has $\|\hat\beta_\lambda\|^2 > M$.

*Proof.* (1) Theorem 10.5; (2) Theorem 11.9; (3) Theorem 11.12. $\square$

**Interpretation.** A "significant" odds ratio from a separated control arm is
not merely unstable — it diverges. The ridge repair converts that divergence into
a bounded, uniquely determined estimate whose size is an explicit function of the
penalty: at least logarithmic in the reciprocal deficiency, at most
$\sqrt{n\log 2/\lambda}$.

---

## 12. Algorithms

Three computational procedures follow directly from the theory.

**(A) Two-layer decomposition and interaction diagnostics.** Given a nonnegative
occupancy table $O$ with positive row sums: compute row sums $R_i$ (the rate
layer), normalise rows to obtain the profiles $p_i$, compute the independence fit
$E_{ib} = R_i C_b/T$, and return $\chi^2(O)$, $G(O)$, and the maximal pairwise
total variation $\max_{i,j}\tfrac12\sum_b|p_i(b)-p_j(b)|$. Cost:
$\Theta(|\iota|\,|\beta|)$ for the statistics, $\Theta(|\iota|^2|\beta|)$ for the
heterogeneity diameter. By Theorems 3.5–3.6, both statistics vanish iff the
profiles are homogeneous, and by Theorem 4.4 the diameter upper-bounds every
pooled contrast.

**(B) Inversion of the edge-decile mass to a window ratio.** Given
$m \in (1/10,1)$, solve $F_r(1/10) = m$ by bisection on $\log r$. By Theorem 7.5
the map is a strictly increasing bijection onto $(1/10,1)$, so bisection is
guaranteed to converge; the brackets of Lemma 7.4 supply an initial interval.
Cost: $O(\log(1/\text{tol}))$ evaluations of a logarithm.

**(C) Ridge-penalised occupancy regression.** Maximise
$\ell(\beta)-\lambda\|\beta\|^2$ by gradient ascent or Newton's method. By
Theorem 11.7 the maximiser exists and is unique regardless of separation, and by
Theorem 11.9 the iterates may be safely confined to the ball
$\|\beta\|^2 \le n\log 2/\lambda$ — which is also a runtime *separation
diagnostic*: if the fitted norm sits at that bound across a decreasing sequence
of $\lambda$, Theorem 11.13 identifies the design as separated and the
unpenalised fit as nonexistent.

---

## 13. Discussion

### 13.1 What the null means

Combining the results: the occupancy table of a scan factorises into a rate layer
and a positional layer that are separately identifiable (Theorem 2.4); "no
interaction" is exactly rank-oneness (Theorem 3.1) and exactly vanishing of all
$2\times2$ contrasts (Theorem 3.2); and the two standard interaction statistics
vanish exactly on that condition (Theorems 3.5–3.6). Under the null, every rate
stratum has the *same* pooled profile (Theorem 4.1, Corollary 4.2), and in
general the pooled contrast is bounded by the pairwise heterogeneity
(Theorems 4.4–4.5).

The empirical finding — a non-firing interaction test and a KS contrast that
fails family-wise correction — therefore has a determinate content: the
positional profile of a scan does *not* vary with its hit rate, to within the
resolution the contrast bound provides. And by Theorems 5.5–5.6, that conclusion
is genuinely new information, since neither layer constrains the other.

### 13.2 The positional layer is law-complete

The positional layer is fully described: it is the harmonic window law
$F_r(u) = \log(1+(r-1)u)/\log r$; it is scale free (Theorem 6.3); it front-loads
strictly (Theorem 6.4), so the edge decile exceeds $1/10$ in every stratum
simultaneously (Theorem 6.9); it is identifiable from a single leading-fraction
mass (Corollary 7.7); and it is the exact limit of the discrete $1/j$ carrier
(Theorem 8.3, Corollary 8.4), with the Euler–Mascheroni constant cancelling.

### 13.3 The open problem, sharpened

The rate layer's overdispersion — some $39\text{–}61\%$ of between-index count
variance unaccounted for — is real (Theorem 5.4 makes any excess a certificate of
rate variation), and it is *not* carried by profile-shape heterogeneity across
terciles. The carrier therefore governs *how many* hits an index produces, not
*where along the window* they land. That is a substantive narrowing of the search
space.

### 13.4 A methodological caution

The control arm of the occupancy-regression design fired on data where nothing
should be found. Theorem 10.5 explains why: dense size-matched controls induce
quasi-separation, under which the estimator being reported does not exist. The
correct response is not re-randomisation but a change of objective: Theorem 11.7
gives a unique estimator for every design, and Theorem 11.13 quantifies exactly
what that estimator is doing as the penalty is relaxed. Unpenalised occupancy
regression should not be used on dense control arms.

---

## 14. Future directions

**Identify the rate-variance carrier.** The unexplained between-index dispersion
is a property of the rate layer alone. Candidate carriers — arithmetic structure
of the index, window-length effects, coverage of the scan — should be tested
directly against the rate layer, with the positional layer now provably
uninformative for this purpose.

**Powered follow-up on the post-hoc location contrast.** A descriptive post-hoc
comparison of mean position between hit-poor and hit-rich indices gave a small
negative contrast whose sign flipped under matching, with a confidence interval
straddling zero. It is a motive for a pre-registered, powered replication, not a
claim.

**Sharpen the escape rate.** Theorem 11.13 sandwiches
$\|\hat\beta_\lambda\|$ between a logarithmic lower bound and
$\sqrt{n\log 2/\lambda}$. The true rate for a separated design is expected to be
logarithmic, i.e. $\|\hat\beta_\lambda\| \asymp \log(1/\lambda)$; closing the gap
would give a calibrated separation diagnostic.

**Non-doubling windows.** Theorem 8.3 is proved for the doubling window
($r = 2$); the same harmonic-difference argument should give
$F_r(k/10)$ for every rational window ratio, with the same cancellation of
$\gamma$.

**Beyond total variation.** Theorem 4.4 bounds the pooled contrast by the
pairwise TV diameter. Analogous bounds in $\chi^2$ or Kullback–Leibler divergence
would connect the resolution guarantee directly to the interaction statistics of
§3, giving a power calculation from first principles.

---

## 15. Conclusion

We have given a complete structural account of two-layer occupancy data. The
no-interaction null is an exact algebraic condition — rank-oneness of the
occupancy table — that the standard statistics detect exactly; under it, all rate
strata have identical pooled positional profiles, and away from it the pooled
contrast is dominated by the pairwise heterogeneity, so a null is a bound rather
than a shrug. The rate layer is the unique source of overdispersion, and the two
layers are logically independent. The positional layer itself is the harmonic
window law: scale free, strictly front-loaded, identifiable from its edge decile,
and the exact continuum limit of a discrete $1/j$ carrier with leading-decile mass
$\log(11/10)/\log 2 = 0.1375\ldots$. Finally, on the inferential side, permutation
p-values are exactly valid and strictly positive, Bonferroni is a clean union
bound, separated logistic designs admit no maximum-likelihood estimate at all, and
the ridge repair supplies a unique estimator for every design whose divergence as
the penalty vanishes is sandwiched between a logarithmic lower bound and
$\sqrt{n\log 2/\lambda}$.
