/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Freivalds' Algorithm: Certified Matrix Product Verification

This file formalizes the exact finite-field soundness theorem for Freivalds' randomized
matrix product verification algorithm.

## Main results

* `card_ker_mulVecLin_le` — For any nonzero matrix `D` over `𝔽_q` (where `q` is prime),
  the kernel of `D.mulVecLin` has cardinality at most `q^(n-1)`.

* `card_solutions_mulVec_eq_zero_le` — Equivalent formulation: the set
  `{r | D.mulVec r = 0}` has cardinality at most `q^(n-1)`.

* `freivalds_product_verification` — If `A * B ≠ C`, then the number of vectors `r`
  for which `(A * B) r = C r` (false accepts) is at most `q^(n-1)`.

* `freivalds_false_accept_prob_le` — The false-accept probability is at most `1/q`.

## Proof strategy

The proof uses the rank-nullity theorem over finite fields:
1. A nonzero matrix induces a nonzero linear map, whose kernel is a proper subspace.
2. Over a field, proper subspaces have strictly smaller dimension.
3. Over a finite field `𝔽_q`, a subspace of dimension `d` has exactly `q^d` elements.
4. Combining: `|ker D| = q^(dim ker D) ≤ q^(n-1)`.
-/
import Mathlib

open Classical Matrix Fintype

noncomputable section

/-! ### Kernel cardinality bound for nonzero matrices -/

/-
The finrank of the kernel of `D.mulVecLin` is at most `n - 1` when `D ≠ 0`.
This is the dimension-theoretic core of the Freivalds bound.
-/
theorem finrank_ker_mulVecLin_le
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Module.finrank (ZMod q) (LinearMap.ker D.mulVecLin) ≤ n - 1 := by
  -- Since $D$ is a nonzero matrix, its linear map $D.mulVecLin$ is also nonzero.
  have h_mulVecLin_nonzero : D.mulVecLin ≠ 0 := by
    exact fun h => hD <| by ext i j; simpa using congr_fun ( LinearMap.congr_fun h ( Pi.single j 1 ) ) i;
  -- By the rank-nullity theorem, since $D$ is a nonzero matrix, its kernel is a proper subspace of $\mathbb{F}^n$.
  have h_ker_proper : (LinearMap.ker (D.mulVecLin)) ≠ ⊤ := by
    exact fun h => h_mulVecLin_nonzero <| LinearMap.ker_eq_top.mp h;
  exact Nat.le_sub_one_of_lt ( Submodule.finrank_lt h_ker_proper ) |> le_trans <| by simp +decide;

/-
The kernel of a nonzero linear map over a finite field `ZMod q` has cardinality
at most `q^(n-1)`. This is the key finite-field counting lemma underlying
Freivalds' algorithm and polynomial identity testing.
-/
theorem card_ker_mulVecLin_le
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Fintype.card (LinearMap.ker D.mulVecLin) ≤ q ^ (n - 1) := by
  -- Since $D \neq 0$, the linear map $D.mulVecLin$ is nonzero. Therefore, the kernel of $D.mulVecLin$ has dimension at most $n-1$.
  have h_ker_dim : Module.finrank (ZMod q) (LinearMap.ker D.mulVecLin) ≤ n - 1 := by
    exact finrank_ker_mulVecLin_le D hD
  -- Apply the fact that the cardinality of a finite-dimensional vector space over a finite field is q^dimension.
  have h_card : Fintype.card (LinearMap.ker D.mulVecLin) = (Fintype.card (ZMod q)) ^ Module.finrank (ZMod q) (LinearMap.ker D.mulVecLin) := by
    exact Module.card_eq_pow_finrank;
  exact h_card.symm ▸ by rw [ ZMod.card ] ; exact Nat.pow_le_pow_right ( Nat.Prime.pos Fact.out ) h_ker_dim;

