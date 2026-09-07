/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Algebra.StandardPartPVMLifting

/-!
# Rigidity: approximate PVMs are infinitesimal perturbations of exact ones

Fourth instalment of the standard-part PVM programme (see `Algebra.StandardPartPVM` for the
descent theorem, `Algebra.StandardPartPVMFunctional` for the functional calculus and
`Algebra.StandardPartPVMLifting` for surjectivity of observation and the geometry of the
observed decomposition).

This file settles the first open conjecture recorded in `FUTURE_DIRECTIONS.md`
("Non-Archimedean Gram–Schmidt Rigidity") — and settles it in a *stronger* form than conjectured:
approximate symmetry is **not** needed for the rigidity statement itself, it is needed only if one
wants the exact model to be symmetric.

## Main results

* `StandardPartPVM.IsExactPVMH` — an *exact* projection-valued measure over the hyperreals
  (no infinitesimal slack at all).
* `StandardPartPVM.exists_exactPVMH_approx` — **rigidity**: every finite-entry approximate
  hyperreal PVM is entrywise infinitesimally close to an exact hyperreal PVM, namely to the
  canonical lift of its own observation.  Hence the approximate class is exactly an infinitesimal
  thickening of the (lifted) exact class.
* `StandardPartPVM.exists_symm_exactPVMH_approx` — the symmetric refinement: if moreover
  `(P a)ᵀ ≈ₕ P a` for all `a`, the exact model can be chosen with `(R a)ᵀ = R a`, i.e. an exact
  *orthogonal* resolution of the identity.
* `StandardPartPVM.exactPVMH_lift_unique` — the exact model produced this way is **unique** among
  lifts of real families: two real families with infinitesimally close lifts are equal.
* `StandardPartPVM.exists_approxPVM_not_exact_but_rigid` — the thickening is non-trivial: the
  `ε`-channel of `Algebra.StandardPartPVMLifting` is an approximate PVM which is *not* exact, yet
  is infinitesimally close to one.
* `StandardPartPVM.rank_eq_of_exactPVMH_approx`, `StandardPartPVM.sum_rank_exact_model_eq_card` —
  the exact model has the same observed ranks as the approximate family, and they quantize.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): `approx_iff_same_observation` says the fibres of observation are the
infinitesimal halos, and `isApproxPVM_hyperMat` says observation is onto.  Composing the two
should show that each halo already *contains* an exact PVM, i.e. that no approximate PVM is at
appreciable distance from the exact world.  Conjectured (previous cycle) to require approximate
symmetry.

Experiment (Experimenter): the composite `P ↦ hyperMat (stMat (P ·))` was tested against the
`ε`-channel `P 0 = !![1, ε; 0, 0]`, `P 1 = !![0, 0; 0, 1]`.  It returns `!![1,0;0,0]`, `!![0,0;0,1]`
— an exact PVM at entrywise distance `ε` from `P`.  No use of symmetry was made anywhere in the
computation, which falsified the conjectured necessity of the symmetry hypothesis.

Analysis (Analyst): the reason symmetry is irrelevant is that `stMat` is a *ring* map on
finite-entry matrices, so the exact identities are inherited by the lift entrywise; symmetry is a
`ᵀ`-statement, orthogonal to the multiplicative structure, and only propagates to the lift when
assumed (`stMat_transpose_eq_of_approx_symm`).  What symmetry buys is an *orthogonal* — as opposed
to merely idempotent — exact model.

Critique (Critic): rigidity would be vacuous if the exact model could always be taken to be `P`
itself; `exists_approxPVM_not_exact_but_rigid` rules that out by exhibiting an approximate PVM
that is genuinely inexact, so the theorem has content.  Uniqueness (`exactPVMH_lift_unique`) rules
out the opposite degeneracy, that "many" unrelated exact models sit in one halo: within lifts of
real families the model is unique, even though `P` itself may be a non-lift inhabitant of the halo.
-- !-- Lab Notes -- !--
-/

open Hyperreal Matrix Finset

namespace StandardPartPVM

variable {n ι : Type*}

/-! ## `hyperMat` is a ring map -/

@[simp] theorem hyperMat_zero : hyperMat (0 : Matrix n n ℝ) = 0 := by
  ext i j; simp [hyperMat]

