/-
# Frankl's Union-Closed Conjecture: Definitions and Foundational Results

This file establishes the core definitions for Frankl's conjecture on
union-closed set families, along with basic structural and counting lemmas.

Frankl's conjecture (1979) states that for every finite union-closed family
of sets, there exists an element belonging to at least half the sets.
-/
import Mathlib

open Finset

/-- A family of finite sets is union-closed if it is closed under pairwise union. -/
def UnionClosed {α : Type*} [DecidableEq α] (F : Finset (Finset α)) : Prop :=
  ∀ ⦃A⦄, A ∈ F → ∀ ⦃B⦄, B ∈ F → A ∪ B ∈ F

/-- The abundance of an element `x` in a family `F` is the number of sets in `F`
    containing `x`. -/
def abundance {α : Type*} [DecidableEq α] (F : Finset (Finset α)) (x : α) : ℕ :=
  (F.filter (x ∈ ·)).card

/-- Frankl's property: there exists an element appearing in at least half the sets. -/
def FranklProperty {α : Type*} [DecidableEq α] (F : Finset (Finset α)) : Prop :=
  ∃ x, 2 * abundance F x ≥ F.card

/-- The universe of a family is the union of all its member sets. -/
def familyUniverse {α : Type*} [DecidableEq α] (F : Finset (Finset α)) : Finset α :=
  F.biUnion id

/-! ## Basic abundance lemmas -/

