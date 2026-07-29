import Mathlib

/-!
# Fixed points of an exponential--logarithmic iteration

This file studies `x ↦ exp a * log (x + c)`.  The unrestricted test claim from
this research question is false: even with `0 < a < 1` and `0 < c < 1`, a fixed
point need not exist.  We prove this for `a = log 2`, `c = 1/2` on the natural
logarithmic domain.

The positive result is the precise contraction theorem suggested by the question.
On a closed invariant interval `[L,U]`, if `L+c>0` and
`exp a / (L+c) ≤ q < 1`, the map has a unique fixed point in the interval;
every iteration starting there converges to it with Banach's geometric error bound.
-/

noncomputable section

open Real Set Filter Function Topology

namespace EMLFixedPoint

/-- The EML exponential--logarithmic update with `b = 1`. -/
def emlMap (a c : ℝ) (x : ℝ) : ℝ :=
  Real.exp a * Real.log (x + c)

/-- Exact derivative of the update on its natural domain. -/
theorem hasDerivAt_emlMap {a c x : ℝ} (hx : x + c ≠ 0) :
    HasDerivAt (emlMap a c) (Real.exp a / (x + c)) x := by
  have h1 : HasDerivAt (fun y => y + c) 1 x := hasDerivAt_id x |>.add_const c
  have h2 : HasDerivAt Real.log ((x + c)⁻¹) (x + c) := Real.hasDerivAt_log hx
  have h3 := h2.comp x h1
  simp at h3
  have h4 := h3.const_mul (Real.exp a)
  convert h4 using 1

