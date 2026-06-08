/-
  # Freivalds' Algorithm — Randomized Matrix Multiplication Verification

  This file proves that Freivalds' randomized matrix multiplication verification
  algorithm has error probability at most 1/q over ZMod q. The proof proceeds
  via a direct linear-algebraic argument:

  1. A nonzero matrix has a nonzero row (linear form).
  2. The zero set of a nonzero linear form on K^n has cardinality |K|^{n-1}.
  3. Therefore, D.mulVec r = 0 for at most |K|^{n-1} choices of r when D ≠ 0.

  This is precisely the degree-1 specialization of the Schwartz–Zippel lemma,
  showing that Freivalds' algorithm is the first nontrivial case of polynomial
  identity testing over finite fields.
-/

import Mathlib

open Classical in
noncomputable section

namespace Freivalds

open Matrix Finset BigOperators

variable {K : Type*} [Field K] [Fintype K]

/-! ## Linear Form Zero Set Bound -/

/-- The dot product with a fixed vector defines a linear map. -/
def dotProductLinearMap {n : ℕ} (v : Fin n → K) :
    (Fin n → K) →ₗ[K] K where
  toFun x := ∑ i, v i * x i
  map_add' x y := by simp [mul_add, Finset.sum_add_distrib]
  map_smul' r x := by
    simp only [RingHom.id_apply, smul_eq_mul]
    rw [Finset.mul_sum]
    congr 1; ext i; simp [Pi.smul_apply, smul_eq_mul]; ring

/-
A nonzero vector defines a surjective linear map via dot product.
-/
theorem dotProductLinearMap_surjective {n : ℕ} (v : Fin n → K)
    (hv : v ≠ 0) : Function.Surjective (dotProductLinearMap v) := by
  intro y;
  -- Since $v$ is nonzero, there exists some $i$ such that $v_i \neq 0$.
  obtain ⟨i, hi⟩ : ∃ i : Fin n, v i ≠ 0 := by
    exact Function.ne_iff.mp hv;
  refine' ⟨ fun j => if j = i then y / v i else 0, _ ⟩;
  simp +decide [ dotProductLinearMap, Finset.sum_ite, Finset.filter_eq', Finset.filter_ne', hi ];
  rw [ mul_div_cancel₀ _ hi ]

/-
The kernel of a surjective linear map from K^n to K has finrank n-1.
-/
omit [Fintype K] in
theorem finrank_ker_of_surjective {n : ℕ}
    (φ : (Fin n → K) →ₗ[K] K) (hφ : Function.Surjective φ) :
    Module.finrank K (LinearMap.ker φ) = n - 1 := by
  have := LinearMap.finrank_range_add_finrank_ker φ;
  rw [ show φ.range = ⊤ from LinearMap.range_eq_top.mpr hφ ] at this ; simp_all +decide;
  exact eq_tsub_of_add_eq ( by rw [ add_comm ] ; exact this )

/-
The zero set of a nonzero linear form on K^n has cardinality at most |K|^{n-1}.
    This is the degree-1 Schwartz–Zippel bound.
