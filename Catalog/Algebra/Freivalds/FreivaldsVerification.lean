/-
  # Freivalds' Matrix Verification Theorem

  A formalization of Freivalds' algorithm soundness as a finite-field
  hyperplane counting theorem. The key structural insight: a nonzero
  linear certificate over a finite field vanishes on at most a 1/q-fraction
  of random inputs.

  ## Main Results

  - `card_ker_dotProduct_eq`: For nonzero w : Fin p → ZMod q, the kernel
    of r ↦ dotProduct w r has exactly q^(p-1) elements.
  - `card_mulVec_eq_zero_le`: For nonzero M, the set {r | M.mulVec r = 0}
    has at most q^(p-1) elements.
  - `freivalds_soundness_card`: The cardinal form of Freivalds' theorem.
  - `freivalds_soundness_prob`: The probability form: Pr[false accept] ≤ 1/q.
-/

import Mathlib

open Classical Matrix Fintype

namespace Freivalds

variable {q : ℕ} [Fact q.Prime]

/-- The field instance on ZMod q when q is prime. -/
noncomputable instance : Field (ZMod q) := ZMod.instField _

/-! ## Helper: dotProduct as a linear map -/

/-- The linear functional r ↦ dotProduct w r. -/
noncomputable def dotProductLin {p : ℕ} (w : Fin p → ZMod q) :
    (Fin p → ZMod q) →ₗ[ZMod q] ZMod q where
  toFun r := dotProduct w r
  map_add' x y := by simp [dotProduct, mul_add, Finset.sum_add_distrib]
  map_smul' c x := by
    simp only [dotProduct, Pi.smul_apply, smul_eq_mul, RingHom.id_apply]
    rw [Finset.mul_sum]
    congr 1; ext i; ring

/-! ## Nonzero vector has a nonzero coordinate -/

omit [Fact q.Prime] in
theorem exists_ne_zero_of_ne_zero_vec {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) : ∃ j : Fin p, w j ≠ 0 := by
  exact Function.ne_iff.mp hw

/-! ## Nonzero matrix has a nonzero row -/

omit [Fact q.Prime] in
theorem exists_nonzero_row_of_matrix_ne_zero {m p : ℕ}
    {M : Matrix (Fin m) (Fin p) (ZMod q)} (hM : M ≠ 0) :
    ∃ i : Fin m, M i ≠ 0 := by
  exact not_forall.mp fun h => hM <| Matrix.ext fun i j => by simp +decide [ show M = 0 from funext h ] ;

/-! ## A nonzero linear functional is surjective -/

theorem dotProductLin_surjective {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) : Function.Surjective (dotProductLin w) := by
  -- Choose a coordinate j such that w j ≠ 0 (use exists_ne_zero_of_ne_zero_vec).
  obtain ⟨j, hj⟩ : ∃ j : Fin p, w j ≠ 0 := by
    exact Function.ne_iff.mp hw;
  intro y;
  -- Set r j = y / (w j) and r k = 0 for k ≠ j.
  use fun k => if k = j then y / (w j) else 0;
  unfold dotProductLin; simp +decide ;
  simp +decide [ dotProduct ];
  rw [ mul_div_cancel₀ _ hj ]

/-! ## Kernel dimension of a nonzero linear functional -/

theorem finrank_ker_dotProductLin {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) :
    Module.finrank (ZMod q) (dotProductLin w).ker = p - 1 := by
  -- By the rank-nullity theorem, we have $\text{finrank}(V) = \text{finrank}(\text{range}(f)) + \text{finrank}(\text{ker}(f))$.
  have h_rank_nullity : Module.finrank (ZMod q) (Fin p → ZMod q) = Module.finrank (ZMod q) (LinearMap.range (dotProductLin w)) + Module.finrank (ZMod q) (LinearMap.ker (dotProductLin w)) := by
    rw [ ← LinearMap.finrank_range_add_finrank_ker ( dotProductLin w ), add_comm ];
  -- Since the range of $f$ is nontrivial, its dimension is $1$.
  have h_range_dim : Module.finrank (ZMod q) (LinearMap.range (dotProductLin w)) = 1 := by
    rw [ LinearMap.range_eq_top.mpr ];
    · norm_num;
    · exact dotProductLin_surjective hw;
  exact eq_tsub_of_add_eq ( by norm_num at *; linarith )

/-! ## Core counting: kernel of dotProduct has exactly q^(p-1) elements -/

/-- The kernel of a nonzero linear functional over ZMod q has exactly q^(p-1) elements. -/
theorem card_ker_dotProduct_eq {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) :
    Fintype.card (dotProductLin w).ker = q ^ (p - 1) := by
  rw [Module.card_eq_pow_finrank (K := ZMod q), ZMod.card,
      finrank_ker_dotProductLin hw]

