/-
# Tropical Entropy Loss and the Shannon–Tropical Bridge

This file defines tropical entropy loss (worst-case fiber log-cardinality) and
proves the fundamental inequality between Shannon and tropical entropy loss,
with equality for constant-fiber maps including linear maps over finite fields.

## Main Results

* `tropicalEntropyLoss` — definition: `log(max fiber size)`
* `entropyDefect_le_tropicalEntropyLoss` — Shannon ≤ tropical for any finite map
* `entropyDefect_eq_tropicalEntropyLoss_of_constant_fiber` — equality when all
  fibers have the same size
* `tropicalEntropyLoss_linearMap_eq` — for linear maps, tropical loss equals
  `finrank(ker A) * log|K|`

## Mathematical Significance

Linear maps over finite fields are exactly the regime where Shannon and tropical
entropy coincide: average-case and worst-case information loss are identical.
This unifies classical and tropical information theory for linear computation.
-/

import Mathlib
import Speculative.RankEntropy

open Real Set Fintype Module Finset

noncomputable section

/-! ## Tropical Entropy Loss -/

/-- The maximum fiber cardinality of a function `f : α → β`. -/
noncomputable def maxFiberCard {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (f : α → β) : ℕ :=
  Finset.univ.sup (fun y => (Finset.univ.filter (fun x => f x = y)).card)

/-- **Tropical entropy loss** of a function `f : α → β`: the logarithm of the
    maximum fiber cardinality. This is the worst-case information loss. -/
noncomputable def tropicalEntropyLoss
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (f : α → β) : ℝ :=
  Real.log (maxFiberCard f)

/-! ## Average Fiber Size -/

/-
For a surjection onto its range, the average fiber size is |α| / |range f|.
    For any function, the average fiber size (over the image) satisfies
    average ≤ max.
-/
theorem avg_fiber_le_max_fiber
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    (f : α → β) :
    (Fintype.card α : ℝ) / (Fintype.card (Set.range f) : ℝ) ≤ (maxFiberCard f : ℝ) := by
  by_cases h : Set.range f = ∅ <;> simp_all +decide [ Fintype.card_subtype ];
  -- The sum of fiber sizes over the image equals the domain size.
  have h_sum_fiber : ∑ y ∈ Finset.image f Finset.univ, (Finset.univ.filter fun x => f x = y).card = Fintype.card α := by
    simp +decide only [card_filter];
    rw [ Finset.sum_comm ] ; simp +decide;
  rw [ div_le_iff₀ ] <;> norm_cast;
  · rw [ ← h_sum_fiber, mul_comm ];
    exact Finset.sum_le_card_nsmul _ _ _ fun x hx => Finset.le_sup ( f := fun y => ( Finset.univ.filter fun z => f z = y ).card ) ( Finset.mem_univ x );
  · exact Finset.card_pos.mpr ⟨ f h.some, Finset.mem_image_of_mem _ ( Finset.mem_univ _ ) ⟩

/-! ## Shannon ≤ Tropical -/

/-
**Shannon ≤ Tropical inequality.**
    For uniform input, Shannon entropy loss ≤ tropical entropy loss.
    This holds because the average fiber size ≤ max fiber size,
    and Shannon loss = log(average fiber) while tropical = log(max fiber).
-/
theorem entropyDefect_le_tropicalEntropyLoss
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    [Nonempty α]
    (f : α → β) :
    entropyDefectFn f ≤ tropicalEntropyLoss f := by
  -- Apply the real logarithm to both sides of the inequality from avg_fiber_le_max_fiber.
  have h_log : Real.log ((Fintype.card α : ℝ) / (Fintype.card (Set.range f) : ℝ)) ≤ Real.log (maxFiberCard f) := by
    exact Real.log_le_log ( div_pos ( Nat.cast_pos.mpr ( Fintype.card_pos ) ) ( Nat.cast_pos.mpr ( Fintype.card_pos_iff.mpr ⟨ _, Set.mem_range_self ( Classical.arbitrary α ) ⟩ ) ) ) ( mod_cast avg_fiber_le_max_fiber f );
  rwa [ Real.log_div ( Nat.cast_ne_zero.mpr Fintype.card_ne_zero ) ( Nat.cast_ne_zero.mpr ( Fintype.card_ne_zero ) ) ] at h_log

/-! ## Equality for Constant-Fiber Maps -/

/-- A map has **constant fibers** if all nonempty fibers have the same cardinality. -/
def HasConstantFibers {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]
    (f : α → β) : Prop :=
  ∀ y₁ y₂ : β, y₁ ∈ Set.range f → y₂ ∈ Set.range f →
    (Finset.univ.filter (fun x => f x = y₁)).card =
    (Finset.univ.filter (fun x => f x = y₂)).card

/-
For constant-fiber maps, Shannon entropy loss equals tropical entropy loss.
-/
theorem entropyDefect_eq_tropicalEntropyLoss_of_constant_fiber
    {α β : Type*} [Fintype α] [Fintype β] [DecidableEq α] [DecidableEq β]
    [Nonempty α]
    (f : α → β) (hf : HasConstantFibers f) :
    entropyDefectFn f = tropicalEntropyLoss f := by
  -- By definition of constant fibers, all nonempty fibers have the same cardinality.
  obtain ⟨c, hc⟩ : ∃ c, ∀ y ∈ Set.range f, (Finset.univ.filter (fun x => f x = y)).card = c := by
    exact ⟨ _, fun y hy => hf y _ hy ( Set.mem_range_self ( Classical.arbitrary α ) ) ⟩;
  -- By definition of constant fibers, we have that the cardinality of the domain is equal to the cardinality of the range times the cardinality of each fiber.
  have h_card_domain : Fintype.card α = Fintype.card (Set.range f) * c := by
    have h_card_domain : Fintype.card α = ∑ y ∈ Finset.image f Finset.univ, (Finset.univ.filter (fun x => f x = y)).card := by
      rw [ Finset.sum_image' ];
      rotate_left;
      exacts [ fun _ => 1, fun _ _ => by simp +decide, by simp +decide ];
    rw [ h_card_domain, Finset.sum_congr rfl fun y hy => hc y <| Finset.mem_image.mp hy |> fun ⟨ x, _, hx ⟩ => hx ▸ Set.mem_range_self x ] ; simp +decide [ Fintype.card_subtype ];
  have h_tropical : tropicalEntropyLoss f = Real.log c := by
    refine' congr_arg Real.log ( mod_cast le_antisymm _ _ );
    · refine' Finset.sup_le _;
      intro y hy; by_cases hy' : y ∈ Set.range f <;> aesop;
    · obtain ⟨ y, hy ⟩ := Set.range_nonempty f;
      exact hc y hy ▸ Finset.le_sup ( f := fun y => Finset.card ( Finset.filter ( fun x => f x = y ) Finset.univ ) ) ( Finset.mem_univ y );
  unfold entropyDefectFn;
  rw [ h_tropical, h_card_domain, Nat.cast_mul, Real.log_mul ] <;> norm_cast <;> aesop

/-! ## Linear Maps Have Constant Fibers -/

/-
Linear maps over finite fields have constant fibers.
-/
theorem linearMap_hasConstantFibers
    (K V W : Type*) [Field K] [Fintype K] [DecidableEq K]
    [AddCommGroup V] [Module K V] [Fintype V] [DecidableEq V]
    [AddCommGroup W] [Module K W] [Fintype W] [DecidableEq W]
    (A : V →ₗ[K] W) :
    HasConstantFibers (A : V → W) := by
  intro y₁ y₂ hy₁ hy₂
  exact AddMonoidHom.card_fiber_eq_of_mem_range A hy₁ hy₂

/-! ## Tropical Loss for Linear Maps -/

/-
For linear maps over finite fields, tropical entropy loss equals
    `finrank(ker A) * log|K|`. Combined with `entropyDefect_linearMap_eq`,
    this shows Shannon = tropical for linear maps.
-/
theorem tropicalEntropyLoss_linearMap_eq
    (K V W : Type*) [Field K] [Fintype K] [DecidableEq K]
    [AddCommGroup V] [Module K V] [FiniteDimensional K V] [Fintype V] [DecidableEq V]
    [AddCommGroup W] [Module K W] [FiniteDimensional K W] [Fintype W] [DecidableEq W]
    (A : V →ₗ[K] W) :
    tropicalEntropyLoss (A : V → W) =
      (Module.finrank K A.ker : ℝ) * Real.log (Fintype.card K) := by
  rw [ ← entropyDefect_linearMap_eq ];
  -- Apply the theorem that states the equality for constant-fiber maps.
  apply Eq.symm; exact entropyDefect_eq_tropicalEntropyLoss_of_constant_fiber A (linearMap_hasConstantFibers K V W A)

/-! ## Shannon = Tropical for Linear Maps -/

/-- **Shannon–Tropical Equality for Linear Maps.**
    For linear maps over finite fields, Shannon and tropical entropy loss coincide. -/
theorem shannon_eq_tropical_linearMap
    (K V W : Type*) [Field K] [Fintype K] [DecidableEq K]
    [AddCommGroup V] [Module K V] [FiniteDimensional K V] [Fintype V] [DecidableEq V]
    [AddCommGroup W] [Module K W] [FiniteDimensional K W] [Fintype W] [DecidableEq W]
    (A : V →ₗ[K] W) :
    entropyDefectFn (A : V → W) = tropicalEntropyLoss (A : V → W) := by
  rw [entropyDefect_linearMap_eq K V W A, tropicalEntropyLoss_linearMap_eq K V W A]

end