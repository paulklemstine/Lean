/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Algebra.StandardPartPVM

/-!
# Functional calculus and coarse-graining for standard-part projection-valued measures

This file continues `Algebra.StandardPartPVM`.  There the *descent theorem* was proved: a family
of hyperreal matrices with finite entries has a projection-valued standard part exactly when it is
pairwise orthogonal up to infinitesimals and complete up to infinitesimals.  Here we determine
*which further structure* survives the observation map `stMat`.

## Main results

* `StandardPartPVM.stMat_pow`, `StandardPartPVM.stMat_polyEval` — **polynomial identities survive
  observation**: for a finite-entry hyperreal matrix `A` and a real polynomial `p`,
  `stMat (p(A)) = p (stMat A)`.  `StandardPartPVM.polyEvalR_eq_aeval` identifies the real side
  with Mathlib's `Polynomial.aeval`.
* `StandardPartPVM.polyEval_eq_zero_of_approx` — **approximate annihilators become exact**: if a
  real polynomial annihilates a finite-entry hyperreal matrix up to an infinitesimal, it
  annihilates the observed matrix exactly.  Approximate idempotency (`X² - X`) and approximate
  involutivity (`X² - 1`) are instances.
* `StandardPartPVM.coarse_isPVM` — **coarse-graining a PVM along any map of index sets again gives
  a PVM**, and `StandardPartPVM.isApproxPVM_coarseH` transports this to hyperreal approximate
  PVMs.  Physically: channels may be merged without leaving the class of measurements.
* `StandardPartPVM.stMat_spectral`, `StandardPartPVM.stMat_spectral_coarse` — **spectral collapse**:
  a hyperreal spectral decomposition `∑ λ a • P a` with finite eigenvalues is observed as a real
  spectral decomposition whose projections are the coarse-grained standard parts; eigenvalues that
  are infinitesimally close are merged into a single observed spectral line.
* `StandardPartPVM.bornWeight_coarse` — the observed Born measure of a coarse-grained PVM is the
  pushforward of the original one.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): after the descent theorem, the natural next conjecture is that the
entire *real polynomial functional calculus* commutes with observation, and that observation is
compatible with merging of channels (coarse graining).  A bolder sub-conjecture: infinitesimally
separated eigenvalues cannot be distinguished by any real observation, so a hyperreal spectral
decomposition always collapses to a *coarser* real one.

Experiment (Experimenter): `stMat_pow` was proved by induction on the exponent from
`stMat_mul`; the polynomial statement then follows by expanding `aeval` as
`∑ i ∈ range (natDegree + 1), coeff i • x ^ i`.  Note that Mathlib has no `Algebra ℝ ℝ*`
instance, so the hyperreal side is written with the explicit coercion of coefficients
(`polyEvalH`) and matched with `Polynomial.aeval` on the real side (`polyEvalR_eq_aeval`).

Analysis (Analyst): the whole obstruction to descent is again *infiniteness of entries*; every
polynomial identity, and every coarse-graining, passes through unharmed once entries are finite.
The coarse-graining theorem also re-proves idempotency of the merged projections from
orthogonality plus completeness, confirming the redundancy pattern observed in the first cycle.

Critique (Critic): `polyEval_eq_zero_of_approx` is not vacuous — its hypothesis is satisfiable
(e.g. by any exact real idempotent viewed in `ℝ*`, and by genuinely infinitesimally perturbed
matrices), and its conclusion is a nontrivial exact identity.  `coarse_isPVM` is not a tautology:
orthogonality across fibres requires a double-sum argument, and completeness uses
`Finset.sum_fiberwise`.
-- !-- Lab Notes -- !--
-/

open Hyperreal Matrix Finset

namespace StandardPartPVM

variable {n ι κ : Type*}

/-! ## Finset-indexed standard parts -/

theorem FiniteEntries.finsetSum {α : Type*} {s : Finset α} {F : α → Matrix n n ℝ*}
    (h : ∀ a ∈ s, FiniteEntries (F a)) : FiniteEntries (∑ a ∈ s, F a) := by
  intro i j
  rw [Matrix.sum_apply]
  exact not_infinite_sum fun a ha => h a ha i j

