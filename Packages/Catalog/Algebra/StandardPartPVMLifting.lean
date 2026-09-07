/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Algebra.StandardPartPVMFunctional

/-!
# Lifting, classification and the geometry of observed projection-valued measures

Third instalment of the standard-part PVM programme (see `Algebra.StandardPartPVM` for the
descent theorem and `Algebra.StandardPartPVMFunctional` for the functional calculus and
coarse-graining).  Here we settle the *structure of the observation map itself*:

* `StandardPartPVM.isApproxPVM_hyperMat` — **every** real projection-valued measure is observed
  from a hyperreal one (the observation map is surjective onto PVMs);
* `StandardPartPVM.approx_iff_same_observation` — two finite-entry families are observed
  identically exactly when they are infinitesimally close, so the fibres of the observation map
  are precisely the infinitesimal neighbourhoods;
* `StandardPartPVM.exists_approxPVM_not_exact` — the hyperreal theory is strictly richer than the
  real one: an explicit `2 × 2` approximate PVM which is *not* an exact PVM (its channels fail to
  be orthogonal and its total is not the identity), yet is observed as one;
* `StandardPartPVM.iSup_range_eq_top`, `StandardPartPVM.range_inf_range_eq_bot`,
  `StandardPartPVM.iSupIndep_range` — the observed projections carve `ℝⁿ` into subspaces that
  span the whole space and are independent;
* `StandardPartPVM.isInternal_range`, `StandardPartPVM.isInternal_range_stMat` — consequently the
  observation of a non-Archimedean measurement is an **internal direct sum decomposition** of
  `ℝⁿ`, whose summand dimensions add up to `Fintype.card n` by `sum_rank_eq_card`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the descent theorem should be upgradeable to an equivalence of
categories-like statement: finite-entry approximate PVMs modulo infinitesimal equivalence should
correspond bijectively to real PVMs, and the correspondence should be strictly non-trivial (there
must exist approximate PVMs that are not exact).

Experiment (Experimenter): the candidate witness `P 0 = !![1, ε; 0, 0]`, `P 1 = !![0, 0; 0, 1]`
was computed by hand: `P 0 * P 1 = !![0, ε; 0, 0]` (infinitesimal but nonzero), `P 1 * P 0 = 0`,
`P 0 + P 1 = !![1, ε; 0, 1]` (infinitesimally close to `1` but different from it).  Both
non-degeneracy claims are formalized below, so the example genuinely separates the approximate
notion from the exact one.

Analysis (Analyst): surjectivity is proved without any new matrix algebra by feeding the descent
theorem the constant lift `Q ↦ Q.map (↑·)`, and injectivity-up-to-infinitesimals is exactly
`approxEq_iff_stMat_eq`.  The geometric statements need only idempotency and completeness of the
descended family, confirming that the observable content is the subspace decomposition.

Critique (Critic): `exists_approxPVM_not_exact` is the theorem that prevents this whole
development from being a re-packaging of real linear algebra — without it the approximate class
could conceivably coincide with the exact one.
-- !-- Lab Notes -- !--
-/

open Hyperreal Matrix Finset

namespace StandardPartPVM

variable {n ι : Type*}

/-! ## Lifting real matrices to the hyperreals -/

/-- The canonical lift of a real matrix to a hyperreal one. -/
noncomputable def hyperMat (A : Matrix n n ℝ) : Matrix n n ℝ* := A.map (fun r => (r : ℝ*))

@[simp] theorem hyperMat_apply (A : Matrix n n ℝ) (i j : n) :
    hyperMat A i j = ((A i j : ℝ) : ℝ*) := rfl

theorem finiteEntries_hyperMat (A : Matrix n n ℝ) : FiniteEntries (hyperMat A) :=
  fun _ _ => not_infinite_real _

@[simp] theorem stMat_hyperMat (A : Matrix n n ℝ) : stMat (hyperMat A) = A := by
  ext i j
  exact st_id_real _

section Lifting

variable [Fintype n] [DecidableEq n] [Fintype ι]

