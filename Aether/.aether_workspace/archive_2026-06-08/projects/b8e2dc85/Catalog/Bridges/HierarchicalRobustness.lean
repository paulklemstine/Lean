/-
# Compositional Robustness for Hierarchical Decision Trees

This module formalizes compositional robustness theorems for hierarchical classifiers
built from binary decision trees. The key insight is that local margin certificates
along a root-to-leaf path compose into a global robustness guarantee.

## Main Results

- `hierarchical_robust_of_path_margins`: Local sign-preservation along a decision path
- `hierarchical_classifier_constant_on_ball`: Classifier invariance on a metric ball
- `robustness_of_radius_lt_path_certificate`: Explicit radius certificate via `Finset.inf'`
- `hierarchical_robust_of_summed_losses`: Additive perturbation budget variant

## Mathematical Context

In the GL3 tropical Satake robustness program, flat decoders (argmax, top-k, ECOC)
yield one-shot multiclass margin statements. Hierarchical trees introduce genuinely
new mathematics: robustness becomes a *pathwise composition* of local tropical margin
certificates. This module proves the fundamental composition principle.
-/
import Mathlib

open Finset

variable {α ι γ : Type*} [MetricSpace α]

/-! ## Local Margin Definition -/

/-- The local chosen-vs-other margin at node `v`.
If the clean input goes right at `v`, the margin is `SR v x - SL v x`;
if it goes left, the margin is `SL v x - SR v x`.
A positive margin means the clean decision is strictly preferred. -/
def localMargin (goRight : ι → Bool) (SL SR : ι → α → ℝ) (v : ι) (x : α) : ℝ :=
  if goRight v then SR v x - SL v x else SL v x - SR v x

/-! ## Core Sign-Preservation Lemma -/

/-- **Path margin preservation theorem.**
If each score difference `SR v - SL v` is Lipschitz with constant `K v`,
and the clean margin at each node exceeds `2 * K v * r`,
then every local binary decision on the clean path remains unchanged
throughout the radius-`r` ball around `x`. -/
theorem hierarchical_robust_of_path_margins
    {path : List ι}
    (SL SR : ι → α → ℝ)
    (goRight : ι → Bool)
    (K : ι → ℝ)
    (x : α) (r : ℝ)
    (hK : ∀ v ∈ path, 0 ≤ K v)
    (hLip :
      ∀ v ∈ path, ∀ y z : α,
        |((SR v y - SL v y) - (SR v z - SL v z))| ≤ K v * dist y z)
    (hmargin :
      ∀ v ∈ path, 2 * K v * r < localMargin goRight SL SR v x) :
    ∀ y : α, dist y x ≤ r →
      ∀ v ∈ path,
        0 < localMargin goRight SL SR v y := by
  intros y hy v hv
  by_cases hgoRight : goRight v
  · unfold localMargin at *
    specialize hmargin v hv; specialize hLip v hv y x
    split_ifs at *; nlinarith [abs_le.mp hLip, hK v hv]
  · have := hLip v hv y x; unfold localMargin at *; simp_all +decide [abs_le]
    have := hmargin v hv; specialize hLip v hv y x
    norm_num [hgoRight] at this; nlinarith [hK v hv]

/-! ## Classifier Invariance -/

/-- **Hierarchical classifier invariance on a metric ball.**
If all local margins along the clean path are preserved (positive),
then the classifier output is constant on the ball of radius `r`. -/
theorem hierarchical_classifier_constant_on_ball
    {path : List ι}
    (SL SR : ι → α → ℝ)
    (goRight : ι → Bool)
    (K : ι → ℝ)
    (F : α → γ)
    (label : γ)
    (x : α) (r : ℝ)
    (hK : ∀ v ∈ path, 0 ≤ K v)
    (hLip :
      ∀ v ∈ path, ∀ y z : α,
        |((SR v y - SL v y) - (SR v z - SL v z))| ≤ K v * dist y z)
    (hmargin :
      ∀ v ∈ path, 2 * K v * r < localMargin goRight SL SR v x)
    (_hclean : F x = label)
    (hspec :
      ∀ y : α,
        (∀ v ∈ path, 0 < localMargin goRight SL SR v y) → F y = label) :
    ∀ y : α, dist y x ≤ r → F y = label := by
  exact fun y hy =>
    hspec y (hierarchical_robust_of_path_margins SL SR goRight K x r hK hLip hmargin y hy)

