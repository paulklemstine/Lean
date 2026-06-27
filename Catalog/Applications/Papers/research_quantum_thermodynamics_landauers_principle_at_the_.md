# Landauer's Principle at the Nanoscale: A Finite-System Derivation from the Jarzynski Equality, with Saturation, Relative-Entropy, and Data-Processing Bridges

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (cross-domain bridge: information theory ↔ thermodynamics)

---

## Abstract

We give a fully elementary, finite-system derivation of Landauer's principle —
the statement that erasing one bit of information dissipates at least $kT\ln 2$
of mean work — and of its sharp finite-size refinement. Working over an
arbitrary finite probability space, we start from the nonequilibrium Jarzynski
equality $\mathbb{E}[e^{-\alpha W}] = e^{-\alpha\,\Delta F}$ and derive an exact
*identity* expressing the mean dissipated work as the reversible free-energy cost
plus a fluctuation correction term. The single analytic ingredient $1 + x \le
e^x$ (and its strict form $1 + x < e^x$ for $x \ne 0$) then yields three results:
(i) the second-law inequality $\Delta F \le \mathbb{E}[W]$, hence Landauer's
bound $kT\ln 2 \le \mathbb{E}[W]$; (ii) a *saturation theorem* showing the bound
is attained **iff** the erasure work is non-fluctuating on the support of the
distribution — so any genuinely stochastic nanoscale erasure dissipates
*strictly* more than $kT\ln 2$; and (iii) the implication *logical
irreversibility $\Rightarrow$ thermodynamic irreversibility* for one-bit erasure.
We complement the work-fluctuation account with two independent information-
theoretic derivations of the same cost: a relative-entropy (Kullback–Leibler)
formulation backed by a first-principles proof of Gibbs' inequality $D(p\|q)\ge
0$, and a deterministic data-processing inequality $H(f_*p)\le H(p)$ that
identifies erasure as the extremal entropy-collapsing map and reversible
computations as the zero-dissipation boundary. Finally we prove extensivity:
erasing $n$ bits costs at least $n\,kT\ln 2$, with an exact per-bit cost of
$kT\ln 2$. All results are stated for finite distributions and require only
nonnegativity, normalization, and positivity of temperature.

---

## 1. Introduction

Landauer's principle [Landauer 1961] asserts that the logically irreversible
erasure of one bit of information has an unavoidable thermodynamic cost: the
process must dissipate at least

$$Q_{\min} = kT\ln 2$$

of heat into its environment, where $T$ is the absolute temperature of the bath
and $k$ is Boltzmann's constant. Together with Bennett's demonstration [Bennett
1973, 1982] that all *reversible* computation can be made dissipationless, it
draws a fundamental thermodynamic boundary around computation and resolves the
paradox of Maxwell's demon: the demon's eventual memory erasure pays exactly the
entropy debt that its sorting appears to create.

Two developments motivate a careful *finite-system* treatment. First, modern
fluctuation theorems — above all the Jarzynski equality [Jarzynski 1997] —
express equilibrium free-energy differences as averages of exponentiated work
over arbitrarily nonequilibrium protocols, providing a rigorous bridge from
fluctuating microscopic work to thermodynamic bounds. Second, the experimental
realization of Landauer erasure in single-particle systems makes the *finite-
size corrections* to the textbook bound physically relevant rather than
academic.

This paper develops the entire chain from first principles over a finite
probability space. Our contributions are:

1. **An exact finite-size Landauer identity** (Theorem 4.2 /
   `jarzynski_correction`, `landauer_identity`): the mean work equals the
   reversible cost plus an explicit fluctuation correction.
2. **The second-law inequality** (Theorem 5.4 / `jarzynski_second_law`) and
   **Landauer's bound** (Theorem 5.5 / `landauer_kT_bound`), with the
   logical-to-thermodynamic irreversibility implication (Theorem 5.7 /
   `logical_to_thermodynamic_irreversibility`).
