import Mathlib

/-!
# Contrarian tests around weak and strong Boolean-cube avoidance

This file formalizes two general obstructions to a weak copy of the Boolean lattice
`B_d`, and an explicit strong-copy construction.  The rank-support theorem strengthens
the usual consecutive-layer argument: the occupied ranks need not be consecutive.
The small-family theorem gives a different obstruction and disproves the tempting
claim that merely meeting `d+1` ranks forces a copy of `B_d`.
-/

open Finset
open scoped Classical

namespace B3FreeContrarian

/-- A weak copy of `B_d` in a finite family of finite sets. -/
def ContainsWeakCube {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) : Prop :=
  ∃ f : Finset (Fin d) → Finset α,
    Function.Injective f ∧
    (∀ A, f A ∈ F) ∧
    ∀ ⦃A B⦄, A ⊂ B → f A ⊂ f B

/-- A strong (induced) copy of `B_d`. -/
def ContainsStrongCube {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) : Prop :=
  ∃ f : Finset (Fin d) → Finset α,
    Function.Injective f ∧
    (∀ A, f A ∈ F) ∧
    ∀ A B, (A ⊂ B ↔ f A ⊂ f B)

abbrev WeakCubeFree {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) := ¬ ContainsWeakCube d F

abbrev StrongCubeFree {α : Type*} [DecidableEq α]
    (d : ℕ) (F : Finset (Finset α)) := ¬ ContainsStrongCube d F

/-
Every strong copy is weak.
-/
theorem strongCopy_is_weakCopy {α : Type*} [DecidableEq α]
    {d : ℕ} {F : Finset (Finset α)} :
    ContainsStrongCube d F → ContainsWeakCube d F := by
  rintro ⟨ f, hf ⟩;
  exact ⟨ f, hf.1, hf.2.1, fun A B hAB => hf.2.2 A B |>.1 hAB ⟩

/-- Initial segments form a canonical maximal chain in `B_d`. -/
def initialSegment (d k : ℕ) : Finset (Fin d) :=
  Finset.univ.filter fun i => (i : ℕ) < k

lemma initialSegment_ssubset {d k : ℕ} (hk : k < d) :
    initialSegment d k ⊂ initialSegment d (k + 1) := by
  simp +decide [ initialSegment, Finset.ssubset_def ];
  simp +decide [ Finset.subset_iff, le_iff_lt_or_eq ];
  exact ⟨ fun x hx => Or.inl hx, ⟨ ⟨ k, hk ⟩, Or.inr rfl, Or.inr rfl ⟩ ⟩

/-
Along the canonical chain, a weak embedding has strictly increasing ranks.
-/
lemma embedded_chain_rank_strict {α : Type*} [DecidableEq α] {d : ℕ}
    (f : Finset (Fin d) → Finset α)
    (hf : ∀ ⦃A B⦄, A ⊂ B → f A ⊂ f B)
    {i j : ℕ} (hij : i < j) (hj : j ≤ d) :
    (f (initialSegment d i)).card < (f (initialSegment d j)).card := by
  induction' hij with k hk;
  · exact Finset.card_lt_card ( hf ( initialSegment_ssubset ( Nat.lt_of_succ_le hj ) ) );
  · exact lt_trans ( by solve_by_elim [ Nat.le_of_succ_le ] ) ( Finset.card_lt_card ( hf ( initialSegment_ssubset ( by linarith ) ) ) )

