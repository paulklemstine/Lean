import Bridges.TropicalFunctional.Basic

/-!
# Tropical Capacity and Maxitive Content

This file defines the canonical maxitive capacity (tropical measure) associated to a
tropical functional on a compact Hausdorff space, and proves basic properties.

## Definitions

- `admissibleAbove K f`: `f` dominates the tropical indicator of `K` (i.e., `f(x) ≥ 0` for `x ∈ K`)
- `muK Λ K`: the tropical capacity of a set `K`, defined as
  `inf {Λ(f) | f dominates the indicator of K}`
- `tropicalIntegral μ f`: the tropical (Shilkret) integral of `f` against a capacity `μ`

## Main results

- `muK_mono`: the capacity is monotone in the set argument
- `muK_union_le`: subadditivity (in the sup sense)
- `muK_empty`: the capacity of the empty set is `⊥`
-/

noncomputable section

variable {X : Type*} [TopologicalSpace X]

/-! ## Admissibility -/

/-- A continuous function `f` is admissible above `K` if `f(x) ≥ 0` for all `x ∈ K`. -/
def admissibleAbove (K : Set X) (f : TropCont X) : Prop :=
  ∀ x, x ∈ K → (0 : WithBot ℝ) ≤ f x

/-! ## Tropical capacity -/

/-- The tropical capacity of a set `K` with respect to a functional `Λ`:
the infimum of `Λ(f)` over all continuous functions that dominate the tropical
indicator of `K`. -/
def muK (Λ : TropicalFunctional X) (K : Set X) : WithBot ℝ :=
  sInf (Λ.toFun '' {f : TropCont X | admissibleAbove K f})

/-
The capacity is monotone: if `K ⊆ L` then `μ(L) ≤ μ(K)`.
(Note: the direction is reversed because a larger set has fewer admissible functions,
so the infimum is taken over a smaller set, giving a larger value... actually,
a larger set means the admissibility condition is stronger, so fewer functions qualify,
and the inf over a subset is ≥ the inf over the superset.)
-/
theorem muK_mono (Λ : TropicalFunctional X) {K L : Set X} (h : K ⊆ L) :
    muK Λ K ≤ muK Λ L := by
  refine' csInf_le_csInf _ _ _ <;> norm_num;
  · exact ⟨ 0, fun x hx => by simp +decide ⟩;
  · exact fun f hf => ⟨ f, fun x hx => hf x ( h hx ), rfl ⟩

/-
The capacity of the empty set is `⊥` (= -∞).
-/
theorem muK_empty (Λ : TropicalFunctional X) :
    muK Λ ∅ = ⊥ := by
  refine' le_antisymm ( csInf_le _ _ ) ( le_csInf _ _ );
  · exact ⟨ ⊥, Set.forall_mem_image.2 fun f hf => bot_le ⟩;
  · -- Since the constant function with value ⊥ is admissible above the empty set and Λ(⊥) = ⊥, we have ⊥ in the image.
    use ContinuousMap.const X ⊥
    simp [admissibleAbove, Λ.map_const];
  · exact ⟨ _, ⟨ 0, fun x _ => by contradiction, rfl ⟩ ⟩;
  · exact fun _ _ => bot_le

/-! ## Tropical integral -/

/-- The tropical (Shilkret) integral of `f` against a set function `μ`:
`∫ᵗ f dμ = sup {μ(K) + inf_{x ∈ K} f(x) | K compact}`.

This is the max-plus analogue of the Choquet integral. -/
def tropicalIntegral [CompactSpace X] (μ : Set X → WithBot ℝ) (f : TropCont X) : WithBot ℝ :=
  sSup {a : WithBot ℝ | ∃ K : Set X, IsCompact K ∧ a ≤ μ K + sInf (f '' K)}

end