theorem stMat_finsetSum {α : Type*} {s : Finset α} {F : α → Matrix n n ℝ*}
    (h : ∀ a ∈ s, FiniteEntries (F a)) :
    stMat (∑ a ∈ s, F a) = ∑ a ∈ s, stMat (F a) := by
  ext i j
  simp only [stMat_apply, Matrix.sum_apply]
  exact st_sum fun a ha => h a ha i j

/-- Multiplication by a finite hyperreal scalar commutes with observation. -/
theorem stMat_smul {c : ℝ*} {A : Matrix n n ℝ*} (hc : ¬Infinite c) (hA : FiniteEntries A) :
    stMat (c • A) = st c • stMat A := by
  ext i j
  simpa [Matrix.smul_apply, smul_eq_mul] using st_mul hc (hA i j)

theorem FiniteEntries.smul {c : ℝ*} {A : Matrix n n ℝ*} (hc : ¬Infinite c)
    (hA : FiniteEntries A) : FiniteEntries (c • A) := by
  intro i j
  simpa [Matrix.smul_apply, smul_eq_mul] using not_infinite_mul hc (hA i j)

/-! ## Powers and the real polynomial functional calculus -/

section Powers

variable [Fintype n] [DecidableEq n]

theorem FiniteEntries.pow {A : Matrix n n ℝ*} (hA : FiniteEntries A) :
    ∀ k : ℕ, FiniteEntries (A ^ k)
  | 0 => by simpa using finiteEntries_one
  | k + 1 => by
      rw [pow_succ]
      exact (hA.pow k).mul hA

/-- **Powers survive observation.** -/
theorem stMat_pow {A : Matrix n n ℝ*} (hA : FiniteEntries A) :
    ∀ k : ℕ, stMat (A ^ k) = (stMat A) ^ k
  | 0 => by simp
  | k + 1 => by
      rw [pow_succ, stMat_mul (hA.pow k) hA, stMat_pow hA k, ← pow_succ]

/-- Evaluation of a *real* polynomial at a hyperreal matrix, with coefficients coerced into
`ℝ*`.  (Mathlib provides no `Algebra ℝ ℝ*` instance, so this is spelled out.) -/
noncomputable def polyEvalH (p : Polynomial ℝ) (A : Matrix n n ℝ*) : Matrix n n ℝ* :=
  ∑ i ∈ Finset.range (p.natDegree + 1), ((p.coeff i : ℝ) : ℝ*) • A ^ i

/-- Evaluation of a real polynomial at a real matrix. -/
noncomputable def polyEvalR (p : Polynomial ℝ) (M : Matrix n n ℝ) : Matrix n n ℝ :=
  ∑ i ∈ Finset.range (p.natDegree + 1), p.coeff i • M ^ i

/-- `polyEvalR` is Mathlib's `Polynomial.aeval`. -/
theorem polyEvalR_eq_aeval (p : Polynomial ℝ) (M : Matrix n n ℝ) :
    polyEvalR p M = Polynomial.aeval M p :=
  (Polynomial.aeval_eq_sum_range M).symm

theorem finiteEntries_polyEvalH {A : Matrix n n ℝ*} (hA : FiniteEntries A) (p : Polynomial ℝ) :
    FiniteEntries (polyEvalH p A) := by
  refine FiniteEntries.finsetSum fun i _ => ?_
  exact FiniteEntries.smul (not_infinite_real _) (hA.pow i)

/-- **The real polynomial functional calculus survives observation.** For a hyperreal matrix with
finite entries and any real polynomial `p`, the observed value of `p(A)` is `p` evaluated at the
observed matrix. -/
theorem stMat_polyEval (p : Polynomial ℝ) {A : Matrix n n ℝ*} (hA : FiniteEntries A) :
    stMat (polyEvalH p A) = polyEvalR p (stMat A) := by
  rw [polyEvalH, stMat_finsetSum fun i _ => FiniteEntries.smul (not_infinite_real _) (hA.pow i)]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [stMat_smul (not_infinite_real _) (hA.pow i), stMat_pow hA i, st_id_real]

