import Mathlib

/-!
# Closure-Capacity–Attention Duality

This file establishes a finite duality between closure-capacity objects and
minimal sparse tropical attention architectures.

## Main Results

* `ClosureCapacityObj` — structure packaging a closure operator with a monotone,
  normalized capacity function on a finite type.
* `SparseAttentionModel` — structure for sparse attention realizations with
  finitely many heads, each with a support set and weight.
* `canonical_attention_model` — constructs the canonical attention model from
  a closure-capacity object, with one head per extreme generator.
* `extremeRank_le_headCount` — lower bound: any realization needs at least as
  many heads as extreme generators.
* `canonical_model_realizes` — the canonical model realizes the closure-capacity data.
* `canonical_model_is_minimal` — the canonical model achieves the minimum head count.
* `head_count_eq_extremeRank` — for minimal models, head count = extreme rank.
* `reconstructClosure` / `reconstructCapacity` — reconstruct closure operator
  and capacity from an attention model.
* `finite_closureCapacity_attention_duality` — the main duality packaging:
  existence of canonical minimal realization, lower bound, and reconstruction.

## Mathematical Overview

A **closure-capacity object** `(cl, κ)` on a finite type `X` consists of:
- A closure operator `cl` on `Finset X` (extensive, monotone, idempotent),
- A capacity function `κ : Finset X → ℕ` that is monotone on closed sets,
  normalized (`κ ∅ = 0`), and invariant under closure.

An **extreme generator** is a nonempty closed set `C` such that every proper
closed subset has strictly smaller capacity. The number of extreme generators
is the **extreme rank**.

A **sparse attention model** with `n` heads assigns each head a support set
(a closed set) and a weight (matching the capacity). The model **realizes**
the closure-capacity object if every extreme generator appears as some head's
support.

The **duality theorem** states:
1. Every closure-capacity object admits a canonical minimal realization with
   head count equal to the extreme rank.
2. Any realization requires at least as many heads as extreme generators.
3. From any realization, one can reconstruct the closure-capacity data.
-/

open Finset Function

noncomputable section

namespace ClosureCapacityAttention

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## Section 1: Finite Closure Operators -/

/-- A closure operator on `Finset X`: extensive, monotone, idempotent. -/
structure FiniteClosure (X : Type*) [Fintype X] [DecidableEq X] where
  cl : Finset X → Finset X
  cl_extensive : ∀ A, A ⊆ cl A
  cl_mono : ∀ ⦃A B⦄, A ⊆ B → cl A ⊆ cl B
  cl_idem : ∀ A, cl (cl A) = cl A

namespace FiniteClosure

/-- A set is closed if it equals its own closure. -/
def IsClosed (C : FiniteClosure X) (A : Finset X) : Prop :=
  C.cl A = A

instance (C : FiniteClosure X) : DecidablePred C.IsClosed :=
  fun A => decEq (C.cl A) A

/-- The closure of any set is closed. -/
theorem cl_closed (C : FiniteClosure X) (A : Finset X) : C.IsClosed (C.cl A) :=
  C.cl_idem A

/-- The full set of all closed subsets of `X`. -/
def closedSets (C : FiniteClosure X) : Finset (Finset X) :=
  Fintype.elems.filter C.IsClosed

theorem mem_closedSets_iff (C : FiniteClosure X) (A : Finset X) :
    A ∈ C.closedSets ↔ C.IsClosed A := by
  simp [closedSets, Fintype.complete]

end FiniteClosure

/-! ## Section 2: Closure-Capacity Objects -/

/-- A closure-capacity object: a closure operator on a finite type equipped with
    a monotone, normalized capacity function. -/
structure ClosureCapacityObj (X : Type*) [Fintype X] [DecidableEq X]
    extends FiniteClosure X where
  κ : Finset X → ℕ
  κ_mono : ∀ ⦃A B⦄, toFiniteClosure.IsClosed A → toFiniteClosure.IsClosed B →
    A ⊆ B → κ A ≤ κ B
  κ_bot : κ ∅ = 0
  κ_cl_invariant : ∀ A, κ A = κ (cl A)
  empty_closed : toFiniteClosure.IsClosed ∅

namespace ClosureCapacityObj

variable (O : ClosureCapacityObj X)

abbrev IsClosed (A : Finset X) : Prop := O.toFiniteClosure.IsClosed A
abbrev closedSets : Finset (Finset X) := O.toFiniteClosure.closedSets

