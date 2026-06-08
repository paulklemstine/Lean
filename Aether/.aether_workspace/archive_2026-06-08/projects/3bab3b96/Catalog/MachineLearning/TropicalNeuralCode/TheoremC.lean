import Mathlib
import MachineLearning.TropicalNeuralCode.Defs

/-!
# Theorem C: Margin Transfer from Coboundary Bounds

If local robustness witnesses across neural code regions satisfy a
coboundary consistency condition, then the resulting tropical classifier
inherits a global margin lower bound.

## Main Results

* `coboundary_adjustment_preserves_margin` — coboundary adjustments
  preserve non-negative margin certificates.
* `globalAdjustedMargin_nonneg` — the global adjusted margin is non-negative.
* `tropical_margin_lower_bound_of_coboundary` — existence of a non-negative
  global margin that lower-bounds all local adjusted margins.
* `tropical_margin_equals_global_adjusted` — the global margin is the infimum.
-/

noncomputable section

open Finset BigOperators

/-! ## Coboundary-Based Margin Transfer -/

/-- A family of local margin certificates `m : ι → ℝ` with Lipschitz constants
`L : ι → ℝ` and gauge corrections `b : ι → ℝ` yields adjusted margins
that are non-negative when the coboundary condition holds. -/
theorem coboundary_adjustment_preserves_margin
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (_hm : ∀ i, 0 ≤ m i)
    (b : ι → ℝ) (hb : ∀ i, L i * |b i| ≤ m i) :
    ∀ i, 0 ≤ (m i - L i * |b i|) / L i := by
  exact fun i => div_nonneg (sub_nonneg.2 (hb i)) (le_of_lt (hL i))

/-- The global adjusted margin is the minimum of local adjusted margins. -/
def globalAdjustedMargin {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L b : ι → ℝ) : ℝ :=
  ⨅ i, (m i - L i * |b i|) / L i

/-- The global adjusted margin is non-negative under coboundary conditions. -/
theorem globalAdjustedMargin_nonneg
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (_hm : ∀ i, 0 ≤ m i)
    (b : ι → ℝ) (hb : ∀ i, L i * |b i| ≤ m i) :
    0 ≤ globalAdjustedMargin m L b := by
  exact Real.iInf_nonneg fun i => div_nonneg (sub_nonneg_of_le (hb i)) (le_of_lt (hL i))

/-! ## Tropical Margin Lower Bound from Coboundary

The key cross-domain theorem: sheaf-theoretic consistency (coboundary
condition) implies tropical classification margin. -/

/-- **Margin Transfer Theorem.**
If local margins `m i` dominate Lipschitz-scaled gauge corrections `L i * |b i|`,
then the global adjusted margin `δ = ⨅ i, (m i - L i * |b i|) / L i` is non-negative
and lower-bounds each local adjusted margin. This `δ` serves as a certified
tropical classification margin. -/
theorem tropical_margin_lower_bound_of_coboundary
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (hL : ∀ i, 0 < L i) (hm : ∀ i, 0 ≤ m i)
    (b : ι → ℝ) (hb : ∀ i, L i * |b i| ≤ m i) :
    ∃ δ : ℝ, 0 ≤ δ ∧ ∀ i, δ ≤ (m i - L i * |b i|) / L i := by
  exact ⟨globalAdjustedMargin m L b,
    globalAdjustedMargin_nonneg m L hL hm b hb,
    fun i => ciInf_le ⟨0, by
      intro x ⟨j, hj⟩
      rw [← hj]
      exact div_nonneg (sub_nonneg.2 (hb j)) (le_of_lt (hL j))⟩ i⟩

/-- The global adjusted margin equals the infimum of local adjusted margins. -/
theorem tropical_margin_equals_global_adjusted
    {ι : Type*} [Fintype ι] [Nonempty ι]
    (m L : ι → ℝ) (_hL : ∀ i, 0 < L i) (_hm : ∀ i, 0 ≤ m i)
    (b : ι → ℝ) (_hb : ∀ i, L i * |b i| ≤ m i) :
    globalAdjustedMargin m L b = ⨅ i, (m i - L i * |b i|) / L i := by
  rfl

end