/-
**Arbitrary-rank obstruction.** If a family occupies at most `d` cardinality
ranks (not necessarily consecutive), then it has no weak `B_d`.
-/
theorem rankSupport_weakCubeFree {α : Type*} [DecidableEq α]
    {d : ℕ} (F : Finset (Finset α)) (R : Finset ℕ)
    (hR : R.card ≤ d) (hsupport : ∀ A ∈ F, A.card ∈ R) :
    WeakCubeFree d F := by
  intro h
  obtain ⟨f, hf_inj, hf_F, hf_strict⟩ := h
  have h_card : ∀ i : Fin (d + 1), (f (initialSegment d i)).card ∈ R := by
    exact fun i => hsupport _ ( hf_F _ );
  have h_distinct : ∀ i j : Fin (d + 1), i ≠ j → (f (initialSegment d i)).card ≠ (f (initialSegment d j)).card := by
    intro i j hij h_eq
    have h_lt : i.val < j.val ∨ j.val < i.val := by
      exact lt_or_gt_of_ne ( by simpa [ Fin.ext_iff ] using hij )
    cases' h_lt with h_lt h_lt
    generalize_proofs at *;
    · have := @embedded_chain_rank_strict α _ d f hf_strict i.val j.val h_lt ( by linarith [ Fin.is_lt j ] ) ; aesop;
    · have := @embedded_chain_rank_strict α _ d f hf_strict j i h_lt ( by linarith [ Fin.is_lt i, Fin.is_lt j ] ) ; aesop;
  exact absurd ( Finset.card_le_card ( show Finset.image ( fun i : Fin ( d + 1 ) => # ( f ( initialSegment d i ) ) ) Finset.univ ⊆ R from Finset.image_subset_iff.mpr fun i _ => h_card i ) ) ( by rw [ Finset.card_image_of_injective _ fun i j hij => not_imp_not.mp ( h_distinct i j ) hij ] ; simp +decide ; linarith )

/-
In particular, any family occupying any three ranks is weakly `B₃`-free.
-/
theorem anyThreeRanks_weakB3Free {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (R : Finset ℕ)
    (hR : R.card ≤ 3) (hsupport : ∀ A ∈ F, A.card ∈ R) :
    WeakCubeFree 3 F := by
  convert rankSupport_weakCubeFree F R hR hsupport

/-
The same arbitrary-three-rank obstruction excludes strong copies.
-/
theorem anyThreeRanks_strongB3Free {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (R : Finset ℕ)
    (hR : R.card ≤ 3) (hsupport : ∀ A ∈ F, A.card ∈ R) :
    StrongCubeFree 3 F := by
  exact fun h => anyThreeRanks_weakB3Free F R hR hsupport ( strongCopy_is_weakCopy h )

/-
A weak copy needs all `2^d` of its elements, so cardinality alone can rule it out.
-/
theorem smallFamily_weakCubeFree {α : Type*} [DecidableEq α]
    {d : ℕ} (F : Finset (Finset α)) (hsmall : F.card < 2 ^ d) :
    WeakCubeFree d F := by
  intro h
  obtain ⟨f, hf_inj, hf_mem, hf_strict⟩ := h
  have h_card : (Finset.univ : Finset (Finset (Fin d))).card ≤ F.card := by
    exact Finset.card_le_card ( show Finset.image f Finset.univ ⊆ F from Finset.image_subset_iff.2 fun A _ => hf_mem A ) |> le_trans ( by rw [ Finset.card_image_of_injective _ hf_inj ] ) ;
  have h_card_false : (Finset.univ : Finset (Finset (Fin d))).card = 2 ^ d := by
    simp +decide [ Finset.card_univ ]
  linarith [h_card, h_card_false]

/-- Four sets meeting all four ranks `0,1,2,3`.  This is the promised counterexample
to the conjecture that meeting four ranks forces a weak `B₃`. -/
def fourRankChain : Finset (Finset (Fin 3)) :=
  {initialSegment 3 0, initialSegment 3 1,
   initialSegment 3 2, initialSegment 3 3}

/-
The four-rank chain really meets each of the four ranks.
-/
theorem fourRankChain_rank_witness (k : ℕ) (hk : k ≤ 3) :
    ∃ A ∈ fourRankChain, A.card = k := by
  interval_cases k
  · exact ⟨initialSegment 3 0, by simp [fourRankChain], by decide⟩
  · exact ⟨initialSegment 3 1, by simp [fourRankChain], by decide⟩
  · exact ⟨initialSegment 3 2, by simp [fourRankChain], by decide⟩
  · exact ⟨initialSegment 3 3, by simp [fourRankChain], by decide⟩

/-
**Disproof:** occupying `d+1` ranks does not force `B_d`; already for `d=3`,
the four-rank maximal chain is weakly `B₃`-free.
-/
theorem fourRanks_do_not_force_weakB3 : WeakCubeFree 3 fourRankChain := by
  convert smallFamily_weakCubeFree _ _ ; simp +decide

/-- An affine Boolean cube generated by independent points over a base set. -/
def affineCube {α : Type*} [DecidableEq α] (d : ℕ)
    (base : Finset α) (g : Fin d → α) : Finset (Finset α) :=
  Finset.univ.image fun A : Finset (Fin d) => base ∪ A.image g

/-
**Explicit strong-copy construction.** Distinct generators outside the base
produce a strong copy of `B_d`; inclusion is both preserved and reflected.
-/
theorem affineCube_containsStrongCube {α : Type*} [DecidableEq α]
    (d : ℕ) (base : Finset α) (g : Fin d → α)
    (hinj : Function.Injective g) (hfresh : ∀ i, g i ∉ base) :
    ContainsStrongCube d (affineCube d base g) := by
  refine' ⟨ _, _, _, _ ⟩;
  refine' fun A => base ∪ A.image g;
  · intro A B hAB;
    simp_all +decide [Finset.ext_iff];
    intro i; specialize hAB ( g i ) ; simp_all +decide [ hinj.eq_iff ] ;
  · exact fun A => Finset.mem_image_of_mem _ ( Finset.mem_univ _ );
  · intro A B; constructor <;> intro h <;> simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ] ;
    · exact ⟨ fun x hx => Or.imp id ( fun ⟨ a, ha, hx ⟩ => ⟨ a, h.1 ha, hx ⟩ ) hx, g h.2.choose, Or.inr ⟨ h.2.choose, h.2.choose_spec.1, rfl ⟩, hfresh _, fun a ha => hinj.ne ( ne_of_mem_of_not_mem ha h.2.choose_spec.2 ) ⟩;
    · grind +splitImp

/-
Consequently, the full power set on `Fin d` contains a strong `B_d`.
-/
theorem powerset_containsStrongCube (d : ℕ) :
    ContainsStrongCube d (Finset.univ : Finset (Fin d)).powerset := by
  refine' ⟨ fun A => A.image ( fun i : Fin d ↦ i ), _, _, _ ⟩ <;> simp +decide [ Function.Injective ]

end B3FreeContrarian