/-- **Approximate annihilators become exact annihilators.** If a real polynomial annihilates a
finite-entry hyperreal matrix up to an infinitesimal error, it annihilates the observed matrix
exactly. -/
theorem polyEval_eq_zero_of_approx (p : Polynomial ℝ) {A : Matrix n n ℝ*} (hA : FiniteEntries A)
    (h : InfinitesimalEntries (polyEvalH p A)) :
    Polynomial.aeval (stMat A) p = 0 := by
  rw [← polyEvalR_eq_aeval, ← stMat_polyEval p hA]
  exact (infinitesimalEntries_iff_stMat_eq_zero (finiteEntries_polyEvalH hA p)).1 h

/-- An approximate involution is observed as an exact involution (`X² - 1`). -/
theorem stMat_mul_self_eq_one_of_approx {A : Matrix n n ℝ*} (hA : FiniteEntries A)
    (h : (A * A) ≈ₕ 1) : stMat A * stMat A = 1 := by
  have : stMat (A * A) = stMat (1 : Matrix n n ℝ*) :=
    (approxEq_iff_stMat_eq (hA.mul hA) finiteEntries_one).1 h
  rwa [stMat_mul hA hA, stMat_one] at this

end Powers

section Idempotents

variable [Fintype n]

/-- An approximately idempotent finite-entry hyperreal matrix is observed as an exact
idempotent — the polynomial `X² - X` version of the previous theorem. -/
theorem isIdempotentElem_stMat_of_approx {A : Matrix n n ℝ*} (hA : FiniteEntries A)
    (h : (A * A) ≈ₕ A) : IsIdempotentElem (stMat A) := by
  have hst : stMat (A * A) = stMat A := (approxEq_iff_stMat_eq (hA.mul hA) hA).1 h
  rw [stMat_mul hA hA] at hst
  exact hst

end Idempotents

/-! ## Coarse-graining: merging measurement channels -/

section CoarseGraining

variable [Fintype ι] [DecidableEq κ]

/-- Coarse-graining of a real PVM along a map of index sets: the `k`-th channel of the coarse
measurement is the sum of all fine channels lying over `k`. -/
noncomputable def coarse (Q : ι → Matrix n n ℝ) (f : ι → κ) (k : κ) : Matrix n n ℝ :=
  ∑ a ∈ Finset.univ.filter (fun a => f a = k), Q a

/-- Coarse-graining of a hyperreal family. -/
noncomputable def coarseH (P : ι → Matrix n n ℝ*) (f : ι → κ) (k : κ) : Matrix n n ℝ* :=
  ∑ a ∈ Finset.univ.filter (fun a => f a = k), P a

theorem finiteEntries_coarseH {P : ι → Matrix n n ℝ*} (hfin : ∀ a, FiniteEntries (P a))
    (f : ι → κ) (k : κ) : FiniteEntries (coarseH P f k) :=
  FiniteEntries.finsetSum fun a _ => hfin a

theorem stMat_coarseH {P : ι → Matrix n n ℝ*} (hfin : ∀ a, FiniteEntries (P a)) (f : ι → κ)
    (k : κ) : stMat (coarseH P f k) = coarse (fun a => stMat (P a)) f k :=
  stMat_finsetSum fun a _ => hfin a

section PVMCoarse

variable [Fintype n] [DecidableEq n] [Fintype κ]

/-- **Coarse-graining preserves the PVM property.** Merging measurement channels along any map
`f : ι → κ` sends projection-valued measures to projection-valued measures. -/
theorem coarse_isPVM {Q : ι → Matrix n n ℝ} (h : IsPVM Q) (f : ι → κ) :
    IsPVM (coarse Q f) := by
  have horth : ∀ k l, k ≠ l → coarse Q f k * coarse Q f l = 0 := by
    intro k l hkl
    rw [coarse, coarse, Finset.sum_mul]
    refine Finset.sum_eq_zero fun a ha => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_eq_zero fun b hb => ?_
    have hfa : f a = k := (Finset.mem_filter.1 ha).2
    have hfb : f b = l := (Finset.mem_filter.1 hb).2
    refine h.orth a b ?_
    intro hab
    exact hkl (by rw [← hfa, hab, hfb])
  have htot : ∑ k, coarse Q f k = 1 := by
    rw [← h.total]
    exact Finset.sum_fiberwise Finset.univ f Q
  exact ⟨isIdempotent_of_orth_of_total horth htot, horth, htot⟩

