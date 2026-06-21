/-
# Shallow EML Networks: Explicit Approximation Rates via Softplus

This file develops a *concrete, constructive* shallow-network approximation theory
for the EML (Exponential / Multiplicative / Logarithmic) function class.

The central object is the **softplus unit**

  `softplus β x = log (1 + exp (β x)) / β`,

which is an honest EML function (a logarithm of an affine combination of an
exponential).  Its compositional **depth is 2** (one `exp` followed by one `log`),
so it is the simplest non-affine EML primitive.  We show it approximates the ReLU
nonlinearity with an *explicit* rate controlled by the steepness `β`:

  `relu x ≤ softplus β x ≤ relu x + log 2 / β`.

Consequently any *shallow* (single-hidden-layer, width-`N`) ReLU network is
approximated by the corresponding shallow softplus (EML) network with an explicit
uniform error `(Σ |cᵢ|) · log 2 / β`, which can be driven below any `ε > 0` by an
explicit choice of `β`.

## Main results
* `softplus_ge_relu`         — softplus dominates ReLU.
* `softplus_le_relu_add`     — softplus exceeds ReLU by at most `log 2 / β`.
* `abs_softplus_sub_relu_le` — the explicit pointwise depth-2 rate.
* `shallow_approx`           — explicit width-`N` shallow-network error bound.
* `shallow_eml_uniform_approx` — explicit `β` achieving any target accuracy `ε`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Among EML primitives the cheapest non-linear unit is
  `log(1+exp(·))`; it should approximate ReLU with a rate that is *uniform in x*
  and inversely proportional to the steepness β, giving a genuine "shallow" rate.
Experiment (Experimenter): Proved the two-sided sandwich
  `relu ≤ softplus β ≤ relu + log 2/β` from `log` monotonicity and the bound
  `1 + e^t ≤ 2 e^{max(t,0)}`.  Lifted it through finite linear combinations.
Analysis (Analyst): The error is *independent of x*, so the rate is purely a
  function of network steepness β and the ℓ¹ mass of the output weights — the
  depth-2 EML primitive already yields O(1/β) uniform accuracy.  The constant
  `log 2` is sharp at x = 0 (where softplus 0 = log 2 / β, relu 0 = 0).
Critique (Critic): The bound must hold for ALL x (not just on [0,1]); verified the
  estimate is global.  Guarded the `β > 0` hypothesis everywhere (division by β).
Synthesis (PI): A constructive companion to the abstract Stone–Weierstrass density
  in `EML.StoneWeierstrassApprox`: density there is non-quantitative, here we give
  explicit constants for the shallow regime.
-- !-- end Lab Notes -- !--
-/
import Mathlib

noncomputable section

open Real Finset

namespace EMLShallow

/-- The ReLU nonlinearity. -/
def relu (x : ℝ) : ℝ := max x 0

/-- The softplus EML unit `log (1 + exp (β x)) / β`.
    Its EML compositional depth is 2: one `exp`, then one `log`. -/
def softplus (β x : ℝ) : ℝ := Real.log (1 + Real.exp (β * x)) / β

@[simp] theorem relu_nonneg (x : ℝ) : 0 ≤ relu x := le_max_right _ _

theorem relu_eq_self_of_nonneg {x : ℝ} (hx : 0 ≤ x) : relu x = x := max_eq_left hx

/-
`β • relu x = max (β x) 0` for `β ≥ 0`.
-/
theorem smul_relu {β : ℝ} (hβ : 0 ≤ β) (x : ℝ) : β * relu x = max (β * x) 0 := by
  simp [ mul_max_of_nonneg, hβ, relu ]