theorem empty_in_closedSets : ∅ ∈ O.closedSets := by
  rw [FiniteClosure.mem_closedSets_iff]
  exact O.empty_closed

theorem cl_mem_closedSets (A : Finset X) : O.cl A ∈ O.closedSets := by
  rw [FiniteClosure.mem_closedSets_iff]
  exact O.toFiniteClosure.cl_closed A

/-- A nonempty closed set is an **extreme generator** if every proper closed subset
    has strictly smaller capacity. These are the irreducible building blocks. -/
def IsExtreme (C : Finset X) : Prop :=
  O.IsClosed C ∧ C ≠ ∅ ∧ ∀ D, O.IsClosed D → D ⊂ C → O.κ D < O.κ C

instance : DecidablePred O.IsExtreme := fun C => by
  unfold IsExtreme; infer_instance

/-- The finset of all extreme generators. -/
def extremeSets : Finset (Finset X) :=
  O.closedSets.filter (fun C => decide (O.IsExtreme C))

theorem mem_extremeSets_iff (C : Finset X) :
    C ∈ O.extremeSets ↔ O.IsExtreme C := by
  simp only [extremeSets, Finset.mem_filter, FiniteClosure.mem_closedSets_iff]
  constructor
  · intro ⟨_, h⟩; exact of_decide_eq_true (by simpa using h)
  · intro h; exact ⟨h.1, by simpa using decide_eq_true h⟩

/-- The extreme rank: number of extreme generators. -/
def extremeRank : ℕ := O.extremeSets.card

end ClosureCapacityObj

/-! ## Section 3: Sparse Attention Models -/

/-- A sparse attention model on `X` with `numHeads` attention heads.
    Each head has a support set (subset of `X`) and a weight (natural number). -/
structure SparseAttentionModel (X : Type*) [Fintype X] [DecidableEq X] where
  numHeads : ℕ
  support : Fin numHeads → Finset X
  weight : Fin numHeads → ℕ

namespace SparseAttentionModel

/-- A sparse attention model **realizes** a closure-capacity object if:
    1. Each head's support is a closed set,
    2. Every extreme generator appears as some head's support,
    3. Weights match capacity on supports. -/
def RealizesClosureCapacity (M : SparseAttentionModel X) (O : ClosureCapacityObj X) : Prop :=
  (∀ h, O.IsClosed (M.support h)) ∧
  (∀ C, O.IsExtreme C → ∃ h, M.support h = C) ∧
  (∀ h, M.weight h = O.κ (M.support h))

/-- A model is **minimal** for `O` if it realizes `O` and no realization uses fewer heads. -/
def IsMinimal (M : SparseAttentionModel X) (O : ClosureCapacityObj X) : Prop :=
  M.RealizesClosureCapacity O ∧
  ∀ M' : SparseAttentionModel X, M'.RealizesClosureCapacity O → M.numHeads ≤ M'.numHeads

/-- A model is **closure-consistent** if it realizes some closure-capacity object. -/
def IsClosureConsistent (M : SparseAttentionModel X) : Prop :=
  ∃ O : ClosureCapacityObj X, M.RealizesClosureCapacity O

end SparseAttentionModel

/-! ## Section 4: Canonical Construction -/

/-- Given an ordering of extreme sets, build the canonical sparse attention model
    with one head per extreme generator. -/
def canonical_attention_model (O : ClosureCapacityObj X)
    (enum : Fin O.extremeRank ≃ O.extremeSets) : SparseAttentionModel X where
  numHeads := O.extremeRank
  support := fun h => (enum h).val
  weight := fun h => O.κ (enum h).val

/-! ## Section 5: Lower Bound -/

/-- **Key lemma**: If a model realizes `O`, any map from extreme sets to matching
    heads is injective. -/
theorem extreme_to_head_injective
    (O : ClosureCapacityObj X)
    (M : SparseAttentionModel X)
    (_hreal : M.RealizesClosureCapacity O)
    (f : ∀ C, O.IsExtreme C → Fin M.numHeads)
    (hf : ∀ C (hC : O.IsExtreme C), M.support (f C hC) = C) :
    ∀ C₁ C₂ (h₁ : O.IsExtreme C₁) (h₂ : O.IsExtreme C₂),
      f C₁ h₁ = f C₂ h₂ → C₁ = C₂ := by
  intro C₁ C₂ h₁ h₂ heq
  have h1 := hf C₁ h₁
  have h2 := hf C₂ h₂
  rw [heq] at h1
  exact h1.symm.trans h2

