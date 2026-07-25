import Mathlib

/-!
# Closure–Matroid–Secret Sharing Bridge

## Overview

This module establishes a formal bridge between finite exchange closure operators,
matroid geometry, and cryptographic secret-sharing access structures, mediated by
an idempotent algebraic structure on closed sets.

## Main results

- **Exchange closures induce matroidal geometry**: independence, rank, flats, and circuits
  arise canonically from the closure axioms.
- **Certified access structures**: for a designated "dealer" element `d`, the set of
  subsets that span `d` under closure forms a monotone access structure with
  formally certified reconstruction (qualified sets are upward-closed) and
  privacy (non-spanning sets are downward-closed).
- **Minimal qualified sets are minimal dependent sets through the dealer**: the
  circuit-like characterization of minimal reconstruction sets.
- **Rank-bounded reconstruction**: every qualified set contains a minimal qualified
  subset of cardinality at most the global rank.
- **Idempotent closed-set algebra**: closed sets form a lattice under join = closure
  of union and meet = intersection, with provable algebraic laws.

## Mathematical significance

Every finite exchange closure is not just a combinatorial geometry, but a certified
cryptographic universe in which reconstruction, privacy, and complexity are all
controlled by closure and rank. This reframes secret-sharing as resource-sensitive
entailment in a finite closure logic, with matroids providing the geometric backbone.
-/

open Set Finset

variable {X : Type*} [Fintype X] [DecidableEq X]

/-! ## 1. Finitary Exchange Closure Structure -/

/-- A finitary exchange closure operator on a finite type.
This is the standard axiomatization that gives rise to matroid geometry. -/
structure FinitaryExchangeClosure (X : Type*) [Fintype X] where
  /-- The closure operator -/
  cl : Set X → Set X
  /-- Every set is contained in its closure -/
  extensive : ∀ A, A ⊆ cl A
  /-- Closure is monotone -/
  monotone : ∀ {A B : Set X}, A ⊆ B → cl A ⊆ cl B
  /-- Closure is idempotent -/
  idempotent : ∀ A, cl (cl A) = cl A
  /-- The Steinitz–Mac Lane exchange axiom -/
  exchange : ∀ A x y, x ∉ cl A → x ∈ cl (A ∪ {y}) → y ∈ cl (A ∪ {x})

namespace FinitaryExchangeClosure

variable (C : FinitaryExchangeClosure X)

/-! ## 2. Basic Definitions -/

/-- A set is closed if it equals its own closure. -/
def Closed (A : Set X) : Prop := C.cl A = A

/-- A set is independent if no element is in the closure of the rest. -/
def Independent (A : Set X) : Prop :=
  ∀ x ∈ A, x ∉ C.cl (A \ {x})

/-- A set qualifies for reconstruction of dealer `d` if `d` is in its closure. -/
def Qualified (d : X) (A : Set X) : Prop := d ∈ C.cl A

/-- A set is private w.r.t. dealer `d` if `d` is not in its closure. -/
def Private (d : X) (A : Set X) : Prop := d ∉ C.cl A

/-- A minimal qualified set: qualifies, but no proper subset does. -/
def MinimalQualified (d : X) (A : Set X) : Prop :=
  C.Qualified d A ∧ ∀ B, B ⊂ A → C.Private d B

/-- Dependent set: not independent -/
def Dependent (A : Set X) : Prop := ¬C.Independent A

/-- Circuit: minimally dependent -/
def IsCircuit (A : Set X) : Prop :=
  C.Dependent A ∧ ∀ B, B ⊂ A → C.Independent B

/-! ## 3. Basic Closure Lemmas -/

/-- The closure of a set is closed. -/
theorem closed_cl (A : Set X) : C.Closed (C.cl A) := by
  exact C.idempotent A

/-- The universe is closed. -/
theorem closed_univ : C.Closed Set.univ := by
  unfold Closed
  exact Set.eq_univ_of_univ_subset (C.extensive Set.univ)

