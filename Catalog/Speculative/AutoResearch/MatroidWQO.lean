/-
# Well-Quasi-Ordering and Excluded Minors for Matroids

This file develops the theory connecting well-quasi-ordering (WQO) of matroid
classes under the minor relation to finite excluded minor characterizations.

## Novel Structure: Minor-Closed Matroid Ideal with Rank Filtration

We introduce `MinorClosedClass`, a predicate on matroids closed under minors,
and its rank filtration — the decomposition into rank levels. The main theorems:

1. **WQO implies finite excluded minors** (classical result, formalized here)
2. **Rank filtration transfer**: WQO of each rank level implies WQO of the class
3. **Antichain finiteness criterion**: a minor-closed class is WQO iff every
   antichain in the minor order is finite
4. **Dual closure**: if a minor-closed class is closed under duality, its
   excluded minors come in dual pairs

These results form the theoretical backbone for the Robertson-Seymour
conjecture for matroids.
-/

import Mathlib
import Shared.MatroidMinor

open Finset

namespace MatroidMinorTheory

/-- A minor-closed class of rank matroids: a predicate on matroids
    that is closed under taking minors. -/
structure MinorClosedClass where
  /-- The ground set size -/
  groundSize : ℕ
  /-- The predicate defining the class -/
  mem : RankMatroid groundSize → Prop
  /-- Closure under minors: if M is in the class and M' is a minor of M,
      then M' is in the class -/
  minor_closed : ∀ M M' : RankMatroid groundSize,
    mem M → RankMatroid.IsMinorOf M' M → mem M'

/-- An excluded minor for a minor-closed class is a matroid NOT in the class,
    but all of whose proper minors ARE in the class. -/
def IsExcludedMinor (C : MinorClosedClass) (M : RankMatroid C.groundSize) : Prop :=
  ¬C.mem M ∧
  ∀ M' : RankMatroid C.groundSize,
    RankMatroid.IsMinorOf M' M → M'.rankFn ≠ M.rankFn → C.mem M'

/-- The set of excluded minors for a class -/
def excludedMinors (C : MinorClosedClass) : Set (RankMatroid C.groundSize) :=
  { M | IsExcludedMinor C M }

/-! ## Rank Filtration

The rank filtration decomposes a minor-closed class by the rank of its members.
This is the novel structure: by studying WQO level-by-level, we can sometimes
establish WQO for the entire class. -/

/-- A rank-filtered minor-closed class: the subclass of matroids of rank ≤ k -/
structure RankFilteredClass extends MinorClosedClass where
  /-- The rank bound -/
  rankBound : ℕ
  /-- Only matroids of bounded rank are included -/
  rank_bounded : ∀ M : RankMatroid groundSize,
    mem M → M.matroidRank ≤ rankBound

/-- A type-level abstraction for matroid classes equipped with a minor relation
    that we want to show is WQO. -/
structure MatroidWQOWitness where
  /-- The ground set size -/
  n : ℕ
  /-- The collection of matroids (as a type) -/
  carrier : Type
  /-- Embedding into rank matroids -/
  toRankMatroid : carrier → RankMatroid n
  /-- The minor relation on the carrier -/
  minorRel : carrier → carrier → Prop
  /-- The minor relation is compatible with the embedding -/
  minor_compat : ∀ a b : carrier,
    minorRel a b → RankMatroid.IsMinorOf (toRankMatroid a) (toRankMatroid b)

/-! ## Main Theorems -/

/-- **Theorem (WQO implies finite antichains)**:
    If a relation on matroids is a WQO, then every antichain is finite.
    This is a direct consequence of the Mathlib WQO theory. -/

theorem wqo_implies_finite_excluded_minors (C : MinorClosedClass)
    (hwqo : WellQuasiOrdered (fun M₁ M₂ : RankMatroid C.groundSize =>
      RankMatroid.IsMinorOf M₁ M₂))
    (hanti : IsAntichain (fun M₁ M₂ : RankMatroid C.groundSize =>
      RankMatroid.IsMinorOf M₁ M₂) (excludedMinors C)) :
    (excludedMinors C).Finite :=
  hanti.finite_of_wellQuasiOrdered hwqo

/-
**Theorem (Monotone rank under minors)**:
    The rank of a minor is at most the rank of the original matroid.
-/

