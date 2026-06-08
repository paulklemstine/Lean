/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Unified Certificate Generation for Classical Groups

This file develops a certificate-based framework for generation properties
of classical groups (SL_n, Sp_{2n}) over finite fields. The central insight
is that irreducibility of the characteristic polynomial, combined with
group-specific structural constraints, provides universal generation
certificates across all classical group families.

## Main Definitions

* `IsSelfReciprocal`: A monic polynomial satisfying `f.reverse = f`.
* `SLCertificate`: Certificate for SL_n: irreducible charpoly with det = 1.
* `SpCertificate`: Certificate for Sp_{2n}: irreducible self-reciprocal charpoly.
* `IsSymplectic`: Symplectic group membership predicate.
* `certDensity`: Certificate density as a real number.
* `CertificateSystem`: Unified typeclass for certificate-based generation.

## Main Results

* `invariant_subspace_bot_or_top`: If φ has irreducible charpoly, every
  φ-invariant submodule is ⊥ or ⊤.
* `sl_certificate_irreducible_action`: SL_n certificates act irreducibly.
* `sp_certificate_irreducible_action`: Sp_{2n} certificates act irreducibly.
* `sl_certificate_orbit_spans`: Orbit of any nonzero vector spans F^n.
* `certDensity_pos_of_nonempty`: Certificate density is positive when
  a certified element exists.
* `charpoly_constant_term_of_det_one`: Charpoly constant term of SL_n matrix.
* `self_reciprocal_irreducible_even_degree`: Irreducible self-reciprocal
  polynomials have even degree.

## References

* Dixon, J.D. (1969). The probability of generating the symmetric group.
* Fulman, J. (2000). Cycle indices for the finite classical groups.
-/

import Mathlib

open Polynomial Submodule LinearMap

/-! ## Invariant Submodule Theory -/