/-
Abundance is bounded by the family size.
-/
theorem abundance_le_card {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (x : α) :
    abundance F x ≤ F.card := by
  exact Finset.card_filter_le _ _

/-
Abundance equals the indicator sum over the family.
-/
theorem abundance_eq_sum {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (x : α) :
    abundance F x = ∑ s ∈ F, if x ∈ s then 1 else 0 := by
  simp +decide only [abundance, card_filter]

/-! ## Double-counting identity -/

/-
The sum of set sizes equals the sum of abundances over the full type.
    This is the fundamental double-counting identity for set families.
-/
theorem sum_card_eq_sum_abundance {α : Type*} [Fintype α] [DecidableEq α]
    (F : Finset (Finset α)) :
    ∑ s ∈ F, s.card = ∑ x : α, abundance F x := by
  simp +decide only [abundance_eq_sum];
  rw [ Finset.sum_comm, Finset.sum_congr rfl ] ; aesop

/-! ## Structural lemmas -/

/-
Every set in the family is a subset of the family's universe.
-/
theorem subset_familyUniverse {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (s : Finset α) (hs : s ∈ F) :
    s ⊆ familyUniverse F := by
  exact Finset.subset_iff.2 fun x hx => Finset.mem_biUnion.2 ⟨ s, hs, hx ⟩

/-
The universe of a union-closed nonempty family belongs to the family.
-/
theorem unionClosed_contains_universe {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hne : F.Nonempty) :
    familyUniverse F ∈ F := by
  have h_sup_mem : ∀ (s : Finset (Finset α)), s.Nonempty → s ⊆ F → s.sup id ∈ F := by
    intro s hs hsub
    induction' s using Finset.cons_induction with a s ha ih;
    · exact False.elim ( Finset.not_nonempty_empty hs );
    · by_cases hs : s.Nonempty <;> simp_all +decide [ Finset.sup_cons, hUC ];
      exact hUC ( hsub ( Finset.mem_insert_self _ _ ) ) ( ih ( Finset.Subset.trans ( Finset.subset_insert _ _ ) hsub ) );
  convert h_sup_mem F hne ( Finset.Subset.refl F ) using 1;
  unfold familyUniverse; aesop;

/-! ## Average-size and pigeonhole -/

/-
If the average set size is at least half the universe, some element is abundant.
    Requires the universe to be nonempty (otherwise there are no elements to be abundant).
-/
theorem exists_abundant_of_sum_large {α : Type*} [Fintype α] [DecidableEq α]
    (F : Finset (Finset α))
    [Nonempty α]
    (h : Fintype.card α * F.card ≤ 2 * ∑ s ∈ F, s.card) :
    ∃ x : α, 2 * abundance F x ≥ F.card := by
  contrapose! h;
  -- Apply the assumption `h` to each element in the sum.
  have h_sum : ∑ x : α, 2 * abundance F x < ∑ x : α, F.card := by
    exact Finset.sum_lt_sum_of_nonempty ( Finset.univ_nonempty ) fun x _ => h x;
  simp_all +decide [ Finset.mul_sum _ _ _, sum_card_eq_sum_abundance ]

/-
Sum of set sizes is bounded by family size times universe size.
-/
theorem sum_card_le_card_mul {α : Type*} [Fintype α] [DecidableEq α]
    (F : Finset (Finset α)) :
    ∑ s ∈ F, s.card ≤ F.card * Fintype.card α := by
  exact le_trans ( Finset.sum_le_sum fun _ _ => Finset.card_le_univ _ ) ( by simp +decide )

/-! ## Lattice reformulation -/

/-
Union-closure is the same as sup-closure in the Finset lattice.
-/
theorem unionClosed_iff_supClosed {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) :
    UnionClosed F ↔ ∀ ⦃A⦄, A ∈ F → ∀ ⦃B⦄, B ∈ F → A ⊔ B ∈ F := by
  exact Iff.symm (Eq.to_iff rfl)

/-! ## Small family cases -/

/-
A singleton family with a nonempty member satisfies Frankl's property.
    Note: {∅} does NOT satisfy Frankl's property, so we need the member to be nonempty.
-/
theorem frankl_card_one_of_nonempty_member {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hcard : F.card = 1)
    (hne : ∃ s ∈ F, s.Nonempty) :
    FranklProperty F := by
  obtain ⟨ s, hs₁, hs₂ ⟩ := hne;
  obtain ⟨ x, hx ⟩ := hs₂;
  rw [ Finset.card_eq_one ] at hcard;
  obtain ⟨ y, rfl ⟩ := hcard; simp_all +decide [ FranklProperty ] ;
  exact ⟨ x, by rw [ abundance ] ; exact Nat.mul_pos ( by decide ) ( Finset.card_pos.mpr ⟨ y, by aesop ⟩ ) ⟩

/-
A two-element union-closed family satisfies Frankl's property.
-/
theorem frankl_card_two {α : Type*} [DecidableEq α]
    (F : Finset (Finset α))
    (hUC : UnionClosed F)
    (hcard : F.card = 2)
    (hne : F.Nonempty) :
    FranklProperty F := by
  -- Since F has exactly two elements, we can consider the following cases:
  -- Case 1: A ⊆ B
  -- Case 2: B ⊆ A
  -- Case 3: A = B
  by_cases h_case1 : ∃ A B : Finset α, A ∈ F ∧ B ∈ F ∧ A ≠ B ∧ A ⊆ B;
  · obtain ⟨ A, B, hA, hB, hne, hAB ⟩ := h_case1
    have hF_eq : F = {A, B} := by
      rw [ Finset.eq_of_subset_of_card_le ( Finset.insert_subset_iff.mpr ⟨ hA, Finset.singleton_subset_iff.mpr hB ⟩ ) ( by simp +decide [ *, Finset.card_insert_of_notMem ] ) ];
    -- Since $B$ is nonempty, we can pick an element $x \in B$.
    obtain ⟨x, hx⟩ : ∃ x, x ∈ B := by
      exact Finset.nonempty_of_ne_empty ( by aesop_cat );
    exact ⟨ x, by rw [ hF_eq, abundance ] ; rw [ Finset.filter_insert, Finset.filter_singleton ] ; aesop ⟩;
  · rw [ Finset.card_eq_two ] at hcard;
    obtain ⟨ A, B, hne, rfl ⟩ := hcard; have := hUC ( Finset.mem_insert_self _ _ ) ( Finset.mem_insert_of_mem ( Finset.mem_singleton_self _ ) ) ; simp_all +decide ;