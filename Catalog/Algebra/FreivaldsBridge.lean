/-
  # Freivalds' Algorithm: Matrix Product Verification via Polynomial Soundness

  This file establishes the bridge from polynomial root bounds to
  matrix product verification (Freivalds' algorithm), and then connects
  to polynomial identity testing.

  ## Main Results

  - `freivalds_bad_vectors_card_le`: The number of "bad" random vectors r
    for which (A * B).mulVec r = C.mulVec r despite A * B ≠ C is at most
    |F|^(k-1).
  - `freivalds_error_prob`: The probability of a false accept is ≤ 1/|F|.
  - `polynomial_identity_from_agreement`: Polynomials agreeing on too many
    points must be equal.
-/

import Mathlib
import Algebra.PolynomialSoundness.RootBound

open Classical Matrix Finset Fintype

/-! ## Freivalds' Algorithm over arbitrary finite fields -/

section Freivalds

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

omit [Fintype F] [DecidableEq F] in
/-- A nonzero vector over a field has at least one nonzero coordinate. -/
theorem exists_nonzero_coord {k : Type*} [Fintype k]
    {w : k → F} (hw : w ≠ 0) : ∃ j, w j ≠ 0 :=
  Function.ne_iff.mp hw

omit [Fintype F] in
/-- A nonzero matrix has at least one nonzero row. -/
theorem exists_nonzero_row {m k : Type*} [Fintype m] [Fintype k]
    {M : Matrix m k F} (hM : M ≠ 0) : ∃ i, M i ≠ 0 := by
  by_contra h; push_neg at h; exact hM (funext h)

/-- The dot product with a vector, viewed as a linear map. -/
noncomputable def dotLin {k : Type*} [Fintype k] (w : k → F) :
    (k → F) →ₗ[F] F where
  toFun r := ∑ i : k, w i * r i
  map_add' x y := by simp [mul_add, Finset.sum_add_distrib]
  map_smul' c x := by
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    congr 1; ext i; ring

omit [Fintype F] [DecidableEq F] in
/-- A nonzero linear functional on a vector space is surjective. -/
theorem dotLin_surjective {k : Type*} [Fintype k]
    {w : k → F} (hw : w ≠ 0) : Function.Surjective (dotLin w) := by
  -- Choose coordinate j where w j ≠ 0.
  obtain ⟨j, hj⟩ : ∃ j, w j ≠ 0 := by
    exact Function.ne_iff.mp hw;
  intro y;
  refine' ⟨ fun i => if i = j then y / w j else 0, _ ⟩;
  simp +decide [ dotLin, hj, mul_div_cancel₀ ]

omit [Fintype F] [DecidableEq F] in
/-- The kernel of a nonzero linear functional has finrank = dim - 1. -/
theorem finrank_ker_dotLin {k : Type*} [Fintype k]
    {w : k → F} (hw : w ≠ 0) :
    Module.finrank F (LinearMap.ker (dotLin w)) = Fintype.card k - 1 := by
  have := LinearMap.finrank_range_add_finrank_ker ( dotLin w );
  -- The range of the dot product with a nonzero vector is all of F, so its dimension is 1.
  have h_range : Module.finrank F (↥(dotLin w).range) = 1 := by
    rw [ show ( dotLin w |> LinearMap.range ) = ⊤ from LinearMap.range_eq_top.mpr ( dotLin_surjective hw ) ] ; simp +decide;
  exact eq_tsub_of_add_eq ( by rw [ h_range, Module.finrank_pi ] at this; simp +decide at this; linarith )

omit [DecidableEq F] in
/-- The kernel of a nonzero linear functional has exactly |F|^(dim-1) elements. -/
theorem card_ker_dotLin {k : Type*} [Fintype k]
    {w : k → F} (hw : w ≠ 0) :
    Fintype.card (LinearMap.ker (dotLin w)) = Fintype.card F ^ (Fintype.card k - 1) := by
  rw [Module.card_eq_pow_finrank (K := F), finrank_ker_dotLin hw]

/-
The set of vectors in the kernel of M.mulVec embeds into the kernel
of the dot product with any row of M.
-/
theorem card_mulVec_zero_le_row {m k : Type*} [Fintype m] [Fintype k]
    (M : Matrix m k F) (i : m) :
    Fintype.card {r : k → F // M.mulVec r = 0}
      ≤ Fintype.card (LinearMap.ker (dotLin (M i))) := by
  refine' Fintype.card_le_of_injective _ _;
  refine' fun r => ⟨ r.val, _ ⟩;
  exacts [ by simpa [ Matrix.mulVec ] using congr_fun r.2 i, fun x y h => by simpa [ Subtype.ext_iff ] using h ]

/-- **Core counting theorem**: For a nonzero matrix `M` over a finite
field `F`, the number of vectors `r` with `M.mulVec r = 0` is at most
`|F|^(k-1)`. -/
theorem card_mulVec_zero_le {m k : Type*} [Fintype m] [Fintype k]
    (M : Matrix m k F) (hM : M ≠ 0) :
    Fintype.card {r : k → F // M.mulVec r = 0}
      ≤ Fintype.card F ^ (Fintype.card k - 1) := by
  obtain ⟨i, hi⟩ := exists_nonzero_row (M := M) hM
  calc Fintype.card {r : k → F // M.mulVec r = 0}
      ≤ Fintype.card (LinearMap.ker (dotLin (M i))) :=
        card_mulVec_zero_le_row M i
    _ = Fintype.card F ^ (Fintype.card k - 1) := card_ker_dotLin hi

/-
**Freivalds' soundness (cardinality form)**: If `A * B ≠ C`, then
the number of random vectors `r : k → F` for which
`(A * B).mulVec r = C.mulVec r` is at most `|F|^(k-1)`.
-/
theorem freivalds_bad_vectors_card_le
    {m n k : Type*} [Fintype m] [Fintype n] [Fintype k]
    (A : Matrix m n F) (B : Matrix n k F) (C : Matrix m k F)
    (hneq : A * B ≠ C) :
    Fintype.card {r : k → F // (A * B).mulVec r = C.mulVec r}
      ≤ Fintype.card F ^ (Fintype.card k - 1) := by
  convert card_mulVec_zero_le ( A * B - C ) _ using 1;
  · simp +decide only [sub_mulVec, sub_eq_zero];
  · exact sub_ne_zero_of_ne hneq

/-
**Freivalds' soundness (probability form)**: If `A * B ≠ C`, the
probability that a uniformly random `r` gives `(A*B)r = Cr` is at
most `1/|F|`.
-/
theorem freivalds_error_prob
    {m n : Type*} [Fintype m] [Fintype n]
    {k : Type*} [Fintype k] [Nonempty k]
    (A : Matrix m n F) (B : Matrix n k F) (C : Matrix m k F)
    (hneq : A * B ≠ C) :
    (Fintype.card {r : k → F // (A * B).mulVec r = C.mulVec r} : ℚ) /
      Fintype.card (k → F) ≤ 1 / Fintype.card F := by
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> try positivity;
  convert Nat.mul_le_mul_right ( Fintype.card F ) ( freivalds_bad_vectors_card_le A B C hneq ) using 1 ; simp +decide [ mul_comm ];
  rw [ ← pow_succ', Nat.sub_add_cancel ( Fintype.card_pos ) ]

end Freivalds

/-! ## Polynomial Identity Testing: Bridge Theorem -/

section PIT

variable {F : Type*} [Field F]

/-- **Polynomial identity testing**: If two polynomials `p` and `q` with
`(p - q).natDegree ≤ d` agree on more than `d` points from a set `s`,
then they are equal. This is the contrapositive of the root bound. -/
theorem polynomial_identity_from_agreement
    (p q : Polynomial F) {d : ℕ} (hdeg : (p - q).natDegree ≤ d)
    (s : Finset F) (hs : d < s.card)
    (hagree : ∀ a ∈ s, p.eval a = q.eval a) :
    p = q := by
  by_contra hne
  have hpq : p - q ≠ 0 := sub_ne_zero.mpr hne
  have hle := card_roots_le_natDegree_filter (p - q) hpq s
  have hsub : s ⊆ s.filter fun a => (p - q).eval a = 0 := by
    intro a ha
    simp only [Finset.mem_filter]
    exact ⟨ha, by rw [Polynomial.eval_sub]; exact sub_eq_zero.mpr (hagree a ha)⟩
  have : s.card ≤ (s.filter fun a => (p - q).eval a = 0).card :=
    Finset.card_le_card hsub
  linarith

end PIT