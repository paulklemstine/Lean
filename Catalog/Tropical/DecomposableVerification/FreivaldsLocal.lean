/-
Copyright (c) 2025 Harmonic. All rights reserved.

# Freivalds' Algorithm — Local-to-Global Detection Principle

## Overview

This file formalizes the core soundness bound for Freivalds' randomized
matrix verification algorithm over finite fields. The key insight is that
a nonzero matrix identity failure is detectable by a random linear probe
with probability at least `1 - 1/|F|`.

The engine behind Freivalds is that a nonzero linear form over F^n
has a zero set of cardinality exactly |F|^(n-1). This means any nonzero
row of the discrepancy matrix D = AB - C creates a hyperplane that
a random vector avoids with probability ≥ 1 - 1/|F|.

## Main Results

* `nonzero_linear_form_zero_set_card` — Exact kernel cardinality of a
  nonzero linear form over F^n.
* `freivalds_soundness_bound` — The accepting set of a false identity
  has cardinality ≤ |F|^(n-1).
* `freivalds_detection_probability` — The probability of acceptance
  given a false identity is at most 1/|F|.
-/
import Mathlib

open Classical in
noncomputable section

open Matrix Finset BigOperators

/-! ## Linear Form Kernel Cardinality -/

/-- The dot product with a fixed vector defines a linear map. -/
def dotProductLinearMap' {K : Type*} [Field K] {p : ℕ} (v : Fin p → K) :
    (Fin p → K) →ₗ[K] K where
  toFun x := ∑ i, v i * x i
  map_add' x y := by simp [mul_add, Finset.sum_add_distrib]
  map_smul' r x := by
    simp only [RingHom.id_apply, smul_eq_mul, Finset.mul_sum]
    congr 1; ext i; simp [Pi.smul_apply, smul_eq_mul]; ring