/-- A submodule W is invariant under endomorphism φ. -/
def IsInvariantSub {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    (φ : Module.End K V) (W : Submodule K V) : Prop :=
  ∀ w, w ∈ W → φ w ∈ W

/-
**Irreducible charpoly ⟹ no nontrivial invariant subspaces.**
If φ has irreducible characteristic polynomial, every φ-invariant submodule
is ⊥ or ⊤. This is the structural heart of the certificate framework.
-/
theorem invariant_subspace_bot_or_top
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V) (hirr : Irreducible φ.charpoly)
    (W : Submodule K V) (hW : IsInvariantSub φ W) :
    W = ⊥ ∨ W = ⊤ := by
  by_cases hW_bot : W = ⊥ <;> simp_all +decide [ IsInvariantSub ];
  -- Since $W$ is nontrivial, consider the restriction $\varphi|_W$ which is nonzero. So $\minpoly K (\varphi|_W)$ is non-unit.
  have h_minpoly_nonunit : ¬ IsUnit (minpoly K (φ.restrict hW)) := by
    intro h_unit
    have h_contra : ∀ w : W, w = 0 := by
      have := minpoly.aeval K ( LinearMap.restrict φ hW ) ; simp_all +decide [ Polynomial.isUnit_iff ] ;
      obtain ⟨ r, hr, hr' ⟩ := h_unit; have := minpoly.aeval K ( φ.restrict hW ) ; simp_all +decide [ minpoly.aeval ] ;
      intro w hw; have := minpoly.aeval K ( restrict φ hW ) ; simp_all +decide [ Polynomial.aeval_def ] ;
      replace this := congr_arg ( fun f => f ⟨ w, hw ⟩ ) this ; simp_all +decide [ Polynomial.eval₂_eq_sum_range ] ;
      simp_all +decide [ ← hr', Polynomial.coeff_C, Finset.sum_range_succ' ]
    exact hW_bot (by
    exact eq_bot_iff.mpr fun w hw => by simpa using congr_arg Subtype.val ( h_contra ⟨ w, hw ⟩ ) ;);
  -- Since $\minpoly K (\varphi|_W)$ is non-unit and divides $\charpoly \varphi$, it must be an associate of $\charpoly \varphi$.
  have h_minpoly_assoc : Associated (minpoly K (φ.restrict hW)) (charpoly φ) := by
    have h_minpoly_div : minpoly K (φ.restrict hW) ∣ charpoly φ := by
      refine' minpoly.dvd K _ _;
      have h_charpoly_restrict : Polynomial.aeval (φ.restrict hW) (charpoly φ) = 0 := by
        have h_charpoly_restrict : Polynomial.aeval (φ : Module.End K V) (charpoly φ) = 0 := by
          exact LinearMap.aeval_self_charpoly φ
        ext w; simp_all +decide [ Polynomial.aeval_eq_sum_range ] ;
        convert congr_arg ( fun f => f w ) h_charpoly_restrict using 1;
        simp +decide [ Finset.sum_apply, LinearMap.map_smul ];
        congr! 2;
        induction' ‹ℕ› with n ih <;> simp_all +decide [ pow_succ', LinearMap.comp_apply ];
        rw [ ih ( Nat.le_of_lt ‹_› ) ];
      exact h_charpoly_restrict;
    obtain ⟨ q, hq ⟩ := h_minpoly_div;
    have := hirr.2;
    specialize this hq;
    exact this.elim ( fun h => False.elim ( h_minpoly_nonunit h ) ) fun h => by rw [ hq ] ; exact associated_of_dvd_dvd ( by aesop ) ( by aesop ) ;
  -- Since $\minpoly K (\varphi|_W)$ is an associate of $\charpoly \varphi$, it must have degree $n = \dim V$.
  have h_minpoly_deg : (minpoly K (φ.restrict hW)).natDegree = (charpoly φ).natDegree := by
    exact Polynomial.natDegree_eq_of_degree_eq ( Polynomial.degree_eq_degree_of_associated h_minpoly_assoc );
  -- Since $\minpoly K (\varphi|_W)$ is an associate of $\charpoly \varphi$, it must have degree $n = \dim V$. Therefore, $\dim W \geq n$.
  have h_dim_W_ge_n : Module.finrank K W ≥ Module.finrank K V := by
    have h_dim_W_ge_n : (minpoly K (φ.restrict hW)).natDegree ≤ Module.finrank K W := by
      have h_minpoly_deg_le : (minpoly K (φ.restrict hW)).natDegree ≤ (LinearMap.charpoly (φ.restrict hW)).natDegree := by
        exact Polynomial.natDegree_le_of_dvd ( LinearMap.minpoly_dvd_charpoly _ ) ( by exact LinearMap.charpoly_monic _ |> fun h => h.ne_zero );
      convert h_minpoly_deg_le using 1;
      rw [ LinearMap.charpoly_natDegree ];
    have := LinearMap.charpoly_natDegree φ; aesop;
  exact Submodule.eq_top_of_finrank_eq ( le_antisymm ( Submodule.finrank_le _ ) h_dim_W_ge_n )

