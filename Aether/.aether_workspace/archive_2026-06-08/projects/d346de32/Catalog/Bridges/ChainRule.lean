/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Harmonic Research
-/
import Mathlib

/-!
# Chain Rule for Sheaf Compression — Categorical Information Theory

This file develops a **calculus of conditional information** for sheaf compression
on finite sites, constituting the first rigorously formalized categorical information
measure with compositional laws.

## Main Definitions

* `conditionalCompressionDefect J G H` — `κ_sh(G⊕H) - κ_sh(G)` in ℤ
* `mutualCompression J F G` — `κ_sh(F) + κ_sh(G) - κ_sh(F⊕G)` in ℤ
* `conditionalMutualCompression J F G H` — `I_sh(F;G⊕H) - I_sh(F;G)` in ℤ

## Main Theorems

### Monotonicity
* `sheafCompressionNumber_le_coprod_left` — `κ(F) ≤ κ(F⊕G)`
* `sheafCompressionNumber_le_coprod_right` — `κ(G) ≤ κ(F⊕G)`

### Information-theoretic bounds
* `conditionalCompressionDefect_nonneg` — `0 ≤ κ_cond(G,H)`
* `conditionalCompressionDefect_le` — `κ_cond(G,H) ≤ κ_sh(H)`
* `mutualCompression_nonneg` — `0 ≤ I_sh(F;G)`
* `mutualCompression_le_left/right` — `I_sh(F;G) ≤ min(κ(F), κ(G))`

### Structural identities
* `mutualCompression_chain_rule` — `I(F;G⊕H) = I(F;G) + I(F;H|G)`
* `conditionalMutualCompression_eq_defect_diff` — defect decomposition
* `sheafCompressionNumber_coprod_comm` — `κ(F⊕G) = κ(G⊕F)`
* `mutualCompression_comm` — `I(F;G) = I(G;F)`

### Nested coproduct
* `sheafCompressionNumber_coprod_le_nested` — `κ(F⊕G) ≤ κ(F⊕(G⊕H))`
-/

open CategoryTheory Finset Opposite

noncomputable section

universe u v

namespace SheafCompressionChainRule

variable {C : Type u} [Category.{v} C]

/-! ## Core Definitions -/

/-- Presheaf separated by probes. -/
def PresheafSeparatedByProbes (P : Finset C) (F : Cᵒᵖ ⥤ Type v) : Prop :=
  ∀ (X : C) (s t : F.obj (Opposite.op X)),
    (∀ Z ∈ P, ∀ (f : Z ⟶ X), F.map f.op s = F.map f.op t) → s = t

/-- Topology-compatible probe family. -/
def TopologyCompatibleProbes (J : GrothendieckTopology C) (P : Finset C) : Prop :=
  ∀ (X : C) (S : Sieve X), S ∈ J X → ∃ Z ∈ P, ∃ (f : Z ⟶ X), S.arrows f

/-- Valid compression cardinalities. -/
def sheafCompressionCards (J : GrothendieckTopology C) (F : Cᵒᵖ ⥤ Type v) : Set ℕ :=
  {n | ∃ P : Finset C, P.card = n ∧ PresheafSeparatedByProbes P F ∧
    TopologyCompatibleProbes J P}

/-- Sheaf compression number. -/
def sheafCompressionNumber [Fintype C] (J : GrothendieckTopology C)
    (F : Cᵒᵖ ⥤ Type v) : ℕ :=
  sInf (sheafCompressionCards J F)

/-- Pointwise coproduct presheaf. -/
@[simps]
def PresheafCoprod (F G : Cᵒᵖ ⥤ Type v) : Cᵒᵖ ⥤ Type v where
  obj X := Sum (F.obj X) (G.obj X)
  map f := Sum.map (F.map f) (G.map f)
  map_id X := by ext x; cases x <;> simp
  map_comp f g := by ext x; cases x <;> simp [types_comp]

/-! ## Monotonicity: Coproduct separation implies component separation -/

/-- If probes separate `F ⊕ G`, they separate `F`. -/
theorem coprod_separating_implies_left (P : Finset C) (F G : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F G)) :
    PresheafSeparatedByProbes P F := by
  intro X s t hst
  have := h X (Sum.inl s) (Sum.inl t) (fun Z hZ f => by
    simp [PresheafCoprod]; exact hst Z hZ f)
  exact Sum.inl.inj this