3. **A sharp saturation theorem** (Theorem 6.4 / `landauer_saturation_iff`):
   equality holds iff the work is constant on the support; otherwise the bound
   is strict (Theorem 6.3 / `landauer_kT_bound_strict`).
4. **A relative-entropy account** (Section 7) with a first-principles Gibbs
   inequality (Theorem 7.2 / `relativeEntropy_nonneg`) and the identity
   $kT\ln 2 = kT\,D(\text{erased}\|\text{uniform})$.
5. **A deterministic data-processing inequality** (Theorem 8.2 /
   `shannonEntropy_pushforward_le`) identifying erasure as the extremal map and
   reversible computations as the free boundary (Theorem 8.3).
6. **Extensivity** (Section 9): erasing $n$ bits costs at least $n\,kT\ln 2$,
   per-bit cost exactly $kT\ln 2$.

A guiding theme is economy of hypotheses: a single convexity fact, $1 + x \le
e^x$ (strict for $x \ne 0$), and its logarithmic dual $\ln x \le x - 1$, power
every inequality below. No measure theory, no Jensen machinery, and no
convexity API are required.

---

## 2. Setup and definitions

Throughout, $\Omega$ is a finite type representing the microstates of the
system, and all sums range over $\Omega$.

**Definition 2.1 (Expectation).** For a weight function $p : \Omega \to
\mathbb{R}$ and observable $f : \Omega \to \mathbb{R}$,
$$\mathbb{E}_p[f] := \sum_{\omega} p(\omega)\, f(\omega).$$

**Definition 2.2 (Probability mass function).** $p$ is a PMF, written
$\mathrm{IsPMF}(p)$, if $p(\omega) \ge 0$ for all $\omega$ and
$\sum_\omega p(\omega) = 1$.

**Definition 2.3 (Shannon entropy).** With the convention $0\ln 0 = 0$
(implemented via the function $x \mapsto -x\ln x$),
$$H(p) := \sum_\omega -p(\omega)\ln p(\omega).$$

**Definition 2.4 (Jarzynski condition).** A triple $(W, \alpha, \Delta F)$ —
work observable $W:\Omega\to\mathbb{R}$, inverse temperature $\alpha$,
free-energy difference $\Delta F$ — satisfies the finite Jarzynski equality
relative to $p$ if
$$\mathbb{E}_p\!\left[e^{-\alpha W}\right] = e^{-\alpha\,\Delta F}.$$

We model a one-bit memory by $\Omega = \mathrm{Bool}$ and three distinguished
objects:

**Definition 2.5 (Bit states and erasure).**
$$u(b) := \tfrac12 \quad(\text{uniform}),\qquad
e(b) := \begin{cases}1 & b=\text{false}\\ 0 & b=\text{true}\end{cases}\quad(\text{erased}),$$
and the erasure map $\mathrm{er} : \mathrm{Bool}\to\mathrm{Bool}$, $\mathrm{er}(b)
= \text{false}$ for all $b$.

The physical dictionary is $\alpha = 1/(kT)$ and, for bit erasure, $\Delta F =
kT\ln 2$.

---

## 3. The information content of a bit

**Theorem 3.1 (Entropy of the uniform bit; `entropy_uniformBool`).**
$$H(u) = \ln 2.$$
*Proof.* $H(u) = -\tfrac12\ln\tfrac12 - \tfrac12\ln\tfrac12 = -\ln\tfrac12 =
\ln 2.$ $\qquad\blacksquare$

**Theorem 3.2 (Entropy of the erased bit; `entropy_erasedBool`).**
$$H(e) = 0.$$
*Proof.* The only nonzero mass is $e(\text{false})=1$, contributing
$-1\cdot\ln 1 = 0$; the term at $\text{true}$ vanishes by the $0\ln 0 = 0$
convention. $\qquad\blacksquare$