/-! ## Connecting mulVec kernel to dotProduct kernel -/

omit [Fact q.Prime] in
/-- If M.mulVec r = 0, then in particular dotProduct (M i) r = 0 for any row i. -/
theorem mulVec_zero_imp_row_zero {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (i : Fin m)
    (r : Fin p → ZMod q) (hr : M.mulVec r = 0) :
    dotProduct (M i) r = 0 := by
  convert congr_fun hr i using 1

/-! ## Connecting subtypes for the injection -/

theorem card_mulVec_zero_le_card_dotProduct_zero {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (i : Fin m) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} ≤
    Fintype.card {r : Fin p → ZMod q // dotProduct (M i) r = 0} := by
  convert Set.card_le_card ?__injective;
  · infer_instance;
  · infer_instance;
  · exact fun r hr => congr_fun hr i

/-! ## Connecting dotProduct kernel subtype to LinearMap.ker -/

theorem card_dotProduct_zero_eq_card_ker {p : ℕ} (w : Fin p → ZMod q) :
    Fintype.card {r : Fin p → ZMod q // dotProduct w r = 0} =
    Fintype.card (dotProductLin w).ker := by
  convert Fintype.card_eq.mpr _;
  refine' ⟨ fun x => ⟨ x.val, _ ⟩, fun x => ⟨ x.val, _ ⟩, fun x => _, fun x => _ ⟩ <;> aesop

/-! ## Main counting theorem -/

/-- **Core counting theorem**: For a nonzero matrix M over ZMod q,
    the number of vectors r with M.mulVec r = 0 is at most q^(p-1). -/
theorem card_mulVec_eq_zero_le {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} ≤ q ^ (p - 1) := by
  obtain ⟨i, hi⟩ := exists_nonzero_row_of_matrix_ne_zero hM
  calc Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ Fintype.card {r : Fin p → ZMod q // dotProduct (M i) r = 0} :=
        card_mulVec_zero_le_card_dotProduct_zero M i
    _ = Fintype.card (dotProductLin (M i)).ker :=
        card_dotProduct_zero_eq_card_ker (M i)
    _ = q ^ (p - 1) := card_ker_dotProduct_eq hi

/-! ## Freivalds' theorem: cardinal form -/

/-
Rewriting: K.mulVec r = (A * B).mulVec r iff (K - A * B).mulVec r = 0
-/
theorem eq_mulVec_iff_sub_mulVec_eq_zero {m n p : ℕ}
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    K.mulVec r = (A * B).mulVec r ↔ (K - A * B).mulVec r = 0 := by
  simp +decide [ sub_mulVec ];
  rw [ sub_eq_zero ]

/-- **Freivalds' soundness (cardinal form)**: If K ≠ A * B, then the number
    of vectors r with K.mulVec r = (A * B).mulVec r is at most q^(p-1). -/
theorem freivalds_soundness_card {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} ≤
      q ^ (p - 1) := by
  have hM : K - A * B ≠ 0 := sub_ne_zero.mpr hne
  have : Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} =
         Fintype.card {r : Fin p → ZMod q // (K - A * B).mulVec r = 0} := by
    apply Fintype.card_congr
    exact Equiv.subtypeEquiv (Equiv.refl _) (fun r => eq_mulVec_iff_sub_mulVec_eq_zero K A B r)
  rw [this]
  exact card_mulVec_eq_zero_le (K - A * B) hM

/-! ## Total space cardinality -/

theorem card_fin_fun_zmod (p : ℕ) :
    Fintype.card (Fin p → ZMod q) = q ^ p := by
  rw [Fintype.card_fun, ZMod.card, Fintype.card_fin]

/-! ## Freivalds' theorem: probability form -/

/-
**Freivalds' soundness (probability form)**: If K ≠ A * B, then the
    probability that a uniformly random r satisfies K.mulVec r = (A * B).mulVec r
    is at most 1/q.
-/
theorem freivalds_soundness_prob {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    (Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} : ℚ) /
      Fintype.card (Fin p → ZMod q) ≤ 1 / q := by
  cases p <;> simp_all +decide [ Fintype.card_subtype ];
  · exact False.elim <| hne <| by ext i j; fin_cases j;
  · rw [ inv_eq_one_div, div_le_div_iff₀ ] <;> norm_cast;
    · convert Nat.mul_le_mul_right q ( freivalds_soundness_card A B K hne ) using 1;
      · rw [ Fintype.card_subtype ];
      · norm_num [ pow_succ ];
    · exact pow_pos ( Nat.Prime.pos Fact.out ) _;
    · exact Nat.Prime.pos Fact.out

end Freivalds