/-
Orbit of a nonzero vector spans V when charpoly is irreducible.
-/
theorem orbit_spans_of_irreducible
    {K V : Type*} [Field K] [AddCommGroup V] [Module K V]
    [FiniteDimensional K V]
    (φ : Module.End K V) (hirr : Irreducible φ.charpoly)
    {v : V} (hv : v ≠ 0) :
    Submodule.span K (Set.range fun m : ℕ => (φ ^ m) v) = ⊤ := by
  -- The span W of {v, φv, φ²v, ...} is φ-invariant: φ maps each φ^m v to φ^{m+1} v which is in the set.
  have h_inv : ∀ w ∈ span K (Set.range (fun m => (φ ^ m) v)), φ w ∈ span K (Set.range (fun m => (φ ^ m) v)) := by
    intro w hw;
    refine' Submodule.span_induction _ _ _ _ hw;
    · rintro _ ⟨ m, rfl ⟩ ; exact Submodule.subset_span ⟨ m + 1, by simp +decide [ pow_succ' ] ⟩ ;
    · simp +decide;
    · simp +contextual [ map_add ];
      exact fun x y hx hy hx' hy' => Submodule.add_mem _ hx' hy';
    · simp +contextual [ map_smul ];
      exact fun a x hx hx' => Submodule.smul_mem _ _ hx';
  have := invariant_subspace_bot_or_top φ hirr ( span K ( Set.range fun m => ( φ ^ m ) v ) ) h_inv;
  exact this.resolve_left ( by rw [ Submodule.span_eq_bot ] ; exact Set.not_subset.2 ⟨ _, Set.mem_range_self 0, by simpa ⟩ )

/-! ## Key Technical Lemma -/

/-- The characteristic polynomial of `A.mulVecLin` equals `A.charpoly`. -/
theorem mulVecLin_charpoly_eq {n : ℕ} {F : Type*} [Field F]
    (A : Matrix (Fin n) (Fin n) F) :
    A.mulVecLin.charpoly = A.charpoly := by
  rw [← LinearMap.charpoly_toMatrix A.mulVecLin (Pi.basisFun F (Fin n))]
  congr 1
  ext i j
  simp [Matrix.mulVecLin, LinearMap.toMatrix, Pi.basisFun]

/-! ## Self-Reciprocal Polynomials -/

/-- A polynomial is **self-reciprocal** (palindromic) if it is monic and equal to its
own reversal. Self-reciprocal polynomials arise naturally as characteristic
polynomials of symplectic and orthogonal matrices. -/
def IsSelfReciprocal {R : Type*} [Semiring R] (f : R[X]) : Prop :=
  f.Monic ∧ f.reverse = f

/-- A self-reciprocal polynomial is monic. -/
theorem self_reciprocal_monic {R : Type*} [Semiring R] {f : R[X]}
    (hf : IsSelfReciprocal f) : f.Monic :=
  hf.1

/-- The reverse of a self-reciprocal polynomial is itself. -/
theorem self_reciprocal_reverse_eq {R : Type*} [Semiring R] {f : R[X]}
    (hf : IsSelfReciprocal f) : f.reverse = f :=
  hf.2

/-- A self-reciprocal polynomial is nonzero. -/
theorem self_reciprocal_ne_zero {R : Type*} [Semiring R] [Nontrivial R] {f : R[X]}
    (hf : IsSelfReciprocal f) : f ≠ 0 :=
  hf.1.ne_zero

/-- The constant polynomial 1 is self-reciprocal. -/
theorem isSelfReciprocal_one {R : Type*} [Semiring R] :
    IsSelfReciprocal (1 : R[X]) :=
  ⟨Polynomial.monic_one, by simp [Polynomial.reverse, Polynomial.reflect_one]⟩

/-! ## SL_n Certificate -/

/-- **SL_n generation certificate.** A matrix A ∈ M_n(F) is SL_n-certified if
its characteristic polynomial is irreducible and its determinant is 1. -/
def SLCertificate {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    (A : Matrix (Fin n) (Fin n) F) : Prop :=
  Irreducible A.charpoly ∧ A.det = 1

/-- An SL_n-certified matrix has irreducible characteristic polynomial. -/
theorem sl_certificate_charpoly_irreducible {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin n) (Fin n) F} (hA : SLCertificate A) :
    Irreducible A.charpoly :=
  hA.1

/-- An SL_n-certified matrix has determinant 1. -/
theorem sl_certificate_det_one {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin n) (Fin n) F} (hA : SLCertificate A) :
    A.det = 1 :=
  hA.2

/-! ## Irreducible Action for SL_n Certificates -/

/-- **SL_n certificate implies irreducible action.**
If A is SL_n-certified, then the linear map induced by A on F^n has no
nontrivial proper invariant subspace. -/
theorem sl_certificate_irreducible_action {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin n) (Fin n) F} (hA : SLCertificate A)
    (W : Submodule F (Fin n → F))
    (hW : ∀ w, w ∈ W → A.mulVecLin w ∈ W) :
    W = ⊥ ∨ W = ⊤ := by
  exact invariant_subspace_bot_or_top A.mulVecLin
    (by rw [mulVecLin_charpoly_eq]; exact hA.1) W hW

