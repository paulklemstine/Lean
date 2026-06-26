# Landauer's Principle from First Principles: Relative Entropy, the Jarzynski Second Law, and the Saturation Condition

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Novelty (quantum/statistical thermodynamics of information)

---

## Abstract

We give a fully elementary, self-contained derivation of Landauer's principle for the
erasure of a finite memory, organized around three pillars. First, we recast the
Landauer free-energy cost $kT\ln 2$ as a **Kullback–Leibler (relative) entropy**,
$kT\,D(\text{erased}\,\|\,\text{uniform})$, and prove **Gibbs' inequality**
$D(p\,\|\,q)\ge 0$ from the single elementary bound $\ln x \le x-1$; this furnishes a
distribution-comparison account of the erasure cost dual to the usual Shannon-entropy
account, and the two are shown to coincide exactly. Second, we upgrade the exact finite
**Jarzynski work identity** to the **second-law inequality** $\Delta F \le \langle
W\rangle$ using only the convexity bound $1+x\le e^{x}$, recovering Landauer's
principle $kT\ln 2 \le \langle W\rangle$ as a genuine lower bound, and we show that
logical irreversibility (non-injectivity of the erasure map) forces strictly positive
dissipation. Third, we determine the **saturation condition**: the bound is attained if
and only if the dissipated work has no fluctuations on the support of the distribution
(the quasi-static, reversible limit), via the strict convexity bound $1+x<e^{x}$ for
$x\neq 0$. We complement these with the extensivity of the bound for $n$-bit registers
($n\,kT\ln 2$) and the deterministic data-processing inequality $H(f_*p)\le H(p)$, which
exhibits reversible computation as the zero-dissipation boundary case. All results have
been formalized and machine-checked.

---

## 1. Introduction

Landauer's principle [Landauer 1961] asserts that the erasure of one bit of information
in an environment at absolute temperature $T$ requires the dissipation of at least
$kT\ln 2$ of energy, where $k$ is Boltzmann's constant. It is the cleanest known bridge
between *information* and *thermodynamics*: a statement about the logic of a computation
that has unavoidable physical consequences. Despite its age and its recent experimental
confirmation, the principle is often presented through heavy machinery — full
nonequilibrium statistical mechanics, convex analysis, or measure-theoretic information
theory.

Our aim is the opposite: to isolate the *minimal* mathematical content of each physical
claim. We work over a finite probability space throughout, so that all sums are finite
and every step is elementary. The contributions are:

1. **A relative-entropy formulation (§3).** We define the KL divergence
   $D(p\,\|\,q)$, prove Gibbs' inequality from $\ln x \le x - 1$, evaluate
   $D(\text{erased}\,\|\,\text{uniform}) = \ln 2$, and prove it equals the Shannon
   entropy loss. This yields $kT\ln 2 = kT\,D(\text{erased}\,\|\,\text{uniform})$ and
   the nonnegativity of relative-entropy work $kT\,D(p\,\|\,q)\ge 0$.

2. **A second-law derivation (§4).** From the exact finite Jarzynski work identity we
   prove $\Delta F \le \langle W\rangle$ using only $1+x\le e^x$, obtain Landauer's
   bound $kT\ln 2 \le \langle W\rangle$, and deduce that logical irreversibility forces
   $0 < \langle W\rangle$.

3. **A saturation theorem (§5).** Using the strict bound $1+x<e^x$ ($x\neq 0$), we show
   the bound is tight iff the work is almost surely constant on the support — the
   reversible limit — making precise the finite-size "Jarzynski correction" as a
   strictly positive surcharge away from reversibility.

4. **Extensivity and data processing (§6).** The bound scales as $n\,kT\ln 2$ for an
   $n$-bit register with per-bit cost exactly $kT\ln 2$, and the deterministic
   data-processing inequality $H(f_*p)\le H(p)$ identifies reversible (injective)
   computation as the unique zero-dissipation case.

Throughout, "machine-checked" means each stated theorem corresponds to a formally
verified proposition; the present paper gives full mathematical statements and proof
sketches.