/-
Closure of union absorbs inner closures (left).
-/
theorem cl_union_cl_left (A B : Set X) :
    C.cl (C.cl A ∪ B) = C.cl (A ∪ B) := by
  apply Set.eq_of_subset_of_subset;
  · have h_closure_union : C.cl A ∪ B ⊆ C.cl (A ∪ B) := by
      simp +decide [ Set.union_subset_iff, C.monotone, C.extensive ];
      exact fun x hx => C.extensive _ ( Set.mem_union_right _ hx );
    exact C.monotone h_closure_union |> Set.Subset.trans <| by simp +decide [ C.idempotent ] ;
  · exact C.monotone ( Set.union_subset_union ( C.extensive _ ) le_rfl )

/-
Closure of union absorbs inner closures (right).
-/
theorem cl_union_cl_right (A B : Set X) :
    C.cl (A ∪ C.cl B) = C.cl (A ∪ B) := by
  have := C.cl_union_cl_left B A; simp_all +decide [ Set.union_comm, Set.union_left_comm ] ;

/-
If `A ⊆ cl B` then `cl A ⊆ cl B`.
-/
theorem cl_subset_cl_of_subset_cl {A B : Set X} (h : A ⊆ C.cl B) :
    C.cl A ⊆ C.cl B := by
  have := C.monotone h;
  rwa [ C.idempotent ] at this

/-- Closure is monotone (named for dot notation). -/
theorem cl_mono {A B : Set X} (h : A ⊆ B) : C.cl A ⊆ C.cl B :=
  C.monotone h

/-
`x ∈ cl A` iff `cl (A ∪ {x}) = cl A`.
-/
theorem mem_cl_iff_cl_insert (A : Set X) (x : X) :
    x ∈ C.cl A ↔ C.cl (A ∪ {x}) = C.cl A := by
  refine' ⟨ fun hx => _, fun hx => _ ⟩;
  · refine' Set.Subset.antisymm _ _;
    · exact C.cl_subset_cl_of_subset_cl ( Set.union_subset ( C.extensive _ ) ( Set.singleton_subset_iff.2 hx ) );
    · exact C.cl_mono ( Set.subset_union_left );
  · exact hx ▸ C.extensive _ ( Set.mem_union_right _ ( Set.mem_singleton _ ) )

/-! ## 4. Independence Lemmas -/

/-- The empty set is independent. -/
theorem independent_empty : C.Independent ∅ := by
  intro x hx; simp at hx

/-
Subsets of independent sets are independent (hereditary property).
-/
theorem independent_subset {A B : Set X} (hA : C.Independent A) (hB : B ⊆ A) :
    C.Independent B := by
  intro x hx;
  have := hA x ( hB hx );
  exact fun h => this ( C.cl_mono ( Set.diff_subset_diff_left hB ) h )

/-
If `I` is independent and `x ∉ cl I`, then `I ∪ {x}` is independent.
-/
theorem independent_insert_of_not_mem_cl {I : Set X} {x : X}
    (hI : C.Independent I) (hx : x ∉ C.cl I) :
    C.Independent (I ∪ {x}) := by
  intro y hy; by_cases hyx : y = x <;> simp_all +decide [ Set.union_comm ] ;
  · exact fun h => hx ( C.cl_mono ( Set.diff_subset ) h );
  · -- Since $y \in I$ and $y \neq x$, we have $I \setminus \{y\} \cup \{x\} \subseteq I \cup \{x\}$.
    have h_subset : insert x I \ {y} = insert x (I \ {y}) := by
      grind;
    have := C.exchange ( I \ { y } ) y x; simp_all +decide [ Set.insert_subset_iff ] ;
    exact this ( hI y hy )