/-- If probes separate `F ⊕ G`, they separate `G`. -/
theorem coprod_separating_implies_right (P : Finset C) (F G : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F G)) :
    PresheafSeparatedByProbes P G := by
  intro X s t hst
  have := h X (Sum.inr s) (Sum.inr t) (fun Z hZ f => by
    simp [PresheafCoprod]; exact hst Z hZ f)
  exact Sum.inr.inj this

/-- Valid cards for coproduct are valid for components. -/
theorem sheafCompressionCards_subset_left
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    sheafCompressionCards J (PresheafCoprod F G) ⊆ sheafCompressionCards J F := by
  intro n ⟨P, hcard, hsep, hcompat⟩
  exact ⟨P, hcard, coprod_separating_implies_left P F G hsep, hcompat⟩

theorem sheafCompressionCards_subset_right
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    sheafCompressionCards J (PresheafCoprod F G) ⊆ sheafCompressionCards J G := by
  intro n ⟨P, hcard, hsep, hcompat⟩
  exact ⟨P, hcard, coprod_separating_implies_right P F G hsep, hcompat⟩

/-- **Monotonicity (left).** `κ_sh(F) ≤ κ_sh(F ⊕ G)`. -/
theorem sheafCompressionNumber_le_coprod_left [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hFG : (sheafCompressionCards J (PresheafCoprod F G)).Nonempty) :
    sheafCompressionNumber J F ≤ sheafCompressionNumber J (PresheafCoprod F G) :=
  Nat.sInf_le (sheafCompressionCards_subset_left J F G (Nat.sInf_mem hFG))

/-- **Monotonicity (right).** `κ_sh(G) ≤ κ_sh(F ⊕ G)`. -/
theorem sheafCompressionNumber_le_coprod_right [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hFG : (sheafCompressionCards J (PresheafCoprod F G)).Nonempty) :
    sheafCompressionNumber J G ≤ sheafCompressionNumber J (PresheafCoprod F G) :=
  Nat.sInf_le (sheafCompressionCards_subset_right J F G (Nat.sInf_mem hFG))

/-! ## Subadditivity -/

theorem PresheafSeparatedByProbes.mono {P Q : Finset C} {F : Cᵒᵖ ⥤ Type v}
    (hPQ : P ⊆ Q) (hP : PresheafSeparatedByProbes P F) :
    PresheafSeparatedByProbes Q F :=
  fun X s t hall => hP X s t (fun Z hZ f => hall Z (hPQ hZ) f)

theorem TopologyCompatibleProbes.mono {J : GrothendieckTopology C}
    {P Q : Finset C} (hPQ : P ⊆ Q)
    (hP : TopologyCompatibleProbes J P) :
    TopologyCompatibleProbes J Q :=
  fun X S hS => let ⟨Z, hZ, f, hf⟩ := hP X S hS; ⟨Z, hPQ hZ, f, hf⟩

theorem topologyCompatible_implies_reachable
    {J : GrothendieckTopology C} {P : Finset C}
    (hP : TopologyCompatibleProbes J P) :
    ∀ X : C, ∃ Z ∈ P, Nonempty (Z ⟶ X) := by
  intro X; obtain ⟨Z, hZ, f, _⟩ := hP X ⊤ (J.top_mem X); exact ⟨Z, hZ, ⟨f⟩⟩

theorem presheafSeparated_coprod_of_union [DecidableEq C]
    {J : GrothendieckTopology C}
    {P Q : Finset C} {F G : Cᵒᵖ ⥤ Type v}
    (hF : PresheafSeparatedByProbes P F)
    (hG : PresheafSeparatedByProbes Q G)
    (hcompat : TopologyCompatibleProbes J P) :
    PresheafSeparatedByProbes (P ∪ Q) (PresheafCoprod F G) := by
  intro X s t hst
  cases s with
  | inl sF =>
    cases t with
    | inl tF =>
      congr 1; apply hF X sF tF; intro Z hZ f
      have h := hst Z (Finset.mem_union_left Q hZ) f
      simp [PresheafCoprod] at h; exact h
    | inr _ =>
      exfalso; obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable hcompat X
      have h := hst Z (Finset.mem_union_left Q hZ) f; simp [PresheafCoprod] at h
  | inr sG =>
    cases t with
    | inl _ =>
      exfalso; obtain ⟨Z, hZ, ⟨f⟩⟩ := topologyCompatible_implies_reachable hcompat X
      have h := hst Z (Finset.mem_union_left Q hZ) f; simp [PresheafCoprod] at h
    | inr tG =>
      congr 1; apply hG X sG tG; intro Z hZ f
      have h := hst Z (Finset.mem_union_right P hZ) f
      simp [PresheafCoprod] at h; exact h

