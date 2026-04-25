/-! # CatalogBuild.Speculative.Other.KaroubiIdempotent

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 13
-/

import Mathlib

noncomputable section

/-- Two idempotents are orthogonal if ef = fe = 0. -/
def AreOrthogonalIdempotents' {R : Type*} [Ring R] (e f : R) : Prop :=
  IsIdempotentElem e ∧ IsIdempotentElem f ∧ e * f = 0 ∧ f * e = 0


/-- e and 1-e are orthogonal idempotents. -/
theorem orthogonal_complement' {R : Type*} [Ring R] (e : R) (he : IsIdempotentElem e) :
    AreOrthogonalIdempotents' e (1 - e) := by
  refine ⟨he, he.one_sub, ?_, ?_⟩
  · rw [mul_sub, mul_one, he.eq, sub_self]
  · rw [sub_mul, one_mul, he.eq, sub_self]


/-- A complete set of orthogonal idempotents sums to 1. -/
def IsCompleteIdempotentSystem' {R : Type*} [Ring R] {n : ℕ}
    (idemps : Fin n → R) : Prop :=
  (∀ i, IsIdempotentElem (idemps i)) ∧
  (∀ i j, i ≠ j → idemps i * idemps j = 0) ∧
  ∑ i, idemps i = 1


/-- The trivial complete system: {1}. -/
theorem trivial_complete_system' {R : Type*} [Ring R] :
    IsCompleteIdempotentSystem' (fun (_ : Fin 1) => (1 : R)) := by
  refine ⟨fun _ => by simp [IsIdempotentElem], fun i j hij => ?_, ?_⟩
  · exact absurd (Fin.ext (by omega)) hij
  · simp


/-- A Hecke algebra element (simplified diagonal model). -/
structure HeckeElement' (n : ℕ) where
  coeffs : Fin n → ℝ


/-- [Section: # CatalogBuild.Speculative.Other.KaroubiIdempotent
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 13] -/
instance {n : ℕ} : Mul (HeckeElement' n) :=
  ⟨fun a b => ⟨fun i => a.coeffs i * b.coeffs i⟩⟩


/-- A Hecke algebra idempotent. -/
def isHeckeIdempotent' {n : ℕ} (e : HeckeElement' n) : Prop :=
  e * e = e


