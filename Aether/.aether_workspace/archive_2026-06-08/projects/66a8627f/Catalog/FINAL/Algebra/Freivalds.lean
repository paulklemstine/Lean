/-
  # Freivalds' Matrix Verification Theorem: A Finite-Field Hyperplane Counting Engine

  This file formalizes a sharp finite-field version of Freivalds' matrix verification
  theorem, exposing the structural reason the failure probability is exactly controlled
  by the codimension of a kernel.

  The core insight: **A nonzero linear certificate over a finite field vanishes on at
  most a 1/q-fraction of random inputs.** This is the finite-field prototype of the
  Schwartz–Zippel lemma and the foundation for randomized algebraic verification.

  ## Main Results

  ### Structural lemmas
  - `Freivalds.exists_nonzero_coord`: A nonzero vector has a nonzero coordinate.
  - `Freivalds.exists_nonzero_row`: A nonzero matrix has a nonzero row.

  ### Core hyperplane counting
  - `Freivalds.card_solutions_single_nontrivial_linear_eq`: Solutions to a nontrivial
    linear equation `⟨w, r⟩ = b` over `ZMod q` number exactly `q^(p-1)`.
  - `Freivalds.card_mulVec_eq_zero_le`: For a nonzero matrix `M`, the vectors `r`
    with `M.mulVec r = 0` number at most `q^(p-1)`.

  ### Freivalds' soundness
  - `Freivalds.freivalds_soundness_card`: Cardinal form of the soundness bound.
  - `Freivalds.freivalds_soundness_prob`: Probability form: `Pr[accept false claim] ≤ 1/q`.
-/

import Mathlib

open Classical Matrix Finset Fintype

namespace Freivalds

variable {q : ℕ} [hq : Fact q.Prime]

/-! ## Structural Lemmas -/

/-- A nonzero function has a nonzero value. -/
theorem exists_nonzero_coord {α : Type*} [Fintype α] {F : Type*}
    [Zero F] {w : α → F} (hw : w ≠ 0) : ∃ j, w j ≠ 0 :=
  Function.ne_iff.mp hw

/-- A nonzero matrix has at least one nonzero row. -/
theorem exists_nonzero_row {m p : Type*} [Fintype m] [Fintype p]
    {F : Type*} [Zero F] {M : Matrix m p F} (hM : M ≠ 0) :
    ∃ i, M i ≠ 0 := by
  by_contra h; push_neg at h; exact hM (funext h)

/-! ## The linear functional and its kernel -/

/-- The dot product with a fixed vector, viewed as a linear map over `ZMod q`. -/
noncomputable def dotLin {p : ℕ} (w : Fin p → ZMod q) :
    (Fin p → ZMod q) →ₗ[ZMod q] ZMod q where
  toFun r := ∑ i : Fin p, w i * r i
  map_add' x y := by simp [mul_add, Finset.sum_add_distrib]
  map_smul' c x := by
    simp only [Pi.smul_apply, smul_eq_mul, RingHom.id_apply, Finset.mul_sum]
    congr 1; ext i; ring

/-- A nonzero linear functional over `ZMod q` is surjective. -/
theorem dotLin_surjective {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) : Function.Surjective (dotLin w) := by
  obtain ⟨j, hj⟩ := exists_nonzero_coord hw
  intro y
  exact ⟨fun i => if i = j then y / w j else 0, by
    simp [dotLin, hj, mul_div_cancel₀]⟩

/-
The kernel of a nonzero linear functional has `finrank = p - 1`.
-/
theorem finrank_ker_dotLin {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) :
    Module.finrank (ZMod q) (LinearMap.ker (dotLin w)) = p - 1 := by
  have := LinearMap.finrank_range_add_finrank_ker ( dotLin w );
  rw [ show ( dotLin w |> LinearMap.range ) = ⊤ from LinearMap.range_eq_top.mpr ( dotLin_surjective hw ) ] at this ; norm_num at * ; omega

/-
The kernel of a nonzero linear functional has exactly `q^(p-1)` elements.
-/
theorem card_ker_dotLin {p : ℕ} {w : Fin p → ZMod q}
    (hw : w ≠ 0) :
    Fintype.card (LinearMap.ker (dotLin w)) = q ^ (p - 1) := by
  have := finrank_ker_dotLin hw;
  convert @Module.card_eq_pow_finrank ( ZMod q ) _ _ _ _ _ _;
  all_goals try infer_instance;
  · exact Eq.symm (ZMod.card q)
  · exact this.symm

/-! ## Exact solution count for a single nontrivial linear equation -/

/-
**Exact hyperplane count**: The number of solutions to `dotProduct w r = b`
over `ZMod q`, when `w ≠ 0`, is exactly `q^(p-1)`.

