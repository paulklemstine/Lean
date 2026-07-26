/-
# Binary Search Threshold for Global Minimizers

This file formalizes a **phase transition theorem** for marking-bonus perturbations
over finite search spaces. Given a finite type `O`, a cost function `cost : O → ℝ`,
and a marking predicate `marked : O → Prop`, we define the β-perturbed objective

    F_β(x) := cost(x) - β · 𝟙_{marked(x)}

and prove that there is a sharp threshold `Δ = markedMin - globalMin` such that:
- For β < Δ, every minimizer of F_β is unmarked.
- For β > Δ, every minimizer of F_β is marked.
- At β = Δ, both marked and unmarked minimizers coexist.

This is a formal **bifurcation theorem** with applications in optimization,
tropical geometry (wall-crossing), statistical mechanics (phase transitions),
and certified search (binary search on the bonus parameter).

## Cross-domain connections

- **Tropical geometry**: The threshold Δ is the intersection of two tropical
  affine branches: the unmarked branch (constant in β) and the marked branch
  (slope -1). This is a wall-crossing event.

- **Statistical mechanics**: β acts as an external field; the theorem formalizes
  a zero-temperature phase transition in a finite energy landscape.

- **Machine learning / reward shaping**: A reward bonus changes the optimizer
  exactly when the bonus exceeds the value gap.

- **Certified search**: Binary search on β recovers the marked optimum value
  without solving a constrained optimization problem each time.
-/

import Mathlib

open Classical

/-! ## Core definitions -/

/-- The β-perturbed objective: `cost(x) - β` if `x` is marked, `cost(x)` otherwise. -/
noncomputable def bonusObj {O : Type*} [Fintype O] (cost : O → ℝ) (marked : O → Prop)
    [DecidablePred marked] (β : ℝ) (x : O) : ℝ :=
  cost x - if marked x then β else 0

/-- A point `x` is a global minimizer of `f` if `f(x) ≤ f(y)` for all `y`. -/
def IsGlobalMin {O : Type*} (f : O → ℝ) (x : O) : Prop :=
  ∀ y, f x ≤ f y

/-- The gap between the best marked point and the global minimum. -/
noncomputable def gapFromWitnesses {O : Type*}
    (cost : O → ℝ) (x₀ xm : O) : ℝ :=
  cost xm - cost x₀

/-! ## Helper lemmas about bonusObj -/

@[simp]
theorem bonusObj_of_marked {O : Type*} [Fintype O] {cost : O → ℝ} {marked : O → Prop}
    [DecidablePred marked] {β : ℝ} {x : O} (hx : marked x) :
    bonusObj cost marked β x = cost x - β := by
  simp [bonusObj, hx]

@[simp]
theorem bonusObj_of_unmarked {O : Type*} [Fintype O] {cost : O → ℝ} {marked : O → Prop}
    [DecidablePred marked] {β : ℝ} {x : O} (hx : ¬ marked x) :
    bonusObj cost marked β x = cost x := by
  simp [bonusObj, hx]

/-! ## Existence of minimizers -/

/-
Every nonempty finite type has a global minimizer for any real-valued function.
-/
theorem exists_global_minimizer
    {O : Type*} [Fintype O] [Nonempty O]
    (cost : O → ℝ) :
    ∃ x : O, IsGlobalMin cost x := by
  obtain ⟨ x, hx ⟩ := Finset.exists_min_image Finset.univ ( fun x => cost x ) ( Finset.univ_nonempty ) ; use x ; aesop;