/-- The set of solutions to `D.mulVec r = 0` is in bijection with the kernel
of `D.mulVecLin`. -/
def equivKerMulVecLin {R : Type*} [CommSemiring R] {n : ℕ}
    (D : Matrix (Fin n) (Fin n) R) :
    {r : Fin n → R // D.mulVec r = 0} ≃
    LinearMap.ker D.mulVecLin where
  toFun := fun ⟨r, hr⟩ => ⟨r, by exact hr⟩
  invFun := fun ⟨r, hr⟩ => ⟨r, by exact hr⟩
  left_inv := fun ⟨r, hr⟩ => rfl
  right_inv := fun ⟨r, hr⟩ => rfl

/-- Reformulation: the set of solutions to `D.mulVec r = 0` for a nonzero matrix `D`
has cardinality at most `q^(n-1)`. -/
theorem card_solutions_mulVec_eq_zero_le
    {q n : ℕ} [Fact q.Prime]
    (D : Matrix (Fin n) (Fin n) (ZMod q))
    (hD : D ≠ 0) :
    Fintype.card {r : Fin n → ZMod q // D.mulVec r = 0} ≤ q ^ (n - 1) := by
  rw [Fintype.card_congr (equivKerMulVecLin D)]
  exact card_ker_mulVecLin_le D hD

/-
`(A * B).mulVec r = C.mulVec r` iff `(A * B - C).mulVec r = 0`.
-/
theorem mulVec_eq_iff_sub_mulVec_eq_zero
    {R : Type*} [Ring R] {n : ℕ}
    (A C : Matrix (Fin n) (Fin n) R) (r : Fin n → R) :
    A.mulVec r = C.mulVec r ↔ (A - C).mulVec r = 0 := by
  simp_all +decide [Matrix.sub_mulVec, sub_eq_zero]

/-! ### Freivalds' algorithm: main theorem -/

/-- **Freivalds' Product Verification Theorem.**
If `A * B ≠ C` over `𝔽_q`, then the set of vectors `r` satisfying
`(A * B) r = C r` (false accepts) has size at most `q^(n-1)`.

This is the exact finite-field soundness guarantee for one round of
Freivalds' randomized matrix product checker. -/
theorem freivalds_product_verification
    {q n : ℕ} [Fact q.Prime]
    (A B C : Matrix (Fin n) (Fin n) (ZMod q))
    (hneq : A * B ≠ C) :
    Fintype.card {r : Fin n → ZMod q // (A * B).mulVec r = C.mulVec r}
      ≤ q ^ (n - 1) := by
  have hD : A * B - C ≠ 0 := sub_ne_zero.mpr hneq
  have : Fintype.card {r : Fin n → ZMod q // (A * B).mulVec r = C.mulVec r} =
         Fintype.card {r : Fin n → ZMod q // (A * B - C).mulVec r = 0} := by
    exact Fintype.card_congr
      { toFun := fun ⟨r, hr⟩ => ⟨r, (mulVec_eq_iff_sub_mulVec_eq_zero _ _ r).mp hr⟩
        invFun := fun ⟨r, hr⟩ => ⟨r, (mulVec_eq_iff_sub_mulVec_eq_zero _ _ r).mpr hr⟩
        left_inv := fun ⟨r, hr⟩ => rfl
        right_inv := fun ⟨r, hr⟩ => rfl }
  rw [this]
  exact card_solutions_mulVec_eq_zero_le _ hD

/-! ### Probability corollary -/

/-
**Freivalds' Soundness Corollary.**
For a uniformly random vector `r ∈ 𝔽_q^n`, the probability that Freivalds' check
falsely accepts (i.e., `(A * B) r = C r` when `A * B ≠ C`) is at most `1/q`.
-/
theorem freivalds_false_accept_prob_le
    {q n : ℕ} [Fact q.Prime]
    (A B C : Matrix (Fin n) (Fin n) (ZMod q))
    (hneq : A * B ≠ C) :
    ((Fintype.card {r : Fin n → ZMod q // (A * B).mulVec r = C.mulVec r} : ℚ)
      / (Fintype.card (Fin n → ZMod q) : ℚ))
      ≤ (1 : ℚ) / q := by
  -- Apply the previous result from `freivalds_product_verification`.
  have h := freivalds_product_verification A B C hneq;
  rw [ div_le_div_iff₀ ] <;> simp_all +decide;
  · rcases n <;> simp_all +decide [ pow_succ' ];
    · exact False.elim <| hneq <| by ext i; fin_cases i;
    · rw [ mul_comm ] ; gcongr ; norm_cast;
  · exact_mod_cast pow_pos ( Nat.Prime.pos Fact.out ) _;
  · exact Nat.Prime.pos Fact.out

end