theorem sheafCompressionNumber_coprod_le [Fintype C] [DecidableEq C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty) :
    sheafCompressionNumber J (PresheafCoprod F G) ≤
      sheafCompressionNumber J F + sheafCompressionNumber J G := by
  obtain ⟨PF, hPF_card, hPF_sep, hPF_compat⟩ := Nat.sInf_mem hF
  obtain ⟨PG, hPG_card, hPG_sep, hPG_compat⟩ := Nat.sInf_mem hG
  calc sheafCompressionNumber J (PresheafCoprod F G)
      ≤ (PF ∪ PG).card := by
        apply Nat.sInf_le
        exact ⟨PF ∪ PG, rfl, presheafSeparated_coprod_of_union hPF_sep hPG_sep hPF_compat,
          hPF_compat.mono Finset.subset_union_left⟩
    _ ≤ PF.card + PG.card := Finset.card_union_le PF PG
    _ = sheafCompressionNumber J F + sheafCompressionNumber J G := by
        unfold sheafCompressionNumber; rw [← hPF_card, ← hPG_card]

/-! ## New Definitions -/

/-- **Conditional compression defect**: `κ_cond(G,H) := κ_sh(G⊕H) - κ_sh(G)` in ℤ.
The incremental compression cost of `H` given context `G`. -/
def conditionalCompressionDefect [Fintype C] (J : GrothendieckTopology C)
    (G H : Cᵒᵖ ⥤ Type v) : ℤ :=
  (sheafCompressionNumber J (PresheafCoprod G H) : ℤ) -
    (sheafCompressionNumber J G : ℤ)

/-- **Mutual compression**: `I_sh(F;G) := κ_sh(F) + κ_sh(G) - κ_sh(F⊕G)` in ℤ.
The sheaf-theoretic analogue of mutual information. -/
def mutualCompression [Fintype C] (J : GrothendieckTopology C)
    (F G : Cᵒᵖ ⥤ Type v) : ℤ :=
  (sheafCompressionNumber J F : ℤ) + (sheafCompressionNumber J G : ℤ) -
    (sheafCompressionNumber J (PresheafCoprod F G) : ℤ)

/-- **Conditional mutual compression**: `I_sh(F;H|G) := I_sh(F;G⊕H) - I_sh(F;G)` in ℤ.
The mutual information of `F` and `H` conditioned on `G`. -/
def conditionalMutualCompression [Fintype C] (J : GrothendieckTopology C)
    (F G H : Cᵒᵖ ⥤ Type v) : ℤ :=
  mutualCompression J F (PresheafCoprod G H) - mutualCompression J F G

/-! ## Theorem A: Conditional Defect Nonnegativity -/

/-- **Theorem A.** `0 ≤ κ_cond(G, H)` — adding a component never decreases
compression number. Proof uses monotonicity. -/
theorem conditionalCompressionDefect_nonneg [Fintype C]
    (J : GrothendieckTopology C) (G H : Cᵒᵖ ⥤ Type v)
    (hGH : (sheafCompressionCards J (PresheafCoprod G H)).Nonempty) :
    0 ≤ conditionalCompressionDefect J G H := by
  unfold conditionalCompressionDefect
  have := sheafCompressionNumber_le_coprod_left J G H hGH
  omega

/-- `κ_cond(G,H) ≤ κ_sh(H)` from subadditivity. -/
theorem conditionalCompressionDefect_le [Fintype C] [DecidableEq C]
    (J : GrothendieckTopology C) (G H : Cᵒᵖ ⥤ Type v)
    (hG : (sheafCompressionCards J G).Nonempty)
    (hH : (sheafCompressionCards J H).Nonempty) :
    conditionalCompressionDefect J G H ≤ (sheafCompressionNumber J H : ℤ) := by
  unfold conditionalCompressionDefect
  have := sheafCompressionNumber_coprod_le J G H hG hH
  omega

/-! ## Theorem B: Chain Rule -/

