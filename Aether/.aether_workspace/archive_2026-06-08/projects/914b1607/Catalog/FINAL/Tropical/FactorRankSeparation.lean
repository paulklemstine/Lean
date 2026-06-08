/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Tropical Factor Rank Separation Theorem

This file proves that the tropical identity matrix has **exact factor rank `n`**,
establishing a foundational separation result in tropical linear algebra.

## Main results

* `tropFactorRank_tropId_eq` — factor rank of the n×n tropical identity is exactly n
* `tropFactorRank_tropMatMul_le_left` — product subadditivity (left)
* `tropFactorRank_tropMatMul_le_right` — product subadditivity (right)
* `tropId_factorRank_unbounded` — the identity family has unbounded factor rank

## References

* Develin, Santos, Sturmfels, "On the rank of a tropical matrix"
* Barvinok, "Combinatorics and Complexity of Partition Functions"
-/

import Mathlib

noncomputable section

open scoped BigOperators
open Classical in
attribute [local instance] Classical.propDecidable

/-! ## Tropical Factor Rank (self-contained definitions) -/

/-- A tropical matrix `M` has a decomposition of rank `r` if it can be written as
the entrywise infimum of `r` rank-1 matrices. -/
def TropDecomp {m n : ℕ} (r : ℕ)
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) : Prop :=
  ∃ U : Fin r → Fin m → WithTop ℤ,
    ∃ V : Fin r → Fin n → WithTop ℤ,
      ∀ i j, M i j = ⨅ k : Fin r, (U k i + V k j)

