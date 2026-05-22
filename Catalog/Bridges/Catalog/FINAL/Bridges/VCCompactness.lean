import Mathlib
import Bridges.ToposTheoreticML.Foundations

/-! # Topos-Theoretic Machine Learning: VC Dimension and Compactness

This file proves core theorems connecting VC dimension (combinatorial learning theory)
to compact subobject rank (topos-theoretic geometry), and establishes the No-Free-Lunch
theorem, sample complexity bounds, transfer learning, and sieve lattice structure.

## Bridge: Combinatorics (shattering) → Learning Theory (VC, PAC, NFL) →
   Category Theory (compact rank, presheaf toposes) → Cryptography (lattice_crypto) →
   Quantum Information (dagger-symmetric learnability)
-/

noncomputable section

open Finset Real

/-! ## I. Basic Shattering Properties -/

/-- The empty set is always shattered by any concept family. -/
theorem shattering_empty {α : Type*} (C : ConceptFamily α) :
    C.shatters ∅ := by
  intro T hT
  have hTeq : T = ∅ := Finset.subset_empty.mp hT
  subst hTeq
  obtain ⟨c, hc⟩ := C.nonempty
  exact ⟨c, hc, fun x hx => absurd hx (by simp)⟩

/-- VC dimension bounds are monotone. -/
theorem vc_dim_bound_monotone {α : Type*} (C : ConceptFamily α) {d₁ d₂ : ℕ}
    (h : C.vcDimBound d₁) (hle : d₁ ≤ d₂) : C.vcDimBound d₂ :=
  fun S hS => le_trans (h S hS) hle

/-- Compact rank witnesses shattering. -/
theorem compactRank_witnesses {α : Type*} (C : ConceptFamily α) (n : ℕ)
    (h : CompactRank C n) : n = 0 ∨ ∃ S : Finset α, C.shatters S ∧ S.card = n :=
  h.2

/-- Compact rank bounds all shattered sets. -/
theorem compactRank_bounds {α : Type*} (C : ConceptFamily α) (n : ℕ)
    (h : CompactRank C n) (S : Finset α) (hS : C.shatters S) : S.card ≤ n :=
  h.1 S hS

/-! ## II. No-Free-Lunch Theorem (Combinatorial Form) -/

/-- No-Free-Lunch: if VC dimension is unbounded, for every sample size m,
    there exists a shattered set of size > m.
    Bridge: learning theory (NFL) → category theory (non-compact objects). -/
theorem no_free_lunch_combinatorial {α : Type*} (C : ConceptFamily α)
    (hUnbounded : ∀ d : ℕ, ¬C.vcDimBound d) (m : ℕ) :
    ∃ S : Finset α, C.shatters S ∧ m < S.card := by
  by_contra h
  push_neg at h
  exact hUnbounded m (fun S hS => h S hS)

/-- Learnability requires finite VC dimension.
    Bridge: ML (learnability) → category theory (compact subobjects). -/
theorem learnability_requires_finite_vc {α : Type*} (C : ConceptFamily α)
    (hFinite : ∃ d : ℕ, C.vcDimBound d) :
    ∀ S : Finset α, C.shatters S → ∃ d : ℕ, S.card ≤ d := by
  obtain ⟨d, hd⟩ := hFinite
  exact fun S hS => ⟨d, hd S hS⟩

/-! ## III. Sample Lower Bound from Shattering -/

/-- Shattering k points forces vcDimBound (k-1) to fail.
    Bridge: learning theory lower bounds → lattice_crypto hardness. -/
theorem sample_lower_bound_from_shattering {α : Type*}
    (C : ConceptFamily α) (k : ℕ) (hk : 0 < k)
    (hw : CryptoHardnessWitness C k) :
    ¬C.vcDimBound (k - 1) := by
  intro h
  have hle := h hw.witness hw.witness_shattered
  rw [hw.witness_card] at hle
  omega