/-
Among marked points, there exists a cost-minimizing one.
-/
theorem exists_marked_minimizer
    {O : Type*} [Fintype O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    (hmarked : ∃ x : O, marked x) :
    ∃ x : O, marked x ∧ ∀ y : O, marked y → cost x ≤ cost y := by
  -- Apply exists_min_image to the filter of marked elements.
  have h_min : ∃ x ∈ Finset.filter marked Finset.univ, ∀ y ∈ Finset.filter marked Finset.univ, cost x ≤ cost y := by
    exact Finset.exists_min_image _ _ ⟨ hmarked.choose, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, hmarked.choose_spec ⟩ ⟩;
  grind +splitImp

/-! ## Main threshold theorem -/

/-
**Main Threshold Theorem (strict phases).**
Given a global minimizer `x₀` and a marked minimizer `xm`, the gap `Δ = cost(xm) - cost(x₀)`
is the critical threshold:
- For β < Δ, every minimizer of the perturbed objective is unmarked.
- For β > Δ, every minimizer of the perturbed objective is marked.
-/
theorem threshold_from_min_witnesses
    {O : Type*} [Fintype O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    {x₀ xm : O}
    (hx₀ : IsGlobalMin cost x₀)
    (hx₀_unmarked : ¬ marked x₀)
    (hxm : marked xm ∧ ∀ y : O, marked y → cost xm ≤ cost y) :
    (∀ {β : ℝ}, β < cost xm - cost x₀ → ∀ z : O, IsGlobalMin (bonusObj cost marked β) z → ¬ marked z) ∧
    (∀ {β : ℝ}, β > cost xm - cost x₀ → ∀ z : O, IsGlobalMin (bonusObj cost marked β) z → marked z) := by
  constructor;
  · intro β hβ z hz hz';
    have := hz x₀; simp_all +decide [ bonusObj ] ;
    linarith [ hxm.2 z hz' ];
  · intro β hβ z hz; have := hz x₀; have := hz xm; simp_all +decide [ IsGlobalMin, bonusObj ] ;
    grind

/-! ## Bifurcation at the critical value -/

/-
At the critical value `Δ = cost(xm) - cost(x₀)`, the perturbed objectives
of `x₀` (unmarked) and `xm` (marked) are tied.
-/
theorem threshold_tie_at_critical_value
    {O : Type*} [Fintype O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    {x₀ xm : O}
    (_hx₀ : IsGlobalMin cost x₀)
    (hx₀_unmarked : ¬ marked x₀)
    (hxm : marked xm ∧ ∀ y : O, marked y → cost xm ≤ cost y) :
    bonusObj cost marked (cost xm - cost x₀) x₀ = bonusObj cost marked (cost xm - cost x₀) xm := by
  unfold bonusObj; aesop;

/-
At the critical value, both `x₀` and `xm` are global minimizers of the perturbed objective.
This is the **bifurcation theorem**: marked and unmarked minimizers coexist at the threshold.
-/
theorem threshold_tie_yields_both_types_of_minimizers
    {O : Type*} [Fintype O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    {x₀ xm : O}
    (hx₀ : IsGlobalMin cost x₀)
    (hx₀_unmarked : ¬ marked x₀)
    (hxm : marked xm ∧ ∀ y : O, marked y → cost xm ≤ cost y) :
    IsGlobalMin (bonusObj cost marked (cost xm - cost x₀)) x₀ ∧
    IsGlobalMin (bonusObj cost marked (cost xm - cost x₀)) xm := by
  constructor <;> intro y <;> unfold bonusObj <;> split_ifs <;> simp_all +decide [ IsGlobalMin ];
  · linarith [ hx₀ y, hxm.2 y ‹_› ];
  · linarith [ hx₀ y, hxm y ‹_› ]

/-! ## Monotonicity of "all minimizers are marked" -/

/-
The predicate "every minimizer of F_β is marked" is monotone in β:
if it holds at β, it holds for all γ ≥ β.
-/
theorem allMinimizersMarked_monotone
    {O : Type*} [Fintype O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    {β γ : ℝ} (hβγ : β ≤ γ)
    (hβ : ∀ z : O, IsGlobalMin (bonusObj cost marked β) z → marked z) :
    ∀ z : O, IsGlobalMin (bonusObj cost marked γ) z → marked z := by
  intro z hz;
  contrapose! hβ;
  refine' ⟨ z, _, hβ ⟩;
  intro w; have := hz w; unfold bonusObj at *; split_ifs at * ; linarith;
  linarith

/-! ## Existential threshold theorem -/

/-
**Existential Threshold Theorem.**
Under the assumption that there exist marked points and an unmarked global minimizer,
there exists a critical threshold `Δ ≥ 0` with the strict phase separation property.
-/
theorem exists_threshold_interval
    {O : Type*} [Fintype O] [Nonempty O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    (hmarked : ∃ x : O, marked x)
    (hunmarkedGlobal : ∃ x : O, IsGlobalMin cost x ∧ ¬ marked x) :
    ∃ Δ : ℝ, Δ ≥ 0 ∧
      (∀ β < Δ, ∀ z, IsGlobalMin (bonusObj cost marked β) z → ¬ marked z) ∧
      (∀ β > Δ, ∀ z, IsGlobalMin (bonusObj cost marked β) z → marked z) ∧
      (∃ z₁ z₂, IsGlobalMin (bonusObj cost marked Δ) z₁ ∧ ¬ marked z₁ ∧
                 IsGlobalMin (bonusObj cost marked Δ) z₂ ∧ marked z₂) := by
  -- Use `exists_marked_minimizer` with `hmarked` to get `xm` with `marked xm` and minimality.
  obtain ⟨xm, hxm⟩ : ∃ x : O, marked x ∧ ∀ y : O, marked y → cost x ≤ cost y := by
    exact exists_marked_minimizer cost marked hmarked;
  -- Use `hunmarkedGlobal` to get `x₀` with `IsGlobalMin cost x₀` and `¬ marked x₀`.
  obtain ⟨x₀, hx₀, hx₀_unmarked⟩ : ∃ x : O, IsGlobalMin cost x ∧ ¬marked x := by
    exact hunmarkedGlobal;
  refine' ⟨ cost xm - cost x₀, sub_nonneg.2 ( hx₀ xm ), _, _, _ ⟩;
  · exact fun β hβ z hz hz' => threshold_from_min_witnesses cost marked hx₀ hx₀_unmarked hxm |>.1 hβ z hz hz';
  · exact fun β hβ z hz => threshold_from_min_witnesses cost marked hx₀ hx₀_unmarked hxm |>.2 hβ z hz;
  · exact ⟨ x₀, xm, by exact ( threshold_tie_yields_both_types_of_minimizers cost marked hx₀ hx₀_unmarked hxm ) |>.1, hx₀_unmarked, by exact ( threshold_tie_yields_both_types_of_minimizers cost marked hx₀ hx₀_unmarked hxm ) |>.2, hxm.1 ⟩

/-! ## Tropical decomposition identity -/

/-
The global minimum of the perturbed objective decomposes as the minimum of
the unmarked minimum and the marked minimum minus β.
This is the **tropical normal form**: two affine branches in β.
-/
theorem inf_bonusObj_decomposition
    {O : Type*} [Fintype O] [Nonempty O]
    (cost : O → ℝ) (marked : O → Prop) [DecidablePred marked]
    (_hmarked : ∃ x : O, marked x)
    (_hunmarked : ∃ x : O, ¬ marked x)
    (β : ℝ)
    {x₀ : O} (hx₀ : IsGlobalMin cost x₀) (hx₀u : ¬ marked x₀)
    {xm : O} (hxm_m : marked xm) (hxm_min : ∀ y : O, marked y → cost xm ≤ cost y)
    {z : O} (hz : IsGlobalMin (bonusObj cost marked β) z) :
    bonusObj cost marked β z = min (cost x₀) (cost xm - β) := by
  refine' le_antisymm _ _;
  · refine' le_min _ _;
    · exact le_trans ( hz x₀ ) ( by unfold bonusObj; aesop );
    · exact le_trans ( hz xm ) ( by unfold bonusObj; aesop );
  · unfold bonusObj;
    split_ifs <;> simp_all +decide [ IsGlobalMin ]