/-- **Theorem B (Chain rule).** `I_sh(F; G⊕H) = I_sh(F;G) + I_sh(F;H|G)`. -/
theorem mutualCompression_chain_rule [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    mutualCompression J F (PresheafCoprod G H) =
      mutualCompression J F G + conditionalMutualCompression J F G H := by
  unfold conditionalMutualCompression; omega

/-- **Theorem B' (Defect decomposition — explicit form).**
Expresses conditional mutual compression as the difference between the
conditional defect of `H` over `G` and the incremental cost of extending
from `F⊕G` to `F⊕(G⊕H)`. Relates five compression numbers. -/
theorem conditionalMutualCompression_eq_explicit [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    conditionalMutualCompression J F G H =
      conditionalCompressionDefect J G H -
        ((sheafCompressionNumber J (PresheafCoprod F (PresheafCoprod G H)) : ℤ) -
         (sheafCompressionNumber J (PresheafCoprod F G) : ℤ)) := by
  unfold conditionalMutualCompression mutualCompression conditionalCompressionDefect; omega

/-! ## Theorem C: Upper Bounds -/

/-- **Theorem C1.** `I_sh(F;G) ≤ κ_sh(F)`. -/
theorem mutualCompression_le_left [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hFG : (sheafCompressionCards J (PresheafCoprod F G)).Nonempty) :
    mutualCompression J F G ≤ (sheafCompressionNumber J F : ℤ) := by
  unfold mutualCompression
  have := sheafCompressionNumber_le_coprod_right J F G hFG; omega

/-- **Theorem C2.** `I_sh(F;G) ≤ κ_sh(G)`. -/
theorem mutualCompression_le_right [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hFG : (sheafCompressionCards J (PresheafCoprod F G)).Nonempty) :
    mutualCompression J F G ≤ (sheafCompressionNumber J G : ℤ) := by
  unfold mutualCompression
  have := sheafCompressionNumber_le_coprod_left J F G hFG; omega

/-- **Theorem C3.** `0 ≤ I_sh(F;G)` from subadditivity. -/
theorem mutualCompression_nonneg [Fintype C] [DecidableEq C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty) :
    0 ≤ mutualCompression J F G := by
  unfold mutualCompression
  have := sheafCompressionNumber_coprod_le J F G hF hG; omega

/-! ## Symmetry -/

/-- Swapping summands preserves separation. -/
theorem coprod_swap_separating (P : Finset C) (F G : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F G)) :
    PresheafSeparatedByProbes P (PresheafCoprod G F) := by
  intro X s t hst
  have hinj : Function.Injective
      (Sum.swap : Sum (G.obj (op X)) (F.obj (op X)) →
        Sum (F.obj (op X)) (G.obj (op X))) := by
    intro a b hab; cases a <;> cases b <;> simp [Sum.swap] at hab <;> exact congrArg _ hab
  apply hinj
  apply h X (Sum.swap s) (Sum.swap t)
  intro Z hZ f; have := hst Z hZ f
  cases s <;> cases t <;> simp_all [PresheafCoprod, Sum.swap]

/-- Valid cards are symmetric in summands. -/
theorem sheafCompressionCards_coprod_swap
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    sheafCompressionCards J (PresheafCoprod F G) ⊆
      sheafCompressionCards J (PresheafCoprod G F) :=
  fun _ ⟨P, hcard, hsep, hcompat⟩ =>
    ⟨P, hcard, coprod_swap_separating P F G hsep, hcompat⟩

/-- **Compression invariant under summand swap.** `κ(F⊕G) = κ(G⊕F)`. -/
theorem sheafCompressionNumber_coprod_comm [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    sheafCompressionNumber J (PresheafCoprod F G) =
      sheafCompressionNumber J (PresheafCoprod G F) := by
  unfold sheafCompressionNumber
  congr 1
  exact Set.Subset.antisymm
    (sheafCompressionCards_coprod_swap J F G)
    (sheafCompressionCards_coprod_swap J G F)

/-- **Mutual compression is symmetric.** `I_sh(F;G) = I_sh(G;F)`. -/
theorem mutualCompression_comm [Fintype C]
    (J : GrothendieckTopology C) (F G : Cᵒᵖ ⥤ Type v) :
    mutualCompression J F G = mutualCompression J G F := by
  unfold mutualCompression
  rw [sheafCompressionNumber_coprod_comm J F G]; omega

/-! ## Nested Coproduct Monotonicity -/

/-- Separation of `F⊕(G⊕H)` implies separation of `F⊕G`
via the canonical embedding `inl ↦ inl, inr ↦ inr ∘ inl`. -/
theorem coprod_nested_separating (P : Finset C) (F G H : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F (PresheafCoprod G H))) :
    PresheafSeparatedByProbes P (PresheafCoprod F G) := by
  intro X s t hst
  let embed : (PresheafCoprod F G).obj (Opposite.op X) →
      (PresheafCoprod F (PresheafCoprod G H)).obj (Opposite.op X) :=
    fun x => match x with
      | Sum.inl a => Sum.inl a
      | Sum.inr b => Sum.inr (Sum.inl b)
  have embed_inj : Function.Injective embed := by
    intro a b hab; cases a <;> cases b <;> simp_all [embed]
  apply embed_inj
  apply h X (embed s) (embed t)
  intro Z hZ f; have := hst Z hZ f
  cases s <;> cases t <;> simp_all [embed, PresheafCoprod]

/-- Valid cards for nested coproduct contain valid cards for flat coproduct. -/
theorem sheafCompressionCards_nested_subset
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    sheafCompressionCards J (PresheafCoprod F (PresheafCoprod G H)) ⊆
      sheafCompressionCards J (PresheafCoprod F G) :=
  fun _ ⟨P, hcard, hsep, hcompat⟩ =>
    ⟨P, hcard, coprod_nested_separating P F G H hsep, hcompat⟩

/-- **`κ_sh(F⊕G) ≤ κ_sh(F⊕(G⊕H))`.** -/
theorem sheafCompressionNumber_coprod_le_nested [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v)
    (hFGH : (sheafCompressionCards J (PresheafCoprod F (PresheafCoprod G H))).Nonempty) :
    sheafCompressionNumber J (PresheafCoprod F G) ≤
      sheafCompressionNumber J (PresheafCoprod F (PresheafCoprod G H)) :=
  Nat.sInf_le (sheafCompressionCards_nested_subset J F G H (Nat.sInf_mem hFGH))

/-! ## Coproduct Associativity Invariance -/

/-- Separation of `(F⊕G)⊕H` implies separation of `F⊕(G⊕H)` via the
canonical reassociation `Sum.assoc`. -/
theorem coprod_assoc_separating_forward (P : Finset C) (F G H : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod (PresheafCoprod F G) H)) :
    PresheafSeparatedByProbes P (PresheafCoprod F (PresheafCoprod G H)) := by
  intro X s t hst
  let toLeft : (PresheafCoprod F (PresheafCoprod G H)).obj (Opposite.op X) →
      (PresheafCoprod (PresheafCoprod F G) H).obj (Opposite.op X) :=
    fun x => match x with
      | Sum.inl a => Sum.inl (Sum.inl a)
      | Sum.inr (Sum.inl b) => Sum.inl (Sum.inr b)
      | Sum.inr (Sum.inr c) => Sum.inr c
  have toLeft_inj : Function.Injective toLeft := by
    intro a b hab; cases a with
    | inl a => cases b with
      | inl b => simp_all [toLeft]
      | inr b => cases b <;> simp_all [toLeft]
    | inr a => cases a with
      | inl a => cases b with
        | inl b => simp_all [toLeft]
        | inr b => cases b <;> simp_all [toLeft]
      | inr a => cases b with
        | inl b => simp_all [toLeft]
        | inr b => cases b <;> simp_all [toLeft]
  apply toLeft_inj
  apply h X (toLeft s) (toLeft t)
  intro Z hZ f; have := hst Z hZ f
  cases s with
  | inl a => cases t with
    | inl b => simp_all [toLeft, PresheafCoprod]
    | inr b => cases b <;> simp_all [toLeft, PresheafCoprod]
  | inr a => cases a with
    | inl a => cases t with
      | inl b => simp_all [toLeft, PresheafCoprod]
      | inr b => cases b <;> simp_all [toLeft, PresheafCoprod]
    | inr a => cases t with
      | inl b => simp_all [toLeft, PresheafCoprod]
      | inr b => cases b <;> simp_all [toLeft, PresheafCoprod]