/-! ## Explicit Radius Certificate -/

/-- **Robustness certificate via minimum normalized margin.**
The certified robustness radius is the minimum over all nodes of
`localMargin v x / (2 * K v)`. Any perturbation within this radius
preserves the classifier output. -/
theorem robustness_of_radius_lt_path_certificate
    {s : Finset ι}
    (hsne : s.Nonempty)
    (SL SR : ι → α → ℝ)
    (goRight : ι → Bool)
    (K : ι → ℝ)
    (F : α → γ)
    (label : γ)
    (x : α) (r : ℝ)
    (hKpos : ∀ v ∈ s, 0 < K v)
    (hLip :
      ∀ v ∈ s, ∀ y z : α,
        |((SR v y - SL v y) - (SR v z - SL v z))| ≤ K v * dist y z)
    (_hclean : F x = label)
    (hspec :
      ∀ y : α,
        (∀ v ∈ s, 0 < localMargin goRight SL SR v y) → F y = label)
    (hr :
      r < s.inf' hsne (fun v => localMargin goRight SL SR v x / (2 * K v))) :
    ∀ y : α, dist y x ≤ r → F y = label := by
  intro y hy
  apply hspec
  intro v hv
  have hmargin : localMargin goRight SL SR v x > 2 * K v * r := by
    have hmargin : r < localMargin goRight SL SR v x / (2 * K v) :=
      hr.trans_le (Finset.inf'_le _ hv)
    rwa [lt_div_iff₀' (mul_pos zero_lt_two (hKpos v hv))] at hmargin
  unfold localMargin at *
  split_ifs at * <;> nlinarith [abs_le.mp (hLip v hv y x), hKpos v hv]

/-! ## Additive Perturbation Budget Variant -/

set_option linter.unusedSectionVars false in
/-- **Hierarchical robustness under summed loss budgets.**
Each node has its own perturbation loss bound. If every node's margin
exceeds the total loss scaled by its Lipschitz constant, the classifier
output is preserved for all inputs. -/
theorem hierarchical_robust_of_summed_losses
    {s : Finset ι}
    (Δ : ι → α → ℝ)
    (K : ι → ℝ)
    (F : α → γ)
    (label : γ)
    (x : α)
    (loss : ι → ℝ)
    (_hK : ∀ v ∈ s, 0 ≤ K v)
    (_hloss_nonneg : ∀ v ∈ s, 0 ≤ loss v)
    (hLip :
      ∀ v ∈ s, ∀ y : α,
        |Δ v y - Δ v x| ≤ K v * (∑ u ∈ s, loss u))
    (hmargin :
      ∀ v ∈ s, K v * (∑ u ∈ s, loss u) < Δ v x)
    (hspec :
      ∀ y : α, (∀ v ∈ s, 0 < Δ v y) → F y = label)
    (_hclean : F x = label) :
    ∀ y : α, F y = label := by
  intro y
  apply hspec
  intro v hv
  have h1 := hLip v hv y
  have h2 := hmargin v hv
  linarith [abs_le.mp h1]

/-! ## Helper: Margin Lipschitz from Aggregate Lipschitz -/

/-- If each score aggregate `SL v` and `SR v` is individually `L`-Lipschitz,
then the score difference `SR v - SL v` is `2L`-Lipschitz. -/
theorem margin_diff_lipschitz_of_aggregate_lipschitz
    (SL SR : α → ℝ) (L : ℝ)
    (hSL : ∀ y z : α, |SL y - SL z| ≤ L * dist y z)
    (hSR : ∀ y z : α, |SR y - SR z| ≤ L * dist y z) :
    ∀ y z : α, |((SR y - SL y) - (SR z - SL z))| ≤ 2 * L * dist y z := by
  exact fun y z => abs_le.mpr
    ⟨by linarith [abs_le.mp (hSL y z), abs_le.mp (hSR y z)],
     by linarith [abs_le.mp (hSL y z), abs_le.mp (hSR y z)]⟩

/-! ## Axiom verification -/
#print axioms hierarchical_robust_of_path_margins
#print axioms hierarchical_classifier_constant_on_ball
#print axioms robustness_of_radius_lt_path_certificate
#print axioms hierarchical_robust_of_summed_losses
#print axioms margin_diff_lipschitz_of_aggregate_lipschitz