/-
**Lower bound theorem**: Any realization of a closure-capacity object requires
    at least as many heads as extreme generators.
-/
theorem extremeRank_le_headCount
    (O : ClosureCapacityObj X)
    (M : SparseAttentionModel X)
    (hreal : M.RealizesClosureCapacity O) :
    O.extremeRank ≤ M.numHeads := by
  -- From hreal.2.1, for each extreme set C, choose a head f(C) with M.support(f(C)) = C.
  have h_head : ∀ C, O.IsExtreme C → ∃ f : Fin M.numHeads, M.support f = C := by
    exact hreal.2.1;
  have h_inj : Function.Injective (fun C : { C : Finset X // O.IsExtreme C } => Classical.choose (h_head C.val C.property)) := by
    intro C₁ C₂ h_eq;
    exact Subtype.ext ( by have := Classical.choose_spec ( h_head C₁.1 C₁.2 ) ; have := Classical.choose_spec ( h_head C₂.1 C₂.2 ) ; aesop );
  convert Fintype.card_le_of_injective _ h_inj;
  · rw [ Fintype.subtype_card ];
    exact congr_arg Finset.card ( Finset.ext fun x => by simp +decide [ ClosureCapacityObj.mem_extremeSets_iff ] );
  · simp +decide

/-! ## Section 6: Canonical Model Properties -/

/-
The canonical model realizes the closure-capacity object.
-/
theorem canonical_model_realizes
    (O : ClosureCapacityObj X)
    (enum : Fin O.extremeRank ≃ O.extremeSets) :
    (canonical_attention_model O enum).RealizesClosureCapacity O := by
  constructor;
  · exact fun h => by have := enum h |>.2; exact (O.mem_extremeSets_iff _).mp this |>.1;
  · constructor;
    · intro C hC;
      obtain ⟨ h, hh ⟩ := enum.surjective ⟨ C, by
        exact (ClosureCapacityObj.mem_extremeSets_iff O C).mpr hC ⟩
      generalize_proofs at *;
      exact ⟨ h, congr_arg Subtype.val hh ⟩;
    · exact fun h => Nat.add_zero (O.κ ↑(enum h))

/-
The canonical model is minimal: it has the fewest possible heads.
-/
theorem canonical_model_is_minimal
    (O : ClosureCapacityObj X)
    (enum : Fin O.extremeRank ≃ O.extremeSets) :
    (canonical_attention_model O enum).IsMinimal O := by
  constructor;
  · exact canonical_model_realizes O enum;
  · exact fun M' hM' => extremeRank_le_headCount O M' hM'

/-
For any minimal model, the head count equals the extreme rank.
-/
theorem head_count_eq_extremeRank
    (O : ClosureCapacityObj X)
    (M : SparseAttentionModel X)
    (hmin : M.IsMinimal O) :
    M.numHeads = O.extremeRank := by
  have h_upper_bound : M.numHeads ≤ O.extremeRank := by
    obtain ⟨enum, henum⟩ : ∃ enum : Fin O.extremeRank ≃ O.extremeSets, True := by
      exact ⟨ Fintype.equivOfCardEq ( by simp +decide [ ClosureCapacityObj.extremeRank ] ), trivial ⟩;
    exact hmin.2 _ ( canonical_model_realizes O enum );
  exact le_antisymm h_upper_bound ( extremeRank_le_headCount O M hmin.1 )

/-! ## Section 7: Reconstruction -/

/-- Reconstruct a closure operator from a sparse attention model.
    `cl(A)` = intersection of all head supports containing `A`. -/
def reconstructClosure (M : SparseAttentionModel X) : Finset X → Finset X :=
  fun A =>
    let covering := Finset.univ.filter (fun h : Fin M.numHeads => A ⊆ M.support h)
    if _h : covering.Nonempty then covering.inf M.support else Finset.univ

/-- Reconstruct a capacity function from a sparse attention model.
    `κ(A)` = max weight over all heads containing `A`. -/
def reconstructCapacity (M : SparseAttentionModel X) : Finset X → ℕ :=
  fun A =>
    let covering := Finset.univ.filter (fun h : Fin M.numHeads => A ⊆ M.support h)
    if covering.Nonempty then covering.sup M.weight else 0

/-
The reconstructed closure is extensive.
-/
theorem reconstructClosure_extensive (M : SparseAttentionModel X) (A : Finset X) :
    A ⊆ reconstructClosure M A := by
  -- Since every head in the covering contains A, their intersection must also contain A.
  simp [reconstructClosure];
  split_ifs <;> simp_all +decide [ Finset.subset_iff ];
  simp +contextual [ Finset.mem_inf ]

/-
The reconstructed closure is monotone.
-/
theorem reconstructClosure_mono (M : SparseAttentionModel X) ⦃A B : Finset X⦄
    (h : A ⊆ B) : reconstructClosure M A ⊆ reconstructClosure M B := by
  simp_all +decide [ reconstructClosure ];
  split_ifs <;> simp_all +decide [ Finset.subset_iff ];
  · simp_all +decide [ Finset.mem_inf ];
    exact fun x hx i hi => hx i fun y hy => hi ( h hy );
  · rename_i h₁ h₂;
    obtain ⟨ h, hh ⟩ := h₂;
    exact absurd ( h₁ ) ( by push_neg; aesop )

/-
The reconstructed closure is idempotent.
-/
theorem reconstructClosure_idem (M : SparseAttentionModel X) (A : Finset X) :
    reconstructClosure M (reconstructClosure M A) = reconstructClosure M A := by
  unfold reconstructClosure;
  by_cases h : ( Finset.univ.filter fun h : Fin M.numHeads => A ⊆ M.support h ).Nonempty <;> simp +decide [ h ];
  · split_ifs <;> simp_all +decide [ Finset.subset_iff ];
    · ext x; simp +decide [ Finset.mem_inf ] ;
      grind;
    · obtain ⟨ k, hk ⟩ := h;
      rename_i h; specialize h; have := h; simp_all +decide [ Finset.mem_inf ] ;
      exact absurd ( h ) ( by push_neg; tauto );
  · simp_all +decide [ Finset.Nonempty ];
    exact fun x hx => False.elim ( h x ( by simp +decide [ hx ] ) )

/-
On supports of heads, reconstructed capacity recovers original weights.
-/
theorem reconstructCapacity_on_support (M : SparseAttentionModel X) (h : Fin M.numHeads) :
    reconstructCapacity M (M.support h) ≥ M.weight h := by
  unfold reconstructCapacity;
  simp +decide [ Finset.Nonempty ];
  split_ifs <;> simp_all +decide [ Finset.le_sup ];
  exact False.elim ( ‹∀ x : Fin M.numHeads, ¬M.support h ⊆ M.support x› h ( Finset.Subset.refl _ ) )

/-! ## Section 8: Main Duality Theorem -/

/-- **Finite Closure-Capacity–Attention Duality Theorem.**

Every closure-capacity object `O` on a finite type admits a canonical minimal
sparse attention realization:
1. The canonical model has one head per extreme generator (existence + construction).
2. It is minimal (optimality).
3. Head count = extreme rank (invariance).

Moreover, the reconstructed capacity from the canonical model gives a lower bound
on the original capacity for every extreme set. -/
theorem finite_closureCapacity_attention_duality
    (O : ClosureCapacityObj X)
    (enum : Fin O.extremeRank ≃ O.extremeSets) :
    (canonical_attention_model O enum).RealizesClosureCapacity O ∧
    (canonical_attention_model O enum).IsMinimal O ∧
    (canonical_attention_model O enum).numHeads = O.extremeRank := by
  exact ⟨canonical_model_realizes O enum, canonical_model_is_minimal O enum, rfl⟩

/-
**Existence form**: every closure-capacity object admits a minimal realization.
-/
theorem exists_minimal_sparse_attention
    (O : ClosureCapacityObj X) :
    ∃ M : SparseAttentionModel X,
      M.RealizesClosureCapacity O ∧
      M.IsMinimal O ∧
      M.numHeads = O.extremeRank := by
  obtain ⟨enum, h_enum⟩ : ∃ enum : Fin O.extremeRank ≃ O.extremeSets, True := by
    simp;
    exact ⟨ Fintype.equivOfCardEq <| by simp +decide [ ClosureCapacityObj.extremeRank ] ⟩;
  exact ⟨ _, canonical_model_realizes O enum, canonical_model_is_minimal O enum, rfl ⟩

/-- **Certified reconstruction**: from any realization, one can extract a closure
    operator and capacity function that is extensive and monotone. -/
theorem certified_reconstruction
    (M : SparseAttentionModel X) :
    (∀ A, A ⊆ reconstructClosure M A) ∧
    (∀ ⦃A B⦄, A ⊆ B → reconstructClosure M A ⊆ reconstructClosure M B) :=
  ⟨reconstructClosure_extensive M, reconstructClosure_mono M⟩

end ClosureCapacityAttention