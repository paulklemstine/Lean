/-
Copyright (c) 2025 Tropical Closure Coding Theory. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Closure Coding Theory — Helly Separation and Unique Decoding

This file establishes the Helly-separation theory for closure codes and proves
the unique bounded-distance decoding theorem.

## Main Results

* `symmRepairCost_comm` — Symmetric repair cost is symmetric.
* `symmRepairCost_eq_zero_iff` — Zero cost iff equal sets (positive weights).
* `unique_nearest_closed_superset` — Closure is the unique minimal closed superset.
* `unique_decoding_insertion_model` — **Theorem D**: Unique decoding in insertion model.
* `certified_decoding` — Syndrome certifies the decoding.
-/

import Mathlib
import Logic.BasicMonotoneCircuit.Basic
import Bridges.Decoder
open Classical in
noncomputable section

universe u

variable {α : Type u} [DecidableEq α] [Fintype α]

/-- Symmetric repair cost (Hamming-style weighted distance):
    the weighted symmetric difference between two sets. -/
noncomputable def symmRepairCost (w : α → ℕ) (x y : Set α) : ℕ :=
  ∑ a : α, if (a ∈ x ∧ a ∉ y) ∨ (a ∈ y ∧ a ∉ x) then w a else 0

/-- The symmetric repair cost is symmetric. -/
theorem symmRepairCost_comm (w : α → ℕ) (x y : Set α) :
    symmRepairCost w x y = symmRepairCost w y x := by
  unfold symmRepairCost
  congr 1; ext a; congr 1; exact propext (by tauto)

/-
Symmetric repair cost is zero iff the sets are equal (for positive weights).
-/
theorem symmRepairCost_eq_zero_iff (w : α → ℕ) (hw : StrictlyPositiveWeight w)
    (x y : Set α) :
    symmRepairCost w x y = 0 ↔ x = y := by
      refine' ⟨ fun h => _, fun h => _ ⟩;
      · unfold symmRepairCost at h;
        simp_all +decide [ Finset.ext_iff, StrictlyPositiveWeight ];
        grind;
      · unfold symmRepairCost; aesop;

/-
The insertion-only repair cost is bounded by the symmetric cost when y ⊇ x.
-/
theorem repairCost_le_symmRepairCost (w : α → ℕ) (x y : Set α) (hxy : x ⊆ y) :
    repairCost w x y ≤ symmRepairCost w x y := by
      exact Finset.sum_le_sum fun a _ => by aesop;

/-- **Unique Nearest Closed Superset:**
    cl(x) is the UNIQUE closed set that is both a superset of x and
    minimal among all closed supersets. -/
theorem unique_nearest_closed_superset (C : ClosureCode α) (x : Set α)
    (y : Set α) (hy : C.IsClosed y) (hxy : x ⊆ y) (hmin : y ⊆ C.cl x) :
    y = C.cl x :=
  Set.Subset.antisymm hmin (C.cl_least_closed_superset x y hy hxy)

/-- The **separation regularity** condition. -/
structure SeparationRegular (C : ClosureCode α) (P : ClosurePresentation α) : Prop where
  separates : ∀ (x y : Set α), C.IsClosed x → C.IsClosed y → x ≠ y →
    ∃ imp ∈ P.implications,
      (imp.Satisfies x ∧ ¬imp.Satisfies y) ∨ (imp.Satisfies y ∧ ¬imp.Satisfies x)

/-- The **Helly property** for a family of closed sets. -/
structure HellyProperty (C : ClosureCode α) (d : ℕ) : Prop where
  helly : ∀ (F : Finset (Set α)),
    (∀ s ∈ F, C.IsClosed s) →
    (∀ G : Finset (Set α), G ⊆ F → G.card ≤ d →
      (⋂₀ (G : Set (Set α))).Nonempty) →
    (⋂₀ (F : Set (Set α))).Nonempty

/-- A closure code has the **intersection-closed property**. -/
structure IntersectionClosed (C : ClosureCode α) : Prop where
  inter_closed : ∀ (S : Set (Set α)),
    S.Nonempty → (∀ s ∈ S, C.IsClosed s) → C.IsClosed (⋂₀ S)

/-
**Theorem D (Unique Bounded-Distance Decoding — Insertion Model):**
    In the insertion-only model, any two cost-minimizing closed supersets
    must equal cl(x), hence must be equal to each other.