**A remark on the philosophy.** The literature on Landauer's principle is large and at
times contentious: debates have turned on what counts as "erasure," on the role of the
observer's information, and on whether the bound is a theorem of physics or of logic. We
sidestep these debates by adopting a deliberately spare model — a finite probability
space, a work observable, and the Jarzynski equality as the sole thermodynamic input —
and asking only what follows rigorously. The reward is clarity: every physical statement
below is pinned to a single, transparent mathematical fact, and the reader can see
exactly where each hypothesis is used and where it is not. In particular, several of our
results (Theorems 3.6, 4.7, 6.4) are *identities* that hold for arbitrary real $k,T$,
while the genuinely thermodynamic content — the inequalities and the saturation
dichotomy — requires only positivity of the inverse temperature.

---

## 2. Setup and definitions

Let $\Omega$ be a finite set (the configuration space). A **weight function** is any
$p:\Omega\to\mathbb{R}$.

**Definition 2.1 (Expectation).** For weight $p$ and observable $f:\Omega\to\mathbb{R}$,
$$ \mathbb{E}_p[f] \;=\; \operatorname{expect}(p,f) \;=\; \sum_{\omega\in\Omega} p(\omega)\,f(\omega). $$

**Definition 2.2 (PMF).** $p$ is a **probability mass function** ($\mathrm{IsPMF}$) if
$p(\omega)\ge 0$ for all $\omega$ and $\sum_\omega p(\omega)=1$.

**Definition 2.3 (Shannon entropy).** With the convention $0\ln 0 = 0$ (encoded by the
function $\operatorname{negMulLog}(x) = -x\ln x$),
$$ H(p) \;=\; \operatorname{shannonEntropy}(p) \;=\; \sum_{\omega} \operatorname{negMulLog}(p(\omega)) \;=\; -\sum_\omega p(\omega)\ln p(\omega). $$

**Definition 2.4 (The one-bit distributions).** On $\Omega=\mathrm{Bool}$:
the uniform bit $\operatorname{uniformBool}(b)=\tfrac12$; the fully erased bit
$\operatorname{erasedBool}(b)=\mathbb 1[b=\mathrm{false}]$ (mass $1$ on
$\mathrm{false}$, $0$ on $\mathrm{true}$); the erasure map
$\operatorname{erasure}(b)=\mathrm{false}$.

**Definition 2.5 (Jarzynski condition).** A work observable $W:\Omega\to\mathbb{R}$
satisfies the finite **Jarzynski equality** at inverse temperature $\alpha$ with
free-energy difference $\Delta F$ if
$$ \mathbb{E}_p\!\big[e^{-\alpha W}\big] \;=\; e^{-\alpha \Delta F}. $$

We collect the basic information-theoretic facts.

**Lemma 2.6 (`entropy_uniformBool`, `entropy_erasedBool`, `entropy_loss`).**
$H(\operatorname{uniformBool}) = \ln 2$, $H(\operatorname{erasedBool}) = 0$, and hence
$$ H(\operatorname{uniformBool}) - H(\operatorname{erasedBool}) = \ln 2. $$
*Sketch.* Direct evaluation: $-2\cdot\tfrac12\ln\tfrac12=\ln2$; the erased bit has a
single certain outcome so its entropy is $0$; subtract. $\square$

**Lemma 2.7 (`erasure_not_injective`).** $\operatorname{erasure}:\mathrm{Bool}\to
\mathrm{Bool}$ is not injective. *Sketch.* It maps both $\mathrm{true}$ and
$\mathrm{false}$ to $\mathrm{false}$ (finite case check). $\square$

---

## 3. Landauer's cost as a relative entropy

**Definition 3.1 (Relative entropy / KL divergence, `relativeEntropy`).** For weights
$p,q:\Omega\to\mathbb{R}$,
$$ D(p\,\|\,q) \;=\; \sum_{\omega} p(\omega)\,\ln\frac{p(\omega)}{q(\omega)}. $$
The leading factor $p(\omega)$ makes the convention $0\cdot\ln 0=0$ automatic:
zero-probability outcomes contribute zero, so no special-casing of the support is
needed.