/-
If `A` is independent, then `x ∈ cl A` iff `x ∈ A` or `A ∪ {x}` is dependent.
-/
theorem mem_cl_iff_dep_or_mem {A : Set X} (hA : C.Independent A) (x : X) :
    x ∈ C.cl A ↔ x ∈ A ∨ ¬C.Independent (A ∪ {x}) := by
  constructor <;> intro h;
  · by_cases hx : x ∈ A <;> simp_all +decide [ FinitaryExchangeClosure.Independent ];
  · contrapose! h;
    exact ⟨ fun hx => h ( C.extensive _ hx ), C.independent_insert_of_not_mem_cl hA h ⟩

/-! ## 5. Secret-Sharing Access Structure (Theorem 4) -/

/-
**Certified Access Structure**: qualification is upward-closed,
    private is downward-closed, and they partition all subsets.
    This is the foundational theorem for closure-based secret sharing.
-/
theorem canonical_access_structure (d : X) :
    (∀ {A B : Set X}, A ⊆ B → C.Qualified d A → C.Qualified d B) ∧
    (∀ A : Set X, C.Qualified d A ↔ ¬C.Private d A) ∧
    (∀ A : Set X, C.Private d A → ∀ B ⊆ A, C.Private d B) := by
  refine' ⟨ _, _, _ ⟩;
  · exact fun hA hB => C.monotone hA hB;
  · exact fun A => by unfold FinitaryExchangeClosure.Qualified FinitaryExchangeClosure.Private; tauto;
  · exact fun A hA B hB => fun h => hA <| C.cl_mono hB h

/-
**Certified Privacy**: non-spanning sets cannot leak the dealer.
    This is the exact privacy guarantee: no subset of a private set is qualified.
-/
theorem privacy_certified_by_nonspanning (d : X) (A : Set X) :
    C.Private d A → ∀ B ⊆ A, C.Private d B := by
  exact fun hA B hBA => fun hB => hA <| C.cl_mono hBA hB

/-
**Reconstruction monotonicity**: if a subset can reconstruct, so can any superset.
-/
theorem qualified_monotone (d : X) {A B : Set X} (h : A ⊆ B) (hA : C.Qualified d A) :
    C.Qualified d B := by
  exact C.cl_mono h hA

/-! ## 6. Rank Function -/

/-- The rank of a set is the maximum cardinality of an independent subset.
    Well-defined for finite types. -/
noncomputable def rank (A : Set X) : ℕ :=
  sSup {n : ℕ | ∃ I : Finset X, (↑I : Set X) ⊆ A ∧ C.Independent (↑I) ∧ I.card = n}

/-
Rank is bounded by cardinality.
-/
theorem rank_le_ncard (A : Set X) (hA : A.Finite) :
    C.rank A ≤ hA.toFinset.card := by
  refine' csSup_le' _;
  rintro n ⟨ I, hI₁, hI₂, rfl ⟩;
  exact Finset.card_le_card fun x hx => by aesop;

/-
Rank is monotone.
-/
theorem rank_monotone {A B : Set X} (h : A ⊆ B) : C.rank A ≤ C.rank B := by
  apply_rules [ csSup_le_csSup ];
  · exact ⟨ _, fun n hn => hn.choose_spec.2.2 ▸ Finset.card_le_univ _ ⟩;
  · exact ⟨ 0, ⟨ ∅, by simp +decide, by simp +decide [ C.independent_empty ], by simp +decide ⟩ ⟩;
  · exact fun n hn => by obtain ⟨ I, hI₁, hI₂, rfl ⟩ := hn; exact ⟨ I, hI₁.trans h, hI₂, rfl ⟩ ;

/-
The empty set has rank zero.
-/
theorem rank_empty : C.rank (∅ : Set X) = 0 := by
  unfold FinitaryExchangeClosure.rank;
  rw [ @csSup_eq_of_forall_le_of_forall_lt_exists_gt ];
  · exact ⟨ 0, ⟨ ∅, by simp +decide, by simp +decide [ FinitaryExchangeClosure.independent_empty ] ⟩ ⟩;
  · aesop;
  · grind