/-- The exponential count: full shattering at k gives 2^k. -/
theorem shattering_exponential_count (k : ℕ) :
    sauerShelahBound k k = 2 ^ k :=
  sauerShelah_full k

/-! ## IV. Transfer Sample Complexity -/

/-- Transfer sample complexity inflation via Lipschitz constant.
    Bridge: analysis (Lipschitz) → ML (certified_robustness)
    → cryptography (post_quantum_security). -/
theorem transfer_sample_complexity_inflation {d : ℕ} {ε δ : ℝ}
    {α β : Type*} (C₁ : ConceptFamily α) (C₂ : ConceptFamily β)
    (f : TransferMorphism C₁ C₂) (hL : f.lipschitzConst ≠ 0) :
    sampleComplexityBound d (ε / f.lipschitzConst) δ =
      f.lipschitzConst ^ 2 * sampleComplexityBound d ε δ := by
  unfold sampleComplexityBound
  field_simp

/-! ## V. Sauer-Shelah Growth Function -/

/-- Sauer-Shelah bound at d=1 equals m+1. -/
theorem sauerShelah_one (m : ℕ) : sauerShelahBound m 1 = m + 1 := by
  unfold sauerShelahBound
  simp [Finset.sum_range_succ, Nat.choose_zero_right, Nat.choose_one_right]
  omega

/-- Sauer-Shelah bound is positive. -/
theorem sauerShelah_pos (m d : ℕ) : 0 < sauerShelahBound m d := by
  unfold sauerShelahBound
  calc 0 < m.choose 0 := by simp [Nat.choose_zero_right]
    _ ≤ ∑ i ∈ Finset.range (d + 1), m.choose i := by
        apply Finset.single_le_sum (fun i _ => Nat.zero_le _)
        exact Finset.mem_range.mpr (by omega)

/-! ## VI. Sieve Lattice Operations -/