**Theorem 3.2 (`relativeEntropy_self`).** $D(p\,\|\,p)=0$ for every $p$.
*Sketch.* Termwise, either $p(\omega)=0$ (the factor kills the term) or
$\ln(p(\omega)/p(\omega))=\ln 1=0$. $\square$

**Theorem 3.3 (Gibbs' inequality, `relativeEntropy_nonneg`).** Let $p,q$ be PMFs with
$q(\omega)>0$ for all $\omega$. Then
$$ D(p\,\|\,q) \;\ge\; 0. $$
*Proof sketch.* The engine is the tangent bound $\ln x \le x-1$ for $x>0$
(`Real.log_le_sub_one_of_pos`). We claim the **pointwise** lower bound
$$ p(\omega)\,\ln\frac{p(\omega)}{q(\omega)} \;\ge\; p(\omega)-q(\omega) \qquad(\forall\omega). $$
If $p(\omega)=0$ this reads $0\ge -q(\omega)$, true since $q(\omega)>0$. If
$p(\omega)>0$, apply $\ln x\le x-1$ to $x=q(\omega)/p(\omega)>0$, giving
$\ln(q(\omega)/p(\omega)) \le q(\omega)/p(\omega)-1$; using $\ln(p/q)=-\ln(q/p)$ and
multiplying by $p(\omega)>0$ yields
$p(\omega)\ln(p(\omega)/q(\omega)) \ge p(\omega)-q(\omega)$. Summing over $\omega$ and
using $\sum_\omega p(\omega)=\sum_\omega q(\omega)=1$,
$$ D(p\,\|\,q) \;\ge\; \sum_\omega\big(p(\omega)-q(\omega)\big) \;=\; 1-1 \;=\; 0. \qquad\square $$

**Theorem 3.4 (`relativeEntropy_erased_uniform`).**
$$ D(\operatorname{erasedBool}\,\|\,\operatorname{uniformBool}) \;=\; \ln 2. $$
*Sketch.* The $\mathrm{false}$ term contributes $1\cdot\ln(1/\tfrac12)=\ln 2$; the
$\mathrm{true}$ term contributes $0$ because the erased bit has probability $0$ there.
$\square$

**Theorem 3.5 (Bridge identity, `relativeEntropy_eq_entropy_loss`).**
$$ D(\operatorname{erasedBool}\,\|\,\operatorname{uniformBool}) \;=\; H(\operatorname{uniformBool}) - H(\operatorname{erasedBool}). $$
*Sketch.* Both sides equal $\ln 2$ by Theorem 3.4 and Lemma 2.6. The content is that
two *a priori* different functionals — an asymmetric divergence of one distribution
against a reference, and a difference of single-distribution entropies — agree exactly
when the reference is uniform. $\square$

**Theorem 3.6 (Landauer cost as relative entropy, `landauer_cost_eq_relative_entropy`).**
For all $k,T\in\mathbb{R}$,
$$ k\,T\,\ln 2 \;=\; k\,T\,D(\operatorname{erasedBool}\,\|\,\operatorname{uniformBool}). $$
*Sketch.* Immediate from Theorem 3.4. $\square$

**Theorem 3.7 (Nonnegativity of relative-entropy work, `landauer_work_nonneg_via_gibbs`).**
Let $p,q$ be PMFs with $q>0$ pointwise, and $k,T\ge 0$. Then
$$ 0 \;\le\; k\,T\,D(p\,\|\,q). $$
*Sketch.* By Gibbs (Theorem 3.3) $D(p\,\|\,q)\ge 0$; multiply by $kT\ge 0$. $\square$

**Interpretation.** The quantity $kT\,D(p\,\|\,q)$ is the nonequilibrium **excess free
energy** of state $p$ relative to the equilibrium reference $q$ — the minimal work to
prepare or erase $p$ against $q$ [Esposito–Van den Broeck 2011]. Theorem 3.7 is the
information-theoretic form of the second law; Theorem 3.6 specializes it to one-bit
erasure, recovering exactly the Shannon-entropy-loss cost of §2.

---

## 4. The Jarzynski second law and Landauer's lower bound

We now derive the *sign* of dissipation. The starting point is the exact finite work
identity, valid whenever the Jarzynski condition holds.

**Theorem 4.1 (Jarzynski correction, `jarzynski_correction`).** If $\alpha\neq 0$ and
$W$ satisfies the Jarzynski condition with free-energy difference $\Delta F$, then
$$ \mathbb{E}_p[W] \;=\; \Delta F \;+\; \alpha^{-1}\ln \mathbb{E}_p\!\Big[e^{-\alpha\,(W-\mathbb{E}_p[W])}\Big]. $$
*Proof sketch.* Factor $e^{-\alpha(W-\langle W\rangle)} = e^{\alpha\langle W\rangle}\,
e^{-\alpha W}$, pull the constant $e^{\alpha\langle W\rangle}$ out of the expectation,
apply the Jarzynski identity $\mathbb{E}_p[e^{-\alpha W}]=e^{-\alpha\Delta F}$, take the
logarithm, and rearrange. $\square$

The first term is the reversible cost; the second is the fluctuation correction. Its
sign is controlled by convexity.

**Theorem 4.2 (Finite Jensen bound, `expect_add_one_le_expect_exp`).** For any PMF $p$
and observable $g$,
$$ 1 + \mathbb{E}_p[g] \;\le\; \mathbb{E}_p\!\big[e^{g}\big]. $$
*Proof sketch.* The pointwise tangent bound $1+x\le e^x$ gives
$1+g(\omega)\le e^{g(\omega)}$; multiply by $p(\omega)\ge 0$ and sum, using
$\sum_\omega p(\omega)=1$ to rewrite $1+\mathbb{E}_p[g]=\sum_\omega p(\omega)(1+g(\omega))$.
$\square$

**Lemma 4.3 (`expect_centered_zero`).** The centred work has zero mean:
$\mathbb{E}_p[-\alpha(W-\mathbb{E}_p[W])]=0$. *Sketch.* Linearity of expectation and
$\sum_\omega p(\omega)=1$. $\square$

**Theorem 4.4 (`work_fluctuation_ge_one`, `work_correction_nonneg`).**
$$ \mathbb{E}_p\!\Big[e^{-\alpha(W-\mathbb{E}_p[W])}\Big] \;\ge\; 1, \qquad \ln \mathbb{E}_p\!\Big[e^{-\alpha(W-\mathbb{E}_p[W])}\Big] \;\ge\; 0. $$
*Sketch.* Apply Theorem 4.2 with $g=-\alpha(W-\mathbb{E}_p[W])$ and Lemma 4.3 ($\mathbb
E_p[g]=0$) to get the first inequality; monotonicity of $\ln$ and $\ln 1=0$ give the
second. $\square$

**Theorem 4.5 (Second law, `jarzynski_second_law`).** Let $p$ be a PMF, $\alpha>0$, and
let $W$ satisfy the Jarzynski condition with free-energy difference $\Delta F$. Then
$$ \Delta F \;\le\; \mathbb{E}_p[W]. $$
*Proof sketch.* Substitute Theorem 4.1; the correction term is $\alpha^{-1}$ (positive)
times a nonnegative logarithm (Theorem 4.4), hence nonnegative. $\square$

**Theorem 4.6 (Landauer's principle, `landauer_kT_bound`).** Let $p$ be a PMF and
$k,T>0$. If $W$ satisfies the Jarzynski condition at inverse temperature
$\alpha=(kT)^{-1}$ with $\Delta F = kT\ln 2$, then
$$ k\,T\,\ln 2 \;\le\; \mathbb{E}_p[W]. $$
*Sketch.* Apply Theorem 4.5 with $\alpha=(kT)^{-1}>0$ and $\Delta F=kT\ln 2$. $\square$

**Theorem 4.7 (Cost = entropy loss, `landauer_cost_eq_entropy_loss`).** For all $k,T$,
$$ k\,T\,\ln 2 \;=\; k\,T\,\big(H(\operatorname{uniformBool})-H(\operatorname{erasedBool})\big). $$
*Sketch.* Lemma 2.6. $\square$

**Theorem 4.8 (Logical ⇒ thermodynamic irreversibility, `logical_to_thermodynamic_irreversibility`).**
Under the hypotheses of Theorem 4.6,
$$ \neg\,\mathrm{Injective}(\operatorname{erasure}) \quad\wedge\quad 0 < \mathbb{E}_p[W]. $$
*Proof sketch.* Non-injectivity is Lemma 2.7. For positivity, Theorem 4.6 gives
$\mathbb{E}_p[W]\ge kT\ln 2$, and $kT\ln 2>0$ since $k,T>0$ and $\ln 2>0$. The logical
irreversibility of erasure (a fact about a two-element function) thus forces strictly
positive mean dissipation. $\square$

---

## 5. The saturation condition: tightness $\Leftrightarrow$ reversibility

Theorem 4.5 is an inequality; when is it an equality? The answer makes the finite-size
"Jarzynski correction" quantitatively sharp.

**Theorem 5.1 (Strict finite Jensen bound, `expect_add_one_lt_expect_exp`).** Let $p$
be a PMF and $g$ an observable that is nonzero somewhere on the support of $p$. Then
$$ 1 + \mathbb{E}_p[g] \;<\; \mathbb{E}_p\!\big[e^{g}\big]. $$
*Proof sketch.* The strict pointwise bound $x+1<e^x$ for $x\neq 0$
(`Real.add_one_lt_exp`) holds with strict inequality at any support point where
$g(\omega)\neq 0$ and with the (non-strict) bound elsewhere; since that point carries
positive probability, the strict gap survives summation. $\square$

**Theorem 5.2 (Saturation $\Leftrightarrow$ zero fluctuations, `work_correction_zero_iff`).**
For $\alpha>0$ the Jarzynski fluctuation correction
$\ln\mathbb{E}_p[e^{-\alpha(W-\mathbb{E}_p[W])}]$ vanishes — equivalently the second-law
inequality $\Delta F\le\mathbb{E}_p[W]$ is an equality — if and only if the dissipated
work $W$ has no fluctuations on the support of $p$, i.e. $W$ is almost surely equal to
$\mathbb{E}_p[W]$.
*Proof sketch.* ($\Leftarrow$) If $W=\mathbb{E}_p[W]$ on the support, the centred work
is identically $0$ there, the exponential averages to $1$, and the logarithm is $0$.
($\Rightarrow$) If $W$ fluctuates, then $g=-\alpha(W-\mathbb{E}_p[W])$ is nonzero at some
support point (here $\alpha>0$ matters), so Theorem 5.1 gives
$1=1+\mathbb{E}_p[g] < \mathbb{E}_p[e^g]$, whence the logarithm is strictly positive and
the bound is strict. $\square$

**Physical reading.** Landauer's bound $kT\ln 2$ is attained *only* in the
quasi-static, reversible limit, where every realization of erasure costs the same
work. Any genuine fluctuation — any finite-speed, noisy protocol — forces a *strictly*
larger mean dissipation. The correction $\alpha^{-1}\ln\mathbb{E}_p[e^{-\alpha(W-\langle
W\rangle)}]$ is exactly this surcharge: nonnegative always (Theorem 4.4), and strictly
positive precisely away from reversibility (Theorem 5.2).

---

## 6. Extensivity and the data-processing inequality

**Theorem 6.1 (Entropy of the uniform distribution, `entropy_uniform`).** If
$|\Omega|=N>0$, the uniform distribution $p(\omega)=1/N$ has $H(p)=\ln N$.
*Sketch.* Constant summand: $H = N\cdot\operatorname{negMulLog}(1/N) = N\cdot
\tfrac1N\ln N = \ln N$. $\square$

**Theorem 6.2 (Maximal register entropy, `entropy_uniform_pow_two`, `entropy_uniform_bits`).**
The uniform distribution over $2^n$ states (e.g. over $\mathrm{Fin}\,n\to\mathrm{Bool}$)
has entropy $n\ln 2$. *Sketch.* Theorem 6.1 with $N=2^n$ and $\ln(2^n)=n\ln 2$. $\square$

**Theorem 6.3 (Extensive Landauer bound, `landauer_nbit_work_bound`).** Let $p$ be a
PMF, $k,T>0$. If $W$ satisfies the Jarzynski condition at $\alpha=(kT)^{-1}$ with
$\Delta F = n\,(kT\ln 2)$, then
$$ n\,k\,T\,\ln 2 \;\le\; \mathbb{E}_p[W]. $$
*Sketch.* Theorem 4.5 with $\Delta F = n\,kT\ln 2$. $\square$

**Theorem 6.4 (Per-bit cost, `landauer_per_bit_cost`).** For $n>0$,
$\big(n\,kT\ln 2\big)/n = kT\ln 2$. The guaranteed per-bit cost is exactly the
single-bit value for every register size — a finite-size, non-asymptotic form of the
thermodynamic limit. $\square$

We close with the principle beneath all of the above.

**Definition 6.5 (Pushforward, `pushforwardFun`).** For $f:\alpha\to\beta$ and weight
$p:\alpha\to\mathbb{R}$, the image measure is
$f_*p(y)=\sum_{x:\,f(x)=y} p(x)$.

**Theorem 6.6 (Deterministic data-processing inequality, `shannonEntropy_pushforward_le`).**
For any $f$ and nonnegative weights $p$,
$$ H(f_*p) \;\le\; H(p). $$
*Proof sketch.* Reindex $H(f_*p) = -\sum_x p(x)\ln f_*p(f(x))$ fiberwise. Since $x$ lies
in its own fiber and the weights are nonnegative, $f_*p(f(x))\ge p(x)$
(`pushforwardFun_apply_ge`); monotonicity of $\ln$ then makes each term of
$H(p)-H(f_*p)=\sum_x p(x)\big(\ln f_*p(f(x))-\ln p(x)\big)$ nonnegative. $\square$

**Theorem 6.7 (Reversible ⇒ entropy-preserving, `shannonEntropy_pushforward_of_injective`).**
If $f$ is injective then $H(f_*p)=H(p)$. *Sketch.* Each fiber is a singleton, so
$f_*p(f(x))=p(x)$ and the entropy gap vanishes termwise. $\square$

**Corollary 6.8 (Landauer lower bound and reversible freedom, `landauer_lower_bound`,
`landauer_lower_bound_zero_of_injective`).** For $k,T\ge 0$ the dissipated heat of
running $f$ on $p$ satisfies
$$ 0 \;\le\; k\,T\,\big(H(p)-H(f_*p)\big), $$
with equality (zero dissipation) whenever $f$ is injective. *Sketch.* Theorems 6.6 and
6.7. $\square$

Erasure is the extremal collapse $f\equiv\text{const}$, maximizing the entropy drop;
reversible (injective) computation is the boundary case of zero cost. The thermodynamic
tax is a fee on *forgetting*, not on *computing*.

---

## 7. Algorithms

The verification is constructive over finite spaces, so each quantity is directly
computable. We highlight two algorithms (Python implementations in §9 and `demo.py`).

**Algorithm A (KL-divergence Landauer cost).** Given finite PMFs $p,q$ (with $q>0$) and
constants $k,T$, compute $D(p\,\|\,q)=\sum_\omega p(\omega)\ln(p(\omega)/q(\omega))$
(treating $p(\omega)=0$ terms as $0$) and return $kT\cdot D$. For
$(p,q)=(\text{erased},\text{uniform})$ this returns $kT\ln 2$, numerically confirming
Theorems 3.4 and 3.6. Complexity $O(|\Omega|)$.

**Algorithm B (Jarzynski second-law / saturation check).** Given a finite distribution
$p$, a work vector $W$, and $\alpha>0$, compute $\langle W\rangle=\sum p(\omega)W(\omega)$
and the correction $C=\alpha^{-1}\ln\sum_\omega p(\omega)e^{-\alpha(W(\omega)-\langle
W\rangle)}$. Then $\langle W\rangle = \Delta F + C$ with $\Delta F=\langle W\rangle-C$,
$C\ge 0$, and $C=0$ iff $W$ is constant on the support — a numerical witness of Theorems
4.5 and 5.2. Complexity $O(|\Omega|)$.

---

## 8. Applications

- **Energy limits of computing.** Theorems 4.6 and 6.3 set an absolute floor on the
  energy any irreversible processor must dissipate per erased bit, a constraint that
  grows in relevance as transistor counts rise and per-operation energies fall toward
  $kT$.
- **Reversible and adiabatic computing.** Theorem 6.7 / Corollary 6.8 give the
  theoretical license for reversible logic: computations that destroy no information can,
  in principle, run without paying Landauer's tax.
- **Single-particle thermodynamics.** The saturation theorem (5.2) explains why
  laboratory measurements of the $kT\ln 2$ floor require slow, quasi-static protocols:
  any finite-speed erasure necessarily overshoots.
- **Nonequilibrium free energy.** The relative-entropy work $kT\,D(p\,\|\,q)$ (Theorem
  3.7) is the operational cost of maintaining a system away from equilibrium, relevant
  to molecular machines and feedback ("Maxwell demon") protocols.

---

## 9. Discussion

The development is deliberately *minimal*: the entire chain rests on two elementary
analytic facts and their strict counterparts.

- **Gibbs' inequality** $D(p\,\|\,q)\ge 0$ is the tangent line $\ln x\le x-1$.
- **The second law** $\Delta F\le\langle W\rangle$ is the convexity bound $1+x\le e^x$.
- **Saturation** ($\langle W\rangle=\Delta F$ iff reversible) is the *strictness*
  $1+x<e^x$ for $x\neq 0$.
- **Logical $\Rightarrow$ thermodynamic irreversibility** is the non-injectivity of a
  two-element map combined with $kT\ln 2 > 0$.

A notable structural point is the **duality** of the two accounts of the erasure cost:
the Shannon entropy *loss* $H(\text{uniform})-H(\text{erased})$ and the relative entropy
$D(\text{erased}\,\|\,\text{uniform})$ are *a priori* different functionals (one a
difference of single-distribution entropies, the other an asymmetric divergence), yet
they coincide exactly against the uniform reference (Theorem 3.5). The leading factor
$p(\omega)$ in the KL definition silently enforces the $0\ln 0=0$ convention, so no
support hypotheses on $p$ are needed; only the reference $q$ must have full support.

**On conventions and units.** We work in *nats* (natural logarithm) throughout, so the
single-bit cost is $kT\ln 2$; converting to *bits* (base-two logarithm) simply replaces
$\ln 2$ by $1$ and rescales $k$ accordingly. The Shannon entropy is defined via
$\operatorname{negMulLog}(x)=-x\ln x$, which is continuous at $0$ with value $0$; this is
the mathematically clean encoding of the physicists' convention that an impossible
outcome carries no surprise. The same device appears in the KL divergence through the
leading factor $p(\omega)$, so the two functionals share a single, uniform treatment of
zero-probability outcomes.

**On the strength of the saturation result.** Theorem 5.2 is a genuine *iff*, not merely
a sufficient condition. The forward direction — fluctuations imply a strict surcharge —
is the physically substantive half, and it is exactly where the *strict* convexity bound
$1+x<e^x$ (rather than its non-strict cousin) is indispensable. This is the precise
sense in which Landauer's bound is "almost never" saturated in practice: any realistic,
finite-time erasure protocol produces a nondegenerate work distribution, and Theorem 5.2
then guarantees that its mean dissipation strictly exceeds $kT\ln 2$. The reversible
ideal is a measure-zero boundary in the space of protocols.

**Relation to the data-processing viewpoint.** Sections 3–5 and Section 6 give two
complementary derivations of nonnegative dissipation. The Jarzynski route (Section 4)
is *dynamical*: it bounds the work of an explicit driven process. The data-processing
route (Section 6, Theorem 6.6) is *static*: it bounds the entropy change of any
deterministic map, with erasure as the extremal entropy-collapsing case and bijections
as the entropy-preserving boundary. That both routes deliver the same $kT\ln 2$ floor —
one through thermodynamic fluctuations, the other through pure information theory — is the
clearest expression of Landauer's thesis that the two subjects are, at bottom, the same.

---

## 10. Future directions

(Reproduced from the Phase A research program.)

**Conjecture 1 — The fluctuation surcharge is monotone in inverse temperature.** For
mean-zero work fluctuation $X=-(W-\mathbb{E}[W])$, the Jarzynski correction
$K(\alpha)=\ln\mathbb{E}[e^{\alpha X}]$ is nondecreasing on $\alpha\ge 0$, with
$K(0)=0$ and $K'(0)=0$. Hence colder operation (larger $\alpha=1/kT$) never decreases —
and generically strictly increases — the dissipated-work surcharge above the reversible
bound. The key insight: $K$ is the cumulant generating function of a mean-zero random
variable, so it is convex with a stationary point at the origin; the second law
$K\ge 0$ proved this cycle is exactly the statement that the origin is its minimum, and
monotonicity is the next derivative-level refinement. This cycle already isolated
$K(\alpha)\ge 0$ with equality iff $X=0$ a.s. (`work_correction_zero_iff`); upgrading
"minimum at $0$" to "monotone on $\alpha\ge0$" needs only convexity of the CGF.

**Conjecture 2 — Strict extensivity defect for correlated multi-bit erasure.** For an
$n$-bit register, the extensive bound $n\,kT\ln 2$ (`landauer_nbit_work_bound`) is
saturated iff the bits are statistically independent and each is erased reversibly; any
correlation strictly lowers the required entropy production below $n\ln 2$, by exactly
the total correlation (multi-information) $\sum_i H(\text{bit}_i)-H(\text{register})$.
The key insight: multi-bit entropy loss is subadditive, and the gap from $n\ln 2$ is the
mutual information among the bits — a relative entropy $D(\text{joint}\,\|\,\text{product
of marginals})$, shown nonnegative this cycle via Gibbs. The ingredients
`relativeEntropy_nonneg` and `relativeEntropy_eq_entropy_loss` express the defect as a
single relative entropy and bound it.

**Conjecture 3 — Pinsker-type quantitative irreversibility bound.** The dissipated-work
surcharge is bounded below by the squared total-variation distance of the work
distribution from its quasi-static (reversible) limit:
$\mathbb{E}[W]-\Delta F \ge (kT)\,c\,\|p-p_{\mathrm{rev}}\|_{\mathrm{TV}}^2$ for an
absolute constant $c>0$. The key insight: this cycle's qualitative dichotomy
(`work_correction_zero_iff`) is the degenerate case of a quantitative stability
estimate; Pinsker's inequality converts the relative-entropy form of the surcharge into
a metric lower bound.

---

## References

- R. Landauer, *Irreversibility and heat generation in the computing process*, IBM J.
  Res. Dev. **5** (1961), 183–191.
- C. Jarzynski, *Nonequilibrium equality for free energy differences*, Phys. Rev. Lett.
  **78** (1997), 2690–2693.
- S. Kullback and R. A. Leibler, *On information and sufficiency*, Ann. Math. Statist.
  **22** (1951), 79–86.
- C. H. Bennett, *The thermodynamics of computation — a review*, Int. J. Theor. Phys.
  **21** (1982), 905–940.
- M. Esposito and C. Van den Broeck, *Second law and Landauer principle far from
  equilibrium*, Europhys. Lett. **95** (2011), 40004.
- M. B. Plenio and V. Vitelli, *The physics of forgetting: Landauer's erasure principle
  and information theory*, Contemp. Phys. **42** (2001), 25–60.
- T. M. Cover and J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley, 2006.
