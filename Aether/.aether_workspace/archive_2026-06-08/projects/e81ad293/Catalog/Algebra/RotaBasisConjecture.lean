/-
  # Rota's Basis Conjecture — Formal Framework and Partial Results

  Rota's Basis Conjecture (1989): Given n bases B₁, ..., Bₙ of an n-dimensional
  vector space V over a field F, one can always arrange the n² vectors into an
  n × n matrix such that each row is a permutation of some Bᵢ and each column
  is also a basis of V.

  This file develops:
  1. A formal framework for stating the conjecture
  2. Proofs for small cases (n = 1, n = 2)
  3. Structural results about basis transversals
  4. A novel "independence deficiency" measure
  5. A falsifiable strengthening conjecture
-/

import Mathlib

open Matrix Finset Function

noncomputable section

/-! ## Core Definitions -/

/-- A `BasisArrangement` packages n bases of an n-dimensional vector space. -/
structure BasisArrangement (F : Type*) [Field F] (n : ℕ) where
  bases : Fin n → Fin n → (Fin n → F)
  row_indep : ∀ i : Fin n, LinearIndependent F (bases i)

/-- Grid entry at row i, column j -/
def BasisArrangement.grid {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n)) (i j : Fin n) : Fin n → F :=
  B.bases i (σ i j)

/-- Column j of the grid -/
def BasisArrangement.column {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n)) (j : Fin n) :
    Fin n → (Fin n → F) :=
  fun i => B.grid σ i j

/-- A valid Rota arrangement: every column is linearly independent -/
def IsRotaArrangement {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n)) : Prop :=
  ∀ j : Fin n, LinearIndependent F (B.column σ j)

/-- Rota's Basis Conjecture for dimension n over field F -/
def RotaBasisConjecture (F : Type*) [Field F] (n : ℕ) : Prop :=
  ∀ B : BasisArrangement F n, ∃ σ : Fin n → Equiv.Perm (Fin n), IsRotaArrangement B σ

/-! ## Novel Definition: Independence Deficiency -/

/-- The independence deficiency: n minus the rank of the span -/
def independenceDeficiency (F : Type*) [Field F] (n : ℕ)
    (v : Fin n → (Fin n → F)) : ℕ :=
  n - Module.finrank F (Submodule.span F (Set.range v))

/-- Total deficiency of an arrangement -/
def totalDeficiency {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n)) : ℕ :=
  ∑ j : Fin n, independenceDeficiency F n (B.column σ j)

/-! ## The Case n = 0 and n = 1 -/

/-- Rota's Basis Conjecture holds for n = 0 -/
theorem rota_basis_conjecture_n0 (F : Type*) [Field F] :
    RotaBasisConjecture F 0 := by
  intro B
  exact ⟨fun _ => Equiv.refl _, fun j => Fin.elim0 j⟩

/-
Rota's Basis Conjecture holds for n = 1
-/
theorem rota_basis_conjecture_n1 (F : Type*) [Field F] :
    RotaBasisConjecture F 1 := by
  -- For n=1, any single vector is linearly independent, so the arranged column is a basis.
  intros B
  use fun _ => Equiv.refl (Fin 1)
  simp [IsRotaArrangement, BasisArrangement.column, BasisArrangement.grid]
  exact fun h => by simpa [h] using (B.row_indep 0).ne_zero 0

/-! ## Structural Results -/

/-- Each column picks exactly one vector from each basis -/
theorem transversal_property {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n))
    (j : Fin n) : ∀ i : Fin n, ∃ k : Fin n, B.column σ j i = B.bases i k := by
  intro i
  exact ⟨σ i j, rfl⟩

/-- Permutation preserves linear independence -/
theorem linearIndependent_perm {F : Type*} [Field F] {n : ℕ}
    {v : Fin n → (Fin n → F)} (hv : LinearIndependent F v)
    (σ : Equiv.Perm (Fin n)) : LinearIndependent F (v ∘ σ) :=
  hv.comp σ σ.injective

/-- Each row of the grid remains a basis -/
theorem row_basis_preserved {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n))
    (i : Fin n) : LinearIndependent F (fun j => B.grid σ i j) := by
  show LinearIndependent F (B.bases i ∘ σ i)
  exact linearIndependent_perm (B.row_indep i) (σ i)

/-! ## The Case n = 2 -/