/-- The derivative bound on a positive interval gives the expected Lipschitz bound. -/
theorem lipschitzOn_emlMap_Icc {a c L U q : ℝ}
    (hpos : 0 < L + c) (hq0 : 0 ≤ q) (hderiv : Real.exp a / (L + c) ≤ q) :
    LipschitzOnWith ⟨q, hq0⟩ (emlMap a c) (Icc L U) := by
  apply Convex.lipschitzOnWith_of_nnnorm_deriv_le (s := Icc L U)
  · intro x hx
    exact (hasDerivAt_emlMap (by linarith [hx.1] : x + c ≠ 0)).differentiableAt
  · intro x hx
    have hderiv' : HasDerivAt (emlMap a c) (Real.exp a / (x + c)) x := hasDerivAt_emlMap (by linarith [hx.1] : x + c ≠ 0)
    rw [hderiv'.deriv]
    rw [nnnorm_div]
    erw [Real.nnnorm_of_nonneg (Real.exp_nonneg a)]
    erw [Real.nnnorm_of_nonneg (by linarith [hx.1] : x + c ≥ 0)]
    have h1 : Real.exp a / (x + c) ≤ Real.exp a / (L + c) := by
      apply div_le_div_of_nonneg_left (Real.exp_nonneg a) hpos
      linarith [hx.1]
    exact_mod_cast le_trans h1 hderiv
  · exact convex_Icc L U

/-- Restriction of an invariant EML update to its interval. -/
def restrictedMap {a c L U : ℝ} (hmap : MapsTo (emlMap a c) (Icc L U) (Icc L U)) :
    Icc L U → Icc L U := hmap.restrict (emlMap a c) (Icc L U) (Icc L U)

/-- Under the explicit derivative bound, the restricted map is a contraction. -/
theorem contracting_restrictedMap {a c L U q : ℝ}
    (hpos : 0 < L + c) (hq0 : 0 ≤ q) (hq1 : q < 1)
    (hderiv : Real.exp a / (L + c) ≤ q)
    (hmap : MapsTo (emlMap a c) (Icc L U) (Icc L U)) :
    ContractingWith ⟨q, hq0⟩ (restrictedMap hmap) := by
  have hLip : LipschitzOnWith ⟨q, hq0⟩ (emlMap a c) (Icc L U) :=
    lipschitzOn_emlMap_Icc hpos hq0 hderiv
  refine ⟨?_, ?_⟩
  · exact_mod_cast hq1
  · intro x y
    exact hLip x.2 y.2

/-- Banach fixed-point theorem for the EML update, including uniqueness,
convergence of every orbit in the invariant interval, and an explicit geometric
error estimate. -/
theorem exists_unique_fixedPoint_and_converges
    {a c L U q : ℝ} (hpos : 0 < L + c)
    (hq0 : 0 ≤ q) (hq1 : q < 1) (hderiv : Real.exp a / (L + c) ≤ q)
    (hmap : MapsTo (emlMap a c) (Icc L U) (Icc L U)) (x₀ : ℝ) (hx₀ : x₀ ∈ Icc L U) :
    ∃ xstar ∈ Icc L U,
      emlMap a c xstar = xstar ∧
      (∀ y ∈ Icc L U, emlMap a c y = y → y = xstar) ∧
      Tendsto (fun n => (emlMap a c)^[n] x₀) atTop (𝓝 xstar) ∧
      ∀ n : ℕ, dist ((emlMap a c)^[n] x₀) xstar ≤
        dist x₀ (emlMap a c x₀) * q ^ n / (1 - q) := by
  let F := hmap.restrict (emlMap a c) (Icc L U) (Icc L U)
  let X : Icc L U := ⟨x₀, hx₀⟩
  letI : Nonempty (Icc L U) := ⟨X⟩
  have hcontract := contracting_restrictedMap hpos hq0 hq1 hderiv hmap
  let Xstar := ContractingWith.fixedPoint F hcontract
  have hfix : F Xstar = Xstar := hcontract.fixedPoint_isFixedPt
  have hit (n : ℕ) : ((F^[n]) X).1 = ((emlMap a c)^[n]) x₀ := by
    rw [show F = hmap.restrict (emlMap a c) (Icc L U) (Icc L U) from rfl,
      MapsTo.iterate_restrict]
    rfl
  refine ⟨Xstar, Xstar.2, ?_, ?_, ?_, ?_⟩
  · exact congrArg Subtype.val hfix
  · intro y hy hyfix
    let Y : Icc L U := ⟨y, hy⟩
    have hY : F Y = Y := Subtype.ext hyfix
    exact congrArg Subtype.val (hcontract.fixedPoint_unique' hY hfix)
  · have ht := hcontract.tendsto_iterate_fixedPoint X
    have hv := continuous_subtype_val.continuousAt.tendsto.comp ht
    convert hv using 1
    funext n
    exact (hit n).symm
  · intro n
    have hb := hcontract.apriori_dist_iterate_fixedPoint_le X n
    rw [← hit n]
    exact hb

/-- `log 2` is a parameter in the proposed test range `(0,1)`. -/
theorem log_two_mem_open_unit : Real.log 2 ∈ Ioo (0 : ℝ) 1 := by
  constructor
  · exact Real.log_pos (by norm_num : (1 : ℝ) < 2)
  · have : (2 : ℝ) < Real.exp 1 := by
      have := Real.exp_one_gt_d9
      norm_num1 at this ⊢
      linarith
    rwa [Real.log_lt_iff_lt_exp (by norm_num : (0 : ℝ) < 2)]

/-- A tangent-line estimate showing that the proposed test case can fail. -/
theorem no_fixedPoint_log_two_half {x : ℝ} (hdomain : 0 < x + (1 / 2 : ℝ)) :
    emlMap (Real.log 2) (1 / 2) x ≠ x := by
  unfold emlMap
  rw [Real.exp_log (by norm_num : (2 : ℝ) > 0)]
  intro heq
  -- heq : 2 * log (x + 1/2) = x
  have hexp : x + 1/2 = Real.exp (x/2) := by
    have h1 : log (x + 1/2) = x/2 := by linarith
    rw [← h1, Real.exp_log hdomain]
  -- Let y = x/2, so exp(y) = 2y + 1/2
  set y := x / 2 with hy_def
  have hexp_y : Real.exp y = 2 * y + 1/2 := by
    have : x = 2 * y := by ring
    linarith
  -- Key lemma: exp(y) ≥ 2y + 2(1 - log 2) for all y (tangent line at y = log 2)
  have htangent : ∀ z : ℝ, Real.exp z ≥ 2 * z + 2 * (1 - Real.log 2) := by
    intro z
    -- exp(z) = 2 * exp(z - log 2) ≥ 2 * (1 + (z - log 2)) = 2z + 2 - 2*log 2
    have h := Real.add_one_le_exp (z - Real.log 2)
    calc Real.exp z = Real.exp (z - Real.log 2 + Real.log 2) := by ring_nf
      _ = Real.exp (z - Real.log 2) * Real.exp (Real.log 2) := by rw [Real.exp_add]
      _ = Real.exp (z - Real.log 2) * 2 := by rw [Real.exp_log (by norm_num : (2 : ℝ) > 0)]
      _ ≥ (1 + (z - Real.log 2)) * 2 := by nlinarith
      _ = 2 * z + 2 - 2 * Real.log 2 := by ring
      _ = 2 * z + 2 * (1 - Real.log 2) := by ring
  -- Now 2(1 - log 2) > 1/2 since log 2 < 3/4
  have h_bound : 2 * (1 - Real.log 2) > 1/2 := by
    have : Real.log 2 < 3/4 := Real.log_two_lt_d9.trans_le (by norm_num : (0.6931471808 : ℝ) ≤ 3/4)
    linarith
  have hcontra : Real.exp y > 2 * y + 1/2 := by linarith [htangent y]
  linarith

/-- Counterexample to the assertion that every `0<a<1`, `0<c<1` test case
has a fixed point on the natural domain. -/
theorem proposed_test_range_counterexample :
    ∃ a c : ℝ, a ∈ Ioo (0 : ℝ) 1 ∧ c ∈ Ioo (0 : ℝ) 1 ∧
      ∀ x : ℝ, 0 < x + c → emlMap a c x ≠ x := by
  refine ⟨Real.log 2, 1 / 2, log_two_mem_open_unit, ?_, ?_⟩
  · constructor <;> norm_num
  · intro x hx
    exact no_fixedPoint_log_two_half hx

end EMLFixedPoint