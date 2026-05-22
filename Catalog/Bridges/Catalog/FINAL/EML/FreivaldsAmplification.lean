/-
  # Freivalds' Algorithm — Exponential Soundness Amplification

  This file formalizes the exponential soundness amplification theorem for
  independent Freivalds trials over a finite field ZMod q (q prime).

  The main result: if K ≠ A * B, then the probability that t independent
  Freivalds checks all accept is at most 1/q^t.

  ## Proof Architecture

  1. **Single-trial bound** (linear algebra):
     A nonzero matrix D has a nonzero row, giving a nontrivial linear form
     whose zero set has cardinality ≤ q^(p-1). The accepting set is a subset.

  2. **Product-space factorization**:
     The t-trial accepting set is equivalent to (Fin t → single-trial accepting set),
     so its cardinality is (single-trial cardinality)^t.

  3. **Amplified bound** (arithmetic):
     The probability ratio ≤ (1/q)^t = 1/q^t.

  This constitutes a reusable pattern for formalizing soundness amplification
  in probabilistic verification, polynomial identity testing, fingerprinting,
  and interactive proof systems.
-/

import Mathlib

open Classical in
noncomputable section

namespace FreivaldsAmplified

open Matrix Finset BigOperators

/-! ## Single-Trial Linear Algebra -/

/-- The dot product with a fixed vector defines a linear map. -/
def dotProductLinearMap {K : Type*} [Field K] {p : ℕ} (v : Fin p → K) :
    (Fin p → K) →ₗ[K] K where
  toFun x := ∑ i, v i * x i
  map_add' x y := by simp [mul_add, Finset.sum_add_distrib]
  map_smul' r x := by
    simp only [RingHom.id_apply, smul_eq_mul]
    rw [Finset.mul_sum]
    congr 1; ext i; simp [Pi.smul_apply, smul_eq_mul]; ring