**Theorem 3.3 (Logical irreversibility; `erasure_not_injective`).** The erasure
map $\mathrm{er}$ is not injective.
*Proof.* $\mathrm{er}(\text{true}) = \mathrm{er}(\text{false}) = \text{false}$
but $\text{true}\ne\text{false}$. $\qquad\blacksquare$

**Theorem 3.4 (Entropy loss; `entropy_loss`).**
$$H(u) - H(e) = \ln 2.$$
*Proof.* Immediate from Theorems 3.1 and 3.2. $\qquad\blacksquare$

The entropy loss $\ln 2$ is the purely information-theoretic content that the
thermodynamic development below will price at $kT\ln 2$.

---

## 4. The finite-size Landauer identity

The Jarzynski equality fixes not just a bound but an *exact* value for the mean
work, once one accounts for fluctuations.

**Theorem 4.1 (Jarzynski fluctuation correction; `jarzynski_correction`).** Let
$p$ be any weight function, $W$ an observable, $\alpha \ne 0$, and suppose the
Jarzynski condition holds for $(W, \alpha, \Delta F)$. Then
$$\mathbb{E}_p[W] = \Delta F + \alpha^{-1}\,
\ln \mathbb{E}_p\!\left[e^{-\alpha(W - \mathbb{E}_p[W])}\right].$$

*Proof sketch.* Factor the centered exponential pointwise,
$$e^{-\alpha(W(\omega) - \mathbb{E}_p[W])} = e^{\alpha\,\mathbb{E}_p[W]}\,
e^{-\alpha W(\omega)},$$
pull the constant $e^{\alpha\,\mathbb{E}_p[W]}$ out of the expectation, and apply
the Jarzynski condition to the remaining factor:
$$\mathbb{E}_p\!\left[e^{-\alpha(W-\mathbb{E}_p[W])}\right]
= e^{\alpha\,\mathbb{E}_p[W]}\,e^{-\alpha\,\Delta F}.$$
Take logarithms, use $\ln e^x = x$, and solve for $\mathbb{E}_p[W]$. $\qquad\blacksquare$

**Theorem 4.2 (Finite-size Landauer identity; `landauer_identity`).** For a
one-bit memory with $\Delta F = (H(u)-H(e))/\alpha = (\ln 2)/\alpha$ and the
Jarzynski condition,
$$\mathbb{E}_p[W] = \frac{H(u)-H(e)}{\alpha} + \alpha^{-1}\,
\ln \mathbb{E}_p\!\left[e^{-\alpha(W-\mathbb{E}_p[W])}\right].$$
*Proof.* Substitute $\Delta F = (H(u)-H(e))/\alpha$ into Theorem 4.1. $\qquad\blacksquare$

This identity has two parts: the reversible free-energy cost (here $(\ln
2)/\alpha = kT\ln 2$) and a *correction term* depending only on the centered
fluctuations of the work. The remainder of the thermodynamic story is the
determination of the sign and vanishing locus of that correction.

---

## 5. Landauer's bound as a second-law inequality

The engine of the inequality is a single elementary fact.

**Lemma 5.1 (Tangent bound).** For all $x\in\mathbb{R}$, $1 + x \le e^x$.

**Theorem 5.2 (Finite Jensen-type bound; `expect_add_one_le_expect_exp`).** For
any PMF $p$ and observable $g$,
$$1 + \mathbb{E}_p[g] \le \mathbb{E}_p\!\left[e^{g}\right].$$
*Proof sketch.* Since $\sum_\omega p(\omega) = 1$, write $1 + \mathbb{E}_p[g] =
\sum_\omega p(\omega)(1 + g(\omega))$. Apply Lemma 5.1 pointwise, $1 + g(\omega)
\le e^{g(\omega)}$, and sum with nonnegative weights $p(\omega)$. $\qquad\blacksquare$

**Lemma 5.3 (Centered work has zero mean; `expect_centered_zero`).** For any PMF
$p$, observable $W$, and scalar $\alpha$,
$$\mathbb{E}_p\!\left[-\alpha(W - \mathbb{E}_p[W])\right] = 0.$$
*Proof.* Linearity of expectation and $\mathbb{E}_p[\mathbb{E}_p[W]] =
\mathbb{E}_p[W]$ (the mean of a constant, using $\sum p = 1$). $\qquad\blacksquare$