-/
theorem nonzero_linear_form_zero_set_bound {n : ℕ}
    (v : Fin n → K) (hv : v ≠ 0) :
    Fintype.card {x : Fin n → K // ∑ i, v i * x i = 0} ≤
      (Fintype.card K) ^ (n - 1) := by
  -- The set {x | ∑ v i * x i = 0} is isomorphic to the kernel of the linear map dotProductLinearMap v : (Fin n → K) →ₗ[K] K.
  have h_isom : Fintype.card {x : (Fin n → K) | ∑ i, v i * x i = 0} = Fintype.card (LinearMap.ker (dotProductLinearMap v)) := by
    simp +decide [ dotProductLinearMap, LinearMap.mem_ker ];
  have h_card_ker : Fintype.card (LinearMap.ker (dotProductLinearMap v)) = Fintype.card K ^ (Module.finrank K (LinearMap.ker (dotProductLinearMap v))) := by
    exact Module.card_eq_pow_finrank
  have := finrank_ker_of_surjective ( dotProductLinearMap v ) ( dotProductLinearMap_surjective v hv ) ; aesop;

/-! ## Matrix Row Extraction -/

/-
A nonzero matrix has at least one nonzero row.
-/
omit [Fintype K] in
theorem exists_nonzero_row_of_ne_zero {m n : ℕ}
    (D : Matrix (Fin m) (Fin n) K)
    (hD : D ≠ 0) :
    ∃ i, D i ≠ 0 := by
  exact not_forall.mp fun h => hD <| Matrix.ext fun i j => by simp [ h ];

/-! ## Freivalds' Algorithm Bounds -/

/-
**Freivalds' Discrepancy Bound**: If D is a nonzero square matrix over a finite
    field K, then at most |K|^{n-1} vectors r satisfy D.mulVec r = 0.
-/
theorem freivalds_discrepancy_bound {n : ℕ}
    (D : Matrix (Fin n) (Fin n) K)
    (hD : D ≠ 0) :
    Fintype.card {r : Fin n → K // D.mulVec r = 0} ≤
      (Fintype.card K) ^ (n - 1) := by
  -- By there exists_nonzero_row_of_ne_zero, there exists i with D i ≠ 0 (i.e. the row function D i : Fin n → K is nonzero).
  obtain ⟨i, hi⟩ : ∃ i, D i ≠ 0 := exists_nonzero_row_of_ne_zero D hD;
  refine' le_trans _ ( nonzero_linear_form_zero_set_bound ( D i ) hi );
  exact Fintype.card_le_of_injective ( fun x ↦ ⟨ x.1, by simpa [ Matrix.mulVec, dotProduct ] using congr_fun x.2 i ⟩ ) fun x y h ↦ by aesop;

/-
**Freivalds' Bound**: If AB ≠ C, then at most |K|^{n-1} vectors r satisfy
    (AB).mulVec r = C.mulVec r.
-/
theorem freivalds_bound {n : ℕ}
    (A B C : Matrix (Fin n) (Fin n) K)
    (hneq : A * B ≠ C) :
    Fintype.card {r : Fin n → K // (A * B).mulVec r = C.mulVec r} ≤
      (Fintype.card K) ^ (n - 1) := by
  -- Set D = A * B - C. Then hneq implies D ≠ 0.
  set D : Matrix (Fin n) (Fin n) K := A * B - C
  have hD : D ≠ 0 := by
    exact sub_ne_zero_of_ne hneq;
  -- Since $D = A * B - C$, the condition $D.mulVec r = 0$ is equivalent to $(A * B).mulVec r = C.mulVec r$.
  have h_equiv : {r : Fin n → K | D.mulVec r = 0} = {r : Fin n → K | (A * B).mulVec r = C.mulVec r} := by
    simp +decide [ D, sub_eq_zero, Matrix.sub_mulVec ];
  convert freivalds_discrepancy_bound D hD using 1;
  exact Fintype.card_congr' (congrArg Subtype (id (Eq.symm h_equiv)))

/-! ## ZMod Specialization -/

/-
**Freivalds over ZMod q**: If D is a nonzero n×n matrix over ZMod q
    (q prime), then at most q^{n-1} vectors r satisfy D.mulVec r = 0.
-/
theorem freivalds_zmod_bound
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Fintype.card {r : Fin n → ZMod q // D.mulVec r = 0} ≤
      q ^ (n - 1) := by
  -- Apply the discrepancy bound for a field to get the result.
  have h_card : Fintype.card { r : Fin n → ZMod q // D *ᵥ r = 0 } ≤ (Fintype.card (ZMod q)) ^ (n - 1) := by
    convert freivalds_discrepancy_bound _ hD;
  rwa [ ZMod.card ] at h_card

/-
**Freivalds over ZMod q (product form)**: AB ≠ C implies few verifying vectors.
-/
theorem freivalds_zmod_product_bound
    {q n : ℕ} [Fact q.Prime]
    (A B C : Matrix (Fin n) (Fin n) (ZMod q))
    (hneq : A * B ≠ C) :
    Fintype.card {r : Fin n → ZMod q // (A * B).mulVec r = C.mulVec r} ≤
      q ^ (n - 1) := by
  have := freivalds_zmod_bound ((A * B) - C) ?_1;
  · simp_all +decide [ funext_iff, Matrix.sub_mulVec ];
    simpa only [ sub_eq_zero ] using this;
  · exact sub_ne_zero_of_ne hneq

/-! ## Probability Form -/

/-
**Freivalds error probability**: The probability that a uniformly random
    vector r over ZMod q satisfies D.mulVec r = 0, when D ≠ 0, is at most 1/q.
-/
theorem freivalds_error_probability
    {q n : ℕ} [Fact q.Prime] (hn : 0 < n)
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    (Fintype.card {r : Fin n → ZMod q // D.mulVec r = 0} : ℚ) /
      (Fintype.card (Fin n → ZMod q) : ℚ) ≤ 1 / q := by
  -- By Freivalds' bound, we have (card {r | D.mulVec r = 0} : ℚ) ≤ q ^ (n - 1).
  have h_card : (Fintype.card {r : (Fin n) → (ZMod q) | D.mulVec r = 0} : ℚ) ≤ q ^ (n - 1) := by
    exact_mod_cast freivalds_zmod_bound D hD;
  rw [ div_le_div_iff₀ ] <;> norm_cast at * <;> rcases n with ( _ | n ) <;> simp_all +decide [ pow_succ' ];
  · nlinarith;
  · exact ⟨ Nat.Prime.pos Fact.out, pow_pos ( Nat.Prime.pos Fact.out ) _ ⟩;
  · exact Nat.Prime.pos Fact.out

end Freivalds

end