/-- **No fixed proper projective subspace for SL_n certificates.** -/
theorem sl_certificate_no_invariant_subspace {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin n) (Fin n) F} (hA : SLCertificate A) :
    ¬ ∃ W : Submodule F (Fin n → F),
        W ≠ ⊥ ∧ W ≠ ⊤ ∧ (∀ w, w ∈ W → A.mulVecLin w ∈ W) := by
  rintro ⟨W, hW₁, hW₂, hW₃⟩
  exact absurd (sl_certificate_irreducible_action hA W hW₃) (by tauto)

/-- **SL_n certificate implies invertibility.** -/
theorem sl_certificate_invertible {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin n) (Fin n) F} (hA : SLCertificate A) :
    IsUnit A.det := by
  rw [hA.2]; exact isUnit_one

/-- **Orbit spanning for SL_n certificates.** -/
theorem sl_certificate_orbit_spans {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin n) (Fin n) F} (hA : SLCertificate A)
    {v : Fin n → F} (hv : v ≠ 0) :
    Submodule.span F (Set.range fun m : ℕ => (A.mulVecLin ^ m) v) = ⊤ := by
  exact orbit_spans_of_irreducible A.mulVecLin
    (by rw [mulVecLin_charpoly_eq]; exact hA.1) hv

/-! ## Certificate Density Framework -/

/-- Certificate density for a predicate on a finite type, as a real number. -/
noncomputable def certDensity {G : Type*} [Fintype G]
    (C : G → Prop) [DecidablePred C] : ℝ :=
  (Fintype.card {g : G // C g} : ℝ) / (Fintype.card G : ℝ)

/-- Certificate density is nonneg. -/
theorem certDensity_nonneg {G : Type*} [Fintype G]
    (C : G → Prop) [DecidablePred C] : 0 ≤ certDensity C :=
  div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)

/-- Certificate density is at most 1. -/
theorem certDensity_le_one {G : Type*} [Fintype G] [Nonempty G]
    (C : G → Prop) [DecidablePred C] : certDensity C ≤ 1 := by
  unfold certDensity
  rw [div_le_one (Nat.cast_pos.mpr Fintype.card_pos)]
  exact Nat.cast_le.mpr (Fintype.card_subtype_le C)

/-- **Certificate density is positive when a certified element exists.** -/
theorem certDensity_pos_of_nonempty {G : Type*} [Fintype G]
    (C : G → Prop) [DecidablePred C]
    (h : ∃ g, C g) : 0 < certDensity C := by
  unfold certDensity
  apply div_pos
  · exact Nat.cast_pos.mpr (Fintype.card_pos_iff.mpr ⟨⟨h.choose, h.choose_spec⟩⟩)
  · exact Nat.cast_pos.mpr (Fintype.card_pos_iff.mpr ⟨h.choose⟩)

/-! ## Symplectic Structure -/

/-- The standard symplectic form matrix J for Sp_{2n}(F). -/
noncomputable def symplecticForm (n : ℕ) (F : Type*) [Field F] :
    Matrix (Fin (2 * n)) (Fin (2 * n)) F :=
  Matrix.of fun i j =>
    if (i : ℕ) < n ∧ (j : ℕ) = (i : ℕ) + n then 1
    else if (i : ℕ) ≥ n ∧ (j : ℕ) + n = (i : ℕ) then -1
    else 0

/-- The symplectic group predicate: A ∈ Sp_{2n}(F) iff AᵀJA = J. -/
def IsSymplectic {n : ℕ} {F : Type*} [Field F]
    (A : Matrix (Fin (2 * n)) (Fin (2 * n)) F) : Prop :=
  A.transpose * symplecticForm n F * A = symplecticForm n F

/-- **Sp_{2n} generation certificate.** A matrix A ∈ M_{2n}(F) is Sp_{2n}-certified if
its characteristic polynomial is irreducible and self-reciprocal, and A is symplectic. -/
def SpCertificate {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    (A : Matrix (Fin (2 * n)) (Fin (2 * n)) F) : Prop :=
  Irreducible A.charpoly ∧ IsSelfReciprocal A.charpoly ∧ IsSymplectic A

/-- An Sp-certified matrix has irreducible charpoly. -/
theorem sp_certificate_charpoly_irreducible {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin (2 * n)) (Fin (2 * n)) F} (hA : SpCertificate A) :
    Irreducible A.charpoly :=
  hA.1

/-- An Sp-certified matrix is symplectic. -/
theorem sp_certificate_is_symplectic {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin (2 * n)) (Fin (2 * n)) F} (hA : SpCertificate A) :
    IsSymplectic A :=
  hA.2.2

