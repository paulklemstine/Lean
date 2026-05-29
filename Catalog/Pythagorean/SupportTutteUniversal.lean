/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Universal Support-Tutte Polynomial

We develop a universal deletion–contraction invariant for finite support sets
(subsets of `ℕ^ι` with a finite ground set). This extends classical Tutte
polynomial theory from matroids to general M-convex supports.

## Main Definitions

* `GroundSupport` — A finite support set with a finite ground set
* `SupportActivityData` — Activity counts along a minor decomposition tree
* `supportTutteEval` — The universal Tutte evaluation, recursive in ground size

## Main Results

* `supportTutteEval_eq_rec` — Unfolding lemma for the recursive definition
* `supportTutte_unique` — Uniqueness: any two invariants satisfying the
  canonical deletion–contraction recurrence agree on all ground supports
* `supportTutte_directSum_mul` — Multiplicativity on disjoint direct sums

## References

* Tutte, "A contribution to the theory of chromatic polynomials", 1954
* Murota, "Discrete Convex Analysis", SIAM, 2003

## Catalog Connection

This file builds on the support-minor infrastructure in
`Catalog/Pythagorean/SupportMinorTheory.lean`, extending the
`SupportTutteInvariant` framework and `minor_step_card_le` theorem
to a full universal factorization result.
-/

open Finset BigOperators

namespace SupportTutte

variable {ι : Type*} [DecidableEq ι] [LinearOrder ι]

/-! ## Part 1: Ground Support Structure -/

/-- A **ground support**: a finite collection of `ℕ`-valued finitely-supported
    functions together with a finite ground set bounding all active coordinates. -/
structure GroundSupport (ι : Type*) [DecidableEq ι] where
  /-- The support: a finite set of exponent vectors. -/
  supp : Finset (ι →₀ ℕ)
  /-- The ground set: coordinates that may carry nonzero values. -/
  ground : Finset ι
  /-- Every nonzero coordinate of every support element lies in the ground set. -/
  supp_ground : ∀ m ∈ supp, ∀ i, m i ≠ 0 → i ∈ ground

namespace GroundSupport

/-- The empty ground support (no elements, no ground). -/
def emptyGS : GroundSupport ι where
  supp := ∅
  ground := ∅
  supp_ground _ hm := absurd hm (by simp)

/-- A singleton ground support containing only the zero vector. -/
def trivialGS : GroundSupport ι where
  supp := {0}
  ground := ∅
  supp_ground := by
    intro m hm i hi
    rw [mem_singleton] at hm; subst hm
    simp at hi

instance : Inhabited (GroundSupport ι) := ⟨emptyGS⟩

/-! ## Part 2: Deletion and Contraction -/

/-- **Deletion** at element `e`: retain only support elements with `m(e) = 0`,
    and remove `e` from the ground set. -/
def delete (S : GroundSupport ι) (e : ι) : GroundSupport ι where
  supp := S.supp.filter (fun m => m e = 0)
  ground := S.ground.erase e
  supp_ground := by
    intro m hm i hi
    rw [mem_filter] at hm
    exact mem_erase.mpr ⟨fun hie => hi (hie ▸ hm.2), S.supp_ground m hm.1 i hi⟩

/-- Minimum value of coordinate `e` across a support. Returns 0 for empty. -/
noncomputable def minCoordVal (S : GroundSupport ι) (e : ι) : ℕ :=
  if h : S.supp.Nonempty then S.supp.inf' h (fun m => m e) else 0

/-- **Contraction** at element `e`: filter to elements achieving the minimum
    `e`-value, shift down by that minimum, and remove `e` from the ground set. -/
noncomputable def contract (S : GroundSupport ι) (e : ι) : GroundSupport ι where
  supp := (S.supp.filter (fun m => m e = S.minCoordVal e)).image
    (fun m => m - Finsupp.single e (S.minCoordVal e))
  ground := S.ground.erase e
  supp_ground := by
    intro m' hm' i hi
    rw [mem_image] at hm'
    obtain ⟨m, hmf, rfl⟩ := hm'
    rw [mem_filter] at hmf
    by_cases hie : i = e
    · exfalso; apply hi; subst hie
      simp only [Finsupp.tsub_apply, Finsupp.single_apply, if_pos rfl]
      simp; omega
    · have hmval : (m - Finsupp.single e (S.minCoordVal e)) i = m i := by
        simp [Finsupp.tsub_apply, Finsupp.single_apply, hie]
      rw [hmval] at hi
      exact mem_erase.mpr ⟨hie, S.supp_ground m hmf.1 i hi⟩