/-
Rank of a singleton is at most 1.
-/
theorem rank_singleton_le (x : X) : C.rank ({x} : Set X) ≤ 1 := by
  convert C.rank_le_ncard { x } _ using 1;
  swap;
  exacts [ Set.finite_singleton x, by simp +decide ]

/-
The set of cardinalities of independent subsets of A is bounded above.
-/
theorem rank_set_bddAbove (A : Set X) :
    BddAbove {n : ℕ | ∃ I : Finset X, (↑I : Set X) ⊆ A ∧ C.Independent (↑I) ∧ I.card = n} := by
  exact ⟨ Fintype.card X, by rintro n ⟨ I, hI₁, hI₂, rfl ⟩ ; exact Finset.card_le_univ _ ⟩

/-
The set of cardinalities of independent subsets of A is nonempty.
-/
theorem rank_set_nonempty (A : Set X) :
    {n : ℕ | ∃ I : Finset X, (↑I : Set X) ⊆ A ∧ C.Independent (↑I) ∧ I.card = n}.Nonempty := by
  -- The empty set is a finite subset of A and is independent.
  use 0
  use ∅
  simp [C.independent_empty]

/-
The rank of a set is achieved by some independent subset.
-/
theorem rank_achieved (A : Set X) :
    ∃ I : Finset X, (↑I : Set X) ⊆ A ∧ C.Independent (↑I) ∧ I.card = C.rank A := by
  convert Nat.sSup_mem ?_ ?_;
  any_goals exact { n | ∃ I : Finset X, ( I : Set X ) ⊆ A ∧ C.Independent ( I : Set X ) ∧ I.card = n };
  · exact?;
  · exact?;
  · exact ⟨ _, fun n hn => hn.choose_spec.2.2 ▸ Finset.card_le_univ _ ⟩

/-
A rank-achieving independent subset spans the whole set under closure.
-/
theorem spanning_of_rank_achieving {A : Set X} {I : Finset X}
    (hI_sub : (↑I : Set X) ⊆ A) (hI_ind : C.Independent (↑I))
    (hI_rank : I.card = C.rank A) :
    A ⊆ C.cl (↑I) := by
  intro y hyA;
  by_contra hy_not_cl;
  have h_indep : C.Independent (I ∪ {y}) := by
    exact?;
  have h_card : (I ∪ {y}).card = I.card + 1 := by
    exact Finset.card_union_of_disjoint ( Finset.disjoint_singleton_right.mpr fun h => hy_not_cl <| C.extensive _ h );
  have h_card_le : (I ∪ {y}).card ≤ C.rank A := by
    apply le_csSup;
    · exact ⟨ Finset.card ( Finset.univ : Finset X ), fun n hn => by obtain ⟨ I, hI_sub, hI_ind, rfl ⟩ := hn; exact Finset.card_le_univ _ ⟩;
    · exact ⟨ I ∪ { y }, by aesop_cat, by simpa using h_indep, by aesop_cat ⟩;
  grind +splitImp

/-! ## 7. Closed Sets and Flats (Theorem 2) -/

/-
A closed set `F` has the property that adding any element outside `F` strictly
    increases the rank. This characterizes flats / dependency flats.