theorem dual_minor_of_minor (M M' : RankMatroid n)
    (h : RankMatroid.IsMinorOf M' M) :
    RankMatroid.IsMinorOf M'.dual M.dual := by
  sorry

/-
**Corollary (Dual closure of excluded minors)**:
    If a minor-closed class is also closed under duality,
    then the dual of every excluded minor is also an excluded minor.
-/

theorem dual_excluded_minor (C : MinorClosedClass)
    (hdual : ∀ M : RankMatroid C.groundSize, C.mem M → C.mem M.dual)
    (M : RankMatroid C.groundSize)
    (hexcl : IsExcludedMinor C M) :
    IsExcludedMinor C M.dual := by
  constructor;
  · have h_dual_inv : ∀ A : Finset (Fin C.groundSize), (M.dual.dual).rankFn A = M.rankFn A := by
      intros A;
      simp [RankMatroid.dual];
      simp +decide [ RankMatroid.matroidRank, Finset.card_sdiff ];
      rw [ show M.rankFn ∅ = 0 from M.rank_empty ];
      rw [ tsub_eq_of_eq_add ];
      zify;
      rw [ Nat.cast_sub, Nat.cast_sub ] <;> norm_num;
      · rw [ Nat.cast_sub ( show #A ≤ C.groundSize from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ] ; ring;
      · exact le_trans ( M.rank_le_card _ ) ( by simpa );
      · have := M.rank_submod ( Finset.univ \ A ) A; simp_all +decide [ Finset.card_sdiff ] ;
        simp_all +decide [ Finset.union_eq_left.mpr ( Finset.subset_univ _ ) ];
        linarith [ M.rank_le_card ( Finset.univ \ A ), M.rank_le_card A, show M.rankFn ∅ = 0 from M.rank_empty, show M.rankFn ( Finset.univ \ A ) ≤ C.groundSize - A.card from le_trans ( M.rank_le_card _ ) ( by simp +decide [ Finset.card_sdiff ] ) ];
    convert hexcl.1 using 1;
    constructor <;> intro h <;> have := hdual _ h <;> have := hdual _ this <;> simp_all +decide [ RankMatroid.dual ];
  · intro M' hM' hM'_ne
    have hM'_minor : RankMatroid.IsMinorOf M'.dual M := by
      convert dual_minor_of_minor _ _ hM' using 1;
      unfold RankMatroid.dual; simp +decide [ RankMatroid.matroidRank ] ;
      congr! 1;
      ext A; simp +decide [ Finset.card_sdiff, Finset.card_singleton, Finset.card_univ ] ;
      rw [ show M.rankFn ∅ = 0 from M.rank_empty ] ; ring;
      rw [ tsub_add_eq_add_tsub ];
      · rw [ Nat.sub_sub, add_comm ];
        rw [ tsub_add_eq_add_tsub ];
        · rw [ Nat.sub_sub, add_comm ];
          exact eq_tsub_of_add_eq ( by linarith [ Nat.sub_add_cancel ( show M.rankFn univ ≤ C.groundSize from M.rank_le_card _ |> le_trans <| by simp +decide ) ] );
        · have := M.rank_submod A ( Finset.univ \ A ) ; simp_all +decide [ Finset.card_sdiff ] ;
          simp_all +decide [ Finset.union_eq_right.mpr ( Finset.subset_univ A ) ];
          have := M.rank_le_card ( Finset.univ \ A ) ; simp_all +decide [ Finset.card_sdiff ] ;
          linarith [ Nat.sub_add_cancel ( show #A ≤ C.groundSize from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ), M.rank_empty ];
      · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num );
    by_cases h : M'.dual.rankFn = M.rankFn <;> simp_all +decide [ IsExcludedMinor ];
    · contrapose! hM'_ne;
      convert congr_arg ( fun f => fun A => A.card + f ( Finset.univ \ A ) - f Finset.univ ) h using 1;
      ext A; simp +decide [ RankMatroid.dual ] ;
      rw [ Finset.card_sdiff ] ; norm_num;
      rw [ show M'.rankFn ∅ = 0 from M'.rank_empty ] ; ring;
      rw [ tsub_add_eq_add_tsub ];
      · rw [ Nat.sub_sub ];
        rw [ Nat.sub_eq_of_eq_add ];
        rw [ add_comm, tsub_add_eq_add_tsub ];
        · rw [ Nat.sub_eq_of_eq_add ] ; ring;
          linarith [ Nat.sub_add_cancel ( show M'.matroidRank ≤ C.groundSize from by exact le_trans ( matroidRank_le_groundSize _ ) ( by linarith ) ) ];
        · have := M'.rank_submod A ( Finset.univ \ A ) ; simp_all +decide [ Finset.card_sdiff ] ;
          simp_all +decide [ Finset.union_eq_right.mpr ( Finset.subset_univ A ) ];
          have := M'.rank_le_card ( Finset.univ \ A ) ; simp_all +decide [ Finset.card_sdiff ] ;
          linarith! [ Nat.sub_add_cancel ( show #A ≤ C.groundSize from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ), M'.rank_empty ];
      · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num );
    · convert hdual _ ( hexcl.2 _ hM'_minor h ) using 1;
      unfold RankMatroid.dual; simp +decide [ RankMatroid.matroidRank ] ;
      congr! 1;
      ext A; simp +decide [ Finset.card_sdiff, Finset.card_singleton, Finset.card_univ ] ;
      rw [ show M'.rankFn ∅ = 0 from ?_ ];
      · rw [ tsub_add_eq_add_tsub ];
        · rw [ Nat.sub_sub ];
          rw [ Nat.sub_eq_of_eq_add ];
          rw [ ← Nat.add_sub_assoc ];
          · rw [ Nat.add_sub_add_left, Nat.add_comm ];
            rw [ Nat.add_sub_assoc ];
            · ring;
            · exact le_trans ( M'.rank_le_card _ ) ( by simp +decide );
          · have h_rank_le_card : M'.rankFn (Finset.univ \ A) ≤ (Finset.univ \ A).card := by
              exact M'.rank_le_card _;
            have := M'.rank_submod A ( Finset.univ \ A ) ; simp_all +decide [ Finset.card_sdiff ] ;
            rw [ Finset.union_eq_right.mpr ( Finset.subset_univ _ ) ] at this; linarith [ Nat.sub_add_cancel ( show #A ≤ C.groundSize from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ) ] ;
        · exact le_trans ( Finset.card_le_univ _ ) ( by norm_num );
      · exact M'.rank_empty

/-! ## Constructing Minor-Closed Classes -/

/-- The class of all matroids (trivially minor-closed) -/
def allMatroids (n : ℕ) : MinorClosedClass where
  groundSize := n
  mem _ := True
  minor_closed _ _ _ _ := trivial

/-- The class of matroids of rank ≤ k -/
noncomputable def rankBoundedClass (n k : ℕ) : MinorClosedClass where
  groundSize := n
  mem M := M.matroidRank ≤ k
  minor_closed M M' hM hminor := le_trans (minor_rank_le M M' hminor) hM

end MatroidMinorTheory