This is the combinatorial heart of Freivalds' theorem and the degree-1 case
of Schwartz–Zippel over finite fields.
-/
theorem card_solutions_single_nontrivial_linear_eq
    {p : ℕ} (w : Fin p → ZMod q) (hw : w ≠ 0) (b : ZMod q) :
    Fintype.card {r : Fin p → ZMod q // dotProduct w r = b} = q ^ (p - 1) := by
  -- The set of solutions to `dotProduct w r = b` forms a coset of the kernel of `dotLin w`.
  have h_coset : ∃ x₀ : Fin p → ZMod q, ∀ r : Fin p → ZMod q, w ⬝ᵥ r = b ↔ r - x₀ ∈ LinearMap.ker (dotLin w) := by
    -- By definition of dot product, we know that `dotProduct w r = b` if and only if `dotLin w r = b`.
    have h_dotLin_eq : ∀ r : Fin p → ZMod q, w ⬝ᵥ r = b ↔ dotLin w r = b := by
      exact fun r => Iff.rfl;
    -- Since `dotLin w` is surjective, there exists some `x₀` such that `dotLin w x₀ = b`.
    obtain ⟨x₀, hx₀⟩ : ∃ x₀ : Fin p → ZMod q, dotLin w x₀ = b := by
      exact dotLin_surjective hw b;
    use x₀; intro r; simp +decide [ h_dotLin_eq, hx₀, sub_eq_zero ] ;
  -- The set of solutions to `dotProduct w r = b` is in bijection with the kernel of `dotLin w`.
  have h_bij : Nonempty ( { r : Fin p → ZMod q // w ⬝ᵥ r = b } ≃ LinearMap.ker (dotLin w) ) := by
    refine' ⟨ fun x => ⟨ x.val - h_coset.choose, h_coset.choose_spec x.val |>.1 x.prop ⟩, fun x => ⟨ x.val + h_coset.choose, h_coset.choose_spec ( x.val + h_coset.choose ) |>.2 ( by simp ) ⟩, fun x => _, fun x => _ ⟩ <;> aesop;
  erw [ Fintype.card_congr h_bij.some, card_ker_dotLin hw ]

/-! ## Kernel bound for matrix-vector multiplication -/

/-
The set of `r` with `M.mulVec r = 0` injects into the kernel of
`dotLin (M i)` for any row `i`.
-/
theorem card_mulVec_zero_le_row {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (i : Fin m) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ Fintype.card (LinearMap.ker (dotLin (M i))) := by
  refine' ( Fintype.card_le_of_injective _ _ );
  exact fun r => ⟨ r.1, by simpa [ dotLin ] using congr_fun r.2 i ⟩;
  intro r s h; aesop;

/-- **Core counting theorem**: For a nonzero matrix `M` over `ZMod q`,
the number of vectors `r` with `M.mulVec r = 0` is at most `q^(p-1)`. -/
theorem card_mulVec_eq_zero_le
    {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ q ^ (p - 1) := by
  obtain ⟨i, hi⟩ := exists_nonzero_row hM
  calc Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ Fintype.card (LinearMap.ker (dotLin (M i))) :=
        card_mulVec_zero_le_row M i
    _ = q ^ (p - 1) := card_ker_dotLin hi

/-! ## Freivalds' Soundness -/

/-
The mulVec equality `K.mulVec r = L.mulVec r` is equivalent to
`(K - L).mulVec r = 0`.
-/
theorem eq_mulVec_iff_sub_mulVec_eq_zero {m p : ℕ}
    (K L : Matrix (Fin m) (Fin p) (ZMod q))
    (r : Fin p → ZMod q) :
    K.mulVec r = L.mulVec r ↔ (K - L).mulVec r = 0 := by
  simp +decide [ sub_mulVec, sub_eq_zero ]

/-
**Freivalds' soundness (cardinal form)**: If `K ≠ A * B`, then the
number of random vectors `r` for which `K.mulVec r = (A * B).mulVec r`
is at most `q^(p-1)`.
-/
theorem freivalds_soundness_card
    {m n p : ℕ}
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r}
      ≤ q ^ (p - 1) := by
  have := card_mulVec_eq_zero_le ( K - A * B ) ?_;
  · convert this using 4 ; simp +decide [Matrix.sub_mulVec];
    rw [ sub_eq_zero ];
  · exact sub_ne_zero_of_ne hne

/-
**Freivalds' soundness (probability form)**: If `K ≠ A * B`, then the
probability that a uniformly random `r : Fin p → ZMod q` yields
`K.mulVec r = (A * B).mulVec r` is at most `1/q`.
-/
theorem freivalds_soundness_prob
    {m n p : ℕ} (hp : 0 < p)
    (A : Matrix (Fin m) (Fin n) (ZMod q))
    (B : Matrix (Fin n) (Fin p) (ZMod q))
    (K : Matrix (Fin m) (Fin p) (ZMod q))
    (hne : K ≠ A * B) :
    ((Fintype.card {r : Fin p → ZMod q // K.mulVec r = (A * B).mulVec r} : ℚ) /
      Fintype.card (Fin p → ZMod q))
      ≤ (1 : ℚ) / q := by
  rw [ div_le_div_iff₀ ] <;> norm_cast <;> norm_num [ Fintype.card_pi, ZMod.card ];
  · convert Nat.mul_le_mul_right q ( freivalds_soundness_card A B K hne ) using 1;
    rw [ ← pow_succ, Nat.sub_add_cancel hp ];
  · exact pow_pos hq.1.pos _;
  · exact hq.1.pos

end Freivalds