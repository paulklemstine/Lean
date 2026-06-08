/-
  # Freivalds as a Corollary of Schwartz–Zippel over Finite Fields

  This module formalizes the conceptual bridge between Freivalds' randomized matrix
  verification algorithm and the Schwartz–Zippel lemma. The core insight:

  > **Freivalds' one-sided error phenomenon is the degree-1 case of Schwartz–Zippel.**

  We construct the explicit multivariate polynomial associated to a linear form,
  prove its degree bound and nontriviality, and then derive the solution count bound.
  The matrix-level theorem follows by extracting a nonzero row.

  ## Main Results

  - `linearRowPoly`: The multivariate polynomial ∑ⱼ C(wⱼ) * Xⱼ associated to a
    coefficient vector w.
  - `eval_linearRowPoly`: Evaluation of `linearRowPoly w` at r equals ∑ⱼ wⱼ * rⱼ.
  - `totalDegree_linearRowPoly_le_one`: The total degree of `linearRowPoly w` is ≤ 1.
  - `linearRowPoly_ne_zero`: If w ≠ 0, then `linearRowPoly w ≠ 0`.
  - `card_solutions_linear_form_le`: For nonzero w, |{r | ∑ⱼ wⱼrⱼ = 0}| ≤ q^(p-1).
  - `freivalds_from_schwartz_zippel`: For nonzero M, |{r | M·r = 0}| ≤ q^(p-1).

  ## Cross-Domain Connections

  1. **Randomized algorithms / Freivalds**: The matrix verification guarantee becomes
     a polynomial zero-set bound.
  2. **Polynomial identity testing (PIT)**: Freivalds is the degree-1 case of black-box
     PIT over finite fields.
  3. **Coding theory**: A nonzero row defines a parity-check equation; this bounds
     the fraction of words satisfying a nontrivial parity check.
  4. **Algebraic complexity**: This is the finite-field degree-vs-error mechanism
     underlying soundness of algebraic protocols.
-/

import Mathlib

open Matrix Finset Fintype BigOperators MvPolynomial

variable {q : ℕ} [hq : Fact q.Prime]

/-! ## The linear row polynomial -/

/-- The multivariate polynomial ∑ⱼ C(wⱼ) * Xⱼ associated to a coefficient vector w.
    This is the degree-1 polynomial whose zero set over a finite field is bounded
    by the Schwartz–Zippel lemma. -/
noncomputable def linearRowPoly {p : ℕ} (w : Fin p → ZMod q) :
    MvPolynomial (Fin p) (ZMod q) :=
  ∑ j, MvPolynomial.C (w j) * MvPolynomial.X j

/-- Evaluation of `linearRowPoly w` at r computes the dot product ∑ⱼ wⱼ * rⱼ. -/
theorem eval_linearRowPoly {p : ℕ} (w r : Fin p → ZMod q) :
    MvPolynomial.eval r (linearRowPoly w) = ∑ j, w j * r j := by
  simp [linearRowPoly, map_sum]