/-
Key lemma: given two bases of F², either the identity or swap works
-/
lemma two_bases_transversal {F : Type*} [Field F]
    (v w : Fin 2 → Fin 2 → F)
    (hv : LinearIndependent F v) (hw : LinearIndependent F w) :
    (LinearIndependent F ![v 0, w 0] ∧ LinearIndependent F ![v 1, w 1]) ∨
    (LinearIndependent F ![v 0, w 1] ∧ LinearIndependent F ![v 1, w 0]) := by
  -- By contradiction, assume that both pairs are linearly dependent.
  by_contra h_contra
  have h_det : (v 0 0 * v 1 1 - v 0 1 * v 1 0) ≠ 0 ∧ (w 0 0 * w 1 1 - w 0 1 * w 1 0) ≠ 0 := by
    constructor <;> intro h <;> simp_all +decide [ linearIndependent_fin2 ];
    · by_cases h1 : v 1 0 = 0 <;> by_cases h2 : v 1 1 = 0 <;> simp_all +decide [ sub_eq_iff_eq_add ];
      · exact hv.1 ( by ext i; fin_cases i <;> aesop );
      · exact hv.2 ( v 0 1 / v 1 1 ) ( by ext i; fin_cases i <;> simp +decide [ *, mul_div_cancel₀ ] );
      · exact hv.2 ( v 0 0 / v 1 0 ) ( by ext i; fin_cases i <;> simp +decide [ *, mul_div_cancel₀ ] );
      · refine' hv.2 ( v 0 0 / v 1 0 ) _;
        ext i; fin_cases i <;> simp +decide [ *, mul_comm, mul_assoc, mul_left_comm, div_eq_inv_mul ] ;
        field_simp [h1, h2] at h ⊢
        ring_nf at h ⊢
        aesop;
    · refine' hw.2 ( w 0 0 / w 1 0 ) _;
      ext i; fin_cases i <;> by_cases h0 : w 1 0 = 0 <;> simp_all +decide [ div_mul_cancel₀, mul_comm ] ;
      · cases h <;> simp_all +decide [ funext_iff, Fin.forall_fin_two ];
      · rw [ mul_div_cancel₀ _ h0 ];
      · cases h <;> simp_all +decide [ funext_iff, Fin.forall_fin_two ];
        exact False.elim ( hw.2 ( w 0 1 / w 1 1 ) ( by rw [ div_mul_cancel₀ _ hw.1 ] ) );
      · grind;
  simp_all +decide [ linearIndependent_fin2 ];
  by_cases h : w 0 = 0 <;> simp_all +decide [ funext_iff, Fin.forall_fin_two ];
  grind +ring

/-
Rota's Basis Conjecture holds for n = 2
-/
theorem rota_basis_conjecture_n2 (F : Type*) [Field F] :
    RotaBasisConjecture F 2 := by
  intro B
  by_cases h : LinearIndependent F ![B.bases 0 0, B.bases 1 0] ∧ LinearIndependent F ![B.bases 0 1, B.bases 1 1];
  · use fun _ => Equiv.refl _;
    intro j; fin_cases j <;> simp_all +decide [ IsRotaArrangement ] ;
    · convert h.1 using 1; funext i; fin_cases i <;> rfl
    · convert h.2 using 1; ext i; fin_cases i <;> rfl
  · -- By two_bases_transversal, either the identity or swap works.
    have h_swap : LinearIndependent F ![B.bases 0 0, B.bases 1 1] ∧ LinearIndependent F ![B.bases 0 1, B.bases 1 0] := by
      have := two_bases_transversal ( B.bases 0 ) ( B.bases 1 ) ( B.row_indep 0 ) ( B.row_indep 1 ) ; aesop;
    use fun i => if i = 0 then Equiv.refl (Fin 2) else Equiv.swap 0 1;
    rintro ⟨ _ | _ | i ⟩ <;> simp_all +decide [ IsRotaArrangement ];
    · convert h_swap.1 using 1 ; ext i ; fin_cases i <;> rfl;
    · convert h_swap.2 using 1 ; ext i ; fin_cases i <;> rfl;
    · lia

/-! ## Deficiency Properties -/

/-
The rank of the span of n vectors in Fⁿ is at most n
-/
lemma finrank_span_le (F : Type*) [Field F] (n : ℕ) (v : Fin n → (Fin n → F)) :
    Module.finrank F (Submodule.span F (Set.range v)) ≤ n := by
  exact le_trans ( Submodule.finrank_le _ ) ( by simpa )