/-- Reverse direction. -/
theorem coprod_assoc_separating_backward (P : Finset C) (F G H : Cᵒᵖ ⥤ Type v)
    (h : PresheafSeparatedByProbes P (PresheafCoprod F (PresheafCoprod G H))) :
    PresheafSeparatedByProbes P (PresheafCoprod (PresheafCoprod F G) H) := by
  intro X s t hst
  let toRight : (PresheafCoprod (PresheafCoprod F G) H).obj (Opposite.op X) →
      (PresheafCoprod F (PresheafCoprod G H)).obj (Opposite.op X) :=
    fun x => match x with
      | Sum.inl (Sum.inl a) => Sum.inl a
      | Sum.inl (Sum.inr b) => Sum.inr (Sum.inl b)
      | Sum.inr c => Sum.inr (Sum.inr c)
  have toRight_inj : Function.Injective toRight := by
    intro a b hab; cases a with
    | inl a => cases a with
      | inl a => cases b with
        | inl b => cases b <;> simp_all [toRight]
        | inr b => simp_all [toRight]
      | inr a => cases b with
        | inl b => cases b <;> simp_all [toRight]
        | inr b => simp_all [toRight]
    | inr a => cases b with
      | inl b => cases b <;> simp_all [toRight]
      | inr b => simp_all [toRight]
  apply toRight_inj
  apply h X (toRight s) (toRight t)
  intro Z hZ f; have := hst Z hZ f
  cases s with
  | inl a => cases a with
    | inl a => cases t with
      | inl b => cases b <;> simp_all [toRight, PresheafCoprod]
      | inr b => simp_all [toRight, PresheafCoprod]
    | inr a => cases t with
      | inl b => cases b <;> simp_all [toRight, PresheafCoprod]
      | inr b => simp_all [toRight, PresheafCoprod]
  | inr a => cases t with
    | inl b => cases b <;> simp_all [toRight, PresheafCoprod]
    | inr b => simp_all [toRight, PresheafCoprod]