/-
The total degree of `linearRowPoly w` is at most 1.
-/
theorem totalDegree_linearRowPoly_le_one {p : ℕ} (w : Fin p → ZMod q) :
    (linearRowPoly w).totalDegree ≤ 1 := by
      refine' Finset.sup_le fun i hi => _;
      unfold linearRowPoly at hi;
      simp_all +decide [ MvPolynomial.coeff_sum, MvPolynomial.coeff_C_mul, MvPolynomial.coeff_X' ];
      obtain ⟨ x, hx ⟩ := Finset.exists_ne_zero_of_sum_ne_zero hi; aesop;

/-
If w ≠ 0, then `linearRowPoly w` is a nonzero polynomial.
-/
theorem linearRowPoly_ne_zero {p : ℕ} (w : Fin p → ZMod q) (hw : w ≠ 0) :
    linearRowPoly w ≠ 0 := by
      -- By definition of $linearRowPoly$, there exists some $j$ such that $w j ≠ 0$.
      obtain ⟨j, hj⟩ : ∃ j, w j ≠ 0 := by
        exact Function.ne_iff.mp hw;
      refine' ne_of_apply_ne ( fun p => MvPolynomial.coeff ( Finsupp.single j 1 ) p ) _;
      simp +decide [ *, linearRowPoly, MvPolynomial.coeff_sum ]

/-! ## Solution count for linear forms -/

/-
**Core row-functional theorem**: For a nonzero coefficient vector w over ZMod q,
    the number of solutions to ∑ⱼ wⱼrⱼ = 0 is at most q^(p-1).

    This is the degree-1 specialization of the Schwartz–Zippel lemma:
    a nonzero polynomial of degree d over a finite field F has at most
    d · |F|^(n-1) zeros, and here d = 1.
-/
theorem card_solutions_linear_form_le {p : ℕ}
    (w : Fin p → ZMod q) (hw : w ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // ∑ j, w j * r j = 0} ≤ q ^ (p - 1) := by
      nontriviality;
      -- By the rank-nullity theorem, since w ≠ 0, the linear map f : (Fin p → ZMod q) →ₗ[ZMod q] ZMod q defined by f r = ∑ j, w j * r j is surjective.
      have h_surjective : Function.Surjective fun r : (Fin p → ZMod q) => ∑ j, w j * r j := by
        intro y
        obtain ⟨j₀, hj₀⟩ : ∃ j₀, w j₀ ≠ 0 := by
          exact Function.ne_iff.mp hw
        use fun j => if j = j₀ then y / w j₀ else 0
        simp
        rw [ mul_div_cancel₀ _ hj₀ ];
      -- By the rank-nullity theorem, the dimension of the kernel of $f$ is $p - 1$.
      have h_rank_nullity : Fintype.card {r : (Fin p → ZMod q) | ∑ j, w j * r j = 0} * Fintype.card (ZMod q) = Fintype.card (Fin p → ZMod q) := by
        nontriviality;
        have h_rank_nullity : Fintype.card {r : (Fin p → ZMod q) | ∑ j, w j * r j = 0} * Fintype.card (ZMod q) = Fintype.card (Fin p → ZMod q) := by
          have h_surjective : Function.Surjective (fun r : (Fin p → ZMod q) => ∑ j, w j * r j) := h_surjective
          have h_kernel : ∀ y : ZMod q, Fintype.card {r : (Fin p → ZMod q) | ∑ j, w j * r j = y} = Fintype.card {r : (Fin p → ZMod q) | ∑ j, w j * r j = 0} := by
            intro y
            obtain ⟨r₀, hr₀⟩ : ∃ r₀ : (Fin p → ZMod q), ∑ j, w j * r₀ j = y := h_surjective y;
            refine' Fintype.card_congr _;
            refine' ⟨ fun x => ⟨ x.val - r₀, _ ⟩, fun x => ⟨ x.val + r₀, _ ⟩, fun x => _, fun x => _ ⟩ <;> simp_all +decide [ mul_sub, sub_eq_iff_eq_add ];
            · exact x.2;
            · simp_all +decide [ mul_add, Finset.sum_add_distrib ];
              exact x.2
          have h_card : ∑ y : ZMod q, Fintype.card {r : (Fin p → ZMod q) | ∑ j, w j * r j = y} = Fintype.card (Fin p → ZMod q) := by
            simp +decide only [Fintype.card_ofFinset, card_eq_sum_ones];
            rw [ ← Finset.sum_biUnion ];
            · rw [ show ( univ.biUnion fun x => filter ( Membership.mem { r : Fin p → ZMod q | ∑ j, w j * r j = x } ) univ ) = univ from Finset.eq_univ_of_forall fun x => by obtain ⟨ y, hy ⟩ := h_surjective ( ∑ j, w j * x j ) ; aesop ] ; simp +decide;
            · exact fun x _ y _ hxy => Finset.disjoint_left.mpr fun z => by aesop;
          simp_all +decide [ mul_comm ];
        convert h_rank_nullity using 1;
      rcases p with ( _ | p ) <;> simp_all +decide [ pow_succ' ];
      nlinarith [ hq.1.two_le ]

/-! ## The Freivalds theorem via Schwartz–Zippel -/

section omit_hq
omit hq in
/-- A nonzero matrix has at least one nonzero row. -/
theorem exists_nonzero_row' {m p : ℕ}
    {M : Matrix (Fin m) (Fin p) (ZMod q)} (hM : M ≠ 0) :
    ∃ i, M i ≠ 0 := Function.ne_iff.mp hM

omit hq in
/-- If M.mulVec r = 0, then the dot product of any row with r is zero. -/
theorem mulVec_zero_row {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q)) (r : Fin p → ZMod q)
    (hr : M.mulVec r = 0) (i : Fin m) :
    ∑ j, M i j * r j = 0 := by
  have := congr_fun hr i
  simpa [mulVec, dotProduct] using this

end omit_hq

/-- **Freivalds' theorem as Schwartz–Zippel**: For a nonzero matrix M over ZMod q,
    the number of vectors r in the kernel of mulVec is at most q^(p-1).

    This recasts Freivalds' one-sided error bound as the degree-1 case of the
    Schwartz–Zippel lemma: the kernel of M is contained in the zero set of
    the degree-1 polynomial defined by any nonzero row of M. -/
theorem freivalds_from_schwartz_zippel
    {m p : ℕ}
    (M : Matrix (Fin m) (Fin p) (ZMod q))
    (hM : M ≠ 0) :
    Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0} ≤ q ^ (p - 1) := by
  obtain ⟨i, hi⟩ := exists_nonzero_row' hM
  calc Fintype.card {r : Fin p → ZMod q // M.mulVec r = 0}
      ≤ Fintype.card {r : Fin p → ZMod q // ∑ j, M i j * r j = 0} := by
        apply Fintype.card_le_of_injective
          (fun ⟨r, hr⟩ => ⟨r, mulVec_zero_row M r hr i⟩)
        intro ⟨a, _⟩ ⟨b, _⟩ h
        exact Subtype.ext (Subtype.mk.inj h)
    _ ≤ q ^ (p - 1) := card_solutions_linear_form_le (M i) hi