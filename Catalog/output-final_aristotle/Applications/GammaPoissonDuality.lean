import Mathlib

/-!
# Gamma–Poisson duality for integer-shape descendant limit laws

For the random recursive DAG `G_n` with out-degree `d ≥ 2`, the rescaled descendant count
`|D_n| / n^{1/d}` converges to a Gamma`(d, 1)` law (Janson, 2023).  When the shape
parameter is a positive integer the limiting distribution is an **Erlang** distribution,
and its cumulative distribution function admits a finite closed form linking it to the
**Poisson** distribution.  This is the classical *Gamma–Poisson duality*:

`P(Gamma(m+1, 1) ≤ t) = P(Poisson(t) ≥ m+1) = 1 - ∑_{k=0}^{m} e^{-t} t^k / k!`.

This file establishes that identity fully formally, entirely by real analysis (a
telescoping derivative computation plus the fundamental theorem of calculus), and derives
its consequences.  The individual summands `e^{-t} t^k / k!` are exactly the Poisson`(t)`
point masses, so the survival function of the continuous Erlang law is *identically* the
tail of a discrete Poisson law — a genuine bridge between a continuous limit target and a
discrete counting distribution.

Main results:

* `poissonTerm_hasDerivAt_succ` / `poissonTerm_hasDerivAt_zero` : the derivative identities
  `d/dt [e^{-t} t^{k+1}/(k+1)!] = e^{-t} t^k/k! - e^{-t} t^{k+1}/(k+1)!` (a telescoping step);
* `erlangSurvival_hasDerivAt` : the survival function
  `S_{m+1}(t) = ∑_{k≤m} e^{-t} t^k/k!` has derivative `-e^{-t} t^m/m!` (minus the density);
* `erlang_cdf` : **the Gamma–Poisson duality** — the Erlang CDF equals `1 - S_{m+1}(t)`;
* `erlangSurvival_tendsto_zero` : `S_{m+1}(t) → 0` as `t → ∞`;
* `erlang_density_integral_tendsto_one` : the Erlang density integrates to `1` over
  `(0, ∞)` (obtained here purely through the duality, a cross-check on the density);
* `poissonTerm_eq_gammaDensity` : the summand is the Gamma`(m+1, 1)` density
  `e^{-x} x^m / Γ(m+1)`.

All densities are with respect to Lebesgue measure on `(0, ∞)`.
-/

open Real MeasureTheory Filter Topology
open scoped Real BigOperators

namespace DDAG

/-- The Poisson`(t)` point mass at `k`, `e^{-t} t^k / k!`.  Viewed as a function of the
continuous variable `t`, `poissonTerm k` is (up to shift of shape) the Gamma density; as a
function of the discrete index `k` it is the Poisson probability mass function. -/
noncomputable def poissonTerm (k : ℕ) (t : ℝ) : ℝ :=
  Real.exp (-t) * t ^ k / (k.factorial : ℝ)

/-- The Erlang survival function with `n` terms, `S_n(t) = ∑_{k<n} e^{-t} t^k/k!`.
This is simultaneously the tail `P(Poisson(t) < n)` of a Poisson law. -/
noncomputable def erlangSurvival (n : ℕ) (t : ℝ) : ℝ :=
  ∑ k ∈ Finset.range n, poissonTerm k t

/-- The summand is the Gamma`(m+1, 1)` density `e^{-x} x^m / Γ(m+1)`. -/
lemma poissonTerm_eq_gammaDensity (m : ℕ) (x : ℝ) :
    poissonTerm m x = Real.exp (-x) * x ^ m / Real.Gamma (m + 1) := by
  unfold poissonTerm
  rw [Real.Gamma_nat_eq_factorial]

/-- **Telescoping derivative step.** The derivative of the `(k+1)`-st Poisson term is the
difference of consecutive terms. -/
lemma poissonTerm_hasDerivAt_succ (m : ℕ) (t : ℝ) :
    HasDerivAt (poissonTerm (m + 1)) (poissonTerm m t - poissonTerm (m + 1) t) t := by
  have he : HasDerivAt (fun x : ℝ => Real.exp (-x)) (-Real.exp (-t)) t := by
    simpa using (Real.hasDerivAt_exp (-t)).comp t ((hasDerivAt_id t).neg)
  have hp : HasDerivAt (fun x : ℝ => x ^ (m + 1)) ((m + 1 : ℝ) * t ^ m) t := by
    simpa using hasDerivAt_pow (m + 1) t
  have hmul := (he.mul hp).div_const ((m + 1).factorial : ℝ)
  unfold poissonTerm
  convert hmul using 1
  push_cast [Nat.factorial_succ]
  have hf : ((m.factorial : ℝ)) ≠ 0 := by exact_mod_cast (Nat.factorial_pos m).ne'
  field_simp
  ring