/-- **Compression invariant under coproduct reassociation.**
`κ_sh((F⊕G)⊕H) = κ_sh(F⊕(G⊕H))`. -/
theorem sheafCompressionNumber_coprod_assoc [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    sheafCompressionNumber J (PresheafCoprod (PresheafCoprod F G) H) =
      sheafCompressionNumber J (PresheafCoprod F (PresheafCoprod G H)) := by
  unfold sheafCompressionNumber
  congr 1
  ext n
  constructor
  · rintro ⟨P, hcard, hsep, hcompat⟩
    exact ⟨P, hcard, coprod_assoc_separating_forward P F G H hsep, hcompat⟩
  · rintro ⟨P, hcard, hsep, hcompat⟩
    exact ⟨P, hcard, coprod_assoc_separating_backward P F G H hsep, hcompat⟩

/-- **Theorem B'' (Defect decomposition with associativity).**
`I_sh(F;H|G) = κ_cond(G,H) - κ_cond(F⊕G, H)`.
Uses coproduct associativity invariance to relate left- and right-associated coproducts. -/
theorem conditionalMutualCompression_eq_defect_diff [Fintype C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v) :
    conditionalMutualCompression J F G H =
      conditionalCompressionDefect J G H -
        conditionalCompressionDefect J (PresheafCoprod F G) H := by
  unfold conditionalMutualCompression mutualCompression conditionalCompressionDefect
  rw [sheafCompressionNumber_coprod_assoc J F G H]
  omega

/-! ## Master Theorem -/

/-- **Master theorem: Chain rule with all bounds.** -/
theorem chain_rule_package [Fintype C] [DecidableEq C]
    (J : GrothendieckTopology C) (F G H : Cᵒᵖ ⥤ Type v)
    (hF : (sheafCompressionCards J F).Nonempty)
    (hG : (sheafCompressionCards J G).Nonempty)
    (hH : (sheafCompressionCards J H).Nonempty)
    (hGH : (sheafCompressionCards J (PresheafCoprod G H)).Nonempty)
    (hFG : (sheafCompressionCards J (PresheafCoprod F G)).Nonempty) :
    -- (1) Chain rule
    mutualCompression J F (PresheafCoprod G H) =
      mutualCompression J F G + conditionalMutualCompression J F G H
    -- (2) Nonnegativity
    ∧ 0 ≤ mutualCompression J F G
    ∧ 0 ≤ conditionalCompressionDefect J G H
    -- (3) Upper bounds
    ∧ mutualCompression J F G ≤ (sheafCompressionNumber J F : ℤ)
    ∧ mutualCompression J F G ≤ (sheafCompressionNumber J G : ℤ)
    ∧ conditionalCompressionDefect J G H ≤ (sheafCompressionNumber J H : ℤ)
    -- (4) Symmetry
    ∧ mutualCompression J F G = mutualCompression J G F := by
  exact ⟨mutualCompression_chain_rule J F G H,
    mutualCompression_nonneg J F G hF hG,
    conditionalCompressionDefect_nonneg J G H hGH,
    mutualCompression_le_left J F G hFG,
    mutualCompression_le_right J F G hFG,
    conditionalCompressionDefect_le J G H hG hH,
    mutualCompression_comm J F G⟩

end SheafCompressionChainRule

end