-/
theorem closed_iff_rank_strict_increase (F : Set X) :
    C.Closed F ↔ ∀ x ∉ F, C.rank (F ∪ {x}) = C.rank F + 1 := by
  constructor;
  · intro hF x hx
    have h_insert : C.rank (F ∪ {x}) ≥ C.rank F + 1 := by
      obtain ⟨ I, hI_sub, hI_ind, hI_rank ⟩ := C.rank_achieved F;
      have h_insert : C.Independent (↑I ∪ {x}) := by
        apply C.independent_insert_of_not_mem_cl hI_ind;
        have h_cl_I_subset_F : C.cl (↑I) ⊆ F := by
          have h_cl_I_subset_F : C.cl (↑I) ⊆ C.cl F := by
            exact C.cl_mono hI_sub;
          exact h_cl_I_subset_F.trans ( hF.symm ▸ Set.Subset.refl _ );
        exact fun h => hx <| h_cl_I_subset_F h;
      refine' le_csSup _ _;
      · exact ⟨ _, fun n hn => hn.choose_spec.2.2 ▸ Finset.card_le_univ _ ⟩;
      · refine' ⟨ Insert.insert x I, _, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff, Set.subset_def ];
        rw [ Finset.card_insert_of_notMem ( fun h => hx ( hI_sub x h ) ), hI_rank ];
    refine' le_antisymm _ h_insert;
    refine' csSup_le' _;
    rintro n ⟨ I, hI₁, hI₂, rfl ⟩;
    by_cases hxI : x ∈ I;
    · have hI_minus_x : (I.erase x : Set X) ⊆ F := by
        intro y hy; specialize hI₁ ( Finset.mem_of_mem_erase hy ) ; aesop;
      have hI_minus_x_rank : (I.erase x).card ≤ C.rank F := by
        exact le_csSup ( C.rank_set_bddAbove F ) ⟨ I.erase x, hI_minus_x, C.independent_subset hI₂ ( by aesop ), rfl ⟩;
      rw [ Finset.card_erase_of_mem hxI ] at hI_minus_x_rank ; omega;
    · exact le_add_of_le_of_nonneg ( le_csSup ( C.rank_set_bddAbove F ) ⟨ I, fun y hy => by have := hI₁ hy; aesop, hI₂, rfl ⟩ ) zero_le_one;
  · intro h
    by_contra h_not_closed
    obtain ⟨x, hx⟩ : ∃ x, x ∈ C.cl F ∧ x ∉ F := by
      exact Set.exists_of_ssubset ( lt_of_le_of_ne ( C.extensive F ) ( Ne.symm h_not_closed ) )
    generalize_proofs at *;
    -- By rank_achieved, get J ⊆ F ∪ {x} independent with J.card = rank F + 1.
    obtain ⟨J, hJ_sub, hJ_ind, hJ_card⟩ : ∃ J : Finset X, (↑J : Set X) ⊆ F ∪ {x} ∧ C.Independent (↑J) ∧ J.card = C.rank (F ∪ {x}) := by
      exact?
    generalize_proofs at *;
    -- Since J is independent and x ∈ J, we have J \ {x} ⊆ F is independent with (J \ {x}).card = rank F.
    have hJ_erase_ind : C.Independent (↑(J.erase x)) := by
      exact C.independent_subset hJ_ind ( by aesop_cat )
    have hJ_erase_card : (J.erase x).card = C.rank F := by
      by_cases hxJ : x ∈ J <;> simp_all +decide [ Finset.card_erase_of_mem ];
      have hJ_subset_F : (J : Set X) ⊆ F := by
        grind
      generalize_proofs at *;
      have hJ_card_le : J.card ≤ C.rank F := by
        exact le_csSup ( C.rank_set_bddAbove F ) ⟨ J, hJ_subset_F, hJ_ind, rfl ⟩
      generalize_proofs at *;
      linarith;
    generalize_proofs at *;
    -- By spanning_of_rank_achieving applied to F and J.erase x, F ⊆ cl(↑(J.erase x)).
    have hF_subset_cl_J_erase : F ⊆ C.cl (↑(J.erase x)) := by
      apply spanning_of_rank_achieving
      generalize_proofs at *;
      · intro y hy; specialize hJ_sub ( Finset.mem_of_mem_erase hy ) ; aesop;
      · exact hJ_erase_ind;
      · exact hJ_erase_card
    generalize_proofs at *;
    -- Then x ∈ cl F ⊆ cl(cl(↑(J.erase x))) = cl(↑(J.erase x)).
    have hx_cl_J_erase : x ∈ C.cl (↑(J.erase x)) := by
      exact C.cl_subset_cl_of_subset_cl hF_subset_cl_J_erase hx.1
    generalize_proofs at *;
    have := hJ_ind x; simp_all +decide [ Set.subset_def ] ;