-/
theorem unique_decoding_insertion_model
    (C : ClosureCode α) (w : α → ℕ) (hw : StrictlyPositiveWeight w)
    (x : Set α)
    (y₁ y₂ : Set α)
    (hy₁ : C.IsClosed y₁) (hy₂ : C.IsClosed y₂)
    (hx₁ : x ⊆ y₁) (hx₂ : x ⊆ y₂)
    (hmin₁ : ∀ z, C.IsClosed z → x ⊆ z → repairCost w x y₁ ≤ repairCost w x z)
    (hmin₂ : ∀ z, C.IsClosed z → x ⊆ z → repairCost w x y₂ ≤ repairCost w x z) :
    y₁ = y₂ := by
  -- Both y₁ and y₂ contain cl(x), which is the least closed superset
  have hcl := C.cl_isClosed x
  have hxcl : x ⊆ C.cl x := C.subset_cl x
  have h1 : C.cl x ⊆ y₁ := C.cl_least_closed_superset x y₁ hy₁ hx₁
  have h2 : C.cl x ⊆ y₂ := C.cl_least_closed_superset x y₂ hy₂ hx₂
  -- cost(x→cl x) ≤ cost(x→y₁) by monotonicity (cl x ⊆ y₁)
  have hm1 : repairCost w x (C.cl x) ≤ repairCost w x y₁ :=
    repairCost_mono w x y₁ (C.cl x) hxcl h1
  -- cost(x→y₁) ≤ cost(x→cl x) by minimality of y₁
  have hr1 := hmin₁ (C.cl x) hcl hxcl
  -- So cost(x→y₁) = cost(x→cl x)
  have heq1 : repairCost w x y₁ = repairCost w x (C.cl x) := le_antisymm hr1 hm1
  -- Similarly for y₂
  have hm2 : repairCost w x (C.cl x) ≤ repairCost w x y₂ :=
    repairCost_mono w x y₂ (C.cl x) hxcl h2
  have hr2 := hmin₂ (C.cl x) hcl hxcl
  have heq2 : repairCost w x y₂ = repairCost w x (C.cl x) := le_antisymm hr2 hm2
  -- Equal cost + cl x ⊆ y₁ + positive weights ⇒ y₁ = cl x
  -- (If y₁ has any element not in cl x, the cost would be strictly higher)
  -- Since $y₁$ and $y₂$ are both closed supersets of $cl(x)$ and have equal repair costs, we must have $y₁ = cl(x)$ and $y₂ = cl(x)$.
  have hy1_eq : y₁ = C.cl x := by
    apply Set.eq_of_subset_of_subset;
    · contrapose! heq1;
      obtain ⟨ a, ha₁, ha₂ ⟩ := Set.not_subset.mp heq1;
      refine' ne_of_gt ( Finset.sum_lt_sum _ _ );
      · grind;
      · use a;
        split_ifs <;> simp_all +decide [ ne_of_gt ];
        · exact hw a;
        · exact ha₂ ( hxcl ‹_› );
    · assumption
  have hy2_eq : y₂ = C.cl x := by
    apply unique_nearest_closed_superset C x y₂ hy₂ hx₂;
    intro a ha;
    contrapose! heq2;
    refine' ne_of_gt ( Finset.sum_lt_sum _ _ );
    · grind;
    · exact ⟨ a, Finset.mem_univ _, by rw [ if_neg ( by aesop ), if_pos ⟨ ha, by rintro H; exact heq2 ( hxcl H ) ⟩ ] ; exact hw a ⟩;
  rw [hy1_eq, hy2_eq]

/-- **Certified Decoding Theorem:**
    The syndrome certifies the decoding. -/
theorem certified_decoding
    (C : ClosureCode α) (P : ClosurePresentation α)
    (hpres : PresentsClosure C P) (x : Set α) :
    (syndrome P x = 0 ↔ tropicalDecode C x = x) ∧
    syndrome P (tropicalDecode C x) = 0 := by
  constructor
  · constructor
    · intro h
      exact tropicalDecode_of_closed C ((closed_iff_zero_syndrome C P hpres x).mpr h)
    · intro h
      rw [← h]
      exact syndrome_tropicalDecode_eq_zero C P hpres x
  · exact syndrome_tropicalDecode_eq_zero C P hpres x

end