/-- Base case of the telescoping derivative: `d/dt e^{-t} = -e^{-t}`. -/
lemma poissonTerm_hasDerivAt_zero (t : ℝ) :
    HasDerivAt (poissonTerm 0) (-poissonTerm 0 t) t := by
  have he : HasDerivAt (fun x : ℝ => Real.exp (-x)) (-Real.exp (-t)) t := by
    simpa using (Real.hasDerivAt_exp (-t)).comp t ((hasDerivAt_id t).neg)
  have hfun : poissonTerm 0 = fun x : ℝ => Real.exp (-x) := by
    funext x; simp [poissonTerm]
  rw [hfun]
  simpa using he

/-- **Derivative of the Erlang survival function.** `S_{m+1}(t) = ∑_{k≤m} e^{-t}t^k/k!`
has derivative `-e^{-t} t^m/m! = -poissonTerm m t`, i.e. minus the Gamma`(m+1,1)` density.
The proof is a telescoping induction on `m`. -/
theorem erlangSurvival_hasDerivAt (m : ℕ) (t : ℝ) :
    HasDerivAt (erlangSurvival (m + 1)) (-poissonTerm m t) t := by
  induction m with
  | zero =>
    have h := poissonTerm_hasDerivAt_zero t
    have : erlangSurvival 1 = poissonTerm 0 := by
      funext x; simp [erlangSurvival]
    rw [this]; exact h
  | succ m ih =>
    have hstep := poissonTerm_hasDerivAt_succ m t
    have hsum : HasDerivAt (erlangSurvival (m + 2))
        (-poissonTerm m t + (poissonTerm m t - poissonTerm (m + 1) t)) t := by
      have : erlangSurvival (m + 2)
          = fun x => erlangSurvival (m + 1) x + poissonTerm (m + 1) x := by
        funext x
        simp [erlangSurvival, Finset.sum_range_succ]
      rw [this]
      exact ih.add hstep
    have : (-poissonTerm m t + (poissonTerm m t - poissonTerm (m + 1) t))
        = -poissonTerm (m + 1) t := by ring
    rwa [this] at hsum

/-- Continuity of the Poisson/Gamma-density summand. -/
lemma continuous_poissonTerm (k : ℕ) : Continuous (poissonTerm k) := by
  unfold poissonTerm
  fun_prop

@[simp] lemma erlangSurvival_zero_eq_one (n : ℕ) (hn : 1 ≤ n) :
    erlangSurvival n 0 = 1 := by
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_lt hn
  simp only [erlangSurvival]
  rw [Finset.sum_eq_single 0]
  · simp [poissonTerm]
  · intro k _ hk
    simp [poissonTerm, zero_pow hk]
  · intro h
    simp at h

/-- **Gamma–Poisson duality (the Erlang CDF).** For every integer shape `m + 1` and every
`t`, the cumulative distribution function of the Gamma`(m+1, 1)` law equals

`∫₀ᵗ e^{-x} x^m/m! dx = 1 - ∑_{k=0}^{m} e^{-t} t^k/k!`,

i.e. `P(Gamma(m+1,1) ≤ t) = 1 - P(Poisson(t) ≤ m) = P(Poisson(t) ≥ m+1)`. -/
theorem erlang_cdf (m : ℕ) (t : ℝ) :
    ∫ x in (0:ℝ)..t, poissonTerm m x = 1 - erlangSurvival (m + 1) t := by
  have hderiv : ∀ x ∈ Set.uIcc (0:ℝ) t,
      HasDerivAt (erlangSurvival (m + 1)) (-poissonTerm m x) x :=
    fun x _ => erlangSurvival_hasDerivAt m x
  have hint : IntervalIntegrable (fun x => -poissonTerm m x) volume 0 t :=
    ((continuous_poissonTerm m).neg).intervalIntegrable 0 t
  have hftc := intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hint
  have : ∫ x in (0:ℝ)..t, poissonTerm m x
      = -(∫ x in (0:ℝ)..t, -poissonTerm m x) := by
    rw [intervalIntegral.integral_neg]; ring
  rw [this, hftc, erlangSurvival_zero_eq_one (m + 1) (Nat.le_add_left 1 m)]
  ring

/-- Each Poisson/Gamma summand vanishes at infinity: `e^{-t} t^k/k! → 0`. -/
lemma poissonTerm_tendsto_zero (k : ℕ) :
    Tendsto (poissonTerm k) atTop (𝓝 0) := by
  have h := tendsto_pow_mul_exp_neg_atTop_nhds_zero k
  have hfun : poissonTerm k
      = fun t : ℝ => (t ^ k * Real.exp (-t)) / (k.factorial : ℝ) := by
    funext t; unfold poissonTerm; ring
  rw [hfun]
  simpa using h.div_const (k.factorial : ℝ)