/-
Intersection of closed sets is closed.
-/
theorem closed_inter {A B : Set X} (hA : C.Closed A) (hB : C.Closed B) :
    C.Closed (A ∩ B) := by
  refine' le_antisymm _ _;
  · refine' Set.subset_inter _ _;
    · exact C.cl_mono ( Set.inter_subset_left ) |> Set.Subset.trans <| hA.le;
    · have h_subset : C.cl (A ∩ B) ⊆ C.cl B := by
        exact C.cl_mono ( Set.inter_subset_right );
      exact h_subset.trans ( hB.symm ▸ Set.Subset.refl _ );
  · exact C.extensive _

/-! ## 8. Minimal Qualified Sets and Circuits (Theorem 3) -/

/-
Every qualified set contains a minimal qualified subset.
-/
theorem exists_minimalQualified_subset (d : X) (A : Set X)
    (hA : C.Qualified d A) (hfin : A.Finite) :
    ∃ B ⊆ A, C.MinimalQualified d B := by
  -- By the well-foundedness of the powerset of a finite set, there exists a minimal subset of $A$ that is qualified.
  obtain ⟨B, hB⟩ : ∃ B ∈ {B : Set X | B ⊆ A ∧ d ∈ C.cl B}, ∀ C' ∈ {B : Set X | B ⊆ A ∧ d ∈ C.cl B}, ¬(C' ⊂ B) := by
    have h_well_founded : WellFounded (fun B C : Set X => B ⊂ C) := by
      exact?;
    exact h_well_founded.has_min _ ⟨ A, ⟨ Set.Subset.refl _, hA ⟩ ⟩;
  refine' ⟨ B, hB.1.1, hB.1.2, fun C' hC' => _ ⟩;
  exact fun h => hB.2 C' ⟨ hC'.1.trans hB.1.1, h ⟩ hC'

/-
Minimal qualified sets are minimal dependent sets that include the dealer
    in their closure.
-/
theorem minimalQualified_iff_minimal_dep_spanning_dealer
    (d : X) (A : Set X) :
    C.MinimalQualified d A ↔
    C.Qualified d A ∧ C.Independent (A \ {d}) ∧
    ∀ B, B ⊂ A → C.Private d B := by
  refine' ⟨ fun h => ⟨ h.1, _, h.2 ⟩, fun h => ⟨ h.1, h.2.2 ⟩ ⟩;
  intro x hx;
  have := h.2 ( A \ { x } ) ?_ <;> simp_all +decide [ Set.diff_subset_iff ];
  have h_closure : C.cl ((A \ {d}) \ {x}) ⊆ C.cl (A \ {x}) := by
    exact C.cl_mono ( by aesop_cat );
  contrapose! this;
  have := C.mem_cl_iff_cl_insert ( A \ { x } ) x; simp_all +decide [ Set.diff_subset_iff ] ;
  have := this.mp ( h_closure ‹_› ) ; simp_all +decide [ FinitaryExchangeClosure.Private ] ;
  exact this ▸ h.1

/-! ## 9. Rank-Bounded Reconstruction (Theorem 5) -/

/-
**Rank-bounded reconstruction**: every qualified set contains a minimal qualified
    subset whose cardinality is bounded by the global rank.
    This is the certified reconstruction complexity theorem.