/-- A nonzero vector defines a surjective linear map via dot product. -/
theorem dotProductLinearMap_surjective {K : Type*} [Field K] {p : ℕ}
    (v : Fin p → K) (hv : v ≠ 0) :
    Function.Surjective (dotProductLinearMap v) := by
  intro y
  obtain ⟨i, hi⟩ : ∃ i : Fin p, v i ≠ 0 := Function.ne_iff.mp hv
  exact ⟨fun j => if j = i then y / v i else 0, by
    simp +decide [dotProductLinearMap, Finset.sum_ite, Finset.filter_eq',
      Finset.filter_ne', mul_div_cancel₀ _ hi]⟩

/-- The kernel of a surjective linear map K^p → K has finrank p-1. -/
theorem finrank_ker_of_surjective {K : Type*} [Field K] {p : ℕ}
    (φ : (Fin p → K) →ₗ[K] K) (hφ : Function.Surjective φ) :
    Module.finrank K (LinearMap.ker φ) = p - 1 := by
  have h := LinearMap.finrank_range_add_finrank_ker φ
  rw [show φ.range = ⊤ from LinearMap.range_eq_top.mpr hφ] at h
  simp_all +decide
  exact eq_tsub_of_add_eq (by rw [add_comm]; exact h)

/-- Zero set of a nonzero linear form on K^p has cardinality ≤ |K|^(p-1). -/
theorem nonzero_linear_form_zero_set_bound {K : Type*} [Field K] [Fintype K]
    {p : ℕ} (v : Fin p → K) (hv : v ≠ 0) :
    Fintype.card {x : Fin p → K // ∑ i, v i * x i = 0} ≤
      (Fintype.card K) ^ (p - 1) := by
  have h_card_ker : Fintype.card (LinearMap.ker (dotProductLinearMap v)) =
      Fintype.card K ^ (Module.finrank K (LinearMap.ker (dotProductLinearMap v))) :=
    Module.card_eq_pow_finrank
  have h_finrank := finrank_ker_of_surjective (dotProductLinearMap v)
    (dotProductLinearMap_surjective v hv)
  have h_isom : Fintype.card {x : (Fin p → K) | ∑ i, v i * x i = 0} =
      Fintype.card (LinearMap.ker (dotProductLinearMap v)) := by
    simp +decide [dotProductLinearMap, LinearMap.mem_ker]
  aesop

/-- A nonzero matrix has at least one nonzero row. -/
theorem exists_nonzero_row {K : Type*} [Zero K] {m p : ℕ}
    (D : Matrix (Fin m) (Fin p) K) (hD : D ≠ 0) :
    ∃ i, D i ≠ 0 := by
  exact not_forall.mp fun h => hD <| Matrix.ext fun i j => by simp [h]

/-! ## Single-Trial Soundness -/

/-- **Single-trial cardinality bound**: If D ≠ 0, at most |K|^(p-1) vectors
    satisfy D.mulVec r = 0. Works for rectangular matrices. -/
theorem discrepancy_bound_rect {K : Type*} [Field K] [Fintype K]
    {m p : ℕ} (D : Matrix (Fin m) (Fin p) K) (hD : D ≠ 0) :
    Fintype.card {r : Fin p → K // D.mulVec r = 0} ≤
      (Fintype.card K) ^ (p - 1) := by
  obtain ⟨i, hi⟩ := exists_nonzero_row D hD
  refine le_trans ?_ (nonzero_linear_form_zero_set_bound (D i) hi)
  exact Fintype.card_le_of_injective
    (fun x => ⟨x.1, by simpa [Matrix.mulVec, dotProduct] using congr_fun x.2 i⟩)
    (fun x y h => by aesop)

/-
**Single-trial bound over ZMod q**: accepting vectors ≤ q^(p-1).
-/
theorem freivalds_single_trial_soundness_card
    {q m n p : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q //
      K.mulVec r = (A * B).mulVec r} ≤ q ^ (p - 1) := by
        -- Express the discrepancy set in terms of the matrix D = K - AB
        set D : Matrix (Fin m) (Fin p) (ZMod q) := K - A * B with hD
        have hD_zero : D ≠ 0 := by
          exact sub_ne_zero_of_ne hne;
        -- Show the accepting set {r | K.mulVec r = (A*B).mulVec r} equals {r | (K - A*B).mulVec r = 0}.
        have h_eq_zero : {r : Fin p → ZMod q | K.mulVec r = (A * B).mulVec r} = {r : Fin p → ZMod q | (K - A * B).mulVec r = 0} := by
          simp +decide [ sub_mulVec, sub_eq_zero ];
        convert discrepancy_bound_rect D hD_zero using 1;
        · simp_all +decide [ Set.ext_iff ];
        · norm_num [ ZMod.card ]

/-
**Single-trial fraction bound**: P[accept] ≤ 1/q.
-/
theorem freivalds_single_trial_fraction_bound
    {q m n p : ℕ} [Fact q.Prime] (hp : 0 < p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {r : Fin p → ZMod q //
        K.mulVec r = (A * B).mulVec r} : ℚ) /
      (Fintype.card (Fin p → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q := by
        convert div_le_div_of_nonneg_right ( show ( Fintype.card { r : Fin p → ZMod q // K.mulVec r = ( A * B ).mulVec r } : ℝ ) ≤ q ^ ( p - 1 ) from ?_ ) ( by positivity : ( 0 : ℝ ) ≤ q ^ p ) using 1;
        · norm_num [ div_le_iff₀, pow_pos ( show 0 < ( q : ℝ ) by exact Nat.cast_pos.mpr ( Nat.Prime.pos Fact.out ) ) ];
          rw [ inv_eq_one_div, div_le_div_iff₀ ] <;> norm_cast <;> cases p <;> simp_all +decide [ pow_succ', Nat.Prime.ne_zero Fact.out ];
          · rw [ mul_comm, mul_le_mul_iff_right₀ ( Nat.Prime.pos Fact.out ) ]
          · exact ⟨ Nat.Prime.pos Fact.out, pow_pos ( Nat.Prime.pos Fact.out ) _ ⟩
          · exact Nat.Prime.pos Fact.out
        · convert freivalds_single_trial_soundness_card A B K hne using 1;
          norm_cast

/-! ## Product Space Factorization -/

/-- The t-trial accepting set is equivalent to a function space into
    the single-trial accepting set. -/
def freivalds_accepting_tuples_equiv
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q)) :
    {rs : Fin t → (Fin p → ZMod q) //
      ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)}
      ≃
    (Fin t → {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r}) :=
  Equiv.subtypePiEquivPi (p := fun _ r => K.mulVec r = (A * B).mulVec r)

/-- **Cardinality factorization**: The t-trial accepting set has cardinality
    equal to the t-th power of the single-trial accepting set. -/
theorem freivalds_amplified_accepting_card
    {q m n p t : ℕ} [Fact q.Prime]
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q)) :
    Fintype.card {rs : Fin t → (Fin p → ZMod q) //
      ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)}
    =
    (Fintype.card {r : Fin p → ZMod q //
      K.mulVec r = (A * B).mulVec r}) ^ t := by
  rw [Fintype.card_congr (freivalds_accepting_tuples_equiv A B K)]
  rw [Fintype.card_fun, Fintype.card_fin]

/-- **Trial space cardinality**: The full t-trial space has cardinality q^(t*p). -/
theorem freivalds_trial_space_card
    {q p t : ℕ} [Fact q.Prime] :
    Fintype.card (Fin t → Fin p → ZMod q) = q ^ (t * p) := by
  simp [ZMod.card, Fintype.card_fin, pow_mul, mul_comm]

/-! ## Amplified Soundness -/

/-
**Main theorem: Exponential soundness amplification for Freivalds' algorithm.**

If K ≠ A * B, then the probability that t independent Freivalds checks
all accept is at most 1/q^t. This is the canonical example of
soundness amplification for randomized algebraic verifiers.
-/
theorem freivalds_amplified_soundness
    {q m n p t : ℕ} [Fact q.Prime] (hp : 0 < p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {rs : Fin t → (Fin p → ZMod q) //
        ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)} : ℚ) /
      (Fintype.card (Fin t → Fin p → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q ^ t := by
        -- Use the amplified accepting card and trial space card.
        have h_accepting_card : (Fintype.card {rs : Fin t → Fin p → ZMod q // ∀ i, K.mulVec (rs i) = (A * B).mulVec (rs i)}) ≤ (q ^ (p - 1)) ^ t := by
          rw [ freivalds_amplified_accepting_card ];
          exact Nat.pow_le_pow_left ( freivalds_single_trial_soundness_card A B K hne ) _;
        rw [ div_le_div_iff₀ ] <;> norm_cast <;> norm_num;
        · refine le_trans ( Nat.mul_le_mul_right _ h_accepting_card ) ?_;
          rw [ ← mul_pow ] ; rcases p with ( _ | p ) <;> simp_all +decide [ pow_succ ];
        · exact pow_pos ( pow_pos ( Nat.Prime.pos Fact.out ) _ ) _;
        · exact pow_pos ( Nat.Prime.pos Fact.out ) _

end FreivaldsAmplified

end