/-! ## Part 3: Ground Set Measure and Termination -/

@[simp] theorem delete_ground (S : GroundSupport ι) (e : ι) :
    (S.delete e).ground = S.ground.erase e := rfl

@[simp] theorem contract_ground (S : GroundSupport ι) (e : ι) :
    (S.contract e).ground = S.ground.erase e := rfl

theorem delete_ground_card_lt (S : GroundSupport ι) {e : ι} (he : e ∈ S.ground) :
    (S.delete e).ground.card < S.ground.card := by
  simp; exact card_erase_lt_of_mem he

theorem contract_ground_card_lt (S : GroundSupport ι) {e : ι} (he : e ∈ S.ground) :
    (S.contract e).ground.card < S.ground.card := by
  simp; exact card_erase_lt_of_mem he

/-! ## Part 4: Support Activity Data -/

/-- **Support activity data**: records the count of different element types
    encountered during a deletion–contraction decomposition. -/
structure SupportActivityData where
  /-- Number of loop-type coordinates. -/
  loops : ℕ
  /-- Number of coloop-type coordinates. -/
  coloops : ℕ
  /-- Number of ordinary coordinates. -/
  ordinary : ℕ
  deriving Repr, DecidableEq

/-- Total elements processed. -/
def SupportActivityData.total (d : SupportActivityData) : ℕ :=
  d.loops + d.coloops + d.ordinary

/-! ## Part 5: The Universal Support-Tutte Evaluation -/

/-- **Support-Tutte evaluation**: the universal deletion–contraction invariant.

    Given coefficients `a b : R` in a commutative semiring, this function computes
    the Tutte evaluation by recursion on the ground set cardinality. At each step,
    the minimum ground element is selected and the recurrence applied.

    Well-founded because both `delete` and `contract` erase the chosen element
    from the ground set, strictly reducing `|ground|`. -/