Applying Theorem 5.2 with $g = -\alpha(W - \mathbb{E}_p[W])$ and Lemma 5.3 gives
$1 \le \mathbb{E}_p[e^{-\alpha(W-\mathbb{E}_p[W])}]$
(`work_fluctuation_ge_one`), hence $\ln(\cdots) \ge 0$
(`work_correction_nonneg`). The correction term in Theorem 4.1 is therefore
nonnegative, and we obtain:

**Theorem 5.4 (Second law; `jarzynski_second_law`).** If $\alpha > 0$ and the
Jarzynski condition holds for $(W,\alpha,\Delta F)$ with $p$ a PMF, then
$$\Delta F \le \mathbb{E}_p[W].$$
*Proof.* Rewrite $\mathbb{E}_p[W]$ via Theorem 4.1; the correction
$\alpha^{-1}\ln(\cdots)$ is a product of $\alpha^{-1} \ge 0$ and a nonnegative
logarithm, hence $\ge 0$. $\qquad\blacksquare$

**Theorem 5.5 (Landauer's bound; `landauer_kT_bound`).** For $k, T > 0$, inverse
temperature $\alpha = (kT)^{-1}$, and $\Delta F = kT\ln 2$ satisfying the
Jarzynski condition,
$$kT\ln 2 \le \mathbb{E}_p[W].$$
*Proof.* Theorem 5.4 with $\alpha = (kT)^{-1} > 0$ and $\Delta F = kT\ln 2$. $\qquad\blacksquare$

**Theorem 5.6 (Cost–entropy bridge; `landauer_cost_eq_entropy_loss`).**
$$kT\ln 2 = kT\,(H(u) - H(e)).$$
*Proof.* Theorem 3.4. $\qquad\blacksquare$

**Theorem 5.7 (Logical $\Rightarrow$ thermodynamic irreversibility;
`logical_to_thermodynamic_irreversibility`).** For $k,T>0$ and the Jarzynski
condition for one-bit erasure, the erasure map is not injective *and* the mean
dissipated work is strictly positive:
$$\neg\,\mathrm{Injective}(\mathrm{er}) \quad\wedge\quad 0 < \mathbb{E}_p[W].$$
*Proof.* Non-injectivity is Theorem 3.3. For positivity, Theorem 5.5 gives
$\mathbb{E}_p[W] \ge kT\ln 2 > 0$ since $k,T>0$ and $\ln 2 > 0$. $\qquad\blacksquare$

Theorem 5.7 is the formal heart of Landauer's principle: the many-to-one
character of erasure (a statement of pure logic) forces strictly positive heat
dissipation (a statement of pure thermodynamics).

---

## 6. Saturation: when is the bound tight?

The second-law inequality leaves open the equality case. The strict tangent
bound resolves it completely.

**Lemma 6.1 (Strict tangent bound).** For $x \ne 0$, $1 + x < e^x$.

**Theorem 6.2 (Strict Jensen bound; `expect_add_one_lt_expect_exp`).** Let $p$
be a PMF and $g$ an observable. If there exists $\omega$ with $p(\omega) > 0$ and
$g(\omega) \ne 0$, then
$$1 + \mathbb{E}_p[g] < \mathbb{E}_p\!\left[e^g\right].$$
*Proof sketch.* As in Theorem 5.2, the summands satisfy $p(\omega)(1+g(\omega))
\le p(\omega)e^{g(\omega)}$ everywhere, and *strictly* at the witnessing
$\omega$ (where $p(\omega)>0$ and $g(\omega)\ne 0$ give strict Lemma 6.1). A sum
with one strict term and the rest weak is strict. $\qquad\blacksquare$

**Theorem 6.3 (Strict Landauer bound; `landauer_kT_bound_strict`).** For
$k,T>0$, the Jarzynski condition for one-bit erasure, and a genuinely
fluctuating work — i.e. some $\omega$ with $p(\omega)>0$ and $W(\omega) \ne
\mathbb{E}_p[W]$ — we have
$$kT\ln 2 < \mathbb{E}_p[W].$$
*Proof sketch.* The witness $\omega$ makes $g = -\alpha(W-\mathbb{E}_p[W])$
nonzero on the support ($\alpha\ne0$), so Theorem 6.2 gives a *strictly*
greater-than-one fluctuation factor, hence a strictly positive correction in
Theorem 4.1. $\qquad\blacksquare$

**Theorem 6.4 (Saturation criterion; `landauer_saturation_iff`,
`jarzynski_second_law_eq_iff`, `work_fluctuation_eq_one_iff`).** For $k,T>0$ and
the Jarzynski condition,
$$kT\ln 2 = \mathbb{E}_p[W] \iff \forall\omega\,(\,p(\omega)>0 \Rightarrow
W(\omega) = \mathbb{E}_p[W]\,).$$
That is, Landauer's bound is saturated **iff** the erasure work has no
fluctuations on the support of $p$.
*Proof sketch.* ($\Leftarrow$) If $W$ is constant $=\mathbb{E}_p[W]$ on the
support, every nonzero-weight term of $\mathbb{E}_p[e^{-\alpha(W-\mathbb{E}_p[W])}]$
equals $p(\omega)\cdot e^0 = p(\omega)$, summing to $1$; the correction
vanishes. ($\Rightarrow$) Contrapositive is Theorem 6.3: any support fluctuation
forces strict inequality. $\qquad\blacksquare$

**Physical interpretation.** The clean value $kT\ln 2$ is achieved only in the
quasi-static, zero-fluctuation (reversible) limit. *Every* genuinely stochastic
nanoscale erasure dissipates strictly more on average. The fluctuation
correction is the thermodynamic-irreversibility surcharge; it is strictly
positive off the reversible manifold $\{W \text{ constant on } \mathrm{supp}\,p\}$
and vanishes exactly on it.

---

## 7. The relative-entropy account

A second, dual derivation expresses the cost as a Kullback–Leibler divergence.

**Definition 7.1 (Relative entropy).** For weight functions $p, q$,
$$D(p\,\|\,q) := \sum_\omega p(\omega)\,\ln\frac{p(\omega)}{q(\omega)}.$$
The leading factor $p(\omega)$ makes the convention $0\ln 0 = 0$ automatic.

**Theorem 7.2 (Gibbs' inequality; `relativeEntropy_nonneg`).** If $p, q$ are
PMFs and $q(\omega) > 0$ for all $\omega$, then $D(p\,\|\,q) \ge 0$.
*Proof sketch.* For each $\omega$ with $p(\omega)>0$, the dual bound $\ln x \le
x-1$ applied to $x = q(\omega)/p(\omega)$ gives, after multiplying by $p(\omega)$
and rearranging,
$$p(\omega)\,\ln\frac{p(\omega)}{q(\omega)} \ge p(\omega) - q(\omega);$$
the inequality also holds (as $0 \ge -q(\omega)$ would, but precisely as an
equality of the convention) at $\omega$ with $p(\omega)=0$. Summing over
$\omega$ and using $\sum p = \sum q = 1$,
$$D(p\,\|\,q) \ge \sum_\omega (p(\omega)-q(\omega)) = 1 - 1 = 0. \qquad\blacksquare$$

**Theorem 7.3 (Self-divergence; `relativeEntropy_self`).** $D(p\,\|\,p) = 0$.

**Theorem 7.4 (Erased-vs-uniform divergence; `relativeEntropy_erased_uniform`).**
$$D(e\,\|\,u) = \ln 2.$$
*Proof.* Only $\omega=\text{false}$ contributes: $1\cdot\ln(1/\tfrac12) = \ln 2$.
$\qquad\blacksquare$

**Theorem 7.5 (Two accounts agree; `relativeEntropy_eq_entropy_loss`).**
$$D(e\,\|\,u) = H(u) - H(e).$$
*Proof.* Both equal $\ln 2$ (Theorems 7.4 and 3.4). $\qquad\blacksquare$

**Theorem 7.6 (Cost as relative entropy; `landauer_cost_eq_relative_entropy`).**
$$kT\ln 2 = kT\,D(e\,\|\,u).$$

**Theorem 7.7 (Nonnegative relative-entropy work; `landauer_work_nonneg_via_gibbs`).**
For PMFs $p,q$ with $q>0$ and $k,T\ge 0$, $0 \le kT\,D(p\,\|\,q)$.
*Proof.* Gibbs' inequality (Theorem 7.2) and nonnegativity of $kT$. $\qquad\blacksquare$

Thermodynamically, $kT\,D(p\,\|\,q)$ is the excess free energy of a state $p$
relative to an equilibrium reference $q$ — the minimal work to prepare or erase
it [Esposito & Van den Broeck 2011]. The remarkable coincidence of Theorem 7.5 —
an asymmetric divergence equalling a single-distribution entropy difference — is
the mathematical signature of a unique underlying cost.

---

## 8. The deterministic data-processing inequality

The most general formulation places erasure within the class of all
deterministic computations.

**Definition 8.1 (Pushforward).** For $f : \alpha \to \beta$ (finite types) and
weights $p:\alpha\to\mathbb{R}$, the pushforward $f_*p:\beta\to\mathbb{R}$ is
$$(f_*p)(y) := \sum_{x : f(x)=y} p(x).$$

The pushforward of a distribution is a distribution
(`pushforwardFun_isDistribution`): nonnegativity is termwise, and total mass is
preserved by fiberwise summation, $\sum_y (f_*p)(y) = \sum_x p(x)$.

**Theorem 8.2 (Data-processing inequality; `shannonEntropy_pushforward_le`).**
For any $f:\alpha\to\beta$ and nonnegative weights $p$,
$$H(f_*p) \le H(p).$$
A deterministic computation never increases Shannon entropy.
*Proof sketch.* The key pointwise fact is fiber domination: since $x$ lies in
its own fiber $f^{-1}\{f(x)\}$ and the other terms are nonnegative,
$$p(x) \le (f_*p)(f(x)).$$
Reindexing the pushforward entropy fiberwise,
$$H(f_*p) = -\sum_x p(x)\,\ln (f_*p)(f(x)).$$
Hence the gap telescopes to a sum of nonnegative terms,
$$H(p) - H(f_*p) = \sum_x p(x)\,\big(\ln (f_*p)(f(x)) - \ln p(x)\big) \ge 0,$$
each term nonnegative by monotonicity of $\ln$ applied to $p(x) \le
(f_*p)(f(x))$. $\qquad\blacksquare$

**Theorem 8.3 (Reversible $\Rightarrow$ free;
`shannonEntropy_pushforward_of_injective`).** If $f$ is injective then $H(f_*p) =
H(p)$.
*Proof sketch.* Injectivity makes every fiber a singleton, so $(f_*p)(f(x)) =
p(x)$ and the gap above vanishes termwise. $\qquad\blacksquare$

**Theorem 8.4 (Landauer lower bound; `landauer_lower_bound`).** For $k,T\ge 0$,
$$0 \le kT\,\big(H(p) - H(f_*p)\big).$$
**Theorem 8.5 (Reversible computations dissipate no heat;
`landauer_lower_bound_zero_of_injective`).** If $f$ is injective,
$$kT\,\big(H(p) - H(f_*p)\big) = 0.$$

Erasure is the extremal case of Theorem 8.2 ($f$ collapses all states to one,
maximizing the entropy drop); bijections are the equality case (Theorem 8.3),
recovering Bennett's principle that reversible computation can be performed
without dissipation.

---

## 9. Extensivity and the thermodynamic limit

**Theorem 9.1 (Entropy of a uniform distribution; `entropy_uniform`).** If
$\Omega$ has $N>0$ states, the uniform distribution $p(\omega)=1/N$ has
$$H(p) = \ln N.$$
*Proof.* Each of $N$ terms is $-\tfrac1N\ln\tfrac1N = \tfrac1N\ln N$; summing,
$H = \ln N$. $\qquad\blacksquare$

**Theorem 9.2 (Maximal entropy of an $n$-bit register;
`entropy_uniform_pow_two`, `entropy_uniform_bits`).** The uniform distribution on
$2^n$ states (e.g. on $\mathrm{Fin}\,n \to \mathrm{Bool}$) has entropy
$$H = \ln(2^n) = n\ln 2.$$
*Proof.* Theorem 9.1 with $N=2^n$ and $\ln(2^n) = n\ln 2$. $\qquad\blacksquare$

**Theorem 9.3 (Extensive Landauer bound; `landauer_nbit_work_bound`).** Erasing
an $n$-bit memory, modeled by the Jarzynski condition at $\alpha=(kT)^{-1}$ with
$\Delta F = n\,kT\ln 2$, dissipates
$$n\,kT\ln 2 \le \mathbb{E}_p[W].$$
*Proof.* Theorem 5.4 with $\Delta F = n\,kT\ln 2$. $\qquad\blacksquare$

**Theorem 9.4 (Exact per-bit cost; `landauer_per_bit_cost`).** For $n>0$,
$$\frac{n\,kT\ln 2}{n} = kT\ln 2.$$

The per-bit cost is *exactly* $kT\ln 2$ for every register size — the strongest
(non-asymptotic) form of the thermodynamic limit, expressing the extensivity of
the bound.

---

## 10. Algorithms

The constructive content yields directly executable procedures (see the
accompanying `demo.py`):

- **Finite-Jarzynski work decomposition.** Given $(p, W, \alpha)$, compute
  $\Delta F = -\alpha^{-1}\ln\mathbb{E}_p[e^{-\alpha W}]$, the mean
  $\mathbb{E}_p[W]$, and the fluctuation correction $\mathbb{E}_p[W] - \Delta F
  = \alpha^{-1}\ln\mathbb{E}_p[e^{-\alpha(W-\mathbb{E}_p[W])}]$, verifying the
  identity of Theorem 4.1 and the nonnegativity of the correction.
- **Saturation detector.** Given $(p, W)$, test whether $W$ is constant on
  $\{\omega : p(\omega)>0\}$; this predicts (by Theorem 6.4) whether the bound is
  saturated or strict.
- **Pushforward entropy / data-processing checker.** Given $f$ and $p$, build
  $f_*p$ and compare $H(f_*p)$ with $H(p)$ to confirm Theorem 8.2 and detect
  injectivity-driven equality (Theorem 8.3).
- **Relative-entropy cost.** Given $(p,q)$ with $q>0$, compute $D(p\|q)$ and the
  Landauer work $kT\,D(p\|q)$, illustrating Gibbs' inequality and Theorem 7.6.

---

## 11. Applications and discussion

**Maxwell's demon and the thermodynamics of computation.** Theorem 5.7
formalizes the modern resolution of the Maxwell-demon paradox: the demon's
memory erasure is logically irreversible (Theorem 3.3) and therefore
thermodynamically costly (positive dissipation), restoring the second law. The
data-processing inequality (Theorem 8.2) extends this from erasure to *every*
deterministic operation, with reversible computation (Theorem 8.3) as the free
boundary [Bennett 1973].

**Nanoscale device engineering.** The saturation theorem (Theorem 6.4) is the
operationally important refinement: it tells device designers that the textbook
$kT\ln 2$ floor is not merely hard to reach but is *unattainable* by any
genuinely stochastic protocol — the residual fluctuation correction is an
irreducible energy tax that shrinks only as the protocol approaches the
quasi-static limit. As CMOS scaling pushes per-operation energies toward $kT$,
this finite-size correction transitions from negligible to design-relevant.

**Two information measures, one cost.** Sections 3, 7, and 8 give three
independent information-theoretic certificates of the same number $\ln 2$:
Shannon entropy loss, relative entropy from equilibrium, and the extremal
entropy collapse of the data-processing inequality. Their agreement (Theorem
7.5) is a structural feature, not a coincidence, and supports the view that the
thermodynamic cost of forgetting is a well-defined invariant of the logical
operation.

**Economy of method.** Every inequality reduces to $1+x\le e^x$ (strict for
$x\ne0$) or its dual $\ln x \le x-1$. The avoidance of Jensen/convexity
machinery is not merely aesthetic: it makes the entire chain robust, fully
finite, and free of integrability or measurability side conditions.

---

## 12. Future directions

This development establishes the finite-size Landauer identity, its second-law
sharpening, the saturation criterion, the relative-entropy and data-processing
bridges, and extensivity. Natural next steps, building on the same
moment-generating-function and convexity backbone, include:

1. **Two-sided (Gaussian-tail) concentration of erasure work.** If the centered
   work is bounded, $|W(\omega) - \mathbb{E}[W]| \le M$ on the support, the same
   MGF identity that yields the one-sided Chernoff bound $P(W < \Delta F - \xi)
   \le e^{-\alpha\xi}$ should upgrade to a Hoeffding-type two-sided bound
   $P(|W - \mathbb{E}[W]| \ge t) \le 2e^{-t^2/(2M^2)}$, so dissipated work
   concentrates in an $O(M)$ window around its mean.
2. **Quadratic finite-size correction via the work variance.** On a bounded
   range, $e^y \ge 1 + y + c\,y^2$, so the Jensen gap of the second-law proof can
   be replaced by a quantitative lower bound $\mathbb{E}[W] - \Delta F \ge
   c(M)\,\alpha\,\mathrm{Var}_p(W)$, sharpening the qualitative saturation result
   into a quantitative correction controlled by the second moment.
3. **Integral-fluctuation / Chernoff layer.** Packaging the Jarzynski identity
   $\mathbb{E}[e^{-\alpha W}] = e^{-\alpha\Delta F}$ as a tail bound formalizes
   that second-law violations are exponentially rare in the violation margin and
   can never occur with certainty.
4. **Maximum-entropy generalization.** The identity $H(p) = \ln N - D(p\|u)$
   (via Gibbs' inequality, Theorem 7.2) yields $H(p) \le \ln N$ and the
   generalized Landauer bound $kT\,H(p) \le \mathbb{E}[W]$ for arbitrary initial
   distributions, with uniform memory the worst case to erase.

---

## References

- Landauer, R. (1961). *Irreversibility and heat generation in the computing
  process.* IBM J. Res. Dev. 5, 183–191.
- Bennett, C. H. (1973). *Logical reversibility of computation.* IBM J. Res.
  Dev. 17, 525–532.
- Bennett, C. H. (1982). *The thermodynamics of computation — a review.* Int. J.
  Theor. Phys. 21, 905–940.
- Jarzynski, C. (1997). *Nonequilibrium equality for free energy differences.*
  Phys. Rev. Lett. 78, 2690–2693.
- Kullback, S. & Leibler, R. A. (1951). *On information and sufficiency.* Ann.
  Math. Stat. 22, 79–86.
- Cover, T. M. & Thomas, J. A. (2006). *Elements of Information Theory*, 2nd ed.
  Wiley.
- Plenio, M. B. & Vitelli, V. (2001). *The physics of forgetting: Landauer's
  erasure principle and information theory.* Contemp. Phys. 42, 25–60.
- Esposito, M. & Van den Broeck, C. (2011). *Second law and Landauer principle
  far from equilibrium.* EPL 95, 40004.
- Sagawa, T. (2014). *Thermodynamic and logical reversibilities revisited.* J.
  Stat. Mech. P03025.