/-- The identity Hecke element is idempotent. -/
theorem heckeIdentity_idempotent' (n : ℕ) :
    isHeckeIdempotent' (⟨fun _ => 1⟩ : HeckeElement' n) := by
  show (⟨fun i => 1 * 1⟩ : HeckeElement' n) = ⟨fun _ => 1⟩
  simp


/-- When δ = 2, TL generators are (rescaled) idempotents: (e/2)² = e/2. -/
theorem tl_delta2_idempotent' (e_val : ℝ) (h : e_val * e_val = 2 * e_val) :
    IsIdempotentElem (e_val / 2) := by
  simp [IsIdempotentElem]
  field_simp
  linarith


/-- Jones-Wenzl idempotent existence bound. -/
theorem jones_wenzl_bound' (n : ℕ) (hn : 0 < n) :
    Real.cos (Real.pi / (n + 1)) > -1 := by
  nlinarith [Real.sin_sq_add_cos_sq (Real.pi / (n + 1)),
    Real.sin_pos_of_pos_of_lt_pi (by positivity)
      (by rw [div_lt_iff₀ (by positivity)]
          nlinarith [Real.pi_pos, show (n : ℝ) ≥ 1 by norm_cast]
        : Real.pi / (n + 1) < Real.pi)]


/-- Trace is additive for any matrices. -/
theorem trace_additive_matrices {n : ℕ} (E F : Matrix (Fin n) (Fin n) ℝ) :
    (E + F).trace = E.trace + F.trace :=
  Matrix.trace_add E F


/-- [Section: # CatalogBuild.Speculative.Other.KaroubiIdempotent
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 13] -/
theorem idempotent_trace_nonneg {n : ℕ} (E : Matrix (Fin n) (Fin n) ℝ)
    (hE : E * E = E) :
    0 ≤ E.trace := by
  -- Since $E$ is idempotent, its eigenvalues are either $0$ or $1$. Therefore, the trace of $E$ is the sum of its eigenvalues, which is non-negative.
  have h_eigenvalues : ∀ (μ : ℂ), μ ∈ Polynomial.roots (Matrix.charpoly (E.map (algebraMap ℝ ℂ))) → μ = 0 ∨ μ = 1 := by
    intro μ hμ
    have h_mu_eq : μ ^ 2 = μ := by
      -- Since μ is an eigenvalue of E, there exists a nonzero vector v such that E * v = μ * v.
      obtain ⟨v, hv⟩ : ∃ v : Fin n → ℂ, v ≠ 0 ∧ (E.map (algebraMap ℝ ℂ)).mulVec v = μ • v := by
        have := Matrix.exists_mulVec_eq_zero_iff.mpr ( show Matrix.det ( E.map ( algebraMap ℝ ℂ ) - Matrix.diagonal ( fun _ => μ ) ) = 0 from ?_ );
        · simp_all +decide [ sub_eq_iff_eq_add, Matrix.sub_mulVec ];
        · rw [ Matrix.det_eq_sign_charpoly_coeff ];
          simp_all +decide [ Matrix.charpoly, Matrix.det_apply' ];
          convert hμ.2 using 1;
          simp +decide [ Polynomial.eval_finset_sum, Polynomial.eval_mul, Polynomial.eval_prod, Polynomial.eval_sub, Polynomial.eval_X, Polynomial.eval_one, Polynomial.coeff_zero_eq_eval_zero ];
          exact Finset.sum_congr rfl fun _ _ => by congr; ext; by_cases h : ‹Equiv.Perm ( Fin n ) › ‹_› = ‹_› <;> simp +decide [ h ] ;
      -- Applying the idempotence of E, we have E * (E * v) = E * v.
      have h_idempotent : (E.map (algebraMap ℝ ℂ)).mulVec ((E.map (algebraMap ℝ ℂ)).mulVec v) = (E.map (algebraMap ℝ ℂ)).mulVec v := by
        convert congr_arg ( Matrix.mulVec ( E.map ( algebraMap ℝ ℂ ) ) ) hv.2 using 1;
        rw [ ← hv.2, Matrix.mulVec_mulVec ];
        rw [ ← Matrix.map_mul ] ; aesop;
      simp_all +decide [ sq, Matrix.mulVec_smul ];
      exact smul_left_injective _ hv.1 <| by simpa [ mul_assoc, smul_smul ] using h_idempotent;
    exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ h <| by linear_combination' h_mu_eq;
  -- The trace of $E$ is the sum of its eigenvalues, which are either $0$ or $1$.
  have h_trace_sum_eigenvalues : Matrix.trace E = Multiset.sum (Polynomial.roots (Matrix.charpoly (E.map (algebraMap ℝ ℂ)))) := by
    have := Matrix.trace_eq_sum_roots_charpoly ( E.map ( algebraMap ℝ ℂ ) );
    convert this using 1;
    norm_num [ Matrix.trace ];
  have h_trace_nonneg : ∀ (μ : ℂ), μ ∈ Polynomial.roots (Matrix.charpoly (E.map (algebraMap ℝ ℂ))) → 0 ≤ μ.re := by
    intro μ hμ; specialize h_eigenvalues μ hμ; aesop;
  have h_trace_nonneg : 0 ≤ Multiset.sum (Multiset.map Complex.re (Polynomial.roots (Matrix.charpoly (E.map (algebraMap ℝ ℂ))))) := by
    exact Multiset.sum_nonneg ( Multiset.forall_mem_map_iff.mpr h_trace_nonneg );
  convert h_trace_nonneg using 1;
  convert congr_arg Complex.re h_trace_sum_eigenvalues using 1;
  induction ( Matrix.charpoly ( E.map ( algebraMap ℝ ℂ ) ) |> Polynomial.roots ) using Multiset.induction <;> aesop


/-- Quantum observable bound: for a complete system of orthogonal projectors,
each projector has non-negative trace. -/
theorem quantum_observable_bound (n : ℕ) (projectors : Fin n → Matrix (Fin n) (Fin n) ℝ)
    (h_idem : ∀ i, projectors i * projectors i = projectors i)
    (h_ortho : ∀ i j, i ≠ j → projectors i * projectors j = 0)
    (h_complete : ∑ i, projectors i = 1) :
    ∀ i, (projectors i).trace ≥ 0 := by
  intro i
  exact idempotent_trace_nonneg _ (h_idem i)


end