-/
theorem exists_minimalQualified_card_le_rank (d : X) (A : Finset X)
    (hA : C.Qualified d (↑A : Set X)) :
    ∃ B : Finset X, (↑B : Set X) ⊆ ↑A ∧
    C.MinimalQualified d (↑B) ∧
    B.card ≤ C.rank Set.univ := by
  have h_minimalQualified_subset : ∃ B : Finset X, (B : Set X) ⊆ A ∧ C.MinimalQualified d B := by
    have := C.exists_minimalQualified_subset d A;
    obtain ⟨ B, hB₁, hB₂ ⟩ := this hA ( Finset.finite_toSet A );
    obtain ⟨ B, hB ⟩ := Set.Finite.exists_finset_coe ( show Set.Finite B from Set.Finite.subset ( Finset.finite_toSet A ) hB₁ ) ; use B; aesop;
  obtain ⟨B, hB_subset, hB_min⟩ := h_minimalQualified_subset
  have hB_card : B.card ≤ C.rank Set.univ := by
    have hB_card : C.Independent (B \ {d}) := by
      have := C.minimalQualified_iff_minimal_dep_spanning_dealer d B; aesop;
    have hB_card_le_rank : (B \ {d}).card ≤ C.rank Set.univ := by
      refine' le_csSup _ _;
      · exact ⟨ Finset.card ( Finset.univ : Finset X ), by rintro n ⟨ I, _, _, rfl ⟩ ; exact Finset.card_le_univ _ ⟩;
      · aesop
    have hB_card_le_rank_plus_one : B.card ≤ C.rank Set.univ + 1 := by
      grind
    by_cases hd : d ∈ B <;> simp_all +decide [ Finset.card_sdiff ];
    have := hB_min.2 ( B \ { d } ) ; simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ] ;
    have hB_card_le_rank : C.rank Set.univ ≥ (B \ {d}).card + 1 := by
      have hB_card_le_rank : ∃ I : Finset X, (I : Set X) ⊆ Set.univ ∧ C.Independent (I : Set X) ∧ I.card = (B \ {d}).card + 1 := by
        have hB_card_le_rank : C.Independent (B \ {d} ∪ {d}) := by
          apply C.independent_insert_of_not_mem_cl hB_card this;
        use B \ {d} ∪ {d};
        simp_all +decide [ Finset.card_sdiff, Finset.subset_iff ];
        rw [ Nat.sub_add_cancel ( Finset.card_pos.mpr ⟨ d, hd ⟩ ) ];
      exact hB_card_le_rank.choose_spec.2.2 ▸ le_csSup ( by exact Set.Finite.bddAbove ( Set.finite_iff_bddAbove.mpr ⟨ Finset.card ( Finset.univ : Finset X ), by rintro n ⟨ I, hI₁, hI₂, rfl ⟩ ; exact Finset.card_le_univ _ ⟩ ) ) ⟨ _, hB_card_le_rank.choose_spec.1, hB_card_le_rank.choose_spec.2.1, rfl ⟩;
    grind
  use B

/-! ## 10. Idempotent Closed-Set Algebra -/

/-- Dependency addition: closure of union. -/
def depAdd (A B : Set X) : Set X := C.cl (A ∪ B)

/-- Dependency meet: closure of intersection. -/
def depMul (A B : Set X) : Set X := C.cl (A ∩ B)

/-
`depAdd` is commutative.
-/
omit [DecidableEq X] in
theorem depAdd_comm (A B : Set X) : C.depAdd A B = C.depAdd B A := by
  exact congr_arg C.cl ( Set.union_comm _ _ )

/-
`depAdd` is associative.
-/
theorem depAdd_assoc (A B D : Set X) :
    C.depAdd (C.depAdd A B) D = C.depAdd A (C.depAdd B D) := by
  unfold FinitaryExchangeClosure.depAdd;
  rw [ C.cl_union_cl_left, C.cl_union_cl_right ];
  rw [ Set.union_assoc ]

/-
`depAdd` is idempotent on closed sets.
-/
omit [DecidableEq X] in
theorem depAdd_idem (A : Set X) (hA : C.Closed A) : C.depAdd A A = A := by
  -- Since $A$ is closed, we have $C.cl A = A$.
  have h_cl_A : C.cl A = A := by
    exact hA
  -- So, $C.cl (A ∪ A) = C.cl A = A$.
  simp [h_cl_A, FinitaryExchangeClosure.depAdd]

