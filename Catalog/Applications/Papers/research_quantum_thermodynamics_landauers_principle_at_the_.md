# Landauer's $kT\ln 2$ Bound as a Second-Law Inequality from the Jarzynski Equality

**Author:** Aristotle

**Date:** 2026-06-21

**Domain:** Applications (Quantum/Stochastic Thermodynamics)

---

## Abstract

We give a fully rigorous, finite-dimensional derivation of Landauer's
principle — the statement that erasing one bit of information dissipates at
least $kT\ln 2$ of work — as a strict consequence of the Jarzynski nonequilibrium
work equality. Working over a finite probability space, we first extract from
the Jarzynski equality an *exact* identity for the mean dissipated work, equal
to the free-energy difference $\Delta F$ plus a fluctuation correction
$\alpha^{-1}\ln\mathbb{E}[e^{-\alpha(W-\mathbb{E}[W])}]$. The entire physical
content of the Second Law is the *sign* of this correction. We prove it is
nonnegative using only the elementary tangent-line bound $1+x\le e^x$, avoiding
all convexity/Jensen API: the centered work fluctuation has mean zero, so its
exponential moment is at least one, whence the correction's logarithm is
nonnegative. This upgrades the finite-size Landauer *identity* to the Landauer
*inequality* $\Delta F \le \mathbb{E}[W]$, and specializes to
$kT\ln 2 \le \mathbb{E}[W]$ for one-bit erasure. We connect the thermodynamic
cost to the information-theoretic entropy loss $H(\text{uniform}) -
H(\text{erased}) = \ln 2$ through an explicit bridge identity, and prove a
qualitative dichotomy: logical irreversibility (non-injectivity of the erasure
map) forces strictly positive dissipation. All results are mechanically
verified.

---

## 1. Introduction

Landauer's principle (Landauer, 1961) asserts a thermodynamic lower bound on
the work required to erase information: resetting a one-bit memory at
temperature $T$ requires dissipating at least $kT\ln 2$ of energy. It is the
resolution of the Maxwell-demon paradox (Bennett, 1982): the demon's apparent
violation of the Second Law is paid for when its finite memory is erased.

Most textbook treatments derive the bound from the Second Law taken as an
axiom, in the quasi-static limit. We instead derive it from a more fundamental
and far-from-equilibrium statement, the **Jarzynski equality** (Jarzynski,
1997), and we make explicit the precise analytic fact that supplies the
inequality's *direction*.

A companion catalog development (`Logic.JarzynskiLandauer`) establishes the
finite-size Landauer *identity*

$$ \mathbb{E}_p[W] = \Delta F + \alpha^{-1}\ln
\mathbb{E}_p\!\left[e^{-\alpha(W-\mathbb{E}_p[W])}\right], $$

which pins the mean work to $\Delta F$ plus an exact fluctuation correction but
says nothing about its sign. The present work supplies the missing sign and
thereby the Second Law and Landauer's bound. A second companion development
(`Computation.LandauerLowerBound`) treats the complementary, purely
information-theoretic deterministic data-processing inequality $H(f_*p)\le
H(p)$; together the two give a complete picture in which reversible
computations are free and irreversible ones are not.

### 1.1 Contributions

1. A finite Jensen-type bound $1+\mathbb{E}[g]\le\mathbb{E}[e^g]$ proved from
   the tangent-line inequality, with no convexity API.
2. The identification of the Jarzynski fluctuation correction as a nonnegative
   quantity, hence the Second Law $\Delta F \le \mathbb{E}[W]$ for $\alpha>0$.
3. The specialization to Landauer's $kT\ln 2$ bound for one-bit erasure.
4. A bridge identity equating the free-energy cost $kT\ln 2$ with $kT$ times the
   Shannon entropy loss.
5. A logical-to-thermodynamic irreversibility dichotomy: non-injective erasure
   forces strictly positive dissipation.

---

## 2. Setting and definitions

We work over a finite type $\Omega$ (the outcome space). The following data are
imported from the catalog development `JarzynskiLandauer`.