/-- **Surjectivity of observation.** Every real projection-valued measure is the observation of a
hyperreal approximate projection-valued measure. -/
theorem isApproxPVM_hyperMat {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    IsApproxPVM (fun a => hyperMat (Q a)) := by
  refine (isApproxPVM_iff_isPVM_stMat (fun a => finiteEntries_hyperMat (Q a))).2 ?_
  simpa using h

end Lifting

section Fibres

/-- **The fibres of observation are the infinitesimal neighbourhoods.** Two finite-entry families
of hyperreal matrices are observed identically if and only if they are entrywise infinitesimally
close. -/
theorem approx_iff_same_observation {P P' : ι → Matrix n n ℝ*}
    (hP : ∀ a, FiniteEntries (P a)) (hP' : ∀ a, FiniteEntries (P' a)) :
    (∀ a, P a ≈ₕ P' a) ↔ (fun a => stMat (P a)) = (fun a => stMat (P' a)) := by
  constructor
  · intro h
    funext a
    exact (approxEq_iff_stMat_eq (hP a) (hP' a)).1 (h a)
  · intro h a
    exact (approxEq_iff_stMat_eq (hP a) (hP' a)).2 (congrFun h a)

end Fibres

section Ranks

variable [Fintype n]

/-- Infinitesimally close approximate PVMs have the same observed ranks. -/
theorem rank_stMat_eq_of_approx {P P' : ι → Matrix n n ℝ*} (hP : ∀ a, FiniteEntries (P a))
    (hP' : ∀ a, FiniteEntries (P' a)) (h : ∀ a, P a ≈ₕ P' a) (a : ι) :
    (stMat (P a)).rank = (stMat (P' a)).rank := by
  rw [(approxEq_iff_stMat_eq (hP a) (hP' a)).1 (h a)]

end Ranks

/-! ## The approximate theory is strictly richer -/

section Strict

/-- The two-channel hyperreal family `P 0 = !![1, ε; 0, 0]`, `P 1 = !![0, 0; 0, 1]`. -/
noncomputable def epsChannel : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ* :=
  ![!![1, ε; 0, 0], !![0, 0; 0, 1]]

theorem finiteEntries_epsChannel (a : Fin 2) : FiniteEntries (epsChannel a) := by
  have hε : ¬Infinite (ε : ℝ*) := infinitesimal_epsilon.not_infinite
  have h0 : ¬Infinite (0 : ℝ*) := infinitesimal_zero.not_infinite
  have h1 : ¬Infinite (1 : ℝ*) := by simpa using not_infinite_real 1
  intro i j
  fin_cases a <;> fin_cases i <;> fin_cases j <;> simp [epsChannel, hε, h0, h1]

theorem infinitesimalEntries_epsChannel_mul {a b : Fin 2} (hab : a ≠ b) :
    InfinitesimalEntries (epsChannel a * epsChannel b) := by
  intro i j
  fin_cases a <;> fin_cases b <;> simp_all <;>
    fin_cases i <;> fin_cases j <;>
      simp [epsChannel, Matrix.mul_apply, Fin.sum_univ_succ, infinitesimal_epsilon,
        infinitesimal_zero]

theorem approxTotal_epsChannel : (∑ a, epsChannel a) ≈ₕ 1 := by
  intro i j
  fin_cases i <;> fin_cases j <;>
    simp [epsChannel, Fin.sum_univ_succ, Matrix.sub_apply, infinitesimal_epsilon,
      infinitesimal_zero]

theorem isApproxPVM_epsChannel : IsApproxPVM epsChannel :=
  ⟨finiteEntries_epsChannel, fun _ _ hab => infinitesimalEntries_epsChannel_mul hab,
    approxTotal_epsChannel⟩

theorem epsChannel_zero_mul_one : epsChannel 0 * epsChannel 1 = !![0, ε; 0, 0] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [epsChannel, Matrix.mul_apply, Fin.sum_univ_succ]

theorem sum_epsChannel : ∑ a, epsChannel a = !![1, ε; 0, 1] := by
  ext i j
  fin_cases i <;> fin_cases j <;> simp [epsChannel, Fin.sum_univ_succ]

/-- **The approximate theory is strictly larger than the exact one.** There is a hyperreal
approximate projection-valued measure whose channels are *not* orthogonal and whose total is
*not* the identity, but which is nevertheless observed as a bona fide real projection-valued
measure. -/
theorem exists_approxPVM_not_exact :
    ∃ P : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ*,
      IsApproxPVM P ∧ IsPVM (fun a => stMat (P a)) ∧
        P 0 * P 1 ≠ 0 ∧ (∑ a, P a) ≠ 1 := by
  have hεne : (ε : ℝ*) ≠ 0 := epsilon_pos.ne'
  refine ⟨epsChannel, isApproxPVM_epsChannel, isApproxPVM_epsChannel.isPVM_stMat, ?_, ?_⟩
  · intro hcon
    rw [epsChannel_zero_mul_one] at hcon
    have h01 : (ε : ℝ*) = 0 := by simpa using congrFun (congrFun hcon 0) 1
    exact hεne h01
  · intro hcon
    rw [sum_epsChannel] at hcon
    have h01 : (ε : ℝ*) = 0 := by simpa using congrFun (congrFun hcon 0) 1
    exact hεne h01

end Strict

/-! ## Geometry of the observed decomposition -/

section Geometry

variable [Fintype n] [DecidableEq n] [Fintype ι]

/-- The ranges of the observed projections span the whole space. -/
theorem iSup_range_eq_top {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    ⨆ a, LinearMap.range (Matrix.toLin' (Q a)) = ⊤ := by
  refine eq_top_iff.2 fun v _ => ?_
  have hv : ∑ a, (Q a) *ᵥ v = v := by
    rw [← Matrix.sum_mulVec, h.total, Matrix.one_mulVec]
  rw [← hv]
  refine Submodule.sum_mem _ fun a _ => Submodule.mem_iSup_of_mem a ?_
  exact ⟨v, by simp [Matrix.toLin'_apply]⟩

/-- An idempotent matrix acts as the identity on its own range. -/
theorem mulVec_eq_self_of_mem_range {Q : Matrix n n ℝ} (hQ : Q * Q = Q) {v : n → ℝ}
    (hv : v ∈ LinearMap.range (Matrix.toLin' Q)) : Q *ᵥ v = v := by
  obtain ⟨w, hw⟩ := hv
  have hw' : Q *ᵥ w = v := by simpa [Matrix.toLin'_apply] using hw
  rw [← hw', Matrix.mulVec_mulVec, hQ]

/-- Distinct observed channels have trivially intersecting ranges. -/
theorem range_inf_range_eq_bot {Q : ι → Matrix n n ℝ} (h : IsPVM Q) {a b : ι} (hab : a ≠ b) :
    LinearMap.range (Matrix.toLin' (Q a)) ⊓ LinearMap.range (Matrix.toLin' (Q b)) = ⊥ := by
  refine eq_bot_iff.2 fun v hv => ?_
  obtain ⟨hva, hvb⟩ := hv
  have hfix : (Q a) *ᵥ v = v := mulVec_eq_self_of_mem_range (h.idem a) hva
  have hzero : (Q a) *ᵥ v = 0 := by
    obtain ⟨u, hu⟩ := hvb
    have hu' : (Q b) *ᵥ u = v := by simpa [Matrix.toLin'_apply] using hu
    rw [← hu', Matrix.mulVec_mulVec, h.orth a b hab, Matrix.zero_mulVec]
  rw [Submodule.mem_bot, ← hfix, hzero]

/-- The ranges of the observed channels are independent in the lattice of subspaces. -/
theorem iSupIndep_range {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    iSupIndep fun a => LinearMap.range (Matrix.toLin' (Q a)) := by
  rw [iSupIndep_def]
  intro a
  have hker : (⨆ b, ⨆ _ : b ≠ a, LinearMap.range (Matrix.toLin' (Q b)))
      ≤ LinearMap.ker (Matrix.toLin' (Q a)) := by
    refine iSup_le fun b => iSup_le fun hb => ?_
    rintro _ ⟨w, rfl⟩
    simp only [LinearMap.mem_ker, Matrix.toLin'_apply, Matrix.mulVec_mulVec,
      h.orth a b (Ne.symm hb), Matrix.zero_mulVec]
  rw [disjoint_iff, eq_bot_iff]
  intro v hv
  obtain ⟨hva, hvb⟩ := hv
  have hfix : (Q a) *ᵥ v = v := mulVec_eq_self_of_mem_range (h.idem a) hva
  have hzero : (Q a) *ᵥ v = 0 := by
    have := hker hvb
    simpa [LinearMap.mem_ker, Matrix.toLin'_apply] using this
  rw [Submodule.mem_bot, ← hfix, hzero]

/-- **The observed decomposition is an internal direct sum.** Observing a hyperreal
approximate projection-valued measure decomposes `ℝⁿ` as the internal direct sum of the ranges of
the observed projections. -/
theorem isInternal_range [DecidableEq ι] {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    DirectSum.IsInternal fun a => LinearMap.range (Matrix.toLin' (Q a)) :=
  (DirectSum.isInternal_submodule_iff_iSupIndep_and_iSup_eq_top _).2
    ⟨iSupIndep_range h, iSup_range_eq_top h⟩

/-- The non-Archimedean form of the previous theorem. -/
theorem isInternal_range_stMat [DecidableEq ι] {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P) :
    DirectSum.IsInternal fun a => LinearMap.range (Matrix.toLin' (stMat (P a))) :=
  isInternal_range h.isPVM_stMat

/-- The observed decomposition is genuinely `Fintype.card n`-dimensional in total: the ranks of
the channels add up to the dimension (restatement of `sum_rank_eq_card` in terms of the ranges). -/
theorem sum_finrank_range_eq_card {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    ∑ a, Module.finrank ℝ (LinearMap.range (Matrix.toLin' (Q a))) = Fintype.card n :=
  sum_rank_eq_card h

end Geometry

end StandardPartPVM