/-- Deficiency is zero iff the span has full rank -/
theorem deficiency_zero_iff {F : Type*} [Field F] {n : ℕ}
    (v : Fin n → (Fin n → F)) :
    independenceDeficiency F n v = 0 ↔
    Module.finrank F (Submodule.span F (Set.range v)) = n := by
  unfold independenceDeficiency
  constructor
  · intro h
    have hle := finrank_span_le F n v
    omega
  · intro h; omega

/-- Zero total deficiency means all columns have full rank -/
theorem zero_total_deficiency_implies_full_rank {F : Type*} [Field F] {n : ℕ}
    (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n))
    (h : totalDeficiency B σ = 0) :
    ∀ j : Fin n,
      Module.finrank F (Submodule.span F (Set.range (B.column σ j))) = n := by
  intro j
  have hsingle : independenceDeficiency F n (B.column σ j) = 0 := by
    have hle : independenceDeficiency F n (B.column σ j) ≤ totalDeficiency B σ := by
      unfold totalDeficiency
      apply Finset.single_le_sum (f := fun j => independenceDeficiency F n (B.column σ j))
      · exact fun i _ => Nat.zero_le _
      · exact Finset.mem_univ j
    omega
  exact (deficiency_zero_iff _).mp hsingle

/-! ## Matroid Transversal Connection -/

/-- A matroid transversal: partition of n² elements into n groups via bijections -/
structure MatroidTransversal (n : ℕ) where
  assignment : Fin n → Fin n → Fin n
  is_perm : ∀ i : Fin n, Function.Bijective (assignment i)

/-- Convert a matroid transversal to permutations -/
def MatroidTransversal.toPerms {n : ℕ} (M : MatroidTransversal n) :
    Fin n → Equiv.Perm (Fin n) :=
  fun i => Equiv.ofBijective (M.assignment i) (M.is_perm i)

/-! ## Falsifiable Conjecture: Greedy Deficiency Reduction -/

/-- Greedy Rota Conjecture: local swaps always reduce positive deficiency.

    **Computational test**: For random 3×3 and 4×4 arrangements over ℚ,
    verify that a deficiency-reducing swap always exists when deficiency > 0.
    A single counterexample would disprove this. -/
def GreedyRotaConjecture (F : Type*) [Field F] (n : ℕ) : Prop :=
  ∀ (B : BasisArrangement F n) (σ : Fin n → Equiv.Perm (Fin n)),
    totalDeficiency B σ > 0 →
    ∃ (i : Fin n) (a b : Fin n),
      a ≠ b ∧
      totalDeficiency B (Function.update σ i (σ i * Equiv.swap a b)) <
      totalDeficiency B σ

/-
The Greedy Rota Conjecture implies the standard Rota Basis Conjecture
-/
theorem greedy_implies_rota {F : Type*} [Field F] {n : ℕ}
    (hGreedy : GreedyRotaConjecture F n) :
    RotaBasisConjecture F n := by
  contrapose! hGreedy;
  -- By definition of negation, there exists some arrangement B and permutation σ such that the total deficiency is positive and no swap reduces it.
  obtain ⟨B, σ, h_def⟩ : ∃ B : BasisArrangement F n, ∃ σ : Fin n → Equiv.Perm (Fin n), totalDeficiency B σ > 0 ∧ ∀ i : Fin n, ∀ a b : Fin n, a ≠ b → totalDeficiency B σ ≤ totalDeficiency B (Function.update σ i (σ i * Equiv.swap a b)) := by
    by_contra! h;
    apply hGreedy;
    intro B
    obtain ⟨σ, hσ⟩ : ∃ σ : Fin n → Equiv.Perm (Fin n), totalDeficiency B σ = 0 := by
      -- By repeatedly applying the greedy hypothesis, we can reduce the total deficiency to zero.
      have h_seq : ∀ (σ : Fin n → Equiv.Perm (Fin n)), ∃ σ' : Fin n → Equiv.Perm (Fin n), totalDeficiency B σ' ≤ totalDeficiency B σ ∧ totalDeficiency B σ' = 0 := by
        intro σ
        induction' k : totalDeficiency B σ using Nat.strong_induction_on with k ih generalizing σ;
        grind;
      exact Exists.elim ( h_seq fun _ => 1 ) fun σ hσ => ⟨ σ, hσ.2 ⟩;
    refine' ⟨ σ, fun j => _ ⟩;
    have h_full_rank : Module.finrank F (Submodule.span F (Set.range (B.column σ j))) = n := by
      exact zero_total_deficiency_implies_full_rank B σ hσ j;
    rw [ linearIndependent_iff_card_eq_finrank_span ];
    convert h_full_rank.symm using 1;
    simp +decide;
  grind +locals

end