**Definition 2.1 (Expectation).** For a weight function $p:\Omega\to\mathbb{R}$
and observable $f:\Omega\to\mathbb{R}$,
$$ \mathbb{E}_p[f] \;:=\; \sum_{\omega\in\Omega} p(\omega)\,f(\omega). $$
(In Lean: `expect p f`.)

**Definition 2.2 (Probability mass function).** $p$ is a PMF, written
`IsPMF p`, iff $p(\omega)\ge 0$ for all $\omega$ and $\sum_\omega p(\omega)=1$.

**Definition 2.3 (Jarzynski condition).** For inverse temperature $\alpha$,
work observable $W:\Omega\to\mathbb{R}$, and free-energy difference $\Delta F$,
the **Jarzynski equality** holds, `JarzynskiCondition p W α ΔF`, iff
$$ \mathbb{E}_p\!\left[e^{-\alpha W}\right] \;=\; e^{-\alpha\,\Delta F}. $$

**Definition 2.4 (Shannon entropy).** With the convention $0\ln 0 = 0$ (encoded
via $\operatorname{negMulLog}$),
$$ H(p) \;:=\; \sum_{\omega\in\Omega} -\,p(\omega)\ln p(\omega). $$

**Definition 2.5 (Bit distributions and erasure).** On $\Omega=\mathrm{Bool}$,
- the uniform bit `uniformBool` is $p(b)=\tfrac12$;
- the erased bit `erasedBool` is $p(\text{false})=1,\ p(\text{true})=0$;
- the erasure map `erasure` is the constant function $b\mapsto\text{false}$.

From the catalog: $H(\text{uniformBool})=\ln 2$ (`entropy_uniformBool`),
$H(\text{erasedBool})=0$ (`entropy_erasedBool`), the erasure map is not
injective (`erasure_not_injective`), and the entropy loss is
$H(\text{uniformBool}) - H(\text{erasedBool}) = \ln 2$ (`entropy_loss`).

The catalog identity we build on is:

**Theorem 2.6 (Jarzynski correction, `jarzynski_correction`).** For $\alpha\ne
0$ and `JarzynskiCondition p W α ΔF`,
$$ \mathbb{E}_p[W] = \Delta F + \alpha^{-1}\,
\ln\mathbb{E}_p\!\left[e^{-\alpha(W-\mathbb{E}_p[W])}\right]. $$

*Proof sketch.* Factor $e^{-\alpha(W-\mathbb{E}_p[W])} = e^{\alpha\mathbb{E}_p[W]}
e^{-\alpha W}$, pull the constant out of the expectation, apply the Jarzynski
equality $\mathbb{E}_p[e^{-\alpha W}]=e^{-\alpha\Delta F}$, take logarithms of
$e^{\alpha\mathbb{E}_p[W]}e^{-\alpha\Delta F}$ and rearrange. $\square$

---

## 3. The finite Jensen bound

The single analytic ingredient is the tangent-line inequality $1+x\le e^x$
(Mathlib: `Real.add_one_le_exp`), valid for all real $x$.

**Lemma 3.1 (Finite Jensen bound for the exponential, `expect_add_one_le_expect_exp`).**
For every PMF $p$ and observable $g:\Omega\to\mathbb{R}$,
$$ 1 + \mathbb{E}_p[g] \;\le\; \mathbb{E}_p\!\left[e^{g}\right]. $$

*Proof.* Using $\sum_\omega p(\omega)=1$,
$$ 1 + \mathbb{E}_p[g] = \sum_\omega p(\omega)\,(1 + g(\omega)). $$
Compare termwise with $\mathbb{E}_p[e^g]=\sum_\omega p(\omega)e^{g(\omega)}$. For
each $\omega$, $p(\omega)\ge 0$ and $1+g(\omega)\le e^{g(\omega)}$ by the
tangent-line bound, so $p(\omega)(1+g(\omega))\le p(\omega)e^{g(\omega)}$.
Summing (`Finset.sum_le_sum`) gives the claim. $\square$

This is the discrete content of the convexity of $\exp$, obtained without any
appeal to Jensen's inequality or convex-function APIs; it needs only
monotonicity of finite sums and the pointwise bound.

---

## 4. The fluctuation correction is nonnegative