/-
**Softplus dominates ReLU.**
-/
theorem softplus_ge_relu {β : ℝ} (hβ : 0 < β) (x : ℝ) : relu x ≤ softplus β x := by
  unfold relu softplus;
  rw [ le_div_iff₀' hβ ];
  cases max_cases x 0 <;> simp +decide [ * ];
  · rw [ Real.le_log_iff_exp_le ] <;> linarith [ Real.exp_pos ( β * x ) ];
  · exact Real.log_nonneg ( by linarith [ Real.exp_pos ( β * x ) ] )

/-
**Softplus exceeds ReLU by at most `log 2 / β`.**
-/
theorem softplus_le_relu_add {β : ℝ} (hβ : 0 < β) (x : ℝ) :
    softplus β x ≤ relu x + Real.log 2 / β := by
  -- By multiplying both sides of the inequality by β, we can eliminate the denominator.
  have h_mul : Real.log (1 + Real.exp (β * x)) ≤ β * relu x + Real.log 2 := by
    -- By multiplying both sides of the inequality by β, we can eliminate the denominator and work with the exponential function.
    have h_exp : 1 + Real.exp (β * x) ≤ 2 * Real.exp (β * relu x) := by
      cases max_cases x 0 <;> simp +decide [ *, relu ];
      · linarith [ Real.one_le_exp ( mul_nonneg hβ.le ( by linarith : 0 ≤ x ) ) ];
      · linarith [ Real.exp_le_one_iff.mpr ( show β * x ≤ 0 by nlinarith ) ];
    rw [ add_comm, Real.log_le_iff_le_exp ];
    · rw [ Real.exp_add, Real.exp_log ] <;> linarith;
    · positivity;
  unfold softplus; rw [ add_div', div_le_div_iff₀ ] <;> nlinarith;

/-
**Explicit pointwise depth-2 EML rate for ReLU.**
-/
theorem abs_softplus_sub_relu_le {β : ℝ} (hβ : 0 < β) (x : ℝ) :
    |softplus β x - relu x| ≤ Real.log 2 / β := by
  rw [ abs_of_nonneg ];
  · exact sub_le_iff_le_add'.mpr ( softplus_le_relu_add hβ x );
  · exact sub_nonneg_of_le ( softplus_ge_relu hβ x )

/-! ## Shallow (single-hidden-layer) networks -/

variable {N : ℕ}

/-- A shallow width-`N` ReLU network `Σ cᵢ relu (aᵢ x + bᵢ)`. -/
def shallowReLU (c a b : Fin N → ℝ) (x : ℝ) : ℝ :=
  ∑ i, c i * relu (a i * x + b i)

/-- A shallow width-`N` softplus (EML) network `Σ cᵢ softplus β (aᵢ x + bᵢ)`. -/
def shallowSoftplus (β : ℝ) (c a b : Fin N → ℝ) (x : ℝ) : ℝ :=
  ∑ i, c i * softplus β (a i * x + b i)

/-
**Explicit shallow-network error bound.**
The width-`N` softplus network approximates the corresponding ReLU network with
uniform error at most `(Σ |cᵢ|) · log 2 / β`.
-/
theorem shallow_approx {β : ℝ} (hβ : 0 < β) (c a b : Fin N → ℝ) (x : ℝ) :
    |shallowReLU c a b x - shallowSoftplus β c a b x|
      ≤ (∑ i, |c i|) * (Real.log 2 / β) := by
  -- By definition of shallowReLU and shallowSoftplus, we can write the difference as a sum of terms.
  have h_diff : |shallowReLU c a b x - shallowSoftplus β c a b x| = |∑ i, c i * (relu (a i * x + b i) - softplus β (a i * x + b i))| := by
    simp +decide [ mul_sub, shallowReLU, shallowSoftplus ];
  rw [ h_diff, Finset.sum_mul _ _ _ ];
  exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( Finset.sum_le_sum fun i _ => by rw [ abs_mul ] ; exact mul_le_mul_of_nonneg_left ( by simpa [ abs_sub_comm ] using abs_softplus_sub_relu_le hβ ( a i * x + b i ) ) ( abs_nonneg _ ) )

/-
**Explicit accuracy.** For any target `ε > 0` there is an explicit steepness
`β` for which the shallow softplus (EML) network is uniformly `ε`-close to the
shallow ReLU network on the whole line.
-/
theorem shallow_eml_uniform_approx (c a b : Fin N → ℝ) {ε : ℝ} (hε : 0 < ε) :
    ∃ β : ℝ, 0 < β ∧ ∀ x : ℝ,
      |shallowReLU c a b x - shallowSoftplus β c a b x| ≤ ε := by
  -- Choose β = (S + 1) * log 2 / ε.
  use ( (∑ i, |c i|) + 1 ) * Real.log 2 / ε;
  refine' ⟨ by positivity, fun x => le_trans ( shallow_approx _ _ _ _ x ) _ ⟩;
  · positivity;
  · field_simp;
    linarith

end EMLShallow