/-
A nonzero vector defines a surjective linear map via dot product.
-/
private theorem dotProductLinearMap_surjective' {K : Type*} [Field K] {p : ℕ}
    (v : Fin p → K) (hv : v ≠ 0) :
    Function.Surjective (dotProductLinearMap' v) := by
  -- Since $v \neq 0$, there exists some $i$ such that $v i \neq 0$.
  obtain ⟨i, hi⟩ : ∃ i, v i ≠ 0 := by
    exact Function.ne_iff.mp hv;
  intro y
  use fun j => if j = i then y / v i else 0
  simp [dotProductLinearMap', hi];
  rw [ mul_div_cancel₀ _ hi ]

/-
The finrank of the kernel of the dot product map equals p - 1.
-/
private theorem finrank_ker_dotProduct' {K : Type*} [Field K] {p : ℕ}
    (v : Fin p → K) (hv : v ≠ 0) :
    Module.finrank K (LinearMap.ker (dotProductLinearMap' v)) = p - 1 := by
  -- By the rank-nullity theorem, since the map is surjective, the dimension of the kernel is $p - 1$.
  have h_rank_nullity : Module.finrank K (LinearMap.range (dotProductLinearMap' v)) + Module.finrank K (LinearMap.ker (dotProductLinearMap' v)) = p := by
    have := LinearMap.finrank_range_add_finrank_ker ( dotProductLinearMap' v );
    aesop;
  exact eq_tsub_of_add_eq ( by rw [ show Module.finrank K ( LinearMap.range ( dotProductLinearMap' v ) ) = 1 by rw [ show LinearMap.range ( dotProductLinearMap' v ) = ⊤ from LinearMap.range_eq_top.mpr ( dotProductLinearMap_surjective' v hv ) ] ; simp +decide ] at h_rank_nullity; linarith )

/-
**Nonzero linear form zero set cardinality.**
    For a nonzero linear form ℓ on F^n defined by dot product with v,
    the zero set {x | v · x = 0} has cardinality exactly |F|^(n-1).
    This is the combinatorial engine behind Freivalds.
-/
theorem nonzero_linear_form_zero_set_card
    {F : Type*} [Field F] [Fintype F]
    {n : ℕ} (v : Fin n → F) (hv : v ≠ 0) :
    Fintype.card {x : Fin n → F // (∑ i, v i * x i) = 0} =
      (Fintype.card F) ^ (n - 1) := by
  -- By finrank_ker_dotProduct', the kernel has finrank n-1.
  have h_finrank : Module.finrank F (LinearMap.ker (dotProductLinearMap' v)) = n - 1 := by
    exact?;
  -- Since the kernel is a subspace of F^n, its cardinality is |F|^(finrank of the kernel).
  have h_card : Fintype.card (LinearMap.ker (dotProductLinearMap' v)) = Fintype.card F ^ (Module.finrank F (LinearMap.ker (dotProductLinearMap' v))) := by
    exact?;
  grind +locals

/-- **Nonzero linear form zero set bound (inequality version).** -/
theorem nonzero_linear_form_zero_set_bound
    {F : Type*} [Field F] [Fintype F]
    {n : ℕ} (v : Fin n → F) (hv : v ≠ 0) :
    Fintype.card {x : Fin n → F // (∑ i, v i * x i) = 0} ≤
      (Fintype.card F) ^ (n - 1) :=
  le_of_eq (nonzero_linear_form_zero_set_card v hv)

/-! ## Nonzero Matrix Row Extraction -/

/-- A nonzero matrix has at least one nonzero row. -/
private theorem exists_nonzero_row' {F : Type*} [Zero F] {n : ℕ}
    (D : Matrix (Fin n) (Fin n) F) (hD : D ≠ 0) :
    ∃ i, D i ≠ 0 := by
  by_contra h
  push_neg at h
  exact hD (Matrix.ext fun i j => by simp [show D i = 0 from h i])

/-! ## Freivalds Soundness -/

/-
**Freivalds soundness bound (cardinality form).**
    For matrices over a finite field, if `A * B ≠ C`, then the set of
    random vectors `r` satisfying `A.mulVec (B.mulVec r) = C.mulVec r`
    has cardinality at most `|F|^(n-1)`.

    This is the classical single-trial Freivalds bound.
-/
theorem freivalds_soundness_bound
    {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {n : ℕ}
    (A B C : Matrix (Fin n) (Fin n) F)
    (hneq : A * B ≠ C) :
    Fintype.card
      {r : Fin n → F // A.mulVec (B.mulVec r) = C.mulVec r}
      ≤ (Fintype.card F) ^ (n - 1) := by
  -- Let $D = AB - C$. Since $hneq$, $D \neq 0$.
  set D : Matrix (Fin n) (Fin n) F := A * B - C
  have hD : D ≠ 0 := by
    exact sub_ne_zero_of_ne hneq;
  -- Extract a nonzero row $i$ of $D$ using `exists_nonzero_row'`.
  obtain ⟨i, hi⟩ : ∃ i, D i ≠ 0 := exists_nonzero_row' D hD;
  -- The set {r | A.mulVec (B.mulVec r) = C.mulVec r} is equivalent to {r | D.mulVec r = 0}.
  have h_equiv : {r : Fin n → F | A.mulVec (B.mulVec r) = C.mulVec r} = {r : Fin n → F | D.mulVec r = 0} := by
    simp +decide [ D, sub_mul, Matrix.sub_mulVec ];
    simp +decide only [sub_eq_zero];
  -- The set {r | D.mulVec r = 0} is a subset of {r | ∑ j, D i j * r j = 0}.
  have h_subset : {r : Fin n → F | D.mulVec r = 0} ⊆ {r : Fin n → F | ∑ j, D i j * r j = 0} := by
    exact fun r hr => congr_fun hr i;
  -- The set {r | ∑ j, D i j * r j = 0} has cardinality at most |F|^(n-1) by the nonzero_linear_form_zero_set_bound theorem.
  have h_card : Fintype.card {r : Fin n → F | ∑ j, D i j * r j = 0} ≤ (Fintype.card F) ^ (n - 1) := by
    convert nonzero_linear_form_zero_set_bound ( D i ) hi using 1;
    convert rfl;
  refine' le_trans _ h_card;
  exact Fintype.card_le_of_injective ( fun x => ⟨ x, h_subset <| h_equiv.subset x.2 ⟩ ) fun x y hxy => by aesop;

/-
**Freivalds detection probability.**
    If `A * B ≠ C`, then the probability that a uniformly random `r`
    satisfies `A.mulVec (B.mulVec r) = C.mulVec r` is at most `1/|F|`.
-/
theorem freivalds_detection_probability
    {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    {n : ℕ} (hn : 0 < n) [NeZero (Fintype.card F)]
    (A B C : Matrix (Fin n) (Fin n) F)
    (hneq : A * B ≠ C) :
    ((Fintype.card {r : Fin n → F // A.mulVec (B.mulVec r) = C.mulVec r} : ℚ) /
      (Fintype.card (Fin n → F) : ℚ))
      ≤ 1 / (Fintype.card F : ℚ) := by
  -- By the soundness bound, we have Fintype.card {r : Fin n → F // (A * B).mulVec r = C.mulVec r} ≤ Fintype.card F ^ (n - 1).
  have h_card : Fintype.card {r : Fin n → F // (A * B).mulVec r = C.mulVec r} ≤ Fintype.card F ^ (n - 1) := by
    convert freivalds_soundness_bound A B C hneq using 1;
    simp +decide only [mulVec_mulVec];
  rcases n with ( _ | n ) <;> simp_all +decide [ pow_succ, div_le_iff₀ ];
  rw [ inv_eq_one_div, div_le_div_iff₀ ] <;> norm_cast <;> nlinarith [ NeZero.pos ( Fintype.card F ), pow_pos ( NeZero.pos ( Fintype.card F ) ) n ]

end