**Lemma 4.1 (Centered work has zero mean, `expect_centered_zero`).** For any
PMF $p$, work $W$, and $\alpha\in\mathbb{R}$,
$$ \mathbb{E}_p\!\left[-\alpha\,(W - \mathbb{E}_p[W])\right] = 0. $$

*Proof.* Expand $-\alpha(W-\mathbb{E}_p[W]) = -\alpha W + \alpha\,\mathbb{E}_p[W]$
and use linearity of $\mathbb{E}_p$ together with $\sum_\omega p(\omega)=1$:
the constant term contributes $\alpha\,\mathbb{E}_p[W]\cdot 1$ which cancels
$\mathbb{E}_p[-\alpha W] = -\alpha\,\mathbb{E}_p[W]$. $\square$

**Lemma 4.2 (Fluctuation factor $\ge 1$, `work_fluctuation_ge_one`).** For any
PMF $p$, work $W$, and $\alpha$,
$$ 1 \;\le\; \mathbb{E}_p\!\left[e^{-\alpha(W-\mathbb{E}_p[W])}\right]. $$

*Proof.* Apply Lemma 3.1 with $g(\omega) = -\alpha(W(\omega)-\mathbb{E}_p[W])$.
By Lemma 4.1, $\mathbb{E}_p[g]=0$, so $1 = 1 + \mathbb{E}_p[g] \le
\mathbb{E}_p[e^g]$. $\square$

**Corollary 4.3 (Correction nonnegative, `work_correction_nonneg`).** For any
PMF $p$, work $W$, and $\alpha$,
$$ 0 \;\le\; \ln\mathbb{E}_p\!\left[e^{-\alpha(W-\mathbb{E}_p[W])}\right]. $$

*Proof.* $\ln$ is nonnegative on $[1,\infty)$ (`Real.log_nonneg`); apply to
Lemma 4.2. $\square$

This nonnegative quantity is the **Jarzynski fluctuation correction** — the
exact gap by which the actual mean work exceeds the reversible minimum. It
vanishes precisely in the quasi-static (zero-fluctuation) limit.

---

## 5. Main results

**Theorem 5.1 (Second law from Jarzynski, `jarzynski_second_law`).** Let $p$ be
a PMF, $W$ a work observable, $\alpha>0$, and suppose `JarzynskiCondition p W α
ΔF`. Then
$$ \Delta F \;\le\; \mathbb{E}_p[W]. $$

*Proof.* By Theorem 2.6, $\mathbb{E}_p[W] = \Delta F + \alpha^{-1}\,C$ where
$C = \ln\mathbb{E}_p[e^{-\alpha(W-\mathbb{E}_p[W])}]$. By Corollary 4.3,
$C\ge 0$, and $\alpha^{-1}>0$ since $\alpha>0$, so $\alpha^{-1}C\ge 0$ and
$\mathbb{E}_p[W]\ge\Delta F$. $\square$

This is the Second Law of Thermodynamics in its Kelvin form for this setting:
the mean dissipated work cannot fall below the free-energy difference. The
hypothesis $\alpha>0$ (i.e. $T>0$) is essential — at $\alpha=0$ the bound is
vacuous.