/-
Every `m × n` tropical matrix admits a decomposition of rank `n`.
-/
theorem tropDecomp_of_numCols {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    TropDecomp n M := by
  constructor;
  case w => exact fun k i => M i k;
  use fun k j => if j = k then 0 else ⊤;
  intro i j;
  refine' le_antisymm _ _;
  · refine' le_csInf _ _ <;> norm_num;
    · exact ⟨ _, ⟨ j, rfl ⟩ ⟩;
    · aesop;
  · exact ciInf_le ( Finite.bddBelow_range _ ) j |> le_trans <| by aesop;

/-- There exists some `r` such that `M` has a tropical decomposition of rank `r`. -/
theorem tropDecomp_exists {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    ∃ r : ℕ, TropDecomp r M :=
  ⟨n, tropDecomp_of_numCols M⟩

/-- The **tropical factor rank** of a matrix is the least `r` with a decomposition. -/
def tropFactorRank {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) : ℕ :=
  @Nat.find (fun r => TropDecomp r M) (Classical.decPred _) (tropDecomp_exists M)

/-- `tropFactorRank M` is a valid decomposition rank and is the least such rank. -/
theorem tropFactorRank_spec {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    TropDecomp (tropFactorRank M) M ∧
    ∀ r, TropDecomp r M → tropFactorRank M ≤ r := by
  unfold tropFactorRank
  exact ⟨@Nat.find_spec (fun r => TropDecomp r M) (Classical.decPred _) (tropDecomp_exists M),
         fun r hr => @Nat.find_min' (fun r => TropDecomp r M) (Classical.decPred _) (tropDecomp_exists M) r hr⟩

theorem tropFactorRank_le_numCols {m n : ℕ}
    (M : Matrix (Fin m) (Fin n) (WithTop ℤ)) :
    tropFactorRank M ≤ n :=
  (tropFactorRank_spec M).2 n (tropDecomp_of_numCols M)

/-! ## The tropical identity matrix -/

/-- The tropical identity matrix: `0` on the diagonal, `⊤` off diagonal. -/
def tropIdMatrix (n : ℕ) : Matrix (Fin n) (Fin n) (WithTop ℤ) :=
  fun i j => if i = j then 0 else ⊤

@[simp] theorem tropIdMatrix_diag {n : ℕ} (i : Fin n) :
    tropIdMatrix n i i = 0 := if_pos rfl

@[simp] theorem tropIdMatrix_offdiag {n : ℕ} {i j : Fin n} (hij : i ≠ j) :
    tropIdMatrix n i j = ⊤ := if_neg hij

/-! ## Factor rank lower bound for the tropical identity -/

/-
Off-diagonal constraint: in any decomposition of the tropical identity,
    each summand gives `⊤` at every off-diagonal position.
-/
lemma tropId_offdiag_summand_top {n r : ℕ} (hr : 0 < r)
    {U : Fin r → Fin n → WithTop ℤ} {V : Fin r → Fin n → WithTop ℤ}
    (hdecomp : ∀ i j, tropIdMatrix n i j = ⨅ k : Fin r, (U k i + V k j))
    {i j : Fin n} (hij : i ≠ j) (k : Fin r) :
    U k i + V k j = ⊤ := by
  -- From hdecomp, for every index k, adding U k i and V k j gives an element which is at least ⊤.
  have h_ge_top : ∀ k, U k i + V k j ≥ ⨅ k, U k i + V k j := by
    exact fun k => ciInf_le ( Finite.bddBelow_range fun k => U k i + V k j ) k;
  have := hdecomp i j; simp_all +decide [ tropIdMatrix ] ;
  exact le_antisymm ( by simpa [ ← this ] ) ( h_ge_top k )

/-
**Support singleton**: If the `k`-th summand has finite entries at row `i`
    and column `j`, then `i = j`.
-/
lemma tropId_support_singleton {n r : ℕ} (hr : 0 < r)
    {U : Fin r → Fin n → WithTop ℤ} {V : Fin r → Fin n → WithTop ℤ}
    (hdecomp : ∀ i j, tropIdMatrix n i j = ⨅ k : Fin r, (U k i + V k j))
    {k : Fin r} {i j : Fin n} (hui : U k i ≠ ⊤) (hvj : V k j ≠ ⊤) :
    i = j := by
  exact Classical.not_not.1 fun hi => absurd ( tropId_offdiag_summand_top hr hdecomp hi k ) ( by simp +decide [ hui, hvj, WithTop.add_eq_top ] )

/-
Each diagonal entry has a witness summand with finite values.
-/
lemma tropId_diag_witness {n r : ℕ}
    {U : Fin r → Fin n → WithTop ℤ} {V : Fin r → Fin n → WithTop ℤ}
    (hdecomp : ∀ i j, tropIdMatrix n i j = ⨅ k : Fin r, (U k i + V k j))
    (i : Fin n) :
    ∃ k : Fin r, U k i ≠ ⊤ ∧ V k i ≠ ⊤ := by
  -- Since the infimum of a set of ⊤ values is ⊤, and 0 ≠ ⊤, there must be some k where U k i + V k i is not ⊤.
  have h_inf_top : ⨅ k : Fin r, U k i + V k i = 0 → ∃ k : Fin r, U k i + V k i ≠ ⊤ := by
    intro h_inf_top;
    contrapose! h_inf_top;
    cases r <;> simp_all +decide [ Finset.inf_eq_iInf ];
    exact ne_of_gt ( lt_of_lt_of_le ( by simp +decide ) ( le_ciInf fun k => show U k i + V k i ≥ ⊤ from by cases h_inf_top k <;> simp +decide [ * ] ) );
  exact h_inf_top ( hdecomp i i ▸ by simp +decide [ tropIdMatrix ] ) |> fun ⟨ k, hk ⟩ => ⟨ k, fun hi => hk <| by simp +decide [ hi ], fun hj => hk <| by simp +decide [ hj ] ⟩

/-
**Factor rank lower bound**: Any decomposition of `tropIdMatrix n` needs ≥ n terms.
-/
theorem tropFactorRank_tropId_ge (n : ℕ) :
    n ≤ tropFactorRank (tropIdMatrix n) := by
  by_contra h_contra;
  -- Let $r = \text{tropFactorRank}(\text{tropIdMatrix}(n))$.
  set r := tropFactorRank (tropIdMatrix n) with hr_def
  have hr_le : r < n := by
    exact lt_of_not_ge h_contra;
  -- By tropFactorRank_spec, there exist U, V with tropIdMatrix n i j = ⨅ k : Fin r, (U k i + V k j).
  obtain ⟨U, V, hdecomp⟩ : ∃ U : Fin r → Fin n → WithTop ℤ, ∃ V : Fin r → Fin n → WithTop ℤ, ∀ i j, tropIdMatrix n i j = ⨅ k : Fin r, (U k i + V k j) := by
    exact tropFactorRank_spec _ |>.1;
  -- For each i : Fin n, by tropId_diag_witness, there exists w(i) : Fin r with U (w i) i ≠ ⊤ and V (w i) i ≠ ⊤.
  obtain ⟨w, hw⟩ : ∃ w : Fin n → Fin r, ∀ i, U (w i) i ≠ ⊤ ∧ V (w i) i ≠ ⊤ := by
    have hw : ∀ i : Fin n, ∃ k : Fin r, U k i ≠ ⊤ ∧ V k i ≠ ⊤ := by
      -- Apply the lemma tropId_diag_witness to each i to obtain the existence of k.
      intros i
      apply tropId_diag_witness hdecomp i;
    exact ⟨ fun i => Classical.choose ( hw i ), fun i => Classical.choose_spec ( hw i ) ⟩;
  -- We claim w is injective: if w i₁ = w i₂, then U (w i₁) i₁ ≠ ⊤ and V (w i₁) i₂ ≠ ⊤ (since w i₁ = w i₂). By tropId_support_singleton (with hr = Fin.pos for w i₁), i₁ = i₂.
  have hw_inj : Function.Injective w := by
    intros i j hij
    have h_eq : U (w i) i ≠ ⊤ ∧ V (w i) j ≠ ⊤ := by
      grind;
    apply tropId_support_singleton (by
    exact Fin.pos ( w i )) hdecomp h_eq.left h_eq.right;
  exact absurd ( Fintype.card_le_of_injective w hw_inj ) ( by simpa using hr_le )

/-- **Factor rank of tropical identity**: exactly `n`. -/
theorem tropFactorRank_tropId_eq (n : ℕ) :
    tropFactorRank (tropIdMatrix n) = n :=
  le_antisymm (tropFactorRank_le_numCols _) (tropFactorRank_tropId_ge n)

/-! ## Tropical matrix multiplication -/

/-- Tropical matrix multiplication: `(A ⊗ B)(i,j) = ⨅ k, (A(i,k) + B(k,j))`. -/
def tropMatMul {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℤ))
    (B : Matrix (Fin n) (Fin p) (WithTop ℤ)) :
    Matrix (Fin m) (Fin p) (WithTop ℤ) :=
  fun i j => ⨅ k : Fin n, (A i k + B k j)

/-! ## Helper: addition distributes over infimum in `WithTop ℤ` -/

/-
Adding a constant distributes over `iInf` in `WithTop ℤ` for finite types:
    `c + ⨅ i, f i = ⨅ i, (c + f i)`.
-/
lemma WithTopInt.add_iInf {ι : Type*} [Finite ι]
    (c : WithTop ℤ) (f : ι → WithTop ℤ) :
    c + ⨅ i, f i = ⨅ i, (c + f i) := by
  cases isEmpty_or_nonempty ι <;> cases c ; simp +decide [ *, ciInf_eq_ite ];
  · simp +decide [ iInf_of_empty ];
  · bound;
  · rename_i a;
    -- Since ι is finite, we can convert it to a finite set.
    obtain ⟨s, hs⟩ : ∃ s : Finset ι, ∀ i, i ∈ s := by
      exact ⟨ Set.Finite.toFinset ( Set.finite_univ ), fun i => Set.Finite.mem_toFinset ( Set.finite_univ ) |>.2 ( Set.mem_univ i ) ⟩;
    -- Since ι is finite, we can convert it to a finite set and use the fact that the infimum over a finite set is the minimum.
    have h_min : ⨅ i, f i = Finset.min' (s.image f) (by
    exact ⟨ f ( Classical.arbitrary ι ), Finset.mem_image_of_mem _ ( hs _ ) ⟩) := by
      refine' le_antisymm _ _;
      · simp +decide [ Finset.min', ciInf_le ];
      · exact le_ciInf fun i => Finset.min'_le _ _ ( Finset.mem_image_of_mem f ( hs i ) )
    generalize_proofs at *;
    have h_min : ⨅ i, (a : WithTop ℤ) + f i = (Finset.image (fun i => (a : WithTop ℤ) + f i) s).min' (by
    exact ⟨ _, Finset.mem_image_of_mem _ ( hs ( Classical.arbitrary ι ) ) ⟩) := by
      refine' le_antisymm _ _;
      · simp +decide [ Finset.min', * ];
        exact fun i => ciInf_le ( Finite.bddBelow_range fun i => ( a : WithTop ℤ ) + f i ) i;
      · exact le_ciInf fun i => Finset.min'_le _ _ ( Finset.mem_image_of_mem _ ( hs i ) )
    generalize_proofs at *;
    simp_all +decide [ Finset.min' ];
    refine' le_antisymm _ _ <;> simp +decide [ Finset.inf'_le, Finset.le_inf' ];
    · exact fun i hi => ⟨ i, hi, le_rfl ⟩;
    · exact Finset.exists_min_image _ _ ⟨ Classical.arbitrary ι, hs _ ⟩

/-- Right version: `(⨅ i, f i) + c = ⨅ i, (f i + c)`. -/
lemma WithTopInt.iInf_add {ι : Type*} [Finite ι]
    (f : ι → WithTop ℤ) (c : WithTop ℤ) :
    (⨅ i, f i) + c = ⨅ i, (f i + c) := by
  rw [add_comm, WithTopInt.add_iInf]
  congr 1; ext i; exact add_comm _ _

/-! ## Helper: monotonicity of iInf -/

/-
Pointwise inequality lifts to iInf.
-/
lemma ciInf_le_ciInf_of_le_forall {ι : Type*} [Finite ι]
    {f g : ι → WithTop ℤ} (h : ∀ i, f i ≤ g i) :
    ⨅ i, f i ≤ ⨅ i, g i := by
  apply_rules [ ciInf_mono ];
  exact Set.finite_range f |> Set.Finite.bddBelow

/-! ## Product subadditivity -/

/-
If `A` has a decomposition of rank `r`, so does `tropMatMul A B`.
-/
lemma tropDecomp_tropMatMul_left {m n p r : ℕ}
    {A : Matrix (Fin m) (Fin n) (WithTop ℤ)}
    (B : Matrix (Fin n) (Fin p) (WithTop ℤ))
    (hA : TropDecomp r A) :
    TropDecomp r (tropMatMul A B) := by
  obtain ⟨ U, V, h ⟩ := hA; use U; use fun k j => ⨅ l, V k l + B l j; intro i j; simp +decide [ tropMatMul, h ] ;
  cases isEmpty_or_nonempty ( Fin r ) <;> cases isEmpty_or_nonempty ( Fin n ) <;> simp_all +decide [ WithTopInt.add_iInf, WithTopInt.iInf_add ];
  nontriviality;
  refine' le_antisymm _ _;
  · refine' le_ciInf fun k => _;
    refine' le_ciInf fun l => _;
    refine' le_trans ( ciInf_le _ l ) _;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ciInf_le ( Finite.bddBelow_range _ ) k |> le_trans <| by simp +decide [ add_assoc ] ;
  · refine' le_ciInf fun k => _;
    refine' le_ciInf fun l => _;
    refine' le_trans ( ciInf_le _ l ) _;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ciInf_le ( Finite.bddBelow_range _ ) k |> le_trans <| by simp +decide [ add_assoc ] ;

/-
If `B` has a decomposition of rank `r`, so does `tropMatMul A B`.
-/
lemma tropDecomp_tropMatMul_right {m n p r : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℤ))
    {B : Matrix (Fin n) (Fin p) (WithTop ℤ)}
    (hB : TropDecomp r B) :
    TropDecomp r (tropMatMul A B) := by
  rcases hB with ⟨ U, V, h ⟩;
  refine' ⟨ fun k i => ⨅ l : Fin n, A i l + U k l, V, fun i j => _ ⟩;
  -- Apply the definition of tropical matrix multiplication.
  simp [tropMatMul, h];
  rcases n with ( _ | n ) <;> rcases r with ( _ | r ) <;> simp_all +decide [ WithTopInt.add_iInf, WithTopInt.iInf_add ];
  refine' le_antisymm _ _;
  · simp +decide [ add_assoc, ciInf_le_ciInf_of_le_forall ];
    refine' le_ciInf fun k => _;
    refine' le_ciInf fun l => _;
    refine' le_trans ( ciInf_le _ l ) _;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ciInf_le ( Finite.bddBelow_range _ ) _;
  · refine' le_ciInf fun k => _;
    refine' le_ciInf fun l => _;
    refine' le_trans ( ciInf_le _ l ) _;
    · exact Set.finite_range _ |> Set.Finite.bddBelow;
    · exact ciInf_le ( Finite.bddBelow_range _ ) k |> le_trans <| by simp +decide [ add_assoc ] ;

/-- **Product subadditivity (left)**: `factorRank(A ⊗ B) ≤ factorRank(A)`. -/
theorem tropFactorRank_tropMatMul_le_left {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℤ))
    (B : Matrix (Fin n) (Fin p) (WithTop ℤ)) :
    tropFactorRank (tropMatMul A B) ≤ tropFactorRank A :=
  (tropFactorRank_spec _).2 _ (tropDecomp_tropMatMul_left B (tropFactorRank_spec A).1)

/-- **Product subadditivity (right)**: `factorRank(A ⊗ B) ≤ factorRank(B)`. -/
theorem tropFactorRank_tropMatMul_le_right {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (WithTop ℤ))
    (B : Matrix (Fin n) (Fin p) (WithTop ℤ)) :
    tropFactorRank (tropMatMul A B) ≤ tropFactorRank B :=
  (tropFactorRank_spec _).2 _ (tropDecomp_tropMatMul_right A (tropFactorRank_spec B).1)

/-! ## Unbounded factor rank family -/

/-- The identity family has unbounded factor rank. -/
theorem tropId_factorRank_unbounded :
    ∀ N : ℕ, ∃ n ≥ N, N ≤ tropFactorRank (tropIdMatrix n) :=
  fun N => ⟨N, le_refl N, tropFactorRank_tropId_ge N⟩

end