/-- **Coarse-graining of hyperreal approximate PVMs.** Merging channels of a hyperreal
approximate PVM again produces a hyperreal approximate PVM; in particular the merged family still
descends to a real projection-valued measure. -/
theorem isApproxPVM_coarseH {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P) (f : ι → κ) :
    IsApproxPVM (coarseH P f) := by
  refine (isApproxPVM_iff_isPVM_stMat (fun k => finiteEntries_coarseH h.finite f k)).2 ?_
  have : (fun k => stMat (coarseH P f k)) = coarse (fun a => stMat (P a)) f := by
    funext k
    exact stMat_coarseH h.finite f k
  rw [this]
  exact coarse_isPVM h.isPVM_stMat f

end PVMCoarse

section BornPushforward

variable [Fintype n]

/-- The observed Born measure of a coarse-grained PVM is the pushforward of the fine one. -/
theorem bornWeight_coarse (Q : ι → Matrix n n ℝ) (f : ι → κ) (v : n → ℝ) (k : κ) :
    bornWeight (coarse Q f) v k = ∑ a ∈ Finset.univ.filter (fun a => f a = k), bornWeight Q v a := by
  simp only [bornWeight, coarse, Matrix.sum_mulVec, dotProduct_sum]

end BornPushforward

end CoarseGraining

/-! ## Spectral collapse -/

section Spectral

variable [Fintype ι]

/-- **Observation of a hyperreal spectral decomposition.** -/
theorem stMat_spectral {P : ι → Matrix n n ℝ*} (hfin : ∀ a, FiniteEntries (P a)) {lam : ι → ℝ*}
    (hlam : ∀ a, ¬Infinite (lam a)) :
    stMat (∑ a, lam a • P a) = ∑ a, st (lam a) • stMat (P a) := by
  rw [stMat_finsetSum fun a _ => FiniteEntries.smul (hlam a) (hfin a)]
  exact Finset.sum_congr rfl fun a _ => stMat_smul (hlam a) (hfin a)

variable [Fintype κ] [DecidableEq κ]

/-- **Spectral collapse.** Suppose a hyperreal operator has a spectral decomposition
`∑ a, lam a • P a` with finite eigenvalues, and suppose the observed eigenvalue `st (lam a)`
depends only on the class `f a` of `a`.  Then the observed operator is a genuine real spectral
decomposition over the *coarse-grained* projections: infinitesimally separated spectral lines are
merged by observation into a single line.  When `P` is an approximate PVM the coarse family is a
real PVM by `coarse_isPVM`. -/
theorem stMat_spectral_coarse {P : ι → Matrix n n ℝ*} (hfin : ∀ a, FiniteEntries (P a))
    {lam : ι → ℝ*} (hlam : ∀ a, ¬Infinite (lam a)) (f : ι → κ) (mu : κ → ℝ)
    (hsep : ∀ a, st (lam a) = mu (f a)) :
    stMat (∑ a, lam a • P a) = ∑ k, mu k • coarse (fun a => stMat (P a)) f k := by
  rw [stMat_spectral hfin hlam]
  have hfib : ∑ a, st (lam a) • stMat (P a)
      = ∑ k, ∑ a ∈ Finset.univ.filter (fun a => f a = k), st (lam a) • stMat (P a) :=
    (Finset.sum_fiberwise Finset.univ f fun a => st (lam a) • stMat (P a)).symm
  rw [hfib]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [coarse, Finset.smul_sum]
  refine Finset.sum_congr rfl fun a ha => ?_
  rw [hsep a, (Finset.mem_filter.1 ha).2]

end Spectral

end StandardPartPVM