@[simp] theorem hyperMat_one [DecidableEq n] : hyperMat (1 : Matrix n n ℝ) = 1 := by
  ext i j
  by_cases h : i = j <;> simp [hyperMat, Matrix.one_apply, h]

/-- The coercion `ℝ → ℝ*` commutes with finite sums. -/
theorem coe_finsetSum {α : Type*} (s : Finset α) (f : α → ℝ) :
    ((∑ i ∈ s, f i : ℝ) : ℝ*) = ∑ i ∈ s, ((f i : ℝ) : ℝ*) := by
  classical
  induction s using Finset.induction with
  | empty => simp
  | insert a s ha ih =>
      rw [Finset.sum_insert ha, Finset.sum_insert ha, Hyperreal.coe_add, ih]

theorem hyperMat_mul [Fintype n] (A B : Matrix n n ℝ) :
    hyperMat (A * B) = hyperMat A * hyperMat B := by
  ext i j
  simp only [hyperMat_apply, Matrix.mul_apply]
  rw [coe_finsetSum]
  exact Finset.sum_congr rfl fun k _ => Hyperreal.coe_mul _ _

theorem hyperMat_sum [Fintype ι] (Q : ι → Matrix n n ℝ) :
    hyperMat (∑ a, Q a) = ∑ a, hyperMat (Q a) := by
  ext i j
  simp only [hyperMat_apply, Matrix.sum_apply]
  exact coe_finsetSum _ _

theorem hyperMat_transpose (A : Matrix n n ℝ) : hyperMat Aᵀ = (hyperMat A)ᵀ := by
  ext i j; rfl

theorem hyperMat_injective : Function.Injective (hyperMat : Matrix n n ℝ → Matrix n n ℝ*) := by
  intro A B h
  have := congrArg stMat h
  simpa using this

/-! ## Exact hyperreal projection-valued measures -/

section Exact

variable [Fintype n] [DecidableEq n] [Fintype ι]

/-- An **exact** projection-valued measure over the hyperreals: idempotent, pairwise orthogonal
and resolving the identity *on the nose*, with no infinitesimal slack. -/
structure IsExactPVMH (R : ι → Matrix n n ℝ*) : Prop where
  idem : ∀ a, R a * R a = R a
  orth : ∀ a b, a ≠ b → R a * R b = 0
  total : ∑ a, R a = 1

/-- An exact hyperreal PVM is in particular an approximate one (with zero slack). -/
theorem IsExactPVMH.isApproxPVM {R : ι → Matrix n n ℝ*} (h : IsExactPVMH R)
    (hfin : ∀ a, FiniteEntries (R a)) : IsApproxPVM R where
  finite := hfin
  orth := by
    intro a b hab
    rw [h.orth a b hab]
    intro i j; simpa using infinitesimal_zero
  total := by
    rw [h.total]
    intro i j; simpa using infinitesimal_zero

/-- The canonical lift of a real PVM is an exact hyperreal PVM. -/
theorem isExactPVMH_hyperMat {Q : ι → Matrix n n ℝ} (h : IsPVM Q) :
    IsExactPVMH (fun a => hyperMat (Q a)) where
  idem a := by rw [← hyperMat_mul, h.idem a]
  orth a b hab := by rw [← hyperMat_mul, h.orth a b hab, hyperMat_zero]
  total := by rw [← hyperMat_sum, h.total, hyperMat_one]

/-! ## Rigidity -/

/-- **Rigidity of approximate PVMs.**  Every finite-entry approximate hyperreal projection-valued
measure is entrywise infinitesimally close to an *exact* hyperreal projection-valued measure,
namely to the canonical lift of its own observation.  The approximate class is therefore precisely
an infinitesimal thickening of the class of lifted exact PVMs.

No symmetry hypothesis is required — contrary to the shape in which this was conjectured. -/
theorem exists_exactPVMH_approx {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P) :
    ∃ R : ι → Matrix n n ℝ*, IsExactPVMH R ∧ (∀ a, FiniteEntries (R a)) ∧
      (∀ a, P a ≈ₕ R a) ∧ (∀ a, stMat (R a) = stMat (P a)) := by
  refine ⟨fun a => hyperMat (stMat (P a)), isExactPVMH_hyperMat h.isPVM_stMat,
    fun a => finiteEntries_hyperMat _, fun a => ?_, fun a => by simp⟩
  refine (approxEq_iff_stMat_eq (h.finite a) (finiteEntries_hyperMat _)).2 ?_
  simp