/-- **The Erlang survival function vanishes at infinity.** `S_n(t) → 0` as `t → ∞`. -/
theorem erlangSurvival_tendsto_zero (n : ℕ) :
    Tendsto (erlangSurvival n) atTop (𝓝 0) := by
  unfold erlangSurvival
  have : Tendsto (fun t => ∑ k ∈ Finset.range n, poissonTerm k t) atTop
      (𝓝 (∑ k ∈ Finset.range n, (0 : ℝ))) :=
    tendsto_finset_sum _ (fun k _ => poissonTerm_tendsto_zero k)
  simpa using this

/-- **The Erlang density is a probability density.** Via the Gamma–Poisson duality, the
cumulative integral `∫₀ᵗ e^{-x} x^m/m! dx` tends to `1` as `t → ∞`; equivalently the
Gamma`(m+1, 1)` density integrates to `1` over the positive half-line. -/
theorem erlang_density_integral_tendsto_one (m : ℕ) :
    Tendsto (fun t => ∫ x in (0:ℝ)..t, poissonTerm m x) atTop (𝓝 1) := by
  have hcdf : (fun t => ∫ x in (0:ℝ)..t, poissonTerm m x)
      = fun t => 1 - erlangSurvival (m + 1) t := by
    funext t; exact erlang_cdf m t
  rw [hcdf]
  have := (erlangSurvival_tendsto_zero (m + 1))
  simpa using tendsto_const_nhds.sub this

/-- **Monotonicity of the Erlang CDF.** The cumulative distribution function is
nondecreasing on the positive half-line, as any CDF must be. -/
theorem erlang_cdf_mono (m : ℕ) :
    MonotoneOn (fun t => ∫ x in (0:ℝ)..t, poissonTerm m x) (Set.Ici (0:ℝ)) := by
  intro a ha b _hb hab
  simp only
  have hnn : 0 ≤ ∫ x in a..b, poissonTerm m x := by
    apply intervalIntegral.integral_nonneg hab
    intro x hx
    have hx0 : 0 ≤ x := le_trans (Set.mem_Ici.mp ha) hx.1
    unfold poissonTerm; positivity
  have hadd : (∫ x in (0:ℝ)..a, poissonTerm m x) + (∫ x in a..b, poissonTerm m x)
      = ∫ x in (0:ℝ)..b, poissonTerm m x :=
    intervalIntegral.integral_add_adjacent_intervals
      ((continuous_poissonTerm m).intervalIntegrable _ _)
      ((continuous_poissonTerm m).intervalIntegrable _ _)
  linarith

end DDAG

/-
-- !-- Lab Notes -- !--

Hypothesis (Hypothesizer).
  The descendant limit law for random `d`-DAGs targets a Gamma`(d, 1)` law.  At an
  integer shape the Gamma law is Erlang, and we conjectured its cumulative distribution
  function has a *finite* closed form tying the continuous limit to a discrete Poisson
  tail: `P(Gamma(m+1,1) <= t) = 1 - sum_{k<=m} e^{-t} t^k/k!`.  This is a bridge between a
  continuous limit target (the Applications / probability domain) and a discrete counting
  law (combinatorics), so it serves the cross-domain half of the menu balance constraint.

Experiment (Experimenter).
  We isolated the summand `poissonTerm k t = e^{-t} t^k/k!` and proved the telescoping
  derivative `d/dt poissonTerm (k+1) = poissonTerm k - poissonTerm (k+1)`.  Summing over
  `k <= m` (an induction) collapses the survival function's derivative to exactly minus the
  density, `-poissonTerm m`.  The fundamental theorem of calculus then delivers the CDF.

Analysis (Analyst).
  The telescoping structure is the crux: it removes any need for integration by parts or
  the incomplete Gamma function.  The same derivative identity simultaneously proves (i)
  the closed-form CDF, (ii) that the density integrates to `1` (letting `t -> infinity`,
  using that `t^k e^{-t} -> 0`), and (iii) monotonicity of the CDF (nonnegative integrand).
  A naive attempt to differentiate `sum x^k/k!` by `HasDerivAt.sum` produced an index-shift
  obligation `sum_{k<n} k t^{k-1}/k! = sum_{j<n-1} t^j/j!`; recasting everything through the
  single-index `poissonTerm` and inducting sidesteps that reindexing entirely.

Critique (Critic).
  No theorem is `True`/`native_decide`/definitional: each main result invokes calculus
  (`HasDerivAt`, FTC), induction, or limit arguments.  `erlang_cdf` is stated for every
  real `t` (not only `t >= 0`), so no corner case is hidden.  The result genuinely extends
  the catalog files `GammaLimitLaw.lean` (which computes moments of the target) and
  `DescendantScaling.lean` (which fixes the `n^{1/d}` normalisation) by supplying the
  distribution *function* of the integer-shape target, which neither file addresses.

Synthesis (Principal Investigator).
  For integer shape the descendant limit law's target distribution is completely explicit:
  its CDF is a finite Poisson tail, it is a bona fide probability law, and it is monotone.
  This closes the loop between the moment description and the pointwise distribution.
-/