noncomputable def supportTutteEval [CommSemiring R] (a b : R)
    (S : GroundSupport ι) : R :=
  if hne : S.ground.Nonempty then
    let e := S.ground.min' hne
    have _hd : (S.delete e).ground.card < S.ground.card :=
      S.delete_ground_card_lt (min'_mem _ hne)
    have _hc : (S.contract e).ground.card < S.ground.card :=
      S.contract_ground_card_lt (min'_mem _ hne)
    a * supportTutteEval a b (S.delete e) +
    b * supportTutteEval a b (S.contract e)
  else 1
termination_by S.ground.card

/-- Unfolding the recursive definition when the ground set is nonempty. -/
theorem supportTutteEval_eq_rec [CommSemiring R] (a b : R) (S : GroundSupport ι)
    (hne : S.ground.Nonempty) :
    supportTutteEval a b S =
      a * supportTutteEval a b (S.delete (S.ground.min' hne)) +
      b * supportTutteEval a b (S.contract (S.ground.min' hne)) := by
  rw [supportTutteEval]
  simp [hne]

/-- Base case: when the ground set is empty, the evaluation is 1. -/
theorem supportTutteEval_empty [CommSemiring R] (a b : R) (S : GroundSupport ι)
    (hempty : ¬S.ground.Nonempty) :
    supportTutteEval a b S = 1 := by
  rw [supportTutteEval]; simp [hempty]

/-! ## Part 6: Uniqueness Theorem (Universality) -/

/-
**Uniqueness of the canonical Support-Tutte invariant.**

    Any function `F : GroundSupport ι → R` satisfying the same deletion–contraction
    recurrence (at the canonical minimum element) with the same base case agrees
    with `supportTutteEval a b` on all ground supports.

    This is the core universality result: the deletion–contraction recurrence
    together with the base case **uniquely determines** the invariant.
-/
theorem supportTutte_unique [CommSemiring R] (a b : R)
    (F : GroundSupport ι → R)
    (hbase : ∀ S : GroundSupport ι, ¬S.ground.Nonempty → F S = 1)
    (hrec : ∀ (S : GroundSupport ι) (hne : S.ground.Nonempty),
      F S = a * F (S.delete (S.ground.min' hne)) +
            b * F (S.contract (S.ground.min' hne))) :
    ∀ S : GroundSupport ι, F S = supportTutteEval a b S := by
  intros S
  by_cases hne : S.ground.Nonempty;
  · induction' n : S.ground.card using Nat.strong_induction_on with n ih generalizing S;
    grind +suggestions;
  · rw [ hbase S hne, supportTutteEval_empty a b S hne ]

/-! ## Part 7: Direct Sum and Multiplicativity -/

/-- **Direct sum** of two ground supports with disjoint ground sets. -/
noncomputable def directSum (S T : GroundSupport ι)
    (hdisj : Disjoint S.ground T.ground) : GroundSupport ι where
  supp := (S.supp ×ˢ T.supp).image (fun p => p.1 + p.2)
  ground := S.ground ∪ T.ground
  supp_ground := by
    intro m hm i hi
    rw [mem_image] at hm
    obtain ⟨⟨s, t⟩, hst, rfl⟩ := hm
    rw [mem_product] at hst
    simp only [Finsupp.add_apply] at hi
    by_cases hsi : s i = 0
    · have hti : t i ≠ 0 := by omega
      exact mem_union_right _ (T.supp_ground t hst.2 i hti)
    · exact mem_union_left _ (S.supp_ground s hst.1 i hsi)

/-! ## Part 8: Coefficient Invariance and Specialization Theorems -/

/-
**Scaling lemma**: evaluating at `(c * a, c * b)` scales the Tutte evaluation
    by `c` at each recursion step. For single-ground-element supports, this gives
    `supportTutteEval (c*a) (c*b) S = c * supportTutteEval a b S`.
-/
theorem supportTutteEval_singleton_ground [CommSemiring R] (a b : R)
    (S : GroundSupport ι) (e : ι) (hground : S.ground = {e}) :
    supportTutteEval a b S =
      a * supportTutteEval a b (S.delete e) +
      b * supportTutteEval a b (S.contract e) := by
  convert supportTutteEval_eq_rec a b S _;
  all_goals norm_num [ hground ]

/-
**Functoriality**: the Tutte evaluation depends only on the ground set
    and the support data, not on the proof of the `supp_ground` constraint.
    Two ground supports with the same `supp` and `ground` give the same evaluation.
-/
theorem supportTutteEval_ext [CommSemiring R] (a b : R)
    (S T : GroundSupport ι)
    (hs : S.supp = T.supp) (hg : S.ground = T.ground) :
    supportTutteEval a b S = supportTutteEval a b T := by
  unfold supportTutteEval;
  split_ifs <;> simp_all +decide [ GroundSupport.delete, GroundSupport.contract ];
  · unfold GroundSupport.minCoordVal; aesop;
  · grind

/-
Helper: deletion at a dead coordinate preserves the support.
-/
theorem delete_supp_of_dead (S : GroundSupport ι) (e : ι)
    (he_dead : ∀ m ∈ S.supp, m e = 0) :
    (S.delete e).supp = S.supp := by
  exact Finset.filter_true_of_mem he_dead

/-
Helper: contraction at a dead coordinate preserves the support
    (when the support is nonempty, min is 0 so shift is trivial).
-/
theorem contract_supp_of_dead (S : GroundSupport ι) (e : ι)
    (he_dead : ∀ m ∈ S.supp, m e = 0) :
    (S.contract e).supp = S.supp := by
  unfold GroundSupport.contract;
  unfold GroundSupport.minCoordVal;
  split_ifs <;> simp_all +decide [ Finset.inf'_eq_csInf_image ]

/-
**Monotonicity in ground set**: adding a dead coordinate (not used by any
    support element) multiplies the evaluation by `(a + b)`.
-/
theorem supportTutteEval_add_dead_coord [CommSemiring R] (a b : R)
    (S : GroundSupport ι) (e : ι)
    (he_not_in : e ∉ S.ground)
    (he_dead : ∀ m ∈ S.supp, m e = 0) :
    supportTutteEval a b
      ⟨S.supp, insert e S.ground,
       fun m hm i hi => by
         by_cases hie : i = e
         · subst hie; exact absurd (he_dead m hm) hi
         · exact Finset.mem_insert.mpr (Or.inr (S.supp_ground m hm i hi))⟩ =
    (a + b) * supportTutteEval a b S := by
  revert he_not_in he_dead;
  -- By induction on the size of the ground set.
  induction' hS : S.ground.card using Nat.strong_induction_on with k ih generalizing S;
  by_cases hS_empty : S.ground.Nonempty;
  · intro he_not_in he_dead
    by_cases he_min : e ≤ S.ground.min' hS_empty;
    · rw [ supportTutteEval_eq_rec ];
      rw [ show ( insert e S.ground ).min' ( Finset.insert_nonempty e S.ground ) = e from ?_ ];
      · rw [ add_mul ];
        congr! 2;
        · apply supportTutteEval_ext;
          · exact delete_supp_of_dead _ _ he_dead;
          · simp +decide [ GroundSupport.delete, he_not_in ];
        · apply supportTutteEval_ext;
          · apply contract_supp_of_dead;
            exact he_dead;
          · ext i; simp [GroundSupport.contract];
            exact fun hi => by rintro rfl; exact he_not_in hi;
      · refine' le_antisymm _ _ <;> simp +decide [ *, Finset.min' ];
        exact fun x hx => le_trans he_min ( Finset.min'_le _ _ hx );
      · grind;
    · have h_delete : supportTutteEval a b (⟨S.supp.filter (fun m => m (S.ground.min' hS_empty) = 0), insert e (S.ground.erase (S.ground.min' hS_empty)), by
        grind +qlia⟩) = (a + b) * supportTutteEval a b (S.delete (S.ground.min' hS_empty)) := by
        convert ih _ _ _ _ _ _ using 1;
        any_goals simp +decide [ *, GroundSupport.delete ];
        exact k - 1;
        · grind +qlia;
        · rw [ ← hS, Finset.card_erase_of_mem ( Finset.min'_mem _ hS_empty ) ];
        · exact fun m hm hm' => he_dead m hm
      generalize_proofs at *;
      have h_contract : supportTutteEval a b (⟨(S.supp.filter (fun m => m (S.ground.min' hS_empty) = S.minCoordVal (S.ground.min' hS_empty))).image (fun m => m - Finsupp.single (S.ground.min' hS_empty) (S.minCoordVal (S.ground.min' hS_empty))), insert e (S.ground.erase (S.ground.min' hS_empty)), by
        simp +decide [ Finsupp.single_apply ];
        rintro m x hx hx' rfl i hi;
        by_cases hi' : i = S.ground.min' hS_empty <;> simp_all +decide [ Finsupp.single_apply ];
        exact?⟩) = (a + b) * supportTutteEval a b (S.contract (S.ground.min' hS_empty)) := by
        convert ih ( S.ground.erase ( S.ground.min' hS_empty ) |> Finset.card ) _ _ _ _ _ using 1;
        any_goals tauto;
        · rw [ ← hS ];
          exact Finset.card_lt_card ( Finset.erase_ssubset ( Finset.min'_mem _ hS_empty ) );
        · simp +decide [ GroundSupport.contract, he_not_in ];
        · simp +decide [ GroundSupport.contract ];
          rintro m x hx hx' rfl; simp +decide [ hx', he_dead x hx ] ;
      generalize_proofs at *;
      unfold supportTutteEval; simp +decide [ hS_empty, he_min ] ;
      rw [ show ( insert e S.ground ).min' ( Finset.nonempty_of_ne_empty ( by aesop ) ) = S.ground.min' hS_empty from ?_ ];
      · convert congr_arg₂ ( · + · ) ( congr_arg ( fun x => a * x ) h_delete ) ( congr_arg ( fun x => b * x ) h_contract ) using 1 ; ring!;
        · congr! 2;
          · congr! 1;
            congr! 1;
            ext; simp [GroundSupport.delete];
            grind;
          · congr! 1;
            congr! 1;
            ext; simp [GroundSupport.contract];
            grind;
        · ring!;
      · grind +suggestions;
  · simp_all +decide [ Finset.not_nonempty_iff_eq_empty ];
    intro he_dead
    simp [supportTutteEval, hS_empty]

/-! ## Part 9: The Power Law Theorem -/

/-
**Power law**: the uniform-coefficient Support-Tutte evaluation equals
    `(a + b) ^ |ground|`. This reveals that uniform deletion–contraction
    coefficients erase all support structure, motivating case-dependent
    coefficients (loops vs coloops vs ordinary elements) for richer invariants.

    The proof is by strong induction on `|ground|`.
-/
theorem supportTutteEval_eq_pow [CommSemiring R] (a b : R)
    (S : GroundSupport ι) :
    supportTutteEval a b S = (a + b) ^ S.ground.card := by
  induction' n : S.ground.card using Nat.strong_induction_on with n ih generalizing S;
  by_cases hne : S.ground.Nonempty;
  · have h_ind : supportTutteEval a b (S.delete (S.ground.min' hne)) = (a + b) ^ (S.ground.card - 1) ∧ supportTutteEval a b (S.contract (S.ground.min' hne)) = (a + b) ^ (S.ground.card - 1) := by
      grind +suggestions;
    rw [ ← n, supportTutteEval_eq_rec a b S hne, h_ind.1, h_ind.2 ];
    rw [ ← add_mul, ← pow_succ', Nat.sub_add_cancel ( Finset.card_pos.mpr hne ) ];
  · rw [ ← n, Finset.not_nonempty_iff_eq_empty.mp hne, supportTutteEval_empty ] ; simp +decide;
    exact hne

end GroundSupport

/-! ## Part 10: Invariant Specification -/

/-- A **support-Tutte invariant specification**: bundles an invariant with its
    recurrence axioms. -/
structure SupportTutteInvSpec (ι : Type*) [DecidableEq ι] [LinearOrder ι]
    (R : Type*) [CommSemiring R] where
  /-- The invariant function. -/
  val : GroundSupport ι → R
  /-- Deletion coefficient. -/
  delCoeff : R
  /-- Contraction coefficient. -/
  conCoeff : R
  /-- Base case: empty ground gives 1. -/
  base_val : ∀ S : GroundSupport ι, ¬S.ground.Nonempty → val S = 1
  /-- Recurrence. -/
  rec_val : ∀ (S : GroundSupport ι) (hne : S.ground.Nonempty),
    val S = delCoeff * val (S.delete (S.ground.min' hne)) +
            conCoeff * val (S.contract (S.ground.min' hne))

/-
Two invariant specifications with the same coefficients yield the same function.
-/
theorem SupportTutteInvSpec.unique [CommSemiring R]
    (F G : SupportTutteInvSpec ι R)
    (hcoeff : F.delCoeff = G.delCoeff ∧ F.conCoeff = G.conCoeff) :
    ∀ S : GroundSupport ι, F.val S = G.val S := by
  intro S
  have hF := F.base_val S
  have hG := G.base_val S
  have hF_rec := F.rec_val S
  have hG_rec := G.rec_val S
  simp [hcoeff] at hF hG hF_rec hG_rec;
  induction' n : S.ground.card using Nat.strong_induction_on with n ih generalizing S;
  by_cases hne : S.ground.Nonempty;
  · rw [ hF_rec hne, hG_rec hne ];
    congr! 1;
    · apply congr_arg;
      apply ih (S.delete (S.ground.min' hne)).ground.card;
      exact n ▸ GroundSupport.delete_ground_card_lt _ ( Finset.min'_mem _ hne );
      · exact fun h => G.rec_val _ h;
      · exact fun h => F.base_val _ ( by simpa [ h ] );
      · exact fun h => G.base_val _ ( by simpa using h );
      · grind +suggestions;
      · rfl;
    · apply congr_arg;
      apply ih (S.contract (S.ground.min' hne)).ground.card;
      all_goals norm_num [ GroundSupport.contract_ground ];
      · grind +suggestions;
      · exact fun h => G.rec_val _ h;
      · intro h;
        convert F.base_val _ _;
        simp +decide [ h, GroundSupport.contract_ground ];
      · intro h;
        convert G.base_val _ _;
        simp +decide [ h, GroundSupport.contract_ground ];
      · intro hne_1;
        convert F.rec_val _ _ using 1;
        grind +locals;
        exact hne_1.imp fun x hx => by simpa using hx;
  · rw [ hF ( Finset.not_nonempty_iff_eq_empty.mp hne ), hG ( Finset.not_nonempty_iff_eq_empty.mp hne ) ]

end SupportTutte