/-- **Symmetric rigidity.**  If in addition the family is approximately symmetric, the exact model
can be chosen symmetric: an exact *orthogonal* resolution of the identity over `ℝ*`. -/
theorem exists_symm_exactPVMH_approx {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P)
    (hsymm : ∀ a, (P a)ᵀ ≈ₕ P a) :
    ∃ R : ι → Matrix n n ℝ*, IsExactPVMH R ∧ (∀ a, (R a)ᵀ = R a) ∧ (∀ a, P a ≈ₕ R a) := by
  refine ⟨fun a => hyperMat (stMat (P a)), isExactPVMH_hyperMat h.isPVM_stMat, fun a => ?_,
    fun a => (approxEq_iff_stMat_eq (h.finite a) (finiteEntries_hyperMat _)).2 (by simp)⟩
  rw [← hyperMat_transpose, stMat_transpose_eq_of_approx_symm (h.finite a) (hsymm a)]

omit [Fintype n] [DecidableEq n] [Fintype ι] in
/-- **Uniqueness of the exact model among lifts.**  Two real families whose canonical lifts are
infinitesimally close are equal; so the exact PVM produced by `exists_exactPVMH_approx` is the
only lifted exact PVM in the infinitesimal halo of `P`. -/
theorem exactPVMH_lift_unique {Q Q' : ι → Matrix n n ℝ}
    (h : ∀ a, hyperMat (Q a) ≈ₕ hyperMat (Q' a)) : Q = Q' := by
  funext a
  have := (approxEq_iff_stMat_eq (finiteEntries_hyperMat (Q a))
    (finiteEntries_hyperMat (Q' a))).1 (h a)
  simpa using this

omit [DecidableEq n] [Fintype ι] in
/-- The observed ranks of the exact model agree with the observed ranks of the approximate
family. -/
theorem rank_eq_of_exactPVMH_approx {P R : ι → Matrix n n ℝ*} (hP : ∀ a, FiniteEntries (P a))
    (hR : ∀ a, FiniteEntries (R a)) (h : ∀ a, P a ≈ₕ R a) (a : ι) :
    (stMat (R a)).rank = (stMat (P a)).rank :=
  ((approxEq_iff_stMat_eq (hP a) (hR a)).1 (h a)).symm ▸ rfl

/-- Combined with dimension quantization: the ranks of the exact model of an approximate PVM sum
to the dimension of the space. -/
theorem sum_rank_exact_model_eq_card {P : ι → Matrix n n ℝ*} (h : IsApproxPVM P) :
    ∑ a, (stMat (hyperMat (stMat (P a)))).rank = Fintype.card n := by
  simpa using sum_rank_eq_card h.isPVM_stMat

end Exact

/-! ## The thickening is non-trivial -/

section NonTrivial

/-- **Rigidity has content.**  There is an approximate PVM which is *not* an exact PVM — its
channels genuinely fail to be orthogonal and its total genuinely differs from the identity — and
yet it is infinitesimally close to an exact hyperreal PVM.  So the inclusion
`{exact PVMs} ⊆ {approximate PVMs}` is strict, while the halo of every approximate PVM meets the
exact class. -/
theorem exists_approxPVM_not_exact_but_rigid :
    ∃ P : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ*,
      IsApproxPVM P ∧ ¬ IsExactPVMH P ∧
      ∃ R : Fin 2 → Matrix (Fin 2) (Fin 2) ℝ*, IsExactPVMH R ∧ ∀ a, P a ≈ₕ R a := by
  obtain ⟨R, hR, -, happrox, -⟩ := exists_exactPVMH_approx isApproxPVM_epsChannel
  refine ⟨epsChannel, isApproxPVM_epsChannel, ?_, R, hR, happrox⟩
  intro hexact
  have hzero : epsChannel 0 * epsChannel 1 = 0 := hexact.orth 0 1 (by decide)
  rw [epsChannel_zero_mul_one] at hzero
  exact epsilon_pos.ne' (by simpa using congrFun (congrFun hzero 0) 1)

end NonTrivial

end StandardPartPVM