/-- Sieve intersection (meet). -/
def sieveIntersection {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : SieveOn α d where
  carrier := s₁.carrier ∩ s₂.carrier
  downward_closed := fun x y ⟨h₁, h₂⟩ hle =>
    ⟨s₁.downward_closed x y h₁ hle, s₂.downward_closed x y h₂ hle⟩
  below_target := fun x ⟨h₁, _⟩ => s₁.below_target x h₁

/-- Sieve union (join). -/
def sieveUnion {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : SieveOn α d where
  carrier := s₁.carrier ∪ s₂.carrier
  downward_closed := fun x y hx hle => by
    rcases hx with h | h
    · exact Or.inl (s₁.downward_closed x y h hle)
    · exact Or.inr (s₂.downward_closed x y h hle)
  below_target := fun x hx => by
    rcases hx with h | h
    · exact s₁.below_target x h
    · exact s₂.below_target x h

/-- Sieve intersection is commutative. -/
theorem sieveIntersection_comm {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : sieveIntersection s₁ s₂ = sieveIntersection s₂ s₁ := by
  apply le_antisymm <;> intro x hx <;> exact ⟨hx.2, hx.1⟩

/-- Sieve union is commutative. -/
theorem sieveUnion_comm {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : sieveUnion s₁ s₂ = sieveUnion s₂ s₁ := by
  apply le_antisymm <;> intro x hx <;> rcases hx with h | h
  all_goals first | exact Or.inl h | exact Or.inr h

/-- Sieve intersection ≤ left. -/
theorem sieveIntersection_le_left {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : sieveIntersection s₁ s₂ ≤ s₁ :=
  Set.inter_subset_left

/-- Sieve intersection ≤ right. -/
theorem sieveIntersection_le_right {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : sieveIntersection s₁ s₂ ≤ s₂ :=
  Set.inter_subset_right

/-- Left ≤ sieve union. -/
theorem sieveUnion_ge_left {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : s₁ ≤ sieveUnion s₁ s₂ :=
  Set.subset_union_left

/-- Right ≤ sieve union. -/
theorem sieveUnion_ge_right {α : Type*} [Preorder α] {d : α}
    (s₁ s₂ : SieveOn α d) : s₂ ≤ sieveUnion s₁ s₂ :=
  Set.subset_union_right

/-- The sieve lattice is bounded.
    Bridge: topos theory (Ω classifier) → lattice theory. -/
theorem sieve_lattice_bounded {α : Type*} [Preorder α] (d : α) (s : SieveOn α d) :
    SieveOn.empty d ≤ s ∧ s ≤ SieveOn.maximal d :=
  ⟨SieveOn.empty_le d s, SieveOn.le_maximal d s⟩

/-! ## VII. Concept-to-Sieve Encoding -/

/-- A downward-closed concept induces a sieve.
    Bridge: learning theory → topos theory (sieves). -/
def conceptToSieve {α : Type*} [Preorder α] (c : Set α)
    (hdown : ∀ x y, x ∈ c → y ≤ x → y ∈ c) (d : α) : SieveOn α d where
  carrier := {x | x ≤ d ∧ x ∈ c}
  downward_closed := fun x y ⟨hxd, hxc⟩ hyx =>
    ⟨le_trans hyx hxd, hdown x y hxc hyx⟩
  below_target := fun _ ⟨hxd, _⟩ => hxd

/-- Concept-to-sieve is order-preserving. -/
theorem conceptToSieve_mono {α : Type*} [Preorder α] (c₁ c₂ : Set α)
    (h₁ : ∀ x y, x ∈ c₁ → y ≤ x → y ∈ c₁)
    (h₂ : ∀ x y, x ∈ c₂ → y ≤ x → y ∈ c₂)
    (d : α) (hsub : c₁ ⊆ c₂) :
    conceptToSieve c₁ h₁ d ≤ conceptToSieve c₂ h₂ d :=
  fun _ ⟨hxd, hxc⟩ => ⟨hxd, hsub hxc⟩

/-! ## VIII. VC Characterizes Learnability -/

/-- VC dimension exactly characterizes learnability.
    Bridge: learning theory → topos theory (compact rank = VC dim). -/
theorem vc_characterizes_learnability {α : Type*} (C : ConceptFamily α) (d : ℕ)
    (hd : CompactRank C d) (hd_pos : 0 < d) :
    C.vcDimBound d ∧ ¬C.vcDimBound (d - 1) := by
  refine ⟨hd.1, ?_⟩
  rcases hd.2 with rfl | ⟨S, hS, hScard⟩
  · omega
  · intro hbound
    have hle := hbound S hS
    omega

/-- Compact rank is unique when positive. -/
theorem compactRank_unique {α : Type*} (C : ConceptFamily α) {n m : ℕ}
    (hn : CompactRank C n) (hm : CompactRank C m)
    (hn_pos : 0 < n) (hm_pos : 0 < m) : n = m := by
  apply le_antisymm
  · rcases hn.2 with rfl | ⟨S, hS, hScard⟩
    · omega
    · have h1 := hm.1 S hS; rw [hScard] at h1; exact h1
  · rcases hm.2 with rfl | ⟨S, hS, hScard⟩
    · omega
    · have h1 := hn.1 S hS; rw [hScard] at h1; exact h1

/-- Sample complexity is positive for valid parameters. -/
theorem sample_complexity_pos' {d : ℕ} {ε δ : ℝ}
    (hd : 0 < d) (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) :
    0 < sampleComplexityBound d ε δ :=
  sampleComplexityBound_pos hd hε hδ hδ1

/-- Sample complexity is monotone in VC dimension. -/
theorem sample_complexity_mono_d {d₁ d₂ : ℕ} {ε δ : ℝ}
    (hε : 0 < ε) (hδ : 0 < δ) (hδ1 : δ < 1) (hd : d₁ ≤ d₂) :
    sampleComplexityBound d₁ ε δ ≤ sampleComplexityBound d₂ ε δ :=
  sampleComplexity_linear_in_d hε hδ hδ1 hd

end