**Theorem 5.2 (Landauer's $kT\ln 2$ bound, `landauer_kT_bound`).** Let $p$ be a
PMF and $W$ a work observable. For $k>0$, $T>0$, with inverse temperature
$\alpha=(kT)^{-1}$ and free-energy cost $\Delta F = kT\ln 2$, suppose
`JarzynskiCondition p W (kT)⁻¹ (kT\ln 2)`. Then
$$ kT\ln 2 \;\le\; \mathbb{E}_p[W]. $$

*Proof.* Apply Theorem 5.1 with $\alpha=(kT)^{-1}>0$ (since $k,T>0$) and
$\Delta F = kT\ln 2$. $\square$

This is Landauer's principle: erasing one bit at temperature $T$ dissipates at
least $kT\ln 2$ of work on average.

**Theorem 5.3 (Bridge identity, `landauer_cost_eq_entropy_loss`).** For all
$k,T\in\mathbb{R}$,
$$ kT\ln 2 \;=\; kT\,\big(H(\text{uniformBool}) - H(\text{erasedBool})\big). $$

*Proof.* Substitute the catalog entropy-loss identity
$H(\text{uniformBool}) - H(\text{erasedBool}) = \ln 2$ (`entropy_loss`). $\square$

The bridge identity is what ties the thermodynamic bound of Theorem 5.2 to the
logical act of erasure: the free-energy price $kT\ln 2$ equals $kT$ times the
information destroyed.

**Theorem 5.4 (Logical $\Rightarrow$ thermodynamic irreversibility,
`logical_to_thermodynamic_irreversibility`).** The erasure map is not injective,
and consequently any physical realization of one-bit erasure subject to the
Jarzynski equality (with $k,T>0$ and a genuine, strictly positive entropy loss)
dissipates strictly positive mean work:
$$ 0 < \mathbb{E}_p[W]. $$

*Proof sketch.* Non-injectivity of `erasure` is `erasure_not_injective`. The
entropy loss $\ln 2 > 0$ gives a strictly positive free-energy difference
$\Delta F = kT\ln 2 > 0$; combine with Theorem 5.2's inequality
$kT\ln 2 \le \mathbb{E}_p[W]$ to obtain $0 < \mathbb{E}_p[W]$. $\square$

This is the qualitative heart of Landauer's principle: irreversibility of the
*logic* (collapse of two inputs to one output) compels irreversibility of the
*thermodynamics* (positive dissipation). Reversible computations, whose maps are
injective, are by contrast free of any forced cost.

---

## 6. The complementary data-processing picture

For context we record the companion deterministic data-processing results
(`Computation.LandauerLowerBound`), which describe the information-theoretic
side of the same coin over finite types $\alpha,\beta$.

**Definition 6.1 (Pushforward).** For $f:\alpha\to\beta$ and weights $p$, the
pushforward is $f_*p(y) = \sum_{x:\,f(x)=y} p(x)$ (`pushforwardFun`).

**Theorem 6.2 (Data-processing inequality, `shannonEntropy_pushforward_le`).**
For nonnegative $p$, $H(f_*p)\le H(p)$.

*Proof sketch.* Since $x$ lies in its own fiber, $p(x)\le f_*p(f(x))$
(`pushforwardFun_apply_ge`); monotonicity of $\ln$ then makes the entropy gap
$H(p)-H(f_*p) = \sum_x p(x)\big(\ln f_*p(f(x)) - \ln p(x)\big)$ a sum of
nonnegative terms. $\square$

**Theorem 6.3 (Reversible $\Rightarrow$ free,
`shannonEntropy_pushforward_of_injective`).** If $f$ is injective then
$H(f_*p)=H(p)$, and consequently the Landauer cost $kT(H(p)-H(f_*p))=0$
(`landauer_lower_bound_zero_of_injective`); for $k,T\ge 0$ the cost is always
nonnegative (`landauer_lower_bound`).

Together, Sections 5 and 6 give two independent routes to "irreversibility
costs, reversibility is free": one through the stochastic work fluctuations
(Jarzynski), one through deterministic information loss (data processing).

---

## 7. Algorithms

The mathematics is constructive and directly computable on finite spaces. Two
core routines are:

**Algorithm A (Jarzynski-consistent free energy and dissipation).** Given a PMF
$p$ and work values $W$, compute $\Delta F = -\alpha^{-1}\ln\mathbb{E}_p[e^{-\alpha
W}]$ (the value forced by the Jarzynski equality), then the dissipated work
$\mathbb{E}_p[W]-\Delta F$, and verify it equals the nonnegative fluctuation
correction $\alpha^{-1}\ln\mathbb{E}_p[e^{-\alpha(W-\mathbb{E}_p[W])}]\ge 0$.

**Algorithm B (One-bit erasure cost certificate).** Given $k,T>0$, set
$\alpha=(kT)^{-1}$ and $\Delta F=kT\ln 2$; construct a two-outcome work
distribution satisfying the Jarzynski condition, and certify both that
$\mathbb{E}_p[W]\ge kT\ln 2$ and that the bound is saturated iff the work is
deterministic.

See `demo.py` for reference implementations.

---

## 8. Applications

- **Nanoscale and single-molecule experiments.** Single-bit erasure has been
  measured approaching $kT\ln 2$ in colloidal and nanomagnetic systems; the
  finite-size fluctuation correction quantifies the unavoidable surcharge above
  the bound when fluctuations are non-negligible.
- **Energy-efficient and reversible computing.** The dichotomy of Theorem 5.4
  and Theorem 6.3 formalizes why reversible logic can in principle approach zero
  dissipation while every erasure carries a hard floor.
- **Foundations.** The bridge identity (Theorem 5.3) makes "information is
  physical" a literal equation: thermodynamic cost equals temperature times lost
  Shannon entropy.

---

## 9. Discussion

The derivation isolates the Second Law's content to a single sign: the
nonnegativity of the Jarzynski fluctuation correction. That sign comes entirely
from the tangent-line bound $1+x\le e^x$ applied to a mean-zero variable. The
phrasing "a mean-zero perturbation can only raise the expectation of a convex
observable" is the conceptual kernel; everything thermodynamic is a corollary.
Methodologically, replacing the convexity/Jensen route by the direct
tangent-line bound removed substantial API friction and made the proof both
shorter and more robust.

---

## 10. Future directions

**FD1. Tightness / saturation theorem: $\mathbb{E}[W]=\Delta F \Leftrightarrow$
zero work fluctuations.** For $\alpha>0$ and a Jarzynski process, the Landauer
bound is saturated iff $W$ is $p$-almost-surely constant on the support of $p$.
The only loss of tightness is the pointwise gap $e^x-(1+x)$, zero exactly at
$x=0$; equality in `work_fluctuation_ge_one` forces every centered fluctuation
to vanish. The bound is already a sum of nonnegative terms $p(\omega)(e^{g}-1-g)$,
so the equality case is the standard "sum of nonnegatives is zero" lemma applied
termwise.

**FD2. Second-order (Gaussian) finite-size correction
$\mathbb{E}[W]=\Delta F+(\alpha/2)\operatorname{Var}(W)+O(\alpha^2)$.** Near
equilibrium, $\alpha^{-1}\ln\mathbb{E}[e^{-\alpha(W-\mathbb{E}[W])}] =
(\alpha/2)\operatorname{Var}_p(W)+o(\alpha)$, giving leading finite-size surcharge
$\approx(\alpha/2)\operatorname{Var}(W)$ above $kT\ln 2$. The cumulant generating
function of a mean-zero variable has vanishing first cumulant and second cumulant
equal to the variance; the missing piece is a quadratic two-sided Taylor bound on
$\exp$.

**FD3. Quantum (von Neumann) Landauer bound via Holevo.** Replacing Shannon by
von Neumann entropy, erasing a qubit dissipates at least $kT\ln 2$, with the
data-processing inequality for the Holevo quantity replacing the classical
pushforward bound. Classical $H(f_*p)\le H(p)$ is the diagonal restriction of
quantum monotonicity of relative entropy; the Holevo bound $\chi\le\ln\dim$ is the
same inequality.

**FD4. Strict-positivity dichotomy: non-injectivity $\Leftrightarrow$ positive
minimal dissipation.** For deterministic $f:\alpha\to\beta$ and full-support $p$,
the minimal Landauer cost $kT(H(p)-H(f_*p))$ is $>0$ iff $f$ is not injective on
the support, since the entropy gap is a sum of terms $p(x)\ln(f_*p(f x)/p(x))\ge
0$.

---

## References

- Landauer, R. (1961). *Irreversibility and heat generation in the computing
  process.* IBM J. Res. Dev. 5(3), 183–191.
- Jarzynski, C. (1997). *Nonequilibrium equality for free energy differences.*
  Phys. Rev. Lett. 78(14), 2690–2693.
- Bennett, C. H. (1982). *The thermodynamics of computation — a review.* Int. J.
  Theor. Phys. 21(12), 905–940.
- Bennett, C. H. (1973). *Logical reversibility of computation.* IBM J. Res. Dev.
  17(6), 525–532.
- Cover, T. M. & Thomas, J. A. (2006). *Elements of Information Theory*, 2nd ed.
  Wiley.