/-
`depMul` is commutative.
-/
omit [DecidableEq X] in
theorem depMul_comm (A B : Set X) : C.depMul A B = C.depMul B A := by
  exact congr_arg _ ( Set.inter_comm _ _ )

/-
`depMul` is idempotent on closed sets.
-/
omit [DecidableEq X] in
theorem depMul_idem (A : Set X) (hA : C.Closed A) : C.depMul A A = A := by
  unfold FinitaryExchangeClosure.depMul;
  aesop

/-
Closed sets form a join-semilattice with join = depAdd and meet = intersection.
    `depMul` on closed sets equals intersection.
-/
theorem depMul_closed_eq_inter {A B : Set X} (hA : C.Closed A) (hB : C.Closed B) :
    C.depMul A B = A ∩ B := by
  exact C.closed_inter hA hB

/-
`depAdd` absorbs `depMul` on closed sets.
-/
theorem depAdd_depMul_absorb (A B : Set X) (hA : C.Closed A) (_hB : C.Closed B) :
    C.depAdd A (C.depMul A B) = A := by
  -- Since C.depMul A B = A ∩ B, we can rewrite the goal using this fact.
  simp [depMul];
  unfold FinitaryExchangeClosure.depAdd;
  rw [ C.cl_union_cl_right ];
  rw [ Set.union_eq_self_of_subset_right ];
  · exact hA;
  · exact Set.inter_subset_left

/-
Rank is subadditive under union:
    `rank(A ∪ B) ≤ rank A + rank B`.
-/
theorem rank_union_le (A B : Set X) :
    C.rank (A ∪ B) ≤ C.rank A + C.rank B := by
  nontriviality;
  refine' csSup_le ( C.rank_set_nonempty _ ) _;
  norm_num +zetaDelta at *;
  intros b x hx_sub hx_ind hx_card;
  obtain ⟨ y, hy_sub, hy_ind, hy_card ⟩ := C.rank_achieved ( A ∩ x );
  -- Since $y \subseteq A \cap x$ and $x \subseteq A \cup B$, we have $x \setminus y \subseteq B$.
  have hxy_sub_B : (x \ y : Set X) ⊆ B := by
    intro z hz;
    cases hx_sub hz.1 <;> simp_all +decide [ Set.subset_def ];
    contrapose! hy_card;
    refine' ne_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ _, _ ⟩ ) ) ( le_csSup _ _ ) );
    exact Insert.insert z y;
    · exact Finset.subset_insert _ _;
    · exact fun h => hz.2 ( h.symm ▸ Finset.mem_insert_self _ _ );
    · exact ⟨ _, fun n hn => hn.choose_spec.2.2 ▸ Finset.card_le_card ( show hn.choose ⊆ x from fun a ha => hn.choose_spec.1 ha |>.2 ) ⟩;
    · refine' ⟨ Insert.insert z y, _, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff, Set.subset_def ];
      grind +suggestions;
  -- Since $x \setminus y$ is independent and a subset of $B$, we have $\text{rank}(B) \geq \text{card}(x \setminus y)$.
  have h_rank_B_ge_card_x_minus_y : C.rank B ≥ (x \ y : Finset X).card := by
    refine' le_csSup _ _;
    · exact ⟨ Finset.card ( Finset.univ : Finset X ), by rintro n ⟨ I, hI_sub, hI_ind, rfl ⟩ ; exact Finset.card_le_univ _ ⟩;
    · refine' ⟨ x \ y, _, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
      exact C.independent_subset hx_ind fun z hz => by aesop;
  have h_rank_A_ge_card_y : C.rank A ≥ y.card := by
    refine' le_csSup _ _;
    · exact ⟨ _, fun n hn => hn.choose_spec.2.2 ▸ Finset.card_le_univ _ ⟩;
    · exact ⟨ y, fun z hz => hy_sub hz |>.1, hy_ind, rfl ⟩;
  grind

end FinitaryExchangeClosure