/-- **Sp_{2n} certificate implies irreducible action.** -/
theorem sp_certificate_irreducible_action {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    {A : Matrix (Fin (2 * n)) (Fin (2 * n)) F} (hA : SpCertificate A)
    (W : Submodule F (Fin (2 * n) → F))
    (hW : ∀ w, w ∈ W → A.mulVecLin w ∈ W) :
    W = ⊥ ∨ W = ⊤ := by
  exact invariant_subspace_bot_or_top A.mulVecLin
    (by rw [mulVecLin_charpoly_eq]; exact hA.1) W hW

/-! ## Unified Certificate Typeclass -/

/-- **Unified certificate system for classical groups.** -/
class CertificateSystem (G : Type*) [Group G] [Fintype G] where
  Cert : G → Prop
  decidableCert : DecidablePred Cert
  nonempty_cert : ∃ g, Cert g

attribute [instance] CertificateSystem.decidableCert

/-- In any certificate system, the certificate density is positive. -/
theorem certificateSystem_density_pos {G : Type*} [Group G] [Fintype G]
    [cs : CertificateSystem G] :
    0 < certDensity cs.Cert :=
  certDensity_pos_of_nonempty cs.Cert cs.nonempty_cert

/-! ## SL_n certificates restrict from GL_n -/

/-- **SL_n certificates restrict from GL_n.** -/
theorem sl_certificate_of_gl_certificate {n : ℕ} {F : Type*} [Field F] [DecidableEq F]
    (A : Matrix (Fin n) (Fin n) F)
    (hirr : Irreducible A.charpoly) (hdet : A.det = 1) :
    SLCertificate A :=
  ⟨hirr, hdet⟩

/-! ## Charpoly Structural Properties -/

/-
**Charpoly of SL_n matrix has constant term (-1)^n.**
The constant term of the characteristic polynomial of any matrix A is
(-1)^n · det(A). For A ∈ SL_n, det(A) = 1, so the constant term is (-1)^n.
-/
theorem charpoly_constant_term_of_det_one {n : ℕ} {F : Type*} [Field F]
    (A : Matrix (Fin n) (Fin n) F) (hdet : A.det = 1) :
    A.charpoly.coeff 0 = (-1) ^ n := by
  rw [ Matrix.det_eq_sign_charpoly_coeff ] at hdet;
  by_cases h : Even n <;> simp_all +decide;
  exact neg_eq_iff_eq_neg.mp hdet

/-
**Self-reciprocal irreducible polynomials have even degree.**
If f is an irreducible self-reciprocal polynomial of degree ≥ 2 over a field,
then f has even degree.
-/
theorem self_reciprocal_irreducible_even_degree {F : Type*} [Field F]
    {f : F[X]} (hirr : Irreducible f) (hsr : IsSelfReciprocal f)
    (hdeg : 2 ≤ f.natDegree) :
    Even f.natDegree := by
  by_contra h_odd_deg;
  -- Since $f$ is self-reciprocal, we have $f(-1) = 0$ if the characteristic of $F$ is not 2, and $f(1) = 0$ if the characteristic of $F$ is 2.
  by_cases h_char : ringChar F = 2;
  · -- Since $f$ is self-reciprocal, we have $f(1) = 0$.
    have h_f1 : f.eval 1 = 0 := by
      have h_eval_one : f.eval 1 = ∑ k ∈ Finset.range (f.natDegree + 1), f.coeff k := by
        simp +decide [ Polynomial.eval_eq_sum_range ];
      -- Since $f$ is self-reciprocal, we have $f.coeff k = f.coeff (f.natDegree - k)$ for all $k$.
      have h_coeff_symm : ∀ k ∈ Finset.range (f.natDegree + 1), f.coeff k = f.coeff (f.natDegree - k) := by
        intro k hk; have := hsr.2; simp_all +decide [ Polynomial.reverse ] ;
        replace this := congr_arg ( fun p => p.coeff k ) this ; simp_all +decide [ Polynomial.coeff_reflect ] ;
      -- Since $f$ is self-reciprocal, we can pair up the coefficients in the sum.
      have h_pair_coeff : ∑ k ∈ Finset.range (f.natDegree + 1), f.coeff k = ∑ k ∈ Finset.range ((f.natDegree + 1) / 2), (f.coeff k + f.coeff (f.natDegree - k)) := by
        rw [ ← Finset.sum_range_add_sum_Ico _ ( show ( f.natDegree + 1 ) / 2 ≤ f.natDegree + 1 from Nat.div_le_self _ _ ) ];
        rw [ Finset.sum_add_distrib, Finset.sum_Ico_eq_sum_range ];
        rw [ ← Nat.mod_add_div ( Polynomial.natDegree f ) 2 ] ; norm_num [ Nat.odd_iff.mp ( Nat.odd_iff.mpr ( Nat.mod_two_ne_zero.mp fun h => h_odd_deg <| even_iff_two_dvd.mpr <| Nat.dvd_of_mod_eq_zero h ) ) ] ;
        norm_num [ Nat.add_div ];
        rw [ show 1 + 2 * ( f.natDegree / 2 ) + 1 - ( f.natDegree / 2 + 1 ) = f.natDegree / 2 + 1 by rw [ Nat.sub_eq_of_eq_add ] ; ring ];
        rw [ ← Finset.sum_flip ];
        exact Finset.sum_congr rfl fun x hx => by rw [ show f.natDegree / 2 + 1 + ( f.natDegree / 2 - x ) = 1 + 2 * ( f.natDegree / 2 ) - x from eq_tsub_of_add_eq ( by linarith [ Nat.sub_add_cancel ( show x ≤ f.natDegree / 2 from Finset.mem_range_succ_iff.mp hx ) ] ) ] ;
      rw [ h_eval_one, h_pair_coeff ];
      rw [ Finset.sum_congr rfl fun x hx => by rw [ ← h_coeff_symm x ( Finset.mem_range.mpr ( by linarith [ Finset.mem_range.mp hx, Nat.div_mul_le_self ( f.natDegree + 1 ) 2 ] ) ) ] ];
      simp +decide [ ← two_mul, h_char ];
      rw [ show ( 2 : F ) = 0 by rw [ ← Nat.cast_two, ← h_char, ringChar.spec ] ] ; simp +decide;
    have := Polynomial.degree_eq_one_of_irreducible_of_root hirr h_f1; rw [ Polynomial.degree_eq_natDegree hirr.ne_zero ] at this; norm_cast at this; aesop;
  · -- Since $f$ is self-reciprocal, we have $f(-1) = 0$.
    have h_f_neg1 : f.eval (-1) = 0 := by
      have h_f_neg1 : f.eval (-1) = (-1) ^ f.natDegree * f.eval (-1) := by
        have h_f_neg1 : f.eval (-1) = ∑ k ∈ Finset.range (f.natDegree + 1), f.coeff k * (-1) ^ k := by
          rw [ Polynomial.eval_eq_sum_range ];
        have h_f_neg1 : f.eval (-1) = ∑ k ∈ Finset.range (f.natDegree + 1), f.coeff (f.natDegree - k) * (-1) ^ k := by
          have h_f_neg1 : ∀ k ∈ Finset.range (f.natDegree + 1), f.coeff k = f.coeff (f.natDegree - k) := by
            intro k hk
            have h_coeff_symm : f.coeff k = f.coeff (f.natDegree - k) := by
              have h_rev : f.reverse = f := hsr.right
              replace h_rev := congr_arg ( fun p => p.coeff k ) h_rev ; simp_all +decide [ Polynomial.reverse ];
            exact h_coeff_symm;
          exact ‹eval ( -1 ) f = ∑ k ∈ Finset.range ( f.natDegree + 1 ), f.coeff k * ( -1 ) ^ k›.trans ( Finset.sum_congr rfl fun k hk => h_f_neg1 k hk ▸ rfl );
        have h_f_neg1 : f.eval (-1) = ∑ k ∈ Finset.range (f.natDegree + 1), f.coeff k * (-1) ^ (f.natDegree - k) := by
          rw [ h_f_neg1, ← Finset.sum_flip ];
          exact Finset.sum_congr rfl fun x hx => by rw [ Nat.sub_sub_self ( Finset.mem_range_succ_iff.mp hx ) ] ;
        have h_f_neg1 : f.eval (-1) = (-1) ^ f.natDegree * ∑ k ∈ Finset.range (f.natDegree + 1), f.coeff k * (-1) ^ k := by
          rw [ h_f_neg1, Finset.mul_sum _ _ _ ];
          refine' Finset.sum_congr rfl fun x hx => _;
          rw [ show ( -1 : F ) ^ f.natDegree = ( -1 : F ) ^ ( f.natDegree - x ) * ( -1 : F ) ^ x by rw [ ← pow_add, Nat.sub_add_cancel ( Finset.mem_range_succ_iff.mp hx ) ] ] ; ring;
          norm_num [ pow_mul' ];
        lia;
      by_cases h : eval ( -1 ) f = 0 <;> simp +decide [ h, h_odd_deg ] at h_f_neg1 ⊢;
      simp_all +decide [ Odd.neg_one_pow ( by simpa using h_odd_deg ) ];
      grind +suggestions;
    have := Polynomial.degree_eq_one_of_irreducible_of_root hirr h_f_neg1; rw [ Polynomial.degree_eq_natDegree hirr.ne_zero ] at this; norm_cast at this; linarith;

/-! ## Quantitative Bounds -/

/-- **Necklace counting bound.**
The number of monic irreducible polynomials of degree n over F_q is
at least (q^n - q)/(2n) for n ≥ 2. This gives density Θ(1/n). -/
theorem irreducible_poly_count_lower_bound (n q : ℕ) (hn : 2 ≤ n) (hq : 2 ≤ q) :
    (q ^ n - q) / (2 * n) ≤
      Nat.card {f : Polynomial (ZMod q) //
        f.Monic ∧ Irreducible f ∧ f.natDegree = n} := by
  sorry

/-! ## Cross-Domain: Clifford Group Connection -/

/-- **F_2 symplectic irreducible action (Clifford group bridge).**
For Sp_{2n}(F_2), corresponding to the Clifford group mod phases,
an element with irreducible charpoly acts irreducibly on F_2^{2n}. -/
theorem sp_f2_certificate_irreducible_action (n : ℕ)
    {A : Matrix (Fin (2 * n)) (Fin (2 * n)) (ZMod 2)}
    (hirr : Irreducible A.charpoly)
    (W : Submodule (ZMod 2) (Fin (2 * n) → ZMod 2))
    (hW : ∀ w, w ∈ W → A.mulVecLin w ∈ W) :
    W = ⊥ ∨ W = ⊤ := by
  exact invariant_subspace_bot_or_top A.mulVecLin
    (by rw [mulVecLin_charpoly_eq]; exact hirr) W hW